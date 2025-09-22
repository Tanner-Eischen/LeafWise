"""Time-lapse tracking schemas.

This module defines Pydantic schemas for time-lapse sessions,
growth photos, and growth analysis functionality.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from uuid import UUID
from enum import Enum

from pydantic import BaseModel, Field, ConfigDict


class TrackingStatus(str, Enum):
    """Status of time-lapse tracking session."""
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class ProcessingStatus(str, Enum):
    """Status of photo processing."""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class MilestoneType(str, Enum):
    """Types of growth milestones."""
    NEW_LEAF = "new_leaf"
    FLOWERING = "flowering"
    HEIGHT_INCREASE = "height_increase"
    WIDTH_INCREASE = "width_increase"
    NEW_BRANCH = "new_branch"
    FRUIT_DEVELOPMENT = "fruit_development"
    COLOR_CHANGE = "color_change"
    HEALTH_IMPROVEMENT = "health_improvement"
    HEALTH_DECLINE = "health_decline"


class DetectionMethod(str, Enum):
    """Method used to detect milestone."""
    MANUAL = "manual"
    AUTOMATIC = "automatic"
    AI_DETECTED = "ai_detected"


# Base schemas for data structures
class PhotoSchedule(BaseModel):
    """Configuration for photo capture scheduling."""
    model_config = ConfigDict(from_attributes=True)
    
    interval_days: int = Field(..., description="Days between photo captures")
    preferred_time: str = Field(..., description="Preferred time for capture (HH:MM)")
    reminder_enabled: bool = Field(default=True, description="Enable capture reminders")
    auto_capture: bool = Field(default=False, description="Enable automatic capture")
    max_photos: Optional[int] = Field(None, description="Maximum photos in session")


class TrackingConfig(BaseModel):
    """Configuration for growth tracking."""
    model_config = ConfigDict(from_attributes=True)
    
    measurement_types: List[str] = Field(..., description="Types of measurements to track")
    positioning_guides: bool = Field(default=True, description="Show positioning guides")
    quality_threshold: float = Field(default=0.7, description="Minimum image quality score")
    lighting_consistency: bool = Field(default=True, description="Check lighting consistency")
    background_removal: bool = Field(default=False, description="Remove background for analysis")


class PlantMeasurements(BaseModel):
    """Plant measurements extracted from image."""
    model_config = ConfigDict(from_attributes=True)
    
    height_cm: Optional[float] = Field(None, description="Plant height in centimeters")
    width_cm: Optional[float] = Field(None, description="Plant width in centimeters")
    leaf_count: Optional[int] = Field(None, description="Number of leaves")
    branch_count: Optional[int] = Field(None, description="Number of branches")
    flower_count: Optional[int] = Field(None, description="Number of flowers")
    fruit_count: Optional[int] = Field(None, description="Number of fruits")
    health_score: Optional[float] = Field(None, description="Overall health score (0-1)")
    leaf_area_cm2: Optional[float] = Field(None, description="Total leaf area")
    stem_thickness_mm: Optional[float] = Field(None, description="Stem thickness in mm")


class HealthIndicators(BaseModel):
    """Health indicators extracted from image analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    leaf_color_health: Optional[float] = Field(None, description="Leaf color health score")
    pest_indicators: List[str] = Field(default_factory=list, description="Detected pest signs")
    disease_indicators: List[str] = Field(default_factory=list, description="Detected disease signs")
    stress_indicators: List[str] = Field(default_factory=list, description="Detected stress signs")
    overall_health: Optional[float] = Field(None, description="Overall health assessment")


class GrowthChanges(BaseModel):
    """Changes detected between photos."""
    model_config = ConfigDict(from_attributes=True)
    
    height_change_cm: Optional[float] = Field(None, description="Height change since last photo")
    width_change_cm: Optional[float] = Field(None, description="Width change since last photo")
    leaf_count_change: Optional[int] = Field(None, description="Change in leaf count")
    new_features: List[str] = Field(default_factory=list, description="New features detected")
    lost_features: List[str] = Field(default_factory=list, description="Lost features detected")
    growth_rate_cm_per_day: Optional[float] = Field(None, description="Growth rate calculation")


class AnomalyFlag(BaseModel):
    """Anomaly detection flag."""
    model_config = ConfigDict(from_attributes=True)
    
    anomaly_type: str = Field(..., description="Type of anomaly detected")
    severity: float = Field(..., description="Severity score (0-1)")
    description: str = Field(..., description="Description of the anomaly")
    confidence: float = Field(..., description="Detection confidence (0-1)")


class GrowthAnalysis(BaseModel):
    """Complete growth analysis for a photo."""
    model_config = ConfigDict(from_attributes=True)
    
    photo_id: UUID
    capture_date: datetime
    plant_measurements: Optional[PlantMeasurements] = None
    health_indicators: Optional[HealthIndicators] = None
    growth_changes: Optional[GrowthChanges] = None
    anomaly_flags: List[AnomalyFlag] = Field(default_factory=list)
    processing_metadata: Dict[str, Any] = Field(default_factory=dict)


class MilestoneTarget(BaseModel):
    """Target milestone for tracking."""
    model_config = ConfigDict(from_attributes=True)
    
    milestone_type: MilestoneType
    target_value: Optional[float] = Field(None, description="Target value for milestone")
    description: str = Field(..., description="Description of milestone")
    priority: int = Field(default=1, description="Priority level (1-5)")


class VideoOptions(BaseModel):
    """Options for time-lapse video generation."""
    model_config = ConfigDict(from_attributes=True)
    
    fps: int = Field(default=10, description="Frames per second")
    resolution: str = Field(default="1080p", description="Video resolution")
    format: str = Field(default="mp4", description="Video format")
    quality: str = Field(default="high", description="Video quality")
    include_metrics: bool = Field(default=True, description="Include growth metrics overlay")
    include_dates: bool = Field(default=True, description="Include capture dates")
    background_music: bool = Field(default=False, description="Add background music")


# Request/Response schemas
class TimelapseSessionBase(BaseModel):
    """Base schema for time-lapse session."""
    model_config = ConfigDict(from_attributes=True)
    
    session_name: str = Field(..., description="Name of the tracking session")
    photo_schedule: PhotoSchedule
    tracking_config: TrackingConfig
    milestone_targets: Optional[List[MilestoneTarget]] = None


class TimelapseSessionCreate(TimelapseSessionBase):
    """Schema for creating a time-lapse session."""
    plant_id: UUID = Field(..., description="ID of the plant to track")


class TimelapseSessionUpdate(BaseModel):
    """Schema for updating a time-lapse session."""
    model_config = ConfigDict(from_attributes=True)
    
    session_name: Optional[str] = None
    status: Optional[TrackingStatus] = None
    photo_schedule: Optional[PhotoSchedule] = None
    tracking_config: Optional[TrackingConfig] = None
    milestone_targets: Optional[List[MilestoneTarget]] = None
    end_date: Optional[datetime] = None


class TimelapseSessionResponse(TimelapseSessionBase):
    """Schema for time-lapse session response."""
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    plant_id: UUID
    user_id: UUID
    start_date: datetime
    end_date: Optional[datetime] = None
    status: TrackingStatus
    total_photos: int
    last_photo_date: Optional[datetime] = None
    initial_measurements: Optional[PlantMeasurements] = None
    current_measurements: Optional[PlantMeasurements] = None
    video_url: Optional[str] = None
    video_generated_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime


class GrowthPhotoBase(BaseModel):
    """Base schema for growth photo."""
    model_config = ConfigDict(from_attributes=True)
    
    photo_url: str = Field(..., description="URL of the photo")
    capture_date: datetime = Field(..., description="When the photo was captured")


class GrowthPhotoCreate(GrowthPhotoBase):
    """Schema for creating a growth photo."""
    session_id: UUID = Field(..., description="ID of the time-lapse session")


class GrowthPhotoResponse(GrowthPhotoBase):
    """Schema for growth photo response."""
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    session_id: UUID
    sequence_number: int
    plant_measurements: Optional[PlantMeasurements] = None
    growth_analysis: Optional[Dict[str, Any]] = None
    health_indicators: Optional[HealthIndicators] = None
    processing_status: ProcessingStatus
    processing_error: Optional[str] = None
    image_quality_score: Optional[float] = None
    positioning_accuracy: Optional[float] = None
    lighting_consistency: Optional[float] = None
    created_at: datetime
    processed_at: Optional[datetime] = None


class GrowthMilestoneBase(BaseModel):
    """Base schema for growth milestone."""
    model_config = ConfigDict(from_attributes=True)
    
    milestone_type: MilestoneType
    milestone_name: str = Field(..., description="Name of the milestone")
    description: Optional[str] = None
    achievement_date: datetime
    user_notes: Optional[str] = None


class GrowthMilestoneCreate(GrowthMilestoneBase):
    """Schema for creating a growth milestone."""
    session_id: UUID = Field(..., description="ID of the time-lapse session")
    photo_id: Optional[UUID] = Field(None, description="ID of the associated photo")
    detection_method: DetectionMethod = DetectionMethod.MANUAL


class GrowthMilestoneResponse(GrowthMilestoneBase):
    """Schema for growth milestone response."""
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    session_id: UUID
    photo_id: Optional[UUID] = None
    measurement_data: Optional[Dict[str, Any]] = None
    comparison_data: Optional[Dict[str, Any]] = None
    detection_method: Optional[DetectionMethod] = None
    confidence_score: Optional[float] = None
    user_verified: bool
    created_at: datetime


class TimelapseVideoRequest(BaseModel):
    """Request schema for generating time-lapse video."""
    model_config = ConfigDict(from_attributes=True)
    
    session_id: UUID = Field(..., description="ID of the time-lapse session")
    video_options: VideoOptions = Field(default_factory=VideoOptions)


class TimelapseVideoResponse(BaseModel):
    """Response schema for time-lapse video."""
    model_config = ConfigDict(from_attributes=True)
    
    video_url: str = Field(..., description="URL of the generated video")
    generation_date: datetime
    video_options: VideoOptions
    processing_time_seconds: Optional[float] = None
    file_size_mb: Optional[float] = None


class TimelapseSessionListResponse(BaseModel):
    """Response schema for listing time-lapse sessions."""
    model_config = ConfigDict(from_attributes=True)
    
    sessions: List[TimelapseSessionResponse]
    total_count: int
    page: int
    page_size: int


class GrowthPhotoListResponse(BaseModel):
    """Response schema for listing growth photos."""
    model_config = ConfigDict(from_attributes=True)
    
    photos: List[GrowthPhotoResponse]
    total_count: int
    session_id: UUID


class GrowthMilestoneListResponse(BaseModel):
    """Response schema for listing growth milestones."""
    model_config = ConfigDict(from_attributes=True)
    
    milestones: List[GrowthMilestoneResponse]
    total_count: int
    session_id: UUID