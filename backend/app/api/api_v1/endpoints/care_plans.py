"""Care Plan API Endpoints.

This module implements REST API endpoints for the Context-Aware Care Plans v2 feature,
including plan generation, retrieval, acknowledgment, and history management.
"""

import time
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Header, Query, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.care_plan import CarePlanV2 as CarePlan
from app.schemas.care_plan import (
    CarePlanRequest,
    CarePlanResponse,
    CarePlanHistory,
    CarePlanAcknowledgment,
    CarePlanHistoryResponse,
    CarePlanGenerationMetrics
)
from app.services.care_plan_service import CarePlanService
from app.services.care_plan_metrics_service import CarePlanMetricsService
from app.core.config import settings


router = APIRouter()
metrics_service = CarePlanMetricsService()


@router.post(
    "/{plant_id}:generate",
    response_model=CarePlanResponse,
    status_code=status.HTTP_200_OK,
    summary="Generate care plan for plant",
    description="Generate a new context-aware care plan for the specified plant"
)
async def generate_care_plan(
    plant_id: UUID,
    request: CarePlanRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key"),
    x_request_id: Optional[str] = Header(None, alias="X-Request-Id")
) -> CarePlanResponse:
    """Generate a new care plan for the specified plant.
    
    Args:
        plant_id: UUID of the plant to generate care plan for
        request: Care plan generation request parameters
        db: Database session
        current_user: Authenticated user
        idempotency_key: Optional idempotency key for duplicate prevention
        x_request_id: Optional request ID for tracing
        
    Returns:
        Generated care plan with rationale
        
    Raises:
        HTTPException: If plant not found, unauthorized, or generation fails
    """
    start_time = time.time()
    
    try:
        # Initialize care plan service with database session
        care_plan_service = CarePlanService(db)
        
        # Verify plant ownership
        plant = db.query(UserPlant).filter(
            UserPlant.id == plant_id,
            UserPlant.user_id == current_user.id,
            UserPlant.is_active == True
        ).first()
        
        if not plant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or access denied"
            )
        
        # Check for existing recent plan if not forcing regeneration
        if not request.force_regenerate and idempotency_key:
            existing_plan = await care_plan_service.get_by_idempotency_key(
                db, idempotency_key
            )
            if existing_plan:
                return CarePlanResponse.from_orm(existing_plan)
        
        # Generate new care plan
        care_plan = await care_plan_service.generate_care_plan(
            db=db,
            plant=plant,
            user=current_user,
            context_override=request.context_override,
            include_rationale=request.include_rationale,
            idempotency_key=idempotency_key
        )
        
        # Record metrics
        generation_time = (time.time() - start_time) * 1000
        await metrics_service.record_generation_metrics(
            plant_id=plant_id,
            user_id=current_user.id,
            generation_time_ms=generation_time,
            request_id=x_request_id
        )
        
        # Check performance SLA (300ms requirement)
        if generation_time > 300:
            await metrics_service.record_sla_violation(
                plant_id=plant_id,
                generation_time_ms=generation_time,
                request_id=x_request_id
            )
        
        return CarePlanResponse.from_orm(care_plan)
        
    except HTTPException:
        raise
    except Exception as e:
        await metrics_service.record_generation_error(
            plant_id=plant_id,
            user_id=current_user.id,
            error=str(e),
            request_id=x_request_id
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate care plan"
        )


@router.get(
    "/{plant_id}",
    response_model=CarePlanResponse,
    summary="Get care plan for plant",
    description="Retrieve the current or latest care plan for the specified plant"
)
async def get_care_plan(
    plant_id: UUID,
    latest: bool = Query(True, description="Get latest plan version"),
    version: Optional[int] = Query(None, description="Specific version to retrieve"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CarePlanResponse:
    """Get care plan for the specified plant.
    
    Args:
        plant_id: UUID of the plant
        latest: Whether to get the latest version
        version: Specific version number to retrieve
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Care plan details
        
    Raises:
        HTTPException: If plant or plan not found, or access denied
    """
    # Verify plant ownership
    plant = db.query(UserPlant).filter(
        UserPlant.id == plant_id,
        UserPlant.user_id == current_user.id,
        UserPlant.is_active == True
    ).first()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found or access denied"
        )
    
    try:
        if version is not None:
            care_plan = await care_plan_service.get_plan_by_version(
                db, plant_id, version
            )
        else:
            care_plan = await care_plan_service.get_latest_plan(
                db, plant_id
            )
        
        if not care_plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care plan not found"
            )
        
        return CarePlanResponse.from_orm(care_plan)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve care plan"
        )


@router.post(
    "/{plant_id}:acknowledge",
    response_model=CarePlanResponse,
    summary="Acknowledge care plan",
    description="Mark a care plan as acknowledged by the user"
)
async def acknowledge_care_plan(
    plant_id: UUID,
    acknowledgment: CarePlanAcknowledgment,
    version: Optional[int] = Query(None, description="Specific version to acknowledge"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CarePlanResponse:
    """Acknowledge a care plan.
    
    Args:
        plant_id: UUID of the plant
        acknowledgment: Acknowledgment details
        version: Specific version to acknowledge (defaults to latest)
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Updated care plan
        
    Raises:
        HTTPException: If plant or plan not found, or access denied
    """
    # Verify plant ownership
    plant = db.query(UserPlant).filter(
        UserPlant.id == plant_id,
        UserPlant.user_id == current_user.id,
        UserPlant.is_active == True
    ).first()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found or access denied"
        )
    
    try:
        # Initialize care plan service with database session
        care_plan_service = CarePlanService(db)
        
        care_plan = await care_plan_service.acknowledge_plan(
            db=db,
            plant_id=plant_id,
            user_id=current_user.id,
            acknowledged=acknowledgment.acknowledged,
            user_notes=acknowledgment.user_notes,
            version=version
        )
        
        if not care_plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care plan not found"
            )
        
        return CarePlanResponse.from_orm(care_plan)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to acknowledge care plan"
        )


@router.get(
    "/{plant_id}/history",
    response_model=CarePlanHistoryResponse,
    summary="Get care plan history",
    description="Retrieve version history of care plans for the specified plant"
)
async def get_care_plan_history(
    plant_id: UUID,
    limit: int = Query(10, ge=1, le=50, description="Number of plans to retrieve"),
    offset: int = Query(0, ge=0, description="Number of plans to skip"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CarePlanHistoryResponse:
    """Get care plan history for the specified plant.
    
    Args:
        plant_id: UUID of the plant
        limit: Maximum number of plans to return
        offset: Number of plans to skip
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Care plan history with summaries
        
    Raises:
        HTTPException: If plant not found or access denied
    """
    # Verify plant ownership
    plant = db.query(UserPlant).filter(
        UserPlant.id == plant_id,
        UserPlant.user_id == current_user.id,
        UserPlant.is_active == True
    ).first()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found or access denied"
        )
    
    try:
        # Initialize care plan service with database session
        care_plan_service = CarePlanService(db)
        
        history = await care_plan_service.get_plan_history(
            db=db,
            plant_id=plant_id,
            limit=limit,
            offset=offset
        )
        
        return history
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve care plan history"
        )


@router.get(
    "/{plant_id}/metrics",
    response_model=CarePlanGenerationMetrics,
    summary="Get care plan generation metrics",
    description="Retrieve performance metrics for care plan generation"
)
async def get_care_plan_metrics(
    plant_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CarePlanGenerationMetrics:
    """Get care plan generation metrics.
    
    Args:
        plant_id: UUID of the plant
        db: Database session
        current_user: Authenticated user
        
    Returns:
        Generation performance metrics
        
    Raises:
        HTTPException: If plant not found or access denied
    """
    # Verify plant ownership
    plant = db.query(UserPlant).filter(
        UserPlant.id == plant_id,
        UserPlant.user_id == current_user.id,
        UserPlant.is_active == True
    ).first()
    
    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plant not found or access denied"
        )
    
    try:
        metrics = await metrics_service.get_latest_metrics(
            plant_id=plant_id,
            user_id=current_user.id
        )
        
        if not metrics:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No metrics found for this plant"
            )
        
        return metrics
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve metrics"
        )


@router.delete(
    "/{plant_id}/{version}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete care plan version",
    description="Delete a specific version of a care plan (admin only)"
)
async def delete_care_plan_version(
    plant_id: UUID,
    version: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete a specific care plan version.
    
    Args:
        plant_id: UUID of the plant
        version: Version number to delete
        db: Database session
        current_user: Authenticated user
        
    Raises:
        HTTPException: If unauthorized, plan not found, or deletion fails
    """
    # Check if user has admin privileges or owns the plant
    plant = db.query(UserPlant).filter(
        UserPlant.id == plant_id,
        UserPlant.user_id == current_user.id,
        UserPlant.is_active == True
    ).first()
    
    if not plant and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions"
        )
    
    try:
        # Initialize care plan service with database session
        care_plan_service = CarePlanService(db)
        
        success = await care_plan_service.delete_plan_version(
            db=db,
            plant_id=plant_id,
            version=version
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care plan version not found"
            )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete care plan version"
        )