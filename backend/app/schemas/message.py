"""Message schemas.

This module defines Pydantic schemas for message-related
data validation and serialization.
"""

from typing import Optional, List
from pydantic import BaseModel, Field, validator
from datetime import datetime
from enum import Enum


class MessageType(str, Enum):
    """Enum for message content types."""
    TEXT = "text"
    IMAGE = "image"
    VIDEO = "video"
    AUDIO = "audio"
    PLANT_ID = "plant_id"  # Plant identification request/response
    PLANT_CARE = "plant_care"  # Plant care tip
    LOCATION = "location"


class MessageStatus(str, Enum):
    """Enum for message status."""
    SENT = "sent"
    DELIVERED = "delivered"
    READ = "read"
    DELETED = "deleted"
    EXPIRED = "expired"


class MessageBase(BaseModel):
    """Base message schema with common fields."""
    content_type: MessageType
    content: Optional[str] = Field(None, max_length=2000)
    media_url: Optional[str] = None
    caption: Optional[str] = Field(None, max_length=500)
    
    # Media metadata
    file_size: Optional[int] = Field(None, ge=0)
    duration: Optional[float] = Field(None, ge=0)  # For audio/video in seconds
    
    # Disappearing message settings
    disappears_at: Optional[int] = Field(None, ge=1, le=604800)  # 1 second to 1 week
    
    # Plant-specific fields
    plant_data: Optional[dict] = None  # For plant identification results
    care_tip_category: Optional[str] = None  # watering, lighting, fertilizing, etc.


class MessageCreate(MessageBase):
    """Schema for creating a new message."""
    recipient_id: str
    
    @validator('content')
    def validate_content(cls, v, values):
        content_type = values.get('content_type')
        if content_type == MessageType.TEXT and not v:
            raise ValueError('Text messages must have content')
        return v
    
    @validator('media_url')
    def validate_media_url(cls, v, values):
        content_type = values.get('content_type')
        if content_type in [MessageType.IMAGE, MessageType.VIDEO, MessageType.AUDIO] and not v:
            raise ValueError(f'{content_type.value} messages must have media_url')
        return v
    
    @validator('plant_data')
    def validate_plant_data(cls, v, values):
        content_type = values.get('content_type')
        if content_type == MessageType.PLANT_ID and not v:
            raise ValueError('Plant identification messages must have plant_data')
        return v


class MessageUpdate(BaseModel):
    """Schema for updating a message (limited fields)."""
    content: Optional[str] = Field(None, max_length=2000)
    caption: Optional[str] = Field(None, max_length=500)
    status: Optional[MessageStatus] = None


class MessageRead(MessageBase):
    """Schema for reading message data."""
    id: str
    sender_id: str
    recipient_id: str
    status: MessageStatus
    created_at: datetime
    updated_at: datetime
    read_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    
    # Sender information (for display)
    sender_username: Optional[str] = None
    sender_display_name: Optional[str] = None
    sender_avatar_url: Optional[str] = None
    
    # Recipient information (for display)
    recipient_username: Optional[str] = None
    recipient_display_name: Optional[str] = None
    recipient_avatar_url: Optional[str] = None
    
    class Config:
        from_attributes = True


class MessageThread(BaseModel):
    """Schema for message thread/conversation."""
    participant_id: str
    participant_username: str
    participant_display_name: str
    participant_avatar_url: Optional[str] = None
    
    # Latest message info
    latest_message: Optional[MessageRead] = None
    latest_message_at: Optional[datetime] = None
    
    # Thread statistics
    total_messages: int = 0
    unread_count: int = 0
    
    # Thread settings
    is_muted: bool = False
    is_archived: bool = False
    
    class Config:
        from_attributes = True


class MessageReaction(BaseModel):
    """Schema for message reactions."""
    message_id: str
    user_id: str
    reaction_type: str = Field(..., pattern=r"^(like|love|laugh|wow|sad|angry|plant)$")
    created_at: datetime
    
    # User info for display
    user_username: Optional[str] = None
    user_display_name: Optional[str] = None
    user_avatar_url: Optional[str] = None
    
    class Config:
        from_attributes = True


class MessageReactionCreate(BaseModel):
    """Schema for creating a message reaction."""
    reaction_type: str = Field(..., pattern=r"^(like|love|laugh|wow|sad|angry|plant)$")
    
    @validator('reaction_type')
    def validate_reaction_type(cls, v):
        valid_reactions = ['like', 'love', 'laugh', 'wow', 'sad', 'angry', 'plant']
        if v not in valid_reactions:
            raise ValueError(f'Invalid reaction type. Must be one of: {valid_reactions}')
        return v


class MessageSearch(BaseModel):
    """Schema for message search parameters."""
    query: str = Field(..., min_length=1, max_length=100)
    content_type: Optional[MessageType] = None
    sender_id: Optional[str] = None
    date_from: Optional[datetime] = None
    date_to: Optional[datetime] = None
    has_media: Optional[bool] = None
    
    @validator('date_to')
    def validate_date_range(cls, v, values):
        if v is not None and 'date_from' in values and values['date_from'] is not None:
            if v < values['date_from']:
                raise ValueError('date_to must be after date_from')
        return v


class MessageDeliveryStatus(BaseModel):
    """Schema for message delivery status."""
    message_id: str
    status: MessageStatus
    delivered_at: Optional[datetime] = None
    read_at: Optional[datetime] = None
    failed_reason: Optional[str] = None
    
    class Config:
        from_attributes = True


class MessageBatch(BaseModel):
    """Schema for batch message operations."""
    message_ids: List[str] = Field(..., min_items=1, max_items=100)
    operation: str = Field(..., pattern=r"^(mark_read|delete|archive)$")
    
    @validator('message_ids')
    def validate_unique_message_ids(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('message_ids must be unique')
        return v


class PlantIdentificationMessage(BaseModel):
    """Schema for plant identification messages."""
    image_url: str
    confidence_score: Optional[float] = Field(None, ge=0.0, le=1.0)
    plant_name: Optional[str] = None
    scientific_name: Optional[str] = None
    plant_family: Optional[str] = None
    care_difficulty: Optional[str] = Field(None, pattern=r"^(easy|moderate|difficult)$")
    care_tips: Optional[List[str]] = None
    common_issues: Optional[List[str]] = None
    
    class Config:
        from_attributes = True


class PlantCareMessage(BaseModel):
    """Schema for plant care tip messages."""
    plant_name: Optional[str] = None
    care_category: str = Field(..., pattern=r"^(watering|lighting|fertilizing|pruning|repotting|pest_control|general)$")
    tip_content: str = Field(..., min_length=10, max_length=1000)
    difficulty_level: Optional[str] = Field(None, pattern=r"^(beginner|intermediate|advanced)$")
    season_specific: Optional[str] = Field(None, pattern=r"^(spring|summer|fall|winter|year_round)$")
    
    @validator('care_category')
    def validate_care_category(cls, v):
        valid_categories = ['watering', 'lighting', 'fertilizing', 'pruning', 'repotting', 'pest_control', 'general']
        if v not in valid_categories:
            raise ValueError(f'Invalid care category. Must be one of: {valid_categories}')
        return v


class MessageAnalytics(BaseModel):
    """Schema for message analytics."""
    user_id: str
    total_messages_sent: int = 0
    total_messages_received: int = 0
    messages_by_type: dict = {}
    average_response_time_minutes: Optional[float] = None
    most_active_conversation: Optional[str] = None
    plant_messages_sent: int = 0
    plant_identifications_requested: int = 0
    care_tips_shared: int = 0
    
    class Config:
        from_attributes = True