"""Enhanced Notification Service for Seasonal AI and Time-lapse Features.

This service handles notifications for seasonal predictions, time-lapse updates,
growth milestones, and community challenges.
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from uuid import UUID
from enum import Enum

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, desc
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.seasonal_ai import SeasonalPrediction
from app.models.timelapse import TimelapseSession, GrowthPhoto
from app.models.friendship import Friendship, FriendshipStatus
from app.core.websocket import websocket_manager

logger = logging.getLogger(__name__)


class NotificationType(str, Enum):
    """Types of notifications."""
    SEASONAL_ALERT = "seasonal_alert"
    CARE_REMINDER = "care_reminder"
    GROWTH_MILESTONE = "growth_milestone"
    TIMELAPSE_READY = "timelapse_ready"
    SEASONAL_CHALLENGE = "seasonal_challenge"
    PLANT_HEALTH_WARNING = "plant_health_warning"
    OPTIMAL_ACTIVITY = "optimal_activity"
    COMMUNITY_ACHIEVEMENT = "community_achievement"


class NotificationPriority(str, Enum):
    """Notification priority levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class SeasonalNotificationService:
    """Service for managing seasonal AI and time-lapse notifications."""
    
    def __init__(self):
        self.connection_manager = websocket_manager
    
    async def send_seasonal_alert(
        self,
        db: AsyncSession,
        user_id: UUID,
        plant_id: UUID,
        alert_type: str,
        alert_data: Dict[str, Any],
        priority: NotificationPriority = NotificationPriority.MEDIUM
    ) -> bool:
        """Send seasonal alert notification to user."""
        try:
            # Get user and plant info
            user = await db.get(User, user_id)
            plant = await db.get(UserPlant, plant_id)
            
            if not user or not plant:
                return False
            
            notification_data = {
                "type": NotificationType.SEASONAL_ALERT,
                "priority": priority.value,
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "plant_nickname": plant.nickname,
                "alert_type": alert_type,
                "alert_data": alert_data,
                "timestamp": datetime.utcnow().isoformat(),
                "title": self._generate_seasonal_alert_title(alert_type, plant.nickname),
                "message": self._generate_seasonal_alert_message(alert_type, alert_data, plant.nickname)
            }
            
            # Send real-time notification
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent seasonal alert to user {user_id} for plant {plant_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending seasonal alert: {str(e)}")
            return False
    
    async def send_growth_milestone_notification(
        self,
        db: AsyncSession,
        user_id: UUID,
        plant_id: UUID,
        milestone_data: Dict[str, Any],
        timelapse_session_id: Optional[UUID] = None
    ) -> bool:
        """Send growth milestone achievement notification."""
        try:
            user = await db.get(User, user_id)
            plant = await db.get(UserPlant, plant_id)
            
            if not user or not plant:
                return False
            
            notification_data = {
                "type": NotificationType.GROWTH_MILESTONE,
                "priority": NotificationPriority.HIGH.value,
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "plant_nickname": plant.nickname,
                "milestone_data": milestone_data,
                "timelapse_session_id": str(timelapse_session_id) if timelapse_session_id else None,
                "timestamp": datetime.utcnow().isoformat(),
                "title": f"🌱 Growth Milestone Achieved!",
                "message": f"{plant.nickname} has reached a new growth milestone: {milestone_data.get('milestone_type', 'Unknown')}"
            }
            
            # Send to user
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            # Also notify friends if it's a significant milestone
            if milestone_data.get("significance", "medium") == "high":
                await self._notify_friends_of_milestone(db, user_id, notification_data)
            
            logger.info(f"Sent growth milestone notification to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending growth milestone notification: {str(e)}")
            return False
    
    async def send_timelapse_ready_notification(
        self,
        db: AsyncSession,
        user_id: UUID,
        timelapse_session_id: UUID,
        video_url: str,
        stats: Dict[str, Any]
    ) -> bool:
        """Send notification when time-lapse video is ready."""
        try:
            user = await db.get(User, user_id)
            session = await db.get(TimelapseSession, timelapse_session_id)
            
            if not user or not session:
                return False
            
            plant = await db.get(UserPlant, session.plant_id)
            
            notification_data = {
                "type": NotificationType.TIMELAPSE_READY,
                "priority": NotificationPriority.HIGH.value,
                "user_id": str(user_id),
                "timelapse_session_id": str(timelapse_session_id),
                "plant_id": str(session.plant_id),
                "plant_nickname": plant.nickname if plant else "Your plant",
                "video_url": video_url,
                "stats": stats,
                "timestamp": datetime.utcnow().isoformat(),
                "title": "🎬 Your Time-lapse is Ready!",
                "message": f"Your growth time-lapse for {plant.nickname if plant else 'your plant'} is ready to view and share!"
            }
            
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent time-lapse ready notification to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending time-lapse ready notification: {str(e)}")
            return False
    
    async def send_seasonal_care_reminder(
        self,
        db: AsyncSession,
        user_id: UUID,
        plant_id: UUID,
        care_recommendations: List[Dict[str, Any]],
        seasonal_context: Dict[str, Any]
    ) -> bool:
        """Send seasonal care reminder with AI recommendations."""
        try:
            user = await db.get(User, user_id)
            plant = await db.get(UserPlant, plant_id)
            
            if not user or not plant:
                return False
            
            # Prioritize recommendations
            high_priority_recs = [r for r in care_recommendations if r.get("priority") == "high"]
            
            notification_data = {
                "type": NotificationType.CARE_REMINDER,
                "priority": NotificationPriority.HIGH.value if high_priority_recs else NotificationPriority.MEDIUM.value,
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "plant_nickname": plant.nickname,
                "care_recommendations": care_recommendations,
                "seasonal_context": seasonal_context,
                "timestamp": datetime.utcnow().isoformat(),
                "title": f"🌿 Seasonal Care Update for {plant.nickname}",
                "message": self._generate_care_reminder_message(care_recommendations, plant.nickname)
            }
            
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent seasonal care reminder to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending seasonal care reminder: {str(e)}")
            return False
    
    async def send_seasonal_challenge_notification(
        self,
        db: AsyncSession,
        user_id: UUID,
        challenge_data: Dict[str, Any]
    ) -> bool:
        """Send seasonal challenge invitation or update."""
        try:
            user = await db.get(User, user_id)
            
            if not user:
                return False
            
            notification_data = {
                "type": NotificationType.SEASONAL_CHALLENGE,
                "priority": NotificationPriority.MEDIUM.value,
                "user_id": str(user_id),
                "challenge_data": challenge_data,
                "timestamp": datetime.utcnow().isoformat(),
                "title": f"🏆 {challenge_data.get('title', 'New Seasonal Challenge')}",
                "message": challenge_data.get('description', 'Join the community in a new seasonal growing challenge!')
            }
            
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent seasonal challenge notification to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending seasonal challenge notification: {str(e)}")
            return False
    
    async def send_plant_health_warning(
        self,
        db: AsyncSession,
        user_id: UUID,
        plant_id: UUID,
        health_prediction: Dict[str, Any],
        recommended_actions: List[str]
    ) -> bool:
        """Send plant health warning based on seasonal AI predictions."""
        try:
            user = await db.get(User, user_id)
            plant = await db.get(UserPlant, plant_id)
            
            if not user or not plant:
                return False
            
            risk_level = health_prediction.get("risk_level", "medium")
            priority = NotificationPriority.URGENT if risk_level == "critical" else NotificationPriority.HIGH
            
            notification_data = {
                "type": NotificationType.PLANT_HEALTH_WARNING,
                "priority": priority.value,
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "plant_nickname": plant.nickname,
                "health_prediction": health_prediction,
                "recommended_actions": recommended_actions,
                "timestamp": datetime.utcnow().isoformat(),
                "title": f"⚠️ Health Alert for {plant.nickname}",
                "message": self._generate_health_warning_message(health_prediction, plant.nickname)
            }
            
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent plant health warning to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending plant health warning: {str(e)}")
            return False
    
    async def send_optimal_activity_notification(
        self,
        db: AsyncSession,
        user_id: UUID,
        plant_id: UUID,
        activity_data: Dict[str, Any]
    ) -> bool:
        """Send notification about optimal timing for plant activities."""
        try:
            user = await db.get(User, user_id)
            plant = await db.get(UserPlant, plant_id)
            
            if not user or not plant:
                return False
            
            notification_data = {
                "type": NotificationType.OPTIMAL_ACTIVITY,
                "priority": NotificationPriority.MEDIUM.value,
                "user_id": str(user_id),
                "plant_id": str(plant_id),
                "plant_nickname": plant.nickname,
                "activity_data": activity_data,
                "timestamp": datetime.utcnow().isoformat(),
                "title": f"🌟 Perfect Time for {activity_data.get('activity_type', 'Plant Care')}",
                "message": f"Now is the optimal time to {activity_data.get('activity_type', 'care for')} {plant.nickname}!"
            }
            
            await self.connection_manager.send_personal_message(
                str(user_id),
                notification_data
            )
            
            logger.info(f"Sent optimal activity notification to user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending optimal activity notification: {str(e)}")
            return False
    
    async def broadcast_seasonal_alerts(
        self,
        db: AsyncSession,
        alert_type: str,
        alert_data: Dict[str, Any],
        location_filter: Optional[str] = None
    ) -> int:
        """Broadcast seasonal alerts to all relevant users."""
        try:
            # Get users to notify (optionally filtered by location)
            query = select(User)
            if location_filter:
                query = query.where(User.location.ilike(f"%{location_filter}%"))
            
            result = await db.execute(query)
            users = result.scalars().all()
            
            notification_count = 0
            for user in users:
                # Get user's plants that might be affected
                plants_result = await db.execute(
                    select(UserPlant).where(UserPlant.user_id == user.id)
                )
                plants = plants_result.scalars().all()
                
                for plant in plants:
                    success = await self.send_seasonal_alert(
                        db, user.id, plant.id, alert_type, alert_data
                    )
                    if success:
                        notification_count += 1
            
            logger.info(f"Broadcast {notification_count} seasonal alerts")
            return notification_count
            
        except Exception as e:
            logger.error(f"Error broadcasting seasonal alerts: {str(e)}")
            return 0
    
    async def _notify_friends_of_milestone(
        self,
        db: AsyncSession,
        user_id: UUID,
        milestone_notification: Dict[str, Any]
    ) -> None:
        """Notify friends about significant growth milestones."""
        try:
            # Get user's friends
            friends_query = select(
                func.case(
                    (Friendship.requester_id == user_id, Friendship.addressee_id),
                    else_=Friendship.requester_id
                ).label("friend_id")
            ).where(
                and_(
                    or_(
                        Friendship.requester_id == user_id,
                        Friendship.addressee_id == user_id
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
            
            result = await db.execute(friends_query)
            friend_ids = [row.friend_id for row in result]
            
            if friend_ids:
                # Modify notification for friends
                friend_notification = milestone_notification.copy()
                friend_notification["type"] = NotificationType.COMMUNITY_ACHIEVEMENT
                friend_notification["title"] = f"🎉 {milestone_notification.get('user_display_name', 'Friend')} achieved a growth milestone!"
                
                await self.connection_manager.broadcast_to_users(
                    [str(fid) for fid in friend_ids],
                    friend_notification
                )
                
        except Exception as e:
            logger.error(f"Error notifying friends of milestone: {str(e)}")
    
    def _generate_seasonal_alert_title(self, alert_type: str, plant_nickname: str) -> str:
        """Generate title for seasonal alert."""
        titles = {
            "winter_dormancy": f"❄️ {plant_nickname} Entering Winter Dormancy",
            "spring_growth": f"🌱 Spring Growth Season for {plant_nickname}",
            "summer_stress": f"☀️ Summer Heat Alert for {plant_nickname}",
            "fall_preparation": f"🍂 Preparing {plant_nickname} for Fall",
            "pest_risk": f"🐛 Pest Risk Alert for {plant_nickname}",
            "optimal_repotting": f"🪴 Perfect Time to Repot {plant_nickname}",
            "fertilizer_season": f"🌿 Fertilizing Season for {plant_nickname}"
        }
        return titles.get(alert_type, f"🌿 Seasonal Update for {plant_nickname}")
    
    def _generate_seasonal_alert_message(
        self, 
        alert_type: str, 
        alert_data: Dict[str, Any], 
        plant_nickname: str
    ) -> str:
        """Generate message for seasonal alert."""
        base_messages = {
            "winter_dormancy": f"{plant_nickname} is entering its dormancy period. Reduce watering and stop fertilizing.",
            "spring_growth": f"{plant_nickname} is ready for its spring growth spurt! Time to resume regular care.",
            "summer_stress": f"High temperatures may stress {plant_nickname}. Ensure adequate humidity and shade.",
            "fall_preparation": f"Help {plant_nickname} prepare for winter by gradually reducing care frequency.",
            "pest_risk": f"Seasonal conditions increase pest risk for {plant_nickname}. Monitor closely.",
            "optimal_repotting": f"Conditions are perfect for repotting {plant_nickname}!",
            "fertilizer_season": f"Begin fertilizing {plant_nickname} for optimal growth."
        }
        
        base_message = base_messages.get(alert_type, f"Seasonal update for {plant_nickname}")
        
        # Add specific recommendations if available
        if alert_data.get("recommendations"):
            recommendations = alert_data["recommendations"][:2]  # Limit to 2 recommendations
            rec_text = " • ".join(recommendations)
            return f"{base_message} Recommendations: {rec_text}"
        
        return base_message
    
    def _generate_care_reminder_message(
        self, 
        care_recommendations: List[Dict[str, Any]], 
        plant_nickname: str
    ) -> str:
        """Generate message for care reminder."""
        if not care_recommendations:
            return f"Check on {plant_nickname} - seasonal care updates available."
        
        high_priority = [r for r in care_recommendations if r.get("priority") == "high"]
        
        if high_priority:
            primary_rec = high_priority[0]
            return f"{plant_nickname} needs attention: {primary_rec.get('message', 'Care required')}"
        else:
            return f"Seasonal care updates available for {plant_nickname}"
    
    def _generate_health_warning_message(
        self, 
        health_prediction: Dict[str, Any], 
        plant_nickname: str
    ) -> str:
        """Generate message for health warning."""
        risk_level = health_prediction.get("risk_level", "medium")
        potential_issues = health_prediction.get("potential_issues", [])
        
        if risk_level == "critical":
            return f"URGENT: {plant_nickname} needs immediate attention!"
        elif risk_level == "high":
            issue_text = potential_issues[0] if potential_issues else "health concerns detected"
            return f"{plant_nickname} shows signs of {issue_text}. Action needed soon."
        else:
            return f"Monitor {plant_nickname} closely - potential health issues detected."


# Global service instance
seasonal_notification_service = SeasonalNotificationService()


# Convenience functions
async def send_seasonal_alert(
    db: AsyncSession,
    user_id: UUID,
    plant_id: UUID,
    alert_type: str,
    alert_data: Dict[str, Any],
    priority: NotificationPriority = NotificationPriority.MEDIUM
) -> bool:
    """Send seasonal alert notification."""
    return await seasonal_notification_service.send_seasonal_alert(
        db, user_id, plant_id, alert_type, alert_data, priority
    )


async def send_growth_milestone_notification(
    db: AsyncSession,
    user_id: UUID,
    plant_id: UUID,
    milestone_data: Dict[str, Any],
    timelapse_session_id: Optional[UUID] = None
) -> bool:
    """Send growth milestone notification."""
    return await seasonal_notification_service.send_growth_milestone_notification(
        db, user_id, plant_id, milestone_data, timelapse_session_id
    )


async def send_timelapse_ready_notification(
    db: AsyncSession,
    user_id: UUID,
    timelapse_session_id: UUID,
    video_url: str,
    stats: Dict[str, Any]
) -> bool:
    """Send time-lapse ready notification."""
    return await seasonal_notification_service.send_timelapse_ready_notification(
        db, user_id, timelapse_session_id, video_url, stats
    )