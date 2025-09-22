"""Environmental data schemas for seasonal AI predictions."""

from datetime import datetime, date
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from enum import Enum


class WeatherProvider(str, Enum):
    """Supported weather API providers."""
    OPENWEATHERMAP = "openweathermap"
    WEATHERAPI = "weatherapi"


class Location(BaseModel):
    """Geographic location for weather data."""
    latitude: float = Field(..., ge=-90, le=90, description="Latitude in decimal degrees")
    longitude: float = Field(..., ge=-180, le=180, description="Longitude in decimal degrees")
    city: Optional[str] = Field(None, description="City name")
    country: Optional[str] = Field(None, description="Country name")
    timezone: Optional[str] = Field(None, description="Timezone identifier")


class WeatherCondition(BaseModel):
    """Current weather conditions."""
    temperature: float = Field(..., description="Temperature in Celsius")
    humidity: float = Field(..., ge=0, le=100, description="Humidity percentage")
    pressure: float = Field(..., description="Atmospheric pressure in hPa")
    wind_speed: float = Field(..., ge=0, description="Wind speed in m/s")
    wind_direction: Optional[float] = Field(None, ge=0, le=360, description="Wind direction in degrees")
    precipitation: float = Field(0, ge=0, description="Precipitation in mm")
    cloud_cover: float = Field(..., ge=0, le=100, description="Cloud cover percentage")
    uv_index: Optional[float] = Field(None, ge=0, description="UV index")
    visibility: Optional[float] = Field(None, ge=0, description="Visibility in km")


class WeatherForecast(BaseModel):
    """Weather forecast data."""
    location: Location
    current: WeatherCondition
    forecast_days: List[Dict[str, Any]] = Field(..., description="Daily forecast data")
    provider: WeatherProvider
    retrieved_at: datetime
    expires_at: datetime


class DaylightInfo(BaseModel):
    """Daylight and astronomical information."""
    date: date
    sunrise: datetime
    sunset: datetime
    daylight_hours: float = Field(..., description="Hours of daylight")
    solar_noon: datetime
    civil_twilight_begin: datetime
    civil_twilight_end: datetime
    astronomical_twilight_begin: datetime
    astronomical_twilight_end: datetime


class DaylightPatterns(BaseModel):
    """Seasonal daylight patterns for a location."""
    location: Location
    year: int
    daily_patterns: List[DaylightInfo]
    average_daylight_by_month: Dict[int, float] = Field(..., description="Average daylight hours by month")
    shortest_day: DaylightInfo
    longest_day: DaylightInfo


class ClimateData(BaseModel):
    """Historical climate data for seasonal analysis."""
    location: Location
    start_date: date
    end_date: date
    temperature_avg: List[float] = Field(..., description="Average daily temperatures")
    temperature_min: List[float] = Field(..., description="Minimum daily temperatures")
    temperature_max: List[float] = Field(..., description="Maximum daily temperatures")
    precipitation: List[float] = Field(..., description="Daily precipitation amounts")
    humidity_avg: List[float] = Field(..., description="Average daily humidity")
    daylight_hours: List[float] = Field(..., description="Daily daylight hours")
    dates: List[date] = Field(..., description="Corresponding dates for data points")


class SeasonalTransition(BaseModel):
    """Detected seasonal transition information."""
    location: Location
    transition_type: str = Field(..., description="Type of transition (spring_onset, winter_onset, etc.)")
    estimated_date: date
    confidence: float = Field(..., ge=0, le=1, description="Confidence score for the transition")
    indicators: Dict[str, Any] = Field(..., description="Environmental indicators supporting the transition")
    temperature_trend: str = Field(..., description="Temperature trend (warming, cooling, stable)")
    daylight_trend: str = Field(..., description="Daylight trend (increasing, decreasing, stable)")


class PestRiskFactor(BaseModel):
    """Pest risk assessment factor."""
    pest_type: str
    risk_level: str = Field(..., description="Risk level: low, medium, high, critical")
    risk_score: float = Field(..., ge=0, le=1, description="Numerical risk score")
    seasonal_peak: Optional[str] = Field(None, description="Peak season for this pest")
    environmental_triggers: List[str] = Field(..., description="Environmental conditions that increase risk")
    prevention_measures: List[str] = Field(..., description="Recommended prevention measures")


class PestRiskData(BaseModel):
    """Comprehensive pest risk assessment."""
    location: Location
    plant_species: str
    assessment_date: date
    overall_risk_score: float = Field(..., ge=0, le=1, description="Overall pest risk score")
    risk_factors: List[PestRiskFactor]
    seasonal_recommendations: Dict[str, List[str]] = Field(..., description="Seasonal prevention recommendations")


class EnvironmentalDataCache(BaseModel):
    """Cached environmental data entry."""
    location_hash: str
    data_type: str
    date_range_start: date
    date_range_end: date
    data: Dict[str, Any]
    expires_at: datetime
    created_at: datetime


# Request/Response schemas
class WeatherDataRequest(BaseModel):
    """Request schema for weather data."""
    location: Location
    days_ahead: int = Field(7, ge=1, le=14, description="Number of forecast days")
    include_historical: bool = Field(False, description="Include historical data")
    historical_days: int = Field(30, ge=1, le=365, description="Days of historical data")


class ClimateDataRequest(BaseModel):
    """Request schema for climate data."""
    location: Location
    start_date: date
    end_date: date
    data_types: List[str] = Field(["temperature", "precipitation", "humidity"], description="Types of climate data to retrieve")


class DaylightPatternsRequest(BaseModel):
    """Request schema for daylight patterns."""
    location: Location
    year: int = Field(..., ge=1900, le=2100, description="Year for daylight calculations")


class PestRiskRequest(BaseModel):
    """Request schema for pest risk assessment."""
    location: Location
    plant_species: str
    assessment_period_days: int = Field(90, ge=30, le=365, description="Period for risk assessment")