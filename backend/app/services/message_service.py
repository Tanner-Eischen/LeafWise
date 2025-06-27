"""Message service.

This module provides messaging services including
sending, receiving, and managing messages.
"""

import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, desc, asc
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, status

from app.models.message import Message
from app.schemas.message import MessageType, MessageStatus
from app.models.user import User
from app.models.friendship import Friendship, FriendshipStatus
from app.schemas.message import (
    MessageCreate, MessageUpdate, MessageRead, MessageThread,
    MessageSearch, MessageAnalytics
)
from app.core.websocket import websocket_manager


class MessageService:
    """Service for message management operations."""
    
    def __init__(self):
        self.connection_manager = websocket_manager
    
    async def send_message(
        self,
        sender_id: str,
        message_data: MessageCreate,
        session: AsyncSession
    ) -> Optional[Message]:
        """Send a message to another user."""
        # Check if users are friends
        if not await self._are_users_friends(sender_id, message_data.recipient_id, session):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only send messages to friends"
            )
        
        # Check if recipient exists and is active
        recipient = await session.execute(
            select(User).where(
                and_(
                    User.id == message_data.recipient_id,
                    User.is_active == True
                )
            )
        )
        recipient = recipient.scalar_one_or_none()
        if not recipient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Recipient not found"
            )
        
        # Validate message content based on type
        await self._validate_message_content(message_data)
        
        # Create message
        message = Message(
            sender_id=sender_id,
            recipient_id=message_data.recipient_id,
            content_type=message_data.content_type,
            content=message_data.content,
            media_url=message_data.media_url,
            caption=message_data.caption,
            duration=message_data.duration,
            file_size=message_data.file_size,
            disappears_at=message_data.disappears_at,
            status=MessageStatus.SENT
        )
        
        session.add(message)
        await session.commit()
        await session.refresh(message)
        
        # Send real-time notification
        await self._send_real_time_notification(message, session)
        
        return message
    
    async def get_message_by_id(
        self,
        message_id: str,
        user_id: str,
        session: AsyncSession
    ) -> Optional[Message]:
        """Get message by ID if user has access."""
        result = await session.execute(
            select(Message).where(
                and_(
                    Message.id == message_id,
                    or_(
                        Message.sender_id == user_id,
                        Message.recipient_id == user_id
                    )
                )
            )
        )
        return result.scalar_one_or_none()
    
    async def get_conversation(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession,
        limit: int = 50,
        offset: int = 0,
        before_message_id: Optional[str] = None
    ) -> List[MessageRead]:
        """Get conversation between two users."""
        # Check if users are friends
        if not await self._are_users_friends(user1_id, user2_id, session):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only view conversations with friends"
            )
        
        # Build query
        query = select(Message).where(
            and_(
                or_(
                    and_(
                        Message.sender_id == user1_id,
                        Message.recipient_id == user2_id
                    ),
                    and_(
                        Message.sender_id == user2_id,
                        Message.recipient_id == user1_id
                    )
                ),
                Message.status != MessageStatus.DELETED
            )
        )
        
        # Add before_message_id filter for pagination
        if before_message_id:
            before_message = await self.get_message_by_id(before_message_id, user1_id, session)
            if before_message:
                query = query.where(Message.created_at < before_message.created_at)
        
        # Add ordering and pagination
        query = query.order_by(desc(Message.created_at)).offset(offset).limit(limit)
        
        result = await session.execute(query)
        messages = result.scalars().all()
        
        # Convert to MessageRead format
        message_reads = []
        for message in messages:
            # Get sender and recipient info
            sender = await session.get(User, message.sender_id)
            recipient = await session.get(User, message.recipient_id)
            
            message_read = MessageRead(
                id=str(message.id),
                sender_id=str(message.sender_id),
                recipient_id=str(message.recipient_id),
                content_type=message.content_type,
                content=message.content,
                media_url=message.media_url,
                caption=message.caption,
                duration=message.duration,
                file_size=message.file_size,
                status=message.status,
                created_at=message.created_at,
                updated_at=message.updated_at,
                delivered_at=message.delivered_at,
                read_at=message.read_at,
                disappears_at=message.disappears_at,
                sender_username=sender.username if sender else None,
                sender_display_name=sender.display_name if sender else None,
                sender_avatar_url=sender.avatar_url if sender else None,
                recipient_username=recipient.username if recipient else None,
                recipient_display_name=recipient.display_name if recipient else None,
                recipient_avatar_url=recipient.avatar_url if recipient else None
            )
            message_reads.append(message_read)
        
        return message_reads
    
    async def get_user_conversations(
        self,
        user_id: str,
        session: AsyncSession,
        limit: int = 20,
        offset: int = 0
    ) -> List[MessageThread]:
        """Get list of user's conversations with latest message."""
        # Get latest message for each conversation
        subquery = (
            select(
                func.max(Message.id).label("latest_message_id"),
                func.case(
                    (Message.sender_id == user_id, Message.recipient_id),
                    else_=Message.sender_id
                ).label("other_user_id")
            )
            .where(
                and_(
                    or_(
                        Message.sender_id == user_id,
                        Message.recipient_id == user_id
                    ),
                    Message.status != MessageStatus.DELETED
                )
            )
            .group_by("other_user_id")
            .subquery()
        )
        
        # Get the actual latest messages
        query = (
            select(Message, User)
            .join(subquery, Message.id == subquery.c.latest_message_id)
            .join(User, User.id == subquery.c.other_user_id)
            .order_by(desc(Message.created_at))
            .offset(offset)
            .limit(limit)
        )
        
        result = await session.execute(query)
        conversations = []
        
        for message, other_user in result:
            # Count unread messages
            unread_count = await session.scalar(
                select(func.count(Message.id)).where(
                    and_(
                        Message.sender_id == str(other_user.id),
                        Message.recipient_id == user_id,
                        Message.read_at.is_(None),
                        Message.status != MessageStatus.DELETED
                    )
                )
            ) or 0
            
            conversation = MessageThread(
                other_user_id=str(other_user.id),
                other_user_username=other_user.username,
                other_user_display_name=other_user.display_name,
                other_user_avatar_url=other_user.avatar_url,
                latest_message_id=str(message.id),
                latest_message_content=message.content,
                latest_message_type=message.content_type,
                latest_message_timestamp=message.created_at,
                unread_count=unread_count,
                is_other_user_online=False  # Will be updated with real-time data
            )
            conversations.append(conversation)
        
        return conversations
    
    async def mark_message_as_read(
        self,
        message_id: str,
        user_id: str,
        session: AsyncSession
    ) -> bool:
        """Mark a message as read."""
        message = await session.execute(
            select(Message).where(
                and_(
                    Message.id == message_id,
                    Message.recipient_id == user_id,
                    Message.read_at.is_(None)
                )
            )
        )
        message = message.scalar_one_or_none()
        
        if message:
            message.read_at = datetime.utcnow()
            message.status = MessageStatus.READ
            await session.commit()
            
            # Send read receipt notification
            await self._send_read_receipt(message)
            return True
        
        return False
    
    async def mark_conversation_as_read(
        self,
        user_id: str,
        other_user_id: str,
        session: AsyncSession
    ) -> int:
        """Mark all messages in a conversation as read."""
        # Get unread messages
        result = await session.execute(
            select(Message).where(
                and_(
                    Message.sender_id == other_user_id,
                    Message.recipient_id == user_id,
                    Message.read_at.is_(None),
                    Message.status != MessageStatus.DELETED
                )
            )
        )
        messages = result.scalars().all()
        
        # Mark as read
        read_count = 0
        for message in messages:
            message.read_at = datetime.utcnow()
            message.status = MessageStatus.READ
            read_count += 1
        
        if read_count > 0:
            await session.commit()
            
            # Send read receipt for the latest message
            if messages:
                latest_message = max(messages, key=lambda m: m.created_at)
                await self._send_read_receipt(latest_message)
        
        return read_count
    
    async def delete_message(
        self,
        message_id: str,
        user_id: str,
        session: AsyncSession,
        delete_for_everyone: bool = False
    ) -> bool:
        """Delete a message."""
        message = await self.get_message_by_id(message_id, user_id, session)
        if not message:
            return False
        
        # Check permissions
        if delete_for_everyone and message.sender_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own messages for everyone"
            )
        
        if delete_for_everyone:
            # Delete for everyone
            message.status = MessageStatus.DELETED
            message.content = "This message was deleted"
            message.media_url = None
            message.caption = None
        else:
            # For now, we'll implement soft delete for everyone
            # In a real app, you might want user-specific deletion
            message.status = MessageStatus.DELETED
        
        message.updated_at = datetime.utcnow()
        await session.commit()
        
        # Send deletion notification
        await self._send_message_deletion_notification(message)
        
        return True
    
    async def search_messages(
        self,
        user_id: str,
        search_params: MessageSearch,
        session: AsyncSession
    ) -> List[MessageRead]:
        """Search messages for a user."""
        query = select(Message).where(
            and_(
                or_(
                    Message.sender_id == user_id,
                    Message.recipient_id == user_id
                ),
                Message.status != MessageStatus.DELETED
            )
        )
        
        # Add search filters
        if search_params.query:
            query = query.where(
                or_(
                    Message.content.ilike(f"%{search_params.query}%"),
                    Message.caption.ilike(f"%{search_params.query}%")
                )
            )
        
        if search_params.content_type:
            query = query.where(Message.content_type == search_params.content_type)
        
        if search_params.sender_id:
            query = query.where(Message.sender_id == search_params.sender_id)
        
        if search_params.start_date:
            query = query.where(Message.created_at >= search_params.start_date)
        
        if search_params.end_date:
            query = query.where(Message.created_at <= search_params.end_date)
        
        # Add ordering and pagination
        query = query.order_by(desc(Message.created_at)).limit(50)
        
        result = await session.execute(query)
        messages = result.scalars().all()
        
        # Convert to MessageRead format (simplified)
        message_reads = []
        for message in messages:
            message_read = MessageRead(
                id=str(message.id),
                sender_id=str(message.sender_id),
                recipient_id=str(message.recipient_id),
                content_type=message.content_type,
                content=message.content,
                media_url=message.media_url,
                caption=message.caption,
                duration=message.duration,
                file_size=message.file_size,
                status=message.status,
                created_at=message.created_at,
                updated_at=message.updated_at,
                delivered_at=message.delivered_at,
                read_at=message.read_at,
                disappears_at=message.disappears_at
            )
            message_reads.append(message_read)
        
        return message_reads
    
    async def get_message_analytics(
        self,
        user_id: str,
        session: AsyncSession,
        days: int = 30
    ) -> MessageAnalytics:
        """Get message analytics for a user."""
        start_date = datetime.utcnow() - timedelta(days=days)
        
        # Messages sent
        messages_sent = await session.scalar(
            select(func.count(Message.id)).where(
                and_(
                    Message.sender_id == user_id,
                    Message.created_at >= start_date
                )
            )
        ) or 0
        
        # Messages received
        messages_received = await session.scalar(
            select(func.count(Message.id)).where(
                and_(
                    Message.recipient_id == user_id,
                    Message.created_at >= start_date
                )
            )
        ) or 0
        
        # Active conversations
        active_conversations = await session.scalar(
            select(func.count(func.distinct(
                func.case(
                    (Message.sender_id == user_id, Message.recipient_id),
                    else_=Message.sender_id
                )
            ))).where(
                and_(
                    or_(
                        Message.sender_id == user_id,
                        Message.recipient_id == user_id
                    ),
                    Message.created_at >= start_date
                )
            )
        ) or 0
        
        return MessageAnalytics(
            user_id=user_id,
            messages_sent=messages_sent,
            messages_received=messages_received,
            total_messages=messages_sent + messages_received,
            active_conversations=active_conversations,
            period_days=days
        )
    
    async def _are_users_friends(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if two users are friends."""
        result = await session.execute(
            select(Friendship).where(
                and_(
                    or_(
                        and_(
                            Friendship.requester_id == user1_id,
                            Friendship.addressee_id == user2_id
                        ),
                        and_(
                            Friendship.requester_id == user2_id,
                            Friendship.addressee_id == user1_id
                        )
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
        )
        return result.scalar_one_or_none() is not None
    
    async def _validate_message_content(self, message_data: MessageCreate):
        """Validate message content based on type."""
        if message_data.content_type == MessageType.TEXT:
            if not message_data.content or len(message_data.content.strip()) == 0:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Text messages must have content"
                )
        
        elif message_data.content_type in [MessageType.IMAGE, MessageType.VIDEO, MessageType.AUDIO]:
            if not message_data.media_url:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"{message_data.content_type.value} messages must have media_url"
                )
    
    async def _send_real_time_notification(self, message: Message, session: AsyncSession):
        """Send real-time notification for new message."""
        # Get recipient info
        recipient = await session.get(User, message.recipient_id)
        sender = await session.get(User, message.sender_id)
        
        if recipient and sender:
            notification_data = {
                "type": "new_message",
                "message_id": str(message.id),
                "sender_id": str(message.sender_id),
                "sender_username": sender.username,
                "sender_display_name": sender.display_name,
                "content_type": message.content_type.value,
                "content": message.content if message.content_type == MessageType.TEXT else None,
                "timestamp": message.created_at.isoformat()
            }
            
            await websocket_manager.send_personal_message(
                str(message.recipient_id),
                notification_data
            )
    
    async def _send_read_receipt(self, message: Message):
        """Send read receipt notification."""
        notification_data = {
            "type": "message_read",
            "message_id": str(message.id),
            "read_at": message.read_at.isoformat() if message.read_at else None
        }
        
        await websocket_manager.send_personal_message(
            str(message.sender_id),
            notification_data
        )
    
    async def _send_message_deletion_notification(self, message: Message):
        """Send message deletion notification."""
        notification_data = {
            "type": "message_deleted",
            "message_id": str(message.id)
        }
        
        # Notify both sender and recipient
        await self.connection_manager.send_personal_message(
            str(message.sender_id),
            notification_data
        )
        await self.connection_manager.send_personal_message(
            str(message.recipient_id),
            notification_data
        )


# Global message service instance
message_service = MessageService()


# Convenience functions for backward compatibility
async def create_message(
    sender_id: str,
    message_data: MessageCreate,
    session: AsyncSession
) -> Optional[Message]:
    """Create a new message."""
    return await message_service.send_message(sender_id, message_data, session)


async def get_conversation_messages(
    user_id: str,
    other_user_id: str,
    session: AsyncSession,
    limit: int = 50,
    offset: int = 0
) -> List[MessageRead]:
    """Get messages in a conversation."""
    return await message_service.get_conversation_messages(
        user_id, other_user_id, session, limit, offset
    )


async def get_user_conversations(
    user_id: str,
    session: AsyncSession
) -> List[MessageThread]:
    """Get user's conversations."""
    return await message_service.get_user_conversations(user_id, session)


async def mark_message_as_read(
    message_id: str,
    user_id: str,
    session: AsyncSession
) -> bool:
    """Mark a message as read."""
    return await message_service.mark_message_as_read(message_id, user_id, session)


async def delete_message(
    message_id: str,
    user_id: str,
    session: AsyncSession
) -> bool:
    """Delete a message."""
    return await message_service.delete_message(message_id, user_id, session)


async def get_message_by_id(
    message_id: str,
    user_id: str,
    session: AsyncSession
) -> Optional[MessageRead]:
    """Get a message by ID."""
    return await message_service.get_message_by_id(message_id, user_id, session)


async def get_message_service() -> MessageService:
    """Get message service dependency."""
    return message_service