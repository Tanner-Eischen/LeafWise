"""Growth photo database model.

This module defines the GrowthPhoto model for tracking plant development
with extracted growth metrics and analysis results.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Integer, Text, Boolean, JSON, Index
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class GrowthPhoto(Base):
    """Growth photo model for tracking plant development.
    
    Stores photos with extracted growth metrics and analysis results.
    """
    
    __tablename__ = "growth_photos"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    
    # Photo metadata
    file_path = Column(String(500), nullable=False)  # Storage path
    file_size = Column(Integer, nullable=True)  # Bytes
    image_width = Column(Integer, nullable=True)  # Pixels
    image_height = Column(Integer, nullable=True)  # Pixels
    
    # Growth metrics (extracted by ML)
    leaf_area_cm2 = Column(Float, nullable=True)  # Total leaf area in cm²
    plant_height_cm = Column(Float, nullable=True)  # Height in centimeters
    leaf_count = Column(Integer, nullable=True)  # Number of leaves detected
    stem_width_mm = Column(Float, nullable=True)  # Stem width in millimeters
    
    # Health indicators
    health_score = Column(Float, nullable=True)  # Overall health (0-100)
    chlorophyll_index = Column(Float, nullable=True)  # Greenness indicator
    disease_indicators = Column(JSON, nullable=True)  # Array of detected issues
    
    # Analysis metadata
    processing_version = Column(String(20), nullable=True)  # ML model version
    confidence_scores = Column(JSON, nullable=True)  # Per-metric confidence
    analysis_duration_ms = Column(Integer, nullable=True)  # Processing time
    
    # Location and lighting context
    location_name = Column(String(100), nullable=True)
    ambient_light_lux = Column(Float, nullable=True)  # Light during photo
    
    # Camera settings
    camera_settings = Column(JSON, nullable=True)  # ISO, exposure, etc.
    
    # Metadata
    notes = Column(Text, nullable=True)
    is_processed = Column(Boolean, default=False)
    processing_error = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    captured_at = Column(DateTime, nullable=False)  # When photo was taken
    processed_at = Column(DateTime, nullable=True)  # When analysis completed
    
    # Relationships
    user = relationship("User")
    plant = relationship("UserPlant")
    light_readings = relationship("LightReading", back_populates="growth_photo")
    
    # Indexes
    __table_args__ = (
        Index('ix_growth_photos_user_id', 'user_id'),
        Index('ix_growth_photos_plant_id', 'plant_id'),
        Index('ix_growth_photos_captured_at', 'captured_at'),
        Index('ix_growth_photos_is_processed', 'is_processed'),
        Index('ix_growth_photos_plant_captured', 'plant_id', 'captured_at'),
    )
    
    def __repr__(self) -> str:
        return f"<GrowthPhoto(id={self.id}, plant_id={self.plant_id}, processed={self.is_processed})>"
    
    @property
    def growth_rate_indicator(self) -> Optional[str]:
        """Get growth rate indicator based on metrics.
        
        Returns:
            Optional[str]: Growth rate category
        """
        if not self.is_processed or not self.leaf_area_cm2:
            return None
        
        # This would typically compare with previous photos
        # For now, return based on absolute values
        if self.leaf_area_cm2 > 100:
            return "vigorous"
        elif self.leaf_area_cm2 > 50:
            return "moderate"
        else:
            return "slow"