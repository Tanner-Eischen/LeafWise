#!/usr/bin/env python3
"""Setup script for RAG infrastructure initialization."""

import asyncio
import logging
import sys
import os
from pathlib import Path

def setup_python_path():
    """Setup Python path to find the app module."""
    # Get the absolute path to the backend directory
    script_path = Path(__file__).resolve()
    backend_dir = script_path.parent.parent
    
    # Add backend directory to Python path if not already there
    backend_str = str(backend_dir)
    if backend_str not in sys.path:
        sys.path.insert(0, backend_str)
    
    # Change to backend directory
    os.chdir(backend_dir)
    
    print(f"📁 Working directory: {os.getcwd()}")
    print(f"🐍 Python path includes: {backend_str}")
    
    return backend_dir

# Setup path before any app imports
backend_dir = setup_python_path()

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
    from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
    from sqlalchemy.orm import sessionmaker
    from sqlalchemy import text

    from app.core.config import settings
    from app.core.database import Base
    from app.services.embedding_service import EmbeddingService
    from app.services.vector_database_service import VectorDatabaseService
    from app.services.rag_content_pipeline import RAGContentPipeline
except ImportError as e:
    print(f"❌ Failed to import core app modules: {e}")
    print("💡 This usually means the Python path is incorrect or required dependencies are not installed.")
    print("   Please ensure you have activated your virtual environment and run `pip install -r requirements.txt`")
    print("   Also, verify the `app` directory structure and imports.")
    sys.exit(1) # Exit if core modules can't be imported

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
            # Use the actual database URL from settings
            database_url = str(settings.SQLALCHEMY_DATABASE_URI)
            logger.info(f"Connecting to database: {database_url.split('@')[1] if '@' in database_url else database_url.split('://')[0] + '://...'}")
            
            self.engine = create_async_engine(database_url, echo=False)
            self.session_factory = sessionmaker(
                bind=self.engine,
                class_=AsyncSession,
                expire_on_commit=False
            )
            logger.info("✅ Database connection established")
        except Exception as e:
            logger.error(f"❌ Failed to setup database connection: {str(e)}")
            logger.error("💡 Please check your DATABASE_URL in .env and ensure PostgreSQL is running.")
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
                    logger.warning("⚠️  pgvector extension is not available in this PostgreSQL installation or database.")
                    logger.info("💡 To install pgvector: For Docker, use `postgres:15-alpine` or `postgres:15-pgvector`. For local, install `postgresql-server-dev-15` and `pgvector`.")
                    return False
                
                # Enable the extension
                await conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
                logger.info("✅ pgvector extension enabled successfully")
                
                # Verify the extension is installed
                result = await conn.execute(
                    text("SELECT extname, extversion FROM pg_extension WHERE extname = 'vector'")
                )
                extension_info = result.fetchone()
                if extension_info:
                    logger.info(f"✅ pgvector extension verified: version {extension_info[1]}")
                    return True
                else:
                    logger.error("❌ pgvector extension installation verification failed.")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error enabling pgvector extension: {str(e)}")
            logger.info("💡 RAG system may have limited functionality without pgvector. Continuing without it.")
            return False
    
    async def create_vector_indexes(self):
        """Create vector similarity indexes for better performance."""
        try:
            async with self.engine.begin() as conn:
                # Import all models to ensure metadata is populated for table reflection
                import app.models # noqa: F401
                
                # Check if tables exist first
                table_names = ['plant_content_embeddings', 'user_preference_embeddings', 'rag_interactions']
                result = await conn.execute(text(f"""
                    SELECT table_name FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_name IN ({', '.join(f"'{tn}'" for tn in table_names)})
                """))
                existing_tables = [row[0] for row in result.fetchall()]
                
                if 'plant_content_embeddings' in existing_tables:
                    await conn.execute(text("""
                        CREATE INDEX IF NOT EXISTS ix_plant_content_embeddings_vector
                        ON plant_content_embeddings
                        USING ivfflat (embedding vector_cosine_ops)
                        WITH (lists = 100)
                    """))
                    logger.info("✅ Plant content embeddings index created")
                else:
                    logger.warning("⚠️  Table 'plant_content_embeddings' not found, skipping index creation.")
                
                if 'user_preference_embeddings' in existing_tables:
                    await conn.execute(text("""
                        CREATE INDEX IF NOT EXISTS ix_user_preference_embeddings_vector
                        ON user_preference_embeddings
                        USING ivfflat (embedding vector_cosine_ops)
                        WITH (lists = 100)
                    """))
                    logger.info("✅ User preference embeddings index created")
                else:
                    logger.warning("⚠️  Table 'user_preference_embeddings' not found, skipping index creation.")
                
                if 'rag_interactions' in existing_tables:
                    await conn.execute(text("""
                        CREATE INDEX IF NOT EXISTS ix_rag_interactions_vector
                        ON rag_interactions
                        USING ivfflat (query_embedding vector_cosine_ops)
                        WITH (lists = 100)
                    """))
                    logger.info("✅ RAG interactions index created")
                else:
                    logger.warning("⚠️  Table 'rag_interactions' not found, skipping index creation.")
                
                logger.info("✅ Vector similarity indexes creation process completed.")
                return True
                
        except Exception as e:
            logger.error(f"❌ Error creating vector indexes: {str(e)}")
            logger.info("💡 This might happen if pgvector is not available or tables are not yet created. Continuing without vector indexes.")
            return False
    
    async def initialize_knowledge_base(self):
        """Initialize the plant knowledge base with essential content."""
        try:
            # Check for OPENAI_API_KEY before attempting to initialize knowledge base with embeddings
            if not settings.OPENAI_API_KEY:
                logger.warning("⚠️  OPENAI_API_KEY is not set. Knowledge base will be initialized but embeddings will be skipped.")
                logger.info("💡 Set OPENAI_API_KEY in your .env file or environment variables for full RAG functionality.")

            async with self.session_factory() as db:
                logger.info("🧠 Initializing plant knowledge base...")
                result = await self.rag_pipeline.initialize_knowledge_base(db)
                
                if result.get("status") == "success":
                    logger.info(f"✅ Knowledge base initialized: {result}")
                    return True
                else:
                    logger.error(f"❌ Knowledge base initialization failed: {result.get('message', 'Unknown error')}")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error initializing knowledge base: {str(e)}")
            import traceback
            traceback.print_exc()
            return False
    
    async def test_rag_functionality(self):
        """Test basic RAG functionality to ensure everything is working."""
        try:
            if not settings.OPENAI_API_KEY:
                logger.warning("⚠️  OPENAI_API_KEY is not set. Skipping RAG functionality test.")
                return False

            async with self.session_factory() as db:
                logger.info("🧪 Testing RAG functionality...")
                
                # Test embedding generation
                test_text = "How do I care for my houseplants?"
                embedding = await self.embedding_service.generate_text_embedding(test_text)
                logger.info(f"✅ Embedding generation test: {len(embedding)} dimensions")
                
                # Test vector search (requires pgvector and existing embeddings)
                try:
                    search_results = await self.vector_service.similarity_search(
                        db=db,
                        query_embedding=embedding,
                        content_types=["knowledge_base"],
                        limit=1,
                        similarity_threshold=0.1
                    )
                    logger.info(f"✅ Vector search test: {len(search_results)} results found")
                except Exception as e:
                    logger.warning(f"⚠️  Vector search test skipped or failed: {str(e)} (This might be due to missing pgvector extension or no data yet.)")
                
                # Test knowledge search
                knowledge_results = await self.vector_service.search_plant_knowledge(
                    db=db,
                    query=test_text,
                    limit=1
                )
                logger.info(f"✅ Knowledge search test: {len(knowledge_results)} knowledge entries found")
                
                return True
                
        except Exception as e:
            logger.error(f"❌ Error testing RAG functionality: {str(e)}")
            import traceback
            traceback.print_exc()
            return False
    
    async def get_system_status(self):
        """Get comprehensive system status."""
        try:
            async with self.session_factory() as db:
                stats = await self.rag_pipeline.get_indexing_stats(db)
                logger.info("📊 Current RAG system status:")
                logger.info(f"   • Total embeddings: {stats.get('total_embeddings', 0)}")
                logger.info(f"   • Embedding types: {stats.get('embedding_counts', {})}")
                logger.info(f"   • Content coverage: {stats.get('content_coverage', {})}")
                return stats
                
        except Exception as e:
            logger.error(f"❌ Error getting system status: {str(e)}")
            return {}
    
    async def run_full_setup(self):
        """Run the complete RAG infrastructure setup."""
        logger.info("🚀 Starting RAG infrastructure setup...")
        logger.info("=" * 60)
        
        try:
            # 1. Setup database connection
            logger.info("1️⃣  Setting up database connection...")
            await self.setup_database_connection()
            
            # 2. Enable pgvector extension
            logger.info("2️⃣  Enabling pgvector extension (optional for basic RAG)...")
            pgvector_success = await self.enable_pgvector_extension()
            if not pgvector_success:
                logger.warning("⚠️  pgvector setup failed or skipped. RAG system will work, but vector similarity search may be unavailable or less efficient.")
            
            # 3. Create vector indexes
            logger.info("3️⃣  Creating vector indexes (requires pgvector)...")
            indexes_success = await self.create_vector_indexes()
            if not indexes_success:
                logger.warning("⚠️  Vector indexes creation failed or skipped. Search performance may be impacted.")
            
            # 4. Initialize knowledge base
            logger.info("4️⃣  Initializing knowledge base with essential content...")
            kb_success = await self.initialize_knowledge_base()
            if not kb_success:
                logger.error("❌ Knowledge base initialization failed. This is critical for RAG functionality.")
                return False
            
            # 5. Test functionality
            logger.info("5️⃣  Testing RAG functionality...")
            test_success = await self.test_rag_functionality()
            if not test_success:
                logger.warning("⚠️  RAG functionality test had issues. Review logs for details. (May be due to missing OpenAI API key or data).")
            
            # 6. Get final status
            logger.info("6️⃣  Getting final RAG system status...")
            await self.get_system_status()
            
            logger.info("=" * 60)
            logger.info("🎉 RAG infrastructure setup completed successfully!")
            return True
            
        except Exception as e:
            logger.error(f"❌ RAG infrastructure setup failed: {str(e)}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            if self.engine:
                await self.engine.dispose()


def check_environment_variables():
    """Check and display environment variable status."""
    print("🔍 Environment Variables Check:")
    print("-" * 40)
    
    required_vars = {
        "OPENAI_API_KEY": "Required for AI embeddings and RAG functionality. Without it, embedding generation and related features will be skipped.",
        "SQLALCHEMY_DATABASE_URI": "Required database connection string (e.g., `postgresql+asyncpg://user:pass@host:port/db_name`)"
    }
    
    # These are typically components of SQLALCHEMY_DATABASE_URI, but useful for debugging
    optional_vars = {
        "POSTGRES_SERVER": "PostgreSQL server host (used if SQLALCHEMY_DATABASE_URI is not fully specified)",
        "POSTGRES_USER": "PostgreSQL username",
        "POSTGRES_PASSWORD": "PostgreSQL password",
        "POSTGRES_DB": "PostgreSQL database name",
        "POSTGRES_PORT": "PostgreSQL port"
    }
    
    missing_required = []
    
    # Check required variables
    for var, description in required_vars.items():
        value = os.getenv(var)
        if value:
            # Mask sensitive values
            if "KEY" in var or "PASSWORD" in var or "URI" in var:
                display_value = f"{value[:8]}..." if len(value) > 8 else "***"
            else:
                display_value = value[:50] + "..." if len(value) > 50 else value
            print(f"✅ {var}: {display_value}")
        else:
            print(f"❌ {var}: Not set. {description}")
            missing_required.append(var)
    
    # Check optional variables
    print("\n📋 Optional Variables (used for SQLALCHEMY_DATABASE_URI auto-assembly or advanced setup):")
    for var, description in optional_vars.items():
        value = os.getenv(var)
        if value:
            if "PASSWORD" in var:
                display_value = "***"
            else:
                display_value = value
            print(f"✅ {var}: {display_value}")
        else:
            print(f"⚪ {var}: Not set (using default or from SQLALCHEMY_DATABASE_URI if provided).")
    print("-" * 40)
    
    if missing_required:
        print(f"❌ Critical missing environment variables: {', '.join(missing_required)}")
        print("💡 Please add these to your `backend/.env` file or set them in your environment:")
        for var in missing_required:
            print(f"   {var}=your_value_here")
        return False
    else:
        print("✅ All required environment variables seem to be set!")
        return True


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
        logger.info("⏹️  Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"💥 Unexpected error during setup: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    print("🧠 RAG Infrastructure Setup Script")
    print("=" * 50)
    
    # Check environment variables
    if not check_environment_variables():
        sys.exit(1)
    
    asyncio.run(main()) 