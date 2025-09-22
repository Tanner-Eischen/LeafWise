"""Story service.

This module provides story management services including
creating, viewing, and managing ephemeral content.
"""

import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, desc, asc
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, status

from app.models.story import Story, StoryView
from app.schemas.story import StoryType, StoryPrivacyLevel
from app.models.user import User
from app.models.friendship import Friendship, FriendshipStatus
from app.models.timelapse import TimelapseSession, GrowthPhoto
from app.models.seasonal_ai import SeasonalPrediction
from app.schemas.story import (
    StoryCreate, StoryUpdate, StoryRead, StoryFeed,
    StoryViewCreate, StoryView, StoryAnalytics, StorySearch
)
from app.core.websocket import websocket_manager


class StoryService:
    """Service for story management operations."""
    
    def __init__(self):
        self.connection_manager = websocket_manager
    
    async def create_story(
        self,
        user_id: str,
        story_data: StoryCreate,
        session: AsyncSession
    ) -> Optional[Story]:
        """Create a new story."""
        # Validate story content
        await self._validate_story_content(story_data)
        
        # Calculate expiration time (24 hours from now)
        expires_at = datetime.utcnow() + timedelta(hours=24)
        
        # Create story
        story = Story(
            user_id=user_id,
            content_type=story_data.content_type,
            media_url=story_data.media_url,
            caption=story_data.caption,
            duration=story_data.duration,
            file_size=story_data.file_size,
            privacy_level=story_data.privacy_level,
            expires_at=expires_at,
            plant_tags=story_data.plant_tags,
            location=story_data.location
        )
        
        session.add(story)
        await session.commit()
        await session.refresh(story)
        
        # Send real-time notification to friends
        await self._notify_friends_of_new_story(story, session)
        
        return story
    
    async def get_story_by_id(
        self,
        story_id: str,
        viewer_id: str,
        session: AsyncSession
    ) -> Optional[StoryRead]:
        """Get story by ID if viewer has access."""
        # Get story with user info
        result = await session.execute(
            select(Story, User).join(User, User.id == Story.user_id).where(
                and_(
                    Story.id == story_id,
                    Story.is_active == True,
                    Story.expires_at > datetime.utcnow()
                )
            )
        )
        story_user = result.first()
        
        if not story_user:
            return None
        
        story, user = story_user
        
        # Check if viewer has access to this story
        if not await self._can_view_story(story, viewer_id, session):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to view this story"
            )
        
        # Check if viewer has already viewed this story
        has_viewed = await self._has_user_viewed_story(story_id, viewer_id, session)
        
        # Get view count
        view_count = await session.scalar(
            select(func.count(StoryView.id)).where(StoryView.story_id == story_id)
        ) or 0
        
        # Convert to StoryRead
        story_read = StoryRead(
            id=str(story.id),
            user_id=str(story.user_id),
            content_type=story.content_type,
            media_url=story.media_url,
            caption=story.caption,
            duration=story.duration,
            file_size=story.file_size,
            privacy_level=story.privacy_level,
            created_at=story.created_at,
            expires_at=story.expires_at,
            plant_tags=story.plant_tags,
            location=story.location,
            user_username=user.username,
            user_display_name=user.display_name,
            user_avatar_url=user.avatar_url,
            view_count=view_count,
            has_viewed=has_viewed
        )
        
        return story_read
    
    async def get_user_stories(
        self,
        user_id: str,
        viewer_id: str,
        session: AsyncSession,
        include_expired: bool = False
    ) -> List[StoryRead]:
        """Get all stories for a specific user."""
        # Build query
        query = select(Story, User).join(User, User.id == Story.user_id).where(
            and_(
                Story.user_id == user_id,
                Story.is_active == True
            )
        )
        
        if not include_expired:
            query = query.where(Story.expires_at > datetime.utcnow())
        
        # Check if viewer can see this user's stories
        if viewer_id != user_id:
            can_view = await self._can_view_user_stories(user_id, viewer_id, session)
            if not can_view:
                return []
        
        query = query.order_by(desc(Story.created_at))
        
        result = await session.execute(query)
        stories_users = result.all()
        
        story_reads = []
        for story, user in stories_users:
            # Check individual story permissions
            if await self._can_view_story(story, viewer_id, session):
                has_viewed = await self._has_user_viewed_story(str(story.id), viewer_id, session)
                view_count = await session.scalar(
                    select(func.count(StoryView.id)).where(StoryView.story_id == str(story.id))
                ) or 0
                
                story_read = StoryRead(
                    id=str(story.id),
                    user_id=str(story.user_id),
                    content_type=story.content_type,
                    media_url=story.media_url,
                    caption=story.caption,
                    duration=story.duration,
                    file_size=story.file_size,
                    privacy_level=story.privacy_level,
                    created_at=story.created_at,
                    expires_at=story.expires_at,
                    plant_tags=story.plant_tags,
                    location=story.location,
                    user_username=user.username,
                    user_display_name=user.display_name,
                    user_avatar_url=user.avatar_url,
                    view_count=view_count,
                    has_viewed=has_viewed
                )
                story_reads.append(story_read)
        
        return story_reads
    
    async def get_stories_feed(
        self,
        user_id: str,
        session: AsyncSession,
        limit: int = 50
    ) -> List[StoryFeed]:
        """Get stories feed for a user (friends' stories)."""
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
        
        friends_result = await session.execute(friends_query)
        friend_ids = [row.friend_id for row in friends_result]
        
        if not friend_ids:
            return []
        
        # Get active stories from friends
        stories_query = (
            select(Story, User)
            .join(User, User.id == Story.user_id)
            .where(
                and_(
                    Story.user_id.in_(friend_ids),
                    Story.is_active == True,
                    Story.expires_at > datetime.utcnow(),
                    or_(
                        Story.privacy_level == StoryPrivacyLevel.FRIENDS,
                        Story.privacy_level == StoryPrivacyLevel.PUBLIC
                    )
                )
            )
            .order_by(desc(Story.created_at))
            .limit(limit)
        )
        
        result = await session.execute(stories_query)
        stories_users = result.all()
        
        # Group stories by user
        user_stories = {}
        for story, user in stories_users:
            user_key = str(user.id)
            if user_key not in user_stories:
                user_stories[user_key] = {
                    "user": user,
                    "stories": []
                }
            user_stories[user_key]["stories"].append(story)
        
        # Convert to StoryFeed format
        story_feeds = []
        for user_key, data in user_stories.items():
            user = data["user"]
            stories = data["stories"]
            
            # Check if user has viewed any stories from this user
            has_unviewed = False
            for story in stories:
                if not await self._has_user_viewed_story(str(story.id), user_id, session):
                    has_unviewed = True
                    break
            
            story_feed = StoryFeed(
                user_id=str(user.id),
                user_username=user.username,
                user_display_name=user.display_name,
                user_avatar_url=user.avatar_url,
                stories_count=len(stories),
                latest_story_timestamp=max(story.created_at for story in stories),
                has_unviewed_stories=has_unviewed
            )
            story_feeds.append(story_feed)
        
        # Sort by latest story timestamp
        story_feeds.sort(key=lambda x: x.latest_story_timestamp, reverse=True)
        
        return story_feeds
    
    async def view_story(
        self,
        story_id: str,
        viewer_id: str,
        session: AsyncSession
    ) -> bool:
        """Mark a story as viewed by a user."""
        # Check if story exists and is accessible
        story_read = await self.get_story_by_id(story_id, viewer_id, session)
        if not story_read:
            return False
        
        # Check if already viewed
        if await self._has_user_viewed_story(story_id, viewer_id, session):
            return True  # Already viewed
        
        # Create story view record
        story_view = StoryView(
            story_id=story_id,
            viewer_id=viewer_id
        )
        
        session.add(story_view)
        await session.commit()
        
        # Send view notification to story owner (if not viewing own story)
        if story_read.user_id != viewer_id:
            await self._send_story_view_notification(story_read, viewer_id, session)
        
        return True
    
    async def delete_story(
        self,
        story_id: str,
        user_id: str,
        session: AsyncSession
    ) -> bool:
        """Delete a story (only by owner)."""
        story = await session.execute(
            select(Story).where(
                and_(
                    Story.id == story_id,
                    Story.user_id == user_id
                )
            )
        )
        story = story.scalar_one_or_none()
        
        if not story:
            return False
        
        # Soft delete
        story.is_active = False
        story.updated_at = datetime.utcnow()
        
        await session.commit()
        return True
    
    async def get_story_analytics(
        self,
        story_id: str,
        user_id: str,
        session: AsyncSession
    ) -> Optional[StoryAnalytics]:
        """Get analytics for a story (only for owner)."""
        # Verify ownership
        story = await session.execute(
            select(Story).where(
                and_(
                    Story.id == story_id,
                    Story.user_id == user_id
                )
            )
        )
        story = story.scalar_one_or_none()
        
        if not story:
            return None
        
        # Get view analytics
        total_views = await session.scalar(
            select(func.count(StoryView.id)).where(StoryView.story_id == story_id)
        ) or 0
        
        unique_viewers = await session.scalar(
            select(func.count(func.distinct(StoryView.viewer_id))).where(
                StoryView.story_id == story_id
            )
        ) or 0
        
        # Get viewers list (recent viewers)
        recent_viewers_query = (
            select(StoryView, User)
            .join(User, User.id == StoryView.viewer_id)
            .where(StoryView.story_id == story_id)
            .order_by(desc(StoryView.viewed_at))
            .limit(10)
        )
        
        result = await session.execute(recent_viewers_query)
        recent_viewers = []
        for view, user in result:
            recent_viewers.append({
                "user_id": str(user.id),
                "username": user.username,
                "display_name": user.display_name,
                "avatar_url": user.avatar_url,
                "viewed_at": view.viewed_at
            })
        
        return StoryAnalytics(
            story_id=story_id,
            total_views=total_views,
            unique_viewers=unique_viewers,
            recent_viewers=recent_viewers,
            created_at=story.created_at,
            expires_at=story.expires_at
        )
    
    async def search_stories(
        self,
        user_id: str,
        search_params: StorySearch,
        session: AsyncSession
    ) -> List[StoryRead]:
        """Search stories accessible to the user."""
        # Get user's friends for privacy filtering
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
        
        friends_result = await session.execute(friends_query)
        friend_ids = [row.friend_id for row in friends_result]
        friend_ids.append(user_id)  # Include own stories
        
        # Build search query
        query = select(Story, User).join(User, User.id == Story.user_id).where(
            and_(
                Story.is_active == True,
                Story.expires_at > datetime.utcnow(),
                or_(
                    Story.privacy_level == StoryPrivacyLevel.PUBLIC,
                    and_(
                        Story.privacy_level == StoryPrivacyLevel.FRIENDS,
                        Story.user_id.in_(friend_ids)
                    ),
                    Story.user_id == user_id  # Own stories
                )
            )
        )
        
        # Apply search filters
        if search_params.query:
            query = query.where(
                or_(
                    Story.caption.ilike(f"%{search_params.query}%"),
                    Story.plant_tags.ilike(f"%{search_params.query}%")
                )
            )
        
        if search_params.content_type:
            query = query.where(Story.content_type == search_params.content_type)
        
        if search_params.user_id:
            query = query.where(Story.user_id == search_params.user_id)
        
        if search_params.start_date:
            query = query.where(Story.created_at >= search_params.start_date)
        
        if search_params.end_date:
            query = query.where(Story.created_at <= search_params.end_date)
        
        # Add ordering and limit
        query = query.order_by(desc(Story.created_at)).limit(50)
        
        result = await session.execute(query)
        stories_users = result.all()
        
        # Convert to StoryRead format
        story_reads = []
        for story, user in stories_users:
            has_viewed = await self._has_user_viewed_story(str(story.id), user_id, session)
            view_count = await session.scalar(
                select(func.count(StoryView.id)).where(StoryView.story_id == str(story.id))
            ) or 0
            
            story_read = StoryRead(
                id=str(story.id),
                user_id=str(story.user_id),
                content_type=story.content_type,
                media_url=story.media_url,
                caption=story.caption,
                duration=story.duration,
                file_size=story.file_size,
                privacy_level=story.privacy_level,
                created_at=story.created_at,
                expires_at=story.expires_at,
                plant_tags=story.plant_tags,
                location=story.location,
                user_username=user.username,
                user_display_name=user.display_name,
                user_avatar_url=user.avatar_url,
                view_count=view_count,
                has_viewed=has_viewed
            )
            story_reads.append(story_read)
        
        return story_reads
    
    async def cleanup_expired_stories(self, session: AsyncSession) -> int:
        """Clean up expired stories (background task)."""
        result = await session.execute(
            select(Story).where(
                and_(
                    Story.is_active == True,
                    Story.expires_at <= datetime.utcnow()
                )
            )
        )
        expired_stories = result.scalars().all()
        
        count = 0
        for story in expired_stories:
            story.is_active = False
            story.updated_at = datetime.utcnow()
            count += 1
        
        if count > 0:
            await session.commit()
        
        return count
    
    async def create_timelapse_story(
        self,
        user_id: str,
        timelapse_session_id: str,
        story_data: StoryCreate,
        session: AsyncSession
    ) -> Optional[Story]:
        """Create a story from a time-lapse video with enhanced metadata."""
        # Get the time-lapse session
        timelapse_session = await session.execute(
            select(TimelapseSession).options(
                selectinload(TimelapseSession.plant),
                selectinload(TimelapseSession.growth_photos)
            ).where(TimelapseSession.id == timelapse_session_id)
        )
        timelapse = timelapse_session.scalar_one_or_none()
        
        if not timelapse or str(timelapse.user_id) != user_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Time-lapse session not found"
            )
        
        # Enhance story data with time-lapse metadata
        enhanced_story_data = story_data.copy()
        enhanced_story_data.content_type = StoryType.TIMELAPSE_VIDEO
        
        # Add time-lapse specific metadata
        timelapse_metadata = {
            "timelapse_session_id": str(timelapse.id),
            "plant_id": str(timelapse.plant_id),
            "plant_nickname": timelapse.plant.nickname,
            "tracking_duration_days": (timelapse.end_date - timelapse.start_date).days if timelapse.end_date else None,
            "photo_count": len(timelapse.growth_photos),
            "growth_milestones": []
        }
        
        # Add growth milestones if available
        if timelapse.growth_photos:
            for photo in timelapse.growth_photos:
                if photo.growth_analysis and photo.growth_analysis.get("milestones"):
                    timelapse_metadata["growth_milestones"].extend(
                        photo.growth_analysis["milestones"]
                    )
        
        # Create the story with enhanced metadata
        story = Story(
            user_id=user_id,
            content_type=enhanced_story_data.content_type,
            media_url=enhanced_story_data.media_url,
            caption=enhanced_story_data.caption or f"Growth journey of {timelapse.plant.nickname}",
            duration=enhanced_story_data.duration,
            file_size=enhanced_story_data.file_size,
            privacy_level=enhanced_story_data.privacy_level,
            expires_at=datetime.utcnow() + timedelta(hours=48),  # Longer expiry for time-lapse
            plant_tags=enhanced_story_data.plant_tags,
            location=enhanced_story_data.location,
            metadata=timelapse_metadata
        )
        
        session.add(story)
        await session.commit()
        await session.refresh(story)
        
        # Send enhanced notification for time-lapse stories
        await self._notify_friends_of_timelapse_story(story, timelapse, session)
        
        return story
    
    async def create_seasonal_prediction_story(
        self,
        user_id: str,
        plant_id: str,
        prediction_data: Dict[str, Any],
        story_data: StoryCreate,
        session: AsyncSession
    ) -> Optional[Story]:
        """Create a story showcasing seasonal predictions."""
        # Get the plant and latest prediction
        plant_result = await session.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = plant_result.scalar_one_or_none()
        
        if not plant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Plant not found"
            )
        
        # Create story with seasonal prediction metadata
        seasonal_metadata = {
            "plant_id": str(plant.id),
            "plant_nickname": plant.nickname,
            "prediction_type": "seasonal_forecast",
            "prediction_data": prediction_data,
            "generated_at": datetime.utcnow().isoformat()
        }
        
        story = Story(
            user_id=user_id,
            content_type=StoryType.SEASONAL_PREDICTION,
            media_url=story_data.media_url,
            caption=story_data.caption or f"Seasonal forecast for {plant.nickname}",
            duration=story_data.duration,
            file_size=story_data.file_size,
            privacy_level=story_data.privacy_level,
            expires_at=datetime.utcnow() + timedelta(hours=24),
            plant_tags=f"{plant.species.common_names[0] if plant.species else 'plant'},seasonal,prediction",
            location=story_data.location,
            metadata=seasonal_metadata
        )
        
        session.add(story)
        await session.commit()
        await session.refresh(story)
        
        # Send notification
        await self._notify_friends_of_new_story(story, session)
        
        return story
    
    async def get_timelapse_stories_feed(
        self,
        user_id: str,
        session: AsyncSession,
        limit: int = 20
    ) -> List[StoryRead]:
        """Get feed of time-lapse stories from friends."""
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
        
        friends_result = await session.execute(friends_query)
        friend_ids = [row.friend_id for row in friends_result]
        friend_ids.append(user_id)  # Include own stories
        
        # Get time-lapse stories
        stories_query = (
            select(Story, User)
            .join(User, User.id == Story.user_id)
            .where(
                and_(
                    Story.user_id.in_(friend_ids),
                    Story.is_active == True,
                    Story.expires_at > datetime.utcnow(),
                    Story.content_type == StoryType.TIMELAPSE_VIDEO
                )
            )
            .order_by(desc(Story.created_at))
            .limit(limit)
        )
        
        result = await session.execute(stories_query)
        stories_users = result.all()
        
        # Convert to StoryRead format
        story_reads = []
        for story, user in stories_users:
            has_viewed = await self._has_user_viewed_story(str(story.id), user_id, session)
            view_count = await session.scalar(
                select(func.count(StoryView.id)).where(StoryView.story_id == str(story.id))
            ) or 0
            
            story_read = StoryRead(
                id=str(story.id),
                user_id=str(story.user_id),
                content_type=story.content_type,
                media_url=story.media_url,
                caption=story.caption,
                duration=story.duration,
                file_size=story.file_size,
                privacy_level=story.privacy_level,
                created_at=story.created_at,
                expires_at=story.expires_at,
                plant_tags=story.plant_tags,
                location=story.location,
                user_username=user.username,
                user_display_name=user.display_name,
                user_avatar_url=user.avatar_url,
                view_count=view_count,
                has_viewed=has_viewed,
                metadata=story.metadata
            )
            story_reads.append(story_read)
        
        return story_reads
    
    async def _validate_story_content(self, story_data: StoryCreate):
        """Validate story content."""
        if story_data.content_type in [StoryType.IMAGE, StoryType.VIDEO]:
            if not story_data.media_url:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"{story_data.content_type.value} stories must have media_url"
                )
        
        if story_data.duration and story_data.duration > 60:  # Max 60 seconds
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Story duration cannot exceed 60 seconds"
            )
    
    async def _can_view_story(
        self,
        story: Story,
        viewer_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if viewer can access this story."""
        # Owner can always view
        if str(story.user_id) == viewer_id:
            return True
        
        # Public stories
        if story.privacy_level == StoryPrivacyLevel.PUBLIC:
            return True
        
        # Friends only stories
        if story.privacy_level == StoryPrivacyLevel.FRIENDS:
            return await self._are_users_friends(str(story.user_id), viewer_id, session)
        
        # Close friends stories
        if story.privacy_level == StoryPrivacyLevel.CLOSE_FRIENDS:
            return await self._are_close_friends(str(story.user_id), viewer_id, session)
        
        return False
    
    async def _can_view_user_stories(
        self,
        user_id: str,
        viewer_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if viewer can see user's stories in general."""
        if user_id == viewer_id:
            return True
        
        # Check if they are friends
        return await self._are_users_friends(user_id, viewer_id, session)
    
    async def _are_users_friends(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if two users are friends."""
        result = await session.execute(
            select(Friendship).where(
                and_(
                    or_(
                        and_(
                            Friendship.requester_id == user1_id,
                            Friendship.addressee_id == user2_id
                        ),
                        and_(
                            Friendship.requester_id == user2_id,
                            Friendship.addressee_id == user1_id
                        )
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED
                )
            )
        )
        return result.scalar_one_or_none() is not None
    
    async def _are_close_friends(
        self,
        user1_id: str,
        user2_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if two users are close friends."""
        result = await session.execute(
            select(Friendship).where(
                and_(
                    or_(
                        and_(
                            Friendship.requester_id == user1_id,
                            Friendship.addressee_id == user2_id
                        ),
                        and_(
                            Friendship.requester_id == user2_id,
                            Friendship.addressee_id == user1_id
                        )
                    ),
                    Friendship.status == FriendshipStatus.ACCEPTED,
                    Friendship.is_close_friend == True
                )
            )
        )
        return result.scalar_one_or_none() is not None
    
    async def _has_user_viewed_story(
        self,
        story_id: str,
        viewer_id: str,
        session: AsyncSession
    ) -> bool:
        """Check if user has viewed a story."""
        result = await session.execute(
            select(StoryView).where(
                and_(
                    StoryView.story_id == story_id,
                    StoryView.viewer_id == viewer_id
                )
            )
        )
        return result.scalar_one_or_none() is not None
    
    async def _notify_friends_of_new_story(self, story: Story, session: AsyncSession):
        """Send notifications to friends about new story."""
        # Get friends based on privacy level
        if story.privacy_level == StoryPrivacyLevel.PUBLIC:
            # For public stories, we might not notify everyone
            # This could be a setting or limited to close friends
            return
        
        friends_query = select(
            func.case(
                (Friendship.requester_id == str(story.user_id), Friendship.addressee_id),
                else_=Friendship.requester_id
            ).label("friend_id")
        ).where(
            and_(
                or_(
                    Friendship.requester_id == str(story.user_id),
                    Friendship.addressee_id == str(story.user_id)
                ),
                Friendship.status == FriendshipStatus.ACCEPTED
            )
        )
        
        if story.privacy_level == StoryPrivacyLevel.CLOSE_FRIENDS:
            friends_query = friends_query.where(Friendship.is_close_friend == True)
        
        result = await session.execute(friends_query)
        friend_ids = [row.friend_id for row in result]
        
        # Get story owner info
        owner = await session.get(User, story.user_id)
        
        if owner and friend_ids:
            notification_data = {
                "type": "new_story",
                "story_id": str(story.id),
                "user_id": str(story.user_id),
                "username": owner.username,
                "display_name": owner.display_name,
                "content_type": story.content_type.value,
                "timestamp": story.created_at.isoformat()
            }
            
            # Send to all friends
            await self.connection_manager.broadcast_to_users(
                friend_ids,
                notification_data
            )
    
    async def _send_story_view_notification(
        self,
        story: StoryRead,
        viewer_id: str,
        session: AsyncSession
    ):
        """Send notification to story owner about view."""
        viewer = await session.get(User, viewer_id)
        
        if viewer:
            notification_data = {
                "type": "story_viewed",
                "story_id": story.id,
                "viewer_id": str(viewer.id),
                "viewer_username": viewer.username,
                "viewer_display_name": viewer.display_name,
                "timestamp": datetime.utcnow().isoformat()
            }
            
            await self.connection_manager.send_personal_message(
                story.user_id,
                notification_data
            )
    
    async def _notify_friends_of_timelapse_story(
        self, 
        story: Story, 
        timelapse: TimelapseSession, 
        session: AsyncSession
    ):
        """Send enhanced notifications for time-lapse stories."""
        # Get friends
        friends_query = select(
            func.case(
                (Friendship.requester_id == str(story.user_id), Friendship.addressee_id),
                else_=Friendship.requester_id
            ).label("friend_id")
        ).where(
            and_(
                or_(
                    Friendship.requester_id == str(story.user_id),
                    Friendship.addressee_id == str(story.user_id)
                ),
                Friendship.status == FriendshipStatus.ACCEPTED
            )
        )
        
        result = await session.execute(friends_query)
        friend_ids = [row.friend_id for row in result]
        
        # Get story owner info
        owner = await session.get(User, story.user_id)
        
        if owner and friend_ids:
            notification_data = {
                "type": "new_timelapse_story",
                "story_id": str(story.id),
                "user_id": str(story.user_id),
                "username": owner.username,
                "display_name": owner.display_name,
                "plant_nickname": timelapse.plant.nickname,
                "tracking_duration_days": story.metadata.get("tracking_duration_days"),
                "photo_count": story.metadata.get("photo_count"),
                "growth_milestones": len(story.metadata.get("growth_milestones", [])),
                "timestamp": story.created_at.isoformat()
            }
            
            # Send to all friends
            await self.connection_manager.broadcast_to_users(
                friend_ids,
                notification_data
            )


# Global story service instance
story_service = StoryService()


# Convenience functions for backward compatibility
async def create_story(
    user_id: str,
    story_data: StoryCreate,
    session: AsyncSession
) -> Optional[Story]:
    """Create a new story."""
    return await story_service.create_story(user_id, story_data, session)


async def get_user_stories(
    user_id: str,
    session: AsyncSession,
    limit: int = 50,
    offset: int = 0
) -> List[StoryRead]:
    """Get user's stories."""
    return await story_service.get_user_stories(user_id, session, limit, offset)


async def get_friends_stories(
    user_id: str,
    session: AsyncSession,
    limit: int = 50,
    offset: int = 0
) -> StoryFeed:
    """Get friends' stories."""
    return await story_service.get_friends_stories(user_id, session, limit, offset)


async def get_story_by_id(
    story_id: str,
    user_id: str,
    session: AsyncSession
) -> Optional[StoryRead]:
    """Get a story by ID."""
    return await story_service.get_story_by_id(story_id, user_id, session)


async def view_story(
    story_id: str,
    viewer_id: str,
    session: AsyncSession
) -> bool:
    """View a story."""
    return await story_service.view_story(story_id, viewer_id, session)


async def delete_story(
    story_id: str,
    user_id: str,
    session: AsyncSession
) -> bool:
    """Delete a story."""
    return await story_service.delete_story(story_id, user_id, session)


async def get_story_views(
    story_id: str,
    user_id: str,
    session: AsyncSession
) -> List[StoryView]:
    """Get story views."""
    return await story_service.get_story_views(story_id, user_id, session)


async def get_story_service():
    """Get story service dependency."""
    return story_service