"""Nursery schemas."""

from datetime import datetime, time
from typing import Optional, List, Dict, Any
from uuid import UUID

from pydantic import BaseModel, Field


class LocalNurseryBase(BaseModel):
    """Base schema for local nurseries."""
    name: str = Field(..., max_length=200)
    description: Optional[str] = None
    address: Optional[str] = Field(None, max_length=500)
    city: Optional[str] = Field(None, max_length=100)
    state: Optional[str] = Field(None, max_length=50)
    country: Optional[str] = Field(None, max_length=50)
    postal_code: Optional[str] = Field(None, max_length=20)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[str] = Field(None, max_length=100)
    website: Optional[str] = Field(None, max_length=200)
    business_type: Optional[str] = Field(None, max_length=50)
    specialties: Optional[List[str]] = None
    services: Optional[List[str]] = None
    operating_hours: Optional[Dict[str, Any]] = None


class LocalNurseryCreate(LocalNurseryBase):
    """Schema for creating local nurseries."""
    pass


class LocalNurseryResponse(LocalNurseryBase):
    """Local nursery response schema."""
    id: UUID
    average_rating: float
    total_reviews: int
    is_verified: bool
    verified_at: Optional[datetime]
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NurseryReviewBase(BaseModel):
    """Base schema for nursery reviews."""
    rating: int = Field(..., ge=1, le=5)
    title: Optional[str] = Field(None, max_length=200)
    review_text: Optional[str] = None
    plant_quality_rating: Optional[int] = Field(None, ge=1, le=5)
    service_rating: Optional[int] = Field(None, ge=1, le=5)
    price_rating: Optional[int] = Field(None, ge=1, le=5)
    selection_rating: Optional[int] = Field(None, ge=1, le=5)
    tags: Optional[List[str]] = None
    is_verified_purchase: bool = False
    visit_date: Optional[datetime] = None


class NurseryReviewCreate(NurseryReviewBase):
    """Schema for creating nursery reviews."""
    pass


class NurseryReviewResponse(NurseryReviewBase):
    """Nursery review response schema."""
    id: UUID
    nursery_id: UUID
    user_id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NurseryEventBase(BaseModel):
    """Base schema for nursery events."""
    title: str = Field(..., max_length=200)
    description: Optional[str] = None
    event_type: Optional[str] = Field(None, max_length=50)
    start_date: datetime
    end_date: Optional[datetime] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    max_participants: Optional[int] = None
    current_participants: int = 0
    price: float = 0.0
    skill_level: Optional[str] = Field(None, max_length=20)
    requirements: Optional[str] = None
    materials_provided: Optional[str] = None
    requires_registration: bool = True
    registration_deadline: Optional[datetime] = None
    contact_info: Optional[str] = Field(None, max_length=200)


class NurseryEventResponse(NurseryEventBase):
    """Nursery event response schema."""
    id: UUID
    nursery_id: UUID
    is_recurring: bool
    recurrence_pattern: Optional[Dict[str, Any]]
    is_active: bool
    is_cancelled: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NurserySearchFilters(BaseModel):
    """Schema for nursery search filters."""
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    radius_km: float = 50
    business_type: Optional[str] = None
    specialties: Optional[List[str]] = None


class UserNurseryFavoriteResponse(BaseModel):
    """User nursery favorite response schema."""
    id: UUID
    user_id: UUID
    nursery_id: UUID
    notes: Optional[str] = None
    last_visited: Optional[datetime] = None
    created_at: datetime
    nursery: LocalNurseryResponse

    class Config:
        from_attributes = True 