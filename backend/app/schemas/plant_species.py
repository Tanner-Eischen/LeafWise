"""Plant species Pydantic schemas.

This module defines the Pydantic schemas for plant species data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field


class PlantSpeciesBase(BaseModel):
    """Base plant species schema with common fields."""
    
    scientific_name: str = Field(..., min_length=1, max_length=255)
    common_names: List[str] = Field(default_factory=list)
    family: Optional[str] = Field(None, max_length=100)
    care_level: Optional[str] = Field(None, pattern="^(easy|moderate|difficult)$")
    light_requirements: Optional[str] = Field(None, max_length=50)
    water_frequency_days: Optional[int] = Field(None, ge=1, le=365)
    humidity_preference: Optional[str] = Field(None, max_length=20)
    temperature_range: Optional[str] = Field(None, max_length=50)
    toxicity_info: Optional[str] = None
    care_notes: Optional[str] = None


class PlantSpeciesCreate(PlantSpeciesBase):
    """Schema for creating a new plant species."""
    pass


class PlantSpeciesUpdate(BaseModel):
    """Schema for updating a plant species."""
    
    scientific_name: Optional[str] = Field(None, min_length=1, max_length=255)
    common_names: Optional[List[str]] = None
    family: Optional[str] = Field(None, max_length=100)
    care_level: Optional[str] = Field(None, pattern="^(easy|moderate|difficult)$")
    light_requirements: Optional[str] = Field(None, max_length=50)
    water_frequency_days: Optional[int] = Field(None, ge=1, le=365)
    humidity_preference: Optional[str] = Field(None, max_length=20)
    temperature_range: Optional[str] = Field(None, max_length=50)
    toxicity_info: Optional[str] = None
    care_notes: Optional[str] = None


class PlantSpeciesResponse(PlantSpeciesBase):
    """Schema for plant species API responses."""
    
    id: UUID
    created_at: datetime
    
    class Config:
        from_attributes = True


class PlantSpeciesListResponse(BaseModel):
    """Schema for paginated plant species list responses."""
    
    items: List[PlantSpeciesResponse]
    total: int
    page: int
    size: int
    pages: int