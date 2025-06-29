#!/usr/bin/env python3
"""Seed script for plant knowledge base."""

import asyncio
import json
import sys
import os
from datetime import datetime
from uuid import uuid4
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    
    # Look for .env file in backend directory
    env_file = backend_dir / '.env'
    if env_file.exists():
        load_dotenv(env_file)
        print(f"✅ Loaded environment variables from {env_file}")
    else:
        # If .env not in backend_dir, try loading from current working directory (less reliable)
        load_dotenv()
        print("✅ Attempted to load environment variables from .env in current directory (may not be backend/.env)")
except ImportError:
    print("⚠️  python-dotenv not available. Please install it (`pip install python-dotenv`) to load variables from .env files. Continuing with system environment variables only.")
except Exception as e:
    print(f"⚠️  Could not load .env file: {e}")

# Now try to import app modules
try:
    from app.core.database import AsyncSessionLocal
    from app.models.plant_species import PlantSpecies
    from app.models.rag_models import PlantKnowledgeBase
    from app.services.embedding_service import EmbeddingService
    from app.services.vector_database_service import VectorDatabaseService
    from app.core.config import settings # Import settings to access API_KEY
except ImportError as e:
    print(f"❌ Failed to import core app modules: {e}")
    print("💡 This usually means the Python path is incorrect or required dependencies are not installed.")
    print("   Please ensure you have activated your virtual environment and run `pip install -r requirements.txt`")
    print("   Also, verify the `app` directory structure and imports.")
    sys.exit(1) # Exit if core modules can't be imported

# Configure logging
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Sample plant knowledge data
PLANT_KNOWLEDGE_DATA = [
    {
        "title": "Monstera Deliciosa Care Guide",
        "content": """
        Monstera deliciosa, also known as the Swiss Cheese Plant, is a popular houseplant known for its distinctive split leaves. It thrives in bright, indirect light and prefers well-draining soil. Water when the top inch of soil feels dry, typically every 1-2 weeks. This plant loves humidity and benefits from regular misting. During growing season (spring and summer), feed monthly with a balanced liquid fertilizer. Monstera can grow quite large indoors, reaching 6-8 feet tall. Support with a moss pole for best results. Common problems include yellowing leaves (overwatering) and brown leaf tips (low humidity or fluoride in water).
        """,
        "content_type": "care_guide",
        "difficulty_level": "intermediate",
        "season": "year_round",
        "tags": ["houseplant", "tropical", "climbing", "low_light_tolerant"],
        "source": "expert"
    },
    {
        "title": "Snake Plant (Sansevieria) Beginner Care",
        "content": """
        Snake plants are perfect for beginners due to their low maintenance requirements. They tolerate low light conditions but prefer bright, indirect light. Water sparingly - only when soil is completely dry, usually every 2-3 weeks in growing season and less in winter. Overwatering is the most common cause of death. Use well-draining cactus soil mix. Snake plants are extremely drought tolerant and can survive weeks without water. They prefer temperatures between 70-90°F and low humidity. Fertilize monthly during spring and summer with diluted liquid fertilizer. Common varieties include Sansevieria trifasciata and Sansevieria cylindrica.
        """,
        "content_type": "care_guide",
        "difficulty_level": "beginner",
        "season": "year_round",
        "tags": ["houseplant", "succulent", "drought_tolerant", "low_light", "air_purifying"],
        "source": "expert"
    },
    {
        "title": "Fiddle Leaf Fig Troubleshooting",
        "content": """
        Fiddle leaf figs are notorious for being finicky, but understanding their needs helps. Brown spots usually indicate overwatering or bacterial infection - reduce watering and ensure good drainage. Yellowing leaves often mean underwatering or natural leaf drop. Dropping leaves suddenly usually indicates stress from changes in light, temperature, or watering schedule. These plants need bright, indirect light and consistent care. Water when top 1-2 inches of soil are dry. They prefer humidity around 40-50% and temperatures between 65-75°F. Rotate weekly for even growth and dust leaves regularly for optimal photosynthesis.
        """,
        "content_type": "troubleshooting",
        "difficulty_level": "advanced",
        "season": "year_round",
        "tags": ["houseplant", "tropical", "finicky", "statement_plant"],
        "source": "expert"
    },
    {
        "title": "Succulent Winter Care",
        "content": """
        Winter care for succulents requires significant adjustments. Reduce watering frequency dramatically - most succulents enter dormancy and need water only every 3-4 weeks. Move plants to the brightest available location as daylight hours decrease. Maintain temperatures above 50°F for most species. Stop fertilizing completely during winter months. Watch for etiolation (stretching) due to insufficient light - consider grow lights if needed. Many succulents like Echeveria and Sedum can handle temperatures down to 40°F but should be protected from frost. Resume normal care gradually in spring.
        """,
        "content_type": "seasonal_care",
        "difficulty_level": "intermediate",
        "season": "winter",
        "tags": ["succulent", "winter_care", "dormancy", "seasonal"],
        "source": "expert"
    },
    {
        "title": "Common Houseplant Pests and Solutions",
        "content": """
        Spider mites appear as tiny webs and stippled leaves - increase humidity and use insecticidal soap. Aphids cluster on new growth - rinse with water or use neem oil. Mealybugs look like white cotton balls - dab with rubbing alcohol or use systemic insecticide. Fungus gnats fly around soil - let soil dry out and use yellow sticky traps. Scale insects appear as brown bumps on stems - scrape off and treat with neem oil. Prevention is key: quarantine new plants, inspect regularly, maintain proper humidity, and avoid overwatering. Always isolate infected plants to prevent spread.
        """,
        "content_type": "pest_management",
        "difficulty_level": "intermediate",
        "season": "year_round",
        "tags": ["pest_control", "plant_health", "troubleshooting", "prevention"],
        "source": "expert"
    },
    {
        "title": "Propagation Basics for Beginners",
        "content": """
        Plant propagation is an exciting way to expand your collection for free. Water propagation works well for pothos, philodendrons, and many tropical plants - cut below a node and place in water until roots develop. Leaf propagation is perfect for succulents - let cut leaves callus for 2-3 days, then place on soil and mist lightly. Division works for plants with multiple crowns like snake plants and ZZ plants - carefully separate root systems and pot separately. Stem cuttings work for most houseplants - cut 4-6 inch pieces with nodes and either root in water or directly in soil. Spring and summer are the best times for propagation when plants are actively growing.
        """,
        "content_type": "propagation",
        "difficulty_level": "beginner",
        "season": "spring_summer",
        "tags": ["propagation", "plant_reproduction", "beginner_friendly", "cost_effective"],
        "source": "expert"
    }
]

# Plant species data to seed
PLANT_SPECIES_DATA = [
    {
        "common_name": "Monstera Deliciosa",
        "scientific_name": "Monstera deliciosa",
        "family": "Araceae",
        "origin": "Central America",
        "care_level": "intermediate",
        "light_requirements": "bright_indirect",
        "water_frequency": "weekly",
        "humidity_preference": "high",
        "temperature_range": "65-85°F",
        "growth_rate": "fast",
        "mature_size": "6-8 feet indoors",
        "toxicity": "toxic_to_pets",
        "description": "Popular houseplant known for its distinctive split leaves and climbing nature."
    },
    {
        "common_name": "Snake Plant",
        "scientific_name": "Sansevieria trifasciata",
        "family": "Asparagaceae",
        "origin": "West Africa",
        "care_level": "beginner",
        "light_requirements": "low_to_bright_indirect",
        "water_frequency": "bi_weekly",
        "humidity_preference": "low",
        "temperature_range": "70-90°F",
        "growth_rate": "slow",
        "mature_size": "2-4 feet",
        "toxicity": "toxic_to_pets",
        "description": "Extremely hardy plant perfect for beginners, known for air purifying qualities."
    },
    {
        "common_name": "Fiddle Leaf Fig",
        "scientific_name": "Ficus lyrata",
        "family": "Moraceae",
        "origin": "Western Africa",
        "care_level": "advanced",
        "light_requirements": "bright_indirect",
        "water_frequency": "weekly",
        "humidity_preference": "medium",
        "temperature_range": "65-75°F",
        "growth_rate": "medium",
        "mature_size": "6-10 feet indoors",
        "toxicity": "toxic_to_pets",
        "description": "Statement plant with large, violin-shaped leaves. Requires consistent care."
    },
    {
        "common_name": "Pothos",
        "scientific_name": "Epipremnum aureum",
        "family": "Araceae",
        "origin": "Southeast Asia",
        "care_level": "beginner",
        "light_requirements": "low_to_bright_indirect",
        "water_frequency": "weekly",
        "humidity_preference": "medium",
        "temperature_range": "65-85°F",
        "growth_rate": "fast",
        "mature_size": "trailing/climbing",
        "toxicity": "toxic_to_pets",
        "description": "Easy-care trailing plant perfect for hanging baskets or climbing."
    },
    {
        "common_name": "ZZ Plant",
        "scientific_name": "Zamioculcas zamiifolia",
        "family": "Araceae",
        "origin": "Eastern Africa",
        "care_level": "beginner",
        "light_requirements": "low_to_bright_indirect",
        "water_frequency": "bi_weekly",
        "humidity_preference": "low",
        "temperature_range": "65-85°F",
        "growth_rate": "slow",
        "mature_size": "2-3 feet",
        "toxicity": "toxic_to_pets",
        "description": "Extremely drought tolerant with glossy, dark green leaves."
    }
]

async def seed_plant_species(db):
    """Seed the database with plant species data."""
    logger.info("🌱 Seeding plant species data...")
    
    try:
        from sqlalchemy import select
        
        for species_data in PLANT_SPECIES_DATA:
            # Check if species already exists
            result = await db.execute(
                select(PlantSpecies).where(
                    PlantSpecies.scientific_name == species_data["scientific_name"]
                )
            )
            existing_species = result.scalar_one_or_none()
            
            if not existing_species:
                species = PlantSpecies(
                    id=str(uuid4()),
                    common_name=species_data["common_name"],
                    scientific_name=species_data["scientific_name"],
                    family=species_data["family"],
                    origin=species_data["origin"],
                    care_level=species_data["care_level"],
                    light_requirements=species_data["light_requirements"],
                    water_frequency=species_data["water_frequency"],
                    humidity_preference=species_data["humidity_preference"],
                    temperature_range=species_data["temperature_range"],
                    growth_rate=species_data["growth_rate"],
                    mature_size=species_data["mature_size"],
                    toxicity=species_data["toxicity"],
                    description=species_data["description"],
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                db.add(species)
                logger.info(f"✅ Added species: {species_data['common_name']}")
            else:
                logger.info(f"⚪ Species already exists: {species_data['common_name']}")
        
        await db.commit()
        logger.info("✅ Plant species seeding completed")
        return True
        
    except Exception as e:
        logger.error(f"❌ Error seeding plant species: {str(e)}")
        await db.rollback()
        return False

async def seed_plant_knowledge(db, embedding_service=None):
    """Seed the database with plant knowledge data."""
    logger.info("🧠 Seeding plant knowledge base...")
    
    try:
        from sqlalchemy import select
        
        for knowledge_data in PLANT_KNOWLEDGE_DATA:
            # Check if knowledge entry already exists
            result = await db.execute(
                select(PlantKnowledgeBase).where(
                    PlantKnowledgeBase.title == knowledge_data["title"]
                )
            )
            existing_knowledge = result.scalar_one_or_none()
            
            if not existing_knowledge:
                # Generate embedding if embedding service is available
                embedding = None
                if embedding_service and settings.OPENAI_API_KEY:
                    try:
                        embedding = await embedding_service.generate_text_embedding(
                            f"{knowledge_data['title']} {knowledge_data['content']}"
                        )
                        logger.info(f"✅ Generated embedding for: {knowledge_data['title']}")
                    except Exception as e:
                        logger.warning(f"⚠️  Failed to generate embedding for {knowledge_data['title']}: {str(e)}")
                
                knowledge = PlantKnowledgeBase(
                    id=str(uuid4()),
                    title=knowledge_data["title"],
                    content=knowledge_data["content"],
                    content_type=knowledge_data["content_type"],
                    difficulty_level=knowledge_data["difficulty_level"],
                    season=knowledge_data["season"],
                    tags=knowledge_data["tags"],
                    source=knowledge_data["source"],
                    embedding=embedding,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                db.add(knowledge)
                logger.info(f"✅ Added knowledge: {knowledge_data['title']}")
            else:
                logger.info(f"⚪ Knowledge already exists: {knowledge_data['title']}")
        
        await db.commit()
        logger.info("✅ Plant knowledge seeding completed")
        return True
        
    except Exception as e:
        logger.error(f"❌ Error seeding plant knowledge: {str(e)}")
        await db.rollback()
        return False

async def main():
    """Main seeding function."""
    logger.info("🌱 Starting plant knowledge seeding...")
    logger.info("=" * 50)
    
    # Check for OPENAI_API_KEY
    if not settings.OPENAI_API_KEY:
        logger.warning("⚠️  OPENAI_API_KEY is not set. Knowledge base will be seeded but embeddings will be skipped.")
        logger.info("💡 Set OPENAI_API_KEY in your .env file for full functionality.")
    
    try:
        # Initialize services
        embedding_service = None
        if settings.OPENAI_API_KEY:
            embedding_service = EmbeddingService()
            logger.info("✅ Embedding service initialized")
        
        # Connect to database
        async with AsyncSessionLocal() as db:
            logger.info("✅ Database connection established")
            
            # Seed plant species
            species_success = await seed_plant_species(db)
            if not species_success:
                logger.error("❌ Plant species seeding failed")
                return False
            
            # Seed plant knowledge
            knowledge_success = await seed_plant_knowledge(db, embedding_service)
            if not knowledge_success:
                logger.error("❌ Plant knowledge seeding failed")
                return False
            
            logger.info("=" * 50)
            logger.info("🎉 Plant knowledge seeding completed successfully!")
            
            # Get final stats
            from sqlalchemy import func
            species_count = await db.scalar(select(func.count(PlantSpecies.id)))
            knowledge_count = await db.scalar(select(func.count(PlantKnowledgeBase.id)))
            
            logger.info(f"📊 Final Statistics:")
            logger.info(f"   • Plant Species: {species_count}")
            logger.info(f"   • Knowledge Entries: {knowledge_count}")
            
            return True
            
    except Exception as e:
        logger.error(f"❌ Seeding failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("🌱 Plant Knowledge Seeding Script")
    print("=" * 40)
    
    # Check environment variables
    print("🔍 Environment Variables Check:")
    if not settings.OPENAI_API_KEY:
        print("⚠️  OPENAI_API_KEY: Not set (embeddings will be skipped)")
    else:
        print("✅ OPENAI_API_KEY: Set")
    
    # Check database connection
    try:
        database_url = str(settings.SQLALCHEMY_DATABASE_URI)
        print(f"✅ Database URL: {database_url.split('@')[1] if '@' in database_url else 'configured'}")
    except Exception as e:
        print(f"❌ Database configuration error: {e}")
        sys.exit(1)
    
    print("=" * 40)
    
    # Run the seeding
    success = asyncio.run(main())
    if success:
        print("✅ Seeding completed successfully!")
        sys.exit(0)
    else:
        print("❌ Seeding failed!")
        sys.exit(1) 