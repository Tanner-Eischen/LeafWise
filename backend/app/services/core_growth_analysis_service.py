"""
Core Growth Analysis Service for LeafWise Platform

This service provides fundamental growth analysis capabilities including:
- Growth trend analysis using time series data
- Growth rate calculations
- Measurement timeline extraction
- Basic growth phase detection

Focused on core analytics without community features or complex integrations.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant


class CoreGrowthAnalysisService:
    """Service for core growth analysis and trend detection."""
    
    def __init__(self):
        pass
    
    async def analyze_growth_trends(
        self,
        db: Session,
        plant_id: str,
        time_period_days: int = 90
    ) -> Dict[str, Any]:
        """
        Analyze growth trends for a specific plant using time series analysis.
        
        Args:
            db: Database session
            plant_id: ID of the plant to analyze
            time_period_days: Number of days to analyze
            
        Returns:
            Dictionary containing growth trend analysis
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get time-lapse sessions for the plant
        start_date = datetime.utcnow() - timedelta(days=time_period_days)
        sessions = db.query(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id,
            TimelapseSession.created_at >= start_date
        ).all()
        
        if not sessions:
            return self._empty_growth_trends_response(plant_id)
        
        # Get growth photos from sessions
        photos = []
        for session in sessions:
            session_photos = db.query(GrowthPhoto).filter(
                GrowthPhoto.timelapse_session_id == session.id
            ).all()
            photos.extend(session_photos)
        
        if len(photos) < 3:
            return self._insufficient_data_response(plant_id, len(photos))
        
        # Extract measurement timeline
        timeline = self.extract_measurement_timeline(photos)
        
        # Perform time series analysis
        trend_analysis = self.perform_time_series_analysis(timeline)
        growth_rates = self.calculate_growth_rates(timeline)
        growth_phases = self.detect_growth_phases(timeline, growth_rates)
        insights = self.generate_growth_insights(trend_analysis, growth_rates, growth_phases)
        
        return {
            "plant_id": plant_id,
            "analysis_period": {
                "start_date": start_date.isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "days": time_period_days
            },
            "trend_analysis": trend_analysis,
            "growth_rates": growth_rates,
            "growth_phases": growth_phases,
            "insights": insights,
            "data_quality": {
                "photo_count": len(photos),
                "measurement_completeness": self.calculate_measurement_completeness(photos)
            }
        }

    def extract_measurement_timeline(self, photos: List[GrowthPhoto]) -> List[Dict[str, Any]]:
        """
        Extract measurement timeline from growth photos.
        
        Args:
            photos: List of growth photos
            
        Returns:
            List of measurement data points sorted by date
        """
        timeline = []
        for photo in sorted(photos, key=lambda p: p.captured_at):
            timeline.append({
                "date": photo.captured_at,
                "height": photo.height_cm or 0,
                "width": photo.width_cm or 0,
                "leaf_count": photo.leaf_count or 0
            })
        return timeline

    def perform_time_series_analysis(self, timeline: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Perform basic time series analysis on growth data.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            Dictionary containing trend analysis results
        """
        if len(timeline) < 2:
            return {"trend": "insufficient_data", "direction": "unknown"}
        
        heights = [point["height"] for point in timeline]
        if heights[-1] > heights[0]:
            trend = "increasing"
        elif heights[-1] < heights[0]:
            trend = "decreasing"
        else:
            trend = "stable"
        
        return {
            "trend": trend,
            "direction": "upward" if trend == "increasing" else "downward" if trend == "decreasing" else "stable",
            "total_growth": heights[-1] - heights[0] if heights else 0,
            "average_height": sum(heights) / len(heights) if heights else 0
        }

    def calculate_growth_rates(self, timeline: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Calculate growth rates from timeline data.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            Dictionary containing daily and weekly growth rates
        """
        if len(timeline) < 2:
            return {"daily_rate": 0, "weekly_rate": 0}
        
        total_days = (timeline[-1]["date"] - timeline[0]["date"]).days
        total_growth = timeline[-1]["height"] - timeline[0]["height"]
        
        daily_rate = total_growth / total_days if total_days > 0 else 0
        weekly_rate = daily_rate * 7
        
        return {
            "daily_rate": round(daily_rate, 2),
            "weekly_rate": round(weekly_rate, 2)
        }

    def detect_growth_phases(self, timeline: List[Dict[str, Any]], growth_rates: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Detect different growth phases based on timeline and growth rates.
        
        Args:
            timeline: List of measurement data points
            growth_rates: Dictionary containing growth rate data
            
        Returns:
            List of detected growth phases
        """
        return [
            {
                "phase": "active_growth" if growth_rates["daily_rate"] > 0.1 else "slow_growth",
                "start_date": timeline[0]["date"].isoformat() if timeline else None,
                "end_date": timeline[-1]["date"].isoformat() if timeline else None,
                "characteristics": "Rapid vertical growth" if growth_rates["daily_rate"] > 0.1 else "Steady maintenance"
            }
        ]

    def generate_growth_insights(self, trend_analysis: Dict[str, Any], growth_rates: Dict[str, Any], growth_phases: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Generate insights based on growth analysis.
        
        Args:
            trend_analysis: Results from time series analysis
            growth_rates: Calculated growth rates
            growth_phases: Detected growth phases
            
        Returns:
            List of growth insights and recommendations
        """
        return [
            {
                "type": "growth_trend",
                "message": f"Your plant is showing {trend_analysis['trend']} growth patterns",
                "recommendation": "Continue current care routine" if trend_analysis["trend"] == "increasing" else "Consider adjusting care routine"
            }
        ]

    def calculate_measurement_completeness(self, photos: List[GrowthPhoto]) -> float:
        """
        Calculate completeness of measurements in photos.
        
        Args:
            photos: List of growth photos
            
        Returns:
            Percentage of photos with complete measurements
        """
        if not photos:
            return 0.0
        
        complete_measurements = sum(1 for photo in photos if photo.height_cm and photo.width_cm)
        return (complete_measurements / len(photos)) * 100

    def _empty_growth_trends_response(self, plant_id: str) -> Dict[str, Any]:
        """
        Return response for plants with no growth data.
        
        Args:
            plant_id: ID of the plant
            
        Returns:
            Dictionary indicating no data available
        """
        return {
            "plant_id": plant_id,
            "status": "no_data",
            "message": "No time-lapse sessions found for analysis"
        }

    def _insufficient_data_response(self, plant_id: str, photo_count: int) -> Dict[str, Any]:
        """
        Return response for plants with insufficient data.
        
        Args:
            plant_id: ID of the plant
            photo_count: Number of photos available
            
        Returns:
            Dictionary indicating insufficient data
        """
        return {
            "plant_id": plant_id,
            "status": "insufficient_data",
            "message": f"Only {photo_count} photos available. Need at least 3 for trend analysis."
        }


def get_core_growth_analysis_service() -> CoreGrowthAnalysisService:
    """
    Factory function to get CoreGrowthAnalysisService instance.
    
    Returns:
        CoreGrowthAnalysisService instance
    """
    return CoreGrowthAnalysisService()