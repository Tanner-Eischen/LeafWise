"""Smart community matching API endpoints."""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.smart_community_service import SmartCommunityService, UserMatch, ExpertRecommendation
from app.services.vector_database_service import VectorDatabaseService
from app.services.embedding_service import EmbeddingService

router = APIRouter()

# Initialize services
embedding_service = EmbeddingService()
vector_service = VectorDatabaseService(embedding_service)
community_service = SmartCommunityService(vector_service, embedding_service)


@router.get("/users/{user_id}/similar", response_model=List[UserMatch])
async def find_similar_users(
    user_id: str,
    limit: int = Query(10, ge=1, le=50),
    include_preferences: bool = Query(True, description="Include preference-based matching"),
    include_behavior: bool = Query(True, description="Include behavioral pattern matching"),
    include_location: bool = Query(True, description="Include location-based matching"),
    db: AsyncSession = Depends(get_db)
):
    """Find users with similar plant interests using AI-powered matching algorithms."""
    try:
        similar_users = await community_service.find_similar_users(
            db=db,
            user_id=user_id,
            limit=limit,
            include_preferences=include_preferences,
            include_behavior=include_behavior,
            include_location=include_location
        )
        return similar_users
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error finding similar users: {str(e)}"
        )


@router.get("/experts/plant-species/{plant_species_id}", response_model=List[ExpertRecommendation])
async def recommend_plant_experts_by_species(
    plant_species_id: str,
    limit: int = Query(5, ge=1, le=20),
    db: AsyncSession = Depends(get_db)
):
    """Recommend expert users for specific plant species using AI-powered expertise analysis."""
    try:
        experts = await community_service.recommend_plant_experts(
            db=db,
            plant_species_id=plant_species_id,
            limit=limit
        )
        return experts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error recommending plant experts: {str(e)}"
        )


@router.post("/experts/by-question", response_model=List[ExpertRecommendation])
async def recommend_experts_by_question(
    question_text: str,
    plant_species_id: Optional[str] = None,
    limit: int = Query(5, ge=1, le=20),
    db: AsyncSession = Depends(get_db)
):
    """Recommend expert users based on question content using semantic analysis."""
    try:
        experts = await community_service.recommend_plant_experts(
            db=db,
            plant_species_id=plant_species_id,
            question_text=question_text,
            limit=limit
        )
        return experts
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error recommending experts by question: {str(e)}"
        )


@router.get("/users/{user_id}/trading-matches")
async def find_trading_matches(
    user_id: str,
    limit: int = Query(10, ge=1, le=30),
    db: AsyncSession = Depends(get_db)
):
    """Find compatible users for plant trading."""
    try:
        trading_matches = await community_service.find_trading_matches(
            db=db,
            user_id=user_id,
            limit=limit
        )
        return trading_matches
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error finding trading matches: {str(e)}"
        )


@router.get("/users/{user_id}/local-community", response_model=List[UserMatch])
async def discover_local_community(
    user_id: str,
    radius_miles: int = Query(25, ge=1, le=100),
    limit: int = Query(15, ge=1, le=50),
    db: AsyncSession = Depends(get_db)
):
    """Discover local plant community members."""
    try:
        local_community = await community_service.discover_local_community(
            db=db,
            user_id=user_id,
            limit=limit
        )
        return local_community
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error discovering local community: {str(e)}"
        )


@router.get("/community-stats/{user_id}")
async def get_community_stats(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get community statistics for a user."""
    try:
        # Get various community metrics
        similar_users = await community_service.find_similar_users(
            db=db,
            user_id=user_id,
            limit=50
        )
        
        local_community = await community_service.discover_local_community(
            db=db,
            user_id=user_id,
            limit=50
        )
        
        trading_matches = await community_service.find_trading_matches(
            db=db,
            user_id=user_id,
            limit=50
        )
        
        stats = {
            "similar_users_count": len(similar_users),
            "local_community_count": len(local_community),
            "trading_matches_count": len(trading_matches),
            "top_shared_interests": [],
            "expertise_areas": []
        }
        
        # Calculate top shared interests
        interest_counts = {}
        for user in similar_users:
            for interest in user.shared_interests:
                interest_counts[interest] = interest_counts.get(interest, 0) + 1
        
        stats["top_shared_interests"] = sorted(
            interest_counts.items(),
            key=lambda x: x[1],
            reverse=True
        )[:5]
        
        return stats
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting community stats: {str(e)}"
        )


@router.get("/users/{user_id}/smart-recommendations")
async def get_smart_recommendations(
    user_id: str,
    recommendation_type: str = Query("general", description="Type of recommendations (general, experts, content, connections)"),
    limit: int = Query(10, ge=1, le=30),
    db: AsyncSession = Depends(get_db)
):
    """Get AI-powered smart recommendations for community connections and content."""
    try:
        # Get personalized recommendations from vector service
        recommendations = await vector_service.get_personalized_recommendations(
            db=db,
            user_id=user_id,
            recommendation_type=recommendation_type,
            limit=limit
        )
        
        return {
            "user_id": user_id,
            "recommendation_type": recommendation_type,
            "recommendations": recommendations,
            "total_count": len(recommendations)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting smart recommendations: {str(e)}"
        )


@router.get("/users/{user_id}/community-insights")
async def get_community_insights(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get comprehensive community insights and analytics for a user."""
    try:
        # Get various community metrics
        similar_users = await community_service.find_similar_users(
            db=db,
            user_id=user_id,
            limit=50
        )
        
        local_community = await community_service.discover_local_community(
            db=db,
            user_id=user_id,
            limit=50
        )
        
        # Calculate insights
        if similar_users:
            avg_similarity = sum(user.similarity_score for user in similar_users) / len(similar_users)
            
            # Analyze top interests
            interest_counts = {}
            for user in similar_users:
                for interest in user.shared_interests:
                    interest_counts[interest] = interest_counts.get(interest, 0) + 1
            
            top_interests = [
                {"interest": interest, "count": count, "percentage": (count / len(similar_users)) * 100}
                for interest, count in sorted(interest_counts.items(), key=lambda x: x[1], reverse=True)[:5]
            ]
            
            # Geographic distribution
            geo_distribution = {}
            for user in local_community:
                # Simplified location analysis
                location = "Unknown"
                if hasattr(user, 'location_match') and user.location_match:
                    location = "Local"
                geo_distribution[location] = geo_distribution.get(location, 0) + 1
            
            # Expertise levels
            expertise_levels = {}
            for user in similar_users:
                if user.expertise_areas:
                    level = "Expert" if len(user.expertise_areas) >= 3 else "Intermediate"
                else:
                    level = "Beginner"
                expertise_levels[level] = expertise_levels.get(level, 0) + 1
        else:
            avg_similarity = 0.0
            top_interests = []
            geo_distribution = {}
            expertise_levels = {}
        
        insights = {
            "user_id": user_id,
            "total_matches": len(similar_users),
            "avg_similarity_score": avg_similarity,
            "top_interests": top_interests,
            "geographic_distribution": geo_distribution,
            "expertise_levels": expertise_levels,
            "local_community_size": len(local_community),
            "recommendations": {
                "connect_with_experts": len([u for u in similar_users if len(u.expertise_areas) >= 2]),
                "local_connections": len(local_community),
                "high_similarity_matches": len([u for u in similar_users if u.similarity_score >= 0.8])
            }
        }
        
        return insights
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting community insights: {str(e)}"
        )


@router.post("/users/{user_id}/update-preferences")
async def update_user_preferences(
    user_id: str,
    preference_type: str,
    preference_data: dict,
    confidence_score: Optional[float] = None,
    db: AsyncSession = Depends(get_db)
):
    """Update user preference embeddings for better matching."""
    try:
        # Update user preferences using embedding service
        preference_embedding = await embedding_service.update_user_preferences(
            db=db,
            user_id=user_id,
            preference_type=preference_type,
            preference_data=preference_data,
            confidence_score=confidence_score
        )
        
        return {
            "user_id": user_id,
            "preference_type": preference_type,
            "updated": True,
            "confidence_score": float(preference_embedding.confidence_score) if preference_embedding.confidence_score else None,
            "message": f"Successfully updated {preference_type} preferences"
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating user preferences: {str(e)}"
        )


@router.get("/users/{user_id}/matching-analytics")
async def get_matching_analytics(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get detailed analytics about user's matching patterns and community connections."""
    try:
        # Get comprehensive user context
        user_context = await community_service._get_comprehensive_user_context(db, user_id)
        if not user_context:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found or no context available"
            )
        
        # Get different types of matches
        preference_matches = await community_service._find_preference_similar_users(db, user_id, 20)
        behavioral_matches = await community_service._find_behavioral_similar_users(db, user_id, 20)
        location_matches = await community_service._find_location_similar_users(db, user_id, user_context, 20)
        
        analytics = {
            "user_id": user_id,
            "user_profile": {
                "experience_level": user_context.get("experience_level"),
                "plant_count": len(user_context.get("plants", [])),
                "activity_score": user_context.get("activity_score", 0),
                "expertise_areas": user_context.get("expertise_areas", []),
                "years_active": user_context.get("years_active", 0)
            },
            "matching_breakdown": {
                "preference_matches": len(preference_matches),
                "behavioral_matches": len(behavioral_matches),
                "location_matches": len(location_matches)
            },
            "match_quality": {
                "avg_preference_score": sum(m["similarity_score"] for m in preference_matches) / len(preference_matches) if preference_matches else 0,
                "avg_behavioral_score": sum(m["similarity_score"] for m in behavioral_matches) / len(behavioral_matches) if behavioral_matches else 0,
                "location_match_available": len(location_matches) > 0
            },
            "recommendations": {
                "improve_profile": user_context.get("activity_score", 0) < 0.5,
                "add_more_plants": len(user_context.get("plants", [])) < 3,
                "engage_more": len(user_context.get("answers", [])) < 5,
                "update_location": not user_context.get("user").location
            }
        }
        
        return analytics
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting matching analytics: {str(e)}"
        ) 