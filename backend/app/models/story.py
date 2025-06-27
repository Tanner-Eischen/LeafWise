"""Story model for ephemeral content sharing.

This module defines the Story model for 24-hour disappearing
content similar to Snapchat stories.
"""

import uuid
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class Story(Base):
    """Story model for 24-hour ephemeral content.
    
    Stories are visible to friends for 24 hours and then
    automatically expire and are deleted.
    """
    
    __tablename__ = "stories"
    
    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # User relationship
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Content
    content_type = Column(String(20), nullable=False)  # image, video
    media_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500), nullable=True)
    caption = Column(Text, nullable=True)
    
    # Media metadata
    duration = Column(Integer, nullable=True)  # For videos, in seconds
    file_size = Column(Integer, nullable=True)  # File size in bytes
    
    # Privacy settings
    privacy_level = Column(String(20), default="friends")  # friends, public, custom
    
    # Story status
    is_active = Column(Boolean, default=True)
    is_archived = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    archived_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", backref="stories")
    views = relationship("StoryView", back_populates="story", cascade="all, delete-orphan")
    
    def __init__(self, **kwargs):
        """Initialize story with automatic expiration time."""
        super().__init__(**kwargs)
        if not self.expires_at:
            self.expires_at = datetime.utcnow() + timedelta(hours=24)
    
    def __repr__(self) -> str:
        """String representation of the story."""
        return f"<Story(id={self.id}, user={self.user_id}, type={self.content_type})>"
    
    @property
    def is_expired(self) -> bool:
        """Check if the story has expired.
        
        Returns:
            bool: True if story has expired, False otherwise
        """
        return datetime.utcnow() > self.expires_at
    
    @property
    def view_count(self) -> int:
        """Get the number of views for this story.
        
        Returns:
            int: Number of unique views
        """
        return len(self.views)
    
    @property
    def time_remaining(self) -> Optional[timedelta]:
        """Get time remaining before story expires.
        
        Returns:
            timedelta: Time remaining, or None if expired
        """
        if self.is_expired:
            return None
        return self.expires_at - datetime.utcnow()
    
    def archive(self) -> None:
        """Archive the story."""
        self.is_archived = True
        self.archived_at = datetime.utcnow()
    
    def deactivate(self) -> None:
        """Deactivate the story (soft delete)."""
        self.is_active = False
    
    def to_dict(self, viewer_id: Optional[str] = None) -> dict:
        """Convert story to dictionary for API responses.
        
        Args:
            viewer_id: ID of the user viewing the story
            
        Returns:
            dict: Story data
        """
        data = {
            "id": str(self.id),
            "user_id": str(self.user_id),
            "content_type": self.content_type,
            "media_url": self.media_url,
            "thumbnail_url": self.thumbnail_url,
            "caption": self.caption,
            "duration": self.duration,
            "privacy_level": self.privacy_level,
            "view_count": self.view_count,
            "created_at": self.created_at.isoformat(),
            "expires_at": self.expires_at.isoformat(),
            "time_remaining_seconds": int(self.time_remaining.total_seconds()) if self.time_remaining else 0,
            "is_expired": self.is_expired,
        }
        
        # Add viewer-specific information
        if viewer_id:
            data["has_viewed"] = any(view.viewer_id == uuid.UUID(viewer_id) for view in self.views)
        
        return data


class StoryView(Base):
    """Story view tracking model.
    
    Tracks when users view stories for analytics
    and to show view status to story creators.
    """
    
    __tablename__ = "story_views"
    
    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Relationships
    story_id = Column(UUID(as_uuid=True), ForeignKey("stories.id"), nullable=False)
    viewer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Timestamps
    viewed_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    story = relationship("Story", back_populates="views")
    viewer = relationship("User", backref="story_views")
    
    def __repr__(self) -> str:
        """String representation of the story view."""
        return f"<StoryView(story={self.story_id}, viewer={self.viewer_id})>"
    
    def to_dict(self) -> dict:
        """Convert story view to dictionary.
        
        Returns:
            dict: Story view data
        """
        return {
            "id": str(self.id),
            "story_id": str(self.story_id),
            "viewer_id": str(self.viewer_id),
            "viewed_at": self.viewed_at.isoformat(),
        }