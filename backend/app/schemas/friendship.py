"""Friendship schemas.

This module defines Pydantic schemas for friendship-related
data validation and serialization.
"""

from typing import Optional, List
from pydantic import BaseModel, Field, validator
from datetime import datetime
from enum import Enum


class FriendshipStatus(str, Enum):
    """Enum for friendship status."""
    PENDING = "pending"
    ACCEPTED = "accepted"
    DECLINED = "declined"
    BLOCKED = "blocked"


class FriendshipBase(BaseModel):
    """Base friendship schema with common fields."""
    status: FriendshipStatus
    is_close_friend: bool = False
    created_at: datetime
    updated_at: datetime


class FriendRequestCreate(BaseModel):
    """Schema for creating a friend request."""
    user_id: str
    message: Optional[str] = Field(None, max_length=200)  # Optional message with request
    
    @validator('message')
    def validate_message(cls, v):
        if v is not None:
            v = v.strip()
            if len(v) == 0:
                return None
        return v


class FriendshipRead(FriendshipBase):
    """Schema for reading friendship data."""
    id: str
    requester_id: str
    addressee_id: str
    
    # User information for display
    requester_username: Optional[str] = None
    requester_display_name: Optional[str] = None
    requester_avatar_url: Optional[str] = None
    
    addressee_username: Optional[str] = None
    addressee_display_name: Optional[str] = None
    addressee_avatar_url: Optional[str] = None
    
    # Request metadata
    request_message: Optional[str] = None
    
    class Config:
        from_attributes = True


class FriendshipUpdate(BaseModel):
    """Schema for updating friendship data."""
    status: Optional[FriendshipStatus] = None
    is_close_friend: Optional[bool] = None
    
    @validator('status')
    def validate_status_transition(cls, v):
        # Add business logic for valid status transitions if needed
        return v


class FriendProfile(BaseModel):
    """Schema for friend profile information."""
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    
    # Plant-specific info
    gardening_experience: Optional[str] = None
    favorite_plants: Optional[str] = None
    location: Optional[str] = None
    
    # Friendship info
    friendship_id: str
    is_close_friend: bool = False
    friends_since: datetime
    
    # Activity info
    last_active: Optional[datetime] = None
    is_online: bool = False
    
    # Statistics
    mutual_friends_count: int = 0
    stories_count: int = 0
    
    class Config:
        from_attributes = True


class FriendsList(BaseModel):
    """Schema for friends list with pagination."""
    friends: List[FriendProfile]
    total_count: int
    close_friends_count: int
    online_friends_count: int
    
    class Config:
        from_attributes = True


class FriendRequestsList(BaseModel):
    """Schema for friend requests list."""
    pending_requests: List[FriendshipRead]
    sent_requests: List[FriendshipRead]
    total_pending: int
    total_sent: int
    
    class Config:
        from_attributes = True


class MutualFriends(BaseModel):
    """Schema for mutual friends information."""
    user_id: str
    mutual_friends: List[FriendProfile]
    mutual_friends_count: int
    total_friends_count: int  # Total friends of the user
    
    class Config:
        from_attributes = True


class FriendshipStats(BaseModel):
    """Schema for friendship statistics."""
    user_id: str
    total_friends: int = 0
    close_friends: int = 0
    pending_requests_received: int = 0
    pending_requests_sent: int = 0
    blocked_users: int = 0
    
    # Activity stats
    friend_requests_sent_this_week: int = 0
    friend_requests_accepted_this_week: int = 0
    new_friends_this_month: int = 0
    
    # Plant community stats
    plant_enthusiast_friends: int = 0
    friends_by_experience: dict = {}  # beginner, intermediate, advanced, expert
    friends_by_location: dict = {}
    
    class Config:
        from_attributes = True


class FriendSuggestion(BaseModel):
    """Schema for friend suggestions."""
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    
    # Plant-specific info
    gardening_experience: Optional[str] = None
    favorite_plants: Optional[str] = None
    location: Optional[str] = None
    
    # Suggestion reasoning
    suggestion_reason: str  # mutual_friends, location, interests, etc.
    mutual_friends_count: int = 0
    compatibility_score: Optional[float] = Field(None, ge=0.0, le=1.0)
    
    # Additional context
    mutual_friends_preview: Optional[List[str]] = None  # List of mutual friend usernames
    shared_interests: Optional[List[str]] = None
    
    class Config:
        from_attributes = True


class FriendActivity(BaseModel):
    """Schema for friend activity information."""
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    
    # Activity info
    activity_type: str  # posted_story, sent_message, plant_identification, etc.
    activity_description: str
    activity_timestamp: datetime
    
    # Activity data
    story_id: Optional[str] = None
    message_preview: Optional[str] = None
    plant_name: Optional[str] = None
    
    class Config:
        from_attributes = True


class BlockedUser(BaseModel):
    """Schema for blocked user information."""
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    
    # Block info
    blocked_at: datetime
    block_reason: Optional[str] = None
    
    class Config:
        from_attributes = True


class FriendshipSearch(BaseModel):
    """Schema for searching friends."""
    query: str = Field(..., min_length=1, max_length=100)
    status: Optional[FriendshipStatus] = None
    is_close_friend: Optional[bool] = None
    gardening_experience: Optional[str] = None
    location: Optional[str] = None
    is_online: Optional[bool] = None
    
    # Sorting options
    sort_by: str = Field("display_name", pattern=r"^(display_name|username|friends_since|last_active)$")
    sort_order: str = Field("asc", pattern=r"^(asc|desc)$")
    
    @validator('sort_by')
    def validate_sort_by(cls, v):
        valid_options = ['display_name', 'username', 'friends_since', 'last_active']
        if v not in valid_options:
            raise ValueError(f'Invalid sort_by option. Must be one of: {valid_options}')
        return v


class FriendshipBatch(BaseModel):
    """Schema for batch friendship operations."""
    user_ids: List[str] = Field(..., min_items=1, max_items=50)
    operation: str = Field(..., pattern=r"^(add_to_close_friends|remove_from_close_friends|block|unblock|remove_friend)$")
    
    @validator('user_ids')
    def validate_unique_user_ids(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('user_ids must be unique')
        return v
    
    @validator('operation')
    def validate_operation(cls, v):
        valid_operations = [
            'add_to_close_friends', 'remove_from_close_friends', 
            'block', 'unblock', 'remove_friend'
        ]
        if v not in valid_operations:
            raise ValueError(f'Invalid operation. Must be one of: {valid_operations}')
        return v


class FriendshipNotification(BaseModel):
    """Schema for friendship-related notifications."""
    id: str
    user_id: str  # User who will receive the notification
    from_user_id: str  # User who triggered the notification
    notification_type: str  # friend_request, friend_accepted, etc.
    
    # User info for display
    from_username: str
    from_display_name: str
    from_avatar_url: Optional[str] = None
    
    # Notification content
    title: str
    message: str
    
    # Metadata
    is_read: bool = False
    created_at: datetime
    
    # Related data
    friendship_id: Optional[str] = None
    
    class Config:
        from_attributes = True


class FriendshipAnalytics(BaseModel):
    """Schema for friendship analytics."""
    user_id: str
    
    # Growth metrics
    friends_gained_this_week: int = 0
    friends_gained_this_month: int = 0
    friends_lost_this_month: int = 0
    
    # Engagement metrics
    messages_sent_to_friends: int = 0
    stories_shared_with_friends: int = 0
    friend_stories_viewed: int = 0
    
    # Network metrics
    network_size: int = 0
    network_density: Optional[float] = None  # How interconnected friend network is
    most_connected_friend: Optional[str] = None  # Friend with most mutual connections
    
    # Plant community metrics
    plant_friends_percentage: Optional[float] = None
    plant_knowledge_exchanges: int = 0
    
    class Config:
        from_attributes = True