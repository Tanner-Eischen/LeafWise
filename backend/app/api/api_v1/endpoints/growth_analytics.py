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
from app.schemas.growth_analytics import (
    GrowthTrendsRequest,
    ComparativeAnalysisRequest,
    SeasonalPatternsRequest,
    AnalyticsReportRequest,
    GrowthTrendsResponse,
    ComparativeAnalysisResponse,
    SeasonalPatternsResponse,
    AnalyticsReportResponse,
    AnalysisType,
    ComparisonType
)
from app.services.growth_analytics_service import GrowthAnalyticsService

router = APIRouter()


@router.get(
    "/growth/{plant_id}",
    response_model=GrowthTrendsResponse,
    summary="Get plant growth analytics",
    description="Get comprehensive growth analytics and trends for a specific plant."
)
async def get_plant_growth_analytics(
    plant_id: UUID,
    time_period_days: int = Query(default=90, ge=30, le=365, description="Number of days to analyze"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> GrowthTrendsResponse:
    """Get growth analytics for a specific plant."""
    try:
        analytics_service = GrowthAnalyticsService()
        
        # Create request
        request = GrowthTrendsRequest(
            plant_id=plant_id,
            time_period_days=time_period_days
        )
        
        # Get growth analytics
        analytics = await analytics_service.analyze_growth_trends(
            db=db,
            user_id=current_user.id,
            request=request
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
    response_model=List[SeasonalPatternsResponse],
    summary="Get user's seasonal patterns",
    description="Get seasonal growth patterns and responses for all of a user's plants."
)
async def get_user_seasonal_patterns(
    user_id: UUID,
    seasons_to_analyze: int = Query(default=4, ge=1, le=8, description="Number of seasons to analyze"),
    plant_id: Optional[UUID] = Query(None, description="Filter by specific plant ID"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[SeasonalPatternsResponse]:
    """Get seasonal patterns for user's plants."""
    try:
        # Verify user access (users can only access their own data or public data)
        if user_id != current_user.id:
            # TODO: Add logic to check if user data is public
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to user's seasonal patterns"
            )
        
        analytics_service = GrowthAnalyticsService()
        
        # Get seasonal patterns
        patterns = await analytics_service.analyze_user_seasonal_patterns(
            db=db,
            user_id=user_id,
            seasons_to_analyze=seasons_to_analyze,
            plant_id=plant_id
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
    response_model=ComparativeAnalysisResponse,
    summary="Get comparative growth analysis",
    description="Get comparative growth analysis across user's plants or community data."
)
async def get_comparative_analysis(
    user_id: UUID,
    comparison_type: ComparisonType = Query(default=ComparisonType.USER_PLANTS, description="Type of comparison"),
    time_period_days: int = Query(default=90, ge=30, le=365, description="Number of days to analyze"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> ComparativeAnalysisResponse:
    """Get comparative growth analysis."""
    try:
        # Verify user access
        if user_id != current_user.id and comparison_type != ComparisonType.COMMUNITY:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to user's comparative analysis"
            )
        
        analytics_service = GrowthAnalyticsService()
        
        # Create request
        request = ComparativeAnalysisRequest(
            user_id=user_id,
            comparison_type=comparison_type,
            time_period_days=time_period_days
        )
        
        # Get comparative analysis
        analysis = await analytics_service.perform_comparative_analysis(
            db=db,
            request=request
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
    response_model=AnalyticsReportResponse,
    summary="Get comprehensive analytics report",
    description="Get a comprehensive analytics report for a plant including all analysis types."
)
async def get_plant_analytics_report(
    plant_id: UUID,
    analysis_type: AnalysisType = Query(default=AnalysisType.COMPREHENSIVE, description="Type of analysis"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> AnalyticsReportResponse:
    """Get comprehensive analytics report for a plant."""
    try:
        analytics_service = GrowthAnalyticsService()
        
        # Create request
        request = AnalyticsReportRequest(
            plant_id=plant_id,
            analysis_type=analysis_type
        )
        
        # Generate report
        report = await analytics_service.generate_analytics_report(
            db=db,
            user_id=current_user.id,
            request=request
        )
        
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
        analytics_service = GrowthAnalyticsService()
        
        # Get leaderboard data
        leaderboard = await analytics_service.get_community_leaderboard(
            db=db,
            time_period_days=time_period_days,
            category=category,
            limit=limit
        )
        
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
        analytics_service = GrowthAnalyticsService()
        
        # Generate insights
        insights = await analytics_service.generate_growth_insights(
            db=db,
            plant_id=plant_id,
            user_id=current_user.id,
            insight_types=insight_types
        )
        
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
        analytics_service = GrowthAnalyticsService()
        
        # Get challenges
        challenges = await analytics_service.get_community_challenges(
            db=db,
            active_only=active_only,
            category=category
        )
        
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
        
        analytics_service = GrowthAnalyticsService()
        
        # Join challenge
        participation = await analytics_service.join_community_challenge(
            db=db,
            challenge_id=challenge_id,
            user_id=current_user.id,
            plant_ids=plant_ids
        )
        
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
        analytics_service = GrowthAnalyticsService()
        
        # Get challenge leaderboard
        leaderboard = await analytics_service.get_challenge_leaderboard(
            db=db,
            challenge_id=challenge_id,
            limit=limit
        )
        
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