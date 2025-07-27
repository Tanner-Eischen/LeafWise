"""Time-lapse tracking database models.

This module defines the database models for time-lapse sessions,
growth photos, and growth analysis functionality.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, Integer, Float
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID, JSONB
from sqlalchemy.orm import relationship

from app.core.database import Base


class TimelapseSession(Base):
    """Model for tracking time-lapse photography sessions."""
    
    __tablename__ = "timelapse_sessions"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Session configuration
    session_name = Column(String(255), nullable=False)
    start_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    end_date = Column(DateTime, nullable=True)  # Null for ongoing sessions
    
    # Photo capture configuration
    photo_schedule = Column(JSONB, nullable=False)  # PhotoSchedule configuration
    tracking_config = Column(JSONB, nullable=False)  # TrackingConfig settings
    
    # Session status and metadata
    status = Column(String(50), nullable=False, default="active")  # active, paused, completed, cancelled
    total_photos = Column(Integer, default=0)
    last_photo_date = Column(DateTime, nullable=True)
    
    # Growth tracking data
    initial_measurements = Column(JSONB, nullable=True)  # PlantMeasurements at start
    current_measurements = Column(JSONB, nullable=True)  # Latest PlantMeasurements
    milestone_targets = Column(JSONB, nullable=True)  # List of MilestoneTarget
    
    # Video generation
    video_url = Column(String(500), nullable=True)  # Generated time-lapse video URL
    video_generated_at = Column(DateTime, nullable=True)
    video_options = Column(JSONB, nullable=True)  # VideoOptions used for generation
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="timelapse_sessions")
    user = relationship("User", back_populates="timelapse_sessions")
    photos = relationship("GrowthPhoto", back_populates="session", cascade="all, delete-orphan")
    milestones = relationship("GrowthMilestone", back_populates="session", cascade="all, delete-orphan")
    
    def __repr__(self) -> str:
        return f"<TimelapseSession(id={self.id}, name='{self.session_name}', status={self.status})>"


class GrowthPhoto(Base):
    """Model for individual photos in a time-lapse session."""
    
    __tablename__ = "growth_photos"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    session_id = Column(PostgresUUID(as_uuid=True), ForeignKey("timelapse_sessions.id"), nullable=False)
    
    # Photo metadata
    photo_url = Column(String(500), nullable=False)
    capture_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    sequence_number = Column(Integer, nullable=False)  # Order in the time-lapse
    
    # Image analysis results
    plant_measurements = Column(JSONB, nullable=True)  # PlantMeasurements extracted from image
    growth_analysis = Column(JSONB, nullable=True)  # GrowthAnalysis results
    health_indicators = Column(JSONB, nullable=True)  # HealthIndicators from image
    
    # Processing status
    processing_status = Column(String(50), nullable=False, default="pending")  # pending, processing, completed, failed
    processing_error = Column(Text, nullable=True)
    processing_metadata = Column(JSONB, nullable=True)  # Processing algorithm details
    
    # Quality metrics
    image_quality_score = Column(Float, nullable=True)
    positioning_accuracy = Column(Float, nullable=True)  # How well positioned for comparison
    lighting_consistency = Column(Float, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    processed_at = Column(DateTime, nullable=True)
    
    # Relationships
    session = relationship("TimelapseSession", back_populates="photos")
    
    def __repr__(self) -> str:
        return f"<GrowthPhoto(id={self.id}, session_id={self.session_id}, sequence={self.sequence_number})>"


class GrowthMilestone(Base):
    """Model for tracking significant growth milestones in time-lapse sessions."""
    
    __tablename__ = "growth_milestones"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    session_id = Column(PostgresUUID(as_uuid=True), ForeignKey("timelapse_sessions.id"), nullable=False)
    photo_id = Column(PostgresUUID(as_uuid=True), ForeignKey("growth_photos.id"), nullable=True)
    
    # Milestone details
    milestone_type = Column(String(100), nullable=False)  # new_leaf, flowering, height_increase, etc.
    milestone_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    # Milestone data
    achievement_date = Column(DateTime, nullable=False)
    measurement_data = Column(JSONB, nullable=True)  # Specific measurements at milestone
    comparison_data = Column(JSONB, nullable=True)  # Comparison with previous state
    
    # Detection metadata
    detection_method = Column(String(50), nullable=True)  # manual, automatic, ai_detected
    confidence_score = Column(Float, nullable=True)
    detection_metadata = Column(JSONB, nullable=True)
    
    # User interaction
    user_verified = Column(Boolean, default=False)
    user_notes = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    session = relationship("TimelapseSession", back_populates="milestones")
    photo = relationship("GrowthPhoto")
    
    def __repr__(self) -> str:
        return f"<GrowthMilestone(id={self.id}, type={self.milestone_type}, date={self.achievement_date})>"


class GrowthAnalytics(Base):
    """Model for storing aggregated growth analytics and insights."""
    
    __tablename__ = "growth_analytics"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Analytics period
    analysis_period_start = Column(DateTime, nullable=False)
    analysis_period_end = Column(DateTime, nullable=False)
    analysis_type = Column(String(50), nullable=False)  # weekly, monthly, seasonal, custom
    
    # Growth metrics
    growth_rate_data = Column(JSONB, nullable=False)  # Time series growth data
    trend_analysis = Column(JSONB, nullable=True)  # Trend patterns and insights
    seasonal_patterns = Column(JSONB, nullable=True)  # Seasonal behavior patterns
    
    # Comparative analytics
    peer_comparison = Column(JSONB, nullable=True)  # Comparison with similar plants
    historical_comparison = Column(JSONB, nullable=True)  # Comparison with plant's history
    
    # Insights and recommendations
    insights = Column(JSONB, nullable=True)  # Generated insights
    recommendations = Column(JSONB, nullable=True)  # Care recommendations based on analysis
    
    # Analytics metadata
    data_quality_score = Column(Float, nullable=True)
    confidence_level = Column(Float, nullable=True)
    analysis_version = Column(String(50), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="growth_analytics")
    user = relationship("User", back_populates="growth_analytics")
    
    def __repr__(self) -> str:
        return f"<GrowthAnalytics(id={self.id}, plant_id={self.plant_id}, type={self.analysis_type})>"