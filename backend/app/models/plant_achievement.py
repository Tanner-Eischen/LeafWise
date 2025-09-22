"""Plant achievement database model.

This module defines models for tracking user achievements and milestones
in their plant care journey.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, Integer, JSON
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantAchievement(Base):
    """Plant achievement model for tracking user milestones."""
    
    __tablename__ = "plant_achievements"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    achievement_type = Column(String(50), nullable=False)  # care_streak, plant_collection, identification, etc.
    title = Column(String(100), nullable=False)
    description = Column(Text)
    icon = Column(String(50))  # emoji or icon name
    badge_color = Column(String(20), default="green")
    points = Column(Integer, default=0)
    unlock_criteria = Column(JSON)  # JSON criteria for unlocking
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user_achievements = relationship("UserAchievement", back_populates="achievement")
    
    def __repr__(self) -> str:
        return f"<PlantAchievement(id={self.id}, title='{self.title}', type='{self.achievement_type}')>"


class UserAchievement(Base):
    """User achievement model for tracking earned achievements."""
    
    __tablename__ = "user_achievements"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    achievement_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_achievements.id"), nullable=False)
    earned_at = Column(DateTime, default=datetime.utcnow)
    progress_data = Column(JSON)  # JSON data for tracking progress
    is_featured = Column(Boolean, default=False)  # Whether to feature on profile
    
    # Relationships
    user = relationship("User", back_populates="achievements")
    achievement = relationship("PlantAchievement", back_populates="user_achievements")
    
    def __repr__(self) -> str:
        return f"<UserAchievement(id={self.id}, user_id={self.user_id}, achievement_id={self.achievement_id})>"


class PlantMilestone(Base):
    """Plant milestone model for tracking plant-specific achievements."""
    
    __tablename__ = "plant_milestones"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    milestone_type = Column(String(50), nullable=False)  # first_flower, one_year_old, propagated, etc.
    title = Column(String(100), nullable=False)
    description = Column(Text)
    achieved_at = Column(DateTime, default=datetime.utcnow)
    photo_url = Column(String(500))  # Optional photo of the milestone
    notes = Column(Text)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="milestones")
    
    def __repr__(self) -> str:
        return f"<PlantMilestone(id={self.id}, plant_id={self.plant_id}, type='{self.milestone_type}')>"


class UserStats(Base):
    """User statistics model for tracking overall plant care stats."""
    
    __tablename__ = "user_stats"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, unique=True)
    
    # Plant collection stats
    total_plants = Column(Integer, default=0)
    active_plants = Column(Integer, default=0)
    plants_identified = Column(Integer, default=0)
    
    # Care activity stats
    total_care_logs = Column(Integer, default=0)
    care_streak_days = Column(Integer, default=0)
    longest_care_streak = Column(Integer, default=0)
    last_care_activity = Column(DateTime)
    
    # Community stats
    questions_asked = Column(Integer, default=0)
    questions_answered = Column(Integer, default=0)
    helpful_answers = Column(Integer, default=0)
    trades_completed = Column(Integer, default=0)
    
    # Achievement stats
    total_achievements = Column(Integer, default=0)
    total_points = Column(Integer, default=0)
    level = Column(Integer, default=1)
    
    # Timestamps
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="stats")
    
    def __repr__(self) -> str:
        return f"<UserStats(id={self.id}, user_id={self.user_id}, level={self.level})>" 