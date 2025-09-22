"""Friendship model for managing user relationships.

This module defines the Friendship model for handling friend requests,
connections, and social relationships between users.
"""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class FriendshipStatus(str, Enum):
    """Enumeration of friendship statuses."""
    PENDING = "pending"
    ACCEPTED = "accepted"
    DECLINED = "declined"
    BLOCKED = "blocked"


class Friendship(Base):
    """Friendship model for managing user relationships.
    
    Handles friend requests, accepted friendships, and blocking.
    Each friendship is directional but creates bidirectional relationships.
    """
    
    __tablename__ = "friendships"
    
    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # User relationships
    requester_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    addressee_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Friendship status
    status = Column(String(20), default=FriendshipStatus.PENDING, nullable=False)
    
    # Metadata
    is_close_friend = Column(Boolean, default=False)  # For story privacy
    is_blocked = Column(Boolean, default=False)
    blocked_by_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    accepted_at = Column(DateTime, nullable=True)
    blocked_at = Column(DateTime, nullable=True)
    
    # Relationships
    requester = relationship("User", foreign_keys=[requester_id], backref="sent_friend_requests")
    addressee = relationship("User", foreign_keys=[addressee_id], backref="received_friend_requests")
    blocked_by = relationship("User", foreign_keys=[blocked_by_id])
    
    # Ensure unique friendship pairs
    __table_args__ = (
        UniqueConstraint('requester_id', 'addressee_id', name='unique_friendship'),
    )
    
    def __repr__(self) -> str:
        """String representation of the friendship."""
        return f"<Friendship(requester={self.requester_id}, addressee={self.addressee_id}, status={self.status})>"
    
    @property
    def is_pending(self) -> bool:
        """Check if friendship request is pending.
        
        Returns:
            bool: True if status is pending, False otherwise
        """
        return self.status == FriendshipStatus.PENDING
    
    @property
    def is_accepted(self) -> bool:
        """Check if friendship is accepted.
        
        Returns:
            bool: True if status is accepted, False otherwise
        """
        return self.status == FriendshipStatus.ACCEPTED
    
    @property
    def is_declined(self) -> bool:
        """Check if friendship request was declined.
        
        Returns:
            bool: True if status is declined, False otherwise
        """
        return self.status == FriendshipStatus.DECLINED
    
    def accept(self) -> None:
        """Accept the friendship request."""
        self.status = FriendshipStatus.ACCEPTED
        self.accepted_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
    
    def decline(self) -> None:
        """Decline the friendship request."""
        self.status = FriendshipStatus.DECLINED
        self.updated_at = datetime.utcnow()
    
    def block(self, blocked_by_user_id: uuid.UUID) -> None:
        """Block the user relationship.
        
        Args:
            blocked_by_user_id: ID of the user who initiated the block
        """
        self.status = FriendshipStatus.BLOCKED
        self.is_blocked = True
        self.blocked_by_id = blocked_by_user_id
        self.blocked_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
    
    def unblock(self) -> None:
        """Unblock the user relationship."""
        self.is_blocked = False
        self.blocked_by_id = None
        self.blocked_at = None
        self.status = FriendshipStatus.DECLINED  # Reset to declined state
        self.updated_at = datetime.utcnow()
    
    def toggle_close_friend(self) -> None:
        """Toggle close friend status."""
        self.is_close_friend = not self.is_close_friend
        self.updated_at = datetime.utcnow()
    
    def get_other_user_id(self, current_user_id: uuid.UUID) -> uuid.UUID:
        """Get the other user's ID in the friendship.
        
        Args:
            current_user_id: ID of the current user
            
        Returns:
            UUID: ID of the other user in the friendship
        """
        if current_user_id == self.requester_id:
            return self.addressee_id
        return self.requester_id
    
    def is_user_involved(self, user_id: uuid.UUID) -> bool:
        """Check if a user is involved in this friendship.
        
        Args:
            user_id: ID of the user to check
            
        Returns:
            bool: True if user is involved, False otherwise
        """
        return user_id in [self.requester_id, self.addressee_id]
    
    def to_dict(self, current_user_id: Optional[uuid.UUID] = None) -> dict:
        """Convert friendship to dictionary for API responses.
        
        Args:
            current_user_id: ID of the current user viewing the friendship
            
        Returns:
            dict: Friendship data
        """
        data = {
            "id": str(self.id),
            "requester_id": str(self.requester_id),
            "addressee_id": str(self.addressee_id),
            "status": self.status,
            "is_close_friend": self.is_close_friend,
            "is_blocked": self.is_blocked,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "accepted_at": self.accepted_at.isoformat() if self.accepted_at else None,
        }
        
        # Add context for current user
        if current_user_id:
            data["other_user_id"] = str(self.get_other_user_id(current_user_id))
            data["is_requester"] = current_user_id == self.requester_id
            data["can_accept"] = (
                current_user_id == self.addressee_id and 
                self.status == FriendshipStatus.PENDING
            )
        
        return data
    
    @classmethod
    def create_friendship_request(
        cls, 
        requester_id: uuid.UUID, 
        addressee_id: uuid.UUID
    ) -> "Friendship":
        """Create a new friendship request.
        
        Args:
            requester_id: ID of the user sending the request
            addressee_id: ID of the user receiving the request
            
        Returns:
            Friendship: New friendship instance
        """
        return cls(
            requester_id=requester_id,
            addressee_id=addressee_id,
            status=FriendshipStatus.PENDING
        )