"""Plant achievement service.

This module provides business logic for plant achievements and milestone tracking.
"""

from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from uuid import UUID

from sqlalchemy import select, func, desc, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.plant_achievement import PlantAchievement, UserAchievement, PlantMilestone, UserStats
from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.plant_identification import PlantIdentification
from app.models.plant_question import PlantQuestion, PlantAnswer


class PlantAchievementService:
    """Service for managing plant achievements."""
    
    @staticmethod
    async def get_user_achievements(
        db: AsyncSession,
        user_id: UUID,
        limit: int = 50,
        offset: int = 0
    ) -> List[UserAchievement]:
        """Get user's earned achievements."""
        result = await db.execute(
            select(UserAchievement).options(
                selectinload(UserAchievement.achievement)
            ).where(
                UserAchievement.user_id == user_id
            ).order_by(desc(UserAchievement.earned_at)).limit(limit).offset(offset)
        )
        return result.scalars().all()
    
    @staticmethod
    async def get_available_achievements(
        db: AsyncSession,
        user_id: UUID
    ) -> List[PlantAchievement]:
        """Get achievements available to unlock."""
        # Get achievements user hasn't earned yet
        earned_achievement_ids = await db.execute(
            select(UserAchievement.achievement_id).where(
                UserAchievement.user_id == user_id
            )
        )
        earned_ids = [row[0] for row in earned_achievement_ids.fetchall()]
        
        result = await db.execute(
            select(PlantAchievement).where(
                and_(
                    PlantAchievement.is_active == True,
                    ~PlantAchievement.id.in_(earned_ids) if earned_ids else True
                )
            ).order_by(PlantAchievement.points)
        )
        return result.scalars().all()
    
    @staticmethod
    async def check_and_award_achievements(
        db: AsyncSession,
        user_id: UUID
    ) -> List[UserAchievement]:
        """Check and award any newly earned achievements."""
        newly_earned = []
        
        # Get user stats
        user_stats = await PlantAchievementService.get_or_create_user_stats(db, user_id)
        
        # Get available achievements
        available_achievements = await PlantAchievementService.get_available_achievements(db, user_id)
        
        for achievement in available_achievements:
            if await PlantAchievementService._check_achievement_criteria(db, user_id, achievement, user_stats):
                # Award the achievement
                user_achievement = UserAchievement(
                    user_id=user_id,
                    achievement_id=achievement.id,
                    earned_at=datetime.utcnow()
                )
                db.add(user_achievement)
                
                # Update user stats
                user_stats.total_achievements += 1
                user_stats.total_points += achievement.points
                user_stats.level = PlantAchievementService._calculate_level(user_stats.total_points)
                
                newly_earned.append(user_achievement)
        
        if newly_earned:
            await db.commit()
            
            # Reload with relationships
            for ua in newly_earned:
                await db.refresh(ua, ['achievement'])
        
        return newly_earned
    
    @staticmethod
    async def _check_achievement_criteria(
        db: AsyncSession,
        user_id: UUID,
        achievement: PlantAchievement,
        user_stats: UserStats
    ) -> bool:
        """Check if user meets achievement criteria."""
        criteria = achievement.unlock_criteria or {}
        
        if achievement.achievement_type == "care_streak":
            required_days = criteria.get("days", 7)
            return user_stats.care_streak_days >= required_days
        
        elif achievement.achievement_type == "plant_collection":
            required_count = criteria.get("count", 5)
            return user_stats.active_plants >= required_count
        
        elif achievement.achievement_type == "identification":
            required_count = criteria.get("count", 10)
            return user_stats.plants_identified >= required_count
        
        elif achievement.achievement_type == "community_helper":
            required_answers = criteria.get("helpful_answers", 5)
            return user_stats.helpful_answers >= required_answers
        
        elif achievement.achievement_type == "plant_age":
            required_days = criteria.get("days", 365)
            # Check if user has any plants older than required days
            result = await db.execute(
                select(func.count(UserPlant.id)).where(
                    and_(
                        UserPlant.user_id == user_id,
                        UserPlant.is_active == True,
                        UserPlant.acquired_date <= datetime.utcnow() - timedelta(days=required_days)
                    )
                )
            )
            count = result.scalar()
            return count > 0
        
        return False
    
    @staticmethod
    def _calculate_level(total_points: int) -> int:
        """Calculate user level based on total points."""
        if total_points < 100:
            return 1
        elif total_points < 300:
            return 2
        elif total_points < 600:
            return 3
        elif total_points < 1000:
            return 4
        elif total_points < 1500:
            return 5
        else:
            return min(10, 5 + (total_points - 1500) // 500)
    
    @staticmethod
    async def get_or_create_user_stats(
        db: AsyncSession,
        user_id: UUID
    ) -> UserStats:
        """Get or create user statistics."""
        result = await db.execute(
            select(UserStats).where(UserStats.user_id == user_id)
        )
        user_stats = result.scalar_one_or_none()
        
        if not user_stats:
            user_stats = UserStats(user_id=user_id)
            db.add(user_stats)
            await db.commit()
            await db.refresh(user_stats)
        
        return user_stats
    
    @staticmethod
    async def update_user_stats(
        db: AsyncSession,
        user_id: UUID,
        stat_updates: Dict[str, Any]
    ) -> UserStats:
        """Update user statistics."""
        user_stats = await PlantAchievementService.get_or_create_user_stats(db, user_id)
        
        for key, value in stat_updates.items():
            if hasattr(user_stats, key):
                setattr(user_stats, key, value)
        
        user_stats.last_updated = datetime.utcnow()
        await db.commit()
        await db.refresh(user_stats)
        
        return user_stats


class PlantMilestoneService:
    """Service for managing plant milestones."""
    
    @staticmethod
    async def create_milestone(
        db: AsyncSession,
        plant_id: UUID,
        milestone_type: str,
        title: str,
        description: Optional[str] = None,
        photo_url: Optional[str] = None,
        notes: Optional[str] = None
    ) -> PlantMilestone:
        """Create a new plant milestone."""
        milestone = PlantMilestone(
            plant_id=plant_id,
            milestone_type=milestone_type,
            title=title,
            description=description,
            photo_url=photo_url,
            notes=notes
        )
        
        db.add(milestone)
        await db.commit()
        await db.refresh(milestone)
        
        return milestone
    
    @staticmethod
    async def get_plant_milestones(
        db: AsyncSession,
        plant_id: UUID
    ) -> List[PlantMilestone]:
        """Get milestones for a specific plant."""
        result = await db.execute(
            select(PlantMilestone).where(
                PlantMilestone.plant_id == plant_id
            ).order_by(desc(PlantMilestone.achieved_at))
        )
        return result.scalars().all()
    
    @staticmethod
    async def get_user_milestones(
        db: AsyncSession,
        user_id: UUID,
        limit: int = 50,
        offset: int = 0
    ) -> List[PlantMilestone]:
        """Get all milestones for user's plants."""
        result = await db.execute(
            select(PlantMilestone).options(
                selectinload(PlantMilestone.plant)
            ).join(UserPlant).where(
                UserPlant.user_id == user_id
            ).order_by(desc(PlantMilestone.achieved_at)).limit(limit).offset(offset)
        )
        return result.scalars().all()
    
    @staticmethod
    async def check_automatic_milestones(
        db: AsyncSession,
        plant_id: UUID
    ) -> List[PlantMilestone]:
        """Check and create automatic milestones for a plant."""
        newly_created = []
        
        # Get plant info
        result = await db.execute(
            select(UserPlant).where(UserPlant.id == plant_id)
        )
        plant = result.scalar_one_or_none()
        
        if not plant or not plant.acquired_date:
            return newly_created
        
        # Get existing milestones
        existing_milestones = await PlantMilestoneService.get_plant_milestones(db, plant_id)
        existing_types = {m.milestone_type for m in existing_milestones}
        
        # Check age-based milestones
        age_days = (datetime.utcnow().date() - plant.acquired_date).days
        
        age_milestones = [
            (30, "one_month", "One Month Together", "Your plant has been with you for a month!"),
            (90, "three_months", "Three Months Strong", "Quarter of a year of plant parenthood!"),
            (365, "one_year", "One Year Anniversary", "A full year of growth and care!"),
            (730, "two_years", "Two Years Together", "Two amazing years with your plant companion!"),
        ]
        
        for days, milestone_type, title, description in age_milestones:
            if age_days >= days and milestone_type not in existing_types:
                milestone = await PlantMilestoneService.create_milestone(
                    db, plant_id, milestone_type, title, description
                )
                newly_created.append(milestone)
        
        return newly_created


# Initialize default achievements
DEFAULT_ACHIEVEMENTS = [
    {
        "achievement_type": "care_streak",
        "title": "Consistent Caregiver",
        "description": "Care for your plants 7 days in a row",
        "icon": "🏆",
        "badge_color": "gold",
        "points": 50,
        "unlock_criteria": {"days": 7}
    },
    {
        "achievement_type": "care_streak",
        "title": "Plant Parent Pro",
        "description": "Maintain a 30-day care streak",
        "icon": "🌟",
        "badge_color": "gold",
        "points": 200,
        "unlock_criteria": {"days": 30}
    },
    {
        "achievement_type": "plant_collection",
        "title": "Green Thumb",
        "description": "Grow your collection to 5 plants",
        "icon": "🌱",
        "badge_color": "green",
        "points": 100,
        "unlock_criteria": {"count": 5}
    },
    {
        "achievement_type": "plant_collection",
        "title": "Plant Collector",
        "description": "Manage 15 plants in your collection",
        "icon": "🌿",
        "badge_color": "green",
        "points": 300,
        "unlock_criteria": {"count": 15}
    },
    {
        "achievement_type": "identification",
        "title": "Plant Detective",
        "description": "Identify 10 different plant species",
        "icon": "🔍",
        "badge_color": "blue",
        "points": 75,
        "unlock_criteria": {"count": 10}
    },
    {
        "achievement_type": "community_helper",
        "title": "Helpful Gardener",
        "description": "Receive 5 helpful votes on your answers",
        "icon": "💚",
        "badge_color": "purple",
        "points": 150,
        "unlock_criteria": {"helpful_answers": 5}
    },
    {
        "achievement_type": "plant_age",
        "title": "Long-term Commitment",
        "description": "Keep a plant alive for one full year",
        "icon": "🎂",
        "badge_color": "gold",
        "points": 250,
        "unlock_criteria": {"days": 365}
    }
]


async def initialize_default_achievements(db: AsyncSession):
    """Initialize default achievements in the database."""
    for achievement_data in DEFAULT_ACHIEVEMENTS:
        # Check if achievement already exists
        result = await db.execute(
            select(PlantAchievement).where(
                and_(
                    PlantAchievement.achievement_type == achievement_data["achievement_type"],
                    PlantAchievement.title == achievement_data["title"]
                )
            )
        )
        
        if not result.scalar_one_or_none():
            achievement = PlantAchievement(**achievement_data)
            db.add(achievement)
    
    await db.commit() 