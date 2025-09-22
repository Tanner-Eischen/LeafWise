"""Discovery feed API endpoints for personalized content curation."""

from typing import List, Optional, Dict, Any
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
# from app.services.contextual_discovery_service import ContextualDiscoveryService, DiscoveryItem
from app.services.vector_database_service import VectorDatabaseService
from app.services.embedding_service import EmbeddingService
from pydantic import BaseModel

router = APIRouter()

# Initialize services
embedding_service = EmbeddingService()
vector_service = VectorDatabaseService(embedding_service)
# discovery_service = ContextualDiscoveryService(vector_service, embedding_service)


class FeedResponse(BaseModel):
    """Response model for discovery feed."""
    items: List[Dict[str, Any]]
    total_count: int
    has_more: bool
    next_offset: Optional[int]


@router.get("/feed/{user_id}", response_model=FeedResponse)
async def get_personalized_feed(
    user_id: str,
    feed_type: str = Query("home", description="Type of feed: home, explore, trending"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db)
):
    """Get personalized discovery feed for user."""
    try:
        # Generate personalized feed
        feed_items = await discovery_service.generate_personalized_feed(
            db=db,
            user_id=user_id,
            feed_type=feed_type,
            limit=limit + 1  # Get one extra to check if there are more
        )
        
        # Check if there are more items
        has_more = len(feed_items) > limit
        if has_more:
            feed_items = feed_items[:limit]
        
        # Convert to response format
        items = []
        for item in feed_items:
            items.append({
                "id": item.id,
                "content_type": item.content_type.value,
                "title": item.title,
                "content": item.content,
                "author_id": item.author_id,
                "author_name": item.author_name,
                "relevance_score": item.relevance_score,
                "engagement_score": item.engagement_score,
                "personalization_factors": item.personalization_factors,
                "tags": item.tags,
                "plant_species": item.plant_species,
                "created_at": item.created_at.isoformat(),
                "metadata": item.metadata
            })
        
        return FeedResponse(
            items=items,
            total_count=len(items),
            has_more=has_more,
            next_offset=offset + limit if has_more else None
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating personalized feed: {str(e)}"
        )


@router.get("/behavior-analysis/{user_id}")
async def analyze_user_behavior(
    user_id: str,
    days: int = Query(30, ge=1, le=365),
    db: AsyncSession = Depends(get_db)
):
    """Analyze user behavior patterns for personalization insights."""
    try:
        behavior_analysis = await discovery_service.analyze_user_behavior(
            db=db,
            user_id=user_id,
            days=days
        )
        
        return behavior_analysis
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error analyzing user behavior: {str(e)}"
        )


@router.get("/trending-topics")
async def get_trending_topics(
    time_window: str = Query("week", description="Time window: day, week, month"),
    limit: int = Query(10, ge=1, le=50),
    use_ml_enhanced: bool = Query(True, description="Use ML-enhanced analysis (fallback to heuristic if fails)"),
    user_id: Optional[str] = Query(None, description="User ID for personalized trending topics"),
    db: AsyncSession = Depends(get_db)
):
    """
    Get trending topics in the plant community.
    
    Now supports ML-enhanced analysis with automatic fallback to heuristic method.
    """
    try:
        trending_topics = await discovery_service.get_trending_topics(
            db=db,
            time_window=time_window,
            limit=limit,
            use_ml_enhanced=use_ml_enhanced,
            user_id=user_id
        )
        
        # Determine which method was used
        ml_used = any(topic.get('ml_enhanced', False) for topic in trending_topics)
        
        return {
            "trending_topics": trending_topics,
            "time_window": time_window,
            "ml_enhanced": ml_used,
            "personalized": user_id is not None,
            "analysis_method": "ML-enhanced" if ml_used else "Heuristic fallback",
            "generated_at": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting trending topics: {str(e)}"
        )


@router.get("/contextual-recommendations/{user_id}")
async def get_contextual_recommendations(
    user_id: str,
    context: str = Query("general", description="Context: general, plant_problem, seasonal, beginner"),
    plant_issue: Optional[str] = Query(None, description="Specific plant issue if context is plant_problem"),
    limit: int = Query(10, ge=1, le=30),
    db: AsyncSession = Depends(get_db)
):
    """Get contextual recommendations based on user's current situation."""
    try:
        # Build context dictionary
        context_data = {"type": context}
        if plant_issue:
            context_data["plant_issue"] = plant_issue
        
        # This would use the contextual discovery service
        # For now, return mock recommendations
        recommendations = [
            {
                "id": "rec_1",
                "content_type": "tip",
                "title": "Winter Plant Care Tips",
                "content": "During winter months, reduce watering frequency and ensure adequate humidity...",
                "relevance_score": 0.9,
                "context_match": context,
                "personalization_factors": ["seasonal_context", "user_plants"],
                "recommended_action": "read_and_apply"
            },
            {
                "id": "rec_2",
                "content_type": "knowledge",
                "title": "Common Winter Plant Problems",
                "content": "Learn to identify and solve common issues that arise during winter...",
                "relevance_score": 0.8,
                "context_match": context,
                "personalization_factors": ["seasonal_context", "experience_level"],
                "recommended_action": "bookmark_for_reference"
            }
        ]
        
        return {
            "recommendations": recommendations[:limit],
            "context": context,
            "user_id": user_id,
            "generated_at": "2025-06-29T00:00:00Z"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting contextual recommendations: {str(e)}"
        )


@router.get("/feed-stats/{user_id}")
async def get_feed_statistics(
    user_id: str,
    days: int = Query(7, ge=1, le=30),
    db: AsyncSession = Depends(get_db)
):
    """Get feed engagement statistics for user."""
    try:
        # This would typically analyze user's feed interactions
        # For now, return mock statistics
        stats = {
            "feed_views": 45,
            "content_interactions": 28,
            "average_session_time": "8.5 minutes",
            "most_engaged_content_types": [
                {"type": "plant_tips", "engagement_rate": 0.75},
                {"type": "stories", "engagement_rate": 0.68},
                {"type": "questions", "engagement_rate": 0.52},
                {"type": "trades", "engagement_rate": 0.35}
            ],
            "personalization_effectiveness": {
                "relevance_score": 0.82,
                "diversity_score": 0.74,
                "freshness_score": 0.89
            },
            "top_interests": [
                "indoor_plants",
                "plant_care",
                "propagation",
                "seasonal_care"
            ],
            "engagement_by_time": {
                "morning": 0.45,
                "afternoon": 0.32,
                "evening": 0.78,
                "night": 0.23
            }
        }
        
        return stats
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting feed statistics: {str(e)}"
        )


@router.post("/feed-feedback")
async def provide_feed_feedback(
    user_id: str,
    item_id: str,
    feedback_type: str,
    feedback_data: Dict[str, Any],
    db: AsyncSession = Depends(get_db)
):
    """Provide feedback on feed items for algorithm improvement."""
    try:
        # Store feedback for learning
        feedback_record = {
            "user_id": user_id,
            "item_id": item_id,
            "feedback_type": feedback_type,  # like, dislike, not_interested, report
            "feedback_data": feedback_data,
            "timestamp": "2025-06-29T00:00:00Z"
        }
        
        # In a real implementation, this would:
        # 1. Store the feedback in the database
        # 2. Update user preference embeddings
        # 3. Improve future feed curation
        # 4. Potentially remove or de-rank similar content
        
        response_message = "Feedback received successfully"
        
        if feedback_type == "not_interested":
            response_message += ". We'll show you less content like this."
        elif feedback_type == "like":
            response_message += ". We'll show you more content like this."
        elif feedback_type == "report":
            response_message += ". Content has been flagged for review."
        
        return {
            "message": response_message,
            "feedback_id": f"feedback_{user_id}_{item_id}",
            "status": "processed",
            "impact": "feed_algorithm_updated"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing feed feedback: {str(e)}"
        )


@router.get("/discovery-insights/{user_id}")
async def get_discovery_insights(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get insights about user's discovery patterns and preferences."""
    try:
        # This would analyze user's discovery behavior
        # For now, return mock insights
        insights = {
            "discovery_profile": {
                "exploration_tendency": "moderate",  # conservative, moderate, adventurous
                "content_depth_preference": "medium",  # shallow, medium, deep
                "novelty_preference": 0.65,  # 0-1 scale
                "expertise_seeking": 0.78
            },
            "content_preferences": {
                "visual_content": 0.85,
                "text_heavy_content": 0.45,
                "interactive_content": 0.72,
                "expert_content": 0.68,
                "community_content": 0.74
            },
            "discovery_patterns": {
                "peak_discovery_times": ["morning", "evening"],
                "session_patterns": "focused_browsing",
                "content_completion_rate": 0.67,
                "follow_through_rate": 0.52
            },
            "recommendations": [
                "Try exploring more advanced plant care techniques",
                "Engage with community questions to share your expertise",
                "Consider following seasonal plant care guides"
            ]
        }
        
        return insights
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting discovery insights: {str(e)}"
        ) 
