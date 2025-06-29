#!/usr/bin/env python3
"""Setup script for RAG infrastructure initialization."""

import asyncio
import logging
import sys
import os
from pathlib import Path

# Add the app directory to the Python path
sys.path.append(str(Path(__file__).parent.parent))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

from app.core.config import settings
from app.core.database import Base
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService
from app.services.rag_content_pipeline import RAGContentPipeline

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class RAGInfrastructureSetup:
    """Setup and initialization for RAG infrastructure."""
    
    def __init__(self):
        self.engine = None
        self.session_factory = None
        self.embedding_service = EmbeddingService()
        self.vector_service = VectorDatabaseService(self.embedding_service)
        self.rag_pipeline = RAGContentPipeline(self.embedding_service, self.vector_service)
    
    async def setup_database_connection(self):
        """Setup database connection."""
        try:
            database_url = str(settings.SQLALCHEMY_DATABASE_URI)
            self.engine = create_async_engine(database_url, echo=False)
            self.session_factory = sessionmaker(
                bind=self.engine,
                class_=AsyncSession,
                expire_on_commit=False
            )
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Failed to setup database connection: {str(e)}")
            raise
    
    async def enable_pgvector_extension(self):
        """Enable pgvector extension in the database."""
        try:
            async with self.engine.begin() as conn:
                # Check if pgvector extension is available
                result = await conn.execute(
                    text("SELECT 1 FROM pg_available_extensions WHERE name = 'vector'")
                )
                if not result.fetchone():
                    logger.warning("pgvector extension is not available in this PostgreSQL installation")
                    return False
                
                # Enable the extension
                await conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
                logger.info("pgvector extension enabled successfully")
                
                # Verify the extension is installed
                result = await conn.execute(
                    text("SELECT extname, extversion FROM pg_extension WHERE extname = 'vector'")
                )
                extension_info = result.fetchone()
                if extension_info:
                    logger.info(f"pgvector extension verified: version {extension_info[1]}")
                    return True
                else:
                    logger.error("pgvector extension installation verification failed")
                    return False
                    
        except Exception as e:
            logger.error(f"Error enabling pgvector extension: {str(e)}")
            return False
    
    async def create_vector_indexes(self):
        """Create vector similarity indexes for better performance."""
        try:
            async with self.engine.begin() as conn:
                # Create indexes for plant content embeddings
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS ix_plant_content_embeddings_vector 
                    ON plant_content_embeddings 
                    USING ivfflat (embedding vector_cosine_ops) 
                    WITH (lists = 100)
                """))
                
                # Create indexes for user preference embeddings
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS ix_user_preference_embeddings_vector 
                    ON user_preference_embeddings 
                    USING ivfflat (embedding vector_cosine_ops) 
                    WITH (lists = 100)
                """))
                
                # Create indexes for RAG interactions
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS ix_rag_interactions_vector 
                    ON rag_interactions 
                    USING ivfflat (query_embedding vector_cosine_ops) 
                    WITH (lists = 100)
                """))
                
                logger.info("Vector similarity indexes created successfully")
                return True
                
        except Exception as e:
            logger.error(f"Error creating vector indexes: {str(e)}")
            return False
    
    async def initialize_knowledge_base(self):
        """Initialize the plant knowledge base with essential content."""
        try:
            async with self.session_factory() as db:
                logger.info("Initializing plant knowledge base...")
                result = await self.rag_pipeline.initialize_knowledge_base(db)
                
                if result.get("status") == "success":
                    logger.info(f"Knowledge base initialized: {result}")
                    return True
                else:
                    logger.error(f"Knowledge base initialization failed: {result}")
                    return False
                    
        except Exception as e:
            logger.error(f"Error initializing knowledge base: {str(e)}")
            return False
    
    async def test_rag_functionality(self):
        """Test basic RAG functionality to ensure everything is working."""
        try:
            async with self.session_factory() as db:
                logger.info("Testing RAG functionality...")
                
                # Test embedding generation
                test_text = "How do I care for my houseplants?"
                embedding = await self.embedding_service.generate_text_embedding(test_text)
                logger.info(f"Embedding generation test: {len(embedding)} dimensions")
                
                # Test vector search
                search_results = await self.vector_service.similarity_search(
                    db=db,
                    query_embedding=embedding,
                    content_types=["knowledge_base"],
                    limit=3,
                    similarity_threshold=0.1
                )
                logger.info(f"Vector search test: {len(search_results)} results found")
                
                # Test knowledge search
                knowledge_results = await self.vector_service.search_plant_knowledge(
                    db=db,
                    query=test_text,
                    limit=3
                )
                logger.info(f"Knowledge search test: {len(knowledge_results)} knowledge entries found")
                
                return True
                
        except Exception as e:
            logger.error(f"Error testing RAG functionality: {str(e)}")
            return False
    
    async def get_system_status(self):
        """Get comprehensive system status."""
        try:
            async with self.session_factory() as db:
                stats = await self.rag_pipeline.get_indexing_stats(db)
                logger.info("Current RAG system status:")
                logger.info(f"  Total embeddings: {stats.get('total_embeddings', 0)}")
                logger.info(f"  Embedding types: {stats.get('embedding_counts', {})}")
                logger.info(f"  Content coverage: {stats.get('content_coverage', {})}")
                return stats
                
        except Exception as e:
            logger.error(f"Error getting system status: {str(e)}")
            return {}
    
    async def run_full_setup(self):
        """Run the complete RAG infrastructure setup."""
        logger.info("Starting RAG infrastructure setup...")
        
        try:
            # 1. Setup database connection
            await self.setup_database_connection()
            
            # 2. Enable pgvector extension
            pgvector_success = await self.enable_pgvector_extension()
            if not pgvector_success:
                logger.warning("pgvector setup failed, but continuing...")
            
            # 3. Create vector indexes
            indexes_success = await self.create_vector_indexes()
            if not indexes_success:
                logger.warning("Vector indexes creation failed, but continuing...")
            
            # 4. Initialize knowledge base
            kb_success = await self.initialize_knowledge_base()
            if not kb_success:
                logger.error("Knowledge base initialization failed")
                return False
            
            # 5. Test functionality
            test_success = await self.test_rag_functionality()
            if not test_success:
                logger.error("RAG functionality test failed")
                return False
            
            # 6. Get final status
            await self.get_system_status()
            
            logger.info("RAG infrastructure setup completed successfully!")
            return True
            
        except Exception as e:
            logger.error(f"RAG infrastructure setup failed: {str(e)}")
            return False
        finally:
            if self.engine:
                await self.engine.dispose()


async def main():
    """Main setup function."""
    setup = RAGInfrastructureSetup()
    
    try:
        success = await setup.run_full_setup()
        if success:
            logger.info("✅ RAG infrastructure setup completed successfully!")
            sys.exit(0)
        else:
            logger.error("❌ RAG infrastructure setup failed!")
            sys.exit(1)
    except KeyboardInterrupt:
        logger.info("Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error during setup: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    # Check for required environment variables
    required_vars = ["OPENAI_API_KEY", "SQLALCHEMY_DATABASE_URI"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        logger.error(f"Missing required environment variables: {', '.join(missing_vars)}")
        sys.exit(1)
    
    asyncio.run(main()) 