"""Vector database service for semantic search and similarity matching."""

import logging
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, text
from sqlalchemy.orm import selectinload

from app.models.rag_models import PlantContentEmbedding, UserPreferenceEmbedding, PlantKnowledgeBase
from app.models.plant_species import PlantSpecies
from app.models.user import User
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


class VectorDatabaseService:
    """Service for vector similarity search and retrieval."""
    
    def __init__(self, embedding_service: EmbeddingService):
        self.embedding_service = embedding_service
    
    async def similarity_search(
        self,
        db: AsyncSession,
        query_embedding: List[float],
        content_types: Optional[List[str]] = None,
        filters: Optional[Dict[str, Any]] = None,
        limit: int = 10,
        similarity_threshold: float = 0.7
    ) -> List[Dict[str, Any]]:
        """Perform similarity search across plant content embeddings.
        
        Args:
            db: Database session
            query_embedding: Query embedding vector
            content_types: Filter by content types
            filters: Additional filters (species, difficulty, season, etc.)
            limit: Maximum number of results
            similarity_threshold: Minimum similarity score
            
        Returns:
            List of similar content with metadata
        """
        try:
            # Build base query with similarity calculation
            similarity_expr = func.cosine_similarity(
                PlantContentEmbedding.embedding,
                query_embedding
            )
            
            stmt = select(
                PlantContentEmbedding,
                similarity_expr.label('similarity_score')
            ).where(
                similarity_expr > similarity_threshold
            )
            
            # Apply content type filters
            if content_types:
                stmt = stmt.where(PlantContentEmbedding.content_type.in_(content_types))
            
            # Apply metadata filters
            if filters:
                metadata_conditions = []
                for key, value in filters.items():
                    if isinstance(value, list):
                        # JSON array contains any of the values
                        metadata_conditions.append(
                            PlantContentEmbedding.meta_data[key].astext.in_(value)
                        )
                    else:
                        # Exact match
                        metadata_conditions.append(
                            PlantContentEmbedding.meta_data[key].astext == str(value)
                        )
                
                if metadata_conditions:
                    stmt = stmt.where(and_(*metadata_conditions))
            
            # Order by similarity and limit
            stmt = stmt.order_by(similarity_expr.desc()).limit(limit)
            
            result = await db.execute(stmt)
            rows = result.fetchall()
            
            # Convert to list of dictionaries
            results = []
            for embedding, similarity_score in rows:
                result_dict = {
                    'id': str(embedding.id),
                    'content_type': embedding.content_type,
                    'content_id': str(embedding.content_id),
                    'metadata': embedding.meta_data,
                    'similarity_score': float(similarity_score),
                    'created_at': embedding.created_at.isoformat()
                }
                results.append(result_dict)
            
            logger.info(f"Found {len(results)} similar content items")
            return results
            
        except Exception as e:
            logger.error(f"Error performing similarity search: {str(e)}")
            raise
    
    async def search_plant_knowledge(
        self,
        db: AsyncSession,
        query: str,
        plant_species_id: Optional[str] = None,
        difficulty_level: Optional[str] = None,
        season: Optional[str] = None,
        content_types: Optional[List[str]] = None,
        limit: int = 5
    ) -> List[Dict[str, Any]]:
        """Search plant knowledge base using semantic similarity.
        
        Args:
            db: Database session
            query: Search query text
            plant_species_id: Filter by plant species
            difficulty_level: Filter by difficulty level
            season: Filter by season
            content_types: Filter by content types
            limit: Maximum number of results
            
        Returns:
            List of relevant knowledge base entries
        """
        try:
            # Generate query embedding
            query_embedding = await self.embedding_service.generate_text_embedding(query)
            
            # Build filters
            filters = {}
            if plant_species_id:
                filters['plant_species_id'] = plant_species_id
            if difficulty_level:
                filters['difficulty_level'] = difficulty_level
            if season:
                filters['season'] = season
            
            # Search embeddings
            embedding_results = await self.similarity_search(
                db=db,
                query_embedding=query_embedding,
                content_types=content_types or ['care_guide', 'species_info', 'technique', 'problem_solution'],
                filters=filters,
                limit=limit
            )
            
            # Get full knowledge base entries
            knowledge_entries = []
            for embedding_result in embedding_results:
                content_id = embedding_result['content_id']
                
                stmt = select(PlantKnowledgeBase).options(
                    selectinload(PlantKnowledgeBase.plant_species)
                ).where(PlantKnowledgeBase.id == content_id)
                
                result = await db.execute(stmt)
                knowledge_entry = result.scalar_one_or_none()
                
                if knowledge_entry:
                    entry_dict = {
                        'id': str(knowledge_entry.id),
                        'title': knowledge_entry.title,
                        'content': knowledge_entry.content,
                        'content_type': knowledge_entry.content_type,
                        'difficulty_level': knowledge_entry.difficulty_level,
                        'season': knowledge_entry.season,
                        'tags': knowledge_entry.tags,
                        'plant_species': {
                            'id': str(knowledge_entry.plant_species.id),
                            'scientific_name': knowledge_entry.plant_species.scientific_name,
                            'common_names': knowledge_entry.plant_species.common_names
                        } if knowledge_entry.plant_species else None,
                        'similarity_score': embedding_result['similarity_score'],
                        'verified': knowledge_entry.verified,
                        'helpful_count': knowledge_entry.helpful_count
                    }
                    knowledge_entries.append(entry_dict)
            
            logger.info(f"Retrieved {len(knowledge_entries)} knowledge base entries for query")
            return knowledge_entries
            
        except Exception as e:
            logger.error(f"Error searching plant knowledge: {str(e)}")
            raise
    
    async def find_similar_users(
        self,
        db: AsyncSession,
        user_id: str,
        preference_types: Optional[List[str]] = None,
        limit: int = 10,
        similarity_threshold: float = 0.6
    ) -> List[Dict[str, Any]]:
        """Find users with similar plant preferences.
        
        Args:
            db: Database session
            user_id: Target user ID
            preference_types: Types of preferences to compare
            limit: Maximum number of similar users
            similarity_threshold: Minimum similarity score
            
        Returns:
            List of similar users with similarity scores
        """
        try:
            # Get target user's preference embeddings
            target_prefs_stmt = select(UserPreferenceEmbedding).where(
                UserPreferenceEmbedding.user_id == user_id
            )
            if preference_types:
                target_prefs_stmt = target_prefs_stmt.where(
                    UserPreferenceEmbedding.preference_type.in_(preference_types)
                )
            
            target_result = await db.execute(target_prefs_stmt)
            target_preferences = target_result.scalars().all()
            
            if not target_preferences:
                logger.info(f"No preferences found for user {user_id}")
                return []
            
            # Find similar users for each preference type
            similar_users = {}
            
            for target_pref in target_preferences:
                # Calculate similarity with other users' preferences of the same type
                similarity_expr = func.cosine_similarity(
                    UserPreferenceEmbedding.embedding,
                    target_pref.embedding
                )
                
                stmt = select(
                    UserPreferenceEmbedding.user_id,
                    similarity_expr.label('similarity_score')
                ).where(
                    and_(
                        UserPreferenceEmbedding.user_id != user_id,
                        UserPreferenceEmbedding.preference_type == target_pref.preference_type,
                        similarity_expr > similarity_threshold
                    )
                ).order_by(similarity_expr.desc()).limit(limit * 2)  # Get more to deduplicate
                
                result = await db.execute(stmt)
                rows = result.fetchall()
                
                # Aggregate scores by user
                for similar_user_id, score in rows:
                    if similar_user_id not in similar_users:
                        similar_users[similar_user_id] = []
                    similar_users[similar_user_id].append(float(score))
            
            # Calculate average similarity scores
            user_similarities = []
            for similar_user_id, scores in similar_users.items():
                avg_score = sum(scores) / len(scores)
                user_similarities.append((similar_user_id, avg_score))
            
            # Sort by average similarity and limit
            user_similarities.sort(key=lambda x: x[1], reverse=True)
            user_similarities = user_similarities[:limit]
            
            # Get user details
            similar_users_list = []
            for similar_user_id, similarity_score in user_similarities:
                user_stmt = select(User).where(User.id == similar_user_id)
                user_result = await db.execute(user_stmt)
                user = user_result.scalar_one_or_none()
                
                if user:
                    user_dict = {
                        'id': str(user.id),
                        'username': user.username,
                        'display_name': user.display_name,
                        'gardening_experience': user.gardening_experience,
                        'location': user.location,
                        'similarity_score': similarity_score
                    }
                    similar_users_list.append(user_dict)
            
            logger.info(f"Found {len(similar_users_list)} similar users for user {user_id}")
            return similar_users_list
            
        except Exception as e:
            logger.error(f"Error finding similar users: {str(e)}")
            raise
    
    async def get_personalized_recommendations(
        self,
        db: AsyncSession,
        user_id: str,
        recommendation_type: str = "general",
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get personalized content recommendations based on user preferences.
        
        Args:
            db: Database session
            user_id: User ID
            recommendation_type: Type of recommendations
            limit: Maximum number of recommendations
            
        Returns:
            List of personalized recommendations
        """
        try:
            # Get user's preference embeddings
            prefs_stmt = select(UserPreferenceEmbedding).where(
                UserPreferenceEmbedding.user_id == user_id
            )
            prefs_result = await db.execute(prefs_stmt)
            user_preferences = prefs_result.scalars().all()
            
            if not user_preferences:
                # Return popular content if no preferences
                return await self._get_popular_content(db, limit)
            
            # Combine user preference embeddings (weighted average)
            combined_embedding = self._combine_embeddings([
                (pref.embedding, pref.confidence_score or 1.0) 
                for pref in user_preferences
            ])
            
            # Search for similar content
            recommendations = await self.similarity_search(
                db=db,
                query_embedding=combined_embedding,
                content_types=['care_guide', 'species_info', 'technique'],
                limit=limit,
                similarity_threshold=0.5
            )
            
            logger.info(f"Generated {len(recommendations)} personalized recommendations for user {user_id}")
            return recommendations
            
        except Exception as e:
            logger.error(f"Error getting personalized recommendations: {str(e)}")
            raise
    
    async def index_content(
        self,
        db: AsyncSession,
        content_id: str,
        content_type: str,
        text_content: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> PlantContentEmbedding:
        """Index new content for vector search.
        
        Args:
            db: Database session
            content_id: Content ID
            content_type: Type of content
            text_content: Text to index
            metadata: Additional metadata
            
        Returns:
            Created embedding record
        """
        try:
            return await self.embedding_service.store_content_embedding(
                db=db,
                content_type=content_type,
                content_id=content_id,
                text=text_content,
                metadata=metadata
            )
            
        except Exception as e:
            logger.error(f"Error indexing content: {str(e)}")
            raise
    
    def _combine_embeddings(self, embeddings_with_weights: List[Tuple[List[float], float]]) -> List[float]:
        """Combine multiple embeddings using weighted average.
        
        Args:
            embeddings_with_weights: List of (embedding, weight) tuples
            
        Returns:
            Combined embedding vector
        """
        if not embeddings_with_weights:
            return [0.0] * self.embedding_service.embedding_dimension
        
        # Calculate weighted average
        total_weight = sum(weight for _, weight in embeddings_with_weights)
        if total_weight == 0:
            total_weight = 1.0
        
        combined = [0.0] * len(embeddings_with_weights[0][0])
        
        for embedding, weight in embeddings_with_weights:
            normalized_weight = weight / total_weight
            for i, value in enumerate(embedding):
                combined[i] += value * normalized_weight
        
        return combined
    
    async def _get_popular_content(self, db: AsyncSession, limit: int) -> List[Dict[str, Any]]:
        """Get popular content as fallback recommendations.
        
        Args:
            db: Database session
            limit: Maximum number of results
            
        Returns:
            List of popular content items
        """
        try:
            stmt = select(PlantKnowledgeBase).where(
                PlantKnowledgeBase.verified == 'verified'
            ).order_by(
                PlantKnowledgeBase.helpful_count.desc(),
                PlantKnowledgeBase.view_count.desc()
            ).limit(limit)
            
            result = await db.execute(stmt)
            popular_entries = result.scalars().all()
            
            popular_content = []
            for entry in popular_entries:
                content_dict = {
                    'id': str(entry.id),
                    'title': entry.title,
                    'content': entry.content,
                    'content_type': entry.content_type,
                    'helpful_count': entry.helpful_count,
                    'view_count': entry.view_count,
                    'similarity_score': 0.5  # Default score for popular content
                }
                popular_content.append(content_dict)
            
            return popular_content
            
        except Exception as e:
            logger.error(f"Error getting popular content: {str(e)}")
            return [] 