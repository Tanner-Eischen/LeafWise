"""Plant care log database model.

This module defines the PlantCareLog model for tracking care activities
performed on user plants.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantCareLog(Base):
    """Plant care log model for tracking care activities."""
    
    __tablename__ = "plant_care_logs"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    care_type = Column(String(50), nullable=False)  # watering, fertilizing, repotting, pruning, etc.
    notes = Column(Text)
    performed_at = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    plant = relationship("UserPlant", back_populates="care_logs")
    
    def __repr__(self) -> str:
        return f"<PlantCareLog(id={self.id}, care_type='{self.care_type}', plant_id={self.plant_id})>"