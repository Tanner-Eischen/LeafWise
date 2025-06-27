"""WebSocket connection manager for real-time messaging.

This module handles WebSocket connections, message broadcasting,
and real-time communication between users.
"""

import json
import logging
from typing import Dict, List, Optional
from uuid import UUID

from fastapi import WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import AsyncSessionLocal
from app.models.user import User
from app.services.auth_service import get_current_user_from_token

logger = logging.getLogger(__name__)


class ConnectionManager:
    """Manages WebSocket connections for real-time messaging."""
    
    def __init__(self):
        # Store active connections: {user_id: websocket}
        self.active_connections: Dict[str, WebSocket] = {}
        # Store user sessions: {websocket: user_id}
        self.user_sessions: Dict[WebSocket, str] = {}
    
    async def connect(self, websocket: WebSocket, user_id: str) -> bool:
        """Accept a WebSocket connection and register the user.
        
        Args:
            websocket: The WebSocket connection
            user_id: The authenticated user's ID
            
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            await websocket.accept()
            
            # Disconnect existing connection for this user if any
            if user_id in self.active_connections:
                old_websocket = self.active_connections[user_id]
                await self.disconnect(old_websocket)
            
            # Register new connection
            self.active_connections[user_id] = websocket
            self.user_sessions[websocket] = user_id
            
            logger.info(f"User {user_id} connected via WebSocket")
            
            # Send connection confirmation
            await self.send_personal_message(
                {
                    "type": "connection_established",
                    "message": "Connected successfully",
                    "user_id": user_id
                },
                websocket
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Error connecting user {user_id}: {e}")
            return False
    
    async def disconnect(self, websocket: WebSocket) -> None:
        """Disconnect a WebSocket and clean up.
        
        Args:
            websocket: The WebSocket connection to disconnect
        """
        try:
            user_id = self.user_sessions.get(websocket)
            
            if user_id:
                # Remove from active connections
                self.active_connections.pop(user_id, None)
                self.user_sessions.pop(websocket, None)
                
                logger.info(f"User {user_id} disconnected from WebSocket")
            
            # Close the connection
            await websocket.close()
            
        except Exception as e:
            logger.error(f"Error disconnecting WebSocket: {e}")
    
    async def send_personal_message(self, message: dict, websocket: WebSocket) -> bool:
        """Send a message to a specific WebSocket connection.
        
        Args:
            message: The message data to send
            websocket: The target WebSocket connection
            
        Returns:
            bool: True if message sent successfully, False otherwise
        """
        try:
            await websocket.send_text(json.dumps(message))
            return True
        except Exception as e:
            logger.error(f"Error sending message: {e}")
            # Connection might be broken, clean it up
            await self.disconnect(websocket)
            return False
    
    async def send_message_to_user(self, message: dict, user_id: str) -> bool:
        """Send a message to a specific user by user ID.
        
        Args:
            message: The message data to send
            user_id: The target user's ID
            
        Returns:
            bool: True if message sent successfully, False otherwise
        """
        websocket = self.active_connections.get(user_id)
        if websocket:
            return await self.send_personal_message(message, websocket)
        return False
    
    async def broadcast_to_users(self, message: dict, user_ids: List[str]) -> int:
        """Broadcast a message to multiple users.
        
        Args:
            message: The message data to send
            user_ids: List of user IDs to send the message to
            
        Returns:
            int: Number of users who received the message
        """
        sent_count = 0
        for user_id in user_ids:
            if await self.send_message_to_user(message, user_id):
                sent_count += 1
        return sent_count
    
    def get_connected_users(self) -> List[str]:
        """Get list of currently connected user IDs.
        
        Returns:
            List[str]: List of connected user IDs
        """
        return list(self.active_connections.keys())
    
    def is_user_connected(self, user_id: str) -> bool:
        """Check if a user is currently connected.
        
        Args:
            user_id: The user ID to check
            
        Returns:
            bool: True if user is connected, False otherwise
        """
        return user_id in self.active_connections
    
    async def handle_message(self, websocket: WebSocket, data: str) -> None:
        """Handle incoming WebSocket message.
        
        Args:
            websocket: The WebSocket connection
            data: The raw message data
        """
        try:
            message = json.loads(data)
            user_id = self.user_sessions.get(websocket)
            
            if not user_id:
                await self.send_personal_message(
                    {"type": "error", "message": "User not authenticated"},
                    websocket
                )
                return
            
            message_type = message.get("type")
            
            if message_type == "ping":
                await self.send_personal_message(
                    {"type": "pong", "timestamp": message.get("timestamp")},
                    websocket
                )
            elif message_type == "typing":
                # Handle typing indicators
                recipient_id = message.get("recipient_id")
                if recipient_id:
                    await self.send_message_to_user(
                        {
                            "type": "typing",
                            "sender_id": user_id,
                            "is_typing": message.get("is_typing", False)
                        },
                        recipient_id
                    )
            else:
                logger.warning(f"Unknown message type: {message_type}")
                
        except json.JSONDecodeError:
            await self.send_personal_message(
                {"type": "error", "message": "Invalid JSON format"},
                websocket
            )
        except Exception as e:
            logger.error(f"Error handling message: {e}")
            await self.send_personal_message(
                {"type": "error", "message": "Internal server error"},
                websocket
            )


# Global connection manager instance
websocket_manager = ConnectionManager()