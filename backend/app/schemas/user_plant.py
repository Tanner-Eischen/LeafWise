"""User plant Pydantic schemas.

This module defines the Pydantic schemas for user plant data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.schemas.plant_species import PlantSpeciesResponse


class UserPlantBase(BaseModel):
    """Base user plant schema with common fields."""
    
    species_id: UUID
    nickname: Optional[str] = Field(None, max_length=100)
    location: Optional[str] = Field(None, max_length=100)
    acquired_date: Optional[datetime] = None
    last_watered: Optional[datetime] = None
    last_fertilized: Optional[datetime] = None
    last_repotted: Optional[datetime] = None
    health_status: str = Field(default="healthy", pattern="^(healthy|sick|recovering|dead)$")
    notes: Optional[str] = None
    is_active: bool = True


class UserPlantCreate(UserPlantBase):
    """Schema for creating a new user plant."""
    pass


class UserPlantUpdate(BaseModel):
    """Schema for updating a user plant."""
    
    nickname: Optional[str] = Field(None, max_length=100)
    location: Optional[str] = Field(None, max_length=100)
    acquired_date: Optional[datetime] = None
    last_watered: Optional[datetime] = None
    last_fertilized: Optional[datetime] = None
    last_repotted: Optional[datetime] = None
    health_status: Optional[str] = Field(None, pattern="^(healthy|sick|recovering|dead)$")
    notes: Optional[str] = None
    is_active: Optional[bool] = None


class UserPlantResponse(UserPlantBase):
    """Schema for user plant API responses."""
    
    id: UUID
    user_id: UUID
    species: Optional[PlantSpeciesResponse] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class UserPlantListResponse(BaseModel):
    """Schema for paginated user plant list responses."""
    
    items: List[UserPlantResponse]
    total: int
    page: int
    size: int
    pages: int


class PlantCareReminderResponse(BaseModel):
    """Schema for plant care reminder responses."""
    
    plant_id: UUID
    plant_nickname: Optional[str]
    species_name: str
    care_type: str
    days_overdue: int
    last_care_date: Optional[datetime]
    recommended_frequency_days: Optional[int]