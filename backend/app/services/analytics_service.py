"""
Advanced Analytics Service for LeafWise Platform
Provides comprehensive insights and analytics for plant care, community engagement, and user behavior.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, text, desc, asc
import json
import statistics
from collections import defaultdict

from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.rag_models import RAGInteraction
from app.models.plant_achievement import PlantAchievement
from app.models.plant_question import PlantQuestion
from app.models.plant_trade import PlantTrade
from app.models.user import User
from app.services.ml_plant_health_service import MLPlantHealthService
from app.services.ml_trending_topics_service import MLTrendingTopicsService
from app.services.embedding_service import EmbeddingService


class AnalyticsService:
    def __init__(
        self,
        ml_health_service: MLPlantHealthService,
        ml_trending_service: MLTrendingTopicsService,
        embedding_service: EmbeddingService
    ):
        self.ml_health_service = ml_health_service
        self.ml_trending_service = ml_trending_service
        self.embedding_service = embedding_service

    async def get_user_plant_analytics(
        self,
        db: Session,
        user_id: str,
        time_period: int = 30
    ) -> Dict[str, Any]:
        """Get comprehensive plant care analytics for a user."""
        
        # Get user plants
        user_plants = db.query(UserPlant).filter(
            UserPlant.user_id == user_id,
            UserPlant.is_active == True
        ).all()
        
        if not user_plants:
            return self._empty_analytics_response()
        
        plant_ids = [plant.id for plant in user_plants]
        
        # Get care logs for the period
        start_date = datetime.utcnow() - timedelta(days=time_period)
        care_logs = db.query(PlantCareLog).filter(
            PlantCareLog.plant_id.in_(plant_ids),
            PlantCareLog.created_at >= start_date
        ).all()
        
        # Calculate health trends
        health_trends = await self._calculate_health_trends(db, plant_ids, time_period)
        
        # Calculate care consistency
        care_consistency = self._calculate_care_consistency(care_logs, user_plants)
        
        # Get plant performance data
        plant_performance = await self._get_plant_performance_data(db, plant_ids)
        
        # Get achievements
        achievements = db.query(PlantAchievement).filter(
            PlantAchievement.plant_id.in_(plant_ids),
            PlantAchievement.achieved_at >= start_date
        ).all()
        
        # Get care activity heatmap
        care_activity = self._generate_care_activity_heatmap(care_logs, time_period)
        
        # Get predictive insights
        predictive_insights = await self._get_predictive_insights(db, plant_ids)
        
        return {
            "user_id": user_id,
            "time_period": time_period,
            "total_plants": len(user_plants),
            "healthy_plants_count": len([p for p in plant_performance if p["health_score"] >= 0.7]),
            "care_consistency_score": care_consistency["score"],
            "care_consistency_trend": care_consistency["trend"],
            "health_trend_data": health_trends,
            "plant_performance_data": plant_performance,
            "achievements": [
                {
                    "id": str(achievement.id),
                    "type": achievement.achievement_type,
                    "name": achievement.name,
                    "description": achievement.description,
                    "achieved_at": achievement.achieved_at.isoformat(),
                    "plant_id": str(achievement.plant_id)
                }
                for achievement in achievements
            ],
            "care_activity_data": care_activity,
            "predictive_insights": predictive_insights,
            "summary_stats": {
                "total_care_logs": len(care_logs),
                "avg_care_frequency": care_consistency["avg_frequency"],
                "most_active_plant": care_consistency["most_active_plant"],
                "care_streak": care_consistency["current_streak"]
            }
        }

    async def get_community_analytics(
        self,
        db: Session,
        user_id: str,
        time_period: int = 30
    ) -> Dict[str, Any]:
        """Get community engagement analytics."""
        
        start_date = datetime.utcnow() - timedelta(days=time_period)
        
        # Get user's questions and answers
        questions_asked = db.query(PlantQuestion).filter(
            PlantQuestion.user_id == user_id,
            PlantQuestion.created_at >= start_date
        ).count()
        
        # Get RAG interactions
        rag_interactions = db.query(RAGInteraction).filter(
            RAGInteraction.user_id == user_id,
            RAGInteraction.created_at >= start_date
        ).all()
        
        # Get trading activity
        trades = db.query(PlantTrade).filter(
            (PlantTrade.seller_id == user_id) | (PlantTrade.buyer_id == user_id),
            PlantTrade.created_at >= start_date
        ).all()
        
        # Calculate engagement metrics
        ai_interactions = len(rag_interactions)
        successful_trades = len([t for t in trades if t.status == "completed"])
        
        # Get trending topics the user engaged with
        trending_topics = await self.ml_trending_service.get_trending_topics(
            db, limit=10, user_id=user_id
        )
        
        # Calculate social impact score
        social_impact = self._calculate_social_impact(
            questions_asked, ai_interactions, successful_trades, rag_interactions
        )
        
        return {
            "user_id": user_id,
            "time_period": time_period,
            "questions_asked": questions_asked,
            "ai_interactions": ai_interactions,
            "successful_trades": successful_trades,
            "social_impact_score": social_impact["score"],
            "impact_breakdown": social_impact["breakdown"],
            "trending_topics_engaged": [
                {
                    "topic": topic["topic"],
                    "engagement_score": topic["engagement_score"],
                    "user_interaction": topic.get("user_interaction", 0)
                }
                for topic in trending_topics
            ],
            "rag_interaction_summary": {
                "total_interactions": len(rag_interactions),
                "avg_feedback_score": statistics.mean([
                    r.feedback_score for r in rag_interactions 
                    if r.feedback_score is not None
                ]) if rag_interactions else 0,
                "most_common_interaction_type": self._get_most_common_interaction_type(rag_interactions),
                "improvement_suggestions": self._get_rag_improvement_suggestions(rag_interactions)
            }
        }

    async def get_plant_health_dashboard(
        self,
        db: Session,
        plant_id: str,
        time_period: int = 90
    ) -> Dict[str, Any]:
        """Get comprehensive health dashboard for a specific plant."""
        
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get ML health prediction
        health_prediction = await self.ml_health_service.predict_plant_health_ml(
            db, plant_id
        )
        
        # Get care optimization
        care_optimization = await self.ml_health_service.optimize_care_schedule_ml(
            db, plant_id
        )
        
        # Get historical care logs
        start_date = datetime.utcnow() - timedelta(days=time_period)
        care_logs = db.query(PlantCareLog).filter(
            PlantCareLog.plant_id == plant_id,
            PlantCareLog.created_at >= start_date
        ).order_by(PlantCareLog.created_at.desc()).all()
        
        # Calculate health trends over time
        health_timeline = self._calculate_health_timeline(care_logs, time_period)
        
        # Get care pattern analysis
        care_patterns = self._analyze_care_patterns(care_logs)
        
        # Get recommendations
        recommendations = await self._get_plant_recommendations(db, plant_id, health_prediction)
        
        return {
            "plant_id": plant_id,
            "plant_name": plant.name,
            "species": plant.species_id,
            "current_health": {
                "health_score": health_prediction["health_score"],
                "risk_level": health_prediction["risk_level"],
                "confidence": health_prediction["confidence"],
                "key_factors": health_prediction["key_factors"]
            },
            "health_timeline": health_timeline,
            "care_optimization": {
                "optimized_schedule": care_optimization["optimized_schedule"],
                "predicted_success_rate": care_optimization["predicted_success_rate"],
                "improvement_areas": care_optimization["improvement_areas"]
            },
            "care_patterns": care_patterns,
            "recommendations": recommendations,
            "care_logs_summary": {
                "total_logs": len(care_logs),
                "recent_activity": [
                    {
                        "date": log.created_at.isoformat(),
                        "type": log.care_type,
                        "notes": log.notes
                    }
                    for log in care_logs[:10]  # Last 10 activities
                ]
            }
        }

    async def get_system_performance_metrics(
        self,
        db: Session
    ) -> Dict[str, Any]:
        """Get system-wide performance metrics."""
        
        # Get ML model performance
        ml_health_metrics = await self.ml_health_service.get_model_performance(db)
        ml_trending_metrics = await self.ml_trending_service.get_analytics(db)
        
        # Get general system stats
        total_users = db.query(User).count()
        total_plants = db.query(UserPlant).filter(UserPlant.is_active == True).count()
        
        # Get recent activity
        last_24h = datetime.utcnow() - timedelta(hours=24)
        recent_care_logs = db.query(PlantCareLog).filter(
            PlantCareLog.created_at >= last_24h
        ).count()
        
        recent_rag_interactions = db.query(RAGInteraction).filter(
            RAGInteraction.created_at >= last_24h
        ).count()
        
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "ml_performance": {
                "health_model": ml_health_metrics,
                "trending_model": ml_trending_metrics
            },
            "system_stats": {
                "total_users": total_users,
                "total_plants": total_plants,
                "daily_care_logs": recent_care_logs,
                "daily_ai_interactions": recent_rag_interactions
            },
            "health_status": "healthy" if ml_health_metrics.get("accuracy", 0) > 0.8 else "warning"
        }

    # Helper methods
    
    def _empty_analytics_response(self) -> Dict[str, Any]:
        """Return empty analytics response for users with no plants."""
        return {
            "total_plants": 0,
            "healthy_plants_count": 0,
            "care_consistency_score": 0,
            "message": "No plants to analyze. Add some plants to see analytics!"
        }

    async def _calculate_health_trends(
        self,
        db: Session,
        plant_ids: List[str],
        time_period: int
    ) -> List[Dict[str, Any]]:
        """Calculate health trends over time."""
        
        trends = []
        end_date = datetime.utcnow()
        
        # Sample health data over time periods
        for i in range(time_period):
            date = end_date - timedelta(days=i)
            
            # Get care logs for this date
            care_logs_count = db.query(PlantCareLog).filter(
                PlantCareLog.plant_id.in_(plant_ids),
                func.date(PlantCareLog.created_at) == date.date()
            ).count()
            
            # Simulate health score based on care activity
            # In a real system, this would be from stored health assessments
            health_score = min(1.0, 0.3 + (care_logs_count * 0.2))
            
            trends.append({
                "date": date.date().isoformat(),
                "health_score": health_score,
                "care_activities": care_logs_count
            })
        
        return list(reversed(trends))  # Chronological order

    def _calculate_care_consistency(
        self,
        care_logs: List[PlantCareLog],
        user_plants: List[UserPlant]
    ) -> Dict[str, Any]:
        """Calculate care consistency metrics."""
        
        if not care_logs:
            return {
                "score": 0,
                "trend": "no_data",
                "avg_frequency": 0,
                "most_active_plant": None,
                "current_streak": 0
            }
        
        # Group care logs by plant
        plant_care_counts = defaultdict(int)
        for log in care_logs:
            plant_care_counts[str(log.plant_id)] += 1
        
        # Calculate consistency score (0-100)
        total_plants = len(user_plants)
        plants_with_care = len(plant_care_counts)
        avg_care_per_plant = sum(plant_care_counts.values()) / total_plants if total_plants > 0 else 0
        
        consistency_score = min(100, (plants_with_care / total_plants) * 50 + min(50, avg_care_per_plant * 10))
        
        # Find most active plant
        most_active_plant_id = max(plant_care_counts, key=plant_care_counts.get) if plant_care_counts else None
        most_active_plant = next((p for p in user_plants if str(p.id) == most_active_plant_id), None)
        
        # Calculate current streak (days with care activity)
        streak = self._calculate_care_streak(care_logs)
        
        return {
            "score": round(consistency_score, 1),
            "trend": "improving" if consistency_score > 70 else "stable" if consistency_score > 40 else "needs_improvement",
            "avg_frequency": avg_care_per_plant,
            "most_active_plant": most_active_plant.name if most_active_plant else None,
            "current_streak": streak
        }

    def _calculate_care_streak(self, care_logs: List[PlantCareLog]) -> int:
        """Calculate current care streak in days."""
        if not care_logs:
            return 0
        
        # Get dates with care activity
        care_dates = set()
        for log in care_logs:
            care_dates.add(log.created_at.date())
        
        # Count consecutive days from today
        current_date = datetime.utcnow().date()
        streak = 0
        
        while current_date in care_dates:
            streak += 1
            current_date -= timedelta(days=1)
        
        return streak

    async def _get_plant_performance_data(
        self,
        db: Session,
        plant_ids: List[str]
    ) -> List[Dict[str, Any]]:
        """Get performance data for each plant."""
        
        performance_data = []
        
        for plant_id in plant_ids:
            plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
            if not plant:
                continue
            
            try:
                # Get ML health prediction
                health_prediction = await self.ml_health_service.predict_plant_health_ml(
                    db, plant_id
                )
                
                # Get recent care logs count
                recent_care_count = db.query(PlantCareLog).filter(
                    PlantCareLog.plant_id == plant_id,
                    PlantCareLog.created_at >= datetime.utcnow() - timedelta(days=7)
                ).count()
                
                performance_data.append({
                    "plant_id": plant_id,
                    "plant_name": plant.name,
                    "health_score": health_prediction["health_score"],
                    "risk_level": health_prediction["risk_level"],
                    "recent_care_activities": recent_care_count,
                    "status": "thriving" if health_prediction["health_score"] > 0.8 else "stable" if health_prediction["health_score"] > 0.6 else "needs_attention"
                })
                
            except Exception as e:
                # Fallback if ML prediction fails
                performance_data.append({
                    "plant_id": plant_id,
                    "plant_name": plant.name,
                    "health_score": 0.5,
                    "risk_level": "medium",
                    "recent_care_activities": 0,
                    "status": "data_unavailable"
                })
        
        return performance_data

    def _generate_care_activity_heatmap(
        self,
        care_logs: List[PlantCareLog],
        time_period: int
    ) -> Dict[str, Any]:
        """Generate care activity heatmap data."""
        
        # Group care logs by date
        daily_activity = defaultdict(int)
        for log in care_logs:
            date_str = log.created_at.date().isoformat()
            daily_activity[date_str] += 1
        
        # Generate heatmap data for time period
        heatmap_data = []
        end_date = datetime.utcnow()
        
        for i in range(time_period):
            date = end_date - timedelta(days=i)
            date_str = date.date().isoformat()
            activity_count = daily_activity.get(date_str, 0)
            
            heatmap_data.append({
                "date": date_str,
                "activity_count": activity_count,
                "intensity": min(1.0, activity_count / 5.0)  # Normalize to 0-1
            })
        
        return {
            "data": list(reversed(heatmap_data)),
            "max_activity": max(daily_activity.values()) if daily_activity else 0,
            "total_active_days": len([d for d in daily_activity.values() if d > 0])
        }

    async def _get_predictive_insights(
        self,
        db: Session,
        plant_ids: List[str]
    ) -> List[Dict[str, Any]]:
        """Get predictive insights for plants."""
        
        insights = []
        
        for plant_id in plant_ids:
            try:
                # Get care optimization
                optimization = await self.ml_health_service.optimize_care_schedule_ml(
                    db, plant_id
                )
                
                plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
                
                insights.append({
                    "plant_id": plant_id,
                    "plant_name": plant.name if plant else "Unknown",
                    "prediction_type": "care_optimization",
                    "insight": f"Optimized care schedule could improve success rate to {optimization['predicted_success_rate']:.1%}",
                    "confidence": optimization.get("confidence", 0.8),
                    "recommended_actions": optimization.get("improvement_areas", [])
                })
                
            except Exception:
                continue
        
        return insights

    def _calculate_social_impact(
        self,
        questions_asked: int,
        ai_interactions: int,
        successful_trades: int,
        rag_interactions: List[RAGInteraction]
    ) -> Dict[str, Any]:
        """Calculate social impact score."""
        
        # Base scores
        question_score = min(questions_asked * 10, 50)
        ai_score = min(ai_interactions * 5, 30)
        trade_score = min(successful_trades * 15, 20)
        
        # Quality bonus from RAG feedback
        quality_bonus = 0
        if rag_interactions:
            avg_feedback = statistics.mean([
                r.feedback_score for r in rag_interactions 
                if r.feedback_score is not None
            ])
            quality_bonus = max(0, (avg_feedback - 3) * 5)  # Bonus for above-average feedback
        
        total_score = question_score + ai_score + trade_score + quality_bonus
        
        return {
            "score": round(total_score, 1),
            "breakdown": {
                "community_questions": question_score,
                "ai_interactions": ai_score,
                "successful_trades": trade_score,
                "quality_bonus": quality_bonus
            }
        }

    def _get_most_common_interaction_type(self, rag_interactions: List[RAGInteraction]) -> str:
        """Get most common RAG interaction type."""
        if not rag_interactions:
            return "none"
        
        type_counts = defaultdict(int)
        for interaction in rag_interactions:
            type_counts[interaction.interaction_type] += 1
        
        return max(type_counts, key=type_counts.get)

    def _get_rag_improvement_suggestions(self, rag_interactions: List[RAGInteraction]) -> List[str]:
        """Get improvement suggestions based on RAG interactions."""
        suggestions = []
        
        if not rag_interactions:
            return ["Try asking more questions to get personalized plant care advice!"]
        
        # Analyze feedback scores
        low_feedback_count = len([r for r in rag_interactions if r.feedback_score and r.feedback_score < 3])
        if low_feedback_count > len(rag_interactions) * 0.3:
            suggestions.append("Try asking more specific questions for better AI responses")
        
        # Check interaction variety
        interaction_types = set(r.interaction_type for r in rag_interactions)
        if len(interaction_types) < 3:
            suggestions.append("Explore different types of AI assistance (care advice, health diagnosis, content generation)")
        
        return suggestions if suggestions else ["Keep up the great engagement with AI assistance!"]

    def _calculate_health_timeline(self, care_logs: List[PlantCareLog], time_period: int) -> List[Dict[str, Any]]:
        """Calculate health timeline based on care activity."""
        timeline = []
        
        # Group by week for better visualization
        weeks = time_period // 7
        end_date = datetime.utcnow()
        
        for week in range(weeks):
            week_start = end_date - timedelta(days=(week + 1) * 7)
            week_end = end_date - timedelta(days=week * 7)
            
            week_logs = [
                log for log in care_logs 
                if week_start <= log.created_at <= week_end
            ]
            
            # Estimate health based on care activity
            care_frequency = len(week_logs)
            estimated_health = min(1.0, 0.4 + (care_frequency * 0.15))
            
            timeline.append({
                "week_start": week_start.date().isoformat(),
                "week_end": week_end.date().isoformat(),
                "estimated_health": estimated_health,
                "care_activities": care_frequency,
                "care_types": list(set(log.care_type for log in week_logs))
            })
        
        return list(reversed(timeline))

    def _analyze_care_patterns(self, care_logs: List[PlantCareLog]) -> Dict[str, Any]:
        """Analyze care patterns and frequencies."""
        if not care_logs:
            return {"pattern": "no_data"}
        
        # Group by care type
        care_type_counts = defaultdict(int)
        for log in care_logs:
            care_type_counts[log.care_type] += 1
        
        # Analyze timing patterns
        care_days = [log.created_at.weekday() for log in care_logs]
        most_common_day = max(set(care_days), key=care_days.count) if care_days else 0
        day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        
        return {
            "most_common_care_type": max(care_type_counts, key=care_type_counts.get),
            "care_type_distribution": dict(care_type_counts),
            "most_active_day": day_names[most_common_day],
            "total_activities": len(care_logs),
            "pattern": "consistent" if len(care_logs) > 10 else "irregular"
        }

    async def _get_plant_recommendations(
        self,
        db: Session,
        plant_id: str,
        health_prediction: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Get personalized recommendations for a plant."""
        recommendations = []
        
        health_score = health_prediction["health_score"]
        risk_level = health_prediction["risk_level"]
        
        # Generate recommendations based on health score
        if health_score < 0.5:
            recommendations.append({
                "type": "urgent",
                "title": "Immediate Attention Needed",
                "description": "Your plant's health score is low. Consider checking soil moisture, light exposure, and recent care activities.",
                "priority": "high"
            })
        
        if risk_level == "high":
            recommendations.append({
                "type": "preventive",
                "title": "Preventive Care Recommended",
                "description": "High risk factors detected. Increase monitoring and consider adjusting care routine.",
                "priority": "medium"
            })
        
        # Always include a general tip
        recommendations.append({
            "type": "general",
            "title": "Regular Care Reminder",
            "description": "Maintain consistent watering and check for pests weekly.",
            "priority": "low"
        })
        
        return recommendations 