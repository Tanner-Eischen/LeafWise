"""Context aggregation service.

This module provides functionality to collect and aggregate context data
from various sources for generating context-aware care plans.
It gathers environmental data, plant history, user preferences, and seasonal patterns.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from uuid import UUID

from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.models.plant_care_log import PlantCareLog
from app.models.seasonal_ai import EnvironmentalDataCache
from app.models.seasonal_ai import SeasonalPrediction
from app.models.growth_photo import GrowthPhoto
from app.services.environmental_data_service import EnvironmentalDataService
from app.services.seasonal_ai_service import SeasonalAIService


class ContextAggregationService:
    """Service for aggregating context data for care plan generation."""
    
    def __init__(self, db: AsyncSession):
        """Initialize the context aggregation service.
        
        Args:
            db: Database session
        """
        self.db = db
        self.env_service = EnvironmentalDataService()
        self.seasonal_service = SeasonalAIService()
    
    async def aggregate_plant_context(
        self,
        plant_id: UUID,
        user_id: UUID,
        context_window_days: int = 30
    ) -> Dict[str, Any]:
        """Aggregate comprehensive context data for a specific plant.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            context_window_days: Number of days to look back for historical data
            
        Returns:
            Aggregated context data dictionary
        """
        # Get plant and species information
        plant_data = await self._get_plant_data(plant_id, user_id)
        if not plant_data:
            raise ValueError(f"Plant {plant_id} not found or not owned by user {user_id}")
        
        # Aggregate all context components
        context = {
            "plant_info": plant_data,
            "care_history": await self._get_care_history(plant_id, context_window_days),
            "environmental_data": await self._get_environmental_context(plant_id, context_window_days),
            "seasonal_context": await self._get_seasonal_context(plant_id),
            "growth_patterns": await self._get_growth_patterns(plant_id, context_window_days),
            "user_preferences": await self._get_user_preferences(user_id),
            "plant_health_indicators": await self._get_health_indicators(plant_id, context_window_days),
            "contextual_metadata": {
                "aggregation_timestamp": datetime.utcnow().isoformat(),
                "context_window_days": context_window_days,
                "data_completeness_score": 0.0  # Will be calculated
            }
        }
        
        # Calculate data completeness score
        context["contextual_metadata"]["data_completeness_score"] = self._calculate_completeness_score(context)
        
        return context
    
    async def _get_plant_data(self, plant_id: UUID, user_id: UUID) -> Optional[Dict[str, Any]]:
        """Get basic plant and species information.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            
        Returns:
            Plant data dictionary or None if not found
        """
        result = await self.db.execute(
            select(UserPlant)
            .options(selectinload(UserPlant.species))
            .where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id,
                    UserPlant.is_active == True
                )
            )
        )
        plant = result.scalar_one_or_none()
        
        if not plant:
            return None
        
        return {
            "id": str(plant.id),
            "nickname": plant.nickname,
            "species_id": str(plant.species_id),
            "species_name": plant.species.common_name if plant.species else None,
            "scientific_name": plant.species.scientific_name if plant.species else None,
            "location": plant.location,
            "pot_size": plant.pot_size,
            "soil_type": plant.soil_type,
            "acquisition_date": plant.acquisition_date.isoformat() if plant.acquisition_date else None,
            "created_at": plant.created_at.isoformat(),
            "plant_age_days": (datetime.utcnow() - plant.created_at).days,
            "care_difficulty": plant.species.care_difficulty if plant.species else None,
            "light_requirements": plant.species.light_requirements if plant.species else None,
            "water_requirements": plant.species.water_requirements if plant.species else None
        }
    
    async def _get_care_history(
        self,
        plant_id: UUID,
        days_back: int
    ) -> Dict[str, Any]:
        """Get plant care history for the specified time window.
        
        Args:
            plant_id: Plant ID
            days_back: Number of days to look back
            
        Returns:
            Care history data
        """
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        
        result = await self.db.execute(
            select(PlantCareLog)
            .where(
                and_(
                    PlantCareLog.plant_id == plant_id,
                    PlantCareLog.performed_at >= cutoff_date
                )
            )
            .order_by(desc(PlantCareLog.performed_at))
        )
        care_logs = result.scalars().all()
        
        # Aggregate care activities by type
        care_summary = {}
        recent_activities = []
        
        for log in care_logs:
            care_type = log.care_type
            if care_type not in care_summary:
                care_summary[care_type] = {
                    "count": 0,
                    "last_performed": None,
                    "average_interval_days": None
                }
            
            care_summary[care_type]["count"] += 1
            if not care_summary[care_type]["last_performed"]:
                care_summary[care_type]["last_performed"] = log.performed_at.isoformat()
            
            recent_activities.append({
                "care_type": care_type,
                "performed_at": log.performed_at.isoformat(),
                "notes": log.notes
            })
        
        return {
            "care_summary": care_summary,
            "recent_activities": recent_activities[:10],  # Last 10 activities
            "total_care_events": len(care_logs)
        }
    
    async def _get_environmental_context(
        self,
        plant_id: UUID,
        days_back: int
    ) -> Dict[str, Any]:
        """Get environmental data context.
        
        Args:
            plant_id: Plant ID
            days_back: Number of days to look back
            
        Returns:
            Environmental context data
        """
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        
        # Get cached environmental data
        result = await self.db.execute(
            select(EnvironmentalDataCache)
            .where(
                and_(
                    EnvironmentalDataCache.plant_id == plant_id,
                    EnvironmentalDataCache.recorded_at >= cutoff_date
                )
            )
            .order_by(desc(EnvironmentalDataCache.recorded_at))
        )
        env_data = result.scalars().all()
        
        if not env_data:
            return {
                "has_data": False,
                "message": "No environmental data available"
            }
        
        # Calculate averages and trends
        temperatures = [d.temperature for d in env_data if d.temperature]
        humidity_levels = [d.humidity for d in env_data if d.humidity]
        light_levels = [d.light_intensity for d in env_data if d.light_intensity]
        
        return {
            "has_data": True,
            "data_points": len(env_data),
            "temperature": {
                "average": sum(temperatures) / len(temperatures) if temperatures else None,
                "min": min(temperatures) if temperatures else None,
                "max": max(temperatures) if temperatures else None
            },
            "humidity": {
                "average": sum(humidity_levels) / len(humidity_levels) if humidity_levels else None,
                "min": min(humidity_levels) if humidity_levels else None,
                "max": max(humidity_levels) if humidity_levels else None
            },
            "light_intensity": {
                "average": sum(light_levels) / len(light_levels) if light_levels else None,
                "min": min(light_levels) if light_levels else None,
                "max": max(light_levels) if light_levels else None
            },
            "latest_reading": {
                "timestamp": env_data[0].recorded_at.isoformat(),
                "temperature": env_data[0].temperature,
                "humidity": env_data[0].humidity,
                "light_intensity": env_data[0].light_intensity
            } if env_data else None
        }
    
    async def _get_seasonal_context(self, plant_id: UUID) -> Dict[str, Any]:
        """Get seasonal context and predictions.
        
        Args:
            plant_id: Plant ID
            
        Returns:
            Seasonal context data
        """
        # Get current seasonal predictions
        result = await self.db.execute(
            select(SeasonalPrediction)
            .where(SeasonalPrediction.plant_id == plant_id)
            .order_by(desc(SeasonalPrediction.created_at))
            .limit(1)
        )
        prediction = result.scalar_one_or_none()
        
        current_season = self._get_current_season()
        
        return {
            "current_season": current_season,
            "has_predictions": prediction is not None,
            "seasonal_adjustments": prediction.seasonal_adjustments if prediction else {},
            "growth_phase": prediction.growth_phase if prediction else None,
            "seasonal_care_tips": prediction.care_recommendations if prediction else []
        }
    
    async def _get_growth_patterns(self, plant_id: UUID, days_back: int) -> Dict[str, Any]:
        """Get growth pattern data from photos and measurements.
        
        Args:
            plant_id: Plant ID
            days_back: Number of days to look back
            
        Returns:
            Growth pattern data
        """
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        
        # Get recent growth photos
        result = await self.db.execute(
            select(GrowthPhoto)
            .where(
                and_(
                    GrowthPhoto.plant_id == plant_id,
                    GrowthPhoto.captured_at >= cutoff_date
                )
            )
            .order_by(desc(GrowthPhoto.captured_at))
        )
        photos = result.scalars().all()
        
        return {
            "photo_count": len(photos),
            "latest_photo": {
                "captured_at": photos[0].captured_at.isoformat(),
                "growth_stage": photos[0].growth_stage,
                "health_score": photos[0].health_score
            } if photos else None,
            "growth_trend": self._analyze_growth_trend(photos)
        }
    
    async def _get_user_preferences(self, user_id: UUID) -> Dict[str, Any]:
        """Get user care preferences and patterns.
        
        Args:
            user_id: User ID
            
        Returns:
            User preference data
        """
        # This would typically come from user settings or learned preferences
        # For now, return basic structure
        return {
            "care_frequency_preference": "moderate",
            "notification_preferences": {
                "watering_reminders": True,
                "fertilizer_reminders": True,
                "health_alerts": True
            },
            "experience_level": "intermediate"
        }
    
    async def _get_health_indicators(
        self,
        plant_id: UUID,
        days_back: int
    ) -> Dict[str, Any]:
        """Get plant health indicators and trends.
        
        Args:
            plant_id: Plant ID
            days_back: Number of days to look back
            
        Returns:
            Health indicator data
        """
        # Get recent photos with health scores
        cutoff_date = datetime.utcnow() - timedelta(days=days_back)
        
        result = await self.db.execute(
            select(GrowthPhoto)
            .where(
                and_(
                    GrowthPhoto.plant_id == plant_id,
                    GrowthPhoto.captured_at >= cutoff_date,
                    GrowthPhoto.health_score.isnot(None)
                )
            )
            .order_by(desc(GrowthPhoto.captured_at))
        )
        photos = result.scalars().all()
        
        health_scores = [p.health_score for p in photos if p.health_score]
        
        return {
            "current_health_score": health_scores[0] if health_scores else None,
            "average_health_score": sum(health_scores) / len(health_scores) if health_scores else None,
            "health_trend": self._calculate_health_trend(health_scores),
            "health_alerts": []  # Would be populated based on analysis
        }
    
    def _get_current_season(self) -> str:
        """Determine current season based on date.
        
        Returns:
            Current season name
        """
        month = datetime.utcnow().month
        if month in [12, 1, 2]:
            return "winter"
        elif month in [3, 4, 5]:
            return "spring"
        elif month in [6, 7, 8]:
            return "summer"
        else:
            return "autumn"
    
    def _analyze_growth_trend(self, photos: List[GrowthPhoto]) -> str:
        """Analyze growth trend from photos.
        
        Args:
            photos: List of growth photos
            
        Returns:
            Growth trend description
        """
        if len(photos) < 2:
            return "insufficient_data"
        
        # Simple trend analysis based on growth stages
        stages = [p.growth_stage for p in photos if p.growth_stage]
        if len(stages) < 2:
            return "stable"
        
        # This would be more sophisticated in a real implementation
        return "growing" if stages[0] != stages[-1] else "stable"
    
    def _calculate_health_trend(self, health_scores: List[float]) -> str:
        """Calculate health trend from scores.
        
        Args:
            health_scores: List of health scores
            
        Returns:
            Health trend description
        """
        if len(health_scores) < 2:
            return "stable"
        
        recent_avg = sum(health_scores[:3]) / min(3, len(health_scores))
        older_avg = sum(health_scores[-3:]) / min(3, len(health_scores[-3:]))
        
        if recent_avg > older_avg + 0.1:
            return "improving"
        elif recent_avg < older_avg - 0.1:
            return "declining"
        else:
            return "stable"
    
    def _calculate_completeness_score(self, context: Dict[str, Any]) -> float:
        """Calculate data completeness score for the context.
        
        Args:
            context: Context data dictionary
            
        Returns:
            Completeness score between 0.0 and 1.0
        """
        score = 0.0
        max_score = 6.0  # Number of main context components
        
        # Check each component
        if context.get("plant_info"):
            score += 1.0
        
        if context.get("care_history", {}).get("total_care_events", 0) > 0:
            score += 1.0
        
        if context.get("environmental_data", {}).get("has_data", False):
            score += 1.0
        
        if context.get("seasonal_context", {}).get("has_predictions", False):
            score += 1.0
        
        if context.get("growth_patterns", {}).get("photo_count", 0) > 0:
            score += 1.0
        
        if context.get("user_preferences"):
            score += 1.0
        
        return score / max_score