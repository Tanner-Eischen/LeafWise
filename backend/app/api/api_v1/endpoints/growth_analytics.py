"""Growth analytics API endpoints.

This module provides REST API endpoints for growth analytics,
pattern recognition, and community challenge functionality.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
# NOTE: Removed growth_analytics schema imports to avoid Pydantic recursion issues
# from app.schemas.growth_analytics import (
#     GrowthTrendsRequest,
#     ComparativeAnalysisRequest,
#     SeasonalPatternsRequest,
#     AnalyticsReportRequest,
#     GrowthTrendsResponse,
#     ComparativeAnalysisResponse,
#     SeasonalPatternsResponse,
#     AnalyticsReportResponse,
#     AnalysisType,
#     ComparisonType
# )
from app.services.core_growth_analysis_service import get_core_growth_analysis_service
from app.services.growth_pattern_recognition_service import get_growth_pattern_recognition_service
from app.services.growth_achievement_service import get_growth_achievement_service
from app.services.seasonal_growth_analytics_service import get_seasonal_growth_analytics_service
from app.services.community_growth_insights_service import get_community_growth_insights_service
from app.services.growth_data_export_service import get_growth_data_export_service
from app.services.growth_prediction_service import get_growth_prediction_service

router = APIRouter()


@router.get(
    "/growth/{plant_id}",
    response_model=dict,
    summary="Get plant growth analytics",
    description="Get comprehensive growth analytics and trends for a specific plant."
)
async def get_plant_growth_analytics(
    plant_id: UUID,
    time_period_days: int = Query(default=90, ge=30, le=365, description="Number of days to analyze"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get growth analytics for a specific plant."""
    try:
        core_service = get_core_growth_analysis_service()
        
        # Get growth analytics using the core service
        analytics = await core_service.analyze_growth_trends(
            db=db,
            plant_id=str(plant_id),
            time_period_days=time_period_days
        )
        
        if not analytics:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or insufficient data for analysis"
            )
        
        return analytics
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get growth analytics"
        )


@router.get(
    "/seasonal-patterns/{user_id}",
    response_model=List[dict],
    summary="Get user's seasonal patterns",
    description="Get seasonal growth patterns and responses for all of a user's plants."
)
async def get_user_seasonal_patterns(
    user_id: UUID,
    seasons_to_analyze: int = Query(default=4, ge=1, le=8, description="Number of seasons to analyze"),
    plant_id: Optional[UUID] = Query(None, description="Filter by specific plant ID"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[dict]:
    """Get seasonal patterns for user's plants."""
    try:
        # Verify user access (users can only access their own data or public data)
        if user_id != current_user.id:
            # TODO: Add logic to check if user data is public
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to user's seasonal patterns"
            )
        
        seasonal_service = get_seasonal_growth_analytics_service()
        
        # Get seasonal patterns using the seasonal service
        patterns = await seasonal_service.analyze_seasonal_patterns(
            db=db,
            plant_id=str(plant_id) if plant_id else None
        )
        
        return patterns
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get seasonal patterns"
        )


@router.get(
    "/comparative/{user_id}",
    response_model=dict,
    summary="Get comparative growth analysis",
    description="Get comparative growth analysis across user's plants or community data."
)
async def get_comparative_analysis(
    user_id: UUID,
    comparison_type: str = Query(default="user_plants", description="Type of comparison"),
    time_period_days: int = Query(default=90, ge=30, le=365, description="Number of days to analyze"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get comparative growth analysis."""
    try:
        # Verify user access
        if user_id != current_user.id and comparison_type != "community":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to user's comparative analysis"
            )
        
        community_service = get_community_growth_insights_service()
        
        # Get comparative analysis using the community service
        if comparison_type == "community":
            analysis = await community_service.analyze_community_patterns(
                db=db,
                time_period_days=time_period_days
            )
        else:
            # For user plant comparisons, use the community service's compare method
            analysis = await community_service.compare_with_community(
                db=db,
                plant_id=str(user_id),  # This would need to be adjusted based on actual plant selection
                comparison_period_days=time_period_days
            )
        
        return analysis
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get comparative analysis"
        )


@router.get(
    "/reports/{plant_id}",
    response_model=dict,
    summary="Get comprehensive analytics report",
    description="Get a comprehensive analytics report for a plant including all analysis types."
)
async def get_plant_analytics_report(
    plant_id: UUID,
    analysis_type: str = Query(default="comprehensive", description="Type of analysis"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get comprehensive analytics report for a plant."""
    try:
        # Use multiple services to generate comprehensive report
        core_service = get_core_growth_analysis_service()
        pattern_service = get_growth_pattern_recognition_service()
        seasonal_service = get_seasonal_growth_analytics_service()
        prediction_service = get_growth_prediction_service()
        
        # Get data from different services
        growth_trends = await core_service.analyze_growth_trends(db, str(plant_id))
        patterns = await pattern_service.detect_growth_patterns(db, str(plant_id))
        seasonal_analysis = await seasonal_service.analyze_seasonal_patterns(db, str(plant_id))
        predictions = await prediction_service.predict_growth_trends(db, str(plant_id))
        
        # Combine into comprehensive report
        report = {
            "plant_id": str(plant_id),
            "analysis_type": analysis_type,
            "growth_trends": growth_trends,
            "patterns": patterns,
            "seasonal_analysis": seasonal_analysis,
            "predictions": predictions,
            "generated_at": datetime.utcnow().isoformat()
        }
        
        if not report:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or insufficient data for report"
            )
        
        return report
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate analytics report"
        )


@router.get(
    "/community/leaderboard",
    summary="Get community growth leaderboard",
    description="Get community leaderboard showing top performing plants and users."
)
async def get_community_leaderboard(
    time_period_days: int = Query(default=30, ge=7, le=365, description="Time period for leaderboard"),
    category: str = Query(default="growth_rate", description="Leaderboard category"),
    limit: int = Query(default=20, ge=5, le=100, description="Number of entries to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get community growth leaderboard."""
    try:
        community_service = get_community_growth_insights_service()
        
        # Get community leaderboard data
        leaderboard_data = await community_service.analyze_community_patterns(
            db=db,
            time_period_days=time_period_days
        )
        
        # Extract leaderboard from community analysis
        leaderboard = leaderboard_data.get("growth_benchmarks", [])
        
        return {
            "leaderboard": leaderboard,
            "category": category,
            "time_period_days": time_period_days,
            "generated_at": datetime.utcnow().isoformat()
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get community leaderboard"
        )


@router.get(
    "/insights/{plant_id}",
    summary="Get plant growth insights",
    description="Get AI-generated insights and recommendations based on growth analytics."
)
async def get_plant_growth_insights(
    plant_id: UUID,
    insight_types: Optional[List[str]] = Query(None, description="Types of insights to generate"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get AI-generated growth insights for a plant."""
    try:
        # Use multiple services to generate comprehensive insights
        core_service = get_core_growth_analysis_service()
        pattern_service = get_growth_pattern_recognition_service()
        prediction_service = get_growth_prediction_service()
        
        # Generate insights from different services
        growth_analysis = await core_service.analyze_growth_trends(db, str(plant_id))
        patterns = await pattern_service.detect_growth_patterns(db, str(plant_id))
        predictions = await prediction_service.predict_growth_trends(db, str(plant_id))
        
        # Combine insights
        insights = {
            "growth_insights": growth_analysis.get("insights", []),
            "pattern_insights": patterns.get("insights", []),
            "prediction_insights": predictions.get("milestone_predictions", [])
        }
        
        if not insights:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or insufficient data for insights"
            )
        
        return {
            "plant_id": str(plant_id),
            "insights": insights,
            "generated_at": datetime.utcnow().isoformat()
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate growth insights"
        )


# Community Challenge Endpoints

@router.get(
    "/community/challenges",
    summary="Get available community challenges",
    description="Get list of available seasonal and growth challenges."
)
async def get_community_challenges(
    active_only: bool = Query(True, description="Only return active challenges"),
    category: Optional[str] = Query(None, description="Filter by challenge category"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get available community challenges."""
    try:
        achievement_service = get_growth_achievement_service()
        
        # Get community challenges using the achievement service
        challenges = await achievement_service.get_seasonal_challenges_available(
            db=db,
            season="current"  # This could be made dynamic based on current season
        )
        
        # Filter challenges based on parameters
        if not active_only:
            # Include inactive challenges (this would need additional logic)
            pass
        
        if category:
            challenges = [c for c in challenges if c.get("category") == category]
        
        return {
            "challenges": challenges,
            "total_count": len(challenges),
            "active_only": active_only,
            "category": category
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get community challenges"
        )


@router.post(
    "/community/challenges/{challenge_id}/join",
    status_code=status.HTTP_201_CREATED,
    summary="Join community challenge",
    description="Join a community growth or seasonal challenge with specified plants."
)
async def join_community_challenge(
    challenge_id: UUID,
    plant_ids: List[UUID],
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Join a community challenge."""
    try:
        if len(plant_ids) > 10:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Maximum 10 plants allowed per challenge"
            )
        
        achievement_service = get_growth_achievement_service()
        
        # Join challenge using the achievement service
        # This would need to be implemented in the achievement service
        participation = {
            "challenge_id": str(challenge_id),
            "user_id": str(current_user.id),
            "plant_ids": [str(pid) for pid in plant_ids],
            "joined_at": datetime.utcnow().isoformat(),
            "status": "active"
        }
        
        if not participation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Challenge not found or already joined"
            )
        
        return {
            "message": "Successfully joined challenge",
            "challenge_id": str(challenge_id),
            "plant_ids": [str(pid) for pid in plant_ids],
            "joined_at": datetime.utcnow().isoformat()
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to join community challenge"
        )


@router.get(
    "/community/challenges/{challenge_id}/leaderboard",
    summary="Get challenge leaderboard",
    description="Get leaderboard for a specific community challenge."
)
async def get_challenge_leaderboard(
    challenge_id: UUID,
    limit: int = Query(default=50, ge=10, le=200, description="Number of entries to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> dict:
    """Get leaderboard for a community challenge."""
    try:
        achievement_service = get_growth_achievement_service()
        
        # Get challenge leaderboard using the achievement service
        # This would need to be implemented in the achievement service
        leaderboard = [
            {
                "rank": 1,
                "user_id": "example",
                "score": 100,
                "challenge_id": str(challenge_id)
            }
        ]
        
        if not leaderboard:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Challenge not found"
            )
        
        return {
            "challenge_id": str(challenge_id),
            "leaderboard": leaderboard,
            "total_participants": len(leaderboard),
            "generated_at": datetime.utcnow().isoformat()
        }
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get challenge leaderboard"
        )