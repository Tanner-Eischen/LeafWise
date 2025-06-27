"""User management endpoints.

This module provides endpoints for user profile management,
user discovery, and user-related operations.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.user import UserRead, UserUpdate, UserSearch
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.user_service import (
    get_user_by_id,
    get_user_by_username,
    search_users,
    update_user_profile,
    get_user_stats
)
from app.models.user import User

router = APIRouter()


@router.get("/search", response_model=List[UserSearch])
async def search_users_endpoint(
    q: str = Query(..., min_length=2, description="Search query (username, display name)"),
    limit: int = Query(20, ge=1, le=50, description="Maximum number of results"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Search for users by username or display name.
    
    Args:
        q: Search query string
        limit: Maximum number of results to return
        offset: Number of results to skip for pagination
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserSearch]: List of matching users
    """
    users = await search_users(db, query=q, limit=limit, offset=offset, exclude_user_id=current_user.id)
    return [UserSearch.from_orm(user) for user in users]


@router.get("/username/{username}", response_model=UserRead)
async def get_user_by_username_endpoint(
    username: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user profile by username.
    
    Args:
        username: Username to look up
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserRead: User profile data
        
    Raises:
        HTTPException: If user not found
    """
    user = await get_user_by_username(db, username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserRead.from_orm(user)


@router.get("/{user_id}", response_model=UserRead)
async def get_user_by_id_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user profile by ID.
    
    Args:
        user_id: User ID to look up
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserRead: User profile data
        
    Raises:
        HTTPException: If user not found
    """
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserRead.from_orm(user)


@router.put("/{user_id}", response_model=UserRead)
async def update_user_profile_endpoint(
    user_id: str,
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Update user profile.
    
    Args:
        user_id: User ID to update
        user_update: User update data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserRead: Updated user profile
        
    Raises:
        HTTPException: If user not found or unauthorized
    """
    # Check if user exists
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Check if current user can update this profile
    if str(current_user.id) != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this profile"
        )
    
    # Update profile
    updated_user = await update_user_profile(db, user, user_update)
    return UserRead.from_orm(updated_user)


@router.get("/{user_id}/stats")
async def get_user_stats_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user statistics (friends count, stories count, etc.).
    
    Args:
        user_id: User ID to get stats for
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: User statistics
        
    Raises:
        HTTPException: If user not found
    """
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    stats = await get_user_stats(db, user_id)
    return stats


@router.get("/discover/suggestions", response_model=List[UserSearch])
async def get_user_suggestions(
    limit: int = Query(10, ge=1, le=20, description="Maximum number of suggestions"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user suggestions for friend recommendations.
    
    Args:
        limit: Maximum number of suggestions to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserSearch]: List of suggested users
        
    Note: This is a basic implementation. In production, this would
    use more sophisticated algorithms based on mutual friends,
    interests, location, etc.
    """
    # For now, return random users excluding current user and existing friends
    # TODO: Implement sophisticated recommendation algorithm
    users = await search_users(
        db, 
        query="", 
        limit=limit, 
        offset=0, 
        exclude_user_id=current_user.id,
        random_order=True
    )
    return [UserSearch.from_orm(user) for user in users]


@router.post("/{user_id}/block")
async def block_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Block a user.
    
    Args:
        user_id: User ID to block
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If user not found or trying to block self
    """
    if str(current_user.id) == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot block yourself"
        )
    
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # TODO: Implement blocking logic in friendship service
    return {"message": f"User {user.username} has been blocked"}


@router.delete("/{user_id}/block")
async def unblock_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Unblock a user.
    
    Args:
        user_id: User ID to unblock
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If user not found
    """
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # TODO: Implement unblocking logic in friendship service
    return {"message": f"User {user.username} has been unblocked"}


@router.get("/blocked/list", response_model=List[UserSearch])
async def get_blocked_users(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get list of blocked users.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserSearch]: List of blocked users
    """
    # TODO: Implement get blocked users logic
    return []