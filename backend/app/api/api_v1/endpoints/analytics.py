"""
Analytics API endpoints for advanced plant care and community analytics.
"""

from typing import Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.analytics_service import AnalyticsService
from app.services.ml_plant_health_service import MLPlantHealthService
from app.services.ml_trending_topics_service import MLTrendingTopicsService
from app.services.embedding_service import EmbeddingService
from app.services.auth_service import get_current_user_from_token as get_current_user
from app.models.user import User

router = APIRouter()


def get_analytics_service(
    db: AsyncSession = Depends(get_db)
) -> AnalyticsService:
    """Get analytics service instance with dependencies."""
    ml_health_service = MLPlantHealthService()
    ml_trending_service = MLTrendingTopicsService()
    embedding_service = EmbeddingService()
    
    return AnalyticsService(
        ml_health_service=ml_health_service,
        ml_trending_service=ml_trending_service,
        embedding_service=embedding_service
    )


@router.get("/my-plant-care")
async def get_my_plant_analytics(
    time_period: int = Query(30, ge=7, le=365, description="Analysis time period in days"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    analytics_service: AnalyticsService = Depends(get_analytics_service)
) -> Dict[str, Any]:
    """Get comprehensive plant care analytics for the current user."""
    try:
        analytics = await analytics_service.get_user_plant_analytics(
            db=db,
            user_id=current_user.id,
            time_period=time_period
        )
        return analytics
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retrieve your plant care analytics: {str(e)}"
        )


@router.get("/dashboard/summary")
async def get_analytics_dashboard_summary(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    analytics_service: AnalyticsService = Depends(get_analytics_service)
) -> Dict[str, Any]:
    """Get a summary analytics dashboard for the current user."""
    try:
        plant_analytics = await analytics_service.get_user_plant_analytics(
            db=db,
            user_id=current_user.id,
            time_period=30
        )
        
        community_analytics = await analytics_service.get_community_analytics(
            db=db,
            user_id=current_user.id,
            time_period=30
        )
        
        summary = {
            "user_id": current_user.id,
            "plant_care_summary": {
                "total_plants": plant_analytics.get("total_plants", 0),
                "healthy_plants": plant_analytics.get("healthy_plants_count", 0),
                "care_consistency": plant_analytics.get("care_consistency_score", 0),
                "care_streak": plant_analytics.get("summary_stats", {}).get("care_streak", 0)
            },
            "community_summary": {
                "social_impact_score": community_analytics.get("social_impact_score", 0),
                "ai_interactions": community_analytics.get("ai_interactions", 0),
                "questions_asked": community_analytics.get("questions_asked", 0),
                "successful_trades": community_analytics.get("successful_trades", 0)
            },
            "quick_insights": plant_analytics.get("predictive_insights", [])[:2],
            "recent_achievements": plant_analytics.get("achievements", [])[:3]
        }
        
        return summary
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retrieve analytics dashboard summary: {str(e)}"
        )
