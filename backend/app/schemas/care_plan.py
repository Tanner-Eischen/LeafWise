"""Care Plan API Schemas.

This module defines Pydantic schemas for care plan API requests and responses,
including validation rules and serialization for the Context-Aware Care Plans v2 feature.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

from pydantic import BaseModel, Field, validator


class WateringScheduleSchema(BaseModel):
    """Schema for watering schedule recommendations."""
    
    interval_days: int = Field(
        ..., 
        ge=1, 
        le=30, 
        description="Days between watering sessions"
    )
    amount_ml: int = Field(
        ..., 
        ge=50, 
        le=2000, 
        description="Amount of water in milliliters"
    )
    next_due: datetime = Field(
        ..., 
        description="Next scheduled watering date"
    )


class FertilizerScheduleSchema(BaseModel):
    """Schema for fertilizer schedule recommendations."""
    
    interval_days: int = Field(
        ..., 
        ge=7, 
        le=90, 
        description="Days between fertilizer applications"
    )
    type: str = Field(
        ..., 
        min_length=1, 
        max_length=100, 
        description="Type of fertilizer (e.g., balanced_10_10_10)"
    )
    next_due: Optional[datetime] = Field(
        None, 
        description="Next scheduled fertilizer date"
    )


class LightTargetSchema(BaseModel):
    """Schema for light requirements and recommendations."""
    
    ppfd_min: int = Field(
        ..., 
        ge=0, 
        le=2000, 
        description="Minimum PPFD (Photosynthetic Photon Flux Density)"
    )
    ppfd_max: int = Field(
        ..., 
        ge=0, 
        le=2000, 
        description="Maximum PPFD (Photosynthetic Photon Flux Density)"
    )
    recommendation: str = Field(
        ..., 
        min_length=1, 
        max_length=100, 
        description="Light placement recommendation"
    )
    
    @validator('ppfd_max')
    def validate_ppfd_range(cls, v, values):
        """Ensure ppfd_max is greater than ppfd_min."""
        if 'ppfd_min' in values and v <= values['ppfd_min']:
            raise ValueError('ppfd_max must be greater than ppfd_min')
        return v


class RationaleSchema(BaseModel):
    """Schema for care plan rationale and explanation."""
    
    features: Dict[str, Any] = Field(
        ..., 
        description="Context features used in plan generation"
    )
    rules_fired: List[str] = Field(
        ..., 
        description="List of rules that were applied"
    )
    confidence: float = Field(
        ..., 
        ge=0.0, 
        le=1.0, 
        description="Confidence score for the generated plan"
    )
    ml_adjustments: Optional[Dict[str, float]] = Field(
        None, 
        description="ML-based adjustments applied to base recommendations"
    )
    environmental_factors: Optional[Dict[str, Any]] = Field(
        None, 
        description="Environmental factors considered in plan generation"
    )


class CarePlanDetailsSchema(BaseModel):
    """Schema for detailed care plan content."""
    
    watering: WateringScheduleSchema = Field(
        ..., 
        description="Watering schedule and recommendations"
    )
    fertilizer: FertilizerScheduleSchema = Field(
        ..., 
        description="Fertilizer schedule and recommendations"
    )
    light_target: LightTargetSchema = Field(
        ..., 
        description="Light requirements and placement recommendations"
    )
    alerts: List[str] = Field(
        default_factory=list, 
        description="Care alerts and warnings"
    )
    review_in_days: int = Field(
        ..., 
        ge=1, 
        le=90, 
        description="Days until plan should be reviewed"
    )


class CarePlanRequest(BaseModel):
    """Schema for care plan generation requests."""
    
    force_regenerate: bool = Field(
        default=False, 
        description="Force regeneration even if recent plan exists"
    )
    context_override: Optional[Dict[str, Any]] = Field(
        None, 
        description="Override specific context values for plan generation"
    )
    include_rationale: bool = Field(
        default=True, 
        description="Include detailed rationale in response"
    )


class CarePlanResponse(BaseModel):
    """Schema for care plan API responses."""
    
    id: UUID = Field(..., description="Unique care plan identifier")
    plant_id: UUID = Field(..., description="Associated plant identifier")
    version: int = Field(..., description="Plan version number")
    plan: CarePlanDetailsSchema = Field(..., description="Care plan details")
    rationale: Optional[RationaleSchema] = Field(
        None, 
        description="Plan generation rationale and explanation"
    )
    valid_from: datetime = Field(..., description="Plan validity start date")
    valid_to: Optional[datetime] = Field(
        None, 
        description="Plan validity end date"
    )
    acknowledged: bool = Field(
        default=False, 
        description="Whether user has acknowledged the plan"
    )
    acknowledged_at: Optional[datetime] = Field(
        None, 
        description="When the plan was acknowledged"
    )
    created_at: datetime = Field(..., description="Plan creation timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class CarePlanHistory(BaseModel):
    """Schema for care plan summary in list views."""
    
    id: UUID = Field(..., description="Unique care plan identifier")
    plant_id: UUID = Field(..., description="Associated plant identifier")
    version: int = Field(..., description="Plan version number")
    watering_interval: int = Field(..., description="Watering interval in days")
    fertilizer_interval: int = Field(..., description="Fertilizer interval in days")
    next_watering: datetime = Field(..., description="Next watering due date")
    alerts_count: int = Field(..., description="Number of active alerts")
    acknowledged: bool = Field(
        default=False, 
        description="Whether user has acknowledged the plan"
    )
    valid_from: datetime = Field(..., description="Plan validity start date")
    created_at: datetime = Field(..., description="Plan creation timestamp")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class CarePlanAcknowledgment(BaseModel):
    """Schema for care plan acknowledgment requests."""
    
    acknowledged: bool = Field(
        default=True, 
        description="Acknowledgment status"
    )
    user_notes: Optional[str] = Field(
        None, 
        max_length=500, 
        description="Optional user notes about the plan"
    )


class CarePlanHistoryResponse(BaseModel):
    """Schema for care plan history responses."""
    
    plant_id: UUID = Field(..., description="Associated plant identifier")
    plans: List[CarePlanHistory] = Field(
        ..., 
        description="List of care plan versions"
    )
    total_count: int = Field(..., description="Total number of plans")
    current_version: int = Field(..., description="Current active plan version")


class CarePlanGenerationMetrics(BaseModel):
    """Schema for care plan generation performance metrics."""
    
    generation_time_ms: float = Field(
        ..., 
        description="Time taken to generate the plan in milliseconds"
    )
    context_collection_ms: float = Field(
        ..., 
        description="Time taken to collect context data"
    )
    rule_evaluation_ms: float = Field(
        ..., 
        description="Time taken to evaluate rules"
    )
    ml_inference_ms: Optional[float] = Field(
        None, 
        description="Time taken for ML inference"
    )
    cache_hit: bool = Field(
        default=False, 
        description="Whether cached data was used"
    )