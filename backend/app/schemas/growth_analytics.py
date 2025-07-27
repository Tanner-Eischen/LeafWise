"""
Growth Analytics Schemas

This module defines Pydantic schemas for growth analytics,
pattern recognition, and comparative analysis functionality.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any, Union
from uuid import UUID
from enum import Enum

from pydantic import BaseModel, Field, ConfigDict


class AnalysisType(str, Enum):
    """Types of growth analysis."""
    COMPREHENSIVE = "comprehensive"
    TRENDS = "trends"
    SEASONAL = "seasonal"
    COMPARATIVE = "comparative"


class ComparisonType(str, Enum):
    """Types of comparative analysis."""
    USER_PLANTS = "user_plants"
    SPECIES = "species"
    COMMUNITY = "community"


class TrendDirection(str, Enum):
    """Direction of growth trends."""
    INCREASING = "increasing"
    DECREASING = "decreasing"
    STABLE = "stable"


class GrowthPhaseType(str, Enum):
    """Types of growth phases."""
    STEADY_GROWTH = "steady_growth"
    VARIABLE_GROWTH = "variable_growth"
    DECLINE = "decline"
    DORMANT = "dormant"
    RAPID_GROWTH = "rapid_growth"


class InsightType(str, Enum):
    """Types of insights."""
    POSITIVE = "positive"
    WARNING = "warning"
    INFO = "info"
    ALERT = "alert"
    SEASONAL = "seasonal"
    COMPARATIVE = "comparative"
    ATTENTION = "attention"
    SPECIES = "species"
    COMMUNITY = "community"


# Base schemas for analytics data structures

class GrowthRateData(BaseModel):
    """Growth rate statistics."""
    model_config = ConfigDict(from_attributes=True)
    
    average: float = Field(..., description="Average growth rate")
    median: float = Field(..., description="Median growth rate")
    std_dev: float = Field(..., description="Standard deviation")
    min: float = Field(..., description="Minimum growth rate")
    max: float = Field(..., description="Maximum growth rate")
    data_points: int = Field(..., description="Number of data points")


class TrendAnalysis(BaseModel):
    """Time series trend analysis results."""
    model_config = ConfigDict(from_attributes=True)
    
    status: str = Field(..., description="Analysis status")
    trend_slope: Optional[float] = Field(None, description="Trend slope coefficient")
    trend_direction: Optional[TrendDirection] = Field(None, description="Direction of trend")
    trend_strength: Optional[float] = Field(None, description="R-squared value for trend strength")
    data_points: Optional[int] = Field(None, description="Number of data points analyzed")
    height_range: Optional[Dict[str, float]] = Field(None, description="Height range statistics")


class GrowthPhase(BaseModel):
    """Growth phase information."""
    model_config = ConfigDict(from_attributes=True)
    
    phase_type: GrowthPhaseType = Field(..., description="Type of growth phase")
    description: str = Field(..., description="Description of the phase")
    duration_days: int = Field(..., description="Duration of phase in days")
    characteristics: List[str] = Field(..., description="Phase characteristics")


class AnalyticsInsight(BaseModel):
    """Analytics insight with actionable recommendations."""
    model_config = ConfigDict(from_attributes=True)
    
    type: InsightType = Field(..., description="Type of insight")
    title: str = Field(..., description="Insight title")
    description: str = Field(..., description="Detailed description")
    confidence: Optional[float] = Field(None, description="Confidence score (0-1)")
    actionable: Optional[str] = Field(None, description="Actionable recommendation")


class MeasurementTimeline(BaseModel):
    """Timeline point with measurements."""
    model_config = ConfigDict(from_attributes=True)
    
    date: datetime = Field(..., description="Measurement date")
    photo_id: str = Field(..., description="Associated photo ID")
    measurements: Dict[str, Any] = Field(..., description="Plant measurements")
    sequence_number: int = Field(..., description="Sequence number in timeline")


class DataQuality(BaseModel):
    """Data quality metrics."""
    model_config = ConfigDict(from_attributes=True)
    
    total_photos: int = Field(..., description="Total number of photos")
    sessions_analyzed: int = Field(..., description="Number of sessions analyzed")
    measurement_completeness: float = Field(..., description="Completeness of measurements (0-1)")


class AnalysisPeriod(BaseModel):
    """Analysis time period."""
    model_config = ConfigDict(from_attributes=True)
    
    start_date: str = Field(..., description="Start date of analysis")
    end_date: str = Field(..., description="End date of analysis")
    days: Optional[int] = Field(None, description="Number of days analyzed")
    seasons_analyzed: Optional[int] = Field(None, description="Number of seasons analyzed")


# Request schemas

class GrowthTrendsRequest(BaseModel):
    """Request for growth trends analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID = Field(..., description="ID of the plant to analyze")
    time_period_days: int = Field(default=90, description="Number of days to analyze")


class ComparativeAnalysisRequest(BaseModel):
    """Request for comparative analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    user_id: UUID = Field(..., description="ID of the user")
    comparison_type: ComparisonType = Field(..., description="Type of comparison")
    time_period_days: int = Field(default=90, description="Number of days to analyze")


class SeasonalPatternsRequest(BaseModel):
    """Request for seasonal pattern analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID = Field(..., description="ID of the plant to analyze")
    seasons_to_analyze: int = Field(default=4, description="Number of seasons to analyze")


class AnalyticsReportRequest(BaseModel):
    """Request for comprehensive analytics report."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: UUID = Field(..., description="ID of the plant")
    analysis_type: AnalysisType = Field(default=AnalysisType.COMPREHENSIVE, description="Type of analysis")


# Response schemas

class GrowthTrendsResponse(BaseModel):
    """Response for growth trends analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: str = Field(..., description="Plant ID")
    analysis_period: AnalysisPeriod = Field(..., description="Analysis period")
    data_quality: DataQuality = Field(..., description="Data quality metrics")
    trend_analysis: TrendAnalysis = Field(..., description="Trend analysis results")
    growth_rates: Dict[str, Union[GrowthRateData, Dict[str, str]]] = Field(..., description="Growth rate statistics")
    growth_phases: List[GrowthPhase] = Field(..., description="Detected growth phases")
    insights: List[AnalyticsInsight] = Field(..., description="Generated insights")
    measurement_timeline: List[MeasurementTimeline] = Field(..., description="Measurement timeline")


class PlantPerformance(BaseModel):
    """Plant performance metrics."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: str = Field(..., description="Plant ID")
    plant_name: str = Field(..., description="Plant name")
    species_id: str = Field(..., description="Species ID")
    health_status: str = Field(..., description="Current health status")
    growth_trend: str = Field(..., description="Growth trend direction")
    trend_strength: float = Field(..., description="Trend strength")
    current_height: float = Field(..., description="Current height in cm")
    height_change: float = Field(..., description="Total height change")
    performance_score: float = Field(..., description="Overall performance score")


class ComparativeAnalysisResponse(BaseModel):
    """Response for comparative analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    comparison_type: str = Field(..., description="Type of comparison")
    total_plants: Optional[int] = Field(None, description="Total plants in comparison")
    analyzed_plants: Optional[int] = Field(None, description="Number of plants analyzed")
    time_period_days: int = Field(..., description="Analysis time period")
    plant_rankings: Optional[List[PlantPerformance]] = Field(None, description="Ranked plant performance")
    insights: List[AnalyticsInsight] = Field(..., description="Comparative insights")
    summary: Optional[Dict[str, Any]] = Field(None, description="Summary statistics")
    status: Optional[str] = Field(None, description="Analysis status")
    message: Optional[str] = Field(None, description="Status message")


class SpeciesPerformance(BaseModel):
    """Species performance metrics."""
    model_config = ConfigDict(from_attributes=True)
    
    species_id: str = Field(..., description="Species ID")
    plant_count: int = Field(..., description="Number of plants of this species")
    analyzed_count: int = Field(..., description="Number of plants analyzed")
    avg_trend_strength: float = Field(..., description="Average trend strength")
    avg_height_change: float = Field(..., description="Average height change")
    performance_score: float = Field(..., description="Overall species performance score")


class SeasonalCluster(BaseModel):
    """Seasonal clustering data."""
    model_config = ConfigDict(from_attributes=True)
    
    status: str = Field(..., description="Clustering status")
    seasonal_groups: Optional[Dict[str, List[Dict[str, Any]]]] = Field(None, description="Seasonal data groups")
    seasonal_stats: Optional[Dict[str, Dict[str, Any]]] = Field(None, description="Seasonal statistics")
    clustering_method: Optional[str] = Field(None, description="Clustering method used")
    message: Optional[str] = Field(None, description="Status message")


class SeasonalResponsePattern(BaseModel):
    """Seasonal response pattern."""
    model_config = ConfigDict(from_attributes=True)
    
    pattern_type: str = Field(..., description="Type of pattern")
    description: str = Field(..., description="Pattern description")
    peak_season: Optional[str] = Field(None, description="Peak growth season")
    dormant_season: Optional[str] = Field(None, description="Dormant season")
    growth_variation: Optional[float] = Field(None, description="Growth variation between seasons")


class SeasonalRecommendation(BaseModel):
    """Seasonal care recommendation."""
    model_config = ConfigDict(from_attributes=True)
    
    season: str = Field(..., description="Season for recommendation")
    recommendation: str = Field(..., description="Care recommendation")
    reason: str = Field(..., description="Reason for recommendation")
    priority: str = Field(..., description="Priority level")


class SeasonalPatternsResponse(BaseModel):
    """Response for seasonal pattern analysis."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: str = Field(..., description="Plant ID")
    analysis_period: AnalysisPeriod = Field(..., description="Analysis period")
    data_quality: DataQuality = Field(..., description="Data quality metrics")
    seasonal_clusters: SeasonalCluster = Field(..., description="Seasonal clustering results")
    response_patterns: List[SeasonalResponsePattern] = Field(..., description="Identified response patterns")
    insights: List[AnalyticsInsight] = Field(..., description="Seasonal insights")
    recommendations: List[SeasonalRecommendation] = Field(..., description="Seasonal recommendations")


class PlantInfo(BaseModel):
    """Basic plant information."""
    model_config = ConfigDict(from_attributes=True)
    
    nickname: Optional[str] = Field(None, description="Plant nickname")
    species_id: str = Field(..., description="Species ID")
    location: Optional[str] = Field(None, description="Plant location")
    acquired_date: Optional[str] = Field(None, description="Date acquired")
    health_status: str = Field(..., description="Current health status")


class AnalyticsSummary(BaseModel):
    """Analytics summary statistics."""
    model_config = ConfigDict(from_attributes=True)
    
    total_sessions: int = Field(..., description="Total time-lapse sessions")
    total_photos: int = Field(..., description="Total photos captured")
    total_milestones: int = Field(..., description="Total milestones achieved")
    plant_age_days: int = Field(..., description="Plant age in days")
    health_status: str = Field(..., description="Current health status")


class AnalyticsReportResponse(BaseModel):
    """Response for comprehensive analytics report."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: str = Field(..., description="Plant ID")
    plant_info: PlantInfo = Field(..., description="Plant information")
    report_type: str = Field(..., description="Type of report")
    generated_at: str = Field(..., description="Report generation timestamp")
    growth_trends: Optional[GrowthTrendsResponse] = Field(None, description="Growth trend analysis")
    seasonal_patterns: Optional[SeasonalPatternsResponse] = Field(None, description="Seasonal pattern analysis")
    comparative_analysis: Optional[ComparativeAnalysisResponse] = Field(None, description="Comparative analysis")
    summary: AnalyticsSummary = Field(..., description="Summary statistics")


class CommunityComparison(BaseModel):
    """Community comparison data."""
    model_config = ConfigDict(from_attributes=True)
    
    plant_id: str = Field(..., description="Plant ID")
    plant_name: str = Field(..., description="Plant name")
    user_performance: float = Field(..., description="User's plant performance")
    community_average: float = Field(..., description="Community average performance")
    percentile: int = Field(..., description="User's percentile ranking")
    sample_size: int = Field(..., description="Community sample size")


# List response schemas

class GrowthTrendsListResponse(BaseModel):
    """Response for listing growth trends."""
    model_config = ConfigDict(from_attributes=True)
    
    trends: List[GrowthTrendsResponse]
    total_count: int
    user_id: str


class ComparativeAnalysisListResponse(BaseModel):
    """Response for listing comparative analyses."""
    model_config = ConfigDict(from_attributes=True)
    
    analyses: List[ComparativeAnalysisResponse]
    total_count: int
    user_id: str


class SeasonalPatternsListResponse(BaseModel):
    """Response for listing seasonal patterns."""
    model_config = ConfigDict(from_attributes=True)
    
    patterns: List[SeasonalPatternsResponse]
    total_count: int
    user_id: str


# Error response schemas

class AnalyticsErrorResponse(BaseModel):
    """Error response for analytics operations."""
    model_config = ConfigDict(from_attributes=True)
    
    error: str = Field(..., description="Error type")
    message: str = Field(..., description="Error message")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")
    timestamp: str = Field(..., description="Error timestamp")