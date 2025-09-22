"""Rationale Builder Service for Context-Aware Care Plans v2

This service generates comprehensive, human-readable explanations for care plan decisions,
making AI recommendations transparent and trustworthy. It combines rule-based logic,
ML predictions, and contextual factors into coherent rationales.

Key Features:
- Multi-layered explanation generation (rules + ML + context)
- Natural language rationale construction
- Confidence explanation and uncertainty communication
- Factor importance ranking and explanation
- User-friendly language with technical depth options
- Customizable explanation templates
- Decision tree visualization support
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import json

from app.services.context_aggregation import PlantContext, HealthStatus
from app.services.rule_engine import RuleResult, RuleApplication, AlertLevel
from app.services.ml_adjustment import MLPrediction, FeatureImportance, FeatureType
from app.services.environmental_data import Season, WeatherCondition

logger = logging.getLogger(__name__)

class ExplanationLevel(Enum):
    """Explanation detail levels"""
    SIMPLE = "simple"          # Basic explanation for casual users
    DETAILED = "detailed"      # Comprehensive explanation
    TECHNICAL = "technical"    # Full technical details
    DEBUG = "debug"            # Complete decision trace

class RationaleSection(Enum):
    """Rationale sections"""
    WATERING = "watering"
    FERTILIZER = "fertilizer"
    LIGHT = "light"
    ENVIRONMENTAL = "environmental"
    HEALTH = "health"
    CONFIDENCE = "confidence"
    ALERTS = "alerts"

@dataclass
class RationaleData:
    """Input data for rationale generation"""
    plant_context: PlantContext
    rule_result: RuleResult
    ml_prediction: MLPrediction
    generation_mode: str = "standard"
    explanation_level: ExplanationLevel = ExplanationLevel.DETAILED
    user_preferences: Optional[Dict[str, Any]] = None

@dataclass
class RationaleOutput:
    """Complete rationale output"""
    # Section-specific rationales
    watering_rationale: str
    fertilizer_rationale: str
    light_rationale: str
    environmental_rationale: str
    health_rationale: str
    confidence_rationale: str
    
    # Summary and overview
    executive_summary: str
    key_factors: List[str]
    
    # Decision factors
    primary_influences: List[Dict[str, Any]]
    secondary_influences: List[Dict[str, Any]]
    
    # Uncertainty and limitations
    uncertainty_factors: List[str]
    data_limitations: List[str]
    
    # Recommendations and next steps
    monitoring_recommendations: List[str]
    improvement_suggestions: List[str]
    
    # Metadata
    generated_at: datetime = field(default_factory=datetime.utcnow)
    explanation_level: ExplanationLevel = ExplanationLevel.DETAILED
    total_factors_considered: int = 0

class RationaleBuilderService:
    """Service for generating comprehensive care plan rationales"""
    
    def __init__(self):
        # Template configurations
        self.templates = {
            'watering_increase': "Watering frequency increased {change} due to {reasons}",
            'watering_decrease': "Watering frequency decreased {change} due to {reasons}",
            'watering_maintain': "Current watering schedule maintained based on {reasons}",
            'fertilizer_increase': "Fertilizer frequency increased {change} due to {reasons}",
            'fertilizer_decrease': "Fertilizer frequency decreased {change} due to {reasons}",
            'fertilizer_maintain': "Current fertilizer schedule maintained based on {reasons}",
            'confidence_high': "High confidence ({score:.0%}) based on {factors}",
            'confidence_medium': "Moderate confidence ({score:.0%}) due to {factors}",
            'confidence_low': "Lower confidence ({score:.0%}) because of {factors}"
        }
        
        # Factor importance thresholds
        self.importance_thresholds = {
            'primary': 0.7,
            'secondary': 0.4,
            'minor': 0.2
        }
        
        # Natural language mappings
        self.season_descriptions = {
            Season.SPRING: "spring growing season",
            Season.SUMMER: "active summer growth period",
            Season.FALL: "autumn transition period",
            Season.WINTER: "winter dormancy period"
        }
        
        self.health_descriptions = {
            HealthStatus.EXCELLENT: "thriving condition",
            HealthStatus.GOOD: "healthy state",
            HealthStatus.FAIR: "adequate health",
            HealthStatus.POOR: "declining health",
            HealthStatus.CRITICAL: "critical condition",
            HealthStatus.UNKNOWN: "unknown health status"
        }
    
    async def build_rationale(self, data: RationaleData) -> Dict[str, Any]:
        """Build comprehensive rationale for care plan decisions
        
        Args:
            data: Input data for rationale generation
            
        Returns:
            Dictionary with complete rationale sections
        """
        try:
            logger.info(f"Building rationale for plant {data.plant_context.plant_id}")
            
            # Generate section-specific rationales
            watering_rationale = await self._build_watering_rationale(data)
            fertilizer_rationale = await self._build_fertilizer_rationale(data)
            light_rationale = await self._build_light_rationale(data)
            environmental_rationale = await self._build_environmental_rationale(data)
            health_rationale = await self._build_health_rationale(data)
            confidence_rationale = await self._build_confidence_rationale(data)
            
            # Generate summary and key factors
            executive_summary = await self._build_executive_summary(data)
            key_factors = await self._extract_key_factors(data)
            
            # Analyze decision influences
            primary_influences, secondary_influences = await self._analyze_influences(data)
            
            # Identify uncertainty and limitations
            uncertainty_factors = await self._identify_uncertainty_factors(data)
            data_limitations = await self._identify_data_limitations(data)
            
            # Generate recommendations
            monitoring_recommendations = await self._generate_monitoring_recommendations(data)
            improvement_suggestions = await self._generate_improvement_suggestions(data)
            
            # Count total factors
            total_factors = len(data.rule_result.applied_rules) + len(data.ml_prediction.feature_importances)
            
            # Build complete rationale
            rationale = {
                'watering': watering_rationale,
                'fertilizer': fertilizer_rationale,
                'light': light_rationale,
                'environmental_factors': {
                    'description': environmental_rationale,
                    'season': data.plant_context.environmental_context.season.value if data.plant_context.environmental_context else 'unknown',
                    'temperature': data.plant_context.environmental_context.temperature if data.plant_context.environmental_context else None,
                    'humidity': data.plant_context.environmental_context.humidity if data.plant_context.environmental_context else None
                },
                'health_factors': {
                    'description': health_rationale,
                    'status': data.plant_context.health_context.overall_status.value,
                    'score': data.plant_context.health_context.health_score
                },
                'ml_adjustments': {
                    'applied': abs(data.ml_prediction.watering_adjustment) > 0.05 or abs(data.ml_prediction.fertilizer_adjustment) > 0.05,
                    'watering_adjustment': data.ml_prediction.watering_adjustment,
                    'fertilizer_adjustment': data.ml_prediction.fertilizer_adjustment,
                    'confidence': data.ml_prediction.confidence_score,
                    'rationale': data.ml_prediction.adjustment_rationale
                },
                'confidence_explanation': confidence_rationale,
                'executive_summary': executive_summary,
                'key_factors': key_factors,
                'primary_influences': primary_influences,
                'secondary_influences': secondary_influences,
                'uncertainty_factors': uncertainty_factors,
                'data_limitations': data_limitations,
                'monitoring_recommendations': monitoring_recommendations,
                'improvement_suggestions': improvement_suggestions,
                'total_factors_considered': total_factors,
                'explanation_level': data.explanation_level.value,
                'generated_at': datetime.utcnow().isoformat()
            }
            
            logger.info(f"Rationale built successfully ({total_factors} factors considered)")
            return rationale
            
        except Exception as e:
            logger.error(f"Error building rationale for plant {data.plant_context.plant_id}: {e}")
            return self._get_fallback_rationale()
    
    async def _build_watering_rationale(self, data: RationaleData) -> str:
        """Build watering-specific rationale"""
        reasons = []
        
        # Base species requirements
        species_name = data.plant_context.species.replace('_', ' ').title()
        reasons.append(f"{species_name} base care requirements")
        
        # Environmental factors
        if data.plant_context.environmental_context:
            env = data.plant_context.environmental_context
            
            if env.heatwave_days > 0:
                reasons.append(f"current heatwave conditions ({env.heatwave_days} days)")
            elif env.cold_snap_days > 0:
                reasons.append(f"cold weather conditions ({env.cold_snap_days} days)")
            
            if env.humidity < 40:
                reasons.append("low humidity environment")
            elif env.humidity > 70:
                reasons.append("high humidity environment")
            
            season_desc = self.season_descriptions.get(env.season, "current season")
            reasons.append(season_desc)
        
        # Health considerations
        health_status = data.plant_context.health_context.overall_status
        if health_status in [HealthStatus.CRITICAL, HealthStatus.POOR]:
            reasons.append(f"plant's {self.health_descriptions[health_status]}")
        
        # ML adjustments
        ml_adj = data.ml_prediction.watering_adjustment
        if abs(ml_adj) > 0.05:
            direction = "increased" if ml_adj < 0 else "decreased"
            percentage = abs(ml_adj) * 100
            reasons.append(f"ML model recommendation ({direction} by {percentage:.0f}%)")
        
        # User behavior patterns
        behavior = data.plant_context.user_behavior_context
        if behavior.watering_consistency < 0.5:
            reasons.append("inconsistent watering history")
        
        # Construct rationale
        interval = data.rule_result.watering_interval_days
        amount = data.rule_result.watering_amount_ml
        
        rationale = f"Water every {interval} days with {amount}ml based on {self._format_reason_list(reasons)}."
        
        # Add soil moisture guidance
        moisture_target = data.rule_result.soil_moisture_target.replace('_', ' ')
        rationale += f" Maintain soil {moisture_target}."
        
        return rationale
    
    async def _build_fertilizer_rationale(self, data: RationaleData) -> str:
        """Build fertilizer-specific rationale"""
        reasons = []
        
        # Base species requirements
        species_name = data.plant_context.species.replace('_', ' ').title()
        reasons.append(f"{species_name} nutritional needs")
        
        # Growth considerations
        growth_rate = data.plant_context.health_context.growth_rate
        if growth_rate and growth_rate > 1.0:
            reasons.append(f"active growth ({growth_rate:.1f} cm/week)")
        elif growth_rate and growth_rate < 0.1:
            reasons.append("slow growth period")
        
        # Seasonal factors
        if data.plant_context.environmental_context:
            season = data.plant_context.environmental_context.season
            if season in [Season.SPRING, Season.SUMMER]:
                reasons.append("active growing season")
            elif season == Season.WINTER:
                reasons.append("dormant season with reduced nutrient needs")
        
        # Plant age
        if data.plant_context.age_days and data.plant_context.age_days < 90:
            reasons.append("young plant requiring frequent feeding")
        
        # ML adjustments
        ml_adj = data.ml_prediction.fertilizer_adjustment
        if abs(ml_adj) > 0.05:
            direction = "increased" if ml_adj < 0 else "decreased"
            percentage = abs(ml_adj) * 100
            reasons.append(f"ML optimization ({direction} by {percentage:.0f}%)")
        
        # Construct rationale
        interval = data.rule_result.fertilizer_interval_days
        fert_type = data.rule_result.fertilizer_type.replace('_', ' ')
        
        rationale = f"Apply {fert_type} fertilizer every {interval} days based on {self._format_reason_list(reasons)}."
        
        return rationale
    
    async def _build_light_rationale(self, data: RationaleData) -> str:
        """Build light-specific rationale"""
        reasons = []
        
        # Species requirements
        species_name = data.plant_context.species.replace('_', ' ').title()
        reasons.append(f"{species_name} light preferences")
        
        # Current light conditions
        if data.plant_context.sensor_context.light_ppfd_avg:
            current_light = data.plant_context.sensor_context.light_ppfd_avg
            target_min = data.rule_result.light_ppfd_min
            target_max = data.rule_result.light_ppfd_max
            
            if current_light < target_min:
                reasons.append(f"current light levels ({current_light:.0f} PPFD) below optimal range")
            elif current_light > target_max:
                reasons.append(f"current light levels ({current_light:.0f} PPFD) above optimal range")
            else:
                reasons.append(f"current light levels ({current_light:.0f} PPFD) within optimal range")
        
        # Seasonal considerations
        if data.plant_context.environmental_context:
            season = data.plant_context.environmental_context.season
            day_length = data.plant_context.environmental_context.day_length_hours
            
            if season == Season.WINTER:
                reasons.append(f"winter season with shorter days ({day_length:.1f} hours)")
            elif season == Season.SUMMER:
                reasons.append(f"summer season with longer days ({day_length:.1f} hours)")
        
        # Construct rationale
        min_ppfd = data.rule_result.light_ppfd_min
        max_ppfd = data.rule_result.light_ppfd_max
        recommendation = data.rule_result.light_recommendation.replace('_', ' ')
        
        rationale = f"Provide {min_ppfd}-{max_ppfd} PPFD ({recommendation} light) based on {self._format_reason_list(reasons)}."
        
        return rationale
    
    async def _build_environmental_rationale(self, data: RationaleData) -> str:
        """Build environmental factors rationale"""
        if not data.plant_context.environmental_context:
            return "Environmental data not available for this assessment."
        
        env = data.plant_context.environmental_context
        factors = []
        
        # Temperature factors
        if env.heatwave_days > 0:
            factors.append(f"heatwave conditions for {env.heatwave_days} days")
        elif env.cold_snap_days > 0:
            factors.append(f"cold snap for {env.cold_snap_days} days")
        elif env.temperature > 28:
            factors.append(f"warm temperature ({env.temperature:.1f}°C)")
        elif env.temperature < 15:
            factors.append(f"cool temperature ({env.temperature:.1f}°C)")
        
        # Humidity factors
        if env.humidity < 40:
            factors.append(f"low humidity ({env.humidity:.0f}%)")
        elif env.humidity > 70:
            factors.append(f"high humidity ({env.humidity:.0f}%)")
        
        # Seasonal factors
        season_desc = self.season_descriptions.get(env.season, "current season")
        factors.append(f"adjustments for {season_desc}")
        
        # Weather patterns
        if env.drought_days > 7:
            factors.append(f"extended dry period ({env.drought_days} days without rain)")
        
        if not factors:
            factors.append("stable environmental conditions")
        
        return f"Environmental considerations include {self._format_reason_list(factors)}."
    
    async def _build_health_rationale(self, data: RationaleData) -> str:
        """Build plant health rationale"""
        health = data.plant_context.health_context
        factors = []
        
        # Overall health status
        health_desc = self.health_descriptions.get(health.overall_status, "unknown condition")
        factors.append(f"plant is in {health_desc}")
        
        # Health score
        if health.health_score > 0:
            factors.append(f"health score of {health.health_score:.1f}/1.0")
        
        # Growth indicators
        if health.growth_rate and health.growth_rate > 0:
            factors.append(f"growth rate of {health.growth_rate:.1f} cm/week")
        
        if health.new_growth:
            factors.append("recent new growth observed")
        
        # Stress indicators
        if health.stress_indicators:
            stress_list = ', '.join(health.stress_indicators)
            factors.append(f"stress indicators: {stress_list}")
        
        # Health trend
        if health.health_trend > 0.1:
            factors.append("improving health trend")
        elif health.health_trend < -0.1:
            factors.append("declining health trend")
        
        # Assessment recency
        if health.last_assessment_days < 7:
            factors.append("recent health assessment")
        elif health.last_assessment_days > 30:
            factors.append("health assessment needed (last assessment over 30 days ago)")
        
        return f"Plant health analysis shows {self._format_reason_list(factors)}."
    
    async def _build_confidence_rationale(self, data: RationaleData) -> str:
        """Build confidence explanation"""
        confidence = data.rule_result.confidence_score
        factors = []
        
        # Data quality factors
        if data.plant_context.sensor_context.reliability_score > 0.8:
            factors.append("high-quality sensor data")
        elif data.plant_context.sensor_context.reliability_score < 0.5:
            factors.append("limited sensor data quality")
        
        # Historical data
        if data.plant_context.historical_context.total_plans > 5:
            success_rate = data.plant_context.historical_context.successful_plans / data.plant_context.historical_context.total_plans
            if success_rate > 0.8:
                factors.append("strong historical success pattern")
            elif success_rate < 0.5:
                factors.append("mixed historical outcomes")
        else:
            factors.append("limited historical data")
        
        # Environmental data
        if data.plant_context.environmental_context:
            if data.plant_context.environmental_context.sensor_reliability_score > 0.7:
                factors.append("reliable environmental monitoring")
        else:
            factors.append("limited environmental data")
        
        # Health assessments
        if data.plant_context.health_context.assessment_count > 3:
            factors.append("comprehensive health tracking")
        elif data.plant_context.health_context.assessment_count == 0:
            factors.append("no recent health assessments")
        
        # ML model confidence
        if data.ml_prediction.confidence_score > 0.8:
            factors.append("high ML model confidence")
        elif data.ml_prediction.confidence_score < 0.5:
            factors.append("low ML model confidence")
        
        # Determine confidence level description
        if confidence > 0.8:
            level_desc = "High confidence"
        elif confidence > 0.6:
            level_desc = "Good confidence"
        elif confidence > 0.4:
            level_desc = "Moderate confidence"
        else:
            level_desc = "Lower confidence"
        
        return f"{level_desc} ({confidence:.0%}) based on {self._format_reason_list(factors)}."
    
    async def _build_executive_summary(self, data: RationaleData) -> str:
        """Build executive summary of the care plan"""
        species_name = data.plant_context.species.replace('_', ' ').title()
        
        # Key care parameters
        watering_days = data.rule_result.watering_interval_days
        fertilizer_days = data.rule_result.fertilizer_interval_days
        
        # Health status
        health_desc = self.health_descriptions.get(
            data.plant_context.health_context.overall_status, 
            "unknown condition"
        )
        
        # Environmental context
        env_desc = ""
        if data.plant_context.environmental_context:
            season = data.plant_context.environmental_context.season
            season_desc = self.season_descriptions.get(season, "current season")
            env_desc = f" during {season_desc}"
        
        # ML adjustments
        ml_desc = ""
        if abs(data.ml_prediction.watering_adjustment) > 0.05 or abs(data.ml_prediction.fertilizer_adjustment) > 0.05:
            ml_desc = " with AI-optimized adjustments"
        
        summary = (f"Care plan for {species_name} in {health_desc}: "
                  f"water every {watering_days} days, fertilize every {fertilizer_days} days{env_desc}{ml_desc}. "
                  f"Confidence: {data.rule_result.confidence_score:.0%}.")
        
        return summary
    
    async def _extract_key_factors(self, data: RationaleData) -> List[str]:
        """Extract key factors that influenced the care plan"""
        factors = []
        
        # Species-specific factors
        factors.append(f"Species: {data.plant_context.species.replace('_', ' ').title()}")
        
        # Health factors
        health_status = data.plant_context.health_context.overall_status
        if health_status != HealthStatus.UNKNOWN:
            factors.append(f"Health: {self.health_descriptions[health_status]}")
        
        # Environmental factors
        if data.plant_context.environmental_context:
            env = data.plant_context.environmental_context
            factors.append(f"Season: {env.season.value}")
            
            if env.heatwave_days > 0 or env.cold_snap_days > 0:
                weather_desc = "heatwave" if env.heatwave_days > 0 else "cold snap"
                factors.append(f"Weather: {weather_desc}")
        
        # Growth factors
        if data.plant_context.health_context.growth_rate and data.plant_context.health_context.growth_rate > 0.5:
            factors.append(f"Growth: active ({data.plant_context.health_context.growth_rate:.1f} cm/week)")
        
        # ML adjustments
        if abs(data.ml_prediction.watering_adjustment) > 0.05:
            factors.append("AI optimization applied")
        
        # Data quality
        if data.plant_context.confidence_score < 0.5:
            factors.append("Limited data available")
        
        return factors[:6]  # Return top 6 factors
    
    async def _analyze_influences(self, data: RationaleData) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        """Analyze primary and secondary influences on the care plan"""
        all_influences = []
        
        # Rule-based influences
        for rule in data.rule_result.applied_rules:
            influence = {
                'type': 'rule',
                'name': rule.rule_name,
                'priority': rule.priority,
                'rationale': rule.rationale,
                'confidence': rule.confidence
            }
            all_influences.append(influence)
        
        # ML-based influences
        for feature in data.ml_prediction.feature_importances:
            influence = {
                'type': 'ml_feature',
                'name': feature.feature_name,
                'importance': feature.importance_score,
                'rationale': feature.explanation,
                'confidence': data.ml_prediction.confidence_score
            }
            all_influences.append(influence)
        
        # Sort by importance/priority
        all_influences.sort(key=lambda x: x.get('priority', 0) + x.get('importance', 0), reverse=True)
        
        # Split into primary and secondary
        primary_threshold = self.importance_thresholds['primary']
        secondary_threshold = self.importance_thresholds['secondary']
        
        primary = [inf for inf in all_influences if 
                  inf.get('priority', 0) >= 300 or inf.get('importance', 0) >= primary_threshold]
        secondary = [inf for inf in all_influences if 
                    inf not in primary and 
                    (inf.get('priority', 0) >= 200 or inf.get('importance', 0) >= secondary_threshold)]
        
        return primary[:5], secondary[:5]  # Limit to top 5 each
    
    async def _identify_uncertainty_factors(self, data: RationaleData) -> List[str]:
        """Identify factors that contribute to uncertainty"""
        uncertainties = []
        
        # Data quality uncertainties
        if data.plant_context.sensor_context.reliability_score < 0.6:
            uncertainties.append("Limited sensor data reliability")
        
        if data.plant_context.sensor_context.data_freshness_hours > 24:
            uncertainties.append("Sensor data is not recent")
        
        # Historical data uncertainties
        if data.plant_context.historical_context.total_plans < 3:
            uncertainties.append("Limited historical care data")
        
        # Health assessment uncertainties
        if data.plant_context.health_context.last_assessment_days > 14:
            uncertainties.append("Health assessment not recent")
        
        # Environmental data uncertainties
        if not data.plant_context.environmental_context:
            uncertainties.append("Environmental data not available")
        elif data.plant_context.environmental_context.weather_api_status != "ok":
            uncertainties.append("Weather data quality issues")
        
        # ML model uncertainties
        if data.ml_prediction.prediction_uncertainty > 0.5:
            uncertainties.append("High ML model prediction uncertainty")
        
        # Species profile uncertainties
        if 'unknown' in data.plant_context.species.lower():
            uncertainties.append("Plant species not fully identified")
        
        return uncertainties
    
    async def _identify_data_limitations(self, data: RationaleData) -> List[str]:
        """Identify data limitations that affect recommendations"""
        limitations = []
        
        # Missing sensor types
        missing_sensors = data.plant_context.sensor_context.missing_sensors
        if missing_sensors and 'all' not in missing_sensors:
            sensor_list = ', '.join(missing_sensors)
            limitations.append(f"Missing sensor data: {sensor_list}")
        elif 'all' in missing_sensors:
            limitations.append("No sensor data available")
        
        # Limited historical context
        if data.plant_context.historical_context.total_plans == 0:
            limitations.append("No previous care plan history")
        
        # Health assessment gaps
        if data.plant_context.health_context.assessment_count == 0:
            limitations.append("No health assessments on record")
        
        # Environmental monitoring gaps
        if not data.plant_context.environmental_context:
            limitations.append("No environmental monitoring data")
        
        # User behavior data
        if data.plant_context.user_behavior_context.total_care_actions == 0:
            limitations.append("No recorded care actions")
        
        return limitations
    
    async def _generate_monitoring_recommendations(self, data: RationaleData) -> List[str]:
        """Generate monitoring recommendations"""
        recommendations = []
        
        # Health monitoring
        if data.plant_context.health_context.last_assessment_days > 7:
            recommendations.append("Perform weekly health assessments to improve care accuracy")
        
        # Sensor monitoring
        if data.plant_context.sensor_context.reliability_score < 0.7:
            recommendations.append("Check sensor connectivity and calibration")
        
        # Growth tracking
        if not data.plant_context.health_context.growth_rate:
            recommendations.append("Track growth measurements to optimize fertilizer timing")
        
        # Environmental monitoring
        if not data.plant_context.environmental_context:
            recommendations.append("Add environmental monitoring for better care recommendations")
        
        # Care consistency
        if data.plant_context.user_behavior_context.watering_consistency < 0.6:
            recommendations.append("Maintain consistent watering schedule for better plant health")
        
        return recommendations[:4]  # Limit to top 4
    
    async def _generate_improvement_suggestions(self, data: RationaleData) -> List[str]:
        """Generate suggestions for improving care plan accuracy"""
        suggestions = []
        
        # Data quality improvements
        if data.plant_context.confidence_score < 0.6:
            suggestions.append("Add more sensors or increase monitoring frequency")
        
        # Species identification
        if 'unknown' in data.plant_context.species.lower():
            suggestions.append("Confirm plant species identification for more accurate care")
        
        # Historical data building
        if data.plant_context.historical_context.total_plans < 5:
            suggestions.append("Continue following care plans to build historical success patterns")
        
        # Health assessment frequency
        if data.plant_context.health_context.assessment_count < 3:
            suggestions.append("Increase health assessment frequency for better health tracking")
        
        return suggestions[:3]  # Limit to top 3
    
    def _format_reason_list(self, reasons: List[str]) -> str:
        """Format a list of reasons into natural language"""
        if not reasons:
            return "general care guidelines"
        elif len(reasons) == 1:
            return reasons[0]
        elif len(reasons) == 2:
            return f"{reasons[0]} and {reasons[1]}"
        else:
            return f"{', '.join(reasons[:-1])}, and {reasons[-1]}"
    
    def _get_fallback_rationale(self) -> Dict[str, Any]:
        """Get fallback rationale when generation fails"""
        return {
            'watering': "Standard watering schedule based on general plant care guidelines.",
            'fertilizer': "Standard fertilizer schedule based on general plant care guidelines.",
            'light': "Standard light requirements based on general plant care guidelines.",
            'environmental_factors': {
                'description': "Environmental factors not available for analysis.",
                'season': 'unknown',
                'temperature': None,
                'humidity': None
            },
            'health_factors': {
                'description': "Plant health data not available for analysis.",
                'status': 'unknown',
                'score': 0.5
            },
            'ml_adjustments': {
                'applied': False,
                'watering_adjustment': 0.0,
                'fertilizer_adjustment': 0.0,
                'confidence': 0.3,
                'rationale': "ML adjustments not available"
            },
            'confidence_explanation': "Limited confidence due to insufficient data for comprehensive analysis.",
            'executive_summary': "Basic care plan generated with limited data availability.",
            'key_factors': ["Limited data available"],
            'primary_influences': [],
            'secondary_influences': [],
            'uncertainty_factors': ["Insufficient data for detailed analysis"],
            'data_limitations': ["Most data sources not available"],
            'monitoring_recommendations': ["Add sensors and tracking for better recommendations"],
            'improvement_suggestions': ["Increase data collection and monitoring frequency"],
            'total_factors_considered': 0,
            'explanation_level': 'simple',
            'generated_at': datetime.utcnow().isoformat()
        }

# Dependency injection helper
def get_rationale_builder_service():
    """Get rationale builder service instance"""
    return RationaleBuilderService()