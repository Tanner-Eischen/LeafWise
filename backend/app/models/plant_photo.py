"""Plant photo database model.

This module defines the PlantPhoto model for storing plant images
and progress photos.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantPhoto(Base):
    """Plant photo model for storing plant images."""
    
    __tablename__ = "plant_photos"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    file_path = Column(String(500), nullable=False)
    caption = Column(Text)
    is_progress_photo = Column(Boolean, default=False)
    taken_at = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="photos")
    
    def __repr__(self) -> str:
        return f"<PlantPhoto(id={self.id}, plant_id={self.plant_id}, file_path='{self.file_path}')>"