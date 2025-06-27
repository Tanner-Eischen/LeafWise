"""Story endpoints.

This module provides endpoints for creating, viewing, and managing
ephemeral stories that disappear after 24 hours.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.story import StoryCreate, StoryRead, StoryViewCreate
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.story_service import (
    create_story,
    get_user_stories,
    get_friends_stories,
    get_story_by_id,
    view_story,
    delete_story,
    get_story_views
)
from app.services.file_service import upload_media_file
from app.models.user import User
from app.schemas.story import StoryType

router = APIRouter()


@router.post("/", response_model=StoryRead, status_code=status.HTTP_201_CREATED)
async def create_story_endpoint(
    file: UploadFile = File(...),
    caption: Optional[str] = None,
    privacy_level: str = "friends",
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a new story.
    
    Args:
        file: Media file for the story (image or video)
        caption: Optional caption for the story
        privacy_level: Privacy level (public, friends, close_friends)
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        StoryRead: Created story
        
    Raises:
        HTTPException: If file upload fails or invalid privacy level
    """
    # Validate privacy level
    valid_privacy_levels = ["public", "friends", "close_friends"]
    if privacy_level not in valid_privacy_levels:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid privacy level. Must be one of: {valid_privacy_levels}"
        )
    
    # Upload media file
    try:
        media_url, file_size, duration = await upload_media_file(file)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to upload media: {str(e)}"
        )
    
    # Determine story type based on file type
    content_type = file.content_type or ""
    if content_type.startswith("image/"):
        story_type = StoryType.IMAGE
    elif content_type.startswith("video/"):
        story_type = StoryType.VIDEO
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported media type. Only images and videos are allowed."
        )
    
    # Create story data
    story_data = StoryCreate(
        content_type=story_type,
        media_url=media_url,
        caption=caption,
        file_size=file_size,
        duration=duration,
        privacy_level=privacy_level
    )
    
    # Create story
    story = await create_story(db, current_user.id, story_data)
    return StoryRead.from_orm(story)


@router.get("/feed", response_model=List[StoryRead])
async def get_stories_feed(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get stories feed from friends.
    
    Args:
        limit: Maximum number of stories to return
        offset: Number of stories to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[StoryRead]: List of stories from friends
    """
    stories = await get_friends_stories(db, current_user.id, limit, offset)
    return [StoryRead.from_orm(story) for story in stories]


@router.get("/user/{user_id}", response_model=List[StoryRead])
async def get_user_stories_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
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
    stories = await get_user_stories(db, user_id, viewer_id=current_user.id)
    return [StoryRead.from_orm(story) for story in stories]


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


@router.post("/{story_id}/view")
async def view_story_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Mark a story as viewed.
    
    Args:
        story_id: ID of the story to mark as viewed
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If story not found or not authorized to view
    """
    story = await get_story_by_id(db, story_id, viewer_id=current_user.id)
    if not story:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Story not found or not authorized to view"
        )
    
    # Don't record views for own stories
    if str(story.user_id) == str(current_user.id):
        return {"message": "Story viewed (own story)"}
    
    await view_story(db, story_id, current_user.id)
    return {"message": "Story viewed successfully"}


@router.get("/{story_id}/views")
async def get_story_views_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get views for a story.
    
    Args:
        story_id: ID of the story to get views for
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Story views data
        
    Raises:
        HTTPException: If story not found or not authorized
    """
    story = await get_story_by_id(db, story_id, viewer_id=current_user.id)
    if not story:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Story not found"
        )
    
    # Only story owner can see views
    if str(story.user_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view story analytics"
        )
    
    views = await get_story_views(db, story_id)
    return {
        "story_id": story_id,
        "total_views": len(views),
        "views": views
    }


@router.delete("/{story_id}")
async def delete_story_endpoint(
    story_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a story.
    
    Args:
        story_id: ID of the story to delete
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
    
    # Only story owner can delete
    if str(story.user_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to delete this story"
        )
    
    await delete_story(db, story_id)
    return {"message": "Story deleted successfully"}


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