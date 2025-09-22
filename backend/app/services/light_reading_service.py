"""Light reading service.

This module provides functionality for managing light readings, including
creating, retrieving, and analyzing light measurement data.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Union
from uuid import UUID
from collections import Counter

from sqlalchemy import desc, func, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import Session

from app.models.light_reading import LightReading, LightSource
from app.models.user import User
from app.schemas.telemetry import LightReadingCreate, LightReadingResponse


class LightReadingService:
    """Service for managing light readings.
    
    Provides methods for creating, retrieving, and analyzing light readings.
    """
    
    def __init__(self, db: Union[Session, AsyncSession]):
        """Initialize light reading service.
        
        Args:
            db: Database session
        """
        self.db = db
    
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
        # Build query with filters
        query = select(LightReading).filter(LightReading.user_id == user_id)
        
        # Apply filters if provided
        if plant_id:
            query = query.filter(LightReading.plant_id == plant_id)
        
        if source:
            query = query.filter(LightReading.source == source)
        
        if location_name:
            query = query.filter(LightReading.location_name == location_name)
        
        if start_date:
            query = query.filter(LightReading.measured_at >= start_date)
        
        if end_date:
            query = query.filter(LightReading.measured_at <= end_date)
        
        if min_lux is not None:
            query = query.filter(LightReading.lux_value >= min_lux)
        
        if max_lux is not None:
            query = query.filter(LightReading.lux_value <= max_lux)
        
        # Order by measured_at descending (newest first)
        query = query.order_by(desc(LightReading.measured_at))
        
        # Apply pagination
        query = query.offset(skip).limit(limit)
        
        # Execute query
        result = await self.db.execute(query)
        return result.scalars().all()
    
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
        query = select(LightReading).filter(
            LightReading.id == reading_id,
            LightReading.user_id == user_id
        )
        
        result = await self.db.execute(query)
        return result.scalars().first()
    
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
        # Create new light reading object
        db_light_reading = LightReading(
            user_id=user_id,
            plant_id=light_reading.plant_id,
            lux_value=light_reading.lux_value,
            ppfd_value=light_reading.ppfd_value,
            source=light_reading.source,
            location_name=light_reading.location_name,
            gps_latitude=light_reading.gps_latitude,
            gps_longitude=light_reading.gps_longitude,
            altitude=light_reading.altitude,
            temperature=light_reading.temperature,
            humidity=light_reading.humidity,
            calibration_profile_id=light_reading.calibration_profile_id,
            device_id=light_reading.device_id,
            ble_device_id=light_reading.ble_device_id,
            raw_data=light_reading.raw_data,
            measured_at=light_reading.measured_at or datetime.utcnow()
        )
        
        # Add to database and commit
        self.db.add(db_light_reading)
        await self.db.commit()
        await self.db.refresh(db_light_reading)
        
        return db_light_reading
    
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
        created_readings = []
        
        for reading in readings:
            db_light_reading = LightReading(
                user_id=user_id,
                plant_id=reading.plant_id,
                lux_value=reading.lux_value,
                ppfd_value=reading.ppfd_value,
                source=reading.source,
                location_name=reading.location_name,
                gps_latitude=reading.gps_latitude,
                gps_longitude=reading.gps_longitude,
                altitude=reading.altitude,
                temperature=reading.temperature,
                humidity=reading.humidity,
                calibration_profile_id=reading.calibration_profile_id,
                device_id=reading.device_id,
                ble_device_id=reading.ble_device_id,
                raw_data=reading.raw_data,
                measured_at=reading.measured_at or datetime.utcnow()
            )
            self.db.add(db_light_reading)
            created_readings.append(db_light_reading)
        
        await self.db.commit()
        
        # Refresh all readings to get their IDs and relationships
        for reading in created_readings:
            await self.db.refresh(reading)
        
        return created_readings
    
    async def get_light_statistics(
        self,
        user_id: UUID,
        plant_id: Optional[UUID] = None,
        days: int = 7
    ) -> Dict[str, Any]:
        """Get light reading statistics for a user or plant.
        
        Args:
            user_id: User ID
            plant_id: Optional plant ID to filter statistics
            days: Number of days to include in statistics
            
        Returns:
            Dictionary with light statistics including averages, min/max values,
            reading counts, and source distribution
        """
        # Calculate date range
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Base query filters
        filters = [
            LightReading.user_id == user_id,
            LightReading.measured_at >= start_date,
            LightReading.measured_at <= end_date
        ]
        
        # Add plant filter if provided
        if plant_id:
            filters.append(LightReading.plant_id == plant_id)
        
        # Get all readings within the date range
        query = select(LightReading).filter(and_(*filters))
        result = await self.db.execute(query)
        readings = result.scalars().all()
        
        # If no readings found, return empty statistics
        if not readings:
            return {
                "count": 0,
                "date_range": {
                    "start": start_date,
                    "end": end_date
                },
                "averages": {
                    "lux": None,
                    "ppfd": None
                },
                "min_max": {
                    "min_lux": None,
                    "max_lux": None,
                    "min_ppfd": None,
                    "max_ppfd": None
                },
                "sources": {},
                "locations": {},
                "readings_by_day": []
            }
        
        # Calculate statistics
        lux_values = [r.lux_value for r in readings if r.lux_value is not None]
        ppfd_values = [r.ppfd_value for r in readings if r.ppfd_value is not None]
        
        # Count readings by source and location
        sources_counter = Counter([r.source.value for r in readings if r.source])
        locations_counter = Counter([r.location_name for r in readings if r.location_name])
        
        # Group readings by day for trend analysis
        readings_by_day = {}
        for r in readings:
            day_key = r.measured_at.date().isoformat()
            if day_key not in readings_by_day:
                readings_by_day[day_key] = {
                    "date": day_key,
                    "count": 0,
                    "lux_values": [],
                    "ppfd_values": []
                }
            
            readings_by_day[day_key]["count"] += 1
            if r.lux_value is not None:
                readings_by_day[day_key]["lux_values"].append(r.lux_value)
            if r.ppfd_value is not None:
                readings_by_day[day_key]["ppfd_values"].append(r.ppfd_value)
        
        # Calculate daily averages
        daily_stats = []
        for day, data in sorted(readings_by_day.items()):
            lux_avg = sum(data["lux_values"]) / len(data["lux_values"]) if data["lux_values"] else None
            ppfd_avg = sum(data["ppfd_values"]) / len(data["ppfd_values"]) if data["ppfd_values"] else None
            
            daily_stats.append({
                "date": day,
                "count": data["count"],
                "avg_lux": lux_avg,
                "avg_ppfd": ppfd_avg
            })
        
        # Compile statistics
        return {
            "count": len(readings),
            "date_range": {
                "start": start_date,
                "end": end_date
            },
            "averages": {
                "lux": sum(lux_values) / len(lux_values) if lux_values else None,
                "ppfd": sum(ppfd_values) / len(ppfd_values) if ppfd_values else None
            },
            "min_max": {
                "min_lux": min(lux_values) if lux_values else None,
                "max_lux": max(lux_values) if lux_values else None,
                "min_ppfd": min(ppfd_values) if ppfd_values else None,
                "max_ppfd": max(ppfd_values) if ppfd_values else None
            },
            "sources": dict(sources_counter),
            "locations": dict(locations_counter),
            "readings_by_day": daily_stats
        }
        
        # Calculate date range
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Build base query
        query = select(
            func.avg(LightReading.lux_value).label('avg_lux'),
            func.min(LightReading.lux_value).label('min_lux'),
            func.max(LightReading.lux_value).label('max_lux'),
            func.count(LightReading.id).label('reading_count')
        ).filter(
            LightReading.user_id == user_id,
            LightReading.measured_at >= start_date,
            LightReading.measured_at <= end_date
        )
        
        # Filter by plant if provided
        if plant_id:
            query = query.filter(LightReading.plant_id == plant_id)
        
        # Execute query
        result = await self.db.execute(query)
        stats = result.first()
        
        # Get source distribution
        source_query = select(
            LightReading.source,
            func.count(LightReading.id).label('count')
        ).filter(
            LightReading.user_id == user_id,
            LightReading.measured_at >= start_date,
            LightReading.measured_at <= end_date
        )
        
        if plant_id:
            source_query = source_query.filter(LightReading.plant_id == plant_id)
        
        source_query = source_query.group_by(LightReading.source)
        source_result = await self.db.execute(source_query)
        source_distribution = {row.source: row.count for row in source_result}
        
        # Compile statistics
        return {
            'avg_lux': stats.avg_lux if stats.avg_lux else 0,
            'min_lux': stats.min_lux if stats.min_lux else 0,
            'max_lux': stats.max_lux if stats.max_lux else 0,
            'reading_count': stats.reading_count,
            'source_distribution': source_distribution,
            'date_range': {
                'start': start_date.isoformat(),
                'end': end_date.isoformat()
            }
        }