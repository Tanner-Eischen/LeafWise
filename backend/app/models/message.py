"""Message model for real-time messaging system.

This module defines the Message model for handling ephemeral
and persistent messages between users.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class Message(Base):
    """Message model for user-to-user communication.
    
    Supports both text messages and media messages with
    disappearing functionality similar to Snapchat.
    """
    
    __tablename__ = "messages"
    
    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # User relationships
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    recipient_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Message content
    content_type = Column(String(20), nullable=False)  # text, image, video, audio
    text_content = Column(Text, nullable=True)  # For text messages
    media_url = Column(String(500), nullable=True)  # For media messages
    media_thumbnail_url = Column(String(500), nullable=True)  # Thumbnail for videos
    
    # Message metadata
    caption = Column(Text, nullable=True)  # Caption for media messages
    duration = Column(Integer, nullable=True)  # Duration for video/audio in seconds
    file_size = Column(Integer, nullable=True)  # File size in bytes
    
    # Disappearing message settings
    disappear_after = Column(Integer, nullable=True)  # Seconds after viewing
    is_disappearing = Column(Boolean, default=False)
    
    # Message status
    is_delivered = Column(Boolean, default=False)
    is_viewed = Column(Boolean, default=False)
    is_deleted = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    delivered_at = Column(DateTime, nullable=True)
    viewed_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=True)  # When message should be deleted
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships
    sender = relationship("User", foreign_keys=[sender_id], backref="sent_messages")
    recipient = relationship("User", foreign_keys=[recipient_id], backref="received_messages")
    
    def __repr__(self) -> str:
        """String representation of the message."""
        return f"<Message(id={self.id}, sender={self.sender_id}, type={self.content_type})>"
    
    @property
    def is_expired(self) -> bool:
        """Check if the message has expired.
        
        Returns:
            bool: True if message has expired, False otherwise
        """
        if not self.expires_at:
            return False
        return datetime.utcnow() > self.expires_at
    
    @property
    def is_media(self) -> bool:
        """Check if the message contains media.
        
        Returns:
            bool: True if message is media type, False otherwise
        """
        return self.content_type in ["image", "video", "audio"]
    
    def mark_as_delivered(self) -> None:
        """Mark the message as delivered."""
        if not self.is_delivered:
            self.is_delivered = True
            self.delivered_at = datetime.utcnow()
    
    def mark_as_viewed(self) -> None:
        """Mark the message as viewed and set expiration if disappearing."""
        if not self.is_viewed:
            self.is_viewed = True
            self.viewed_at = datetime.utcnow()
            
            # Set expiration time for disappearing messages
            if self.is_disappearing and self.disappear_after:
                from datetime import timedelta
                self.expires_at = datetime.utcnow() + timedelta(seconds=self.disappear_after)
    
    def soft_delete(self) -> None:
        """Soft delete the message."""
        self.is_deleted = True
        self.deleted_at = datetime.utcnow()
    
    def to_dict(self, include_content: bool = True) -> dict:
        """Convert message to dictionary for API responses.
        
        Args:
            include_content: Whether to include message content
            
        Returns:
            dict: Message data
        """
        data = {
            "id": str(self.id),
            "sender_id": str(self.sender_id),
            "recipient_id": str(self.recipient_id),
            "content_type": self.content_type,
            "is_disappearing": self.is_disappearing,
            "disappear_after": self.disappear_after,
            "is_delivered": self.is_delivered,
            "is_viewed": self.is_viewed,
            "is_deleted": self.is_deleted,
            "created_at": self.created_at.isoformat(),
            "delivered_at": self.delivered_at.isoformat() if self.delivered_at else None,
            "viewed_at": self.viewed_at.isoformat() if self.viewed_at else None,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
        }
        
        # Include content only if not expired and requested
        if include_content and not self.is_expired and not self.is_deleted:
            data.update({
                "text_content": self.text_content,
                "media_url": self.media_url,
                "media_thumbnail_url": self.media_thumbnail_url,
                "caption": self.caption,
                "duration": self.duration,
                "file_size": self.file_size,
            })
        
        return data
    
    def to_notification_dict(self) -> dict:
        """Convert message to dictionary for push notifications.
        
        Returns:
            dict: Notification data
        """
        return {
            "id": str(self.id),
            "sender_id": str(self.sender_id),
            "content_type": self.content_type,
            "preview": self._get_preview_text(),
            "created_at": self.created_at.isoformat(),
        }
    
    def _get_preview_text(self) -> str:
        """Get preview text for notifications.
        
        Returns:
            str: Preview text based on message type
        """
        if self.content_type == "text":
            return self.text_content[:50] + "..." if len(self.text_content or "") > 50 else self.text_content or ""
        elif self.content_type == "image":
            return "📷 Photo"
        elif self.content_type == "video":
            return "🎥 Video"
        elif self.content_type == "audio":
            return "🎵 Audio"
        else:
            return "Message"