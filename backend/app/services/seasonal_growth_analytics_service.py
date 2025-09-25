"""
Seasonal Growth Analytics Service for LeafWise Platform

This service provides seasonal analysis capabilities including:
- Seasonal transition detection and analysis
- Weather correlation with growth patterns
- Seasonal care recommendations

Focused on seasonal patterns and environmental correlations.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
import json

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant


class SeasonalGrowthAnalyticsService:
    """Service for seasonal growth analysis and environmental correlations."""
    
    def __init__(self):
        pass
    
    async def analyze_seasonal_patterns(
        self,
        db: Session,
        plant_id: str,
        location: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Analyze seasonal growth patterns for a plant.
        
        Args:
            db: Database session
            plant_id: ID of the plant to analyze
            location: Optional location for weather correlation
            
        Returns:
            Dictionary containing seasonal analysis results
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get growth data for the past year
        start_date = datetime.utcnow() - timedelta(days=365)
        sessions = db.query(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id,
            TimelapseSession.created_at >= start_date
        ).all()
        
        if not sessions:
            return self._empty_seasonal_analysis_response(plant_id)
        
        # Get growth photos from sessions
        photos = []
        for session in sessions:
            session_photos = db.query(GrowthPhoto).filter(
                GrowthPhoto.timelapse_session_id == session.id
            ).all()
            photos.extend(session_photos)
        
        if len(photos) < 10:
            return self._insufficient_seasonal_data_response(plant_id, len(photos))
        
        # Analyze seasonal patterns
        seasonal_breakdown = self.analyze_seasonal_breakdown(photos)
        transition_periods = self.detect_seasonal_transitions(photos)
        seasonal_recommendations = self.generate_seasonal_recommendations(seasonal_breakdown, plant.species_id)
        
        return {
            "plant_id": plant_id,
            "analysis_period": {
                "start_date": start_date.isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "total_photos": len(photos)
            },
            "seasonal_breakdown": seasonal_breakdown,
            "transition_periods": transition_periods,
            "seasonal_recommendations": seasonal_recommendations,
            "seasonal_health_score": self.calculate_seasonal_health_score(seasonal_breakdown)
        }
    
    def analyze_seasonal_breakdown(self, photos: List[GrowthPhoto]) -> Dict[str, Any]:
        """
        Break down growth data by seasons.
        
        Args:
            photos: List of growth photos
            
        Returns:
            Dictionary containing seasonal breakdown
        """
        seasons = {
            "spring": {"photos": [], "growth": 0, "months": [3, 4, 5]},
            "summer": {"photos": [], "growth": 0, "months": [6, 7, 8]},
            "fall": {"photos": [], "growth": 0, "months": [9, 10, 11]},
            "winter": {"photos": [], "growth": 0, "months": [12, 1, 2]}
        }
        
        # Categorize photos by season
        for photo in photos:
            month = photo.captured_at.month
            for season_name, season_data in seasons.items():
                if month in season_data["months"]:
                    season_data["photos"].append(photo)
                    break
        
        # Calculate growth metrics for each season
        for season_name, season_data in seasons.items():
            if len(season_data["photos"]) >= 2:
                season_photos = sorted(season_data["photos"], key=lambda p: p.captured_at)
                initial_height = season_photos[0].height_cm or 0
                final_height = season_photos[-1].height_cm or 0
                season_data["growth"] = final_height - initial_height
                season_data["growth_rate"] = self.calculate_seasonal_growth_rate(season_photos)
                season_data["photo_count"] = len(season_photos)
                season_data["avg_leaf_count"] = sum(p.leaf_count or 0 for p in season_photos) / len(season_photos)
            else:
                season_data["growth_rate"] = 0
                season_data["photo_count"] = len(season_data["photos"])
                season_data["avg_leaf_count"] = 0
        
        return seasons
    
    def calculate_seasonal_growth_rate(self, photos: List[GrowthPhoto]) -> float:
        """
        Calculate growth rate for a season.
        
        Args:
            photos: List of photos for the season
            
        Returns:
            Growth rate in cm per day
        """
        if len(photos) < 2:
            return 0.0
        
        total_growth = (photos[-1].height_cm or 0) - (photos[0].height_cm or 0)
        total_days = (photos[-1].captured_at - photos[0].captured_at).days
        
        return total_growth / total_days if total_days > 0 else 0.0
    
    def detect_seasonal_transitions(self, photos: List[GrowthPhoto]) -> List[Dict[str, Any]]:
        """
        Detect seasonal transition periods and their effects.
        
        Args:
            photos: List of growth photos
            
        Returns:
            List of detected seasonal transitions
        """
        transitions = []
        sorted_photos = sorted(photos, key=lambda p: p.captured_at)
        
        # Look for significant changes in growth patterns at season boundaries
        transition_months = [3, 6, 9, 12]  # March, June, September, December
        
        for i, photo in enumerate(sorted_photos[:-1]):
            if photo.captured_at.month in transition_months and i > 0 and i < len(sorted_photos) - 2:
                prev_photo = sorted_photos[i - 1]
                next_photo = sorted_photos[i + 1]
                future_photo = sorted_photos[i + 2]
                
                before_rate = self.calculate_growth_rate_between_photos(prev_photo, photo)
                after_rate = self.calculate_growth_rate_between_photos(next_photo, future_photo)
                
                rate_change = after_rate - before_rate
                
                if abs(rate_change) > 0.1:  # Significant change threshold
                    transitions.append({
                        "date": photo.captured_at.isoformat(),
                        "season_from": self.get_season_from_month(photo.captured_at.month - 1),
                        "season_to": self.get_season_from_month(photo.captured_at.month),
                        "growth_rate_change": round(rate_change, 3),
                        "transition_type": "acceleration" if rate_change > 0 else "deceleration"
                    })
        
        return transitions
    
    def calculate_growth_rate_between_photos(self, photo1: GrowthPhoto, photo2: GrowthPhoto) -> float:
        """Calculate growth rate between two photos."""
        height_diff = (photo2.height_cm or 0) - (photo1.height_cm or 0)
        days_diff = (photo2.captured_at - photo1.captured_at).days
        return height_diff / days_diff if days_diff > 0 else 0.0
    
    def get_season_from_month(self, month: int) -> str:
        """Get season name from month number."""
        if month in [3, 4, 5]:
            return "spring"
        elif month in [6, 7, 8]:
            return "summer"
        elif month in [9, 10, 11]:
            return "fall"
        else:
            return "winter"
    
    def generate_seasonal_recommendations(
        self,
        seasonal_breakdown: Dict[str, Any],
        species_id: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Generate seasonal care recommendations based on analysis."""
        recommendations = []
        current_season = self.get_season_from_month(datetime.utcnow().month)
        
        # Analyze each season's performance
        for season, data in seasonal_breakdown.items():
            if data["photo_count"] > 0:
                growth_rate = data.get("growth_rate", 0)
                
                if growth_rate < 0.05:  # Low growth rate
                    recommendations.append({
                        "season": season,
                        "type": "care_adjustment",
                        "priority": "high" if season == current_season else "medium",
                        "recommendation": f"Consider adjusting care routine for {season} - growth rate is below optimal"
                    })
                elif growth_rate > 0.3:  # High growth rate
                    recommendations.append({
                        "season": season,
                        "type": "maintenance",
                        "priority": "medium",
                        "recommendation": f"Excellent growth in {season} - maintain current care routine"
                    })
        
        return recommendations
    
    def calculate_seasonal_health_score(self, seasonal_breakdown: Dict[str, Any]) -> float:
        """Calculate overall seasonal health score."""
        total_score = 0
        season_count = 0
        
        for season, data in seasonal_breakdown.items():
            if data["photo_count"] > 0:
                growth_rate = data.get("growth_rate", 0)
                # Score based on growth rate (0.1 cm/day = 50 points, 0.2+ = 100 points)
                season_score = min(100, (growth_rate / 0.2) * 100)
                total_score += season_score
                season_count += 1
        
        return round(total_score / season_count if season_count > 0 else 0, 1)
    
    def _empty_seasonal_analysis_response(self, plant_id: str) -> Dict[str, Any]:
        """Return response for plants with no seasonal data."""
        return {
            "plant_id": plant_id,
            "status": "no_seasonal_data",
            "message": "No growth data available for seasonal analysis"
        }
    
    def _insufficient_seasonal_data_response(self, plant_id: str, photo_count: int) -> Dict[str, Any]:
        """Return response for plants with insufficient seasonal data."""
        return {
            "plant_id": plant_id,
            "status": "insufficient_seasonal_data",
            "message": f"Only {photo_count} photos available. Need at least 10 for seasonal analysis."
        }


def get_seasonal_growth_analytics_service() -> SeasonalGrowthAnalyticsService:
    """Factory function to get SeasonalGrowthAnalyticsService instance."""
    return SeasonalGrowthAnalyticsService()