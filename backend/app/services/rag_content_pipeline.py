"""RAG Content Pipeline for embedding generation and content indexing."""

import logging
import asyncio
from typing import List, Dict, Any, Optional, Union
from datetime import datetime, timedelta
import json
import hashlib

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, text, desc
from sqlalchemy.orm import selectinload

from app.models.rag_models import PlantContentEmbedding, PlantKnowledgeBase, SemanticSearchCache
from app.models.plant_species import PlantSpecies
from app.models.user_plant import UserPlant
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.story import Story
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService
from app.core.config import settings

logger = logging.getLogger(__name__)


class RAGContentPipeline:
    """Service for RAG content pipeline and embedding management."""
    
    def __init__(self, embedding_service: EmbeddingService, vector_service: VectorDatabaseService):
        self.embedding_service = embedding_service
        self.vector_service = vector_service
        
    async def initialize_knowledge_base(self, db: AsyncSession) -> Dict[str, Any]:
        """Initialize the plant knowledge base with essential content.
        
        This creates foundational knowledge entries for common plants and care topics.
        """
        try:
            logger.info("Initializing plant knowledge base...")
            
            # Create basic plant care knowledge entries
            basic_knowledge = [
                {
                    "title": "Basic Watering Guidelines",
                    "content": """
                    Proper watering is crucial for plant health. Check soil moisture by inserting your finger 1-2 inches deep. 
                    Water when the top inch feels dry for most houseplants. Water thoroughly until excess drains from the bottom. 
                    Avoid overwatering as it can lead to root rot. Different plants have different water needs - succulents need 
                    less frequent watering, while tropical plants may need more consistent moisture.
                    """,
                    "content_type": "care_guide",
                    "difficulty_level": "beginner",
                    "season": "year_round",
                    "tags": ["watering", "basics", "houseplants", "care"]
                },
                {
                    "title": "Understanding Light Requirements",
                    "content": """
                    Light is essential for photosynthesis. Bright indirect light means near a window but not in direct sun rays. 
                    Direct light means the plant receives unfiltered sunlight. Low light areas are typically 6+ feet from windows. 
                    Signs of insufficient light include leggy growth, pale leaves, and slow growth. Too much light can cause 
                    leaf burn, brown spots, or wilting.
                    """,
                    "content_type": "care_guide",
                    "difficulty_level": "beginner",
                    "season": "year_round",
                    "tags": ["lighting", "basics", "houseplants", "placement"]
                },
                {
                    "title": "Common Plant Problems and Solutions",
                    "content": """
                    Yellow leaves often indicate overwatering or poor drainage. Brown leaf tips suggest low humidity or 
                    fluoride in water. Drooping leaves may mean underwatering or root problems. Pests like spider mites, 
                    aphids, and scale can be treated with insecticidal soap. Fungal issues require better air circulation 
                    and less moisture on leaves.
                    """,
                    "content_type": "problem_solution",
                    "difficulty_level": "intermediate",
                    "season": "year_round",
                    "tags": ["problems", "troubleshooting", "pests", "diseases"]
                },
                {
                    "title": "Seasonal Plant Care Adjustments",
                    "content": """
                    Plants need different care throughout the year. In spring, increase watering and fertilizing as growth resumes. 
                    Summer requires more frequent watering and protection from intense heat. Fall is time to reduce fertilizing 
                    and prepare for dormancy. Winter means less water, no fertilizer, and protection from cold drafts. 
                    Adjust care based on your plant's natural growing season.
                    """,
                    "content_type": "care_guide",
                    "difficulty_level": "intermediate",
                    "season": "year_round",
                    "tags": ["seasonal", "care", "adjustments", "yearly"]
                }
            ]
            
            created_count = 0
            indexed_count = 0
            
            for knowledge_data in basic_knowledge:
                # Check if already exists
                existing_stmt = select(PlantKnowledgeBase).where(
                    PlantKnowledgeBase.title == knowledge_data["title"]
                )
                existing_result = await db.execute(existing_stmt)
                if existing_result.scalar_one_or_none():
                    logger.info(f"Knowledge entry '{knowledge_data['title']}' already exists")
                    continue
                
                # Create knowledge base entry
                knowledge_entry = PlantKnowledgeBase(
                    title=knowledge_data["title"],
                    content=knowledge_data["content"].strip(),
                    content_type=knowledge_data["content_type"],
                    difficulty_level=knowledge_data["difficulty_level"],
                    season=knowledge_data["season"],
                    tags=knowledge_data["tags"],
                    source="system",
                    verified="verified"
                )
                
                db.add(knowledge_entry)
                await db.flush()  # Get the ID
                created_count += 1
                
                # Index the content
                success = await self.index_knowledge_entry(db, str(knowledge_entry.id))
                if success:
                    indexed_count += 1
            
            await db.commit()
            
            result = {
                "status": "success",
                "created_entries": created_count,
                "indexed_entries": indexed_count,
                "total_basic_knowledge": len(basic_knowledge)
            }
            
            logger.info(f"Knowledge base initialization completed: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Error initializing knowledge base: {str(e)}")
            await db.rollback()
            return {"status": "error", "message": str(e)}
    
    async def index_knowledge_entry(
        self,
        db: AsyncSession,
        knowledge_id: str,
        force_reindex: bool = False
    ) -> bool:
        """Index a knowledge base entry for RAG retrieval."""
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
    
    async def index_plant_species(
        self,
        db: AsyncSession,
        species_id: str,
        force_reindex: bool = False
    ) -> bool:
        """Index plant species information for RAG retrieval."""
        try:
            # Get plant species
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
                delete_stmt = PlantContentEmbedding.__table__.delete().where(
                    and_(
                        PlantContentEmbedding.content_type == "species_info",
                        PlantContentEmbedding.content_id == species_id
                    )
                )
                await db.execute(delete_stmt)
            
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
    
    async def bulk_index_all_species(self, db: AsyncSession) -> Dict[str, int]:
        """Index all plant species in the database."""
        try:
            # Get all plant species
            species_stmt = select(PlantSpecies.id, PlantSpecies.scientific_name)
            species_result = await db.execute(species_stmt)
            all_species = species_result.fetchall()
            
            results = {"success": 0, "failed": 0, "total": len(all_species)}
            
            logger.info(f"Starting bulk indexing of {len(all_species)} plant species")
            
            # Process in batches
            batch_size = 5
            for i in range(0, len(all_species), batch_size):
                batch = all_species[i:i + batch_size]
                batch_tasks = []
                
                for species_id, scientific_name in batch:
                    task = self.index_plant_species(db, str(species_id))
                    batch_tasks.append(task)
                
                # Process batch
                batch_results = await asyncio.gather(*batch_tasks, return_exceptions=True)
                
                for j, result in enumerate(batch_results):
                    if isinstance(result, Exception):
                        results["failed"] += 1
                        logger.error(f"Failed to index species {batch[j][1]}: {str(result)}")
                    elif result:
                        results["success"] += 1
                    else:
                        results["failed"] += 1
                
                # Small delay between batches to avoid overwhelming the system
                await asyncio.sleep(0.1)
            
            logger.info(f"Bulk species indexing completed: {results}")
            return results
            
        except Exception as e:
            logger.error(f"Error in bulk species indexing: {str(e)}")
            return {"success": 0, "failed": 0, "total": 0, "error": str(e)}
    
    async def get_indexing_stats(self, db: AsyncSession) -> Dict[str, Any]:
        """Get statistics about the current indexing status."""
        try:
            # Count embeddings by type
            embedding_stats_stmt = select(
                PlantContentEmbedding.content_type,
                func.count(PlantContentEmbedding.id).label('count')
            ).group_by(PlantContentEmbedding.content_type)
            
            embedding_result = await db.execute(embedding_stats_stmt)
            embedding_stats = {row.content_type: row.count for row in embedding_result}
            
            # Count total content items
            species_count_stmt = select(func.count(PlantSpecies.id))
            species_result = await db.execute(species_count_stmt)
            total_species = species_result.scalar()
            
            knowledge_count_stmt = select(func.count(PlantKnowledgeBase.id))
            knowledge_result = await db.execute(knowledge_count_stmt)
            total_knowledge = knowledge_result.scalar()
            
            # Calculate indexing coverage
            species_indexed = embedding_stats.get("species_info", 0)
            knowledge_indexed = embedding_stats.get("knowledge_base", 0)
            
            stats = {
                "embedding_counts": embedding_stats,
                "total_embeddings": sum(embedding_stats.values()),
                "content_coverage": {
                    "species": {
                        "total": total_species,
                        "indexed": species_indexed,
                        "coverage_percent": round((species_indexed / max(total_species, 1)) * 100, 2)
                    },
                    "knowledge_base": {
                        "total": total_knowledge,
                        "indexed": knowledge_indexed,
                        "coverage_percent": round((knowledge_indexed / max(total_knowledge, 1)) * 100, 2)
                    }
                },
                "last_updated": datetime.utcnow().isoformat()
            }
            
            return stats
            
        except Exception as e:
            logger.error(f"Error getting indexing stats: {str(e)}")
            return {"error": str(e)}
    
    async def refresh_search_cache(self, db: AsyncSession) -> Dict[str, int]:
        """Refresh the semantic search cache by removing expired entries."""
        try:
            # Remove expired cache entries
            expired_stmt = SemanticSearchCache.__table__.delete().where(
                SemanticSearchCache.expires_at < datetime.utcnow()
            )
            result = await db.execute(expired_stmt)
            expired_count = result.rowcount
            
            # Remove least accessed entries if cache is too large
            cache_count_stmt = select(func.count(SemanticSearchCache.id))
            cache_result = await db.execute(cache_count_stmt)
            total_cache_entries = cache_result.scalar()
            
            removed_count = 0
            max_cache_size = 10000  # Configurable limit
            
            if total_cache_entries > max_cache_size:
                # Remove oldest entries with lowest hit count
                old_entries_stmt = select(SemanticSearchCache.id).order_by(
                    SemanticSearchCache.hit_count.asc(),
                    SemanticSearchCache.last_accessed.asc()
                ).limit(total_cache_entries - max_cache_size)
                
                old_entries_result = await db.execute(old_entries_stmt)
                old_entry_ids = [row.id for row in old_entries_result]
                
                if old_entry_ids:
                    delete_old_stmt = SemanticSearchCache.__table__.delete().where(
                        SemanticSearchCache.id.in_(old_entry_ids)
                    )
                    delete_result = await db.execute(delete_old_stmt)
                    removed_count = delete_result.rowcount
            
            await db.commit()
            
            result = {
                "expired_removed": expired_count,
                "old_removed": removed_count,
                "total_removed": expired_count + removed_count
            }
            
            logger.info(f"Search cache refresh completed: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Error refreshing search cache: {str(e)}")
            await db.rollback()
            return {"error": str(e)}
    
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