"""Telemetry API Schemas.

This module defines Pydantic schemas for telemetry API requests and responses,
including validation rules and serialization for sensor data, growth photos,
calibration profiles, and BLE device management.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any, Union
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.models.light_reading import LightSource, CalibrationStatus, BLEDeviceStatus


# Light Reading Schemas

class LightReadingCreate(BaseModel):
    """Schema for creating light readings."""
    
    plant_id: Optional[UUID] = Field(
        None, 
        description="Associated plant identifier"
    )
    lux_value: float = Field(
        ..., 
        ge=0.0, 
        le=200000.0, 
        description="Light intensity in lux"
    )
    ppfd_value: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=3000.0, 
        description="Photosynthetic Photon Flux Density (μmol/m²/s)"
    )
    source: LightSource = Field(
        ..., 
        description="Light measurement source"
    )
    location_name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Location name (e.g., 'Living room window')"
    )
    gps_latitude: Optional[float] = Field(
        None, 
        ge=-90.0, 
        le=90.0, 
        description="GPS latitude"
    )
    gps_longitude: Optional[float] = Field(
        None, 
        ge=-180.0, 
        le=180.0, 
        description="GPS longitude"
    )
    altitude: Optional[float] = Field(
        None, 
        ge=-500.0, 
        le=10000.0, 
        description="Altitude in meters above sea level"
    )
    temperature: Optional[float] = Field(
        None, 
        ge=-50.0, 
        le=70.0, 
        description="Temperature in Celsius"
    )
    humidity: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=100.0, 
        description="Humidity percentage"
    )
    calibration_profile_id: Optional[UUID] = Field(
        None, 
        description="Calibration profile identifier"
    )
    device_id: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device identifier"
    )
    ble_device_id: Optional[UUID] = Field(
        None, 
        description="BLE device identifier"
    )
    raw_data: Optional[Dict[str, Any]] = Field(
        None, 
        description="Raw sensor data for debugging"
    )
    measured_at: datetime = Field(
        ..., 
        description="When measurement was taken"
    )


class BatchLightReadingRequest(BaseModel):
    """Schema for batch light reading creation."""
    
    readings: List[LightReadingCreate] = Field(
        ..., 
        min_items=1, 
        max_items=100, 
        description="List of light readings to create"
    )
    
    @field_validator('readings')
    @classmethod
    def validate_readings_timestamps(cls, v):
        """Ensure readings are in chronological order."""
        if len(v) > 1:
            timestamps = [reading.measured_at for reading in v]
            if timestamps != sorted(timestamps):
                raise ValueError('Readings must be in chronological order')
        return v


class LightReadingResponse(BaseModel):
    """Schema for light reading API responses."""
    
    id: UUID = Field(..., description="Unique reading identifier")
    user_id: UUID = Field(..., description="User identifier")
    plant_id: Optional[UUID] = Field(None, description="Associated plant identifier")
    lux_value: float = Field(..., description="Light intensity in lux")
    ppfd_value: Optional[float] = Field(None, description="PPFD value")
    estimated_ppfd: Optional[float] = Field(None, description="Estimated PPFD from lux")
    source: LightSource = Field(..., description="Light measurement source")
    location_name: Optional[str] = Field(None, description="Location name")
    gps_latitude: Optional[float] = Field(None, description="GPS latitude")
    gps_longitude: Optional[float] = Field(None, description="GPS longitude")
    temperature: Optional[float] = Field(None, description="Temperature in Celsius")
    humidity: Optional[float] = Field(None, description="Humidity percentage")
    accuracy_estimate: Optional[float] = Field(None, description="Accuracy percentage")
    confidence_score: Optional[float] = Field(None, description="ML confidence score")
    is_calibrated: bool = Field(..., description="Whether reading was calibrated")
    device_id: Optional[str] = Field(None, description="Device identifier")
    measured_at: datetime = Field(..., description="Measurement timestamp")
    created_at: datetime = Field(..., description="Creation timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# Growth Photo Schemas

class GrowthPhotoCreate(BaseModel):
    """Schema for creating growth photos."""
    
    plant_id: UUID = Field(
        ..., 
        description="Associated plant identifier"
    )
    file_path: str = Field(
        ..., 
        max_length=500, 
        description="Photo file storage path"
    )
    location_name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Location where photo was taken"
    )
    ambient_light_lux: Optional[float] = Field(
        None, 
        ge=0.0, 
        description="Ambient light during photo capture"
    )
    camera_settings: Optional[Dict[str, Any]] = Field(
        None, 
        description="Camera settings (ISO, exposure, etc.)"
    )
    notes: Optional[str] = Field(
        None, 
        max_length=1000, 
        description="User notes about the photo"
    )
    captured_at: datetime = Field(
        ..., 
        description="When photo was captured"
    )


class GrowthMetricsSchema(BaseModel):
    """Schema for growth metrics extracted from photos."""
    
    leaf_area_cm2: Optional[float] = Field(
        None, 
        ge=0.0, 
        description="Total leaf area in cm²"
    )
    plant_height_cm: Optional[float] = Field(
        None, 
        ge=0.0, 
        description="Plant height in centimeters"
    )
    leaf_count: Optional[int] = Field(
        None, 
        ge=0, 
        description="Number of leaves detected"
    )
    stem_width_mm: Optional[float] = Field(
        None, 
        ge=0.0, 
        description="Stem width in millimeters"
    )
    health_score: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=100.0, 
        description="Overall health score (0-100)"
    )
    chlorophyll_index: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=1.0, 
        description="Chlorophyll/greenness index"
    )
    disease_indicators: Optional[List[str]] = Field(
        None, 
        description="Detected disease or health issues"
    )


class GrowthPhotoResponse(BaseModel):
    """Schema for growth photo API responses."""
    
    id: UUID = Field(..., description="Unique photo identifier")
    user_id: UUID = Field(..., description="User identifier")
    plant_id: UUID = Field(..., description="Associated plant identifier")
    file_path: str = Field(..., description="Photo file storage path")
    file_size: Optional[int] = Field(None, description="File size in bytes")
    image_width: Optional[int] = Field(None, description="Image width in pixels")
    image_height: Optional[int] = Field(None, description="Image height in pixels")
    metrics: Optional[GrowthMetricsSchema] = Field(None, description="Extracted growth metrics")
    processing_version: Optional[str] = Field(None, description="ML model version used")
    confidence_scores: Optional[Dict[str, float]] = Field(None, description="Per-metric confidence")
    analysis_duration_ms: Optional[int] = Field(None, description="Processing time in milliseconds")
    location_name: Optional[str] = Field(None, description="Photo location")
    ambient_light_lux: Optional[float] = Field(None, description="Ambient light during capture")
    notes: Optional[str] = Field(None, description="User notes")
    is_processed: bool = Field(..., description="Whether photo has been analyzed")
    processing_error: Optional[str] = Field(None, description="Processing error message")
    growth_rate_indicator: Optional[str] = Field(None, description="Growth rate category")
    captured_at: datetime = Field(..., description="Capture timestamp")
    processed_at: Optional[datetime] = Field(None, description="Processing completion timestamp")
    created_at: datetime = Field(..., description="Creation timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# Calibration Profile Schemas

class CalibrationProfileCreate(BaseModel):
    """Schema for creating calibration profiles."""
    
    name: str = Field(
        ..., 
        min_length=1, 
        max_length=100, 
        description="Profile name"
    )
    sensor_type: LightSource = Field(
        ..., 
        description="Sensor type being calibrated"
    )
    device_model: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device or phone model"
    )
    reference_lux: float = Field(
        ..., 
        ge=0.0, 
        description="Reference measurement from calibrated device"
    )
    measured_lux: float = Field(
        ..., 
        ge=0.0, 
        description="Actual sensor reading"
    )
    calibration_method: Optional[str] = Field(
        None, 
        max_length=50, 
        description="Calibration method used"
    )
    reference_device: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Reference sensor device used"
    )
    calibration_conditions: Optional[Dict[str, Any]] = Field(
        None, 
        description="Environmental conditions during calibration"
    )
    
    @field_validator('measured_lux')
    @classmethod
    def validate_measured_lux(cls, v, info):
        """Ensure measured_lux is reasonable compared to reference."""
        values = info.data
        if 'reference_lux' in values:
            ratio = v / values['reference_lux'] if values['reference_lux'] > 0 else float('inf')
            if ratio < 0.1 or ratio > 10.0:
                raise ValueError('Measured lux seems unreasonable compared to reference')
        return v


class CalibrationProfileUpdate(BaseModel):
    """Schema for updating calibration profiles."""
    
    name: Optional[str] = Field(
        None, 
        min_length=1, 
        max_length=100, 
        description="Profile name"
    )
    valid_until: Optional[datetime] = Field(
        None, 
        description="Profile expiration date"
    )
    validation_notes: Optional[str] = Field(
        None, 
        max_length=1000, 
        description="Validation notes"
    )


class CalibrationProfileResponse(BaseModel):
    """Schema for calibration profile API responses."""
    
    id: UUID = Field(..., description="Unique profile identifier")
    user_id: UUID = Field(..., description="User identifier")
    name: str = Field(..., description="Profile name")
    sensor_type: LightSource = Field(..., description="Sensor type")
    device_model: Optional[str] = Field(None, description="Device model")
    calibration_factor: float = Field(..., description="Calibration multiplication factor")
    offset_value: float = Field(..., description="Calibration offset value")
    reference_lux: Optional[float] = Field(None, description="Reference measurement")
    measured_lux: Optional[float] = Field(None, description="Sensor reading")
    accuracy_percentage: Optional[float] = Field(None, description="Estimated accuracy")
    variance_percentage: Optional[float] = Field(None, description="Measurement variance")
    sample_count: int = Field(..., description="Number of calibration samples")
    status: CalibrationStatus = Field(..., description="Calibration status")
    calibration_method: Optional[str] = Field(None, description="Method used")
    reference_device: Optional[str] = Field(None, description="Reference device")
    valid_from: datetime = Field(..., description="Validity start date")
    valid_until: Optional[datetime] = Field(None, description="Expiration date")
    last_validation: Optional[datetime] = Field(None, description="Last validation date")
    is_active: bool = Field(..., description="Whether profile is currently active")
    needs_recalibration: bool = Field(..., description="Whether recalibration is needed")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# BLE Device Schemas

class BLEDeviceCreate(BaseModel):
    """Schema for registering BLE devices."""
    
    device_name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device advertised name"
    )
    mac_address: str = Field(
        ..., 
        pattern=r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$', 
        description="Device MAC address"
    )
    manufacturer: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device manufacturer"
    )
    model: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device model"
    )
    supported_services: Optional[List[str]] = Field(
        None, 
        description="Supported GATT services"
    )
    sensor_types: Optional[List[str]] = Field(
        None, 
        description="Available sensor types"
    )
    sampling_rate_hz: Optional[float] = Field(
        None, 
        ge=0.1, 
        le=10.0, 
        description="Data collection rate in Hz"
    )
    auto_connect: bool = Field(
        default=True, 
        description="Whether to auto-connect to device"
    )
    notes: Optional[str] = Field(
        None, 
        max_length=1000, 
        description="Device notes"
    )


class BLEDeviceUpdate(BaseModel):
    """Schema for updating BLE devices."""
    
    device_name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Device name"
    )
    sampling_rate_hz: Optional[float] = Field(
        None, 
        ge=0.1, 
        le=10.0, 
        description="Data collection rate"
    )
    auto_connect: Optional[bool] = Field(
        None, 
        description="Auto-connect setting"
    )
    is_trusted: Optional[bool] = Field(
        None, 
        description="Whether device is trusted"
    )
    notes: Optional[str] = Field(
        None, 
        max_length=1000, 
        description="Device notes"
    )


class BLEDeviceResponse(BaseModel):
    """Schema for BLE device API responses."""
    
    id: UUID = Field(..., description="Unique device identifier")
    user_id: UUID = Field(..., description="User identifier")
    device_name: Optional[str] = Field(None, description="Device name")
    mac_address: str = Field(..., description="MAC address")
    manufacturer: Optional[str] = Field(None, description="Manufacturer")
    model: Optional[str] = Field(None, description="Model")
    firmware_version: Optional[str] = Field(None, description="Firmware version")
    supported_services: Optional[List[str]] = Field(None, description="GATT services")
    sensor_types: Optional[List[str]] = Field(None, description="Available sensors")
    battery_level: Optional[int] = Field(None, description="Battery percentage")
    status: BLEDeviceStatus = Field(..., description="Connection status")
    last_seen: Optional[datetime] = Field(None, description="Last seen timestamp")
    last_connected: Optional[datetime] = Field(None, description="Last connection timestamp")
    connection_attempts: int = Field(..., description="Total connection attempts")
    rssi: Optional[int] = Field(None, description="Signal strength (dBm)")
    connection_stability: Optional[float] = Field(None, description="Connection success rate")
    sampling_rate_hz: Optional[float] = Field(None, description="Data collection rate")
    auto_connect: bool = Field(..., description="Auto-connect setting")
    is_trusted: bool = Field(..., description="Trusted device flag")
    is_connected: bool = Field(..., description="Current connection status")
    is_available: bool = Field(..., description="Device availability")
    connection_quality: str = Field(..., description="Connection quality indicator")
    notes: Optional[str] = Field(None, description="Device notes")
    created_at: datetime = Field(..., description="Registration timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# Query and Filter Schemas

class TelemetryQueryParams(BaseModel):
    """Schema for telemetry data query parameters."""
    
    plant_id: Optional[UUID] = Field(None, description="Filter by plant ID")
    source: Optional[LightSource] = Field(None, description="Filter by light source")
    location_name: Optional[str] = Field(None, description="Filter by location")
    start_date: Optional[datetime] = Field(None, description="Start date for range query")
    end_date: Optional[datetime] = Field(None, description="End date for range query")
    min_lux: Optional[float] = Field(None, ge=0.0, description="Minimum lux value")
    max_lux: Optional[float] = Field(None, ge=0.0, description="Maximum lux value")
    calibrated_only: bool = Field(default=False, description="Only calibrated readings")
    limit: int = Field(default=100, ge=1, le=1000, description="Maximum results")
    offset: int = Field(default=0, ge=0, description="Results offset")
    
    @field_validator('end_date')
    @classmethod
    def validate_date_range(cls, v, info):
        """Ensure end_date is after start_date."""
        values = info.data
        if v and 'start_date' in values and values['start_date']:
            if v <= values['start_date']:
                raise ValueError('end_date must be after start_date')
        return v
    
    @field_validator('max_lux')
    @classmethod
    def validate_lux_range(cls, v, info):
        """Ensure max_lux is greater than min_lux."""
        values = info.data
        if v and 'min_lux' in values and values['min_lux']:
            if v <= values['min_lux']:
                raise ValueError('max_lux must be greater than min_lux')
        return v


class TelemetryStatsResponse(BaseModel):
    """Schema for telemetry statistics responses."""
    
    total_readings: int = Field(..., description="Total number of readings")
    date_range: Dict[str, Optional[datetime]] = Field(..., description="Date range of data")
    source_distribution: Dict[str, int] = Field(..., description="Readings by source")
    location_distribution: Dict[str, int] = Field(..., description="Readings by location")
    average_lux: Optional[float] = Field(None, description="Average lux value")
    min_lux: Optional[float] = Field(None, description="Minimum lux value")
    max_lux: Optional[float] = Field(None, description="Maximum lux value")
    calibrated_percentage: float = Field(..., description="Percentage of calibrated readings")
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat() if v else None
        }


# Telemetry Data Transfer Object Schemas

class TelemetryLightReadingCreate(LightReadingCreate):
    """Enhanced schema for creating light readings with telemetry-specific fields.
    
    Extends LightReadingCreate with additional fields for offline sync,
    session tracking, and conflict resolution.
    """
    
    telemetry_session_id: Optional[UUID] = Field(
        None,
        description="Session identifier for grouping related measurements"
    )
    sync_status: str = Field(
        default="pending",
        pattern="^(pending|synced|failed|conflict)$",
        description="Synchronization status"
    )
    offline_created: bool = Field(
        default=False,
        description="Whether reading was created while offline"
    )
    conflict_resolution_data: Optional[Dict[str, Any]] = Field(
        None,
        description="Data for resolving sync conflicts"
    )
    client_timestamp: datetime = Field(
        ...,
        description="Client-side timestamp when reading was created"
    )
    retry_count: int = Field(
        default=0,
        ge=0,
        le=10,
        description="Number of sync retry attempts"
    )
    
    @field_validator('sync_status')
    @classmethod
    def validate_sync_status(cls, v):
        """Validate sync status values."""
        valid_statuses = {"pending", "synced", "failed", "conflict"}
        if v not in valid_statuses:
            raise ValueError(f'sync_status must be one of: {valid_statuses}')
        return v


class TelemetryGrowthPhotoCreate(GrowthPhotoCreate):
    """Enhanced schema for creating growth photos with telemetry-specific fields.
    
    Extends GrowthPhotoCreate with additional fields for offline sync,
    session tracking, and metadata management.
    """
    
    telemetry_session_id: Optional[UUID] = Field(
        None,
        description="Session identifier for grouping related photos"
    )
    sync_status: str = Field(
        default="pending",
        pattern="^(pending|synced|failed|conflict)$",
        description="Synchronization status"
    )
    offline_created: bool = Field(
        default=False,
        description="Whether photo was created while offline"
    )
    local_file_path: Optional[str] = Field(
        None,
        max_length=500,
        description="Local device file path before upload"
    )
    file_size: Optional[int] = Field(
        None,
        ge=0,
        description="File size in bytes"
    )
    image_width: Optional[int] = Field(
        None,
        ge=1,
        le=10000,
        description="Image width in pixels"
    )
    image_height: Optional[int] = Field(
        None,
        ge=1,
        le=10000,
        description="Image height in pixels"
    )
    upload_progress: float = Field(
        default=0.0,
        ge=0.0,
        le=100.0,
        description="Upload progress percentage"
    )
    client_timestamp: datetime = Field(
        ...,
        description="Client-side timestamp when photo was created"
    )
    retry_count: int = Field(
        default=0,
        ge=0,
        le=10,
        description="Number of sync retry attempts"
    )
    
    @field_validator('sync_status')
    @classmethod
    def validate_sync_status(cls, v):
        """Validate sync status values."""
        valid_statuses = {"pending", "synced", "failed", "conflict"}
        if v not in valid_statuses:
            raise ValueError(f'sync_status must be one of: {valid_statuses}')
        return v


class TelemetryBatchRequest(BaseModel):
    """Schema for batch telemetry data operations.
    
    Supports creating multiple light readings and growth photos in a single request
    with session tracking and conflict resolution.
    """
    
    session_id: UUID = Field(
        ...,
        description="Unique session identifier for this batch"
    )
    light_readings: List[TelemetryLightReadingCreate] = Field(
        default_factory=list,
        max_items=100,
        description="List of light readings to create"
    )
    growth_photos: List[TelemetryGrowthPhotoCreate] = Field(
        default_factory=list,
        max_items=50,
        description="List of growth photos to create"
    )
    batch_metadata: Optional[Dict[str, Any]] = Field(
        None,
        description="Additional metadata for the batch operation"
    )
    client_timestamp: datetime = Field(
        ...,
        description="Client-side timestamp when batch was created"
    )
    offline_mode: bool = Field(
        default=False,
        description="Whether batch was created in offline mode"
    )
    
    @field_validator('light_readings', 'growth_photos')
    @classmethod
    def validate_batch_not_empty(cls, v, info):
        """Ensure at least one item is provided in the batch."""
        # Get the other field to check if batch is completely empty
        field_name = info.field_name
        values = info.data
        other_field = 'growth_photos' if field_name == 'light_readings' else 'light_readings'
        other_value = values.get(other_field, [])
        
        if not v and not other_value:
            raise ValueError('Batch must contain at least one light reading or growth photo')
        return v
    
    @field_validator('light_readings')
    @classmethod
    def validate_light_readings_timestamps(cls, v):
        """Ensure light readings are in chronological order."""
        if len(v) > 1:
            timestamps = [reading.measured_at for reading in v]
            if timestamps != sorted(timestamps):
                raise ValueError('Light readings must be in chronological order')
        return v
    
    @field_validator('growth_photos')
    @classmethod
    def validate_growth_photos_timestamps(cls, v):
        """Ensure growth photos are in chronological order."""
        if len(v) > 1:
            timestamps = [photo.captured_at for photo in v]
            if timestamps != sorted(timestamps):
                raise ValueError('Growth photos must be in chronological order')
        return v


class TelemetrySyncStatus(BaseModel):
    """Schema for telemetry data synchronization status.
    
    Tracks the sync status of telemetry data items with detailed
    error information and retry management.
    """
    
    item_id: UUID = Field(
        ...,
        description="Unique identifier of the telemetry item"
    )
    item_type: str = Field(
        ...,
        pattern="^(light_reading|growth_photo|batch)$",
        description="Type of telemetry item"
    )
    session_id: Optional[UUID] = Field(
        None,
        description="Session identifier if part of a batch"
    )
    sync_status: str = Field(
        ...,
        pattern="^(pending|in_progress|synced|failed|conflict|cancelled)$",
        description="Current synchronization status"
    )
    last_sync_attempt: Optional[datetime] = Field(
        None,
        description="Timestamp of last sync attempt"
    )
    next_retry_at: Optional[datetime] = Field(
        None,
        description="Scheduled time for next retry attempt"
    )
    retry_count: int = Field(
        default=0,
        ge=0,
        description="Number of retry attempts made"
    )
    max_retries: int = Field(
        default=5,
        ge=1,
        le=20,
        description="Maximum number of retry attempts"
    )
    error_message: Optional[str] = Field(
        None,
        max_length=1000,
        description="Last error message if sync failed"
    )
    error_code: Optional[str] = Field(
        None,
        max_length=50,
        description="Error code for categorizing failures"
    )
    conflict_data: Optional[Dict[str, Any]] = Field(
        None,
        description="Data for resolving sync conflicts"
    )
    sync_priority: int = Field(
        default=5,
        ge=1,
        le=10,
        description="Sync priority (1=highest, 10=lowest)"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        description="When sync status was created"
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow,
        description="When sync status was last updated"
    )
    
    @field_validator('item_type')
    @classmethod
    def validate_item_type(cls, v):
        """Validate item type values."""
        valid_types = {"light_reading", "growth_photo", "batch"}
        if v not in valid_types:
            raise ValueError(f'item_type must be one of: {valid_types}')
        return v
    
    @field_validator('sync_status')
    @classmethod
    def validate_sync_status(cls, v):
        """Validate sync status values."""
        valid_statuses = {"pending", "in_progress", "synced", "failed", "conflict", "cancelled"}
        if v not in valid_statuses:
            raise ValueError(f'sync_status must be one of: {valid_statuses}')
        return v
    
    @field_validator('next_retry_at')
    @classmethod
    def validate_next_retry_at(cls, v, info):
        """Ensure next_retry_at is in the future if provided."""
        if v and v <= datetime.utcnow():
            raise ValueError('next_retry_at must be in the future')
        return v
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class TelemetryBatchResponse(BaseModel):
    """Schema for telemetry batch operation responses.
    
    Provides detailed results of batch operations including
    success/failure counts and individual item statuses.
    """
    
    batch_id: UUID = Field(
        ...,
        description="Unique batch operation identifier"
    )
    session_id: UUID = Field(
        ...,
        description="Session identifier for the batch"
    )
    total_items: int = Field(
        ...,
        ge=0,
        description="Total number of items in the batch"
    )
    successful_items: int = Field(
        ...,
        ge=0,
        description="Number of successfully processed items"
    )
    failed_items: int = Field(
        ...,
        ge=0,
        description="Number of failed items"
    )
    light_readings_created: List[UUID] = Field(
        default_factory=list,
        description="IDs of successfully created light readings"
    )
    growth_photos_created: List[UUID] = Field(
        default_factory=list,
        description="IDs of successfully created growth photos"
    )
    sync_statuses: List[TelemetrySyncStatus] = Field(
        default_factory=list,
        description="Sync status for each item in the batch"
    )
    processing_duration_ms: Optional[int] = Field(
        None,
        ge=0,
        description="Total processing time in milliseconds"
    )
    errors: List[Dict[str, Any]] = Field(
        default_factory=list,
        description="Detailed error information for failed items"
    )
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        description="When batch processing completed"
    )
    
    @field_validator('successful_items', 'failed_items')
    @classmethod
    def validate_item_counts(cls, v, info):
        """Validate that item counts are consistent."""
        values = info.data
        field_name = info.field_name
        if 'total_items' in values:
            total = values['total_items']
            if field_name == 'successful_items':
                if v > total:
                    raise ValueError('successful_items cannot exceed total_items')
            elif field_name == 'failed_items':
                if v > total:
                    raise ValueError('failed_items cannot exceed total_items')
                # Check if successful + failed = total when both are available
                successful = values.get('successful_items', 0)
                if successful + v != total:
                    raise ValueError('successful_items + failed_items must equal total_items')
        return v
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# Error Response Schemas

class TelemetryErrorResponse(BaseModel):
    """Schema for telemetry API error responses."""
    
    error_code: str = Field(..., description="Error code")
    message: str = Field(..., description="Error message")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Error timestamp")
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }