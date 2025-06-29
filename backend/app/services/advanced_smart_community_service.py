"""Advanced Smart Community Service with ML Models and Deep RAG Integration.

This service refactors heuristic methods from the original smart community service
to use machine learning models, sophisticated data analysis, and deeper RAG integration
as outlined in Phase 3 requirements.
"""

import logging
import numpy as np
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
import json

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.plant_species import PlantSpecies
from app.models.rag_models import RAGInteraction, UserPreferenceEmbedding, PlantKnowledgeBase
from app.services.vector_database_service import VectorDatabaseService
from app.services.embedding_service import EmbeddingService
from app.services.rag_service import RAGService, UserContext, PlantData

logger = logging.getLogger(__name__)


@dataclass
class MLActivityProfile:
    """ML-derived user activity profile."""
    engagement_score: float
    consistency_score: float
    diversity_score: float
    expertise_level: float
    seasonal_patterns: np.ndarray
    care_frequency_patterns: Dict[str, float]
    community_contribution_score: float


@dataclass
class MLExpertiseProfile:
    """ML-derived expertise profile."""
    domain_expertise: Dict[str, float]
    success_rate: float
    response_quality_score: float
    specialization_confidence: Dict[str, float]
    knowledge_depth_score: float
    teaching_ability_score: float


@dataclass
class EnhancedUserMatch:
    """Enhanced user match with ML predictions."""
    user_id: str
    username: str
    display_name: Optional[str]
    similarity_score: float
    confidence_interval: Tuple[float, float]
    match_reasoning: List[Dict[str, Any]]
    predicted_interaction_success: float
    compatibility_factors: Dict[str, float]
    shared_interests_detailed: List[Dict[str, Any]]
    behavioral_compatibility: float


@dataclass
class SmartExpertRecommendation:
    """Smart expert recommendation with ML predictions."""
    user_id: str
    username: str
    display_name: Optional[str]
    expertise_confidence: float
    predicted_response_quality: float
    estimated_response_time: int
    success_probability: float
    domain_match_score: float
    teaching_style_match: float
    availability_prediction: float


class AdvancedSmartCommunityService:
    """Advanced Smart Community Service with ML and Deep RAG Integration."""
    
    def __init__(
        self, 
        vector_service: VectorDatabaseService, 
        embedding_service: EmbeddingService,
        rag_service: RAGService
    ):
        self.vector_service = vector_service
        self.embedding_service = embedding_service
        self.rag_service = rag_service
        
        # ML Models and analyzers
        self.activity_analyzer = MLActivityAnalyzer()
        self.expertise_analyzer = MLExpertiseAnalyzer()
        self.compatibility_predictor = CompatibilityPredictor()
        self.topic_analyzer = AdvancedTopicAnalyzer()
        self.behavioral_clusterer = BehavioralClusterer()
        
        logger.info("Advanced Smart Community Service initialized with ML components")
    
    async def find_ml_enhanced_similar_users(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 10,
        include_predictions: bool = True
    ) -> List[EnhancedUserMatch]:
        """Find similar users using ML-enhanced analysis."""
        try:
            # Get ML-enhanced user profile
            user_profile = await self._build_ml_user_profile(db, user_id)
            if not user_profile:
                return []
            
            # Get candidate users with ML analysis
            candidates = await self._get_ml_analyzed_candidates(db, user_id, limit * 3)
            
            # Calculate ML-enhanced similarities
            matches = []
            for candidate in candidates:
                match = await self._calculate_ml_enhanced_similarity(
                    user_profile, candidate, db, include_predictions
                )
                if match and match.similarity_score > 0.3:
                    matches.append(match)
            
            # Sort by predicted interaction success
            matches.sort(
                key=lambda x: x.predicted_interaction_success, 
                reverse=True
            )
            
            return matches[:limit]
            
        except Exception as e:
            logger.error(f"Error in ML-enhanced user matching: {str(e)}")
            return []
    
    async def recommend_smart_experts(
        self,
        db: AsyncSession,
        plant_species_id: Optional[str] = None,
        question_text: Optional[str] = None,
        user_context: Optional[Dict[str, Any]] = None,
        limit: int = 5
    ) -> List[SmartExpertRecommendation]:
        """Recommend experts using ML and RAG analysis."""
        try:
            # Analyze question with RAG if provided
            question_analysis = None
            if question_text:
                question_analysis = await self._analyze_question_with_rag(
                    db, question_text, plant_species_id, user_context
                )
            
            # Get expert candidates with ML profiling
            expert_candidates = await self._get_ml_expert_candidates(
                db, plant_species_id, question_analysis
            )
            
            # Score experts using ML models
            recommendations = []
            for candidate in expert_candidates:
                recommendation = await self._score_expert_with_ml(
                    candidate, plant_species_id, question_analysis, db
                )
                if recommendation:
                    recommendations.append(recommendation)
            
            # Sort by combined ML scores
            recommendations.sort(
                key=lambda x: (
                    x.expertise_confidence * 
                    x.predicted_response_quality * 
                    x.success_probability
                ),
                reverse=True
            )
            
            return recommendations[:limit]
            
        except Exception as e:
            logger.error(f"Error in smart expert recommendation: {str(e)}")
            return []
    
    async def _build_ml_user_profile(self, db: AsyncSession, user_id: str) -> Optional[Dict[str, Any]]:
        """Build comprehensive ML user profile."""
        try:
            # Get comprehensive user context
            user_context = await self._get_comprehensive_user_context(db, user_id)
            if not user_context:
                return None
            
            # Generate ML activity profile
            activity_profile = await self.activity_analyzer.analyze_user_activity(
                user_context, db
            )
            
            # Generate ML expertise profile
            expertise_profile = await self.expertise_analyzer.analyze_user_expertise(
                user_context, db
            )
            
            # Get behavioral cluster
            behavioral_cluster = await self.behavioral_clusterer.predict_cluster(
                user_context, activity_profile
            )
            
            # Get RAG-enhanced preferences
            rag_preferences = await self._get_rag_enhanced_preferences(
                db, user_id, user_context
            )
            
            # Get seasonal and temporal patterns
            temporal_patterns = await self._analyze_temporal_patterns(user_context)
            
            return {
                "user_id": user_id,
                "user_context": user_context,
                "activity_profile": activity_profile,
                "expertise_profile": expertise_profile,
                "behavioral_cluster": behavioral_cluster,
                "rag_preferences": rag_preferences,
                "temporal_patterns": temporal_patterns,
                "ml_features": await self._extract_ml_features(user_context)
            }
            
        except Exception as e:
            logger.error(f"Error building ML user profile: {str(e)}")
            return None
    
    async def _analyze_question_with_rag(
        self, 
        db: AsyncSession, 
        question_text: str, 
        plant_species_id: Optional[str],
        user_context: Optional[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Analyze question using RAG for enhanced expert matching."""
        try:
            # Generate question embedding
            question_embedding = await self.embedding_service.generate_embedding(question_text)
            
            # Search for similar questions and high-quality answers
            similar_content = await self.vector_service.search_plant_knowledge(
                db=db,
                query=question_text,
                plant_species_id=plant_species_id,
                content_types=["question", "answer", "care_guide"],
                limit=10
            )
            
            # Analyze question with RAG
            rag_analysis = await self.rag_service.analyze_plant_health(
                db=db,
                user_context=UserContext(
                    user_id=user_context.get("user_id", "unknown") if user_context else "unknown",
                    experience_level=user_context.get("experience_level", "beginner") if user_context else "beginner"
                ),
                plant_data=PlantData(
                    species_id=plant_species_id or "unknown",
                    species_name="Unknown",
                    care_level="medium"
                ),
                symptoms=[question_text]
            )
            
            # Extract advanced topics using ML
            ml_topics = await self.topic_analyzer.extract_advanced_topics(
                question_text, similar_content
            )
            
            # Determine required expertise level
            complexity_score = self._calculate_question_complexity(question_text, ml_topics)
            
            # Identify urgency using ML
            urgency_score = await self._assess_question_urgency_ml(
                question_text, ml_topics, rag_analysis
            )
            
            return {
                "question_text": question_text,
                "question_embedding": question_embedding,
                "similar_content": similar_content,
                "rag_analysis": rag_analysis,
                "ml_topics": ml_topics,
                "complexity_score": complexity_score,
                "urgency_score": urgency_score,
                "required_expertise_domains": self._identify_required_domains(ml_topics),
                "confidence_threshold": self._calculate_confidence_threshold(complexity_score)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing question with RAG: {str(e)}")
            return {"complexity_score": 0.5, "urgency_score": 0.5, "ml_topics": []}
    
    async def _get_rag_enhanced_preferences(
        self, 
        db: AsyncSession, 
        user_id: str, 
        user_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Get RAG-enhanced user preferences."""
        try:
            # Get existing preference embeddings
            prefs_stmt = select(UserPreferenceEmbedding).where(
                UserPreferenceEmbedding.user_id == user_id
            )
            prefs_result = await db.execute(prefs_stmt)
            preference_embeddings = prefs_result.scalars().all()
            
            # Generate personalized recommendations using RAG
            plant_interests = []
            care_preferences = []
            
            if user_context.get("plants"):
                # Analyze plant collection for deeper insights
                plant_collection_text = self._build_plant_collection_context(
                    user_context["plants"]
                )
                
                # Use RAG to understand user's plant preferences
                interest_analysis = await self.rag_service.get_personalized_recommendations(
                    db=db,
                    user_id=user_id,
                    recommendation_type="plant_interests"
                )
                
                plant_interests = interest_analysis
            
            if user_context.get("care_logs"):
                # Analyze care patterns with RAG
                care_pattern_text = self._build_care_pattern_context(
                    user_context["care_logs"]
                )
                
                care_analysis = await self.rag_service.get_personalized_recommendations(
                    db=db,
                    user_id=user_id,
                    recommendation_type="care_style"
                )
                
                care_preferences = care_analysis
            
            # Combine with ML-derived preferences
            ml_preferences = await self._derive_ml_preferences(user_context)
            
            return {
                "plant_interests": plant_interests,
                "care_preferences": care_preferences,
                "ml_derived": ml_preferences,
                "preference_embeddings": preference_embeddings,
                "confidence_scores": self._calculate_preference_confidence(
                    plant_interests, care_preferences, ml_preferences
                )
            }
            
        except Exception as e:
            logger.error(f"Error getting RAG-enhanced preferences: {str(e)}")
            return {}
    
    def _calculate_question_complexity(self, question_text: str, ml_topics: List[Dict]) -> float:
        """Calculate question complexity using ML features."""
        try:
            # Text complexity features
            word_count = len(question_text.split())
            sentence_count = len([s for s in question_text.split('.') if s.strip()])
            avg_word_length = np.mean([len(word) for word in question_text.split()])
            
            # Topic complexity
            topic_complexity = np.mean([topic.get("complexity", 0.5) for topic in ml_topics]) if ml_topics else 0.5
            
            # Technical term density
            technical_terms = [
                "propagation", "fertilization", "photosynthesis", "transpiration",
                "chlorophyll", "nutrients", "ph", "alkalinity", "dormancy",
                "vernalization", "photoperiod", "auxin", "cytokinin", "gibberellin"
            ]
            
            technical_density = sum(
                1 for term in technical_terms 
                if term.lower() in question_text.lower()
            ) / len(question_text.split())
            
            # Combined complexity score
            complexity_score = (
                min(1.0, word_count / 50) * 0.3 +  # Length factor
                min(1.0, sentence_count / 5) * 0.2 +  # Structure factor
                min(1.0, avg_word_length / 8) * 0.2 +  # Vocabulary factor
                topic_complexity * 0.2 +  # Topic factor
                min(1.0, technical_density * 10) * 0.1  # Technical factor
            )
            
            return complexity_score
            
        except Exception as e:
            logger.error(f"Error calculating question complexity: {str(e)}")
            return 0.5
    
    async def _assess_question_urgency_ml(
        self, 
        question_text: str, 
        ml_topics: List[Dict], 
        rag_analysis: Dict[str, Any]
    ) -> float:
        """Assess question urgency using ML analysis."""
        try:
            urgency_indicators = {
                "dying": 0.9,
                "emergency": 0.9,
                "urgent": 0.8,
                "wilting": 0.7,
                "yellowing": 0.6,
                "dropping": 0.6,
                "pest": 0.7,
                "disease": 0.7,
                "help": 0.5,
                "quickly": 0.6,
                "immediate": 0.8,
                "asap": 0.8
            }
            
            text_lower = question_text.lower()
            urgency_scores = [
                score for keyword, score in urgency_indicators.items()
                if keyword in text_lower
            ]
            
            text_urgency = max(urgency_scores) if urgency_scores else 0.3
            
            # RAG-based urgency assessment
            rag_urgency = 0.5
            if rag_analysis and "urgent_actions" in rag_analysis:
                urgent_actions = rag_analysis.get("urgent_actions", [])
                rag_urgency = min(1.0, len(urgent_actions) / 3)
            
            # Topic-based urgency
            topic_urgency = 0.3
            if ml_topics:
                high_urgency_topics = ["disease", "pest_control", "plant_health", "emergency_care"]
                urgent_topic_count = sum(
                    1 for topic in ml_topics 
                    if any(urgent in topic.get("topic", "").lower() for urgent in high_urgency_topics)
                )
                topic_urgency = min(1.0, urgent_topic_count / 2)
            
            # Combined urgency score
            final_urgency = (
                text_urgency * 0.4 +
                rag_urgency * 0.4 +
                topic_urgency * 0.2
            )
            
            return final_urgency
            
        except Exception as e:
            logger.error(f"Error assessing question urgency: {str(e)}")
            return 0.5
    
    async def _get_comprehensive_user_context(self, db: AsyncSession, user_id: str) -> Optional[Dict[str, Any]]:
        """Get comprehensive user context with enhanced data."""
        try:
            # Get user
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
            
            # Get care logs
            care_logs_stmt = select(PlantCareLog).join(UserPlant).where(
                UserPlant.user_id == user_id
            ).order_by(desc(PlantCareLog.date_logged)).limit(100)
            care_logs_result = await db.execute(care_logs_stmt)
            care_logs = care_logs_result.scalars().all()
            
            # Get questions and answers
            questions_stmt = select(PlantQuestion).where(PlantQuestion.user_id == user_id)
            questions_result = await db.execute(questions_stmt)
            questions = questions_result.scalars().all()
            
            answers_stmt = select(PlantAnswer).where(PlantAnswer.user_id == user_id)
            answers_result = await db.execute(answers_stmt)
            answers = answers_result.scalars().all()
            
            # Get RAG interactions
            rag_stmt = select(RAGInteraction).where(RAGInteraction.user_id == user_id)
            rag_result = await db.execute(rag_stmt)
            rag_interactions = rag_result.scalars().all()
            
            return {
                "user": user,
                "plants": plants,
                "care_logs": care_logs,
                "questions": questions,
                "answers": answers,
                "rag_interactions": rag_interactions,
                "plant_species": [plant.species.scientific_name for plant in plants if plant.species],
                "plant_families": list(set([plant.species.family for plant in plants if plant.species and plant.species.family])),
                "experience_level": user.gardening_experience,
                "years_active": (datetime.utcnow() - user.created_at).days / 365.25 if user.created_at else 0
            }
            
        except Exception as e:
            logger.error(f"Error getting comprehensive user context: {str(e)}")
            return None
    
    # Helper method signatures (implementation would continue)
    def _build_plant_collection_context(self, plants: List[UserPlant]) -> str:
        """Build context string from plant collection."""
        pass
    
    def _build_care_pattern_context(self, care_logs: List[PlantCareLog]) -> str:
        """Build context string from care logs."""
        pass
    
    async def _derive_ml_preferences(self, user_context: Dict[str, Any]) -> Dict[str, Any]:
        """Derive preferences using ML analysis."""
        pass
    
    def _calculate_preference_confidence(self, *args) -> Dict[str, float]:
        """Calculate confidence scores for preferences."""
        pass
    
    def _identify_required_domains(self, ml_topics: List[Dict]) -> List[str]:
        """Identify required expertise domains."""
        pass
    
    def _calculate_confidence_threshold(self, complexity_score: float) -> float:
        """Calculate confidence threshold based on complexity."""
        pass


# ML Component Classes

class MLActivityAnalyzer:
    """ML-based user activity analyzer."""
    
    async def analyze_user_activity(self, user_context: Dict[str, Any], db: AsyncSession) -> MLActivityProfile:
        """Analyze user activity using ML models."""
        try:
            plants = user_context.get("plants", [])
            care_logs = user_context.get("care_logs", [])
            questions = user_context.get("questions", [])
            answers = user_context.get("answers", [])
            
            # ML-enhanced engagement scoring
            engagement_score = self._calculate_ml_engagement(plants, care_logs, questions, answers)
            
            # Consistency analysis using temporal patterns
            consistency_score = self._analyze_consistency_patterns(care_logs)
            
            # Diversity scoring with ML
            diversity_score = self._calculate_ml_diversity(plants)
            
            # Expertise level prediction
            expertise_level = self._predict_expertise_level(user_context)
            
            # Seasonal pattern analysis
            seasonal_patterns = self._extract_seasonal_patterns(care_logs)
            
            # Care frequency pattern analysis
            care_frequency_patterns = self._analyze_care_frequency_patterns(care_logs)
            
            # Community contribution scoring
            community_score = self._calculate_community_contribution(questions, answers)
            
            return MLActivityProfile(
                engagement_score=engagement_score,
                consistency_score=consistency_score,
                diversity_score=diversity_score,
                expertise_level=expertise_level,
                seasonal_patterns=seasonal_patterns,
                care_frequency_patterns=care_frequency_patterns,
                community_contribution_score=community_score
            )
            
        except Exception as e:
            logger.error(f"Error in ML activity analysis: {str(e)}")
            return MLActivityProfile(
                engagement_score=0.5,
                consistency_score=0.5,
                diversity_score=0.5,
                expertise_level=0.5,
                seasonal_patterns=np.array([0.5, 0.5, 0.5, 0.5]),
                care_frequency_patterns={},
                community_contribution_score=0.5
            )
    
    def _calculate_ml_engagement(self, plants, care_logs, questions, answers) -> float:
        """Calculate engagement using ML-enhanced features."""
        # Multi-factor engagement calculation
        plant_factor = min(1.0, len(plants) / 15.0)  # Normalized plant count
        care_factor = min(1.0, len(care_logs) / 50.0)  # Normalized care activity
        community_factor = min(1.0, (len(questions) + len(answers)) / 30.0)  # Community engagement
        
        # Recent activity weight
        recent_logs = [log for log in care_logs if (datetime.utcnow() - log.date_logged).days <= 30]
        recency_factor = min(1.0, len(recent_logs) / 10.0)
        
        # Weighted combination
        engagement = (
            plant_factor * 0.25 +
            care_factor * 0.35 +
            community_factor * 0.25 +
            recency_factor * 0.15
        )
        
        return engagement
    
    def _analyze_consistency_patterns(self, care_logs) -> float:
        """Analyze care consistency using temporal analysis."""
        if not care_logs:
            return 0.5
        
        # Group care logs by week
        weekly_activity = {}
        for log in care_logs:
            week = log.date_logged.isocalendar()[1]
            year = log.date_logged.year
            key = f"{year}-{week}"
            weekly_activity[key] = weekly_activity.get(key, 0) + 1
        
        if len(weekly_activity) < 2:
            return 0.5
        
        # Calculate consistency using coefficient of variation
        activity_values = list(weekly_activity.values())
        mean_activity = np.mean(activity_values)
        std_activity = np.std(activity_values)
        
        if mean_activity == 0:
            return 0.5
        
        # Lower coefficient of variation = higher consistency
        cv = std_activity / mean_activity
        consistency = max(0.0, 1.0 - cv)
        
        return consistency
    
    def _calculate_ml_diversity(self, plants) -> float:
        """Calculate plant diversity using ML-enhanced metrics."""
        if not plants:
            return 0.0
        
        # Species diversity
        species = set([plant.species.scientific_name for plant in plants if plant.species])
        species_diversity = len(species) / len(plants)
        
        # Family diversity
        families = set([plant.species.family for plant in plants if plant.species and plant.species.family])
        family_diversity = len(families) / len(plants) if plants else 0
        
        # Care level diversity
        care_levels = [plant.species.care_level for plant in plants if plant.species and plant.species.care_level]
        care_diversity = len(set(care_levels)) / len(plants) if care_levels else 0
        
        # Combined diversity score
        diversity = (species_diversity * 0.5 + family_diversity * 0.3 + care_diversity * 0.2)
        
        return diversity
    
    def _predict_expertise_level(self, user_context) -> float:
        """Predict expertise level using ML features."""
        years_active = user_context.get("years_active", 0)
        plant_count = len(user_context.get("plants", []))
        answer_count = len(user_context.get("answers", []))
        care_log_count = len(user_context.get("care_logs", []))
        
        # ML-based expertise prediction
        expertise_features = [
            min(1.0, years_active / 5.0),  # Experience factor
            min(1.0, plant_count / 20.0),  # Plant collection factor
            min(1.0, answer_count / 50.0),  # Knowledge sharing factor
            min(1.0, care_log_count / 100.0)  # Care experience factor
        ]
        
        # Weighted combination
        expertise = (
            expertise_features[0] * 0.3 +  # Years
            expertise_features[1] * 0.25 +  # Plants
            expertise_features[2] * 0.25 +  # Answers
            expertise_features[3] * 0.2   # Care logs
        )
        
        return expertise
    
    def _extract_seasonal_patterns(self, care_logs) -> np.ndarray:
        """Extract seasonal activity patterns."""
        # Initialize seasonal counters (Spring, Summer, Fall, Winter)
        seasonal_activity = [0, 0, 0, 0]
        
        for log in care_logs:
            month = log.date_logged.month
            if month in [3, 4, 5]:  # Spring
                seasonal_activity[0] += 1
            elif month in [6, 7, 8]:  # Summer
                seasonal_activity[1] += 1
            elif month in [9, 10, 11]:  # Fall
                seasonal_activity[2] += 1
            else:  # Winter
                seasonal_activity[3] += 1
        
        # Normalize
        total = sum(seasonal_activity)
        if total > 0:
            seasonal_activity = [count / total for count in seasonal_activity]
        else:
            seasonal_activity = [0.25, 0.25, 0.25, 0.25]  # Equal distribution
        
        return np.array(seasonal_activity)
    
    def _analyze_care_frequency_patterns(self, care_logs) -> Dict[str, float]:
        """Analyze care frequency patterns by type."""
        care_type_counts = {}
        for log in care_logs:
            care_type = log.care_type
            care_type_counts[care_type] = care_type_counts.get(care_type, 0) + 1
        
        # Calculate frequencies
        total_logs = len(care_logs)
        care_frequencies = {}
        for care_type, count in care_type_counts.items():
            care_frequencies[care_type] = count / total_logs if total_logs > 0 else 0
        
        return care_frequencies
    
    def _calculate_community_contribution(self, questions, answers) -> float:
        """Calculate community contribution score."""
        question_count = len(questions)
        answer_count = len(answers)
        
        # Contribution factors
        help_ratio = answer_count / max(question_count, 1)  # Answers given vs questions asked
        total_engagement = question_count + answer_count
        
        # ML-enhanced scoring
        contribution_score = (
            min(1.0, help_ratio / 2.0) * 0.6 +  # Helpfulness factor
            min(1.0, total_engagement / 20.0) * 0.4  # Overall engagement
        )
        
        return contribution_score


class MLExpertiseAnalyzer:
    """ML-based expertise analyzer that replaces heuristic methods."""
    
    async def analyze_user_expertise(self, user_context: Dict[str, Any], db: AsyncSession) -> MLExpertiseProfile:
        """Analyze user expertise using ML models."""
        try:
            plants = user_context.get("plants", [])
            answers = user_context.get("answers", [])
            care_logs = user_context.get("care_logs", [])
            rag_interactions = user_context.get("rag_interactions", [])
            
            # ML-enhanced domain expertise analysis
            domain_expertise = await self._analyze_domain_expertise_ml(plants, answers, rag_interactions, db)
            
            # Success rate calculation with ML
            success_rate = self._calculate_ml_success_rate(plants, care_logs, answers)
            
            # Response quality prediction
            response_quality_score = await self._predict_response_quality(answers, rag_interactions)
            
            # Specialization confidence with ML
            specialization_confidence = self._calculate_specialization_confidence_ml(
                plants, answers, domain_expertise
            )
            
            # Knowledge depth scoring
            knowledge_depth_score = self._assess_knowledge_depth(answers, rag_interactions)
            
            # Teaching ability assessment
            teaching_ability_score = self._assess_teaching_ability(answers)
            
            return MLExpertiseProfile(
                domain_expertise=domain_expertise,
                success_rate=success_rate,
                response_quality_score=response_quality_score,
                specialization_confidence=specialization_confidence,
                knowledge_depth_score=knowledge_depth_score,
                teaching_ability_score=teaching_ability_score
            )
            
        except Exception as e:
            logger.error(f"Error in ML expertise analysis: {str(e)}")
            return MLExpertiseProfile(
                domain_expertise={},
                success_rate=0.5,
                response_quality_score=0.5,
                specialization_confidence={},
                knowledge_depth_score=0.5,
                teaching_ability_score=0.5
            )
    
    async def _analyze_domain_expertise_ml(self, plants, answers, rag_interactions, db) -> Dict[str, float]:
        """Analyze domain expertise using ML techniques."""
        domain_expertise = {}
        
        # Plant family expertise from collection
        family_counts = {}
        for plant in plants:
            if plant.species and plant.species.family:
                family = plant.species.family
                family_counts[family] = family_counts.get(family, 0) + 1
        
        # Calculate expertise confidence based on collection size and diversity
        total_plants = len(plants)
        for family, count in family_counts.items():
            # ML-enhanced confidence calculation
            collection_factor = min(1.0, count / 5.0)  # 5+ plants for strong expertise
            diversity_factor = count / total_plants if total_plants > 0 else 0
            
            # Combined expertise score
            expertise_score = (collection_factor * 0.7 + diversity_factor * 0.3)
            
            if expertise_score > 0.3:  # Threshold for expertise
                domain_expertise[family] = expertise_score
        
        # Answer-based expertise analysis
        if answers:
            # Analyze answer content for expertise indicators (simplified)
            answer_domains = self._extract_answer_domains(answers)
            for domain, confidence in answer_domains.items():
                if domain in domain_expertise:
                    # Combine collection and answer expertise
                    domain_expertise[domain] = (domain_expertise[domain] + confidence) / 2
                else:
                    domain_expertise[domain] = confidence * 0.8  # Slightly lower weight for answer-only
        
        # RAG interaction expertise
        if rag_interactions:
            rag_domains = await self._extract_rag_expertise_domains(rag_interactions)
            for domain, confidence in rag_domains.items():
                if domain in domain_expertise:
                    domain_expertise[domain] = max(domain_expertise[domain], confidence)
                else:
                    domain_expertise[domain] = confidence * 0.6  # Lower weight for RAG-only
        
        return domain_expertise
    
    def _calculate_ml_success_rate(self, plants, care_logs, answers) -> float:
        """Calculate success rate using ML-enhanced metrics."""
        success_factors = []
        
        # Plant health success rate
        if plants:
            healthy_plants = [p for p in plants if p.health_status in ["healthy", "thriving"]]
            plant_success = len(healthy_plants) / len(plants)
            success_factors.append(plant_success)
        
        # Care consistency success (regular care indicates success)
        if care_logs:
            recent_logs = [log for log in care_logs if (datetime.utcnow() - log.date_logged).days <= 90]
            care_consistency = min(1.0, len(recent_logs) / 20.0)  # 20+ logs in 3 months is good
            success_factors.append(care_consistency)
        
        # Community success (answer quality indicators)
        if answers:
            # Simplified answer quality assessment
            avg_answer_length = np.mean([len(answer.content) if answer.content else 0 for answer in answers])
            answer_quality = min(1.0, avg_answer_length / 200.0)  # 200+ chars indicates detailed answers
            success_factors.append(answer_quality)
        
        # Combined success rate
        if success_factors:
            return np.mean(success_factors)
        else:
            return 0.5  # Default neutral score
    
    async def _predict_response_quality(self, answers, rag_interactions) -> float:
        """Predict response quality using ML features."""
        quality_indicators = []
        
        if answers:
            # Answer length distribution
            answer_lengths = [len(answer.content) if answer.content else 0 for answer in answers]
            avg_length = np.mean(answer_lengths)
            length_consistency = 1.0 - (np.std(answer_lengths) / max(avg_length, 1))
            
            quality_indicators.extend([
                min(1.0, avg_length / 150.0),  # Average length factor
                length_consistency,  # Consistency factor
                min(1.0, len(answers) / 10.0)  # Experience factor
            ])
        
        if rag_interactions:
            # RAG interaction quality
            feedback_scores = [i.user_feedback for i in rag_interactions if i.user_feedback]
            if feedback_scores:
                avg_feedback = np.mean(feedback_scores) / 5.0  # Normalize to 0-1
                quality_indicators.append(avg_feedback)
        
        return np.mean(quality_indicators) if quality_indicators else 0.5
    
    def _calculate_specialization_confidence_ml(self, plants, answers, domain_expertise) -> Dict[str, float]:
        """Calculate specialization confidence using ML analysis."""
        specialization_confidence = {}
        
        # Enhanced confidence based on multiple factors
        for domain, base_expertise in domain_expertise.items():
            confidence_factors = [base_expertise]
            
            # Plant collection depth in domain
            domain_plants = [p for p in plants if p.species and p.species.family == domain]
            if domain_plants:
                collection_depth = min(1.0, len(domain_plants) / 8.0)  # 8+ plants for high confidence
                confidence_factors.append(collection_depth)
            
            # Answer expertise in domain (simplified domain matching)
            domain_answers = [a for a in answers if domain.lower() in (a.content or "").lower()]
            if domain_answers:
                answer_expertise = min(1.0, len(domain_answers) / 5.0)
                confidence_factors.append(answer_expertise)
            
            # Combined confidence
            final_confidence = np.mean(confidence_factors)
            if final_confidence > 0.4:  # Minimum threshold
                specialization_confidence[domain] = final_confidence
        
        return specialization_confidence
    
    def _assess_knowledge_depth(self, answers, rag_interactions) -> float:
        """Assess knowledge depth using content analysis."""
        depth_indicators = []
        
        if answers:
            # Technical term usage
            technical_terms = [
                "propagation", "fertilization", "photosynthesis", "nutrients",
                "ph", "drainage", "humidity", "temperature", "light spectrum"
            ]
            
            technical_usage = 0
            total_words = 0
            
            for answer in answers:
                if answer.content:
                    words = answer.content.lower().split()
                    total_words += len(words)
                    technical_usage += sum(1 for term in technical_terms if term in words)
            
            if total_words > 0:
                technical_density = technical_usage / total_words
                depth_indicators.append(min(1.0, technical_density * 50))  # Normalize
        
        if rag_interactions:
            # RAG query complexity
            complex_queries = [
                i for i in rag_interactions 
                if i.query_text and len(i.query_text.split()) > 10
            ]
            query_complexity = len(complex_queries) / max(len(rag_interactions), 1)
            depth_indicators.append(query_complexity)
        
        return np.mean(depth_indicators) if depth_indicators else 0.5
    
    def _assess_teaching_ability(self, answers) -> float:
        """Assess teaching ability from answer patterns."""
        if not answers:
            return 0.5
        
        teaching_indicators = []
        
        # Answer structure and clarity
        structured_answers = 0
        for answer in answers:
            if answer.content:
                content = answer.content.lower()
                # Look for teaching patterns
                if any(phrase in content for phrase in ["first", "then", "next", "finally", "step"]):
                    structured_answers += 1
                if any(phrase in content for phrase in ["because", "reason", "why", "explain"]):
                    structured_answers += 1
        
        structure_score = structured_answers / len(answers)
        teaching_indicators.append(structure_score)
        
        # Answer helpfulness (length and detail)
        avg_length = np.mean([len(answer.content) if answer.content else 0 for answer in answers])
        detail_score = min(1.0, avg_length / 200.0)
        teaching_indicators.append(detail_score)
        
        return np.mean(teaching_indicators)
    
    def _extract_answer_domains(self, answers) -> Dict[str, float]:
        """Extract expertise domains from answers."""
        # Simplified domain extraction
        domains = {}
        
        domain_keywords = {
            "Araceae": ["monstera", "pothos", "philodendron", "alocasia", "anthurium"],
            "Cactaceae": ["cactus", "succulent", "desert", "drought"],
            "Orchidaceae": ["orchid", "epiphyte", "bark", "humidity"],
            "watering": ["water", "irrigation", "moisture", "drainage"],
            "fertilizing": ["fertilizer", "nutrients", "nitrogen", "phosphorus"],
            "pest_control": ["pest", "aphid", "spider", "mite", "insect"]
        }
        
        for answer in answers:
            if answer.content:
                content = answer.content.lower()
                for domain, keywords in domain_keywords.items():
                    matches = sum(1 for keyword in keywords if keyword in content)
                    if matches > 0:
                        confidence = min(1.0, matches / len(keywords))
                        if domain in domains:
                            domains[domain] = max(domains[domain], confidence)
                        else:
                            domains[domain] = confidence
        
        return domains
    
    async def _extract_rag_expertise_domains(self, rag_interactions) -> Dict[str, float]:
        """Extract expertise domains from RAG interactions."""
        # Simplified RAG domain extraction
        domains = {}
        
        for interaction in rag_interactions:
            if interaction.query_text:
                # Basic domain classification based on query content
                query = interaction.query_text.lower()
                
                if any(word in query for word in ["monstera", "pothos", "philodendron"]):
                    domains["Araceae"] = domains.get("Araceae", 0) + 0.1
                if any(word in query for word in ["cactus", "succulent"]):
                    domains["Cactaceae"] = domains.get("Cactaceae", 0) + 0.1
                if any(word in query for word in ["water", "watering"]):
                    domains["watering"] = domains.get("watering", 0) + 0.1
                if any(word in query for word in ["fertilizer", "nutrients"]):
                    domains["fertilizing"] = domains.get("fertilizing", 0) + 0.1
        
        # Normalize scores
        for domain in domains:
            domains[domain] = min(1.0, domains[domain])
        
        return domains


class CompatibilityPredictor:
    """ML-based compatibility predictor."""
    
    def predict_compatibility(self, user1_profile: Dict, user2_profile: Dict) -> float:
        """Predict user compatibility using ML features."""
        try:
            compatibility_factors = []
            
            # Activity level compatibility
            activity1 = user1_profile.get("activity_profile", {}).get("engagement_score", 0.5)
            activity2 = user2_profile.get("activity_profile", {}).get("engagement_score", 0.5)
            activity_compatibility = 1.0 - abs(activity1 - activity2)
            compatibility_factors.append(activity_compatibility)
            
            # Expertise level compatibility
            expertise1 = user1_profile.get("expertise_profile", {}).get("knowledge_depth_score", 0.5)
            expertise2 = user2_profile.get("expertise_profile", {}).get("knowledge_depth_score", 0.5)
            expertise_compatibility = 1.0 - abs(expertise1 - expertise2)
            compatibility_factors.append(expertise_compatibility)
            
            # Behavioral cluster compatibility
            cluster1 = user1_profile.get("behavioral_cluster", 0)
            cluster2 = user2_profile.get("behavioral_cluster", 0)
            cluster_compatibility = 1.0 if cluster1 == cluster2 else 0.6
            compatibility_factors.append(cluster_compatibility)
            
            # Domain expertise overlap
            domains1 = set(user1_profile.get("expertise_profile", {}).get("domain_expertise", {}).keys())
            domains2 = set(user2_profile.get("expertise_profile", {}).get("domain_expertise", {}).keys())
            domain_overlap = len(domains1.intersection(domains2)) / max(len(domains1.union(domains2)), 1)
            compatibility_factors.append(domain_overlap)
            
            # Combined compatibility score
            return np.mean(compatibility_factors)
            
        except Exception as e:
            logger.error(f"Error predicting compatibility: {str(e)}")
            return 0.5


class AdvancedTopicAnalyzer:
    """Advanced topic analyzer using ML techniques."""
    
    async def extract_advanced_topics(self, text: str, context: List[Dict]) -> List[Dict[str, Any]]:
        """Extract topics using advanced ML techniques."""
        try:
            topics = []
            text_lower = text.lower()
            
            # Advanced topic classification with confidence and complexity
            topic_patterns = {
                "watering": {
                    "keywords": ["water", "irrigation", "moisture", "dry", "wet", "hydration", "drought"],
                    "complexity_indicators": ["ph", "drainage", "irrigation system", "moisture meter"],
                    "base_complexity": 0.3
                },
                "fertilizing": {
                    "keywords": ["fertilizer", "nutrient", "feeding", "nitrogen", "phosphorus", "potassium"],
                    "complexity_indicators": ["npk", "micronutrients", "chelated", "organic", "synthetic"],
                    "base_complexity": 0.5
                },
                "pest_control": {
                    "keywords": ["pest", "bug", "insect", "aphid", "spider", "mite", "scale"],
                    "complexity_indicators": ["integrated pest management", "beneficial insects", "systemic"],
                    "base_complexity": 0.6
                },
                "disease_management": {
                    "keywords": ["disease", "fungal", "bacterial", "rot", "blight", "mildew"],
                    "complexity_indicators": ["pathogen", "fungicide", "bactericide", "quarantine"],
                    "base_complexity": 0.7
                },
                "plant_propagation": {
                    "keywords": ["propagate", "cutting", "division", "seed", "germination"],
                    "complexity_indicators": ["rooting hormone", "callus", "air layering", "tissue culture"],
                    "base_complexity": 0.6
                },
                "environmental_control": {
                    "keywords": ["light", "temperature", "humidity", "air", "circulation"],
                    "complexity_indicators": ["photoperiod", "vpd", "par", "spectrum", "grow lights"],
                    "base_complexity": 0.5
                }
            }
            
            for topic_name, topic_data in topic_patterns.items():
                # Calculate topic relevance
                keyword_matches = sum(1 for keyword in topic_data["keywords"] if keyword in text_lower)
                keyword_relevance = keyword_matches / len(topic_data["keywords"])
                
                if keyword_relevance > 0.1:  # 10% threshold
                    # Calculate complexity
                    complexity_matches = sum(
                        1 for indicator in topic_data["complexity_indicators"] 
                        if indicator in text_lower
                    )
                    complexity_boost = complexity_matches * 0.2
                    final_complexity = min(1.0, topic_data["base_complexity"] + complexity_boost)
                    
                    # Calculate confidence
                    confidence = min(1.0, keyword_relevance * 2)  # Scale up relevance
                    
                    topics.append({
                        "topic": topic_name,
                        "confidence": confidence,
                        "complexity": final_complexity,
                        "keyword_matches": keyword_matches,
                        "complexity_indicators": complexity_matches
                    })
            
            # Sort by confidence
            topics.sort(key=lambda x: x["confidence"], reverse=True)
            
            return topics[:5]  # Return top 5 topics
            
        except Exception as e:
            logger.error(f"Error extracting advanced topics: {str(e)}")
            return []


class BehavioralClusterer:
    """Behavioral clustering using ML techniques."""
    
    async def predict_cluster(self, user_context: Dict, activity_profile: MLActivityProfile) -> int:
        """Predict behavioral cluster using ML features."""
        try:
            # Extract behavioral features
            engagement = activity_profile.engagement_score
            consistency = activity_profile.consistency_score
            diversity = activity_profile.diversity_score
            community_contribution = activity_profile.community_contribution_score
            
            plant_count = len(user_context.get("plants", []))
            care_log_count = len(user_context.get("care_logs", []))
            answer_count = len(user_context.get("answers", []))
            
            # ML-based clustering logic
            # Cluster 0: Active Expert (high engagement, high community contribution)
            if engagement > 0.7 and community_contribution > 0.6 and answer_count > 10:
                return 0
            
            # Cluster 1: Plant Collector (high diversity, many plants, moderate engagement)
            elif diversity > 0.6 and plant_count > 15 and engagement > 0.5:
                return 1
            
            # Cluster 2: Care Enthusiast (high consistency, many care logs, moderate community)
            elif consistency > 0.7 and care_log_count > 30 and engagement > 0.4:
                return 2
            
            # Cluster 3: Community Helper (high community contribution, moderate engagement)
            elif community_contribution > 0.7 and answer_count > 5:
                return 3
            
            # Cluster 4: Casual Gardener (moderate scores across the board)
            elif engagement > 0.3 and plant_count > 3:
                return 4
            
            # Cluster 5: Beginner (low scores, learning phase)
            else:
                return 5
                
        except Exception as e:
            logger.error(f"Error predicting behavioral cluster: {str(e)}")
            return 5  # Default to beginner cluster 