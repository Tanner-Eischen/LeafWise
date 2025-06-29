"""User schemas.

This module defines Pydantic schemas for user-related
data validation and serialization.
"""

from typing import Optional, List
from pydantic import BaseModel, Field, validator
from datetime import datetime
from app.schemas.auth import UserPublicRead

class UserBase(BaseModel):
    """Base user schema with common fields."""
    username: str = Field(..., min_length=3, max_length=30)
    display_name: str = Field(..., min_length=1, max_length=50)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None
    
    # Plant-specific fields
    gardening_experience: Optional[str] = Field(None, pattern=r"^(beginner|intermediate|advanced|expert)$")
    favorite_plants: Optional[str] = Field(None, max_length=200)
    location: Optional[str] = Field(None, max_length=100)
    
    # Privacy settings
    is_private: bool = False
    show_location: bool = True
    allow_plant_id_requests: bool = True


class UserRead(UserBase):
    """Schema for reading user data (public view)."""
    id: str
    email: str  # Only shown to the user themselves or friends
    is_verified: bool
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    # Statistics (computed fields)
    friends_count: Optional[int] = None
    stories_count: Optional[int] = None
    
    class Config:
        from_attributes = True


class UserSearch(BaseModel):
    """Schema for user search results (limited public info)."""
    id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    gardening_experience: Optional[str] = None
    is_verified: bool = False
    is_private: bool = False
    
    # Friendship status (computed field)
    friendship_status: Optional[str] = None  # none, pending, accepted, blocked
    is_close_friend: Optional[bool] = None
    
    class Config:
        from_attributes = True


class UserPublicResponse(BaseModel):
    """Schema for public user information in API responses."""
    id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    gardening_experience: Optional[str] = None
    location: Optional[str] = None
    is_verified: bool = False
    
    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    display_name: Optional[str] = Field(None, min_length=1, max_length=50)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None
    
    # Plant-specific fields
    gardening_experience: Optional[str] = Field(None, pattern=r"^(beginner|intermediate|advanced|expert)$")
    favorite_plants: Optional[str] = Field(None, max_length=200)
    location: Optional[str] = Field(None, max_length=100)
    
    # Privacy settings
    is_private: Optional[bool] = None
    show_location: Optional[bool] = None
    allow_plant_id_requests: Optional[bool] = None
    
    @validator('gardening_experience')
    def validate_experience(cls, v):
        if v is not None:
            valid_levels = ['beginner', 'intermediate', 'advanced', 'expert']
            if v not in valid_levels:
                raise ValueError(f'Invalid gardening experience. Must be one of: {valid_levels}')
        return v


class UserProfile(UserRead):
    """Schema for detailed user profile (includes private info for owner)."""
    email: str
    phone_number: Optional[str] = None
    
    # Additional statistics
    total_messages_sent: Optional[int] = None
    total_stories_posted: Optional[int] = None
    account_created_days_ago: Optional[int] = None
    
    # Privacy and security
    two_factor_enabled: bool = False
    email_notifications: bool = True
    push_notifications: bool = True
    
    class Config:
        from_attributes = True


class UserStats(BaseModel):
    """Schema for user statistics."""
    user_id: str
    friends_count: int = 0
    close_friends_count: int = 0
    stories_count: int = 0
    active_stories_count: int = 0
    total_messages_sent: int = 0
    total_messages_received: int = 0
    account_age_days: int = 0
    last_active: Optional[datetime] = None
    
    # Plant-specific stats
    plants_identified: int = 0
    plant_care_tips_shared: int = 0
    plant_photos_shared: int = 0


class UserPreferences(BaseModel):
    """Schema for user preferences and settings."""
    # Notification preferences
    email_notifications: bool = True
    push_notifications: bool = True
    friend_request_notifications: bool = True
    message_notifications: bool = True
    story_notifications: bool = True
    
    # Privacy preferences
    discoverable_by_email: bool = True
    discoverable_by_username: bool = True
    show_online_status: bool = True
    
    # Plant-specific preferences
    auto_plant_identification: bool = True
    share_plant_care_tips: bool = True
    receive_plant_recommendations: bool = True
    
    # Content preferences
    content_language: str = "en"
    timezone: str = "UTC"
    
    class Config:
        from_attributes = True


class UserActivity(BaseModel):
    """Schema for user activity tracking."""
    user_id: str
    activity_type: str  # login, logout, message_sent, story_posted, etc.
    activity_data: Optional[dict] = None
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    timestamp: datetime
    
    class Config:
        from_attributes = True


class UserBlock(BaseModel):
    """Schema for user blocking information."""
    blocked_user_id: str
    blocked_user: UserSearch
    blocked_at: datetime
    reason: Optional[str] = None
    
    class Config:
        from_attributes = True


class UserReport(BaseModel):
    """Schema for reporting users."""
    reported_user_id: str
    reason: str = Field(..., min_length=1, max_length=500)
    category: str = Field(..., pattern=r"^(spam|harassment|inappropriate_content|fake_account|other)$")
    additional_info: Optional[str] = Field(None, max_length=1000)
    
    @validator('category')
    def validate_category(cls, v):
        valid_categories = ['spam', 'harassment', 'inappropriate_content', 'fake_account', 'other']
        if v not in valid_categories:
            raise ValueError(f'Invalid report category. Must be one of: {valid_categories}')
        return v


class UserSearchFilters(BaseModel):
    """Schema for user search filters."""
    query: str = Field(..., min_length=2, max_length=100)
    gardening_experience: Optional[str] = None
    location: Optional[str] = None
    has_avatar: Optional[bool] = None
    is_verified: Optional[bool] = None
    min_friends_count: Optional[int] = Field(None, ge=0)
    max_friends_count: Optional[int] = Field(None, ge=0)
    
    @validator('max_friends_count')
    def validate_friends_count_range(cls, v, values):
        if v is not None and 'min_friends_count' in values and values['min_friends_count'] is not None:
            if v < values['min_friends_count']:
                raise ValueError('max_friends_count must be greater than or equal to min_friends_count')
        return v


class UserBatchOperation(BaseModel):
    """Schema for batch operations on users."""
    user_ids: List[str] = Field(..., min_items=1, max_items=100)
    operation: str = Field(..., pattern=r"^(block|unblock|add_friend|remove_friend)$")
    
    @validator('user_ids')
    def validate_unique_user_ids(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('user_ids must be unique')
        return v


class UserListResponse(BaseModel):
    """Schema for paginated user list responses."""
    users: List[UserPublicRead]
    total: int
    skip: int
    limit: int
    # Assuming 'pages' is also part of the standard ListResponse pattern if needed
    # You might need to calculate this in the service layer if not directly from DB
    pages: Optional[int] = None

    class Config:
        from_attributes = True
