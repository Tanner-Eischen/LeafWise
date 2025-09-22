"""Growth Analysis Service for plant growth pattern detection and milestone tracking.

This service provides functionality for analyzing plant growth patterns,
detecting milestones, and identifying anomalies in plant growth.
"""

import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional, Tuple
from app.schemas.timelapse import PlantMeasurements, AnomalyFlag

logger = logging.getLogger(__name__)


class GrowthAnalysisService:
    """Service for analyzing plant growth patterns and detecting anomalies."""
    
    def __init__(self):
        """Initialize growth analyzer with statistical parameters."""
        self.growth_rate_threshold = 0.5  # cm per week for significant growth
        self.health_decline_threshold = 0.15  # Health score decline threshold
        self.leaf_count_significance = 3  # Minimum leaf change for milestone
        self.size_increase_threshold = 5.0  # cm increase for size milestone
    
    def calculate_growth_rate(
        self,
        measurements_history: List[Dict[str, Any]],
        time_window_days: int = 14
    ) -> Dict[str, float]:
        """
        Calculate growth rates over specified time window.
        
        Args:
            measurements_history: List of measurement dictionaries with timestamps
            time_window_days: Time window for rate calculation
            
        Returns:
            Dictionary with growth rates for different metrics
        """
        if len(measurements_history) < 2:
            return {}
        
        try:
            # Sort by date
            sorted_measurements = sorted(
                measurements_history,
                key=lambda x: datetime.fromisoformat(x.get('capture_date', ''))
            )
            
            # Get measurements within time window
            cutoff_date = datetime.utcnow() - timedelta(days=time_window_days)
            recent_measurements = [
                m for m in sorted_measurements
                if datetime.fromisoformat(m.get('capture_date', '')) >= cutoff_date
            ]
            
            if len(recent_measurements) < 2:
                recent_measurements = sorted_measurements[-2:]  # Use last 2 if not enough recent
            
            first_measurement = recent_measurements[0]
            last_measurement = recent_measurements[-1]
            
            # Calculate time difference in days
            first_date = datetime.fromisoformat(first_measurement.get('capture_date', ''))
            last_date = datetime.fromisoformat(last_measurement.get('capture_date', ''))
            days_diff = (last_date - first_date).days
            
            if days_diff == 0:
                days_diff = 1  # Avoid division by zero
            
            growth_rates = {}
            
            # Height growth rate
            if (first_measurement.get('height_cm') and last_measurement.get('height_cm')):
                height_change = last_measurement['height_cm'] - first_measurement['height_cm']
                growth_rates['height_cm_per_day'] = height_change / days_diff
                growth_rates['height_cm_per_week'] = height_change / days_diff * 7
            
            # Width growth rate
            if (first_measurement.get('width_cm') and last_measurement.get('width_cm')):
                width_change = last_measurement['width_cm'] - first_measurement['width_cm']
                growth_rates['width_cm_per_day'] = width_change / days_diff
                growth_rates['width_cm_per_week'] = width_change / days_diff * 7
            
            # Leaf area growth rate
            if (first_measurement.get('leaf_area_cm2') and last_measurement.get('leaf_area_cm2')):
                area_change = last_measurement['leaf_area_cm2'] - first_measurement['leaf_area_cm2']
                growth_rates['leaf_area_cm2_per_day'] = area_change / days_diff
            
            # Health trend
            if (first_measurement.get('health_score') and last_measurement.get('health_score')):
                health_change = last_measurement['health_score'] - first_measurement['health_score']
                growth_rates['health_trend_per_day'] = health_change / days_diff
            
            return growth_rates
            
        except Exception as e:
            logger.error(f"Error calculating growth rates: {str(e)}")
            return {}
    
    def detect_growth_patterns(
        self,
        measurements_history: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Detect growth patterns using statistical analysis.
        
        Args:
            measurements_history: Historical measurements data
            
        Returns:
            Dictionary with detected patterns and trends
        """
        if len(measurements_history) < 3:
            return {"status": "insufficient_data"}
        
        try:
            # Extract time series data
            heights = []
            widths = []
            health_scores = []
            dates = []
            
            for measurement in sorted(measurements_history, key=lambda x: x.get('capture_date', '')):
                if measurement.get('height_cm'):
                    heights.append(measurement['height_cm'])
                if measurement.get('width_cm'):
                    widths.append(measurement['width_cm'])
                if measurement.get('health_score'):
                    health_scores.append(measurement['health_score'])
                dates.append(measurement.get('capture_date', ''))
            
            patterns = {}
            
            # Analyze height trend
            if len(heights) >= 3:
                height_trend = self._analyze_trend(heights)
                patterns['height_trend'] = height_trend
            
            # Analyze width trend
            if len(widths) >= 3:
                width_trend = self._analyze_trend(widths)
                patterns['width_trend'] = width_trend
            
            # Analyze health trend
            if len(health_scores) >= 3:
                health_trend = self._analyze_trend(health_scores)
                patterns['health_trend'] = health_trend
            
            # Detect growth phases
            patterns['growth_phase'] = self._detect_growth_phase(heights, health_scores)
            
            # Calculate consistency metrics
            patterns['growth_consistency'] = self._calculate_consistency(heights)
            
            return patterns
            
        except Exception as e:
            logger.error(f"Error detecting growth patterns: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def _analyze_trend(self, values: List[float]) -> Dict[str, Any]:
        """
        Analyze trend in a series of values.
        
        Args:
            values: List of numerical values
            
        Returns:
            Dictionary with trend analysis results
        """
        if len(values) < 3:
            return {"trend": "unknown"}
        
        # Calculate simple linear trend
        n = len(values)
        x = list(range(n))
        
        # Simple linear regression
        x_mean = sum(x) / n
        y_mean = sum(values) / n
        
        numerator = sum((x[i] - x_mean) * (values[i] - y_mean) for i in range(n))
        denominator = sum((x[i] - x_mean) ** 2 for i in range(n))
        
        if denominator == 0:
            slope = 0
        else:
            slope = numerator / denominator
        
        # Determine trend direction and strength
        if abs(slope) < 0.01:
            trend = "stable"
        elif slope > 0:
            trend = "increasing"
        else:
            trend = "decreasing"
        
        # Calculate R-squared for trend strength
        y_pred = [x_mean + slope * (x[i] - x_mean) for i in range(n)]
        ss_res = sum((values[i] - y_pred[i]) ** 2 for i in range(n))
        ss_tot = sum((values[i] - y_mean) ** 2 for i in range(n))
        
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        
        return {
            "trend": trend,
            "slope": slope,
            "strength": r_squared,
            "confidence": "high" if r_squared > 0.7 else "medium" if r_squared > 0.4 else "low"
        }
    
    def _detect_growth_phase(self, heights: List[float], health_scores: List[float]) -> str:
        """
        Detect current growth phase based on measurements.
        
        Args:
            heights: List of height measurements
            health_scores: List of health scores
            
        Returns:
            Growth phase classification
        """
        if not heights or not health_scores:
            return "unknown"
        
        recent_height_trend = self._analyze_trend(heights[-3:]) if len(heights) >= 3 else {"trend": "unknown"}
        recent_health = health_scores[-1] if health_scores else 0
        
        # Determine growth phase
        if recent_height_trend["trend"] == "increasing" and recent_health > 0.8:
            return "active_growth"
        elif recent_height_trend["trend"] == "stable" and recent_health > 0.7:
            return "maintenance"
        elif recent_height_trend["trend"] == "decreasing" or recent_health < 0.6:
            return "stress_or_dormancy"
        else:
            return "transitional"
    
    def _calculate_consistency(self, values: List[float]) -> float:
        """
        Calculate growth consistency score.
        
        Args:
            values: List of numerical values
            
        Returns:
            Consistency score between 0.0 and 1.0
        """
        if len(values) < 3:
            return 0.0
        
        # Calculate coefficient of variation
        mean_val = sum(values) / len(values)
        if mean_val == 0:
            return 0.0
        
        variance = sum((x - mean_val) ** 2 for x in values) / len(values)
        std_dev = variance ** 0.5
        cv = std_dev / mean_val
        
        # Convert to consistency score (lower CV = higher consistency)
        consistency = max(0.0, 1.0 - cv)
        return consistency
    
    def detect_milestones(
        self,
        current_measurements: PlantMeasurements,
        previous_measurements: Optional[PlantMeasurements],
        measurements_history: List[Dict[str, Any]],
        milestone_targets: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Detect achieved milestones based on current measurements.
        
        Args:
            current_measurements: Current plant measurements
            previous_measurements: Previous measurements for comparison
            measurements_history: Historical measurements
            milestone_targets: Configured milestone targets
            
        Returns:
            List of detected milestones
        """
        detected_milestones = []
        
        try:
            # Check target-based milestones
            for target in milestone_targets:
                milestone = self._check_target_milestone(current_measurements, target)
                if milestone:
                    detected_milestones.append(milestone)
            
            # Check automatic milestones
            auto_milestones = self._detect_automatic_milestones(
                current_measurements, previous_measurements, measurements_history
            )
            detected_milestones.extend(auto_milestones)
            
            return detected_milestones
            
        except Exception as e:
            logger.error(f"Error detecting milestones: {str(e)}")
            return []
    
    def _check_target_milestone(
        self,
        measurements: PlantMeasurements,
        target: Dict[str, Any]
    ) -> Optional[Dict[str, Any]]:
        """
        Check if a target milestone has been achieved.
        
        Args:
            measurements: Current plant measurements
            target: Milestone target configuration
            
        Returns:
            Milestone data if achieved, None otherwise
        """
        milestone_type = target.get('milestone_type')
        target_value = target.get('target_value')
        
        if not milestone_type or target_value is None:
            return None
        
        achieved = False
        current_value = None
        
        if milestone_type == 'height_increase' and measurements.height_cm:
            current_value = measurements.height_cm
            achieved = measurements.height_cm >= target_value
        elif milestone_type == 'width_increase' and measurements.width_cm:
            current_value = measurements.width_cm
            achieved = measurements.width_cm >= target_value
        elif milestone_type == 'leaf_count' and measurements.leaf_count:
            current_value = measurements.leaf_count
            achieved = measurements.leaf_count >= target_value
        elif milestone_type == 'health_improvement' and measurements.health_score:
            current_value = measurements.health_score
            achieved = measurements.health_score >= target_value
        
        if achieved:
            return {
                "milestone_type": milestone_type,
                "milestone_name": target.get('description', f"Reached {target_value}"),
                "achievement_date": datetime.utcnow().isoformat(),
                "target_value": target_value,
                "achieved_value": current_value,
                "detection_method": "target_based",
                "confidence_score": 0.95
            }
        
        return None
    
    def _detect_automatic_milestones(
        self,
        current: PlantMeasurements,
        previous: Optional[PlantMeasurements],
        history: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Detect automatic milestones based on significant changes.
        
        Args:
            current: Current plant measurements
            previous: Previous measurements for comparison
            history: Historical measurements
            
        Returns:
            List of detected automatic milestones
        """
        milestones = []
        
        if not previous:
            return milestones
        
        # Significant height increase
        if (current.height_cm and previous.height_cm and
            current.height_cm - previous.height_cm >= self.size_increase_threshold):
            milestones.append({
                "milestone_type": "significant_height_increase",
                "milestone_name": f"Grew {current.height_cm - previous.height_cm:.1f}cm in height",
                "achievement_date": datetime.utcnow().isoformat(),
                "detection_method": "automatic",
                "confidence_score": 0.8
            })
        
        # Significant leaf count increase
        if (current.leaf_count and previous.leaf_count and
            current.leaf_count - previous.leaf_count >= self.leaf_count_significance):
            milestones.append({
                "milestone_type": "new_leaf_growth",
                "milestone_name": f"Grew {current.leaf_count - previous.leaf_count} new leaves",
                "achievement_date": datetime.utcnow().isoformat(),
                "detection_method": "automatic",
                "confidence_score": 0.85
            })
        
        # Health improvement milestone
        if (current.health_score and previous.health_score and
            current.health_score - previous.health_score >= 0.2):
            milestones.append({
                "milestone_type": "health_improvement",
                "milestone_name": "Significant health improvement detected",
                "achievement_date": datetime.utcnow().isoformat(),
                "detection_method": "automatic",
                "confidence_score": 0.75
            })
        
        # First measurement milestone
        if len(history) == 1:
            milestones.append({
                "milestone_type": "tracking_started",
                "milestone_name": "Time-lapse tracking initiated",
                "achievement_date": datetime.utcnow().isoformat(),
                "detection_method": "automatic",
                "confidence_score": 1.0
            })
        
        return milestones
    
    def detect_unhealthy_patterns(
        self,
        measurements_history: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Detect patterns indicating plant health issues.
        
        Args:
            measurements_history: Historical measurements
            
        Returns:
            List of detected unhealthy patterns
        """
        if len(measurements_history) < 3:
            return []
        
        unhealthy_patterns = []
        
        try:
            # Extract recent health scores
            recent_health = [
                m.get('health_score', 0) for m in measurements_history[-5:]
                if m.get('health_score') is not None
            ]
            
            if len(recent_health) >= 3:
                # Check for declining health trend
                health_trend = self._analyze_trend(recent_health)
                if health_trend["trend"] == "decreasing" and health_trend["strength"] > 0.5:
                    unhealthy_patterns.append({
                        "pattern_type": "declining_health",
                        "severity": "medium" if recent_health[-1] > 0.5 else "high",
                        "description": "Consistent decline in plant health detected",
                        "confidence": health_trend["strength"],
                        "recommendation": "Review care routine and environmental conditions"
                    })
            
            # Check for stunted growth
            recent_heights = [
                m.get('height_cm', 0) for m in measurements_history[-5:]
                if m.get('height_cm') is not None
            ]
            
            if len(recent_heights) >= 3:
                height_trend = self._analyze_trend(recent_heights)
                if height_trend["trend"] == "stable" and len(measurements_history) > 10:
                    # No growth over extended period
                    unhealthy_patterns.append({
                        "pattern_type": "stunted_growth",
                        "severity": "medium",
                        "description": "No significant growth detected over extended period",
                        "confidence": 0.7,
                        "recommendation": "Consider adjusting fertilization or light conditions"
                    })
            
            return unhealthy_patterns
            
        except Exception as e:
            logger.error(f"Error detecting unhealthy patterns: {str(e)}")
            return []
    
    def detect_anomalies(
        self, 
        measurements: PlantMeasurements, 
        previous_measurements: Optional[PlantMeasurements]
    ) -> List[AnomalyFlag]:
        """
        Detect growth anomalies by comparing measurements.
        
        Args:
            measurements: Current plant measurements
            previous_measurements: Previous measurements for comparison
            
        Returns:
            List of detected anomalies
        """
        anomalies = []
        
        if not previous_measurements:
            return anomalies
        
        try:
            # Check for significant health decline
            if (measurements.health_score and previous_measurements.health_score and
                measurements.health_score < previous_measurements.health_score - 0.2):
                anomalies.append(AnomalyFlag(
                    anomaly_type="health_decline",
                    severity=0.7,
                    description="Significant decrease in plant health score detected",
                    confidence=0.8
                ))
            
            # Check for unusual size changes
            if (measurements.height_cm and previous_measurements.height_cm and
                measurements.height_cm < previous_measurements.height_cm * 0.9):
                anomalies.append(AnomalyFlag(
                    anomaly_type="size_reduction",
                    severity=0.6,
                    description="Plant appears to have decreased in size",
                    confidence=0.7
                ))
            
            # Check for leaf loss
            if (measurements.leaf_count and previous_measurements.leaf_count and
                measurements.leaf_count < previous_measurements.leaf_count * 0.8):
                anomalies.append(AnomalyFlag(
                    anomaly_type="leaf_loss",
                    severity=0.5,
                    description="Significant leaf loss detected",
                    confidence=0.6
                ))
            
            return anomalies
            
        except Exception as e:
            logger.error(f"Error detecting anomalies: {str(e)}")
            return anomalies
    
    def predict_future_growth(
        self,
        measurements_history: List[Dict[str, Any]],
        prediction_days: int = 30
    ) -> Dict[str, Any]:
        """
        Predict future growth based on historical measurements.
        
        Args:
            measurements_history: Historical measurements
            prediction_days: Number of days to predict into the future
            
        Returns:
            Dictionary with growth predictions
        """
        if len(measurements_history) < 5:
            return {"status": "insufficient_data"}
        
        try:
            # Calculate growth rates
            growth_rates = self.calculate_growth_rate(measurements_history)
            
            if not growth_rates:
                return {"status": "insufficient_data"}
            
            # Get latest measurements
            sorted_measurements = sorted(
                measurements_history,
                key=lambda x: datetime.fromisoformat(x.get('capture_date', ''))
            )
            latest = sorted_measurements[-1]
            
            # Predict future values
            predictions = {}
            
            # Height prediction
            if 'height_cm_per_day' in growth_rates and latest.get('height_cm'):
                daily_growth = growth_rates['height_cm_per_day']
                current_height = latest['height_cm']
                predicted_height = current_height + (daily_growth * prediction_days)
                predictions['height_cm'] = max(0, predicted_height)
            
            # Width prediction
            if 'width_cm_per_day' in growth_rates and latest.get('width_cm'):
                daily_width_growth = growth_rates['width_cm_per_day']
                current_width = latest['width_cm']
                predicted_width = current_width + (daily_width_growth * prediction_days)
                predictions['width_cm'] = max(0, predicted_width)
            
            # Leaf area prediction
            if 'leaf_area_cm2_per_day' in growth_rates and latest.get('leaf_area_cm2'):
                daily_area_growth = growth_rates['leaf_area_cm2_per_day']
                current_area = latest['leaf_area_cm2']
                predicted_area = current_area + (daily_area_growth * prediction_days)
                predictions['leaf_area_cm2'] = max(0, predicted_area)
            
            # Add prediction date
            prediction_date = datetime.utcnow() + timedelta(days=prediction_days)
            predictions['prediction_date'] = prediction_date.isoformat()
            predictions['confidence'] = self._calculate_prediction_confidence(measurements_history)
            
            return {
                "status": "success",
                "predictions": predictions
            }
            
        except Exception as e:
            logger.error(f"Error predicting future growth: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def _calculate_prediction_confidence(self, measurements_history: List[Dict[str, Any]]) -> float:
        """
        Calculate confidence score for growth predictions.
        
        Args:
            measurements_history: Historical measurements
            
        Returns:
            Confidence score between 0.0 and 1.0
        """
        # Base confidence starts at 0.5
        confidence = 0.5
        
        # More data points increase confidence
        data_points = len(measurements_history)
        if data_points >= 10:
            confidence += 0.2
        elif data_points >= 5:
            confidence += 0.1
        
        # Consistent growth patterns increase confidence
        heights = [m.get('height_cm') for m in measurements_history if m.get('height_cm') is not None]
        if heights and len(heights) >= 3:
            consistency = self._calculate_consistency(heights)
            confidence += consistency * 0.3
        
        # Cap confidence at 0.95
        return min(0.95, confidence)