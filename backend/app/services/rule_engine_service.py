"""Rule engine service.

This module provides a rule-based system for generating care recommendations
based on plant species, environmental conditions, and care history.
It processes aggregated context data and applies configurable care rules.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID
import json
from dataclasses import dataclass
from enum import Enum

from sqlalchemy.ext.asyncio import AsyncSession

from app.services.context_aggregation_service import ContextAggregationService


class RuleConditionOperator(Enum):
    """Operators for rule conditions."""
    EQUALS = "equals"
    NOT_EQUALS = "not_equals"
    GREATER_THAN = "greater_than"
    LESS_THAN = "less_than"
    GREATER_EQUAL = "greater_equal"
    LESS_EQUAL = "less_equal"
    CONTAINS = "contains"
    IN_RANGE = "in_range"
    EXISTS = "exists"


@dataclass
class RuleCondition:
    """Represents a single rule condition."""
    field_path: str  # e.g., "environmental_data.temperature.average"
    operator: RuleConditionOperator
    value: Any
    weight: float = 1.0


@dataclass
class CareRecommendation:
    """Represents a care recommendation."""
    action_type: str  # watering, fertilizing, light_adjustment, etc.
    priority: str  # high, medium, low
    recommendation: str
    parameters: Dict[str, Any]
    confidence: float
    reasoning: str


@dataclass
class CareRule:
    """Represents a complete care rule."""
    rule_id: str
    name: str
    description: str
    conditions: List[RuleCondition]
    recommendations: List[CareRecommendation]
    species_filter: Optional[List[str]] = None  # Species IDs this rule applies to
    season_filter: Optional[List[str]] = None  # Seasons this rule applies to
    enabled: bool = True


class RuleEngineService:
    """Service for processing care rules and generating recommendations."""
    
    def __init__(self, db: AsyncSession):
        """Initialize the rule engine service.
        
        Args:
            db: Database session
        """
        self.db = db
        self.context_service = ContextAggregationService(db)
        self.rules = self._load_default_rules()
    
    async def generate_care_recommendations(
        self,
        plant_id: UUID,
        user_id: UUID,
        context_window_days: int = 30
    ) -> Tuple[List[CareRecommendation], Dict[str, Any]]:
        """Generate care recommendations for a plant.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            context_window_days: Days of historical data to consider
            
        Returns:
            Tuple of (recommendations list, processing metadata)
        """
        # Get aggregated context
        context = await self.context_service.aggregate_plant_context(
            plant_id, user_id, context_window_days
        )
        
        # Apply rules to generate recommendations
        recommendations = []
        applied_rules = []
        
        for rule in self.rules:
            if not rule.enabled:
                continue
            
            # Check if rule applies to this plant/context
            if not self._rule_applies(rule, context):
                continue
            
            # Evaluate rule conditions
            rule_score = self._evaluate_rule_conditions(rule, context)
            
            if rule_score > 0.5:  # Rule threshold
                # Generate recommendations from this rule
                rule_recommendations = self._generate_rule_recommendations(
                    rule, context, rule_score
                )
                recommendations.extend(rule_recommendations)
                applied_rules.append({
                    "rule_id": rule.rule_id,
                    "name": rule.name,
                    "score": rule_score,
                    "recommendations_count": len(rule_recommendations)
                })
        
        # Sort recommendations by priority and confidence
        recommendations.sort(
            key=lambda r: (self._priority_score(r.priority), r.confidence),
            reverse=True
        )
        
        # Generate processing metadata
        metadata = {
            "processing_timestamp": datetime.utcnow().isoformat(),
            "context_completeness": context["contextual_metadata"]["data_completeness_score"],
            "rules_evaluated": len(self.rules),
            "rules_applied": len(applied_rules),
            "applied_rules": applied_rules,
            "total_recommendations": len(recommendations)
        }
        
        return recommendations, metadata
    
    def _rule_applies(self, rule: CareRule, context: Dict[str, Any]) -> bool:
        """Check if a rule applies to the given context.
        
        Args:
            rule: Care rule to check
            context: Plant context data
            
        Returns:
            True if rule applies, False otherwise
        """
        # Check species filter
        if rule.species_filter:
            species_id = context.get("plant_info", {}).get("species_id")
            if species_id not in rule.species_filter:
                return False
        
        # Check season filter
        if rule.season_filter:
            current_season = context.get("seasonal_context", {}).get("current_season")
            if current_season not in rule.season_filter:
                return False
        
        return True
    
    def _evaluate_rule_conditions(self, rule: CareRule, context: Dict[str, Any]) -> float:
        """Evaluate all conditions for a rule.
        
        Args:
            rule: Care rule to evaluate
            context: Plant context data
            
        Returns:
            Rule score between 0.0 and 1.0
        """
        if not rule.conditions:
            return 1.0
        
        total_weight = sum(condition.weight for condition in rule.conditions)
        weighted_score = 0.0
        
        for condition in rule.conditions:
            condition_met = self._evaluate_condition(condition, context)
            if condition_met:
                weighted_score += condition.weight
        
        return weighted_score / total_weight if total_weight > 0 else 0.0
    
    def _evaluate_condition(self, condition: RuleCondition, context: Dict[str, Any]) -> bool:
        """Evaluate a single rule condition.
        
        Args:
            condition: Rule condition to evaluate
            context: Plant context data
            
        Returns:
            True if condition is met, False otherwise
        """
        # Get value from context using field path
        actual_value = self._get_nested_value(context, condition.field_path)
        
        if actual_value is None and condition.operator != RuleConditionOperator.EXISTS:
            return False
        
        # Evaluate based on operator
        if condition.operator == RuleConditionOperator.EQUALS:
            return actual_value == condition.value
        elif condition.operator == RuleConditionOperator.NOT_EQUALS:
            return actual_value != condition.value
        elif condition.operator == RuleConditionOperator.GREATER_THAN:
            return actual_value > condition.value
        elif condition.operator == RuleConditionOperator.LESS_THAN:
            return actual_value < condition.value
        elif condition.operator == RuleConditionOperator.GREATER_EQUAL:
            return actual_value >= condition.value
        elif condition.operator == RuleConditionOperator.LESS_EQUAL:
            return actual_value <= condition.value
        elif condition.operator == RuleConditionOperator.CONTAINS:
            return condition.value in str(actual_value)
        elif condition.operator == RuleConditionOperator.IN_RANGE:
            min_val, max_val = condition.value
            return min_val <= actual_value <= max_val
        elif condition.operator == RuleConditionOperator.EXISTS:
            return actual_value is not None
        
        return False
    
    def _get_nested_value(self, data: Dict[str, Any], field_path: str) -> Any:
        """Get nested value from dictionary using dot notation.
        
        Args:
            data: Dictionary to search
            field_path: Dot-separated path (e.g., "environmental_data.temperature.average")
            
        Returns:
            Value at the specified path or None if not found
        """
        keys = field_path.split(".")
        current = data
        
        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return None
        
        return current
    
    def _generate_rule_recommendations(
        self,
        rule: CareRule,
        context: Dict[str, Any],
        rule_score: float
    ) -> List[CareRecommendation]:
        """Generate recommendations from a rule.
        
        Args:
            rule: Care rule that was triggered
            context: Plant context data
            rule_score: Score of the rule evaluation
            
        Returns:
            List of care recommendations
        """
        recommendations = []
        
        for base_rec in rule.recommendations:
            # Adjust confidence based on rule score and context completeness
            context_completeness = context["contextual_metadata"]["data_completeness_score"]
            adjusted_confidence = base_rec.confidence * rule_score * context_completeness
            
            # Create personalized recommendation
            recommendation = CareRecommendation(
                action_type=base_rec.action_type,
                priority=base_rec.priority,
                recommendation=self._personalize_recommendation(
                    base_rec.recommendation, context
                ),
                parameters=base_rec.parameters.copy(),
                confidence=adjusted_confidence,
                reasoning=f"{base_rec.reasoning} (Rule: {rule.name}, Score: {rule_score:.2f})"
            )
            
            recommendations.append(recommendation)
        
        return recommendations
    
    def _personalize_recommendation(
        self,
        template: str,
        context: Dict[str, Any]
    ) -> str:
        """Personalize recommendation text with context data.
        
        Args:
            template: Recommendation template string
            context: Plant context data
            
        Returns:
            Personalized recommendation text
        """
        # Simple template substitution
        plant_name = context.get("plant_info", {}).get("nickname", "your plant")
        species_name = context.get("plant_info", {}).get("species_name", "plant")
        
        personalized = template.replace("{plant_name}", plant_name)
        personalized = personalized.replace("{species_name}", species_name)
        
        return personalized
    
    def _priority_score(self, priority: str) -> int:
        """Convert priority string to numeric score for sorting.
        
        Args:
            priority: Priority string
            
        Returns:
            Numeric priority score
        """
        priority_map = {
            "high": 3,
            "medium": 2,
            "low": 1
        }
        return priority_map.get(priority.lower(), 1)
    
    def _load_default_rules(self) -> List[CareRule]:
        """Load default care rules.
        
        Returns:
            List of default care rules
        """
        return [
            # Watering rules
            CareRule(
                rule_id="watering_dry_soil",
                name="Dry Soil Watering",
                description="Water when soil moisture is low",
                conditions=[
                    RuleCondition(
                        field_path="environmental_data.humidity.average",
                        operator=RuleConditionOperator.LESS_THAN,
                        value=40.0,
                        weight=1.0
                    )
                ],
                recommendations=[
                    CareRecommendation(
                        action_type="watering",
                        priority="high",
                        recommendation="Water {plant_name} thoroughly as the soil appears dry",
                        parameters={"amount_ml": 200, "frequency_days": 3},
                        confidence=0.9,
                        reasoning="Low humidity indicates dry soil conditions"
                    )
                ]
            ),
            
            # Temperature stress rule
            CareRule(
                rule_id="temperature_stress",
                name="Temperature Stress",
                description="Adjust care when temperature is outside optimal range",
                conditions=[
                    RuleCondition(
                        field_path="environmental_data.temperature.average",
                        operator=RuleConditionOperator.GREATER_THAN,
                        value=28.0,
                        weight=1.0
                    )
                ],
                recommendations=[
                    CareRecommendation(
                        action_type="environmental_adjustment",
                        priority="medium",
                        recommendation="Move {plant_name} to a cooler location or increase ventilation",
                        parameters={"target_temperature": 24.0},
                        confidence=0.8,
                        reasoning="High temperature can stress the plant"
                    )
                ]
            ),
            
            # Light adjustment rule
            CareRule(
                rule_id="low_light",
                name="Low Light Conditions",
                description="Adjust light when intensity is too low",
                conditions=[
                    RuleCondition(
                        field_path="environmental_data.light_intensity.average",
                        operator=RuleConditionOperator.LESS_THAN,
                        value=200.0,
                        weight=1.0
                    )
                ],
                recommendations=[
                    CareRecommendation(
                        action_type="light_adjustment",
                        priority="medium",
                        recommendation="Provide more light for {plant_name} by moving closer to a window or adding grow lights",
                        parameters={"target_ppfd": 300},
                        confidence=0.7,
                        reasoning="Low light levels may affect growth"
                    )
                ]
            ),
            
            # Fertilizer rule based on growth phase
            CareRule(
                rule_id="growth_fertilizer",
                name="Growth Phase Fertilizing",
                description="Fertilize during active growth periods",
                conditions=[
                    RuleCondition(
                        field_path="seasonal_context.current_season",
                        operator=RuleConditionOperator.EQUALS,
                        value="spring",
                        weight=0.7
                    ),
                    RuleCondition(
                        field_path="growth_patterns.growth_trend",
                        operator=RuleConditionOperator.EQUALS,
                        value="growing",
                        weight=0.3
                    )
                ],
                recommendations=[
                    CareRecommendation(
                        action_type="fertilizing",
                        priority="medium",
                        recommendation="Apply balanced fertilizer to {plant_name} to support active growth",
                        parameters={"fertilizer_type": "balanced", "frequency_weeks": 2},
                        confidence=0.8,
                        reasoning="Spring growth period benefits from regular fertilization"
                    )
                ]
            ),
            
            # Health monitoring rule
            CareRule(
                rule_id="health_decline",
                name="Health Decline Alert",
                description="Alert when plant health is declining",
                conditions=[
                    RuleCondition(
                        field_path="plant_health_indicators.health_trend",
                        operator=RuleConditionOperator.EQUALS,
                        value="declining",
                        weight=1.0
                    )
                ],
                recommendations=[
                    CareRecommendation(
                        action_type="health_check",
                        priority="high",
                        recommendation="Inspect {plant_name} closely for signs of pests, disease, or environmental stress",
                        parameters={"inspection_areas": ["leaves", "stems", "soil", "roots"]},
                        confidence=0.9,
                        reasoning="Declining health trend requires immediate attention"
                    )
                ]
            )
        ]
    
    def add_custom_rule(self, rule: CareRule) -> None:
        """Add a custom care rule.
        
        Args:
            rule: Custom care rule to add
        """
        self.rules.append(rule)
    
    def remove_rule(self, rule_id: str) -> bool:
        """Remove a care rule by ID.
        
        Args:
            rule_id: ID of rule to remove
            
        Returns:
            True if rule was removed, False if not found
        """
        for i, rule in enumerate(self.rules):
            if rule.rule_id == rule_id:
                del self.rules[i]
                return True
        return False
    
    def get_rule_by_id(self, rule_id: str) -> Optional[CareRule]:
        """Get a rule by its ID.
        
        Args:
            rule_id: Rule ID to search for
            
        Returns:
            Care rule if found, None otherwise
        """
        for rule in self.rules:
            if rule.rule_id == rule_id:
                return rule
        return None
    
    def list_rules(self) -> List[Dict[str, Any]]:
        """List all rules with basic information.
        
        Returns:
            List of rule summaries
        """
        return [
            {
                "rule_id": rule.rule_id,
                "name": rule.name,
                "description": rule.description,
                "enabled": rule.enabled,
                "conditions_count": len(rule.conditions),
                "recommendations_count": len(rule.recommendations)
            }
            for rule in self.rules
        ]