"""Plant identification database model.

This module defines the PlantIdentification model for storing
AI-powered plant identification results.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Float, Boolean
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantIdentification(Base):
    """Plant identification model for AI identification results."""
    
    __tablename__ = "plant_identifications"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    species_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_species.id"), nullable=True)
    image_path = Column(String(500), nullable=False)
    confidence_score = Column(Float)
    identified_name = Column(String(255))
    is_verified = Column(Boolean, default=False)
    verification_notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    species = relationship("PlantSpecies", back_populates="identifications")
    
    def __repr__(self) -> str:
        return f"<PlantIdentification(id={self.id}, identified_name='{self.identified_name}', confidence={self.confidence_score})>"