"""Seasonal AI prediction schemas.

This module defines Pydantic schemas for seasonal AI predictions,
care adjustments, and growth forecasting functionality.
"""
from __future__ import annotations

from datetime import datetime, date
from typing import Optional, Any
from uuid import UUID
from enum import Enum

from pydantic import BaseModel, Field, ConfigDict


class Season(str, Enum):
    """Seasons for seasonal predictions."""
    SPRING = "spring"
    SUMMER = "summer"
    AUTUMN = "autumn"
    WINTER = "winter"


class CareType(str, Enum):
    """Types of plant care activities."""
    WATERING = "watering"
    FERTILIZING = "fertilizing"
    LIGHT = "light"
    HUMIDITY = "humidity"
    TEMPERATURE = "temperature"
    PRUNING = "pruning"
    REPOTTING = "repotting"
    PEST_CONTROL = "pest_control"


class RiskLevel(str, Enum):
    """Risk levels for seasonal factors."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class GrowthPhaseType(str, Enum):
    """Types of plant growth phases."""
    ACTIVE_GROWTH = "active_growth"
    SLOW_GROWTH = "slow_growth"
    DORMANCY = "dormancy"
    FLOWERING = "flowering"
    FRUITING = "fruiting"
    RECOVERY = "recovery"


class ActivityType(str, Enum):
    """Types of plant activities."""
    REPOTTING = "repotting"
    PROPAGATION = "propagation"
    PRUNING = "pruning"
    FERTILIZING = "fertilizing"
    PEST_TREATMENT = "pest_treatment"


# Base data structures
class SizeProjection(BaseModel):
    """Size projection for a specific date."""
    model_config = ConfigDict(from_attributes=True)
    
    projection_date: date = Field(..., description="Projection date")
    height_cm: Optional[float] = Field(None, description="Projected height in cm")
    width_cm: Optional[float] = Field(None, description="Projected width in cm")
    leaf_count: Optional[int] = Field(None, description="Projected leaf count")
    confidence: float = Field(..., ge=0, le=1, description="Projection confidence")


class FloweringPeriod(BaseModel):
    """Flowering period prediction."""
    model_config = ConfigDict(from_attributes=True)
    
    start_date: date = Field(..., description="Expected flowering start")
    end_date: date = Field(..., description="Expected flowering end")
    peak_bloom_date: Optional[date] = Field(None, description="Peak bloom date")
    confidence: float = Field(..., ge=0, le=1, description="Prediction confidence")


class DormancyPeriod(BaseModel):
    """Dormancy period prediction."""
    model_config = ConfigDict(from_attributes=True)
    
    start_date: date = Field(..., description="Expected dormancy start")
    end_date: date = Field(..., description="Expected dormancy end")
    dormancy_type: str = Field(..., description="Type of dormancy")
    care_adjustments: list[str] = Field(default_factory=list, description="Required care adjustments")
    confidence: float = Field(..., ge=0, le=1, description="Prediction confidence")


class GrowthForecast(BaseModel):
    """Growth forecast data."""
    model_config = ConfigDict(from_attributes=True)
    
    expected_growth_rate: float = Field(..., description="Expected growth rate (cm/month)")
    size_projections: list[SizeProjection] = Field(..., description="Size projections over time")
    flowering_predictions: list[FloweringPeriod] = Field(default_factory=list, description="Flowering predictions")
    dormancy_periods: list[DormancyPeriod] = Field(default_factory=list, description="Dormancy predictions")
    stress_likelihood: float = Field(..., ge=0, le=1, description="Likelihood of seasonal stress")


class CareAdjustment(BaseModel):
    """Care adjustment recommendation."""
    model_config = ConfigDict(from_attributes=True)
    
    care_type: CareType = Field(..., description="Type of care to adjust")
    current_frequency: Optional[str] = Field(None, description="Current care frequency")
    recommended_frequency: str = Field(..., description="Recommended care frequency")
    adjustment_reason: str = Field(..., description="Reason for adjustment")
    seasonal_factor: str = Field(..., description="Seasonal factor driving adjustment")
    priority: int = Field(..., ge=1, le=5, description="Priority level (1=highest)")
    start_date: Optional[date] = Field(None, description="When to start adjustment")
    end_date: Optional[date] = Field(None, description="When to end adjustment")


class RiskFactor(BaseModel):
    """Seasonal risk factor."""
    model_config = ConfigDict(from_attributes=True)
    
    risk_type: str = Field(..., description="Type of risk")
    risk_level: RiskLevel = Field(..., description="Risk severity level")
    probability: float = Field(..., ge=0, le=1, description="Risk probability")
    impact_description: str = Field(..., description="Description of potential impact")
    prevention_measures: list[str] = Field(..., description="Recommended prevention measures")
    monitoring_indicators: list[str] = Field(..., description="Signs to monitor")


class PlantActivity(BaseModel):
    """Plant activity prediction."""
    model_config = ConfigDict(from_attributes=True)
    
    activity_type: str = Field(..., description="Type of activity")
    optimal_date_range: tuple[date, date] = Field(..., description="Optimal date range")
    description: str = Field(..., description="Activity description")
    required_conditions: list[str] = Field(default_factory=list, description="Required conditions")


class GrowthPhase(BaseModel):
    """Growth phase prediction."""
    model_config = ConfigDict(from_attributes=True)
    
    phase_type: GrowthPhaseType = Field(..., description="Type of growth phase")
    start_date: date = Field(..., description="Phase start date")
    end_date: date = Field(..., description="Phase end date")
    characteristics: list[str] = Field(..., description="Phase characteristics")
    care_requirements: list[str] = Field(..., description="Special care requirements")
    expected_changes: list[str] = Field(..., description="Expected plant changes")


# Request schemas
class SeasonalPredictionRequest(BaseModel):
    """Request for seasonal predictions."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID = Field(..., description="ID of the plant")
    prediction_days: int = Field(default=90, ge=30, le=365, description="Number of days to predict")
    include_care_adjustments: bool = Field(default=True, description="Include care adjustments")
    include_risk_factors: bool = Field(default=True, description="Include risk factors")
    include_activities: bool = Field(default=True, description="Include optimal activities")


class CustomPredictionRequest(BaseModel):
    """Request for custom seasonal prediction."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_species: str = Field(..., description="Plant species identifier")
    location: dict[str, float] = Field(..., description="Location coordinates")
    current_conditions: dict[str, Any] = Field(..., description="Current environmental conditions")
    plant_age_days: Optional[int] = Field(None, description="Plant age in days")
    current_size: Optional[dict[str, float]] = Field(None, description="Current plant size")
    prediction_days: int = Field(default=90, ge=30, le=365, description="Number of days to predict")


class CareAdjustmentRequest(BaseModel):
    """Request for care adjustments."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID = Field(..., description="ID of the plant")
    current_season: Optional[Season] = Field(None, description="Current season")
    specific_concerns: Optional[list[str]] = Field(None, description="Specific care concerns")


# Response schemas
class SeasonalPrediction(BaseModel):
    """Complete seasonal prediction response."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID
    prediction_date: datetime
    prediction_period_start: date
    prediction_period_end: date
    growth_forecast: GrowthForecast
    care_adjustments: list[CareAdjustment]
    risk_factors: list[RiskFactor]
    optimal_activities: list[PlantActivity]
    growth_phases: list[GrowthPhase]
    confidence_score: float = Field(..., ge=0, le=1, description="Overall prediction confidence")
    environmental_factors: dict[str, Any] = Field(default_factory=dict, description="Environmental factors considered")
    model_version: str = Field(..., description="Version of prediction model used")


class CareAdjustmentResponse(BaseModel):
    """Response for care adjustment recommendations."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID
    current_season: Season
    adjustment_date: datetime
    care_adjustments: list[CareAdjustment]
    seasonal_summary: str = Field(..., description="Summary of seasonal conditions")
    next_review_date: date = Field(..., description="When to review adjustments again")


class CustomPredictionResponse(BaseModel):
    """Response for custom prediction request."""
    model_config = ConfigDict(from_attributes=True)
    
    prediction_id: str = Field(..., description="Unique prediction identifier")
    plant_species: str
    location: dict[str, float]
    prediction_date: datetime
    growth_forecast: GrowthForecast
    care_recommendations: list[CareAdjustment]
    risk_assessment: list[RiskFactor]
    confidence_score: float = Field(..., ge=0, le=1, description="Overall prediction confidence")
    limitations: list[str] = Field(default_factory=list, description="Prediction limitations")


class SeasonalPredictionListResponse(BaseModel):
    """Response for listing seasonal predictions."""
    model_config = ConfigDict(from_attributes=True)
    
    predictions: list[SeasonalPrediction]
    total_count: int
    plant_id: UUID


class SeasonalTransitionResponse(BaseModel):
    """Response for seasonal transition detection."""
    model_config = ConfigDict(from_attributes=True)
    
    location: dict[str, float]
    current_season: Season
    next_season: Season
    transition_date: date
    transition_confidence: float = Field(..., ge=0, le=1, description="Transition prediction confidence")
    environmental_indicators: list[str] = Field(..., description="Environmental signs of transition")
    plant_care_implications: list[str] = Field(..., description="Care implications of transition")


# Error response schemas
class SeasonalAIErrorResponse(BaseModel):
    """Error response for seasonal AI operations."""
    model_config = ConfigDict(from_attributes=True)
    
    error: str = Field(..., description="Error type")
    message: str = Field(..., description="Error message")
    details: Optional[dict[str, Any]] = Field(None, description="Additional error details")
    timestamp: datetime = Field(..., description="Error timestamp")
    plant_id: Optional[UUID] = Field(None, description="Plant ID if applicable")