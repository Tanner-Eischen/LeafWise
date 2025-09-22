"""Seasonal AI database models.

This module defines the database models for seasonal predictions,
environmental data caching, and seasonal AI functionality.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, Integer, Float, Date
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID, JSONB, DATERANGE
from sqlalchemy.orm import relationship

from app.core.database import Base


class SeasonalPrediction(Base):
    """Model for storing seasonal AI predictions for plants."""
    
    __tablename__ = "seasonal_predictions"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    prediction_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    prediction_period_start = Column(Date, nullable=False)
    prediction_period_end = Column(Date, nullable=False)
    
    # JSON fields for complex data structures
    growth_forecast = Column(JSONB, nullable=False)  # GrowthForecast data
    care_adjustments = Column(JSONB, nullable=False)  # List of CareAdjustment data
    risk_factors = Column(JSONB, nullable=True)  # List of RiskFactor data
    optimal_activities = Column(JSONB, nullable=True)  # List of PlantActivity data
    
    # Prediction metadata
    confidence_score = Column(Float, nullable=False)
    model_version = Column(String(50), nullable=True)
    environmental_factors = Column(JSONB, nullable=True)  # Environmental conditions used
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="seasonal_predictions")
    
    def __repr__(self) -> str:
        return f"<SeasonalPrediction(id={self.id}, plant_id={self.plant_id}, confidence={self.confidence_score})>"


class EnvironmentalDataCache(Base):
    """Model for caching environmental data from external APIs."""
    
    __tablename__ = "environmental_data_cache"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    location_hash = Column(String(100), nullable=False, index=True)  # Hash of location coordinates
    data_type = Column(String(50), nullable=False, index=True)  # weather, climate, daylight, etc.
    date_range = Column(DATERANGE, nullable=False)
    
    # Cached data
    data = Column(JSONB, nullable=False)  # The actual environmental data
    source = Column(String(100), nullable=True)  # API source (OpenWeatherMap, etc.)
    
    # Cache metadata
    expires_at = Column(DateTime, nullable=False)
    hit_count = Column(Integer, default=0)
    last_accessed = Column(DateTime, default=datetime.utcnow)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    def __repr__(self) -> str:
        return f"<EnvironmentalDataCache(id={self.id}, type={self.data_type}, location={self.location_hash})>"


class SeasonalTransition(Base):
    """Model for tracking seasonal transitions and their effects on plants."""
    
    __tablename__ = "seasonal_transitions"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    location_hash = Column(String(100), nullable=False, index=True)
    transition_type = Column(String(50), nullable=False)  # spring_onset, winter_dormancy, etc.
    transition_date = Column(Date, nullable=False)
    
    # Transition characteristics
    temperature_change = Column(Float, nullable=True)  # Average temperature change
    daylight_change = Column(Float, nullable=True)  # Hours of daylight change
    precipitation_change = Column(Float, nullable=True)  # Precipitation pattern change
    
    # Metadata
    confidence_score = Column(Float, nullable=False)
    detection_method = Column(String(50), nullable=True)  # algorithm used for detection
    environmental_indicators = Column(JSONB, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    def __repr__(self) -> str:
        return f"<SeasonalTransition(id={self.id}, type={self.transition_type}, date={self.transition_date})>"