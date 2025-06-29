"""Content generation API endpoints."""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.services.content_generation_service import ContentGenerationService, GeneratedContent
from app.services.rag_service import RAGService
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService
from pydantic import BaseModel

router = APIRouter()

# Initialize services
embedding_service = EmbeddingService()
vector_service = VectorDatabaseService(embedding_service)
rag_service = RAGService()
content_service = ContentGenerationService(rag_service, embedding_service, vector_service)


class ImageContext(BaseModel):
    """Image context for caption generation."""
    plant_type: Optional[str] = None
    setting: Optional[str] = None  # indoor, outdoor, greenhouse
    lighting: Optional[str] = None  # bright, low, natural
    plant_health: Optional[str] = None  # healthy, struggling, thriving
    special_features: Optional[List[str]] = None  # new_growth, flowers, etc.


class CaptionRequest(BaseModel):
    """Request for caption generation."""
    image_context: ImageContext
    plant_id: Optional[str] = None
    tone: Optional[str] = "friendly"  # friendly, professional, casual, educational
    include_hashtags: bool = True


class TipRequest(BaseModel):
    """Request for plant care tip generation."""
    plant_id: Optional[str] = None
    topic: Optional[str] = None  # watering, fertilizing, pruning, etc.
    urgency: Optional[str] = "normal"  # urgent, normal, seasonal


class DescriptionRequest(BaseModel):
    """Request for plant description generation."""
    plant_species_id: str
    context_type: str = "identification"  # identification, care_guide, social_post
    detail_level: str = "medium"  # brief, medium, detailed


@router.post("/caption", response_model=GeneratedContent)
async def generate_plant_caption(
    request: CaptionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate personalized caption for plant photo."""
    try:
        # Convert request to image context dict
        image_context = {
            "plant_type": request.image_context.plant_type,
            "setting": request.image_context.setting,
            "lighting": request.image_context.lighting,
            "plant_health": request.image_context.plant_health,
            "special_features": request.image_context.special_features or [],
            "tone": request.tone,
            "include_hashtags": request.include_hashtags
        }
        
        caption = await content_service.generate_plant_caption(
            db=db,
            user_id=str(current_user.id),
            image_context=image_context,
            plant_id=request.plant_id
        )
        
        return caption
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating caption: {str(e)}"
        )


@router.post("/tip", response_model=GeneratedContent)
async def generate_plant_tip(
    request: TipRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate personalized plant care tip."""
    try:
        tip = await content_service.generate_personalized_plant_tip(
            db=db,
            user_id=str(current_user.id),
            plant_id=request.plant_id,
            topic=request.topic
        )
        
        return tip
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating tip: {str(e)}"
        )


@router.get("/story-suggestions", response_model=List[GeneratedContent])
async def get_story_suggestions(
    limit: int = Query(5, ge=1, le=20),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get personalized story content suggestions."""
    try:
        suggestions = await content_service.generate_story_suggestions(
            db=db,
            user_id=str(current_user.id),
            limit=limit
        )
        
        return suggestions
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating story suggestions: {str(e)}"
        )


@router.post("/plant-description", response_model=GeneratedContent)
async def generate_plant_description(
    request: DescriptionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate context-aware plant description."""
    try:
        description = await content_service.generate_plant_description(
            db=db,
            user_id=str(current_user.id),
            plant_species_id=request.plant_species_id,
            context_type=request.context_type
        )
        
        return description
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating plant description: {str(e)}"
        )


@router.get("/seasonal-content")
async def get_seasonal_content(
    content_types: List[str] = Query(["tip", "story_suggestion"]),
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get seasonal content recommendations for user."""
    try:
        seasonal_content = []
        
        for content_type in content_types:
            if content_type == "tip":
                # Generate seasonal plant tips
                tip = await content_service.generate_personalized_plant_tip(
                    db=db,
                    user_id=str(current_user.id),
                    topic="seasonal"
                )
                seasonal_content.append(tip)
                
            elif content_type == "story_suggestion":
                # Generate seasonal story suggestions
                suggestions = await content_service.generate_story_suggestions(
                    db=db,
                    user_id=str(current_user.id),
                    limit=3
                )
                # Filter for seasonal content
                seasonal_suggestions = [
                    s for s in suggestions 
                    if "seasonal" in s.personalization_factors or "season" in s.tags
                ]
                seasonal_content.extend(seasonal_suggestions[:2])
        
        # Limit total results
        return seasonal_content[:limit]
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating seasonal content: {str(e)}"
        )


@router.get("/content-analytics")
async def get_content_analytics(
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get content generation analytics for user."""
    try:
        # This would typically query RAGInteraction logs
        # For now, return mock analytics
        analytics = {
            "total_generated": 45,
            "content_types": {
                "captions": 20,
                "tips": 15,
                "story_suggestions": 8,
                "descriptions": 2
            },
            "avg_confidence": 0.82,
            "avg_engagement_score": 0.75,
            "top_personalization_factors": [
                "experience_level",
                "plant_collection",
                "seasonal_context",
                "location"
            ],
            "most_used_hashtags": [
                "#PlantParent",
                "#IndoorPlants",
                "#PlantCare",
                "#GreenThumb",
                "#PlantLife"
            ]
        }
        
        return analytics
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting content analytics: {str(e)}"
        )


@router.post("/feedback")
async def provide_content_feedback(
    content_id: str,
    feedback: Dict[str, Any] = Body(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Provide feedback on generated content for improvement."""
    try:
        # Store feedback for learning
        # This would typically update RAGInteraction records
        
        feedback_data = {
            "user_id": str(current_user.id),
            "content_id": content_id,
            "rating": feedback.get("rating", 3),
            "helpful": feedback.get("helpful", True),
            "used": feedback.get("used", False),
            "comments": feedback.get("comments", ""),
            "timestamp": "2025-06-29T00:00:00Z"
        }
        
        # In a real implementation, this would:
        # 1. Store the feedback in the database
        # 2. Update user preference embeddings
        # 3. Improve future content generation
        
        return {
            "message": "Feedback received successfully",
            "feedback_id": f"feedback_{current_user.id}_{content_id}",
            "status": "processed"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing feedback: {str(e)}"
        )


@router.get("/writing-style")
async def analyze_writing_style(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Analyze user's writing style for better content personalization."""
    try:
        # This would typically analyze user's past posts/comments
        # For now, return mock analysis
        writing_style = {
            "tone": "friendly",
            "formality": "casual",
            "emoji_usage": "moderate",
            "hashtag_preference": "selective",
            "content_length": "medium",
            "topics_of_interest": [
                "plant_care",
                "indoor_gardening",
                "plant_health",
                "seasonal_care"
            ],
            "vocabulary_level": "intermediate",
            "engagement_patterns": {
                "best_posting_times": ["morning", "evening"],
                "preferred_content_types": ["tips", "progress_photos"],
                "interaction_style": "supportive"
            }
        }
        
        return writing_style
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error analyzing writing style: {str(e)}"
        ) 