"""Rule Engine Service for Context-Aware Care Plans v2

This service applies species-specific care rules with environmental modifiers to generate
deterministic care recommendations. It processes YAML-based rule configurations and applies
them based on plant context, environmental conditions, and seasonal factors.

Key Features:
- Species-specific rule application with inheritance
- Environmental modifier processing (temperature, humidity, season)
- Rule priority and conflict resolution
- Deterministic output with consistent results
- Validation and constraint enforcement
- Comprehensive logging and debugging support
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import copy

from app.services.context_aggregation import PlantContext, HealthStatus
from app.services.environmental_data import EnvironmentalContext, Season, WeatherCondition

logger = logging.getLogger(__name__)

class RulePriority(Enum):
    """Rule priority levels"""
    SPECIES_BASE = 100
    POT_SIZE = 200
    ENVIRONMENTAL_CURRENT = 300
    ENVIRONMENTAL_FORECAST = 250
    PLANT_HEALTH = 400
    USER_OVERRIDE = 500

class AlertLevel(Enum):
    """Alert severity levels"""
    CRITICAL = "critical"
    WARNING = "warning"
    INFO = "info"
    TIP = "tip"

@dataclass
class RuleApplication:
    """Record of a rule application"""
    rule_name: str
    priority: int
    condition_met: bool
    adjustment_applied: Dict[str, Any]
    rationale: str
    confidence: float = 1.0

@dataclass
class RuleResult:
    """Result of rule engine processing"""
    # Core care parameters
    watering_interval_days: int
    watering_amount_ml: int
    fertilizer_interval_days: int
    fertilizer_type: str
    
    # Light requirements
    light_ppfd_min: int
    light_ppfd_max: int
    light_recommendation: str
    
    # Additional parameters
    soil_moisture_target: str
    review_interval_days: int
    
    # Metadata
    applied_rules: List[RuleApplication] = field(default_factory=list)
    alerts: List[Dict[str, str]] = field(default_factory=list)
    confidence_score: float = 1.0
    
    # Notes and explanations
    watering_notes: Optional[str] = None
    fertilizer_notes: Optional[str] = None
    light_notes: Optional[str] = None
    
    # Validation flags
    within_constraints: bool = True
    constraint_violations: List[str] = field(default_factory=list)

class RuleEngineService:
    """Service for applying species-specific care rules"""
    
    def __init__(self):
        self.rule_applications = []  # Track applied rules for debugging
        
    async def apply_rules(
        self, 
        context: PlantContext, 
        species_rules: Dict[str, Any],
        generation_mode: str = "standard"
    ) -> RuleResult:
        """Apply species-specific rules with environmental modifiers
        
        Args:
            context: Complete plant context
            species_rules: Loaded species rules configuration
            generation_mode: Generation mode (standard, emergency, detailed)
            
        Returns:
            Rule result with applied care parameters
        """
        try:
            logger.info(f"Applying rules for species {context.species} (mode: {generation_mode})")
            
            # Clear previous rule applications
            self.rule_applications = []
            
            # Get base species profile
            species_profile = self._get_species_profile(context.species, species_rules)
            if not species_profile:
                logger.warning(f"No species profile found for {context.species}, using defaults")
                species_profile = self._get_default_profile()
            
            # Initialize result with base care parameters
            result = self._initialize_result_from_profile(species_profile)
            
            # Apply rules in priority order
            result = await self._apply_species_base_rules(result, species_profile, context)
            result = await self._apply_pot_size_rules(result, species_profile, context)
            result = await self._apply_environmental_rules(result, species_rules, context)
            result = await self._apply_health_rules(result, context)
            result = await self._apply_seasonal_rules(result, species_rules, context)
            
            # Apply ML integration if enabled
            if species_rules.get('ml_integration', {}).get('enabled', False):
                result = await self._apply_ml_integration_rules(result, species_rules, context)
            
            # Validate constraints
            result = self._validate_constraints(result, species_rules)
            
            # Generate alerts and recommendations
            result = self._generate_rule_alerts(result, species_profile, context)
            
            # Calculate final confidence score
            result.confidence_score = self._calculate_rule_confidence(result, context)
            
            logger.info(f"Rules applied successfully (confidence: {result.confidence_score:.2f})")
            return result
            
        except Exception as e:
            logger.error(f"Error applying rules for species {context.species}: {e}")
            # Return safe defaults
            return self._get_fallback_result()
    
    def _get_species_profile(self, species: str, species_rules: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get species profile from rules configuration"""
        species_profiles = species_rules.get('species_profiles', {})
        
        # Try exact match first
        if species in species_profiles:
            return species_profiles[species]
        
        # Try partial matches (e.g., "ficus_lyrata" matches "ficus")
        species_lower = species.lower().replace(' ', '_')
        for profile_key, profile_data in species_profiles.items():
            if profile_key in species_lower or species_lower in profile_key:
                logger.info(f"Using profile {profile_key} for species {species}")
                return profile_data
        
        return None
    
    def _get_default_profile(self) -> Dict[str, Any]:
        """Get default care profile for unknown species"""
        return {
            'common_name': 'Unknown Plant',
            'profile_version': 'v1',
            'base_care': {
                'watering': {
                    'interval_days': 7,
                    'amount_ml_per_liter_pot': 200,
                    'soil_moisture_target': 'slightly_moist'
                },
                'fertilizer': {
                    'interval_days': 30,
                    'type': 'balanced_10_10_10'
                },
                'light': {
                    'ppfd_min': 100,
                    'ppfd_max': 300,
                    'recommendation': 'bright_indirect'
                }
            },
            'alerts': ['unknown_species_using_defaults']
        }
    
    def _initialize_result_from_profile(self, species_profile: Dict[str, Any]) -> RuleResult:
        """Initialize rule result from species profile base care"""
        base_care = species_profile.get('base_care', {})
        watering = base_care.get('watering', {})
        fertilizer = base_care.get('fertilizer', {})
        light = base_care.get('light', {})
        
        return RuleResult(
            watering_interval_days=watering.get('interval_days', 7),
            watering_amount_ml=watering.get('amount_ml_per_liter_pot', 200),
            fertilizer_interval_days=fertilizer.get('interval_days', 30),
            fertilizer_type=fertilizer.get('type', 'balanced_10_10_10'),
            light_ppfd_min=light.get('ppfd_min', 100),
            light_ppfd_max=light.get('ppfd_max', 300),
            light_recommendation=light.get('recommendation', 'bright_indirect'),
            soil_moisture_target=watering.get('soil_moisture_target', 'slightly_moist'),
            review_interval_days=7
        )
    
    async def _apply_species_base_rules(self, result: RuleResult, species_profile: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Apply base species-specific rules"""
        rule_app = RuleApplication(
            rule_name="species_base",
            priority=RulePriority.SPECIES_BASE.value,
            condition_met=True,
            adjustment_applied={
                'watering_interval': result.watering_interval_days,
                'fertilizer_interval': result.fertilizer_interval_days,
                'light_range': f"{result.light_ppfd_min}-{result.light_ppfd_max}"
            },
            rationale=f"Applied base care parameters for {species_profile.get('common_name', 'plant')}"
        )
        
        result.applied_rules.append(rule_app)
        self.rule_applications.append(rule_app)
        
        return result
    
    async def _apply_pot_size_rules(self, result: RuleResult, species_profile: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Apply pot size-specific adjustments"""
        if not context.pot_size_liters:
            return result
        
        conditions = species_profile.get('conditions', {})
        pot_size = context.pot_size_liters
        
        # Determine pot size category
        if pot_size < 2:
            size_category = 'pot_size_small'
        elif pot_size <= 5:
            size_category = 'pot_size_medium'
        else:
            size_category = 'pot_size_large'
        
        size_rules = conditions.get(size_category, {})
        if not size_rules:
            return result
        
        # Apply pot size adjustments
        adjustments = {}
        
        if 'watering_amount_ml' in size_rules:
            result.watering_amount_ml = size_rules['watering_amount_ml']
            adjustments['watering_amount_ml'] = size_rules['watering_amount_ml']
        
        if 'review_days' in size_rules:
            result.review_interval_days = size_rules['review_days']
            adjustments['review_days'] = size_rules['review_days']
        
        if adjustments:
            rule_app = RuleApplication(
                rule_name=f"pot_size_{size_category}",
                priority=RulePriority.POT_SIZE.value,
                condition_met=True,
                adjustment_applied=adjustments,
                rationale=f"Adjusted for {pot_size}L pot size ({size_category})"
            )
            
            result.applied_rules.append(rule_app)
            self.rule_applications.append(rule_app)
        
        return result
    
    async def _apply_environmental_rules(self, result: RuleResult, species_rules: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Apply environmental modifier rules"""
        if not context.environmental_context:
            return result
        
        env_context = context.environmental_context
        env_modifiers = species_rules.get('environmental_modifiers', {})
        
        # Apply temperature modifiers
        result = await self._apply_temperature_modifiers(result, env_modifiers, env_context)
        
        # Apply humidity modifiers
        result = await self._apply_humidity_modifiers(result, env_modifiers, env_context)
        
        # Apply seasonal modifiers
        result = await self._apply_season_modifiers(result, env_modifiers, env_context)
        
        return result
    
    async def _apply_temperature_modifiers(self, result: RuleResult, env_modifiers: Dict[str, Any], env_context: EnvironmentalContext) -> RuleResult:
        """Apply temperature-based rule modifications"""
        temp_modifiers = env_modifiers.get('temperature', {})
        
        # Check for heatwave conditions
        if env_context.heatwave_days >= 3:
            heatwave_rules = temp_modifiers.get('heatwave', {})
            if heatwave_rules:
                adjustment = heatwave_rules.get('watering_adjustment', 0)
                if adjustment != 0:
                    result.watering_interval_days = max(1, result.watering_interval_days + adjustment)
                    
                    rule_app = RuleApplication(
                        rule_name="temperature_heatwave",
                        priority=RulePriority.ENVIRONMENTAL_CURRENT.value,
                        condition_met=True,
                        adjustment_applied={'watering_adjustment': adjustment},
                        rationale=f"Heatwave detected ({env_context.heatwave_days} days), adjusted watering by {adjustment} days"
                    )
                    
                    result.applied_rules.append(rule_app)
                    
                    # Add alerts
                    alerts = heatwave_rules.get('alerts', [])
                    for alert in alerts:
                        result.alerts.append({
                            'level': AlertLevel.WARNING.value,
                            'message': alert,
                            'source': 'temperature_heatwave'
                        })
        
        # Check for cold snap conditions
        if env_context.cold_snap_days >= 3:
            cold_rules = temp_modifiers.get('cold_snap', {})
            if cold_rules:
                watering_adj = cold_rules.get('watering_adjustment', 0)
                fertilizer_adj = cold_rules.get('fertilizer_adjustment', 0)
                
                adjustments = {}
                if watering_adj != 0:
                    result.watering_interval_days = max(1, result.watering_interval_days + watering_adj)
                    adjustments['watering_adjustment'] = watering_adj
                
                if fertilizer_adj != 0:
                    result.fertilizer_interval_days = max(7, result.fertilizer_interval_days + fertilizer_adj)
                    adjustments['fertilizer_adjustment'] = fertilizer_adj
                
                if adjustments:
                    rule_app = RuleApplication(
                        rule_name="temperature_cold_snap",
                        priority=RulePriority.ENVIRONMENTAL_CURRENT.value,
                        condition_met=True,
                        adjustment_applied=adjustments,
                        rationale=f"Cold snap detected ({env_context.cold_snap_days} days), adjusted care intervals"
                    )
                    
                    result.applied_rules.append(rule_app)
                    
                    # Add alerts
                    alerts = cold_rules.get('alerts', [])
                    for alert in alerts:
                        result.alerts.append({
                            'level': AlertLevel.INFO.value,
                            'message': alert,
                            'source': 'temperature_cold_snap'
                        })
        
        return result
    
    async def _apply_humidity_modifiers(self, result: RuleResult, env_modifiers: Dict[str, Any], env_context: EnvironmentalContext) -> RuleResult:
        """Apply humidity-based rule modifications"""
        humidity_modifiers = env_modifiers.get('humidity', {})
        
        # Check for very low humidity
        if env_context.humidity < 30:
            low_humidity_rules = humidity_modifiers.get('very_low', {})
            if low_humidity_rules:
                adjustment = low_humidity_rules.get('watering_adjustment', 0)
                if adjustment != 0:
                    result.watering_interval_days = max(1, result.watering_interval_days + adjustment)
                    
                    rule_app = RuleApplication(
                        rule_name="humidity_very_low",
                        priority=RulePriority.ENVIRONMENTAL_CURRENT.value,
                        condition_met=True,
                        adjustment_applied={'watering_adjustment': adjustment},
                        rationale=f"Very low humidity ({env_context.humidity:.1f}%), adjusted watering"
                    )
                    
                    result.applied_rules.append(rule_app)
                    
                    # Add alerts
                    alerts = low_humidity_rules.get('alerts', [])
                    for alert in alerts:
                        result.alerts.append({
                            'level': AlertLevel.INFO.value,
                            'message': alert,
                            'source': 'humidity_very_low'
                        })
        
        # Check for very high humidity
        elif env_context.humidity > 80:
            high_humidity_rules = humidity_modifiers.get('very_high', {})
            if high_humidity_rules:
                adjustment = high_humidity_rules.get('watering_adjustment', 0)
                if adjustment != 0:
                    result.watering_interval_days = max(1, result.watering_interval_days + adjustment)
                    
                    rule_app = RuleApplication(
                        rule_name="humidity_very_high",
                        priority=RulePriority.ENVIRONMENTAL_CURRENT.value,
                        condition_met=True,
                        adjustment_applied={'watering_adjustment': adjustment},
                        rationale=f"Very high humidity ({env_context.humidity:.1f}%), adjusted watering"
                    )
                    
                    result.applied_rules.append(rule_app)
                    
                    # Add alerts
                    alerts = high_humidity_rules.get('alerts', [])
                    for alert in alerts:
                        result.alerts.append({
                            'level': AlertLevel.WARNING.value,
                            'message': alert,
                            'source': 'humidity_very_high'
                        })
        
        return result
    
    async def _apply_season_modifiers(self, result: RuleResult, env_modifiers: Dict[str, Any], env_context: EnvironmentalContext) -> RuleResult:
        """Apply seasonal rule modifications"""
        season_modifiers = env_modifiers.get('season', {})
        season_rules = season_modifiers.get(env_context.season.value, {})
        
        if not season_rules:
            return result
        
        adjustments = {}
        
        # Apply watering adjustment
        watering_adj = season_rules.get('watering_adjustment', 0)
        if watering_adj != 0:
            result.watering_interval_days = max(1, result.watering_interval_days + watering_adj)
            adjustments['watering_adjustment'] = watering_adj
        
        # Apply fertilizer adjustment
        fertilizer_adj = season_rules.get('fertilizer_adjustment', 0)
        if fertilizer_adj != 0:
            result.fertilizer_interval_days = max(7, result.fertilizer_interval_days + fertilizer_adj)
            adjustments['fertilizer_adjustment'] = fertilizer_adj
        
        # Apply light adjustment
        light_factor = season_rules.get('light_adjustment_factor', 1.0)
        if light_factor != 1.0:
            result.light_ppfd_min = int(result.light_ppfd_min * light_factor)
            result.light_ppfd_max = int(result.light_ppfd_max * light_factor)
            adjustments['light_adjustment_factor'] = light_factor
        
        if adjustments:
            rule_app = RuleApplication(
                rule_name=f"season_{env_context.season.value}",
                priority=RulePriority.ENVIRONMENTAL_CURRENT.value,
                condition_met=True,
                adjustment_applied=adjustments,
                rationale=f"Seasonal adjustment for {env_context.season.value}"
            )
            
            result.applied_rules.append(rule_app)
        
        return result
    
    async def _apply_health_rules(self, result: RuleResult, context: PlantContext) -> RuleResult:
        """Apply plant health-based rule modifications"""
        health_context = context.health_context
        
        # Adjust based on overall health status
        if health_context.overall_status == HealthStatus.CRITICAL:
            # Emergency care - more frequent attention
            result.watering_interval_days = max(1, result.watering_interval_days - 2)
            result.review_interval_days = min(3, result.review_interval_days)
            
            rule_app = RuleApplication(
                rule_name="health_critical",
                priority=RulePriority.PLANT_HEALTH.value,
                condition_met=True,
                adjustment_applied={
                    'watering_interval_reduction': 2,
                    'review_interval': 3
                },
                rationale="Critical plant health detected - increased care frequency"
            )
            
            result.applied_rules.append(rule_app)
            result.alerts.append({
                'level': AlertLevel.CRITICAL.value,
                'message': 'Plant health is critical - immediate attention required',
                'source': 'health_assessment'
            })
        
        elif health_context.overall_status == HealthStatus.POOR:
            # Increased attention
            result.watering_interval_days = max(1, result.watering_interval_days - 1)
            result.review_interval_days = min(5, result.review_interval_days)
            
            rule_app = RuleApplication(
                rule_name="health_poor",
                priority=RulePriority.PLANT_HEALTH.value,
                condition_met=True,
                adjustment_applied={
                    'watering_interval_reduction': 1,
                    'review_interval': 5
                },
                rationale="Poor plant health detected - slightly increased care frequency"
            )
            
            result.applied_rules.append(rule_app)
            result.alerts.append({
                'level': AlertLevel.WARNING.value,
                'message': 'Plant health is declining - review care routine',
                'source': 'health_assessment'
            })
        
        elif health_context.overall_status == HealthStatus.EXCELLENT:
            # Plant is thriving - maintain current care
            rule_app = RuleApplication(
                rule_name="health_excellent",
                priority=RulePriority.PLANT_HEALTH.value,
                condition_met=True,
                adjustment_applied={},
                rationale="Excellent plant health - maintaining current care routine"
            )
            
            result.applied_rules.append(rule_app)
            result.alerts.append({
                'level': AlertLevel.INFO.value,
                'message': 'Plant is thriving - continue current care routine',
                'source': 'health_assessment'
            })
        
        # Adjust based on growth rate
        if health_context.growth_rate and health_context.growth_rate > 1.0:  # Fast growth
            # Increase fertilizer frequency for fast-growing plants
            result.fertilizer_interval_days = max(14, result.fertilizer_interval_days - 7)
            
            rule_app = RuleApplication(
                rule_name="fast_growth",
                priority=RulePriority.PLANT_HEALTH.value,
                condition_met=True,
                adjustment_applied={'fertilizer_interval_reduction': 7},
                rationale=f"Fast growth detected ({health_context.growth_rate:.1f} cm/week) - increased fertilizer frequency"
            )
            
            result.applied_rules.append(rule_app)
        
        return result
    
    async def _apply_seasonal_rules(self, result: RuleResult, species_rules: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Apply additional seasonal rules beyond environmental modifiers"""
        # This method can be extended for more complex seasonal logic
        # For now, seasonal adjustments are handled in environmental modifiers
        return result
    
    async def _apply_ml_integration_rules(self, result: RuleResult, species_rules: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Apply ML integration rules if enabled"""
        ml_config = species_rules.get('ml_integration', {})
        
        if not ml_config.get('enabled', False):
            return result
        
        # This would integrate with ML models for adjustments
        # For now, just log that ML integration is enabled
        rule_app = RuleApplication(
            rule_name="ml_integration_ready",
            priority=RulePriority.SPECIES_BASE.value,
            condition_met=True,
            adjustment_applied={},
            rationale="ML integration enabled - ready for model-based adjustments"
        )
        
        result.applied_rules.append(rule_app)
        
        return result
    
    def _validate_constraints(self, result: RuleResult, species_rules: Dict[str, Any]) -> RuleResult:
        """Validate result against global and species constraints"""
        global_constraints = species_rules.get('global', {})
        validation_rules = species_rules.get('validation', {})
        
        violations = []
        
        # Validate watering constraints
        watering_constraints = global_constraints.get('watering', {})
        min_interval = watering_constraints.get('min_interval_days', 1)
        max_interval = watering_constraints.get('max_interval_days', 30)
        min_amount = watering_constraints.get('min_amount_ml', 50)
        max_amount = watering_constraints.get('max_amount_ml', 2000)
        
        if result.watering_interval_days < min_interval:
            result.watering_interval_days = min_interval
            violations.append(f"Watering interval clamped to minimum {min_interval} days")
        
        if result.watering_interval_days > max_interval:
            result.watering_interval_days = max_interval
            violations.append(f"Watering interval clamped to maximum {max_interval} days")
        
        if result.watering_amount_ml < min_amount:
            result.watering_amount_ml = min_amount
            violations.append(f"Watering amount clamped to minimum {min_amount} ml")
        
        if result.watering_amount_ml > max_amount:
            result.watering_amount_ml = max_amount
            violations.append(f"Watering amount clamped to maximum {max_amount} ml")
        
        # Validate fertilizer constraints
        fertilizer_constraints = global_constraints.get('fertilizer', {})
        min_fert_interval = fertilizer_constraints.get('min_interval_days', 7)
        max_fert_interval = fertilizer_constraints.get('max_interval_days', 90)
        
        if result.fertilizer_interval_days < min_fert_interval:
            result.fertilizer_interval_days = min_fert_interval
            violations.append(f"Fertilizer interval clamped to minimum {min_fert_interval} days")
        
        if result.fertilizer_interval_days > max_fert_interval:
            result.fertilizer_interval_days = max_fert_interval
            violations.append(f"Fertilizer interval clamped to maximum {max_fert_interval} days")
        
        # Validate light constraints
        light_constraints = global_constraints.get('light', {})
        min_ppfd = light_constraints.get('min_ppfd', 0)
        max_ppfd = light_constraints.get('max_ppfd', 2000)
        
        if result.light_ppfd_min < min_ppfd:
            result.light_ppfd_min = min_ppfd
            violations.append(f"Light minimum clamped to {min_ppfd} PPFD")
        
        if result.light_ppfd_max > max_ppfd:
            result.light_ppfd_max = max_ppfd
            violations.append(f"Light maximum clamped to {max_ppfd} PPFD")
        
        # Set validation results
        result.within_constraints = len(violations) == 0
        result.constraint_violations = violations
        
        if violations:
            logger.warning(f"Constraint violations: {violations}")
        
        return result
    
    def _generate_rule_alerts(self, result: RuleResult, species_profile: Dict[str, Any], context: PlantContext) -> RuleResult:
        """Generate additional alerts based on rule processing"""
        # Add species-specific alerts
        species_alerts = species_profile.get('alerts', [])
        for alert in species_alerts:
            result.alerts.append({
                'level': AlertLevel.INFO.value,
                'message': alert,
                'source': 'species_profile'
            })
        
        # Add constraint violation alerts
        for violation in result.constraint_violations:
            result.alerts.append({
                'level': AlertLevel.WARNING.value,
                'message': violation,
                'source': 'constraint_validation'
            })
        
        # Add data quality alerts
        if context.confidence_score < 0.5:
            result.alerts.append({
                'level': AlertLevel.WARNING.value,
                'message': 'Low data confidence - recommendations may be less accurate',
                'source': 'data_quality'
            })
        
        return result
    
    def _calculate_rule_confidence(self, result: RuleResult, context: PlantContext) -> float:
        """Calculate confidence score for rule application"""
        base_confidence = context.confidence_score
        
        # Reduce confidence for constraint violations
        violation_penalty = len(result.constraint_violations) * 0.1
        
        # Reduce confidence if using default profile
        default_penalty = 0.0
        if any(rule.rule_name == 'species_base' and 'unknown' in rule.rationale.lower() 
               for rule in result.applied_rules):
            default_penalty = 0.2
        
        # Increase confidence for health-based adjustments
        health_bonus = 0.0
        if any(rule.rule_name.startswith('health_') for rule in result.applied_rules):
            health_bonus = 0.1
        
        final_confidence = base_confidence - violation_penalty - default_penalty + health_bonus
        return max(0.1, min(1.0, final_confidence))
    
    def _get_fallback_result(self) -> RuleResult:
        """Get safe fallback result when rule processing fails"""
        return RuleResult(
            watering_interval_days=7,
            watering_amount_ml=200,
            fertilizer_interval_days=30,
            fertilizer_type='balanced_10_10_10',
            light_ppfd_min=100,
            light_ppfd_max=300,
            light_recommendation='bright_indirect',
            soil_moisture_target='slightly_moist',
            review_interval_days=7,
            confidence_score=0.3,
            alerts=[{
                'level': AlertLevel.WARNING.value,
                'message': 'Using fallback care parameters due to rule processing error',
                'source': 'fallback'
            }],
            within_constraints=True
        )

# Dependency injection helper
def get_rule_engine_service():
    """Get rule engine service instance"""
    return RuleEngineService()