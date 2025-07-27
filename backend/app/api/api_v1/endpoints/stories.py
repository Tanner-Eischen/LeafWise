"""Story endpoints.

This module provides endpoints for creating, viewing, and managing
ephemeral stories that disappear after 24 hours.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.story import (
    StoryCreate, StoryRead, StoryViewCreate, StoryType,
    TimelapseStoryCreate, SeasonalPredictionStoryCreate,
    GrowthMilestoneStoryCreate, ChallengeUpdateStoryCreate,
    EnhancedStoryRead, StoryNotificationData
)
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.story_service import (
    create_story,
    get_user_stories,
    get_friends_stories,
    get_story_by_id,
    view_story,
    delete_story,
    get_story_views,
    story_service
)
from app.services.file_service import upload_media_file
from app.services.notification_service import seasonal_notification_service
from app.models.user import User

router = APIRouter()


@router.post("/", response_model=StoryRead, status_code=status.HTTP_201_CREATED)
async def create_story_endpoint(
    file: UploadFile = File(...),
    caption: Optional[str] = None,
    privacy_level: str = "friends",
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> StoryRead:
    """Create a new story.
    
    Args:
        file: Media file (image/video)
        caption: Optional story caption
        privacy_level: Story privacy setting
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        StoryRead: Created story data
    """
    try:
        # Upload media file
        media_url = await upload_media_file(file, "stories")
        
        # Create story data
        story_data = StoryCreate(
            media_url=media_url,
            caption=caption,
            privacy_level=privacy_level,
            story_type=StoryType.get_type_from_file(file)
        )
        
        # Create story
        story = await create_story(db, current_user.id, story_data)
        return StoryRead.from_orm(story)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create story: {str(e)}"
        )


@router.get("/feed", response_model=List[StoryRead])
async def get_stories_feed(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[StoryRead]:
    """Get stories feed from friends.
    
    Args:
        limit: Maximum number of stories to return
        offset: Number of stories to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[StoryRead]: List of stories from friends
    """
    try:
        stories = await get_friends_stories(db, current_user.id, limit, offset)
        return [StoryRead.from_orm(story) for story in stories]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get stories feed: {str(e)}"
        )


@router.get("/user/{user_id}", response_model=List[StoryRead])
async def get_user_stories_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[StoryRead]:
    """Get stories from a specific user.
    
    Args:
        user_id: ID of the user whose stories to retrieve
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[StoryRead]: List of user's stories
        
    Note: Only returns stories that the current user is allowed to see
    based on privacy settings and friendship status.
    """
    try:
        stories = await get_user_stories(db, user_id, viewer_id=current_user.id)
        return [StoryRead.from_orm(story) for story in stories]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user stories: {str(e)}"
        )


@router.get("/my-stories", response_model=List[StoryRead])
async def get_my_stories(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get current user's own stories.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[StoryRead]: List of current user's stories
    """
    stories = await get_user_stories(db, current_user.id, viewer_id=current_user.id, include_all=True)
    return [StoryRead.from_orm(story) for story in stories]


@router.get("/{story_id}", response_model=StoryRead)
async def get_story(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get a specific story by ID.
    
    Args:
        story_id: ID of the story to retrieve
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        StoryRead: Story data
        
    Raises:
        HTTPException: If story not found or not authorized to view
    """
    story = await get_story_by_id(db, story_id, viewer_id=current_user.id)
    if not story:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Story not found or not authorized to view"
        )
    
    return StoryRead.from_orm(story)


@router.post("/{story_id}/view", status_code=status.HTTP_204_NO_CONTENT)
async def view_story_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> None:
    """Record a story view.
    
    Args:
        story_id: ID of the story being viewed
        current_user: Current authenticated user
        db: Database session
    """
    try:
        view_data = StoryViewCreate(
            story_id=story_id,
            viewer_id=str(current_user.id)
        )
        await view_story(db, view_data)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to record story view: {str(e)}"
        )


@router.get("/{story_id}/views", response_model=List[str])
async def get_story_views_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[str]:
    """Get list of users who viewed a story.
    
    Args:
        story_id: ID of the story
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[str]: List of viewer user IDs
    """
    try:
        # Check if story exists and belongs to user
        story = await get_story_by_id(db, story_id)
        if not story:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Story not found"
            )
        
        if str(story.user_id) != str(current_user.id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view story statistics"
            )
        
        viewer_ids = await get_story_views(db, story_id)
        return viewer_ids
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get story views: {str(e)}"
        )


@router.delete("/{story_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_story_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> None:
    """Delete a story.
    
    Args:
        story_id: ID of the story to delete
        current_user: Current authenticated user
        db: Database session
    """
    try:
        # Check if story exists and belongs to user
        story = await get_story_by_id(db, story_id)
        if not story:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Story not found"
            )
        
        if str(story.user_id) != str(current_user.id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to delete this story"
            )
        
        await delete_story(db, story_id)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete story: {str(e)}"
        )


@router.get("/archive/my-stories", response_model=List[StoryRead])
async def get_archived_stories(
    limit: int = Query(20, ge=1, le=50),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get current user's archived stories.
    
    Args:
        limit: Maximum number of stories to return
        offset: Number of stories to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[StoryRead]: List of archived stories
        
    Note: This would return stories that have expired but been
    saved to the user's archive.
    """
    # TODO: Implement archived stories functionality
    return []


@router.post("/{story_id}/archive")
async def archive_story(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Archive a story before it expires.
    
    Args:
        story_id: ID of the story to archive
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If story not found or not authorized
    """
    story = await get_story_by_id(db, story_id, viewer_id=current_user.id)
    if not story:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Story not found"
        )
    
    # Only story owner can archive
    if str(story.user_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to archive this story"
        )
    
    # TODO: Implement story archiving logic
    return {"message": "Story archived successfully"}


# Enhanced story endpoints for seasonal AI and time-lapse features

@router.post("/timelapse", response_model=EnhancedStoryRead, status_code=status.HTTP_201_CREATED)
async def create_timelapse_story(
    story_data: TimelapseStoryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> EnhancedStoryRead:
    """Create a time-lapse story from a completed time-lapse session.
    
    Args:
        story_data: Time-lapse story creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        EnhancedStoryRead: Created time-lapse story
    """
    try:
        story = await story_service.create_timelapse_story(
            str(current_user.id),
            story_data.timelapse_data.timelapse_session_id,
            story_data,
            db
        )
        
        if not story:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create time-lapse story"
            )
        
        # Send notification about new time-lapse story
        notification_data = StoryNotificationData(
            notification_type="new_timelapse_story",
            story_id=str(story.id),
            story_type=StoryType.TIMELAPSE_VIDEO,
            user_id=str(current_user.id),
            username=current_user.username,
            display_name=current_user.display_name or current_user.username,
            plant_nickname=story_data.timelapse_data.plant_nickname,
            timelapse_stats={
                "duration_days": story_data.timelapse_data.tracking_duration_days,
                "photo_count": story_data.timelapse_data.photo_count,
                "milestones": len(story_data.timelapse_data.growth_milestones)
            }
        )
        
        return EnhancedStoryRead(
            **story.to_dict(),
            timelapse_data=story_data.timelapse_data
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create time-lapse story: {str(e)}"
        )


@router.post("/seasonal-prediction", response_model=EnhancedStoryRead, status_code=status.HTTP_201_CREATED)
async def create_seasonal_prediction_story(
    story_data: SeasonalPredictionStoryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> EnhancedStoryRead:
    """Create a seasonal prediction story.
    
    Args:
        story_data: Seasonal prediction story creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        EnhancedStoryRead: Created seasonal prediction story
    """
    try:
        story = await story_service.create_seasonal_prediction_story(
            str(current_user.id),
            story_data.prediction_data.plant_id,
            story_data.prediction_data.dict(),
            story_data,
            db
        )
        
        if not story:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create seasonal prediction story"
            )
        
        return EnhancedStoryRead(
            **story.to_dict(),
            prediction_data=story_data.prediction_data
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create seasonal prediction story: {str(e)}"
        )


@router.post("/growth-milestone", response_model=EnhancedStoryRead, status_code=status.HTTP_201_CREATED)
async def create_growth_milestone_story(
    story_data: GrowthMilestoneStoryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> EnhancedStoryRead:
    """Create a growth milestone achievement story.
    
    Args:
        story_data: Growth milestone story creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        EnhancedStoryRead: Created growth milestone story
    """
    try:
        # Create basic story
        story = await story_service.create_story(
            str(current_user.id),
            story_data,
            db
        )
        
        if not story:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create growth milestone story"
            )
        
        # Send milestone achievement notification
        await seasonal_notification_service.send_growth_milestone_notification(
            db,
            current_user.id,
            story_data.milestone_data.plant_id,
            story_data.milestone_data.dict(),
            story_data.milestone_data.timelapse_session_id
        )
        
        return EnhancedStoryRead(
            **story.to_dict(),
            milestone_data=story_data.milestone_data
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create growth milestone story: {str(e)}"
        )


@router.post("/challenge-update", response_model=EnhancedStoryRead, status_code=status.HTTP_201_CREATED)
async def create_challenge_update_story(
    story_data: ChallengeUpdateStoryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> EnhancedStoryRead:
    """Create a community challenge update story.
    
    Args:
        story_data: Challenge update story creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        EnhancedStoryRead: Created challenge update story
    """
    try:
        # Create basic story
        story = await story_service.create_story(
            str(current_user.id),
            story_data,
            db
        )
        
        if not story:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create challenge update story"
            )
        
        return EnhancedStoryRead(
            **story.to_dict(),
            challenge_data=story_data.challenge_data
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create challenge update story: {str(e)}"
        )


@router.get("/feed/timelapse", response_model=List[EnhancedStoryRead])
async def get_timelapse_stories_feed(
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[EnhancedStoryRead]:
    """Get feed of time-lapse stories from friends.
    
    Args:
        limit: Maximum number of stories to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[EnhancedStoryRead]: List of time-lapse stories
    """
    try:
        stories = await story_service.get_timelapse_stories_feed(
            str(current_user.id),
            db,
            limit
        )
        
        enhanced_stories = []
        for story in stories:
            enhanced_story = EnhancedStoryRead(**story.dict())
            if story.metadata:
                enhanced_story.metadata = story.metadata
            enhanced_stories.append(enhanced_story)
        
        return enhanced_stories
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get time-lapse stories feed: {str(e)}"
        )


@router.get("/feed/seasonal", response_model=List[EnhancedStoryRead])
async def get_seasonal_stories_feed(
    limit: int = Query(20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[EnhancedStoryRead]:
    """Get feed of seasonal prediction and milestone stories.
    
    Args:
        limit: Maximum number of stories to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[EnhancedStoryRead]: List of seasonal stories
    """
    try:
        # Get stories of seasonal types
        seasonal_types = [
            StoryType.SEASONAL_PREDICTION,
            StoryType.GROWTH_MILESTONE,
            StoryType.CHALLENGE_UPDATE
        ]
        
        # This would need to be implemented in the story service
        # For now, return empty list
        return []
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get seasonal stories feed: {str(e)}"
        )


@router.get("/analytics/{story_id}")
async def get_story_analytics(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get detailed analytics for a story (owner only).
    
    Args:
        story_id: ID of the story
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Story analytics data
    """
    try:
        analytics = await story_service.get_story_analytics(
            story_id,
            str(current_user.id),
            db
        )
        
        if not analytics:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Story not found or not authorized"
            )
        
        return analytics
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get story analytics: {str(e)}"
        )