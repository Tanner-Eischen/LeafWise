"""Plant care log service.

This module provides business logic for managing plant care logs,
including CRUD operations and care statistics.
Enhanced with seasonal AI integration for predictive care recommendations.
"""

from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from uuid import UUID

from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_care_log import PlantCareLog
from app.models.user_plant import UserPlant
from app.models.seasonal_ai import SeasonalPrediction
from app.models.timelapse import TimelapseSession
from app.models.growth_photo import GrowthPhoto
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
    
    @staticmethod
    async def create_care_log_with_seasonal_integration(
        db: AsyncSession,
        user_id: UUID,
        log_data: PlantCareLogCreate
    ) -> Optional[PlantCareLog]:
        """Create care log with seasonal AI integration and time-lapse tracking.
        
        Enhanced version that integrates with seasonal predictions and time-lapse sessions.
        """
        # Create the basic care log
        care_log = await PlantCareLogService.create_care_log(db, user_id, log_data)
        
        if not care_log:
            return None
        
        try:
            # Update seasonal predictions based on new care data
            await PlantCareLogService._update_seasonal_predictions_from_care(
                db, care_log.plant_id, care_log
            )
            
            # Check if this care event affects any active time-lapse sessions
            await PlantCareLogService._update_timelapse_sessions_from_care(
                db, care_log.plant_id, care_log
            )
            
            # Trigger growth milestone check if this is a significant care event
            if log_data.care_type in ["repotting", "fertilizing", "pruning"]:
                await PlantCareLogService._check_growth_milestones_from_care(
                    db, care_log.plant_id, care_log
                )
            
        except Exception as e:
            # Log error but don't fail the care log creation
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in seasonal integration for care log {care_log.id}: {str(e)}")
        
        return care_log
    
    @staticmethod
    async def get_seasonal_care_recommendations(
        db: AsyncSession,
        plant_id: UUID,
        user_id: UUID
    ) -> Dict[str, Any]:
        """Get seasonal care recommendations based on current predictions and care history."""
        try:
            # Get latest seasonal prediction for the plant
            prediction_result = await db.execute(
                select(SeasonalPrediction)
                .where(SeasonalPrediction.plant_id == plant_id)
                .order_by(desc(SeasonalPrediction.created_at))
                .limit(1)
            )
            latest_prediction = prediction_result.scalar_one_or_none()
            
            if not latest_prediction:
                return {"recommendations": [], "message": "No seasonal predictions available"}
            
            # Get recent care history
            recent_logs, _ = await PlantCareLogService.get_plant_care_logs(
                db, plant_id, user_id, start_date=datetime.utcnow() - timedelta(days=30)
            )
            
            # Analyze care patterns vs seasonal recommendations
            recommendations = []
            
            # Check watering frequency against seasonal adjustments
            watering_logs = [log for log in recent_logs if log.care_type == "watering"]
            if watering_logs and latest_prediction.care_adjustments:
                watering_adjustments = [
                    adj for adj in latest_prediction.care_adjustments 
                    if adj.get("care_type") == "watering"
                ]
                
                if watering_adjustments:
                    last_watering = max(watering_logs, key=lambda x: x.performed_at)
                    days_since_watering = (datetime.utcnow() - last_watering.performed_at).days
                    
                    recommended_frequency = watering_adjustments[0].get("recommended_frequency", 7)
                    
                    if days_since_watering >= recommended_frequency:
                        recommendations.append({
                            "type": "watering",
                            "priority": "high",
                            "message": f"Plant needs watering (last watered {days_since_watering} days ago)",
                            "seasonal_context": watering_adjustments[0].get("reason", "")
                        })
            
            # Check for seasonal activities
            if latest_prediction.optimal_activities:
                current_date = datetime.utcnow().date()
                for activity in latest_prediction.optimal_activities:
                    activity_date = activity.get("optimal_date")
                    if activity_date and isinstance(activity_date, str):
                        activity_date = datetime.fromisoformat(activity_date).date()
                    
                    if activity_date and abs((activity_date - current_date).days) <= 7:
                        recommendations.append({
                            "type": "seasonal_activity",
                            "priority": activity.get("priority", "medium"),
                            "message": f"Optimal time for {activity.get('activity_type', 'plant care')}",
                            "activity": activity
                        })
            
            return {
                "recommendations": recommendations,
                "prediction_date": latest_prediction.created_at.isoformat(),
                "confidence_score": latest_prediction.confidence_score
            }
            
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error getting seasonal recommendations: {str(e)}")
            return {"recommendations": [], "error": str(e)}
    
    @staticmethod
    async def _update_seasonal_predictions_from_care(
        db: AsyncSession,
        plant_id: UUID,
        care_log: PlantCareLog
    ) -> None:
        """Update seasonal predictions based on new care data."""
        # This would trigger a re-evaluation of seasonal predictions
        # For now, we'll just update the prediction metadata
        try:
            latest_prediction = await db.execute(
                select(SeasonalPrediction)
                .where(SeasonalPrediction.plant_id == plant_id)
                .order_by(desc(SeasonalPrediction.created_at))
                .limit(1)
            )
            prediction = latest_prediction.scalar_one_or_none()
            
            if prediction:
                # Update last care event in prediction metadata
                if not prediction.metadata:
                    prediction.metadata = {}
                
                prediction.metadata["last_care_event"] = {
                    "type": care_log.care_type,
                    "date": care_log.performed_at.isoformat(),
                    "notes": care_log.notes
                }
                prediction.updated_at = datetime.utcnow()
                await db.commit()
                
        except Exception as e:
            # Log but don't raise - this is supplementary functionality
            pass
    
    @staticmethod
    async def _update_timelapse_sessions_from_care(
        db: AsyncSession,
        plant_id: UUID,
        care_log: PlantCareLog
    ) -> None:
        """Update active time-lapse sessions with care event data."""
        try:
            # Get active time-lapse sessions for this plant
            active_sessions = await db.execute(
                select(TimelapseSession)
                .where(
                    and_(
                        TimelapseSession.plant_id == plant_id,
                        TimelapseSession.status == "active"
                    )
                )
            )
            sessions = active_sessions.scalars().all()
            
            for session in sessions:
                # Add care event to session metadata
                if not session.metadata:
                    session.metadata = {}
                
                if "care_events" not in session.metadata:
                    session.metadata["care_events"] = []
                
                session.metadata["care_events"].append({
                    "type": care_log.care_type,
                    "date": care_log.performed_at.isoformat(),
                    "notes": care_log.notes,
                    "log_id": str(care_log.id)
                })
                
                session.updated_at = datetime.utcnow()
            
            if sessions:
                await db.commit()
                
        except Exception as e:
            # Log but don't raise - this is supplementary functionality
            pass
    
    @staticmethod
    async def _check_growth_milestones_from_care(
        db: AsyncSession,
        plant_id: UUID,
        care_log: PlantCareLog
    ) -> None:
        """Check if care event triggers any growth milestones."""
        try:
            # For significant care events, we might want to trigger a growth analysis
            # This would integrate with the time-lapse service to check for milestones
            
            # Get the most recent growth photo to analyze
            recent_photo = await db.execute(
                select(GrowthPhoto)
                .join(TimelapseSession)
                .where(
                    and_(
                        TimelapseSession.plant_id == plant_id,
                        TimelapseSession.status == "active"
                    )
                )
                .order_by(desc(GrowthPhoto.capture_date))
                .limit(1)
            )
            photo = recent_photo.scalar_one_or_none()
            
            if photo and care_log.care_type in ["repotting", "fertilizing"]:
                # Mark this as a potential milestone trigger
                if not photo.metadata:
                    photo.metadata = {}
                
                photo.metadata["care_milestone_trigger"] = {
                    "care_type": care_log.care_type,
                    "care_date": care_log.performed_at.isoformat(),
                    "expected_growth_response": True
                }
                
                await db.commit()
                
        except Exception as e:
            # Log but don't raise - this is supplementary functionality
            pass


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