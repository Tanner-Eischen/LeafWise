"""
Growth Analytics Service for Plant Social Platform

This service provides comprehensive growth analytics and insights for time-lapse tracking,
including pattern recognition, comparative analytics, and community insights.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, text, desc, asc, and_, or_
import json
import statistics
import numpy as np
from collections import defaultdict
from uuid import UUID, uuid4

from app.models.timelapse import TimelapseSession, GrowthPhoto, GrowthMilestone, GrowthAnalytics
from app.models.user_plant import UserPlant
from app.models.user import User
from app.models.seasonal_ai import SeasonalPrediction
from app.schemas.timelapse import PlantMeasurements, GrowthChanges, HealthIndicators


class GrowthAnalyticsService:
    """Service for growth analytics and pattern recognition."""
    
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
        
        # Get all photos from these sessions
        session_ids = [session.id for session in sessions]
        photos = db.query(GrowthPhoto).filter(
            GrowthPhoto.session_id.in_(session_ids),
            GrowthPhoto.processing_status == "completed"
        ).order_by(GrowthPhoto.capture_date).all()
        
        if len(photos) < 2:
            return self._insufficient_data_response(plant_id, len(photos))
        
        # Extract measurement data
        measurement_timeline = self._extract_measurement_timeline(photos)
        
        # Perform time series analysis
        trend_analysis = self._perform_time_series_analysis(measurement_timeline)
        
        # Calculate growth rates
        growth_rates = self._calculate_growth_rates(measurement_timeline)
        
        # Detect growth phases
        growth_phases = self._detect_growth_phases(measurement_timeline, growth_rates)
        
        # Generate insights
        insights = self._generate_growth_insights(trend_analysis, growth_rates, growth_phases)
        
        return {
            "plant_id": plant_id,
            "analysis_period": {
                "start_date": start_date.isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "days": time_period_days
            },
            "data_quality": {
                "total_photos": len(photos),
                "sessions_analyzed": len(sessions),
                "measurement_completeness": self._calculate_measurement_completeness(photos)
            },
            "trend_analysis": trend_analysis,
            "growth_rates": growth_rates,
            "growth_phases": growth_phases,
            "insights": insights,
            "measurement_timeline": measurement_timeline
        }
    
    async def compare_plant_performance(
        self,
        db: Session,
        user_id: str,
        comparison_type: str = "user_plants",
        time_period_days: int = 90
    ) -> Dict[str, Any]:
        """
        Compare growth performance across plant collections.
        
        Args:
            db: Database session
            user_id: ID of the user
            comparison_type: Type of comparison ("user_plants", "species", "community")
            time_period_days: Number of days to analyze
            
        Returns:
            Dictionary containing comparative analytics
        """
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError(f"User with id {user_id} not found")
        
        start_date = datetime.utcnow() - timedelta(days=time_period_days)
        
        if comparison_type == "user_plants":
            return await self._compare_user_plants(db, user_id, start_date, time_period_days)
        elif comparison_type == "species":
            return await self._compare_by_species(db, user_id, start_date, time_period_days)
        elif comparison_type == "community":
            return await self._compare_with_community(db, user_id, start_date, time_period_days)
        else:
            raise ValueError(f"Invalid comparison_type: {comparison_type}")
    
    async def identify_seasonal_patterns(
        self,
        db: Session,
        plant_id: str,
        seasons_to_analyze: int = 4
    ) -> Dict[str, Any]:
        """
        Identify seasonal response patterns using clustering algorithms.
        
        Args:
            db: Database session
            plant_id: ID of the plant to analyze
            seasons_to_analyze: Number of seasons to analyze
            
        Returns:
            Dictionary containing seasonal pattern analysis
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get data spanning multiple seasons
        analysis_days = seasons_to_analyze * 90  # Approximate 90 days per season
        start_date = datetime.utcnow() - timedelta(days=analysis_days)
        
        # Get time-lapse data
        sessions = db.query(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id,
            TimelapseSession.created_at >= start_date
        ).all()
        
        if not sessions:
            return self._empty_seasonal_patterns_response(plant_id)
        
        # Get photos and seasonal predictions
        session_ids = [session.id for session in sessions]
        photos = db.query(GrowthPhoto).filter(
            GrowthPhoto.session_id.in_(session_ids),
            GrowthPhoto.processing_status == "completed"
        ).order_by(GrowthPhoto.capture_date).all()
        
        seasonal_predictions = db.query(SeasonalPrediction).filter(
            SeasonalPrediction.plant_id == plant_id,
            SeasonalPrediction.prediction_date >= start_date
        ).all()
        
        # Perform seasonal clustering analysis
        seasonal_clusters = self._perform_seasonal_clustering(photos, seasonal_predictions)
        
        # Identify seasonal response patterns
        response_patterns = self._identify_response_patterns(seasonal_clusters)
        
        # Generate seasonal insights
        seasonal_insights = self._generate_seasonal_insights(response_patterns, seasonal_clusters)
        
        return {
            "plant_id": plant_id,
            "analysis_period": {
                "start_date": start_date.isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "seasons_analyzed": seasons_to_analyze
            },
            "data_quality": {
                "total_photos": len(photos),
                "seasonal_predictions": len(seasonal_predictions),
                "sessions_analyzed": len(sessions)
            },
            "seasonal_clusters": seasonal_clusters,
            "response_patterns": response_patterns,
            "insights": seasonal_insights,
            "recommendations": self._generate_seasonal_recommendations(response_patterns)
        }
    
    async def generate_growth_analytics_report(
        self,
        db: Session,
        plant_id: str,
        analysis_type: str = "comprehensive"
    ) -> Dict[str, Any]:
        """
        Generate comprehensive growth analytics report.
        
        Args:
            db: Database session
            plant_id: ID of the plant
            analysis_type: Type of analysis ("comprehensive", "trends", "seasonal", "comparative")
            
        Returns:
            Dictionary containing complete analytics report
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        report = {
            "plant_id": plant_id,
            "plant_info": {
                "nickname": plant.nickname,
                "species_id": str(plant.species_id),
                "location": plant.location,
                "acquired_date": plant.acquired_date.isoformat() if plant.acquired_date else None,
                "health_status": plant.health_status
            },
            "report_type": analysis_type,
            "generated_at": datetime.utcnow().isoformat()
        }
        
        if analysis_type in ["comprehensive", "trends"]:
            # Add growth trend analysis
            trend_analysis = await self.analyze_growth_trends(db, plant_id, 90)
            report["growth_trends"] = trend_analysis
        
        if analysis_type in ["comprehensive", "seasonal"]:
            # Add seasonal pattern analysis
            seasonal_analysis = await self.identify_seasonal_patterns(db, plant_id, 4)
            report["seasonal_patterns"] = seasonal_analysis
        
        if analysis_type in ["comprehensive", "comparative"]:
            # Add comparative analysis
            comparative_analysis = await self.compare_plant_performance(
                db, str(plant.user_id), "user_plants", 90
            )
            report["comparative_analysis"] = comparative_analysis
        
        # Add summary statistics
        report["summary"] = await self._generate_analytics_summary(db, plant_id)
        
        # Store analytics report in database
        await self._store_analytics_report(db, plant_id, str(plant.user_id), report)
        
        return report
    
    # Helper methods for time series analysis
    
    def _extract_measurement_timeline(self, photos: List[GrowthPhoto]) -> List[Dict[str, Any]]:
        """Extract measurement timeline from photos."""
        timeline = []
        
        for photo in photos:
            if not photo.plant_measurements:
                continue
            
            measurements = photo.plant_measurements
            timeline.append({
                "date": photo.capture_date,
                "photo_id": str(photo.id),
                "measurements": measurements,
                "sequence_number": photo.sequence_number
            })
        
        return timeline
    
    def _perform_time_series_analysis(self, timeline: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Perform time series analysis on measurement data."""
        if len(timeline) < 3:
            return {"status": "insufficient_data", "message": "Need at least 3 data points"}
        
        # Extract height data for trend analysis
        height_data = []
        dates = []
        
        for point in timeline:
            measurements = point["measurements"]
            if isinstance(measurements, dict) and "height_cm" in measurements:
                height = measurements["height_cm"]
                if height is not None:
                    height_data.append(float(height))
                    dates.append(point["date"])
        
        if len(height_data) < 3:
            return {"status": "insufficient_height_data"}
        
        # Calculate trend using linear regression
        x = np.arange(len(height_data))
        coefficients = np.polyfit(x, height_data, 1)
        trend_slope = coefficients[0]
        
        # Calculate trend strength (R-squared)
        y_pred = np.polyval(coefficients, x)
        ss_res = np.sum((height_data - y_pred) ** 2)
        ss_tot = np.sum((height_data - np.mean(height_data)) ** 2)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        
        # Determine trend direction
        if trend_slope > 0.1:
            trend_direction = "increasing"
        elif trend_slope < -0.1:
            trend_direction = "decreasing"
        else:
            trend_direction = "stable"
        
        return {
            "status": "success",
            "trend_slope": float(trend_slope),
            "trend_direction": trend_direction,
            "trend_strength": float(r_squared),
            "data_points": len(height_data),
            "height_range": {
                "min": float(min(height_data)),
                "max": float(max(height_data)),
                "current": float(height_data[-1])
            }
        }
    
    def _calculate_growth_rates(self, timeline: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate various growth rates."""
        if len(timeline) < 2:
            return {"status": "insufficient_data"}
        
        rates = {
            "height_rate_cm_per_day": [],
            "width_rate_cm_per_day": [],
            "leaf_count_rate_per_day": []
        }
        
        for i in range(1, len(timeline)):
            current = timeline[i]
            previous = timeline[i-1]
            
            # Calculate time difference in days
            time_diff = (current["date"] - previous["date"]).total_seconds() / (24 * 3600)
            if time_diff <= 0:
                continue
            
            curr_measurements = current["measurements"]
            prev_measurements = previous["measurements"]
            
            if isinstance(curr_measurements, dict) and isinstance(prev_measurements, dict):
                # Height growth rate
                if "height_cm" in curr_measurements and "height_cm" in prev_measurements:
                    curr_height = curr_measurements.get("height_cm")
                    prev_height = prev_measurements.get("height_cm")
                    if curr_height is not None and prev_height is not None:
                        height_rate = (float(curr_height) - float(prev_height)) / time_diff
                        rates["height_rate_cm_per_day"].append(height_rate)
                
                # Width growth rate
                if "width_cm" in curr_measurements and "width_cm" in prev_measurements:
                    curr_width = curr_measurements.get("width_cm")
                    prev_width = prev_measurements.get("width_cm")
                    if curr_width is not None and prev_width is not None:
                        width_rate = (float(curr_width) - float(prev_width)) / time_diff
                        rates["width_rate_cm_per_day"].append(width_rate)
                
                # Leaf count rate
                if "leaf_count" in curr_measurements and "leaf_count" in prev_measurements:
                    curr_leaves = curr_measurements.get("leaf_count")
                    prev_leaves = prev_measurements.get("leaf_count")
                    if curr_leaves is not None and prev_leaves is not None:
                        leaf_rate = (int(curr_leaves) - int(prev_leaves)) / time_diff
                        rates["leaf_count_rate_per_day"].append(leaf_rate)
        
        # Calculate statistics for each rate
        result = {}
        for rate_type, values in rates.items():
            if values:
                result[rate_type] = {
                    "average": float(statistics.mean(values)),
                    "median": float(statistics.median(values)),
                    "std_dev": float(statistics.stdev(values)) if len(values) > 1 else 0,
                    "min": float(min(values)),
                    "max": float(max(values)),
                    "data_points": len(values)
                }
            else:
                result[rate_type] = {"status": "no_data"}
        
        return result 
   
    def _detect_growth_phases(
        self, 
        timeline: List[Dict[str, Any]], 
        growth_rates: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Detect distinct growth phases based on rate changes."""
        if len(timeline) < 4:
            return []
        
        phases = []
        height_rates = growth_rates.get("height_rate_cm_per_day", {})
        
        if "data_points" not in height_rates or height_rates["data_points"] < 3:
            return []
        
        # Simple phase detection based on growth rate changes
        # In a real implementation, this would use more sophisticated algorithms
        avg_rate = height_rates["average"]
        std_dev = height_rates["std_dev"]
        
        if avg_rate > 0.1:
            if std_dev < 0.05:
                phases.append({
                    "phase_type": "steady_growth",
                    "description": "Consistent steady growth phase",
                    "duration_days": len(timeline),
                    "characteristics": ["stable_rate", "predictable_growth"]
                })
            else:
                phases.append({
                    "phase_type": "variable_growth",
                    "description": "Variable growth with fluctuations",
                    "duration_days": len(timeline),
                    "characteristics": ["variable_rate", "growth_spurts"]
                })
        elif avg_rate < -0.05:
            phases.append({
                "phase_type": "decline",
                "description": "Declining growth or health issues",
                "duration_days": len(timeline),
                "characteristics": ["negative_growth", "health_concern"]
            })
        else:
            phases.append({
                "phase_type": "dormant",
                "description": "Minimal growth, possibly dormant period",
                "duration_days": len(timeline),
                "characteristics": ["minimal_growth", "stable_size"]
            })
        
        return phases
    
    def _generate_growth_insights(
        self,
        trend_analysis: Dict[str, Any],
        growth_rates: Dict[str, Any],
        growth_phases: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Generate actionable insights from growth analysis."""
        insights = []
        
        # Trend-based insights
        if trend_analysis.get("status") == "success":
            trend_direction = trend_analysis["trend_direction"]
            trend_strength = trend_analysis["trend_strength"]
            
            if trend_direction == "increasing" and trend_strength > 0.7:
                insights.append({
                    "type": "positive",
                    "title": "Strong Growth Trend",
                    "description": f"Your plant shows consistent upward growth with {trend_strength:.1%} trend strength",
                    "confidence": trend_strength,
                    "actionable": "Continue current care routine as it's working well"
                })
            elif trend_direction == "decreasing":
                insights.append({
                    "type": "warning",
                    "title": "Declining Growth",
                    "description": "Growth trend is declining, may need care adjustments",
                    "confidence": trend_strength,
                    "actionable": "Review watering, lighting, and fertilization schedule"
                })
        
        # Growth rate insights
        height_rates = growth_rates.get("height_rate_cm_per_day", {})
        if "average" in height_rates:
            avg_rate = height_rates["average"]
            if avg_rate > 0.2:
                insights.append({
                    "type": "positive",
                    "title": "Rapid Growth",
                    "description": f"Excellent growth rate of {avg_rate:.2f} cm/day",
                    "confidence": 0.8,
                    "actionable": "Monitor for adequate nutrition to support rapid growth"
                })
            elif avg_rate < 0.05:
                insights.append({
                    "type": "info",
                    "title": "Slow Growth",
                    "description": "Growth rate is slower than typical",
                    "confidence": 0.7,
                    "actionable": "Consider increasing light exposure or checking soil nutrients"
                })
        
        # Phase-based insights
        for phase in growth_phases:
            if phase["phase_type"] == "decline":
                insights.append({
                    "type": "alert",
                    "title": "Health Concern Detected",
                    "description": "Growth analysis indicates potential health issues",
                    "confidence": 0.9,
                    "actionable": "Inspect plant for pests, diseases, or environmental stress"
                })
        
        return insights
    
    def _calculate_measurement_completeness(self, photos: List[GrowthPhoto]) -> float:
        """Calculate completeness of measurement data."""
        if not photos:
            return 0.0
        
        total_measurements = 0
        complete_measurements = 0
        
        for photo in photos:
            if photo.plant_measurements:
                measurements = photo.plant_measurements
                if isinstance(measurements, dict):
                    # Count expected measurements
                    expected_fields = ["height_cm", "width_cm", "leaf_count", "health_score"]
                    total_measurements += len(expected_fields)
                    
                    # Count available measurements
                    for field in expected_fields:
                        if field in measurements and measurements[field] is not None:
                            complete_measurements += 1
        
        return complete_measurements / total_measurements if total_measurements > 0 else 0.0
    
    # Helper methods for comparative analysis
    
    async def _compare_user_plants(
        self,
        db: Session,
        user_id: str,
        start_date: datetime,
        time_period_days: int
    ) -> Dict[str, Any]:
        """Compare growth performance across user's plants."""
        user_plants = db.query(UserPlant).filter(
            UserPlant.user_id == user_id,
            UserPlant.is_active == True
        ).all()
        
        if len(user_plants) < 2:
            return {
                "comparison_type": "user_plants",
                "status": "insufficient_plants",
                "message": "Need at least 2 plants for comparison"
            }
        
        plant_performances = []
        
        for plant in user_plants:
            try:
                # Get growth trend for each plant
                trend_analysis = await self.analyze_growth_trends(
                    db, str(plant.id), time_period_days
                )
                
                # Extract key metrics
                performance = {
                    "plant_id": str(plant.id),
                    "plant_name": plant.nickname or "Unnamed Plant",
                    "species_id": str(plant.species_id),
                    "health_status": plant.health_status
                }
                
                if trend_analysis.get("trend_analysis", {}).get("status") == "success":
                    trend = trend_analysis["trend_analysis"]
                    performance.update({
                        "growth_trend": trend["trend_direction"],
                        "trend_strength": trend["trend_strength"],
                        "current_height": trend["height_range"]["current"],
                        "height_change": trend["height_range"]["max"] - trend["height_range"]["min"]
                    })
                else:
                    performance.update({
                        "growth_trend": "no_data",
                        "trend_strength": 0,
                        "current_height": 0,
                        "height_change": 0
                    })
                
                plant_performances.append(performance)
                
            except Exception as e:
                # Skip plants with errors
                continue
        
        # Rank plants by performance
        ranked_plants = self._rank_plant_performance(plant_performances)
        
        # Generate comparative insights
        comparative_insights = self._generate_comparative_insights(ranked_plants)
        
        return {
            "comparison_type": "user_plants",
            "total_plants": len(user_plants),
            "analyzed_plants": len(plant_performances),
            "time_period_days": time_period_days,
            "plant_rankings": ranked_plants,
            "insights": comparative_insights,
            "summary": {
                "best_performer": ranked_plants[0] if ranked_plants else None,
                "needs_attention": [p for p in ranked_plants if p.get("performance_score", 0) < 0.3]
            }
        }
    
    async def _compare_by_species(
        self,
        db: Session,
        user_id: str,
        start_date: datetime,
        time_period_days: int
    ) -> Dict[str, Any]:
        """Compare growth performance by plant species."""
        user_plants = db.query(UserPlant).filter(
            UserPlant.user_id == user_id,
            UserPlant.is_active == True
        ).all()
        
        # Group plants by species
        species_groups = defaultdict(list)
        for plant in user_plants:
            species_groups[str(plant.species_id)].append(plant)
        
        species_performance = []
        
        for species_id, plants in species_groups.items():
            if len(plants) < 1:
                continue
            
            # Analyze each plant in the species group
            plant_metrics = []
            for plant in plants:
                try:
                    trend_analysis = await self.analyze_growth_trends(
                        db, str(plant.id), time_period_days
                    )
                    
                    if trend_analysis.get("trend_analysis", {}).get("status") == "success":
                        trend = trend_analysis["trend_analysis"]
                        plant_metrics.append({
                            "plant_id": str(plant.id),
                            "trend_strength": trend["trend_strength"],
                            "height_change": trend["height_range"]["max"] - trend["height_range"]["min"]
                        })
                except Exception:
                    continue
            
            if plant_metrics:
                # Calculate species averages
                avg_trend_strength = statistics.mean([m["trend_strength"] for m in plant_metrics])
                avg_height_change = statistics.mean([m["height_change"] for m in plant_metrics])
                
                species_performance.append({
                    "species_id": species_id,
                    "plant_count": len(plants),
                    "analyzed_count": len(plant_metrics),
                    "avg_trend_strength": avg_trend_strength,
                    "avg_height_change": avg_height_change,
                    "performance_score": (avg_trend_strength + min(avg_height_change / 10, 1)) / 2
                })
        
        # Sort by performance
        species_performance.sort(key=lambda x: x["performance_score"], reverse=True)
        
        return {
            "comparison_type": "species",
            "total_species": len(species_groups),
            "analyzed_species": len(species_performance),
            "time_period_days": time_period_days,
            "species_rankings": species_performance,
            "insights": self._generate_species_insights(species_performance)
        }
    
    async def _compare_with_community(
        self,
        db: Session,
        user_id: str,
        start_date: datetime,
        time_period_days: int
    ) -> Dict[str, Any]:
        """Compare user's plants with community averages."""
        # Get user's plant performance
        user_comparison = await self._compare_user_plants(
            db, user_id, start_date, time_period_days
        )
        
        if user_comparison.get("status") == "insufficient_plants":
            return user_comparison
        
        # Get community benchmarks (simplified for this implementation)
        community_benchmarks = await self._get_community_benchmarks(db, start_date)
        
        # Compare user performance with community
        user_plants = user_comparison["plant_rankings"]
        community_comparison = []
        
        for plant in user_plants:
            species_id = plant.get("species_id")
            plant_performance = plant.get("performance_score", 0)
            
            # Find community benchmark for this species
            species_benchmark = community_benchmarks.get(species_id, {
                "avg_performance": 0.5,
                "sample_size": 0
            })
            
            comparison = {
                "plant_id": plant["plant_id"],
                "plant_name": plant["plant_name"],
                "user_performance": plant_performance,
                "community_average": species_benchmark["avg_performance"],
                "percentile": self._calculate_percentile(
                    plant_performance, 
                    species_benchmark["avg_performance"]
                ),
                "sample_size": species_benchmark["sample_size"]
            }
            
            community_comparison.append(comparison)
        
        return {
            "comparison_type": "community",
            "user_id": user_id,
            "time_period_days": time_period_days,
            "community_comparison": community_comparison,
            "insights": self._generate_community_insights(community_comparison),
            "summary": {
                "above_average_count": len([c for c in community_comparison if c["percentile"] > 50]),
                "below_average_count": len([c for c in community_comparison if c["percentile"] < 50])
            }
        }
    
    # Helper methods for seasonal pattern analysis
    
    def _perform_seasonal_clustering(
        self,
        photos: List[GrowthPhoto],
        seasonal_predictions: List[SeasonalPrediction]
    ) -> Dict[str, Any]:
        """Perform clustering analysis on seasonal data."""
        if len(photos) < 10:
            return {"status": "insufficient_data", "message": "Need at least 10 photos for clustering"}
        
        # Group photos by season (simplified)
        seasonal_groups = {
            "spring": [],
            "summer": [],
            "fall": [],
            "winter": []
        }
        
        for photo in photos:
            season = self._determine_season(photo.capture_date)
            if photo.plant_measurements:
                seasonal_groups[season].append({
                    "date": photo.capture_date,
                    "measurements": photo.plant_measurements,
                    "health_indicators": photo.health_indicators
                })
        
        # Calculate seasonal statistics
        seasonal_stats = {}
        for season, data in seasonal_groups.items():
            if data:
                heights = [
                    d["measurements"].get("height_cm", 0) 
                    for d in data 
                    if isinstance(d["measurements"], dict) and d["measurements"].get("height_cm")
                ]
                
                if heights:
                    seasonal_stats[season] = {
                        "photo_count": len(data),
                        "avg_height": statistics.mean(heights),
                        "height_std": statistics.stdev(heights) if len(heights) > 1 else 0,
                        "growth_activity": "high" if len(data) > len(photos) / 6 else "low"
                    }
        
        return {
            "status": "success",
            "seasonal_groups": seasonal_groups,
            "seasonal_stats": seasonal_stats,
            "clustering_method": "seasonal_grouping"
        }
    
    def _identify_response_patterns(self, seasonal_clusters: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Identify seasonal response patterns from clustering data."""
        if seasonal_clusters.get("status") != "success":
            return []
        
        patterns = []
        seasonal_stats = seasonal_clusters.get("seasonal_stats", {})
        
        # Identify growth season
        if seasonal_stats:
            season_growth = {
                season: stats.get("avg_height", 0) 
                for season, stats in seasonal_stats.items()
            }
            
            if season_growth:
                peak_season = max(season_growth, key=season_growth.get)
                low_season = min(season_growth, key=season_growth.get)
                
                patterns.append({
                    "pattern_type": "seasonal_growth_cycle",
                    "description": f"Peak growth in {peak_season}, lowest in {low_season}",
                    "peak_season": peak_season,
                    "dormant_season": low_season,
                    "growth_variation": season_growth[peak_season] - season_growth[low_season]
                })
        
        return patterns
    
    def _generate_seasonal_insights(
        self,
        response_patterns: List[Dict[str, Any]],
        seasonal_clusters: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Generate insights from seasonal pattern analysis."""
        insights = []
        
        for pattern in response_patterns:
            if pattern["pattern_type"] == "seasonal_growth_cycle":
                peak_season = pattern["peak_season"]
                dormant_season = pattern["dormant_season"]
                
                insights.append({
                    "type": "seasonal",
                    "title": f"Peak Growth in {peak_season.title()}",
                    "description": f"Your plant shows strongest growth during {peak_season}",
                    "actionable": f"Increase feeding and monitoring during {peak_season} season",
                    "confidence": 0.8
                })
                
                insights.append({
                    "type": "seasonal",
                    "title": f"Dormant Period in {dormant_season.title()}",
                    "description": f"Reduced growth activity during {dormant_season}",
                    "actionable": f"Reduce watering and fertilization during {dormant_season}",
                    "confidence": 0.7
                })
        
        return insights
    
    def _generate_seasonal_recommendations(self, response_patterns: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Generate seasonal care recommendations."""
        recommendations = []
        
        for pattern in response_patterns:
            if pattern["pattern_type"] == "seasonal_growth_cycle":
                recommendations.append({
                    "season": pattern["peak_season"],
                    "recommendation": "Increase fertilization and monitoring",
                    "reason": "Peak growth period detected",
                    "priority": "high"
                })
                
                recommendations.append({
                    "season": pattern["dormant_season"],
                    "recommendation": "Reduce watering frequency",
                    "reason": "Dormant period with minimal growth",
                    "priority": "medium"
                })
        
        return recommendations
    
    # Utility helper methods
    
    def _determine_season(self, date: datetime) -> str:
        """Determine season based on date (Northern Hemisphere)."""
        month = date.month
        if month in [12, 1, 2]:
            return "winter"
        elif month in [3, 4, 5]:
            return "spring"
        elif month in [6, 7, 8]:
            return "summer"
        else:
            return "fall"
    
    def _rank_plant_performance(self, plant_performances: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Rank plants by performance score."""
        for plant in plant_performances:
            # Calculate performance score based on multiple factors
            trend_strength = plant.get("trend_strength", 0)
            height_change = plant.get("height_change", 0)
            
            # Normalize height change (assuming 0-20cm is good range)
            normalized_height = min(height_change / 20, 1) if height_change > 0 else 0
            
            # Calculate composite score
            performance_score = (trend_strength * 0.6 + normalized_height * 0.4)
            plant["performance_score"] = performance_score
        
        # Sort by performance score
        return sorted(plant_performances, key=lambda x: x["performance_score"], reverse=True)
    
    def _generate_comparative_insights(self, ranked_plants: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Generate insights from plant comparison."""
        insights = []
        
        if not ranked_plants:
            return insights
        
        best_plant = ranked_plants[0]
        worst_plant = ranked_plants[-1]
        
        insights.append({
            "type": "comparative",
            "title": f"Top Performer: {best_plant['plant_name']}",
            "description": f"Best growth performance with score {best_plant['performance_score']:.2f}",
            "actionable": "Use this plant's care routine as a model for others"
        })
        
        if len(ranked_plants) > 1 and worst_plant["performance_score"] < 0.3:
            insights.append({
                "type": "attention",
                "title": f"Needs Attention: {worst_plant['plant_name']}",
                "description": f"Lower performance score of {worst_plant['performance_score']:.2f}",
                "actionable": "Review care routine and environmental conditions"
            })
        
        return insights
    
    def _generate_species_insights(self, species_performance: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Generate insights from species comparison."""
        insights = []
        
        if not species_performance:
            return insights
        
        best_species = species_performance[0]
        insights.append({
            "type": "species",
            "title": "Best Performing Species",
            "description": f"Species shows excellent growth with score {best_species['performance_score']:.2f}",
            "actionable": "Consider expanding collection of this species type"
        })
        
        return insights
    
    async def _get_community_benchmarks(self, db: Session, start_date: datetime) -> Dict[str, Dict[str, Any]]:
        """Get community performance benchmarks by species."""
        # Simplified implementation - in reality, this would aggregate community data
        # For now, return mock benchmarks
        return {
            "default": {
                "avg_performance": 0.6,
                "sample_size": 100
            }
        }
    
    def _calculate_percentile(self, user_score: float, community_average: float) -> int:
        """Calculate user's percentile compared to community."""
        if community_average == 0:
            return 50
        
        ratio = user_score / community_average
        if ratio >= 1.5:
            return 90
        elif ratio >= 1.2:
            return 75
        elif ratio >= 1.0:
            return 60
        elif ratio >= 0.8:
            return 40
        elif ratio >= 0.6:
            return 25
        else:
            return 10
    
    def _generate_community_insights(self, community_comparison: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Generate insights from community comparison."""
        insights = []
        
        above_average = [c for c in community_comparison if c["percentile"] > 50]
        below_average = [c for c in community_comparison if c["percentile"] < 50]
        
        if above_average:
            insights.append({
                "type": "community",
                "title": f"{len(above_average)} Plants Above Community Average",
                "description": "Your plants are performing well compared to the community",
                "actionable": "Share your successful care strategies with the community"
            })
        
        if below_average:
            insights.append({
                "type": "community",
                "title": f"{len(below_average)} Plants Below Community Average",
                "description": "Some plants could benefit from community insights",
                "actionable": "Check community care guides for these plant types"
            })
        
        return insights
    
    async def _generate_analytics_summary(self, db: Session, plant_id: str) -> Dict[str, Any]:
        """Generate summary statistics for analytics report."""
        # Get basic plant info
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            return {}
        
        # Get time-lapse sessions count
        sessions_count = db.query(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id
        ).count()
        
        # Get total photos count
        photos_count = db.query(GrowthPhoto).join(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id
        ).count()
        
        # Get milestones count
        milestones_count = db.query(GrowthMilestone).join(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id
        ).count()
        
        return {
            "total_sessions": sessions_count,
            "total_photos": photos_count,
            "total_milestones": milestones_count,
            "plant_age_days": (datetime.utcnow() - plant.created_at).days,
            "health_status": plant.health_status
        }
    
    async def _store_analytics_report(
        self,
        db: Session,
        plant_id: str,
        user_id: str,
        report: Dict[str, Any]
    ) -> None:
        """Store analytics report in database."""
        try:
            # Create GrowthAnalytics record
            analytics_record = GrowthAnalytics(
                plant_id=plant_id,
                user_id=user_id,
                analysis_period_start=datetime.utcnow() - timedelta(days=90),
                analysis_period_end=datetime.utcnow(),
                analysis_type="comprehensive",
                growth_rate_data=report.get("growth_trends", {}),
                trend_analysis=report.get("growth_trends", {}).get("trend_analysis", {}),
                seasonal_patterns=report.get("seasonal_patterns", {}),
                insights=report.get("growth_trends", {}).get("insights", []),
                data_quality_score=report.get("growth_trends", {}).get("data_quality", {}).get("measurement_completeness", 0),
                confidence_level=0.8,
                analysis_version="1.0"
            )
            
            db.add(analytics_record)
            db.commit()
            
        except Exception as e:
            db.rollback()
            # Log error but don't fail the request
            print(f"Failed to store analytics report: {e}")
    
    # Response helper methods
    
    def _empty_growth_trends_response(self, plant_id: str) -> Dict[str, Any]:
        """Return empty response for plants with no time-lapse data."""
        return {
            "plant_id": plant_id,
            "status": "no_data",
            "message": "No time-lapse sessions found for this plant",
            "recommendation": "Start a time-lapse tracking session to analyze growth trends"
        }
    
    def _insufficient_data_response(self, plant_id: str, photo_count: int) -> Dict[str, Any]:
        """Return response for insufficient data."""
        return {
            "plant_id": plant_id,
            "status": "insufficient_data",
            "message": f"Only {photo_count} photos available, need at least 2 for analysis",
            "recommendation": "Continue capturing photos to enable growth analysis"
        }
    
    def _empty_seasonal_patterns_response(self, plant_id: str) -> Dict[str, Any]:
        """Return empty response for seasonal pattern analysis."""
        return {
            "plant_id": plant_id,
            "status": "no_seasonal_data",
            "message": "No time-lapse data spanning multiple seasons",
            "recommendation": "Continue tracking for at least one full season to identify patterns"
        }es challengturnre 
        })
              
     }r"er Survivo: "Summge"00, "badpoints": 1 {"ds":arew     "r      ",
     ugh summeralth thront hentain plants": "Mairequireme  "               90,
":ysuration_da   "d           eat!",
  er hhrough summg tivin thrplantsr Keep youion": ""descript           ",
     ngeence ChalleiliResmer le": "Sum  "tit             4",
 02lience_2mmer_resi"sud": nge_ialle    "ch        d({
    appen challenges.       
    mmer  # Sun [6, 7, 8]:nth i_moif current      el
   })       er"}
    wth MastGro": "Spring "badge: 100, "points" {ards":"rew       
         n",seasoing sprring y photos du: "Weeklnts"iremerequ          "    ": 90,
  uration_days         "d
       h spurt!",ing growt plant's spr"Track your: cription"es     "d         ge",
  owth Challeng Grprinle": "S "tit        ",
       024wth_2gropring_d": "shallenge_i    "c            ({
endllenges.app   cha
         g Sprin 4, 5]:  #nth in [3,_mocurrent      if 
    []
       hallenges = 
        c       month
e.utcnow().= datetimnt_month   currem
      tehallenge sysl c actuae with integration - wouldmentatple imlaceholder   # P"""
     r the user.es fonal challengle seasoavailab"""Get       ny]]:
  , Atrct[sist[Di> L) -tr_id: son, userf, db: Sessiges(sel_challenble_seasonal_availaetf _gc de
    asyn }
           el_points)
rent_levrement - curlevel_requi0, next_": max(velxt_les_to_ne   "point         ,
age)percentrogress_100, p": min(entages_perc"progres        ent,
    remui_level_req nextquirement":_level_re     "next       ints,
t_level_po: currenl_points"ent_leverr"cu            turn {
    re  
    
       * 100t)menquireext_level_re noints /nt_level_page = (curress_percent      progre  
        
ldent_threshocurrhold - ext_thres= nrequirement next_level_    
        _threshold - current_pointsotals = tl_pointrrent_leve      cu  
              
  1] + 250thresholds[-e level_holds) elsvel_thres(le_level < len current_level] ifds[currentoleshel_thrd = leveshol_thr  next  
        lse 0> 1 et_level ] if currenlevel - 1t_[currensholdshrevel_tshold = lerrent_thre      cu    else:
         increment
  = level_mentuirereqnext_level_        nt
    _increme% levelrrent_level nts_in_cuoints = point_level_pcurre           s
 _pointints - baseotal_po_level = tenturrpoints_in_c         = 250
   ment  level_incre     
      nts = 750ase_poi        b   ion
  calculatel lev# High       :
     holds)threslen(level_evel >= ent_lrr    if cu
    
        00, 750], 300, 5, 150ds = [0, 50hreshollevel_t        "
""next level.ard ogress tow prte"Calcula      ""ny]:
  t[str, Ant) -> Dicvel: it_lerents: int, curl_poinf, totaress(selel_proglate_levef _calcu   
    d 250)
 750) //s - l_point 5 + (totan min(10,tur       re     
   else:n 5
       retur    
      ts < 750:al_poinf tot     eli 4
         return     
 ts < 500:poinotal_     elif t
    return 3           < 300:
 intstotal_po  elif 
       2 return         150:
    <intsl_potota       elif turn 1
      re0:
       nts < 5otal_poi  if t""
      oints."al psed on totbauser level "Calculate         ""int:
) -> points: intelf, total_(svelleser_calculate_u
    def _s
    estioneturn sugg    r 
     })
            "
      s4 weekeekly for tos we pho: "Capturents"quirem    "re           ys",
 ": "30 damated_time  "esti             days",
  ntly for 30onsistek growth cac": "Tription    "descr            ",
ent Tracker"Consisttitle":           "
      cking",tent_transis": "co_type "milestone         ({
      pendapions.stge   sug        il
 cs fa if analytins suggestio# Default       
     ion:cept Except ex             
     )
            }"
 ransitionnal tgh seasothroulth t heaplann Maintai"s": mentire     "requ           months",
"1-3 d_time": "estimate            ",
    al changenext seasonte the fully navigaccess": "Suonti  "descrip     ,
         "terastion MnsiraSeasonal Ttitle": "  "        
      ",succession_transiteasonal_": "sestone_type    "mil         d({
   tions.appenges   sug         s
milestone seasonal  # Suggest               
            })
           y"
 0.15 cm/darate above rowth nt gtain curreMainnts": ""requireme                    4 weeks",
"2-ime": ed_t "estimat          
         ",d!trenowth gr excellent tinue then": "Conscriptio "de            ",
       ment Achievepid Growth"Rae":     "titl         
       ",rowth_periodd_g"rapie_type": "mileston            
        nd({s.appeestiongg     su
           :increasing" == "rection")"trend_dit(ge).lysis", {}("trend_anaalytics.get    if anrn
        h patterent growt curt based on Sugges        #      
    0)
       plant_id, 9ends(db,rowth_trlf.analyze_git seytics = awaanal         
           try:ilestones
 next mvant relesuggestics to nt analytplarrent cuGet        # 
 []
        stions =      sugge."""
   onesble milestossixt ptions for ne"Get sugges       ""Any]]:
 str, Dict[ist[ L -> str)ilestone:nt_m, curre_id: strsion, plant db: Ses(self,uggestionsstone_st_milenex_get_  async def    
  )
 nsoice(captioandom.chturn r     rendom
    import ra     
               ]
ent"
   Achievemurney #tJo! #Planing offion is payedicate d! Tht_title} {achievemenievement:s latest achlant_name}'{pelebrating      f"🌿 C      
 gether",ngTo#Growiss Succe}! #Plantement_titlene: {achievtoew milesreached a nme} _nad! {plantunlocket 🏆 Achievemen    f"   ne",
     thMilestorent #GrowtPaney! #Planourhis growth j of t So proudt!' achievemenement_title}'{achievrned the me} just ealant_na   f"🌱 {p
         s = [ion      capt     
  
   ilestone")w m"Ne", le("tit.get_info achievement =itleement_tevhi      ac"
  "My plant name ornick= plant._name       plant."""
  ent sharingachievemtion for uggested cap"Generate s ""   
    t) -> str:Plan: Usernt], pla Anystr,fo: Dict[inchievement_ion(self, at_captchievemennerate_a  def _ges
    
  achievemento_omb  return c
           
        })       s": 50
_pointbonus  "           
   ked!",ements unlocsonal achievseaple : "Multiription"   "desc             ster",
nal Ma: "Seasole""tit              r",
  asteasonal_m: "se  "type"    
          nd({ments.appeeve combo_achi     
       >= 2:s)achievementeasonal_n(s le
        ifs_seasonal]a.ievements if achiin recent_a r ents = [a fohievemeasonal_ac
        smboer" col Mast"Seasona Check for#        
   })
                : 20
  _points"     "bonus           ,
0 days!"es in 33 milestoneved ": "Achiion"descript          k",
      reaStowth : "Gr  "title"              
th_streak","grow"type":         {
        nts.append(mechieve  combo_a       
   >= 3:ievements) recent_ach if len(  ombo
     Streak" c"Growth  Check for    #
         
    ements = []ombo_achiev      c       
   ).all()
     ys=30)
   delta(danow() - time.utcmeatetieved_at >= dchiMilestone.a Growth      d,
     = user_iser_id =estone.uhMilrowt        Gr(
    tone).filtehMilesrowtb.query(Gnts = dnt_achievemece   re   ments
  ieve achet recent       # G"""
 es.ilestonecent md on rnts basehievemeo aceck for comb""Ch        "ny]]:
r, Act[st) -> List[Di strtone_type: str, mileser_id:ession, uslf, db: Sements(seo_achievck_combc def _cheyn   as
    
 s: {e}")atment st achieveupdate userd to "Faile print(f       s e:
    xception aept E exc
       ")oints, 0)} points'info.get('pt_{achievemenr_id}: +use {ts for userstaevement ated achi"Upd print(f   e
        _stats tabla useruld update his woon, tmentati real imple In a      #       try:
 ""
      tics."statisment eveachierall 's ov userpdate"U"     "e:
   ]) -> Nonict[str, Any Dent_info:hievemtr, acr_id: s useon,db: Sessif, ats(selnt_stevemete_user_achiupdaf _ de
    async   })
    se
     ": Falonal_seas        "is     5,
 "points":           "bronze",
ge_type":  "bad       ",
    estone!new mil reached a : "You'ven"scriptio       "de     ",
nlocked Umentchieve "A":le  "tit
          type, {ilestone_onfigs.get(mement_chiev  return ac        

      }      }
          e
    lsonal": Fa "is_seas            ": 30,
    "points            
   ver",ype": "sil "badge_t             ity!",
  p the communa to helatred growth d"Sha": iption"descr          r",
      y Contributo"Communit"title":                
 r": {ntributommunity_co        "co    
     },e
       onal": Tru  "is_seas             s": 100,
  "point               um",
 "platin":ype"badge_t            ",
    ll year!fuwth for a lant's grod your packeTr "n":criptio   "des     ",
        ication-Long Ded "Year":itle        "t
        ": {ar_tracking    "one_ye            },

        al": Trueis_season          "0,
      : 5  "points"            ",
  ": "goldtype"badge_           
     s!",nal changeseasoough r plant thr guided youcessfully"Suc: ription" "desc               ster",
tion Manal Transi"Seaso"title":           
      : {n_success"iol_transitna"seaso              },
 
         al": False_season        "is       25,
 s": int   "po            ",
 ilver": "sbadge_type          "  ,
    ate!" growth rceptionald exhowent sla": "Your pon"descripti           
     t",hievemenAcpid Growth "Rae": "titl                d": {
wth_perio "rapid_gro             },
          ": False
onal"is_seas           10,
     s":   "point            nze",
  ": "brotype "badge_        ",
       lestone!le growth miabrst measur fiyour"Achieved ion": "descript               stone",
  Mileirst Growthtitle": "F  "              ": {
nesto_growth_mile    "first       igs = {
 ent_confem  achiev"
      e type.""ilestons based on metailevement dchiermine a  """Dety]:
      tr, An -> Dict[s Any])r,ct[stDi: ta_da milestonee: str,lestone_typls(self, mint_detaiachievememine_ _deter  def 
  nsights
   urn i      ret       
  
          })
    patterns"nalseasommunity with coule e sched car"Align yourionable":  "act       
        rns",tenal patrecs)} season(seasonal_{le shows ata dty"Communi": fontiripsc     "de          ,
 ts"ghty Insininal CommuSeasotle": "ti   "           
  easonal",pe": "s  "ty     
         d({enights.app         ins  
 asonal_recs:       if se
      )
         }"
      plantses to your are strategiven cpromunity- com": "Applyactionable  "        ",
      eciess)} sp{len(patterns for ternul patnd successfouon": f"Fescripti         "d    e",
   ilabltterns Avamunity Pa": f"Come  "titl          ",
    "communitye":       "typ  {
        ppend(ights.a    ins
        atterns:  if p        
    = []
  s      insight   is."""
lysananity murom com insights fmaryte sumenera """G
       ]: Any]ct[str, -> List[Di
    )tr, Any]]ist[Dict[secs: Lal_r  season, 
      tr, Any]s: Dict[s  pattern     
   self,
       ary(mm_sutsnity_insighte_commuera  def _gen  
  s
  onrecommendatieturn   r    
      
           })        insights)
 son_en(seae": lsample_siz    "           .0),
     ) / 20, 1_insightsen(season: min(lnce"ide      "conf              ention",
attrease care ncriod - iowth peOptimal gr f"tion":ecommenda       "r    ,
         ": season  "season                  ppend({
ns.amendatio    recom           ta
  dad sufficient>= 5:  # Neehts) season_insigen( if l
           ():itemsal_groups.asonhts in sesig, season_inasonfor se  = []
      dations    recommen 
       ht)
     pend(insig]].apeason"peak_s["nsightps[ional_grou       seas         "):
season("peak_nsight.get        if i    s:
htght in insig    for insi
    st)faultdict(li = deonal_groups    seas    y season
ights b# Group ins   ""
     ta."community das from insighteasonal  ste"Aggrega   ""    :
 r, Any]]ist[Dict[st-> L]]) tr, Anyct[ss: List[Di, insightlf(seightsal_inseasonte_sregadef _agg    
          ]
     }
  
       eral"]"gen [species":icable_"appl             
   ate": 0.78,s_r"succes               riods",
  pewthgrod summer spring anring on duertilizatincreased fon": "Iscripti        "de        tion",
zanal_fertili "seaso":_type"strategy             {
            },
              "]
 ralne ["gecies":able_speapplic    "     
       ": 0.85,atecess_ruc         "s
       itoring",moisture monil ring with soate weekly wistentonsption": "Cscride         "      
 le",cheduatering_s "we":gy_typtetra"s                       {
 n [
    etur  rn
      ntatiomempleaceholder i Pl
        #ata."""munity domfrom crategies mmon care stcoify ""Ident  "]:
      Any]Dict[str, ]]) -> List[tr, Anyst[Dict[sies: Li, strategs(selfategieommon_strify_c  def _ident  
    y]
quenc min_fre if count >=unts.items()_coactor, count in ffor factortor  return [fac    0.5
    patterns) * len(quency =   min_fres
     f patterneast 50% o at lppear inat a thrsfactoReturn #         
     = 1
   [factor] +tor_countsfac         rs:
   toall_facr in r facto     fo   
t)inltdict(= defauts actor_coun        factor
 each frequency ofnt f  # Cou 
          ]))
   ctors", [cess_faet("sucn.g(pattertors.extend    all_fac      :
  patternsttern in pa    for     ]
 = [ all_factors    ""
   patterns."tors across success facind common "F""
         List[str]: ->tr, Any]])t[sicList[D: atternsf, p(seln_factors_commodef _find
    
    atedeturn aggreg   r
                 }
       t))
     tterns_lises_paeci p in sp") foration_typet("locn(set(p.ge: lediversity""location_           ,
         s_list)s_patternors(specie_factd_commonfin": self._torscess_fac"common_suc                  ]),
                   t
   tterns_lisecies_pa for p in sp                      rate"] 
 rowth_rics"]["growth_met    p["g          
          tics.mean([e": statisowth_rat_gr "avg                         ]),
            s_list
  tternpecies_pan sp i   for                  "] 
    strength"trend_][s"_metricp["growth                   an([
     .me statistics_strength":avg_trend         "
           st),_patterns_li(species_size": lensample   "                 = {
] ecies_idted[spggrega           a
     plest 3 examd at leas:  # Neelist) >= 3s_patterns_ecie   if len(sp    s():
     erns.itemecies_patts_list in spatternpecies_pcies_id, s spe      for}
  gregated = {    ag        
ern)
    ttd].append(pa[species_is_patterns  specie            d:
  cies_iif spe            species")
lant_"pn.get(patterpecies_id =       ss:
      in patternor pattern     fist)
    t(ldefaultdicterns = patecies_sp   cies
     oup by spe# Gr
                }
rn {   retu:
          patterns    if not
    """tegies.ommon strao crns inttteiple care paltAggregate mu""":
        r, Any]) -> Dict[sttr, Any]]t[Dict[sisns: Lf, patterpatterns(selte_care_ef _aggrega   d 
 tes
   duplicaemove rs))  # R(set(facto listreturn           
   []))
   ristics",t("charactephase.ged(enors.ext    fact            h"]:
rapid_growtgrowth", "["steady_ in hase_type")"pase.get(ph if 
           hases: phase in p    for[])
    ses", pha"growth_t(alytics.geases = an phs
       wth phase Analyze gro      #
          ))
, ""le"ht.get("titd(insigappentors.  fac              :
positive"e") == "et("typght.ginsi  if 
          hts:in insiginsight    for      ", [])
nsights"i.get(ics = analytinsightss
        ive factorsit for poyze insights     # Anal   
     rs = []
       facto
    """ growth. successfulg toontributin cify factors"Ident        ""st[str]:
> Li) -y], An: Dict[strticsself, analyfactors(uccess_ify_s_ident
    def one
      return N         
 xception:   except E   rn
  rn patte    retu  
                     }

         ])tterns", [response_pat(".ge{})", rnsatte"seasonal_pcs.get(": analytionsespl_re  "seasona    
          ),nalytics(afactorsify_success_dent self._itors":"success_fac         
       },        
        erage", 0){}).get("avday", m_per_t_rate_cghget("heis", {}).wth_ratecs.get("gronalyti_rate": agrowth "                   gth", 0),
strent("trend_ {}).geanalysis",t("trend_alytics.ge": antrengthend_s        "tr        ": {
    trics "growth_me      
         ation,.locype": plantation_t "loc      ,
         pecies_id)t.splan": str(ciespe   "plant_s            = {
   pattern           
cking data) care traalactuwould need fied - liimpe history (s   # Get car          try:
     ""
  plant." successful  fromre patternract caxt """E       
, Any]]:ict[str> Optional[D]) -ict[str, Anycs: D analyti UserPlant, plant:b: Session,f, dtern(selre_pat _extract_ca def   alse
    
    return F   
         s) == 0
_concern len(healthturn     re            
    ert"]]
   ", "alning"war[pe") in i.get("tynsights if in ir i = [i fos _concern      health)
      sights", []s.get("inyticts = analnsigh    is
        in insightrns ceth conalheck for he# C         .6:
    > 0_strengthrend and t"ncreasing == "iirectionif trend_d             

    0)th",strengend_t("trgeanalysis.trend_strength =     trend_")
    nctiond_diret("trenalysis.ged_a trenection =  trend_dirts
      sighs in inncernor health co # - No majgth
       good stren with owth trendve grPositi       # - :
 ful ifuccess sConsider
        #  e
       lsreturn Fa        s":
    ucces= "stus") !("stais.getd_analys  if tren})
       {",alysistrend_ancs.get("is = analytinalys     trend_a         
n False
  retur         ta"]:
   ufficient_data", "ins in ["no_da"status")get(s.alyticf an
        il."""ssfucesidered succonattern is th pf a growe i"Determin  ""
       -> bool:, Any])ict[strlytics: Dlf, anan(seowth_patteruccessful_grdef _is_s
    
    }") {eort record:to store exp"Failed int(f   pr     
     as e:Exception   except   
   d']}")['plant_i_metadata {export} for plantexport_id']['datametat_pored: {export record"Ext(f  prin
          e exportthust log , we'll j   # For now      s table
   to an exportwould store tion, this  implementaeal    # In a r
           try:     "
""lytics.ana and kingtracrecord for xport "Store e     ""one:
   , Any]) -> NDict[strmetadata: xport_sion, ef, db: Sesd(selcorort_re_expef _storesync d
    a
    n options   retur           
 feed"]
 nity_ ["commu"] =atformsocial_plons["s       optiy":
     = "communit =el_levivacy  elif pr     s"]
 plant_storie", "hallenges_c "seasonalty_feed","communi [forms"] =_platons["social    opti        
lic":pub= "evel =vacy_l  if pri
       }
              
 s": []platformocial_ "s       ,
    ", "pdf"]n", "csvjso": ["le_formats "availab          lic",
 = "pubacy_level =ges": privhallenn_cipate_i"can_partic          
  ,"]ymmunitic", "copublin ["cy_level  privaunity":_comme_tocontribut    "can_        ",
= "public =vel privacy_le":lyare_public  "can_sh        {
  options = 
        el."""evy ld on privacseons baring optivailable sha"""Get a        ny]:
tr, A[s -> Dictvel: str)y_le privacons(self,ing_optishardef _get_     
  ]
 ()[:16)).hexdigestode(.enctoken_dataib.md5(hlurn has   ret
     e())}".timl}:{int(timeleveacy_privd}:{ f"{plant_idata =token_    milar)
    WT or sier Jn, use proproductio (in pionoken generatle t # Simp        
    me
   port ti        imhlib
mport has     i  n."""
 sharing tokeate secure ener  """G     str:
 -> evel: str) y_lr, privact_id: st planlf,n(seing_toke_sharenerate
    def _g  
  cy_level}"cy={priva}&privaing_tokenn={sharkeant_id}?tol}/{pl{base_urn f"       returcy_level)
 rivat_id, ptoken(planing_e_shar._generatoken = selfng_t   sharih"
     munity/growtcom/comtsocial.anps://app.pl = "httse_url   ba     es."""
eaturnity fL for commuURng sharinerate   """Ge  str:
    > vel: str) -rivacy_led: str, pant_il(self, plsharing_urf _generate_   de
 
    v_datan csetur
        r]
               
     nsights"]ends"]["iwth_trn data["groght i  for insi                    }
    )
      ", 0ncefidet.get("conigh": insidenceonf  "c               n"],
   criptioight["desn": ins"descriptio                   "],
 title insight["":"title                pe"],
    ["tysightype": in"t                {
                  s"] = [
  ghtinsiata["     csv_d
       :"]owth_trendsdata["grights" in a and "ins dattrends" inf "growth_
        isightst in   # Extrac  
                 ]
      n timeline
oint ifor p                
       }      ")
   e_scorealtht("hgeents"].["measuremre": pointco"health_s            ),
        nt"couget("leaf_rements"].su"meat[inunt": po  "leaf_co                 "),
 width_cms"].get("ementeasurint["mh_cm": powidt    "           ),
     m"eight_c"].get("hntsmeureoint["measght_cm": p     "hei         "],
      t["datepoin": ate        "d    {
                        ne"] = [
_timelithta["growv_da    cs       eline"]
 rement_timasu]["merends"owth_tdata["gr=    timeline     
     nds"]:tre"growth_in data[imeline" urement_tnd "measn data aends" irowth_tr "gif     data
    timeline tract        # Ex   
   {}
   a =  csv_dat
      rmat."""iendly fo CSV-frs data toicvert analyt""Con
        "ny]: Aict[str,> D) -y]An Dict[str, elf, data:(sv_formatonvert_to_cs    def _c
    
turn data         re
   lse:      e    }
       
   ()) * 2a.keys": len(datd_pagesstimate     "e      
     e,ired": Truon_requ"generati                ()),
a.keysist(datctions": lreport_se"           ,
     "pdf" rmat":   "fo           rn {
  retu         a
   datetaF report mPDate   # Gener      f":
    type == "pdt_orma      elif ft(data)
  formavert_to_csv_elf._con sturn re
           t forma-friendlyrt to CSV Conve   #     
    csv": == "mat_typelif for      edata
   return      ":
      onjs== "mat_type for  if 
      mat."""equested forased on rort data bt exp"""Forma
         -> Any:str)ype: format_ty], tr, Ana: Dict[sta(self, dat_export_daef _format    d   
ata
 turn dre    
    taeps all dalevel kePublic    #         
   _info
  = planto"] lant_infta["pda               
 ", None)tion"locainfo.pop(lant_      p       None)
    nickname",pop("o.nt_inf    pla         
   opy()].c_info"data["plantinfo = nt_  pla       :
        datat_info" inplanif "          copy()
  ta = data.     da      ta
  daowthep grut keentifiers bsonal idperove   # Rem
          ":mmunity == "coacy_levelrivlif p 
        e
       one)ne", Nnt_timelime"measureop("].ph_trendsowt"gr      data[          in data:
rends" "growth_t        if ne)
    fo", Noinpop("plant_ta.        daopy()
    data.ca = dat       ation
     nform ifyingidentie all ov # Rem       te":
    ivaprlevel == "vacy_    if pri
    a."""t dats to exporvacy control"Apply pri""   Any]:
     tr, [sstr) -> Dict: vacy_level], pri Anyt[str,f, data: Dicontrols(selly_privacy_cef _app
    
    dsy featuremunitor comhods f# Helper met
    
         }
   id)r_usedb, s(allengel_chasona_seableet_availwait self._g: aenges"hallailable_c "av   
                ],  ents
  t 5 achievem Las:5]  #ements[achievr a in   fo         
              }ype
       ": a.badge_tge_type    "bad              at(),
  rm_at.isofohievedac: a.ed_at"ev"achi                ,
    escriptionlestone_dion": a.miipt  "descr                pe,
  lestone_ty.mi ae":"typ                 .id),
    str(a":       "id                {
          ": [
   entsachievem"recent_        ,
    ent_groups)emdict(achievy_type": _bnts"achieveme                 },
       l_progress
eves": next_lesgrlevel_prot_     "nex         
  ,ser_levelr_level": u"use        
        chievements,onal_a": seasvementssonal_achiesea      "   s,
       pointl_ota": tntsoi"total_p           
     ),ievementschlen(aevements": "total_achi             {
   ": yarnt_summevemeachi      "   _id,
   r_id": user"use            return {
        
   l)
      user_level_points,ss(total_progrete_leveelf._calcularogress = s_level_p  nexts)
      pointl(total_user_levelate_calculf._vel = seuser_le
        rogressevel and pser lulate u    # Calc    
      += 1
  nts _achievemeseasonal                sonal:
s_seat.iievemen  if ach  0
        or _earned ment.points += achieveoints_pal        tot  
    
             })l
         asonament.is_sehievesonal": acs_sea   "i      ,
       nts_earnedievement.poid": achearnepoints_       "      ,
   ypeent.badge_tachievem: _type"     "badge          at(),
 soformchieved_at.iievement.a_at": ach"achieved       
         ption,crie_des.milestonvement": achiescription   "de         t.id),
    (achievemenstr"id":          ({
       ppendtype].aestone_t.milhievemens[acent_groupchievem  a          s:
ievementnt in achmehiever acfo  
         = 0
      ievementsl_ach  seasona 0
      ints =_po       totalist)
 (laultdictefups = dvement_gro      achiey type
  ts bachievemenGroup 
        #         all()
d_at)).evechione.arowthMilest(Ger_by(descry.ord= quents chieveme   a
            type)
 t_chievemen_type == ailestonee.mMilestonGrowthry.filter( query = que         e:
  t_typf achievemen   i 
     d)
       ser_i u==ser_id Milestone.uwther(Grofiltne).ilestothMry(Growdb.que  query =      
 ".""ressprogents and hievem's ac"Get user    ""  ]:
  r, Any[st  ) -> Dict
   Nonetr] =nal[s Optioent_type: achievemr,
       user_id: st       Session,
        db: elf,
     ss(
    chievementf get_user_a  async de  
   }
        type)
 stone_ileplant_id, mns(db, estiosuggestone_xt_milself._get_neawait lestones":  "next_mi           },
         plant)
   nfo, ement_iievtion(achapevement_cte_achinera self._gecaption":gested_"sug            "],
    easonalo["is_svement_infie: achchallenges"share_to_n_ "ca           ue,
    ": Trmunityto_com"can_share_           {
      ":ionsptng_oshari       "nts,
     chievemecombo_aents": vemmbo_achie   "co        },
            ()
 rmatved_at.isofoie.achone": milestchieved_at        "a,
        _seasonal"]nfo["isment_iachieve": sonal    "is_sea        s"],
    ntoio["pment_infhievened": acoints_ear"p               type"],
 o["badge_ent_infachievem": ge_type"bad           "],
     ion"descripto[ement_infachievon": ripti"desc           ,
     tle"]fo["tit_in achievemen"title":             _type,
   tone: miles "type"               ne.id),
(milesto str"id":          
      ent": {hievem"ac        ",
    lockedment_un": "achieves "statu           urn {

        ret       pe)
 _tyestoneer_id, mil, usdbements(hievcombo_acck__chet self. = awaitsevemenmbo_achi        cots
emencombo achiev Check for   #
             nfo)
 chievement_id, a user_iats(db,vement_ster_achief._update_us sel  await      ent stats
r achievempdate use U        # 

       estone)(milesh   db.refr
     b.commit()        dstone)
.add(mile
        db            )
  ue
  d=Trnableg_e  sharin    ,
      sonal"]["is_seanfo_iemental=achievs_season      i      points"],
o["ment_infvearned=achieints_e        po"],
    _typeo["badgeent_infchievemtype=ae_adg    b        
w(),etime.utcnodatat=ieved_ ach        
   e_data,ondata=milestne_   milesto       ,
  ion"]ript_info["deschievementacdescription=ne_lesto          mitype,
  ne_stoe=mile_typestonemil      
      d,_id=user      user_i  
    id,id=plant_plant_           
 estone(wthMilestone = Gro        mild
ne recorlestomi# Create         
        
data)estone_ milstone_type,etails(mileement_drmine_achievf._deteo = sel_infvement      achie  ls
t detaihievemenmine acter  # De 
       }
            
           }           format()
so.id_athieveent.acchievemting_aat": exis "achieved_                 ),
  idievement.achng_exististr(d":      "i       
        nt": {g_achievemeexistin         "  ",
     entlyed recchievdy aeaone was alrstleThis mi: "message"    "            ,
eved"already_achitus": "   "sta             urn {
   ret       t:
  ievemenaching_  if exist            
  ()
  ).first     ys=30)
 delta(daime - ttcnow() datetime.ued_at >=e.achievlestonwthMi Gro      type,
     one_st= milee_type =ne.milestonestowthMil      Gro
      t_id,_id == planplantilestone.hMowt  Gr   er(
       ltfie).onowthMilestdb.query(Grment = ing_achieve   existxists
     already echievement  if aCheck     #      
   d")
   ess denie accund orfont not lalueError("Praise Va      
      t:not plan       if 
  t()
             ).firser_id
  usd == lant.user_i      UserP,
      t_id== planrPlant.id          Use  filter(
 t).anserPl.query(U db     plant =
   wnershipnt olafy p# Veri        """
  ion
      t informatevemenng achiainiry contDictiona        s:
        Return      
    e
      onthe milestout ata: Data abmilestone_d        ed
    tone achieve of milesne_type: Typ   milesto       
  the plantf  ID oplant_id:       ser
     f the user_id: ID o   u       ession
   satabase D db:           Args:
       
        
 .allenges chaleasonones and sestr growth milfo system ementachievate    Cre         """
ny]:
     Dict[str, A
    ) ->]r, Anyct[stdata: Diilestone_,
        mne_type: strilesto       m
 tr,lant_id: s   ptr,
     r_id: sse,
        ussiondb: Se   f,
        seltem(
     sysnt_vemeeate_achiecrdef 
    async         }
 ns)
   mendatioal_recomonaserns, settted_pamary(aggregansights_sumunity_iate_commerf._gen: selhts"   "insig
         tions,commendaasonal_re: sens"ndatiommerecol_asona"se           s,
 giemmon_strateco": esn_strategiommo "c       s,
    attern_pgatedns": aggresful_pattersucces  "
          },      ))
      p.locationy_plants if nit in commu for pcationt(p.lo: len(seity"on_divers  "locati            lants)),
  unity_pr p in commes_id) fo.specitr(plen(set(sverage": cos_ecie"sp                atterns),
cessful_puc": len(sns_foundterpat"successful_              
  s),_plantcommunity: len("yzedanalotal_plants_ "t     
          stats": {ommunity_        "c          },
s
      period_day": time_  "days             t(),
 ma.isofore.utcnow(): datetime"   "end_dat         
    rmat(),e.isofostart_datdate": t_"star               {
 d": erio"analysis_p    ",
        : "successstatus"          "eturn {
   
        rs)
       insights(seasonal_l_insightgate_seasonaggref._as = selendationnal_recommeaso        sies)
rateges(care_stgi_stratecommonf._identify_egies = seltrat    common_sterns)
    essful_patsuccatterns(care_pate__aggregself.= ns patteregated_  aggr
      ernsattnd analyze pgregate a# Ag        
        
ntinueco              rrors
   es withSkip plant#                 :
n as etioExcep     except   
                         rns"])
nse_patteysis["respoal(seasonal_anights.extendeasonal_ins           s      s"):
   erne_pattesponst("ralysis.geseasonal_anf         i            
           )
            
     , 4(plant.id)     db, str          (
     ernsl_pattsonaentify_sea self.idwaitanalysis = a  seasonal_         hts
     nsig ialonct seas Extra         #
                  
     nd(pattern).appernsssful_patte       succe               rn:
  tteif pa          
          ytics)t_anal, plan plantrn(db,are_pattect_cself._extra= rn    patte                cs):
 nt_analytirn(plateatful_growth_psuccesss_f self._i       i         patterns
 cessfulIdentify suc#         
                            )
          _days
  ioderd), time_p.i(plant  db, str              rends(
    ze_growth_tanalyf. = await sel_analytics plant      
          analytics # Get plant           ry:
        ts
        issueperformance event o primit t50]:  # Lty_plants[:communit in plan     for       
   = []
  ghts _insi   seasonal[]
      = e_strategiesar c     ]
  = [tterns l_pafu  success      ants
unity plss commcro arns patte # Analyze          
   
   }    
       ty_plants)en(communi: lble_plants"lavai   "a             ysis",
rn anal for pattety plantsommunieast 10 c "Need at le":"messag              ",
  nt_datansufficie "i "status":             
   {return         :
   s) < 10nity_plantcommuen(  if l    
       
   ().allryplants = quenity_ommu     c    
     
  lter}%"))fion_"%{locatiike(fon.ilPlant.locatiter(User.filery = qu    query      er:
  tion_filt   if loca  
       id)
    ies_ spececies_id ==rPlant.spr(Useery.filteery = qu      qud:
      s_ispecie        if         
 )
ate
       art_d >= stted_att.crearPlan        Use
    e == True,is_activlant.     UserPer(
       iltt).fUserPlanquery( query = db.       ng enabled
 sharith publics wiunity plant  # Get comm 
      s)
       iod_dayys=time_peredelta(datim- me.utcnow() te = dateti start_da     ""
          "
ity patternscommunaggregated ining ry contaionaDict       
         Returns:   
    s
         lysifor anad rioime peod_days: T   time_peri       er
  filtation tional locn_filter: Op     locatioter
       s fil specienal Optiopecies_id:       sion
     base sessata   db: D
         Args:       
      data.
    tym communiies froe strategul carccessfate su    Aggreg"""
           ]:
 [str, Any -> Dict 365
    )days: int =d_erio    time_pne,
     Nonal[str] =lter: Optioon_fi   locati,
     [str] = NoneOptionalies_id:       spec,
  Session    db: self,
    
        erns(attcommunity_pgregate_c def ag asyn    
   
        }
      }    
  s": Truehievementarn_ac     "can_e
           "public",l == y_leve": privac_challengesorligible_f"e                "],
"community"public", l in [y_leve": privacpatternsute_to_ntrib  "can_co     {
         tures": mmunity_fea "co
           _level),ns(privacyg_optioinshar_get_f.tions": selng_op "shari     a,
      tted_dat forma":xport_data       "ea,
     metadatt_ata": exporort_metad"exp       urn {
     et    r     
    
   rt_metadata)expoord(db, e_export_recstor self._it      awa  tracking
ecord for xport rStore e  #    
    }
        one
       e N" els"privatel != vevacy_lepriy_level) if d, privacant_il(pling_ure_sharlf._generat": seng_url    "shari
        e")),timelinurement_t("meas{}).ge_trends", t("growthrt_data.ge bool(expo":etimelapses_    "includ      {}),
  , iod"analysis_per"get(ta._da: exportperiod"ata_      "d  
    isoformat(),me.utcnow().etid_at": datxporte      "e    evel,
   privacy_l":ivacy_level"pr            ,
matport_fort": exrt_forma      "expo      ,
": user_idser_id    "u       ,
 : plant_idant_id" "pl        d4()),
   ": str(uuiort_id"exp          ta = {
  xport_metada  e   tadata
    me exportenerate    # G   
    mat)
     xport_for_data, e(exporttadaort_expformat_f._ selta =ed_da    formatt
    formatested  on requ data basedrmatFo #    
           
 cy_level), privaics_reportlytrols(anaivacy_contly_prlf._app sedata =port_
        ex controlscyiva pr   # Apply     
        )
"
        omprehensive"c, plant_id,  db         rt(
  repocs_lytih_anawtte_groneraself.geait ort = aws_rep  analytic     s data
 ive analytichens compre       # Get       
 ied")
  access denornot found ant rror(f"Plraise ValueE          ant:
  not pl if    
            ).first()
      r_id
  = useer_id =UserPlant.us        id,
     plant_t.id ==    UserPlan   er(
     ).filtanty(UserPlnt = db.quer        plaant
pls the er ownerify us     # V"
        ""data
   d metaort data an expiningtationary conic   D        Returns:
                 
")
    vatety", "pri", "communipubliclevel ("cy vaPriy_level:       privac  df")
    ", "p"csv("json",  export at for: Form_formatport  ex
          rtesting expohe user requd: ID of t_iuser    nt
        he pla of tant_id: ID          pl session
  : Databasedb            s:
      Arg      
  g.
  ty sharin communicontrols forprivacy h with data growtt por Ex   ""
    "       ny]:
  Dict[str, A ->ic"
    )tr = "publ_level: s   privacyn",
      "jso =at: strrt_formexpo
        er_id: str,us       
 ,id: str      plant_on,
  si    db: Ses    elf,
     s
   h_data(wt export_grosync def    
    aods
ring MethhaData Snsights and ity I    # Commun
    
