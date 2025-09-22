"""Local nursery database model.

This module defines models for local nurseries and garden centers.
"""

from datetime import datetime, time
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, Boolean, Float, JSON, Time, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class LocalNursery(Base):
    """Local nursery model for garden centers and plant shops."""
    
    __tablename__ = "local_nurseries"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    
    # Location information
    address = Column(String(500))
    city = Column(String(100))
    state = Column(String(50))
    country = Column(String(50))
    postal_code = Column(String(20))
    latitude = Column(Float)
    longitude = Column(Float)
    
    # Contact information
    phone = Column(String(20))
    email = Column(String(100))
    website = Column(String(200))
    
    # Business information
    business_type = Column(String(50))  # nursery, garden_center, plant_shop, greenhouse
    specialties = Column(JSON)  # List of specialties like ["houseplants", "succulents", "native_plants"]
    services = Column(JSON)  # List of services like ["delivery", "consultation", "repotting"]
    
    # Operating hours (JSON format for flexibility)
    operating_hours = Column(JSON)  # {"monday": {"open": "08:00", "close": "18:00"}, ...}
    
    # Ratings and verification
    average_rating = Column(Float, default=0.0)
    total_reviews = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)
    verified_at = Column(DateTime)
    
    # Status
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    reviews = relationship("NurseryReview", back_populates="nursery")
    events = relationship("NurseryEvent", back_populates="nursery")
    
    def __repr__(self) -> str:
        return f"<LocalNursery(id={self.id}, name='{self.name}', city='{self.city}')>"


class NurseryReview(Base):
    """Nursery review model for user feedback."""
    
    __tablename__ = "nursery_reviews"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    nursery_id = Column(PostgresUUID(as_uuid=True), ForeignKey("local_nurseries.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    rating = Column(Integer, nullable=False)  # 1-5 stars
    title = Column(String(200))
    review_text = Column(Text)
    
    # Review categories
    plant_quality_rating = Column(Integer)  # 1-5
    service_rating = Column(Integer)  # 1-5
    price_rating = Column(Integer)  # 1-5
    selection_rating = Column(Integer)  # 1-5
    
    # Tags for categorization
    tags = Column(JSON)  # ["helpful_staff", "good_prices", "wide_selection"]
    
    # Verification
    is_verified_purchase = Column(Boolean, default=False)
    visit_date = Column(DateTime)
    
    # Status
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    nursery = relationship("LocalNursery", back_populates="reviews")
    user = relationship("User", back_populates="nursery_reviews")
    
    def __repr__(self) -> str:
        return f"<NurseryReview(id={self.id}, nursery_id={self.nursery_id}, rating={self.rating})>"


class NurseryEvent(Base):
    """Nursery event model for workshops and special events."""
    
    __tablename__ = "nursery_events"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    nursery_id = Column(PostgresUUID(as_uuid=True), ForeignKey("local_nurseries.id"), nullable=False)
    
    title = Column(String(200), nullable=False)
    description = Column(Text)
    event_type = Column(String(50))  # workshop, sale, plant_swap, consultation
    
    # Scheduling
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime)
    start_time = Column(Time)
    end_time = Column(Time)
    is_recurring = Column(Boolean, default=False)
    recurrence_pattern = Column(JSON)  # For recurring events
    
    # Event details
    max_participants = Column(Integer)
    current_participants = Column(Integer, default=0)
    price = Column(Float, default=0.0)
    skill_level = Column(String(20))  # beginner, intermediate, advanced, all
    
    # Requirements and materials
    requirements = Column(Text)  # What participants should bring
    materials_provided = Column(Text)  # What the nursery provides
    
    # Registration
    requires_registration = Column(Boolean, default=True)
    registration_deadline = Column(DateTime)
    contact_info = Column(String(200))
    
    # Status
    is_active = Column(Boolean, default=True)
    is_cancelled = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    nursery = relationship("LocalNursery", back_populates="events")
    
    def __repr__(self) -> str:
        return f"<NurseryEvent(id={self.id}, title='{self.title}', start_date={self.start_date})>"


class UserNurseryFavorite(Base):
    """User favorite nurseries model."""
    
    __tablename__ = "user_nursery_favorites"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    nursery_id = Column(PostgresUUID(as_uuid=True), ForeignKey("local_nurseries.id"), nullable=False)
    
    notes = Column(Text)  # Personal notes about the nursery
    last_visited = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="favorite_nurseries")
    nursery = relationship("LocalNursery")
    
    def __repr__(self) -> str:
        return f"<UserNurseryFavorite(id={self.id}, user_id={self.user_id}, nursery_id={self.nursery_id})>" 