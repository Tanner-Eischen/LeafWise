"""Achievement endpoints."""

from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.plant_achievement_service import PlantAchievementService, PlantMilestoneService
from app.models.plant_achievement import UserAchievement, PlantMilestone, UserStats
from app.schemas.achievement import (
    UserAchievementResponse,
    PlantMilestoneResponse,
    UserStatsResponse,
    PlantMilestoneCreate
)
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("/achievements", response_model=List[UserAchievementResponse])
async def get_user_achievements(
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's earned achievements."""
    achievements = await PlantAchievementService.get_user_achievements(
        db, current_user.id, limit, offset
    )
    return achievements


@router.post("/achievements/check")
async def check_achievements(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Check and award any newly earned achievements."""
    newly_earned = await PlantAchievementService.check_and_award_achievements(
        db, current_user.id
    )
    return {
        "newly_earned_count": len(newly_earned),
        "achievements": newly_earned
    }


@router.get("/stats", response_model=UserStatsResponse)
async def get_user_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's plant care statistics."""
    stats = await PlantAchievementService.get_or_create_user_stats(db, current_user.id)
    return stats


@router.get("/milestones", response_model=List[PlantMilestoneResponse])
async def get_user_milestones(
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's plant milestones."""
    milestones = await PlantMilestoneService.get_user_milestones(
        db, current_user.id, limit, offset
    )
    return milestones


@router.get("/plants/{plant_id}/milestones", response_model=List[PlantMilestoneResponse])
async def get_plant_milestones(
    plant_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get milestones for a specific plant."""
    # TODO: Add authorization check to ensure user owns the plant
    milestones = await PlantMilestoneService.get_plant_milestones(db, plant_id)
    return milestones


@router.post("/plants/{plant_id}/milestones", response_model=PlantMilestoneResponse)
async def create_plant_milestone(
    plant_id: UUID,
    milestone_data: PlantMilestoneCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a new plant milestone."""
    # TODO: Add authorization check to ensure user owns the plant
    milestone = await PlantMilestoneService.create_milestone(
        db=db,
        plant_id=plant_id,
        milestone_type=milestone_data.milestone_type,
        title=milestone_data.title,
        description=milestone_data.description,
        photo_url=milestone_data.photo_url,
        notes=milestone_data.notes
    )
    return milestone


@router.post("/plants/{plant_id}/milestones/check")
async def check_automatic_milestones(
    plant_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Check and create automatic milestones for a plant."""
    # TODO: Add authorization check to ensure user owns the plant
    newly_created = await PlantMilestoneService.check_automatic_milestones(db, plant_id)
    return {
        "newly_created_count": len(newly_created),
        "milestones": newly_created
    } 