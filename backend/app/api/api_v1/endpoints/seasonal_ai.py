"""Seasonal AI prediction API endpoints.

This module provides REST API endpoints for seasonal AI predictions,
care adjustments, and growth forecasting functionality.
"""

import logging
from typing import List, Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User
from app.schemas.seasonal_ai import (
    SeasonalPredictionRequest,
    CustomPredictionRequest,
    CareAdjustmentRequest,
    SeasonalPrediction,
    CareAdjustmentResponse,
    CustomPredictionResponse,
    SeasonalPredictionListResponse,
    SeasonalTransitionResponse,
    Season
)
from app.services.seasonal_ai_service import SeasonalAIService
from app.services.environmental_data_service import EnvironmentalDataService

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get(
    "/plants/{plant_id}/seasonal-predictions",
    response_model=SeasonalPrediction,
    summary="Get seasonal predictions for plant",
    description="Get AI-powered seasonal predictions for a specific plant including growth forecasts, care adjustments, and risk factors."
)
async def get_plant_seasonal_predictions(
    plant_id: UUID,
    prediction_days: int = Query(default=90, ge=30, le=365, description="Number of days to predict"),
    include_care_adjustments: bool = Query(default=True, description="Include care adjustments"),
    include_risk_factors: bool = Query(default=True, description="Include risk factors"),
    include_activities: bool = Query(default=True, description="Include optimal activities"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> SeasonalPrediction:
    """Get seasonal predictions for a specific plant."""
    try:
        seasonal_ai_service = SeasonalAIService()
        
        # Create prediction request
        request = SeasonalPredictionRequest(
            plant_id=plant_id,
            prediction_days=prediction_days,
            include_care_adjustments=include_care_adjustments,
            include_risk_factors=include_risk_factors,
            include_activities=include_activities
        )
        
        # Get predictions
        prediction = await seasonal_ai_service.predict_seasonal_behavior(
            db=db,
            user_id=current_user.id,
            request=request
        )
        
        if not prediction:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or no prediction data available"
            )
        
        return prediction
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate seasonal predictions"
        )


@router.post(
    "/seasonal-ai/predict",
    response_model=CustomPredictionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate custom seasonal prediction",
    description="Generate seasonal predictions with custom parameters for plant species and environmental conditions."
)
async def create_custom_seasonal_prediction(
    prediction_request: CustomPredictionRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CustomPredictionResponse:
    """Generate custom seasonal prediction with specified parameters."""
    try:
        seasonal_ai_service = SeasonalAIService()
        
        # Generate custom prediction
        prediction = await seasonal_ai_service.generate_custom_prediction(
            db=db,
            user_id=current_user.id,
            request=prediction_request
        )
        
        return prediction
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate custom prediction"
        )


@router.get(
    "/seasonal-ai/care-adjustments/{plant_id}",
    response_model=CareAdjustmentResponse,
    summary="Get seasonal care adjustments",
    description="Get current seasonal care adjustment recommendations for a specific plant."
)
async def get_seasonal_care_adjustments(
    plant_id: UUID,
    current_season: Optional[Season] = Query(None, description="Current season (auto-detected if not provided)"),
    specific_concerns: Optional[List[str]] = Query(None, description="Specific care concerns to address"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> CareAdjustmentResponse:
    """Get seasonal care adjustment recommendations for a plant."""
    try:
        seasonal_ai_service = SeasonalAIService()
        
        # Create care adjustment request
        request = CareAdjustmentRequest(
            plant_id=plant_id,
            current_season=current_season,
            specific_concerns=specific_concerns or []
        )
        
        # Get care adjustments
        adjustments = await seasonal_ai_service.get_seasonal_care_adjustments(
            db=db,
            user_id=current_user.id,
            request=request
        )
        
        if not adjustments:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found or no care adjustment data available"
            )
        
        return adjustments
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get care adjustments"
        )


@router.get(
    "/seasonal-ai/transitions",
    response_model=SeasonalTransitionResponse,
    summary="Get seasonal transition predictions",
    description="Get predictions about upcoming seasonal transitions based on location and environmental data."
)
async def get_seasonal_transitions(
    latitude: float = Query(..., ge=-90, le=90, description="Latitude in decimal degrees"),
    longitude: float = Query(..., ge=-180, le=180, description="Longitude in decimal degrees"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> SeasonalTransitionResponse:
    """Get seasonal transition predictions for a location."""
    try:
        environmental_service = EnvironmentalDataService()
        seasonal_ai_service = SeasonalAIService()
        
        # Create location object
        location = {"latitude": latitude, "longitude": longitude}
        
        # Detect seasonal transitions
        transitions = await seasonal_ai_service.detect_seasonal_transitions(
            db=db,
            location=location
        )
        
        return transitions
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to detect seasonal transitions"
        )


@router.get(
    "/plants/{plant_id}/seasonal-predictions/history",
    response_model=SeasonalPredictionListResponse,
    summary="Get historical seasonal predictions",
    description="Get historical seasonal predictions for a plant to track prediction accuracy over time."
)
async def get_plant_prediction_history(
    plant_id: UUID,
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(10, ge=1, le=50, description="Maximum number of records to return"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> SeasonalPredictionListResponse:
    """Get historical seasonal predictions for a plant."""
    try:
        seasonal_ai_service = SeasonalAIService()
        
        # Get prediction history
        predictions, total = await seasonal_ai_service.get_prediction_history(
            db=db,
            plant_id=plant_id,
            user_id=current_user.id,
            skip=skip,
            limit=limit
        )
        
        return SeasonalPredictionListResponse(
            predictions=predictions,
            total_count=total,
            plant_id=plant_id
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get prediction history"
        )


@router.post(
    "/seasonal-ai/batch-predict",
    response_model=List[SeasonalPrediction],
    summary="Generate batch seasonal predictions",
    description="Generate seasonal predictions for multiple plants at once."
)
async def create_batch_seasonal_predictions(
    plant_ids: List[UUID],
    prediction_days: int = Query(default=90, ge=30, le=365, description="Number of days to predict"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[SeasonalPrediction]:
    """Generate seasonal predictions for multiple plants."""
    try:
        if len(plant_ids) > 20:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Maximum 20 plants allowed per batch request"
            )
        
        seasonal_ai_service = SeasonalAIService()
        predictions = []
        
        for plant_id in plant_ids:
            try:
                request = SeasonalPredictionRequest(
                    plant_id=plant_id,
                    prediction_days=prediction_days
                )
                
                prediction = await seasonal_ai_service.predict_seasonal_behavior(
                    db=db,
                    user_id=current_user.id,
                    request=request
                )
                
                if prediction:
                    predictions.append(prediction)
                    
            except Exception as e:
                # Log error but continue with other plants
                logger.warning(f"Failed to generate prediction for plant {plant_id}: {str(e)}")
                continue
        
        return predictions
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate batch predictions"
        )