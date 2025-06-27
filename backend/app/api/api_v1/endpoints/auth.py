"""Authentication endpoints.

This module provides user registration, login, logout,
and authentication management using FastAPI-Users.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.auth import UserCreate, UserRead, UserUpdate, Token
from app.services.auth_service import get_auth_service
from app.services.user_service import get_user_service
from app.models.user import User

router = APIRouter()


async def get_current_user(
    token: str = Depends(OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")),
    db: AsyncSession = Depends(get_db),
    auth_service = Depends(get_auth_service)
) -> User:
    """Get current authenticated user from JWT token."""
    user = await auth_service.get_current_user(token, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


@router.post("/register", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db),
    user_service = Depends(get_user_service)
):
    """Register a new user.
    
    Args:
        user_data: User registration data
        db: Database session
        
    Returns:
        UserRead: Created user data
        
    Raises:
        HTTPException: If email or username already exists
    """
    # Check if email already exists
    existing_user = await user_service.get_user_by_email(user_data.email, db)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Check if username already exists
    existing_username = await user_service.get_user_by_username(user_data.username, db)
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )
    
    # Create new user
    user = await user_service.create_user(user_data, db)
    return UserRead.from_orm(user)


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
    auth_service = Depends(get_auth_service)
):
    """Authenticate user and return access token.
    
    Args:
        form_data: Login form data (username/email and password)
        db: Database session
        
    Returns:
        Token: Access and refresh tokens
        
    Raises:
        HTTPException: If authentication fails
    """
    # Authenticate user (supports both email and username)
    user = await auth_service.authenticate_user(form_data.username, form_data.password, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email/username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create tokens
    access_token = auth_service.create_access_token(data={"sub": str(user.id)})
    refresh_token = auth_service.create_refresh_token(data={"sub": str(user.id)})
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer"
    )


@router.post("/refresh", response_model=Token)
async def refresh_token(
    refresh_token: str,
    db: AsyncSession = Depends(get_db),
    auth_service = Depends(get_auth_service)
):
    """Refresh access token using refresh token.
    
    Args:
        refresh_token: Valid refresh token
        db: Database session
        
    Returns:
        Token: New access and refresh tokens
        
    Raises:
        HTTPException: If refresh token is invalid
    """
    # Verify refresh token
    payload = await auth_service.verify_refresh_token(refresh_token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    user_id = payload.get("sub")
    # Create new tokens
    access_token = auth_service.create_access_token(data={"sub": user_id})
    new_refresh_token = auth_service.create_refresh_token(data={"sub": user_id})
    
    return Token(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer"
    )


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


@router.post("/forgot-password")
async def forgot_password(
    email: str,
    db: AsyncSession = Depends(get_db)
):
    """Send password reset email.
    
    Args:
        email: User's email address
        db: Database session
        
    Returns:
        dict: Success message
        
    Note: Implementation depends on email service setup
    """
    # TODO: Implement password reset logic
    return {"message": "Password reset not implemented yet"}