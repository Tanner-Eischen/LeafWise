"""Community Challenge endpoints.

This module provides endpoints for managing seasonal community challenges,
growth competitions, and community achievements.
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.community_challenge_service import (
    community_challenge_service,
    ChallengeType,
    ChallengeStatus,
    ParticipationStatus
)
from app.models.user import User

router = APIRouter()


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_challenge(
    challenge_data: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Create a new seasonal challenge.
    
    Args:
        challenge_data: Challenge creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        Dict: Created challenge data
    """
    try:
        challenge = await community_challenge_service.create_seasonal_challenge(
            db, challenge_data, current_user.id
        )
        return challenge
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create challenge: {str(e)}"
        )


@router.get("/", response_model=List[Dict[str, Any]])
async def get_active_challenges(
    challenge_type: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[Dict[str, Any]]:
    """Get list of active challenges.
    
    Args:
        challenge_type: Optional filter by challenge type
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[Dict]: List of active challenges
    """
    try:
        challenge_type_enum = None
        if challenge_type:
            try:
                challenge_type_enum = ChallengeType(challenge_type)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid challenge type: {challenge_type}"
                )
        
        challenges = await community_challenge_service.get_active_challenges(
            db, current_user.id, challenge_type_enum
        )
        return challenges
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get challenges: {str(e)}"
        )


@router.post("/{challenge_id}/join", status_code=status.HTTP_201_CREATED)
async def join_challenge(
    challenge_id: str,
    plant_id: str,
    entry_data: Optional[Dict[str, Any]] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Join a seasonal challenge with a specific plant.
    
    Args:
        challenge_id: ID of the challenge to join
        plant_id: ID of the plant to use for the challenge
        entry_data: Optional additional entry data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        Dict: Participation record
    """
    try:
        participation = await community_challenge_service.join_challenge(
            db, challenge_id, current_user.id, UUID(plant_id), entry_data
        )
        return participation
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to join challenge: {str(e)}"
        )


@router.put("/{challenge_id}/progress")
async def update_challenge_progress(
    challenge_id: str,
    progress_data: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Update user's progress in a challenge.
    
    Args:
        challenge_id: ID of the challenge
        progress_data: Progress update data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        Dict: Updated participation record
    """
    try:
        participation = await community_challenge_service.update_challenge_progress(
            db, challenge_id, current_user.id, progress_data
        )
        return participation
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update challenge progress: {str(e)}"
        )


@router.get("/{challenge_id}/leaderboard")
async def get_challenge_leaderboard(
    challenge_id: str,
    limit: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[Dict[str, Any]]:
    """Get challenge leaderboard.
    
    Args:
        challenge_id: ID of the challenge
        limit: Maximum number of entries to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[Dict]: Leaderboard entries
    """
    try:
        leaderboard = await community_challenge_service.get_challenge_leaderboard(
            db, challenge_id, limit
        )
        return leaderboard
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get challenge leaderboard: {str(e)}"
        )


@router.get("/my-challenges")
async def get_my_challenges(
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[Dict[str, Any]]:
    """Get user's challenge participation history.
    
    Args:
        limit: Maximum number of challenges to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[Dict]: User's challenge history
    """
    try:
        challenges = await community_challenge_service.get_user_challenge_history(
            db, current_user.id, limit
        )
        return challenges
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user challenges: {str(e)}"
        )


@router.post("/{challenge_id}/complete")
async def complete_challenge(
    challenge_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Complete a challenge and distribute rewards (admin only).
    
    Args:
        challenge_id: ID of the challenge to complete
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        Dict: Challenge completion results
    """
    try:
        # TODO: Add admin permission check
        # For now, allow any user to complete challenges for testing
        
        result = await community_challenge_service.complete_challenge(
            db, challenge_id
        )
        return result
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to complete challenge: {str(e)}"
        )


@router.get("/types")
async def get_challenge_types() -> List[Dict[str, str]]:
    """Get available challenge types.
    
    Returns:
        List[Dict]: Available challenge types with descriptions
    """
    challenge_types = [
        {
            "type": ChallengeType.SEASONAL_GROWTH.value,
            "name": "Seasonal Growth",
            "description": "Track and compare plant growth during specific seasons"
        },
        {
            "type": ChallengeType.WINTER_SURVIVAL.value,
            "name": "Winter Survival",
            "description": "Keep plants healthy through the winter months"
        },
        {
            "type": ChallengeType.SPRING_AWAKENING.value,
            "name": "Spring Awakening",
            "description": "Maximize spring growth and new leaf development"
        },
        {
            "type": ChallengeType.SUMMER_THRIVING.value,
            "name": "Summer Thriving",
            "description": "Help plants thrive in summer heat and conditions"
        },
        {
            "type": ChallengeType.FALL_PREPARATION.value,
            "name": "Fall Preparation",
            "description": "Prepare plants for dormancy and winter"
        },
        {
            "type": ChallengeType.PROPAGATION_CHALLENGE.value,
            "name": "Propagation Challenge",
            "description": "Successfully propagate new plants from cuttings"
        },
        {
            "type": ChallengeType.TIMELAPSE_SHOWCASE.value,
            "name": "Time-lapse Showcase",
            "description": "Create the most impressive growth time-lapse"
        },
        {
            "type": ChallengeType.CARE_CONSISTENCY.value,
            "name": "Care Consistency",
            "description": "Maintain consistent plant care routines"
        },
        {
            "type": ChallengeType.SPECIES_SPECIFIC.value,
            "name": "Species Specific",
            "description": "Challenges focused on specific plant species"
        }
    ]
    return challenge_types


@router.get("/seasonal-recommendations")
async def get_seasonal_challenge_recommendations(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[Dict[str, Any]]:
    """Get personalized seasonal challenge recommendations.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[Dict]: Recommended challenges based on user's plants and season
    """
    try:
        # This would analyze user's plants and current season to recommend challenges
        # For now, return some sample recommendations
        
        from datetime import datetime
        current_month = datetime.now().month
        
        recommendations = []
        
        if current_month in [12, 1, 2]:  # Winter
            recommendations.append({
                "challenge_type": ChallengeType.WINTER_SURVIVAL.value,
                "title": "Winter Survival Challenge",
                "description": "Keep your plants healthy through the cold winter months",
                "difficulty": "medium",
                "estimated_duration_weeks": 12,
                "suitable_plants": ["Most houseplants", "Succulents", "Tropical plants"]
            })
        elif current_month in [3, 4, 5]:  # Spring
            recommendations.append({
                "challenge_type": ChallengeType.SPRING_AWAKENING.value,
                "title": "Spring Growth Boost",
                "description": "Maximize your plants' spring growth potential",
                "difficulty": "easy",
                "estimated_duration_weeks": 8,
                "suitable_plants": ["Fast-growing plants", "Herbs", "Vegetables"]
            })
        elif current_month in [6, 7, 8]:  # Summer
            recommendations.append({
                "challenge_type": ChallengeType.SUMMER_THRIVING.value,
                "title": "Summer Heat Challenge",
                "description": "Help your plants thrive in summer conditions",
                "difficulty": "medium",
                "estimated_duration_weeks": 10,
                "suitable_plants": ["Heat-tolerant plants", "Cacti", "Mediterranean plants"]
            })
        else:  # Fall
            recommendations.append({
                "challenge_type": ChallengeType.FALL_PREPARATION.value,
                "title": "Fall Preparation Challenge",
                "description": "Prepare your plants for the coming winter",
                "difficulty": "easy",
                "estimated_duration_weeks": 6,
                "suitable_plants": ["Deciduous plants", "Perennials", "Outdoor plants"]
            })
        
        # Always recommend time-lapse showcase
        recommendations.append({
            "challenge_type": ChallengeType.TIMELAPSE_SHOWCASE.value,
            "title": "Growth Time-lapse Contest",
            "description": "Create the most impressive plant growth time-lapse",
            "difficulty": "medium",
            "estimated_duration_weeks": 4,
            "suitable_plants": ["Fast-growing plants", "New propagations", "Flowering plants"]
        })
        
        return recommendations
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get challenge recommendations: {str(e)}"
        )


@router.get("/achievements")
async def get_available_achievements(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[Dict[str, Any]]:
    """Get list of available challenge achievements.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[Dict]: Available achievements
    """
    achievements = [
        {
            "id": "first_milestone",
            "title": "First Milestone",
            "description": "Reached your first growth milestone",
            "icon": "🌱",
            "rarity": "common"
        },
        {
            "id": "consistency_champion",
            "title": "Consistency Champion",
            "description": "Maintained perfect care consistency for 7 days",
            "icon": "🏆",
            "rarity": "uncommon"
        },
        {
            "id": "growth_guru",
            "title": "Growth Guru",
            "description": "Achieved exceptional growth rate",
            "icon": "🌿",
            "rarity": "rare"
        },
        {
            "id": "seasonal_master",
            "title": "Seasonal Master",
            "description": "Completed challenges in all four seasons",
            "icon": "🌍",
            "rarity": "epic"
        },
        {
            "id": "timelapse_artist",
            "title": "Time-lapse Artist",
            "description": "Created a time-lapse with over 100 photos",
            "icon": "🎬",
            "rarity": "rare"
        },
        {
            "id": "community_leader",
            "title": "Community Leader",
            "description": "Finished in top 3 of 5 different challenges",
            "icon": "👑",
            "rarity": "legendary"
        }
    ]
    
    return achievements