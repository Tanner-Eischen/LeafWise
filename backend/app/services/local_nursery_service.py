"""Local nursery service.

This module provides business logic for local nursery and garden center operations.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID
import math

from sqlalchemy import select, func, desc, and_, or_, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.local_nursery import LocalNursery, NurseryReview, NurseryEvent, UserNurseryFavorite
from app.schemas.nursery import LocalNurseryCreate, NurseryReviewCreate, NurserySearchFilters


class LocalNurseryService:
    """Service for managing local nurseries and garden centers."""
    
    @staticmethod
    async def search_nurseries(
        db: AsyncSession,
        filters: NurserySearchFilters,
        limit: int = 20,
        offset: int = 0
    ) -> List[LocalNursery]:
        """Search for nurseries based on location and filters."""
        query = select(LocalNursery).where(LocalNursery.is_active == True)
        
        # Add location-based filtering if coordinates provided
        if filters.latitude and filters.longitude:
            # Use Haversine formula for distance calculation
            distance_query = func.acos(
                func.cos(func.radians(filters.latitude)) *
                func.cos(func.radians(LocalNursery.latitude)) *
                func.cos(func.radians(LocalNursery.longitude) - func.radians(filters.longitude)) +
                func.sin(func.radians(filters.latitude)) *
                func.sin(func.radians(LocalNursery.latitude))
            ) * 6371  # Earth's radius in km
            
            query = query.where(distance_query <= filters.radius_km)
        
        # Add business type filter
        if filters.business_type:
            query = query.where(LocalNursery.business_type == filters.business_type)
        
        # Add specialties filter
        if filters.specialties:
            # Check if any of the specialties match
            specialty_conditions = []
            for specialty in filters.specialties:
                specialty_conditions.append(
                    LocalNursery.specialties.op('@>')([specialty])
                )
            query = query.where(or_(*specialty_conditions))
        
        # Order by rating and distance
        query = query.order_by(desc(LocalNursery.average_rating))
        
        result = await db.execute(query.limit(limit).offset(offset))
        return result.scalars().all()
    
    @staticmethod
    async def get_nursery_by_id(
        db: AsyncSession,
        nursery_id: UUID
    ) -> Optional[LocalNursery]:
        """Get nursery by ID."""
        result = await db.execute(
            select(LocalNursery).where(LocalNursery.id == nursery_id)
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def create_nursery(
        db: AsyncSession,
        nursery_data: LocalNurseryCreate
    ) -> LocalNursery:
        """Create a new nursery."""
        nursery = LocalNursery(**nursery_data.model_dump())
        db.add(nursery)
        await db.commit()
        await db.refresh(nursery)
        return nursery
    
    @staticmethod
    async def get_nursery_reviews(
        db: AsyncSession,
        nursery_id: UUID,
        limit: int = 20,
        offset: int = 0
    ) -> List[NurseryReview]:
        """Get reviews for a nursery."""
        result = await db.execute(
            select(NurseryReview).options(
                selectinload(NurseryReview.user)
            ).where(
                and_(
                    NurseryReview.nursery_id == nursery_id,
                    NurseryReview.is_active == True
                )
            ).order_by(desc(NurseryReview.created_at)).limit(limit).offset(offset)
        )
        return result.scalars().all()
    
    @staticmethod
    async def create_review(
        db: AsyncSession,
        nursery_id: UUID,
        user_id: UUID,
        review_data: NurseryReviewCreate
    ) -> NurseryReview:
        """Create a new nursery review."""
        review = NurseryReview(
            nursery_id=nursery_id,
            user_id=user_id,
            **review_data.model_dump()
        )
        db.add(review)
        
        # Update nursery rating
        await LocalNurseryService._update_nursery_rating(db, nursery_id)
        
        await db.commit()
        await db.refresh(review, ['user'])
        return review
    
    @staticmethod
    async def _update_nursery_rating(
        db: AsyncSession,
        nursery_id: UUID
    ):
        """Update the average rating for a nursery."""
        result = await db.execute(
            select(
                func.avg(NurseryReview.rating).label('avg_rating'),
                func.count(NurseryReview.id).label('total_reviews')
            ).where(
                and_(
                    NurseryReview.nursery_id == nursery_id,
                    NurseryReview.is_active == True
                )
            )
        )
        
        stats = result.first()
        if stats:
            # Update nursery with new stats
            nursery_result = await db.execute(
                select(LocalNursery).where(LocalNursery.id == nursery_id)
            )
            nursery = nursery_result.scalar_one_or_none()
            
            if nursery:
                nursery.average_rating = float(stats.avg_rating or 0.0)
                nursery.total_reviews = int(stats.total_reviews or 0)
    
    @staticmethod
    async def get_nursery_events(
        db: AsyncSession,
        nursery_id: UUID,
        upcoming_only: bool = True,
        limit: int = 20,
        offset: int = 0
    ) -> List[NurseryEvent]:
        """Get events for a nursery."""
        query = select(NurseryEvent).where(
            and_(
                NurseryEvent.nursery_id == nursery_id,
                NurseryEvent.is_active == True,
                NurseryEvent.is_cancelled == False
            )
        )
        
        if upcoming_only:
            query = query.where(NurseryEvent.start_date >= datetime.utcnow())
        
        query = query.order_by(NurseryEvent.start_date)
        
        result = await db.execute(query.limit(limit).offset(offset))
        return result.scalars().all()
    
    @staticmethod
    async def toggle_favorite(
        db: AsyncSession,
        user_id: UUID,
        nursery_id: UUID
    ) -> bool:
        """Toggle nursery favorite status for user."""
        # Check if already favorited
        result = await db.execute(
            select(UserNurseryFavorite).where(
                and_(
                    UserNurseryFavorite.user_id == user_id,
                    UserNurseryFavorite.nursery_id == nursery_id
                )
            )
        )
        existing_favorite = result.scalar_one_or_none()
        
        if existing_favorite:
            # Remove from favorites
            await db.delete(existing_favorite)
            await db.commit()
            return False
        else:
            # Add to favorites
            favorite = UserNurseryFavorite(
                user_id=user_id,
                nursery_id=nursery_id
            )
            db.add(favorite)
            await db.commit()
            return True
    
    @staticmethod
    async def get_user_favorites(
        db: AsyncSession,
        user_id: UUID
    ) -> List[LocalNursery]:
        """Get user's favorite nurseries."""
        result = await db.execute(
            select(LocalNursery).join(UserNurseryFavorite).where(
                UserNurseryFavorite.user_id == user_id
            ).order_by(UserNurseryFavorite.created_at)
        )
        return result.scalars().all()
    
    @staticmethod
    async def get_nearby_events(
        db: AsyncSession,
        latitude: Optional[float],
        longitude: Optional[float],
        radius_km: float = 50,
        event_type: Optional[str] = None,
        limit: int = 20,
        offset: int = 0
    ) -> List[NurseryEvent]:
        """Get nearby nursery events."""
        query = select(NurseryEvent).options(
            selectinload(NurseryEvent.nursery)
        ).join(LocalNursery).where(
            and_(
                NurseryEvent.is_active == True,
                NurseryEvent.is_cancelled == False,
                NurseryEvent.start_date >= datetime.utcnow(),
                LocalNursery.is_active == True
            )
        )
        
        # Add location filter if coordinates provided
        if latitude and longitude:
            distance_query = func.acos(
                func.cos(func.radians(latitude)) *
                func.cos(func.radians(LocalNursery.latitude)) *
                func.cos(func.radians(LocalNursery.longitude) - func.radians(longitude)) +
                func.sin(func.radians(latitude)) *
                func.sin(func.radians(LocalNursery.latitude))
            ) * 6371
            
            query = query.where(distance_query <= radius_km)
        
        # Add event type filter
        if event_type:
            query = query.where(NurseryEvent.event_type == event_type)
        
        query = query.order_by(NurseryEvent.start_date)
        
        result = await db.execute(query.limit(limit).offset(offset))
        return result.scalars().all() 