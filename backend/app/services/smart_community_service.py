"""Smart community matching service for connecting plant enthusiasts."""

import logging
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
import asyncio

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func, or_, text, desc
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.plant_trade import PlantTrade
from app.models.plant_species import PlantSpecies
from app.models.plant_care_log import PlantCareLog
from app.models.rag_models import UserPreferenceEmbedding
from app.services.vector_database_service import VectorDatabaseService
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


@dataclass
class UserMatch:
    """A matched user with similarity details."""
    user_id: str
    username: str
    display_name: Optional[str]
    similarity_score: float
    matching_factors: List[str]
    shared_interests: List[str]
    expertise_areas: List[str]
    location_match: bool


@dataclass
class ExpertRecommendation:
    """Expert user recommendation for specific plant questions."""
    user_id: str
    username: str
    display_name: Optional[str]
    expertise_score: float
    relevant_experience: List[str]
    success_rate: float
    response_time_avg: int
    plant_count: int
    years_experience: float
    specializations: List[str]


@dataclass
class CommunityInsight:
    """Community insights and analytics."""
    total_matches: int
    avg_similarity_score: float
    top_interests: List[Dict[str, Any]]
    geographic_distribution: Dict[str, int]
    expertise_levels: Dict[str, int]


@dataclass
class SmartRecommendation:
    """Smart recommendation with reasoning."""
    user_id: str
    username: str
    display_name: Optional[str]
    recommendation_type: str
    confidence_score: float
    reasoning: List[str]
    metadata: Dict[str, Any]


class SmartCommunityService:
    """Service for intelligent community matching and recommendations."""
    
    def __init__(self, vector_service: VectorDatabaseService, embedding_service: EmbeddingService):
        self.vector_service = vector_service
        self.embedding_service = embedding_service
    
    async def find_similar_users(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 10,
        include_preferences: bool = True,
        include_behavior: bool = True,
        include_location: bool = True
    ) -> List[UserMatch]:
        """Find users with similar plant interests using AI-powered matching."""
        try:
            # Get comprehensive user context
            target_user_context = await self._get_comprehensive_user_context(db, user_id)
            if not target_user_context:
                logger.warning(f"No context found for user {user_id}")
                return []
            
            # Ensure user has preference embeddings
            await self._ensure_user_preferences(db, user_id, target_user_context)
            
            # Find similar users using multiple similarity methods
            similarity_results = await asyncio.gather(
                self._find_preference_similar_users(db, user_id, limit * 2) if include_preferences else asyncio.coroutine(lambda: [])(),
                self._find_behavioral_similar_users(db, user_id, limit * 2) if include_behavior else asyncio.coroutine(lambda: [])(),
                self._find_location_similar_users(db, user_id, target_user_context, limit * 2) if include_location else asyncio.coroutine(lambda: [])()
            )
            
            preference_matches, behavioral_matches, location_matches = similarity_results
            
            # Combine and weight similarity scores
            combined_matches = self._combine_similarity_scores(
                preference_matches, behavioral_matches, location_matches
            )
            
            # Build detailed UserMatch objects
            matches = []
            for user_data in combined_matches[:limit]:
                user_context = await self._get_comprehensive_user_context(db, user_data['user_id'])
                if user_context:
                    match = await self._build_enhanced_user_match(
                        target_user_context, user_context, user_data
                    )
                    if match:
                        matches.append(match)
            
            logger.info(f"Found {len(matches)} similar users for user {user_id}")
            return matches
            
        except Exception as e:
            logger.error(f"Error finding similar users: {str(e)}")
            return []
    
    async def recommend_plant_experts(
        self,
        db: AsyncSession,
        plant_species_id: Optional[str] = None,
        question_text: Optional[str] = None,
        limit: int = 5
    ) -> List[ExpertRecommendation]:
        """Recommend expert users using AI-powered expertise analysis."""
        try:
            # Get plant species info if provided
            plant_species = None
            if plant_species_id:
                species_stmt = select(PlantSpecies).where(PlantSpecies.id == plant_species_id)
                species_result = await db.execute(species_stmt)
                plant_species = species_result.scalar_one_or_none()
            
            # Find potential experts
            experts_data = await self._find_potential_experts(db, plant_species_id, question_text)
            
            # Calculate comprehensive expertise scores
            experts = []
            for expert_data in experts_data:
                expertise_score = await self._calculate_expertise_score(
                    db, expert_data, plant_species, question_text
                )
                
                if expertise_score > 0.3:  # Minimum threshold
                    expert = ExpertRecommendation(
                        user_id=str(expert_data['user_id']),
                        username=expert_data['username'],
                        display_name=expert_data.get('display_name'),
                        expertise_score=expertise_score,
                        relevant_experience=expert_data.get('relevant_experience', []),
                        success_rate=expert_data.get('success_rate', 0.7),
                        response_time_avg=expert_data.get('response_time_avg', 24),
                        plant_count=expert_data.get('plant_count', 0),
                        years_experience=expert_data.get('years_experience', 0.0),
                        specializations=expert_data.get('specializations', [])
                    )
                    experts.append(expert)
            
            # Sort by expertise score and return top experts
            experts.sort(key=lambda x: x.expertise_score, reverse=True)
            return experts[:limit]
            
        except Exception as e:
            logger.error(f"Error recommending experts: {str(e)}")
            return []
    
    async def find_trading_matches(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Find compatible users for plant trading."""
        try:
            # Get user's plants for trading context
            user_plants_stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.user_id == user_id)
            
            user_plants_result = await db.execute(user_plants_stmt)
            user_plants = user_plants_result.scalars().all()
            
            # Find other users with active trades
            trades_stmt = select(PlantTrade, User).join(User).where(
                and_(
                    PlantTrade.trader_id != user_id,
                    PlantTrade.status == "available"
                )
            ).limit(limit)
            
            trades_result = await db.execute(trades_stmt)
            potential_trades = trades_result.fetchall()
            
            trading_matches = []
            for trade, trader in potential_trades:
                match = {
                    "user_id": str(trader.id),
                    "username": trader.username,
                    "trade_id": str(trade.id),
                    "plant_name": trade.plant_name,
                    "trade_type": trade.trade_type,
                    "location": trader.location,
                    "compatibility_score": 0.8  # Simplified scoring
                }
                trading_matches.append(match)
            
            return trading_matches
            
        except Exception as e:
            logger.error(f"Error finding trading matches: {str(e)}")
            return []
    
    async def discover_local_community(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 15
    ) -> List[UserMatch]:
        """Discover local plant community members."""
        try:
            # Get user location
            user_stmt = select(User).where(User.id == user_id)
            result = await db.execute(user_stmt)
            user = result.scalar_one_or_none()
            
            if not user or not user.location:
                return []
            
            # Find users in similar location (simplified)
            location_filter = user.location.lower()
            
            local_users_stmt = select(User).where(
                and_(
                    User.id != user_id,
                    func.lower(User.location).contains(location_filter)
                )
            ).limit(limit)
            
            result = await db.execute(local_users_stmt)
            local_users = result.scalars().all()
            
            # Build matches
            local_matches = []
            for local_user in local_users:
                user_context = await self._get_user_context(db, str(local_user.id))
                target_context = await self._get_user_context(db, user_id)
                
                if user_context and target_context:
                    similarity_score = self._calculate_interest_similarity(target_context, user_context)
                    
                    if similarity_score > 0.3:
                        match = UserMatch(
                            user_id=str(local_user.id),
                            username=local_user.username,
                            display_name=local_user.display_name,
                            similarity_score=similarity_score,
                            matching_factors=["location"],
                            shared_interests=self._find_shared_interests(target_context, user_context),
                            expertise_areas=[],
                            location_match=True
                        )
                        local_matches.append(match)
            
            return local_matches
            
        except Exception as e:
            logger.error(f"Error discovering local community: {str(e)}")
            return []
    
    async def _get_user_context(self, db: AsyncSession, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user context for matching."""
        try:
            # Get user
            user_stmt = select(User).where(User.id == user_id)
            user_result = await db.execute(user_stmt)
            user = user_result.scalar_one_or_none()
            
            if not user:
                return None
            
            # Get user's plants
            plants_stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.user_id == user_id)
            plants_result = await db.execute(plants_stmt)
            plants = plants_result.scalars().all()
            
            return {
                "user": user,
                "plants": plants,
                "plant_species": [plant.species.scientific_name for plant in plants],
                "experience_level": user.gardening_experience
            }
            
        except Exception as e:
            logger.error(f"Error getting user context: {str(e)}")
            return None
    
    def _build_user_match(
        self,
        target_user: Dict[str, Any],
        candidate_user: Dict[str, Any],
        base_similarity: float
    ) -> Optional[UserMatch]:
        """Build user match object."""
        try:
            matching_factors = []
            shared_interests = []
            
            # Check plant species overlap
            target_species = set(target_user["plant_species"])
            candidate_species = set(candidate_user["plant_species"])
            common_species = target_species.intersection(candidate_species)
            
            if common_species:
                matching_factors.append("plant_species")
                shared_interests.extend(list(common_species))
            
            # Experience level matching
            if target_user["experience_level"] == candidate_user["experience_level"]:
                matching_factors.append("experience_level")
            
            return UserMatch(
                user_id=str(candidate_user["user"].id),
                username=candidate_user["user"].username,
                display_name=candidate_user["user"].display_name,
                similarity_score=base_similarity,
                matching_factors=matching_factors,
                shared_interests=shared_interests,
                expertise_areas=[],
                location_match=False
            )
            
        except Exception as e:
            logger.error(f"Error building user match: {str(e)}")
            return None
    
    def _calculate_interest_similarity(
        self,
        user1_context: Dict[str, Any],
        user2_context: Dict[str, Any]
    ) -> float:
        """Calculate plant interest similarity between users."""
        species1 = set(user1_context.get("plant_species", []))
        species2 = set(user2_context.get("plant_species", []))
        
        if not species1 or not species2:
            return 0.3
        
        # Jaccard similarity
        intersection = len(species1.intersection(species2))
        union = len(species1.union(species2))
        
        if union == 0:
            return 0.3
        
        return intersection / union
    
    def _find_shared_interests(
        self,
        user1_context: Dict[str, Any],
        user2_context: Dict[str, Any]
    ) -> List[str]:
        """Find shared plant interests between users."""
        species1 = set(user1_context.get("plant_species", []))
        species2 = set(user2_context.get("plant_species", []))
        
        return list(species1.intersection(species2))
    
    # ============================================================================
    # NEW ENHANCED METHODS FOR AI-POWERED COMMUNITY MATCHING
    # ============================================================================
    
    async def _get_comprehensive_user_context(self, db: AsyncSession, user_id: str) -> Optional[Dict[str, Any]]:
        """Get comprehensive user context including plants, activities, and preferences."""
        try:
            # Get user basic info
            user_stmt = select(User).where(User.id == user_id)
            user_result = await db.execute(user_stmt)
            user = user_result.scalar_one_or_none()
            
            if not user:
                return None
            
            # Get user's plants with species info
            plants_stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.user_id == user_id)
            plants_result = await db.execute(plants_stmt)
            plants = plants_result.scalars().all()
            
            # Get care logs for activity analysis
            care_logs_stmt = select(PlantCareLog).join(UserPlant).where(
                UserPlant.user_id == user_id
            ).order_by(desc(PlantCareLog.date_logged)).limit(50)
            care_logs_result = await db.execute(care_logs_stmt)
            care_logs = care_logs_result.scalars().all()
            
            # Get questions and answers for expertise analysis
            questions_stmt = select(PlantQuestion).where(PlantQuestion.user_id == user_id)
            questions_result = await db.execute(questions_stmt)
            questions = questions_result.scalars().all()
            
            answers_stmt = select(PlantAnswer).where(PlantAnswer.user_id == user_id)
            answers_result = await db.execute(answers_stmt)
            answers = answers_result.scalars().all()
            
            # Calculate activity metrics
            activity_score = self._calculate_activity_score(plants, care_logs, questions, answers)
            expertise_areas = self._identify_expertise_areas(plants, answers)
            plant_diversity = self._calculate_plant_diversity(plants)
            
            return {
                "user": user,
                "plants": plants,
                "care_logs": care_logs,
                "questions": questions,
                "answers": answers,
                "plant_species": [plant.species.scientific_name for plant in plants if plant.species],
                "plant_families": list(set([plant.species.family for plant in plants if plant.species and plant.species.family])),
                "experience_level": user.gardening_experience,
                "activity_score": activity_score,
                "expertise_areas": expertise_areas,
                "plant_diversity": plant_diversity,
                "years_active": (datetime.utcnow() - user.created_at).days / 365.25 if user.created_at else 0
            }
            
        except Exception as e:
            logger.error(f"Error getting comprehensive user context: {str(e)}")
            return None
    
    async def _ensure_user_preferences(self, db: AsyncSession, user_id: str, user_context: Dict[str, Any]) -> None:
        """Ensure user has preference embeddings, create if missing."""
        try:
            # Check if user has existing preferences
            prefs_stmt = select(UserPreferenceEmbedding).where(UserPreferenceEmbedding.user_id == user_id)
            prefs_result = await db.execute(prefs_stmt)
            existing_prefs = prefs_result.scalars().all()
            
            preference_types = ["plant_interests", "care_style", "content_preferences"]
            existing_types = {pref.preference_type for pref in existing_prefs}
            
            # Create missing preference embeddings
            for pref_type in preference_types:
                if pref_type not in existing_types:
                    await self._create_user_preference_embedding(db, user_id, pref_type, user_context)
            
        except Exception as e:
            logger.error(f"Error ensuring user preferences: {str(e)}")
    
    async def _create_user_preference_embedding(
        self, 
        db: AsyncSession, 
        user_id: str, 
        preference_type: str, 
        user_context: Dict[str, Any]
    ) -> None:
        """Create preference embedding for user."""
        try:
            preference_data = self._extract_preference_data(user_context, preference_type)
            if preference_data:
                await self.embedding_service.update_user_preferences(
                    db=db,
                    user_id=user_id,
                    preference_type=preference_type,
                    preference_data=preference_data,
                    confidence_score=0.7
                )
                logger.info(f"Created {preference_type} preferences for user {user_id}")
        except Exception as e:
            logger.error(f"Error creating user preference embedding: {str(e)}")
    
    def _extract_preference_data(self, user_context: Dict[str, Any], preference_type: str) -> Dict[str, Any]:
        """Extract preference data from user context."""
        if preference_type == "plant_interests":
            return {
                "plant_species": user_context.get("plant_species", []),
                "plant_families": user_context.get("plant_families", []),
                "experience_level": user_context.get("experience_level", "beginner"),
                "plant_diversity": user_context.get("plant_diversity", 0.0)
            }
        elif preference_type == "care_style":
            care_patterns = self._analyze_care_patterns(user_context.get("care_logs", []))
            return {
                "watering_frequency": care_patterns.get("watering_frequency", "moderate"),
                "fertilizing_frequency": care_patterns.get("fertilizing_frequency", "seasonal"),
                "care_consistency": care_patterns.get("consistency_score", 0.5),
                "preferred_care_types": care_patterns.get("preferred_types", [])
            }
        elif preference_type == "content_preferences":
            return {
                "question_topics": self._analyze_question_topics(user_context.get("questions", [])),
                "answer_expertise": user_context.get("expertise_areas", []),
                "engagement_level": user_context.get("activity_score", 0.5)
            }
        return {}
    
    async def _find_preference_similar_users(self, db: AsyncSession, user_id: str, limit: int) -> List[Dict[str, Any]]:
        """Find users with similar preferences using vector similarity."""
        try:
            similar_users = await self.vector_service.find_similar_users(
                db=db,
                user_id=user_id,
                preference_types=["plant_interests", "care_style", "content_preferences"],
                limit=limit,
                similarity_threshold=0.5
            )
            
            return [
                {
                    "user_id": user["id"],
                    "similarity_score": user["similarity_score"],
                    "match_type": "preference"
                }
                for user in similar_users
            ]
        except Exception as e:
            logger.error(f"Error finding preference similar users: {str(e)}")
            return []
    
    async def _find_behavioral_similar_users(self, db: AsyncSession, user_id: str, limit: int) -> List[Dict[str, Any]]:
        """Find users with similar behavior patterns."""
        try:
            # Get user's activity patterns
            user_context = await self._get_comprehensive_user_context(db, user_id)
            if not user_context:
                return []
            
            target_activity = user_context["activity_score"]
            target_expertise = len(user_context["expertise_areas"])
            
            # Find users with similar activity levels and expertise
            users_stmt = select(User).where(User.id != user_id).limit(limit * 3)
            users_result = await db.execute(users_stmt)
            users = users_result.scalars().all()
            
            behavioral_matches = []
            for user in users:
                candidate_context = await self._get_comprehensive_user_context(db, str(user.id))
                if candidate_context:
                    # Calculate behavioral similarity
                    activity_sim = 1.0 - abs(target_activity - candidate_context["activity_score"])
                    expertise_sim = 1.0 - abs(target_expertise - len(candidate_context["expertise_areas"])) / max(target_expertise, len(candidate_context["expertise_areas"]), 1)
                    
                    behavioral_score = (activity_sim + expertise_sim) / 2
                    
                    if behavioral_score > 0.4:
                        behavioral_matches.append({
                            "user_id": str(user.id),
                            "similarity_score": behavioral_score,
                            "match_type": "behavioral"
                        })
            
            # Sort by similarity
            behavioral_matches.sort(key=lambda x: x["similarity_score"], reverse=True)
            return behavioral_matches[:limit]
            
        except Exception as e:
            logger.error(f"Error finding behavioral similar users: {str(e)}")
            return []
    
    async def _find_location_similar_users(
        self, 
        db: AsyncSession, 
        user_id: str, 
        user_context: Dict[str, Any], 
        limit: int
    ) -> List[Dict[str, Any]]:
        """Find users in similar locations."""
        try:
            user_location = user_context["user"].location
            if not user_location:
                return []
            
            # Simple location matching (can be enhanced with geographic libraries)
            location_parts = user_location.lower().split()
            location_conditions = [
                func.lower(User.location).contains(part) for part in location_parts
            ]
            
            local_users_stmt = select(User).where(
                and_(
                    User.id != user_id,
                    or_(*location_conditions)
                )
            ).limit(limit)
            
            result = await db.execute(local_users_stmt)
            local_users = result.scalars().all()
            
            return [
                {
                    "user_id": str(user.id),
                    "similarity_score": 0.8,  # High score for location match
                    "match_type": "location"
                }
                for user in local_users
            ]
            
        except Exception as e:
            logger.error(f"Error finding location similar users: {str(e)}")
            return []
    
    def _combine_similarity_scores(
        self, 
        preference_matches: List[Dict[str, Any]], 
        behavioral_matches: List[Dict[str, Any]], 
        location_matches: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Combine and weight different similarity scores."""
        try:
            # Weights for different match types
            weights = {"preference": 0.5, "behavioral": 0.3, "location": 0.2}
            
            # Combine all matches
            all_matches = {}
            
            for matches, match_type in [
                (preference_matches, "preference"),
                (behavioral_matches, "behavioral"), 
                (location_matches, "location")
            ]:
                for match in matches:
                    user_id = match["user_id"]
                    if user_id not in all_matches:
                        all_matches[user_id] = {
                            "user_id": user_id,
                            "scores": {},
                            "match_types": []
                        }
                    
                    all_matches[user_id]["scores"][match_type] = match["similarity_score"]
                    all_matches[user_id]["match_types"].append(match_type)
            
            # Calculate weighted combined scores
            combined_matches = []
            for user_id, data in all_matches.items():
                weighted_score = sum(
                    data["scores"].get(match_type, 0) * weight
                    for match_type, weight in weights.items()
                )
                
                combined_matches.append({
                    "user_id": user_id,
                    "combined_score": weighted_score,
                    "individual_scores": data["scores"],
                    "match_types": data["match_types"]
                })
            
            # Sort by combined score
            combined_matches.sort(key=lambda x: x["combined_score"], reverse=True)
            return combined_matches
            
        except Exception as e:
            logger.error(f"Error combining similarity scores: {str(e)}")
            return []
    
    async def _build_enhanced_user_match(
        self, 
        target_context: Dict[str, Any], 
        candidate_context: Dict[str, Any], 
        match_data: Dict[str, Any]
    ) -> Optional[UserMatch]:
        """Build enhanced user match with detailed analysis."""
        try:
            candidate_user = candidate_context["user"]
            
            # Analyze matching factors
            matching_factors = self._analyze_matching_factors(target_context, candidate_context, match_data)
            shared_interests = self._find_enhanced_shared_interests(target_context, candidate_context)
            expertise_areas = candidate_context.get("expertise_areas", [])
            
            # Determine location match
            location_match = "location" in match_data.get("match_types", [])
            
            return UserMatch(
                user_id=str(candidate_user.id),
                username=candidate_user.username,
                display_name=candidate_user.display_name,
                similarity_score=match_data["combined_score"],
                matching_factors=matching_factors,
                shared_interests=shared_interests,
                expertise_areas=expertise_areas,
                location_match=location_match
            )
            
        except Exception as e:
            logger.error(f"Error building enhanced user match: {str(e)}")
            return None
    
    async def _find_potential_experts(
        self, 
        db: AsyncSession, 
        plant_species_id: Optional[str], 
        question_text: Optional[str]
    ) -> List[Dict[str, Any]]:
        """Find potential expert users based on species or question."""
        try:
            potential_experts = []
            
            if plant_species_id:
                # Find users with this plant species
                plants_stmt = select(UserPlant, User).join(User).where(
                    UserPlant.species_id == plant_species_id
                ).options(selectinload(UserPlant.species))
                
                plants_result = await db.execute(plants_stmt)
                user_plants = plants_result.fetchall()
                
                for user_plant, user in user_plants:
                    expert_data = await self._build_expert_data(db, user, user_plant)
                    if expert_data:
                        potential_experts.append(expert_data)
            
            if question_text:
                # Use semantic search to find experts based on question content
                query_embedding = await self.embedding_service.generate_text_embedding(question_text)
                
                # Find users with relevant answers or content
                similar_content = await self.vector_service.similarity_search(
                    db=db,
                    query_embedding=query_embedding,
                    content_types=["qa_answer", "user_post"],
                    limit=20
                )
                
                # Extract user IDs from similar content
                expert_user_ids = set()
                for content in similar_content:
                    if content.get("metadata", {}).get("user_id"):
                        expert_user_ids.add(content["metadata"]["user_id"])
                
                # Get expert data for these users
                for user_id in expert_user_ids:
                    user_stmt = select(User).where(User.id == user_id)
                    user_result = await db.execute(user_stmt)
                    user = user_result.scalar_one_or_none()
                    
                    if user:
                        expert_data = await self._build_expert_data(db, user)
                        if expert_data:
                            potential_experts.append(expert_data)
            
            # Remove duplicates and return
            seen_users = set()
            unique_experts = []
            for expert in potential_experts:
                if expert["user_id"] not in seen_users:
                    seen_users.add(expert["user_id"])
                    unique_experts.append(expert)
            
            return unique_experts
            
        except Exception as e:
            logger.error(f"Error finding potential experts: {str(e)}")
            return []
    
    async def _build_expert_data(
        self, 
        db: AsyncSession, 
        user: User, 
        user_plant: Optional[UserPlant] = None
    ) -> Optional[Dict[str, Any]]:
        """Build comprehensive expert data for a user."""
        try:
            # Get user's comprehensive context
            user_context = await self._get_comprehensive_user_context(db, str(user.id))
            if not user_context:
                return None
            
            # Calculate experience metrics
            years_experience = user_context["years_active"]
            plant_count = len(user_context["plants"])
            answer_count = len(user_context["answers"])
            
            # Analyze specializations
            specializations = self._identify_specializations(user_context)
            
            # Calculate success metrics
            success_rate = self._calculate_success_rate(user_context)
            response_time_avg = self._calculate_avg_response_time(user_context)
            
            return {
                "user_id": str(user.id),
                "username": user.username,
                "display_name": user.display_name,
                "years_experience": years_experience,
                "plant_count": plant_count,
                "answer_count": answer_count,
                "specializations": specializations,
                "success_rate": success_rate,
                "response_time_avg": response_time_avg,
                "relevant_experience": self._get_relevant_experience(user_context, user_plant),
                "gardening_experience": user.gardening_experience
            }
            
        except Exception as e:
            logger.error(f"Error building expert data: {str(e)}")
            return None
    
    async def _calculate_expertise_score(
        self, 
        db: AsyncSession, 
        expert_data: Dict[str, Any], 
        plant_species: Optional[PlantSpecies], 
        question_text: Optional[str]
    ) -> float:
        """Calculate comprehensive expertise score for an expert."""
        try:
            base_score = 0.0
            
            # Experience factors (40% of score)
            years_exp = expert_data.get("years_experience", 0)
            plant_count = expert_data.get("plant_count", 0)
            answer_count = expert_data.get("answer_count", 0)
            
            experience_score = min(1.0, (
                (years_exp / 5.0) * 0.4 +  # Max at 5 years
                (plant_count / 20.0) * 0.3 +  # Max at 20 plants
                (answer_count / 50.0) * 0.3   # Max at 50 answers
            ))
            base_score += experience_score * 0.4
            
            # Success rate (30% of score)
            success_rate = expert_data.get("success_rate", 0.5)
            base_score += success_rate * 0.3
            
            # Specialization match (20% of score)
            specializations = expert_data.get("specializations", [])
            if plant_species and plant_species.family in specializations:
                base_score += 0.2
            elif plant_species and plant_species.scientific_name in specializations:
                base_score += 0.15
            
            # Response time bonus (10% of score)
            response_time = expert_data.get("response_time_avg", 48)
            response_score = max(0, 1.0 - (response_time / 48.0))  # Better score for faster response
            base_score += response_score * 0.1
            
            return min(1.0, base_score)
            
        except Exception as e:
            logger.error(f"Error calculating expertise score: {str(e)}")
            return 0.3
    
    # ============================================================================
    # HELPER METHODS FOR ANALYSIS AND CALCULATIONS
    # ============================================================================
    
    def _calculate_activity_score(
        self, 
        plants: List[UserPlant], 
        care_logs: List[PlantCareLog], 
        questions: List[PlantQuestion], 
        answers: List[PlantAnswer]
    ) -> float:
        """Calculate user activity score based on engagement."""
        try:
            # Plant care activity
            plant_score = min(1.0, len(plants) / 10.0)
            
            # Care log activity (recent activity weighted more)
            recent_logs = [log for log in care_logs if (datetime.utcnow() - log.date_logged).days <= 30]
            care_score = min(1.0, len(recent_logs) / 20.0)
            
            # Community engagement
            question_score = min(1.0, len(questions) / 10.0)
            answer_score = min(1.0, len(answers) / 20.0)
            
            # Weighted average
            return (plant_score * 0.3 + care_score * 0.3 + question_score * 0.2 + answer_score * 0.2)
            
        except Exception as e:
            logger.error(f"Error calculating activity score: {str(e)}")
            return 0.5
    
    def _identify_expertise_areas(self, plants: List[UserPlant], answers: List[PlantAnswer]) -> List[str]:
        """Identify user's expertise areas based on plants and answers."""
        try:
            expertise_areas = []
            
            # Plant families from owned plants
            plant_families = [plant.species.family for plant in plants if plant.species and plant.species.family]
            family_counts = {}
            for family in plant_families:
                family_counts[family] = family_counts.get(family, 0) + 1
            
            # Add families with multiple plants as expertise
            for family, count in family_counts.items():
                if count >= 3:  # 3+ plants in same family indicates expertise
                    expertise_areas.append(family)
            
            # Add general categories based on plant types
            if len(plants) >= 5:
                expertise_areas.append("general_plant_care")
            
            return expertise_areas
            
        except Exception as e:
            logger.error(f"Error identifying expertise areas: {str(e)}")
            return []
    
    def _calculate_plant_diversity(self, plants: List[UserPlant]) -> float:
        """Calculate plant diversity score."""
        try:
            if not plants:
                return 0.0
            
            families = set([plant.species.family for plant in plants if plant.species and plant.species.family])
            return len(families) / len(plants) if plants else 0.0
            
        except Exception as e:
            logger.error(f"Error calculating plant diversity: {str(e)}")
            return 0.0
    
    def _analyze_care_patterns(self, care_logs: List[PlantCareLog]) -> Dict[str, Any]:
        """Analyze care patterns from logs."""
        try:
            if not care_logs:
                return {"watering_frequency": "moderate", "consistency_score": 0.5}
            
            care_types = [log.care_type for log in care_logs]
            care_type_counts = {}
            for care_type in care_types:
                care_type_counts[care_type] = care_type_counts.get(care_type, 0) + 1
            
            # Determine most common care type
            most_common_care = max(care_type_counts.items(), key=lambda x: x[1])[0] if care_type_counts else "watering"
            
            # Simple frequency analysis (can be enhanced)
            total_logs = len(care_logs)
            if total_logs >= 20:
                frequency = "high"
            elif total_logs >= 10:
                frequency = "moderate"
            else:
                frequency = "low"
            
            return {
                "watering_frequency": frequency,
                "consistency_score": min(1.0, total_logs / 30.0),
                "preferred_types": list(care_type_counts.keys())
            }
            
        except Exception as e:
            logger.error(f"Error analyzing care patterns: {str(e)}")
            return {"watering_frequency": "moderate", "consistency_score": 0.5}
    
    def _analyze_question_topics(self, questions: List[PlantQuestion]) -> List[str]:
        """Analyze topics from user questions."""
        try:
            # Simple keyword-based topic extraction
            topics = []
            for question in questions:
                if question.title and question.content:
                    text = (question.title + " " + question.content).lower()
                    
                    # Common plant care topics
                    if any(word in text for word in ["water", "watering", "irrigation"]):
                        topics.append("watering")
                    if any(word in text for word in ["fertiliz", "nutrient", "feeding"]):
                        topics.append("fertilizing")
                    if any(word in text for word in ["pest", "bug", "insect"]):
                        topics.append("pest_control")
                    if any(word in text for word in ["disease", "sick", "dying"]):
                        topics.append("plant_health")
                    if any(word in text for word in ["prune", "trim", "cut"]):
                        topics.append("pruning")
            
            return list(set(topics))
            
        except Exception as e:
            logger.error(f"Error analyzing question topics: {str(e)}")
            return []
    
    def _analyze_matching_factors(
        self, 
        target_context: Dict[str, Any], 
        candidate_context: Dict[str, Any], 
        match_data: Dict[str, Any]
    ) -> List[str]:
        """Analyze what factors contributed to the match."""
        try:
            factors = []
            
            # Check match types from similarity calculation
            match_types = match_data.get("match_types", [])
            factors.extend(match_types)
            
            # Check specific overlaps
            target_species = set(target_context.get("plant_species", []))
            candidate_species = set(candidate_context.get("plant_species", []))
            if target_species.intersection(candidate_species):
                factors.append("plant_species_overlap")
            
            target_families = set(target_context.get("plant_families", []))
            candidate_families = set(candidate_context.get("plant_families", []))
            if target_families.intersection(candidate_families):
                factors.append("plant_family_overlap")
            
            # Experience level match
            if target_context.get("experience_level") == candidate_context.get("experience_level"):
                factors.append("experience_level_match")
            
            # Activity level similarity
            target_activity = target_context.get("activity_score", 0)
            candidate_activity = candidate_context.get("activity_score", 0)
            if abs(target_activity - candidate_activity) < 0.2:
                factors.append("similar_activity_level")
            
            return list(set(factors))
            
        except Exception as e:
            logger.error(f"Error analyzing matching factors: {str(e)}")
            return ["general_similarity"]
    
    def _find_enhanced_shared_interests(
        self, 
        target_context: Dict[str, Any], 
        candidate_context: Dict[str, Any]
    ) -> List[str]:
        """Find enhanced shared interests including families and care types."""
        try:
            shared_interests = []
            
            # Plant species overlap
            target_species = set(target_context.get("plant_species", []))
            candidate_species = set(candidate_context.get("plant_species", []))
            shared_species = target_species.intersection(candidate_species)
            shared_interests.extend(list(shared_species))
            
            # Plant family overlap
            target_families = set(target_context.get("plant_families", []))
            candidate_families = set(candidate_context.get("plant_families", []))
            shared_families = target_families.intersection(candidate_families)
            shared_interests.extend([f"{family}_family" for family in shared_families])
            
            # Expertise area overlap
            target_expertise = set(target_context.get("expertise_areas", []))
            candidate_expertise = set(candidate_context.get("expertise_areas", []))
            shared_expertise = target_expertise.intersection(candidate_expertise)
            shared_interests.extend(list(shared_expertise))
            
            return list(set(shared_interests))
            
        except Exception as e:
            logger.error(f"Error finding enhanced shared interests: {str(e)}")
            return []
    
    def _identify_specializations(self, user_context: Dict[str, Any]) -> List[str]:
        """Identify user specializations from their context."""
        try:
            specializations = []
            
            # Plant family specializations
            plant_families = user_context.get("plant_families", [])
            family_counts = {}
            for family in plant_families:
                family_counts[family] = family_counts.get(family, 0) + 1
            
            # Families with 3+ plants indicate specialization
            for family, count in family_counts.items():
                if count >= 3:
                    specializations.append(family)
            
            # Experience-based specializations
            years_exp = user_context.get("years_active", 0)
            if years_exp >= 3:
                specializations.append("experienced_gardener")
            
            plant_count = len(user_context.get("plants", []))
            if plant_count >= 15:
                specializations.append("plant_collector")
            
            # Diversity-based specializations
            diversity = user_context.get("plant_diversity", 0)
            if diversity >= 0.7:
                specializations.append("diverse_gardener")
            
            return specializations
            
        except Exception as e:
            logger.error(f"Error identifying specializations: {str(e)}")
            return []
    
    def _calculate_success_rate(self, user_context: Dict[str, Any]) -> float:
        """Calculate success rate based on plant health and community engagement."""
        try:
            plants = user_context.get("plants", [])
            if not plants:
                return 0.5
            
            # Plant health success rate
            healthy_plants = [p for p in plants if p.health_status in ["healthy", "thriving"]]
            plant_success_rate = len(healthy_plants) / len(plants)
            
            # Community engagement success (simplified)
            answers = user_context.get("answers", [])
            questions = user_context.get("questions", [])
            
            # More answers relative to questions indicates helpfulness
            if len(questions) > 0:
                help_ratio = len(answers) / len(questions)
                community_success = min(1.0, help_ratio)
            else:
                community_success = 0.7 if len(answers) > 0 else 0.5
            
            # Weighted average
            return (plant_success_rate * 0.7 + community_success * 0.3)
            
        except Exception as e:
            logger.error(f"Error calculating success rate: {str(e)}")
            return 0.5
    
    def _calculate_avg_response_time(self, user_context: Dict[str, Any]) -> int:
        """Calculate average response time in hours (simplified)."""
        try:
            answers = user_context.get("answers", [])
            if not answers:
                return 48  # Default 48 hours
            
            # Simplified calculation - in real scenario, would compare answer timestamps with question timestamps
            recent_answers = [a for a in answers if (datetime.utcnow() - a.created_at).days <= 30]
            
            if len(recent_answers) >= 5:
                return 12  # Active responder
            elif len(recent_answers) >= 2:
                return 24  # Moderate responder
            else:
                return 48  # Slow responder
                
        except Exception as e:
            logger.error(f"Error calculating response time: {str(e)}")
            return 24
    
    def _get_relevant_experience(self, user_context: Dict[str, Any], user_plant: Optional[UserPlant] = None) -> List[str]:
        """Get relevant experience areas for an expert."""
        try:
            experience = []
            
            # Plant-specific experience
            if user_plant and user_plant.species:
                experience.append(f"{user_plant.species.scientific_name}_care")
                if user_plant.species.family:
                    experience.append(f"{user_plant.species.family}_family")
            
            # General experience areas
            expertise_areas = user_context.get("expertise_areas", [])
            experience.extend(expertise_areas)
            
            # Experience level
            years_exp = user_context.get("years_active", 0)
            if years_exp >= 3:
                experience.append("experienced_gardener")
            
            return list(set(experience))
            
        except Exception as e:
            logger.error(f"Error getting relevant experience: {str(e)}")
            return ["general_plant_care"]
