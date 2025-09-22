"""Plant question database model.

This module defines the PlantQuestion and PlantAnswer models
for the Q&A community functionality.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PlantQuestion(Base):
    """Plant question model for Q&A functionality."""
    
    __tablename__ = "plant_questions"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    species_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_species.id"), nullable=True)
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)
    image_paths = Column(Text)  # JSON array of image paths
    tags = Column(Text)  # JSON array of tags
    is_solved = Column(Boolean, default=False)
    view_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    species = relationship("PlantSpecies", back_populates="questions")
    answers = relationship("PlantAnswer", back_populates="question")
    
    def __repr__(self) -> str:
        return f"<PlantQuestion(id={self.id}, title='{self.title}', user_id={self.user_id})>"


class PlantAnswer(Base):
    """Plant answer model for Q&A functionality."""
    
    __tablename__ = "plant_answers"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    question_id = Column(PostgresUUID(as_uuid=True), ForeignKey("plant_questions.id"), nullable=False)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    is_accepted = Column(Boolean, default=False)
    upvotes = Column(Integer, default=0)
    downvotes = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    question = relationship("PlantQuestion", back_populates="answers")
    user = relationship("User")
    
    def __repr__(self) -> str:
        return f"<PlantAnswer(id={self.id}, question_id={self.question_id}, user_id={self.user_id})>"