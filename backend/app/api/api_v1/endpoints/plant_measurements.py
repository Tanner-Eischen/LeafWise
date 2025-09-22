"""
Plant Measurement API endpoints for AR-based plant size tracking.
"""

from typing import Dict, Any, Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.plant_measurement_service import PlantMeasurementService
from app.services.auth_service import get_current_user_from_token as get_current_user
from app.models.user import User

router = APIRouter()

class ARMeasurementRequest(BaseModel):
    measurement_type: str  # height, width, diameter, etc.
    value: float
    unit: str = "cm"
    confidence_score: float
    reference_points: List[Dict[str, float]] = []
    calibration_data: Dict[str, Any] = {}
    device_info: Dict[str, Any] = {}

def get_measurement_service():
    return PlantMeasurementService()

@router.post("/ar/{plant_id}")
async def record_ar_measurement(
    plant_id: str,
    measurement_request: ARMeasurementRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    measurement_service: PlantMeasurementService = Depends(get_measurement_service)
) -> Dict[str, Any]:
    """Record an AR-based plant measurement."""
    
    try:
        measurement_data = {
            "measurement_type": measurement_request.measurement_type,
            "value": measurement_request.value,
            "unit": measurement_request.unit,
            "confidence_score": measurement_request.confidence_score,
            "ar_data": {
                "reference_points": measurement_request.reference_points,
                "calibration_data": measurement_request.calibration_data,
                "device_info": measurement_request.device_info
            }
        }
        
        result = await measurement_service.record_ar_measurement(
            db=db,
            plant_id=plant_id,
            user_id=current_user.id,
            measurement_data=measurement_data
        )
        
        return result
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to record measurement: {str(e)}")

@router.get("/history/{plant_id}")
async def get_measurement_history(
    plant_id: str,
    measurement_type: Optional[str] = Query(None, description="Filter by measurement type"),
    time_range: int = Query(90, ge=7, le=365, description="Days to look back"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    measurement_service: PlantMeasurementService = Depends(get_measurement_service)
) -> Dict[str, Any]:
    """Get measurement history for a plant."""
    
    try:
        history = await measurement_service.get_plant_measurement_history(
            db=db,
            plant_id=plant_id,
            measurement_type=measurement_type,
            time_range=time_range
        )
        
        return history
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve measurement history: {str(e)}")

@router.get("/calibration")
async def get_ar_calibration_data(
    device_model: str = Query(..., description="Device model for calibration"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    measurement_service: PlantMeasurementService = Depends(get_measurement_service)
) -> Dict[str, Any]:
    """Get AR calibration data for accurate measurements."""
    
    try:
        device_info = {"model": device_model}
        calibration_data = await measurement_service.get_ar_calibration_data(device_info)
        return calibration_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get calibration data: {str(e)}")

