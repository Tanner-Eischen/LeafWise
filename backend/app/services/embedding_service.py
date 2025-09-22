"""Embedding generation service for RAG system."""

import hashlib
import json
import logging
from typing import List, Dict, Any, Optional, Union
from datetime import datetime, timedelta

import numpy as np
from openai import AsyncOpenAI
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.core.config import settings
from app.models.rag_models import PlantContentEmbedding, UserPreferenceEmbedding, SemanticSearchCache

logger = logging.getLogger(__name__)


class EmbeddingService:
    """Service for generating and managing embeddings."""
    
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.embedding_model = "text-embedding-3-small"
        self.embedding_dimension = 1536
        
    async def generate_text_embedding(self, text: str) -> List[float]:
        """Generate embedding for text content.
        
        Args:
            text: Text to embed
            
        Returns:
            List of embedding values
        """
        try:
            # Clean and prepare text
            cleaned_text = self._clean_text(text)
            
            response = await self.client.embeddings.create(
                model=self.embedding_model,
                input=cleaned_text,
                encoding_format="float"
            )
            
            embedding = response.data[0].embedding
            logger.info(f"Generated embedding for text of length {len(text)}")
            return embedding
            
        except Exception as e:
            logger.error(f"Error generating text embedding: {str(e)}")
            raise
    
    async def generate_batch_embeddings(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for multiple texts in batch.
        
        Args:
            texts: List of texts to embed
            
        Returns:
            List of embedding lists
        """
        try:
            # Clean texts
            cleaned_texts = [self._clean_text(text) for text in texts]
            
            response = await self.client.embeddings.create(
                model=self.embedding_model,
                input=cleaned_texts,
                encoding_format="float"
            )
            
            embeddings = [data.embedding for data in response.data]
            logger.info(f"Generated {len(embeddings)} embeddings in batch")
            return embeddings
            
        except Exception as e:
            logger.error(f"Error generating batch embeddings: {str(e)}")
            raise
    
    async def store_content_embedding(
        self,
        db: AsyncSession,
        content_type: str,
        content_id: str,
        text: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> PlantContentEmbedding:
        """Generate and store content embedding.
        
        Args:
            db: Database session
            content_type: Type of content (species_info, care_guide, etc.)
            content_id: ID of the content
            text: Text content to embed
            metadata: Additional metadata
            
        Returns:
            Created PlantContentEmbedding instance
        """
        try:
            # Generate embedding
            embedding = await self.generate_text_embedding(text)
            
            # Create embedding record
            content_embedding = PlantContentEmbedding(
                content_type=content_type,
                content_id=content_id,
                embedding=embedding,
                meta_data=metadata or {}
            )
            
            db.add(content_embedding)
            await db.commit()
            await db.refresh(content_embedding)
            
            logger.info(f"Stored embedding for {content_type} content {content_id}")
            return content_embedding
            
        except Exception as e:
            await db.rollback()
            logger.error(f"Error storing content embedding: {str(e)}")
            raise
    
    async def update_user_preferences(
        self,
        db: AsyncSession,
        user_id: str,
        preference_type: str,
        preference_data: Dict[str, Any],
        confidence_score: Optional[float] = None
    ) -> UserPreferenceEmbedding:
        """Update user preference embeddings.
        
        Args:
            db: Database session
            user_id: User ID
            preference_type: Type of preference
            preference_data: Preference data to embed
            confidence_score: Confidence in the preference
            
        Returns:
            Updated UserPreferenceEmbedding instance
        """
        try:
            # Convert preference data to text for embedding
            preference_text = self._preference_to_text(preference_data)
            embedding = await self.generate_text_embedding(preference_text)
            
            # Check if preference embedding exists
            stmt = select(UserPreferenceEmbedding).where(
                and_(
                    UserPreferenceEmbedding.user_id == user_id,
                    UserPreferenceEmbedding.preference_type == preference_type
                )
            )
            result = await db.execute(stmt)
            existing = result.scalar_one_or_none()
            
            if existing:
                # Update existing
                existing.embedding = embedding
                existing.confidence_score = confidence_score
                existing.meta_data = preference_data
                existing.last_updated = datetime.utcnow()
                preference_embedding = existing
            else:
                # Create new
                preference_embedding = UserPreferenceEmbedding(
                    user_id=user_id,
                    preference_type=preference_type,
                    embedding=embedding,
                    confidence_score=confidence_score,
                    meta_data=preference_data
                )
                db.add(preference_embedding)
            
            await db.commit()
            await db.refresh(preference_embedding)
            
            logger.info(f"Updated {preference_type} preferences for user {user_id}")
            return preference_embedding
            
        except Exception as e:
            await db.rollback()
            logger.error(f"Error updating user preferences: {str(e)}")
            raise
    
    async def get_cached_search_results(
        self,
        db: AsyncSession,
        query: str,
        filters: Optional[Dict[str, Any]] = None
    ) -> Optional[Dict[str, Any]]:
        """Get cached semantic search results.
        
        Args:
            db: Database session
            query: Search query
            filters: Search filters
            
        Returns:
            Cached results if available
        """
        try:
            query_hash = self._generate_query_hash(query, filters)
            
            stmt = select(SemanticSearchCache).where(
                and_(
                    SemanticSearchCache.query_hash == query_hash,
                    SemanticSearchCache.expires_at > datetime.utcnow()
                )
            )
            result = await db.execute(stmt)
            cache_entry = result.scalar_one_or_none()
            
            if cache_entry:
                # Update access tracking
                cache_entry.hit_count += 1
                cache_entry.last_accessed = datetime.utcnow()
                await db.commit()
                
                logger.info(f"Retrieved cached search results for query hash {query_hash}")
                return cache_entry.results
            
            return None
            
        except Exception as e:
            logger.error(f"Error retrieving cached search results: {str(e)}")
            return None
    
    async def cache_search_results(
        self,
        db: AsyncSession,
        query: str,
        filters: Optional[Dict[str, Any]],
        results: Dict[str, Any],
        cache_duration_hours: int = 24
    ) -> None:
        """Cache semantic search results.
        
        Args:
            db: Database session
            query: Search query
            filters: Search filters
            results: Search results to cache
            cache_duration_hours: Cache duration in hours
        """
        try:
            query_hash = self._generate_query_hash(query, filters)
            query_embedding = await self.generate_text_embedding(query)
            
            cache_entry = SemanticSearchCache(
                query_hash=query_hash,
                query_embedding=query_embedding,
                results=results,
                filters_hash=self._generate_filters_hash(filters),
                expires_at=datetime.utcnow() + timedelta(hours=cache_duration_hours)
            )
            
            db.add(cache_entry)
            await db.commit()
            
            logger.info(f"Cached search results for query hash {query_hash}")
            
        except Exception as e:
            await db.rollback()
            logger.error(f"Error caching search results: {str(e)}")
    
    def calculate_similarity(self, embedding1: List[float], embedding2: List[float]) -> float:
        """Calculate cosine similarity between two embeddings.
        
        Args:
            embedding1: First embedding
            embedding2: Second embedding
            
        Returns:
            Cosine similarity score
        """
        try:
            vec1 = np.array(embedding1)
            vec2 = np.array(embedding2)
            
            # Calculate cosine similarity
            dot_product = np.dot(vec1, vec2)
            norm1 = np.linalg.norm(vec1)
            norm2 = np.linalg.norm(vec2)
            
            if norm1 == 0 or norm2 == 0:
                return 0.0
                
            similarity = dot_product / (norm1 * norm2)
            return float(similarity)
            
        except Exception as e:
            logger.error(f"Error calculating similarity: {str(e)}")
            return 0.0
    
    def _clean_text(self, text: str) -> str:
        """Clean text for embedding generation.
        
        Args:
            text: Raw text
            
        Returns:
            Cleaned text
        """
        if not text:
            return ""
            
        # Remove excessive whitespace
        cleaned = " ".join(text.split())
        
        # Truncate if too long (OpenAI has token limits)
        max_length = 8000  # Conservative limit
        if len(cleaned) > max_length:
            cleaned = cleaned[:max_length] + "..."
            
        return cleaned
    
    def _preference_to_text(self, preference_data: Dict[str, Any]) -> str:
        """Convert preference data to text for embedding.
        
        Args:
            preference_data: Preference data dictionary
            
        Returns:
            Text representation of preferences
        """
        text_parts = []
        
        for key, value in preference_data.items():
            if isinstance(value, (list, tuple)):
                text_parts.append(f"{key}: {', '.join(map(str, value))}")
            else:
                text_parts.append(f"{key}: {value}")
        
        return "; ".join(text_parts)
    
    def _generate_query_hash(self, query: str, filters: Optional[Dict[str, Any]]) -> str:
        """Generate hash for query and filters.
        
        Args:
            query: Search query
            filters: Search filters
            
        Returns:
            SHA-256 hash string
        """
        content = {
            "query": query,
            "filters": filters or {}
        }
        
        content_str = json.dumps(content, sort_keys=True)
        return hashlib.sha256(content_str.encode()).hexdigest()
    
    def _generate_filters_hash(self, filters: Optional[Dict[str, Any]]) -> Optional[str]:
        """Generate hash for filters only.
        
        Args:
            filters: Search filters
            
        Returns:
            SHA-256 hash string or None
        """
        if not filters:
            return None
            
        filters_str = json.dumps(filters, sort_keys=True)
        return hashlib.sha256(filters_str.encode()).hexdigest() 