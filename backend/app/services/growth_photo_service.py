"""Growth photo service for managing plant growth photos.

This module provides functionality for retrieving, creating, and analyzing
growth photos to track plant development over time.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID

from sqlalchemy import and_, func, desc, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session

from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant
from app.schemas.telemetry import GrowthPhotoResponse


class GrowthPhotoService:
    """Service for managing growth photos.
    
    Provides methods for retrieving, creating, and analyzing growth photos
    to track plant development over time.
    """
    
    def __init__(self, db: AsyncSession):
        """Initialize the growth photo service.
        
        Args:
            db: Database session
        """
        self.db = db
    
    async def get_growth_photos(
        self,
        user_id: UUID,
        plant_id: Optional[UUID] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        is_processed: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[GrowthPhoto]:
        """Retrieve growth photos with optional filtering.
        
        Args:
            user_id: User ID
            plant_id: Optional plant ID filter
            start_date: Optional start date filter
            end_date: Optional end date filter
            is_processed: Optional processing status filter
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of growth photos matching the criteria
        """
        query = select(GrowthPhoto).where(GrowthPhoto.user_id == user_id)
        
        # Apply filters if provided
        if plant_id is not None:
            query = query.where(GrowthPhoto.plant_id == plant_id)
            
        if is_processed is not None:
            query = query.where(GrowthPhoto.is_processed == is_processed)
            
        if start_date is not None:
            query = query.where(GrowthPhoto.captured_at >= start_date)
            
        if end_date is not None:
            query = query.where(GrowthPhoto.captured_at <= end_date)
        
        # Order by capture date (newest first) and apply pagination
        query = query.order_by(desc(GrowthPhoto.captured_at)).offset(skip).limit(limit)
        
        result = await self.db.execute(query)
        return result.scalars().all()
    
    async def get_growth_photo_by_id(self, photo_id: UUID, user_id: UUID) -> Optional[GrowthPhoto]:
        """Retrieve a specific growth photo by ID.
        
        Args:
            photo_id: Growth photo ID
            user_id: User ID
            
        Returns:
            Growth photo if found, None otherwise
        """
        query = select(GrowthPhoto).where(
            GrowthPhoto.id == photo_id,
            GrowthPhoto.user_id == user_id
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
    
    async def create_growth_photo(
        self,
        user_id: UUID,
        plant_id: UUID,
        file_path: str,
        location_name: Optional[str] = None,
        notes: Optional[str] = None,
        **kwargs
    ) -> GrowthPhoto:
        """Create a new growth photo record.
        
        Args:
            user_id: User ID
            plant_id: Plant ID
            file_path: Path to the uploaded file
            location_name: Optional location name
            notes: Optional notes
            **kwargs: Additional fields for the growth photo
            
        Returns:
            Created growth photo
        """
        # Create growth photo object
        growth_photo = GrowthPhoto(
            user_id=user_id,
            plant_id=plant_id,
            file_path=file_path,
            location_name=location_name,
            notes=notes,
            is_processed=False,
            created_at=datetime.utcnow(),
            captured_at=kwargs.pop('captured_at', datetime.utcnow()),
            **kwargs
        )
        
        self.db.add(growth_photo)
        await self.db.commit()
        await self.db.refresh(growth_photo)
        
        return growth_photo
    
    async def analyze_growth_photo(
        self,
        photo_id: UUID,
        user_id: UUID,
        measurements: Dict[str, Any]
    ) -> Optional[GrowthPhoto]:
        """Analyze a growth photo and update with measurements.
        
        Args:
            photo_id: Growth photo ID
            user_id: User ID
            measurements: Dictionary of measurements extracted from the photo
            
        Returns:
            Updated growth photo if found, None otherwise
        """
        # Get the photo
        photo = await self.get_growth_photo_by_id(photo_id, user_id)
        if not photo:
            return None
            
        # Update the photo with measurements and mark as processed
        photo.height_cm = measurements.get('height_cm')
        photo.width_cm = measurements.get('width_cm')
        photo.leaf_count = measurements.get('leaf_count')
        photo.color_analysis = measurements.get('color_analysis')
        photo.is_processed = True
        photo.processed_at = datetime.utcnow()
        
        # Save changes
        self.db.add(photo)
        await self.db.commit()
        await self.db.refresh(photo)
        
        return photo
    
    async def update_growth_photo(self, photo_id: UUID, update_data: Dict[str, Any]) -> Optional[GrowthPhoto]:
        """Update an existing growth photo.
        
        Args:
            photo_id: Growth photo ID
            update_data: Data to update
            
        Returns:
            Updated growth photo if found, None otherwise
        """
        query = select(GrowthPhoto).where(GrowthPhoto.id == photo_id)
        result = await self.db.execute(query)
        photo = result.scalar_one_or_none()
        
        if not photo:
            return None
        
        # Update fields
        for key, value in update_data.items():
            if hasattr(photo, key):
                setattr(photo, key, value)
        
        await self.db.commit()
        await self.db.refresh(photo)
        
        return photo
    
    async def get_growth_statistics(
        self,
        user_id: UUID,
        plant_id: UUID,
        days: Optional[int] = 30,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None,
    ) -> Dict[str, Any]:
        """Get growth statistics for a plant over time.
        
        Args:
            user_id: User ID
            plant_id: Plant ID
            days: Number of days to analyze (default 30)
            from_date: Optional custom start date
            to_date: Optional custom end date
            
        Returns:
            Dictionary with growth statistics
        """
        # Calculate date range if not provided
        if to_date is None:
            to_date = datetime.utcnow()
            
        if from_date is None and days is not None:
            from_date = to_date - timedelta(days=days)
        
        # Query growth photos in date range
        query = select(GrowthPhoto).where(
            GrowthPhoto.user_id == user_id,
            GrowthPhoto.plant_id == plant_id,
            GrowthPhoto.is_processed == True,
            GrowthPhoto.captured_at.between(start_date, end_date)
        ).order_by(GrowthPhoto.captured_at)
        
        result = await self.db.execute(query)
        photos = result.scalars().all()
        
        if not photos:
            return {
                "total_photos": 0,
                "date_range": {
                    "from": from_date.isoformat() if from_date else None,
                    "to": to_date.isoformat() if to_date else None,
                },
                "metrics": {}
            }
        
        # Calculate statistics
        first_photo = photos[0]
        last_photo = photos[-1]
        total_days = (last_photo.captured_at - first_photo.captured_at).days or 1  # Avoid division by zero
        
        # Extract metrics
        height_values = [p.plant_height_cm for p in photos if p.plant_height_cm is not None]
        leaf_area_values = [p.leaf_area_cm2 for p in photos if p.leaf_area_cm2 is not None]
        leaf_count_values = [p.leaf_count for p in photos if p.leaf_count is not None]
        health_scores = [p.health_score for p in photos if p.health_score is not None]
        
        # Calculate growth rates
        height_growth = None
        if len(height_values) >= 2:
            height_growth = (height_values[-1] - height_values[0]) / total_days
            
        leaf_area_growth = None
        if len(leaf_area_values) >= 2:
            leaf_area_growth = (leaf_area_values[-1] - leaf_area_values[0]) / total_days
            
        leaf_count_growth = None
        if len(leaf_count_values) >= 2:
            leaf_count_growth = (leaf_count_values[-1] - leaf_count_values[0]) / total_days
        
        # Compile statistics
        return {
            "total_photos": len(photos),
            "date_range": {
                "from": from_date.isoformat(),
                "to": to_date.isoformat(),
                "days": total_days
            },
            "metrics": {
                "height": {
                    "first": height_values[0] if height_values else None,
                    "last": height_values[-1] if height_values else None,
                    "growth_per_day": height_growth,
                    "total_growth": (height_values[-1] - height_values[0]) if len(height_values) >= 2 else None,
                    "growth_percent": ((height_values[-1] / height_values[0]) - 1) * 100 if len(height_values) >= 2 and height_values[0] > 0 else None
                },
                "leaf_area": {
                    "first": leaf_area_values[0] if leaf_area_values else None,
                    "last": leaf_area_values[-1] if leaf_area_values else None,
                    "growth_per_day": leaf_area_growth,
                    "total_growth": (leaf_area_values[-1] - leaf_area_values[0]) if len(leaf_area_values) >= 2 else None,
                    "growth_percent": ((leaf_area_values[-1] / leaf_area_values[0]) - 1) * 100 if len(leaf_area_values) >= 2 and leaf_area_values[0] > 0 else None
                },
                "leaf_count": {
                    "first": leaf_count_values[0] if leaf_count_values else None,
                    "last": leaf_count_values[-1] if leaf_count_values else None,
                    "growth_per_day": leaf_count_growth,
                    "total_growth": (leaf_count_values[-1] - leaf_count_values[0]) if len(leaf_count_values) >= 2 else None,
                    "growth_percent": ((leaf_count_values[-1] / leaf_count_values[0]) - 1) * 100 if len(leaf_count_values) >= 2 and leaf_count_values[0] > 0 else None
                },
                "health": {
                    "average": sum(health_scores) / len(health_scores) if health_scores else None,
                    "min": min(health_scores) if health_scores else None,
                    "max": max(health_scores) if health_scores else None,
                    "trend": "improving" if len(health_scores) >= 2 and health_scores[-1] > health_scores[0] else
                             "declining" if len(health_scores) >= 2 and health_scores[-1] < health_scores[0] else
                             "stable" if len(health_scores) >= 2 else None
                }
            },
            "growth_rate_category": self._calculate_growth_rate_category(height_growth, leaf_area_growth) if height_growth and leaf_area_growth else None
        }
    
    def _calculate_growth_rate_category(self, height_growth: float, leaf_area_growth: float) -> str:
        """Calculate growth rate category based on metrics.
        
        Args:
            height_growth: Height growth per day
            leaf_area_growth: Leaf area growth per day
            
        Returns:
            Growth rate category
        """
        # Combined score (simplified approach)
        combined_score = (height_growth * 0.5) + (leaf_area_growth * 0.5)
        
        if combined_score > 0.5:
            return "vigorous"
        elif combined_score > 0.2:
            return "moderate"
        else:
            return "slow"


# Convenience function to get service instance
def get_growth_photo_service(db: Session):
    """Get growth photo service instance.
    
    Args:
        db: Database session
        
    Returns:
        GrowthPhotoService instance
    """
    return GrowthPhotoService(db)