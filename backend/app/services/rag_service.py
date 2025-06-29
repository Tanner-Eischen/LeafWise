"""Main RAG service for intelligent plant care and content generation."""

import logging
import time
from typing import List, Dict, Any, Optional, Union
from datetime import datetime
from dataclasses import dataclass

from openai import AsyncOpenAI
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.config import settings
from app.models.rag_models import RAGInteraction, PlantKnowledgeBase
from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService

logger = logging.getLogger(__name__)


@dataclass
class UserContext:
    """User context for personalized RAG responses."""
    user_id: str
    experience_level: str
    location: Optional[str] = None
    plant_collection: List[Dict[str, Any]] = None
    preferences: Dict[str, Any] = None
    recent_activity: List[Dict[str, Any]] = None


@dataclass
class PlantData:
    """Plant-specific data for RAG queries."""
    species_id: str
    species_name: str
    care_level: str
    user_plant_id: Optional[str] = None
    current_health: Optional[str] = None
    care_history: List[Dict[str, Any]] = None


@dataclass
class PlantCareAdvice:
    """Structured plant care advice response."""
    advice: str
    confidence: float
    sources: List[Dict[str, Any]]
    urgent_actions: List[str] = None
    follow_up_questions: List[str] = None
    care_schedule_updates: Dict[str, Any] = None


class RAGService:
    """Main RAG service for intelligent plant care assistance."""
    
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.embedding_service = EmbeddingService()
        self.vector_service = VectorDatabaseService(self.embedding_service)
        
    async def generate_plant_care_advice(
        self,
        db: AsyncSession,
        user_context: UserContext,
        plant_data: PlantData,
        query: str
    ) -> PlantCareAdvice:
        """Generate personalized plant care advice using RAG.
        
        Args:
            db: Database session
            user_context: User context information
            plant_data: Plant-specific data
            query: User's question or concern
            
        Returns:
            PlantCareAdvice with personalized recommendations
        """
        start_time = time.time()
        
        try:
            # Search for relevant plant knowledge
            relevant_docs = await self.vector_service.search_plant_knowledge(
                db=db,
                query=query,
                plant_species_id=plant_data.species_id,
                difficulty_level=self._map_experience_to_difficulty(user_context.experience_level),
                limit=5
            )
            
            # Build context for LLM
            context = self._build_care_advice_context(user_context, plant_data, relevant_docs)
            
            # Generate advice using LLM
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": self._get_plant_care_system_prompt()
                    },
                    {
                        "role": "user",
                        "content": f"Context: {context}\n\nQuestion: {query}"
                    }
                ],
                temperature=0.7,
                max_tokens=800
            )
            
            advice_text = response.choices[0].message.content
            confidence = self._calculate_confidence(relevant_docs)
            
            # Parse structured response
            advice = PlantCareAdvice(
                advice=advice_text,
                confidence=confidence,
                sources=relevant_docs,
                urgent_actions=self._extract_urgent_actions(advice_text),
                follow_up_questions=self._generate_follow_up_questions(query, advice_text)
            )
            
            # Log interaction
            await self._log_rag_interaction(
                db=db,
                user_id=user_context.user_id,
                interaction_type="care_advice",
                query=query,
                retrieved_docs=relevant_docs,
                response=advice_text,
                response_time_ms=int((time.time() - start_time) * 1000),
                confidence=confidence
            )
            
            logger.info(f"Generated plant care advice for user {user_context.user_id}")
            return advice
            
        except Exception as e:
            logger.error(f"Error generating plant care advice: {str(e)}")
            # Return fallback advice
            return PlantCareAdvice(
                advice="I'm having trouble accessing plant care information right now. Please try again later or consult basic care guides.",
                confidence=0.1,
                sources=[]
            )
    
    async def generate_personalized_caption(
        self,
        db: AsyncSession,
        user_context: UserContext,
        image_context: Dict[str, Any],
        plant_data: Optional[PlantData] = None
    ) -> str:
        """Generate personalized caption for plant photo.
        
        Args:
            db: Database session
            user_context: User context information
            image_context: Image analysis context
            plant_data: Plant-specific data if identified
            
        Returns:
            Generated caption text
        """
        start_time = time.time()
        
        try:
            # Get relevant plant information if plant is identified
            plant_info = ""
            if plant_data:
                knowledge_results = await self.vector_service.search_plant_knowledge(
                    db=db,
                    query=f"interesting facts about {plant_data.species_name}",
                    plant_species_id=plant_data.species_id,
                    content_types=['species_info'],
                    limit=2
                )
                plant_info = self._extract_plant_facts(knowledge_results)
            
            # Build caption generation context
            context = self._build_caption_context(user_context, image_context, plant_info)
            
            # Generate caption
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": self._get_caption_generation_system_prompt()
                    },
                    {
                        "role": "user",
                        "content": context
                    }
                ],
                temperature=0.8,
                max_tokens=200
            )
            
            caption = response.choices[0].message.content.strip()
            
            # Log interaction
            await self._log_rag_interaction(
                db=db,
                user_id=user_context.user_id,
                interaction_type="content_generation",
                query=f"Caption for {image_context.get('plant_type', 'plant')} photo",
                response=caption,
                response_time_ms=int((time.time() - start_time) * 1000)
            )
            
            logger.info(f"Generated personalized caption for user {user_context.user_id}")
            return caption
            
        except Exception as e:
            logger.error(f"Error generating caption: {str(e)}")
            return "Beautiful plant moment 🌱 #PlantParent #GreenThumb"
    
    async def analyze_plant_health(
        self,
        db: AsyncSession,
        user_context: UserContext,
        plant_data: PlantData,
        symptoms: List[str]
    ) -> Dict[str, Any]:
        """Analyze plant health issues and provide diagnosis.
        
        Args:
            db: Database session
            user_context: User context information
            plant_data: Plant-specific data
            symptoms: List of observed symptoms
            
        Returns:
            Health analysis with diagnosis and treatment recommendations
        """
        start_time = time.time()
        
        try:
            # Search for relevant problem-solving knowledge
            symptoms_query = " ".join(symptoms)
            relevant_docs = await self.vector_service.search_plant_knowledge(
                db=db,
                query=f"{plant_data.species_name} {symptoms_query} problems diagnosis treatment",
                plant_species_id=plant_data.species_id,
                content_types=['problem_solution', 'care_guide'],
                limit=5
            )
            
            # Build health analysis context
            context = self._build_health_analysis_context(user_context, plant_data, symptoms, relevant_docs)
            
            # Generate health analysis
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": self._get_health_analysis_system_prompt()
                    },
                    {
                        "role": "user",
                        "content": context
                    }
                ],
                temperature=0.3,  # Lower temperature for more factual analysis
                max_tokens=600
            )
            
            analysis_text = response.choices[0].message.content
            
            # Parse structured response
            analysis = self._parse_health_analysis(analysis_text)
            analysis['confidence'] = self._calculate_confidence(relevant_docs)
            analysis['sources'] = relevant_docs
            
            # Log interaction
            await self._log_rag_interaction(
                db=db,
                user_id=user_context.user_id,
                interaction_type="health_diagnosis",
                query=f"Health analysis for {plant_data.species_name}: {symptoms_query}",
                retrieved_docs=relevant_docs,
                response=analysis_text,
                response_time_ms=int((time.time() - start_time) * 1000),
                confidence=analysis['confidence']
            )
            
            logger.info(f"Analyzed plant health for user {user_context.user_id}")
            return analysis
            
        except Exception as e:
            logger.error(f"Error analyzing plant health: {str(e)}")
            return {
                'diagnosis': 'Unable to analyze symptoms at this time',
                'treatment': 'Please consult a plant expert or local nursery',
                'urgency': 'unknown',
                'confidence': 0.1,
                'sources': []
            }
    
    async def get_personalized_recommendations(
        self,
        db: AsyncSession,
        user_id: str,
        recommendation_type: str = "general",
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get personalized content recommendations.
        
        Args:
            db: Database session
            user_id: User ID
            recommendation_type: Type of recommendations
            limit: Maximum number of recommendations
            
        Returns:
            List of personalized recommendations
        """
        try:
            return await self.vector_service.get_personalized_recommendations(
                db=db,
                user_id=user_id,
                recommendation_type=recommendation_type,
                limit=limit
            )
            
        except Exception as e:
            logger.error(f"Error getting recommendations: {str(e)}")
            return []
    
    async def update_user_preferences_from_interaction(
        self,
        db: AsyncSession,
        user_id: str,
        interaction_data: Dict[str, Any]
    ) -> None:
        """Update user preferences based on interactions.
        
        Args:
            db: Database session
            user_id: User ID
            interaction_data: Interaction data to learn from
        """
        try:
            # Extract preferences from interaction
            preferences = self._extract_preferences_from_interaction(interaction_data)
            
            # Update preference embeddings
            for pref_type, pref_data in preferences.items():
                await self.embedding_service.update_user_preferences(
                    db=db,
                    user_id=user_id,
                    preference_type=pref_type,
                    preference_data=pref_data,
                    confidence_score=0.8
                )
            
            logger.info(f"Updated preferences for user {user_id}")
            
        except Exception as e:
            logger.error(f"Error updating user preferences: {str(e)}")
    
    def _build_care_advice_context(
        self,
        user_context: UserContext,
        plant_data: PlantData,
        relevant_docs: List[Dict[str, Any]]
    ) -> str:
        """Build context string for care advice generation."""
        context_parts = []
        
        # User context
        context_parts.append(f"User experience level: {user_context.experience_level}")
        if user_context.location:
            context_parts.append(f"User location: {user_context.location}")
        
        # Plant context
        context_parts.append(f"Plant species: {plant_data.species_name}")
        context_parts.append(f"Care level: {plant_data.care_level}")
        if plant_data.current_health:
            context_parts.append(f"Current health status: {plant_data.current_health}")
        
        # Relevant knowledge
        if relevant_docs:
            context_parts.append("Relevant plant care information:")
            for doc in relevant_docs[:3]:  # Limit to top 3 most relevant
                context_parts.append(f"- {doc['title']}: {doc['content'][:200]}...")
        
        return "\n".join(context_parts)
    
    def _build_caption_context(
        self,
        user_context: UserContext,
        image_context: Dict[str, Any],
        plant_info: str
    ) -> str:
        """Build context for caption generation."""
        context_parts = []
        
        context_parts.append(f"Generate a social media caption for a plant photo.")
        context_parts.append(f"User experience level: {user_context.experience_level}")
        
        if user_context.preferences:
            writing_style = user_context.preferences.get('writing_style', 'casual')
            context_parts.append(f"User's preferred writing style: {writing_style}")
        
        if image_context.get('plant_type'):
            context_parts.append(f"Plant type: {image_context['plant_type']}")
        
        if plant_info:
            context_parts.append(f"Interesting plant facts: {plant_info}")
        
        context_parts.append("Make the caption engaging, informative, and matching the user's style.")
        
        return "\n".join(context_parts)
    
    def _build_health_analysis_context(
        self,
        user_context: UserContext,
        plant_data: PlantData,
        symptoms: List[str],
        relevant_docs: List[Dict[str, Any]]
    ) -> str:
        """Build context for health analysis."""
        context_parts = []
        
        context_parts.append(f"Analyze plant health issues and provide diagnosis.")
        context_parts.append(f"Plant species: {plant_data.species_name}")
        context_parts.append(f"User experience level: {user_context.experience_level}")
        context_parts.append(f"Observed symptoms: {', '.join(symptoms)}")
        
        if relevant_docs:
            context_parts.append("Relevant diagnostic information:")
            for doc in relevant_docs[:3]:
                context_parts.append(f"- {doc['title']}: {doc['content'][:150]}...")
        
        context_parts.append("Provide diagnosis, treatment recommendations, and urgency level.")
        
        return "\n".join(context_parts)
    
    def _get_plant_care_system_prompt(self) -> str:
        """Get system prompt for plant care advice."""
        return """You are an expert plant care advisor. Provide personalized, practical advice based on the user's experience level and plant-specific information. Be encouraging and supportive while being accurate. If you're uncertain about something, acknowledge it and suggest consulting additional resources."""
    
    def _get_caption_generation_system_prompt(self) -> str:
        """Get system prompt for caption generation."""
        return """You are a creative social media content creator specializing in plant content. Generate engaging, authentic captions that match the user's style and experience level. Include relevant hashtags and encourage community engagement."""
    
    def _get_health_analysis_system_prompt(self) -> str:
        """Get system prompt for health analysis."""
        return """You are a plant health diagnostic expert. Analyze symptoms and provide structured diagnosis with treatment recommendations. Be precise about urgency levels and always recommend professional consultation for serious issues."""
    
    def _calculate_confidence(self, relevant_docs: List[Dict[str, Any]]) -> float:
        """Calculate confidence score based on retrieved documents."""
        if not relevant_docs:
            return 0.3
        
        avg_similarity = sum(doc['similarity_score'] for doc in relevant_docs) / len(relevant_docs)
        verified_bonus = 0.1 if any(doc.get('verified') == 'verified' for doc in relevant_docs) else 0
        
        return min(avg_similarity + verified_bonus, 1.0)
    
    def _map_experience_to_difficulty(self, experience_level: str) -> str:
        """Map user experience to plant difficulty level."""
        mapping = {
            'beginner': 'beginner',
            'intermediate': 'intermediate',
            'expert': 'advanced'
        }
        return mapping.get(experience_level, 'beginner')
    
    def _extract_urgent_actions(self, advice_text: str) -> List[str]:
        """Extract urgent actions from advice text."""
        urgent_keywords = ['urgent', 'immediately', 'right away', 'asap', 'critical']
        actions = []
        
        sentences = advice_text.split('.')
        for sentence in sentences:
            if any(keyword in sentence.lower() for keyword in urgent_keywords):
                actions.append(sentence.strip())
        
        return actions
    
    def _generate_follow_up_questions(self, original_query: str, advice: str) -> List[str]:
        """Generate relevant follow-up questions."""
        # Simple implementation - could be enhanced with LLM generation
        return [
            "How often should I check for improvement?",
            "Are there any warning signs to watch for?",
            "When should I seek additional help?"
        ]
    
    def _extract_plant_facts(self, knowledge_results: List[Dict[str, Any]]) -> str:
        """Extract interesting plant facts from knowledge results."""
        facts = []
        for result in knowledge_results:
            content = result.get('content', '')
            # Extract first sentence as a fact
            sentences = content.split('.')
            if sentences:
                facts.append(sentences[0].strip())
        
        return ". ".join(facts[:2])  # Return top 2 facts
    
    def _parse_health_analysis(self, analysis_text: str) -> Dict[str, Any]:
        """Parse structured health analysis from text."""
        # Simple parsing - could be enhanced with structured output
        return {
            'diagnosis': analysis_text.split('\n')[0] if analysis_text else 'Unknown',
            'treatment': analysis_text,
            'urgency': 'medium'  # Default urgency
        }
    
    def _extract_preferences_from_interaction(self, interaction_data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract user preferences from interaction data."""
        preferences = {}
        
        # Extract plant interests
        if 'plant_species' in interaction_data:
            preferences['plant_interests'] = {
                'species': interaction_data['plant_species'],
                'interaction_type': interaction_data.get('interaction_type', 'query')
            }
        
        # Extract content preferences
        if 'query' in interaction_data:
            preferences['content_preferences'] = {
                'topics': [interaction_data['query']],
                'engagement_level': 'high'
            }
        
        return preferences
    
    async def _log_rag_interaction(
        self,
        db: AsyncSession,
        user_id: str,
        interaction_type: str,
        query: str,
        retrieved_docs: Optional[List[Dict[str, Any]]] = None,
        response: Optional[str] = None,
        response_time_ms: Optional[int] = None,
        confidence: Optional[float] = None
    ) -> None:
        """Log RAG interaction for analytics."""
        try:
            query_embedding = await self.embedding_service.generate_text_embedding(query)
            
            interaction = RAGInteraction(
                user_id=user_id,
                interaction_type=interaction_type,
                query_text=query,
                query_embedding=query_embedding,
                retrieved_documents=retrieved_docs,
                generated_response=response,
                response_time_ms=response_time_ms,
                confidence_score=confidence
            )
            
            db.add(interaction)
            await db.commit()
            
        except Exception as e:
            logger.error(f"Error logging RAG interaction: {str(e)}")
            await db.rollback() 