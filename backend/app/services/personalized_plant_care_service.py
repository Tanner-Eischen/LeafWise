"""Personalized Plant Care AI service for intelligent care recommendations."""

import logging
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
import json

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.plant_species import PlantSpecies
from app.models.rag_models import PlantKnowledgeBase, UserPreferenceEmbedding
from app.services.rag_service import RAGService, UserContext, PlantData, PlantCareAdvice
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


@dataclass
class EnvironmentalData:
    """Environmental context for plant care recommendations."""
    season: str
    temperature_range: Tuple[int, int]  # (min, max) in Fahrenheit
    humidity_level: str  # low, medium, high
    light_hours: int  # daylight hours
    location: str
    climate_zone: str


@dataclass
class CarePattern:
    """User's care pattern analysis."""
    watering_frequency: float  # days between watering
    consistency_score: float  # 0-1, how consistent the user is
    success_rate: float  # 0-1, how successful their care has been
    preferred_care_times: List[str]  # times of day user typically cares for plants
    care_style: str  # "frequent", "moderate", "minimal"


@dataclass
class PlantHealthPrediction:
    """Prediction of plant health issues."""
    risk_level: str  # low, medium, high
    potential_issues: List[str]
    prevention_tips: List[str]
    check_in_days: int  # when to check again


@dataclass
class PersonalizedCareSchedule:
    """Optimized care schedule for a specific plant and user."""
    plant_id: str
    next_watering: datetime
    next_fertilizing: Optional[datetime]
    next_repotting: Optional[datetime]
    seasonal_adjustments: Dict[str, str]
    care_reminders: List[Dict[str, Any]]


class PersonalizedPlantCareService:
    """Service for AI-powered personalized plant care recommendations."""
    
    def __init__(self, rag_service: RAGService, embedding_service: EmbeddingService):
        self.rag_service = rag_service
        self.embedding_service = embedding_service
    
    async def analyze_user_care_patterns(
        self,
        db: AsyncSession,
        user_id: str,
        days_back: int = 90
    ) -> CarePattern:
        """Analyze user's plant care patterns and consistency.
        
        Args:
            db: Database session
            user_id: User ID to analyze
            days_back: Number of days to look back for analysis
            
        Returns:
            CarePattern with user's care behavior analysis
        """
        try:
            # Get user's care logs from the specified period
            since_date = datetime.utcnow() - timedelta(days=days_back)
            
            stmt = select(PlantCareLog).options(
                selectinload(PlantCareLog.plant)
            ).where(
                and_(
                    PlantCareLog.user_id == user_id,
                    PlantCareLog.care_date >= since_date
                )
            ).order_by(desc(PlantCareLog.care_date))
            
            result = await db.execute(stmt)
            care_logs = result.scalars().all()
            
            if not care_logs:
                # Return default pattern for new users
                return CarePattern(
                    watering_frequency=7.0,
                    consistency_score=0.5,
                    success_rate=0.7,
                    preferred_care_times=["morning"],
                    care_style="moderate"
                )
            
            # Analyze watering frequency
            watering_logs = [log for log in care_logs if log.care_type == "watering"]
            watering_frequency = self._calculate_watering_frequency(watering_logs)
            
            # Analyze consistency (how regular the user is with care)
            consistency_score = self._calculate_consistency_score(care_logs)
            
            # Analyze success rate (based on plant health outcomes)
            success_rate = await self._calculate_success_rate(db, user_id, care_logs)
            
            # Analyze preferred care times
            preferred_times = self._analyze_care_times(care_logs)
            
            # Determine care style
            care_style = self._determine_care_style(watering_frequency, len(care_logs), days_back)
            
            pattern = CarePattern(
                watering_frequency=watering_frequency,
                consistency_score=consistency_score,
                success_rate=success_rate,
                preferred_care_times=preferred_times,
                care_style=care_style
            )
            
            # Update user preferences with this analysis
            await self._update_care_preferences(db, user_id, pattern)
            
            logger.info(f"Analyzed care patterns for user {user_id}")
            return pattern
            
        except Exception as e:
            logger.error(f"Error analyzing care patterns: {str(e)}")
            # Return safe defaults
            return CarePattern(
                watering_frequency=7.0,
                consistency_score=0.5,
                success_rate=0.7,
                preferred_care_times=["morning"],
                care_style="moderate"
            )
    
    async def get_environmental_context(
        self,
        location: str,
        current_date: Optional[datetime] = None
    ) -> EnvironmentalData:
        """Get environmental context for plant care recommendations.
        
        Args:
            location: User's location
            current_date: Current date (defaults to now)
            
        Returns:
            EnvironmentalData with current environmental context
        """
        if current_date is None:
            current_date = datetime.utcnow()
        
        # Determine season based on date (Northern Hemisphere)
        month = current_date.month
        if month in [12, 1, 2]:
            season = "winter"
            temp_range = (35, 65)
            light_hours = 9
        elif month in [3, 4, 5]:
            season = "spring"
            temp_range = (50, 75)
            light_hours = 12
        elif month in [6, 7, 8]:
            season = "summer"
            temp_range = (70, 85)
            light_hours = 15
        else:  # fall
            season = "fall"
            temp_range = (45, 70)
            light_hours = 11
        
        # Simple location-based climate zone mapping
        climate_zone = self._determine_climate_zone(location)
        
        # Humidity based on season and location
        if season == "winter":
            humidity = "low"
        elif season == "summer":
            humidity = "high"
        else:
            humidity = "medium"
        
        return EnvironmentalData(
            season=season,
            temperature_range=temp_range,
            humidity_level=humidity,
            light_hours=light_hours,
            location=location,
            climate_zone=climate_zone
        )
    
    async def optimize_care_schedule(
        self,
        db: AsyncSession,
        user_id: str,
        plant_id: str,
        care_pattern: CarePattern,
        environmental_data: EnvironmentalData
    ) -> PersonalizedCareSchedule:
        """Create optimized care schedule for a specific plant and user.
        
        Args:
            db: Database session
            user_id: User ID
            plant_id: Plant ID
            care_pattern: User's care pattern analysis
            environmental_data: Current environmental context
            
        Returns:
            PersonalizedCareSchedule with optimized timing
        """
        try:
            # Get plant details
            stmt = select(UserPlant).options(
                selectinload(UserPlant.species),
                selectinload(UserPlant.care_logs)
            ).where(UserPlant.id == plant_id)
            
            result = await db.execute(stmt)
            plant = result.scalar_one_or_none()
            
            if not plant:
                raise ValueError(f"Plant {plant_id} not found")
            
            # Get recent care history
            recent_logs = sorted(plant.care_logs, key=lambda x: x.care_date, reverse=True)[:10]
            
            # Calculate base watering schedule
            base_frequency = plant.species.water_frequency_days or 7
            
            # Adjust for user patterns
            user_adjusted_frequency = self._adjust_for_user_pattern(
                base_frequency, care_pattern
            )
            
            # Adjust for environmental conditions
            env_adjusted_frequency = self._adjust_for_environment(
                user_adjusted_frequency, environmental_data
            )
            
            # Calculate next care dates
            last_watering = self._get_last_care_date(recent_logs, "watering")
            next_watering = last_watering + timedelta(days=env_adjusted_frequency)
            
            # Fertilizing schedule (typically monthly during growing season)
            next_fertilizing = None
            if environmental_data.season in ["spring", "summer"]:
                last_fertilizing = self._get_last_care_date(recent_logs, "fertilizing")
                if not last_fertilizing or (datetime.utcnow() - last_fertilizing).days > 30:
                    next_fertilizing = datetime.utcnow() + timedelta(days=7)
            
            # Repotting schedule (typically yearly)
            next_repotting = None
            if plant.last_repotted:
                months_since_repot = (datetime.utcnow() - plant.last_repotted).days / 30
                if months_since_repot > 12:
                    next_repotting = datetime.utcnow() + timedelta(days=30)
            
            # Seasonal adjustments
            seasonal_adjustments = self._get_seasonal_adjustments(
                plant.species, environmental_data
            )
            
            # Generate care reminders
            care_reminders = self._generate_care_reminders(
                plant, care_pattern, environmental_data
            )
            
            schedule = PersonalizedCareSchedule(
                plant_id=plant_id,
                next_watering=next_watering,
                next_fertilizing=next_fertilizing,
                next_repotting=next_repotting,
                seasonal_adjustments=seasonal_adjustments,
                care_reminders=care_reminders
            )
            
            logger.info(f"Generated optimized care schedule for plant {plant_id}")
            return schedule
            
        except Exception as e:
            logger.error(f"Error optimizing care schedule: {str(e)}")
            raise
    
    async def predict_plant_health_issues(
        self,
        db: AsyncSession,
        plant_id: str,
        care_pattern: CarePattern,
        environmental_data: EnvironmentalData
    ) -> PlantHealthPrediction:
        """Predict potential plant health issues based on care patterns and environment.
        
        Args:
            db: Database session
            plant_id: Plant ID to analyze
            care_pattern: User's care pattern
            environmental_data: Environmental context
            
        Returns:
            PlantHealthPrediction with risk assessment
        """
        try:
            # Get plant and recent care history
            stmt = select(UserPlant).options(
                selectinload(UserPlant.species),
                selectinload(UserPlant.care_logs)
            ).where(UserPlant.id == plant_id)
            
            result = await db.execute(stmt)
            plant = result.scalar_one_or_none()
            
            if not plant:
                raise ValueError(f"Plant {plant_id} not found")
            
            # Analyze risk factors
            risk_factors = []
            potential_issues = []
            prevention_tips = []
            
            # Check watering patterns
            if care_pattern.watering_frequency < (plant.species.water_frequency_days or 7) * 0.5:
                risk_factors.append("overwatering")
                potential_issues.append("Root rot from overwatering")
                prevention_tips.append("Reduce watering frequency and check soil moisture before watering")
            elif care_pattern.watering_frequency > (plant.species.water_frequency_days or 7) * 2:
                risk_factors.append("underwatering")
                potential_issues.append("Dehydration and leaf drop")
                prevention_tips.append("Increase watering frequency and monitor soil moisture")
            
            # Check consistency
            if care_pattern.consistency_score < 0.3:
                risk_factors.append("inconsistent_care")
                potential_issues.append("Stress from irregular care schedule")
                prevention_tips.append("Set up care reminders to maintain consistent schedule")
            
            # Check environmental factors
            if environmental_data.season == "winter" and environmental_data.humidity_level == "low":
                risk_factors.append("low_humidity")
                potential_issues.append("Brown leaf tips and pest susceptibility")
                prevention_tips.append("Increase humidity with a humidifier or pebble tray")
            
            # Check plant-specific issues
            species_risks = await self._get_species_specific_risks(db, plant.species, environmental_data)
            potential_issues.extend(species_risks)
            
            # Determine overall risk level
            risk_level = self._calculate_risk_level(risk_factors, care_pattern.success_rate)
            
            # Determine check-in frequency
            if risk_level == "high":
                check_in_days = 3
            elif risk_level == "medium":
                check_in_days = 7
            else:
                check_in_days = 14
            
            prediction = PlantHealthPrediction(
                risk_level=risk_level,
                potential_issues=potential_issues,
                prevention_tips=prevention_tips,
                check_in_days=check_in_days
            )
            
            logger.info(f"Generated health prediction for plant {plant_id}")
            return prediction
            
        except Exception as e:
            logger.error(f"Error predicting plant health: {str(e)}")
            return PlantHealthPrediction(
                risk_level="medium",
                potential_issues=["Unable to assess at this time"],
                prevention_tips=["Continue regular care and monitor plant closely"],
                check_in_days=7
            )
    
    async def generate_personalized_care_advice(
        self,
        db: AsyncSession,
        user_id: str,
        plant_id: str,
        query: str
    ) -> PlantCareAdvice:
        """Generate personalized care advice using RAG with user context.
        
        Args:
            db: Database session
            user_id: User ID
            plant_id: Plant ID
            query: User's question or concern
            
        Returns:
            PlantCareAdvice with personalized recommendations
        """
        try:
            # Get user context
            user_stmt = select(User).where(User.id == user_id)
            user_result = await db.execute(user_stmt)
            user = user_result.scalar_one_or_none()
            
            # Get plant data
            plant_stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.id == plant_id)
            plant_result = await db.execute(plant_stmt)
            plant = plant_result.scalar_one_or_none()
            
            if not user or not plant:
                raise ValueError("User or plant not found")
            
            # Analyze care patterns
            care_pattern = await self.analyze_user_care_patterns(db, user_id)
            
            # Get environmental context
            environmental_data = await self.get_environmental_context(user.location or "temperate")
            
            # Build user context for RAG
            user_context = UserContext(
                user_id=user_id,
                experience_level=user.gardening_experience or "beginner",
                location=user.location,
                preferences={
                    "care_style": care_pattern.care_style,
                    "consistency_score": care_pattern.consistency_score,
                    "success_rate": care_pattern.success_rate
                }
            )
            
            # Build plant data for RAG
            plant_data = PlantData(
                species_id=str(plant.species.id),
                species_name=plant.species.scientific_name,
                care_level=plant.species.care_level or "intermediate",
                user_plant_id=str(plant.id),
                current_health=plant.health_status
            )
            
            # Generate advice using RAG
            advice = await self.rag_service.generate_plant_care_advice(
                db=db,
                user_context=user_context,
                plant_data=plant_data,
                query=query
            )
            
            # Enhance advice with personalized schedule updates
            schedule = await self.optimize_care_schedule(
                db, user_id, plant_id, care_pattern, environmental_data
            )
            
            advice.care_schedule_updates = {
                "next_watering": schedule.next_watering.isoformat(),
                "seasonal_adjustments": schedule.seasonal_adjustments,
                "care_reminders": schedule.care_reminders
            }
            
            logger.info(f"Generated personalized care advice for user {user_id}, plant {plant_id}")
            return advice
            
        except Exception as e:
            logger.error(f"Error generating personalized care advice: {str(e)}")
            raise
    
    def _calculate_watering_frequency(self, watering_logs: List[PlantCareLog]) -> float:
        """Calculate average days between watering events."""
        if len(watering_logs) < 2:
            return 7.0  # Default weekly
        
        intervals = []
        for i in range(1, len(watering_logs)):
            days_diff = (watering_logs[i-1].care_date - watering_logs[i].care_date).days
            if 0 < days_diff <= 30:  # Filter out unrealistic intervals
                intervals.append(days_diff)
        
        return sum(intervals) / len(intervals) if intervals else 7.0
    
    def _calculate_consistency_score(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate how consistent the user is with their care schedule."""
        if len(care_logs) < 3:
            return 0.5  # Default moderate consistency
        
        # Group by care type and calculate variance in intervals
        care_by_type = {}
        for log in care_logs:
            if log.care_type not in care_by_type:
                care_by_type[log.care_type] = []
            care_by_type[log.care_type].append(log.care_date)
        
        consistency_scores = []
        for care_type, dates in care_by_type.items():
            if len(dates) >= 3:
                dates.sort(reverse=True)
                intervals = [(dates[i] - dates[i+1]).days for i in range(len(dates)-1)]
                if intervals:
                    avg_interval = sum(intervals) / len(intervals)
                    variance = sum((x - avg_interval) ** 2 for x in intervals) / len(intervals)
                    # Convert variance to consistency score (lower variance = higher consistency)
                    consistency = max(0, 1 - (variance / (avg_interval ** 2)))
                    consistency_scores.append(consistency)
        
        return sum(consistency_scores) / len(consistency_scores) if consistency_scores else 0.5
    
    async def _calculate_success_rate(
        self,
        db: AsyncSession,
        user_id: str,
        care_logs: List[PlantCareLog]
    ) -> float:
        """Calculate user's success rate based on plant health outcomes."""
        try:
            # Get user's plants and their health status
            stmt = select(UserPlant).where(UserPlant.user_id == user_id)
            result = await db.execute(stmt)
            plants = result.scalars().all()
            
            if not plants:
                return 0.7  # Default moderate success rate
            
            # Calculate success based on plant health
            healthy_plants = sum(1 for plant in plants if plant.health_status in ["healthy", "thriving"])
            total_plants = len(plants)
            
            base_success_rate = healthy_plants / total_plants
            
            # Adjust based on care frequency (more care logs might indicate more engaged user)
            care_engagement_bonus = min(0.2, len(care_logs) / 100)
            
            return min(1.0, base_success_rate + care_engagement_bonus)
            
        except Exception as e:
            logger.error(f"Error calculating success rate: {str(e)}")
            return 0.7
    
    def _analyze_care_times(self, care_logs: List[PlantCareLog]) -> List[str]:
        """Analyze preferred times of day for plant care."""
        time_counts = {"morning": 0, "afternoon": 0, "evening": 0}
        
        for log in care_logs:
            hour = log.care_date.hour
            if 6 <= hour < 12:
                time_counts["morning"] += 1
            elif 12 <= hour < 18:
                time_counts["afternoon"] += 1
            else:
                time_counts["evening"] += 1
        
        # Return times sorted by frequency
        sorted_times = sorted(time_counts.items(), key=lambda x: x[1], reverse=True)
        return [time for time, count in sorted_times if count > 0]
    
    def _determine_care_style(self, watering_frequency: float, total_logs: int, days_back: int) -> str:
        """Determine user's care style based on frequency and engagement."""
        care_events_per_week = (total_logs / days_back) * 7
        
        if watering_frequency <= 3 or care_events_per_week > 5:
            return "frequent"
        elif watering_frequency >= 10 or care_events_per_week < 1:
            return "minimal"
        else:
            return "moderate"
    
    async def _update_care_preferences(
        self,
        db: AsyncSession,
        user_id: str,
        care_pattern: CarePattern
    ) -> None:
        """Update user preferences based on care pattern analysis."""
        try:
            preference_data = {
                "care_style": care_pattern.care_style,
                "watering_frequency": care_pattern.watering_frequency,
                "consistency_score": care_pattern.consistency_score,
                "success_rate": care_pattern.success_rate,
                "preferred_care_times": care_pattern.preferred_care_times
            }
            
            await self.embedding_service.update_user_preferences(
                db=db,
                user_id=user_id,
                preference_type="care_patterns",
                preference_data=preference_data,
                confidence_score=0.8
            )
            
        except Exception as e:
            logger.error(f"Error updating care preferences: {str(e)}")
    
    def _determine_climate_zone(self, location: str) -> str:
        """Determine climate zone based on location."""
        location_lower = location.lower() if location else ""
        
        if any(region in location_lower for region in ["florida", "california", "texas", "arizona"]):
            return "subtropical"
        elif any(region in location_lower for region in ["alaska", "maine", "minnesota", "montana"]):
            return "cold"
        elif any(region in location_lower for region in ["hawaii", "puerto rico"]):
            return "tropical"
        else:
            return "temperate"
    
    def _adjust_for_user_pattern(self, base_frequency: int, care_pattern: CarePattern) -> float:
        """Adjust watering frequency based on user's care patterns."""
        adjustment_factor = 1.0
        
        # Adjust based on care style
        if care_pattern.care_style == "frequent":
            adjustment_factor *= 0.8  # Water more often
        elif care_pattern.care_style == "minimal":
            adjustment_factor *= 1.3  # Water less often
        
        # Adjust based on success rate
        if care_pattern.success_rate > 0.8:
            adjustment_factor *= 0.9  # Successful users can water slightly more often
        elif care_pattern.success_rate < 0.5:
            adjustment_factor *= 1.2  # Less successful users should water less often
        
        return base_frequency * adjustment_factor
    
    def _adjust_for_environment(self, frequency: float, env_data: EnvironmentalData) -> float:
        """Adjust watering frequency based on environmental conditions."""
        adjustment = 1.0
        
        # Seasonal adjustments
        if env_data.season == "winter":
            adjustment *= 1.5  # Water less in winter
        elif env_data.season == "summer":
            adjustment *= 0.8  # Water more in summer
        
        # Humidity adjustments
        if env_data.humidity_level == "low":
            adjustment *= 0.9  # Water slightly more in low humidity
        elif env_data.humidity_level == "high":
            adjustment *= 1.1  # Water slightly less in high humidity
        
        return frequency * adjustment
    
    def _get_last_care_date(self, care_logs: List[PlantCareLog], care_type: str) -> datetime:
        """Get the last date a specific type of care was performed."""
        for log in care_logs:
            if log.care_type == care_type:
                return log.care_date
        
        # If no care of this type found, assume it was done a while ago
        return datetime.utcnow() - timedelta(days=30)
    
    def _get_seasonal_adjustments(
        self,
        species: PlantSpecies,
        env_data: EnvironmentalData
    ) -> Dict[str, str]:
        """Get seasonal care adjustments for the plant species."""
        adjustments = {}
        
        if env_data.season == "winter":
            adjustments.update({
                "watering": "Reduce watering frequency as plant enters dormancy",
                "fertilizing": "Stop fertilizing during winter months",
                "light": "Move closer to windows for maximum light exposure",
                "humidity": "Increase humidity to combat dry indoor air"
            })
        elif env_data.season == "spring":
            adjustments.update({
                "watering": "Gradually increase watering as growth resumes",
                "fertilizing": "Begin monthly fertilizing schedule",
                "repotting": "Best time for repotting if needed",
                "pruning": "Prune dead or damaged growth"
            })
        elif env_data.season == "summer":
            adjustments.update({
                "watering": "Monitor soil moisture more frequently",
                "fertilizing": "Continue regular fertilizing",
                "light": "Protect from intense direct sunlight",
                "humidity": "Maintain good air circulation"
            })
        else:  # fall
            adjustments.update({
                "watering": "Begin reducing watering frequency",
                "fertilizing": "Stop fertilizing by mid-fall",
                "preparation": "Prepare plant for winter dormancy",
                "inspection": "Check for pests before bringing indoors"
            })
        
        return adjustments
    
    def _generate_care_reminders(
        self,
        plant: UserPlant,
        care_pattern: CarePattern,
        env_data: EnvironmentalData
    ) -> List[Dict[str, Any]]:
        """Generate personalized care reminders."""
        reminders = []
        
        # Watering reminder
        preferred_time = care_pattern.preferred_care_times[0] if care_pattern.preferred_care_times else "morning"
        reminders.append({
            "type": "watering",
            "message": f"Water your {plant.nickname or plant.species.common_names[0]} in the {preferred_time}",
            "frequency": f"every {int(care_pattern.watering_frequency)} days",
            "priority": "high"
        })
        
        # Seasonal reminders
        if env_data.season == "winter":
            reminders.append({
                "type": "humidity",
                "message": "Check humidity levels - winter air can be very dry",
                "frequency": "weekly",
                "priority": "medium"
            })
        elif env_data.season == "spring":
            reminders.append({
                "type": "fertilizing",
                "message": "Time to start fertilizing for the growing season",
                "frequency": "monthly",
                "priority": "medium"
            })
        
        return reminders
    
    async def _get_species_specific_risks(
        self,
        db: AsyncSession,
        species: PlantSpecies,
        env_data: EnvironmentalData
    ) -> List[str]:
        """Get species-specific health risks based on current conditions."""
        risks = []
        
        # Check if species care level matches current conditions
        if species.care_level == "difficult" and env_data.season == "winter":
            risks.append("Increased sensitivity during winter months")
        
        # Check humidity requirements
        if species.humidity_preference == "high" and env_data.humidity_level == "low":
            risks.append("Low humidity stress for humidity-loving plant")
        
        # Check temperature requirements
        if species.temperature_range:
            temp_range = species.temperature_range.split("-")
            if len(temp_range) == 2:
                min_temp, max_temp = int(temp_range[0]), int(temp_range[1])
                env_min, env_max = env_data.temperature_range
                if env_min < min_temp or env_max > max_temp:
                    risks.append("Temperature outside plant's preferred range")
        
        return risks
    
    def _calculate_risk_level(self, risk_factors: List[str], success_rate: float) -> str:
        """Calculate overall risk level based on factors and user success rate."""
        base_risk = len(risk_factors)
        
        # Adjust based on user success rate
        if success_rate > 0.8:
            base_risk *= 0.7  # Experienced users have lower risk
        elif success_rate < 0.5:
            base_risk *= 1.3  # Inexperienced users have higher risk
        
        if base_risk >= 3:
            return "high"
        elif base_risk >= 1:
            return "medium"
        else:
            return "low" 