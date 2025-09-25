"""Community Challenge Service for Seasonal Growing Competitions.

This service manages seasonal challenges, growth competitions, and community
achievements related to plant care and time-lapse tracking.
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID, uuid4
from enum import Enum

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, desc, func, text
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.timelapse import TimelapseSession
from app.models.growth_photo import GrowthPhoto
from app.models.seasonal_ai import SeasonalPrediction
from app.models.friendship import Friendship, FriendshipStatus
from app.services.notification_service import seasonal_notification_service, NotificationPriority

logger = logging.getLogger(__name__)


class ChallengeType(str, Enum):
    """Types of community challenges."""
    SEASONAL_GROWTH = "seasonal_growth"
    WINTER_SURVIVAL = "winter_survival"
    SPRING_AWAKENING = "spring_awakening"
    SUMMER_THRIVING = "summer_thriving"
    FALL_PREPARATION = "fall_preparation"
    PROPAGATION_CHALLENGE = "propagation_challenge"
    TIMELAPSE_SHOWCASE = "timelapse_showcase"
    CARE_CONSISTENCY = "care_consistency"
    SPECIES_SPECIFIC = "species_specific"


class ChallengeStatus(str, Enum):
    """Challenge status options."""
    UPCOMING = "upcoming"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class ParticipationStatus(str, Enum):
    """User participation status."""
    REGISTERED = "registered"
    ACTIVE = "active"
    COMPLETED = "completed"
    WITHDRAWN = "withdrawn"


class CommunityChallengeService:
    """Service for managing seasonal community challenges."""
    
    def __init__(self):
        self.notification_service = seasonal_notification_service
    
    async def create_seasonal_challenge(
        self,
        db: AsyncSession,
        challenge_data: Dict[str, Any],
        creator_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Create a new seasonal challenge."""
        try:
            challenge_id = uuid4()
            
            # Determine challenge dates based on season
            start_date, end_date = self._calculate_seasonal_dates(
                challenge_data.get("challenge_type"),
                challenge_data.get("duration_weeks", 4)
            )
            
            challenge = {
                "id": str(challenge_id),
                "title": challenge_data.get("title"),
                "description": challenge_data.get("description"),
                "challenge_type": challenge_data.get("challenge_type"),
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "status": ChallengeStatus.UPCOMING.value,
                "creator_id": str(creator_id) if creator_id else None,
                "max_participants": challenge_data.get("max_participants"),
                "entry_requirements": challenge_data.get("entry_requirements", []),
                "success_criteria": challenge_data.get("success_criteria", []),
                "rewards": challenge_data.get("rewards", []),
                "rules": challenge_data.get("rules", []),
                "categories": challenge_data.get("categories", []),
                "created_at": datetime.utcnow().isoformat(),
                "participants": [],
                "leaderboard": [],
                "metadata": challenge_data.get("metadata", {})
            }
            
            # Store challenge (in a real implementation, this would go to database)
            # For now, we'll simulate storage
            await self._store_challenge(db, challenge)
            
            # Notify potential participants
            await self._notify_challenge_creation(db, challenge)
            
            logger.info(f"Created seasonal challenge: {challenge['title']}")
            return challenge
            
        except Exception as e:
            logger.error(f"Error creating seasonal challenge: {str(e)}")
            raise
    
    async def join_challenge(
        self,
        db: AsyncSession,
        challenge_id: str,
        user_id: UUID,
        plant_id: UUID,
        entry_data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Join a seasonal challenge with a specific plant."""
        try:
            # Get challenge details
            challenge = await self._get_challenge(db, challenge_id)
            if not challenge:
                raise ValueError("Challenge not found")
            
            # Verify user owns the plant
            plant = await db.get(UserPlant, plant_id)
            if not plant or plant.user_id != user_id:
                raise ValueError("Plant not found or not owned by user")
            
            # Check if user is already participating
            existing_participation = next(
                (p for p in challenge["participants"] if p["user_id"] == str(user_id)),
                None
            )
            
            if existing_participation:
                raise ValueError("Already participating in this challenge")
            
            # Check entry requirements
            if not await self._check_entry_requirements(db, challenge, user_id, plant_id):
                raise ValueError("Entry requirements not met")
            
            # Create participation record
            participation = {
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "joined_at": datetime.utcnow().isoformat(),
                "status": ParticipationStatus.REGISTERED.value,
                "entry_data": entry_data or {},
                "progress": {},
                "achievements": [],
                "score": 0
            }
            
            # Add to challenge participants
            challenge["participants"].append(participation)
            await self._update_challenge(db, challenge)
            
            # Initialize tracking for the challenge
            await self._initialize_challenge_tracking(db, challenge_id, user_id, plant_id)
            
            # Send confirmation notification
            await self.notification_service.send_seasonal_challenge_notification(
                db, user_id, {
                    "type": "challenge_joined",
                    "title": f"Joined {challenge['title']}!",
                    "description": f"You've successfully joined the challenge with {plant.nickname}",
                    "challenge_id": challenge_id
                }
            )
            
            logger.info(f"User {user_id} joined challenge {challenge_id} with plant {plant_id}")
            return participation
            
        except Exception as e:
            logger.error(f"Error joining challenge: {str(e)}")
            raise
    
    async def update_challenge_progress(
        self,
        db: AsyncSession,
        challenge_id: str,
        user_id: UUID,
        progress_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Update user's progress in a challenge."""
        try:
            challenge = await self._get_challenge(db, challenge_id)
            if not challenge:
                raise ValueError("Challenge not found")
            
            # Find user's participation
            participation = next(
                (p for p in challenge["participants"] if p["user_id"] == str(user_id)),
                None
            )
            
            if not participation:
                raise ValueError("User not participating in this challenge")
            
            # Update progress
            participation["progress"].update(progress_data)
            participation["last_updated"] = datetime.utcnow().isoformat()
            
            # Calculate new score based on progress
            new_score = await self._calculate_challenge_score(
                challenge, participation, progress_data
            )
            participation["score"] = new_score
            
            # Check for new achievements
            new_achievements = await self._check_challenge_achievements(
                db, challenge, participation, progress_data
            )
            
            if new_achievements:
                participation["achievements"].extend(new_achievements)
                
                # Send achievement notifications
                for achievement in new_achievements:
                    await self.notification_service.send_seasonal_challenge_notification(
                        db, user_id, {
                            "type": "challenge_achievement",
                            "title": f"Achievement Unlocked: {achievement['title']}!",
                            "description": achievement["description"],
                            "challenge_id": challenge_id
                        }
                    )
            
            # Update leaderboard
            await self._update_leaderboard(challenge, user_id, new_score)
            
            # Save changes
            await self._update_challenge(db, challenge)
            
            logger.info(f"Updated challenge progress for user {user_id} in challenge {challenge_id}")
            return participation
            
        except Exception as e:
            logger.error(f"Error updating challenge progress: {str(e)}")
            raise
    
    async def get_active_challenges(
        self,
        db: AsyncSession,
        user_id: Optional[UUID] = None,
        challenge_type: Optional[ChallengeType] = None
    ) -> List[Dict[str, Any]]:
        """Get list of active challenges, optionally filtered by user or type."""
        try:
            # Get all active challenges
            challenges = await self._get_challenges_by_status(db, ChallengeStatus.ACTIVE)
            
            # Filter by type if specified
            if challenge_type:
                challenges = [c for c in challenges if c["challenge_type"] == challenge_type.value]
            
            # Add user-specific information if user_id provided
            if user_id:
                for challenge in challenges:
                    user_participation = next(
                        (p for p in challenge["participants"] if p["user_id"] == str(user_id)),
                        None
                    )
                    challenge["user_participation"] = user_participation
                    challenge["user_eligible"] = await self._check_user_eligibility(
                        db, challenge, user_id
                    )
            
            return challenges
            
        except Exception as e:
            logger.error(f"Error getting active challenges: {str(e)}")
            return []
    
    async def get_challenge_leaderboard(
        self,
        db: AsyncSession,
        challenge_id: str,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get challenge leaderboard with user details."""
        try:
            challenge = await self._get_challenge(db, challenge_id)
            if not challenge:
                return []
            
            # Sort participants by score
            sorted_participants = sorted(
                challenge["participants"],
                key=lambda p: p.get("score", 0),
                reverse=True
            )[:limit]
            
            # Enrich with user details
            leaderboard = []
            for i, participant in enumerate(sorted_participants):
                user = await db.get(User, UUID(participant["user_id"]))
                plant = await db.get(UserPlant, UUID(participant["plant_id"]))
                
                if user and plant:
                    leaderboard_entry = {
                        "rank": i + 1,
                        "user_id": participant["user_id"],
                        "username": user.username,
                        "display_name": user.display_name,
                        "avatar_url": user.avatar_url,
                        "plant_id": participant["plant_id"],
                        "plant_nickname": plant.nickname,
                        "plant_species": plant.species.common_names[0] if plant.species else "Unknown",
                        "score": participant.get("score", 0),
                        "achievements": participant.get("achievements", []),
                        "joined_at": participant["joined_at"],
                        "progress": participant.get("progress", {})
                    }
                    leaderboard.append(leaderboard_entry)
            
            return leaderboard
            
        except Exception as e:
            logger.error(f"Error getting challenge leaderboard: {str(e)}")
            return []
    
    async def complete_challenge(
        self,
        db: AsyncSession,
        challenge_id: str
    ) -> Dict[str, Any]:
        """Complete a challenge and distribute rewards."""
        try:
            challenge = await self._get_challenge(db, challenge_id)
            if not challenge:
                raise ValueError("Challenge not found")
            
            # Update challenge status
            challenge["status"] = ChallengeStatus.COMPLETED.value
            challenge["completed_at"] = datetime.utcnow().isoformat()
            
            # Calculate final rankings
            final_leaderboard = await self.get_challenge_leaderboard(db, challenge_id)
            challenge["final_leaderboard"] = final_leaderboard
            
            # Distribute rewards
            rewards_distributed = await self._distribute_challenge_rewards(
                db, challenge, final_leaderboard
            )
            
            # Send completion notifications
            await self._notify_challenge_completion(db, challenge, final_leaderboard)
            
            # Save final state
            await self._update_challenge(db, challenge)
            
            logger.info(f"Completed challenge {challenge_id} with {len(final_leaderboard)} participants")
            return {
                "challenge": challenge,
                "final_leaderboard": final_leaderboard,
                "rewards_distributed": rewards_distributed
            }
            
        except Exception as e:
            logger.error(f"Error completing challenge: {str(e)}")
            raise
    
    async def get_user_challenge_history(
        self,
        db: AsyncSession,
        user_id: UUID,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Get user's challenge participation history."""
        try:
            # Get all challenges where user participated
            all_challenges = await self._get_all_challenges(db)
            user_challenges = []
            
            for challenge in all_challenges:
                user_participation = next(
                    (p for p in challenge["participants"] if p["user_id"] == str(user_id)),
                    None
                )
                
                if user_participation:
                    challenge_summary = {
                        "challenge_id": challenge["id"],
                        "title": challenge["title"],
                        "challenge_type": challenge["challenge_type"],
                        "status": challenge["status"],
                        "start_date": challenge["start_date"],
                        "end_date": challenge["end_date"],
                        "participation": user_participation,
                        "total_participants": len(challenge["participants"])
                    }
                    
                    # Add ranking if challenge is completed
                    if challenge["status"] == ChallengeStatus.COMPLETED.value:
                        leaderboard = challenge.get("final_leaderboard", [])
                        user_rank = next(
                            (entry["rank"] for entry in leaderboard if entry["user_id"] == str(user_id)),
                            None
                        )
                        challenge_summary["final_rank"] = user_rank
                    
                    user_challenges.append(challenge_summary)
            
            # Sort by start date (most recent first)
            user_challenges.sort(
                key=lambda c: datetime.fromisoformat(c["start_date"]),
                reverse=True
            )
            
            return user_challenges[:limit]
            
        except Exception as e:
            logger.error(f"Error getting user challenge history: {str(e)}")
            return []
    
    # Helper methods
    
    def _calculate_seasonal_dates(
        self, 
        challenge_type: str, 
        duration_weeks: int
    ) -> Tuple[datetime, datetime]:
        """Calculate appropriate start and end dates for seasonal challenges."""
        now = datetime.utcnow()
        current_month = now.month
        
        # Determine optimal start date based on challenge type and season
        if challenge_type == ChallengeType.SPRING_AWAKENING.value:
            # Start in early spring (March)
            start_date = datetime(now.year, 3, 1)
            if now.month > 3:
                start_date = datetime(now.year + 1, 3, 1)
        elif challenge_type == ChallengeType.SUMMER_THRIVING.value:
            # Start in early summer (June)
            start_date = datetime(now.year, 6, 1)
            if now.month > 6:
                start_date = datetime(now.year + 1, 6, 1)
        elif challenge_type == ChallengeType.FALL_PREPARATION.value:
            # Start in early fall (September)
            start_date = datetime(now.year, 9, 1)
            if now.month > 9:
                start_date = datetime(now.year + 1, 9, 1)
        elif challenge_type == ChallengeType.WINTER_SURVIVAL.value:
            # Start in early winter (December)
            start_date = datetime(now.year, 12, 1)
            if now.month > 12:
                start_date = datetime(now.year + 1, 12, 1)
        else:
            # Default: start next week
            start_date = now + timedelta(weeks=1)
        
        end_date = start_date + timedelta(weeks=duration_weeks)
        return start_date, end_date
    
    async def _store_challenge(self, db: AsyncSession, challenge: Dict[str, Any]) -> None:
        """Store challenge in database (placeholder implementation)."""
        # In a real implementation, this would create a Challenge model and store it
        pass
    
    async def _get_challenge(self, db: AsyncSession, challenge_id: str) -> Optional[Dict[str, Any]]:
        """Get challenge by ID (placeholder implementation)."""
        # In a real implementation, this would query the Challenge model
        return None
    
    async def _update_challenge(self, db: AsyncSession, challenge: Dict[str, Any]) -> None:
        """Update challenge in database (placeholder implementation)."""
        # In a real implementation, this would update the Challenge model
        pass
    
    async def _get_challenges_by_status(
        self, 
        db: AsyncSession, 
        status: ChallengeStatus
    ) -> List[Dict[str, Any]]:
        """Get challenges by status (placeholder implementation)."""
        # In a real implementation, this would query Challenge models by status
        return []
    
    async def _get_all_challenges(self, db: AsyncSession) -> List[Dict[str, Any]]:
        """Get all challenges (placeholder implementation)."""
        # In a real implementation, this would query all Challenge models
        return []
    
    async def _check_entry_requirements(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any],
        user_id: UUID,
        plant_id: UUID
    ) -> bool:
        """Check if user meets challenge entry requirements."""
        requirements = challenge.get("entry_requirements", [])
        
        for requirement in requirements:
            req_type = requirement.get("type")
            
            if req_type == "plant_age_minimum":
                plant = await db.get(UserPlant, plant_id)
                if plant and plant.acquired_date:
                    age_days = (datetime.utcnow() - plant.acquired_date).days
                    if age_days < requirement.get("value", 0):
                        return False
            
            elif req_type == "species_allowed":
                plant = await db.get(UserPlant, plant_id)
                if plant and plant.species:
                    allowed_species = requirement.get("value", [])
                    if plant.species.scientific_name not in allowed_species:
                        return False
            
            elif req_type == "user_experience_minimum":
                user = await db.get(User, user_id)
                if user:
                    experience_levels = ["beginner", "intermediate", "advanced", "expert"]
                    user_level = experience_levels.index(user.gardening_experience or "beginner")
                    required_level = experience_levels.index(requirement.get("value", "beginner"))
                    if user_level < required_level:
                        return False
        
        return True
    
    async def _check_user_eligibility(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any],
        user_id: UUID
    ) -> bool:
        """Check if user is eligible to join the challenge."""
        # Check if challenge is still accepting participants
        if challenge["status"] != ChallengeStatus.UPCOMING.value:
            return False
        
        # Check max participants limit
        max_participants = challenge.get("max_participants")
        if max_participants and len(challenge["participants"]) >= max_participants:
            return False
        
        # Check if user already participating
        existing_participation = next(
            (p for p in challenge["participants"] if p["user_id"] == str(user_id)),
            None
        )
        if existing_participation:
            return False
        
        return True
    
    async def _initialize_challenge_tracking(
        self,
        db: AsyncSession,
        challenge_id: str,
        user_id: UUID,
        plant_id: UUID
    ) -> None:
        """Initialize tracking systems for challenge participation."""
        # This could initialize time-lapse sessions, care reminders, etc.
        # For time-lapse challenges, start a new session
        # For care consistency challenges, set up monitoring
        pass
    
    async def _calculate_challenge_score(
        self,
        challenge: Dict[str, Any],
        participation: Dict[str, Any],
        progress_data: Dict[str, Any]
    ) -> float:
        """Calculate user's score in the challenge."""
        challenge_type = challenge.get("challenge_type")
        base_score = participation.get("score", 0)
        
        # Different scoring logic based on challenge type
        if challenge_type == ChallengeType.SEASONAL_GROWTH.value:
            growth_rate = progress_data.get("growth_rate", 0)
            consistency = progress_data.get("care_consistency", 0)
            return (growth_rate * 0.7) + (consistency * 0.3)
        
        elif challenge_type == ChallengeType.CARE_CONSISTENCY.value:
            consistency = progress_data.get("care_consistency", 0)
            streak = progress_data.get("care_streak_days", 0)
            return (consistency * 0.6) + (min(streak / 30, 1.0) * 0.4)
        
        elif challenge_type == ChallengeType.TIMELAPSE_SHOWCASE.value:
            video_quality = progress_data.get("video_quality_score", 0)
            engagement = progress_data.get("community_engagement", 0)
            return (video_quality * 0.5) + (engagement * 0.5)
        
        else:
            # Generic scoring
            return sum(progress_data.values()) / len(progress_data) if progress_data else 0
    
    async def _check_challenge_achievements(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any],
        participation: Dict[str, Any],
        progress_data: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Check for new achievements based on progress."""
        achievements = []
        existing_achievements = [a["id"] for a in participation.get("achievements", [])]
        
        # Define achievement criteria
        achievement_criteria = {
            "first_milestone": {
                "title": "First Milestone",
                "description": "Reached your first growth milestone",
                "condition": lambda p: p.get("milestones_reached", 0) >= 1
            },
            "consistency_champion": {
                "title": "Consistency Champion",
                "description": "Maintained perfect care consistency for 7 days",
                "condition": lambda p: p.get("care_streak_days", 0) >= 7
            },
            "growth_guru": {
                "title": "Growth Guru",
                "description": "Achieved exceptional growth rate",
                "condition": lambda p: p.get("growth_rate", 0) >= 0.8
            }
        }
        
        # Check each achievement
        for achievement_id, criteria in achievement_criteria.items():
            if achievement_id not in existing_achievements:
                if criteria["condition"](progress_data):
                    achievements.append({
                        "id": achievement_id,
                        "title": criteria["title"],
                        "description": criteria["description"],
                        "earned_at": datetime.utcnow().isoformat()
                    })
        
        return achievements
    
    async def _update_leaderboard(
        self,
        challenge: Dict[str, Any],
        user_id: UUID,
        new_score: float
    ) -> None:
        """Update challenge leaderboard."""
        # Sort participants by score and update leaderboard
        sorted_participants = sorted(
            challenge["participants"],
            key=lambda p: p.get("score", 0),
            reverse=True
        )
        
        challenge["leaderboard"] = [
            {
                "user_id": p["user_id"],
                "score": p.get("score", 0),
                "rank": i + 1
            }
            for i, p in enumerate(sorted_participants[:10])  # Top 10
        ]
    
    async def _distribute_challenge_rewards(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any],
        final_leaderboard: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Distribute rewards to challenge winners."""
        rewards_distributed = []
        rewards = challenge.get("rewards", [])
        
        for reward in rewards:
            eligible_ranks = reward.get("eligible_ranks", [1])  # Default to winner only
            
            for entry in final_leaderboard:
                if entry["rank"] in eligible_ranks:
                    # Distribute reward (placeholder implementation)
                    reward_record = {
                        "user_id": entry["user_id"],
                        "reward_type": reward.get("type"),
                        "reward_value": reward.get("value"),
                        "rank": entry["rank"],
                        "distributed_at": datetime.utcnow().isoformat()
                    }
                    rewards_distributed.append(reward_record)
        
        return rewards_distributed
    
    async def _notify_challenge_creation(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any]
    ) -> None:
        """Notify users about new challenge creation."""
        # Get active users who might be interested
        # This is a simplified implementation
        pass
    
    async def _notify_challenge_completion(
        self,
        db: AsyncSession,
        challenge: Dict[str, Any],
        final_leaderboard: List[Dict[str, Any]]
    ) -> None:
        """Notify participants about challenge completion."""
        for entry in final_leaderboard:
            user_id = UUID(entry["user_id"])
            
            notification_data = {
                "type": "challenge_completed",
                "title": f"Challenge Complete: {challenge['title']}",
                "description": f"You finished #{entry['rank']} out of {len(final_leaderboard)} participants!",
                "challenge_id": challenge["id"],
                "final_rank": entry["rank"],
                "total_participants": len(final_leaderboard)
            }
            
            await self.notification_service.send_seasonal_challenge_notification(
                db, user_id, notification_data
            )


# Global service instance
community_challenge_service = CommunityChallengeService()


# Convenience functions
async def create_seasonal_challenge(
    db: AsyncSession,
    challenge_data: Dict[str, Any],
    creator_id: Optional[UUID] = None
) -> Dict[str, Any]:
    """Create a new seasonal challenge."""
    return await community_challenge_service.create_seasonal_challenge(
        db, challenge_data, creator_id
    )


async def join_challenge(
    db: AsyncSession,
    challenge_id: str,
    user_id: UUID,
    plant_id: UUID,
    entry_data: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """Join a seasonal challenge."""
    return await community_challenge_service.join_challenge(
        db, challenge_id, user_id, plant_id, entry_data
    )


async def get_active_challenges(
    db: AsyncSession,
    user_id: Optional[UUID] = None,
    challenge_type: Optional[ChallengeType] = None
) -> List[Dict[str, Any]]:
    """Get active challenges."""
    return await community_challenge_service.get_active_challenges(
        db, user_id, challenge_type
    )