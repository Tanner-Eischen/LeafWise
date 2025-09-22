"""ML-Enhanced Plant Health API endpoints."""

from typing import List, Dict, Any, Optional
from datetime import datetime
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.ml_plant_health_service import (
    MLPlantHealthService, 
    HealthPrediction, 
    CareOptimization
)
from app.services.rag_service import RAGService
from app.services.embedding_service import EmbeddingService
from app.api.api_v1.endpoints.auth import get_current_user
from app.models.user import User

logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize ML services
rag_service = RAGService()
embedding_service = EmbeddingService()
ml_plant_health_service = MLPlantHealthService(rag_service, embedding_service)


@router.post("/predict-health/{plant_id}")
async def predict_plant_health_ml(
    plant_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get ML-enhanced plant health prediction with risk assessment.
    
    This endpoint uses advanced machine learning models to:
    - Predict plant health score (0-1)
    - Assess risk levels (low/medium/high/critical) 
    - Identify specific risk factors
    - Generate prevention actions
    - Predict potential issues
    - Calculate optimal care windows
    """
    try:
        # Get ML health prediction
        prediction = await ml_plant_health_service.predict_plant_health_ml(
            db=db,
            plant_id=plant_id,
            user_id=str(current_user.id)
        )
        
        # Convert dataclass to dict for JSON response
        return {
            "health_score": prediction.health_score,
            "risk_level": prediction.risk_level,
            "confidence": prediction.confidence,
            "risk_factors": prediction.risk_factors,
            "prevention_actions": prediction.prevention_actions,
            "predicted_issues": prediction.predicted_issues,
            "optimal_care_window": {
                key: value.isoformat() if isinstance(value, datetime) else value
                for key, value in prediction.optimal_care_window.items()
            },
            "intervention_urgency": prediction.intervention_urgency,
            "model_info": {
                "version": ml_plant_health_service.model_version,
                "last_trained": ml_plant_health_service.last_trained.isoformat() 
                    if ml_plant_health_service.last_trained else None
            }
        }
        
    except Exception as e:
        logger.error(f"Error predicting plant health: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to predict plant health"
        )


@router.post("/optimize-care/{plant_id}")
async def optimize_plant_care_ml(
    plant_id: str,
    include_health_prediction: bool = True,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get ML-optimized care schedule and recommendations.
    
    This endpoint provides:
    - Optimal watering frequency
    - Fertilizing schedule optimization
    - Predicted care success rate
    - Personalized adjustments
    - Seasonal modifications
    - Risk mitigation schedule
    - Growth trajectory predictions
    """
    try:
        # Get current health prediction if requested
        health_prediction = None
        if include_health_prediction:
            health_prediction = await ml_plant_health_service.predict_plant_health_ml(
                db=db,
                plant_id=plant_id,
                user_id=str(current_user.id)
            )
        
        # Get care optimization
        optimization = await ml_plant_health_service.optimize_care_schedule_ml(
            db=db,
            plant_id=plant_id,
            user_id=str(current_user.id),
            current_health_prediction=health_prediction
        )
        
        response_data = {
            "optimal_watering_frequency": optimization.optimal_watering_frequency,
            "optimal_fertilizing_schedule": optimization.optimal_fertilizing_schedule,
            "predicted_care_success_rate": optimization.predicted_care_success_rate,
            "personalized_adjustments": optimization.personalized_adjustments,
            "seasonal_modifications": optimization.seasonal_modifications,
            "risk_mitigation_schedule": optimization.risk_mitigation_schedule,
            "predicted_growth_trajectory": optimization.predicted_growth_trajectory,
            "model_info": {
                "version": ml_plant_health_service.model_version,
                "last_trained": ml_plant_health_service.last_trained.isoformat() 
                    if ml_plant_health_service.last_trained else None
            }
        }
        
        # Include health prediction if requested
        if include_health_prediction and health_prediction:
            response_data["current_health_prediction"] = {
                "health_score": health_prediction.health_score,
                "risk_level": health_prediction.risk_level,
                "confidence": health_prediction.confidence,
                "intervention_urgency": health_prediction.intervention_urgency
            }
        
        return response_data
        
    except Exception as e:
        logger.error(f"Error optimizing plant care: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to optimize plant care"
        )


@router.post("/comprehensive-analysis/{plant_id}")
async def comprehensive_plant_analysis(
    plant_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get comprehensive ML-enhanced plant analysis combining health prediction and care optimization.
    
    This is the most complete analysis available, providing:
    - Full health assessment
    - Risk analysis with specific factors
    - Optimized care recommendations  
    - Prevention strategies
    - Growth predictions
    - Actionable insights
    """
    try:
        # Get comprehensive analysis
        health_prediction = await ml_plant_health_service.predict_plant_health_ml(
            db=db,
            plant_id=plant_id,
            user_id=str(current_user.id)
        )
        
        care_optimization = await ml_plant_health_service.optimize_care_schedule_ml(
            db=db,
            plant_id=plant_id,
            user_id=str(current_user.id),
            current_health_prediction=health_prediction
        )
        
        return {
            "analysis_timestamp": datetime.utcnow().isoformat(),
            "plant_id": plant_id,
            "health_assessment": {
                "health_score": health_prediction.health_score,
                "risk_level": health_prediction.risk_level,
                "confidence": health_prediction.confidence,
                "intervention_urgency": health_prediction.intervention_urgency,
                "risk_factors": health_prediction.risk_factors,
                "predicted_issues": health_prediction.predicted_issues
            },
            "care_optimization": {
                "optimal_watering_frequency": care_optimization.optimal_watering_frequency,
                "optimal_fertilizing_schedule": care_optimization.optimal_fertilizing_schedule,
                "predicted_care_success_rate": care_optimization.predicted_care_success_rate,
                "personalized_adjustments": care_optimization.personalized_adjustments,
                "seasonal_modifications": care_optimization.seasonal_modifications,
                "predicted_growth_trajectory": care_optimization.predicted_growth_trajectory
            },
            "action_plan": {
                "immediate_actions": health_prediction.prevention_actions,
                "care_schedule": {
                    "watering": {
                        "frequency_days": care_optimization.optimal_watering_frequency,
                        "next_window": health_prediction.optimal_care_window
                    },
                    "fertilizing": care_optimization.optimal_fertilizing_schedule,
                    "monitoring": care_optimization.risk_mitigation_schedule
                }
            },
            "model_info": {
                "version": ml_plant_health_service.model_version,
                "last_trained": ml_plant_health_service.last_trained.isoformat() 
                    if ml_plant_health_service.last_trained else None,
                "performance": ml_plant_health_service.model_performance
            }
        }
        
    except Exception as e:
        logger.error(f"Error in comprehensive plant analysis: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to perform comprehensive plant analysis"
        )


@router.post("/train-models")
async def train_ml_models(
    feedback_days: int = 30,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Train ML models using recent user feedback and outcomes.
    
    This endpoint triggers the continuous learning pipeline:
    - Collects recent user feedback
    - Retrains health prediction models
    - Retrains care optimization models
    - Updates model performance metrics
    - Saves improved models
    
    Requires admin privileges for security.
    """
    try:
        # Check if user has admin privileges (simplified check)
        if not getattr(current_user, 'is_admin', False):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Admin privileges required for model training"
            )
        
        # Trigger model training
        training_result = await ml_plant_health_service.train_models_from_feedback(
            db=db,
            feedback_days=feedback_days
        )
        
        return {
            "training_completed": datetime.utcnow().isoformat(),
            "feedback_period_days": feedback_days,
            "results": training_result,
            "model_version": ml_plant_health_service.model_version,
            "next_training_recommended": (datetime.utcnow().timestamp() + (7 * 24 * 60 * 60))  # 1 week
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error training ML models: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to train ML models"
        )


@router.get("/model-status")
async def get_model_status(
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get current status and performance metrics of ML models.
    
    Returns:
    - Model version and training history
    - Performance metrics
    - Health and availability status
    - Recommendation for retraining
    """
    try:
        return {
            "model_version": ml_plant_health_service.model_version,
            "last_trained": ml_plant_health_service.last_trained.isoformat() 
                if ml_plant_health_service.last_trained else None,
            "performance_metrics": ml_plant_health_service.model_performance,
            "models_available": {
                "health_classifier": ml_plant_health_service.health_classifier is not None,
                "risk_predictor": ml_plant_health_service.risk_predictor is not None,
                "care_optimizer": ml_plant_health_service.care_optimizer is not None,
                "success_predictor": ml_plant_health_service.success_predictor is not None
            },
            "training_recommendations": {
                "needs_retraining": (
                    ml_plant_health_service.last_trained is None or
                    (datetime.utcnow() - ml_plant_health_service.last_trained).days > 7
                ),
                "recommended_feedback_days": 30,
                "minimum_training_samples": 100
            },
            "status": "healthy" if all([
                ml_plant_health_service.health_classifier,
                ml_plant_health_service.risk_predictor,
                ml_plant_health_service.care_optimizer,
                ml_plant_health_service.success_predictor
            ]) else "needs_initialization"
        }
        
    except Exception as e:
        logger.error(f"Error getting model status: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get model status"
        )


@router.post("/feedback/{plant_id}")
async def submit_prediction_feedback(
    plant_id: str,
    feedback_rating: int,
    feedback_comments: Optional[str] = None,
    prediction_type: str = "health_prediction",  # or "care_optimization"
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Submit feedback on ML predictions for continuous learning.
    
    Args:
        plant_id: Plant ID for the prediction
        feedback_rating: Rating from 1-5 (5 = excellent prediction)
        feedback_comments: Optional detailed feedback
        prediction_type: Type of prediction ("health_prediction" or "care_optimization")
    
    This feedback is used to improve ML models through continuous learning.
    """
    try:
        if not 1 <= feedback_rating <= 5:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Feedback rating must be between 1 and 5"
            )
        
        # Find the most recent prediction for this plant
        from sqlalchemy import select, desc
        from app.models.rag_models import RAGInteraction
        
        stmt = select(RAGInteraction).where(
            RAGInteraction.user_id == current_user.id,
            RAGInteraction.interaction_type == prediction_type,
            RAGInteraction.meta_data.op('->>')('plant_id') == plant_id
        ).order_by(desc(RAGInteraction.created_at)).limit(1)
        
        result = await db.execute(stmt)
        interaction = result.scalar_one_or_none()
        
        if not interaction:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No recent prediction found for this plant"
            )
        
        # Update the interaction with feedback
        interaction.user_feedback = feedback_rating
        if feedback_comments:
            interaction.meta_data = interaction.meta_data or {}
            interaction.meta_data["feedback_comments"] = feedback_comments
        
        await db.commit()
        
        return {
            "feedback_submitted": datetime.utcnow().isoformat(),
            "plant_id": plant_id,
            "prediction_type": prediction_type,
            "rating": feedback_rating,
            "message": "Thank you for your feedback! This helps improve our ML models.",
            "contribution_to_learning": "Your feedback will be used in the next model training cycle."
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error submitting feedback: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to submit feedback"
        ) 