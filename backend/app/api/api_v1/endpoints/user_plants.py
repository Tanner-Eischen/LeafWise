"""User plants API endpoints.

This module provides REST API endpoints for managing user's individual plants.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.user_plant import (
    UserPlantCreate,
    UserPlantUpdate,
    UserPlantResponse,
    UserPlantListResponse,
    PlantCareReminderResponse
)
from app.services.user_plant_service import (
    create_plant,
    get_plant_by_id,
    get_user_plants,
    update_plant,
    delete_plant,
    get_care_reminders,
    update_care_activity,
    get_plant_stats
)

router = APIRouter()


@router.post(
    "/",
    response_model=UserPlantResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add new plant",
    description="Add a new plant to user's collection."
)
async def create_user_plant(
    plant_data: UserPlantCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> UserPlantResponse:
    """Create a new user plant."""
    try:
        plant = await create_plant(db, current_user.id, plant_data)
        return UserPlantResponse.from_orm(plant)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create plant"
        )


@router.get(
    "/",
    response_model=UserPlantListResponse,
    summary="Get user's plants",
    description="Get all plants owned by the current user."
)
async def get_my_plants(
    is_active: Optional[bool] = Query(True, description="Filter by active status"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> UserPlantListResponse:
    """Get user's plants."""
    try:
        plants, total = await get_user_plants(db, current_user.id, is_active, skip, limit)
        
        return UserPlantListResponse(
            plants=[UserPlantResponse.from_orm(plant) for plant in plants],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get plants"
        )


@router.get(
    "/stats",
    summary="Get plant statistics",
    description="Get statistics about user's plant collection."
)
async def get_my_plant_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get plant statistics for the current user."""
    try:
        stats = await get_plant_stats(db, current_user.id)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get plant statistics"
        )


@router.get(
    "/care-reminders",
    response_model=List[PlantCareReminderResponse],
    summary="Get care reminders",
    description="Get care reminders for user's plants."
)
async def get_my_care_reminders(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[PlantCareReminderResponse]:
    """Get care reminders for user's plants."""
    try:
        reminders = await get_care_reminders(db, current_user.id)
        return [PlantCareReminderResponse(**reminder) for reminder in reminders]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get care reminders"
        )


@router.get(
    "/{plant_id}",
    response_model=UserPlantResponse,
    summary="Get plant details",
    description="Get details of a specific plant owned by the user."
)
async def get_user_plant(
    plant_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> UserPlantResponse:
    """Get user plant by ID."""
    plant = await get_plant_by_id(db, plant_id, current_user.id)
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found"
        )
    return UserPlantResponse.from_orm(plant)


@router.put(
    "/{plant_id}",
    response_model=UserPlantResponse,
    summary="Update plant",
    description="Update plant information."
)
async def update_user_plant(
    plant_id: UUID,
    plant_data: UserPlantUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> UserPlantResponse:
    """Update user plant."""
    try:
        plant = await update_plant(db, plant_id, current_user.id, plant_data)
        if not plant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found"
            )
        return UserPlantResponse.from_orm(plant)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update plant"
        )


@router.post(
    "/{plant_id}/care",
    summary="Record care activity",
    description="Record a care activity for the plant (watering, fertilizing, etc.)."
)
async def record_care_activity(
    plant_id: UUID,
    care_type: str = Query(..., description="Type of care activity"),
    care_date: Optional[datetime] = Query(None, description="Date of care activity (defaults to now)"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Record care activity for a plant."""
    try:
        success = await update_care_activity(
            db, plant_id, current_user.id, care_type, care_date
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found"
            )
        
        return {
            "message": f"Care activity '{care_type}' recorded successfully",
            "plant_id": plant_id,
            "care_type": care_type,
            "care_date": care_date or datetime.utcnow()
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to record care activity"
        )


@router.delete(
    "/{plant_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Remove plant",
    description="Remove plant from user's collection (soft delete)."
)
async def delete_user_plant(
    plant_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete user plant."""
    try:
        success = await delete_plant(db, plant_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete plant"
        )


# Public endpoint for viewing other users' plants (optional)
@router.get(
    "/user/{user_id}",
    response_model=UserPlantListResponse,
    summary="Get user's public plants",
    description="Get public plants owned by a specific user."
)
async def get_user_public_plants(
    user_id: UUID,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db)
) -> UserPlantListResponse:
    """Get public plants owned by a specific user."""
    try:
        # Only get active plants for public viewing
        plants, total = await get_user_plants(db, user_id, True, skip, limit)
        
        return UserPlantListResponse(
            plants=[UserPlantResponse.from_orm(plant) for plant in plants],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get user plants"
        )