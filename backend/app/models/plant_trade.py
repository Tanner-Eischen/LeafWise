"""Plant trade database model.

This module defines the PlantTrade model for the plant trading
marketplace functionality.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship
from enum import Enum

from app.core.database import Base


class TradeStatus(str, Enum):
    """Trade status enumeration."""
    AVAILABLE = "available"
    PENDING = "pending"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class TradeType(str, Enum):
    """Trade type enumeration."""
    TRADE = "trade"
    SELL = "sell"
    GIVE_AWAY = "give_away"


class PlantTrade(Base):
    """Plant trade model for marketplace functionality."""
    
    __tablename__ = "plant_trades"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    owner_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    species_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_species.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    trade_type = Column(SQLEnum(TradeType), nullable=False)
    status = Column(SQLEnum(TradeStatus), default=TradeStatus.AVAILABLE)
    location = Column(String(100))
    price = Column(String(50))  # Can be "Free", "$10", "Trade only", etc.
    image_paths = Column(Text)  # JSON array of image paths
    interested_user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    owner = relationship("User", foreign_keys=[owner_id])
    interested_user = relationship("User", foreign_keys=[interested_user_id])
    species = relationship("PlantSpecies", back_populates="trades")
    
    def __repr__(self) -> str:
        return f"<PlantTrade(id={self.id}, title='{self.title}', trade_type='{self.trade_type}')>"