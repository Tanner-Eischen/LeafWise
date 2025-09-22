"""User service.

This module provides user management services including
profile management, search, and user statistics.
"""

import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, desc, asc
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, status

from app.models.user import User
from app.models.friendship import Friendship, FriendshipStatus
from app.models.message import Message
from app.models.story import Story
from app.schemas.user import (
    UserUpdate, UserSearch, UserStats, UserSearchFilters,
    UserActivity, UserPreferences
)
from app.schemas.auth import UserCreate
from app.schemas.friendship import FriendProfile
from app.services.auth_service import auth_service


class UserService:
    """Service for user management operations."""
    
    def __init__(self):
        self.auth_service = auth_service
    
    async def create_user(
        self, 
        user_data: UserCreate, 
        session: AsyncSession
    ) -> User:
        """Create a new user."""
        # Hash the password
        hashed_password = self.auth_service.get_password_hash(user_data.password)
        
        # Create user instance
        user = User(
            email=user_data.email,
            username=user_data.username,
            display_name=user_data.display_name or user_data.username,
            hashed_password=hashed_password,
            bio=user_data.bio,
            location=user_data.location,
            gardening_experience=user_data.gardening_experience
        )
        
        session.add(user)
        await session.commit()
        await session.refresh(user)
        
        return user
    
    async def get_user_by_id(
        self, 
        user_id: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get user by ID."""
        result = await session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_user_by_id_uuid(
        self, 
        user_id: UUID, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get user by UUID."""
        result = await session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_user_by_username(
        self, 
        username: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get user by username."""
        result = await session.execute(
            select(User).where(User.username == username)
        )
        return result.scalar_one_or_none()
    
    async def get_user_by_email(
        self, 
        email: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get user by email."""
        result = await session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def search_users(
        self,
        query: str,
        current_user_id: str,
        session: AsyncSession,
        filters: Optional[UserSearchFilters] = None,
        limit: int = 20,
        offset: int = 0
    ) -> List[UserSearch]:
        """Search for users with optional filters."""
        # Base query
        base_query = select(User).where(
            and_(
                User.id != current_user_id,  # Exclude current user
                User.is_active == True,
                or_(
                    User.username.ilike(f"%{query}%"),
                    User.display_name.ilike(f"%{query}%"),
                    User.bio.ilike(f"%{query}%")
                )
            )
        )
        
        # Apply filters if provided
        if filters:
            if filters.gardening_experience:
                base_query = base_query.where(
                    User.gardening_experience == filters.gardening_experience
                )
            
            if filters.location:
                base_query = base_query.where(
                    User.location.ilike(f"%{filters.location}%")
                )
            
            if filters.has_avatar is not None:
                if filters.has_avatar:
                    base_query = base_query.where(User.avatar_url.isnot(None))
                else:
                    base_query = base_query.where(User.avatar_url.is_(None))
        
        # Add pagination
        base_query = base_query.offset(offset).limit(limit)
        
        # Execute query
        result = await session.execute(base_query)
        users = result.scalars().all()
        
        # Get friendship status for each user
        user_searches = []
        for user in users:
            friendship_status = await self._get_friendship_status(
                current_user_id, str(user.id), session
            )
            
            user_search = UserSearch(
                id=str(user.id),
                username=user.username,
                display_name=user.display_name,
                avatar_url=user.avatar_url,
                bio=user.bio,
                gardening_experience=user.gardening_experience,
                location=user.location,
                is_verified=user.is_verified,
                friendship_status=friendship_status,
                mutual_friends_count=await self._get_mutual_friends_count(
                    current_user_id, str(user.id), session
                )
            )
            user_searches.append(user_search)
        
        return user_searches
    
    async def get_user_profile(
        self,
        user_id: str,
        current_user_id: str,
        session: AsyncSession
    ) -> Optional[Dict[str, Any]]:
        """Get detailed user profile."""
        user = await self.get_user_by_id(user_id, session)
        if not user:
            return None
        
        # Check if current user can view this profile
        can_view_full_profile = await self._can_view_full_profile(
            current_user_id, user_id, session
        )
        
        # Get friendship status
        friendship_status = await self._get_friendship_status(
            current_user_id, user_id, session
        )
        
        # Get user statistics
        stats = await self.get_user_stats(user_id, session)
        
        # Build profile data
        profile_data = {
            "id": str(user.id),
            "username": user.username,
            "display_name": user.display_name,
            "avatar_url": user.avatar_url,
            "bio": user.bio if can_view_full_profile else None,
            "gardening_experience": user.gardening_experience,
            "favorite_plants": user.favorite_plants if can_view_full_profile else None,
            "location": user.location if can_view_full_profile or user.show_location else None,
            "is_verified": user.is_verified,
            "created_at": user.created_at,
            "last_active": user.last_active if can_view_full_profile else None,
            "friendship_status": friendship_status,
            "stats": stats,
            "is_online": await self.auth_service.is_user_online(user_id)
        }
        
        # Add mutual friends count if not the same user
        if current_user_id != user_id:
            profile_data["mutual_friends_count"] = await self._get_mutual_friends_count(
                current_user_id, user_id, session
            )
        
        return profile_data
    
    async def update_user_profile(
        self,
        user_id: str,
        update_data: UserUpdate,
        session: AsyncSession
    ) -> Optional[User]:
        """Update user profile."""
        user = await self.get_user_by_id(user_id, session)
        if not user:
            return None
        
        # Check username availability if being updated
        if update_data.username and update_data.username != user.username:
            is_available = await self.auth_service.check_username_availability(
                update_data.username, session, exclude_user_id=user_id
            )
            if not is_available:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Username is already taken"
                )
        
        # Update fields
        update_dict = update_data.dict(exclude_unset=True)
        for field, value in update_dict.items():
            if hasattr(user, field):
                setattr(user, field, value)
        
        user.updated_at = datetime.utcnow()
        await session.commit()
        await session.refresh(user)
        
        return user
    
    async def get_user_stats(
        self,
        user_id: str,
        session: AsyncSession
    ) -> UserStats:
        """Get user statistics."""
        # Count friends
        friends_count = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    or_(
                        Friendship.requester_id == user_id,
                        Friendship.addressee_id == user_id
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
        ) or 0
        
        # Count stories
        stories_count = await session.scalar(
            select(func.count(Story.id)).where(
                and_(
                    Story.user_id == user_id,
                    Story.is_active == True
                )
            )
        ) or 0
        
        # Count messages sent
        messages_sent = await session.scalar(
            select(func.count(Message.id)).where(
                Message.sender_id == user_id
            )
        ) or 0
        
        # Count messages received
        messages_received = await session.scalar(
            select(func.count(Message.id)).where(
                Message.recipient_id == user_id
            )
        ) or 0
        
        return UserStats(
            user_id=user_id,
            friends_count=friends_count,
            stories_count=stories_count,
            messages_sent=messages_sent,
            messages_received=messages_received,
            total_messages=messages_sent + messages_received
        )
    
    async def get_user_suggestions(
        self,
        user_id: str,
        session: AsyncSession,
        limit: int = 10
    ) -> List[UserSearch]:
        """Get user suggestions based on mutual friends and interests."""
        # Get users who are friends of friends but not direct friends
        mutual_friends_query = """
        SELECT DISTINCT u.id, u.username, u.display_name, u.avatar_url, u.bio,
               u.gardening_experience, u.location, u.is_verified,
               COUNT(mf.friend_id) as mutual_count
        FROM users u
        JOIN (
            SELECT CASE 
                WHEN f1.requester_id = :user_id THEN f1.addressee_id
                ELSE f1.requester_id
            END as friend_id
            FROM friendships f1
            WHERE (f1.requester_id = :user_id OR f1.addressee_id = :user_id)
            AND f1.status = 'accepted'
        ) mf ON (
            (u.id IN (
                SELECT CASE 
                    WHEN f2.requester_id = mf.friend_id THEN f2.addressee_id
                    ELSE f2.requester_id
                END
                FROM friendships f2
                WHERE (f2.requester_id = mf.friend_id OR f2.addressee_id = mf.friend_id)
                AND f2.status = 'accepted'
            ))
        )
        WHERE u.id != :user_id
        AND u.is_active = true
        AND u.id NOT IN (
            SELECT CASE 
                WHEN f3.requester_id = :user_id THEN f3.addressee_id
                ELSE f3.requester_id
            END
            FROM friendships f3
            WHERE (f3.requester_id = :user_id OR f3.addressee_id = :user_id)
        )
        GROUP BY u.id, u.username, u.display_name, u.avatar_url, u.bio,
                 u.gardening_experience, u.location, u.is_verified
        ORDER BY mutual_count DESC, u.created_at DESC
        LIMIT :limit
        """
        
        result = await session.execute(
            mutual_friends_query,
            {"user_id": user_id, "limit": limit}
        )
        
        suggestions = []
        for row in result:
            suggestion = UserSearch(
                id=str(row.id),
                username=row.username,
                display_name=row.display_name,
                avatar_url=row.avatar_url,
                bio=row.bio,
                gardening_experience=row.gardening_experience,
                location=row.location,
                is_verified=row.is_verified,
                friendship_status="none",
                mutual_friends_count=row.mutual_count
            )
            suggestions.append(suggestion)
        
        return suggestions
    
    async def block_user(
        self,
        blocker_id: str,
        blocked_id: str,
        session: AsyncSession
    ) -> bool:
        """Block a user."""
        # Check if friendship exists
        friendship = await session.execute(
            select(Friendship).where(
                or_(
                    and_(
                        Friendship.requester_id == blocker_id,
                        Friendship.addressee_id == blocked_id
                    ),
                    and_(
                        Friendship.requester_id == blocked_id,
                        Friendship.addressee_id == blocker_id
                    )
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if friendship:
            # Update existing friendship to blocked
            friendship.status = FriendshipStatus.BLOCKED
            friendship.updated_at = datetime.utcnow()
        else:
            # Create new blocked relationship
            new_friendship = Friendship(
                requester_id=blocker_id,
                addressee_id=blocked_id,
                status=FriendshipStatus.BLOCKED
            )
            session.add(new_friendship)
        
        await session.commit()
        return True
    
    async def unblock_user(
        self,
        blocker_id: str,
        blocked_id: str,
        session: AsyncSession
    ) -> bool:
        """Unblock a user."""
        friendship = await session.execute(
            select(Friendship).where(
                and_(
                    Friendship.requester_id == blocker_id,
                    Friendship.addressee_id == blocked_id,
                    Friendship.status == FriendshipStatus.BLOCKED
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if friendship:
            await session.delete(friendship)
            await session.commit()
            return True
        
        return False
    
    async def get_blocked_users(
        self,
        user_id: str,
        session: AsyncSession
    ) -> List[Dict[str, Any]]:
        """Get list of blocked users."""
        result = await session.execute(
            select(Friendship, User).join(
                User, User.id == Friendship.addressee_id
            ).where(
                and_(
                    Friendship.requester_id == user_id,
                    Friendship.status == FriendshipStatus.BLOCKED
                )
            )
        )
        
        blocked_users = []
        for friendship, user in result:
            blocked_users.append({
                "user_id": str(user.id),
                "username": user.username,
                "display_name": user.display_name,
                "avatar_url": user.avatar_url,
                "blocked_at": friendship.created_at
            })
        
        return blocked_users
    
    async def _get_friendship_status(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> str:
        """Get friendship status between two users."""
        if user1_id == user2_id:
            return "self"
        
        result = await session.execute(
            select(Friendship).where(
                or_(
                    and_(
                        Friendship.requester_id == user1_id,
                        Friendship.addressee_id == user2_id
                    ),
                    and_(
                        Friendship.requester_id == user2_id,
                        Friendship.addressee_id == user1_id
                    )
                )
            )
        )
        friendship = result.scalar_one_or_none()
        
        if not friendship:
            return "none"
        
        if friendship.status == FriendshipStatus.BLOCKED:
            return "blocked"
        elif friendship.status == FriendshipStatus.PENDING:
            if friendship.requester_id == user1_id:
                return "pending_sent"
            else:
                return "pending_received"
        elif friendship.status == FriendshipStatus.ACCEPTED:
            return "friends"
        elif friendship.status == FriendshipStatus.DECLINED:
            return "declined"
        
        return "none"
    
    async def _get_mutual_friends_count(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> int:
        """Get count of mutual friends between two users."""
        # This is a complex query - for now return 0
        # In a real implementation, you'd query for mutual friends
        return 0
    
    async def _can_view_full_profile(
        self,
        viewer_id: str,
        profile_user_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if viewer can see full profile details."""
        if viewer_id == profile_user_id:
            return True
        
        # Check if they are friends
        friendship_status = await self._get_friendship_status(
            viewer_id, profile_user_id, session
        )
        
        return friendship_status == "friends"
    
    async def get_all_users(
        self,
        session: AsyncSession,
        skip: int = 0,
        limit: int = 50,
        role_filter: Optional[str] = None
    ) -> tuple[List[User], int]:
        """Get all users with optional role filtering (admin only).
        
        Args:
            session: Database session
            skip: Number of records to skip
            limit: Maximum number of records to return
            role_filter: Optional role filter (admin, expert, moderator)
            
        Returns:
            Tuple of (users list, total count)
        """
        # Build base query
        base_query = select(User).where(User.is_active == True)
        count_query = select(func.count(User.id)).where(User.is_active == True)
        
        # Apply role filter if provided
        if role_filter:
            if role_filter == "admin":
                base_query = base_query.where(User.is_admin == True)
                count_query = count_query.where(User.is_admin == True)
            elif role_filter == "expert":
                base_query = base_query.where(User.is_expert == True)
                count_query = count_query.where(User.is_expert == True)
            elif role_filter == "moderator":
                base_query = base_query.where(User.is_moderator == True)
                count_query = count_query.where(User.is_moderator == True)
        
        # Get total count
        count_result = await session.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await session.execute(
            base_query.order_by(User.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        users = result.scalars().all()
        
        return list(users), total
    
    async def search_users_simple(
        self,
        query: str,
        session: AsyncSession,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[User], int]:
        """Simple user search without complex filtering.
        
        Args:
            query: Search query
            session: Database session
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (users list, total count)
        """
        # Build base query
        base_query = select(User).where(
            and_(
                User.is_active == True,
                or_(
                    User.username.ilike(f"%{query}%"),
                    User.display_name.ilike(f"%{query}%"),
                    User.bio.ilike(f"%{query}%")
                )
            )
        )
        
        count_query = select(func.count(User.id)).where(
            and_(
                User.is_active == True,
                or_(
                    User.username.ilike(f"%{query}%"),
                    User.display_name.ilike(f"%{query}%"),
                    User.bio.ilike(f"%{query}%")
                )
            )
        )
        
        # Get total count
        count_result = await session.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await session.execute(
            base_query.order_by(User.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        users = result.scalars().all()
        
        return list(users), total


# Global user service instance
user_service = UserService()


async def get_user_by_id(
    user_id: str,
    session: AsyncSession
) -> Optional[User]:
    """Get user by ID."""
    return await user_service.get_user_by_id(user_id, session)


async def get_user_by_username(
    username: str,
    session: AsyncSession
) -> Optional[User]:
    """Get user by username."""
    return await user_service.get_user_by_username(username, session)


async def search_users(
    query: str,
    current_user_id: str,
    session: AsyncSession,
    limit: int = 20
) -> List[dict]:
    """Search users."""
    return await user_service.search_users(query, current_user_id, session, limit)


async def update_user_profile(
    user_id: str,
    profile_data: dict,
    session: AsyncSession
) -> User:
    """Update user profile."""
    return await user_service.update_user_profile(user_id, profile_data, session)


async def get_user_stats(
    user_id: str,
    session: AsyncSession
) -> dict:
    """Get user stats."""
    return await user_service.get_user_stats(user_id, session)


async def get_user_service():
    """Get user service dependency."""
    return user_service