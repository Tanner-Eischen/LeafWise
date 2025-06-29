"""Intelligent content generation service for personalized plant content."""

import logging
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from dataclasses import dataclass
import json
import re

from openai import AsyncOpenAI
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.models.story import Story
from app.models.rag_models import PlantKnowledgeBase, UserPreferenceEmbedding
from app.services.rag_service import RAGService, UserContext
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService

logger = logging.getLogger(__name__)


@dataclass
class ContentGenerationContext:
    """Context for content generation."""
    user_id: str
    content_type: str  # caption, tip, story_suggestion, plant_description
    plant_context: Optional[Dict[str, Any]] = None
    image_context: Optional[Dict[str, Any]] = None
    seasonal_context: Optional[Dict[str, Any]] = None
    user_preferences: Optional[Dict[str, Any]] = None


@dataclass
class GeneratedContent:
    """Generated content with metadata."""
    content: str
    content_type: str
    confidence: float
    tags: List[str]
    engagement_score: float  # predicted engagement potential
    personalization_factors: List[str]
    suggested_hashtags: List[str]


class ContentGenerationService:
    """Service for AI-powered content generation and personalization."""
    
    def __init__(self, rag_service: RAGService, embedding_service: EmbeddingService, vector_service: VectorDatabaseService):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.rag_service = rag_service
        self.embedding_service = embedding_service
        self.vector_service = vector_service
    
    async def generate_plant_caption(
        self,
        db: AsyncSession,
        user_id: str,
        image_context: Dict[str, Any],
        plant_id: Optional[str] = None
    ) -> GeneratedContent:
        """Generate personalized caption for plant photo.
        
        Args:
            db: Database session
            user_id: User ID
            image_context: Context about the image (plant type, setting, etc.)
            plant_id: Optional specific plant ID
            
        Returns:
            GeneratedContent with personalized caption
        """
        try:
            # Get user context and preferences
            user_context = await self._build_user_context(db, user_id)
            
            # Get plant context if plant_id provided
            plant_context = None
            if plant_id:
                plant_context = await self._get_plant_context(db, plant_id)
            
            # Get seasonal context
            seasonal_context = self._get_seasonal_context()
            
            # Build generation context
            context = ContentGenerationContext(
                user_id=user_id,
                content_type="caption",
                plant_context=plant_context,
                image_context=image_context,
                seasonal_context=seasonal_context,
                user_preferences=user_context.get("preferences", {})
            )
            
            # Generate caption using RAG
            caption = await self._generate_caption_with_rag(db, context)
            
            # Enhance with hashtags and engagement optimization
            enhanced_caption = await self._enhance_caption(db, caption, context)
            
            # Calculate confidence and engagement score
            confidence = self._calculate_content_confidence(enhanced_caption, context)
            engagement_score = self._predict_engagement_score(enhanced_caption, context)
            
            # Extract personalization factors
            personalization_factors = self._extract_personalization_factors(context)
            
            # Generate hashtags
            hashtags = self._generate_hashtags(enhanced_caption, context)
            
            result = GeneratedContent(
                content=enhanced_caption,
                content_type="caption",
                confidence=confidence,
                tags=self._extract_content_tags(enhanced_caption),
                engagement_score=engagement_score,
                personalization_factors=personalization_factors,
                suggested_hashtags=hashtags
            )
            
            # Log generation for learning
            await self._log_content_generation(db, user_id, context, result)
            
            logger.info(f"Generated plant caption for user {user_id}")
            return result
            
        except Exception as e:
            logger.error(f"Error generating plant caption: {str(e)}")
            # Return fallback caption
            return GeneratedContent(
                content="Beautiful plant moment 🌱 #PlantParent #GreenThumb",
                content_type="caption",
                confidence=0.3,
                tags=["fallback"],
                engagement_score=0.5,
                personalization_factors=[],
                suggested_hashtags=["#PlantParent", "#GreenThumb"]
            )
    
    async def generate_personalized_plant_tip(
        self,
        db: AsyncSession,
        user_id: str,
        plant_id: Optional[str] = None,
        topic: Optional[str] = None
    ) -> GeneratedContent:
        """Generate personalized plant care tip.
        
        Args:
            db: Database session
            user_id: User ID
            plant_id: Optional specific plant ID
            topic: Optional specific topic (watering, fertilizing, etc.)
            
        Returns:
            GeneratedContent with personalized tip
        """
        try:
            # Get user context
            user_context = await self._build_user_context(db, user_id)
            
            # Get plant context if specified
            plant_context = None
            if plant_id:
                plant_context = await self._get_plant_context(db, plant_id)
            
            # Build generation context
            context = ContentGenerationContext(
                user_id=user_id,
                content_type="plant_tip",
                plant_context=plant_context,
                seasonal_context=self._get_seasonal_context(),
                user_preferences=user_context.get("preferences", {})
            )
            
            # Search for relevant plant knowledge
            search_query = self._build_tip_search_query(context, topic)
            relevant_knowledge = await self.vector_service.search_plant_knowledge(
                db=db,
                query=search_query,
                plant_species_id=plant_context.get("species_id") if plant_context else None,
                difficulty_level=user_context.get("experience_level"),
                limit=3
            )
            
            # Generate tip using LLM
            tip = await self._generate_tip_with_llm(context, relevant_knowledge, topic)
            
            # Calculate metrics
            confidence = self._calculate_content_confidence(tip, context)
            engagement_score = self._predict_engagement_score(tip, context)
            
            result = GeneratedContent(
                content=tip,
                content_type="plant_tip",
                confidence=confidence,
                tags=self._extract_content_tags(tip),
                engagement_score=engagement_score,
                personalization_factors=self._extract_personalization_factors(context),
                suggested_hashtags=self._generate_hashtags(tip, context)
            )
            
            await self._log_content_generation(db, user_id, context, result)
            
            logger.info(f"Generated personalized plant tip for user {user_id}")
            return result
            
        except Exception as e:
            logger.error(f"Error generating plant tip: {str(e)}")
            return GeneratedContent(
                content="Remember to check your plants regularly and adjust care based on the season!",
                content_type="plant_tip",
                confidence=0.3,
                tags=["fallback"],
                engagement_score=0.5,
                personalization_factors=[],
                suggested_hashtags=["#PlantCare"]
            )
    
    async def generate_story_suggestions(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 5
    ) -> List[GeneratedContent]:
        """Generate personalized story content suggestions.
        
        Args:
            db: Database session
            user_id: User ID
            limit: Number of suggestions to generate
            
        Returns:
            List of GeneratedContent with story suggestions
        """
        try:
            # Get user context and plant collection
            user_context = await self._build_user_context(db, user_id)
            user_plants = await self._get_user_plants(db, user_id)
            
            # Get trending topics in plant community
            trending_topics = await self._get_trending_topics(db)
            
            suggestions = []
            
            # Generate different types of story suggestions
            suggestion_types = [
                "plant_progress",
                "care_routine",
                "seasonal_tips",
                "plant_personality",
                "care_challenges"
            ]
            
            for suggestion_type in suggestion_types[:limit]:
                context = ContentGenerationContext(
                    user_id=user_id,
                    content_type="story_suggestion",
                    plant_context={"plants": user_plants},
                    seasonal_context=self._get_seasonal_context(),
                    user_preferences=user_context.get("preferences", {})
                )
                
                suggestion = await self._generate_story_suggestion(
                    db, context, suggestion_type, trending_topics
                )
                
                if suggestion:
                    suggestions.append(suggestion)
            
            logger.info(f"Generated {len(suggestions)} story suggestions for user {user_id}")
            return suggestions
            
        except Exception as e:
            logger.error(f"Error generating story suggestions: {str(e)}")
            return []
    
    async def generate_plant_description(
        self,
        db: AsyncSession,
        user_id: str,
        plant_species_id: str,
        context_type: str = "identification"  # identification, care_guide, social_post
    ) -> GeneratedContent:
        """Generate context-aware plant description.
        
        Args:
            db: Database session
            user_id: User ID
            plant_species_id: Plant species ID
            context_type: Context for the description
            
        Returns:
            GeneratedContent with plant description
        """
        try:
            # Get plant species information
            stmt = select(PlantSpecies).where(PlantSpecies.id == plant_species_id)
            result = await db.execute(stmt)
            species = result.scalar_one_or_none()
            
            if not species:
                raise ValueError(f"Plant species {plant_species_id} not found")
            
            # Get user context
            user_context = await self._build_user_context(db, user_id)
            
            # Search for relevant plant knowledge
            relevant_knowledge = await self.vector_service.search_plant_knowledge(
                db=db,
                query=f"{species.scientific_name} characteristics care information",
                plant_species_id=plant_species_id,
                content_types=["species_info", "care_guide"],
                limit=3
            )
            
            # Build context
            context = ContentGenerationContext(
                user_id=user_id,
                content_type="plant_description",
                plant_context={
                    "species": species,
                    "context_type": context_type
                },
                user_preferences=user_context.get("preferences", {})
            )
            
            # Generate description
            description = await self._generate_plant_description_with_llm(
                context, relevant_knowledge, context_type
            )
            
            result = GeneratedContent(
                content=description,
                content_type="plant_description",
                confidence=self._calculate_content_confidence(description, context),
                tags=self._extract_content_tags(description),
                engagement_score=self._predict_engagement_score(description, context),
                personalization_factors=self._extract_personalization_factors(context),
                suggested_hashtags=self._generate_hashtags(description, context)
            )
            
            await self._log_content_generation(db, user_id, context, result)
            
            logger.info(f"Generated plant description for species {plant_species_id}")
            return result
            
        except Exception as e:
            logger.error(f"Error generating plant description: {str(e)}")
            raise
    
    async def _build_user_context(self, db: AsyncSession, user_id: str) -> Dict[str, Any]:
        """Build comprehensive user context for content generation."""
        try:
            # Get user information
            stmt = select(User).where(User.id == user_id)
            result = await db.execute(stmt)
            user = result.scalar_one_or_none()
            
            if not user:
                return {"experience_level": "beginner", "preferences": {}}
            
            # Get user preferences
            prefs_stmt = select(UserPreferenceEmbedding).where(
                UserPreferenceEmbedding.user_id == user_id
            )
            prefs_result = await db.execute(prefs_stmt)
            preferences = prefs_result.scalars().all()
            
            # Combine preferences
            combined_preferences = {}
            for pref in preferences:
                if pref.meta_data:
                    combined_preferences.update(pref.meta_data)
            
            return {
                "user": user,
                "experience_level": user.gardening_experience or "beginner",
                "location": user.location,
                "preferences": combined_preferences
            }
            
        except Exception as e:
            logger.error(f"Error building user context: {str(e)}")
            return {"experience_level": "beginner", "preferences": {}}
    
    async def _get_plant_context(self, db: AsyncSession, plant_id: str) -> Dict[str, Any]:
        """Get context for a specific plant."""
        try:
            stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.id == plant_id)
            
            result = await db.execute(stmt)
            plant = result.scalar_one_or_none()
            
            if not plant:
                return {}
            
            return {
                "plant": plant,
                "species_id": str(plant.species.id),
                "species_name": plant.species.scientific_name,
                "common_names": plant.species.common_names,
                "nickname": plant.nickname,
                "health_status": plant.health_status,
                "care_level": plant.species.care_level
            }
            
        except Exception as e:
            logger.error(f"Error getting plant context: {str(e)}")
            return {}
    
    def _get_seasonal_context(self) -> Dict[str, Any]:
        """Get current seasonal context."""
        now = datetime.utcnow()
        month = now.month
        
        if month in [12, 1, 2]:
            season = "winter"
            season_mood = "cozy"
            plant_activity = "dormant"
        elif month in [3, 4, 5]:
            season = "spring"
            season_mood = "fresh"
            plant_activity = "growing"
        elif month in [6, 7, 8]:
            season = "summer"
            season_mood = "vibrant"
            plant_activity = "thriving"
        else:
            season = "fall"
            season_mood = "warm"
            plant_activity = "preparing"
        
        return {
            "season": season,
            "mood": season_mood,
            "plant_activity": plant_activity,
            "month": month
        }
    
    async def _generate_caption_with_rag(
        self,
        db: AsyncSession,
        context: ContentGenerationContext
    ) -> str:
        """Generate caption using RAG for relevant plant information."""
        try:
            # Build search query based on context
            search_query = "plant photo caption social media engaging"
            
            if context.plant_context:
                species_name = context.plant_context.get("species_name", "")
                search_query = f"{species_name} {search_query}"
            
            if context.image_context:
                image_type = context.image_context.get("type", "")
                search_query = f"{search_query} {image_type}"
            
            # Search for relevant content
            relevant_docs = await self.vector_service.similarity_search(
                db=db,
                query_embedding=await self.embedding_service.generate_text_embedding(search_query),
                content_types=["species_info", "care_guide"],
                limit=2
            )
            
            # Generate caption with LLM
            prompt = self._build_caption_prompt(context, relevant_docs)
            
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a creative social media content creator specializing in plant content. Generate engaging, authentic captions that match the user's style and experience level."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.8,
                max_tokens=200
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"Error generating caption with RAG: {str(e)}")
            return "Beautiful plant moment 🌱"
    
    async def _enhance_caption(
        self,
        db: AsyncSession,
        caption: str,
        context: ContentGenerationContext
    ) -> str:
        """Enhance caption with personalization and engagement optimization."""
        try:
            # Add seasonal elements
            if context.seasonal_context:
                season = context.seasonal_context.get("season")
                if season == "winter" and "winter" not in caption.lower():
                    caption += " ❄️"
                elif season == "spring" and "spring" not in caption.lower():
                    caption += " 🌸"
                elif season == "summer" and "summer" not in caption.lower():
                    caption += " ☀️"
                elif season == "fall" and "fall" not in caption.lower():
                    caption += " 🍂"
            
            # Add plant-specific emoji if not present
            if context.plant_context and "🌱" not in caption and "🪴" not in caption:
                caption += " 🌱"
            
            # Ensure caption ends with engaging element
            if not any(char in caption for char in ["!", "?", "✨", "💚"]):
                caption += " ✨"
            
            return caption
            
        except Exception as e:
            logger.error(f"Error enhancing caption: {str(e)}")
            return caption
    
    def _build_caption_prompt(
        self,
        context: ContentGenerationContext,
        relevant_docs: List[Dict[str, Any]]
    ) -> str:
        """Build prompt for caption generation."""
        prompt_parts = ["Generate a social media caption for a plant photo."]
        
        # Add user context
        if context.user_preferences:
            experience = context.user_preferences.get("experience_level", "beginner")
            prompt_parts.append(f"User experience level: {experience}")
            
            writing_style = context.user_preferences.get("writing_style", "casual")
            prompt_parts.append(f"Writing style: {writing_style}")
        
        # Add plant context
        if context.plant_context:
            species = context.plant_context.get("species_name", "")
            nickname = context.plant_context.get("nickname", "")
            if species:
                prompt_parts.append(f"Plant: {species}")
            if nickname:
                prompt_parts.append(f"Plant nickname: {nickname}")
        
        # Add image context
        if context.image_context:
            image_type = context.image_context.get("type", "")
            if image_type:
                prompt_parts.append(f"Photo type: {image_type}")
        
        # Add seasonal context
        if context.seasonal_context:
            season = context.seasonal_context.get("season")
            prompt_parts.append(f"Season: {season}")
        
        # Add relevant plant information
        if relevant_docs:
            prompt_parts.append("Relevant plant information:")
            for doc in relevant_docs[:2]:
                content = doc.get("content", "")[:100]
                prompt_parts.append(f"- {content}...")
        
        prompt_parts.append("Generate an engaging, authentic caption (50-150 characters) that encourages interaction.")
        
        return "\n".join(prompt_parts)
    
    async def _generate_tip_with_llm(
        self,
        context: ContentGenerationContext,
        relevant_knowledge: List[Dict[str, Any]],
        topic: Optional[str]
    ) -> str:
        """Generate plant care tip using LLM."""
        try:
            prompt = self._build_tip_prompt(context, relevant_knowledge, topic)
            
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert plant care advisor. Provide practical, actionable tips that are personalized to the user's experience level and current conditions."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=300
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"Error generating tip with LLM: {str(e)}")
            return "Check your plants regularly and adjust care based on their needs!"
    
    def _build_tip_prompt(
        self,
        context: ContentGenerationContext,
        relevant_knowledge: List[Dict[str, Any]],
        topic: Optional[str]
    ) -> str:
        """Build prompt for tip generation."""
        prompt_parts = ["Generate a personalized plant care tip."]
        
        if topic:
            prompt_parts.append(f"Focus on: {topic}")
        
        # Add user context
        if context.user_preferences:
            experience = context.user_preferences.get("experience_level", "beginner")
            prompt_parts.append(f"User experience: {experience}")
        
        # Add plant context
        if context.plant_context:
            species = context.plant_context.get("species_name")
            if species:
                prompt_parts.append(f"Plant species: {species}")
        
        # Add seasonal context
        if context.seasonal_context:
            season = context.seasonal_context.get("season")
            prompt_parts.append(f"Current season: {season}")
        
        # Add relevant knowledge
        if relevant_knowledge:
            prompt_parts.append("Relevant information:")
            for knowledge in relevant_knowledge[:2]:
                content = knowledge.get("content", "")[:200]
                prompt_parts.append(f"- {content}...")
        
        prompt_parts.append("Provide a specific, actionable tip (1-2 sentences) that's appropriate for this user and season.")
        
        return "\n".join(prompt_parts)
    
    def _build_tip_search_query(
        self,
        context: ContentGenerationContext,
        topic: Optional[str]
    ) -> str:
        """Build search query for tip generation."""
        query_parts = ["plant care tips"]
        
        if topic:
            query_parts.append(topic)
        
        if context.plant_context:
            species = context.plant_context.get("species_name")
            if species:
                query_parts.append(species)
        
        if context.seasonal_context:
            season = context.seasonal_context.get("season")
            query_parts.append(f"{season} care")
        
        return " ".join(query_parts)
    
    async def _get_user_plants(self, db: AsyncSession, user_id: str) -> List[Dict[str, Any]]:
        """Get user's plant collection for context."""
        try:
            stmt = select(UserPlant).options(
                selectinload(UserPlant.species)
            ).where(UserPlant.user_id == user_id)
            
            result = await db.execute(stmt)
            plants = result.scalars().all()
            
            return [
                {
                    "id": str(plant.id),
                    "nickname": plant.nickname,
                    "species": plant.species.scientific_name,
                    "common_names": plant.species.common_names,
                    "health_status": plant.health_status
                }
                for plant in plants
            ]
            
        except Exception as e:
            logger.error(f"Error getting user plants: {str(e)}")
            return []
    
    async def _get_trending_topics(self, db: AsyncSession) -> List[str]:
        """Get trending topics in the plant community."""
        try:
            # Get recent stories and their topics
            recent_date = datetime.utcnow() - timedelta(days=7)
            stmt = select(Story).where(Story.created_at >= recent_date)
            result = await db.execute(stmt)
            stories = result.scalars().all()
            
            # Extract topics from story content (simplified)
            topics = ["plant care", "new growth", "propagation", "repotting", "seasonal care"]
            
            return topics
            
        except Exception as e:
            logger.error(f"Error getting trending topics: {str(e)}")
            return ["plant care", "growth progress", "seasonal tips"]
    
    async def _generate_story_suggestion(
        self,
        db: AsyncSession,
        context: ContentGenerationContext,
        suggestion_type: str,
        trending_topics: List[str]
    ) -> Optional[GeneratedContent]:
        """Generate a specific type of story suggestion."""
        try:
            prompts = {
                "plant_progress": "Suggest a story idea about showcasing plant growth progress",
                "care_routine": "Suggest a story idea about sharing daily plant care routine",
                "seasonal_tips": "Suggest a story idea about seasonal plant care tips",
                "plant_personality": "Suggest a story idea about plant personality and characteristics",
                "care_challenges": "Suggest a story idea about overcoming plant care challenges"
            }
            
            base_prompt = prompts.get(suggestion_type, "Suggest an engaging plant-related story idea")
            
            # Add context
            prompt_parts = [base_prompt]
            
            if context.plant_context and context.plant_context.get("plants"):
                plants = context.plant_context["plants"]
                if plants:
                    plant_names = [p.get("nickname") or p.get("species", "") for p in plants[:3]]
                    prompt_parts.append(f"User has plants: {', '.join(plant_names)}")
            
            if context.seasonal_context:
                season = context.seasonal_context.get("season")
                prompt_parts.append(f"Current season: {season}")
            
            prompt_parts.append("Generate a brief, engaging story suggestion (1-2 sentences).")
            
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a creative content strategist for plant enthusiasts. Generate engaging story ideas that encourage community interaction."
                    },
                    {
                        "role": "user",
                        "content": "\n".join(prompt_parts)
                    }
                ],
                temperature=0.9,
                max_tokens=150
            )
            
            suggestion = response.choices[0].message.content.strip()
            
            return GeneratedContent(
                content=suggestion,
                content_type="story_suggestion",
                confidence=0.8,
                tags=[suggestion_type],
                engagement_score=0.7,
                personalization_factors=["user_plants", "season"],
                suggested_hashtags=[f"#{suggestion_type.replace('_', '')}"]
            )
            
        except Exception as e:
            logger.error(f"Error generating story suggestion: {str(e)}")
            return None
    
    async def _generate_plant_description_with_llm(
        self,
        context: ContentGenerationContext,
        relevant_knowledge: List[Dict[str, Any]],
        context_type: str
    ) -> str:
        """Generate plant description using LLM."""
        try:
            species = context.plant_context["species"]
            
            prompt_parts = [
                f"Generate a {context_type} description for {species.scientific_name}."
            ]
            
            if species.common_names:
                prompt_parts.append(f"Common names: {', '.join(species.common_names)}")
            
            # Add context-specific requirements
            if context_type == "identification":
                prompt_parts.append("Focus on distinctive visual characteristics for identification.")
            elif context_type == "care_guide":
                prompt_parts.append("Focus on care requirements and growing conditions.")
            elif context_type == "social_post":
                prompt_parts.append("Write in an engaging, social media friendly tone.")
            
            # Add relevant knowledge
            if relevant_knowledge:
                prompt_parts.append("Relevant information:")
                for knowledge in relevant_knowledge:
                    content = knowledge.get("content", "")[:200]
                    prompt_parts.append(f"- {content}...")
            
            prompt_parts.append("Generate a clear, informative description (2-3 sentences).")
            
            response = await self.client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a plant expert providing accurate, helpful plant descriptions."
                    },
                    {
                        "role": "user",
                        "content": "\n".join(prompt_parts)
                    }
                ],
                temperature=0.6,
                max_tokens=250
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"Error generating plant description: {str(e)}")
            return "This is a beautiful plant species with unique characteristics."
    
    def _calculate_content_confidence(
        self,
        content: str,
        context: ContentGenerationContext
    ) -> float:
        """Calculate confidence score for generated content."""
        base_confidence = 0.7
        
        # Boost confidence if we have good context
        if context.plant_context:
            base_confidence += 0.1
        
        if context.user_preferences:
            base_confidence += 0.1
        
        # Reduce confidence for very short content
        if len(content) < 20:
            base_confidence -= 0.2
        
        # Boost confidence for content with specific plant information
        if any(word in content.lower() for word in ["care", "water", "light", "soil"]):
            base_confidence += 0.1
        
        return min(1.0, max(0.1, base_confidence))
    
    def _predict_engagement_score(
        self,
        content: str,
        context: ContentGenerationContext
    ) -> float:
        """Predict engagement potential of generated content."""
        base_score = 0.5
        
        # Boost for engaging elements
        if any(char in content for char in ["!", "?", "✨", "💚", "🌱"]):
            base_score += 0.2
        
        # Boost for questions (encourage interaction)
        if "?" in content:
            base_score += 0.1
        
        # Boost for seasonal relevance
        if context.seasonal_context:
            season = context.seasonal_context.get("season", "")
            if season.lower() in content.lower():
                base_score += 0.1
        
        # Boost for personalization
        if context.plant_context and context.plant_context.get("nickname"):
            nickname = context.plant_context["nickname"]
            if nickname and nickname.lower() in content.lower():
                base_score += 0.2
        
        return min(1.0, base_score)
    
    def _extract_personalization_factors(self, context: ContentGenerationContext) -> List[str]:
        """Extract factors that contributed to personalization."""
        factors = []
        
        if context.user_preferences:
            factors.append("user_preferences")
        
        if context.plant_context:
            factors.append("plant_specific")
        
        if context.seasonal_context:
            factors.append("seasonal")
        
        if context.image_context:
            factors.append("image_context")
        
        return factors
    
    def _extract_content_tags(self, content: str) -> List[str]:
        """Extract relevant tags from content."""
        tags = []
        
        # Plant-related keywords
        plant_keywords = ["water", "light", "soil", "care", "growth", "leaf", "root", "flower"]
        for keyword in plant_keywords:
            if keyword in content.lower():
                tags.append(keyword)
        
        # Seasonal keywords
        seasonal_keywords = ["spring", "summer", "fall", "winter", "seasonal"]
        for keyword in seasonal_keywords:
            if keyword in content.lower():
                tags.append(keyword)
        
        # Care keywords
        care_keywords = ["fertilize", "repot", "prune", "propagate", "humidity"]
        for keyword in care_keywords:
            if keyword in content.lower():
                tags.append(keyword)
        
        return list(set(tags))  # Remove duplicates
    
    def _generate_hashtags(
        self,
        content: str,
        context: ContentGenerationContext
    ) -> List[str]:
        """Generate relevant hashtags for content."""
        hashtags = ["#PlantParent", "#GreenThumb", "#PlantCare"]
        
        # Add plant-specific hashtags
        if context.plant_context:
            species_name = context.plant_context.get("species_name", "")
            if species_name:
                # Create hashtag from species name
                species_hashtag = "#" + species_name.replace(" ", "").replace(".", "")
                hashtags.append(species_hashtag)
        
        # Add seasonal hashtags
        if context.seasonal_context:
            season = context.seasonal_context.get("season", "")
            if season:
                hashtags.append(f"#{season.capitalize()}Plants")
        
        # Add content-specific hashtags
        if "tip" in context.content_type:
            hashtags.append("#PlantTips")
        elif "caption" in context.content_type:
            hashtags.append("#PlantLife")
        
        # Add care-specific hashtags based on content
        if "water" in content.lower():
            hashtags.append("#PlantWatering")
        if "light" in content.lower():
            hashtags.append("#PlantLight")
        if "growth" in content.lower():
            hashtags.append("#PlantGrowth")
        
        return hashtags[:8]  # Limit to 8 hashtags
    
    async def _log_content_generation(
        self,
        db: AsyncSession,
        user_id: str,
        context: ContentGenerationContext,
        result: GeneratedContent
    ) -> None:
        """Log content generation for analytics and improvement."""
        try:
            # This could be expanded to store in a dedicated table
            # For now, we'll use the RAG interaction logging
            metadata = {
                "content_type": context.content_type,
                "confidence": result.confidence,
                "engagement_score": result.engagement_score,
                "personalization_factors": result.personalization_factors,
                "hashtags": result.suggested_hashtags
            }
            
            # Log using RAG service
            await self.rag_service._log_rag_interaction(
                db=db,
                user_id=user_id,
                interaction_type="content_generation",
                query=f"Generate {context.content_type}",
                response=result.content[:500],  # Truncate if too long
                confidence=result.confidence
            )
            
        except Exception as e:
            logger.error(f"Error logging content generation: {str(e)}") 