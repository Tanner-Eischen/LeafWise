"""User plant service.

This module provides business logic for managing user plants,
including CRUD operations, care tracking, and reminders.
"""

from datetime import datetime, timedelta
from typing import List, Optional
from uuid import UUID

from sqlalchemy import and_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.models.plant_care_log import PlantCareLog
from app.schemas.user_plant import UserPlantCreate, UserPlantUpdate


class UserPlantService:
    """Service for managing user plants."""
    
    @staticmethod
    async def create_plant(
        db: AsyncSession,
        user_id: UUID,
        plant_data: UserPlantCreate
    ) -> UserPlant:
        """Create a new user plant.
        
        Args:
            db: Database session
            user_id: Owner user ID
            plant_data: Plant creation data
            
        Returns:
            Created user plant
        """
        plant = UserPlant(
            user_id=user_id,
            **plant_data.dict()
        )
        db.add(plant)
        await db.commit()
        await db.refresh(plant)
        return plant
    
    @staticmethod
    async def get_plant_by_id(
        db: AsyncSession,
        plant_id: UUID,
        user_id: Optional[UUID] = None
    ) -> Optional[UserPlant]:
        """Get user plant by ID.
        
        Args:
            db: Database session
            plant_id: Plant ID
            user_id: Optional user ID for ownership check
            
        Returns:
            User plant if found, None otherwise
        """
        query = select(UserPlant).options(
            selectinload(UserPlant.species)
        ).where(UserPlant.id == plant_id)
        
        if user_id:
            query = query.where(UserPlant.user_id == user_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_user_plants(
        db: AsyncSession,
        user_id: UUID,
        is_active: Optional[bool] = True,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[UserPlant], int]:
        """Get plants owned by a user.
        
        Args:
            db: Database session
            user_id: User ID
            is_active: Filter by active status
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (plants list, total count)
        """
        # Build base query
        base_query = select(UserPlant).options(
            selectinload(UserPlant.species)
        ).where(UserPlant.user_id == user_id)
        
        count_query = select(func.count(UserPlant.id)).where(
            UserPlant.user_id == user_id
        )
        
        if is_active is not None:
            base_query = base_query.where(UserPlant.is_active == is_active)
            count_query = count_query.where(UserPlant.is_active == is_active)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(UserPlant.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        plants = result.scalars().all()
        
        return list(plants), total
    
    @staticmethod
    async def update_plant(
        db: AsyncSession,
        plant_id: UUID,
        user_id: UUID,
        plant_data: UserPlantUpdate
    ) -> Optional[UserPlant]:
        """Update user plant.
        
        Args:
            db: Database session
            plant_id: Plant ID
            user_id: Owner user ID
            plant_data: Update data
            
        Returns:
            Updated plant if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = result.scalar_one_or_none()
        
        if not plant:
            return None
        
        # Update fields
        update_data = plant_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(plant, field, value)
        
        plant.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(plant)
        return plant
    
    @staticmethod
    async def delete_plant(
        db: AsyncSession,
        plant_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete user plant (soft delete by setting is_active=False).
        
        Args:
            db: Database session
            plant_id: Plant ID
            user_id: Owner user ID
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = result.scalar_one_or_none()
        
        if not plant:
            return False
        
        plant.is_active = False
        plant.updated_at = datetime.utcnow()
        await db.commit()
        return True
    
    @staticmethod
    async def get_care_reminders(
        db: AsyncSession,
        user_id: UUID
    ) -> List[dict]:
        """Get care reminders for user's plants.
        
        Args:
            db: Database session
            user_id: User ID
            
        Returns:
            List of care reminder data
        """
        # Get plants with species info
        result = await db.execute(
            select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(
                and_(
                    UserPlant.user_id == user_id,
                    UserPlant.is_active == True
                )
            )
        )
        plants = result.scalars().all()
        
        reminders = []
        current_time = datetime.utcnow()
        
        for plant in plants:
            if not plant.species or not plant.species.water_frequency_days:
                continue
            
            # Check watering reminder
            if plant.last_watered:
                days_since_watered = (current_time - plant.last_watered).days
                if days_since_watered >= plant.species.water_frequency_days:
                    reminders.append({
                        "plant_id": plant.id,
                        "plant_nickname": plant.nickname,
                        "species_name": plant.species.scientific_name,
                        "care_type": "watering",
                        "days_overdue": days_since_watered - plant.species.water_frequency_days,
                        "last_care_date": plant.last_watered,
                        "recommended_frequency_days": plant.species.water_frequency_days
                    })
        
        return reminders
    
    @staticmethod
    async def update_care_activity(
        db: AsyncSession,
        plant_id: UUID,
        user_id: UUID,
        care_type: str,
        care_date: Optional[datetime] = None
    ) -> bool:
        """Update plant care activity timestamp.
        
        Args:
            db: Database session
            plant_id: Plant ID
            user_id: Owner user ID
            care_type: Type of care (watering, fertilizing, etc.)
            care_date: Date of care activity
            
        Returns:
            True if updated, False if plant not found or not owned
        """
        result = await db.execute(
            select(UserPlant).where(
                and_(
                    UserPlant.id == plant_id,
                    UserPlant.user_id == user_id
                )
            )
        )
        plant = result.scalar_one_or_none()
        
        if not plant:
            return False
        
        if care_date is None:
            care_date = datetime.utcnow()
        
        # Update appropriate timestamp
        if care_type == "watering":
            plant.last_watered = care_date
        elif care_type == "fertilizing":
            plant.last_fertilized = care_date
        elif care_type == "repotting":
            plant.last_repotted = care_date
        
        plant.updated_at = datetime.utcnow()
        await db.commit()
        return True
    
    @staticmethod
    async def get_plant_stats(
        db: AsyncSession,
        user_id: UUID
    ) -> dict:
        """Get plant statistics for a user.
        
        Args:
            db: Database session
            user_id: User ID
            
        Returns:
            Dictionary with plant statistics
        """
        # Get total plants count
        total_result = await db.execute(
            select(func.count(UserPlant.id)).where(
                and_(
                    UserPlant.user_id == user_id,
                    UserPlant.is_active == True
                )
            )
        )
        total_plants = total_result.scalar()
        
        # Get plants by health status
        health_result = await db.execute(
            select(
                UserPlant.health_status,
                func.count(UserPlant.id)
            ).where(
                and_(
                    UserPlant.user_id == user_id,
                    UserPlant.is_active == True
                )
            ).group_by(UserPlant.health_status)
        )
        health_stats = {status: count for status, count in health_result.all()}
        
        return {
            "total_plants": total_plants,
            "health_distribution": health_stats,
            "healthy_plants": health_stats.get("healthy", 0),
            "sick_plants": health_stats.get("sick", 0),
            "recovering_plants": health_stats.get("recovering", 0)
        }


# Convenience functions for dependency injection
async def get_plant_by_id(
    db: AsyncSession,
    plant_id: UUID,
    user_id: Optional[UUID] = None
) -> Optional[UserPlant]:
    """Get user plant by ID."""
    return await UserPlantService.get_plant_by_id(db, plant_id, user_id)


async def get_user_plants(
    db: AsyncSession,
    user_id: UUID,
    is_active: Optional[bool] = True,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[UserPlant], int]:
    """Get user's plants."""
    return await UserPlantService.get_user_plants(db, user_id, is_active, skip, limit)


async def create_plant(
    db: AsyncSession,
    user_id: UUID,
    plant_data: UserPlantCreate
) -> UserPlant:
    """Create a new user plant."""
    return await UserPlantService.create_plant(db, user_id, plant_data)


async def update_plant(
    db: AsyncSession,
    plant_id: UUID,
    user_id: UUID,
    plant_data: UserPlantUpdate
) -> Optional[UserPlant]:
    """Update user plant."""
    return await UserPlantService.update_plant(db, plant_id, user_id, plant_data)


async def get_care_reminders(db: AsyncSession, user_id: UUID) -> List[dict]:
    """Get care reminders for user's plants."""
    return await UserPlantService.get_care_reminders(db, user_id)


async def update_care_activity(
    db: AsyncSession,
    plant_id: UUID,
    user_id: UUID,
    care_type: str,
    care_date: Optional[datetime] = None
) -> bool:
    """Update plant care activity."""
    return await UserPlantService.update_care_activity(
        db, plant_id, user_id, care_type, care_date
    )


async def get_plant_stats(db: AsyncSession, user_id: UUID) -> dict:
    """Get plant statistics for a user."""
    return await UserPlantService.get_plant_stats(db, user_id)


async def delete_plant(db: AsyncSession, plant_id: UUID, user_id: UUID) -> bool:
    """Delete user plant (soft delete)."""
    return await UserPlantService.delete_plant(db, plant_id, user_id)