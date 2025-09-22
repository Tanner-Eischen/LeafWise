"""Plant species service.

This module provides business logic for managing plant species data,
including CRUD operations and search functionality.
"""

from typing import List, Optional
from uuid import UUID

from sqlalchemy import and_, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_species import PlantSpecies
from app.schemas.plant_species import PlantSpeciesCreate, PlantSpeciesUpdate


class PlantSpeciesService:
    """Service for managing plant species."""
    
    @staticmethod
    async def create_species(
        db: AsyncSession,
        species_data: PlantSpeciesCreate
    ) -> PlantSpecies:
        """Create a new plant species.
        
        Args:
            db: Database session
            species_data: Plant species creation data
            
        Returns:
            Created plant species
        """
        species = PlantSpecies(**species_data.dict())
        db.add(species)
        await db.commit()
        await db.refresh(species)
        return species
    
    @staticmethod
    async def get_species_by_id(
        db: AsyncSession,
        species_id: UUID
    ) -> Optional[PlantSpecies]:
        """Get plant species by ID.
        
        Args:
            db: Database session
            species_id: Species ID
            
        Returns:
            Plant species if found, None otherwise
        """
        result = await db.execute(
            select(PlantSpecies).where(PlantSpecies.id == species_id)
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_species_by_scientific_name(
        db: AsyncSession,
        scientific_name: str
    ) -> Optional[PlantSpecies]:
        """Get plant species by scientific name.
        
        Args:
            db: Database session
            scientific_name: Scientific name
            
        Returns:
            Plant species if found, None otherwise
        """
        result = await db.execute(
            select(PlantSpecies).where(
                PlantSpecies.scientific_name.ilike(f"%{scientific_name}%")
            )
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def search_species(
        db: AsyncSession,
        query: Optional[str] = None,
        care_level: Optional[str] = None,
        family: Optional[str] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantSpecies], int]:
        """Search plant species with filters.
        
        Args:
            db: Database session
            query: Search query for name matching
            care_level: Filter by care level
            family: Filter by plant family
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (species list, total count)
        """
        # Build base query
        base_query = select(PlantSpecies)
        count_query = select(func.count(PlantSpecies.id))
        
        # Apply filters
        conditions = []
        
        if query:
            search_condition = or_(
                PlantSpecies.scientific_name.ilike(f"%{query}%"),
                PlantSpecies.common_names.op("@>")(f'["{query}"]'),
                PlantSpecies.family.ilike(f"%{query}%")
            )
            conditions.append(search_condition)
        
        if care_level:
            conditions.append(PlantSpecies.care_level == care_level)
        
        if family:
            conditions.append(PlantSpecies.family.ilike(f"%{family}%"))
        
        if conditions:
            base_query = base_query.where(and_(*conditions))
            count_query = count_query.where(and_(*conditions))
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(PlantSpecies.scientific_name)
            .offset(skip)
            .limit(limit)
        )
        species = result.scalars().all()
        
        return list(species), total
    
    @staticmethod
    async def update_species(
        db: AsyncSession,
        species_id: UUID,
        species_data: PlantSpeciesUpdate
    ) -> Optional[PlantSpecies]:
        """Update plant species.
        
        Args:
            db: Database session
            species_id: Species ID
            species_data: Update data
            
        Returns:
            Updated plant species if found, None otherwise
        """
        result = await db.execute(
            select(PlantSpecies).where(PlantSpecies.id == species_id)
        )
        species = result.scalar_one_or_none()
        
        if not species:
            return None
        
        # Update fields
        update_data = species_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(species, field, value)
        
        await db.commit()
        await db.refresh(species)
        return species
    
    @staticmethod
    async def delete_species(
        db: AsyncSession,
        species_id: UUID
    ) -> bool:
        """Delete plant species.
        
        Args:
            db: Database session
            species_id: Species ID
            
        Returns:
            True if deleted, False if not found
        """
        result = await db.execute(
            select(PlantSpecies).where(PlantSpecies.id == species_id)
        )
        species = result.scalar_one_or_none()
        
        if not species:
            return False
        
        await db.delete(species)
        await db.commit()
        return True
    
    @staticmethod
    async def get_popular_species(
        db: AsyncSession,
        limit: int = 10
    ) -> List[PlantSpecies]:
        """Get most popular plant species based on user plants.
        
        Args:
            db: Database session
            limit: Maximum number of species to return
            
        Returns:
            List of popular plant species
        """
        # This would require a join with user_plants table
        # For now, return species ordered by creation date
        result = await db.execute(
            select(PlantSpecies)
            .order_by(PlantSpecies.created_at.desc())
            .limit(limit)
        )
        return list(result.scalars().all())


# Convenience functions for dependency injection
async def get_species_by_id(db: AsyncSession, species_id: UUID) -> Optional[PlantSpecies]:
    """Get plant species by ID."""
    return await PlantSpeciesService.get_species_by_id(db, species_id)


async def get_species_by_scientific_name(db: AsyncSession, scientific_name: str) -> Optional[PlantSpecies]:
    """Get plant species by scientific name."""
    return await PlantSpeciesService.get_species_by_scientific_name(db, scientific_name)


async def search_species(
    db: AsyncSession,
    query: Optional[str] = None,
    care_level: Optional[str] = None,
    family: Optional[str] = None,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantSpecies], int]:
    """Search plant species."""
    return await PlantSpeciesService.search_species(
        db, query, care_level, family, skip, limit
    )


async def create_species(db: AsyncSession, species_data: PlantSpeciesCreate) -> PlantSpecies:
    """Create a new plant species."""
    return await PlantSpeciesService.create_species(db, species_data)


async def update_species(
    db: AsyncSession,
    species_id: UUID,
    species_data: PlantSpeciesUpdate
) -> Optional[PlantSpecies]:
    """Update plant species."""
    return await PlantSpeciesService.update_species(db, species_id, species_data)


async def delete_species(db: AsyncSession, species_id: UUID) -> bool:
    """Delete plant species."""
    return await PlantSpeciesService.delete_species(db, species_id)


async def get_popular_species(db: AsyncSession, limit: int = 10) -> List[PlantSpecies]:
    """Get popular plant species."""
    return await PlantSpeciesService.get_popular_species(db, limit)