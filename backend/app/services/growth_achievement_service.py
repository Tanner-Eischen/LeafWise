"""
Growth Achievement Service for LeafWise Platform

This service provides achievement and milestone tracking capabilities including:
- Growth milestone detection and creation
- Achievement system management
- Seasonal challenge tracking
- Badge and points management

Focused on gamification and user engagement through achievements.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from uuid import uuid4
import json

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant
from app.models.user import User


class GrowthAchievementService:
    """Service for growth achievements and milestone tracking."""
    
    def __init__(self):
        pass
    
    async def create_achievement_system(
        self,
        db: Session,
        user_id: str,
        plant_id: str,
        milestone_type: str,
        milestone_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Create achievement system for growth milestones and seasonal challenges.
        
        Args:
            db: Database session
            user_id: ID of the user
            plant_id: ID of the plant
            milestone_type: Type of milestone achieved
            milestone_data: Data about the milestone
            
        Returns:
            Dictionary containing achievement information
        """
        # Verify plant ownership
        plant = db.query(UserPlant).filter(
            UserPlant.id == plant_id,
            UserPlant.user_id == user_id
        ).first()
        
        if not plant:
            raise ValueError("Plant not found or access denied")
        
        # Check if achievement already exists
        existing_achievement = db.query(GrowthMilestone).filter(
            GrowthMilestone.plant_id == plant_id,
            GrowthMilestone.milestone_type == milestone_type,
            GrowthMilestone.achieved_at >= datetime.utcnow() - timedelta(days=30)
        ).first()
        
        if existing_achievement:
            return {
                "status": "already_achieved",
                "message": "This milestone was already achieved recently",
                "existing_achievement": {
                    "id": str(existing_achievement.id),
                    "achieved_at": existing_achievement.achieved_at.isoformat()
                }
            }
        
        # Determine achievement details
        achievement_info = self.determine_achievement_details(milestone_type, milestone_data)
        
        # Create milestone record
        milestone = GrowthMilestone(
            plant_id=plant_id,
            user_id=user_id,
            milestone_type=milestone_type,
            milestone_data=milestone_data,
            description=achievement_info["description"],
            achieved_at=datetime.utcnow(),
            badge_type=achievement_info["badge_type"],
            points_earned=achievement_info["points"],
            is_seasonal=achievement_info["is_seasonal"],
            sharing_enabled=True
        )
        
        db.add(milestone)
        db.commit()
        db.refresh(milestone)
        
        return {
            "achievement": {
                "id": str(milestone.id),
                "type": milestone_type,
                "title": achievement_info["title"],
                "description": achievement_info["description"],
                "badge_type": achievement_info["badge_type"],
                "points_earned": achievement_info["points"],
                "is_seasonal": achievement_info["is_seasonal"],
                "achieved_at": milestone.achieved_at.isoformat()
            },
            "status": "achievement_unlocked"
        }

    def determine_achievement_details(self, milestone_type: str, milestone_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Determine achievement details based on milestone type.
        
        Args:
            milestone_type: Type of milestone
            milestone_data: Data about the milestone
            
        Returns:
            Dictionary containing achievement details
        """
        achievement_details = {
            "first_photo": {
                "title": "First Steps",
                "description": "Captured your first growth photo!",
                "badge_type": "bronze",
                "points": 10,
                "is_seasonal": False
            },
            "growth_spurt": {
                "title": "Growth Champion",
                "description": "Achieved significant growth milestone!",
                "badge_type": "gold",
                "points": 50,
                "is_seasonal": False
            },
            "seasonal_transition": {
                "title": "Season Survivor",
                "description": "Successfully tracked plant through seasonal changes!",
                "badge_type": "silver",
                "points": 30,
                "is_seasonal": True
            },
            "consistency_streak": {
                "title": "Dedicated Gardener",
                "description": "Maintained consistent tracking for 30 days!",
                "badge_type": "silver",
                "points": 40,
                "is_seasonal": False
            },
            "height_milestone": {
                "title": "Reaching New Heights",
                "description": f"Plant reached {milestone_data.get('height', 0)}cm tall!",
                "badge_type": "gold",
                "points": 60,
                "is_seasonal": False
            }
        }
        
        return achievement_details.get(milestone_type, {
            "title": "Achievement Unlocked",
            "description": "Milestone achieved!",
            "badge_type": "bronze",
            "points": 10,
            "is_seasonal": False
        })

    async def get_seasonal_challenges_available(self, db: Session, user_id: str, season: str) -> List[Dict[str, Any]]:
        """
        Get available seasonal challenges for a user.
        
        Args:
            db: Database session
            user_id: ID of the user
            season: Current season
            
        Returns:
            List of available seasonal challenges
        """
        current_month = datetime.utcnow().month
        challenges = []
        
        if current_month in [3, 4, 5]:  # Spring
            challenges.append({
                "challenge_id": "spring_growth_2024",
                "title": "Spring Growth Challenge",
                "description": "Track your plant's spring growth spurt!",
                "requirements": "Weekly photos during spring season",
                "duration_days": 90,
                "points": 100,
                "rewards": {"badge": "Spring Growth Master"}
            })
        elif current_month in [6, 7, 8]:  # Summer
            challenges.append({
                "challenge_id": "summer_care_2024",
                "title": "Summer Care Challenge",
                "description": "Maintain healthy plants through summer heat!",
                "requirements": "Daily care logs during summer",
                "duration_days": 90,
                "points": 120,
                "rewards": {"badge": "Summer Care Expert"}
            })
        elif current_month in [9, 10, 11]:  # Fall
            challenges.append({
                "challenge_id": "fall_preparation_2024",
                "title": "Fall Preparation Challenge",
                "description": "Prepare your plants for winter!",
                "requirements": "Document seasonal care adjustments",
                "duration_days": 90,
                "points": 80,
                "rewards": {"badge": "Fall Preparation Pro"}
            })
        else:  # Winter
            challenges.append({
                "challenge_id": "winter_survival_2024",
                "title": "Winter Survival Challenge",
                "description": "Keep your plants thriving through winter!",
                "requirements": "Monitor and adjust care for winter conditions",
                "duration_days": 90,
                "points": 150,
                "rewards": {"badge": "Winter Survival Expert"}
            })

        return challenges

    async def get_user_achievements(self, db: Session, user_id: str) -> Dict[str, Any]:
        """
        Get all achievements for a user.
        
        Args:
            db: Database session
            user_id: ID of the user
            
        Returns:
            Dictionary containing user achievements
        """
        achievements = db.query(GrowthMilestone).filter(
            GrowthMilestone.user_id == user_id
        ).order_by(GrowthMilestone.achieved_at.desc()).all()
        
        # Calculate achievement statistics
        total_points = sum(achievement.points_earned for achievement in achievements)
        badge_counts = {}
        seasonal_achievements = 0
        
        for achievement in achievements:
            badge_type = achievement.badge_type
            badge_counts[badge_type] = badge_counts.get(badge_type, 0) + 1
            if achievement.is_seasonal:
                seasonal_achievements += 1
        
        return {
            "user_id": user_id,
            "total_achievements": len(achievements),
            "total_points": total_points,
            "badge_counts": badge_counts,
            "seasonal_achievements": seasonal_achievements,
            "recent_achievements": [
                {
                    "id": str(achievement.id),
                    "type": achievement.milestone_type,
                    "description": achievement.description,
                    "badge_type": achievement.badge_type,
                    "points_earned": achievement.points_earned,
                    "achieved_at": achievement.achieved_at.isoformat()
                }
                for achievement in achievements[:10]  # Last 10 achievements
            ]
        }

    async def check_milestone_eligibility(
        self,
        db: Session,
        plant_id: str,
        timeline: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Check if plant is eligible for any new milestones.
        
        Args:
            db: Database session
            plant_id: ID of the plant
            timeline: Growth timeline data
            
        Returns:
            List of eligible milestones
        """
        eligible_milestones = []
        
        if not timeline:
            return eligible_milestones
        
        # Check for height milestones
        current_height = timeline[-1]["height"]
        height_milestones = [10, 20, 30, 50, 75, 100]  # cm
        
        for milestone_height in height_milestones:
            if current_height >= milestone_height:
                # Check if this milestone was already achieved
                existing = db.query(GrowthMilestone).filter(
                    GrowthMilestone.plant_id == plant_id,
                    GrowthMilestone.milestone_type == "height_milestone",
                    GrowthMilestone.milestone_data.contains(f'"height": {milestone_height}')
                ).first()
                
                if not existing:
                    eligible_milestones.append({
                        "type": "height_milestone",
                        "data": {"height": milestone_height},
                        "priority": "high" if milestone_height >= 50 else "medium"
                    })
        
        # Check for growth spurt milestone
        if len(timeline) >= 2:
            recent_growth = timeline[-1]["height"] - timeline[-2]["height"]
            days_diff = (timeline[-1]["date"] - timeline[-2]["date"]).days
            
            if days_diff > 0 and (recent_growth / days_diff) > 1.0:  # > 1cm per day
                eligible_milestones.append({
                    "type": "growth_spurt",
                    "data": {"growth_rate": recent_growth / days_diff},
                    "priority": "high"
                })
        
        # Check for consistency milestone
        if len(timeline) >= 30:  # 30 data points suggest consistent tracking
            eligible_milestones.append({
                "type": "consistency_streak",
                "data": {"tracking_days": len(timeline)},
                "priority": "medium"
            })
        
        return eligible_milestones


def get_growth_achievement_service() -> GrowthAchievementService:
    """
    Factory function to get GrowthAchievementService instance.
    
    Returns:
        GrowthAchievementService instance
    """
    return GrowthAchievementService()