"""
Environmental Data Cache Model
Manages cached environmental data for efficient retrieval and storage
"""
from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, Integer, Text
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, JSONB, DATERANGE
from sqlalchemy.sql import func

from app.core.database import Base


class EnvironmentalDataCache(Base):
    """
    Environmental data cache for storing weather and environmental conditions
    
    This model caches environmental data to reduce API calls and improve performance.
    Data is stored with location-based hashing and expiration times.
    """
    __tablename__ = "environmental_data_cache"

    id: UUID = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    location_hash: str = Column(String(100), nullable=False, index=True)
    data_type: str = Column(String(50), nullable=False, index=True)
    date_range = Column(DATERANGE, nullable=False)
    data: Dict[str, Any] = Column(JSONB, nullable=False)
    source: Optional[str] = Column(String(100), nullable=True)
    expires_at: datetime = Column(DateTime, nullable=False)
    hit_count: Optional[int] = Column(Integer, nullable=True, default=0)
    last_accessed: Optional[datetime] = Column(DateTime, nullable=True)
    created_at: datetime = Column(DateTime, nullable=False, default=func.now())

    def __repr__(self) -> str:
        return f"<EnvironmentalDataCache(id={self.id}, location_hash={self.location_hash}, data_type={self.data_type})>"

    def is_expired(self) -> bool:
        """Check if the cached data has expired"""
        return datetime.utcnow() > self.expires_at

    def increment_hit_count(self) -> None:
        """Increment the hit count and update last accessed time"""
        self.hit_count = (self.hit_count or 0) + 1
        self.last_accessed = datetime.utcnow()

    @property
    def age_minutes(self) -> int:
        """Get the age of the cached data in minutes"""
        return int((datetime.utcnow() - self.created_at).total_seconds() / 60)