"""Authentication service.

This module provides authentication and user management services
using FastAPI-Users and custom business logic.
"""

import uuid
from typing import Optional, Dict, Any, AsyncGenerator, List
from datetime import datetime, timedelta
from fastapi import Depends, HTTPException, status
from fastapi_users import BaseUserManager, UUIDIDMixin
from fastapi_users.db import SQLAlchemyUserDatabase
from fastapi_users.password import PasswordHelper
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from jose import JWTError, jwt
from passlib.context import CryptContext
import redis.asyncio as redis
import secrets
import json

from app.core.config import settings
from app.core.database import AsyncSessionLocal
from app.models.user import User
from app.models.user_plant import UserPlant
from app.schemas.auth import UserCreate, UserUpdate


class UserManager(UUIDIDMixin, BaseUserManager[User, uuid.UUID]):
    """Custom user manager for handling user operations."""
    
    reset_password_token_secret = settings.SECRET_KEY
    verification_token_secret = settings.SECRET_KEY
    
    async def on_after_register(self, user: User, request: Optional[Any] = None):
        """Called after user registration."""
        print(f"User {user.id} has registered.")
        # Here you can add logic like sending welcome email,
        # creating default user preferences, etc.
    
    async def on_after_login(
        self,
        user: User,
        request: Optional[Any] = None,
        response: Optional[Any] = None,
    ):
        """Called after user login."""
        print(f"User {user.id} logged in.")
        # Update last login timestamp
        user.last_login = datetime.utcnow()
        # Note: You'll need to commit this change in the calling code
    
    async def on_after_update(
        self,
        user: User,
        update_dict: Dict[str, Any],
        request: Optional[Any] = None,
    ):
        """Called after user update."""
        print(f"User {user.id} has been updated with {update_dict}.")
    
    async def on_after_request_verify(
        self, user: User, token: str, request: Optional[Any] = None
    ):
        """Called after verification request."""
        print(f"Verification requested for user {user.id}. Token: {token}")
        # Here you would send verification email
    
    async def on_after_verify(
        self, user: User, request: Optional[Any] = None
    ):
        """Called after user verification."""
        print(f"User {user.id} has been verified")
    
    async def validate_password(
        self,
        password: str,
        user: UserCreate | User,
    ) -> None:
        """Validate password strength."""
        if len(password) < 8:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must be at least 8 characters long"
            )
        
        # Check for at least one uppercase letter
        if not any(c.isupper() for c in password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must contain at least one uppercase letter"
            )
        
        # Check for at least one lowercase letter
        if not any(c.islower() for c in password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must contain at least one lowercase letter"
            )
        
        # Check for at least one digit
        if not any(c.isdigit() for c in password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must contain at least one digit"
            )
        
        # Check if password contains user's email or username
        if hasattr(user, 'email') and user.email:
            if user.email.lower() in password.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Password cannot contain your email address"
                )
        
        if hasattr(user, 'username') and user.username:
            if user.username.lower() in password.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Password cannot contain your username"
                )


async def get_user_db() -> AsyncGenerator[SQLAlchemyUserDatabase, None]:
    """Get user database dependency."""
    async with AsyncSessionLocal() as session:
        yield SQLAlchemyUserDatabase(session, User)


async def get_user_manager(user_db: SQLAlchemyUserDatabase = Depends(get_user_db)):
    """Get user manager dependency."""
    yield UserManager(user_db)


class AuthService:
    """Authentication and authorization service with comprehensive role-based access control."""
    
    def __init__(self):
        """Initialize the authentication service."""
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        self.redis_client = None
    
    async def get_redis_client(self):
        """Get Redis client for session management."""
        if not self.redis_client:
            self.redis_client = redis.from_url(
                settings.REDIS_URL,
                encoding="utf-8",
                decode_responses=True
            )
        return self.redis_client
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash."""
        return self.pwd_context.verify(plain_password, hashed_password)
    
    def get_password_hash(self, password: str) -> str:
        """Hash a password."""
        return self.pwd_context.hash(password)
    
    def create_access_token(
        self, 
        data: dict, 
        expires_delta: Optional[timedelta] = None
    ) -> str:
        """Create JWT access token."""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.SECRET_KEY, 
            algorithm=settings.ALGORITHM
        )
        return encoded_jwt
    
    def create_refresh_token(
        self, 
        data: dict, 
        expires_delta: Optional[timedelta] = None
    ) -> str:
        """Create JWT refresh token."""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(days=7)  # Refresh tokens last 7 days
        
        to_encode.update({"exp": expire, "type": "refresh"})
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.SECRET_KEY, 
            algorithm=settings.ALGORITHM
        )
        return encoded_jwt
    
    async def verify_token(self, token: str) -> Optional[dict]:
        """Verify and decode JWT token."""
        try:
            payload = jwt.decode(
                token, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM]
            )
            return payload
        except JWTError:
            return None
    
    async def store_refresh_token(
        self, 
        user_id: str, 
        refresh_token: str, 
        expires_in: int = 7 * 24 * 60 * 60  # 7 days in seconds
    ):
        """Store refresh token in Redis."""
        redis_client = await self.get_redis_client()
        key = f"refresh_token:{user_id}"
        await redis_client.setex(key, expires_in, refresh_token)
    
    async def get_stored_refresh_token(self, user_id: str) -> Optional[str]:
        """Get stored refresh token from Redis."""
        redis_client = await self.get_redis_client()
        key = f"refresh_token:{user_id}"
        return await redis_client.get(key)
    
    async def revoke_refresh_token(self, user_id: str):
        """Revoke refresh token by deleting from Redis."""
        redis_client = await self.get_redis_client()
        key = f"refresh_token:{user_id}"
        await redis_client.delete(key)
    
    async def store_user_session(
        self, 
        user_id: str, 
        session_data: dict, 
        expires_in: int = 24 * 60 * 60  # 24 hours
    ):
        """Store user session data in Redis."""
        redis_client = await self.get_redis_client()
        key = f"user_session:{user_id}"
        await redis_client.setex(key, expires_in, str(session_data))
    
    async def get_user_session(self, user_id: str) -> Optional[dict]:
        """Get user session data from Redis."""
        redis_client = await self.get_redis_client()
        key = f"user_session:{user_id}"
        session_data = await redis_client.get(key)
        if session_data:
            try:
                return eval(session_data)  # Note: In production, use json.loads
            except:
                return None
        return None
    
    async def revoke_user_session(self, user_id: str):
        """Revoke user session."""
        redis_client = await self.get_redis_client()
        key = f"user_session:{user_id}"
        await redis_client.delete(key)
    
    async def is_user_online(self, user_id: str) -> bool:
        """Check if user is currently online."""
        redis_client = await self.get_redis_client()
        key = f"user_online:{user_id}"
        return await redis_client.exists(key) > 0
    
    async def set_user_online(
        self, 
        user_id: str, 
        expires_in: int = 5 * 60  # 5 minutes
    ):
        """Mark user as online."""
        redis_client = await self.get_redis_client()
        key = f"user_online:{user_id}"
        await redis_client.setex(key, expires_in, "1")
    
    async def set_user_offline(self, user_id: str):
        """Mark user as offline."""
        redis_client = await self.get_redis_client()
        key = f"user_online:{user_id}"
        await redis_client.delete(key)
    
    async def get_user_by_email(
        self, 
        email: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get user by email address."""
        result = await session.execute(
            select(User).where(User.email == email)
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
    
    async def check_username_availability(
        self, 
        username: str, 
        session: AsyncSession,
        exclude_user_id: Optional[str] = None
    ) -> bool:
        """Check if username is available."""
        query = select(User).where(User.username == username)
        if exclude_user_id:
            query = query.where(User.id != exclude_user_id)
        
        result = await session.execute(query)
        return result.scalar_one_or_none() is None
    
    async def check_email_availability(
        self, 
        email: str, 
        session: AsyncSession,
        exclude_user_id: Optional[str] = None
    ) -> bool:
        """Check if email is available."""
        query = select(User).where(User.email == email)
        if exclude_user_id:
            query = query.where(User.id != exclude_user_id)
        
        result = await session.execute(query)
        return result.scalar_one_or_none() is None
    
    async def update_last_active(
        self, 
        user_id: str, 
        session: AsyncSession
    ):
        """Update user's last active timestamp."""
        result = await session.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        if user:
            user.last_active = datetime.utcnow()
            await session.commit()
    
    async def authenticate_user(
        self, 
        username: str, 
        password: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Authenticate user with username/email and password."""
        # Try to find user by username or email
        user = await self.get_user_by_username(username, session)
        if not user:
            user = await self.get_user_by_email(username, session)
        
        if not user:
            return None
        
        if not self.verify_password(password, user.hashed_password):
            return None
        
        return user
    
    async def get_current_user(
        self, 
        token: str, 
        session: AsyncSession
    ) -> Optional[User]:
        """Get current user from JWT token."""
        payload = await self.verify_token(token)
        if not payload:
            return None
        
        user_id = payload.get("sub")
        if not user_id:
            return None
        
        result = await session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def verify_refresh_token(
        self, 
        token: str
    ) -> Optional[dict]:
        """Verify refresh token and return payload."""
        payload = await self.verify_token(token)
        if not payload or payload.get("type") != "refresh":
            return None
        return payload
    
    async def get_current_user_from_token(self, token: str, session: AsyncSession) -> Optional[User]:
        """Get current user from token without Bearer prefix."""
        return await self.get_current_user(token, session)
    
    async def close(self):
        """Close Redis connection."""
        if self.redis_client:
            await self.redis_client.close()

    # Authorization and Role-Based Access Control Methods
    
    @staticmethod
    def check_admin_permission(user: User, required_permission: Optional[str] = None) -> bool:
        """Check if user has admin permissions.
        
        Args:
            user: User to check
            required_permission: Specific permission required (optional)
            
        Returns:
            True if user has admin access, False otherwise
            
        Raises:
            HTTPException: If user lacks admin permissions
        """
        if not user.is_admin:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Admin privileges required"
            )
        
        # Check specific permission if required
        if required_permission and user.admin_permissions:
            try:
                permissions = json.loads(user.admin_permissions)
                if required_permission not in permissions and "all" not in permissions:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Admin permission '{required_permission}' required"
                    )
            except (json.JSONDecodeError, TypeError):
                # If permissions can't be parsed, allow only super admin
                if not user.is_superuser:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Admin permission '{required_permission}' required"
                    )
        
        return True
    
    @staticmethod
    def check_expert_permission(
        user: User, 
        required_specialty: Optional[str] = None
    ) -> bool:
        """Check if user has expert permissions.
        
        Args:
            user: User to check
            required_specialty: Specific plant specialty required (optional)
            
        Returns:
            True if user has expert access, False otherwise
            
        Raises:
            HTTPException: If user lacks expert permissions
        """
        if not (user.is_expert or user.is_admin):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Expert or admin privileges required"
            )
        
        # Admins can bypass specialty checks
        if user.is_admin:
            return True
        
        # Check specific specialty if required
        if required_specialty and user.expert_specialties:
            try:
                specialties = json.loads(user.expert_specialties)
                if required_specialty not in specialties and "all_plants" not in specialties:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Expert specialty in '{required_specialty}' required"
                    )
            except (json.JSONDecodeError, TypeError):
                # If specialties can't be parsed, check if they're a general expert
                pass
        
        return True
    
    @staticmethod
    def check_moderator_permission(user: User) -> bool:
        """Check if user has moderator permissions.
        
        Args:
            user: User to check
            
        Returns:
            True if user has moderator access, False otherwise
            
        Raises:
            HTTPException: If user lacks moderator permissions
        """
        if not (user.is_moderator or user.is_admin):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Moderator or admin privileges required"
            )
        
        return True
    
    @staticmethod
    async def check_plant_ownership(
        db: AsyncSession,
        plant_id: uuid.UUID,
        user_id: uuid.UUID
    ) -> bool:
        """Check if user owns the specified plant.
        
        Args:
            db: Database session
            plant_id: Plant ID to check
            user_id: User ID to verify ownership
            
        Returns:
            True if user owns the plant, False otherwise
            
        Raises:
            HTTPException: If plant not found or user doesn't own it
        """
        result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id,
                    UserPlant.is_active == True
                )
            )
        )
        plant = result.scalar_one_or_none()
        
        if not plant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or you don't have permission to access it"
            )
        
        return True
    
    @staticmethod
    async def verify_plant_ownership_or_admin(
        db: AsyncSession,
        plant_id: uuid.UUID,
        user: User
    ) -> bool:
        """Check if user owns the plant or has admin privileges.
        
        Args:
            db: Database session
            plant_id: Plant ID to check
            user: User to verify
            
        Returns:
            True if user owns plant or is admin, False otherwise
            
        Raises:
            HTTPException: If unauthorized access
        """
        # Admins can access any plant
        if user.is_admin:
            return True
        
        # Check plant ownership
        return await AuthService.check_plant_ownership(db, plant_id, user.id)
    
    @staticmethod
    def check_privacy_permissions(
        target_user: User,
        requesting_user: User,
        resource_type: str = "profile"
    ) -> bool:
        """Check privacy permissions for accessing user resources.
        
        Args:
            target_user: User whose resource is being accessed
            requesting_user: User making the request
            resource_type: Type of resource being accessed
            
        Returns:
            True if access is allowed, False otherwise
            
        Raises:
            HTTPException: If access is denied
        """
        # Users can always access their own resources
        if target_user.id == requesting_user.id:
            return True
        
        # Admins can access any resource
        if requesting_user.is_admin:
            return True
        
        # Check privacy settings
        if target_user.is_private:
            # For private users, check if they're friends (simplified for now)
            # In a full implementation, you'd check friendship status
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"User's {resource_type} is private"
            )
        
        # Check specific resource permissions
        if resource_type == "plant_identification" and not target_user.allow_plant_identification:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User doesn't allow plant identification requests"
            )
        
        return True
    
    @staticmethod
    def get_user_permissions_summary(user: User) -> Dict[str, Any]:
        """Get a summary of user's permissions and roles.
        
        Args:
            user: User to analyze
            
        Returns:
            Dictionary containing user's permission summary
        """
        permissions_summary = {
            "user_id": str(user.id),
            "is_admin": user.is_admin,
            "is_expert": user.is_expert,
            "is_moderator": user.is_moderator,
            "is_superuser": getattr(user, 'is_superuser', False),
            "admin_permissions": [],
            "expert_specialties": [],
            "privacy_settings": {
                "is_private": user.is_private,
                "allow_plant_identification": user.allow_plant_identification,
                "allow_friend_requests": user.allow_friend_requests,
            }
        }
        
        # Parse admin permissions
        if user.admin_permissions:
            try:
                permissions_summary["admin_permissions"] = json.loads(user.admin_permissions)
            except (json.JSONDecodeError, TypeError):
                permissions_summary["admin_permissions"] = []
        
        # Parse expert specialties
        if user.expert_specialties:
            try:
                permissions_summary["expert_specialties"] = json.loads(user.expert_specialties)
            except (json.JSONDecodeError, TypeError):
                permissions_summary["expert_specialties"] = []
        
        return permissions_summary
    
    @staticmethod
    async def grant_role(
        db: AsyncSession,
        user_id: uuid.UUID,
        role: str,
        permissions: Optional[List[str]] = None,
        granted_by_user_id: Optional[uuid.UUID] = None
    ) -> bool:
        """Grant a role to a user (admin only operation).
        
        Args:
            db: Database session
            user_id: User to grant role to
            role: Role to grant (admin, expert, moderator)
            permissions: Optional specific permissions for the role
            granted_by_user_id: ID of user granting the role
            
        Returns:
            True if role granted successfully
            
        Raises:
            HTTPException: If operation fails
        """
        # Get the user
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Grant the role
        if role == "admin":
            user.is_admin = True
            if permissions:
                user.admin_permissions = json.dumps(permissions)
        elif role == "expert":
            user.is_expert = True
            if permissions:
                user.expert_specialties = json.dumps(permissions)
        elif role == "moderator":
            user.is_moderator = True
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid role specified"
            )
        
        user.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(user)
        
        return True
    
    @staticmethod
    async def revoke_role(
        db: AsyncSession,
        user_id: uuid.UUID,
        role: str,
        revoked_by_user_id: Optional[uuid.UUID] = None
    ) -> bool:
        """Revoke a role from a user (admin only operation).
        
        Args:
            db: Database session
            user_id: User to revoke role from
            role: Role to revoke (admin, expert, moderator)
            revoked_by_user_id: ID of user revoking the role
            
        Returns:
            True if role revoked successfully
            
        Raises:
            HTTPException: If operation fails
        """
        # Get the user
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Revoke the role
        if role == "admin":
            user.is_admin = False
            user.admin_permissions = None
        elif role == "expert":
            user.is_expert = False
            user.expert_specialties = None
        elif role == "moderator":
            user.is_moderator = False
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid role specified"
            )
        
        user.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(user)
        
        return True


# Global auth service instance
auth_service = AuthService()


async def get_auth_service() -> AuthService:
    """Get auth service dependency."""
    return auth_service


async def get_current_user_from_token(token: str, session: AsyncSession) -> Optional[User]:
    """Get current user from token without Bearer prefix."""
    return await auth_service.get_current_user_from_token(token, session)