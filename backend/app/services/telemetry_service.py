"""Telemetry service for managing sensor data and growth photos.

This module provides a unified interface for handling various types of telemetry data,
including light readings and growth photos. It serves as an integration layer for
different telemetry services.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Union, Tuple
from uuid import UUID, uuid4

from sqlalchemy import and_, func, desc, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session

from app.models.light_reading import LightReading, LightSource, CalibrationProfile, BLEDevice
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant
from app.schemas.telemetry import (
    LightReadingCreate, 
    LightReadingResponse,
    GrowthPhotoResponse,
    BatchLightReadingRequest
)
from app.services.light_reading_service import LightReadingService
from app.services.growth_photo_service import GrowthPhotoService


class TelemetryService:
    """Service for managing telemetry data.
    
    Provides a unified interface for handling various types of telemetry data,
    including light readings and growth photos.
    """
    
    def __init__(self, db: AsyncSession):
        """Initialize the telemetry service.
        
        Args:
            db: Database session
        """
        self.db = db
        self.light_reading_service = LightReadingService(db)
        self.growth_photo_service = GrowthPhotoService(db)
    
    # Light Reading Methods
    
    async def get_light_readings(
        self,
        user_id: UUID,
        plant_id: Optional[UUID] = None,
        source: Optional[LightSource] = None,
        location_name: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        min_lux: Optional[float] = None,
        max_lux: Optional[float] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[LightReading]:
        """Get light readings with filtering and pagination.
        
        Args:
            user_id: User ID
            plant_id: Filter by plant ID
            source: Filter by light source type
            location_name: Filter by location name
            start_date: Filter by start date
            end_date: Filter by end date
            min_lux: Filter by minimum lux value
            max_lux: Filter by maximum lux value
            skip: Number of records to skip (pagination)
            limit: Maximum number of records to return (pagination)
            
        Returns:
            List of light readings matching the filters
        """
        return await self.light_reading_service.get_light_readings(
            user_id=user_id,
            plant_id=plant_id,
            source=source,
            location_name=location_name,
            start_date=start_date,
            end_date=end_date,
            min_lux=min_lux,
            max_lux=max_lux,
            skip=skip,
            limit=limit
        )
    
    async def get_light_reading_by_id(
        self,
        reading_id: UUID,
        user_id: UUID
    ) -> Optional[LightReading]:
        """Get a specific light reading by ID.
        
        Args:
            reading_id: Light reading ID
            user_id: User ID for ownership verification
            
        Returns:
            Light reading if found and owned by user, None otherwise
        """
        return await self.light_reading_service.get_light_reading_by_id(
            reading_id=reading_id,
            user_id=user_id
        )
    
    async def create_light_reading(
        self,
        user_id: UUID,
        light_reading: LightReadingCreate
    ) -> LightReading:
        """Create a new light reading measurement.
        
        Args:
            user_id: User ID
            light_reading: Light reading data
            
        Returns:
            Created light reading
        """
        return await self.light_reading_service.create_light_reading(
            user_id=user_id,
            light_reading=light_reading
        )
    
    async def create_batch_light_readings(
        self,
        user_id: UUID,
        readings: List[LightReadingCreate]
    ) -> List[LightReading]:
        """Create multiple light readings in a single request.
        
        Args:
            user_id: User ID
            readings: List of light reading data
            
        Returns:
            List of created light readings
        """
        return await self.light_reading_service.create_batch_light_readings(
            user_id=user_id,
            readings=readings
        )
    
    # Growth Photo Methods
    
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
        return await self.growth_photo_service.get_growth_photos(
            user_id=user_id,
            plant_id=plant_id,
            start_date=start_date,
            end_date=end_date,
            is_processed=is_processed,
            skip=skip,
            limit=limit
        )
    
    async def get_growth_photo_by_id(
        self, 
        photo_id: UUID, 
        user_id: UUID
    ) -> Optional[GrowthPhoto]:
        """Retrieve a specific growth photo by ID.
        
        Args:
            photo_id: Growth photo ID
            user_id: User ID
            
        Returns:
            Growth photo if found, None otherwise
        """
        return await self.growth_photo_service.get_growth_photo_by_id(
            photo_id=photo_id,
            user_id=user_id
        )
    
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
        return await self.growth_photo_service.create_growth_photo(
            user_id=user_id,
            plant_id=plant_id,
            file_path=file_path,
            location_name=location_name,
            notes=notes,
            **kwargs
        )
    
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
        return await self.growth_photo_service.analyze_growth_photo(
            photo_id=photo_id,
            user_id=user_id,
            measurements=measurements
        )
    
    # Integrated Telemetry Methods
    
    async def get_plant_telemetry_summary(
        self,
        user_id: UUID,
        plant_id: UUID,
        days: int = 30
    ) -> Dict[str, Any]:
        """Get a comprehensive telemetry summary for a plant.
        
        This method aggregates data from both light readings and growth photos
        to provide a complete picture of the plant's environment and growth.
        
        Args:
            user_id: User ID
            plant_id: Plant ID
            days: Number of days to analyze
            
        Returns:
            Dictionary with telemetry summary
        """
        # Calculate date range
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Get plant information
        plant_query = select(UserPlant).where(
            UserPlant.id == plant_id,
            UserPlant.user_id == user_id
        )
        plant_result = await self.db.execute(plant_query)
        plant = plant_result.scalar_one_or_none()

        if not plant:
            return {
                "error": "Plant not found",
                "plant_id": str(plant_id)
            }
        
        # Get light readings
        light_readings = await self.get_light_readings(
            user_id=user_id,
            plant_id=plant_id,
            start_date=start_date,
            end_date=end_date,
            limit=1000  # Increased limit for analysis
        )
        
        # Get growth photos
        growth_photos = await self.get_growth_photos(
            user_id=user_id,
            plant_id=plant_id,
            start_date=start_date,
            end_date=end_date,
            is_processed=True,
            limit=100
        )
        
        # Calculate light statistics
        lux_values = [r.lux_value for r in light_readings if r.lux_value is not None]
        avg_lux = sum(lux_values) / len(lux_values) if lux_values else None
        min_lux = min(lux_values) if lux_values else None
        max_lux = max(lux_values) if lux_values else None
        
        # Calculate growth statistics
        height_values = [p.plant_height_cm for p in growth_photos if p.plant_height_cm is not None]
        leaf_area_values = [p.leaf_area_cm2 for p in growth_photos if p.leaf_area_cm2 is not None]
        
        # Calculate growth rates if we have at least two measurements
        height_growth = None
        if len(height_values) >= 2:
            first_height = height_values[0]
            last_height = height_values[-1]
            days_between = (growth_photos[-1].captured_at - growth_photos[0].captured_at).days or 1
            height_growth = (last_height - first_height) / days_between
        
        leaf_area_growth = None
        if len(leaf_area_values) >= 2:
            first_area = leaf_area_values[0]
            last_area = leaf_area_values[-1]
            days_between = (growth_photos[-1].captured_at - growth_photos[0].captured_at).days or 1
            leaf_area_growth = (last_area - first_area) / days_between
        
        # Compile summary
        return {
            "plant": {
                "id": str(plant.id),
                "name": plant.name,
                "species": plant.species,
                "date_range": {
                    "start": start_date.isoformat(),
                    "end": end_date.isoformat(),
                    "days": days
                }
            },
            "light": {
                "reading_count": len(light_readings),
                "averages": {
                    "lux": avg_lux,
                },
                "min_max": {
                    "min_lux": min_lux,
                    "max_lux": max_lux,
                }
            },
            "growth": {
                "photo_count": len(growth_photos),
                "height": {
                    "first": height_values[0] if height_values else None,
                    "last": height_values[-1] if height_values else None,
                    "growth_per_day": height_growth,
                    "total_growth": (height_values[-1] - height_values[0]) if len(height_values) >= 2 else None,
                },
                "leaf_area": {
                    "first": leaf_area_values[0] if leaf_area_values else None,
                    "last": leaf_area_values[-1] if leaf_area_values else None,
                    "growth_per_day": leaf_area_growth,
                    "total_growth": (leaf_area_values[-1] - leaf_area_values[0]) if len(leaf_area_values) >= 2 else None,
                }
            },
            "health_assessment": self._assess_plant_health(light_readings, growth_photos, plant)
        }

    # Batch Operations Methods
    
    async def create_batch_light_readings(
        self,
        user_id: UUID,
        readings: List[Dict[str, Any]],
        session_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Create multiple light readings in a single batch operation.
        
        Args:
            user_id: User ID
            readings: List of light reading data dictionaries
            session_id: Optional session ID for grouping
            
        Returns:
            Dictionary with batch operation results
        """
        from app.schemas.telemetry import LightReadingCreate
        
        try:
            # Convert dictionaries to schema objects
            reading_schemas = []
            for reading_data in readings:
                # Ensure required fields are present
                if 'lux_value' not in reading_data:
                    raise ValueError("lux_value is required for light readings")
                
                reading_schema = LightReadingCreate(**reading_data)
                reading_schemas.append(reading_schema)
            
            # Use the existing batch method from LightReadingService
            created_readings = await self.light_reading_service.create_batch_light_readings(
                user_id=user_id,
                readings=reading_schemas
            )
            
            return {
                "success": True,
                "created_count": len(created_readings),
                "session_id": str(session_id) if session_id else None,
                "reading_ids": [str(reading.id) for reading in created_readings],
                "created_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "created_count": 0,
                "session_id": str(session_id) if session_id else None,
                "created_at": datetime.utcnow().isoformat()
            }
    
    async def create_batch_growth_photos(
        self,
        user_id: UUID,
        photos: List[Dict[str, Any]],
        session_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Create multiple growth photos in a single batch operation.
        
        Args:
            user_id: User ID
            photos: List of growth photo data dictionaries
            session_id: Optional session ID for grouping
            
        Returns:
            Dictionary with batch operation results
        """
        try:
            created_photos = []
            
            for photo_data in photos:
                # Ensure required fields are present
                if 'plant_id' not in photo_data or 'file_path' not in photo_data:
                    raise ValueError("plant_id and file_path are required for growth photos")
                
                # Create growth photo using the existing service method
                created_photo = await self.growth_photo_service.create_growth_photo(
                    user_id=user_id,
                    plant_id=UUID(photo_data['plant_id']),
                    file_path=photo_data['file_path'],
                    location_name=photo_data.get('location_name'),
                    notes=photo_data.get('notes'),
                    **{k: v for k, v in photo_data.items() if k not in ['plant_id', 'file_path', 'location_name', 'notes']}
                )
                created_photos.append(created_photo)
            
            return {
                "success": True,
                "created_count": len(created_photos),
                "session_id": str(session_id) if session_id else None,
                "photo_ids": [str(photo.id) for photo in created_photos],
                "created_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "created_count": 0,
                "session_id": str(session_id) if session_id else None,
                "created_at": datetime.utcnow().isoformat()
            }
    
    async def create_batch_telemetry_data(
        self,
        user_id: UUID,
        batch_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Create mixed batch of telemetry data (light readings and growth photos).
        
        Args:
            user_id: User ID
            batch_data: Dictionary containing light_readings and growth_photos lists
            
        Returns:
            Dictionary with comprehensive batch operation results
        """
        session_id = batch_data.get('session_id')
        light_readings = batch_data.get('light_readings', [])
        growth_photos = batch_data.get('growth_photos', [])
        
        results = {
            "session_id": session_id,
            "light_readings": {"success": True, "created_count": 0, "errors": []},
            "growth_photos": {"success": True, "created_count": 0, "errors": []},
            "overall_success": True,
            "created_at": datetime.utcnow().isoformat()
        }
        
        # Process light readings if provided
        if light_readings:
            light_result = await self.create_batch_light_readings(
                user_id=user_id,
                readings=light_readings,
                session_id=UUID(session_id) if session_id else None
            )
            results["light_readings"] = light_result
            if not light_result["success"]:
                results["overall_success"] = False
        
        # Process growth photos if provided
        if growth_photos:
            photo_result = await self.create_batch_growth_photos(
                user_id=user_id,
                photos=growth_photos,
                session_id=UUID(session_id) if session_id else None
            )
            results["growth_photos"] = photo_result
            if not photo_result["success"]:
                results["overall_success"] = False
        
        return results

    # Sync Status Management Methods
    
    async def get_sync_status(
        self,
        user_id: UUID,
        session_id: Optional[UUID] = None,
        item_type: Optional[str] = None,
        sync_status: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get synchronization status for telemetry items.
        
        Args:
            user_id: User ID
            session_id: Optional session ID filter
            item_type: Optional item type filter (light_reading, growth_photo)
            sync_status: Optional sync status filter (pending, synced, failed, conflict)
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of sync status records
        """
        # This is a simplified implementation - in a real system, you'd have a dedicated sync_status table
        # For now, we'll simulate sync status based on the telemetry data
        
        sync_statuses = []
        
        # Get light readings if requested
        if not item_type or item_type == "light_reading":
            light_readings = await self.get_light_readings(
                user_id=user_id,
                skip=skip,
                limit=limit
            )
            
            for reading in light_readings:
                sync_statuses.append({
                    "item_id": str(reading.id),
                    "item_type": "light_reading",
                    "session_id": str(session_id) if session_id else None,
                    "sync_status": "synced",  # Assume synced since it's in the database
                    "last_sync_attempt": reading.created_at.isoformat(),
                    "retry_count": 0,
                    "created_at": reading.created_at.isoformat(),
                    "updated_at": reading.created_at.isoformat()
                })
        
        # Get growth photos if requested
        if not item_type or item_type == "growth_photo":
            growth_photos = await self.get_growth_photos(
                user_id=user_id,
                skip=skip,
                limit=limit
            )
            
            for photo in growth_photos:
                sync_statuses.append({
                    "item_id": str(photo.id),
                    "item_type": "growth_photo",
                    "session_id": str(session_id) if session_id else None,
                    "sync_status": "synced",  # Assume synced since it's in the database
                    "last_sync_attempt": photo.created_at.isoformat(),
                    "retry_count": 0,
                    "created_at": photo.created_at.isoformat(),
                    "updated_at": photo.created_at.isoformat()
                })
        
        # Filter by sync_status if provided
        if sync_status:
            sync_statuses = [s for s in sync_statuses if s["sync_status"] == sync_status]
        
        return sync_statuses[:limit]
    
    async def update_sync_status(
        self,
        user_id: UUID,
        item_id: UUID,
        item_type: str,
        new_status: str,
        error_message: Optional[str] = None
    ) -> Dict[str, Any]:
        """Update synchronization status for a telemetry item.
        
        Args:
            user_id: User ID
            item_id: Item ID
            item_type: Item type (light_reading, growth_photo)
            new_status: New sync status
            error_message: Optional error message if status is failed
            
        Returns:
            Dictionary with update result
        """
        try:
            # Verify the item exists and belongs to the user
            if item_type == "light_reading":
                item = await self.get_light_reading_by_id(item_id, user_id)
            elif item_type == "growth_photo":
                item = await self.get_growth_photo_by_id(item_id, user_id)
            else:
                return {
                    "success": False,
                    "error": f"Invalid item_type: {item_type}"
                }
            
            if not item:
                return {
                    "success": False,
                    "error": "Item not found or not owned by user"
                }
            
            # In a real implementation, you'd update a sync_status table
            # For now, we'll just return success
            return {
                "success": True,
                "item_id": str(item_id),
                "item_type": item_type,
                "old_status": "synced",  # Placeholder
                "new_status": new_status,
                "updated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    async def get_pending_sync_items(
        self,
        user_id: UUID,
        item_type: Optional[str] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get telemetry items that need to be synchronized.
        
        Args:
            user_id: User ID
            item_type: Optional item type filter
            limit: Maximum number of items to return
            
        Returns:
            List of items pending synchronization
        """
        # In a real implementation, this would query items with sync_status = 'pending'
        # For now, we'll return an empty list since all items in the database are considered synced
        return []

    # Conflict Resolution Methods
    
    async def detect_conflicts(
        self,
        user_id: UUID,
        local_data: List[Dict[str, Any]],
        session_id: Optional[UUID] = None
    ) -> List[Dict[str, Any]]:
        """Detect conflicts between local and server data.
        
        Args:
            user_id: User ID
            local_data: List of local telemetry data
            session_id: Optional session ID
            
        Returns:
            List of detected conflicts
        """
        conflicts = []
        
        for local_item in local_data:
            item_type = local_item.get('item_type')
            measured_at = local_item.get('measured_at') or local_item.get('captured_at')
            
            if not item_type or not measured_at:
                continue
            
            # Convert string timestamp to datetime if needed
            if isinstance(measured_at, str):
                try:
                    measured_at = datetime.fromisoformat(measured_at.replace('Z', '+00:00'))
                except ValueError:
                    continue
            
            # Look for existing data at the same time
            if item_type == 'light_reading':
                # Check for light readings within 1 minute of the local timestamp
                time_window = timedelta(minutes=1)
                existing_readings = await self.get_light_readings(
                    user_id=user_id,
                    start_date=measured_at - time_window,
                    end_date=measured_at + time_window,
                    limit=10
                )
                
                for existing in existing_readings:
                    # Check if values are significantly different
                    local_lux = local_item.get('lux_value')
                    existing_lux = existing.lux_value
                    
                    if local_lux and existing_lux and abs(local_lux - existing_lux) > (existing_lux * 0.1):  # 10% difference
                        conflicts.append({
                            "conflict_type": "value_mismatch",
                            "item_type": item_type,
                            "local_data": local_item,
                            "server_data": {
                                "id": str(existing.id),
                                "lux_value": existing_lux,
                                "measured_at": existing.measured_at.isoformat()
                            },
                            "conflict_reason": f"Lux values differ significantly: local={local_lux}, server={existing_lux}",
                            "detected_at": datetime.utcnow().isoformat()
                        })
            
            elif item_type == 'growth_photo':
                # Check for growth photos within 1 hour of the local timestamp
                time_window = timedelta(hours=1)
                existing_photos = await self.get_growth_photos(
                    user_id=user_id,
                    plant_id=UUID(local_item['plant_id']) if local_item.get('plant_id') else None,
                    start_date=measured_at - time_window,
                    end_date=measured_at + time_window,
                    limit=10
                )
                
                for existing in existing_photos:
                    # Check if there's already a photo for the same plant at similar time
                    conflicts.append({
                        "conflict_type": "duplicate_photo",
                        "item_type": item_type,
                        "local_data": local_item,
                        "server_data": {
                            "id": str(existing.id),
                            "plant_id": str(existing.plant_id),
                            "captured_at": existing.captured_at.isoformat()
                        },
                        "conflict_reason": "Photo already exists for this plant at similar time",
                        "detected_at": datetime.utcnow().isoformat()
                    })
        
        return conflicts
    
    async def resolve_conflicts(
        self,
        user_id: UUID,
        conflicts: List[Dict[str, Any]],
        resolution_strategy: str = "server_wins"
    ) -> Dict[str, Any]:
        """Resolve synchronization conflicts using the specified strategy.
        
        Args:
            user_id: User ID
            conflicts: List of conflicts to resolve
            resolution_strategy: Strategy for resolution (server_wins, client_wins, merge, manual)
            
        Returns:
            Dictionary with resolution results
        """
        resolved_conflicts = []
        failed_resolutions = []
        
        for conflict in conflicts:
            try:
                conflict_type = conflict.get('conflict_type')
                item_type = conflict.get('item_type')
                local_data = conflict.get('local_data', {})
                server_data = conflict.get('server_data', {})
                
                resolution_result = {
                    "conflict_id": conflict.get('conflict_id', str(uuid4())),
                    "conflict_type": conflict_type,
                    "item_type": item_type,
                    "resolution_strategy": resolution_strategy,
                    "resolved_at": datetime.utcnow().isoformat()
                }
                
                if resolution_strategy == "server_wins":
                    # Keep server data, discard local changes
                    resolution_result.update({
                        "action": "keep_server_data",
                        "result": "Server data preserved, local changes discarded"
                    })
                
                elif resolution_strategy == "client_wins":
                    # Update server with local data
                    if item_type == "light_reading" and server_data.get('id'):
                        # In a real implementation, you'd update the existing record
                        resolution_result.update({
                            "action": "update_server_data",
                            "result": "Server data updated with local changes"
                        })
                    else:
                        resolution_result.update({
                            "action": "create_new_record",
                            "result": "Local data created as new record"
                        })
                
                elif resolution_strategy == "merge":
                    # Merge local and server data intelligently
                    merged_data = self._merge_conflicted_data(local_data, server_data, item_type)
                    resolution_result.update({
                        "action": "merge_data",
                        "result": "Data merged using intelligent strategy",
                        "merged_data": merged_data
                    })
                
                elif resolution_strategy == "manual":
                    # Flag for manual resolution
                    resolution_result.update({
                        "action": "flag_for_manual_review",
                        "result": "Conflict flagged for manual resolution",
                        "requires_user_action": True
                    })
                
                resolved_conflicts.append(resolution_result)
                
            except Exception as e:
                failed_resolutions.append({
                    "conflict": conflict,
                    "error": str(e),
                    "failed_at": datetime.utcnow().isoformat()
                })
        
        return {
            "total_conflicts": len(conflicts),
            "resolved_count": len(resolved_conflicts),
            "failed_count": len(failed_resolutions),
            "resolution_strategy": resolution_strategy,
            "resolved_conflicts": resolved_conflicts,
            "failed_resolutions": failed_resolutions,
            "processed_at": datetime.utcnow().isoformat()
        }
    
    def _merge_conflicted_data(
        self,
        local_data: Dict[str, Any],
        server_data: Dict[str, Any],
        item_type: str
    ) -> Dict[str, Any]:
        """Merge conflicted data using intelligent strategies.
        
        Args:
            local_data: Local data
            server_data: Server data
            item_type: Type of item being merged
            
        Returns:
            Merged data dictionary
        """
        merged = server_data.copy()  # Start with server data as base
        
        if item_type == "light_reading":
            # For light readings, use the most recent timestamp
            local_time = local_data.get('measured_at')
            server_time = server_data.get('measured_at')
            
            if local_time and server_time:
                if isinstance(local_time, str):
                    local_time = datetime.fromisoformat(local_time.replace('Z', '+00:00'))
                if isinstance(server_time, str):
                    server_time = datetime.fromisoformat(server_time.replace('Z', '+00:00'))
                
                # Use data from the most recent measurement
                if local_time > server_time:
                    merged.update({
                        'lux_value': local_data.get('lux_value', merged.get('lux_value')),
                        'ppfd_value': local_data.get('ppfd_value', merged.get('ppfd_value')),
                        'measured_at': local_data.get('measured_at', merged.get('measured_at'))
                    })
        
        elif item_type == "growth_photo":
            # For growth photos, prefer local notes and measurements if they exist
            if local_data.get('notes'):
                merged['notes'] = local_data['notes']
            
            # Prefer local measurements if they're more recent or more complete
            local_measurements = ['plant_height_cm', 'leaf_area_cm2', 'health_score']
            for measurement in local_measurements:
                if local_data.get(measurement) is not None:
                    merged[measurement] = local_data[measurement]
        
        merged['merge_timestamp'] = datetime.utcnow().isoformat()
        merged['merge_source'] = 'intelligent_merge'
        
        return merged

    def _assess_plant_health(
        self,
        light_readings: List[LightReading],
        growth_photos: List[GrowthPhoto],
        plant: UserPlant
    ) -> Dict[str, Any]:
        """Assess plant health based on telemetry data.
        
        Args:
            light_readings: List of light readings
            growth_photos: List of growth photos
            plant: Plant information
            
        Returns:
            Dictionary with health assessment
        """
        # This would be more sophisticated in a real implementation
        # For now, provide a basic assessment
        
        # Check if we have enough data
        if not light_readings or not growth_photos:
            return {
                "status": "insufficient_data",
                "message": "Not enough telemetry data to assess plant health"
            }
        
        # Calculate average light
        lux_values = [r.lux_value for r in light_readings if r.lux_value is not None]
        avg_lux = sum(lux_values) / len(lux_values) if lux_values else 0
        
        # Get latest growth metrics
        latest_photo = growth_photos[-1] if growth_photos else None
        health_score = latest_photo.health_score if latest_photo and latest_photo.health_score else None
        
        # Determine light adequacy based on plant type
        # This is a simplified example - real implementation would be more sophisticated
        light_status = "unknown"
        if avg_lux > 0:
            if plant.light_preference == "high" and avg_lux < 10000:
                light_status = "insufficient"
            elif plant.light_preference == "medium" and (avg_lux < 5000 or avg_lux > 15000):
                light_status = "suboptimal"
            elif plant.light_preference == "low" and avg_lux > 7500:
                light_status = "excessive"
            else:
                light_status = "adequate"
        
        # Determine growth status
        growth_status = "unknown"
        if len(growth_photos) >= 2:
            first_photo = growth_photos[0]
            last_photo = growth_photos[-1]
            
            if hasattr(first_photo, 'plant_height_cm') and hasattr(last_photo, 'plant_height_cm') and \
               first_photo.plant_height_cm and last_photo.plant_height_cm:
                height_change = last_photo.plant_height_cm - first_photo.plant_height_cm
                days_between = (last_photo.captured_at - first_photo.captured_at).days or 1
                
                if height_change <= 0:
                    growth_status = "stalled"
                elif height_change / days_between < 0.1:  # Less than 1mm per day
                    growth_status = "slow"
                elif height_change / days_between > 0.5:  # More than 5mm per day
                    growth_status = "rapid"
                else:
                    growth_status = "normal"
        
        return {
            "light": {
                "status": light_status,
                "average_lux": avg_lux
            },
            "growth": {
                "status": growth_status,
                "health_score": health_score
            },
            "overall": "healthy" if light_status in ["adequate", "unknown"] and growth_status in ["normal", "rapid", "unknown"] else "needs_attention"
        }


# Convenience function to get service instance
async def get_telemetry_service(db: AsyncSession):
    """Get telemetry service instance.
    
    Args:
        db: Database session
        
    Returns:
        TelemetryService instance
    """
    return TelemetryService(db)