"""Plant care logs API endpoints.

This module provides REST API endpoints for managing plant care logs.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime, date

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.plant_care_log import (
    PlantCareLogCreate,
    PlantCareLogUpdate,
    PlantCareLogResponse,
    PlantCareLogListResponse,
    CareTypeStatsResponse
)
from app.services.plant_care_log_service import (
    create_care_log,
    get_care_log_by_id,
    get_plant_care_logs,
    get_user_care_logs,
    update_care_log,
    delete_care_log,
    get_care_statistics
)
from app.services.personalized_plant_care_service import PersonalizedPlantCareService
from app.services.vector_database_service import VectorDatabaseService
from app.services.embedding_service import EmbeddingService

router = APIRouter()

# Initialize services
embedding_service = EmbeddingService()
vector_service = VectorDatabaseService(embedding_service)
personalized_care_service = PersonalizedPlantCareService(vector_service, embedding_service)


@router.post(
    "/",
    response_model=PlantCareLogResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create care log",
    description="Create a new plant care log entry."
)
async def create_plant_care_log(
    care_log_data: PlantCareLogCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantCareLogResponse:
    """Create a new plant care log."""
    try:
        care_log = await create_care_log(db, current_user.id, care_log_data)
        return PlantCareLogResponse.from_orm(care_log)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create care log"
        )


@router.get(
    "/",
    response_model=PlantCareLogListResponse,
    summary="Get user's care logs",
    description="Get all care logs for the current user."
)
async def get_my_care_logs(
    plant_id: Optional[UUID] = Query(None, description="Filter by plant ID"),
    care_type: Optional[str] = Query(None, description="Filter by care type"),
    start_date: Optional[date] = Query(None, description="Filter from this date"),
    end_date: Optional[date] = Query(None, description="Filter until this date"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantCareLogListResponse:
    """Get user's care logs with optional filters."""
    try:
        care_logs, total = await get_user_care_logs(
            db, current_user.id, plant_id, care_type, start_date, end_date, skip, limit
        )
        
        return PlantCareLogListResponse(
            care_logs=[PlantCareLogResponse.from_orm(log) for log in care_logs],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get care logs"
        )


@router.get(
    "/plant/{plant_id}",
    response_model=PlantCareLogListResponse,
    summary="Get plant care logs",
    description="Get all care logs for a specific plant."
)
async def get_plant_logs(
    plant_id: UUID,
    care_type: Optional[str] = Query(None, description="Filter by care type"),
    start_date: Optional[date] = Query(None, description="Filter from this date"),
    end_date: Optional[date] = Query(None, description="Filter until this date"),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantCareLogListResponse:
    """Get care logs for a specific plant."""
    try:
        care_logs, total = await get_plant_care_logs(
            db, plant_id, current_user.id, care_type, start_date, end_date, skip, limit
        )
        
        return PlantCareLogListResponse(
            care_logs=[PlantCareLogResponse.from_orm(log) for log in care_logs],
            total=total,
            skip=skip,
            limit=limit
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get plant care logs"
        )


@router.get(
    "/stats",
    response_model=List[CareTypeStatsResponse],
    summary="Get care statistics",
    description="Get care statistics for the current user."
)
async def get_my_care_stats(
    plant_id: Optional[UUID] = Query(None, description="Filter by plant ID"),
    start_date: Optional[date] = Query(None, description="Filter from this date"),
    end_date: Optional[date] = Query(None, description="Filter until this date"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[CareTypeStatsResponse]:
    """Get care statistics for the current user."""
    try:
        stats = await get_care_statistics(
            db, current_user.id, plant_id, start_date, end_date
        )
        return [CareTypeStatsResponse(**stat) for stat in stats]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get care statistics"
        )


@router.get(
    "/{care_log_id}",
    response_model=PlantCareLogResponse,
    summary="Get care log details",
    description="Get details of a specific care log."
)
async def get_care_log(
    care_log_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantCareLogResponse:
    """Get care log by ID."""
    care_log = await get_care_log_by_id(db, care_log_id, current_user.id)
    if not care_log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Care log not found"
        )
    return PlantCareLogResponse.from_orm(care_log)


@router.put(
    "/{care_log_id}",
    response_model=PlantCareLogResponse,
    summary="Update care log",
    description="Update a care log entry."
)
async def update_plant_care_log(
    care_log_id: UUID,
    care_log_data: PlantCareLogUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> PlantCareLogResponse:
    """Update care log."""
    try:
        care_log = await update_care_log(db, care_log_id, current_user.id, care_log_data)
        if not care_log:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care log not found"
            )
        return PlantCareLogResponse.from_orm(care_log)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update care log"
        )


@router.delete(
    "/{care_log_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete care log",
    description="Delete a care log entry."
)
async def delete_plant_care_log(
    care_log_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> None:
    """Delete care log."""
    try:
        success = await delete_care_log(db, care_log_id, current_user.id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Care log not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete care log"
        )


# Bulk operations
@router.post(
    "/bulk",
    response_model=List[PlantCareLogResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Create multiple care logs",
    description="Create multiple care log entries at once."
)
async def create_bulk_care_logs(
    care_logs_data: List[PlantCareLogCreate],
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[PlantCareLogResponse]:
    """Create multiple care logs."""
    if len(care_logs_data) > 50:  # Limit bulk operations
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot create more than 50 care logs at once"
        )
    
    try:
        created_logs = []
        for care_log_data in care_logs_data:
            care_log = await create_care_log(db, current_user.id, care_log_data)
            created_logs.append(care_log)
        
        return [PlantCareLogResponse.from_orm(log) for log in created_logs]
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create care logs"
        )


# Personalized Plant Care Endpoints

@router.get("/personalized/{user_id}/{plant_id}/care-schedule")
async def get_personalized_care_schedule(
    user_id: str,
    plant_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get personalized care schedule for a specific plant."""
    try:
        schedule = await personalized_care_service.get_personalized_care_schedule(
            db=db,
            user_id=user_id,
            plant_id=plant_id
        )
        return schedule
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating care schedule: {str(e)}"
        )


@router.get("/personalized/{user_id}/{plant_id}/health-prediction")
async def get_plant_health_prediction(
    user_id: str,
    plant_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get plant health prediction based on care patterns."""
    try:
        prediction = await personalized_care_service.predict_plant_health(
            db=db,
            user_id=user_id,
            plant_id=plant_id
        )
        return prediction
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error predicting plant health: {str(e)}"
        )


@router.get("/personalized/{user_id}/care-patterns")
async def analyze_user_care_patterns(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Analyze user's plant care patterns."""
    try:
        patterns = await personalized_care_service.analyze_care_patterns(
            db=db,
            user_id=user_id
        )
        return patterns
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error analyzing care patterns: {str(e)}"
        )


@router.post("/personalized/{user_id}/{plant_id}/care-advice")
async def get_personalized_care_advice(
    user_id: str,
    plant_id: str,
    question: str,
    db: AsyncSession = Depends(get_db)
):
    """Get personalized plant care advice."""
    try:
        advice = await personalized_care_service.get_personalized_care_advice(
            db=db,
            user_id=user_id,
            plant_id=plant_id,
            question=question
        )
        return advice
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating care advice: {str(e)}"
        )


@router.get("/personalized/{user_id}/seasonal-recommendations")
async def get_seasonal_recommendations(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get seasonal care recommendations for all user's plants."""
    try:
        recommendations = await personalized_care_service.get_seasonal_recommendations(
            db=db,
            user_id=user_id
        )
        return recommendations
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating seasonal recommendations: {str(e)}"
        )