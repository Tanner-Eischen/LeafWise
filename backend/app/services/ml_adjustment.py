"""ML Adjustment Service for Context-Aware Care Plans v2

This service provides machine learning-based adjustments to rule-based care recommendations.
It uses historical data, plant context, and environmental factors to predict optimal adjustments
with confidence scoring and explainable predictions.

Key Features:
- Historical success pattern analysis
- Environmental factor correlation modeling
- Plant health indicator integration
- User behavior pattern recognition
- Confidence-based adjustment application
- Explainable AI with feature importance
- Fallback to rule-based recommendations
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import statistics
import math

from app.services.context_aggregation import PlantContext, HealthStatus
from app.services.rule_engine import RuleResult
from app.services.environmental_data import EnvironmentalContext, Season

logger = logging.getLogger(__name__)

class MLModelType(Enum):
    """Available ML model types"""
    WATERING_PREDICTOR = "watering_predictor"
    FERTILIZER_OPTIMIZER = "fertilizer_optimizer"
    GROWTH_PREDICTOR = "growth_predictor"
    HEALTH_PREDICTOR = "health_predictor"

class FeatureType(Enum):
    """Feature categories for ML models"""
    ENVIRONMENTAL = "environmental"
    PLANT_HEALTH = "plant_health"
    USER_BEHAVIOR = "user_behavior"
    HISTORICAL = "historical"
    SEASONAL = "seasonal"
    SENSOR_DATA = "sensor_data"

@dataclass
class FeatureImportance:
    """Feature importance for explainable AI"""
    feature_name: str
    importance_score: float  # 0.0-1.0
    feature_type: FeatureType
    current_value: Any
    impact_direction: str  # "positive", "negative", "neutral"
    explanation: str

@dataclass
class MLPrediction:
    """ML model prediction result"""
    # Adjustment factors (-1.0 to 1.0, where 0 = no change)
    watering_adjustment: float = 0.0
    amount_adjustment: float = 0.0
    fertilizer_adjustment: float = 0.0
    
    # Confidence scores (0.0-1.0)
    confidence_score: float = 0.0
    watering_confidence: float = 0.0
    fertilizer_confidence: float = 0.0
    
    # Feature analysis
    feature_importances: List[FeatureImportance] = field(default_factory=list)
    
    # Model metadata
    model_version: str = "v1.0"
    prediction_timestamp: datetime = field(default_factory=datetime.utcnow)
    
    # Explanations
    adjustment_rationale: str = ""
    confidence_explanation: str = ""
    
    # Quality indicators
    data_quality_score: float = 0.0
    prediction_uncertainty: float = 0.0

class MLAdjustmentService:
    """Service for ML-based care plan adjustments"""
    
    def __init__(self):
        # Model configuration (would be loaded from config in production)
        self.model_config = {
            'watering_predictor': {
                'version': 'v1.2',
                'confidence_threshold': 0.7,
                'max_adjustment': 0.3,
                'enabled': True
            },
            'fertilizer_optimizer': {
                'version': 'v1.0',
                'confidence_threshold': 0.8,
                'max_adjustment': 0.2,
                'enabled': True
            }
        }
        
        # Feature weights for different model types
        self.feature_weights = {
            'historical_success': 0.4,
            'environmental_factors': 0.3,
            'plant_health_indicators': 0.2,
            'user_behavior': 0.1
        }
        
        # Seasonal adjustment factors
        self.seasonal_factors = {
            Season.SPRING: {'growth_multiplier': 1.2, 'water_multiplier': 1.1},
            Season.SUMMER: {'growth_multiplier': 1.3, 'water_multiplier': 1.2},
            Season.FALL: {'growth_multiplier': 0.8, 'water_multiplier': 0.9},
            Season.WINTER: {'growth_multiplier': 0.6, 'water_multiplier': 0.8}
        }
    
    async def predict_adjustments(
        self, 
        context: PlantContext, 
        rule_result: RuleResult,
        target_days: int = 14
    ) -> MLPrediction:
        """Predict ML-based adjustments to rule recommendations
        
        Args:
            context: Complete plant context
            rule_result: Rule-based recommendations
            target_days: Prediction horizon in days
            
        Returns:
            ML prediction with adjustments and confidence scores
        """
        try:
            logger.info(f"Generating ML adjustments for plant {context.plant_id}")
            
            # Extract features from context
            features = await self._extract_features(context, rule_result)
            
            # Generate predictions for different aspects
            watering_prediction = await self._predict_watering_adjustment(features, context)
            fertilizer_prediction = await self._predict_fertilizer_adjustment(features, context)
            
            # Combine predictions
            prediction = MLPrediction(
                watering_adjustment=watering_prediction['adjustment'],
                amount_adjustment=watering_prediction['amount_adjustment'],
                fertilizer_adjustment=fertilizer_prediction['adjustment'],
                confidence_score=self._calculate_overall_confidence(watering_prediction, fertilizer_prediction),
                watering_confidence=watering_prediction['confidence'],
                fertilizer_confidence=fertilizer_prediction['confidence'],
                data_quality_score=context.confidence_score
            )
            
            # Generate feature importance analysis
            prediction.feature_importances = await self._analyze_feature_importance(features, prediction)
            
            # Generate explanations
            prediction.adjustment_rationale = self._generate_adjustment_rationale(prediction, features)
            prediction.confidence_explanation = self._generate_confidence_explanation(prediction, context)
            
            # Calculate prediction uncertainty
            prediction.prediction_uncertainty = self._calculate_uncertainty(prediction, features)
            
            # Apply confidence thresholds and constraints
            prediction = self._apply_confidence_thresholds(prediction)
            
            logger.info(f"ML adjustments generated (confidence: {prediction.confidence_score:.2f})")
            return prediction
            
        except Exception as e:
            logger.error(f"Error generating ML adjustments for plant {context.plant_id}: {e}")
            return self._get_fallback_prediction()
    
    async def _extract_features(self, context: PlantContext, rule_result: RuleResult) -> Dict[str, Any]:
        """Extract features for ML models from plant context"""
        features = {}
        
        # Environmental features
        if context.environmental_context:
            env = context.environmental_context
            features.update({
                'temperature': env.temperature,
                'humidity': env.humidity,
                'light_ppfd': env.light_ppfd or 0,
                'season': env.season.value,
                'temp_trend': env.temp_trend,
                'humidity_trend': env.humidity_trend,
                'heatwave_days': env.heatwave_days,
                'cold_snap_days': env.cold_snap_days,
                'drought_days': env.drought_days,
                'day_length_hours': env.day_length_hours
            })
        
        # Plant health features
        health = context.health_context
        features.update({
            'health_score': health.health_score,
            'growth_rate': health.growth_rate or 0,
            'leaf_condition_score': health.leaf_condition_score,
            'health_trend': health.health_trend,
            'stress_indicator_count': len(health.stress_indicators),
            'new_growth': 1 if health.new_growth else 0,
            'days_since_assessment': health.last_assessment_days
        })
        
        # User behavior features
        behavior = context.user_behavior_context
        features.update({
            'watering_consistency': behavior.watering_consistency,
            'care_frequency_days': behavior.care_frequency_days,
            'plan_adherence_rate': behavior.plan_adherence_rate,
            'avg_watering_amount': behavior.avg_watering_amount_ml or 0,
            'days_since_last_care': behavior.last_care_action_days,
            'overwatering_tendency': behavior.overwatering_tendency,
            'underwatering_tendency': behavior.underwatering_tendency
        })
        
        # Historical features
        historical = context.historical_context
        features.update({
            'historical_success_rate': historical.successful_plans / max(historical.total_plans, 1),
            'total_plans': historical.total_plans,
            'avg_plan_duration': historical.avg_plan_duration_days
        })
        
        # Sensor features
        sensor = context.sensor_context
        features.update({
            'sensor_temperature': sensor.temperature_avg or 0,
            'sensor_humidity': sensor.humidity_avg or 0,
            'sensor_light': sensor.light_ppfd_avg or 0,
            'sensor_soil_moisture': sensor.soil_moisture_avg or 0,
            'sensor_reliability': sensor.reliability_score,
            'data_freshness_hours': sensor.data_freshness_hours
        })
        
        # Plant characteristics
        features.update({
            'plant_age_days': context.age_days or 0,
            'pot_size_liters': context.pot_size_liters or 2,
            'location_indoor': 1 if context.location_indoor else 0
        })
        
        # Rule-based baseline
        features.update({
            'rule_watering_interval': rule_result.watering_interval_days,
            'rule_watering_amount': rule_result.watering_amount_ml,
            'rule_fertilizer_interval': rule_result.fertilizer_interval_days,
            'rule_confidence': rule_result.confidence_score
        })
        
        return features
    
    async def _predict_watering_adjustment(self, features: Dict[str, Any], context: PlantContext) -> Dict[str, Any]:
        """Predict watering frequency and amount adjustments"""
        # Simplified ML model simulation - in production, this would use trained models
        
        adjustment_factors = []
        confidence_factors = []
        
        # Environmental factors
        if features.get('temperature', 20) > 28:  # Hot conditions
            adjustment_factors.append(-0.15)  # Water more frequently
            confidence_factors.append(0.8)
        elif features.get('temperature', 20) < 15:  # Cool conditions
            adjustment_factors.append(0.1)  # Water less frequently
            confidence_factors.append(0.7)
        
        if features.get('humidity', 50) < 40:  # Low humidity
            adjustment_factors.append(-0.1)  # Water more frequently
            confidence_factors.append(0.75)
        elif features.get('humidity', 50) > 70:  # High humidity
            adjustment_factors.append(0.1)  # Water less frequently
            confidence_factors.append(0.75)
        
        # Health-based adjustments
        health_score = features.get('health_score', 0.5)
        if health_score < 0.3:  # Poor health
            adjustment_factors.append(-0.2)  # More frequent care
            confidence_factors.append(0.9)
        elif health_score > 0.8:  # Excellent health
            adjustment_factors.append(0.05)  # Maintain current schedule
            confidence_factors.append(0.8)
        
        # Growth rate adjustments
        growth_rate = features.get('growth_rate', 0)
        if growth_rate > 1.0:  # Fast growth
            adjustment_factors.append(-0.1)  # More frequent watering
            confidence_factors.append(0.7)
        
        # User behavior adjustments
        consistency = features.get('watering_consistency', 0.5)
        if consistency < 0.3:  # Inconsistent watering
            adjustment_factors.append(0.05)  # Slightly less frequent to account for inconsistency
            confidence_factors.append(0.6)
        
        # Historical success adjustments
        success_rate = features.get('historical_success_rate', 0.5)
        if success_rate > 0.8:  # High success rate
            confidence_factors.append(0.9)
        elif success_rate < 0.3:  # Low success rate
            adjustment_factors.append(-0.1)  # Try more frequent care
            confidence_factors.append(0.5)
        
        # Seasonal adjustments
        season = features.get('season', 'spring')
        seasonal_factor = self.seasonal_factors.get(Season(season), {}).get('water_multiplier', 1.0)
        seasonal_adjustment = (seasonal_factor - 1.0) * 0.5  # Moderate the seasonal effect
        adjustment_factors.append(-seasonal_adjustment)  # Negative because more water = shorter interval
        confidence_factors.append(0.8)
        
        # Calculate final adjustment
        if adjustment_factors:
            watering_adjustment = statistics.mean(adjustment_factors)
            # Clamp to maximum adjustment
            watering_adjustment = max(-0.3, min(0.3, watering_adjustment))
        else:
            watering_adjustment = 0.0
        
        # Amount adjustment (correlated with frequency but smaller)
        amount_adjustment = watering_adjustment * 0.5
        
        # Calculate confidence
        if confidence_factors:
            confidence = statistics.mean(confidence_factors)
            # Reduce confidence based on data quality
            confidence *= features.get('sensor_reliability', 0.5)
            confidence *= context.confidence_score
        else:
            confidence = 0.3
        
        return {
            'adjustment': watering_adjustment,
            'amount_adjustment': amount_adjustment,
            'confidence': min(1.0, confidence),
            'factors_considered': len(adjustment_factors)
        }
    
    async def _predict_fertilizer_adjustment(self, features: Dict[str, Any], context: PlantContext) -> Dict[str, Any]:
        """Predict fertilizer frequency adjustments"""
        adjustment_factors = []
        confidence_factors = []
        
        # Growth-based adjustments
        growth_rate = features.get('growth_rate', 0)
        if growth_rate > 1.0:  # Fast growth
            adjustment_factors.append(-0.2)  # More frequent fertilizing
            confidence_factors.append(0.8)
        elif growth_rate < 0.1:  # Slow growth
            adjustment_factors.append(0.1)  # Less frequent fertilizing
            confidence_factors.append(0.7)
        
        # Health-based adjustments
        health_score = features.get('health_score', 0.5)
        if health_score < 0.4:  # Poor health might need nutrients
            adjustment_factors.append(-0.15)
            confidence_factors.append(0.7)
        
        # Seasonal adjustments
        season = features.get('season', 'spring')
        if season in ['spring', 'summer']:  # Growing seasons
            adjustment_factors.append(-0.1)  # More frequent fertilizing
            confidence_factors.append(0.8)
        elif season == 'winter':  # Dormant season
            adjustment_factors.append(0.2)  # Less frequent fertilizing
            confidence_factors.append(0.9)
        
        # Plant age adjustments
        age_days = features.get('plant_age_days', 0)
        if age_days < 90:  # Young plant
            adjustment_factors.append(-0.1)  # More frequent feeding
            confidence_factors.append(0.7)
        
        # Calculate final adjustment
        if adjustment_factors:
            fertilizer_adjustment = statistics.mean(adjustment_factors)
            # Clamp to maximum adjustment
            fertilizer_adjustment = max(-0.2, min(0.2, fertilizer_adjustment))
        else:
            fertilizer_adjustment = 0.0
        
        # Calculate confidence
        if confidence_factors:
            confidence = statistics.mean(confidence_factors)
            confidence *= features.get('sensor_reliability', 0.5)
            confidence *= context.confidence_score
        else:
            confidence = 0.3
        
        return {
            'adjustment': fertilizer_adjustment,
            'confidence': min(1.0, confidence),
            'factors_considered': len(adjustment_factors)
        }
    
    def _calculate_overall_confidence(self, watering_pred: Dict[str, Any], fertilizer_pred: Dict[str, Any]) -> float:
        """Calculate overall prediction confidence"""
        watering_conf = watering_pred['confidence']
        fertilizer_conf = fertilizer_pred['confidence']
        
        # Weight watering confidence higher as it's more critical
        overall_confidence = (watering_conf * 0.7) + (fertilizer_conf * 0.3)
        
        return min(1.0, overall_confidence)
    
    async def _analyze_feature_importance(self, features: Dict[str, Any], prediction: MLPrediction) -> List[FeatureImportance]:
        """Analyze feature importance for explainable AI"""
        importances = []
        
        # Environmental features
        if abs(features.get('temperature', 20) - 22) > 5:  # Significant temperature deviation
            importance = min(1.0, abs(features.get('temperature', 20) - 22) / 15)
            importances.append(FeatureImportance(
                feature_name="temperature",
                importance_score=importance,
                feature_type=FeatureType.ENVIRONMENTAL,
                current_value=features.get('temperature'),
                impact_direction="positive" if features.get('temperature', 20) > 25 else "negative",
                explanation=f"Temperature of {features.get('temperature', 20):.1f}°C affects watering needs"
            ))
        
        # Health features
        health_score = features.get('health_score', 0.5)
        if health_score < 0.5 or health_score > 0.8:
            importance = abs(health_score - 0.65) / 0.35  # Distance from "good" health
            importances.append(FeatureImportance(
                feature_name="plant_health",
                importance_score=importance,
                feature_type=FeatureType.PLANT_HEALTH,
                current_value=health_score,
                impact_direction="positive" if health_score > 0.8 else "negative",
                explanation=f"Plant health score of {health_score:.2f} influences care frequency"
            ))
        
        # Growth rate
        growth_rate = features.get('growth_rate', 0)
        if growth_rate > 0.5:
            importance = min(1.0, growth_rate / 2.0)
            importances.append(FeatureImportance(
                feature_name="growth_rate",
                importance_score=importance,
                feature_type=FeatureType.PLANT_HEALTH,
                current_value=growth_rate,
                impact_direction="positive",
                explanation=f"Growth rate of {growth_rate:.1f} cm/week indicates active growth"
            ))
        
        # User behavior
        consistency = features.get('watering_consistency', 0.5)
        if consistency < 0.5:
            importance = (0.5 - consistency) / 0.5
            importances.append(FeatureImportance(
                feature_name="watering_consistency",
                importance_score=importance,
                feature_type=FeatureType.USER_BEHAVIOR,
                current_value=consistency,
                impact_direction="negative",
                explanation=f"Watering consistency of {consistency:.2f} affects recommendation reliability"
            ))
        
        # Seasonal factors
        season = features.get('season', 'spring')
        if season in ['summer', 'winter']:
            importances.append(FeatureImportance(
                feature_name="season",
                importance_score=0.6,
                feature_type=FeatureType.SEASONAL,
                current_value=season,
                impact_direction="positive" if season == 'summer' else "negative",
                explanation=f"Current season ({season}) affects plant water and nutrient needs"
            ))
        
        # Sort by importance score
        importances.sort(key=lambda x: x.importance_score, reverse=True)
        
        return importances[:5]  # Return top 5 most important features
    
    def _generate_adjustment_rationale(self, prediction: MLPrediction, features: Dict[str, Any]) -> str:
        """Generate human-readable rationale for adjustments"""
        rationale_parts = []
        
        if abs(prediction.watering_adjustment) > 0.05:
            direction = "increased" if prediction.watering_adjustment < 0 else "decreased"
            percentage = abs(prediction.watering_adjustment) * 100
            rationale_parts.append(f"Watering frequency {direction} by {percentage:.0f}%")
        
        if abs(prediction.fertilizer_adjustment) > 0.05:
            direction = "increased" if prediction.fertilizer_adjustment < 0 else "decreased"
            percentage = abs(prediction.fertilizer_adjustment) * 100
            rationale_parts.append(f"Fertilizer frequency {direction} by {percentage:.0f}%")
        
        # Add key factors
        key_factors = []
        for importance in prediction.feature_importances[:3]:
            if importance.importance_score > 0.3:
                key_factors.append(importance.feature_name.replace('_', ' '))
        
        if key_factors:
            rationale_parts.append(f"Based on: {', '.join(key_factors)}")
        
        if not rationale_parts:
            return "No significant adjustments recommended - rule-based plan is optimal"
        
        return ". ".join(rationale_parts) + "."
    
    def _generate_confidence_explanation(self, prediction: MLPrediction, context: PlantContext) -> str:
        """Generate explanation for confidence score"""
        confidence = prediction.confidence_score
        
        if confidence > 0.8:
            return "High confidence based on comprehensive data and strong historical patterns"
        elif confidence > 0.6:
            return "Good confidence with adequate data quality and some historical context"
        elif confidence > 0.4:
            return "Moderate confidence - limited data or mixed historical outcomes"
        else:
            return "Low confidence due to insufficient data or conflicting patterns"
    
    def _calculate_uncertainty(self, prediction: MLPrediction, features: Dict[str, Any]) -> float:
        """Calculate prediction uncertainty"""
        uncertainty_factors = []
        
        # Data quality uncertainty
        data_quality = features.get('sensor_reliability', 0.5)
        uncertainty_factors.append(1.0 - data_quality)
        
        # Historical data uncertainty
        total_plans = features.get('total_plans', 0)
        if total_plans < 3:
            uncertainty_factors.append(0.5)  # High uncertainty with little history
        
        # Feature consistency uncertainty
        if len(prediction.feature_importances) < 3:
            uncertainty_factors.append(0.3)  # Fewer features = more uncertainty
        
        # Model agreement uncertainty (simulated)
        if abs(prediction.watering_adjustment) > 0.2:
            uncertainty_factors.append(0.2)  # Large adjustments are less certain
        
        return statistics.mean(uncertainty_factors) if uncertainty_factors else 0.3
    
    def _apply_confidence_thresholds(self, prediction: MLPrediction) -> MLPrediction:
        """Apply confidence thresholds and constraints"""
        watering_config = self.model_config.get('watering_predictor', {})
        fertilizer_config = self.model_config.get('fertilizer_optimizer', {})
        
        # Apply watering confidence threshold
        watering_threshold = watering_config.get('confidence_threshold', 0.7)
        if prediction.watering_confidence < watering_threshold:
            prediction.watering_adjustment = 0.0
            prediction.amount_adjustment = 0.0
        
        # Apply fertilizer confidence threshold
        fertilizer_threshold = fertilizer_config.get('confidence_threshold', 0.8)
        if prediction.fertilizer_confidence < fertilizer_threshold:
            prediction.fertilizer_adjustment = 0.0
        
        # Apply maximum adjustment constraints
        max_watering_adj = watering_config.get('max_adjustment', 0.3)
        prediction.watering_adjustment = max(-max_watering_adj, min(max_watering_adj, prediction.watering_adjustment))
        
        max_fertilizer_adj = fertilizer_config.get('max_adjustment', 0.2)
        prediction.fertilizer_adjustment = max(-max_fertilizer_adj, min(max_fertilizer_adj, prediction.fertilizer_adjustment))
        
        # Recalculate overall confidence after thresholding
        if prediction.watering_adjustment == 0.0 and prediction.fertilizer_adjustment == 0.0:
            prediction.confidence_score = min(prediction.confidence_score, 0.5)
        
        return prediction
    
    def _get_fallback_prediction(self) -> MLPrediction:
        """Get fallback prediction when ML processing fails"""
        return MLPrediction(
            watering_adjustment=0.0,
            amount_adjustment=0.0,
            fertilizer_adjustment=0.0,
            confidence_score=0.3,
            watering_confidence=0.3,
            fertilizer_confidence=0.3,
            adjustment_rationale="ML adjustment unavailable - using rule-based recommendations",
            confidence_explanation="Fallback to rule-based system due to ML processing error",
            data_quality_score=0.3
        )

# Dependency injection helper
def get_ml_adjustment_service():
    """Get ML adjustment service instance"""
    return MLAdjustmentService()