"""Plant species database model.

This module defines the PlantSpecies model for storing plant species information
including care requirements, toxicity info, and other plant characteristics.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Integer, Text, DateTime, Boolean, ARRAY
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantSpecies(Base):
    """Plant species model for storing plant information."""
    
    __tablename__ = "plant_species"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    scientific_name = Column(String(255), nullable=False, unique=True)
    common_names = Column(ARRAY(String), nullable=False, default=[])
    family = Column(String(100))
    care_level = Column(String(20))  # easy, moderate, difficult
    light_requirements = Column(String(50))
    water_frequency_days = Column(Integer)
    humidity_preference = Column(String(20))
    temperature_range = Column(String(50))
    toxicity_info = Column(Text)
    care_notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user_plants = relationship("UserPlant", back_populates="species")
    identifications = relationship("PlantIdentification", back_populates="species")
    trades = relationship("PlantTrade", back_populates="species")
    questions = relationship("PlantQuestion", back_populates="species")
    
    def __repr__(self) -> str:
        return f"<PlantSpecies(id={self.id}, scientific_name='{self.scientific_name}')>"