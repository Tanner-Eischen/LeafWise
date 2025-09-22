"""Plant content indexing service for RAG system."""

import logging
import asyncio
from typing import List, Dict, Any, Optional, Union
from datetime import datetime
import json
import hashlib

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, text
from sqlalchemy.orm import selectinload

from app.models.rag_models import PlantContentEmbedding, PlantKnowledgeBase, SemanticSearchCache
from app.models.plant_species import PlantSpecies
from app.models.user_plant import UserPlant
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.story import Story
from app.services.embedding_service import EmbeddingService
from app.core.config import settings

logger = logging.getLogger(__name__)


class PlantContentIndexer:
    """Service for indexing plant content and generating embeddings."""
    
    def __init__(self, embedding_service: EmbeddingService):
        self.embedding_service = embedding_service
        
    async def index_plant_species(
        self,
        db: AsyncSession,
        species_id: str,
        force_reindex: bool = False
    ) -> bool:
        """Index plant species information for RAG retrieval.
        
        Args:
            db: Database session
            species_id: Plant species ID to index
            force_reindex: Force reindexing even if already exists
            
        Returns:
            True if indexing successful
        """
        try:
            # Get plant species with all related data
            stmt = select(PlantSpecies).where(PlantSpecies.id == species_id)
            result = await db.execute(stmt)
            species = result.scalar_one_or_none()
            
            if not species:
                logger.warning(f"Plant species {species_id} not found")
                return False
            
            # Check if already indexed
            if not force_reindex:
                existing_stmt = select(PlantContentEmbedding).where(
                    and_(
                        PlantContentEmbedding.content_type == "species_info",
                        PlantContentEmbedding.content_id == species_id
                    )
                )
                existing_result = await db.execute(existing_stmt)
                if existing_result.scalar_one_or_none():
                    logger.info(f"Species {species.scientific_name} already indexed")
                    return True
            
            # Build comprehensive species text for embedding
            species_text = self._build_species_text(species)
            
            # Generate embedding
            embedding = await self.embedding_service.generate_text_embedding(species_text)
            
            # Create metadata
            metadata = {
                "scientific_name": species.scientific_name,
                "common_names": species.common_names,
                "family": species.family,
                "care_level": species.care_level,
                "light_requirements": species.light_requirements,
                "water_requirements": species.water_requirements,
                "humidity_requirements": species.humidity_requirements,
                "temperature_range": species.temperature_range,
                "growth_rate": species.growth_rate,
                "mature_size": species.mature_size,
                "toxicity": species.toxicity,
                "origin": species.origin,
                "content_length": len(species_text)
            }
            
            # Create or update embedding
            if force_reindex:
                # Delete existing
                delete_stmt = PlantContentEmbedding.__table__.delete().where(
                    and_(
                        PlantContentEmbedding.content_type == "species_info",
                        PlantContentEmbedding.content_id == species_id
                    )
                )
                await db.execute(delete_stmt)
            
            # Create new embedding
            content_embedding = PlantContentEmbedding(
                content_type="species_info",
                content_id=species_id,
                embedding=embedding,
                meta_data=metadata
            )
            
            db.add(content_embedding)
            await db.commit()
            
            logger.info(f"Successfully indexed species: {species.scientific_name}")
            return True
            
        except Exception as e:
            logger.error(f"Error indexing plant species {species_id}: {str(e)}")
            await db.rollback()
            return False
    
    async def index_knowledge_base_entry(
        self,
        db: AsyncSession,
        knowledge_id: str,
        force_reindex: bool = False
    ) -> bool:
        """Index knowledge base entry for RAG retrieval.
        
        Args:
            db: Database session
            knowledge_id: Knowledge base entry ID
            force_reindex: Force reindexing even if already exists
            
        Returns:
            True if indexing successful
        """
        try:
            # Get knowledge base entry
            stmt = select(PlantKnowledgeBase).options(
                selectinload(PlantKnowledgeBase.plant_species)
            ).where(PlantKnowledgeBase.id == knowledge_id)
            result = await db.execute(stmt)
            knowledge_entry = result.scalar_one_or_none()
            
            if not knowledge_entry:
                logger.warning(f"Knowledge base entry {knowledge_id} not found")
                return False
            
            # Check if already indexed
            if not force_reindex:
                existing_stmt = select(PlantContentEmbedding).where(
                    and_(
                        PlantContentEmbedding.content_type == "knowledge_base",
                        PlantContentEmbedding.content_id == knowledge_id
                    )
                )
                existing_result = await db.execute(existing_stmt)
                if existing_result.scalar_one_or_none():
                    logger.info(f"Knowledge entry {knowledge_entry.title} already indexed")
                    return True
            
            # Build text for embedding
            knowledge_text = self._build_knowledge_text(knowledge_entry)
            
            # Generate embedding
            embedding = await self.embedding_service.generate_text_embedding(knowledge_text)
            
            # Create metadata
            metadata = {
                "title": knowledge_entry.title,
                "content_type": knowledge_entry.content_type,
                "difficulty_level": knowledge_entry.difficulty_level,
                "season": knowledge_entry.season,
                "climate_zones": knowledge_entry.climate_zones,
                "tags": knowledge_entry.tags,
                "verified": knowledge_entry.verified,
                "helpful_count": knowledge_entry.helpful_count,
                "content_length": len(knowledge_entry.content)
            }
            
            if knowledge_entry.plant_species:
                metadata.update({
                    "plant_species_id": str(knowledge_entry.plant_species.id),
                    "scientific_name": knowledge_entry.plant_species.scientific_name,
                    "plant_family": knowledge_entry.plant_species.family
                })
            
            # Create or update embedding
            if force_reindex:
                delete_stmt = PlantContentEmbedding.__table__.delete().where(
                    and_(
                        PlantContentEmbedding.content_type == "knowledge_base",
                        PlantContentEmbedding.content_id == knowledge_id
                    )
                )
                await db.execute(delete_stmt)
            
            content_embedding = PlantContentEmbedding(
                content_type="knowledge_base",
                content_id=knowledge_id,
                embedding=embedding,
                meta_data=metadata
            )
            
            db.add(content_embedding)
            await db.commit()
            
            logger.info(f"Successfully indexed knowledge entry: {knowledge_entry.title}")
            return True
            
        except Exception as e:
            logger.error(f"Error indexing knowledge base entry {knowledge_id}: {str(e)}")
            await db.rollback()
            return False
    
    async def index_user_content(
        self,
        db: AsyncSession,
        content_type: str,
        content_id: str,
        force_reindex: bool = False
    ) -> bool:
        """Index user-generated content (questions, answers, stories).
        
        Args:
            db: Database session
            content_type: Type of content (question, answer, story)
            content_id: Content ID
            force_reindex: Force reindexing even if already exists
            
        Returns:
            True if indexing successful
        """
        try:
            content_data = None
            content_text = ""
            metadata = {}
            
            if content_type == "question":
                stmt = select(PlantQuestion).options(
                    selectinload(PlantQuestion.user),
                    selectinload(PlantQuestion.plant_species)
                ).where(PlantQuestion.id == content_id)
                result = await db.execute(stmt)
                question = result.scalar_one_or_none()
                
                if question:
                    content_text = f"{question.title}\n{question.content or ''}"
                    metadata = {
                        "title": question.title,
                        "question_type": question.question_type,
                        "urgency": question.urgency,
                        "tags": question.tags,
                        "user_experience": question.user.gardening_experience if question.user else "unknown",
                        "plant_species": question.plant_species.scientific_name if question.plant_species else None,
                        "answer_count": len(question.answers) if hasattr(question, 'answers') else 0
                    }
            
            elif content_type == "answer":
                stmt = select(PlantAnswer).options(
                    selectinload(PlantAnswer.user),
                    selectinload(PlantAnswer.question)
                ).where(PlantAnswer.id == content_id)
                result = await db.execute(stmt)
                answer = result.scalar_one_or_none()
                
                if answer:
                    content_text = answer.content
                    metadata = {
                        "question_title": answer.question.title if answer.question else "",
                        "is_helpful": answer.is_helpful,
                        "helpful_count": answer.helpful_count,
                        "user_experience": answer.user.gardening_experience if answer.user else "unknown",
                        "answer_length": len(answer.content)
                    }
            
            elif content_type == "story":
                stmt = select(Story).options(
                    selectinload(Story.user)
                ).where(Story.id == content_id)
                result = await db.execute(stmt)
                story = result.scalar_one_or_none()
                
                if story:
                    content_text = f"{story.caption or ''}\n{story.plant_tags or ''}"
                    metadata = {
                        "story_type": story.story_type,
                        "plant_tags": story.plant_tags,
                        "location": story.location,
                        "view_count": story.view_count,
                        "like_count": story.like_count,
                        "user_experience": story.user.gardening_experience if story.user else "unknown"
                    }
            
            if not content_text:
                logger.warning(f"No content found for {content_type} {content_id}")
                return False
            
            # Check if already indexed
            if not force_reindex:
                existing_stmt = select(PlantContentEmbedding).where(
                    and_(
                        PlantContentEmbedding.content_type == content_type,
                        PlantContentEmbedding.content_id == content_id
                    )
                )
                existing_result = await db.execute(existing_stmt)
                if existing_result.scalar_one_or_none():
                    logger.info(f"Content {content_type} {content_id} already indexed")
                    return True
            
            # Generate embedding
            embedding = await self.embedding_service.generate_text_embedding(content_text)
            
            # Create or update embedding
            if force_reindex:
                delete_stmt = PlantContentEmbedding.__table__.delete().where(
                    and_(
                        PlantContentEmbedding.content_type == content_type,
                        PlantContentEmbedding.content_id == content_id
                    )
                )
                await db.execute(delete_stmt)
            
            content_embedding = PlantContentEmbedding(
                content_type=content_type,
                content_id=content_id,
                embedding=embedding,
                meta_data=metadata
            )
            
            db.add(content_embedding)
            await db.commit()
            
            logger.info(f"Successfully indexed {content_type}: {content_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error indexing {content_type} {content_id}: {str(e)}")
            await db.rollback()
            return False
    
    async def bulk_index_content(
        self,
        db: AsyncSession,
        content_items: List[Dict[str, str]],
        batch_size: int = 10
    ) -> Dict[str, int]:
        """Bulk index multiple content items.
        
        Args:
            db: Database session
            content_items: List of content items with type and id
            batch_size: Number of items to process in each batch
            
        Returns:
            Summary of indexing results
        """
        results = {"success": 0, "failed": 0, "skipped": 0}
        
        for i in range(0, len(content_items), batch_size):
            batch = content_items[i:i + batch_size]
            batch_tasks = []
            
            for item in batch:
                content_type = item["content_type"]
                content_id = item["content_id"]
                force_reindex = item.get("force_reindex", False)
                
                if content_type == "species":
                    task = self.index_plant_species(db, content_id, force_reindex)
                elif content_type == "knowledge":
                    task = self.index_knowledge_base_entry(db, content_id, force_reindex)
                else:
                    task = self.index_user_content(db, content_type, content_id, force_reindex)
                
                batch_tasks.append(task)
            
            # Process batch
            batch_results = await asyncio.gather(*batch_tasks, return_exceptions=True)
            
            for result in batch_results:
                if isinstance(result, Exception):
                    results["failed"] += 1
                    logger.error(f"Batch indexing error: {str(result)}")
                elif result:
                    results["success"] += 1
                else:
                    results["skipped"] += 1
        
        logger.info(f"Bulk indexing completed: {results}")
        return results
    
    async def reindex_all_content(
        self,
        db: AsyncSession,
        content_types: Optional[List[str]] = None
    ) -> Dict[str, int]:
        """Reindex all content of specified types.
        
        Args:
            db: Database session
            content_types: List of content types to reindex (None for all)
            
        Returns:
            Summary of reindexing results
        """
        results = {"success": 0, "failed": 0}
        
        try:
            # Get all content to reindex
            content_items = []
            
            if not content_types or "species" in content_types:
                # Get all plant species
                species_stmt = select(PlantSpecies.id)
                species_result = await db.execute(species_stmt)
                for species_id, in species_result:
                    content_items.append({
                        "content_type": "species",
                        "content_id": str(species_id),
                        "force_reindex": True
                    })
            
            if not content_types or "knowledge" in content_types:
                # Get all knowledge base entries
                kb_stmt = select(PlantKnowledgeBase.id)
                kb_result = await db.execute(kb_stmt)
                for kb_id, in kb_result:
                    content_items.append({
                        "content_type": "knowledge",
                        "content_id": str(kb_id),
                        "force_reindex": True
                    })
            
            if not content_types or "question" in content_types:
                # Get all questions
                q_stmt = select(PlantQuestion.id)
                q_result = await db.execute(q_stmt)
                for q_id, in q_result:
                    content_items.append({
                        "content_type": "question",
                        "content_id": str(q_id),
                        "force_reindex": True
                    })
            
            if not content_types or "answer" in content_types:
                # Get all answers
                a_stmt = select(PlantAnswer.id)
                a_result = await db.execute(a_stmt)
                for a_id, in a_result:
                    content_items.append({
                        "content_type": "answer",
                        "content_id": str(a_id),
                        "force_reindex": True
                    })
            
            if not content_types or "story" in content_types:
                # Get all stories
                s_stmt = select(Story.id)
                s_result = await db.execute(s_stmt)
                for s_id, in s_result:
                    content_items.append({
                        "content_type": "story",
                        "content_id": str(s_id),
                        "force_reindex": True
                    })
            
            logger.info(f"Starting reindex of {len(content_items)} content items")
            
            # Bulk index all content
            results = await self.bulk_index_content(db, content_items)
            
            logger.info(f"Reindexing completed: {results}")
            return results
            
        except Exception as e:
            logger.error(f"Error during reindexing: {str(e)}")
            return {"success": 0, "failed": len(content_items) if 'content_items' in locals() else 0}
    
    async def cleanup_orphaned_embeddings(self, db: AsyncSession) -> int:
        """Remove embeddings for content that no longer exists.
        
        Args:
            db: Database session
            
        Returns:
            Number of orphaned embeddings removed
        """
        removed_count = 0
        
        try:
            # Get all embeddings
            embeddings_stmt = select(PlantContentEmbedding)
            embeddings_result = await db.execute(embeddings_stmt)
            embeddings = embeddings_result.scalars().all()
            
            for embedding in embeddings:
                content_exists = False
                
                # Check if referenced content still exists
                if embedding.content_type == "species_info":
                    species_stmt = select(PlantSpecies.id).where(PlantSpecies.id == embedding.content_id)
                    species_result = await db.execute(species_stmt)
                    content_exists = species_result.scalar_one_or_none() is not None
                
                elif embedding.content_type == "knowledge_base":
                    kb_stmt = select(PlantKnowledgeBase.id).where(PlantKnowledgeBase.id == embedding.content_id)
                    kb_result = await db.execute(kb_stmt)
                    content_exists = kb_result.scalar_one_or_none() is not None
                
                elif embedding.content_type == "question":
                    q_stmt = select(PlantQuestion.id).where(PlantQuestion.id == embedding.content_id)
                    q_result = await db.execute(q_stmt)
                    content_exists = q_result.scalar_one_or_none() is not None
                
                elif embedding.content_type == "answer":
                    a_stmt = select(PlantAnswer.id).where(PlantAnswer.id == embedding.content_id)
                    a_result = await db.execute(a_stmt)
                    content_exists = a_result.scalar_one_or_none() is not None
                
                elif embedding.content_type == "story":
                    s_stmt = select(Story.id).where(Story.id == embedding.content_id)
                    s_result = await db.execute(s_stmt)
                    content_exists = s_result.scalar_one_or_none() is not None
                
                # Remove orphaned embedding
                if not content_exists:
                    await db.delete(embedding)
                    removed_count += 1
            
            await db.commit()
            logger.info(f"Removed {removed_count} orphaned embeddings")
            return removed_count
            
        except Exception as e:
            logger.error(f"Error cleaning up orphaned embeddings: {str(e)}")
            await db.rollback()
            return 0
    
    def _build_species_text(self, species: PlantSpecies) -> str:
        """Build comprehensive text representation of plant species."""
        text_parts = [
            f"Plant: {species.scientific_name}",
            f"Common names: {', '.join(species.common_names) if species.common_names else 'None'}",
            f"Family: {species.family}",
            f"Care level: {species.care_level}",
            f"Description: {species.description or 'No description available'}"
        ]
        
        if species.light_requirements:
            text_parts.append(f"Light requirements: {species.light_requirements}")
        if species.water_requirements:
            text_parts.append(f"Water requirements: {species.water_requirements}")
        if species.humidity_requirements:
            text_parts.append(f"Humidity requirements: {species.humidity_requirements}")
        if species.temperature_range:
            text_parts.append(f"Temperature range: {species.temperature_range}")
        if species.growth_rate:
            text_parts.append(f"Growth rate: {species.growth_rate}")
        if species.mature_size:
            text_parts.append(f"Mature size: {species.mature_size}")
        if species.toxicity:
            text_parts.append(f"Toxicity: {species.toxicity}")
        if species.origin:
            text_parts.append(f"Origin: {species.origin}")
        if species.care_tips:
            text_parts.append(f"Care tips: {species.care_tips}")
        
        return "\n".join(text_parts)
    
    def _build_knowledge_text(self, knowledge: PlantKnowledgeBase) -> str:
        """Build text representation of knowledge base entry."""
        text_parts = [
            f"Title: {knowledge.title}",
            f"Content: {knowledge.content}",
            f"Type: {knowledge.content_type}"
        ]
        
        if knowledge.difficulty_level:
            text_parts.append(f"Difficulty: {knowledge.difficulty_level}")
        if knowledge.season:
            text_parts.append(f"Season: {knowledge.season}")
        if knowledge.tags:
            text_parts.append(f"Tags: {', '.join(knowledge.tags)}")
        
        return "\n".join(text_parts) 