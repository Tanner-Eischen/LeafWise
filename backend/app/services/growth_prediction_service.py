"""
Growth Prediction Service for LeafWise Platform

This service provides predictive analytics for plant growth including:
- Future growth trend predictions using statistical models
- Growth milestone forecasting
- Confidence scoring for predictions
- Seasonal growth projections

Focused on predictive modeling and future growth insights.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import numpy as np
from scipy import stats
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import r2_score
import json

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant


class GrowthPredictionService:
    """Service for predicting future plant growth using statistical models."""
    
    def __init__(self):
        pass
    
    async def predict_growth_trends(
        self,
        db: Session,
        plant_id: str,
        prediction_days: int = 30,
        model_type: str = "linear"
    ) -> Dict[str, Any]:
        """
        Predict future growth trends for a plant.
        
        Args:
            db: Database session
            plant_id: ID of the plant to analyze
            prediction_days: Number of days to predict into the future
            model_type: Type of prediction model (linear, polynomial, seasonal)
            
        Returns:
            Dictionary containing prediction results
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get historical growth data
        historical_data = self.collect_historical_data(db, plant_id)
        
        if len(historical_data) < 5:
            return self._insufficient_prediction_data_response(plant_id, len(historical_data))
        
        # Prepare data for modeling
        X, y = self.prepare_modeling_data(historical_data)
        
        # Generate predictions based on model type
        predictions = None
        model_metrics = None
        
        if model_type == "linear":
            predictions, model_metrics = self.linear_prediction(X, y, prediction_days)
        elif model_type == "polynomial":
            predictions, model_metrics = self.polynomial_prediction(X, y, prediction_days)
        elif model_type == "seasonal":
            predictions, model_metrics = self.seasonal_prediction(X, y, prediction_days, historical_data)
        else:
            raise ValueError(f"Unsupported model type: {model_type}")
        
        # Calculate confidence intervals
        confidence_intervals = self.calculate_confidence_intervals(predictions, model_metrics)
        
        # Generate milestone predictions
        milestone_predictions = self.predict_growth_milestones(predictions, historical_data)
        
        return {
            "plant_id": plant_id,
            "model_type": model_type,
            "prediction_period_days": prediction_days,
            "historical_data_points": len(historical_data),
            "model_performance": model_metrics,
            "predictions": predictions,
            "confidence_intervals": confidence_intervals,
            "milestone_predictions": milestone_predictions,
            "prediction_confidence": self.calculate_overall_confidence(model_metrics)
        }
    
    def collect_historical_data(self, db: Session, plant_id: str) -> List[Dict[str, Any]]:
        """
        Collect historical growth data for modeling.
        
        Args:
            db: Database session
            plant_id: ID of the plant
            
        Returns:
            List of historical data points
        """
        # Get timelapse sessions for the past 90 days
        start_date = datetime.utcnow() - timedelta(days=90)
        sessions = db.query(TimelapseSession).filter(
            TimelapseSession.plant_id == plant_id,
            TimelapseSession.created_at >= start_date
        ).all()
        
        historical_data = []
        for session in sessions:
            photos = db.query(GrowthPhoto).filter(
                GrowthPhoto.timelapse_session_id == session.id
            ).order_by(GrowthPhoto.captured_at).all()
            
            for photo in photos:
                days_since_start = (photo.captured_at - start_date).days
                historical_data.append({
                    "days_since_start": days_since_start,
                    "height_cm": photo.height_cm or 0,
                    "leaf_count": photo.leaf_count or 0,
                    "health_score": photo.health_score or 0,
                    "date": photo.captured_at
                })
        
        return sorted(historical_data, key=lambda x: x["days_since_start"])
    
    def prepare_modeling_data(self, historical_data: List[Dict[str, Any]]) -> Tuple[np.ndarray, np.ndarray]:
        """
        Prepare data for machine learning models.
        
        Args:
            historical_data: Historical growth data
            
        Returns:
            Tuple of (X, y) arrays for modeling
        """
        X = np.array([[point["days_since_start"]] for point in historical_data])
        y = np.array([point["height_cm"] for point in historical_data])
        
        return X, y
    
    def linear_prediction(
        self,
        X: np.ndarray,
        y: np.ndarray,
        prediction_days: int
    ) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
        """
        Generate linear growth predictions.
        
        Args:
            X: Input features (days)
            y: Target values (height)
            prediction_days: Number of days to predict
            
        Returns:
            Tuple of (predictions, model_metrics)
        """
        # Fit linear regression model
        model = LinearRegression()
        model.fit(X, y)
        
        # Calculate model performance
        y_pred_train = model.predict(X)
        r2 = r2_score(y, y_pred_train)
        mse = np.mean((y - y_pred_train) ** 2)
        
        # Generate future predictions
        last_day = X[-1][0] if len(X) > 0 else 0
        future_days = np.array([[last_day + i] for i in range(1, prediction_days + 1)])
        future_predictions = model.predict(future_days)
        
        predictions = []
        for i, pred_height in enumerate(future_predictions):
            prediction_date = datetime.utcnow() + timedelta(days=i + 1)
            predictions.append({
                "date": prediction_date.isoformat(),
                "predicted_height_cm": round(max(0, pred_height), 2),
                "days_ahead": i + 1
            })
        
        model_metrics = {
            "model_type": "linear",
            "r2_score": round(r2, 3),
            "mse": round(mse, 3),
            "growth_rate_cm_per_day": round(model.coef_[0], 4)
        }
        
        return predictions, model_metrics
    
    def polynomial_prediction(
        self,
        X: np.ndarray,
        y: np.ndarray,
        prediction_days: int,
        degree: int = 2
    ) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
        """
        Generate polynomial growth predictions.
        
        Args:
            X: Input features (days)
            y: Target values (height)
            prediction_days: Number of days to predict
            degree: Polynomial degree
            
        Returns:
            Tuple of (predictions, model_metrics)
        """
        # Create polynomial features
        poly_features = PolynomialFeatures(degree=degree)
        X_poly = poly_features.fit_transform(X)
        
        # Fit polynomial regression model
        model = LinearRegression()
        model.fit(X_poly, y)
        
        # Calculate model performance
        y_pred_train = model.predict(X_poly)
        r2 = r2_score(y, y_pred_train)
        mse = np.mean((y - y_pred_train) ** 2)
        
        # Generate future predictions
        last_day = X[-1][0] if len(X) > 0 else 0
        future_days = np.array([[last_day + i] for i in range(1, prediction_days + 1)])
        future_days_poly = poly_features.transform(future_days)
        future_predictions = model.predict(future_days_poly)
        
        predictions = []
        for i, pred_height in enumerate(future_predictions):
            prediction_date = datetime.utcnow() + timedelta(days=i + 1)
            predictions.append({
                "date": prediction_date.isoformat(),
                "predicted_height_cm": round(max(0, pred_height), 2),
                "days_ahead": i + 1
            })
        
        model_metrics = {
            "model_type": f"polynomial_degree_{degree}",
            "r2_score": round(r2, 3),
            "mse": round(mse, 3),
            "polynomial_degree": degree
        }
        
        return predictions, model_metrics
    
    def seasonal_prediction(
        self,
        X: np.ndarray,
        y: np.ndarray,
        prediction_days: int,
        historical_data: List[Dict[str, Any]]
    ) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
        """
        Generate seasonal growth predictions considering seasonal patterns.
        
        Args:
            X: Input features (days)
            y: Target values (height)
            prediction_days: Number of days to predict
            historical_data: Historical data with dates
            
        Returns:
            Tuple of (predictions, model_metrics)
        """
        # Extract seasonal features
        seasonal_features = []
        for data_point in historical_data:
            month = data_point["date"].month
            day_of_year = data_point["date"].timetuple().tm_yday
            seasonal_features.append([
                data_point["days_since_start"],
                np.sin(2 * np.pi * day_of_year / 365),  # Seasonal sine component
                np.cos(2 * np.pi * day_of_year / 365)   # Seasonal cosine component
            ])
        
        X_seasonal = np.array(seasonal_features)
        
        # Fit seasonal model
        model = LinearRegression()
        model.fit(X_seasonal, y)
        
        # Calculate model performance
        y_pred_train = model.predict(X_seasonal)
        r2 = r2_score(y, y_pred_train)
        mse = np.mean((y - y_pred_train) ** 2)
        
        # Generate future predictions with seasonal components
        predictions = []
        last_day = X[-1][0] if len(X) > 0 else 0
        
        for i in range(1, prediction_days + 1):
            prediction_date = datetime.utcnow() + timedelta(days=i)
            day_of_year = prediction_date.timetuple().tm_yday
            
            future_features = np.array([[
                last_day + i,
                np.sin(2 * np.pi * day_of_year / 365),
                np.cos(2 * np.pi * day_of_year / 365)
            ]])
            
            pred_height = model.predict(future_features)[0]
            
            predictions.append({
                "date": prediction_date.isoformat(),
                "predicted_height_cm": round(max(0, pred_height), 2),
                "days_ahead": i,
                "seasonal_factor": round(np.sin(2 * np.pi * day_of_year / 365), 3)
            })
        
        model_metrics = {
            "model_type": "seasonal",
            "r2_score": round(r2, 3),
            "mse": round(mse, 3),
            "seasonal_amplitude": round(abs(model.coef_[1]), 4)
        }
        
        return predictions, model_metrics
    
    def calculate_confidence_intervals(
        self,
        predictions: List[Dict[str, Any]],
        model_metrics: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Calculate confidence intervals for predictions."""
        confidence_intervals = []
        base_uncertainty = model_metrics.get("mse", 1.0) ** 0.5
        
        for i, prediction in enumerate(predictions):
            # Uncertainty increases with prediction distance
            uncertainty = base_uncertainty * (1 + 0.1 * i)
            
            lower_bound = max(0, prediction["predicted_height_cm"] - 1.96 * uncertainty)
            upper_bound = prediction["predicted_height_cm"] + 1.96 * uncertainty
            
            confidence_intervals.append({
                "date": prediction["date"],
                "lower_95": round(lower_bound, 2),
                "upper_95": round(upper_bound, 2),
                "uncertainty": round(uncertainty, 2)
            })
        
        return confidence_intervals
    
    def predict_growth_milestones(
        self,
        predictions: List[Dict[str, Any]],
        historical_data: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Predict when growth milestones will be reached."""
        if not historical_data:
            return []
        
        current_height = max(point["height_cm"] for point in historical_data)
        milestones = []
        
        # Define milestone targets
        milestone_targets = [
            current_height + 5,   # +5cm
            current_height + 10,  # +10cm
            current_height + 20   # +20cm
        ]
        
        for target_height in milestone_targets:
            for prediction in predictions:
                if prediction["predicted_height_cm"] >= target_height:
                    milestones.append({
                        "milestone_type": f"height_{int(target_height)}cm",
                        "target_height_cm": target_height,
                        "predicted_date": prediction["date"],
                        "days_to_milestone": prediction["days_ahead"],
                        "confidence": "medium"  # Based on model performance
                    })
                    break
        
        return milestones
    
    def calculate_overall_confidence(self, model_metrics: Dict[str, Any]) -> str:
        """Calculate overall confidence level for predictions."""
        r2_score = model_metrics.get("r2_score", 0)
        
        if r2_score >= 0.8:
            return "high"
        elif r2_score >= 0.6:
            return "medium"
        else:
            return "low"
    
    def _insufficient_prediction_data_response(self, plant_id: str, data_points: int) -> Dict[str, Any]:
        """Return response for insufficient prediction data."""
        return {
            "plant_id": plant_id,
            "status": "insufficient_data",
            "message": f"Only {data_points} data points available. Need at least 5 for predictions.",
            "data_points": data_points
        }


def get_growth_prediction_service() -> GrowthPredictionService:
    """Factory function to get GrowthPredictionService instance."""
    return GrowthPredictionService()