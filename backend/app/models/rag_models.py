"""RAG-specific database models for embeddings and interactions."""

from datetime import datetime
from uuid import UUID, uuid4
from typing import Optional, List

from sqlalchemy import Column, String, Text, DateTime, Integer, ForeignKey, DECIMAL, Index
from sqlalchemy.dialects.postgresql import UUID as PGUUID, JSONB
from sqlalchemy.orm import relationship
from pgvector.sqlalchemy import Vector

from app.core.database import Base
from app.utils.datetime_utils import utc_now


class PlantContentEmbedding(Base):
    """Vector embeddings for plant-related content."""
    __tablename__ = "plant_content_embeddings"
    
    id = Column(PGUUID, primary_key=True, default=uuid4)
    content_type = Column(String(50), nullable=False)  # species_info, care_guide, user_post, qa_answer
    content_id = Column(PGUUID, nullable=False)  # References to specific content
    embedding = Column(Vector(1536), nullable=False)  # OpenAI embedding dimension
    meta_data = Column(JSONB, nullable=True)  # Additional context (species, difficulty, season, etc.)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)
    
    # Index for vector similarity search
    __table_args__ = (
        Index('ix_plant_content_embeddings_vector', 'embedding', postgresql_using='ivfflat', 
              postgresql_with={'lists': 100}, postgresql_ops={'embedding': 'vector_cosine_ops'}),
        Index('ix_plant_content_embeddings_type', 'content_type'),
        Index('ix_plant_content_embeddings_content_id', 'content_id'),
    )


class UserPreferenceEmbedding(Base):
    """User preference embeddings for personalization."""
    __tablename__ = "user_preference_embeddings"
    
    id = Column(PGUUID, primary_key=True, default=uuid4)
    user_id = Column(PGUUID, ForeignKey("users.id"), nullable=False)
    preference_type = Column(String(50), nullable=False)  # plant_interests, care_style, content_preferences
    embedding = Column(Vector(1536), nullable=False)
    confidence_score = Column(DECIMAL(3, 2), nullable=True)
    meta_data = Column(JSONB, nullable=True)  # Additional preference context
    last_updated = Column(DateTime, default=utc_now, onupdate=utc_now)
    created_at = Column(DateTime, default=utc_now)
    
    # Relationships
    user = relationship("User", back_populates="preference_embeddings")
    
    # Index for vector similarity search
    __table_args__ = (
        Index('ix_user_preference_embeddings_vector', 'embedding', postgresql_using='ivfflat', 
              postgresql_with={'lists': 100}, postgresql_ops={'embedding': 'vector_cosine_ops'}),
        Index('ix_user_preference_embeddings_user', 'user_id'),
        Index('ix_user_preference_embeddings_type', 'preference_type'),
    )


class RAGInteraction(Base):
    """Log of RAG interactions for analytics and improvement."""
    __tablename__ = "rag_interactions"
    
    id = Column(PGUUID, primary_key=True, default=uuid4)
    user_id = Column(PGUUID, ForeignKey("users.id"), nullable=False)
    interaction_type = Column(String(50), nullable=False)  # care_advice, content_generation, recommendation
    query_text = Column(Text, nullable=True)
    query_embedding = Column(Vector(1536), nullable=True)
    retrieved_documents = Column(JSONB, nullable=True)  # Retrieved document metadata
    generated_response = Column(Text, nullable=True)
    user_feedback = Column(Integer, nullable=True)  # 1-5 rating
    response_time_ms = Column(Integer, nullable=True)
    confidence_score = Column(DECIMAL(3, 2), nullable=True)
    meta_data = Column(JSONB, nullable=True)  # Additional interaction context
    created_at = Column(DateTime, default=utc_now)
    
    # Relationships
    user = relationship("User", back_populates="rag_interactions")
    
    # Index for vector similarity search and analytics
    __table_args__ = (
        Index('ix_rag_interactions_vector', 'query_embedding', postgresql_using='ivfflat', 
              postgresql_with={'lists': 100}, postgresql_ops={'query_embedding': 'vector_cosine_ops'}),
        Index('ix_rag_interactions_user', 'user_id'),
        Index('ix_rag_interactions_type', 'interaction_type'),
        Index('ix_rag_interactions_created', 'created_at'),
    )


class PlantKnowledgeBase(Base):
    """Structured plant knowledge for RAG retrieval."""
    __tablename__ = "plant_knowledge_base"
    
    id = Column(PGUUID, primary_key=True, default=uuid4)
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)
    content_type = Column(String(50), nullable=False)  # care_guide, species_info, technique, problem_solution
    plant_species_id = Column(PGUUID, ForeignKey("plant_species.id"), nullable=True)
    difficulty_level = Column(String(20), nullable=True)  # beginner, intermediate, advanced
    season = Column(String(20), nullable=True)  # spring, summer, fall, winter, year_round
    climate_zones = Column(JSONB, nullable=True)  # List of applicable climate zones
    tags = Column(JSONB, nullable=True)  # Searchable tags
    source = Column(String(100), nullable=True)  # expert, research, community
    author_id = Column(PGUUID, ForeignKey("users.id"), nullable=True)
    verified = Column(String(20), default='pending')  # pending, verified, rejected
    view_count = Column(Integer, default=0)
    helpful_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)
    
    # Relationships
    plant_species = relationship("PlantSpecies", back_populates="knowledge_base_entries")
    author = relationship("User", back_populates="knowledge_contributions")
    embedding = relationship("PlantContentEmbedding", 
                           primaryjoin="PlantKnowledgeBase.id == foreign(PlantContentEmbedding.content_id)",
                           uselist=False)
    
    __table_args__ = (
        Index('ix_plant_knowledge_base_species', 'plant_species_id'),
        Index('ix_plant_knowledge_base_type', 'content_type'),
        Index('ix_plant_knowledge_base_difficulty', 'difficulty_level'),
        Index('ix_plant_knowledge_base_verified', 'verified'),
    )


class SemanticSearchCache(Base):
    """Cache for semantic search results to improve performance."""
    __tablename__ = "semantic_search_cache"
    
    id = Column(PGUUID, primary_key=True, default=uuid4)
    query_hash = Column(String(64), nullable=False, unique=True)  # SHA-256 of query + filters
    query_embedding = Column(Vector(1536), nullable=False)
    results = Column(JSONB, nullable=False)  # Cached search results
    filters_hash = Column(String(64), nullable=True)  # Hash of applied filters
    hit_count = Column(Integer, default=0)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=utc_now)
    last_accessed = Column(DateTime, default=utc_now)
    
    __table_args__ = (
        Index('ix_semantic_search_cache_query_hash', 'query_hash'),
        Index('ix_semantic_search_cache_expires', 'expires_at'),
    )