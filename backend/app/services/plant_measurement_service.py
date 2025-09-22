from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import json
import statistics
import math
from enum import Enum

from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog

class MeasurementMethod(str, Enum):
    AR = "ar"
    MANUAL = "manual"
    PHOTO_ANALYSIS = "photo_analysis"

class PlantMeasurementService:
    def __init__(self):
        pass

    async def record_ar_measurement(
        self,
        db: Session,
        plant_id: str,
        user_id: str,
        measurement_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Record an AR-based plant measurement."""
        
        plant = db.query(UserPlant).filter(
            UserPlant.id == plant_id,
            UserPlant.user_id == user_id
        ).first()
        
        if not plant:
            raise ValueError("Plant not found or access denied")
        
        processed_measurement = await self._process_ar_measurement(measurement_data)
        
        care_log = PlantCareLog(
            plant_id=plant_id,
            care_type="measurement",
            notes=json.dumps({
                "measurement_type": measurement_data.get("measurement_type"),
                "value": processed_measurement["value"],
                "unit": processed_measurement["unit"],
                "confidence_score": processed_measurement["confidence"],
                "method": MeasurementMethod.AR,
                "ar_data": measurement_data.get("ar_data", {})
            }),
            created_at=datetime.utcnow()
        )
        
        db.add(care_log)
        db.commit()
        db.refresh(care_log)
        
        return {
            "measurement_id": str(care_log.id),
            "plant_id": plant_id,
            "measurement_type": measurement_data.get("measurement_type"),
            "value": processed_measurement["value"],
            "unit": processed_measurement["unit"],
            "confidence_score": processed_measurement["confidence"],
            "timestamp": care_log.created_at.isoformat()
        }

    async def get_plant_measurement_history(
        self,
        db: Session,
        plant_id: str,
        measurement_type: Optional[str] = None,
        time_range: int = 90
    ) -> Dict[str, Any]:
        """Get measurement history for a plant."""
        
        start_date = datetime.utcnow() - timedelta(days=time_range)
        
        measurements = db.query(PlantCareLog).filter(
            PlantCareLog.plant_id == plant_id,
            PlantCareLog.care_type == "measurement",
            PlantCareLog.created_at >= start_date
        ).order_by(PlantCareLog.created_at.desc()).all()
        
        processed_measurements = []
        for measurement in measurements:
            try:
                measurement_data = json.loads(measurement.notes)
                
                if measurement_type and measurement_data.get("measurement_type") != measurement_type:
                    continue
                
                processed_measurements.append({
                    "id": str(measurement.id),
                    "timestamp": measurement.created_at.isoformat(),
                    "measurement_type": measurement_data.get("measurement_type"),
                    "value": measurement_data.get("value"),
                    "unit": measurement_data.get("unit"),
                    "confidence_score": measurement_data.get("confidence_score", 0),
                    "method": measurement_data.get("method", "unknown")
                })
            except (json.JSONDecodeError, KeyError):
                continue
        
        return {
            "plant_id": plant_id,
            "measurement_type": measurement_type,
            "total_measurements": len(processed_measurements),
            "measurements": processed_measurements
        }

    async def _process_ar_measurement(self, measurement_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process and validate AR measurement data."""
        
        raw_value = measurement_data.get("value", 0)
        unit = measurement_data.get("unit", "cm")
        confidence = measurement_data.get("confidence_score", 0.5)
        
        normalized_value = self._normalize_to_cm(raw_value, unit)
        
        return {
            "value": round(normalized_value, 2),
            "unit": "cm",
            "confidence": confidence
        }

    def _normalize_to_cm(self, value: float, unit: str) -> float:
        """Normalize measurement to centimeters."""
        
        conversion_factors = {
            "mm": 0.1,
            "cm": 1.0,
            "m": 100.0,
            "inches": 2.54,
            "ft": 30.48
        }
        
        return value * conversion_factors.get(unit.lower(), 1.0)
