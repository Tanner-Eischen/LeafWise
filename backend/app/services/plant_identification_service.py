"""Plant identification service.

This module provides business logic for AI-powered plant identification,
including image processing, species matching, and verification.
"""

import os
from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

from sqlalchemy import and_, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.models.plant_identification import PlantIdentification
from app.models.plant_species import PlantSpecies
from app.schemas.plant_identification import PlantIdentificationCreate, PlantIdentificationUpdate


class PlantIdentificationService:
    """Service for managing plant identification."""
    
    @staticmethod
    async def create_identification(
        db: AsyncSession,
        user_id: UUID,
        identification_data: PlantIdentificationCreate
    ) -> PlantIdentification:
        """Create a new plant identification record.
        
        Args:
            db: Database session
            user_id: User ID
            identification_data: Identification creation data
            
        Returns:
            Created identification record
        """
        identification = PlantIdentification(
            user_id=user_id,
            **identification_data.dict()
        )
        db.add(identification)
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def get_identification_by_id(
        db: AsyncSession,
        identification_id: UUID,
        user_id: Optional[UUID] = None
    ) -> Optional[PlantIdentification]:
        """Get identification by ID.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: Optional user ID for ownership check
            
        Returns:
            Identification if found and accessible, None otherwise
        """
        query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species),
            selectinload(PlantIdentification.user)
        ).where(PlantIdentification.id == identification_id)
        
        if user_id:
            query = query.where(PlantIdentification.user_id == user_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_user_identifications(
        db: AsyncSession,
        user_id: UUID,
        verified_only: Optional[bool] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantIdentification], int]:
        """Get identifications by user.
        
        Args:
            db: Database session
            user_id: User ID
            verified_only: Filter by verification status
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (identifications list, total count)
        """
        # Build base query
        base_query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species)
        ).where(PlantIdentification.user_id == user_id)
        
        count_query = select(func.count(PlantIdentification.id)).where(
            PlantIdentification.user_id == user_id
        )
        
        if verified_only is not None:
            base_query = base_query.where(PlantIdentification.is_verified == verified_only)
            count_query = count_query.where(PlantIdentification.is_verified == verified_only)
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results
        result = await db.execute(
            base_query.order_by(desc(PlantIdentification.created_at))
            .offset(skip)
            .limit(limit)
        )
        identifications = result.scalars().all()
        
        return list(identifications), total
    
    @staticmethod
    async def update_identification(
        db: AsyncSession,
        identification_id: UUID,
        user_id: UUID,
        identification_data: PlantIdentificationUpdate
    ) -> Optional[PlantIdentification]:
        """Update identification record.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: User ID (for ownership verification)
            identification_data: Update data
            
        Returns:
            Updated identification if found and owned by user, None otherwise
        """
        result = await db.execute(
            select(PlantIdentification).where(
                and_(
                    PlantIdentification.id == identification_id,
                    PlantIdentification.user_id == user_id
                )
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return None
        
        # Update fields
        update_data = identification_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(identification, field, value)
        
        identification.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def verify_identification(
        db: AsyncSession,
        identification_id: UUID,
        verified_by_user_id: UUID,
        is_correct: bool,
        correct_species_id: Optional[UUID] = None
    ) -> Optional[PlantIdentification]:
        """Verify an identification (community verification).
        
        Args:
            db: Database session
            identification_id: Identification ID
            verified_by_user_id: User ID of verifier
            is_correct: Whether the identification is correct
            correct_species_id: Correct species ID if identification was wrong
            
        Returns:
            Updated identification if found, None otherwise
        """
        result = await db.execute(
            select(PlantIdentification).where(
                PlantIdentification.id == identification_id
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return None
        
        # Update verification status
        identification.is_verified = True
        identification.verified_at = datetime.utcnow()
        identification.verified_by_user_id = verified_by_user_id
        
        # If identification was incorrect, update with correct species
        if not is_correct and correct_species_id:
            identification.species_id = correct_species_id
            identification.confidence_score = 1.0  # Human verification is 100% confident
        
        identification.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(identification)
        return identification
    
    @staticmethod
    async def delete_identification(
        db: AsyncSession,
        identification_id: UUID,
        user_id: UUID
    ) -> bool:
        """Delete identification record.
        
        Args:
            db: Database session
            identification_id: Identification ID
            user_id: User ID (for ownership verification)
            
        Returns:
            True if deleted, False if not found or not owned
        """
        result = await db.execute(
            select(PlantIdentification).where(
                and_(
                    PlantIdentification.id == identification_id,
                    PlantIdentification.user_id == user_id
                )
            )
        )
        identification = result.scalar_one_or_none()
        
        if not identification:
            return False
        
        # Delete image file if it exists
        if identification.image_path and os.path.exists(identification.image_path):
            try:
                os.remove(identification.image_path)
            except OSError:
                pass  # File might already be deleted
        
        await db.delete(identification)
        await db.commit()
        return True
    
    @staticmethod
    async def get_pending_verifications(
        db: AsyncSession,
        skip: int = 0,
        limit: int = 20
    ) -> tuple[List[PlantIdentification], int]:
        """Get identifications pending verification.
        
        Args:
            db: Database session
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            Tuple of (identifications list, total count)
        """
        # Build query for unverified identifications
        base_query = select(PlantIdentification).options(
            selectinload(PlantIdentification.species),
            selectinload(PlantIdentification.user)
        ).where(PlantIdentification.is_verified == False)
        
        count_query = select(func.count(PlantIdentification.id)).where(
            PlantIdentification.is_verified == False
        )
        
        # Get total count
        count_result = await db.execute(count_query)
        total = count_result.scalar()
        
        # Get paginated results, ordered by confidence score (lowest first for review)
        result = await db.execute(
            base_query.order_by(PlantIdentification.confidence_score.asc())
            .offset(skip)
            .limit(limit)
        )
        identifications = result.scalars().all()
        
        return list(identifications), total
    
    @staticmethod
    async def get_identification_statistics(
        db: AsyncSession,
        user_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Get identification statistics.
        
        Args:
            db: Database session
            user_id: Optional user ID for user-specific stats
            
        Returns:
            Dictionary with identification statistics
        """
        base_query = select(PlantIdentification)
        
        if user_id:
            base_query = base_query.where(PlantIdentification.user_id == user_id)
        
        # Total identifications
        total_result = await db.execute(
            select(func.count(PlantIdentification.id)).where(
                PlantIdentification.user_id == user_id if user_id else True
            )
        )
        total_identifications = total_result.scalar()
        
        # Verified identifications
        verified_result = await db.execute(
            select(func.count(PlantIdentification.id)).where(
                and_(
                    PlantIdentification.is_verified == True,
                    PlantIdentification.user_id == user_id if user_id else True
                )
            )
        )
        verified_identifications = verified_result.scalar()
        
        # Average confidence score
        avg_confidence_result = await db.execute(
            select(func.avg(PlantIdentification.confidence_score)).where(
                PlantIdentification.user_id == user_id if user_id else True
            )
        )
        avg_confidence = avg_confidence_result.scalar() or 0.0
        
        # Most identified species
        species_result = await db.execute(
            select(
                PlantIdentification.species_id,
                func.count(PlantIdentification.id).label('count')
            ).where(
                PlantIdentification.user_id == user_id if user_id else True
            ).group_by(PlantIdentification.species_id)
            .order_by(desc('count'))
            .limit(5)
        )
        top_species = species_result.all()
        
        # Get species names for top species
        top_species_with_names = []
        for species_id, count in top_species:
            if species_id:
                species_result = await db.execute(
                    select(PlantSpecies).where(PlantSpecies.id == species_id)
                )
                species = species_result.scalar_one_or_none()
                if species:
                    top_species_with_names.append({
                        "species_id": species_id,
                        "scientific_name": species.scientific_name,
                        "common_names": species.common_names,
                        "count": count
                    })
        
        return {
            "total_identifications": total_identifications,
            "verified_identifications": verified_identifications,
            "pending_verification": total_identifications - verified_identifications,
            "verification_rate": round(
                (verified_identifications / total_identifications * 100) if total_identifications > 0 else 0, 2
            ),
            "average_confidence_score": round(float(avg_confidence), 3),
            "top_identified_species": top_species_with_names
        }
    
    @staticmethod
    async def search_similar_identifications(
        db: AsyncSession,
        species_id: UUID,
        confidence_threshold: float = 0.8,
        limit: int = 10
    ) -> List[PlantIdentification]:
        """Search for similar identifications of the same species.
        
        Args:
            db: Database session
            species_id: Species ID to search for
            confidence_threshold: Minimum confidence score
            limit: Maximum number of results
            
        Returns:
            List of similar identifications
        """
        result = await db.execute(
            select(PlantIdentification).options(
                selectinload(PlantIdentification.user)
            ).where(
                and_(
                    PlantIdentification.species_id == species_id,
                    PlantIdentification.confidence_score >= confidence_threshold,
                    PlantIdentification.is_verified == True
                )
            ).order_by(desc(PlantIdentification.confidence_score))
            .limit(limit)
        )
        
        return list(result.scalars().all())


# Convenience functions for dependency injection
async def create_identification(
    db: AsyncSession,
    user_id: UUID,
    identification_data: PlantIdentificationCreate
) -> PlantIdentification:
    """Create a new plant identification record."""
    return await PlantIdentificationService.create_identification(
        db, user_id, identification_data
    )


async def get_identification_by_id(
    db: AsyncSession,
    identification_id: UUID,
    user_id: Optional[UUID] = None
) -> Optional[PlantIdentification]:
    """Get identification by ID."""
    return await PlantIdentificationService.get_identification_by_id(
        db, identification_id, user_id
    )


async def get_user_identifications(
    db: AsyncSession,
    user_id: UUID,
    verified_only: Optional[bool] = None,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantIdentification], int]:
    """Get identifications by user."""
    return await PlantIdentificationService.get_user_identifications(
        db, user_id, verified_only, skip, limit
    )


async def verify_identification(
    db: AsyncSession,
    identification_id: UUID,
    verified_by_user_id: UUID,
    is_correct: bool,
    correct_species_id: Optional[UUID] = None
) -> Optional[PlantIdentification]:
    """Verify an identification."""
    return await PlantIdentificationService.verify_identification(
        db, identification_id, verified_by_user_id, is_correct, correct_species_id
    )


async def get_pending_verifications(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 20
) -> tuple[List[PlantIdentification], int]:
    """Get identifications pending verification."""
    return await PlantIdentificationService.get_pending_verifications(db, skip, limit)


async def get_identification_statistics(
    db: AsyncSession,
    user_id: Optional[UUID] = None
) -> Dict[str, Any]:
    """Get identification statistics."""
    return await PlantIdentificationService.get_identification_statistics(db, user_id)


async def update_identification(
    db: AsyncSession,
    identification_id: UUID,
    user_id: UUID,
    identification_data: PlantIdentificationUpdate
) -> Optional[PlantIdentification]:
    """Update identification record."""
    return await PlantIdentificationService.update_identification(
        db, identification_id, user_id, identification_data
    )


async def delete_identification(
    db: AsyncSession,
    identification_id: UUID,
    user_id: UUID
) -> bool:
    """Delete identification record."""
    return await PlantIdentificationService.delete_identification(
        db, identification_id, user_id
    )