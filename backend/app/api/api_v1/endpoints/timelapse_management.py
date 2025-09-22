"""Time-lapse management API endpoints.

This module provides REST API endpoints for time-lapse session management,
photo uploads, and video generation functionality.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.timelapse import (
    TimelapseSessionCreate,
    TimelapseSessionUpdate,
    TimelapseSessionResponse,
    TimelapseSessionListResponse,
    GrowthPhotoCreate,
    GrowthPhotoResponse,
    GrowthPhotoListResponse,
    TimelapseVideoRequest,
    TimelapseVideoResponse,
    GrowthMilestoneResponse,
    GrowthMilestoneListResponse,
    TrackingStatus,
    ProcessingStatus,
    VideoOptions
)
from app.services.timelapse_service import TimelapseService

router = APIRouter()


@router.post(
    "/sessions",
    response_model=TimelapseSessionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create time-lapse tracking session",
    description="Initialize a new time-lapse tracking session for a plant with specified configuration."
)
async def create_timelapse_session(
    session_data: TimelapseSessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> TimelapseSessionResponse:
    """Create a new time-lapse tracking session."""
    try:
        timelapse_service = TimelapseService()
        
        # Create tracking session
        session = await timelapse_service.initialize_tracking(
            db=db,
            user_id=current_user.id,
            session_data=session_data
        )
        
        return TimelapseSessionResponse.from_orm(session)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create time-lapse session"
        )


@router.get(
    "/sessions",
    response_model=TimelapseSessionListResponse,
    summary="Get user's time-lapse sessions",
    description="Get all time-lapse tracking sessions for the current user."
)
async def get_user_timelapse_sessions(
    status_filter: Optional[TrackingStatus] = Query(None, description="Filter by session status"),
    plant_id: Optional[UUID] = Query(None, description="Filter by plant ID"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> TimelapseSessionListResponse:
    """Get user's time-lapse sessions."""
    try:
        timelapse_service = TimelapseService()
        
        sessions, total = await timelapse_service.get_user_sessions(
            db=db,
            user_id=current_user.id,
            status_filter=status_filter,
            plant_id=plant_id,
            skip=skip,
            limit=limit
        )
        
        return TimelapseSessionListResponse(
            sessions=[TimelapseSessionResponse.from_orm(session) for session in sessions],
            total_count=total,
            page=skip // limit + 1,
            page_size=limit
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get time-lapse sessions"
        )


@router.get(
    "/sessions/{session_id}",
    response_model=TimelapseSessionResponse,
    summary="Get time-lapse session details",
    description="Get detailed information about a specific time-lapse session."
)
async def get_timelapse_session(
    session_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> TimelapseSessionResponse:
    """Get time-lapse session by ID."""
    try:
        timelapse_service = TimelapseService()
        
        session = await timelapse_service.get_session_by_id(
            db=db,
            session_id=session_id,
            user_id=current_user.id
        )
        
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time-lapse session not found"
            )
        
        return TimelapseSessionResponse.from_orm(session)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get time-lapse session"
        )


@router.put(
    "/sessions/{session_id}",
    response_model=TimelapseSessionResponse,
    summary="Update time-lapse session",
    description="Update time-lapse session configuration or status."
)
async def update_timelapse_session(
    session_id: UUID,
    session_update: TimelapseSessionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> TimelapseSessionResponse:
    """Update time-lapse session."""
    try:
        timelapse_service = TimelapseService()
        
        session = await timelapse_service.update_session(
            db=db,
            session_id=session_id,
            user_id=current_user.id,
            session_update=session_update
        )
        
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time-lapse session not found"
            )
        
        return TimelapseSessionResponse.from_orm(session)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update time-lapse session"
        )


@router.post(
    "/{session_id}/photos",
    response_model=GrowthPhotoResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload growth photo",
    description="Upload a new growth photo to a time-lapse session for analysis."
)
async def upload_growth_photo(
    session_id: UUID,
    photo: UploadFile = File(..., description="Growth photo to upload"),
    capture_date: Optional[datetime] = Form(None, description="Photo capture date (defaults to now)"),
    user_notes: Optional[str] = Form(None, description="Optional user notes about the photo"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> GrowthPhotoResponse:
    """Upload a growth photo to a time-lapse session."""
    try:
        # Validate file type
        if not photo.content_type or not photo.content_type.startswith('image/'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File must be an image"
            )
        
        # Validate file size (max 10MB)
        if photo.size and photo.size > 10 * 1024 * 1024:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File size must be less than 10MB"
            )
        
        timelapse_service = TimelapseService()
        
        # Process and upload photo
        growth_photo = await timelapse_service.process_growth_photo(
            db=db,
            session_id=session_id,
            user_id=current_user.id,
            photo_file=photo,
            capture_date=capture_date or datetime.utcnow(),
            user_notes=user_notes
        )
        
        return GrowthPhotoResponse.from_orm(growth_photo)
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to upload growth photo"
        )


@router.get(
    "/{session_id}/photos",
    response_model=GrowthPhotoListResponse,
    summary="Get session photos",
    description="Get all photos from a time-lapse session."
)
async def get_session_photos(
    session_id: UUID,
    processing_status: Optional[ProcessingStatus] = Query(None, description="Filter by processing status"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> GrowthPhotoListResponse:
    """Get photos from a time-lapse session."""
    try:
        timelapse_service = TimelapseService()
        
        photos, total = await timelapse_service.get_session_photos(
            db=db,
            session_id=session_id,
            user_id=current_user.id,
            processing_status=processing_status,
            skip=skip,
            limit=limit
        )
        
        return GrowthPhotoListResponse(
            photos=[GrowthPhotoResponse.from_orm(photo) for photo in photos],
            total_count=total,
            session_id=session_id
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get session photos"
        )


@router.get(
    "/{session_id}/video",
    response_model=TimelapseVideoResponse,
    summary="Generate time-lapse video",
    description="Generate or retrieve a time-lapse video from a session's photos."
)
async def get_timelapse_video(
    session_id: UUID,
    regenerate: bool = Query(False, description="Force regeneration of video"),
    fps: int = Query(10, ge=1, le=60, description="Frames per second"),
    resolution: str = Query("1080p", description="Video resolution"),
    include_metrics: bool = Query(True, description="Include growth metrics overlay"),
    include_dates: bool = Query(True, description="Include capture dates"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> TimelapseVideoResponse:
    """Generate or retrieve time-lapse video."""
    try:
        timelapse_service = TimelapseService()
        
        # Create video options
        video_options = VideoOptions(
            fps=fps,
            resolution=resolution,
            include_metrics=include_metrics,
            include_dates=include_dates
        )
        
        # Generate or retrieve video
        video_response = await timelapse_service.generate_timelapse_video(
            db=db,
            session_id=session_id,
            user_id=current_user.id,
            video_options=video_options,
            force_regenerate=regenerate
        )
        
        if not video_response:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time-lapse session not found or insufficient photos"
            )
        
        return video_response
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate time-lapse video"
        )


@router.get(
    "/{session_id}/milestones",
    response_model=GrowthMilestoneListResponse,
    summary="Get growth milestones",
    description="Get detected growth milestones from a time-lapse session."
)
async def get_session_milestones(
    session_id: UUID,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> GrowthMilestoneListResponse:
    """Get growth milestones from a time-lapse session."""
    try:
        timelapse_service = TimelapseService()
        
        milestones, total = await timelapse_service.get_session_milestones(
            db=db,
            session_id=session_id,
            user_id=current_user.id,
            skip=skip,
            limit=limit
        )
        
        return GrowthMilestoneListResponse(
            milestones=[GrowthMilestoneResponse.from_orm(milestone) for milestone in milestones],
            total_count=total,
            session_id=session_id
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get session milestones"
        )


@router.delete(
    "/sessions/{session_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete time-lapse session",
    description="Delete a time-lapse session and all associated photos and data."
)
async def delete_timelapse_session(
    session_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete a time-lapse session."""
    try:
        timelapse_service = TimelapseService()
        
        success = await timelapse_service.delete_session(
            db=db,
            session_id=session_id,
            user_id=current_user.id
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time-lapse session not found"
            )
            
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete time-lapse session"
        )