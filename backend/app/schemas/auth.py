"""Authentication schemas.

This module defines Pydantic schemas for authentication-related
data validation and serialization.
"""

from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema with common fields."""
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=30, pattern=r"^[a-zA-Z0-9_]+$")
    display_name: str = Field(..., min_length=1, max_length=50)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None
    
    # Plant-specific fields
    gardening_experience: Optional[str] = Field(None, pattern=r"^(beginner|intermediate|advanced|expert)$")
    favorite_plants: Optional[str] = Field(None, max_length=200)
    location: Optional[str] = Field(None, max_length=100)
    
    # Privacy settings
    is_private: bool = False
    show_location: bool = True
    allow_plant_id_requests: bool = True


class UserCreate(UserBase):
    """Schema for user registration."""
    password: str = Field(..., min_length=8, max_length=100)
    confirm_password: str = Field(..., min_length=8, max_length=100)
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'password' in info.data and v != info.data['password']:
            raise ValueError('Passwords do not match')
        return v
    
    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v):
        if not v.replace('_', '').isalnum():
            raise ValueError('Username must contain only letters, numbers, and underscores')
        return v.lower()
    
    @field_validator('email')
    @classmethod
    def email_lowercase(cls, v):
        return v.lower()


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    display_name: Optional[str] = Field(None, min_length=1, max_length=50)
    bio: Optional[str] = Field(None, max_length=500)
    avatar_url: Optional[str] = None
    
    # Plant-specific fields
    gardening_experience: Optional[str] = Field(None, pattern=r"^(beginner|intermediate|advanced|expert)$")
    favorite_plants: Optional[str] = Field(None, max_length=200)
    location: Optional[str] = Field(None, max_length=100)
    
    # Privacy settings
    is_private: Optional[bool] = None
    show_location: Optional[bool] = None
    allow_plant_id_requests: Optional[bool] = None


class UserRead(UserBase):
    """Schema for reading user data."""
    id: str
    is_verified: bool
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class UserInDB(UserRead):
    """Schema for user data stored in database (includes sensitive fields)."""
    hashed_password: str


class Token(BaseModel):
    """Schema for authentication tokens."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: Optional[int] = None


class TokenData(BaseModel):
    """Schema for token payload data."""
    user_id: Optional[str] = None
    username: Optional[str] = None
    exp: Optional[datetime] = None


class PasswordReset(BaseModel):
    """Schema for password reset request."""
    email: EmailStr
    
    @field_validator('email')
    @classmethod
    def email_lowercase(cls, v):
        return v.lower()


class PasswordResetConfirm(BaseModel):
    """Schema for password reset confirmation."""
    token: str
    new_password: str = Field(..., min_length=8, max_length=100)
    confirm_password: str = Field(..., min_length=8, max_length=100)
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'new_password' in info.data and v != info.data['new_password']:
            raise ValueError('Passwords do not match')
        return v


class EmailVerification(BaseModel):
    """Schema for email verification."""
    token: str


class ChangePassword(BaseModel):
    """Schema for changing password."""
    current_password: str
    new_password: str = Field(..., min_length=8, max_length=100)
    confirm_password: str = Field(..., min_length=8, max_length=100)
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'new_password' in info.data and v != info.data['new_password']:
            raise ValueError('Passwords do not match')
        return v


class LoginRequest(BaseModel):
    """Schema for login request."""
    username_or_email: str = Field(..., min_length=3)
    password: str = Field(..., min_length=1)
    remember_me: bool = False


class RefreshTokenRequest(BaseModel):
    """Schema for refresh token request."""
    refresh_token: str


class LogoutRequest(BaseModel):
    """Schema for logout request."""
    refresh_token: Optional[str] = None
    logout_all_devices: bool = False