"""WebSocket endpoints.

This module provides WebSocket endpoints for real-time communication,
including messaging, typing indicators, and live updates.
"""

import json
from typing import Dict, Any
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.websocket import websocket_manager as manager
from app.services.auth_service import get_current_user_from_token
from app.services.message_service import create_message
from app.services.friendship_service import check_friendship_status
from app.schemas.message import MessageCreate
from app.schemas.message import MessageType

router = APIRouter()


@router.websocket("/connect/{token}")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str,
    db: AsyncSession = Depends(get_db)
):
    """WebSocket connection endpoint for real-time communication.
    
    Args:
        websocket: WebSocket connection
        token: Authentication token
        db: Database session
        
    Note: This endpoint handles real-time messaging, typing indicators,
    and other live updates between users.
    """
    # Authenticate user
    try:
        user = await get_current_user_from_token(token, db)
        if not user:
            await websocket.close(code=4001, reason="Invalid token")
            return
    except Exception:
        await websocket.close(code=4001, reason="Authentication failed")
        return
    
    # Accept connection and add to manager
    await websocket.accept()
    await manager.connect(websocket, str(user.id))
    
    try:
        # Send connection confirmation
        await manager.send_personal_message(
            {
                "type": "connection_established",
                "user_id": str(user.id),
                "message": "Connected successfully"
            },
            str(user.id)
        )
        
        # Listen for messages
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            
            try:
                message_data = json.loads(data)
                await handle_websocket_message(message_data, user.id, db)
            except json.JSONDecodeError:
                await manager.send_personal_message(
                    {
                        "type": "error",
                        "message": "Invalid JSON format"
                    },
                    str(user.id)
                )
            except Exception as e:
                await manager.send_personal_message(
                    {
                        "type": "error",
                        "message": f"Error processing message: {str(e)}"
                    },
                    str(user.id)
                )
    
    except WebSocketDisconnect:
        # Handle disconnection
        await manager.disconnect(str(user.id))
        print(f"User {user.username} disconnected")
    
    except Exception as e:
        # Handle other errors
        print(f"WebSocket error for user {user.username}: {str(e)}")
        await manager.disconnect(str(user.id))


async def handle_websocket_message(
    message_data: Dict[str, Any],
    user_id: str,
    db: AsyncSession
):
    """Handle incoming WebSocket messages.
    
    Args:
        message_data: Parsed message data from client
        user_id: ID of the user sending the message
        db: Database session
    """
    message_type = message_data.get("type")
    
    if message_type == "send_message":
        await handle_send_message(message_data, user_id, db)
    
    elif message_type == "typing_start":
        await handle_typing_indicator(message_data, user_id, True)
    
    elif message_type == "typing_stop":
        await handle_typing_indicator(message_data, user_id, False)
    
    elif message_type == "message_read":
        await handle_message_read(message_data, user_id, db)
    
    elif message_type == "ping":
        await handle_ping(user_id)
    
    else:
        await manager.send_personal_message(
            {
                "type": "error",
                "message": f"Unknown message type: {message_type}"
            },
            user_id
        )


async def handle_send_message(
    message_data: Dict[str, Any],
    sender_id: str,
    db: AsyncSession
):
    """Handle sending a message through WebSocket.
    
    Args:
        message_data: Message data from client
        sender_id: ID of the user sending the message
        db: Database session
    """
    try:
        recipient_id = message_data.get("recipient_id")
        content = message_data.get("content")
        
        if not recipient_id or not content:
            await manager.send_personal_message(
                {
                    "type": "error",
                    "message": "Missing recipient_id or content"
                },
                sender_id
            )
            return
        
        # Check if users are friends
        friendship_status = await check_friendship_status(db, sender_id, recipient_id)
        if friendship_status != "accepted":
            await manager.send_personal_message(
                {
                    "type": "error",
                    "message": "Can only send messages to friends"
                },
                sender_id
            )
            return
        
        # Create message in database
        message_create = MessageCreate(
            recipient_id=recipient_id,
            content_type=MessageType.TEXT,
            content=content,
            disappears_at=message_data.get("disappears_at")
        )
        
        message = await create_message(db, sender_id, message_create)
        
        # Send message to recipient if online
        await manager.send_personal_message(
            {
                "type": "new_message",
                "message": message.to_dict()
            },
            recipient_id
        )
        
        # Send confirmation to sender
        await manager.send_personal_message(
            {
                "type": "message_sent",
                "message": message.to_dict()
            },
            sender_id
        )
    
    except Exception as e:
        await manager.send_personal_message(
            {
                "type": "error",
                "message": f"Failed to send message: {str(e)}"
            },
            sender_id
        )


async def handle_typing_indicator(
    message_data: Dict[str, Any],
    user_id: str,
    is_typing: bool
):
    """Handle typing indicators.
    
    Args:
        message_data: Message data from client
        user_id: ID of the user typing
        is_typing: Whether user is typing or stopped typing
    """
    recipient_id = message_data.get("recipient_id")
    
    if not recipient_id:
        await manager.send_personal_message(
            {
                "type": "error",
                "message": "Missing recipient_id for typing indicator"
            },
            user_id
        )
        return
    
    # Send typing indicator to recipient
    await manager.send_personal_message(
        {
            "type": "typing_indicator",
            "user_id": user_id,
            "is_typing": is_typing
        },
        recipient_id
    )


async def handle_message_read(
    message_data: Dict[str, Any],
    user_id: str,
    db: AsyncSession
):
    """Handle message read receipts.
    
    Args:
        message_data: Message data from client
        user_id: ID of the user who read the message
        db: Database session
    """
    message_id = message_data.get("message_id")
    
    if not message_id:
        await manager.send_personal_message(
            {
                "type": "error",
                "message": "Missing message_id for read receipt"
            },
            user_id
        )
        return
    
    # TODO: Update message read status in database
    # For now, just send read receipt to sender
    sender_id = message_data.get("sender_id")
    if sender_id:
        await manager.send_personal_message(
            {
                "type": "message_read",
                "message_id": message_id,
                "read_by": user_id
            },
            sender_id
        )


async def handle_ping(user_id: str):
    """Handle ping messages for connection health check.
    
    Args:
        user_id: ID of the user sending ping
    """
    await manager.send_personal_message(
        {
            "type": "pong",
            "timestamp": manager.get_current_timestamp()
        },
        user_id
    )


@router.get("/active-users")
async def get_active_users():
    """Get list of currently active users.
    
    Returns:
        dict: List of active user IDs
        
    Note: This endpoint is for debugging/monitoring purposes.
    In production, you might want to restrict access.
    """
    active_users = list(manager.active_connections.keys())
    return {
        "active_users": active_users,
        "total_connections": len(active_users)
    }


@router.post("/broadcast")
async def broadcast_message(
    message: str,
    user_ids: list = None
):
    """Broadcast a message to specific users or all connected users.
    
    Args:
        message: Message to broadcast
        user_ids: Optional list of user IDs to send to (if None, sends to all)
        
    Returns:
        dict: Success message
        
    Note: This endpoint is for admin/system messages.
    In production, you'd want proper authentication and authorization.
    """
    broadcast_data = {
        "type": "system_message",
        "message": message,
        "timestamp": manager.get_current_timestamp()
    }
    
    if user_ids:
        # Send to specific users
        for user_id in user_ids:
            await manager.send_personal_message(broadcast_data, user_id)
    else:
        # Send to all connected users
        await manager.broadcast(broadcast_data)
    
    return {"message": "Broadcast sent successfully"}