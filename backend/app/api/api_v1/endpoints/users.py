"""User management endpoints.

This module provides endpoints for user profile management,
user discovery, and user-related operations.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime
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
from app.services.user_service import UserService
from app.services.auth_service import AuthService
from app.schemas.auth import (
    UserPublicRead, 
    UserRoleUpdate, 
    UserPermissionsSummary
)
from app.schemas.user import  UserListResponse, UserSearchFilters

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


@router.get("/me", response_model=UserRead)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """Get current authenticated user information.
    
    Args:
        current_user: Current authenticated user
        
    Returns:
        UserRead: Current user data
    """
    return UserRead.from_orm(current_user)


@router.put("/me", response_model=UserRead)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Update current authenticated user information.
    
    Args:
        user_update: User update data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserRead: Updated user data
    """
    # Update user fields
    update_data = user_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if hasattr(current_user, field):
            setattr(current_user, field, value)
    
    # Save changes
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    
    return UserRead.from_orm(current_user)


@router.get("/{user_id}", response_model=UserPublicRead)
async def get_user_profile(
    user_id: UUID,
    current_user: Optional[User] = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user profile information.
    
    Args:
        user_id: User ID to get profile for
        current_user: Current authenticated user (optional)
        db: Database session
        
    Returns:
        UserPublicRead: User profile data
    """
    user_service = UserService()
    user = await user_service.get_user_by_id_uuid(user_id, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Check privacy permissions if needed
    if current_user:
        AuthService.check_privacy_permissions(user, current_user, "profile")
    elif user.is_private:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User profile is private"
        )
    
    return UserPublicRead.from_orm(user)


@router.get("/search", response_model=UserListResponse)
async def search_users(
    query: str = Query(..., min_length=2, description="Search query"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Search users by username or display name.
    
    Args:
        query: Search query
        skip: Number of records to skip
        limit: Maximum number of records to return
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserListResponse: Search results
    """
    user_service = UserService()
    users, total = await user_service.search_users_simple(query, db, skip, limit)
    
    return UserListResponse(
        users=[UserPublicRead.from_orm(user) for user in users],
        total=total,
        skip=skip,
        limit=limit
    )


# Admin-only endpoints for user role management

@router.get("/admin/users", response_model=List[UserRead])
async def get_all_users_admin(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(50, ge=1, le=200, description="Maximum number of records to return"),
    role_filter: Optional[str] = Query(None, description="Filter by role (admin, expert, moderator)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get all users (admin only).
    
    Args:
        skip: Number of records to skip
        limit: Maximum number of records to return
        role_filter: Optional role filter
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[UserRead]: List of users with full data
    """
    # Verify admin permission
    AuthService.check_admin_permission(current_user, "user_management")
    
    user_service = UserService()
    users, total = await user_service.get_all_users(db, skip, limit, role_filter)
    
    return [UserRead.from_orm(user) for user in users]


@router.put("/admin/users/{user_id}/roles", response_model=UserRead)
async def update_user_roles(
    user_id: UUID,
    role_update: UserRoleUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Update user roles and permissions (admin only).
    
    Args:
        user_id: User ID to update
        role_update: Role update data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserRead: Updated user data
    """
    # Verify admin permission
    AuthService.check_admin_permission(current_user, "role_management")
    
    # Get target user
    user_service = UserService()
    user = await user_service.get_user_by_id_uuid(user_id, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Update role fields
    update_data = role_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if field in ["expert_specialties", "admin_permissions"] and value is not None:
            # Convert list to JSON string
            import json
            setattr(user, field, json.dumps(value))
        elif hasattr(user, field):
            setattr(user, field, value)
    
    user.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(user)
    
    return UserRead.from_orm(user)


@router.post("/admin/users/{user_id}/grant-role")
async def grant_user_role(
    user_id: UUID,
    role: str = Query(..., description="Role to grant (admin, expert, moderator)"),
    permissions: Optional[List[str]] = Query(None, description="Specific permissions for the role"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Grant a role to a user (admin only).
    
    Args:
        user_id: User ID to grant role to
        role: Role to grant
        permissions: Optional specific permissions
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
    """
    # Verify admin permission
    AuthService.check_admin_permission(current_user, "role_management")
    
    success = await AuthService.grant_role(db, user_id, role, permissions, current_user.id)
    
    return {
        "success": success,
        "message": f"Role '{role}' granted to user {user_id}",
        "granted_by": str(current_user.id)
    }


@router.post("/admin/users/{user_id}/revoke-role")
async def revoke_user_role(
    user_id: UUID,
    role: str = Query(..., description="Role to revoke (admin, expert, moderator)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Revoke a role from a user (admin only).
    
    Args:
        user_id: User ID to revoke role from
        role: Role to revoke
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
    """
    # Verify admin permission
    AuthService.check_admin_permission(current_user, "role_management")
    
    # Prevent self-role revocation for admins
    if user_id == current_user.id and role == "admin":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot revoke your own admin role"
        )
    
    success = await AuthService.revoke_role(db, user_id, role, current_user.id)
    
    return {
        "success": success,
        "message": f"Role '{role}' revoked from user {user_id}",
        "revoked_by": str(current_user.id)
    }


@router.get("/admin/users/{user_id}/permissions", response_model=UserPermissionsSummary)
async def get_user_permissions(
    user_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user permissions summary (admin only).
    
    Args:
        user_id: User ID to get permissions for
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        UserPermissionsSummary: User permissions summary
    """
    # Verify admin permission or self-access
    if user_id != current_user.id:
        AuthService.check_admin_permission(current_user, "user_management")
    
    user_service = UserService()
    user = await user_service.get_user_by_id_uuid(user_id, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    permissions_summary = AuthService.get_user_permissions_summary(user)
    
    return UserPermissionsSummary(**permissions_summary)


@router.get("/my-permissions", response_model=UserPermissionsSummary)
async def get_my_permissions(
    current_user: User = Depends(get_current_user)
):
    """Get current user's permissions summary.
    
    Args:
        current_user: Current authenticated user
        
    Returns:
        UserPermissionsSummary: Current user's permissions summary
    """
    permissions_summary = AuthService.get_user_permissions_summary(current_user)
    
    return UserPermissionsSummary(**permissions_summary)


@router.post("/logout")
async def logout(
    current_user: User = Depends(get_current_user)
):
    """Logout current user.
    
    Note: In a stateless JWT system, logout is handled client-side
    by removing the token. This endpoint is for consistency.
    
    Args:
        current_user: Current authenticated user
        
    Returns:
        dict: Success message
    """
    return {"message": "Successfully logged out"}


@router.post("/verify-email")
async def verify_email(
    token: str,
    db: AsyncSession = Depends(get_db)
):
    """Verify user email address.
    
    Args:
        token: Email verification token
        db: Database session
        
    Returns:
        dict: Success message
        
    Note: Implementation depends on email service setup
    """
    # TODO: Implement email verification logic
    return {"message": "Email verification not implemented yet"}