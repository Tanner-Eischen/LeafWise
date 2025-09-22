"""Plant trade Pydantic schemas.

This module defines the Pydantic schemas for plant trade data
validation and serialization in API requests and responses.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.models.plant_trade import TradeStatus, TradeType
from app.schemas.plant_species import PlantSpeciesResponse
from app.schemas.user import UserPublicResponse


class PlantTradeBase(BaseModel):
    """Base plant trade schema with common fields."""
    
    species_id: UUID
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    trade_type: TradeType
    location: Optional[str] = Field(None, max_length=100)
    price: Optional[str] = Field(None, max_length=50)
    image_paths: Optional[str] = None  # JSON array of image paths


class PlantTradeCreate(PlantTradeBase):
    """Schema for creating a new plant trade listing."""
    pass


class PlantTradeUpdate(BaseModel):
    """Schema for updating a plant trade listing."""
    
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    trade_type: Optional[TradeType] = None
    status: Optional[TradeStatus] = None
    location: Optional[str] = Field(None, max_length=100)
    price: Optional[str] = Field(None, max_length=50)
    image_paths: Optional[str] = None
    interested_user_id: Optional[UUID] = None


class PlantTradeResponse(PlantTradeBase):
    """Schema for plant trade API responses."""
    
    id: UUID
    owner_id: UUID
    owner: Optional[UserPublicResponse] = None
    species: Optional[PlantSpeciesResponse] = None
    status: TradeStatus
    interested_user_id: Optional[UUID] = None
    interested_user: Optional[UserPublicResponse] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class PlantTradeListResponse(BaseModel):
    """Schema for paginated plant trade list responses."""
    
    items: List[PlantTradeResponse]
    total: int
    page: int
    size: int
    pages: int


class PlantTradeSearchRequest(BaseModel):
    """Schema for plant trade search requests."""
    
    query: Optional[str] = None
    trade_type: Optional[TradeType] = None
    location: Optional[str] = None
    species_id: Optional[UUID] = None
    max_price: Optional[float] = None
    page: int = Field(default=1, ge=1)
    size: int = Field(default=20, ge=1, le=100)


class PlantTradeInterestRequest(BaseModel):
    """Schema for expressing interest in a plant trade."""
    
    message: Optional[str] = Field(None, max_length=500)