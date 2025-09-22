"""Friendship service.

This module provides friendship management services including
friend requests, friend management, and social features.
"""

import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, desc, asc
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, status

from app.models.friendship import Friendship, FriendshipStatus
from app.models.user import User
from app.schemas.friendship import (
    FriendRequestCreate, FriendshipUpdate, FriendProfile,
    FriendsList, FriendRequestsList, MutualFriends,
    FriendshipStats, FriendSuggestion, FriendActivity
)
from app.core.websocket import websocket_manager


class FriendshipService:
    """Service for friendship management operations."""
    
    def __init__(self):
        self.connection_manager = websocket_manager
    
    async def send_friend_request(
        self,
        requester_id: str,
        request_data: FriendRequestCreate,
        session: AsyncSession
    ) -> Optional[Friendship]:
        """Send a friend request."""
        addressee_id = request_data.user_id
        
        # Check if trying to add self
        if requester_id == addressee_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You cannot send a friend request to yourself"
            )
        
        # Check if addressee exists
        addressee = await session.get(User, addressee_id)
        if not addressee or not addressee.is_active:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Check if friendship already exists
        existing_friendship = await session.execute(
            select(Friendship).where(
                or_(
                    and_(
                        Friendship.requester_id == requester_id,
                        Friendship.addressee_id == addressee_id
                    ),
                    and_(
                        Friendship.requester_id == addressee_id,
                        Friendship.addressee_id == requester_id
                    )
                )
            )
        )
        existing_friendship = existing_friendship.scalar_one_or_none()
        
        if existing_friendship:
            if existing_friendship.status == FriendshipStatus.ACCEPTED:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="You are already friends with this user"
                )
            elif existing_friendship.status == FriendshipStatus.PENDING:
                if existing_friendship.requester_id == requester_id:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Friend request already sent"
                    )
                else:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="This user has already sent you a friend request"
                    )
            elif existing_friendship.status == FriendshipStatus.BLOCKED:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Cannot send friend request to this user"
                )
            elif existing_friendship.status == FriendshipStatus.DECLINED:
                # Allow sending new request after decline
                existing_friendship.status = FriendshipStatus.PENDING
                existing_friendship.requester_id = requester_id
                existing_friendship.addressee_id = addressee_id
                existing_friendship.updated_at = datetime.utcnow()
                await session.commit()
                await session.refresh(existing_friendship)
                
                # Send notification
                await self._send_friend_request_notification(
                    existing_friendship, request_data.message, session
                )
                
                return existing_friendship
        
        # Create new friend request
        friendship = Friendship(
            requester_id=requester_id,
            addressee_id=addressee_id,
            status=FriendshipStatus.PENDING
        )
        
        session.add(friendship)
        await session.commit()
        await session.refresh(friendship)
        
        # Send notification
        await self._send_friend_request_notification(
            friendship, request_data.message, session
        )
        
        return friendship
    
    async def accept_friend_request(
        self,
        friendship_id: str,
        user_id: str,
        session: AsyncSession
    ) -> bool:
        """Accept a friend request."""
        friendship = await session.execute(
            select(Friendship).where(
                and_(
                    Friendship.id == friendship_id,
                    Friendship.addressee_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if not friendship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Friend request not found"
            )
        
        # Accept the request
        friendship.status = FriendshipStatus.ACCEPTED
        friendship.updated_at = datetime.utcnow()
        
        await session.commit()
        
        # Send acceptance notification
        await self._send_friend_request_accepted_notification(friendship, session)
        
        return True
    
    async def decline_friend_request(
        self,
        friendship_id: str,
        user_id: str,
        session: AsyncSession
    ) -> bool:
        """Decline a friend request."""
        friendship = await session.execute(
            select(Friendship).where(
                and_(
                    Friendship.id == friendship_id,
                    Friendship.addressee_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if not friendship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Friend request not found"
            )
        
        # Decline the request
        friendship.status = FriendshipStatus.DECLINED
        friendship.updated_at = datetime.utcnow()
        
        await session.commit()
        return True
    
    async def remove_friend(
        self,
        user_id: str,
        friend_id: str,
        session: AsyncSession
    ) -> bool:
        """Remove a friend."""
        friendship = await session.execute(
            select(Friendship).where(
                and_(
                    or_(
                        and_(
                            Friendship.requester_id == user_id,
                            Friendship.addressee_id == friend_id
                        ),
                        and_(
                            Friendship.requester_id == friend_id,
                            Friendship.addressee_id == user_id
                        )
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if not friendship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Friendship not found"
            )
        
        # Remove the friendship
        await session.delete(friendship)
        await session.commit()
        
        return True
    
    async def get_friends_list(
        self,
        user_id: str,
        session: AsyncSession,
        limit: int = 50,
        offset: int = 0,
        close_friends_only: bool = False
    ) -> FriendsList:
        """Get user's friends list."""
        # Build query for friends
        friends_query = (
            select(
                Friendship,
                User,
                func.case(
                    (Friendship.requester_id == user_id, Friendship.addressee_id),
                    else_=Friendship.requester_id
                ).label("friend_id")
            )
            .join(
                User,
                User.id == func.case(
                    (Friendship.requester_id == user_id, Friendship.addressee_id),
                    else_=Friendship.requester_id
                )
            )
            .where(
                and_(
                    or_(
                        Friendship.requester_id == user_id,
                        Friendship.addressee_id == user_id
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED,
                    User.is_active == True
                )
            )
        )
        
        if close_friends_only:
            friends_query = friends_query.where(Friendship.is_close_friend == True)
        
        # Get total count
        count_query = select(func.count()).select_from(friends_query.subquery())
        total_count = await session.scalar(count_query) or 0
        
        # Add pagination and ordering
        friends_query = (
            friends_query
            .order_by(asc(User.display_name))
            .offset(offset)
            .limit(limit)
        )
        
        result = await session.execute(friends_query)
        friends_data = result.all()
        
        # Convert to FriendProfile format
        friends = []
        for friendship, user, friend_id in friends_data:
            # Get mutual friends count
            mutual_count = await self._get_mutual_friends_count(user_id, str(friend_id), session)
            
            friend_profile = FriendProfile(
                user_id=str(user.id),
                username=user.username,
                display_name=user.display_name,
                avatar_url=user.avatar_url,
                bio=user.bio,
                gardening_experience=user.gardening_experience,
                favorite_plants=user.favorite_plants,
                location=user.location,
                friendship_id=str(friendship.id),
                is_close_friend=friendship.is_close_friend,
                friends_since=friendship.created_at,
                last_active=user.last_active,
                is_online=False,  # Will be updated with real-time data
                mutual_friends_count=mutual_count,
                stories_count=0  # Could be calculated if needed
            )
            friends.append(friend_profile)
        
        # Get additional counts
        close_friends_count = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    or_(
                        Friendship.requester_id == user_id,
                        Friendship.addressee_id == user_id
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED,
                    Friendship.is_close_friend == True
                )
            )
        ) or 0
        
        return FriendsList(
            friends=friends,
            total_count=total_count,
            close_friends_count=close_friends_count,
            online_friends_count=0  # Would need real-time data
        )
    
    async def get_friend_requests(
        self,
        user_id: str,
        session: AsyncSession
    ) -> FriendRequestsList:
        """Get pending friend requests for a user."""
        # Received requests
        received_query = (
            select(Friendship, User)
            .join(User, User.id == Friendship.requester_id)
            .where(
                and_(
                    Friendship.addressee_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
            .order_by(desc(Friendship.created_at))
        )
        
        # Sent requests
        sent_query = (
            select(Friendship, User)
            .join(User, User.id == Friendship.addressee_id)
            .where(
                and_(
                    Friendship.requester_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
            .order_by(desc(Friendship.created_at))
        )
        
        received_result = await session.execute(received_query)
        sent_result = await session.execute(sent_query)
        
        # Convert to FriendshipRead format
        from app.schemas.friendship import FriendshipRead
        
        pending_requests = []
        for friendship, user in received_result:
            request = FriendshipRead(
                id=str(friendship.id),
                requester_id=str(friendship.requester_id),
                addressee_id=str(friendship.addressee_id),
                status=friendship.status,
                is_close_friend=friendship.is_close_friend,
                created_at=friendship.created_at,
                updated_at=friendship.updated_at,
                requester_username=user.username,
                requester_display_name=user.display_name,
                requester_avatar_url=user.avatar_url
            )
            pending_requests.append(request)
        
        sent_requests = []
        for friendship, user in sent_result:
            request = FriendshipRead(
                id=str(friendship.id),
                requester_id=str(friendship.requester_id),
                addressee_id=str(friendship.addressee_id),
                status=friendship.status,
                is_close_friend=friendship.is_close_friend,
                created_at=friendship.created_at,
                updated_at=friendship.updated_at,
                addressee_username=user.username,
                addressee_display_name=user.display_name,
                addressee_avatar_url=user.avatar_url
            )
            sent_requests.append(request)
        
        return FriendRequestsList(
            pending_requests=pending_requests,
            sent_requests=sent_requests,
            total_pending=len(pending_requests),
            total_sent=len(sent_requests)
        )
    
    async def toggle_close_friend(
        self,
        user_id: str,
        friend_id: str,
        session: AsyncSession
    ) -> bool:
        """Toggle close friend status."""
        friendship = await session.execute(
            select(Friendship).where(
                and_(
                    or_(
                        and_(
                            Friendship.requester_id == user_id,
                            Friendship.addressee_id == friend_id
                        ),
                        and_(
                            Friendship.requester_id == friend_id,
                            Friendship.addressee_id == user_id
                        )
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
        )
        friendship = friendship.scalar_one_or_none()
        
        if not friendship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Friendship not found"
            )
        
        # Toggle close friend status
        friendship.is_close_friend = not friendship.is_close_friend
        friendship.updated_at = datetime.utcnow()
        
        await session.commit()
        return friendship.is_close_friend
    
    async def block_user(
        self,
        blocker_id: str,
        blocked_id: str,
        session: AsyncSession
    ) -> bool:
        """Block a user."""
        if blocker_id == blocked_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You cannot block yourself"
            )
        
        # Check if user exists
        blocked_user = await session.get(User, blocked_id)
        if not blocked_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Check existing friendship
        existing_friendship = await session.execute(
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
        existing_friendship = existing_friendship.scalar_one_or_none()
        
        if existing_friendship:
            # Update existing relationship to blocked
            existing_friendship.status = FriendshipStatus.BLOCKED
            existing_friendship.requester_id = blocker_id  # Blocker becomes requester
            existing_friendship.addressee_id = blocked_id
            existing_friendship.is_close_friend = False
            existing_friendship.updated_at = datetime.utcnow()
        else:
            # Create new blocked relationship
            friendship = Friendship(
                requester_id=blocker_id,
                addressee_id=blocked_id,
                status=FriendshipStatus.BLOCKED
            )
            session.add(friendship)
        
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
        
        if not friendship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Block relationship not found"
            )
        
        # Remove the block
        await session.delete(friendship)
        await session.commit()
        
        return True
    
    async def get_friendship_status(
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
            if friendship.requester_id == user1_id:
                return "blocked_by_you"
            else:
                return "blocked_by_them"
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
    
    async def get_mutual_friends(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession,
        limit: int = 10
    ) -> MutualFriends:
        """Get mutual friends between two users."""
        # This is a complex query - simplified implementation
        mutual_friends = []  # Would implement actual mutual friends logic
        
        return MutualFriends(
            user_id=user2_id,
            mutual_friends=mutual_friends,
            mutual_friends_count=len(mutual_friends),
            total_friends_count=0  # Would calculate actual count
        )
    
    async def get_friendship_stats(
        self,
        user_id: str,
        session: AsyncSession
    ) -> FriendshipStats:
        """Get friendship statistics for a user."""
        # Total friends
        total_friends = await session.scalar(
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
        
        # Close friends
        close_friends = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    or_(
                        Friendship.requester_id == user_id,
                        Friendship.addressee_id == user_id
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED,
                    Friendship.is_close_friend == True
                )
            )
        ) or 0
        
        # Pending requests received
        pending_received = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    Friendship.addressee_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
        ) or 0
        
        # Pending requests sent
        pending_sent = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    Friendship.requester_id == user_id,
                    Friendship.status == FriendshipStatus.PENDING
                )
            )
        ) or 0
        
        # Blocked users
        blocked_users = await session.scalar(
            select(func.count(Friendship.id)).where(
                and_(
                    Friendship.requester_id == user_id,
                    Friendship.status == FriendshipStatus.BLOCKED
                )
            )
        ) or 0
        
        return FriendshipStats(
            user_id=user_id,
            total_friends=total_friends,
            close_friends=close_friends,
            pending_requests_received=pending_received,
            pending_requests_sent=pending_sent,
            blocked_users=blocked_users
        )
    
    async def _get_mutual_friends_count(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> int:
        """Get count of mutual friends between two users."""
        # Simplified implementation - would need complex query for actual mutual friends
        return 0
    
    async def _send_friend_request_notification(
        self,
        friendship: Friendship,
        message: Optional[str],
        session: AsyncSession
    ):
        """Send friend request notification."""
        requester = await session.get(User, friendship.requester_id)
        
        if requester:
            notification_data = {
                "type": "friend_request",
                "friendship_id": str(friendship.id),
                "requester_id": str(friendship.requester_id),
                "requester_username": requester.username,
                "requester_display_name": requester.display_name,
                "requester_avatar_url": requester.avatar_url,
                "message": message,
                "timestamp": friendship.created_at.isoformat()
            }
            
            await self.connection_manager.send_personal_message(
                str(friendship.addressee_id),
                notification_data
            )
    
    async def _send_friend_request_accepted_notification(
        self,
        friendship: Friendship,
        session: AsyncSession
    ):
        """Send friend request accepted notification."""
        addressee = await session.get(User, friendship.addressee_id)
        
        if addressee:
            notification_data = {
                "type": "friend_request_accepted",
                "friendship_id": str(friendship.id),
                "accepter_id": str(friendship.addressee_id),
                "accepter_username": addressee.username,
                "accepter_display_name": addressee.display_name,
                "accepter_avatar_url": addressee.avatar_url,
                "timestamp": friendship.updated_at.isoformat()
            }
            
            await self.connection_manager.send_personal_message(
                str(friendship.requester_id),
                notification_data
            )


# Global friendship service instance
friendship_service = FriendshipService()


# Convenience functions for backward compatibility
async def check_friendship_status(
    user_id: str,
    other_user_id: str,
    session: AsyncSession
) -> Optional[str]:
    """Check friendship status between two users."""
    friendship = await session.execute(
        select(Friendship).where(
            or_(
                and_(
                    Friendship.requester_id == user_id,
                    Friendship.addressee_id == other_user_id
                ),
                and_(
                    Friendship.requester_id == other_user_id,
                    Friendship.addressee_id == user_id
                )
            )
        )
    )
    friendship = friendship.scalar_one_or_none()
    
    if not friendship:
        return None
    
    return friendship.status.value


async def send_friend_request(
    requester_id: str,
    addressee_id: str,
    session: AsyncSession
) -> dict:
    """Send a friend request."""
    return await friendship_service.send_friend_request(requester_id, addressee_id, session)


async def accept_friend_request(
    request_id: str,
    user_id: str,
    session: AsyncSession
) -> dict:
    """Accept a friend request."""
    return await friendship_service.accept_friend_request(request_id, user_id, session)


async def decline_friend_request(
    request_id: str,
    user_id: str,
    session: AsyncSession
) -> dict:
    """Decline a friend request."""
    return await friendship_service.decline_friend_request(request_id, user_id, session)


async def remove_friend(
    user_id: str,
    friend_id: str,
    session: AsyncSession
) -> dict:
    """Remove a friend."""
    return await friendship_service.remove_friend(user_id, friend_id, session)


async def block_user(
    user_id: str,
    blocked_user_id: str,
    session: AsyncSession
) -> dict:
    """Block a user."""
    return await friendship_service.block_user(user_id, blocked_user_id, session)


async def unblock_user(
    user_id: str,
    blocked_user_id: str,
    session: AsyncSession
) -> dict:
    """Unblock a user."""
    return await friendship_service.unblock_user(user_id, blocked_user_id, session)


async def get_friends_list(
    user_id: str,
    session: AsyncSession
) -> List[dict]:
    """Get friends list."""
    return await friendship_service.get_friends_list(user_id, session)


async def get_pending_requests(
    user_id: str,
    session: AsyncSession
) -> List[dict]:
    """Get pending friend requests."""
    return await friendship_service.get_pending_requests(user_id, session)


async def get_sent_requests(
    user_id: str,
    session: AsyncSession
) -> List[dict]:
    """Get sent friend requests."""
    return await friendship_service.get_sent_requests(user_id, session)


async def get_blocked_users(
    user_id: str,
    session: AsyncSession
) -> List[dict]:
    """Get blocked users."""
    return await friendship_service.get_blocked_users(user_id, session)


async def toggle_close_friend(
    user_id: str,
    friend_id: str,
    session: AsyncSession
) -> dict:
    """Toggle close friend status."""
    return await friendship_service.toggle_close_friend(user_id, friend_id, session)


async def get_close_friends(
    user_id: str,
    session: AsyncSession
) -> List[dict]:
    """Get close friends."""
    return await friendship_service.get_close_friends(user_id, session)


async def get_friendship_service():
    """Get friendship service dependency."""
    return friendship_service