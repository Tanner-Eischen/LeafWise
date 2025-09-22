"""Rationale builder service.

This module provides explainable AI functionality for care plan recommendations.
It generates human-readable explanations for why specific care actions are recommended,
including the reasoning behind ML adjustments and rule-based decisions.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID
from dataclasses import dataclass
from enum import Enum

from app.services.rule_engine_service import CareRecommendation, CareRule
from app.services.ml_adjustment_service import MLPrediction, MLModelType


class ExplanationType(Enum):
    """Types of explanations that can be generated."""
    RULE_BASED = "rule_based"
    ML_PREDICTION = "ml_prediction"
    CONTEXTUAL = "contextual"
    HISTORICAL = "historical"
    ENVIRONMENTAL = "environmental"
    SEASONAL = "seasonal"


@dataclass
class ExplanationComponent:
    """Represents a single component of an explanation."""
    type: ExplanationType
    title: str
    description: str
    confidence: float
    supporting_data: Dict[str, Any]
    weight: float = 1.0


@dataclass
class CareRationale:
    """Complete rationale for a care recommendation."""
    recommendation_id: str
    action_type: str
    primary_reason: str
    explanation_components: List[ExplanationComponent]
    confidence_score: float
    data_sources: List[str]
    generated_at: datetime
    user_friendly_summary: str
    technical_details: Dict[str, Any]


class RationaleBuilderService:
    """Service for building explainable AI rationales for care recommendations."""
    
    def __init__(self):
        """Initialize the rationale builder service."""
        self.explanation_templates = self._load_explanation_templates()
    
    def build_care_plan_rationale(
        self,
        recommendations: List[CareRecommendation],
        context: Dict[str, Any],
        applied_rules: List[Dict[str, Any]],
        ml_predictions: Dict[MLModelType, MLPrediction],
        ml_adjustments: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Build comprehensive rationale for an entire care plan.
        
        Args:
            recommendations: List of care recommendations
            context: Plant context data
            applied_rules: Rules that were applied
            ml_predictions: ML model predictions
            ml_adjustments: ML adjustments made
            
        Returns:
            Complete care plan rationale
        """
        # Build rationale for each recommendation
        recommendation_rationales = []
        for i, recommendation in enumerate(recommendations):
            rationale = self.build_recommendation_rationale(
                recommendation, context, applied_rules, ml_predictions, ml_adjustments, i
            )
            recommendation_rationales.append(rationale)
        
        # Build overall plan rationale
        plan_rationale = self._build_plan_level_rationale(
            recommendations, context, applied_rules, ml_predictions
        )
        
        return {
            "plan_rationale": plan_rationale,
            "recommendation_rationales": [r.__dict__ for r in recommendation_rationales],
            "generation_metadata": {
                "generated_at": datetime.utcnow().isoformat(),
                "total_recommendations": len(recommendations),
                "rules_applied": len(applied_rules),
                "ml_models_used": len(ml_predictions),
                "adjustments_made": len(ml_adjustments)
            }
        }
    
    def build_recommendation_rationale(
        self,
        recommendation: CareRecommendation,
        context: Dict[str, Any],
        applied_rules: List[Dict[str, Any]],
        ml_predictions: Dict[MLModelType, MLPrediction],
        ml_adjustments: List[Dict[str, Any]],
        rec_index: int
    ) -> CareRationale:
        """Build rationale for a single recommendation.
        
        Args:
            recommendation: Care recommendation
            context: Plant context data
            applied_rules: Rules that were applied
            ml_predictions: ML model predictions
            ml_adjustments: ML adjustments made
            rec_index: Index of recommendation in list
            
        Returns:
            Complete rationale for the recommendation
        """
        explanation_components = []
        
        # Add rule-based explanations
        rule_components = self._build_rule_explanations(
            recommendation, applied_rules, context
        )
        explanation_components.extend(rule_components)
        
        # Add ML-based explanations
        ml_components = self._build_ml_explanations(
            recommendation, ml_predictions, ml_adjustments
        )
        explanation_components.extend(ml_components)
        
        # Add contextual explanations
        context_components = self._build_contextual_explanations(
            recommendation, context
        )
        explanation_components.extend(context_components)
        
        # Add environmental explanations
        env_components = self._build_environmental_explanations(
            recommendation, context
        )
        explanation_components.extend(env_components)
        
        # Add seasonal explanations
        seasonal_components = self._build_seasonal_explanations(
            recommendation, context
        )
        explanation_components.extend(seasonal_components)
        
        # Generate primary reason and summary
        primary_reason = self._determine_primary_reason(explanation_components)
        user_summary = self._generate_user_friendly_summary(
            recommendation, explanation_components, context
        )
        
        # Calculate overall confidence
        overall_confidence = self._calculate_overall_confidence(
            recommendation, explanation_components
        )
        
        # Collect data sources
        data_sources = self._collect_data_sources(explanation_components, context)
        
        return CareRationale(
            recommendation_id=f"rec_{rec_index}",
            action_type=recommendation.action_type,
            primary_reason=primary_reason,
            explanation_components=explanation_components,
            confidence_score=overall_confidence,
            data_sources=data_sources,
            generated_at=datetime.utcnow(),
            user_friendly_summary=user_summary,
            technical_details={
                "original_confidence": recommendation.confidence,
                "reasoning": recommendation.reasoning,
                "parameters": recommendation.parameters
            }
        )
    
    def _build_rule_explanations(
        self,
        recommendation: CareRecommendation,
        applied_rules: List[Dict[str, Any]],
        context: Dict[str, Any]
    ) -> List[ExplanationComponent]:
        """Build explanations based on applied rules.
        
        Args:
            recommendation: Care recommendation
            applied_rules: Rules that were applied
            context: Plant context data
            
        Returns:
            List of rule-based explanation components
        """
        components = []
        
        for rule_info in applied_rules:
            if rule_info.get("recommendations_count", 0) > 0:
                component = ExplanationComponent(
                    type=ExplanationType.RULE_BASED,
                    title=f"Care Rule: {rule_info.get('name', 'Unknown')}",
                    description=f"This recommendation is based on the '{rule_info.get('name')}' care rule, which scored {rule_info.get('score', 0):.2f} based on your plant's current conditions.",
                    confidence=rule_info.get("score", 0.5),
                    supporting_data={
                        "rule_id": rule_info.get("rule_id"),
                        "rule_name": rule_info.get("name"),
                        "rule_score": rule_info.get("score"),
                        "recommendations_generated": rule_info.get("recommendations_count")
                    },
                    weight=0.8
                )
                components.append(component)
        
        return components
    
    def _build_ml_explanations(
        self,
        recommendation: CareRecommendation,
        ml_predictions: Dict[MLModelType, MLPrediction],
        ml_adjustments: List[Dict[str, Any]]
    ) -> List[ExplanationComponent]:
        """Build explanations based on ML predictions and adjustments.
        
        Args:
            recommendation: Care recommendation
            ml_predictions: ML model predictions
            ml_adjustments: ML adjustments made
            
        Returns:
            List of ML-based explanation components
        """
        components = []
        
        # Find relevant ML adjustments for this recommendation
        relevant_adjustments = [
            adj for adj in ml_adjustments
            if adj.get("type", "").startswith(recommendation.action_type)
        ]
        
        for adjustment in relevant_adjustments:
            component = ExplanationComponent(
                type=ExplanationType.ML_PREDICTION,
                title="Machine Learning Adjustment",
                description=self._generate_ml_explanation(adjustment, recommendation),
                confidence=adjustment.get("ml_confidence", 0.7),
                supporting_data=adjustment,
                weight=0.7
            )
            components.append(component)
        
        # Add explanations for relevant ML predictions
        for model_type, prediction in ml_predictions.items():
            if self._is_prediction_relevant(model_type, recommendation):
                component = ExplanationComponent(
                    type=ExplanationType.ML_PREDICTION,
                    title=f"ML Model: {model_type.value.replace('_', ' ').title()}",
                    description=self._generate_prediction_explanation(prediction, recommendation),
                    confidence=prediction.confidence,
                    supporting_data={
                        "model_type": model_type.value,
                        "prediction": prediction.prediction,
                        "model_version": prediction.model_version,
                        "feature_importance": prediction.feature_importance
                    },
                    weight=0.6
                )
                components.append(component)
        
        return components
    
    def _build_contextual_explanations(
        self,
        recommendation: CareRecommendation,
        context: Dict[str, Any]
    ) -> List[ExplanationComponent]:
        """Build explanations based on plant context.
        
        Args:
            recommendation: Care recommendation
            context: Plant context data
            
        Returns:
            List of contextual explanation components
        """
        components = []
        
        plant_info = context.get("plant_info", {})
        care_history = context.get("care_history", {})
        
        # Plant age and maturity
        plant_age_days = plant_info.get("plant_age_days", 0)
        if plant_age_days > 0:
            age_explanation = self._generate_age_explanation(
                plant_age_days, recommendation
            )
            if age_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.CONTEXTUAL,
                    title="Plant Maturity Factor",
                    description=age_explanation,
                    confidence=0.8,
                    supporting_data={"plant_age_days": plant_age_days},
                    weight=0.5
                )
                components.append(component)
        
        # Care history patterns
        total_care_events = care_history.get("total_care_events", 0)
        if total_care_events > 0:
            history_explanation = self._generate_history_explanation(
                care_history, recommendation
            )
            if history_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.HISTORICAL,
                    title="Care History Pattern",
                    description=history_explanation,
                    confidence=0.7,
                    supporting_data=care_history,
                    weight=0.6
                )
                components.append(component)
        
        return components
    
    def _build_environmental_explanations(
        self,
        recommendation: CareRecommendation,
        context: Dict[str, Any]
    ) -> List[ExplanationComponent]:
        """Build explanations based on environmental conditions.
        
        Args:
            recommendation: Care recommendation
            context: Plant context data
            
        Returns:
            List of environmental explanation components
        """
        components = []
        
        env_data = context.get("environmental_data", {})
        if not env_data.get("has_data"):
            return components
        
        # Temperature explanations
        temp_data = env_data.get("temperature", {})
        if temp_data.get("average"):
            temp_explanation = self._generate_temperature_explanation(
                temp_data, recommendation
            )
            if temp_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.ENVIRONMENTAL,
                    title="Temperature Conditions",
                    description=temp_explanation,
                    confidence=0.8,
                    supporting_data=temp_data,
                    weight=0.7
                )
                components.append(component)
        
        # Humidity explanations
        humidity_data = env_data.get("humidity", {})
        if humidity_data.get("average"):
            humidity_explanation = self._generate_humidity_explanation(
                humidity_data, recommendation
            )
            if humidity_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.ENVIRONMENTAL,
                    title="Humidity Levels",
                    description=humidity_explanation,
                    confidence=0.8,
                    supporting_data=humidity_data,
                    weight=0.7
                )
                components.append(component)
        
        # Light explanations
        light_data = env_data.get("light_intensity", {})
        if light_data.get("average"):
            light_explanation = self._generate_light_explanation(
                light_data, recommendation
            )
            if light_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.ENVIRONMENTAL,
                    title="Light Conditions",
                    description=light_explanation,
                    confidence=0.8,
                    supporting_data=light_data,
                    weight=0.7
                )
                components.append(component)
        
        return components
    
    def _build_seasonal_explanations(
        self,
        recommendation: CareRecommendation,
        context: Dict[str, Any]
    ) -> List[ExplanationComponent]:
        """Build explanations based on seasonal factors.
        
        Args:
            recommendation: Care recommendation
            context: Plant context data
            
        Returns:
            List of seasonal explanation components
        """
        components = []
        
        seasonal_context = context.get("seasonal_context", {})
        current_season = seasonal_context.get("current_season")
        
        if current_season:
            seasonal_explanation = self._generate_seasonal_explanation(
                current_season, recommendation
            )
            if seasonal_explanation:
                component = ExplanationComponent(
                    type=ExplanationType.SEASONAL,
                    title=f"Seasonal Factor: {current_season.title()}",
                    description=seasonal_explanation,
                    confidence=0.9,
                    supporting_data=seasonal_context,
                    weight=0.8
                )
                components.append(component)
        
        return components
    
    def _generate_ml_explanation(
        self,
        adjustment: Dict[str, Any],
        recommendation: CareRecommendation
    ) -> str:
        """Generate explanation for ML adjustment.
        
        Args:
            adjustment: ML adjustment information
            recommendation: Care recommendation
            
        Returns:
            Human-readable explanation
        """
        adj_type = adjustment.get("type", "")
        
        if adj_type == "watering_frequency":
            original = adjustment.get("original_interval")
            ml_interval = adjustment.get("ml_interval")
            return f"Based on your plant's historical care patterns, the watering interval was adjusted from {original} to {ml_interval} days for optimal results."
        
        return "Machine learning models have adjusted this recommendation based on historical data and plant response patterns."
    
    def _generate_prediction_explanation(
        self,
        prediction: MLPrediction,
        recommendation: CareRecommendation
    ) -> str:
        """Generate explanation for ML prediction.
        
        Args:
            prediction: ML prediction
            recommendation: Care recommendation
            
        Returns:
            Human-readable explanation
        """
        model_type = prediction.model_type
        confidence = prediction.confidence
        
        if model_type == MLModelType.WATERING_FREQUENCY:
            interval = prediction.prediction.get("interval_days", 7)
            return f"ML analysis suggests watering every {interval} days based on environmental conditions and plant response patterns (confidence: {confidence:.1%})."
        elif model_type == MLModelType.HEALTH_PREDICTION:
            trend = prediction.prediction.get("predicted_trend", "stable")
            return f"Health prediction model forecasts a {trend} trend for your plant (confidence: {confidence:.1%})."
        
        return f"ML model {model_type.value} contributed to this recommendation with {confidence:.1%} confidence."
    
    def _generate_age_explanation(
        self,
        age_days: int,
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on plant age.
        
        Args:
            age_days: Plant age in days
            recommendation: Care recommendation
            
        Returns:
            Age-based explanation or None
        """
        if age_days < 30:
            return "As a young plant (less than 1 month old), it requires gentle care and close monitoring."
        elif age_days < 90:
            return "Your plant is in its establishment phase (1-3 months), requiring consistent care to develop strong roots."
        elif age_days < 365:
            return "Your plant is maturing (3-12 months) and developing its full care requirements."
        else:
            return "As an established plant (over 1 year), it has developed stable care patterns and resilience."
    
    def _generate_history_explanation(
        self,
        care_history: Dict[str, Any],
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on care history.
        
        Args:
            care_history: Care history data
            recommendation: Care recommendation
            
        Returns:
            History-based explanation or None
        """
        total_events = care_history.get("total_care_events", 0)
        care_summary = care_history.get("care_summary", {})
        
        if recommendation.action_type == "watering" and "watering" in care_summary:
            watering_count = care_summary["watering"].get("count", 0)
            if watering_count > 0:
                return f"Based on your {watering_count} previous watering sessions, this timing aligns with your plant's established care pattern."
        
        if total_events > 10:
            return "Your consistent care history helps inform the timing and approach for this recommendation."
        elif total_events > 0:
            return "Building on your recent care activities to establish a healthy routine."
        
        return None
    
    def _generate_temperature_explanation(
        self,
        temp_data: Dict[str, Any],
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on temperature.
        
        Args:
            temp_data: Temperature data
            recommendation: Care recommendation
            
        Returns:
            Temperature-based explanation or None
        """
        avg_temp = temp_data.get("average", 22)
        
        if avg_temp > 26:
            return f"Higher temperatures ({avg_temp:.1f}°C) increase water evaporation and plant stress, influencing this care recommendation."
        elif avg_temp < 18:
            return f"Cooler temperatures ({avg_temp:.1f}°C) slow plant metabolism, affecting the timing of care activities."
        
        return None
    
    def _generate_humidity_explanation(
        self,
        humidity_data: Dict[str, Any],
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on humidity.
        
        Args:
            humidity_data: Humidity data
            recommendation: Care recommendation
            
        Returns:
            Humidity-based explanation or None
        """
        avg_humidity = humidity_data.get("average", 50)
        
        if avg_humidity < 40:
            return f"Low humidity levels ({avg_humidity:.1f}%) increase water loss and may require more frequent care."
        elif avg_humidity > 70:
            return f"High humidity levels ({avg_humidity:.1f}%) reduce water loss and may extend care intervals."
        
        return None
    
    def _generate_light_explanation(
        self,
        light_data: Dict[str, Any],
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on light conditions.
        
        Args:
            light_data: Light data
            recommendation: Care recommendation
            
        Returns:
            Light-based explanation or None
        """
        avg_light = light_data.get("average", 300)
        
        if recommendation.action_type == "light_adjustment":
            if avg_light < 200:
                return f"Current light levels ({avg_light:.0f} PPFD) are below optimal range for healthy growth."
            elif avg_light > 800:
                return f"Current light levels ({avg_light:.0f} PPFD) may be too intense and could stress the plant."
        
        return None
    
    def _generate_seasonal_explanation(
        self,
        season: str,
        recommendation: CareRecommendation
    ) -> Optional[str]:
        """Generate explanation based on season.
        
        Args:
            season: Current season
            recommendation: Care recommendation
            
        Returns:
            Season-based explanation or None
        """
        seasonal_explanations = {
            "spring": "Spring is the active growing season, requiring more frequent care and nutrition.",
            "summer": "Summer heat and longer days increase plant activity and water needs.",
            "autumn": "Autumn signals plants to prepare for dormancy, requiring adjusted care routines.",
            "winter": "Winter dormancy period means reduced care frequency and gentler treatment."
        }
        
        return seasonal_explanations.get(season)
    
    def _is_prediction_relevant(
        self,
        model_type: MLModelType,
        recommendation: CareRecommendation
    ) -> bool:
        """Check if ML prediction is relevant to recommendation.
        
        Args:
            model_type: ML model type
            recommendation: Care recommendation
            
        Returns:
            True if relevant, False otherwise
        """
        relevance_map = {
            MLModelType.WATERING_FREQUENCY: ["watering"],
            MLModelType.FERTILIZER_TIMING: ["fertilizing"],
            MLModelType.LIGHT_OPTIMIZATION: ["light_adjustment"],
            MLModelType.HEALTH_PREDICTION: ["health_check", "preventive_care"]
        }
        
        relevant_actions = relevance_map.get(model_type, [])
        return recommendation.action_type in relevant_actions
    
    def _determine_primary_reason(
        self,
        components: List[ExplanationComponent]
    ) -> str:
        """Determine the primary reason from explanation components.
        
        Args:
            components: List of explanation components
            
        Returns:
            Primary reason string
        """
        if not components:
            return "General plant care recommendation"
        
        # Find component with highest weighted confidence
        best_component = max(
            components,
            key=lambda c: c.confidence * c.weight
        )
        
        return best_component.title
    
    def _generate_user_friendly_summary(
        self,
        recommendation: CareRecommendation,
        components: List[ExplanationComponent],
        context: Dict[str, Any]
    ) -> str:
        """Generate user-friendly summary of the rationale.
        
        Args:
            recommendation: Care recommendation
            components: Explanation components
            context: Plant context data
            
        Returns:
            User-friendly summary
        """
        plant_name = context.get("plant_info", {}).get("nickname", "your plant")
        action = recommendation.action_type.replace("_", " ")
        
        # Get top 2 most important reasons
        top_components = sorted(
            components,
            key=lambda c: c.confidence * c.weight,
            reverse=True
        )[:2]
        
        if not top_components:
            return f"It's time to {action} {plant_name} based on general care guidelines."
        
        primary = top_components[0]
        summary = f"I recommend {action} for {plant_name} primarily because of {primary.title.lower()}."
        
        if len(top_components) > 1:
            secondary = top_components[1]
            summary += f" Additionally, {secondary.title.lower()} supports this recommendation."
        
        return summary
    
    def _calculate_overall_confidence(
        self,
        recommendation: CareRecommendation,
        components: List[ExplanationComponent]
    ) -> float:
        """Calculate overall confidence score.
        
        Args:
            recommendation: Care recommendation
            components: Explanation components
            
        Returns:
            Overall confidence score
        """
        if not components:
            return recommendation.confidence
        
        # Weighted average of component confidences
        total_weight = sum(c.weight for c in components)
        if total_weight == 0:
            return recommendation.confidence
        
        weighted_confidence = sum(
            c.confidence * c.weight for c in components
        ) / total_weight
        
        # Combine with original recommendation confidence
        return (recommendation.confidence + weighted_confidence) / 2
    
    def _collect_data_sources(
        self,
        components: List[ExplanationComponent],
        context: Dict[str, Any]
    ) -> List[str]:
        """Collect data sources used in explanations.
        
        Args:
            components: Explanation components
            context: Plant context data
            
        Returns:
            List of data source names
        """
        sources = set()
        
        for component in components:
            if component.type == ExplanationType.RULE_BASED:
                sources.add("Care Rules Engine")
            elif component.type == ExplanationType.ML_PREDICTION:
                sources.add("Machine Learning Models")
            elif component.type == ExplanationType.ENVIRONMENTAL:
                sources.add("Environmental Sensors")
            elif component.type == ExplanationType.HISTORICAL:
                sources.add("Care History")
            elif component.type == ExplanationType.SEASONAL:
                sources.add("Seasonal Patterns")
            elif component.type == ExplanationType.CONTEXTUAL:
                sources.add("Plant Profile")
        
        # Add context-based sources
        if context.get("environmental_data", {}).get("has_data"):
            sources.add("Environmental Data")
        if context.get("care_history", {}).get("total_care_events", 0) > 0:
            sources.add("Historical Care Data")
        
        return sorted(list(sources))
    
    def _build_plan_level_rationale(
        self,
        recommendations: List[CareRecommendation],
        context: Dict[str, Any],
        applied_rules: List[Dict[str, Any]],
        ml_predictions: Dict[MLModelType, MLPrediction]
    ) -> Dict[str, Any]:
        """Build rationale for the overall care plan.
        
        Args:
            recommendations: List of care recommendations
            context: Plant context data
            applied_rules: Rules that were applied
            ml_predictions: ML model predictions
            
        Returns:
            Plan-level rationale
        """
        plant_name = context.get("plant_info", {}).get("nickname", "your plant")
        species_name = context.get("plant_info", {}).get("species_name", "plant")
        
        # Categorize recommendations
        action_types = [rec.action_type for rec in recommendations]
        high_priority = [rec for rec in recommendations if rec.priority == "high"]
        
        # Generate plan summary
        plan_summary = f"This care plan for {plant_name} ({species_name}) includes {len(recommendations)} recommendations."
        
        if high_priority:
            plan_summary += f" {len(high_priority)} high-priority actions require immediate attention."
        
        # Generate plan reasoning
        reasoning_points = []
        
        if "watering" in action_types:
            reasoning_points.append("Watering schedule optimized based on environmental conditions and plant response")
        
        if "fertilizing" in action_types:
            reasoning_points.append("Fertilization timing aligned with seasonal growth patterns")
        
        if "light_adjustment" in action_types:
            reasoning_points.append("Light conditions adjusted to meet species requirements")
        
        return {
            "summary": plan_summary,
            "reasoning_points": reasoning_points,
            "confidence_distribution": {
                "high": len([r for r in recommendations if r.confidence > 0.8]),
                "medium": len([r for r in recommendations if 0.6 <= r.confidence <= 0.8]),
                "low": len([r for r in recommendations if r.confidence < 0.6])
            },
            "data_completeness": context.get("contextual_metadata", {}).get("data_completeness_score", 0.5)
        }
    
    def _load_explanation_templates(self) -> Dict[str, str]:
        """Load explanation templates for different scenarios.
        
        Returns:
            Dictionary of explanation templates
        """
        return {
            "watering_dry": "The soil appears dry based on humidity readings below {threshold}%",
            "fertilizer_growth": "Active growth phase detected, requiring additional nutrients",
            "light_insufficient": "Light levels below {min_ppfd} PPFD may limit photosynthesis",
            "temperature_stress": "Temperature above {max_temp}°C may stress the plant",
            "seasonal_adjustment": "Seasonal care adjustments for {season} growing conditions"
        }