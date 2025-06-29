"""Seed script for plant knowledge base."""

import asyncio
import json
from datetime import datetime
from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.models.plant_species import PlantSpecies
from app.models.rag_models import PlantKnowledgeBase
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService


# Sample plant knowledge data
PLANT_KNOWLEDGE_DATA = [
    {
        "title": "Monstera Deliciosa Care Guide",
        "content": "Monstera deliciosa, also known as the Swiss Cheese Plant, is a popular houseplant known for its distinctive split leaves. It thrives in bright, indirect light and prefers well-draining soil. Water when the top inch of soil feels dry, typically every 1-2 weeks. This plant loves humidity and benefits from regular misting. During growing season (spring and summer), feed monthly with a balanced liquid fertilizer. Monstera can grow quite large indoors, reaching 6-8 feet tall. Support with a moss pole for best results. Common problems include yellowing leaves (overwatering) and brown leaf tips (low humidity or fluoride in water).",
        "content_type": "care_guide",
        "difficulty_level": "intermediate",
        "season": "year_round",
        "tags": ["houseplant", "tropical", "climbing", "low_light_tolerant"],
        "source": "expert"
    },
    {
        "title": "Snake Plant (Sansevieria) Beginner Care",
        "content": "Snake plants are perfect for beginners due to their low maintenance requirements. They tolerate low light conditions but prefer bright, indirect light. Water sparingly - only when soil is completely dry, usually every 2-3 weeks in growing season and less in winter. Overwatering is the most common cause of death. Use well-draining cactus soil mix. Snake plants are extremely drought tolerant and can survive weeks without water. They prefer temperatures between 70-90°F and low humidity. Fertilize sparingly, only 2-3 times during growing season. Propagate by leaf cuttings or division.",
        "content_type": "care_guide",
        "difficulty_level": "beginner",
        "season": "year_round",
        "tags": ["houseplant", "low_maintenance", "drought_tolerant", "air_purifying"],
        "source": "expert"
    },
    {
        "title": "Fiddle Leaf Fig Common Problems",
        "content": "Fiddle leaf figs are notorious for being finicky. Brown spots on leaves usually indicate overwatering or bacterial infection - reduce watering and ensure good drainage. Dropping leaves can be caused by sudden changes in light, temperature, or watering schedule - maintain consistency. Yellow leaves typically mean overwatering, while brown crispy edges suggest underwatering or low humidity. Fiddle leaf figs hate being moved, so find a good spot and leave them there. They need bright, indirect light and consistent watering when top 2 inches of soil are dry. Dust leaves regularly for optimal photosynthesis.",
        "content_type": "problem_solution",
        "difficulty_level": "advanced",
        "season": "year_round",
        "tags": ["houseplant", "finicky", "common_problems", "troubleshooting"],
        "source": "expert"
    },
    {
        "title": "Pothos Propagation Techniques",
        "content": "Pothos is one of the easiest plants to propagate. For water propagation: cut a 4-6 inch stem with at least 2 nodes, remove lower leaves, place in water, and change water every few days. Roots will develop in 1-2 weeks. For soil propagation: take cuttings with nodes, dip in rooting hormone (optional), plant in moist potting mix, and keep soil consistently moist but not soggy. Pothos can also be propagated by division when repotting. The best time to propagate is during growing season (spring/summer). New plants will be identical to the parent plant.",
        "content_type": "technique",
        "difficulty_level": "beginner",
        "season": "spring",
        "tags": ["propagation", "houseplant", "easy", "water_propagation"],
        "source": "expert"
    },
    {
        "title": "Winter Plant Care Adjustments",
        "content": "During winter months, most houseplants enter a dormant period and require adjusted care. Reduce watering frequency as plants use less water in lower light and cooler temperatures. Stop or reduce fertilizing from October through February as plants aren't actively growing. Increase humidity around plants as indoor heating can dry the air. Move plants closer to windows for maximum light exposure, but away from cold drafts and heating vents. Some plants may drop leaves naturally - this is normal. Avoid repotting during winter unless absolutely necessary. Monitor for pests more closely as dry indoor air can stress plants and make them more susceptible.",
        "content_type": "care_guide",
        "difficulty_level": "intermediate",
        "season": "winter",
        "tags": ["seasonal_care", "winter", "dormancy", "houseplant"],
        "source": "expert"
    },
    {
        "title": "Spider Plant Care and Benefits",
        "content": "Spider plants (Chlorophytum comosum) are excellent air-purifying houseplants that are nearly impossible to kill. They thrive in bright, indirect light but tolerate various lighting conditions. Water when soil surface feels dry, typically weekly. Spider plants prefer temperatures between 65-75°F and moderate humidity. They produce plantlets (babies) on long stolons that can be propagated easily. These plants are non-toxic to pets and children. NASA studies show spider plants remove formaldehyde and xylene from indoor air. Brown leaf tips usually indicate fluoride in water - use distilled water if this occurs. Fertilize monthly during growing season.",
        "content_type": "species_info",
        "difficulty_level": "beginner",
        "season": "year_round",
        "tags": ["air_purifying", "pet_safe", "easy_care", "propagation"],
        "source": "research"
    }
]


async def get_or_create_species(db: AsyncSession, common_name: str, scientific_name: str) -> PlantSpecies:
    """Get existing species or create a new one."""
    stmt = select(PlantSpecies).where(PlantSpecies.scientific_name == scientific_name)
    result = await db.execute(stmt)
    species = result.scalar_one_or_none()
    
    if not species:
        species = PlantSpecies(
            scientific_name=scientific_name,
            common_names=[common_name],
            care_level="intermediate"
        )
        db.add(species)
        await db.commit()
        await db.refresh(species)
    
    return species


async def seed_plant_knowledge():
    """Seed the plant knowledge base with initial data."""
    print("Starting plant knowledge seeding...")
    
    embedding_service = EmbeddingService()
    vector_service = VectorDatabaseService(embedding_service)
    
    async with AsyncSessionLocal() as db:
        try:
            # Create some basic plant species if they don't exist
            species_mapping = {
                "Monstera Deliciosa": ("Monstera deliciosa", "Monstera deliciosa"),
                "Snake Plant": ("Sansevieria trifasciata", "Snake Plant"),
                "Fiddle Leaf Fig": ("Ficus lyrata", "Fiddle Leaf Fig"),
                "Pothos": ("Epipremnum aureum", "Golden Pothos"),
                "Spider Plant": ("Chlorophytum comosum", "Spider Plant")
            }
            
            species_dict = {}
            for common, (scientific, display) in species_mapping.items():
                species = await get_or_create_species(db, display, scientific)
                species_dict[common] = species
            
            # Create knowledge base entries
            for knowledge_data in PLANT_KNOWLEDGE_DATA:
                # Determine plant species for this knowledge entry
                plant_species = None
                title = knowledge_data["title"]
                
                for species_name, species in species_dict.items():
                    if species_name.lower() in title.lower():
                        plant_species = species
                        break
                
                # Create knowledge base entry
                knowledge_entry = PlantKnowledgeBase(
                    title=knowledge_data["title"],
                    content=knowledge_data["content"],
                    content_type=knowledge_data["content_type"],
                    plant_species_id=plant_species.id if plant_species else None,
                    difficulty_level=knowledge_data["difficulty_level"],
                    season=knowledge_data["season"],
                    climate_zones=["temperate", "subtropical"],  # Default zones
                    tags=knowledge_data["tags"],
                    source=knowledge_data["source"],
                    verified="verified"
                )
                
                db.add(knowledge_entry)
                await db.commit()
                await db.refresh(knowledge_entry)
                
                # Create embedding for the knowledge entry
                content_for_embedding = f"{knowledge_entry.title}. {knowledge_entry.content}"
                metadata = {
                    "plant_species_id": str(plant_species.id) if plant_species else None,
                    "difficulty_level": knowledge_entry.difficulty_level,
                    "season": knowledge_entry.season,
                    "content_type": knowledge_entry.content_type,
                    "tags": knowledge_entry.tags
                }
                
                await vector_service.index_content(
                    db=db,
                    content_id=str(knowledge_entry.id),
                    content_type=knowledge_entry.content_type,
                    text_content=content_for_embedding,
                    metadata=metadata
                )
                
                print(f"Created knowledge entry: {knowledge_entry.title}")
            
            print(f"Successfully seeded {len(PLANT_KNOWLEDGE_DATA)} knowledge base entries!")
            
        except Exception as e:
            print(f"Error seeding plant knowledge: {str(e)}")
            await db.rollback()
            raise


if __name__ == "__main__":
    asyncio.run(seed_plant_knowledge()) 