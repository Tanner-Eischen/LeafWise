"""User model and authentication setup.

This module defines the User model and integrates with FastAPI-Users
for authentication and user management.
"""

import uuid
from datetime import datetime
from typing import Optional

from fastapi_users.db import SQLAlchemyBaseUserTableUUID
from sqlalchemy import Boolean, Column, DateTime, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class User(SQLAlchemyBaseUserTableUUID, Base):
    """User model with authentication and profile information.
    
    Extends FastAPI-Users base user table with additional fields
    for the plant social platform.
    """
    
    __tablename__ = "users"
    
    # Additional profile fields
    username = Column(String(50), unique=True, nullable=False, index=True)
    display_name = Column(String(100), nullable=True)
    bio = Column(Text, nullable=True)
    profile_picture_url = Column(String(500), nullable=True)
    
    # Plant-specific profile fields
    gardening_experience = Column(String(20), nullable=True)  # beginner, intermediate, expert
    favorite_plants = Column(Text, nullable=True)  # JSON array of plant names
    location = Column(String(100), nullable=True)
    
    # Privacy and preferences
    is_private = Column(Boolean, default=False)
    allow_plant_identification = Column(Boolean, default=True)
    allow_friend_requests = Column(Boolean, default=True)
    
    # Role and permission fields for authorization
    is_admin = Column(Boolean, default=False, nullable=False)
    is_expert = Column(Boolean, default=False, nullable=False)
    is_moderator = Column(Boolean, default=False, nullable=False)
    expert_specialties = Column(Text, nullable=True)  # JSON array of plant specialties
    admin_permissions = Column(Text, nullable=True)  # JSON array of specific admin permissions
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_active = Column(DateTime, nullable=True)
    
    # Relationships (will be defined in other models)
    # sent_messages = relationship("Message", foreign_keys="Message.sender_id", back_populates="sender")
    # received_messages = relationship("Message", foreign_keys="Message.recipient_id", back_populates="recipient")
    # stories = relationship("Story", back_populates="user")
    # sent_friend_requests = relationship("Friendship", foreign_keys="Friendship.requester_id")
    # received_friend_requests = relationship("Friendship", foreign_keys="Friendship.addressee_id")
    
    # Plant-related relationships
    plants = relationship("UserPlant", back_populates="user")
    achievements = relationship("UserAchievement", back_populates="user")
    stats = relationship("UserStats", back_populates="user", uselist=False)
    nursery_reviews = relationship("NurseryReview", back_populates="user")
    favorite_nurseries = relationship("UserNurseryFavorite", back_populates="user")
    
    # RAG-related relationships
    preference_embeddings = relationship("UserPreferenceEmbedding", back_populates="user")
    rag_interactions = relationship("RAGInteraction", back_populates="user")
    knowledge_contributions = relationship("PlantKnowledgeBase", back_populates="author")
    
    def __repr__(self) -> str:
        """String representation of the user."""
        return f"<User(id={self.id}, username={self.username}, email={self.email})>"
    
    @property
    def full_name(self) -> str:
        """Get the user's display name or username."""
        return self.display_name or self.username
    
    def to_dict(self) -> dict:
        """Convert user to dictionary for API responses.
        
        Returns:
            dict: User data excluding sensitive information
        """
        return {
            "id": str(self.id),
            "username": self.username,
            "display_name": self.display_name,
            "bio": self.bio,
            "profile_picture_url": self.profile_picture_url,
            "gardening_experience": self.gardening_experience,
            "location": self.location,
            "is_private": self.is_private,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "last_active": self.last_active.isoformat() if self.last_active else None,
        }
    
    def to_public_dict(self) -> dict:
        """Convert user to public dictionary (limited information).
        
        Returns:
            dict: Public user data for display to other users
        """
        return {
            "id": str(self.id),
            "username": self.username,
            "display_name": self.display_name,
            "profile_picture_url": self.profile_picture_url,
            "gardening_experience": self.gardening_experience,
            "location": self.location if not self.is_private else None,
        }