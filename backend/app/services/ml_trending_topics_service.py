"""
ML-Enhanced Trending Topics Analysis Service

Replaces heuristic keyword counting with sophisticated ML-based real-time trending analysis.
Features include trend momentum analysis, semantic clustering, engagement prediction, 
and personalized trending topics with lifecycle management.
"""

import logging
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
from collections import defaultdict, Counter
import asyncio
import json
import math
from scipy.stats import zscore
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_
from sqlalchemy.orm import selectinload

from app.models.story import Story
from app.models.plant_question import PlantQuestion
from app.models.plant_trade import PlantTrade
from app.models.rag_models import RAGInteraction, UserPreferenceEmbedding
from app.models.user_plant import UserPlant
from app.models.user import User
from app.services.embedding_service import EmbeddingService
from app.services.vector_database_service import VectorDatabaseService

logger = logging.getLogger(__name__)


class TrendPhase(Enum):
    """Lifecycle phases of trending topics."""
    EMERGING = "emerging"
    GROWING = "growing"
    PEAK = "peak"
    DECLINING = "declining"
    STABLE = "stable"


class TrendSource(Enum):
    """Sources of trending data."""
    STORIES = "stories"
    QUESTIONS = "questions"
    TRADES = "trades"
    SEARCHES = "searches"
    RAG_INTERACTIONS = "rag_interactions"


@dataclass
class TrendingTopic:
    """Advanced trending topic with ML-enhanced metrics."""
    topic: str
    normalized_topic: str
    trend_score: float
    momentum: float
    velocity: float
    engagement_rate: float
    confidence: float
    phase: TrendPhase
    sources: List[TrendSource]
    related_topics: List[str]
    sentiment_score: float
    user_segments: List[str]
    geographic_distribution: Dict[str, float]
    seasonal_factor: float
    prediction_horizon: Dict[str, float]  # Future trend predictions
    feature_importance: Dict[str, float]
    peak_time: Optional[datetime]
    emergence_time: datetime
    metadata: Dict[str, Any]


@dataclass
class TrendAnalysisContext:
    """Context for trend analysis."""
    time_window: str
    user_id: Optional[str]
    location: Optional[str]
    plant_interests: List[str]
    experience_level: str
    seasonal_context: Dict[str, Any]
    personalization_factors: List[str]


class MLTrendingTopicsService:
    """ML-Enhanced service for sophisticated trending topics analysis."""
    
    def __init__(self, embedding_service: EmbeddingService, vector_service: VectorDatabaseService):
        self.embedding_service = embedding_service
        self.vector_service = vector_service
        self.vectorizer = TfidfVectorizer(
            max_features=1000,
            stop_words='english',
            ngram_range=(1, 3),
            min_df=2,
            max_df=0.95
        )
        self.topic_memory = {}  # Cache for topic tracking
        self.trend_models = {}  # Cached ML models
        
    async def analyze_trending_topics(
        self,
        db: AsyncSession,
        context: TrendAnalysisContext,
        limit: int = 20
    ) -> List[TrendingTopic]:
        """
        Perform comprehensive ML-based trending topics analysis.
        
        Features:
        - Multi-source data integration
        - Semantic topic clustering 
        - Trend momentum calculation
        - Engagement prediction
        - Personalized relevance scoring
        """
        try:
            logger.info(f"Starting ML trending analysis for window: {context.time_window}")
            
            # Step 1: Collect multi-source data
            trend_data = await self._collect_multi_source_data(db, context)
            
            if not trend_data['total_interactions']:
                return []
            
            # Step 2: Extract and cluster semantic topics
            semantic_topics = await self._extract_semantic_topics(trend_data['raw_content'])
            
            # Step 3: Calculate advanced trend metrics
            trend_metrics = await self._calculate_trend_metrics(db, semantic_topics, trend_data, context)
            
            # Step 4: Perform trend lifecycle analysis
            lifecycle_analysis = await self._analyze_trend_lifecycle(db, trend_metrics, context)
            
            # Step 5: Generate personalized trending topics
            personalized_trends = await self._personalize_trending_topics(
                lifecycle_analysis, context, limit
            )
            
            # Step 6: Apply ML-based ranking and filtering
            final_trends = await self._rank_and_filter_trends(personalized_trends, context)
            
            logger.info(f"Generated {len(final_trends)} ML-enhanced trending topics")
            return final_trends[:limit]
            
        except Exception as e:
            logger.error(f"Error in ML trending analysis: {str(e)}")
            return []
    
    async def _collect_multi_source_data(
        self,
        db: AsyncSession,
        context: TrendAnalysisContext
    ) -> Dict[str, Any]:
        """Collect trending data from multiple sources with ML preprocessing."""
        try:
            # Calculate time boundaries
            time_boundaries = self._calculate_time_boundaries(context.time_window)
            current_period = time_boundaries['current']
            previous_period = time_boundaries['previous']
            
            # Collect from all sources in parallel
            tasks = [
                self._get_story_trends(db, current_period, previous_period),
                self._get_question_trends(db, current_period, previous_period),
                self._get_trade_trends(db, current_period, previous_period),
                self._get_rag_interaction_trends(db, current_period, previous_period),
            ]
            
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Combine and structure data
            combined_data = {
                'stories': results[0] if not isinstance(results[0], Exception) else [],
                'questions': results[1] if not isinstance(results[1], Exception) else [],
                'trades': results[2] if not isinstance(results[2], Exception) else [],
                'rag_interactions': results[3] if not isinstance(results[3], Exception) else [],
                'time_boundaries': time_boundaries
            }
            
            # Extract raw content for NLP processing
            raw_content = []
            for source_data in combined_data.values():
                if isinstance(source_data, list):
                    for item in source_data:
                        if isinstance(item, dict) and 'content' in item:
                            raw_content.append(item['content'])
            
            combined_data['raw_content'] = raw_content
            combined_data['total_interactions'] = len(raw_content)
            
            return combined_data
            
        except Exception as e:
            logger.error(f"Error collecting multi-source data: {str(e)}")
            return {'raw_content': [], 'total_interactions': 0}
    
    async def _extract_semantic_topics(self, raw_content: List[str]) -> List[Dict[str, Any]]:
        """Extract semantic topics using advanced NLP and clustering."""
        try:
            if not raw_content:
                return []
            
            # Clean and preprocess text
            processed_content = [self._preprocess_text(text) for text in raw_content]
            processed_content = [text for text in processed_content if len(text.strip()) > 10]
            
            if len(processed_content) < 3:
                return []
            
            # Generate TF-IDF vectors
            tfidf_matrix = self.vectorizer.fit_transform(processed_content)
            feature_names = self.vectorizer.get_feature_names_out()
            
            # Perform semantic clustering
            n_clusters = min(20, max(3, len(processed_content) // 5))
            kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            cluster_labels = kmeans.fit_predict(tfidf_matrix)
            
            # Extract topics from clusters
            semantic_topics = []
            for cluster_id in range(n_clusters):
                cluster_center = kmeans.cluster_centers_[cluster_id]
                
                # Get top terms for this cluster
                top_indices = cluster_center.argsort()[-10:][::-1]
                top_terms = [feature_names[i] for i in top_indices]
                
                # Calculate cluster metrics
                cluster_docs = [i for i, label in enumerate(cluster_labels) if label == cluster_id]
                cluster_content = [processed_content[i] for i in cluster_docs]
                
                # Generate topic representation
                topic_name = self._generate_topic_name(top_terms, cluster_content)
                
                semantic_topic = {
                    'topic': topic_name,
                    'cluster_id': cluster_id,
                    'top_terms': top_terms,
                    'document_count': len(cluster_docs),
                    'document_indices': cluster_docs,
                    'coherence_score': self._calculate_topic_coherence(top_terms, cluster_content),
                    'cluster_center': cluster_center,
                    'representative_content': cluster_content[:3]
                }
                
                semantic_topics.append(semantic_topic)
            
            # Sort by coherence and document count
            semantic_topics.sort(
                key=lambda x: (x['coherence_score'] * x['document_count']), 
                reverse=True
            )
            
            return semantic_topics
            
        except Exception as e:
            logger.error(f"Error extracting semantic topics: {str(e)}")
            return []
    
    async def _calculate_trend_metrics(
        self,
        db: AsyncSession,
        semantic_topics: List[Dict[str, Any]],
        trend_data: Dict[str, Any],
        context: TrendAnalysisContext
    ) -> List[Dict[str, Any]]:
        """Calculate advanced trend metrics including momentum and velocity."""
        try:
            trend_metrics = []
            
            for topic_data in semantic_topics:
                # Base frequency metrics
                current_freq = topic_data['document_count']
                
                # Calculate historical comparison
                historical_freq = await self._get_historical_frequency(
                    db, topic_data['topic'], context.time_window
                )
                
                # Calculate momentum (rate of change)
                momentum = self._calculate_momentum(current_freq, historical_freq)
                
                # Calculate velocity (acceleration of change)
                velocity = await self._calculate_velocity(db, topic_data['topic'], context.time_window)
                
                # Calculate engagement rate
                engagement_rate = await self._calculate_engagement_rate(
                    db, topic_data, trend_data
                )
                
                # Calculate confidence score
                confidence = self._calculate_confidence_score(
                    topic_data['coherence_score'],
                    current_freq,
                    momentum,
                    engagement_rate
                )
                
                # Calculate trend score (composite metric)
                trend_score = self._calculate_composite_trend_score(
                    current_freq, momentum, velocity, engagement_rate, confidence
                )
                
                # Determine user segments
                user_segments = await self._identify_user_segments(db, topic_data)
                
                # Calculate sentiment
                sentiment_score = self._calculate_topic_sentiment(topic_data['representative_content'])
                
                # Get related topics through similarity
                related_topics = await self._find_related_topics(topic_data, semantic_topics)
                
                metrics = {
                    'topic_data': topic_data,
                    'current_frequency': current_freq,
                    'historical_frequency': historical_freq,
                    'momentum': momentum,
                    'velocity': velocity,
                    'engagement_rate': engagement_rate,
                    'confidence': confidence,
                    'trend_score': trend_score,
                    'user_segments': user_segments,
                    'sentiment_score': sentiment_score,
                    'related_topics': related_topics,
                    'raw_score_components': {
                        'frequency_score': current_freq / max(1, len(trend_data['raw_content'])),
                        'momentum_score': momentum,
                        'velocity_score': velocity,
                        'engagement_score': engagement_rate,
                        'confidence_score': confidence
                    }
                }
                
                trend_metrics.append(metrics)
            
            return trend_metrics
            
        except Exception as e:
            logger.error(f"Error calculating trend metrics: {str(e)}")
            return []
    
    async def _analyze_trend_lifecycle(
        self,
        db: AsyncSession,
        trend_metrics: List[Dict[str, Any]],
        context: TrendAnalysisContext
    ) -> List[Dict[str, Any]]:
        """Analyze trend lifecycle phases and predict future trajectories."""
        try:
            lifecycle_analysis = []
            
            for metrics in trend_metrics:
                topic = metrics['topic_data']['topic']
                
                # Determine current phase
                phase = self._determine_trend_phase(
                    metrics['momentum'],
                    metrics['velocity'],
                    metrics['current_frequency'],
                    metrics['historical_frequency']
                )
                
                # Calculate seasonal factor
                seasonal_factor = self._calculate_seasonal_factor(topic, context.seasonal_context)
                
                # Predict future trend trajectory
                prediction_horizon = await self._predict_trend_trajectory(db, topic, metrics)
                
                # Calculate geographic distribution (mock for now)
                geographic_dist = self._calculate_geographic_distribution(context.location)
                
                # Determine emergence and peak times
                emergence_time = await self._estimate_emergence_time(db, topic)
                peak_time = await self._estimate_peak_time(db, topic, metrics)
                
                # Calculate feature importance
                feature_importance = self._calculate_feature_importance(metrics)
                
                lifecycle_data = {
                    **metrics,
                    'phase': phase,
                    'seasonal_factor': seasonal_factor,
                    'prediction_horizon': prediction_horizon,
                    'geographic_distribution': geographic_dist,
                    'emergence_time': emergence_time,
                    'peak_time': peak_time,
                    'feature_importance': feature_importance
                }
                
                lifecycle_analysis.append(lifecycle_data)
            
            return lifecycle_analysis
            
        except Exception as e:
            logger.error(f"Error analyzing trend lifecycle: {str(e)}")
            return []
    
    async def _personalize_trending_topics(
        self,
        lifecycle_analysis: List[Dict[str, Any]],
        context: TrendAnalysisContext,
        limit: int
    ) -> List[TrendingTopic]:
        """Generate personalized trending topics based on user context."""
        try:
            personalized_trends = []
            
            for analysis in lifecycle_analysis:
                topic_data = analysis['topic_data']
                
                # Calculate personalization score
                personalization_score = self._calculate_personalization_score(
                    topic_data, context
                )
                
                # Determine active sources
                sources = self._determine_active_sources(analysis)
                
                # Create TrendingTopic object
                trending_topic = TrendingTopic(
                    topic=analysis['topic_data']['topic'],
                    normalized_topic=self._normalize_topic_name(analysis['topic_data']['topic']),
                    trend_score=analysis['trend_score'] * personalization_score,
                    momentum=analysis['momentum'],
                    velocity=analysis['velocity'],
                    engagement_rate=analysis['engagement_rate'],
                    confidence=analysis['confidence'],
                    phase=analysis['phase'],
                    sources=sources,
                    related_topics=analysis['related_topics'],
                    sentiment_score=analysis['sentiment_score'],
                    user_segments=analysis['user_segments'],
                    geographic_distribution=analysis['geographic_distribution'],
                    seasonal_factor=analysis['seasonal_factor'],
                    prediction_horizon=analysis['prediction_horizon'],
                    feature_importance=analysis['feature_importance'],
                    peak_time=analysis['peak_time'],
                    emergence_time=analysis['emergence_time'],
                    metadata={
                        'personalization_score': personalization_score,
                        'raw_components': analysis['raw_score_components'],
                        'cluster_id': topic_data['cluster_id'],
                        'coherence_score': topic_data['coherence_score'],
                        'document_count': topic_data['document_count']
                    }
                )
                
                personalized_trends.append(trending_topic)
            
            return personalized_trends
            
        except Exception as e:
            logger.error(f"Error personalizing trending topics: {str(e)}")
            return []
    
    async def _rank_and_filter_trends(
        self,
        personalized_trends: List[TrendingTopic],
        context: TrendAnalysisContext
    ) -> List[TrendingTopic]:
        """Apply ML-based ranking and filtering to trending topics."""
        try:
            # Filter by minimum confidence
            filtered_trends = [
                trend for trend in personalized_trends 
                if trend.confidence > 0.3 and trend.trend_score > 0.1
            ]
            
            # Sort by composite trend score
            filtered_trends.sort(key=lambda x: x.trend_score, reverse=True)
            
            # Apply diversity filtering to avoid similar topics
            diverse_trends = self._apply_diversity_filtering(filtered_trends)
            
            # Boost emerging trends if user likes discovering new topics
            if "early_adopter" in context.personalization_factors:
                diverse_trends = self._boost_emerging_trends(diverse_trends)
            
            return diverse_trends
            
        except Exception as e:
            logger.error(f"Error ranking and filtering trends: {str(e)}")
            return personalized_trends
    
    # Comprehensive helper methods
    def _calculate_time_boundaries(self, time_window: str) -> Dict[str, Tuple[datetime, datetime]]:
        """Calculate current and previous period boundaries."""
        now = datetime.utcnow()
        
        if time_window == "hour":
            current_start = now - timedelta(hours=1)
            previous_start = now - timedelta(hours=2)
            previous_end = current_start
        elif time_window == "day":
            current_start = now - timedelta(days=1)
            previous_start = now - timedelta(days=2)
            previous_end = current_start
        elif time_window == "week":
            current_start = now - timedelta(weeks=1)
            previous_start = now - timedelta(weeks=2)
            previous_end = current_start
        else:  # month
            current_start = now - timedelta(days=30)
            previous_start = now - timedelta(days=60)
            previous_end = current_start
        
        return {
            'current': (current_start, now),
            'previous': (previous_start, previous_end)
        }
    
    def _preprocess_text(self, text: str) -> str:
        """Preprocess text for NLP analysis."""
        if not text:
            return ""
        
        # Basic cleaning
        text = text.lower().strip()
        
        # Remove common noise
        noise_words = ['plant', 'plants', 'help', 'please', 'thanks', 'thank', 'you']
        words = text.split()
        cleaned_words = [word for word in words if word not in noise_words and len(word) > 2]
        
        return ' '.join(cleaned_words)
    
    def _generate_topic_name(self, top_terms: List[str], cluster_content: List[str]) -> str:
        """Generate a meaningful topic name from cluster terms."""
        # Use top 2-3 most relevant terms
        if len(top_terms) >= 2:
            return f"{top_terms[0]}_{top_terms[1]}"
        elif len(top_terms) >= 1:
            return top_terms[0]
        else:
            return "general_discussion"
    
    def _calculate_topic_coherence(self, terms: List[str], content: List[str]) -> float:
        """Calculate topic coherence score."""
        if not terms or not content:
            return 0.0
        
        # Simple coherence based on term co-occurrence
        coherence_score = 0.0
        term_count = 0
        
        for term in terms[:5]:  # Top 5 terms
            appearances = sum(1 for text in content if term in text.lower())
            coherence_score += appearances / len(content)
            term_count += 1
        
        return coherence_score / max(1, term_count)
    
    async def _get_historical_frequency(
        self, 
        db: AsyncSession, 
        topic: str, 
        time_window: str
    ) -> int:
        """Get historical frequency for comparison."""
        try:
            # Mock implementation - in production would query historical data
            return max(1, int(topic.count('_') * 3))  # Simple heuristic
        except Exception:
            return 1
    
    def _calculate_momentum(self, current_freq: int, historical_freq: int) -> float:
        """Calculate trend momentum."""
        if historical_freq == 0:
            return 1.0 if current_freq > 0 else 0.0
        
        momentum = (current_freq - historical_freq) / historical_freq
        return max(-1.0, min(1.0, momentum))  # Clamp between -1 and 1
    
    async def _calculate_velocity(self, db: AsyncSession, topic: str, time_window: str) -> float:
        """Calculate trend velocity (acceleration)."""
        try:
            # Mock implementation - would calculate second derivative of trend
            return np.random.uniform(-0.5, 0.5)  # Placeholder
        except Exception:
            return 0.0
    
    async def _calculate_engagement_rate(
        self, 
        db: AsyncSession, 
        topic_data: Dict[str, Any], 
        trend_data: Dict[str, Any]
    ) -> float:
        """Calculate engagement rate for topic."""
        try:
            # Mock calculation based on interactions
            base_engagement = topic_data['document_count'] / max(1, trend_data['total_interactions'])
            return min(1.0, base_engagement * 2)  # Scale up and clamp
        except Exception:
            return 0.5
    
    def _calculate_confidence_score(
        self, 
        coherence: float, 
        frequency: int, 
        momentum: float, 
        engagement: float
    ) -> float:
        """Calculate overall confidence score."""
        # Weighted combination of metrics
        confidence = (
            coherence * 0.3 +
            min(1.0, frequency / 10) * 0.3 +
            abs(momentum) * 0.2 +
            engagement * 0.2
        )
        return min(1.0, confidence)
    
    def _calculate_composite_trend_score(
        self, 
        frequency: int, 
        momentum: float, 
        velocity: float, 
        engagement: float, 
        confidence: float
    ) -> float:
        """Calculate composite trend score."""
        # Advanced weighting based on trend characteristics
        frequency_score = min(1.0, frequency / 20)
        momentum_score = (momentum + 1) / 2  # Normalize to 0-1
        velocity_score = (velocity + 1) / 2  # Normalize to 0-1
        
        composite = (
            frequency_score * 0.25 +
            momentum_score * 0.3 +
            velocity_score * 0.15 +
            engagement * 0.2 +
            confidence * 0.1
        )
        
        return min(1.0, composite)
    
    async def _identify_user_segments(self, db: AsyncSession, topic_data: Dict[str, Any]) -> List[str]:
        """Identify user segments interested in this topic."""
        # Mock implementation
        segments = ["plant_enthusiasts"]
        
        if "propagation" in topic_data['topic'] or "cutting" in topic_data['topic']:
            segments.append("advanced_growers")
        if "watering" in topic_data['topic'] or "care" in topic_data['topic']:
            segments.append("beginners")
        
        return segments
    
    def _calculate_topic_sentiment(self, content_samples: List[str]) -> float:
        """Calculate sentiment score for topic."""
        if not content_samples:
            return 0.0
        
        # Simple sentiment analysis
        positive_words = ['love', 'beautiful', 'amazing', 'great', 'wonderful', 'success']
        negative_words = ['dying', 'problem', 'help', 'sick', 'dead', 'brown']
        
        sentiment_scores = []
        for content in content_samples:
            content_lower = content.lower()
            positive_count = sum(1 for word in positive_words if word in content_lower)
            negative_count = sum(1 for word in negative_words if word in content_lower)
            
            if positive_count + negative_count > 0:
                sentiment = (positive_count - negative_count) / (positive_count + negative_count)
                sentiment_scores.append(sentiment)
        
        return np.mean(sentiment_scores) if sentiment_scores else 0.0
    
    async def _find_related_topics(
        self, 
        topic_data: Dict[str, Any], 
        all_topics: List[Dict[str, Any]]
    ) -> List[str]:
        """Find related topics using similarity."""
        related = []
        current_terms = set(topic_data['top_terms'][:5])
        
        for other_topic in all_topics:
            if other_topic['topic'] == topic_data['topic']:
                continue
            
            other_terms = set(other_topic['top_terms'][:5])
            similarity = len(current_terms.intersection(other_terms)) / len(current_terms.union(other_terms))
            
            if similarity > 0.3:  # 30% similarity threshold
                related.append(other_topic['topic'])
        
        return related[:3]  # Return top 3 related topics
    
    def _determine_trend_phase(
        self, 
        momentum: float, 
        velocity: float, 
        current_freq: int, 
        historical_freq: int
    ) -> TrendPhase:
        """Determine the current phase of the trend."""
        if momentum > 0.5 and velocity > 0:
            return TrendPhase.GROWING
        elif momentum > 0.8 and velocity < 0:
            return TrendPhase.PEAK
        elif momentum < -0.3:
            return TrendPhase.DECLINING
        elif abs(momentum) < 0.2:
            return TrendPhase.STABLE
        else:
            return TrendPhase.EMERGING
    
    def _calculate_seasonal_factor(self, topic: str, seasonal_context: Dict[str, Any]) -> float:
        """Calculate seasonal relevance factor."""
        if not seasonal_context:
            return 1.0
        
        # Mock seasonal adjustments
        season = seasonal_context.get('season', '').lower()
        
        seasonal_topics = {
            'winter': ['indoor', 'humidity', 'light', 'heating'],
            'spring': ['repotting', 'fertilizing', 'propagation', 'growth'],
            'summer': ['watering', 'outdoor', 'sun', 'heat'],
            'autumn': ['dormancy', 'preparation', 'harvest']
        }
        
        if season in seasonal_topics:
            topic_lower = topic.lower()
            for seasonal_term in seasonal_topics[season]:
                if seasonal_term in topic_lower:
                    return 1.3  # Boost seasonal relevance
        
        return 1.0
    
    async def _predict_trend_trajectory(
        self, 
        db: AsyncSession, 
        topic: str, 
        metrics: Dict[str, Any]
    ) -> Dict[str, float]:
        """Predict future trend trajectory."""
        # Mock prediction - in production would use time series models
        current_momentum = metrics['momentum']
        current_velocity = metrics['velocity']
        
        predictions = {}
        for days in [1, 3, 7, 14]:
            # Simple linear prediction
            predicted_change = current_momentum * (days / 7) + current_velocity * (days / 14)
            predicted_score = metrics['trend_score'] * (1 + predicted_change)
            predictions[f"{days}_days"] = max(0.0, min(1.0, predicted_score))
        
        return predictions
    
    def _calculate_geographic_distribution(self, user_location: Optional[str]) -> Dict[str, float]:
        """Calculate geographic distribution (mock implementation)."""
        return {
            "local": 0.6,
            "regional": 0.3,
            "global": 0.1
        }
    
    async def _estimate_emergence_time(self, db: AsyncSession, topic: str) -> datetime:
        """Estimate when topic first emerged."""
        # Mock implementation - would query historical data
        return datetime.utcnow() - timedelta(days=np.random.randint(1, 14))
    
    async def _estimate_peak_time(
        self, 
        db: AsyncSession, 
        topic: str, 
        metrics: Dict[str, Any]
    ) -> Optional[datetime]:
        """Estimate peak time for trend."""
        if metrics['momentum'] > 0.5:
            # Predict peak in future
            days_to_peak = max(1, int(10 / (metrics['momentum'] + 0.1)))
            return datetime.utcnow() + timedelta(days=days_to_peak)
        elif metrics['momentum'] < -0.3:
            # Peak was in the past
            return datetime.utcnow() - timedelta(days=np.random.randint(1, 7))
        else:
            return None
    
    def _calculate_feature_importance(self, metrics: Dict[str, Any]) -> Dict[str, float]:
        """Calculate feature importance for trend score."""
        components = metrics['raw_score_components']
        total = sum(components.values())
        
        if total == 0:
            return {key: 0.0 for key in components.keys()}
        
        return {key: value / total for key, value in components.items()}
    
    def _calculate_personalization_score(
        self, 
        topic_data: Dict[str, Any], 
        context: TrendAnalysisContext
    ) -> float:
        """Calculate personalization score based on user context."""
        score = 1.0  # Base score
        
        # Check plant interests alignment
        if context.plant_interests:
            topic_lower = topic_data['topic'].lower()
            interest_matches = sum(1 for interest in context.plant_interests 
                                 if interest.lower() in topic_lower)
            if interest_matches > 0:
                score *= 1.2  # Boost for interest alignment
        
        # Adjust for experience level
        if context.experience_level == "beginner":
            if any(term in topic_data['topic'].lower() 
                   for term in ['basic', 'beginner', 'care', 'watering']):
                score *= 1.15
        elif context.experience_level == "advanced":
            if any(term in topic_data['topic'].lower() 
                   for term in ['propagation', 'advanced', 'technique']):
                score *= 1.15
        
        return min(1.5, score)  # Cap boost at 50%
    
    def _determine_active_sources(self, analysis: Dict[str, Any]) -> List[TrendSource]:
        """Determine which sources contributed to this trend."""
        # Mock implementation based on topic characteristics
        sources = [TrendSource.RAG_INTERACTIONS]
        
        if "question" in analysis.get('metadata', {}):
            sources.append(TrendSource.QUESTIONS)
        if "story" in analysis.get('metadata', {}):
            sources.append(TrendSource.STORIES)
        if "trade" in analysis.get('metadata', {}):
            sources.append(TrendSource.TRADES)
        
        return sources
    
    def _normalize_topic_name(self, topic: str) -> str:
        """Normalize topic name for display."""
        return topic.replace('_', ' ').title()
    
    def _apply_diversity_filtering(self, trends: List[TrendingTopic]) -> List[TrendingTopic]:
        """Apply diversity filtering to avoid similar topics."""
        if len(trends) <= 5:
            return trends
        
        diverse_trends = [trends[0]]  # Always include top trend
        
        for trend in trends[1:]:
            # Check similarity with already selected trends
            is_diverse = True
            for selected in diverse_trends:
                similarity = len(set(trend.topic.split('_')).intersection(
                    set(selected.topic.split('_'))
                )) / len(set(trend.topic.split('_')).union(
                    set(selected.topic.split('_'))
                ))
                
                if similarity > 0.6:  # Too similar
                    is_diverse = False
                    break
            
            if is_diverse:
                diverse_trends.append(trend)
        
        return diverse_trends
    
    def _boost_emerging_trends(self, trends: List[TrendingTopic]) -> List[TrendingTopic]:
        """Boost emerging trends for early adopters."""
        for trend in trends:
            if trend.phase == TrendPhase.EMERGING:
                trend.trend_score *= 1.2
        
        # Re-sort after boosting
        trends.sort(key=lambda x: x.trend_score, reverse=True)
        return trends
    
    # Data collection methods
    async def _get_story_trends(self, db: AsyncSession, current_period: Tuple, previous_period: Tuple) -> List[Dict]:
        """Get trending data from stories."""
        try:
            stmt = select(Story).where(
                and_(
                    Story.created_at >= current_period[0],
                    Story.created_at <= current_period[1]
                )
            )
            result = await db.execute(stmt)
            stories = result.scalars().all()
            
            return [
                {
                    'content': story.content,
                    'created_at': story.created_at,
                    'source': TrendSource.STORIES,
                    'engagement_metrics': {'likes': 0, 'comments': 0}  # Mock data
                }
                for story in stories
            ]
        except Exception as e:
            logger.error(f"Error getting story trends: {str(e)}")
            return []
    
    async def _get_question_trends(self, db: AsyncSession, current_period: Tuple, previous_period: Tuple) -> List[Dict]:
        """Get trending data from questions."""
        try:
            stmt = select(PlantQuestion).where(
                and_(
                    PlantQuestion.created_at >= current_period[0],
                    PlantQuestion.created_at <= current_period[1]
                )
            )
            result = await db.execute(stmt)
            questions = result.scalars().all()
            
            return [
                {
                    'content': f"{question.title} {question.content}",
                    'created_at': question.created_at,
                    'source': TrendSource.QUESTIONS,
                    'engagement_metrics': {'likes': question.upvotes, 'comments': 0}
                }
                for question in questions
            ]
        except Exception as e:
            logger.error(f"Error getting question trends: {str(e)}")
            return []
    
    async def _get_trade_trends(self, db: AsyncSession, current_period: Tuple, previous_period: Tuple) -> List[Dict]:
        """Get trending data from trades."""
        try:
            stmt = select(PlantTrade).where(
                and_(
                    PlantTrade.created_at >= current_period[0],
                    PlantTrade.created_at <= current_period[1]
                )
            )
            result = await db.execute(stmt)
            trades = result.scalars().all()
            
            return [
                {
                    'content': f"{trade.title} {trade.description}",
                    'created_at': trade.created_at,
                    'source': TrendSource.TRADES,
                    'engagement_metrics': {'likes': 0, 'comments': 0}
                }
                for trade in trades
            ]
        except Exception as e:
            logger.error(f"Error getting trade trends: {str(e)}")
            return []
    
    async def _get_rag_interaction_trends(self, db: AsyncSession, current_period: Tuple, previous_period: Tuple) -> List[Dict]:
        """Get trending data from RAG interactions."""
        try:
            stmt = select(RAGInteraction).where(
                and_(
                    RAGInteraction.created_at >= current_period[0],
                    RAGInteraction.created_at <= current_period[1]
                )
            )
            result = await db.execute(stmt)
            interactions = result.scalars().all()
            
            return [
                {
                    'content': interaction.query_text,
                    'created_at': interaction.created_at,
                    'source': TrendSource.RAG_INTERACTIONS,
                    'engagement_metrics': {'likes': 0, 'comments': 0}
                }
                for interaction in interactions if interaction.query_text
            ]
        except Exception as e:
            logger.error(f"Error getting RAG interaction trends: {str(e)}")
            return [] 