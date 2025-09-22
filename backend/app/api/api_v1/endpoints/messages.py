"""Message endpoints.

This module provides endpoints for sending, receiving, and managing
messages in the real-time messaging system.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.message import MessageCreate, MessageRead, MessageUpdate
from app.api.api_v1.endpoints.auth import get_current_user
from app.services.message_service import (
    create_message,
    get_conversation_messages,
    get_user_conversations,
    mark_message_as_read,
    delete_message,
    get_message_by_id
)
from app.services.friendship_service import check_friendship_status
from app.services.file_service import upload_media_file
from app.models.user import User
from app.schemas.message import MessageType

router = APIRouter()


@router.post("/", response_model=MessageRead, status_code=status.HTTP_201_CREATED)
async def send_message(
    message_data: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Send a new message.
    
    Args:
        message_data: Message creation data
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        MessageRead: Created message
        
    Raises:
        HTTPException: If recipient not found or not friends
    """
    # Check if users are friends (required for messaging)
    friendship_status = await check_friendship_status(db, current_user.id, message_data.recipient_id)
    if friendship_status != "accepted":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only send messages to friends"
        )
    
    # Create message
    message = await create_message(db, current_user.id, message_data)
    return MessageRead.from_orm(message)


@router.post("/media", response_model=MessageRead, status_code=status.HTTP_201_CREATED)
async def send_media_message(
    recipient_id: str,
    file: UploadFile = File(...),
    caption: Optional[str] = None,
    disappears_at: Optional[int] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Send a media message (image, video, audio).
    
    Args:
        recipient_id: ID of the message recipient
        file: Media file to upload
        caption: Optional caption for the media
        disappears_at: Optional timestamp when message should disappear
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        MessageRead: Created message with media
        
    Raises:
        HTTPException: If file upload fails or users not friends
    """
    # Check if users are friends
    friendship_status = await check_friendship_status(db, current_user.id, recipient_id)
    if friendship_status != "accepted":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only send messages to friends"
        )
    
    # Upload media file
    try:
        media_url, file_size, duration = await upload_media_file(file)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to upload media: {str(e)}"
        )
    
    # Determine message type based on file type
    content_type = file.content_type or ""
    if content_type.startswith("image/"):
        message_type = MessageType.IMAGE
    elif content_type.startswith("video/"):
        message_type = MessageType.VIDEO
    elif content_type.startswith("audio/"):
        message_type = MessageType.AUDIO
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported media type"
        )
    
    # Create message data
    message_data = MessageCreate(
        recipient_id=recipient_id,
        content_type=message_type,
        media_url=media_url,
        caption=caption,
        file_size=file_size,
        duration=duration,
        disappears_at=disappears_at
    )
    
    # Create message
    message = await create_message(db, current_user.id, message_data)
    return MessageRead.from_orm(message)


@router.get("/conversations", response_model=List[dict])
async def get_conversations(
    limit: int = Query(20, ge=1, le=50),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's conversations with latest message preview.
    
    Args:
        limit: Maximum number of conversations to return
        offset: Number of conversations to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[dict]: List of conversations with latest messages
    """
    conversations = await get_user_conversations(db, current_user.id, limit, offset)
    return conversations


@router.get("/conversation/{user_id}", response_model=List[MessageRead])
async def get_conversation(
    user_id: str,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get messages in a conversation with another user.
    
    Args:
        user_id: ID of the other user in the conversation
        limit: Maximum number of messages to return
        offset: Number of messages to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[MessageRead]: List of messages in the conversation
        
    Raises:
        HTTPException: If users are not friends
    """
    # Check if users are friends
    friendship_status = await check_friendship_status(db, current_user.id, user_id)
    if friendship_status != "accepted":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only view conversations with friends"
        )
    
    messages = await get_conversation_messages(db, current_user.id, user_id, limit, offset)
    return [MessageRead.from_orm(message) for message in messages]


@router.put("/{message_id}/read")
async def mark_as_read(
    message_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Mark a message as read.
    
    Args:
        message_id: ID of the message to mark as read
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If message not found or unauthorized
    """
    message = await get_message_by_id(db, message_id)
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Check if current user is the recipient
    if str(message.recipient_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only mark own messages as read"
        )
    
    await mark_message_as_read(db, message_id)
    return {"message": "Message marked as read"}


@router.delete("/{message_id}")
async def delete_message_endpoint(
    message_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a message.
    
    Args:
        message_id: ID of the message to delete
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        dict: Success message
        
    Raises:
        HTTPException: If message not found or unauthorized
    """
    message = await get_message_by_id(db, message_id)
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Check if current user is the sender
    if str(message.sender_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only delete own messages"
        )
    
    await delete_message(db, message_id)
    return {"message": "Message deleted successfully"}


@router.get("/{message_id}", response_model=MessageRead)
async def get_message(
    message_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get a specific message by ID.
    
    Args:
        message_id: ID of the message to retrieve
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        MessageRead: Message data
        
    Raises:
        HTTPException: If message not found or unauthorized
    """
    message = await get_message_by_id(db, message_id)
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Check if current user is sender or recipient
    if str(current_user.id) not in [str(message.sender_id), str(message.recipient_id)]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this message"
        )
    
    return MessageRead.from_orm(message)


@router.get("/search/{query}")
async def search_messages(
    query: str,
    limit: int = Query(20, ge=1, le=50),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Search messages by content.
    
    Args:
        query: Search query string
        limit: Maximum number of results to return
        offset: Number of results to skip
        current_user: Current authenticated user
        db: Database session
        
    Returns:
        List[MessageRead]: List of matching messages
        
    Note: This is a basic implementation. In production,
    you might want to use full-text search capabilities.
    """
    # TODO: Implement message search functionality
    return []