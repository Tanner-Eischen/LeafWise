"""Plant question Pydantic schemas.

This module defines the Pydantic schemas for plant question and answer data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.schemas.plant_species import PlantSpeciesResponse
from app.schemas.user import UserPublicResponse


class PlantQuestionBase(BaseModel):
    """Base plant question schema with common fields."""
    
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1)
    species_id: Optional[UUID] = None
    image_paths: Optional[str] = None  # JSON array of image paths
    tags: Optional[str] = None  # JSON array of tags


class PlantQuestionCreate(PlantQuestionBase):
    """Schema for creating a new plant question."""
    pass


class PlantQuestionUpdate(BaseModel):
    """Schema for updating a plant question."""
    
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1)
    species_id: Optional[UUID] = None
    image_paths: Optional[str] = None
    tags: Optional[str] = None
    is_solved: Optional[bool] = None


class PlantAnswerBase(BaseModel):
    """Base plant answer schema with common fields."""
    
    content: str = Field(..., min_length=1)


class PlantAnswerCreate(PlantAnswerBase):
    """Schema for creating a new plant answer."""
    
    question_id: UUID


class PlantAnswerUpdate(BaseModel):
    """Schema for updating a plant answer."""
    
    content: Optional[str] = Field(None, min_length=1)
    is_accepted: Optional[bool] = None


class PlantAnswerResponse(PlantAnswerBase):
    """Schema for plant answer API responses."""
    
    id: UUID
    question_id: UUID
    user_id: UUID
    user: Optional[UserPublicResponse] = None
    is_accepted: bool
    upvotes: int
    downvotes: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class PlantQuestionResponse(PlantQuestionBase):
    """Schema for plant question API responses."""
    
    id: UUID
    user_id: UUID
    user: Optional[UserPublicResponse] = None
    species: Optional[PlantSpeciesResponse] = None
    is_solved: bool
    view_count: int
    answers: List[PlantAnswerResponse] = []
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class PlantQuestionListResponse(BaseModel):
    """Schema for paginated plant question list responses."""
    
    items: List[PlantQuestionResponse]
    total: int
    page: int
    size: int
    pages: int


class PlantQuestionSearchRequest(BaseModel):
    """Schema for plant question search requests."""
    
    query: Optional[str] = None
    species_id: Optional[UUID] = None
    tags: Optional[List[str]] = None
    is_solved: Optional[bool] = None
    user_id: Optional[UUID] = None
    page: int = Field(default=1, ge=1)
    size: int = Field(default=20, ge=1, le=100)


class PlantAnswerVoteRequest(BaseModel):
    """Schema for voting on plant answers."""
    
    vote_type: str = Field(..., pattern="^(upvote|downvote)$")