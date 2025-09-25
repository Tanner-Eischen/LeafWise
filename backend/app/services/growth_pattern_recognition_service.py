"""
Growth Pattern Recognition Service for LeafWise Platform

This service provides advanced pattern recognition capabilities including:
- Growth pattern detection and classification
- Anomaly detection in growth data
- Growth milestone identification
- Pattern-based predictions

Focused on pattern analysis and recognition algorithms.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import numpy as np

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant


class GrowthPatternRecognitionService:
    """Service for advanced growth pattern recognition and analysis."""
    
    def __init__(self):
        pass
    
    async def detect_growth_patterns(
        self,
        db: Session,
        plant_id: str,
        timeline: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Detect and classify growth patterns from timeline data.
        
        Args:
            db: Database session
            plant_id: ID of the plant
            timeline: List of measurement data points
            
        Returns:
            Dictionary containing detected patterns
        """
        if len(timeline) < 5:
            return {"status": "insufficient_data", "patterns": []}
        
        # Detect different types of patterns
        growth_spurts = self.detect_growth_spurts(timeline)
        dormancy_periods = self.detect_dormancy_periods(timeline)
        seasonal_patterns = self.detect_seasonal_patterns(timeline)
        anomalies = self.detect_growth_anomalies(timeline)
        
        return {
            "plant_id": plant_id,
            "analysis_date": datetime.utcnow().isoformat(),
            "patterns": {
                "growth_spurts": growth_spurts,
                "dormancy_periods": dormancy_periods,
                "seasonal_patterns": seasonal_patterns,
                "anomalies": anomalies
            },
            "pattern_summary": self.generate_pattern_summary(growth_spurts, dormancy_periods, seasonal_patterns)
        }
    
    def detect_growth_spurts(self, timeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Detect periods of rapid growth in the timeline.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            List of detected growth spurts
        """
        spurts = []
        heights = [point["height"] for point in timeline]
        
        # Calculate growth rates between consecutive measurements
        for i in range(1, len(timeline)):
            days_diff = (timeline[i]["date"] - timeline[i-1]["date"]).days
            if days_diff > 0:
                growth_rate = (heights[i] - heights[i-1]) / days_diff
                
                # Consider it a growth spurt if rate > 0.5 cm/day
                if growth_rate > 0.5:
                    spurts.append({
                        "start_date": timeline[i-1]["date"].isoformat(),
                        "end_date": timeline[i]["date"].isoformat(),
                        "growth_rate": round(growth_rate, 2),
                        "total_growth": round(heights[i] - heights[i-1], 2),
                        "duration_days": days_diff
                    })
        
        return spurts
    
    def detect_dormancy_periods(self, timeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Detect periods of minimal or no growth.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            List of detected dormancy periods
        """
        dormancy_periods = []
        heights = [point["height"] for point in timeline]
        
        dormancy_start = None
        for i in range(1, len(timeline)):
            days_diff = (timeline[i]["date"] - timeline[i-1]["date"]).days
            if days_diff > 0:
                growth_rate = abs(heights[i] - heights[i-1]) / days_diff
                
                # Consider dormancy if growth rate < 0.1 cm/day
                if growth_rate < 0.1:
                    if dormancy_start is None:
                        dormancy_start = i-1
                else:
                    if dormancy_start is not None:
                        dormancy_periods.append({
                            "start_date": timeline[dormancy_start]["date"].isoformat(),
                            "end_date": timeline[i-1]["date"].isoformat(),
                            "duration_days": (timeline[i-1]["date"] - timeline[dormancy_start]["date"]).days,
                            "avg_growth_rate": round(growth_rate, 3)
                        })
                        dormancy_start = None
        
        return dormancy_periods
    
    def detect_seasonal_patterns(self, timeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Detect seasonal growth patterns.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            List of detected seasonal patterns
        """
        seasonal_patterns = []
        
        # Group measurements by season
        seasons = {"spring": [], "summer": [], "fall": [], "winter": []}
        
        for point in timeline:
            month = point["date"].month
            if month in [3, 4, 5]:
                seasons["spring"].append(point)
            elif month in [6, 7, 8]:
                seasons["summer"].append(point)
            elif month in [9, 10, 11]:
                seasons["fall"].append(point)
            else:
                seasons["winter"].append(point)
        
        # Analyze growth patterns for each season
        for season, points in seasons.items():
            if len(points) >= 2:
                heights = [p["height"] for p in points]
                avg_growth = (heights[-1] - heights[0]) / len(points) if len(points) > 1 else 0
                
                seasonal_patterns.append({
                    "season": season,
                    "measurement_count": len(points),
                    "average_growth_rate": round(avg_growth, 2),
                    "pattern_type": self.classify_seasonal_pattern(avg_growth)
                })
        
        return seasonal_patterns
    
    def detect_growth_anomalies(self, timeline: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Detect anomalies in growth data.
        
        Args:
            timeline: List of measurement data points
            
        Returns:
            List of detected anomalies
        """
        anomalies = []
        heights = [point["height"] for point in timeline]
        
        if len(heights) < 3:
            return anomalies
        
        # Calculate moving average and standard deviation
        window_size = min(5, len(heights) // 2)
        for i in range(window_size, len(heights)):
            window = heights[i-window_size:i]
            mean_height = np.mean(window)
            std_height = np.std(window)
            
            # Detect significant deviations
            if abs(heights[i] - mean_height) > 2 * std_height:
                anomalies.append({
                    "date": timeline[i]["date"].isoformat(),
                    "height": heights[i],
                    "expected_height": round(mean_height, 2),
                    "deviation": round(abs(heights[i] - mean_height), 2),
                    "anomaly_type": "sudden_growth" if heights[i] > mean_height else "growth_decline"
                })
        
        return anomalies
    
    def classify_seasonal_pattern(self, avg_growth: float) -> str:
        """
        Classify seasonal growth pattern based on average growth rate.
        
        Args:
            avg_growth: Average growth rate for the season
            
        Returns:
            Classification of the seasonal pattern
        """
        if avg_growth > 0.3:
            return "active_growth"
        elif avg_growth > 0.1:
            return "moderate_growth"
        elif avg_growth > -0.1:
            return "stable"
        else:
            return "decline"
    
    def generate_pattern_summary(
        self,
        growth_spurts: List[Dict[str, Any]],
        dormancy_periods: List[Dict[str, Any]],
        seasonal_patterns: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Generate a summary of detected patterns.
        
        Args:
            growth_spurts: List of detected growth spurts
            dormancy_periods: List of detected dormancy periods
            seasonal_patterns: List of seasonal patterns
            
        Returns:
            Summary of all detected patterns
        """
        return {
            "total_growth_spurts": len(growth_spurts),
            "total_dormancy_periods": len(dormancy_periods),
            "seasonal_pattern_count": len(seasonal_patterns),
            "dominant_pattern": self.identify_dominant_pattern(growth_spurts, dormancy_periods),
            "growth_consistency": self.calculate_growth_consistency(seasonal_patterns)
        }
    
    def identify_dominant_pattern(
        self,
        growth_spurts: List[Dict[str, Any]],
        dormancy_periods: List[Dict[str, Any]]
    ) -> str:
        """
        Identify the dominant growth pattern.
        
        Args:
            growth_spurts: List of growth spurts
            dormancy_periods: List of dormancy periods
            
        Returns:
            Dominant pattern classification
        """
        if len(growth_spurts) > len(dormancy_periods):
            return "growth_oriented"
        elif len(dormancy_periods) > len(growth_spurts):
            return "dormancy_prone"
        else:
            return "balanced"
    
    def calculate_growth_consistency(self, seasonal_patterns: List[Dict[str, Any]]) -> float:
        """
        Calculate growth consistency across seasons.
        
        Args:
            seasonal_patterns: List of seasonal patterns
            
        Returns:
            Growth consistency score (0-1)
        """
        if not seasonal_patterns:
            return 0.0
        
        growth_rates = [pattern["average_growth_rate"] for pattern in seasonal_patterns]
        if len(growth_rates) < 2:
            return 1.0
        
        # Calculate coefficient of variation (lower = more consistent)
        mean_rate = np.mean(growth_rates)
        std_rate = np.std(growth_rates)
        
        if mean_rate == 0:
            return 0.0
        
        cv = std_rate / abs(mean_rate)
        # Convert to consistency score (1 - normalized CV)
        return max(0.0, 1.0 - min(cv, 1.0))


def get_growth_pattern_recognition_service() -> GrowthPatternRecognitionService:
    """
    Factory function to get GrowthPatternRecognitionService instance.
    
    Returns:
        GrowthPatternRecognitionService instance
    """
    return GrowthPatternRecognitionService()