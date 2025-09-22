"""Light meter manager service.

This module provides a unified interface for light measurement from multiple sources
using the strategy pattern. It coordinates between ALS, Camera, and BLE sensors
to provide accurate light readings with calibration support.
"""

from abc import ABC, abstractmethod
from datetime import datetime
from typing import Dict, List, Optional, Any, Union
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.models.telemetry import LightReading, CalibrationProfile, BLEDevice, LightSource
from app.models.user import User


class LightMeasurementResult:
    """Result of a light measurement operation.
    
    Contains the measured values, metadata, and quality indicators.
    """
    
    def __init__(
        self,
        lux_value: float,
        source: LightSource,
        ppfd_value: Optional[float] = None,
        accuracy_estimate: Optional[float] = None,
        confidence_score: Optional[float] = None,
        calibration_applied: bool = False,
        device_id: Optional[str] = None,
        raw_data: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None
    ):
        """Initialize measurement result.
        
        Args:
            lux_value: Measured light intensity in lux
            source: Light measurement source
            ppfd_value: Optional PPFD measurement
            accuracy_estimate: Estimated accuracy percentage
            confidence_score: ML confidence score (0-1)
            calibration_applied: Whether calibration was applied
            device_id: Device identifier
            raw_data: Raw sensor data
            error_message: Error message if measurement failed
        """
        self.lux_value = lux_value
        self.source = source
        self.ppfd_value = ppfd_value
        self.accuracy_estimate = accuracy_estimate
        self.confidence_score = confidence_score
        self.calibration_applied = calibration_applied
        self.device_id = device_id
        self.raw_data = raw_data or {}
        self.error_message = error_message
        self.timestamp = datetime.utcnow()
    
    @property
    def is_valid(self) -> bool:
        """Check if measurement is valid.
        
        Returns:
            bool: True if measurement is valid
        """
        return self.error_message is None and self.lux_value >= 0
    
    @property
    def estimated_ppfd(self) -> Optional[float]:
        """Get PPFD value or estimate from lux.
        
        Returns:
            Optional[float]: PPFD value
        """
        if self.ppfd_value is not None:
            return self.ppfd_value
        
        # Rough conversion: 1 μmol/m²/s ≈ 54 lux for sunlight
        return self.lux_value / 54.0 if self.lux_value > 0 else None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert result to dictionary.
        
        Returns:
            Dict[str, Any]: Result as dictionary
        """
        return {
            "lux_value": self.lux_value,
            "source": self.source.value,
            "ppfd_value": self.ppfd_value,
            "estimated_ppfd": self.estimated_ppfd,
            "accuracy_estimate": self.accuracy_estimate,
            "confidence_score": self.confidence_score,
            "calibration_applied": self.calibration_applied,
            "device_id": self.device_id,
            "raw_data": self.raw_data,
            "error_message": self.error_message,
            "timestamp": self.timestamp.isoformat(),
            "is_valid": self.is_valid
        }


class LightMeterStrategy(ABC):
    """Abstract base class for light measurement strategies.
    
    Each strategy implements a specific method for measuring light
    (ALS, Camera, BLE) with its own calibration and accuracy characteristics.
    """
    
    def __init__(self, db: AsyncSession):
        """Initialize strategy.
        
        Args:
            db: Database session
        """
        self.db = db
    
    @abstractmethod
    async def measure_light(
        self,
        user_id: UUID,
        calibration_profile: Optional[CalibrationProfile] = None,
        **kwargs
    ) -> LightMeasurementResult:
        """Measure light using this strategy.
        
        Args:
            user_id: User requesting measurement
            calibration_profile: Optional calibration profile
            **kwargs: Strategy-specific parameters
            
        Returns:
            LightMeasurementResult: Measurement result
        """
        pass
    
    @abstractmethod
    async def is_available(self, user_id: UUID) -> bool:
        """Check if this strategy is available for use.
        
        Args:
            user_id: User ID
            
        Returns:
            bool: True if strategy is available
        """
        pass
    
    @abstractmethod
    def get_source_type(self) -> LightSource:
        """Get the light source type for this strategy.
        
        Returns:
            LightSource: Source type
        """
        pass
    
    @abstractmethod
    async def calibrate(
        self,
        user_id: UUID,
        reference_lux: float,
        **kwargs
    ) -> CalibrationProfile:
        """Perform calibration for this strategy.
        
        Args:
            user_id: User performing calibration
            reference_lux: Reference light measurement
            **kwargs: Strategy-specific calibration parameters
            
        Returns:
            CalibrationProfile: Created calibration profile
        """
        pass
    
    async def get_calibration_profile(
        self,
        user_id: UUID
    ) -> Optional[CalibrationProfile]:
        """Get active calibration profile for this strategy.
        
        Args:
            user_id: User ID
            
        Returns:
            Optional[CalibrationProfile]: Active calibration profile
        """
        result = await self.db.execute(
            select(CalibrationProfile).where(
                CalibrationProfile.user_id == user_id,
                CalibrationProfile.sensor_type == self.get_source_type().value,
                CalibrationProfile.status == "completed"
            ).order_by(CalibrationProfile.created_at.desc()).limit(1)
        )
        
        profile = result.scalar_one_or_none()
        return profile if profile and profile.is_active else None
    
    def apply_calibration(
        self,
        raw_value: float,
        calibration_profile: Optional[CalibrationProfile]
    ) -> tuple[float, bool]:
        """Apply calibration to raw measurement.
        
        Args:
            raw_value: Raw sensor reading
            calibration_profile: Calibration profile to apply
            
        Returns:
            tuple[float, bool]: (calibrated_value, was_calibrated)
        """
        if calibration_profile and calibration_profile.is_active:
            calibrated_value = calibration_profile.apply_calibration(raw_value)
            return calibrated_value, True
        
        return raw_value, False


class LightMeterManager:
    """Manager for coordinating light measurements across multiple strategies.
    
    Provides a unified interface for light measurement, automatically selecting
    the best available strategy and applying appropriate calibration.
    """
    
    def __init__(self, db: AsyncSession):
        """Initialize light meter manager.
        
        Args:
            db: Database session
        """
        self.db = db
        self.strategies: Dict[LightSource, LightMeterStrategy] = {}
        self._strategy_priority = [
            LightSource.BLE,     # Highest priority - external sensors
            LightSource.ALS,     # Medium priority - device sensors
            LightSource.CAMERA   # Lowest priority - camera estimation
        ]
    
    def register_strategy(self, strategy: LightMeterStrategy) -> None:
        """Register a light measurement strategy.
        
        Args:
            strategy: Strategy to register
        """
        source_type = strategy.get_source_type()
        self.strategies[source_type] = strategy
    
    async def measure_light(
        self,
        user_id: UUID,
        preferred_source: Optional[LightSource] = None,
        plant_id: Optional[UUID] = None,
        location_name: Optional[str] = None,
        **kwargs
    ) -> LightMeasurementResult:
        """Measure light using the best available strategy.
        
        Args:
            user_id: User requesting measurement
            preferred_source: Preferred light source
            plant_id: Optional plant ID for context
            location_name: Optional location name
            **kwargs: Strategy-specific parameters
            
        Returns:
            LightMeasurementResult: Measurement result
        """
        # Try preferred source first if specified
        if preferred_source and preferred_source in self.strategies:
            strategy = self.strategies[preferred_source]
            if await strategy.is_available(user_id):
                calibration_profile = await strategy.get_calibration_profile(user_id)
                return await strategy.measure_light(
                    user_id, calibration_profile, **kwargs
                )
        
        # Try strategies in priority order
        for source_type in self._strategy_priority:
            if source_type in self.strategies:
                strategy = self.strategies[source_type]
                if await strategy.is_available(user_id):
                    try:
                        calibration_profile = await strategy.get_calibration_profile(user_id)
                        return await strategy.measure_light(
                            user_id, calibration_profile, **kwargs
                        )
                    except Exception as e:
                        # Log error and try next strategy
                        continue
        
        # No strategies available
        return LightMeasurementResult(
            lux_value=0.0,
            source=LightSource.MANUAL,
            error_message="No light measurement strategies available"
        )
    
    async def measure_light_multi_source(
        self,
        user_id: UUID,
        sources: List[LightSource],
        **kwargs
    ) -> List[LightMeasurementResult]:
        """Measure light using multiple sources for comparison.
        
        Args:
            user_id: User requesting measurements
            sources: List of sources to use
            **kwargs: Strategy-specific parameters
            
        Returns:
            List[LightMeasurementResult]: Results from each source
        """
        results = []
        
        for source_type in sources:
            if source_type in self.strategies:
                strategy = self.strategies[source_type]
                if await strategy.is_available(user_id):
                    try:
                        calibration_profile = await strategy.get_calibration_profile(user_id)
                        result = await strategy.measure_light(
                            user_id, calibration_profile, **kwargs
                        )
                        results.append(result)
                    except Exception as e:
                        # Add error result
                        results.append(LightMeasurementResult(
                            lux_value=0.0,
                            source=source_type,
                            error_message=str(e)
                        ))
        
        return results
    
    async def get_available_sources(self, user_id: UUID) -> List[LightSource]:
        """Get list of available light sources for user.
        
        Args:
            user_id: User ID
            
        Returns:
            List[LightSource]: Available sources
        """
        available_sources = []
        
        for source_type, strategy in self.strategies.items():
            if await strategy.is_available(user_id):
                available_sources.append(source_type)
        
        return available_sources
    
    async def calibrate_source(
        self,
        user_id: UUID,
        source_type: LightSource,
        reference_lux: float,
        **kwargs
    ) -> CalibrationProfile:
        """Calibrate a specific light source.
        
        Args:
            user_id: User performing calibration
            source_type: Source to calibrate
            reference_lux: Reference measurement
            **kwargs: Strategy-specific parameters
            
        Returns:
            CalibrationProfile: Created calibration profile
            
        Raises:
            ValueError: If source is not available
        """
        if source_type not in self.strategies:
            raise ValueError(f"Strategy for {source_type} not registered")
        
        strategy = self.strategies[source_type]
        
        if not await strategy.is_available(user_id):
            raise ValueError(f"Strategy for {source_type} not available")
        
        return await strategy.calibrate(user_id, reference_lux, **kwargs)
    
    async def get_measurement_accuracy(
        self,
        user_id: UUID,
        source_type: LightSource
    ) -> Optional[float]:
        """Get estimated accuracy for a light source.
        
        Args:
            user_id: User ID
            source_type: Source type
            
        Returns:
            Optional[float]: Accuracy percentage or None
        """
        if source_type not in self.strategies:
            return None
        
        strategy = self.strategies[source_type]
        calibration_profile = await strategy.get_calibration_profile(user_id)
        
        if calibration_profile:
            return calibration_profile.accuracy_percentage
        
        # Return default accuracy estimates for uncalibrated sources
        default_accuracies = {
            LightSource.BLE: 85.0,      # External sensors are generally good
            LightSource.ALS: 70.0,      # Device sensors vary
            LightSource.CAMERA: 50.0,   # Camera estimation is rough
            LightSource.MANUAL: 60.0    # User input varies
        }
        
        return default_accuracies.get(source_type)
    
    async def save_measurement(
        self,
        user_id: UUID,
        result: LightMeasurementResult,
        plant_id: Optional[UUID] = None,
        location_name: Optional[str] = None,
        gps_latitude: Optional[float] = None,
        gps_longitude: Optional[float] = None,
        temperature: Optional[float] = None,
        humidity: Optional[float] = None
    ) -> LightReading:
        """Save measurement result to database.
        
        Args:
            user_id: User ID
            result: Measurement result
            plant_id: Optional plant ID
            location_name: Optional location name
            gps_latitude: Optional GPS latitude
            gps_longitude: Optional GPS longitude
            temperature: Optional temperature
            humidity: Optional humidity
            
        Returns:
            LightReading: Saved reading
        """
        # Get calibration profile if calibration was applied
        calibration_profile_id = None
        if result.calibration_applied and result.source in self.strategies:
            strategy = self.strategies[result.source]
            profile = await strategy.get_calibration_profile(user_id)
            if profile:
                calibration_profile_id = profile.id
        
        # Create light reading
        reading = LightReading(
            user_id=user_id,
            plant_id=plant_id,
            lux_value=result.lux_value,
            ppfd_value=result.ppfd_value,
            source=result.source.value,
            location_name=location_name,
            gps_latitude=gps_latitude,
            gps_longitude=gps_longitude,
            temperature=temperature,
            humidity=humidity,
            calibration_profile_id=calibration_profile_id,
            accuracy_estimate=result.accuracy_estimate,
            confidence_score=result.confidence_score,
            device_id=result.device_id,
            raw_data=result.raw_data,
            measured_at=result.timestamp
        )
        
        self.db.add(reading)
        await self.db.commit()
        await self.db.refresh(reading)
        
        return reading
    
    def get_strategy_info(self) -> Dict[str, Dict[str, Any]]:
        """Get information about registered strategies.
        
        Returns:
            Dict[str, Dict[str, Any]]: Strategy information
        """
        info = {}
        
        for source_type, strategy in self.strategies.items():
            info[source_type.value] = {
                "source_type": source_type.value,
                "strategy_class": strategy.__class__.__name__,
                "priority": self._strategy_priority.index(source_type) if source_type in self._strategy_priority else -1
            }
        
        return info