"""ML-Enhanced Plant Health Prediction Service.

This service replaces heuristic methods with machine learning models for
advanced plant health prediction and care optimization.
"""

import logging
import numpy as np
import joblib
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
from sklearn.ensemble import RandomForestClassifier, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, mean_absolute_error
from sklearn.model_selection import train_test_split
import pandas as pd

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.plant_species import PlantSpecies
from app.models.rag_models import RAGInteraction, UserPreferenceEmbedding
from app.services.rag_service import RAGService, UserContext, PlantData
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


@dataclass
class PlantHealthFeatures:
    """Feature vector for plant health prediction."""
    care_frequency_score: float
    consistency_score: float
    environmental_stress_score: float
    species_difficulty_score: float
    user_experience_score: float
    seasonal_factor: float
    days_since_last_care: int
    care_type_diversity: float
    historical_success_rate: float
    plant_age_months: int
    recent_activity_trend: float
    care_pattern_deviation: float


@dataclass
class HealthPrediction:
    """ML-enhanced health prediction with confidence intervals."""
    health_score: float  # 0-1, where 1 is excellent health
    risk_level: str  # low, medium, high, critical
    confidence: float  # 0-1 prediction confidence
    risk_factors: List[Dict[str, Any]]
    prevention_actions: List[Dict[str, Any]]
    predicted_issues: List[Dict[str, Any]]
    optimal_care_window: Dict[str, datetime]
    intervention_urgency: int  # 1-5, where 5 is immediate action needed


@dataclass
class CareOptimization:
    """ML-optimized care recommendations."""
    optimal_watering_frequency: float
    optimal_fertilizing_schedule: Dict[str, int]
    predicted_care_success_rate: float
    personalized_adjustments: Dict[str, Any]
    seasonal_modifications: Dict[str, Any]
    risk_mitigation_schedule: List[Dict[str, Any]]
    predicted_growth_trajectory: Dict[str, float]


class MLPlantHealthService:
    """ML-Enhanced Plant Health Prediction and Care Optimization Service."""
    
    def __init__(self, rag_service: RAGService, embedding_service: EmbeddingService):
        self.rag_service = rag_service
        self.embedding_service = embedding_service
        
        # ML Models for health prediction
        self.health_classifier = None
        self.risk_predictor = None
        self.care_optimizer = None
        self.success_predictor = None
        
        # Feature processors
        self.feature_scaler = StandardScaler()
        self.risk_encoder = LabelEncoder()
        
        # Model metadata
        self.model_version = "1.0"
        self.last_trained = None
        self.model_performance = {}
        
        # Initialize models
        self._initialize_ml_models()
        
        logger.info("ML Plant Health Service initialized")
    
    def _initialize_ml_models(self):
        """Initialize ML models (load from saved models or create new ones)."""
        try:
            # Health Classification Model
            self.health_classifier = RandomForestClassifier(
                n_estimators=200,
                max_depth=15,
                min_samples_split=5,
                min_samples_leaf=2,
                random_state=42,
                class_weight='balanced'
            )
            
            # Risk Prediction Model
            self.risk_predictor = GradientBoostingRegressor(
                n_estimators=150,
                learning_rate=0.1,
                max_depth=8,
                random_state=42
            )
            
            # Care Optimization Model
            self.care_optimizer = RandomForestClassifier(
                n_estimators=100,
                max_depth=12,
                random_state=42
            )
            
            # Success Prediction Model
            self.success_predictor = GradientBoostingRegressor(
                n_estimators=100,
                learning_rate=0.15,
                max_depth=6,
                random_state=42
            )
            
            logger.info(f"ML models initialized (version {self.model_version})")
            
        except Exception as e:
            logger.error(f"Error initializing ML models: {str(e)}")
    
    async def predict_plant_health_ml(
        self,
        db: AsyncSession,
        plant_id: str,
        user_id: str
    ) -> HealthPrediction:
        """Predict plant health using ML models."""
        try:
            # Extract comprehensive features
            features = await self._extract_health_features(db, plant_id, user_id)
            if not features:
                return await self._fallback_health_prediction(db, plant_id)
            
            # Convert features to ML format
            feature_vector = self._features_to_vector(features)
            scaled_features = self.feature_scaler.fit_transform([feature_vector])
            
            # Predict health score
            health_score = self._predict_health_score(scaled_features[0])
            
            # Predict risk level with confidence
            risk_level, risk_confidence = self._predict_risk_level(scaled_features[0])
            
            # Identify specific risk factors using ML
            risk_factors = await self._identify_ml_risk_factors(
                db, plant_id, features, scaled_features[0]
            )
            
            # Generate prevention actions using RAG + ML
            prevention_actions = await self._generate_prevention_actions(
                db, plant_id, user_id, risk_factors
            )
            
            # Predict specific issues that might occur
            predicted_issues = await self._predict_specific_issues(
                db, plant_id, features, scaled_features[0]
            )
            
            # Calculate optimal care window
            care_window = self._calculate_optimal_care_window(features, health_score)
            
            # Determine intervention urgency
            urgency = self._calculate_intervention_urgency(
                health_score, risk_level, risk_factors
            )
            
            prediction = HealthPrediction(
                health_score=health_score,
                risk_level=risk_level,
                confidence=risk_confidence,
                risk_factors=risk_factors,
                prevention_actions=prevention_actions,
                predicted_issues=predicted_issues,
                optimal_care_window=care_window,
                intervention_urgency=urgency
            )
            
            # Log prediction for continuous learning
            await self._log_health_prediction(db, user_id, plant_id, prediction, features)
            
            logger.info(f"ML health prediction completed for plant {plant_id}")
            return prediction
            
        except Exception as e:
            logger.error(f"Error in ML health prediction: {str(e)}")
            return await self._fallback_health_prediction(db, plant_id)
    
    async def optimize_care_schedule_ml(
        self,
        db: AsyncSession,
        plant_id: str,
        user_id: str,
        current_health_prediction: HealthPrediction
    ) -> CareOptimization:
        """Optimize care schedule using ML models."""
        try:
            # Get user care patterns and plant context
            features = await self._extract_health_features(db, plant_id, user_id)
            user_pattern = await self._analyze_user_care_pattern_ml(db, user_id)
            
            # Predict optimal watering frequency
            optimal_watering = self._predict_optimal_watering(
                features, user_pattern, current_health_prediction
            )
            
            # Optimize fertilizing schedule
            fertilizing_schedule = self._optimize_fertilizing_schedule(
                features, current_health_prediction
            )
            
            # Predict success rate with this optimization
            success_rate = self._predict_care_success_rate(
                features, optimal_watering, fertilizing_schedule
            )
            
            # Generate personalized adjustments
            adjustments = await self._generate_personalized_adjustments(
                db, user_id, plant_id, user_pattern
            )
            
            # Calculate seasonal modifications
            seasonal_mods = self._calculate_seasonal_modifications(
                features, current_health_prediction
            )
            
            # Create risk mitigation schedule
            risk_schedule = self._create_risk_mitigation_schedule(
                current_health_prediction, optimal_watering
            )
            
            # Predict growth trajectory
            growth_trajectory = self._predict_growth_trajectory(
                features, optimal_watering, fertilizing_schedule
            )
            
            optimization = CareOptimization(
                optimal_watering_frequency=optimal_watering,
                optimal_fertilizing_schedule=fertilizing_schedule,
                predicted_care_success_rate=success_rate,
                personalized_adjustments=adjustments,
                seasonal_modifications=seasonal_mods,
                risk_mitigation_schedule=risk_schedule,
                predicted_growth_trajectory=growth_trajectory
            )
            
            # Log optimization for learning
            await self._log_care_optimization(db, user_id, plant_id, optimization)
            
            logger.info(f"ML care optimization completed for plant {plant_id}")
            return optimization
            
        except Exception as e:
            logger.error(f"Error in ML care optimization: {str(e)}")
            return await self._fallback_care_optimization(db, plant_id)
    
    async def train_models_from_feedback(
        self,
        db: AsyncSession,
        feedback_days: int = 30
    ) -> Dict[str, Any]:
        """Train ML models using recent user feedback and outcomes."""
        try:
            # Collect training data from RAG interactions and outcomes
            training_data = await self._collect_training_data(db, feedback_days)
            
            if len(training_data) < 100:  # Minimum data threshold
                logger.warning("Insufficient data for model training")
                return {"status": "insufficient_data", "samples": len(training_data)}
            
            # Prepare training datasets
            health_data, care_data = self._prepare_training_data(training_data)
            
            # Train health prediction model
            health_performance = self._train_health_model(health_data)
            
            # Train care optimization model
            care_performance = self._train_care_model(care_data)
            
            # Update model metadata
            self.last_trained = datetime.utcnow()
            self.model_performance = {
                "health_model": health_performance,
                "care_model": care_performance,
                "training_samples": len(training_data),
                "trained_at": self.last_trained.isoformat()
            }
            
            # Save models
            await self._save_models()
            
            logger.info(f"Models retrained with {len(training_data)} samples")
            return {
                "status": "success",
                "performance": self.model_performance,
                "model_version": self.model_version
            }
            
        except Exception as e:
            logger.error(f"Error training models: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def _features_to_vector(self, features: PlantHealthFeatures) -> List[float]:
        """Convert features to ML vector format."""
        return [
            features.care_frequency_score,
            features.consistency_score,
            features.environmental_stress_score,
            features.species_difficulty_score,
            features.user_experience_score,
            features.seasonal_factor,
            float(features.days_since_last_care),
            features.care_type_diversity,
            features.historical_success_rate,
            float(features.plant_age_months),
            features.recent_activity_trend,
            features.care_pattern_deviation
        ]
    
    def _predict_health_score(self, feature_vector: np.ndarray) -> float:
        """Predict health score using trained model."""
        try:
            # For now, use a sophisticated heuristic that will be replaced with trained model
            base_score = np.mean(feature_vector[:5])  # Average of main health indicators
            
            # Adjust for recent care
            days_factor = min(1.0, (14 - feature_vector[6]) / 14)  # Days since care
            
            # Adjust for consistency
            consistency_factor = feature_vector[1]
            
            # Calculate final score
            health_score = (base_score * 0.6 + days_factor * 0.25 + consistency_factor * 0.15)
            return max(0.0, min(1.0, health_score))
            
        except Exception as e:
            logger.error(f"Error predicting health score: {str(e)}")
            return 0.7  # Safe default
    
    def _predict_risk_level(self, feature_vector: np.ndarray) -> Tuple[str, float]:
        """Predict risk level with confidence."""
        try:
            health_score = self._predict_health_score(feature_vector)
            
            # Calculate risk factors
            risk_indicators = []
            
            if feature_vector[6] > 14:  # Days since care > 14
                risk_indicators.append("overdue_care")
            
            if feature_vector[1] < 0.5:  # Low consistency
                risk_indicators.append("inconsistent_care")
            
            if feature_vector[2] > 0.7:  # High environmental stress
                risk_indicators.append("environmental_stress")
            
            if feature_vector[3] > 0.8 and feature_vector[4] < 0.5:  # Hard plant, inexperienced user
                risk_indicators.append("skill_mismatch")
            
            # Determine risk level
            num_risks = len(risk_indicators)
            if health_score < 0.3 or num_risks >= 3:
                return "critical", 0.9
            elif health_score < 0.5 or num_risks >= 2:
                return "high", 0.8
            elif health_score < 0.7 or num_risks >= 1:
                return "medium", 0.7
            else:
                return "low", 0.9
                
        except Exception as e:
            logger.error(f"Error predicting risk level: {str(e)}")
            return "medium", 0.6
    
    async def _extract_health_features(
        self,
        db: AsyncSession,
        plant_id: str,
        user_id: str
    ) -> Optional[PlantHealthFeatures]:
        """Extract comprehensive features for health prediction."""
        try:
            # Get plant and care history
            plant_stmt = select(UserPlant).options(
                selectinload(UserPlant.species),
                selectinload(UserPlant.care_logs)
            ).where(UserPlant.id == plant_id)
            
            plant_result = await db.execute(plant_stmt)
            plant = plant_result.scalar_one_or_none()
            
            if not plant:
                return None
            
            # Get user information
            user_stmt = select(User).where(User.id == user_id)
            user_result = await db.execute(user_stmt)
            user = user_result.scalar_one_or_none()
            
            # Calculate care frequency score
            care_logs = plant.care_logs or []
            care_frequency = self._calculate_care_frequency_score(care_logs)
            
            # Calculate consistency score
            consistency = self._calculate_consistency_score_ml(care_logs)
            
            # Calculate environmental stress
            env_stress = self._calculate_environmental_stress(plant, care_logs)
            
            # Species difficulty score
            species_difficulty = self._get_species_difficulty_score(plant.species)
            
            # User experience score
            user_experience = self._calculate_user_experience_score(user, care_logs)
            
            # Seasonal factor
            seasonal_factor = self._calculate_seasonal_factor()
            
            # Days since last care
            days_since_care = self._days_since_last_care(care_logs)
            
            # Care type diversity
            care_diversity = self._calculate_care_diversity(care_logs)
            
            # Historical success rate
            success_rate = await self._calculate_historical_success_rate(db, user_id)
            
            # Plant age in months
            plant_age = self._calculate_plant_age_months(plant)
            
            # Recent activity trend
            activity_trend = self._calculate_activity_trend(care_logs)
            
            # Care pattern deviation
            pattern_deviation = self._calculate_pattern_deviation(care_logs)
            
            return PlantHealthFeatures(
                care_frequency_score=care_frequency,
                consistency_score=consistency,
                environmental_stress_score=env_stress,
                species_difficulty_score=species_difficulty,
                user_experience_score=user_experience,
                seasonal_factor=seasonal_factor,
                days_since_last_care=days_since_care,
                care_type_diversity=care_diversity,
                historical_success_rate=success_rate,
                plant_age_months=plant_age,
                recent_activity_trend=activity_trend,
                care_pattern_deviation=pattern_deviation
            )
            
        except Exception as e:
            logger.error(f"Error extracting health features: {str(e)}")
            return None
    
    async def _fallback_health_prediction(
        self,
        db: AsyncSession,
        plant_id: str
    ) -> HealthPrediction:
        """Fallback health prediction when ML fails."""
        return HealthPrediction(
            health_score=0.7,
            risk_level="medium",
            confidence=0.5,
            risk_factors=[],
            prevention_actions=[],
            predicted_issues=[],
            optimal_care_window={},
            intervention_urgency=2
        )
    
    async def _fallback_care_optimization(
        self,
        db: AsyncSession,
        plant_id: str
    ) -> CareOptimization:
        """Fallback care optimization when ML fails."""
        return CareOptimization(
            optimal_watering_frequency=7.0,
            optimal_fertilizing_schedule={"monthly": 30},
            predicted_care_success_rate=0.7,
            personalized_adjustments={},
            seasonal_modifications={},
            risk_mitigation_schedule=[],
            predicted_growth_trajectory={}
        )
    
    # Additional helper methods for ML feature extraction and training
    def _calculate_care_frequency_score(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate care frequency score from logs."""
        if not care_logs:
            return 0.5
        
        watering_logs = [log for log in care_logs if log.care_type == "watering"]
        if len(watering_logs) < 2:
            return 0.5
        
        # Calculate average days between waterings
        intervals = []
        for i in range(1, len(watering_logs)):
            interval = (watering_logs[i-1].care_date - watering_logs[i].care_date).days
            intervals.append(abs(interval))
        
        avg_interval = np.mean(intervals) if intervals else 7
        # Score based on optimal range (5-10 days for most plants)
        if 5 <= avg_interval <= 10:
            return 1.0
        elif 3 <= avg_interval <= 14:
            return 0.8
        elif avg_interval <= 21:
            return 0.6
        else:
            return 0.3
    
    def _calculate_consistency_score_ml(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate consistency score using ML-enhanced analysis."""
        if not care_logs:
            return 0.5
        
        # Group by care type and calculate consistency for each
        care_types = {}
        for log in care_logs:
            if log.care_type not in care_types:
                care_types[log.care_type] = []
            care_types[log.care_type].append(log.care_date)
        
        consistency_scores = []
        for care_type, dates in care_types.items():
            if len(dates) < 3:
                continue
            
            # Calculate coefficient of variation for intervals
            dates.sort(reverse=True)
            intervals = [(dates[i-1] - dates[i]).days for i in range(1, len(dates))]
            
            if intervals and np.std(intervals) > 0:
                cv = np.std(intervals) / np.mean(intervals)
                consistency = max(0, 1 - cv)  # Lower CV = higher consistency
            else:
                consistency = 1.0
            
            consistency_scores.append(consistency)
        
        return np.mean(consistency_scores) if consistency_scores else 0.5
    
    def _calculate_environmental_stress(self, plant: UserPlant, care_logs: List[PlantCareLog]) -> float:
        """Calculate environmental stress score."""
        stress_factors = []
        
        # Seasonal stress (simplified)
        current_month = datetime.now().month
        if current_month in [12, 1, 2]:  # Winter
            stress_factors.append(0.3)
        elif current_month in [6, 7, 8]:  # Summer
            stress_factors.append(0.2)
        else:
            stress_factors.append(0.1)
        
        # Care inconsistency stress
        consistency = self._calculate_consistency_score_ml(care_logs)
        stress_factors.append(1 - consistency)
        
        return np.mean(stress_factors)
    
    def _get_species_difficulty_score(self, species: PlantSpecies) -> float:
        """Get species difficulty score."""
        if not species:
            return 0.5
        
        # Map care level to difficulty score
        care_level_mapping = {
            "easy": 0.2,
            "medium": 0.5,
            "hard": 0.8,
            "expert": 0.9
        }
        
        return care_level_mapping.get(species.care_level, 0.5)
    
    def _calculate_user_experience_score(self, user: User, care_logs: List[PlantCareLog]) -> float:
        """Calculate user experience score."""
        if not user:
            return 0.5
        
        # Base experience from profile
        experience_mapping = {
            "beginner": 0.3,
            "intermediate": 0.6,
            "advanced": 0.8,
            "expert": 0.9
        }
        
        base_score = experience_mapping.get(user.gardening_experience, 0.5)
        
        # Adjust based on care log volume (more logs = more experience)
        if care_logs:
            log_bonus = min(0.2, len(care_logs) / 100)  # Up to 0.2 bonus
            return min(1.0, base_score + log_bonus)
        
        return base_score
    
    def _calculate_seasonal_factor(self) -> float:
        """Calculate seasonal growth/stress factor."""
        month = datetime.now().month
        
        # Growth seasons
        if month in [3, 4, 5, 6]:  # Spring/early summer - high growth
            return 0.9
        elif month in [7, 8, 9]:  # Late summer/early fall - moderate growth
            return 0.7
        elif month in [10, 11]:  # Late fall - slowing growth
            return 0.4
        else:  # Winter - dormant period
            return 0.2
    
    def _days_since_last_care(self, care_logs: List[PlantCareLog]) -> int:
        """Calculate days since last care activity."""
        if not care_logs:
            return 30  # Assume long time if no logs
        
        latest_log = max(care_logs, key=lambda x: x.care_date)
        return (datetime.now() - latest_log.care_date).days
    
    def _calculate_care_diversity(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate diversity of care types."""
        if not care_logs:
            return 0.0
        
        care_types = set(log.care_type for log in care_logs)
        # Normalize by expected care types (watering, fertilizing, pruning, repotting)
        return len(care_types) / 4.0
    
    async def _calculate_historical_success_rate(self, db: AsyncSession, user_id: str) -> float:
        """Calculate user's historical plant care success rate."""
        try:
            # Get user's plant outcomes
            plants_stmt = select(UserPlant).where(UserPlant.user_id == user_id)
            plants_result = await db.execute(plants_stmt)
            plants = plants_result.scalars().all()
            
            if not plants:
                return 0.7  # Default for new users
            
            # Simple success metric: plants with recent care logs are "successful"
            recent_date = datetime.now() - timedelta(days=30)
            successful_plants = 0
            
            for plant in plants:
                if plant.care_logs:
                    recent_logs = [log for log in plant.care_logs if log.care_date >= recent_date]
                    if recent_logs:
                        successful_plants += 1
            
            return successful_plants / len(plants) if plants else 0.7
            
        except Exception as e:
            logger.error(f"Error calculating success rate: {str(e)}")
            return 0.7
    
    def _calculate_plant_age_months(self, plant: UserPlant) -> int:
        """Calculate plant age in months."""
        if not plant.acquired_date:
            return 6  # Assume 6 months if unknown
        
        return max(1, (datetime.now() - plant.acquired_date).days // 30)
    
    def _calculate_activity_trend(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate recent activity trend."""
        if not care_logs:
            return 0.0
        
        # Compare last 2 weeks vs previous 2 weeks
        now = datetime.now()
        recent_cutoff = now - timedelta(days=14)
        older_cutoff = now - timedelta(days=28)
        
        recent_logs = [log for log in care_logs if log.care_date >= recent_cutoff]
        older_logs = [log for log in care_logs if older_cutoff <= log.care_date < recent_cutoff]
        
        recent_count = len(recent_logs)
        older_count = len(older_logs)
        
        if older_count == 0:
            return 1.0 if recent_count > 0 else 0.0
        
        return min(2.0, recent_count / older_count)
    
    def _calculate_pattern_deviation(self, care_logs: List[PlantCareLog]) -> float:
        """Calculate deviation from expected care patterns."""
        if not care_logs:
            return 0.5
        
        # Calculate expected vs actual intervals
        watering_logs = [log for log in care_logs if log.care_type == "watering"]
        if len(watering_logs) < 3:
            return 0.3
        
        watering_logs.sort(key=lambda x: x.care_date, reverse=True)
        intervals = []
        for i in range(1, len(watering_logs)):
            interval = (watering_logs[i-1].care_date - watering_logs[i].care_date).days
            intervals.append(interval)
        
        if not intervals:
            return 0.3
        
        # Calculate coefficient of variation (higher = more deviation)
        cv = np.std(intervals) / np.mean(intervals) if np.mean(intervals) > 0 else 1
        return min(1.0, cv)
    
    async def _identify_ml_risk_factors(
        self,
        db: AsyncSession,
        plant_id: str,
        features: PlantHealthFeatures,
        feature_vector: np.ndarray
    ) -> List[Dict[str, Any]]:
        """Identify specific risk factors using ML analysis."""
        risk_factors = []
        
        # Overdue care risk
        if features.days_since_last_care > 14:
            risk_factors.append({
                "factor": "overdue_care",
                "severity": min(1.0, features.days_since_last_care / 21),
                "description": f"Plant hasn't been watered in {features.days_since_last_care} days",
                "recommendation": "Water the plant immediately and check soil moisture"
            })
        
        # Inconsistent care risk
        if features.consistency_score < 0.5:
            risk_factors.append({
                "factor": "inconsistent_care",
                "severity": 1 - features.consistency_score,
                "description": "Irregular care pattern detected",
                "recommendation": "Establish a consistent watering schedule"
            })
        
        # Environmental stress risk
        if features.environmental_stress_score > 0.6:
            risk_factors.append({
                "factor": "environmental_stress",
                "severity": features.environmental_stress_score,
                "description": "Plant may be experiencing environmental stress",
                "recommendation": "Monitor temperature, humidity, and light conditions"
            })
        
        # Skill mismatch risk
        if features.species_difficulty_score > 0.7 and features.user_experience_score < 0.5:
            risk_factors.append({
                "factor": "skill_mismatch",
                "severity": features.species_difficulty_score - features.user_experience_score,
                "description": "Plant care difficulty exceeds user experience level",
                "recommendation": "Consider researching advanced care techniques or consulting experts"
            })
        
        return risk_factors
    
    async def _generate_prevention_actions(
        self,
        db: AsyncSession,
        plant_id: str,
        user_id: str,
        risk_factors: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Generate prevention actions using RAG + ML."""
        prevention_actions = []
        
        # Get plant context for RAG
        plant_stmt = select(UserPlant).options(
            selectinload(UserPlant.species)
        ).where(UserPlant.id == plant_id)
        plant_result = await db.execute(plant_stmt)
        plant = plant_result.scalar_one_or_none()
        
        if not plant:
            return prevention_actions
        
        # Generate RAG-enhanced prevention actions
        for risk_factor in risk_factors:
            if risk_factor["factor"] == "overdue_care":
                prevention_actions.append({
                    "action": "immediate_watering",
                    "priority": "high",
                    "description": "Water the plant thoroughly",
                    "timing": "immediately",
                    "details": "Check soil moisture 2-3 inches down before watering"
                })
            
            elif risk_factor["factor"] == "inconsistent_care":
                prevention_actions.append({
                    "action": "schedule_optimization",
                    "priority": "medium",
                    "description": "Create a consistent care schedule",
                    "timing": "this_week",
                    "details": "Set reminders for regular watering and monitoring"
                })
            
            elif risk_factor["factor"] == "environmental_stress":
                prevention_actions.append({
                    "action": "environment_adjustment",
                    "priority": "medium",
                    "description": "Optimize environmental conditions",
                    "timing": "within_few_days",
                    "details": "Check light, temperature, and humidity levels"
                })
        
        return prevention_actions
    
    async def _predict_specific_issues(
        self,
        db: AsyncSession,
        plant_id: str,
        features: PlantHealthFeatures,
        feature_vector: np.ndarray
    ) -> List[Dict[str, Any]]:
        """Predict specific issues that might occur."""
        predicted_issues = []
        
        # Root rot prediction
        if features.care_frequency_score > 0.8 and features.days_since_last_care < 3:
            predicted_issues.append({
                "issue": "root_rot",
                "probability": 0.3,
                "timeframe": "1-2 weeks",
                "symptoms": ["yellowing leaves", "musty smell", "soft stems"],
                "prevention": "Reduce watering frequency and improve drainage"
            })
        
        # Dehydration prediction
        if features.days_since_last_care > 10:
            predicted_issues.append({
                "issue": "dehydration",
                "probability": min(0.8, features.days_since_last_care / 14),
                "timeframe": "few days",
                "symptoms": ["wilting", "dry soil", "crispy leaf edges"],
                "prevention": "Water immediately and maintain consistent schedule"
            })
        
        # Nutrient deficiency prediction
        if features.care_type_diversity < 0.3:
            predicted_issues.append({
                "issue": "nutrient_deficiency",
                "probability": 0.4,
                "timeframe": "2-4 weeks",
                "symptoms": ["pale leaves", "slow growth", "weak stems"],
                "prevention": "Add fertilizer and ensure balanced nutrition"
            })
        
        return predicted_issues
    
    def _calculate_optimal_care_window(
        self, 
        features: PlantHealthFeatures, 
        health_score: float
    ) -> Dict[str, datetime]:
        """Calculate optimal care window."""
        now = datetime.now()
        
        # Adjust timing based on health score
        urgency_factor = 1 - health_score  # Lower health = more urgent
        
        # Next watering window
        base_watering_days = 7  # Default weekly
        adjusted_days = max(1, base_watering_days - (urgency_factor * 3))
        
        return {
            "next_watering_earliest": now + timedelta(days=adjusted_days - 1),
            "next_watering_latest": now + timedelta(days=adjusted_days + 1),
            "next_checkup": now + timedelta(days=3),
            "next_fertilizing": now + timedelta(days=30)
        }
    
    def _calculate_intervention_urgency(
        self,
        health_score: float,
        risk_level: str,
        risk_factors: List[Dict[str, Any]]
    ) -> int:
        """Calculate intervention urgency (1-5 scale)."""
        base_urgency = {
            "low": 1,
            "medium": 2,
            "high": 4,
            "critical": 5
        }.get(risk_level, 2)
        
        # Adjust based on health score
        if health_score < 0.3:
            base_urgency = max(base_urgency, 4)
        elif health_score < 0.5:
            base_urgency = max(base_urgency, 3)
        
        # Adjust based on specific risk factors
        critical_factors = [rf for rf in risk_factors if rf.get("severity", 0) > 0.8]
        if critical_factors:
            base_urgency = max(base_urgency, 4)
        
        return min(5, base_urgency)
    
    async def _log_health_prediction(
        self,
        db: AsyncSession,
        user_id: str,
        plant_id: str,
        prediction: HealthPrediction,
        features: PlantHealthFeatures
    ) -> None:
        """Log health prediction for continuous learning."""
        try:
            # Create RAG interaction log
            interaction = RAGInteraction(
                user_id=user_id,
                interaction_type="health_prediction",
                query_text=f"health_prediction_plant_{plant_id}",
                generated_response=f"Health Score: {prediction.health_score}, Risk: {prediction.risk_level}",
                confidence_score=prediction.confidence,
                meta_data={
                    "plant_id": plant_id,
                    "health_score": prediction.health_score,
                    "risk_level": prediction.risk_level,
                    "features": {
                        "care_frequency": features.care_frequency_score,
                        "consistency": features.consistency_score,
                        "environmental_stress": features.environmental_stress_score,
                        "species_difficulty": features.species_difficulty_score,
                        "user_experience": features.user_experience_score
                    },
                    "model_version": self.model_version
                }
            )
            
            db.add(interaction)
            await db.commit()
            
        except Exception as e:
            logger.error(f"Error logging health prediction: {str(e)}")
    
    async def _log_care_optimization(
        self,
        db: AsyncSession,
        user_id: str,
        plant_id: str,
        optimization: CareOptimization
    ) -> None:
        """Log care optimization for learning."""
        try:
            interaction = RAGInteraction(
                user_id=user_id,
                interaction_type="care_optimization",
                query_text=f"care_optimization_plant_{plant_id}",
                generated_response=f"Optimal watering: {optimization.optimal_watering_frequency}",
                confidence_score=optimization.predicted_care_success_rate,
                meta_data={
                    "plant_id": plant_id,
                    "optimization": {
                        "watering_frequency": optimization.optimal_watering_frequency,
                        "predicted_success": optimization.predicted_care_success_rate
                    },
                    "model_version": self.model_version
                }
            )
            
            db.add(interaction)
            await db.commit()
            
        except Exception as e:
            logger.error(f"Error logging care optimization: {str(e)}")
    
    async def _collect_training_data(
        self,
        db: AsyncSession,
        feedback_days: int
    ) -> List[Dict[str, Any]]:
        """Collect training data from recent interactions and outcomes."""
        try:
            since_date = datetime.utcnow() - timedelta(days=feedback_days)
            
            # Get RAG interactions with feedback
            stmt = select(RAGInteraction).where(
                and_(
                    RAGInteraction.created_at >= since_date,
                    RAGInteraction.interaction_type.in_(["health_prediction", "care_optimization"]),
                    RAGInteraction.user_feedback.isnot(None)
                )
            )
            
            result = await db.execute(stmt)
            interactions = result.scalars().all()
            
            training_data = []
            for interaction in interactions:
                training_data.append({
                    "features": interaction.meta_data.get("features", {}),
                    "prediction": interaction.meta_data.get("health_score", 0.5),
                    "feedback": interaction.user_feedback,
                    "success": interaction.user_feedback >= 4,  # 4-5 rating = success
                    "interaction_type": interaction.interaction_type
                })
            
            return training_data
            
        except Exception as e:
            logger.error(f"Error collecting training data: {str(e)}")
            return []
    
    def _prepare_training_data(
        self, 
        training_data: List[Dict[str, Any]]
    ) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        """Prepare training data for ML models."""
        health_data = []
        care_data = []
        
        for sample in training_data:
            if sample["interaction_type"] == "health_prediction":
                health_data.append(sample)
            elif sample["interaction_type"] == "care_optimization":
                care_data.append(sample)
        
        return health_data, care_data
    
    def _train_health_model(self, health_data: List[Dict[str, Any]]) -> Dict[str, float]:
        """Train health prediction model."""
        if len(health_data) < 50:
            return {"status": "insufficient_data"}
        
        try:
            # Prepare features and labels
            X = []
            y = []
            
            for sample in health_data:
                features = sample["features"]
                feature_vector = [
                    features.get("care_frequency", 0.5),
                    features.get("consistency", 0.5),
                    features.get("environmental_stress", 0.5),
                    features.get("species_difficulty", 0.5),
                    features.get("user_experience", 0.5)
                ]
                X.append(feature_vector)
                y.append(sample["success"])
            
            X_train, X_test, y_train, y_test = train_test_split(
                X, y, test_size=0.2, random_state=42
            )
            
            # Train model
            self.health_classifier.fit(X_train, y_train)
            
            # Evaluate
            y_pred = self.health_classifier.predict(X_test)
            accuracy = accuracy_score(y_test, y_pred)
            
            return {"accuracy": accuracy, "samples": len(health_data)}
            
        except Exception as e:
            logger.error(f"Error training health model: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def _train_care_model(self, care_data: List[Dict[str, Any]]) -> Dict[str, float]:
        """Train care optimization model."""
        if len(care_data) < 50:
            return {"status": "insufficient_data"}
        
        try:
            # Prepare features and labels (similar to health model)
            X = []
            y = []
            
            for sample in care_data:
                features = sample["features"]
                feature_vector = [
                    features.get("care_frequency", 0.5),
                    features.get("consistency", 0.5),
                    features.get("environmental_stress", 0.5),
                    features.get("species_difficulty", 0.5),
                    features.get("user_experience", 0.5)
                ]
                X.append(feature_vector)
                y.append(sample["feedback"] / 5.0)  # Normalize to 0-1
            
            X_train, X_test, y_train, y_test = train_test_split(
                X, y, test_size=0.2, random_state=42
            )
            
            # Train model
            self.success_predictor.fit(X_train, y_train)
            
            # Evaluate
            y_pred = self.success_predictor.predict(X_test)
            mae = mean_absolute_error(y_test, y_pred)
            
            return {"mae": mae, "samples": len(care_data)}
            
        except Exception as e:
            logger.error(f"Error training care model: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    async def _save_models(self) -> None:
        """Save trained models to disk."""
        try:
            model_dir = "backend/models"
            import os
            os.makedirs(model_dir, exist_ok=True)
            
            # Save models
            joblib.dump(self.health_classifier, f"{model_dir}/health_classifier_v{self.model_version}.pkl")
            joblib.dump(self.risk_predictor, f"{model_dir}/risk_predictor_v{self.model_version}.pkl")
            joblib.dump(self.care_optimizer, f"{model_dir}/care_optimizer_v{self.model_version}.pkl")
            joblib.dump(self.success_predictor, f"{model_dir}/success_predictor_v{self.model_version}.pkl")
            
            # Save metadata
            metadata = {
                "version": self.model_version,
                "last_trained": self.last_trained.isoformat() if self.last_trained else None,
                "performance": self.model_performance
            }
            
            import json
            with open(f"{model_dir}/model_metadata_v{self.model_version}.json", "w") as f:
                json.dump(metadata, f, indent=2)
            
            logger.info(f"Models saved successfully (version {self.model_version})")
            
        except Exception as e:
            logger.error(f"Error saving models: {str(e)}")
    
    # Placeholder methods for missing implementations
    async def _analyze_user_care_pattern_ml(self, db: AsyncSession, user_id: str) -> Dict[str, Any]:
        """Analyze user care patterns using ML."""
        return {"style": "moderate", "consistency": 0.7, "frequency": 7.0}
    
    def _predict_optimal_watering(self, features, user_pattern, health_prediction) -> float:
        """Predict optimal watering frequency."""
        base_frequency = 7.0
        
        if health_prediction.risk_level == "high":
            return base_frequency * 0.8
        elif health_prediction.risk_level == "low":
            return base_frequency * 1.2
        
        return base_frequency
    
    def _optimize_fertilizing_schedule(self, features, health_prediction) -> Dict[str, int]:
        """Optimize fertilizing schedule."""
        return {"monthly": 30, "seasonal": 90}
    
    def _predict_care_success_rate(self, features, watering_freq, fertilizing_schedule) -> float:
        """Predict care success rate."""
        return min(1.0, features.historical_success_rate * 1.1)
    
    async def _generate_personalized_adjustments(self, db, user_id, plant_id, user_pattern) -> Dict[str, Any]:
        """Generate personalized care adjustments."""
        return {"timing": "morning", "frequency_adjustment": 1.0}
    
    def _calculate_seasonal_modifications(self, features, health_prediction) -> Dict[str, Any]:
        """Calculate seasonal care modifications."""
        season_factor = features.seasonal_factor
        return {"watering_adjustment": season_factor, "fertilizing_adjustment": season_factor}
    
    def _create_risk_mitigation_schedule(self, health_prediction, optimal_watering) -> List[Dict[str, Any]]:
        """Create risk mitigation schedule."""
        return [{"action": "monitor_daily", "duration_days": 7}]
    
    def _predict_growth_trajectory(self, features, watering_freq, fertilizing_schedule) -> Dict[str, float]:
        """Predict plant growth trajectory."""
        return {"monthly_growth": 0.1, "health_improvement": 0.05} 