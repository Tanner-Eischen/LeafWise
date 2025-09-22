"""User plant database model.

This module defines the UserPlant model for tracking individual plants
owned by users, including care schedules and plant health status.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class UserPlant(Base):
    """User plant model for tracking individual plants."""
    
    __tablename__ = "user_plants"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    species_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_species.id"), nullable=False)
    nickname = Column(String(100))
    location = Column(String(100))  # e.g., "Living room window", "Bedroom"
    acquired_date = Column(DateTime)
    last_watered = Column(DateTime)
    last_fertilized = Column(DateTime)
    last_repotted = Column(DateTime)
    health_status = Column(String(20), default="healthy")  # healthy, sick, recovering, dead
    notes = Column(Text)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="plants")
    species = relationship("PlantSpecies", back_populates="user_plants")
    care_logs = relationship("PlantCareLog", back_populates="plant")
    photos = relationship("PlantPhoto", back_populates="plant")
    milestones = relationship("PlantMilestone", back_populates="plant")
    
    # Seasonal AI and Time-lapse relationships
    seasonal_predictions = relationship("SeasonalPrediction", back_populates="plant", cascade="all, delete-orphan")
    timelapse_sessions = relationship("TimelapseSession", back_populates="plant", cascade="all, delete-orphan")
    growth_analytics = relationship("GrowthAnalytics", back_populates="plant", cascade="all, delete-orphan")
    
    # Care plan relationships
    care_plans = relationship("CarePlanV2", back_populates="plant", cascade="all, delete-orphan")
    
    def __repr__(self) -> str:
        return f"<UserPlant(id={self.id}, nickname='{self.nickname}', user_id={self.user_id})>"