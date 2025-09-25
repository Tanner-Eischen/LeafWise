"""ML adjustment service.

This module provides machine learning-based adjustments to care recommendations.
It uses historical care data and outcomes to refine and personalize care plans
through pattern recognition and predictive modeling.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID
import numpy as np
from dataclasses import dataclass
from enum import Enum

from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.growth_photo import GrowthPhoto
from app.models.seasonal_ai import EnvironmentalDataCache
from app.services.rule_engine_service import CareRecommendation


class MLModelType(Enum):
    """Types of ML models used for adjustments."""
    WATERING_FREQUENCY = "watering_frequency"
    FERTILIZER_TIMING = "fertilizer_timing"
    LIGHT_OPTIMIZATION = "light_optimization"
    HEALTH_PREDICTION = "health_prediction"


@dataclass
class MLPrediction:
    """Represents an ML model prediction."""
    model_type: MLModelType
    prediction: Any
    confidence: float
    feature_importance: Dict[str, float]
    model_version: str


@dataclass
class CareOutcome:
    """Represents the outcome of a care action."""
    care_type: str
    performed_at: datetime
    parameters: Dict[str, Any]
    outcome_score: float  # 0.0 to 1.0, based on plant response
    health_change: Optional[float] = None
    growth_change: Optional[float] = None


class MLAdjustmentService:
    """Service for ML-based care plan adjustments."""
    
    def __init__(self, db: AsyncSession):
        """Initialize the ML adjustment service.
        
        Args:
            db: Database session
        """
        self.db = db
        self.models = {}
        self._initialize_models()
    
    async def adjust_recommendations(
        self,
        plant_id: UUID,
        user_id: UUID,
        base_recommendations: List[CareRecommendation],
        context: Dict[str, Any]
    ) -> Tuple[List[CareRecommendation], Dict[str, Any]]:
        """Adjust care recommendations using ML models.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            base_recommendations: Base recommendations from rule engine
            context: Plant context data
            
        Returns:
            Tuple of (adjusted recommendations, ML metadata)
        """
        # Get historical care data for training/adjustment
        care_history = await self._get_care_outcomes(plant_id, days_back=90)
        
        # Generate ML predictions for different care aspects
        predictions = await self._generate_predictions(plant_id, context, care_history)
        
        # Adjust recommendations based on ML insights
        adjusted_recommendations = []
        adjustments_made = []
        
        for recommendation in base_recommendations:
            adjusted_rec, adjustment_info = await self._adjust_single_recommendation(
                recommendation, predictions, context, care_history
            )
            adjusted_recommendations.append(adjusted_rec)
            
            if adjustment_info:
                adjustments_made.append(adjustment_info)
        
        # Add ML-generated recommendations
        ml_recommendations = await self._generate_ml_recommendations(
            plant_id, predictions, context
        )
        adjusted_recommendations.extend(ml_recommendations)
        
        # Generate ML metadata
        ml_metadata = {
            "ml_processing_timestamp": datetime.utcnow().isoformat(),
            "models_used": list(predictions.keys()),
            "adjustments_made": len(adjustments_made),
            "adjustment_details": adjustments_made,
            "ml_recommendations_added": len(ml_recommendations),
            "care_history_data_points": len(care_history),
            "prediction_confidence_avg": np.mean([
                pred.confidence for pred in predictions.values()
            ]) if predictions else 0.0
        }
        
        return adjusted_recommendations, ml_metadata
    
    async def _get_care_outcomes(
        self,
        plant_id: UUID,
        days_back: int = 90
    ) -> List[CareOutcome]:
        """Get historical care outcomes for ML training.
        
        Args:
            plant_id: Plant ID
            days_back: Number of days to look back
            
        Returns:
            List of care outcomes
        """
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        
        # Get care logs
        care_result = await self.db.execute(
            select(PlantCareLog)
            .where(
                and_(
                    PlantCareLog.plant_id == plant_id,
                    PlantCareLog.performed_at >= cutoff_date
                )
            )
            .order_by(PlantCareLog.performed_at)
        )
        care_logs = care_result.scalars().all()
        
        # Get health scores from photos
        health_result = await self.db.execute(
            select(GrowthPhoto)
            .where(
                and_(
                    GrowthPhoto.plant_id == plant_id,
                    GrowthPhoto.captured_at >= cutoff_date,
                    GrowthPhoto.health_score.isnot(None)
                )
            )
            .order_by(GrowthPhoto.captured_at)
        )
        health_photos = health_result.scalars().all()
        
        # Correlate care actions with outcomes
        outcomes = []
        
        for care_log in care_logs:
            # Find health score changes after this care action
            outcome_score = self._calculate_care_outcome(
                care_log, health_photos
            )
            
            outcome = CareOutcome(
                care_type=care_log.care_type,
                performed_at=care_log.performed_at,
                parameters=self._extract_care_parameters(care_log),
                outcome_score=outcome_score
            )
            outcomes.append(outcome)
        
        return outcomes
    
    def _calculate_care_outcome(
        self,
        care_log: PlantCareLog,
        health_photos: List[GrowthPhoto]
    ) -> float:
        """Calculate outcome score for a care action.
        
        Args:
            care_log: Care log entry
            health_photos: List of health photos
            
        Returns:
            Outcome score between 0.0 and 1.0
        """
        # Find health scores before and after care action
        care_time = care_log.performed_at
        
        # Get health score within 3 days before care
        before_photos = [
            p for p in health_photos
            if care_time - timedelta(days=3) <= p.captured_at <= care_time
        ]
        
        # Get health score within 7 days after care
        after_photos = [
            p for p in health_photos
            if care_time <= p.captured_at <= care_time + timedelta(days=7)
        ]
        
        if not before_photos or not after_photos:
            return 0.5  # Neutral score if no data
        
        before_score = np.mean([p.health_score for p in before_photos])
        after_score = np.mean([p.health_score for p in after_photos])
        
        # Calculate improvement (0.0 to 1.0)
        improvement = (after_score - before_score + 1.0) / 2.0
        return max(0.0, min(1.0, improvement))
    
    def _extract_care_parameters(self, care_log: PlantCareLog) -> Dict[str, Any]:
        """Extract care parameters from care log.
        
        Args:
            care_log: Care log entry
            
        Returns:
            Dictionary of care parameters
        """
        # This would extract structured parameters from notes or metadata
        # For now, return basic structure
        return {
            "care_type": care_log.care_type,
            "notes": care_log.notes
        }
    
    async def _generate_predictions(
        self,
        plant_id: UUID,
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> Dict[MLModelType, MLPrediction]:
        """Generate ML predictions for different care aspects.
        
        Args:
            plant_id: Plant ID
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            Dictionary of ML predictions by model type
        """
        predictions = {}
        
        # Watering frequency prediction
        if len(care_history) >= 5:  # Minimum data requirement
            watering_pred = self._predict_watering_frequency(
                context, care_history
            )
            predictions[MLModelType.WATERING_FREQUENCY] = watering_pred
        
        # Fertilizer timing prediction
        fertilizer_pred = self._predict_fertilizer_timing(
            context, care_history
        )
        predictions[MLModelType.FERTILIZER_TIMING] = fertilizer_pred
        
        # Light optimization prediction
        light_pred = self._predict_light_optimization(
            context, care_history
        )
        predictions[MLModelType.LIGHT_OPTIMIZATION] = light_pred
        
        # Health prediction
        health_pred = self._predict_health_trend(
            context, care_history
        )
        predictions[MLModelType.HEALTH_PREDICTION] = health_pred
        
        return predictions
    
    def _predict_watering_frequency(
        self,
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> MLPrediction:
        """Predict optimal watering frequency.
        
        Args:
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            ML prediction for watering frequency
        """
        # Simple heuristic-based prediction (would be ML model in production)
        watering_outcomes = [
            outcome for outcome in care_history
            if outcome.care_type == "watering"
        ]
        
        if not watering_outcomes:
            return MLPrediction(
                model_type=MLModelType.WATERING_FREQUENCY,
                prediction={"interval_days": 7, "amount_ml": 200},
                confidence=0.5,
                feature_importance={"default": 1.0},
                model_version="heuristic_v1"
            )
        
        # Analyze successful watering patterns
        successful_waterings = [
            outcome for outcome in watering_outcomes
            if outcome.outcome_score > 0.6
        ]
        
        if successful_waterings:
            # Calculate average interval between successful waterings
            intervals = []
            for i in range(1, len(successful_waterings)):
                interval = (successful_waterings[i].performed_at - 
                           successful_waterings[i-1].performed_at).days
                intervals.append(interval)
            
            optimal_interval = int(np.mean(intervals)) if intervals else 7
        else:
            optimal_interval = 7
        
        # Adjust based on environmental conditions
        env_data = context.get("environmental_data", {})
        if env_data.get("has_data"):
            temp_avg = env_data.get("temperature", {}).get("average", 22)
            humidity_avg = env_data.get("humidity", {}).get("average", 50)
            
            # Adjust for temperature and humidity
            if temp_avg > 25:
                optimal_interval = max(3, optimal_interval - 1)
            if humidity_avg < 40:
                optimal_interval = max(3, optimal_interval - 1)
        
        return MLPrediction(
            model_type=MLModelType.WATERING_FREQUENCY,
            prediction={
                "interval_days": optimal_interval,
                "amount_ml": 200,
                "confidence_factors": {
                    "historical_success": len(successful_waterings),
                    "environmental_adjustment": True
                }
            },
            confidence=min(0.9, 0.5 + len(successful_waterings) * 0.1),
            feature_importance={
                "historical_patterns": 0.6,
                "temperature": 0.2,
                "humidity": 0.2
            },
            model_version="heuristic_v1"
        )
    
    def _predict_fertilizer_timing(
        self,
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> MLPrediction:
        """Predict optimal fertilizer timing.
        
        Args:
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            ML prediction for fertilizer timing
        """
        # Seasonal and growth-based fertilizer prediction
        current_season = context.get("seasonal_context", {}).get("current_season", "spring")
        growth_trend = context.get("growth_patterns", {}).get("growth_trend", "stable")
        
        # Base fertilizer schedule
        if current_season in ["spring", "summer"]:
            base_interval = 14  # Every 2 weeks during growing season
        else:
            base_interval = 28  # Monthly during dormant season
        
        # Adjust based on growth trend
        if growth_trend == "growing":
            base_interval = max(7, base_interval - 7)
        elif growth_trend == "declining":
            base_interval = base_interval + 7
        
        return MLPrediction(
            model_type=MLModelType.FERTILIZER_TIMING,
            prediction={
                "interval_days": base_interval,
                "fertilizer_type": "balanced",
                "season_factor": current_season,
                "growth_factor": growth_trend
            },
            confidence=0.7,
            feature_importance={
                "season": 0.5,
                "growth_trend": 0.3,
                "historical_data": 0.2
            },
            model_version="seasonal_v1"
        )
    
    def _predict_light_optimization(
        self,
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> MLPrediction:
        """Predict optimal light conditions.
        
        Args:
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            ML prediction for light optimization
        """
        env_data = context.get("environmental_data", {})
        plant_info = context.get("plant_info", {})
        
        # Get current light levels
        current_light = 0
        if env_data.get("has_data"):
            current_light = env_data.get("light_intensity", {}).get("average", 0)
        
        # Get species light requirements
        light_req = plant_info.get("light_requirements", "medium")
        
        # Determine optimal light range
        light_ranges = {
            "low": (100, 300),
            "medium": (300, 600),
            "high": (600, 1000)
        }
        
        optimal_range = light_ranges.get(light_req, (300, 600))
        
        return MLPrediction(
            model_type=MLModelType.LIGHT_OPTIMIZATION,
            prediction={
                "current_ppfd": current_light,
                "optimal_min": optimal_range[0],
                "optimal_max": optimal_range[1],
                "adjustment_needed": current_light < optimal_range[0] or current_light > optimal_range[1]
            },
            confidence=0.8,
            feature_importance={
                "species_requirements": 0.6,
                "current_conditions": 0.4
            },
            model_version="light_req_v1"
        )
    
    def _predict_health_trend(
        self,
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> MLPrediction:
        """Predict plant health trend.
        
        Args:
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            ML prediction for health trend
        """
        health_indicators = context.get("plant_health_indicators", {})
        current_trend = health_indicators.get("health_trend", "stable")
        current_score = health_indicators.get("current_health_score", 0.7)
        
        # Predict future health based on current trend and care quality
        care_quality = np.mean([
            outcome.outcome_score for outcome in care_history
        ]) if care_history else 0.5
        
        # Simple trend prediction
        if current_trend == "improving" and care_quality > 0.6:
            predicted_trend = "improving"
            confidence = 0.8
        elif current_trend == "declining" and care_quality < 0.4:
            predicted_trend = "declining"
            confidence = 0.8
        else:
            predicted_trend = "stable"
            confidence = 0.6
        
        return MLPrediction(
            model_type=MLModelType.HEALTH_PREDICTION,
            prediction={
                "predicted_trend": predicted_trend,
                "current_score": current_score,
                "care_quality_score": care_quality,
                "risk_factors": []
            },
            confidence=confidence,
            feature_importance={
                "current_trend": 0.4,
                "care_quality": 0.3,
                "environmental_factors": 0.3
            },
            model_version="health_trend_v1"
        )
    
    async def _adjust_single_recommendation(
        self,
        recommendation: CareRecommendation,
        predictions: Dict[MLModelType, MLPrediction],
        context: Dict[str, Any],
        care_history: List[CareOutcome]
    ) -> Tuple[CareRecommendation, Optional[Dict[str, Any]]]:
        """Adjust a single recommendation based on ML predictions.
        
        Args:
            recommendation: Base recommendation to adjust
            predictions: ML predictions
            context: Plant context data
            care_history: Historical care outcomes
            
        Returns:
            Tuple of (adjusted recommendation, adjustment info)
        """
        adjustment_info = None
        adjusted_rec = recommendation
        
        # Adjust watering recommendations
        if (recommendation.action_type == "watering" and 
            MLModelType.WATERING_FREQUENCY in predictions):
            
            watering_pred = predictions[MLModelType.WATERING_FREQUENCY]
            ml_interval = watering_pred.prediction.get("interval_days", 7)
            
            # Adjust parameters
            new_parameters = recommendation.parameters.copy()
            new_parameters["interval_days"] = ml_interval
            new_parameters["ml_adjusted"] = True
            
            # Adjust confidence based on ML confidence
            new_confidence = (recommendation.confidence + watering_pred.confidence) / 2
            
            adjusted_rec = CareRecommendation(
                action_type=recommendation.action_type,
                priority=recommendation.priority,
                recommendation=recommendation.recommendation,
                parameters=new_parameters,
                confidence=new_confidence,
                reasoning=f"{recommendation.reasoning} (ML-adjusted: {ml_interval} day interval)"
            )
            
            adjustment_info = {
                "type": "watering_frequency",
                "original_interval": recommendation.parameters.get("interval_days"),
                "ml_interval": ml_interval,
                "ml_confidence": watering_pred.confidence
            }
        
        return adjusted_rec, adjustment_info
    
    async def _generate_ml_recommendations(
        self,
        plant_id: UUID,
        predictions: Dict[MLModelType, MLPrediction],
        context: Dict[str, Any]
    ) -> List[CareRecommendation]:
        """Generate additional recommendations based on ML insights.
        
        Args:
            plant_id: Plant ID
            predictions: ML predictions
            context: Plant context data
            
        Returns:
            List of ML-generated recommendations
        """
        ml_recommendations = []
        
        # Health prediction recommendations
        if MLModelType.HEALTH_PREDICTION in predictions:
            health_pred = predictions[MLModelType.HEALTH_PREDICTION]
            predicted_trend = health_pred.prediction.get("predicted_trend")
            
            if predicted_trend == "declining" and health_pred.confidence > 0.7:
                ml_recommendations.append(
                    CareRecommendation(
                        action_type="preventive_care",
                        priority="high",
                        recommendation="Take preventive action as ML models predict declining health",
                        parameters={
                            "predicted_trend": predicted_trend,
                            "confidence": health_pred.confidence
                        },
                        confidence=health_pred.confidence,
                        reasoning="ML health prediction model indicates declining trend"
                    )
                )
        
        # Light optimization recommendations
        if MLModelType.LIGHT_OPTIMIZATION in predictions:
            light_pred = predictions[MLModelType.LIGHT_OPTIMIZATION]
            if light_pred.prediction.get("adjustment_needed"):
                current_ppfd = light_pred.prediction.get("current_ppfd", 0)
                optimal_min = light_pred.prediction.get("optimal_min", 300)
                
                if current_ppfd < optimal_min:
                    ml_recommendations.append(
                        CareRecommendation(
                            action_type="light_adjustment",
                            priority="medium",
                            recommendation=f"Increase light levels from {current_ppfd} to {optimal_min}-{light_pred.prediction.get('optimal_max', 600)} PPFD",
                            parameters=light_pred.prediction,
                            confidence=light_pred.confidence,
                            reasoning="ML light optimization model suggests insufficient light"
                        )
                    )
        
        return ml_recommendations
    
    def _initialize_models(self) -> None:
        """Initialize ML models (placeholder for actual model loading)."""
        # In a production system, this would load trained ML models
        # For now, we use heuristic-based predictions
        self.models = {
            "watering_frequency": "heuristic_v1",
            "fertilizer_timing": "seasonal_v1",
            "light_optimization": "light_req_v1",
            "health_prediction": "health_trend_v1"
        }
    
    async def train_model(
        self,
        model_type: MLModelType,
        training_data: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Train or retrain an ML model (placeholder).
        
        Args:
            model_type: Type of model to train
            training_data: Training data
            
        Returns:
            Training results and metrics
        """
        # Placeholder for actual ML model training
        return {
            "model_type": model_type.value,
            "training_samples": len(training_data),
            "status": "trained",
            "accuracy": 0.85,  # Mock accuracy
            "version": f"{model_type.value}_v2"
        }
    
    def get_model_info(self) -> Dict[str, Any]:
        """Get information about loaded ML models.
        
        Returns:
            Dictionary of model information
        """
        return {
            "models_loaded": len(self.models),
            "model_versions": self.models,
            "last_updated": datetime.utcnow().isoformat()
        }