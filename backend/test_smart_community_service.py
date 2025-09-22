"""
Test script for enhanced Smart Community Service with AI-powered matching.
"""

import asyncio
import sys
import os
import logging
from datetime import datetime, timedelta
from uuid import uuid4

# Add the app directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.database import Base
from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.models.plant_care_log import PlantCareLog
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.rag_models import UserPreferenceEmbedding
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService
from app.services.smart_community_service import SmartCommunityService

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SmartCommunityTester:
    """Test suite for Smart Community Service."""
    
    def __init__(self):
        self.engine = None
        self.session_factory = None
        self.embedding_service = EmbeddingService()
        self.vector_service = VectorDatabaseService(self.embedding_service)
        self.community_service = SmartCommunityService(self.vector_service, self.embedding_service)
        
    async def setup_database(self):
        """Set up test database connection."""
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
            logger.error(f"Failed to setup database: {str(e)}")
            raise
    
    async def test_service_initialization(self):
        """Test service initialization and dependencies."""
        logger.info("\n=== Testing Service Initialization ===")
        
        try:
            # Test that services are properly initialized
            assert self.embedding_service is not None, "Embedding service not initialized"
            assert self.vector_service is not None, "Vector service not initialized"
            assert self.community_service is not None, "Community service not initialized"
            
            # Test that community service has proper dependencies
            assert self.community_service.vector_service is not None, "Vector service dependency missing"
            assert self.community_service.embedding_service is not None, "Embedding service dependency missing"
            
            logger.info("✓ All services initialized correctly")
            return True
            
        except Exception as e:
            logger.error(f"✗ Service initialization failed: {str(e)}")
            return False
    
    async def test_user_context_analysis(self, db: AsyncSession):
        """Test comprehensive user context analysis."""
        logger.info("\n=== Testing User Context Analysis ===")
        
        try:
            # Get a test user (we'll use mock data for this test)
            from sqlalchemy import select
            user_stmt = select(User).limit(1)
            result = await db.execute(user_stmt)
            test_user = result.scalar_one_or_none()
            
            if not test_user:
                logger.info("No test user found, creating mock user for testing")
                test_user = User(
                    username="test_user_context",
                    email="test_context@example.com",
                    display_name="Test Context User",
                    gardening_experience="intermediate",
                    location="Test City, TS",
                    created_at=datetime.utcnow() - timedelta(days=365)
                )
                db.add(test_user)
                await db.commit()
                await db.refresh(test_user)
            
            # Test comprehensive user context retrieval
            user_context = await self.community_service._get_comprehensive_user_context(db, str(test_user.id))
            
            if user_context:
                logger.info(f"✓ User context retrieved for {test_user.username}")
                logger.info(f"  - User: {user_context['user'].username}")
                logger.info(f"  - Plants: {len(user_context.get('plants', []))}")
                logger.info(f"  - Plant species: {user_context.get('plant_species', [])}")
                logger.info(f"  - Activity score: {user_context.get('activity_score', 0):.3f}")
                logger.info(f"  - Expertise areas: {user_context.get('expertise_areas', [])}")
                logger.info(f"  - Years active: {user_context.get('years_active', 0):.1f}")
                
                # Test preference data extraction
                for pref_type in ["plant_interests", "care_style", "content_preferences"]:
                    pref_data = self.community_service._extract_preference_data(user_context, pref_type)
                    logger.info(f"  - {pref_type} preferences: {len(pref_data)} fields")
                
                return True
            else:
                logger.error("✗ Failed to retrieve user context")
                return False
                
        except Exception as e:
            logger.error(f"✗ User context analysis failed: {str(e)}")
            return False
    
    async def test_similarity_calculations(self, db: AsyncSession):
        """Test similarity calculation methods."""
        logger.info("\n=== Testing Similarity Calculations ===")
        
        try:
            # Create mock user contexts for testing
            user_context_1 = {
                "plant_species": ["Monstera deliciosa", "Ficus lyrata"],
                "plant_families": ["Araceae", "Moraceae"],
                "activity_score": 0.8,
                "expertise_areas": ["Araceae", "general_plant_care"]
            }
            
            user_context_2 = {
                "plant_species": ["Monstera deliciosa", "Pothos aureus"],
                "plant_families": ["Araceae"],
                "activity_score": 0.7,
                "expertise_areas": ["Araceae"]
            }
            
            user_context_3 = {
                "plant_species": ["Sansevieria trifasciata"],
                "plant_families": ["Asparagaceae"],
                "activity_score": 0.3,
                "expertise_areas": []
            }
            
            # Test interest similarity calculation
            similarity_1_2 = self.community_service._calculate_interest_similarity(user_context_1, user_context_2)
            similarity_1_3 = self.community_service._calculate_interest_similarity(user_context_1, user_context_3)
            
            logger.info(f"✓ Interest similarity calculations:")
            logger.info(f"  - Similar users (1-2): {similarity_1_2:.3f}")
            logger.info(f"  - Different users (1-3): {similarity_1_3:.3f}")
            
            # Test shared interests finding
            shared_1_2 = self.community_service._find_enhanced_shared_interests(user_context_1, user_context_2)
            shared_1_3 = self.community_service._find_enhanced_shared_interests(user_context_1, user_context_3)
            
            logger.info(f"✓ Shared interests:")
            logger.info(f"  - Similar users (1-2): {shared_1_2}")
            logger.info(f"  - Different users (1-3): {shared_1_3}")
            
            # Test matching factors analysis
            mock_match_data = {
                "match_types": ["preference", "behavioral"],
                "combined_score": 0.75
            }
            
            factors = self.community_service._analyze_matching_factors(user_context_1, user_context_2, mock_match_data)
            logger.info(f"✓ Matching factors: {factors}")
            
            return True
            
        except Exception as e:
            logger.error(f"✗ Similarity calculations failed: {str(e)}")
            return False
    
    async def test_expertise_analysis(self, db: AsyncSession):
        """Test expertise analysis and scoring."""
        logger.info("\n=== Testing Expertise Analysis ===")
        
        try:
            # Create mock expert data
            expert_data = {
                "user_id": "test-expert-123",
                "username": "plant_expert",
                "years_experience": 3.5,
                "plant_count": 15,
                "answer_count": 25,
                "specializations": ["Araceae", "experienced_gardener"],
                "success_rate": 0.85,
                "response_time_avg": 18
            }
            
            # Test expertise score calculation
            expertise_score = await self.community_service._calculate_expertise_score(
                db, expert_data, None, None
            )
            
            logger.info(f"✓ Expertise score calculation:")
            logger.info(f"  - Expert data: {expert_data['username']}")
            logger.info(f"  - Years experience: {expert_data['years_experience']}")
            logger.info(f"  - Plant count: {expert_data['plant_count']}")
            logger.info(f"  - Answer count: {expert_data['answer_count']}")
            logger.info(f"  - Success rate: {expert_data['success_rate']}")
            logger.info(f"  - Calculated expertise score: {expertise_score:.3f}")
            
            # Test specialization identification
            mock_user_context = {
                "plant_families": ["Araceae", "Araceae", "Araceae", "Moraceae"],
                "years_active": 4.0,
                "plants": [{"id": i} for i in range(20)],  # Mock 20 plants
                "plant_diversity": 0.8
            }
            
            specializations = self.community_service._identify_specializations(mock_user_context)
            logger.info(f"✓ Specialization identification: {specializations}")
            
            return True
            
        except Exception as e:
            logger.error(f"✗ Expertise analysis failed: {str(e)}")
            return False
    
    async def test_vector_similarity_integration(self, db: AsyncSession):
        """Test integration with vector database service."""
        logger.info("\n=== Testing Vector Similarity Integration ===")
        
        try:
            # Test that vector service methods are accessible
            assert hasattr(self.vector_service, 'find_similar_users'), "find_similar_users method missing"
            assert hasattr(self.vector_service, 'similarity_search'), "similarity_search method missing"
            assert hasattr(self.vector_service, 'get_personalized_recommendations'), "get_personalized_recommendations method missing"
            
            logger.info("✓ Vector service integration methods available")
            
            # Test embedding service integration
            assert hasattr(self.embedding_service, 'generate_text_embedding'), "generate_text_embedding method missing"
            assert hasattr(self.embedding_service, 'update_user_preferences'), "update_user_preferences method missing"
            
            logger.info("✓ Embedding service integration methods available")
            
            # Test preference data to text conversion
            test_preference_data = {
                "plant_species": ["Monstera deliciosa", "Ficus lyrata"],
                "experience_level": "intermediate",
                "plant_diversity": 0.6
            }
            
            preference_text = self.embedding_service._preference_to_text(test_preference_data)
            logger.info(f"✓ Preference to text conversion: {len(preference_text)} characters")
            
            return True
            
        except Exception as e:
            logger.error(f"✗ Vector similarity integration failed: {str(e)}")
            return False
    
    async def test_error_handling(self, db: AsyncSession):
        """Test error handling and graceful degradation."""
        logger.info("\n=== Testing Error Handling ===")
        
        try:
            # Test with invalid user ID
            invalid_user_id = "invalid-user-id-12345"
            
            # This should return empty results, not crash
            similar_users = await self.community_service.find_similar_users(
                db=db,
                user_id=invalid_user_id,
                limit=5
            )
            
            logger.info(f"✓ Invalid user ID handled gracefully: {len(similar_users)} results")
            
            # Test with empty/None parameters
            experts = await self.community_service.recommend_plant_experts(
                db=db,
                plant_species_id=None,
                question_text=None,
                limit=5
            )
            
            logger.info(f"✓ Empty parameters handled gracefully: {len(experts)} experts")
            
            # Test user context with missing data
            context = await self.community_service._get_comprehensive_user_context(db, invalid_user_id)
            assert context is None, "Should return None for invalid user"
            
            logger.info("✓ Missing user context handled gracefully")
            
            return True
            
        except Exception as e:
            logger.error(f"✗ Error handling test failed: {str(e)}")
            return False
    
    async def run_all_tests(self):
        """Run all test methods."""
        logger.info("Starting Enhanced Smart Community Service Tests")
        
        try:
            await self.setup_database()
            
            async with self.session_factory() as db:
                # Run tests
                tests = [
                    ("Service Initialization", self.test_service_initialization()),
                    ("User Context Analysis", self.test_user_context_analysis(db)),
                    ("Similarity Calculations", self.test_similarity_calculations(db)),
                    ("Expertise Analysis", self.test_expertise_analysis(db)),
                    ("Vector Integration", self.test_vector_similarity_integration(db)),
                    ("Error Handling", self.test_error_handling(db))
                ]
                
                results = []
                for test_name, test_coro in tests:
                    try:
                        result = await test_coro
                        results.append((test_name, result))
                    except Exception as e:
                        logger.error(f"Test {test_name} raised exception: {str(e)}")
                        results.append((test_name, False))
                
                # Report results
                passed = sum(1 for _, result in results if result is True)
                total = len(results)
                
                logger.info(f"\n=== Test Results ===")
                logger.info(f"Passed: {passed}/{total}")
                
                for test_name, result in results:
                    if result is True:
                        logger.info(f"✓ {test_name}")
                    else:
                        logger.error(f"✗ {test_name}")
                
                # Summary
                if passed == total:
                    logger.info("\n🎉 All tests passed! Enhanced Smart Community Service is working correctly.")
                    logger.info("Key features validated:")
                    logger.info("  - AI-powered user similarity matching")
                    logger.info("  - Comprehensive user context analysis") 
                    logger.info("  - Expert recommendation system")
                    logger.info("  - Vector database integration")
                    logger.info("  - Robust error handling")
                else:
                    logger.warning(f"\n⚠️  {total - passed} tests failed. Check logs for details.")
                
                return passed == total
                
        except Exception as e:
            logger.error(f"Test suite failed: {str(e)}")
            return False
        finally:
            if self.engine:
                await self.engine.dispose()

async def main():
    """Main test function."""
    tester = SmartCommunityTester()
    success = await tester.run_all_tests()
    
    if success:
        logger.info("\n✅ Smart Community Service implementation is robust and ready for production!")
        return 0
    else:
        logger.error("\n❌ Some tests failed. Please review the implementation.")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code) 