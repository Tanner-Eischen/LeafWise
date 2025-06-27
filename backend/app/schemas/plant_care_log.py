"""Plant care log Pydantic schemas.

This module defines the Pydantic schemas for plant care log data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class PlantCareLogBase(BaseModel):
    """Base plant care log schema with common fields."""
    
    care_type: str = Field(..., min_length=1, max_length=50)
    notes: Optional[str] = None
    performed_at: Optional[datetime] = None


class PlantCareLogCreate(PlantCareLogBase):
    """Schema for creating a new plant care log entry."""
    
    plant_id: UUID


class PlantCareLogUpdate(BaseModel):
    """Schema for updating a plant care log entry."""
    
    care_type: Optional[str] = Field(None, min_length=1, max_length=50)
    notes: Optional[str] = None
    performed_at: Optional[datetime] = None


class PlantCareLogResponse(PlantCareLogBase):
    """Schema for plant care log API responses."""
    
    id: UUID
    plant_id: UUID
    created_at: datetime
    
    class Config:
        from_attributes = True


class PlantCareLogListResponse(BaseModel):
    """Schema for paginated plant care log list responses."""
    
    items: List[PlantCareLogResponse]
    total: int
    page: int
    size: int
    pages: int


class CareTypeStatsResponse(BaseModel):
    """Schema for care type statistics responses."""
    
    care_type: str
    count: int
    last_performed: Optional[datetime]
    average_frequency_days: Optional[float]