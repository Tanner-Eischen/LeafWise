"""Plant identification Pydantic schemas.

This module defines the Pydantic schemas for plant identification data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.schemas.plant_species import PlantSpeciesResponse


class PlantIdentificationBase(BaseModel):
    """Base plant identification schema with common fields."""
    
    image_path: str = Field(..., min_length=1, max_length=500)
    confidence_score: Optional[float] = Field(None, ge=0.0, le=1.0)
    identified_name: Optional[str] = Field(None, max_length=255)
    is_verified: bool = False
    verification_notes: Optional[str] = None


class PlantIdentificationCreate(BaseModel):
    """Schema for creating a new plant identification request."""
    
    image_path: str = Field(..., min_length=1, max_length=500)


class PlantIdentificationUpdate(BaseModel):
    """Schema for updating a plant identification."""
    
    species_id: Optional[UUID] = None
    confidence_score: Optional[float] = Field(None, ge=0.0, le=1.0)
    identified_name: Optional[str] = Field(None, max_length=255)
    is_verified: Optional[bool] = None
    verification_notes: Optional[str] = None


class PlantIdentificationResponse(PlantIdentificationBase):
    """Schema for plant identification API responses."""
    
    id: UUID
    user_id: UUID
    species_id: Optional[UUID] = None
    species: Optional[PlantSpeciesResponse] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class PlantIdentificationListResponse(BaseModel):
    """Schema for paginated plant identification list responses."""
    
    items: List[PlantIdentificationResponse]
    total: int
    page: int
    size: int
    pages: int


class PlantIdentificationResultResponse(BaseModel):
    """Schema for AI identification result responses."""
    
    identified_name: str
    confidence_score: float
    species_suggestions: List[PlantSpeciesResponse]
    care_recommendations: Optional[str] = None