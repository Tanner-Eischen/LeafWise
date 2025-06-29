"""Local nursery endpoints."""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.local_nursery_service import LocalNurseryService
from app.services.auth_service import AuthService
from app.models.local_nursery import LocalNursery, NurseryReview, NurseryEvent
from app.schemas.nursery import (
    LocalNurseryResponse,
    LocalNurseryCreate,
    NurseryReviewResponse,
    NurseryReviewCreate,
    NurseryEventResponse,
    NurserySearchFilters
)
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("/nurseries", response_model=List[LocalNurseryResponse])
async def search_nurseries(
    latitude: Optional[float] = Query(None, description="User's latitude"),
    longitude: Optional[float] = Query(None, description="User's longitude"),
    radius_km: float = Query(50, ge=1, le=200, description="Search radius in kilometers"),
    business_type: Optional[str] = Query(None, description="Type of business"),
    specialties: Optional[List[str]] = Query(None, description="Plant specialties"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db)
):
    """Search for local nurseries and garden centers."""
    filters = NurserySearchFilters(
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        business_type=business_type,
        specialties=specialties
    )
    
    nurseries = await LocalNurseryService.search_nurseries(
        db, filters, limit, offset
    )
    return nurseries


@router.get("/nurseries/{nursery_id}", response_model=LocalNurseryResponse)
async def get_nursery(
    nursery_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """Get details for a specific nursery."""
    nursery = await LocalNurseryService.get_nursery_by_id(db, nursery_id)
    if not nursery:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nursery not found"
        )
    return nursery


@router.post("/nurseries", response_model=LocalNurseryResponse)
async def create_nursery(
    nursery_data: LocalNurseryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a new nursery listing (admin only)."""
    # Verify admin permission with specific permission for nursery management
    AuthService.check_admin_permission(current_user, "nursery_management")
    
    nursery = await LocalNurseryService.create_nursery(db, nursery_data)
    return nursery


@router.get("/nurseries/{nursery_id}/reviews", response_model=List[NurseryReviewResponse])
async def get_nursery_reviews(
    nursery_id: UUID,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db)
):
    """Get reviews for a nursery."""
    reviews = await LocalNurseryService.get_nursery_reviews(
        db, nursery_id, limit, offset
    )
    return reviews


@router.post("/nurseries/{nursery_id}/reviews", response_model=NurseryReviewResponse)
async def create_nursery_review(
    nursery_id: UUID,
    review_data: NurseryReviewCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a review for a nursery."""
    # Check if nursery exists
    nursery = await LocalNurseryService.get_nursery_by_id(db, nursery_id)
    if not nursery:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nursery not found"
        )
    
    review = await LocalNurseryService.create_review(
        db, nursery_id, current_user.id, review_data
    )
    return review


@router.get("/nurseries/{nursery_id}/events", response_model=List[NurseryEventResponse])
async def get_nursery_events(
    nursery_id: UUID,
    upcoming_only: bool = Query(True, description="Show only upcoming events"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db)
):
    """Get events for a nursery."""
    events = await LocalNurseryService.get_nursery_events(
        db, nursery_id, upcoming_only, limit, offset
    )
    return events


@router.post("/nurseries/{nursery_id}/favorite")
async def toggle_favorite_nursery(
    nursery_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Add or remove nursery from user's favorites."""
    is_favorite = await LocalNurseryService.toggle_favorite(
        db, current_user.id, nursery_id
    )
    return {"is_favorite": is_favorite}


@router.get("/favorites", response_model=List[LocalNurseryResponse])
async def get_favorite_nurseries(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's favorite nurseries."""
    favorites = await LocalNurseryService.get_user_favorites(db, current_user.id)
    return favorites


@router.get("/events/nearby", response_model=List[NurseryEventResponse])
async def get_nearby_events(
    latitude: Optional[float] = Query(None, description="User's latitude"),
    longitude: Optional[float] = Query(None, description="User's longitude"),
    radius_km: float = Query(50, ge=1, le=200),
    event_type: Optional[str] = Query(None, description="Type of event"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db)
):
    """Get nearby nursery events."""
    events = await LocalNurseryService.get_nearby_events(
        db, latitude, longitude, radius_km, event_type, limit, offset
    )
    return events 