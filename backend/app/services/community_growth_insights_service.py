"""
Community Growth Insights Service for LeafWise Platform

This service provides community-based growth analysis including:
- Community pattern aggregation and analysis
- Comparative growth analysis across users
- Best practice identification from successful growers
- Community benchmarking and insights

Focused on leveraging community data for growth insights.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
import statistics
import json

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies


class CommunityGrowthInsightsService:
    """Service for community-based growth analysis and insights."""
    
    def __init__(self):
        pass
    
    async def analyze_community_patterns(
        self,
        db: Session,
        species_id: Optional[str] = None,
        location: Optional[str] = None,
        time_period_days: int = 90
    ) -> Dict[str, Any]:
        """
        Analyze growth patterns across the community.
        
        Args:
            db: Database session
            species_id: Optional species filter
            location: Optional location filter
            time_period_days: Analysis period in days
            
        Returns:
            Dictionary containing community analysis results
        """
        start_date = datetime.utcnow() - timedelta(days=time_period_days)
        
        # Build query for community data
        query = db.query(UserPlant)
        if species_id:
            query = query.filter(UserPlant.species_id == species_id)
        if location:
            query = query.filter(UserPlant.location.ilike(f"%{location}%"))
        
        plants = query.all()
        
        if len(plants) < 5:
            return self._insufficient_community_data_response(len(plants))
        
        # Aggregate growth data from all plants
        community_data = self.aggregate_community_growth_data(db, plants, start_date)
        growth_benchmarks = self.calculate_growth_benchmarks(community_data)
        success_patterns = self.identify_success_patterns(db, plants, start_date)
        care_correlations = self.analyze_care_correlations(db, plants, start_date)
        
        return {
            "analysis_period": {
                "start_date": start_date.isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "plants_analyzed": len(plants)
            },
            "growth_benchmarks": growth_benchmarks,
            "success_patterns": success_patterns,
            "care_correlations": care_correlations,
            "community_insights": self.generate_community_insights(growth_benchmarks, success_patterns)
        }
    
    def aggregate_community_growth_data(
        self,
        db: Session,
        plants: List[UserPlant],
        start_date: datetime
    ) -> List[Dict[str, Any]]:
        """
        Aggregate growth data from multiple plants.
        
        Args:
            db: Database session
            plants: List of plants to analyze
            start_date: Start date for analysis
            
        Returns:
            List of aggregated growth data
        """
        community_data = []
        
        for plant in plants:
            # Get timelapse sessions for this plant
            sessions = db.query(TimelapseSession).filter(
                TimelapseSession.plant_id == plant.id,
                TimelapseSession.created_at >= start_date
            ).all()
            
            if not sessions:
                continue
            
            # Get growth photos
            photos = []
            for session in sessions:
                session_photos = db.query(GrowthPhoto).filter(
                    GrowthPhoto.timelapse_session_id == session.id
                ).all()
                photos.extend(session_photos)
            
            if len(photos) < 3:
                continue
            
            # Calculate growth metrics for this plant
            sorted_photos = sorted(photos, key=lambda p: p.captured_at)
            initial_height = sorted_photos[0].height_cm or 0
            final_height = sorted_photos[-1].height_cm or 0
            total_growth = final_height - initial_height
            days_tracked = (sorted_photos[-1].captured_at - sorted_photos[0].captured_at).days
            
            if days_tracked > 0:
                growth_rate = total_growth / days_tracked
                
                community_data.append({
                    "plant_id": plant.id,
                    "species_id": plant.species_id,
                    "location": plant.location,
                    "total_growth": total_growth,
                    "growth_rate": growth_rate,
                    "days_tracked": days_tracked,
                    "photo_count": len(photos),
                    "initial_height": initial_height,
                    "final_height": final_height,
                    "avg_leaf_count": sum(p.leaf_count or 0 for p in sorted_photos) / len(sorted_photos)
                })
        
        return community_data
    
    def calculate_growth_benchmarks(self, community_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Calculate growth benchmarks from community data.
        
        Args:
            community_data: Aggregated community growth data
            
        Returns:
            Dictionary containing growth benchmarks
        """
        if not community_data:
            return {}
        
        growth_rates = [data["growth_rate"] for data in community_data if data["growth_rate"] > 0]
        total_growths = [data["total_growth"] for data in community_data if data["total_growth"] > 0]
        
        if not growth_rates:
            return {}
        
        return {
            "growth_rate": {
                "mean": round(statistics.mean(growth_rates), 3),
                "median": round(statistics.median(growth_rates), 3),
                "percentile_25": round(statistics.quantiles(growth_rates, n=4)[0], 3),
                "percentile_75": round(statistics.quantiles(growth_rates, n=4)[2], 3),
                "top_10_percent": round(statistics.quantiles(growth_rates, n=10)[8], 3)
            },
            "total_growth": {
                "mean": round(statistics.mean(total_growths), 2),
                "median": round(statistics.median(total_growths), 2),
                "percentile_25": round(statistics.quantiles(total_growths, n=4)[0], 2),
                "percentile_75": round(statistics.quantiles(total_growths, n=4)[2], 2)
            },
            "sample_size": len(community_data)
        }
    
    def identify_success_patterns(
        self,
        db: Session,
        plants: List[UserPlant],
        start_date: datetime
    ) -> List[Dict[str, Any]]:
        """
        Identify patterns from the most successful growers.
        
        Args:
            db: Database session
            plants: List of plants to analyze
            start_date: Start date for analysis
            
        Returns:
            List of success patterns
        """
        # Get top performing plants (top 20% by growth rate)
        community_data = self.aggregate_community_growth_data(db, plants, start_date)
        
        if len(community_data) < 5:
            return []
        
        # Sort by growth rate and get top 20%
        sorted_data = sorted(community_data, key=lambda x: x["growth_rate"], reverse=True)
        top_performers_count = max(1, len(sorted_data) // 5)
        top_performers = sorted_data[:top_performers_count]
        
        patterns = []
        
        # Analyze photo frequency pattern
        avg_photo_frequency = sum(p["photo_count"] / p["days_tracked"] for p in top_performers) / len(top_performers)
        patterns.append({
            "pattern_type": "photo_frequency",
            "description": f"Top performers take photos every {round(1/avg_photo_frequency, 1)} days on average",
            "metric_value": round(avg_photo_frequency, 3),
            "confidence": "high" if len(top_performers) >= 3 else "medium"
        })
        
        # Analyze growth consistency
        growth_rates = [p["growth_rate"] for p in top_performers]
        consistency_score = 1 - (statistics.stdev(growth_rates) / statistics.mean(growth_rates))
        patterns.append({
            "pattern_type": "growth_consistency",
            "description": f"Top performers maintain consistent growth with {round(consistency_score * 100, 1)}% consistency",
            "metric_value": round(consistency_score, 3),
            "confidence": "high" if len(top_performers) >= 3 else "medium"
        })
        
        return patterns
    
    def analyze_care_correlations(
        self,
        db: Session,
        plants: List[UserPlant],
        start_date: datetime
    ) -> List[Dict[str, Any]]:
        """
        Analyze correlations between care patterns and growth success.
        
        Args:
            db: Database session
            plants: List of plants to analyze
            start_date: Start date for analysis
            
        Returns:
            List of care correlations
        """
        correlations = []
        community_data = self.aggregate_community_growth_data(db, plants, start_date)
        
        if len(community_data) < 10:
            return correlations
        
        # Group by location and analyze
        location_groups = {}
        for data in community_data:
            location = data.get("location", "unknown")
            if location not in location_groups:
                location_groups[location] = []
            location_groups[location].append(data["growth_rate"])
        
        # Find locations with significantly better performance
        overall_avg = statistics.mean([d["growth_rate"] for d in community_data])
        
        for location, rates in location_groups.items():
            if len(rates) >= 3:
                location_avg = statistics.mean(rates)
                if location_avg > overall_avg * 1.2:  # 20% better than average
                    correlations.append({
                        "correlation_type": "location",
                        "factor": location,
                        "improvement": round((location_avg / overall_avg - 1) * 100, 1),
                        "sample_size": len(rates),
                        "confidence": "high" if len(rates) >= 5 else "medium"
                    })
        
        return correlations
    
    def generate_community_insights(
        self,
        benchmarks: Dict[str, Any],
        success_patterns: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Generate actionable insights from community analysis."""
        insights = []
        
        if benchmarks and "growth_rate" in benchmarks:
            top_10_rate = benchmarks["growth_rate"].get("top_10_percent", 0)
            median_rate = benchmarks["growth_rate"].get("median", 0)
            
            if top_10_rate > median_rate * 1.5:
                insights.append({
                    "insight_type": "performance_gap",
                    "title": "Significant Performance Variation",
                    "description": f"Top 10% of growers achieve {round((top_10_rate/median_rate - 1) * 100, 1)}% better growth rates",
                    "actionable": True,
                    "recommendation": "Study top performer patterns to improve your growth results"
                })
        
        # Add insights from success patterns
        for pattern in success_patterns:
            if pattern["pattern_type"] == "photo_frequency" and pattern["confidence"] == "high":
                insights.append({
                    "insight_type": "tracking_frequency",
                    "title": "Optimal Tracking Frequency",
                    "description": pattern["description"],
                    "actionable": True,
                    "recommendation": "Adjust your photo tracking frequency to match successful growers"
                })
        
        return insights
    
    async def compare_with_community(
        self,
        db: Session,
        plant_id: str,
        comparison_period_days: int = 30
    ) -> Dict[str, Any]:
        """
        Compare a specific plant's performance with community benchmarks.
        
        Args:
            db: Database session
            plant_id: ID of the plant to compare
            comparison_period_days: Period for comparison
            
        Returns:
            Dictionary containing comparison results
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get community benchmarks for the same species
        community_analysis = await self.analyze_community_patterns(
            db, species_id=plant.species_id, time_period_days=comparison_period_days
        )
        
        # Get plant's own performance
        start_date = datetime.utcnow() - timedelta(days=comparison_period_days)
        plant_data = self.aggregate_community_growth_data(db, [plant], start_date)
        
        if not plant_data or not community_analysis.get("growth_benchmarks"):
            return {"status": "insufficient_data"}
        
        plant_performance = plant_data[0]
        benchmarks = community_analysis["growth_benchmarks"]
        
        # Calculate percentile ranking
        plant_growth_rate = plant_performance["growth_rate"]
        median_rate = benchmarks["growth_rate"]["median"]
        top_25_rate = benchmarks["growth_rate"]["percentile_75"]
        
        if plant_growth_rate >= top_25_rate:
            performance_tier = "top_25_percent"
        elif plant_growth_rate >= median_rate:
            performance_tier = "above_average"
        else:
            performance_tier = "below_average"
        
        return {
            "plant_id": plant_id,
            "comparison_period_days": comparison_period_days,
            "plant_performance": plant_performance,
            "community_benchmarks": benchmarks,
            "performance_tier": performance_tier,
            "improvement_potential": round((top_25_rate - plant_growth_rate) / plant_growth_rate * 100, 1) if plant_growth_rate > 0 else 0
        }
    
    def _insufficient_community_data_response(self, plant_count: int) -> Dict[str, Any]:
        """Return response when insufficient community data is available."""
        return {
            "status": "insufficient_community_data",
            "message": f"Only {plant_count} plants available for analysis. Need at least 5 for community insights.",
            "plants_analyzed": plant_count
        }


def get_community_growth_insights_service() -> CommunityGrowthInsightsService:
    """Factory function to get CommunityGrowthInsightsService instance."""
    return CommunityGrowthInsightsService()