"""Seasonal AI Service for plant behavior prediction and care recommendations.

This service implements ML-based seasonal prediction models for plant care optimization,
integrating with environmental data and plant species characteristics.
"""

import logging
import numpy as np
import pandas as pd
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass
from uuid import UUID
import joblib
import os
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler, LabelEncoder, PolynomialFeatures
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.metrics import mean_squared_error, accuracy_score, r2_score
from sklearn.cluster import KMeans
from sklearn.linear_model import Ridge, Lasso
from sklearn.neural_network import MLPRegressor
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.core.database import get_db
from app.models.user_plant import UserPlant
from app.models.plant_species import PlantSpecies
from app.models.seasonal_ai import SeasonalPrediction
from app.schemas.environmental_data import Location, WeatherCondition
from app.services.environmental_data_service import EnvironmentalDataService
from app.services.seasonal_pattern_service import SeasonalPatternService

logger = logging.getLogger(__name__)


@dataclass
class GrowthForecast:
    """Growth forecast data structure."""
    expected_growth_rate: float
    size_projections: List[Dict[str, Any]]
    flowering_predictions: List[Dict[str, Any]]
    dormancy_periods: List[Dict[str, Any]]
    stress_likelihood: float


@dataclass
class CareAdjustment:
    """Care adjustment recommendation."""
    care_type: str  # watering, fertilizing, light, humidity, temperature
    adjustment_type: str  # increase, decrease, maintain, schedule_change
    current_value: Optional[float]
    recommended_value: Optional[float]
    adjustment_percentage: float
    reason: str
    confidence: float
    effective_date: date
    duration_days: int


@dataclass
class RiskFactor:
    """Risk factor for plant health."""
    risk_type: str  # pest, disease, environmental_stress, dormancy
    risk_level: str  # low, medium, high, critical
    probability: float
    impact_severity: float
    onset_date: Optional[date]
    mitigation_actions: List[str]
    monitoring_frequency: str


@dataclass
class PlantActivity:
    """Optimal plant activity recommendation."""
    activity_type: str  # repotting, propagation, pruning, fertilizing
    optimal_date_range: Tuple[date, date]
    priority: str  # low, medium, high
    success_probability: float
    required_conditions: List[str]
    preparation_steps: List[str]


@dataclass
class SeasonalPredictionResult:
    """Complete seasonal prediction result."""
    plant_id: UUID
    prediction_period: Tuple[date, date]
    growth_forecast: GrowthForecast
    care_adjustments: List[CareAdjustment]
    risk_factors: List[RiskFactor]
    optimal_activities: List[PlantActivity]
    confidence_score: float
    model_version: str
    environmental_factors: Dict[str, Any]


class SeasonalAIService:
    """Service for seasonal AI predictions and plant care optimization."""
    
    def __init__(self):
        self.environmental_service = EnvironmentalDataService()
        self.pattern_service = SeasonalPatternService()
        
        # Model paths
        self.model_dir = "backend/models/seasonal_ai"
        self.growth_model_path = f"{self.model_dir}/growth_prediction_model.joblib"
        self.care_model_path = f"{self.model_dir}/care_adjustment_model.joblib"
        self.risk_model_path = f"{self.model_dir}/risk_assessment_model.joblib"
        self.scaler_path = f"{self.model_dir}/feature_scaler.joblib"
        self.species_model_path = f"{self.model_dir}/species_behavior_model.joblib"
        self.growth_phase_model_path = f"{self.model_dir}/growth_phase_model.joblib"
        self.poly_features_path = f"{self.model_dir}/polynomial_features.joblib"
        self.care_confidence_model_path = f"{self.model_dir}/care_confidence_model.joblib"
        
        # Model version
        self.model_version = "v2.0.0"
        
        # Initialize models
        self.growth_model = None
        self.care_model = None
        self.risk_model = None
        self.feature_scaler = None
        self.species_behavior_model = None
        self.growth_phase_model = None
        self.polynomial_features = None
        
        # Species-specific model cache
        self.species_models_cache = {}
        
        # Load or create models
        self._initialize_models()
    
    def _initialize_models(self):
        """Initialize or load ML models."""
        try:
            # Create model directory if it doesn't exist
            os.makedirs(self.model_dir, exist_ok=True)
            
            # Try to load existing models
            if (os.path.exists(self.growth_model_path) and 
                os.path.exists(self.care_model_path) and 
                os.path.exists(self.risk_model_path) and
                os.path.exists(self.scaler_path)):
                
                self.growth_model = joblib.load(self.growth_model_path)
                self.care_model = joblib.load(self.care_model_path)
                self.risk_model = joblib.load(self.risk_model_path)
                self.feature_scaler = joblib.load(self.scaler_path)
                
                # Load enhanced models if they exist
                if os.path.exists(self.species_model_path):
                    self.species_behavior_model = joblib.load(self.species_model_path)
                if os.path.exists(self.growth_phase_model_path):
                    self.growth_phase_model = joblib.load(self.growth_phase_model_path)
                if os.path.exists(self.poly_features_path):
                    self.polynomial_features = joblib.load(self.poly_features_path)
                
                logger.info("Loaded existing seasonal AI models")
            else:
                # Create and train new models
                self._create_and_train_enhanced_models()
                logger.info("Created and trained enhanced seasonal AI models")
                
        except Exception as e:
            logger.error(f"Failed to initialize models: {str(e)}")
            # Create basic models as fallback
            self._create_basic_models()
    
    def _create_and_train_enhanced_models(self):
        """Create and train enhanced ML models with species-specific behavior modeling."""
        logger.info("Creating and training enhanced seasonal AI models")
        
        # Generate comprehensive training data
        training_data = self._generate_enhanced_training_data()
        
        # Prepare base features
        base_features = ['temperature', 'humidity', 'daylight_hours', 'precipitation',
                        'plant_age_days', 'season_encoded', 'species_encoded']
        
        # Create polynomial features for non-linear relationships
        self.polynomial_features = PolynomialFeatures(degree=2, interaction_only=True, include_bias=False)
        base_feature_data = training_data[base_features]
        poly_features = self.polynomial_features.fit_transform(base_feature_data)
        
        # Scale features
        self.feature_scaler = StandardScaler()
        features_scaled = self.feature_scaler.fit_transform(poly_features)
        
        # Enhanced Growth Prediction Model with Gradient Boosting
        growth_targets = training_data['growth_rate']
        self.growth_model = GradientBoostingRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=6,
            random_state=42
        )
        self.growth_model.fit(features_scaled, growth_targets)
        
        # Enhanced Care Adjustment Model with Neural Network
        care_targets = training_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
        self.care_model = MLPRegressor(
            hidden_layer_sizes=(100, 50, 25),
            activation='relu',
            solver='adam',
            alpha=0.001,
            max_iter=1000,
            random_state=42
        )
        self.care_model.fit(features_scaled, care_targets)
        
        # Enhanced Risk Assessment Model with ensemble
        risk_targets = training_data['risk_score']
        self.risk_model = GradientBoostingRegressor(
            n_estimators=150,
            learning_rate=0.1,
            max_depth=5,
            random_state=42
        )
        self.risk_model.fit(features_scaled, risk_targets)
        
        # Species-specific behavior model
        self._create_species_behavior_model(training_data)
        
        # Growth phase prediction model
        self._create_growth_phase_model(training_data, features_scaled)
        
        # Care adjustment confidence model
        self._create_care_confidence_model(training_data, features_scaled)
        
        # Save all models
        self._save_enhanced_models()
        
        logger.info("Enhanced seasonal AI models created and trained successfully")

    def _create_and_train_models(self):
        """Create and train ML models with synthetic data."""
        # Generate synthetic training data
        training_data = self._generate_synthetic_training_data()
        
        # Prepare features and targets
        features = training_data[['temperature', 'humidity', 'daylight_hours', 'precipitation',
                                'plant_age_days', 'season_encoded', 'species_encoded']]
        
        # Initialize and train models
        self.feature_scaler = StandardScaler()
        features_scaled = self.feature_scaler.fit_transform(features)
        
        # Growth prediction model
        growth_targets = training_data['growth_rate']
        self.growth_model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.growth_model.fit(features_scaled, growth_targets)
        
        # Care adjustment model (multi-output)
        care_targets = training_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
        self.care_model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.care_model.fit(features_scaled, care_targets)
        
        # Risk assessment model
        risk_targets = training_data['risk_score']
        self.risk_model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.risk_model.fit(features_scaled, risk_targets)
        
        # Save models
        joblib.dump(self.growth_model, self.growth_model_path)
        joblib.dump(self.care_model, self.care_model_path)
        joblib.dump(self.risk_model, self.risk_model_path)
        joblib.dump(self.feature_scaler, self.scaler_path)
    
    def _create_basic_models(self):
        """Create basic fallback models."""
        self.growth_model = RandomForestRegressor(n_estimators=50, random_state=42)
        self.care_model = RandomForestRegressor(n_estimators=50, random_state=42)
        self.risk_model = RandomForestRegressor(n_estimators=50, random_state=42)
        self.feature_scaler = StandardScaler()
        
        # Train with minimal synthetic data
        basic_data = self._generate_basic_training_data()
        features = basic_data[['temperature', 'humidity', 'daylight_hours', 'precipitation',
                              'plant_age_days', 'season_encoded', 'species_encoded']]
        features_scaled = self.feature_scaler.fit_transform(features)
        
        self.growth_model.fit(features_scaled, basic_data['growth_rate'])
        self.care_model.fit(features_scaled, basic_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']])
        self.risk_model.fit(features_scaled, basic_data['risk_score'])
    
    def _generate_synthetic_training_data(self) -> pd.DataFrame:
        """Generate synthetic training data for model training."""
        np.random.seed(42)
        n_samples = 10000
        
        data = {
            'temperature': np.random.normal(20, 8, n_samples),
            'humidity': np.random.normal(60, 20, n_samples),
            'daylight_hours': np.random.uniform(8, 16, n_samples),
            'precipitation': np.random.exponential(2, n_samples),
            'plant_age_days': np.random.uniform(30, 1095, n_samples),  # 1 month to 3 years
            'season_encoded': np.random.randint(0, 4, n_samples),  # 0=spring, 1=summer, 2=autumn, 3=winter
            'species_encoded': np.random.randint(0, 50, n_samples),  # 50 different species
        }
        
        df = pd.DataFrame(data)
        
        # Generate target variables based on realistic relationships
        df['growth_rate'] = (
            0.5 + 
            0.3 * np.sin(df['season_encoded'] * np.pi / 2) +  # Seasonal growth
            0.2 * (df['temperature'] - 15) / 10 +  # Temperature effect
            0.1 * df['humidity'] / 100 +  # Humidity effect
            0.2 * df['daylight_hours'] / 16 +  # Light effect
            -0.1 * np.log(df['plant_age_days'] / 365 + 1) +  # Age effect
            np.random.normal(0, 0.1, n_samples)  # Noise
        )
        df['growth_rate'] = np.clip(df['growth_rate'], 0, 2)
        
        # Care adjustments
        df['water_adjustment'] = (
            0.5 * (25 - df['temperature']) / 10 +  # Cooler = more water
            0.3 * (50 - df['humidity']) / 50 +  # Drier = more water
            0.2 * np.sin(df['season_encoded'] * np.pi / 2) +  # Seasonal watering
            np.random.normal(0, 0.1, n_samples)
        )
        df['water_adjustment'] = np.clip(df['water_adjustment'], -0.5, 0.5)
        
        df['fertilizer_adjustment'] = (
            0.4 * np.sin(df['season_encoded'] * np.pi / 2) +  # Spring/summer fertilizing
            0.2 * df['growth_rate'] +  # More growth = more fertilizer
            np.random.normal(0, 0.1, n_samples)
        )
        df['fertilizer_adjustment'] = np.clip(df['fertilizer_adjustment'], -0.3, 0.3)
        
        df['light_adjustment'] = (
            0.3 * (12 - df['daylight_hours']) / 4 +  # Less daylight = more artificial light
            0.2 * np.sin(df['season_encoded'] * np.pi / 2 + np.pi) +  # Winter light needs
            np.random.normal(0, 0.1, n_samples)
        )
        df['light_adjustment'] = np.clip(df['light_adjustment'], -0.4, 0.4)
        
        # Risk score
        df['risk_score'] = (
            0.3 * np.abs(df['temperature'] - 22) / 15 +  # Temperature stress
            0.2 * np.abs(df['humidity'] - 60) / 40 +  # Humidity stress
            0.2 * (1 - df['daylight_hours'] / 16) +  # Light stress
            0.2 * np.clip(df['precipitation'] / 5, 0, 1) +  # Excess moisture risk
            0.1 * np.random.random(n_samples)  # Random factors
        )
        df['risk_score'] = np.clip(df['risk_score'], 0, 1)
        
        return df
    
    def _generate_enhanced_training_data(self) -> pd.DataFrame:
        """Generate enhanced synthetic training data with species-specific patterns."""
        np.random.seed(42)
        n_samples = 15000
        
        # Define plant species categories with different behaviors
        species_categories = {
            'tropical': {'temp_opt': 25, 'humidity_opt': 70, 'growth_rate_base': 0.8},
            'temperate': {'temp_opt': 20, 'humidity_opt': 60, 'growth_rate_base': 0.6},
            'succulent': {'temp_opt': 22, 'humidity_opt': 40, 'growth_rate_base': 0.3},
            'fern': {'temp_opt': 18, 'humidity_opt': 80, 'growth_rate_base': 0.5},
            'flowering': {'temp_opt': 21, 'humidity_opt': 65, 'growth_rate_base': 0.7}
        }
        
        data = {
            'temperature': np.random.normal(20, 10, n_samples),
            'humidity': np.random.normal(60, 25, n_samples),
            'daylight_hours': np.random.uniform(6, 18, n_samples),
            'precipitation': np.random.exponential(2.5, n_samples),
            'plant_age_days': np.random.uniform(30, 1460, n_samples),  # Up to 4 years
            'season_encoded': np.random.randint(0, 4, n_samples),
            'species_encoded': np.random.randint(0, 100, n_samples),
        }
        
        df = pd.DataFrame(data)
        
        # Add species category
        df['species_category'] = np.random.choice(list(species_categories.keys()), n_samples)
        
        # Enhanced growth rate calculation with species-specific behavior
        df['growth_rate'] = 0.0
        for category, params in species_categories.items():
            mask = df['species_category'] == category
            
            # Base growth rate for species
            base_rate = params['growth_rate_base']
            
            # Temperature effect (optimal temperature preference)
            temp_effect = 1 - np.abs(df.loc[mask, 'temperature'] - params['temp_opt']) / 20
            temp_effect = np.clip(temp_effect, 0.2, 1.2)
            
            # Humidity effect
            humidity_effect = 1 - np.abs(df.loc[mask, 'humidity'] - params['humidity_opt']) / 50
            humidity_effect = np.clip(humidity_effect, 0.3, 1.1)
            
            # Seasonal effect
            seasonal_effect = 0.8 + 0.4 * np.sin(df.loc[mask, 'season_encoded'] * np.pi / 2)
            
            # Light effect
            light_effect = np.clip(df.loc[mask, 'daylight_hours'] / 14, 0.4, 1.2)
            
            # Age effect (young plants grow faster)
            age_effect = np.exp(-df.loc[mask, 'plant_age_days'] / 1000)
            age_effect = np.clip(age_effect, 0.3, 1.0)
            
            df.loc[mask, 'growth_rate'] = (
                base_rate * temp_effect * humidity_effect * 
                seasonal_effect * light_effect * age_effect +
                np.random.normal(0, 0.1, mask.sum())
            )
        
        df['growth_rate'] = np.clip(df['growth_rate'], 0, 2.5)
        
        # Enhanced care adjustments with species-specific needs
        df['water_adjustment'] = 0.0
        df['fertilizer_adjustment'] = 0.0
        df['light_adjustment'] = 0.0
        
        for category, params in species_categories.items():
            mask = df['species_category'] == category
            
            # Water adjustment based on species and conditions
            if category == 'succulent':
                water_base = -0.2  # Succulents need less water
            elif category == 'fern':
                water_base = 0.3   # Ferns need more water
            else:
                water_base = 0.0
            
            df.loc[mask, 'water_adjustment'] = (
                water_base +
                0.3 * (params['temp_opt'] - df.loc[mask, 'temperature']) / 15 +
                0.2 * (params['humidity_opt'] - df.loc[mask, 'humidity']) / 40 +
                0.1 * np.sin(df.loc[mask, 'season_encoded'] * np.pi / 2) +
                np.random.normal(0, 0.1, mask.sum())
            )
            
            # Fertilizer adjustment
            fert_seasonal = 0.4 * np.sin(df.loc[mask, 'season_encoded'] * np.pi / 2)
            fert_growth = 0.3 * df.loc[mask, 'growth_rate']
            df.loc[mask, 'fertilizer_adjustment'] = (
                fert_seasonal + fert_growth + np.random.normal(0, 0.1, mask.sum())
            )
            
            # Light adjustment
            light_need = 0.4 * (14 - df.loc[mask, 'daylight_hours']) / 8
            if category == 'fern':
                light_need *= 0.5  # Ferns prefer less direct light
            elif category == 'succulent':
                light_need *= 1.2  # Succulents need more light
            
            df.loc[mask, 'light_adjustment'] = light_need + np.random.normal(0, 0.1, mask.sum())
        
        # Clip adjustments
        df['water_adjustment'] = np.clip(df['water_adjustment'], -0.6, 0.6)
        df['fertilizer_adjustment'] = np.clip(df['fertilizer_adjustment'], -0.4, 0.4)
        df['light_adjustment'] = np.clip(df['light_adjustment'], -0.5, 0.5)
        
        # Enhanced risk score with species-specific vulnerabilities
        df['risk_score'] = 0.0
        for category, params in species_categories.items():
            mask = df['species_category'] == category
            
            # Temperature stress
            temp_stress = np.abs(df.loc[mask, 'temperature'] - params['temp_opt']) / 20
            
            # Humidity stress
            humidity_stress = np.abs(df.loc[mask, 'humidity'] - params['humidity_opt']) / 50
            
            # Light stress
            light_stress = np.abs(df.loc[mask, 'daylight_hours'] - 12) / 8
            
            # Seasonal vulnerability
            if category == 'tropical':
                seasonal_risk = 0.3 * (df.loc[mask, 'season_encoded'] == 3)  # Winter risk
            elif category == 'succulent':
                seasonal_risk = 0.2 * (df.loc[mask, 'season_encoded'] == 1)  # Summer risk
            else:
                seasonal_risk = 0.1
            
            df.loc[mask, 'risk_score'] = (
                0.3 * temp_stress + 0.25 * humidity_stress + 
                0.2 * light_stress + seasonal_risk +
                0.15 * np.random.random(mask.sum())
            )
        
        df['risk_score'] = np.clip(df['risk_score'], 0, 1)
        
        # Add growth phase encoding
        df['growth_phase'] = np.random.choice(['dormant', 'slow', 'active', 'rapid'], n_samples)
        
        return df
    
    def _create_species_behavior_model(self, training_data: pd.DataFrame):
        """Create species-specific behavior clustering model."""
        logger.info("Creating species behavior model")
        
        # Features for species clustering
        species_features = ['temperature', 'humidity', 'daylight_hours', 'growth_rate', 
                           'water_adjustment', 'fertilizer_adjustment', 'risk_score']
        
        # Group by species and calculate mean characteristics
        species_profiles = training_data.groupby('species_encoded')[species_features].mean()
        
        # Create clustering model for species behavior patterns
        self.species_behavior_model = KMeans(n_clusters=5, random_state=42)
        self.species_behavior_model.fit(species_profiles)
        
        logger.info("Species behavior model created successfully")
    
    def _create_growth_phase_model(self, training_data: pd.DataFrame, features_scaled: np.ndarray):
        """Create growth phase prediction model."""
        logger.info("Creating growth phase prediction model")
        
        # Encode growth phases
        phase_encoder = LabelEncoder()
        growth_phase_encoded = phase_encoder.fit_transform(training_data['growth_phase'])
        
        # Create multi-class classifier for growth phases
        self.growth_phase_model = RandomForestClassifier(
            n_estimators=150,
            max_depth=8,
            random_state=42
        )
        self.growth_phase_model.fit(features_scaled, growth_phase_encoded)
        
        # Store the encoder for later use
        self.growth_phase_encoder = phase_encoder
        
        logger.info("Growth phase prediction model created successfully")
    
    def _create_care_confidence_model(self, training_data: pd.DataFrame, features_scaled: np.ndarray):
        """Create care adjustment confidence scoring model."""
        logger.info("Creating care confidence model")
        
        # Generate confidence scores based on prediction uncertainty
        # Use the variance in care adjustments as a proxy for confidence
        care_adjustments = training_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
        
        # Calculate confidence based on environmental stability and species certainty
        confidence_scores = []
        for idx, row in training_data.iterrows():
            # Base confidence on environmental factor stability
            temp_stability = 1 - min(abs(row['temperature'] - 20) / 20, 1)
            humidity_stability = 1 - min(abs(row['humidity'] - 60) / 40, 1)
            light_stability = 1 - min(abs(row['daylight_hours'] - 12) / 6, 1)
            
            # Species familiarity (more common species = higher confidence)
            species_confidence = 1 - (row['species_encoded'] / 100)
            
            # Growth phase certainty
            growth_certainty = min(row['growth_rate'] * 2, 1)
            
            # Combined confidence score
            confidence = (
                0.3 * temp_stability + 
                0.2 * humidity_stability + 
                0.2 * light_stability + 
                0.2 * species_confidence + 
                0.1 * growth_certainty
            )
            confidence_scores.append(np.clip(confidence, 0.3, 0.95))
        
        training_data['care_confidence'] = confidence_scores
        
        # Train confidence prediction model
        self.care_confidence_model = GradientBoostingRegressor(
            n_estimators=100,
            learning_rate=0.1,
            max_depth=4,
            random_state=42
        )
        self.care_confidence_model.fit(features_scaled, confidence_scores)
        
        logger.info("Care confidence model created successfully")
    
    def _save_enhanced_models(self):
        """Save all enhanced models to disk."""
        try:
            joblib.dump(self.growth_model, self.growth_model_path)
            joblib.dump(self.care_model, self.care_model_path)
            joblib.dump(self.risk_model, self.risk_model_path)
            joblib.dump(self.feature_scaler, self.scaler_path)
            joblib.dump(self.polynomial_features, self.poly_features_path)
            
            if self.species_behavior_model:
                joblib.dump(self.species_behavior_model, self.species_model_path)
            
            if self.growth_phase_model:
                joblib.dump(self.growth_phase_model, self.growth_phase_model_path)
            
            if hasattr(self, 'care_confidence_model') and self.care_confidence_model:
                joblib.dump(self.care_confidence_model, self.care_confidence_model_path)
            
            logger.info("All enhanced models saved successfully")
            
        except Exception as e:
            logger.error(f"Failed to save enhanced models: {str(e)}")
    
    def predict_species_behavior_pattern(self, species_characteristics: Dict[str, float]) -> int:
        """Predict behavior pattern cluster for a plant species."""
        if not self.species_behavior_model:
            return 0  # Default cluster
        
        features = [
            species_characteristics.get('temperature', 20),
            species_characteristics.get('humidity', 60),
            species_characteristics.get('daylight_hours', 12),
            species_characteristics.get('growth_rate', 0.5),
            species_characteristics.get('water_adjustment', 0),
            species_characteristics.get('fertilizer_adjustment', 0),
            species_characteristics.get('risk_score', 0.3)
        ]
        
        return self.species_behavior_model.predict([features])[0]
    
    def predict_growth_phase_with_confidence(self, environmental_features: List[float]) -> Tuple[str, float]:
        """Predict growth phase with confidence score."""
        if not self.growth_phase_model or not hasattr(self, 'growth_phase_encoder'):
            return "active", 0.5  # Default prediction
        
        try:
            # Transform features
            if self.polynomial_features:
                features_poly = self.polynomial_features.transform([environmental_features])
                features_scaled = self.feature_scaler.transform(features_poly)
            else:
                features_scaled = self.feature_scaler.transform([environmental_features])
            
            # Predict phase
            phase_encoded = self.growth_phase_model.predict(features_scaled)[0]
            phase_name = self.growth_phase_encoder.inverse_transform([phase_encoded])[0]
            
            # Get confidence (probability of predicted class)
            probabilities = self.growth_phase_model.predict_proba(features_scaled)[0]
            confidence = np.max(probabilities)
            
            return phase_name, confidence
            
        except Exception as e:
            logger.error(f"Error predicting growth phase: {str(e)}")
            return "active", 0.5
    
    def _generate_basic_training_data(self) -> pd.DataFrame:
        """Generate minimal training data for basic models."""
        np.random.seed(42)
        n_samples = 1000
        
        data = {
            'temperature': np.random.normal(20, 5, n_samples),
            'humidity': np.random.normal(60, 15, n_samples),
            'daylight_hours': np.random.uniform(10, 14, n_samples),
            'precipitation': np.random.exponential(1, n_samples),
            'plant_age_days': np.random.uniform(60, 730, n_samples),
            'season_encoded': np.random.randint(0, 4, n_samples),
            'species_encoded': np.random.randint(0, 10, n_samples),
        }
        
        df = pd.DataFrame(data)
        
        # Simple target variables
        df['growth_rate'] = np.clip(np.random.normal(0.5, 0.2, n_samples), 0, 1)
        df['water_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.3, 0.3)
        df['fertilizer_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['light_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['risk_score'] = np.clip(np.random.normal(0.3, 0.2, n_samples), 0, 1)
        
        return dfclip(np.random.normal(0.5, 0.2, n_samples), 0, 1)
        df['water_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.3, 0.3)
        df['fertilizer_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['light_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['risk_score'] = np.clip(np.random.normal(0.3, 0.2, n_samples), 0, 1)
        
        return df
    
    def predict_care_adjustments_with_confidence(
        self, 
        environmental_features: List[float],
        species_id: Optional[int] = None
    ) -> Tuple[List[CareAdjustment], float]:
        """
        Predict care adjustments with confidence scoring.
        
        Args:
            environmental_features: Environmental feature vector
            species_id: Optional species identifier for species-specific adjustments
            
        Returns:
            Tuple of (care_adjustments, overall_confidence)
        """
        try:
            # Transform features
            if self.polynomial_features:
                features_poly = self.polynomial_features.transform([environmental_features])
                features_scaled = self.feature_scaler.transform(features_poly)
            else:
                features_scaled = self.feature_scaler.transform([environmental_features])
            
            # Predict care adjustments
            care_predictions = self.care_model.predict(features_scaled)[0]
            
            # Predict confidence if model exists
            if hasattr(self, 'care_confidence_model') and self.care_confidence_model:
                confidence = self.care_confidence_model.predict(features_scaled)[0]
            else:
                confidence = 0.7  # Default confidence
            
            # Create care adjustment objects
            care_adjustments = []
            care_types = ['watering', 'fertilizing', 'light']
            adjustment_values = care_predictions
            
            for i, care_type in enumerate(care_types):
                adjustment_value = adjustment_values[i]
                
                # Determine adjustment type and percentage
                if abs(adjustment_value) < 0.05:
                    adjustment_type = "maintain"
                    adjustment_percentage = 0.0
                elif adjustment_value > 0:
                    adjustment_type = "increase"
                    adjustment_percentage = min(adjustment_value * 100, 50)
                else:
                    adjustment_type = "decrease"
                    adjustment_percentage = max(adjustment_value * 100, -50)
                
                # Generate reason based on environmental conditions
                reason = self._generate_care_reason(care_type, adjustment_value, environmental_features)
                
                care_adjustment = CareAdjustment(
                    care_type=care_type,
                    adjustment_type=adjustment_type,
                    current_value=None,  # Would be filled from plant data
                    recommended_value=None,  # Would be calculated based on current value
                    adjustment_percentage=adjustment_percentage,
                    reason=reason,
                    confidence=confidence,
                    effective_date=date.today(),
                    duration_days=7  # Default duration
                )
                care_adjustments.append(care_adjustment)
            
            return care_adjustments, confidence
            
        except Exception as e:
            logger.error(f"Error predicting care adjustments: {str(e)}")
            # Return default care adjustments
            default_adjustments = [
                CareAdjustment(
                    care_type="watering",
                    adjustment_type="maintain",
                    current_value=None,
                    recommended_value=None,
                    adjustment_percentage=0.0,
                    reason="Unable to calculate specific adjustments",
                    confidence=0.3,
                    effective_date=date.today(),
                    duration_days=7
                )
            ]
            return default_adjustments, 0.3
    
    def _generate_care_reason(self, care_type: str, adjustment_value: float, environmental_features: List[float]) -> str:
        """Generate human-readable reason for care adjustment."""
        temp, humidity, daylight, precip = environmental_features[:4]
        
        if care_type == "watering":
            if adjustment_value > 0.1:
                if temp > 25:
                    return "Increase watering due to high temperatures"
                elif humidity < 40:
                    return "Increase watering due to low humidity"
                else:
                    return "Increase watering based on seasonal patterns"
            elif adjustment_value < -0.1:
                if humidity > 80:
                    return "Reduce watering due to high humidity"
                elif precip > 5:
                    return "Reduce watering due to recent precipitation"
                else:
                    return "Reduce watering to prevent overwatering"
            else:
                return "Maintain current watering schedule"
        
        elif care_type == "fertilizing":
            if adjustment_value > 0.1:
                return "Increase fertilization during active growth period"
            elif adjustment_value < -0.1:
                return "Reduce fertilization during dormant period"
            else:
                return "Maintain current fertilization schedule"
        
        elif care_type == "light":
            if adjustment_value > 0.1:
                if daylight < 10:
                    return "Increase artificial lighting due to short daylight hours"
                else:
                    return "Increase light exposure for optimal growth"
            elif adjustment_value < -0.1:
                return "Reduce light exposure to prevent stress"
            else:
                return "Current light conditions are adequate"
        
        return "Adjustment based on seasonal AI analysis"
    
    def predict_growth_phase_from_environment(
        self, 
        temperature: float,
        humidity: float,
        daylight_hours: float,
        precipitation: float,
        plant_age_days: int,
        season: int,
        species_id: int
    ) -> Tuple[str, float]:
        """
        Predict growth phase based on environmental factors.
        
        Args:
            temperature: Temperature in Celsius
            humidity: Humidity percentage
            daylight_hours: Hours of daylight
            precipitation: Precipitation in mm
            plant_age_days: Plant age in days
            season: Season encoded (0=spring, 1=summer, 2=autumn, 3=winter)
            species_id: Species identifier
            
        Returns:
            Tuple of (growth_phase, confidence)
        """
        environmental_features = [
            temperature, humidity, daylight_hours, precipitation,
            plant_age_days, season, species_id
        ]
        
        return self.predict_growth_phase_with_confidence(environmental_features)
    
    def get_species_seasonal_behavior(self, species_id: int) -> Dict[str, Any]:
        """
        Get seasonal behavior patterns for a specific plant species.
        
        Args:
            species_id: Species identifier
            
        Returns:
            Dictionary with species seasonal behavior characteristics
        """
        # Default characteristics - in production, this would query species database
        default_characteristics = {
            'temperature': 20.0,
            'humidity': 60.0,
            'daylight_hours': 12.0,
            'growth_rate': 0.5,
            'water_adjustment': 0.0,
            'fertilizer_adjustment': 0.0,
            'risk_score': 0.3
        }
        
        # Get behavior pattern cluster
        behavior_cluster = self.predict_species_behavior_pattern(default_characteristics)
        
        # Define cluster characteristics
        cluster_behaviors = {
            0: {  # Tropical plants
                'optimal_temperature_range': (22, 28),
                'optimal_humidity_range': (60, 80),
                'light_requirements': 'high',
                'seasonal_dormancy': False,
                'growth_peak_seasons': ['spring', 'summer'],
                'water_frequency_multiplier': 1.2,
                'fertilizer_frequency_multiplier': 1.1
            },
            1: {  # Temperate plants
                'optimal_temperature_range': (18, 24),
                'optimal_humidity_range': (50, 70),
                'light_requirements': 'medium',
                'seasonal_dormancy': True,
                'growth_peak_seasons': ['spring', 'summer'],
                'water_frequency_multiplier': 1.0,
                'fertilizer_frequency_multiplier': 1.0
            },
            2: {  # Succulents
                'optimal_temperature_range': (20, 26),
                'optimal_humidity_range': (30, 50),
                'light_requirements': 'high',
                'seasonal_dormancy': False,
                'growth_peak_seasons': ['spring', 'autumn'],
                'water_frequency_multiplier': 0.6,
                'fertilizer_frequency_multiplier': 0.8
            },
            3: {  # Ferns
                'optimal_temperature_range': (16, 22),
                'optimal_humidity_range': (70, 90),
                'light_requirements': 'low',
                'seasonal_dormancy': False,
                'growth_peak_seasons': ['spring', 'summer'],
                'water_frequency_multiplier': 1.3,
                'fertilizer_frequency_multiplier': 0.9
            },
            4: {  # Flowering plants
                'optimal_temperature_range': (19, 25),
                'optimal_humidity_range': (55, 75),
                'light_requirements': 'medium-high',
                'seasonal_dormancy': True,
                'growth_peak_seasons': ['spring', 'summer'],
                'water_frequency_multiplier': 1.1,
                'fertilizer_frequency_multiplier': 1.2
            }
        }
        
        return cluster_behaviors.get(behavior_cluster, cluster_behaviors[1])
    
    def get_model_performance_metrics(self) -> Dict[str, Any]:
        """Get performance metrics for the trained models."""
        metrics = {
            'model_version': self.model_version,
            'models_loaded': {
                'growth_model': self.growth_model is not None,
                'care_model': self.care_model is not None,
                'risk_model': self.risk_model is not None,
                'species_behavior_model': self.species_behavior_model is not None,
                'growth_phase_model': self.growth_phase_model is not None,
                'care_confidence_model': hasattr(self, 'care_confidence_model') and self.care_confidence_model is not None
            }
        }
        
        # Add model-specific metrics if available
        try:
            # Generate test data for evaluation
            test_data = self._generate_enhanced_training_data()
            base_features = ['temperature', 'humidity', 'daylight_hours', 'precipitation',
                           'plant_age_days', 'season_encoded', 'species_encoded']
            
            if self.polynomial_features and self.feature_scaler:
                features_poly = self.polynomial_features.transform(test_data[base_features])
                features_scaled = self.feature_scaler.transform(features_poly)
                
                # Growth model metrics
                if self.growth_model:
                    growth_pred = self.growth_model.predict(features_scaled)
                    growth_mse = mean_squared_error(test_data['growth_rate'], growth_pred)
                    growth_r2 = r2_score(test_data['growth_rate'], growth_pred)
                    metrics['growth_model_mse'] = growth_mse
                    metrics['growth_model_r2'] = growth_r2
                
                # Care model metrics
                if self.care_model:
                    care_pred = self.care_model.predict(features_scaled)
                    care_targets = test_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
                    care_mse = mean_squared_error(care_targets, care_pred)
                    metrics['care_model_mse'] = care_mse
                
                # Risk model metrics
                if self.risk_model:
                    risk_pred = self.risk_model.predict(features_scaled)
                    risk_mse = mean_squared_error(test_data['risk_score'], risk_pred)
                    risk_r2 = r2_score(test_data['risk_score'], risk_pred)
                    metrics['risk_model_mse'] = risk_mse
                    metrics['risk_model_r2'] = risk_r2
                
                # Growth phase model metrics
                if self.growth_phase_model and hasattr(self, 'growth_phase_encoder'):
                    phase_encoded = self.growth_phase_encoder.transform(test_data['growth_phase'])
                    phase_pred = self.growth_phase_model.predict(features_scaled)
                    phase_accuracy = accuracy_score(phase_encoded, phase_pred)
                    metrics['growth_phase_accuracy'] = phase_accuracy
                    
        except Exception as e:
            logger.warning(f"Could not calculate model metrics: {str(e)}")
            metrics['metrics_error'] = str(e)
        
        return metricsclip(np.random.normal(0.5, 0.2, n_samples), 0, 1)
        df['water_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.3, 0.3)
        df['fertilizer_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['light_adjustment'] = np.clip(np.random.normal(0, 0.1, n_samples), -0.2, 0.2)
        df['risk_score'] = np.clip(np.random.normal(0.3, 0.2, n_samples), 0, 1)
        
        return df
    
    async def predict_seasonal_behavior(
        self, 
        plant_id: UUID, 
        prediction_days: int = 90
    ) -> SeasonalPredictionResult:
        """
        Predict seasonal behavior for a specific plant.
        
        Args:
            plant_id: UUID of the plant
            prediction_days: Number of days to predict ahead
            
        Returns:
            SeasonalPredictionResult with comprehensive predictions
        """
        logger.info(f"Predicting seasonal behavior for plant {plant_id}")
        
        async with get_db() as db:
            # Get plant and species information
            plant_query = select(UserPlant).where(UserPlant.id == plant_id)
            plant_result = await db.execute(plant_query)
            plant = plant_result.scalar_one_or_none()
            
            if not plant:
                raise ValueError(f"Plant with ID {plant_id} not found")
            
            species_query = select(PlantSpecies).where(PlantSpecies.id == plant.species_id)
            species_result = await db.execute(species_query)
            species = species_result.scalar_one_or_none()
            
            if not species:
                raise ValueError(f"Species for plant {plant_id} not found")
        
        # Get user location (assuming it's stored in user profile or plant location)
        # For now, use a default location - this should be retrieved from user data
        location = Location(
            latitude=40.7128,  # New York City default
            longitude=-74.0060,
            city="New York",
            country="USA",
            timezone="America/New_York"
        )
        
        # Get environmental data
        weather_forecast = await self.environmental_service.get_weather_data(location, prediction_days)
        seasonal_transitions = await self.pattern_service.detect_seasonal_transitions(location)
        
        # Prepare prediction period
        start_date = date.today()
        end_date = start_date + timedelta(days=prediction_days)
        
        # Generate predictions
        growth_forecast = await self._predict_growth_phases(
            plant, species, weather_forecast, seasonal_transitions
        )
        
        care_adjustments = await self._predict_care_adjustments(
            plant, species, weather_forecast, seasonal_transitions
        )
        
        risk_factors = await self._assess_seasonal_risks(
            plant, species, location, weather_forecast
        )
        
        optimal_activities = await self._predict_optimal_activities(
            plant, species, seasonal_transitions, start_date, end_date
        )
        
        # Calculate overall confidence
        confidence_score = self._calculate_prediction_confidence(
            growth_forecast, care_adjustments, risk_factors
        )
        
        return SeasonalPredictionResult(
            plant_id=plant_id,
            prediction_period=(start_date, end_date),
            growth_forecast=growth_forecast,
            care_adjustments=care_adjustments,
            risk_factors=risk_factors,
            optimal_activities=optimal_activities,
            confidence_score=confidence_score,
            model_version=self.model_version,
            environmental_factors={
                "location": location.model_dump(),
                "seasonal_transitions": len(seasonal_transitions),
                "weather_provider": weather_forecast.provider.value
            }
        )
    
    async def _predict_growth_phases(
        self,
        plant: UserPlant,
        species: PlantSpecies,
        weather_forecast: Any,
        seasonal_transitions: List[Any]
    ) -> GrowthForecast:
        """Predict growth phases based on environmental factors."""
        # Calculate plant age
        plant_age_days = (datetime.utcnow() - plant.created_at).days
        
        # Prepare features for ML model
        features = self._prepare_growth_features(
            plant, species, weather_forecast, plant_age_days
        )
        
        # Predict growth rate
        growth_rate = self.growth_model.predict([features])[0]
        growth_rate = max(0, min(2, growth_rate))  # Clamp to reasonable range
        
        # Generate size projections
        size_projections = self._generate_size_projections(growth_rate, 90)
        
        # Predict flowering periods
        flowering_predictions = self._predict_flowering_periods(
            species, seasonal_transitions, weather_forecast
        )
        
        # Predict dormancy periods
        dormancy_periods = self._predict_dormancy_periods(
            species, seasonal_transitions, weather_forecast
        )
        
        # Calculate stress likelihood
        stress_likelihood = self._calculate_stress_likelihood(
            weather_forecast, seasonal_transitions
        )
        
        return GrowthForecast(
            expected_growth_rate=growth_rate,
            size_projections=size_projections,
            flowering_predictions=flowering_predictions,
            dormancy_periods=dormancy_periods,
            stress_likelihood=stress_likelihood
        )
    
    async def _predict_care_adjustments(
        self,
        plant: UserPlant,
        species: PlantSpecies,
        weather_forecast: Any,
        seasonal_transitions: List[Any]
    ) -> List[CareAdjustment]:
        """Predict care adjustments based on seasonal changes."""
        plant_age_days = (datetime.utcnow() - plant.created_at).days
        
        # Prepare features for ML model
        features = self._prepare_care_features(
            plant, species, weather_forecast, plant_age_days
        )
        
        # Predict care adjustments
        care_predictions = self.care_model.predict([features])[0]
        
        adjustments = []
        
        # Water adjustment
        water_adj = care_predictions[0]
        if abs(water_adj) > 0.1:  # Only significant adjustments
            adjustments.append(CareAdjustment(
                care_type="watering",
                adjustment_type="increase" if water_adj > 0 else "decrease",
                current_value=species.water_frequency_days,
                recommended_value=species.water_frequency_days * (1 - water_adj),
                adjustment_percentage=abs(water_adj) * 100,
                reason=self._get_water_adjustment_reason(water_adj, seasonal_transitions),
                confidence=0.8,
                effective_date=date.today(),
                duration_days=30
            ))
        
        # Fertilizer adjustment
        fertilizer_adj = care_predictions[1]
        if abs(fertilizer_adj) > 0.1:
            adjustments.append(CareAdjustment(
                care_type="fertilizing",
                adjustment_type="increase" if fertilizer_adj > 0 else "decrease",
                current_value=None,
                recommended_value=None,
                adjustment_percentage=abs(fertilizer_adj) * 100,
                reason=self._get_fertilizer_adjustment_reason(fertilizer_adj, seasonal_transitions),
                confidence=0.75,
                effective_date=date.today(),
                duration_days=60
            ))
        
        # Light adjustment
        light_adj = care_predictions[2]
        if abs(light_adj) > 0.1:
            adjustments.append(CareAdjustment(
                care_type="light",
                adjustment_type="increase" if light_adj > 0 else "decrease",
                current_value=None,
                recommended_value=None,
                adjustment_percentage=abs(light_adj) * 100,
                reason=self._get_light_adjustment_reason(light_adj, seasonal_transitions),
                confidence=0.7,
                effective_date=date.today(),
                duration_days=90
            ))
        
        return adjustments
    
    async def _assess_seasonal_risks(
        self,
        plant: UserPlant,
        species: PlantSpecies,
        location: Location,
        weather_forecast: Any
    ) -> List[RiskFactor]:
        """Assess seasonal risks for the plant."""
        plant_age_days = (datetime.utcnow() - plant.created_at).days
        
        # Prepare features for risk model
        features = self._prepare_risk_features(
            plant, species, weather_forecast, plant_age_days
        )
        
        # Predict overall risk score
        risk_score = self.risk_model.predict([features])[0]
        risk_score = max(0, min(1, risk_score))
        
        risk_factors = []
        
        # Environmental stress risk
        if risk_score > 0.6:
            risk_factors.append(RiskFactor(
                risk_type="environmental_stress",
                risk_level="high" if risk_score > 0.8 else "medium",
                probability=risk_score,
                impact_severity=0.7,
                onset_date=date.today() + timedelta(days=7),
                mitigation_actions=[
                    "Monitor plant closely for stress signs",
                    "Adjust watering schedule based on weather",
                    "Provide additional humidity if needed",
                    "Consider relocating plant if conditions worsen"
                ],
                monitoring_frequency="daily"
            ))
        
        # Seasonal pest risk
        pest_risk_data = await self.environmental_service.get_seasonal_pest_data(
            location, species.scientific_name
        )
        
        if pest_risk_data.overall_risk_score > 0.5:
            risk_factors.append(RiskFactor(
                risk_type="pest",
                risk_level="medium" if pest_risk_data.overall_risk_score < 0.7 else "high",
                probability=pest_risk_data.overall_risk_score,
                impact_severity=0.6,
                onset_date=date.today() + timedelta(days=14),
                mitigation_actions=[
                    "Inspect plant regularly for pest signs",
                    "Improve air circulation around plant",
                    "Use preventive treatments if recommended",
                    "Quarantine plant if pests detected"
                ],
                monitoring_frequency="weekly"
            ))
        
        return risk_factors
    
    async def _predict_optimal_activities(
        self,
        plant: UserPlant,
        species: PlantSpecies,
        seasonal_transitions: List[Any],
        start_date: date,
        end_date: date
    ) -> List[PlantActivity]:
        """Predict optimal timing for plant activities."""
        activities = []
        
        # Repotting recommendations
        if plant.last_repotted:
            days_since_repot = (datetime.utcnow() - plant.last_repotted).days
            if days_since_repot > 365:  # More than a year
                optimal_start = start_date + timedelta(days=30)  # Spring timing
                optimal_end = optimal_start + timedelta(days=60)
                
                activities.append(PlantActivity(
                    activity_type="repotting",
                    optimal_date_range=(optimal_start, optimal_end),
                    priority="medium",
                    success_probability=0.8,
                    required_conditions=[
                        "Active growing season",
                        "Stable temperatures above 15°C",
                        "No recent stress events"
                    ],
                    preparation_steps=[
                        "Prepare new pot and soil",
                        "Water plant 24 hours before repotting",
                        "Choose overcast day to reduce stress"
                    ]
                ))
        
        # Propagation opportunities
        if any(t.transition_type == "spring_onset" for t in seasonal_transitions):
            prop_start = start_date + timedelta(days=45)
            prop_end = prop_start + timedelta(days=30)
            
            activities.append(PlantActivity(
                activity_type="propagation",
                optimal_date_range=(prop_start, prop_end),
                priority="low",
                success_probability=0.7,
                required_conditions=[
                    "Healthy parent plant",
                    "Active growth phase",
                    "Warm temperatures"
                ],
                preparation_steps=[
                    "Identify healthy growth points",
                    "Prepare propagation medium",
                    "Sterilize cutting tools"
                ]
            ))
        
        return activities
    
    def _prepare_growth_features(
        self, 
        plant: UserPlant, 
        species: PlantSpecies, 
        weather_forecast: Any, 
        plant_age_days: int
    ) -> List[float]:
        """Prepare enhanced features for growth prediction model."""
        current_weather = weather_forecast.current
        
        # Encode season (0=spring, 1=summer, 2=autumn, 3=winter)
        month = date.today().month
        season = self._encode_season(month)
        
        # Enhanced species encoding with behavior pattern
        species_encoded = hash(species.scientific_name) % 100
        
        # Calculate daylight hours based on season and location
        daylight_hours = self._estimate_daylight_hours(season)
        
        base_features = [
            current_weather.temperature,
            current_weather.humidity,
            daylight_hours,
            current_weather.precipitation,
            plant_age_days,
            season,
            species_encoded
        ]
        
        # Apply polynomial features if available
        if self.polynomial_features:
            try:
                poly_features = self.polynomial_features.transform([base_features])
                return poly_features[0].tolist()
            except Exception as e:
                logger.warning(f"Failed to apply polynomial features: {str(e)}")
                return base_features
        
        return base_features
    
    def _estimate_daylight_hours(self, season: int) -> float:
        """Estimate daylight hours based on season."""
        # Approximate daylight hours by season (Northern Hemisphere)
        daylight_by_season = {
            0: 12.5,  # Spring
            1: 14.5,  # Summer
            2: 11.5,  # Autumn
            3: 9.5    # Winter
        }
        return daylight_by_season.get(season, 12.0)
    
    def _prepare_care_features(
        self, 
        plant: UserPlant, 
        species: PlantSpecies, 
        weather_forecast: Any, 
        plant_age_days: int
    ) -> List[float]:
        """Prepare features for care adjustment model."""
        return self._prepare_growth_features(plant, species, weather_forecast, plant_age_days)
    
    def _prepare_risk_features(
        self, 
        plant: UserPlant, 
        species: PlantSpecies, 
        weather_forecast: Any, 
        plant_age_days: int
    ) -> List[float]:
        """Prepare features for risk assessment model."""
        return self._prepare_growth_features(plant, species, weather_forecast, plant_age_days)
    
    def _generate_size_projections(self, growth_rate: float, days: int) -> List[Dict[str, Any]]:
        """Generate size projections based on growth rate."""
        projections = []
        current_size = 1.0  # Normalized size
        
        for week in range(0, days, 7):
            current_size *= (1 + growth_rate * 0.01)  # Weekly growth
            projections.append({
                "date": date.today() + timedelta(days=week),
                "relative_size": current_size,
                "growth_stage": self._classify_growth_stage(current_size)
            })
        
        return projections
    
    def _classify_growth_stage(self, size: float) -> str:
        """Classify growth stage based on size."""
        if size < 1.1:
            return "stable"
        elif size < 1.3:
            return "slow_growth"
        elif size < 1.6:
            return "active_growth"
        else:
            return "rapid_growth"
    
    def _predict_flowering_periods(
        self, 
        species: PlantSpecies, 
        seasonal_transitions: List[Any], 
        weather_forecast: Any
    ) -> List[Dict[str, Any]]:
        """Predict flowering periods based on species and season."""
        flowering_predictions = []
        
        # Simple flowering prediction based on season
        current_month = date.today().month
        
        if current_month in [3, 4, 5, 6]:  # Spring/early summer
            flowering_predictions.append({
                "start_date": date.today() + timedelta(days=30),
                "end_date": date.today() + timedelta(days=60),
                "flowering_type": "spring_bloom",
                "probability": 0.7,
                "intensity": "moderate"
            })
        
        return flowering_predictions
    
    def _predict_dormancy_periods(
        self, 
        species: PlantSpecies, 
        seasonal_transitions: List[Any], 
        weather_forecast: Any
    ) -> List[Dict[str, Any]]:
        """Predict dormancy periods based on species and season."""
        dormancy_predictions = []
        
        # Check for winter dormancy
        winter_transitions = [t for t in seasonal_transitions if "winter" in t.transition_type]
        
        if winter_transitions:
            dormancy_predictions.append({
                "start_date": date.today() + timedelta(days=60),
                "end_date": date.today() + timedelta(days=150),
                "dormancy_type": "winter_dormancy",
                "intensity": "moderate",
                "care_adjustments": [
                    "Reduce watering frequency",
                    "Stop fertilizing",
                    "Provide cooler temperatures if possible"
                ]
            })
        
        return dormancy_predictions
    
    def _calculate_stress_likelihood(
        self, 
        weather_forecast: Any, 
        seasonal_transitions: List[Any]
    ) -> float:
        """Calculate likelihood of plant stress."""
        stress_factors = 0
        
        # Temperature stress
        current_temp = weather_forecast.current.temperature
        if current_temp < 10 or current_temp > 30:
            stress_factors += 0.3
        
        # Humidity stress
        current_humidity = weather_forecast.current.humidity
        if current_humidity < 30 or current_humidity > 80:
            stress_factors += 0.2
        
        # Seasonal transition stress
        if len(seasonal_transitions) > 2:
            stress_factors += 0.2
        
        return min(1.0, stress_factors)
    
    def _get_water_adjustment_reason(self, adjustment: float, transitions: List[Any]) -> str:
        """Get reason for water adjustment."""
        if adjustment > 0:
            return "Increased watering needed due to warmer temperatures and lower humidity"
        else:
            return "Reduced watering recommended due to cooler temperatures and higher humidity"
    
    def _get_fertilizer_adjustment_reason(self, adjustment: float, transitions: List[Any]) -> str:
        """Get reason for fertilizer adjustment."""
        if adjustment > 0:
            return "Increased fertilization recommended during active growing season"
        else:
            return "Reduced fertilization recommended during dormant period"
    
    def _get_light_adjustment_reason(self, adjustment: float, transitions: List[Any]) -> str:
        """Get reason for light adjustment."""
        if adjustment > 0:
            return "Additional light needed due to shorter daylight hours"
        else:
            return "Reduced light intensity recommended to prevent stress"
    
    def _calculate_prediction_confidence(
        self, 
        growth_forecast: GrowthForecast, 
        care_adjustments: List[CareAdjustment], 
        risk_factors: List[RiskFactor]
    ) -> float:
        """Calculate overall confidence score for predictions."""
        # Base confidence on model certainty and data quality
        base_confidence = 0.7
        
        # Adjust based on risk factors
        if len(risk_factors) > 2:
            base_confidence -= 0.1
        
        # Adjust based on care adjustments certainty
        if care_adjustments:
            avg_care_confidence = sum(adj.confidence for adj in care_adjustments) / len(care_adjustments)
            base_confidence = (base_confidence + avg_care_confidence) / 2
        
        # Adjust based on growth forecast stress likelihood
        if growth_forecast.stress_likelihood > 0.7:
            base_confidence -= 0.15
        
        return max(0.3, min(0.95, base_confidence))

    # ===== SEASONAL RISK ASSESSMENT AND FORECASTING METHODS =====
    
    async def predict_dormancy_periods(
        self,
        plant_id: UUID,
        species_name: str,
        location: Location,
        prediction_days: int = 180
    ) -> List[Dict[str, Any]]:
        """
        Predict dormancy periods for different plant species based on seasonal patterns.
        
        This method analyzes species-specific dormancy patterns, environmental conditions,
        and seasonal transitions to predict when plants will enter dormancy periods.
        """
        logger.info(f"Predicting dormancy periods for plant {plant_id}, species: {species_name}")
        
        try:
            # Get environmental data and seasonal transitions
            weather_forecast = await self.environmental_service.get_weather_data(location, prediction_days)
            seasonal_transitions = await self.pattern_service.detect_seasonal_transitions(location)
            
            # Get species-specific dormancy characteristics
            species_dormancy_profile = self._get_species_dormancy_profile(species_name)
            
            dormancy_predictions = []
            current_date = date.today()
            
            # Analyze seasonal transitions for dormancy triggers
            for transition in seasonal_transitions:
                if self._is_dormancy_trigger(transition, species_dormancy_profile):
                    dormancy_period = self._calculate_dormancy_period(
                        transition, species_dormancy_profile, weather_forecast
                    )
                    
                    if dormancy_period:
                        dormancy_predictions.append(dormancy_period)
            
            # If no specific transitions found, use general seasonal patterns
            if not dormancy_predictions:
                dormancy_predictions = self._predict_general_dormancy_patterns(
                    species_dormancy_profile, current_date, prediction_days
                )
            
            # Sort by start date
            dormancy_predictions.sort(key=lambda x: x['start_date'])
            
            logger.info(f"Predicted {len(dormancy_predictions)} dormancy periods")
            return dormancy_predictions
            
        except Exception as e:
            logger.error(f"Error predicting dormancy periods: {str(e)}")
            return []
    
    def _get_species_dormancy_profile(self, species_name: str) -> Dict[str, Any]:
        """Get dormancy characteristics for a plant species."""
        # Species-specific dormancy profiles
        dormancy_profiles = {
            # Deciduous trees and shrubs
            'acer': {
                'dormancy_type': 'winter_deciduous',
                'trigger_temperature': 10.0,
                'trigger_daylight': 10.0,
                'duration_days': 120,
                'intensity': 'complete',
                'care_adjustments': ['stop_fertilizing', 'reduce_watering_75', 'no_pruning']
            },
            'hibiscus': {
                'dormancy_type': 'winter_semi',
                'trigger_temperature': 15.0,
                'trigger_daylight': 10.5,
                'duration_days': 90,
                'intensity': 'partial',
                'care_adjustments': ['reduce_fertilizing', 'reduce_watering_50', 'maintain_humidity']
            },
            # Bulbs and tubers
            'tulipa': {
                'dormancy_type': 'summer_bulb',
                'trigger_temperature': 25.0,
                'trigger_daylight': 14.0,
                'duration_days': 150,
                'intensity': 'complete',
                'care_adjustments': ['stop_watering', 'stop_fertilizing', 'store_cool_dry']
            },
            # Succulents
            'echeveria': {
                'dormancy_type': 'winter_succulent',
                'trigger_temperature': 12.0,
                'trigger_daylight': 9.0,
                'duration_days': 60,
                'intensity': 'minimal',
                'care_adjustments': ['reduce_watering_80', 'stop_fertilizing', 'increase_light']
            },
            # Tropical plants
            'ficus': {
                'dormancy_type': 'winter_tropical',
                'trigger_temperature': 18.0,
                'trigger_daylight': 10.0,
                'duration_days': 45,
                'intensity': 'light',
                'care_adjustments': ['reduce_watering_30', 'reduce_fertilizing', 'maintain_warmth']
            }
        }
        
        # Try to match species name to profile
        species_lower = species_name.lower()
        for key, profile in dormancy_profiles.items():
            if key in species_lower:
                return profile
        
        # Default profile for unknown species
        return {
            'dormancy_type': 'winter_general',
            'trigger_temperature': 15.0,
            'trigger_daylight': 10.0,
            'duration_days': 75,
            'intensity': 'moderate',
            'care_adjustments': ['reduce_watering_50', 'reduce_fertilizing', 'monitor_closely']
        }
    
    def _is_dormancy_trigger(self, transition: Any, dormancy_profile: Dict[str, Any]) -> bool:
        """Check if a seasonal transition triggers dormancy for the species."""
        if not hasattr(transition, 'transition_type'):
            return False
            
        dormancy_type = dormancy_profile['dormancy_type']
        
        # Winter dormancy triggers
        if 'winter' in dormancy_type and 'winter' in transition.transition_type:
            return True
        
        # Summer dormancy triggers (for bulbs, some succulents)
        if 'summer' in dormancy_type and 'summer' in transition.transition_type:
            return True
        
        # Temperature-based triggers
        if hasattr(transition, 'temperature_change') and transition.temperature_change:
            if transition.temperature_change < -5 and 'winter' in dormancy_type:
                return True
        
        return False
    
    def _calculate_dormancy_period(
        self, 
        transition: Any, 
        dormancy_profile: Dict[str, Any], 
        weather_forecast: Any
    ) -> Optional[Dict[str, Any]]:
        """Calculate specific dormancy period based on transition and species profile."""
        try:
            # Calculate start date based on transition
            if hasattr(transition, 'transition_date'):
                start_date = transition.transition_date
            else:
                start_date = date.today() + timedelta(days=30)
            
            # Calculate duration
            base_duration = dormancy_profile['duration_days']
            
            # Adjust duration based on weather severity
            if hasattr(weather_forecast, 'forecast') and weather_forecast.forecast:
                avg_temp = sum(day.temperature for day in weather_forecast.forecast[:30]) / 30
                if avg_temp < dormancy_profile['trigger_temperature'] - 5:
                    base_duration = int(base_duration * 1.2)  # Extend dormancy in harsh conditions
            
            end_date = start_date + timedelta(days=base_duration)
            
            return {
                'start_date': start_date,
                'end_date': end_date,
                'dormancy_type': dormancy_profile['dormancy_type'],
                'intensity': dormancy_profile['intensity'],
                'trigger_factors': {
                    'temperature': getattr(transition, 'temperature_change', None),
                    'daylight': getattr(transition, 'daylight_change', None),
                    'transition_type': getattr(transition, 'transition_type', 'unknown')
                },
                'care_adjustments': dormancy_profile['care_adjustments'],
                'monitoring_recommendations': [
                    'Check soil moisture weekly',
                    'Monitor for pest activity',
                    'Ensure adequate ventilation',
                    'Watch for early emergence signs'
                ],
                'confidence_score': 0.8
            }
            
        except Exception as e:
            logger.error(f"Error calculating dormancy period: {str(e)}")
            return None
    
    def _predict_general_dormancy_patterns(
        self, 
        dormancy_profile: Dict[str, Any], 
        current_date: date, 
        prediction_days: int
    ) -> List[Dict[str, Any]]:
        """Predict dormancy patterns based on general seasonal cycles."""
        dormancy_predictions = []
        
        # Calculate next dormancy period based on current season
        current_month = current_date.month
        
        if 'winter' in dormancy_profile['dormancy_type']:
            # Winter dormancy typically starts in late fall
            if current_month < 11:  # Before November
                start_date = date(current_date.year, 11, 15)
            else:  # Already in dormancy season
                start_date = date(current_date.year + 1, 11, 15)
        elif 'summer' in dormancy_profile['dormancy_type']:
            # Summer dormancy typically starts in late spring
            if current_month < 6:  # Before June
                start_date = date(current_date.year, 6, 1)
            else:  # Already past or in summer dormancy
                start_date = date(current_date.year + 1, 6, 1)
        else:
            # Default to winter pattern
            start_date = date(current_date.year, 11, 15)
            if current_month >= 11:
                start_date = date(current_date.year + 1, 11, 15)
        
        # Only include if within prediction window
        if start_date <= current_date + timedelta(days=prediction_days):
            end_date = start_date + timedelta(days=dormancy_profile['duration_days'])
            
            dormancy_predictions.append({
                'start_date': start_date,
                'end_date': end_date,
                'dormancy_type': dormancy_profile['dormancy_type'],
                'intensity': dormancy_profile['intensity'],
                'trigger_factors': {
                    'seasonal_cycle': True,
                    'estimated': True
                },
                'care_adjustments': dormancy_profile['care_adjustments'],
                'monitoring_recommendations': [
                    'Monitor environmental conditions',
                    'Adjust care routine gradually',
                    'Prepare for dormancy period'
                ],
                'confidence_score': 0.6
            })
        
        return dormancy_predictions
    
    async def detect_seasonal_stress_risks(
        self,
        plant_id: UUID,
        species_name: str,
        location: Location,
        prediction_days: int = 90
    ) -> List[Dict[str, Any]]:
        """
        Detect and predict seasonal stress risks with prevention recommendations.
        
        This method analyzes environmental conditions, species vulnerabilities,
        and seasonal patterns to identify potential stress factors and provide
        preventive care recommendations.
        """
        logger.info(f"Detecting seasonal stress risks for plant {plant_id}, species: {species_name}")
        
        try:
            # Get environmental data
            weather_forecast = await self.environmental_service.get_weather_data(location, prediction_days)
            seasonal_transitions = await self.pattern_service.detect_seasonal_transitions(location)
            
            # Get species stress vulnerabilities
            stress_profile = self._get_species_stress_profile(species_name)
            
            stress_risks = []
            
            # Analyze temperature stress risks
            temp_risks = self._analyze_temperature_stress(weather_forecast, stress_profile)
            stress_risks.extend(temp_risks)
            
            # Analyze humidity stress risks
            humidity_risks = self._analyze_humidity_stress(weather_forecast, stress_profile)
            stress_risks.extend(humidity_risks)
            
            # Analyze light stress risks
            light_risks = self._analyze_light_stress(seasonal_transitions, stress_profile, location)
            stress_risks.extend(light_risks)
            
            # Analyze seasonal transition stress
            transition_risks = self._analyze_transition_stress(seasonal_transitions, stress_profile)
            stress_risks.extend(transition_risks)
            
            # Analyze pest and disease risks
            pest_risks = await self._analyze_seasonal_pest_risks(location, species_name, weather_forecast)
            stress_risks.extend(pest_risks)
            
            # Sort by risk level and onset date
            stress_risks.sort(key=lambda x: (x['risk_level_numeric'], x.get('onset_date', date.today())))
            
            logger.info(f"Detected {len(stress_risks)} seasonal stress risks")
            return stress_risks
            
        except Exception as e:
            logger.error(f"Error detecting seasonal stress risks: {str(e)}")
            return []
    
    def _get_species_stress_profile(self, species_name: str) -> Dict[str, Any]:
        """Get stress vulnerability profile for a plant species."""
        stress_profiles = {
            'ficus': {
                'temperature_range': (18, 26),
                'humidity_range': (50, 70),
                'light_sensitivity': 'moderate',
                'cold_tolerance': 'low',
                'heat_tolerance': 'moderate',
                'drought_tolerance': 'low',
                'pest_susceptibility': ['spider_mites', 'scale', 'mealybugs'],
                'seasonal_vulnerabilities': ['winter_shock', 'dry_air']
            },
            'monstera': {
                'temperature_range': (20, 28),
                'humidity_range': (60, 80),
                'light_sensitivity': 'low',
                'cold_tolerance': 'low',
                'heat_tolerance': 'high',
                'drought_tolerance': 'moderate',
                'pest_susceptibility': ['spider_mites', 'thrips'],
                'seasonal_vulnerabilities': ['winter_dormancy', 'low_humidity']
            },
            'echeveria': {
                'temperature_range': (15, 25),
                'humidity_range': (30, 50),
                'light_sensitivity': 'high',
                'cold_tolerance': 'moderate',
                'heat_tolerance': 'high',
                'drought_tolerance': 'high',
                'pest_susceptibility': ['mealybugs', 'aphids'],
                'seasonal_vulnerabilities': ['overwatering', 'frost_damage']
            },
            'pothos': {
                'temperature_range': (18, 24),
                'humidity_range': (40, 60),
                'light_sensitivity': 'low',
                'cold_tolerance': 'moderate',
                'heat_tolerance': 'moderate',
                'drought_tolerance': 'moderate',
                'pest_susceptibility': ['spider_mites', 'mealybugs'],
                'seasonal_vulnerabilities': ['root_rot', 'cold_drafts']
            }
        }
        
        # Try to match species name
        species_lower = species_name.lower()
        for key, profile in stress_profiles.items():
            if key in species_lower:
                return profile
        
        # Default profile
        return {
            'temperature_range': (16, 26),
            'humidity_range': (40, 70),
            'light_sensitivity': 'moderate',
            'cold_tolerance': 'moderate',
            'heat_tolerance': 'moderate',
            'drought_tolerance': 'moderate',
            'pest_susceptibility': ['common_pests'],
            'seasonal_vulnerabilities': ['temperature_fluctuations']
        }
    
    def _analyze_temperature_stress(
        self, 
        weather_forecast: Any, 
        stress_profile: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Analyze temperature-related stress risks."""
        temp_risks = []
        temp_range = stress_profile['temperature_range']
        min_temp, max_temp = temp_range
        
        if hasattr(weather_forecast, 'forecast') and weather_forecast.forecast:
            for i, day_forecast in enumerate(weather_forecast.forecast[:30]):  # Next 30 days
                day_temp = day_forecast.temperature
                risk_date = date.today() + timedelta(days=i)
                
                # Cold stress risk
                if day_temp < min_temp:
                    severity = 'high' if day_temp < min_temp - 5 else 'medium'
                    temp_risks.append({
                        'stress_type': 'cold_stress',
                        'risk_level': severity,
                        'risk_level_numeric': 3 if severity == 'high' else 2,
                        'onset_date': risk_date,
                        'severity_score': max(0, (min_temp - day_temp) / 10),
                        'description': f'Temperature ({day_temp}°C) below optimal range',
                        'prevention_actions': [
                            'Move plant away from cold windows',
                            'Provide additional insulation',
                            'Reduce watering frequency',
                            'Monitor for cold damage signs'
                        ],
                        'monitoring_frequency': 'daily'
                    })
                
                # Heat stress risk
                elif day_temp > max_temp:
                    severity = 'high' if day_temp > max_temp + 8 else 'medium'
                    temp_risks.append({
                        'stress_type': 'heat_stress',
                        'risk_level': severity,
                        'risk_level_numeric': 3 if severity == 'high' else 2,
                        'onset_date': risk_date,
                        'severity_score': max(0, (day_temp - max_temp) / 15),
                        'description': f'Temperature ({day_temp}°C) above optimal range',
                        'prevention_actions': [
                            'Increase watering frequency',
                            'Provide shade during peak hours',
                            'Increase humidity around plant',
                            'Ensure good air circulation'
                        ],
                        'monitoring_frequency': 'daily'
                    })
        
        return temp_risks
    
    def _analyze_humidity_stress(
        self, 
        weather_forecast: Any, 
        stress_profile: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Analyze humidity-related stress risks."""
        humidity_risks = []
        humidity_range = stress_profile['humidity_range']
        min_humidity, max_humidity = humidity_range
        
        if hasattr(weather_forecast, 'current') and weather_forecast.current:
            current_humidity = weather_forecast.current.humidity
            
            # Low humidity stress
            if current_humidity < min_humidity:
                severity = 'high' if current_humidity < min_humidity - 20 else 'medium'
                humidity_risks.append({
                    'stress_type': 'low_humidity_stress',
                    'risk_level': severity,
                    'risk_level_numeric': 3 if severity == 'high' else 2,
                    'onset_date': date.today(),
                    'severity_score': max(0, (min_humidity - current_humidity) / 50),
                    'description': f'Humidity ({current_humidity}%) below optimal range',
                    'prevention_actions': [
                        'Use humidity tray or humidifier',
                        'Group plants together',
                        'Mist plant regularly (if appropriate)',
                        'Place away from heating vents'
                    ],
                    'monitoring_frequency': 'weekly'
                })
            
            # High humidity stress
            elif current_humidity > max_humidity:
                severity = 'medium' if current_humidity > max_humidity + 15 else 'low'
                humidity_risks.append({
                    'stress_type': 'high_humidity_stress',
                    'risk_level': severity,
                    'risk_level_numeric': 2 if severity == 'medium' else 1,
                    'onset_date': date.today(),
                    'severity_score': max(0, (current_humidity - max_humidity) / 30),
                    'description': f'Humidity ({current_humidity}%) above optimal range',
                    'prevention_actions': [
                        'Improve air circulation',
                        'Reduce watering frequency',
                        'Check for fungal issues',
                        'Consider dehumidifier if severe'
                    ],
                    'monitoring_frequency': 'weekly'
                })
        
        return humidity_risks
    
    def _analyze_light_stress(
        self, 
        seasonal_transitions: List[Any], 
        stress_profile: Dict[str, Any], 
        location: Location
    ) -> List[Dict[str, Any]]:
        """Analyze light-related stress risks."""
        light_risks = []
        light_sensitivity = stress_profile['light_sensitivity']
        
        # Check for seasonal light changes
        current_month = date.today().month
        
        # Winter light stress (shorter days)
        if current_month in [11, 12, 1, 2]:
            if light_sensitivity in ['high', 'moderate']:
                light_risks.append({
                    'stress_type': 'insufficient_light',
                    'risk_level': 'medium',
                    'risk_level_numeric': 2,
                    'onset_date': date.today(),
                    'severity_score': 0.6 if light_sensitivity == 'high' else 0.4,
                    'description': 'Reduced daylight hours during winter months',
                    'prevention_actions': [
                        'Provide supplemental grow lights',
                        'Move plant to brighter location',
                        'Clean windows to maximize light',
                        'Rotate plant regularly for even exposure'
                    ],
                    'monitoring_frequency': 'weekly'
                })
        
        # Summer light stress (too intense)
        elif current_month in [6, 7, 8]:
            if light_sensitivity == 'low':  # Plants that prefer low light
                light_risks.append({
                    'stress_type': 'excessive_light',
                    'risk_level': 'medium',
                    'risk_level_numeric': 2,
                    'onset_date': date.today(),
                    'severity_score': 0.5,
                    'description': 'Intense summer sunlight may cause leaf burn',
                    'prevention_actions': [
                        'Provide shade during peak hours',
                        'Move away from direct sunlight',
                        'Use sheer curtains to filter light',
                        'Monitor for leaf scorch signs'
                    ],
                    'monitoring_frequency': 'weekly'
                })
        
        return light_risks
    
    def _analyze_transition_stress(
        self, 
        seasonal_transitions: List[Any], 
        stress_profile: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Analyze stress risks from seasonal transitions."""
        transition_risks = []
        
        for transition in seasonal_transitions:
            if hasattr(transition, 'transition_type') and hasattr(transition, 'transition_date'):
                transition_type = transition.transition_type
                transition_date = transition.transition_date
                
                # Check if this transition affects the species
                if any(vuln in transition_type for vuln in stress_profile['seasonal_vulnerabilities']):
                    severity = 'high' if 'shock' in transition_type else 'medium'
                    
                    transition_risks.append({
                        'stress_type': 'seasonal_transition_stress',
                        'risk_level': severity,
                        'risk_level_numeric': 3 if severity == 'high' else 2,
                        'onset_date': transition_date,
                        'severity_score': 0.7 if severity == 'high' else 0.5,
                        'description': f'Seasonal transition: {transition_type}',
                        'prevention_actions': [
                            'Gradually adjust care routine',
                            'Monitor plant closely during transition',
                            'Avoid major changes (repotting, fertilizing)',
                            'Provide stable microenvironment'
                        ],
                        'monitoring_frequency': 'daily'
                    })
        
        return transition_risks
    
    async def _analyze_seasonal_pest_risks(
        self, 
        location: Location, 
        species_name: str, 
        weather_forecast: Any
    ) -> List[Dict[str, Any]]:
        """Analyze seasonal pest and disease risks."""
        pest_risks = []
        
        try:
            # Get pest risk data from environmental service
            pest_data = await self.environmental_service.get_seasonal_pest_data(location, species_name)
            
            if pest_data and pest_data.overall_risk_score > 0.4:
                severity = 'high' if pest_data.overall_risk_score > 0.7 else 'medium'
                
                pest_risks.append({
                    'stress_type': 'pest_disease_risk',
                    'risk_level': severity,
                    'risk_level_numeric': 3 if severity == 'high' else 2,
                    'onset_date': date.today() + timedelta(days=7),
                    'severity_score': pest_data.overall_risk_score,
                    'description': f'Increased pest activity risk: {pest_data.primary_pests}',
                    'prevention_actions': [
                        'Inspect plant weekly for pest signs',
                        'Improve air circulation',
                        'Avoid overwatering',
                        'Consider preventive treatments',
                        'Quarantine new plants'
                    ],
                    'monitoring_frequency': 'weekly'
                })
                
        except Exception as e:
            logger.warning(f"Could not get pest risk data: {str(e)}")
            # Add general seasonal pest risk
            current_month = date.today().month
            if current_month in [4, 5, 6, 9, 10]:  # Spring and fall - higher pest activity
                pest_risks.append({
                    'stress_type': 'seasonal_pest_risk',
                    'risk_level': 'medium',
                    'risk_level_numeric': 2,
                    'onset_date': date.today(),
                    'severity_score': 0.5,
                    'description': 'Seasonal increase in pest activity',
                    'prevention_actions': [
                        'Regular plant inspection',
                        'Maintain good plant hygiene',
                        'Monitor humidity levels',
                        'Check for early pest signs'
                    ],
                    'monitoring_frequency': 'weekly'
                })
        
        return pest_risks
    
    async def predict_optimal_activity_timing(
        self,
        plant_id: UUID,
        species_name: str,
        location: Location,
        activities: List[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Predict optimal timing for plant activities like repotting, propagation, and purchases.
        
        This method analyzes seasonal patterns, plant growth cycles, and environmental
        conditions to recommend the best timing for various plant care activities.
        """
        if activities is None:
            activities = ['repotting', 'propagation', 'fertilizing', 'pruning', 'purchase']
        
        logger.info(f"Predicting optimal timing for activities: {activities}")
        
        try:
            # Get environmental data and seasonal patterns
            weather_forecast = await self.environmental_service.get_weather_data(location, 365)
            seasonal_transitions = await self.pattern_service.detect_seasonal_transitions(location)
            
            # Get species-specific activity preferences
            activity_profile = self._get_species_activity_profile(species_name)
            
            optimal_timings = []
            
            for activity in activities:
                timing_recommendations = self._calculate_optimal_timing(
                    activity, activity_profile, seasonal_transitions, weather_forecast, location
                )
                optimal_timings.extend(timing_recommendations)
            
            # Sort by priority and date
            optimal_timings.sort(key=lambda x: (x['priority_numeric'], x['optimal_start_date']))
            
            logger.info(f"Generated {len(optimal_timings)} activity timing recommendations")
            return optimal_timings
            
        except Exception as e:
            logger.error(f"Error predicting optimal activity timing: {str(e)}")
            return []
    
    def _get_species_activity_profile(self, species_name: str) -> Dict[str, Any]:
        """Get activity timing preferences for a plant species."""
        activity_profiles = {
            'ficus': {
                'repotting': {'season': 'spring', 'frequency_years': 2, 'temperature_min': 18},
                'propagation': {'season': 'spring_summer', 'success_rate': 0.8, 'temperature_min': 20},
                'pruning': {'season': 'spring', 'frequency_months': 6, 'avoid_dormancy': True},
                'fertilizing': {'season': 'spring_summer_fall', 'frequency_weeks': 4, 'dormancy_stop': True},
                'purchase': {'season': 'spring_summer', 'avoid_winter': True}
            },
            'monstera': {
                'repotting': {'season': 'spring', 'frequency_years': 2, 'temperature_min': 20},
                'propagation': {'season': 'spring_summer', 'success_rate': 0.9, 'temperature_min': 22},
                'pruning': {'season': 'spring_summer', 'frequency_months': 12, 'avoid_dormancy': True},
                'fertilizing': {'season': 'spring_summer', 'frequency_weeks': 2, 'dormancy_stop': True},
                'purchase': {'season': 'spring_summer', 'avoid_winter': True}
            },
            'echeveria': {
                'repotting': {'season': 'spring', 'frequency_years': 1, 'temperature_min': 15},
                'propagation': {'season': 'spring_summer_fall', 'success_rate': 0.9, 'temperature_min': 18},
                'pruning': {'season': 'any', 'frequency_months': 3, 'avoid_dormancy': False},
                'fertilizing': {'season': 'spring_summer', 'frequency_weeks': 8, 'dormancy_stop': True},
                'purchase': {'season': 'spring_summer_fall', 'avoid_winter': False}
            }
        }
        
        # Try to match species
        species_lower = species_name.lower()
        for key, profile in activity_profiles.items():
            if key in species_lower:
                return profile
        
        # Default profile
        return {
            'repotting': {'season': 'spring', 'frequency_years': 2, 'temperature_min': 16},
            'propagation': {'season': 'spring_summer', 'success_rate': 0.7, 'temperature_min': 18},
            'pruning': {'season': 'spring', 'frequency_months': 6, 'avoid_dormancy': True},
            'fertilizing': {'season': 'spring_summer', 'frequency_weeks': 6, 'dormancy_stop': True},
            'purchase': {'season': 'spring_summer', 'avoid_winter': True}
        }
    
    def _calculate_optimal_timing(
        self,
        activity: str,
        activity_profile: Dict[str, Any],
        seasonal_transitions: List[Any],
        weather_forecast: Any,
        location: Location
    ) -> List[Dict[str, Any]]:
        """Calculate optimal timing for a specific activity."""
        if activity not in activity_profile:
            return []
        
        activity_config = activity_profile[activity]
        optimal_periods = []
        
        # Get seasonal preferences
        preferred_seasons = activity_config['season'].split('_')
        
        # Calculate optimal periods for the next year
        current_date = date.today()
        
        for month in range(1, 13):
            season = self._get_season_from_month(month)
            
            if season in preferred_seasons:
                # Calculate period start and end
                period_start = date(current_date.year, month, 1)
                if month == 12:
                    period_end = date(current_date.year + 1, 1, 1) - timedelta(days=1)
                else:
                    period_end = date(current_date.year, month + 1, 1) - timedelta(days=1)
                
                # Adjust for current date
                if period_start < current_date:
                    if current_date.year == period_start.year:
                        period_start = date(current_date.year + 1, month, 1)
                        if month == 12:
                            period_end = date(current_date.year + 2, 1, 1) - timedelta(days=1)
                        else:
                            period_end = date(current_date.year + 1, month + 1, 1) - timedelta(days=1)
                
                # Check temperature requirements
                temp_suitable = self._check_temperature_suitability(
                    period_start, period_end, activity_config.get('temperature_min', 15), weather_forecast
                )
                
                if temp_suitable:
                    success_probability = self._calculate_activity_success_probability(
                        activity, activity_config, period_start, seasonal_transitions
                    )
                    
                    priority = self._calculate_activity_priority(activity, activity_config, period_start)
                    
                    optimal_periods.append({
                        'activity_type': activity,
                        'optimal_start_date': period_start,
                        'optimal_end_date': period_end,
                        'success_probability': success_probability,
                        'priority': priority,
                        'priority_numeric': self._priority_to_numeric(priority),
                        'required_conditions': self._get_activity_conditions(activity, activity_config),
                        'preparation_steps': self._get_preparation_steps(activity),
                        'expected_duration': self._get_activity_duration(activity),
                        'confidence_score': 0.8
                    })
        
        return optimal_periods
    
    def _get_season_from_month(self, month: int) -> str:
        """Get season name from month number."""
        if month in [3, 4, 5]:
            return 'spring'
        elif month in [6, 7, 8]:
            return 'summer'
        elif month in [9, 10, 11]:
            return 'fall'
        else:
            return 'winter'
    
    def _check_temperature_suitability(
        self, 
        start_date: date, 
        end_date: date, 
        min_temp: float, 
        weather_forecast: Any
    ) -> bool:
        """Check if temperature conditions are suitable for the activity."""
        # For now, use seasonal averages since detailed long-term forecasts aren't available
        season = self._get_season_from_month(start_date.month)
        
        seasonal_temps = {
            'spring': 18,
            'summer': 25,
            'fall': 16,
            'winter': 10
        }
        
        avg_temp = seasonal_temps.get(season, 15)
        return avg_temp >= min_temp
    
    def _calculate_activity_success_probability(
        self, 
        activity: str, 
        activity_config: Dict[str, Any], 
        start_date: date, 
        seasonal_transitions: List[Any]
    ) -> float:
        """Calculate success probability for an activity at a given time."""
        base_probability = activity_config.get('success_rate', 0.7)
        
        # Adjust based on seasonal stability
        season = self._get_season_from_month(start_date.month)
        
        # Spring and early summer are generally better for most activities
        if season in ['spring', 'summer']:
            base_probability *= 1.1
        elif season == 'winter':
            base_probability *= 0.8
        
        # Check for seasonal transitions that might affect success
        for transition in seasonal_transitions:
            if hasattr(transition, 'transition_date'):
                days_diff = abs((start_date - transition.transition_date).days)
                if days_diff < 14:  # Within 2 weeks of transition
                    base_probability *= 0.9  # Slightly reduce probability
        
        return min(0.95, max(0.3, base_probability))
    
    def _calculate_activity_priority(self, activity: str, activity_config: Dict[str, Any], start_date: date) -> str:
        """Calculate priority level for an activity."""
        # Repotting is high priority if overdue
        if activity == 'repotting':
            return 'high'
        
        # Propagation is medium priority during optimal seasons
        elif activity == 'propagation':
            season = self._get_season_from_month(start_date.month)
            return 'medium' if season in ['spring', 'summer'] else 'low'
        
        # Fertilizing is high priority during growing season
        elif activity == 'fertilizing':
            season = self._get_season_from_month(start_date.month)
            return 'high' if season in ['spring', 'summer'] else 'low'
        
        # Default to medium priority
        return 'medium'
    
    def _priority_to_numeric(self, priority: str) -> int:
        """Convert priority string to numeric value for sorting."""
        priority_map = {'high': 1, 'medium': 2, 'low': 3}
        return priority_map.get(priority, 2)
    
    def _get_activity_conditions(self, activity: str, activity_config: Dict[str, Any]) -> List[str]:
        """Get required conditions for an activity."""
        conditions_map = {
            'repotting': [
                'Plant showing signs of being rootbound',
                f'Temperature above {activity_config.get("temperature_min", 15)}°C',
                'Plant not in dormancy period',
                'No recent stress events'
            ],
            'propagation': [
                'Healthy parent plant with new growth',
                f'Temperature above {activity_config.get("temperature_min", 18)}°C',
                'High humidity environment available',
                'Adequate light for new growth'
            ],
            'pruning': [
                'Plant in active growth phase',
                'Clean, sharp pruning tools',
                'No signs of disease or pest issues',
                'Stable environmental conditions'
            ],
            'fertilizing': [
                'Plant in active growth phase',
                'Soil not waterlogged',
                'No signs of fertilizer burn',
                'Appropriate fertilizer type available'
            ],
            'purchase': [
                'Stable home environment ready',
                'Quarantine space available',
                'Appropriate care knowledge',
                'Seasonal conditions favorable'
            ]
        }
        
        return conditions_map.get(activity, ['Favorable environmental conditions'])
    
    def _get_preparation_steps(self, activity: str) -> List[str]:
        """Get preparation steps for an activity."""
        steps_map = {
            'repotting': [
                'Prepare new pot and fresh soil',
                'Water plant 24 hours before repotting',
                'Gather necessary tools',
                'Choose overcast day to reduce stress'
            ],
            'propagation': [
                'Identify healthy growth points',
                'Prepare propagation medium',
                'Sterilize cutting tools',
                'Set up humidity chamber if needed'
            ],
            'pruning': [
                'Clean and sharpen pruning tools',
                'Research proper pruning techniques',
                'Plan cuts to maintain plant shape',
                'Prepare wound sealant if needed'
            ],
            'fertilizing': [
                'Choose appropriate fertilizer type',
                'Check soil moisture levels',
                'Read fertilizer instructions carefully',
                'Plan regular feeding schedule'
            ],
            'purchase': [
                'Research plant care requirements',
                'Prepare appropriate location',
                'Set up quarantine area',
                'Gather necessary care supplies'
            ]
        }
        
        return steps_map.get(activity, ['Research activity requirements', 'Prepare necessary materials'])
    
    def _get_activity_duration(self, activity: str) -> str:
        """Get expected duration for an activity."""
        duration_map = {
            'repotting': '1-2 hours',
            'propagation': '30 minutes setup, 2-8 weeks for results',
            'pruning': '30 minutes - 1 hour',
            'fertilizing': '15 minutes',
            'purchase': 'Ongoing research and preparation'
        }
        
        return duration_map.get(activity, 'Variable')
    
    def _encode_season(self, month: int) -> int:
        """Encode season as integer (0=spring, 1=summer, 2=autumn, 3=winter)."""
        if month in [3, 4, 5]:
            return 0  # Spring
        elif month in [6, 7, 8]:
            return 1  # Summer
        elif month in [9, 10, 11]:
            return 2  # Autumn
        else:
            return 3  # Winter
        """Calculate overall prediction confidence."""
        # Base confidence
        confidence = 0.7
        
        # Adjust based on number of adjustments (more adjustments = less confidence)
        if len(care_adjustments) > 3:
            confidence -= 0.1
        
        # Adjust based on risk factors
        high_risk_count = sum(1 for rf in risk_factors if rf.risk_level == "high")
        confidence -= high_risk_count * 0.05
        
        # Adjust based on stress likelihood
        confidence -= growth_forecast.stress_likelihood * 0.1
        
        return max(0.5, min(0.95, confidence))
    
    async def get_seasonal_care_adjustments(
        self, 
        plant_id: UUID, 
        current_season: str
    ) -> List[CareAdjustment]:
        """Get seasonal care adjustments for a specific plant and season."""
        prediction = await self.predict_seasonal_behavior(plant_id, 30)
        return prediction.care_adjustments
    
    async def save_prediction_to_database(
        self, 
        prediction: SeasonalPredictionResult
    ) -> UUID:
        """Save prediction result to database."""
        async with get_db() as db:
            db_prediction = SeasonalPrediction(
                plant_id=prediction.plant_id,
                prediction_period_start=prediction.prediction_period[0],
                prediction_period_end=prediction.prediction_period[1],
                growth_forecast={
                    "expected_growth_rate": prediction.growth_forecast.expected_growth_rate,
                    "size_projections": prediction.growth_forecast.size_projections,
                    "flowering_predictions": prediction.growth_forecast.flowering_predictions,
                    "dormancy_periods": prediction.growth_forecast.dormancy_periods,
                    "stress_likelihood": prediction.growth_forecast.stress_likelihood
                },
                care_adjustments=[
                    {
                        "care_type": adj.care_type,
                        "adjustment_type": adj.adjustment_type,
                        "current_value": adj.current_value,
                        "recommended_value": adj.recommended_value,
                        "adjustment_percentage": adj.adjustment_percentage,
                        "reason": adj.reason,
                        "confidence": adj.confidence,
                        "effective_date": adj.effective_date.isoformat(),
                        "duration_days": adj.duration_days
                    }
                    for adj in prediction.care_adjustments
                ],
                risk_factors=[
                    {
                        "risk_type": rf.risk_type,
                        "risk_level": rf.risk_level,
                        "probability": rf.probability,
                        "impact_severity": rf.impact_severity,
                        "onset_date": rf.onset_date.isoformat() if rf.onset_date else None,
                        "mitigation_actions": rf.mitigation_actions,
                        "monitoring_frequency": rf.monitoring_frequency
                    }
                    for rf in prediction.risk_factors
                ],
                optimal_activities=[
                    {
                        "activity_type": act.activity_type,
                        "optimal_date_range": [
                            act.optimal_date_range[0].isoformat(),
                            act.optimal_date_range[1].isoformat()
                        ],
                        "priority": act.priority,
                        "success_probability": act.success_probability,
                        "required_conditions": act.required_conditions,
                        "preparation_steps": act.preparation_steps
                    }
                    for act in prediction.optimal_activities
                ],
                confidence_score=prediction.confidence_score,
                model_version=prediction.model_version,
                environmental_factors=prediction.environmental_factors
            )
            
            db.add(db_prediction)
            await db.commit()
            await db.refresh(db_prediction)
            
            return db_prediction.id 
   
    def _get_water_adjustment_reason(self, adjustment: float, seasonal_transitions: List[Any]) -> str:
        """Get reason for water adjustment."""
        if adjustment > 0:
            return "Increased watering needed due to higher temperatures and lower humidity"
        else:
            return "Reduced watering needed due to cooler temperatures and higher humidity"
    
    def _get_fertilizer_adjustment_reason(self, adjustment: float, seasonal_transitions: List[Any]) -> str:
        """Get reason for fertilizer adjustment."""
        if adjustment > 0:
            return "Increased fertilization recommended for active growing season"
        else:
            return "Reduced fertilization recommended for dormant season"
    
    def _get_light_adjustment_reason(self, adjustment: float, seasonal_transitions: List[Any]) -> str:
        """Get reason for light adjustment."""
        if adjustment > 0:
            return "Additional artificial light needed due to shorter daylight hours"
        else:
            return "Reduced artificial light needed due to longer daylight hours"
    
    async def predict_growth_phases(
        self, 
        plant_species: str, 
        environmental_conditions: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """
        Enhanced prediction of growth phases based on plant species and environmental conditions.
        
        Args:
            plant_species: Scientific name of the plant species
            environmental_conditions: Current environmental conditions
            
        Returns:
            List of predicted growth phases with confidence scores
        """
        logger.info(f"Predicting growth phases for species {plant_species}")
        
        # Extract environmental features
        temperature = environmental_conditions.get('temperature', 20)
        humidity = environmental_conditions.get('humidity', 60)
        daylight_hours = environmental_conditions.get('daylight_hours', 12)
        precipitation = environmental_conditions.get('precipitation', 1)
        
        # Encode season and species
        current_month = date.today().month
        season_encoded = self._encode_season(current_month)
        species_encoded = hash(plant_species) % 100
        
        # Prepare base features for growth prediction
        base_features = [
            temperature, humidity, daylight_hours, precipitation,
            365,  # Default plant age
            season_encoded, species_encoded
        ]
        
        # Apply polynomial features if available
        if self.polynomial_features:
            try:
                features_poly = self.polynomial_features.transform([base_features])
                features_scaled = self.feature_scaler.transform(features_poly)
            except Exception as e:
                logger.warning(f"Failed to apply polynomial features: {str(e)}")
                features_scaled = self.feature_scaler.transform([base_features])
        else:
            features_scaled = self.feature_scaler.transform([base_features])
        
        # Predict growth rate using enhanced model
        growth_rate = self.growth_model.predict(features_scaled)[0]
        growth_rate = max(0, min(2.5, growth_rate))
        
        # Predict growth phase with confidence
        growth_phase, phase_confidence = self.predict_growth_phase_with_confidence(base_features)
        
        # Predict species behavior pattern
        species_characteristics = {
            'temperature': temperature,
            'humidity': humidity,
            'daylight_hours': daylight_hours,
            'growth_rate': growth_rate,
            'water_adjustment': 0,
            'fertilizer_adjustment': 0,
            'risk_score': 0.3
        }
        behavior_pattern = self.predict_species_behavior_pattern(species_characteristics)
        
        # Generate enhanced growth phases based on predicted data
        growth_phases = []
        
        # Create growth phases for the next 90 days
        for week in range(0, 90, 7):
            current_date = date.today() + timedelta(days=week)
            
            # Adjust environmental conditions for future weeks (simplified)
            future_temp = temperature + np.random.normal(0, 2)  # Temperature variation
            future_humidity = humidity + np.random.normal(0, 5)  # Humidity variation
            
            # Calculate growth metrics for this period
            weekly_growth = growth_rate * (1 + 0.1 * np.sin(week * np.pi / 45))  # Seasonal variation
            
            # Determine care requirements based on species behavior pattern
            care_requirements = self._get_care_requirements_for_behavior_pattern(
                behavior_pattern, growth_phase, future_temp, future_humidity
            )
            
            growth_phases.append({
                "date": current_date,
                "phase": growth_phase,
                "growth_rate": weekly_growth,
                "duration_days": 7,
                "care_requirements": care_requirements,
                "confidence": phase_confidence,
                "environmental_factors": {
                    "temperature": future_temp,
                    "humidity": future_humidity,
                    "daylight_hours": daylight_hours
                }
            })
        
        return growth_phases
    
    def _get_care_requirements_for_behavior_pattern(
        self, 
        behavior_pattern: int, 
        growth_phase: str, 
        temperature: float, 
        humidity: float
    ) -> List[str]:
        """Get care requirements based on behavior pattern and growth phase."""
        requirements = []
        
        # Base requirements by growth phase
        if growth_phase == "rapid":
            requirements.extend([
                "Increase watering frequency",
                "Apply balanced fertilizer weekly",
                "Ensure adequate light exposure"
            ])
        elif growth_phase == "active":
            requirements.extend([
                "Maintain regular watering schedule",
                "Fertilize bi-weekly",
                "Monitor for growth changes"
            ])
        elif growth_phase == "slow":
            requirements.extend([
                "Reduce watering frequency",
                "Fertilize monthly",
                "Check for stress indicators"
            ])
        else:  # dormant
            requirements.extend([
                "Minimal watering",
                "Stop fertilizing",
                "Reduce light if needed"
            ])
        
        # Behavior pattern specific adjustments
        if behavior_pattern == 0:  # High maintenance pattern
            requirements.append("Monitor daily for changes")
        elif behavior_pattern == 1:  # Drought tolerant pattern
            requirements.append("Allow soil to dry between waterings")
        elif behavior_pattern == 2:  # High humidity pattern
            requirements.append("Maintain high humidity levels")
        elif behavior_pattern == 3:  # Temperature sensitive pattern
            requirements.append("Keep temperature stable")
        elif behavior_pattern == 4:  # Light sensitive pattern
            requirements.append("Adjust light exposure carefully")
        
        # Environmental adjustments
        if temperature > 25:
            requirements.append("Increase watering due to high temperature")
        elif temperature < 15:
            requirements.append("Reduce watering due to low temperature")
        
        if humidity < 40:
            requirements.append("Increase humidity around plant")
        elif humidity > 80:
            requirements.append("Improve air circulation")
        
        return requirements
        growth_phases = []
        
        if growth_rate > 1.2:
            growth_phases.append({
                "phase": "rapid_growth",
                "duration_days": 30,
                "characteristics": ["Active cell division", "Increased nutrient uptake", "Visible size increase"],
                "care_requirements": ["Frequent watering", "Regular fertilization", "Optimal light exposure"]
            })
        elif growth_rate > 0.7:
            growth_phases.append({
                "phase": "active_growth",
                "duration_days": 45,
                "characteristics": ["Steady development", "New leaf formation", "Root expansion"],
                "care_requirements": ["Regular watering", "Bi-weekly fertilization", "Adequate light"]
            })
        elif growth_rate > 0.3:
            growth_phases.append({
                "phase": "slow_growth",
                "duration_days": 60,
                "characteristics": ["Minimal visible changes", "Maintenance mode", "Energy conservation"],
                "care_requirements": ["Reduced watering", "Monthly fertilization", "Moderate light"]
            })
        else:
            growth_phases.append({
                "phase": "dormancy",
                "duration_days": 90,
                "characteristics": ["Minimal metabolic activity", "No visible growth", "Rest period"],
                "care_requirements": ["Minimal watering", "No fertilization", "Reduced light"]
            })
        
        return growth_phases
    
    def _encode_season(self, month: int) -> int:
        """Encode month to season number."""
        if month in [3, 4, 5]:
            return 0  # Spring
        elif month in [6, 7, 8]:
            return 1  # Summer
        elif month in [9, 10, 11]:
            return 2  # Autumn
        else:
            return 3  # Winter
    
    async def retrain_models(self, training_data: Optional[Dict[str, Any]] = None) -> bool:
        """
        Retrain ML models with new data.
        
        Args:
            training_data: Optional new training data
            
        Returns:
            True if retraining was successful
        """
        try:
            logger.info("Retraining seasonal AI models")
            
            if training_data:
                # Use provided training data
                df = pd.DataFrame(training_data)
            else:
                # Generate new synthetic training data
                df = self._generate_synthetic_training_data()
            
            # Prepare features and targets
            features = df[['temperature', 'humidity', 'daylight_hours', 'precipitation',
                          'plant_age_days', 'season_encoded', 'species_encoded']]
            
            # Retrain feature scaler
            self.feature_scaler = StandardScaler()
            features_scaled = self.feature_scaler.fit_transform(features)
            
            # Retrain growth model
            growth_targets = df['growth_rate']
            self.growth_model = RandomForestRegressor(n_estimators=100, random_state=42)
            self.growth_model.fit(features_scaled, growth_targets)
            
            # Retrain care adjustment model
            care_targets = df[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
            self.care_model = RandomForestRegressor(n_estimators=100, random_state=42)
            self.care_model.fit(features_scaled, care_targets)
            
            # Retrain risk assessment model
            risk_targets = df['risk_score']
            self.risk_model = RandomForestRegressor(n_estimators=100, random_state=42)
            self.risk_model.fit(features_scaled, risk_targets)
            
            # Save retrained models
            joblib.dump(self.growth_model, self.growth_model_path)
            joblib.dump(self.care_model, self.care_model_path)
            joblib.dump(self.risk_model, self.risk_model_path)
            joblib.dump(self.feature_scaler, self.scaler_path)
            
            logger.info("Successfully retrained seasonal AI models")
            return True
            
        except Exception as e:
            logger.error(f"Failed to retrain models: {str(e)}")
            return False
    
    def get_model_performance_metrics(self) -> Dict[str, Any]:
        """
        Get performance metrics for the current models.
        
        Returns:
            Dictionary containing model performance metrics
        """
        try:
            # Generate test data
            test_data = self._generate_synthetic_training_data()
            features = test_data[['temperature', 'humidity', 'daylight_hours', 'precipitation',
                                'plant_age_days', 'season_encoded', 'species_encoded']]
            features_scaled = self.feature_scaler.transform(features)
            
            # Growth model metrics
            growth_true = test_data['growth_rate']
            growth_pred = self.growth_model.predict(features_scaled)
            growth_mse = mean_squared_error(growth_true, growth_pred)
            
            # Care model metrics
            care_true = test_data[['water_adjustment', 'fertilizer_adjustment', 'light_adjustment']]
            care_pred = self.care_model.predict(features_scaled)
            care_mse = mean_squared_error(care_true, care_pred)
            
            # Risk model metrics
            risk_true = test_data['risk_score']
            risk_pred = self.risk_model.predict(features_scaled)
            risk_mse = mean_squared_error(risk_true, risk_pred)
            
            return {
                "model_version": self.model_version,
                "growth_model_mse": float(growth_mse),
                "care_model_mse": float(care_mse),
                "risk_model_mse": float(risk_mse),
                "feature_count": len(features.columns),
                "training_samples": len(test_data),
                "last_updated": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Failed to calculate model metrics: {str(e)}")
            return {
                "error": str(e),
                "model_version": self.model_version
            }
    
    async def create_care_recommendation_engine(
        self, 
        plant_id: UUID, 
        environmental_factors: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Create comprehensive care recommendations with confidence scoring.
        
        Args:
            plant_id: UUID of the plant
            environmental_factors: Current environmental conditions
            
        Returns:
            Dictionary containing care recommendations with confidence scores
        """
        logger.info(f"Creating care recommendation engine for plant {plant_id}")
        
        try:
            # Get seasonal prediction
            prediction = await self.predict_seasonal_behavior(plant_id, 30)
            
            # Calculate confidence scores for each recommendation type
            recommendations = {
                "watering": {
                    "recommendations": [],
                    "overall_confidence": 0.0
                },
                "fertilizing": {
                    "recommendations": [],
                    "overall_confidence": 0.0
                },
                "lighting": {
                    "recommendations": [],
                    "overall_confidence": 0.0
                },
                "environmental": {
                    "recommendations": [],
                    "overall_confidence": 0.0
                }
            }
            
            # Process care adjustments
            for adjustment in prediction.care_adjustments:
                category = adjustment.care_type
                if category == "watering":
                    recommendations["watering"]["recommendations"].append({
                        "action": adjustment.adjustment_type,
                        "current_value": adjustment.current_value,
                        "recommended_value": adjustment.recommended_value,
                        "adjustment_percentage": adjustment.adjustment_percentage,
                        "reason": adjustment.reason,
                        "confidence": adjustment.confidence,
                        "effective_date": adjustment.effective_date.isoformat(),
                        "duration_days": adjustment.duration_days
                    })
                    recommendations["watering"]["overall_confidence"] = max(
                        recommendations["watering"]["overall_confidence"], 
                        adjustment.confidence
                    )
                elif category == "fertilizing":
                    recommendations["fertilizing"]["recommendations"].append({
                        "action": adjustment.adjustment_type,
                        "adjustment_percentage": adjustment.adjustment_percentage,
                        "reason": adjustment.reason,
                        "confidence": adjustment.confidence,
                        "effective_date": adjustment.effective_date.isoformat(),
                        "duration_days": adjustment.duration_days
                    })
                    recommendations["fertilizing"]["overall_confidence"] = max(
                        recommendations["fertilizing"]["overall_confidence"], 
                        adjustment.confidence
                    )
                elif category == "light":
                    recommendations["lighting"]["recommendations"].append({
                        "action": adjustment.adjustment_type,
                        "adjustment_percentage": adjustment.adjustment_percentage,
                        "reason": adjustment.reason,
                        "confidence": adjustment.confidence,
                        "effective_date": adjustment.effective_date.isoformat(),
                        "duration_days": adjustment.duration_days
                    })
                    recommendations["lighting"]["overall_confidence"] = max(
                        recommendations["lighting"]["overall_confidence"], 
                        adjustment.confidence
                    )
            
            # Add environmental recommendations based on risk factors
            for risk_factor in prediction.risk_factors:
                for action in risk_factor.mitigation_actions:
                    recommendations["environmental"]["recommendations"].append({
                        "action": action,
                        "risk_type": risk_factor.risk_type,
                        "risk_level": risk_factor.risk_level,
                        "probability": risk_factor.probability,
                        "monitoring_frequency": risk_factor.monitoring_frequency,
                        "confidence": 0.8  # Default confidence for risk mitigation
                    })
                recommendations["environmental"]["overall_confidence"] = max(
                    recommendations["environmental"]["overall_confidence"], 
                    0.8
                )
            
            # Add growth phase recommendations
            growth_phases = await self.predict_growth_phases(
                "default_species",  # This should be retrieved from plant data
                environmental_factors
            )
            
            for phase in growth_phases:
                for requirement in phase["care_requirements"]:
                    category = "watering" if "water" in requirement.lower() else \
                              "fertilizing" if "fertil" in requirement.lower() else \
                              "lighting" if "light" in requirement.lower() else "environmental"
                    
                    recommendations[category]["recommendations"].append({
                        "action": requirement,
                        "growth_phase": phase["phase"],
                        "duration_days": phase["duration_days"],
                        "confidence": 0.75  # Default confidence for growth phase recommendations
                    })
            
            # Calculate overall system confidence
            all_confidences = [
                rec["overall_confidence"] for rec in recommendations.values() 
                if rec["overall_confidence"] > 0
            ]
            overall_confidence = sum(all_confidences) / len(all_confidences) if all_confidences else 0.5
            
            return {
                "plant_id": str(plant_id),
                "recommendations": recommendations,
                "overall_confidence": overall_confidence,
                "prediction_period": {
                    "start": prediction.prediction_period[0].isoformat(),
                    "end": prediction.prediction_period[1].isoformat()
                },
                "environmental_factors": environmental_factors,
                "model_version": self.model_version,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Failed to create care recommendation engine: {str(e)}")
            return {
                "plant_id": str(plant_id),
                "error": str(e),
                "recommendations": {},
                "overall_confidence": 0.0
            }