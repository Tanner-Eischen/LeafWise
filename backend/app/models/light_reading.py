"""Light reading database model.

This module defines the LightReading model for storing sensor measurements
with location and calibration data.
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Integer, Text, Boolean, JSON, Index
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship
from sqlalchemy.schema import UniqueConstraint

from app.core.database import Base


class LightSource(str, Enum):
    """Light measurement source enumeration."""
    ALS = "als"  # Ambient Light Sensor
    CAMERA = "camera"  # Camera-based estimation
    BLE = "ble"  # Bluetooth Low Energy sensor
    MANUAL = "manual"  # Manual input


class CalibrationStatus(str, Enum):
    """Calibration status enumeration."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    EXPIRED = "expired"


class BLEDeviceStatus(str, Enum):
    """BLE device connection status enumeration."""
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    ERROR = "error"


class LightReading(Base):
    """Light reading model for storing sensor measurements.
    
    Stores light measurements from various sources with location and calibration data.
    """
    
    __tablename__ = "light_readings"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=True)
    
    # Light measurement data
    lux_value = Column(Float, nullable=False)  # Light intensity in lux
    ppfd_value = Column(Float, nullable=True)  # Photosynthetic Photon Flux Density (μmol/m²/s)
    source = Column(String(20), nullable=False)  # LightSource enum value
    
    # Location and context
    location_name = Column(String(100), nullable=True)  # e.g., "Living room window"
    gps_latitude = Column(Float, nullable=True)
    gps_longitude = Column(Float, nullable=True)
    altitude = Column(Float, nullable=True)  # Meters above sea level
    
    # Environmental context
    temperature = Column(Float, nullable=True)  # Celsius
    humidity = Column(Float, nullable=True)  # Percentage
    
    # Calibration and accuracy
    calibration_profile_id = Column(PostgresUUID(as_uuid=True), ForeignKey("calibration_profiles.id"), nullable=True)
    accuracy_estimate = Column(Float, nullable=True)  # Percentage (0-100)
    confidence_score = Column(Float, nullable=True)  # ML confidence (0-1)
    
    # Device information
    device_id = Column(String(100), nullable=True)  # Device identifier
    ble_device_id = Column(PostgresUUID(as_uuid=True), ForeignKey("ble_devices.id"), nullable=True)
    
    # Telemetry fields for offline sync and data management
    growth_photo_id = Column(PostgresUUID(as_uuid=True), ForeignKey("growth_photos.id"), nullable=True)
    telemetry_session_id = Column(PostgresUUID(as_uuid=True), nullable=True)  # Session grouping
    sync_status = Column(String(20), default="pending", nullable=False)  # pending, synced, failed
    offline_created = Column(Boolean, default=False, nullable=False)  # Created while offline
    conflict_resolution_data = Column(JSON, nullable=True)  # Data for resolving sync conflicts
    
    # Metadata
    raw_data = Column(JSON, nullable=True)  # Raw sensor data for debugging
    processing_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    measured_at = Column(DateTime, nullable=False)  # When measurement was taken
    
    # Relationships
    user = relationship("User")
    plant = relationship("UserPlant")
    calibration_profile = relationship("CalibrationProfile")
    ble_device = relationship("BLEDevice")
    growth_photo = relationship("GrowthPhoto", back_populates="light_readings")
    
    # Indexes for performance
    __table_args__ = (
        Index('ix_light_readings_user_id', 'user_id'),
        Index('ix_light_readings_plant_id', 'plant_id'),
        Index('ix_light_readings_measured_at', 'measured_at'),
        Index('ix_light_readings_source', 'source'),
        Index('ix_light_readings_location', 'location_name'),
        Index('ix_light_readings_user_measured', 'user_id', 'measured_at'),
    )
    
    def __repr__(self) -> str:
        return f"<LightReading(id={self.id}, lux={self.lux_value}, source={self.source})>"
    
    @property
    def is_calibrated(self) -> bool:
        """Check if reading was taken with calibrated sensor.
        
        Returns:
            bool: True if calibration profile exists and is valid
        """
        return (self.calibration_profile is not None and 
                self.calibration_profile.status == CalibrationStatus.COMPLETED)
    
    @property
    def estimated_ppfd(self) -> Optional[float]:
        """Estimate PPFD from lux if not directly measured.
        
        Returns:
            Optional[float]: Estimated PPFD value
        """
        if self.ppfd_value is not None:
            return self.ppfd_value
        
        # Rough conversion: 1 μmol/m²/s ≈ 54 lux for sunlight
        # This varies by light spectrum, but provides a baseline
        if self.lux_value is not None:
            return self.lux_value / 54.0
        
        return None


class CalibrationProfile(Base):
    """Calibration profile model for sensor accuracy management.
    
    Stores calibration data and accuracy parameters for different sensor types.
    """
    
    __tablename__ = "calibration_profiles"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Profile identification
    name = Column(String(100), nullable=False)
    sensor_type = Column(String(20), nullable=False)  # LightSource enum value
    device_model = Column(String(100), nullable=True)  # Device/phone model
    
    # Calibration parameters
    calibration_factor = Column(Float, nullable=False, default=1.0)  # Multiplication factor
    offset_value = Column(Float, nullable=False, default=0.0)  # Addition offset
    reference_lux = Column(Float, nullable=True)  # Reference measurement
    measured_lux = Column(Float, nullable=True)  # Actual sensor reading
    
    # Accuracy metrics
    accuracy_percentage = Column(Float, nullable=True)  # Estimated accuracy
    variance_percentage = Column(Float, nullable=True)  # Measurement variance
    sample_count = Column(Integer, nullable=False, default=0)  # Calibration samples
    
    # Calibration process
    status = Column(String(20), nullable=False, default=CalibrationStatus.PENDING.value)
    calibration_method = Column(String(50), nullable=True)  # Method used
    reference_device = Column(String(100), nullable=True)  # Reference sensor used
    
    # Validity and maintenance
    valid_from = Column(DateTime, nullable=False, default=datetime.utcnow)
    valid_until = Column(DateTime, nullable=True)  # Expiration date
    last_validation = Column(DateTime, nullable=True)
    validation_notes = Column(Text, nullable=True)
    
    # Environmental conditions during calibration
    calibration_conditions = Column(JSON, nullable=True)  # Temperature, humidity, etc.
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    light_readings = relationship("LightReading", back_populates="calibration_profile")
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint('user_id', 'name', name='uq_calibration_profile_user_name'),
        Index('ix_calibration_profiles_user_id', 'user_id'),
        Index('ix_calibration_profiles_sensor_type', 'sensor_type'),
        Index('ix_calibration_profiles_status', 'status'),
        Index('ix_calibration_profiles_valid_from', 'valid_from'),
    )
    
    def __repr__(self) -> str:
        return f"<CalibrationProfile(id={self.id}, name='{self.name}', sensor_type={self.sensor_type})>"
    
    @property
    def is_active(self) -> bool:
        """Check if calibration profile is currently active.
        
        Returns:
            bool: True if profile is valid and not expired
        """
        now = datetime.utcnow()
        return (self.status == CalibrationStatus.COMPLETED.value and
                self.valid_from <= now and
                (self.valid_until is None or now <= self.valid_until))
    
    @property
    def needs_recalibration(self) -> bool:
        """Check if profile needs recalibration.
        
        Returns:
            bool: True if recalibration is recommended
        """
        if not self.is_active:
            return True
        
        # Check if accuracy is below threshold
        if self.accuracy_percentage and self.accuracy_percentage < 80:
            return True
        
        # Check if variance is too high
        if self.variance_percentage and self.variance_percentage > 20:
            return True
        
        return False
    
    def apply_calibration(self, raw_value: float) -> float:
        """Apply calibration to raw sensor value.
        
        Args:
            raw_value: Raw sensor reading
            
        Returns:
            float: Calibrated value
        """
        return (raw_value * self.calibration_factor) + self.offset_value


class BLEDevice(Base):
    """BLE device model for managing Bluetooth Low Energy sensors.
    
    Stores BLE device information, connection status, and capabilities.
    """
    
    __tablename__ = "ble_devices"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Device identification
    device_name = Column(String(100), nullable=True)  # Advertised name
    mac_address = Column(String(17), nullable=False)  # MAC address (unique)
    manufacturer = Column(String(100), nullable=True)
    model = Column(String(100), nullable=True)
    firmware_version = Column(String(50), nullable=True)
    
    # Device capabilities
    supported_services = Column(JSON, nullable=True)  # GATT services
    sensor_types = Column(JSON, nullable=True)  # Available sensors
    battery_level = Column(Integer, nullable=True)  # Battery percentage
    
    # Connection management
    status = Column(String(20), nullable=False, default=BLEDeviceStatus.DISCONNECTED.value)
    last_seen = Column(DateTime, nullable=True)
    last_connected = Column(DateTime, nullable=True)
    connection_attempts = Column(Integer, nullable=False, default=0)
    
    # Signal strength and reliability
    rssi = Column(Integer, nullable=True)  # Signal strength (dBm)
    connection_stability = Column(Float, nullable=True)  # Success rate (0-1)
    
    # Device settings
    sampling_rate_hz = Column(Float, nullable=True)  # Data collection rate
    auto_connect = Column(Boolean, default=True)
    is_trusted = Column(Boolean, default=False)
    
    # Calibration
    calibration_profile_id = Column(PostgresUUID(as_uuid=True), ForeignKey("calibration_profiles.id"), nullable=True)
    
    # Metadata
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    calibration_profile = relationship("CalibrationProfile")
    light_readings = relationship("LightReading", back_populates="ble_device")
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint('user_id', 'mac_address', name='uq_ble_device_user_mac'),
        Index('ix_ble_devices_user_id', 'user_id'),
        Index('ix_ble_devices_mac_address', 'mac_address'),
        Index('ix_ble_devices_status', 'status'),
        Index('ix_ble_devices_last_seen', 'last_seen'),
    )
    
    def __repr__(self) -> str:
        return f"<BLEDevice(id={self.id}, name='{self.device_name}', mac={self.mac_address})>"
    
    @property
    def is_connected(self) -> bool:
        """Check if device is currently connected.
        
        Returns:
            bool: True if device status is connected
        """
        return self.status == BLEDeviceStatus.CONNECTED.value
    
    @property
    def is_available(self) -> bool:
        """Check if device is available for connection.
        
        Returns:
            bool: True if device was seen recently
        """
        if not self.last_seen:
            return False
        
        # Consider device available if seen within last 5 minutes
        time_threshold = datetime.utcnow() - timedelta(minutes=5)
        return self.last_seen > time_threshold
    
    @property
    def connection_quality(self) -> str:
        """Get connection quality indicator.
        
        Returns:
            str: Quality indicator (excellent, good, fair, poor)
        """
        if not self.rssi:
            return "unknown"
        
        if self.rssi > -50:
            return "excellent"
        elif self.rssi > -70:
            return "good"
        elif self.rssi > -85:
            return "fair"
        else:
            return "poor"
    
    def update_connection_stats(self, success: bool, rssi: Optional[int] = None) -> None:
        """Update connection statistics.
        
        Args:
            success: Whether connection attempt was successful
            rssi: Signal strength reading
        """
        self.connection_attempts += 1
        
        if success:
            self.last_connected = datetime.utcnow()
            self.status = BLEDeviceStatus.CONNECTED.value
        
        if rssi is not None:
            self.rssi = rssi
        
        # Update stability score (exponential moving average)
        if self.connection_stability is None:
            self.connection_stability = 1.0 if success else 0.0
        else:
            alpha = 0.1  # Smoothing factor
            new_value = 1.0 if success else 0.0
            self.connection_stability = (alpha * new_value + 
                                       (1 - alpha) * self.connection_stability)
        
        self.updated_at = datetime.utcnow()