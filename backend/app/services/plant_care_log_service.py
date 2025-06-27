"""Plant care log service.

This module provides business logic for managing plant care logs,
including CRUD operations and care statistics.
"""

from datetime import datetime, timedelta
from typing import List, Optional, Dict
from uuid import UUID

from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_care_log import PlantCareLog
from app.models.user_plant import UserPlant
from app.schemas.plant_care_log import PlantCareLogCreate, PlantCareLogUpdate


class PlantCareLogService:
    """Service for managing plant care logs."""
    
    @staticmethod
    async def create_care_log(
        db: AsyncSession,
        user_id: UUID,
        log_data: PlantCareLogCreate
    ) -> Optional[PlantCareLog]:
        """Create a new care log entry.
        
        Args:
            db: Database session
            user_id: User ID (for ownership verification)
            log_data: Care log creation data
            
        Returns:
            Created care log if plant is owned by user, None otherwise
        """
        # Verify plant ownership
        plant_result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == log_data.plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = plant_result.scalar_one_or_none()
        
        if not plant:
            return None
        
        # Create care log
        care_log = PlantCareLog(**log_data.dict())
        db.add(care_log)
        
        # Update plant's last care timestamp
        if log_data.care_type == "watering":
            plant.last_watered = log_data.performed_at or datetime.utcnow()
        elif log_data.care_type == "fertilizing":
            plant.last_fertilized = log_data.performed_at or datetime.utcnow()
        elif log_data.care_type == "repotting":
            plant.last_repotted = log_data.performed_at or datetime.utcnow()
        
        plant.updated_at = datetime.utcnow()
        
        await db.commit()
        await db.refresh(care_log)
        return care_log
    
    @staticmethod
    async def get_care_log_by_id(
        db: AsyncSession,
        log_id: UUID,
        user_id: Optional[UUID] = None
    ) -> Optional[PlantCareLog]:
        """Get care log by ID.
        
        Args:
            db: Database session
            log_id: Care log ID
            user_id: Optional user ID for ownership check
            
        Returns:
            Care log if found and accessible, None otherwise
        """
        query = select(PlantCareLog).options(
            selectinload(PlantCareLog.plant)
        ).where(PlantCareLog.id == log_id)
        
        result = await db.execute(query)
        care_log = result.scalar_one_or_none()
        
        # Check ownership if user_id provided
        if care_log and user_id:
            if care_log.plant.user_id != user_id:
                return None
        
        return care_log
    
    @staticmethod
    async def get_plant_care_logs(
        db: AsyncSession,
        plant_id: UUID,
        user_id: UUID,
        care_type: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        skip: int = 0,
        limit: int = 50
    ) -> tuple[List[PlantCareLog], int]:
        """Get care logs for a specific plant.
        
        Args:
            db: Database session
            plant_id: Plant ID
            user_id: User ID (for ownership verification)
            care_type: Optional care type filter
            start_date: Optional start date filter
            end_date: Optional end date filter
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (care logs list, total count)
        """
        # Verify plant ownership
        plant_result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = plant_result.scalar_one_or_none()
        
        if not plant:
            return [], 0
        
        # Build base query
        base_query = select(PlantCareLog).where(
            PlantCareLog.plant_id == plant_id
        )
        count_query = select(func.count(PlantCareLog.id)).where(
            PlantCareLog.plant_id == plant_id
        )
        
        # Apply filters
        if care_type:
            base_query = base_query.where(PlantCareLog.care_type == care_type)
            count_query = count_query.where(PlantCareLog.care_type == care_type)
        
        if start_date:
            base_query = base_query.where(PlantCareLog.performed_at >= start_date)
            count_query = count_query.where(PlantCareLog.performed_at >= start_date)
        
        if end_date:
            base_query = base_query.where(PlantCareLog.performed_at <= end_date)
            count_query = count_query.where(PlantCareLog.performed_at <= end_date)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(desc(PlantCareLog.performed_at))
            .offset(skip)
            .limit(limit)
        )
        logs = result.scalars().all()
        
        return list(logs), total
    
    @staticmethod
    async def get_user_care_logs(
        db: AsyncSession,
        user_id: UUID,
        care_type: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        skip: int = 0,
        limit: int = 50
    ) -> tuple[List[PlantCareLog], int]:
        """Get care logs for all user's plants.
        
        Args:
            db: Database session
            user_id: User ID
            care_type: Optional care type filter
            start_date: Optional start date filter
            end_date: Optional end date filter
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (care logs list, total count)
        """
        # Build base query with join to user plants
        base_query = select(PlantCareLog).options(
            selectinload(PlantCareLog.plant)
        ).join(UserPlant).where(UserPlant.user_id == user_id)
        
        count_query = select(func.count(PlantCareLog.id)).join(UserPlant).where(
            UserPlant.user_id == user_id
        )
        
        # Apply filters
        if care_type:
            base_query = base_query.where(PlantCareLog.care_type == care_type)
            count_query = count_query.where(PlantCareLog.care_type == care_type)
        
        if start_date:
            base_query = base_query.where(PlantCareLog.performed_at >= start_date)
            count_query = count_query.where(PlantCareLog.performed_at >= start_date)
        
        if end_date:
            base_query = base_query.where(PlantCareLog.performed_at <= end_date)
            count_query = count_query.where(PlantCareLog.performed_at <= end_date)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(desc(PlantCareLog.performed_at))
            .offset(skip)
            .limit(limit)
        )
        logs = result.scalars().all()
        
        return list(logs), total
    
    @staticmethod
    async def update_care_log(
        db: AsyncSession,
        log_id: UUID,
        user_id: UUID,
        log_data: PlantCareLogUpdate
    ) -> Optional[PlantCareLog]:
        """Update care log.
        
        Args:
            db: Database session
            log_id: Care log ID
            user_id: User ID (for ownership verification)
            log_data: Update data
            
        Returns:
            Updated care log if found and owned by user, None otherwise
        """
        # Get care log with plant info
        result = await db.execute(
            select(PlantCareLog).options(
                selectinload(PlantCareLog.plant)
            ).where(PlantCareLog.id == log_id)
        )
        care_log = result.scalar_one_or_none()
        
        if not care_log or care_log.plant.user_id != user_id:
            return None
        
        # Update fields
        update_data = log_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(care_log, field, value)
        
        care_log.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(care_log)
        return care_log
    
    @staticmethod
    async def delete_care_log(
        db: AsyncSession,
        log_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete care log.
        
        Args:
            db: Database session
            log_id: Care log ID
            user_id: User ID (for ownership verification)
            
        Returns:
            True if deleted, False if not found or not owned
        """
        # Get care log with plant info
        result = await db.execute(
            select(PlantCareLog).options(
                selectinload(PlantCareLog.plant)
            ).where(PlantCareLog.id == log_id)
        )
        care_log = result.scalar_one_or_none()
        
        if not care_log or care_log.plant.user_id != user_id:
            return False
        
        await db.delete(care_log)
        await db.commit()
        return True
    
    @staticmethod
    async def get_care_statistics(
        db: AsyncSession,
        user_id: UUID,
        plant_id: Optional[UUID] = None,
        days: int = 30
    ) -> Dict[str, any]:
        """Get care statistics for user's plants.
        
        Args:
            db: Database session
            user_id: User ID
            plant_id: Optional specific plant ID
            days: Number of days to look back
            
        Returns:
            Dictionary with care statistics
        """
        start_date = datetime.utcnow() - timedelta(days=days)
        
        # Build base query
        base_query = select(
            PlantCareLog.care_type,
            func.count(PlantCareLog.id).label('count')
        ).join(UserPlant).where(
            and_(
                UserPlant.user_id == user_id,
                PlantCareLog.performed_at >= start_date
            )
        )
        
        if plant_id:
            base_query = base_query.where(PlantCareLog.plant_id == plant_id)
        
        # Get care type statistics
        result = await db.execute(
            base_query.group_by(PlantCareLog.care_type)
        )
        care_type_stats = {care_type: count for care_type, count in result.all()}
        
        # Get total care activities
        total_result = await db.execute(
            select(func.count(PlantCareLog.id)).join(UserPlant).where(
                and_(
                    UserPlant.user_id == user_id,
                    PlantCareLog.performed_at >= start_date,
                    PlantCareLog.plant_id == plant_id if plant_id else True
                )
            )
        )
        total_activities = total_result.scalar()
        
        # Get most recent activity
        recent_result = await db.execute(
            select(PlantCareLog).options(
                selectinload(PlantCareLog.plant)
            ).join(UserPlant).where(
                and_(
                    UserPlant.user_id == user_id,
                    PlantCareLog.plant_id == plant_id if plant_id else True
                )
            ).order_by(desc(PlantCareLog.performed_at)).limit(1)
        )
        recent_activity = recent_result.scalar_one_or_none()
        
        return {
            "period_days": days,
            "total_activities": total_activities,
            "care_type_breakdown": care_type_stats,
            "most_recent_activity": {
                "care_type": recent_activity.care_type if recent_activity else None,
                "performed_at": recent_activity.performed_at if recent_activity else None,
                "plant_nickname": recent_activity.plant.nickname if recent_activity else None
            } if recent_activity else None,
            "average_activities_per_day": round(total_activities / days, 2) if days > 0 else 0
        }


# Convenience functions for dependency injection
async def create_care_log(
    db: AsyncSession,
    user_id: UUID,
    log_data: PlantCareLogCreate
) -> Optional[PlantCareLog]:
    """Create a new care log entry."""
    return await PlantCareLogService.create_care_log(db, user_id, log_data)


async def get_care_log_by_id(
    db: AsyncSession,
    log_id: UUID,
    user_id: Optional[UUID] = None
) -> Optional[PlantCareLog]:
    """Get care log by ID."""
    return await PlantCareLogService.get_care_log_by_id(db, log_id, user_id)


async def get_plant_care_logs(
    db: AsyncSession,
    plant_id: UUID,
    user_id: UUID,
    care_type: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    skip: int = 0,
    limit: int = 50
) -> tuple[List[PlantCareLog], int]:
    """Get care logs for a specific plant."""
    return await PlantCareLogService.get_plant_care_logs(
        db, plant_id, user_id, care_type, start_date, end_date, skip, limit
    )


async def get_user_care_logs(
    db: AsyncSession,
    user_id: UUID,
    care_type: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    skip: int = 0,
    limit: int = 50
) -> tuple[List[PlantCareLog], int]:
    """Get care logs for all user's plants."""
    return await PlantCareLogService.get_user_care_logs(
        db, user_id, care_type, start_date, end_date, skip, limit
    )


async def get_care_statistics(
    db: AsyncSession,
    user_id: UUID,
    plant_id: Optional[UUID] = None,
    days: int = 30
) -> Dict[str, any]:
    """Get care statistics for user's plants."""
    return await PlantCareLogService.get_care_statistics(db, user_id, plant_id, days)


async def update_care_log(
    db: AsyncSession,
    log_id: UUID,
    user_id: UUID,
    log_data: PlantCareLogUpdate
) -> Optional[PlantCareLog]:
    """Update care log."""
    return await PlantCareLogService.update_care_log(db, log_id, user_id, log_data)


async def delete_care_log(db: AsyncSession, log_id: UUID, user_id: UUID) -> bool:
    """Delete care log."""
    return await PlantCareLogService.delete_care_log(db, log_id, user_id)