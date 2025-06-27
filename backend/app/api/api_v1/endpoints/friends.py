"""Friend management endpoints.

This module provides endpoints for managing friendships,
friend requests, and social connections.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.friendship import FriendshipRead, FriendRequestCreate
from app.schemas.user import UserSearch
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.friendship_service import (
    send_friend_request,
    accept_friend_request,
    decline_friend_request,
    remove_friend,
    block_user,
    unblock_user,
    get_friends_list,
    get_pending_requests,
    get_sent_requests,
    get_blocked_users,
    toggle_close_friend,
    get_close_friends,
    check_friendship_status
)
from app.services.user_service import get_user_by_id
from app.models.user import User

router = APIRouter()


@router.post("/request", status_code=status.HTTP_201_CREATED)
async def send_friend_request_endpoint(
    request_data: FriendRequestCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Send a friend request to another user.
    
    Args:
        request_data: Friend request data containing user_id
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If user not found, already friends, or request already sent
    """
    # Check if target user exists
    target_user = await get_user_by_id(db, request_data.user_id)
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Can't send request to self
    if str(current_user.id) == request_data.user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot send friend request to yourself"
        )
    
    # Check current friendship status
    status_result = await check_friendship_status(db, current_user.id, request_data.user_id)
    if status_result == "accepted":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already friends with this user"
        )
    elif status_result == "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Friend request already sent"
        )
    elif status_result == "blocked":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot send friend request to this user"
        )
    
    # Send friend request
    await send_friend_request(db, current_user.id, request_data.user_id)
    return {"message": f"Friend request sent to {target_user.username}"}


@router.post("/accept/{friendship_id}")
async def accept_friend_request_endpoint(
    friendship_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Accept a friend request.
    
    Args:
        friendship_id: ID of the friendship/request to accept
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If request not found or not authorized
    """
    success = await accept_friend_request(db, friendship_id, current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found or not authorized"
        )
    
    return {"message": "Friend request accepted"}


@router.post("/decline/{friendship_id}")
async def decline_friend_request_endpoint(
    friendship_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Decline a friend request.
    
    Args:
        friendship_id: ID of the friendship/request to decline
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If request not found or not authorized
    """
    success = await decline_friend_request(db, friendship_id, current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found or not authorized"
        )
    
    return {"message": "Friend request declined"}


@router.delete("/remove/{user_id}")
async def remove_friend_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Remove a friend (unfriend).
    
    Args:
        user_id: ID of the user to unfriend
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If not friends or user not found
    """
    success = await remove_friend(db, current_user.id, user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friendship not found"
        )
    
    return {"message": "Friend removed successfully"}


@router.get("/list", response_model=List[UserSearch])
async def get_friends_list_endpoint(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get list of current user's friends.
    
    Args:
        limit: Maximum number of friends to return
        offset: Number of friends to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserSearch]: List of friends
    """
    friends = await get_friends_list(db, current_user.id, limit, offset)
    return [UserSearch.from_orm(friend) for friend in friends]


@router.get("/requests/pending", response_model=List[FriendshipRead])
async def get_pending_requests_endpoint(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get pending friend requests received by current user.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[FriendshipRead]: List of pending friend requests
    """
    requests = await get_pending_requests(db, current_user.id)
    return [FriendshipRead.from_orm(request) for request in requests]


@router.get("/requests/sent", response_model=List[FriendshipRead])
async def get_sent_requests_endpoint(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get friend requests sent by current user.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[FriendshipRead]: List of sent friend requests
    """
    requests = await get_sent_requests(db, current_user.id)
    return [FriendshipRead.from_orm(request) for request in requests]


@router.post("/block/{user_id}")
async def block_user_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Block a user.
    
    Args:
        user_id: ID of the user to block
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
    
    # Check if target user exists
    target_user = await get_user_by_id(db, user_id)
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    await block_user(db, current_user.id, user_id)
    return {"message": f"User {target_user.username} has been blocked"}


@router.delete("/block/{user_id}")
async def unblock_user_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Unblock a user.
    
    Args:
        user_id: ID of the user to unblock
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If user not found or not blocked
    """
    success = await unblock_user(db, current_user.id, user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found or not blocked"
        )
    
    return {"message": "User has been unblocked"}


@router.get("/blocked", response_model=List[UserSearch])
async def get_blocked_users_endpoint(
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
    blocked_users = await get_blocked_users(db, current_user.id)
    return [UserSearch.from_orm(user) for user in blocked_users]


@router.post("/close-friend/{user_id}")
async def toggle_close_friend_endpoint(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Toggle close friend status for a user.
    
    Args:
        user_id: ID of the friend to toggle close friend status
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message with new status
        
    Raises:
        HTTPException: If not friends with the user
    """
    # Check if users are friends
    friendship_status = await check_friendship_status(db, current_user.id, user_id)
    if friendship_status != "accepted":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Can only set close friend status for existing friends"
        )
    
    is_close_friend = await toggle_close_friend(db, current_user.id, user_id)
    status_text = "added to" if is_close_friend else "removed from"
    
    return {"message": f"User {status_text} close friends list"}


@router.get("/close-friends", response_model=List[UserSearch])
async def get_close_friends_endpoint(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get list of close friends.
    
    Args:
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserSearch]: List of close friends
    """
    close_friends = await get_close_friends(db, current_user.id)
    return [UserSearch.from_orm(friend) for friend in close_friends]


@router.get("/status/{user_id}")
async def get_friendship_status(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get friendship status with another user.
    
    Args:
        user_id: ID of the user to check friendship status with
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Friendship status information
    """
    if str(current_user.id) == user_id:
        return {"status": "self"}
    
    status_result = await check_friendship_status(db, current_user.id, user_id)
    return {"status": status_result}


@router.get("/mutual/{user_id}")
async def get_mutual_friends(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get mutual friends with another user.
    
    Args:
        user_id: ID of the user to find mutual friends with
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Mutual friends information
        
    Note: This is a placeholder implementation.
    In production, you'd implement efficient mutual friends logic.
    """
    # TODO: Implement mutual friends functionality
    return {
        "mutual_friends_count": 0,
        "mutual_friends": []
    }