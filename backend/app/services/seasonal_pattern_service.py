"""Seasonal Pattern Service for detecting seasonal transitions and microclimate adjustments.

This service provides functionality for detecting seasonal transitions, calculating
microclimate adjustments, and assessing seasonal pest risks for plants.
"""

from datetime import date, datetime
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

from app.schemas.environmental_data import Location

@dataclass
class SeasonalTransition:
    """Seasonal transition data structure."""
    transition_type: str
    estimated_date: date
    confidence: float
    temperature_trend: str
    daylight_trend: str


@dataclass
class MicroclimateAdjustment:
    """Microclimate adjustment data structure."""
    indoor_temperature_offset: float
    indoor_humidity_offset: float
    light_reduction_factor: float
    air_circulation_factor: float
    seasonal_adjustments: Dict[str, Dict[str, float]]


@dataclass
class PestRiskFactor:
    """Pest risk factor data structure."""
    pest_type: str
    risk_level: str
    risk_score: float
    seasonal_peak: str
    prevention_measures: List[str]


@dataclass
class PestRiskAssessment:
    """Pest risk assessment data structure."""
    overall_risk_score: float
    risk_factors: List[PestRiskFactor]
    seasonal_recommendations: Dict[str, List[str]]


class SeasonalPatternService:
    """Service for detecting seasonal patterns and transitions."""
    
    async def detect_seasonal_transitions(self, location: Location) -> List[SeasonalTransition]:
        """
        Detect seasonal transitions for a given location.
        
        Args:
            location: Location data including coordinates and timezone
            
        Returns:
            List of detected seasonal transitions
        """
        # Get current date and calculate transitions based on location
        current_date = datetime.now().date()
        current_year = current_date.year
        
        # Calculate transitions based on hemisphere
        is_northern = location.latitude > 0
        
        if is_northern:
            transitions = [
                SeasonalTransition(
                    transition_type="winter_to_spring",
                    estimated_date=date(current_year, 3, 20),
                    confidence=0.95,
                    temperature_trend="increasing",
                    daylight_trend="increasing"
                ),
                SeasonalTransition(
                    transition_type="spring_to_summer",
                    estimated_date=date(current_year, 6, 21),
                    confidence=0.95,
                    temperature_trend="increasing",
                    daylight_trend="stable"
                ),
                SeasonalTransition(
                    transition_type="summer_to_fall",
                    estimated_date=date(current_year, 9, 22),
                    confidence=0.90,
                    temperature_trend="decreasing",
                    daylight_trend="decreasing"
                ),
                SeasonalTransition(
                    transition_type="fall_to_winter",
                    estimated_date=date(current_year, 12, 21),
                    confidence=0.95,
                    temperature_trend="decreasing",
                    daylight_trend="decreasing"
                )
            ]
        else:
            # Southern hemisphere has opposite seasons
            transitions = [
                SeasonalTransition(
                    transition_type="summer_to_fall",
                    estimated_date=date(current_year, 3, 20),
                    confidence=0.95,
                    temperature_trend="decreasing",
                    daylight_trend="decreasing"
                ),
                SeasonalTransition(
                    transition_type="fall_to_winter",
                    estimated_date=date(current_year, 6, 21),
                    confidence=0.95,
                    temperature_trend="decreasing",
                    daylight_trend="decreasing"
                ),
                SeasonalTransition(
                    transition_type="winter_to_spring",
                    estimated_date=date(current_year, 9, 22),
                    confidence=0.90,
                    temperature_trend="increasing",
                    daylight_trend="increasing"
                ),
                SeasonalTransition(
                    transition_type="spring_to_summer",
                    estimated_date=date(current_year, 12, 21),
                    confidence=0.95,
                    temperature_trend="increasing",
                    daylight_trend="stable"
                )
            ]
        
        # Adjust for location-specific factors
        # This would be more sophisticated in a real implementation
        return transitions
    
    async def calculate_microclimate_adjustments(
        self, 
        location: Location, 
        indoor_conditions: bool = True
    ) -> MicroclimateAdjustment:
        """
        Calculate microclimate adjustments for indoor/outdoor conditions.
        
        Args:
            location: Location data
            indoor_conditions: Whether to calculate for indoor environment
            
        Returns:
            Microclimate adjustment data
        """
        # Base adjustments
        if indoor_conditions:
            # Indoor environments typically have different conditions
            base_temp_offset = 5.0  # Indoor typically warmer
            base_humidity_offset = -10.0  # Indoor typically drier
            light_reduction = 0.7  # Indoor light is reduced
            air_circulation = 0.6  # Indoor air circulation is reduced
            
            # Seasonal adjustments for indoor environments
            seasonal_adjustments = {
                "winter": {"temperature": 7.0, "humidity": -15.0, "light": 0.5},
                "spring": {"temperature": 5.0, "humidity": -10.0, "light": 0.6},
                "summer": {"temperature": 3.0, "humidity": -5.0, "light": 0.8},
                "fall": {"temperature": 5.0, "humidity": -10.0, "light": 0.6}
            }
        else:
            # Outdoor conditions (no adjustment needed as baseline)
            base_temp_offset = 0.0
            base_humidity_offset = 0.0
            light_reduction = 1.0
            air_circulation = 1.0
            
            # Seasonal adjustments for outdoor environments
            seasonal_adjustments = {
                "winter": {"temperature": 0.0, "humidity": 0.0, "light": 1.0},
                "spring": {"temperature": 0.0, "humidity": 0.0, "light": 1.0},
                "summer": {"temperature": 0.0, "humidity": 0.0, "light": 1.0},
                "fall": {"temperature": 0.0, "humidity": 0.0, "light": 1.0}
            }
        
        # Location-specific adjustments could be added here
        # For example, adjusting for altitude, proximity to water, etc.
        
        return MicroclimateAdjustment(
            indoor_temperature_offset=base_temp_offset,
            indoor_humidity_offset=base_humidity_offset,
            light_reduction_factor=light_reduction,
            air_circulation_factor=air_circulation,
            seasonal_adjustments=seasonal_adjustments
        )
    
    async def assess_seasonal_pest_risks(
        self,
        location: Location,
        plant_species: str,
        microclimate: MicroclimateAdjustment
    ) -> PestRiskAssessment:
        """
        Assess seasonal pest risks for a plant species in a location.
        
        Args:
            location: Location data
            plant_species: Plant species name
            microclimate: Microclimate adjustment data
            
        Returns:
            Pest risk assessment
        """
        # Determine current season based on location
        current_month = datetime.now().month
        is_northern = location.latitude > 0
        
        if is_northern:
            if 3 <= current_month <= 5:
                current_season = "spring"
            elif 6 <= current_month <= 8:
                current_season = "summer"
            elif 9 <= current_month <= 11:
                current_season = "fall"
            else:
                current_season = "winter"
        else:
            # Southern hemisphere has opposite seasons
            if 3 <= current_month <= 5:
                current_season = "fall"
            elif 6 <= current_month <= 8:
                current_season = "winter"
            elif 9 <= current_month <= 11:
                current_season = "spring"
            else:
                current_season = "summer"
        
        # Common pests by season
        seasonal_pests = {
            "spring": [
                PestRiskFactor(
                    pest_type="aphids",
                    risk_level="high",
                    risk_score=0.8,
                    seasonal_peak="spring",
                    prevention_measures=["Neem oil spray", "Beneficial insects", "Regular inspection"]
                ),
                PestRiskFactor(
                    pest_type="fungus_gnats",
                    risk_level="medium",
                    risk_score=0.6,
                    seasonal_peak="spring",
                    prevention_measures=["Allow soil to dry between waterings", "Yellow sticky traps"]
                )
            ],
            "summer": [
                PestRiskFactor(
                    pest_type="spider_mites",
                    risk_level="high",
                    risk_score=0.8,
                    seasonal_peak="summer",
                    prevention_measures=["Increase humidity", "Regular inspection", "Neem oil spray"]
                ),
                PestRiskFactor(
                    pest_type="thrips",
                    risk_level="medium",
                    risk_score=0.6,
                    seasonal_peak="summer",
                    prevention_measures=["Blue sticky traps", "Insecticidal soap", "Regular inspection"]
                )
            ],
            "fall": [
                PestRiskFactor(
                    pest_type="mealybugs",
                    risk_level="medium",
                    risk_score=0.5,
                    seasonal_peak="fall",
                    prevention_measures=["Alcohol swab", "Insecticidal soap", "Isolate new plants"]
                ),
                PestRiskFactor(
                    pest_type="scale",
                    risk_level="medium",
                    risk_score=0.5,
                    seasonal_peak="fall",
                    prevention_measures=["Manual removal", "Horticultural oil", "Regular inspection"]
                )
            ],
            "winter": [
                PestRiskFactor(
                    pest_type="spider_mites",
                    risk_level="medium",
                    risk_score=0.5,
                    seasonal_peak="winter",
                    prevention_measures=["Increase humidity", "Regular inspection"]
                ),
                PestRiskFactor(
                    pest_type="mealybugs",
                    risk_level="low",
                    risk_score=0.3,
                    seasonal_peak="winter",
                    prevention_measures=["Alcohol swab", "Insecticidal soap"]
                )
            ]
        }
        
        # Get current season pests
        current_pests = seasonal_pests.get(current_season, [])
        
        # Adjust risk based on microclimate
        adjusted_pests = []
        for pest in current_pests:
            # Adjust risk based on microclimate factors
            adjusted_risk = pest.risk_score
            
            # Indoor environments typically have different pest pressures
            if microclimate.indoor_temperature_offset > 0:
                # Warmer indoor environments can increase pest activity
                adjusted_risk *= 1.2
            
            if microclimate.indoor_humidity_offset < -15:
                # Very dry environments favor spider mites
                if pest.pest_type == "spider_mites":
                    adjusted_risk *= 1.3
            
            # Create adjusted pest risk factor
            adjusted_pest = PestRiskFactor(
                pest_type=pest.pest_type,
                risk_level=pest.risk_level,
                risk_score=min(1.0, adjusted_risk),  # Cap at 1.0
                seasonal_peak=pest.seasonal_peak,
                prevention_measures=pest.prevention_measures
            )
            adjusted_pests.append(adjusted_pest)
        
        # Calculate overall risk score
        overall_risk = sum(p.risk_score for p in adjusted_pests) / max(1, len(adjusted_pests))
        
        # Generate seasonal recommendations
        current_month_name = datetime.now().strftime("%B")
        next_month_name = datetime.now().replace(month=((current_month % 12) + 1)).strftime("%B")
        
        recommendations = {
            "current_month": [
                f"Monitor for early signs of {p.pest_type}" for p in adjusted_pests
            ] + ["Maintain regular inspection routine", "Clean plant leaves periodically"],
            "next_month": [
                f"Prepare preventive measures for {next_month_name} pests",
                "Adjust watering schedule for seasonal changes"
            ]
        }
        
        # Add specific recommendations based on pest types
        for pest in adjusted_pests:
            if pest.risk_score > 0.7:
                recommendations["current_month"].append(
                    f"Implement {pest.prevention_measures[0]} for {pest.pest_type} prevention"
                )
        
        return PestRiskAssessment(
            overall_risk_score=overall_risk,
            risk_factors=adjusted_pests,
            seasonal_recommendations=recommendations
        )