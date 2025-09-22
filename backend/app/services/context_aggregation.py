"""Context Aggregation Service for Context-Aware Care Plans v2

This service aggregates context from multiple data sources to provide comprehensive
plant context for care plan generation. It combines:
- Sensor telemetry data (temperature, humidity, light, soil moisture)
- Environmental data (weather, seasonal patterns, location)
- Plant health metrics (growth rate, leaf condition, stress indicators)
- User behavior patterns (watering history, care consistency)
- Historical care outcomes and success rates

Key Features:
- Multi-source data integration with reliability scoring
- Data quality assessment and validation
- Temporal pattern analysis and trend detection
- Confidence scoring based on data completeness
- Fallback handling for missing data sources
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
from enum import Enum
import statistics

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.models.user_plant import UserPlant
from app.models.care_plan import CarePlanV2
# Note: WateringSchedule and FertilizerSchedule are embedded in CarePlanV2.plan JSON
# Note: Using placeholder models for telemetry and health data until they are implemented
from app.services.environmental_data import EnvironmentalDataService, EnvironmentalContext

logger = logging.getLogger(__name__)

class DataSource(Enum):
    """Available data sources for context aggregation"""
    SENSOR_TELEMETRY = "sensor_telemetry"
    WEATHER_API = "weather_api"
    PLANT_HEALTH = "plant_health"
    USER_BEHAVIOR = "user_behavior"
    HISTORICAL_PLANS = "historical_plans"
    SPECIES_DATABASE = "species_database"
    MANUAL_INPUT = "manual_input"

class HealthStatus(Enum):
    """Plant health status classifications"""
    EXCELLENT = "excellent"
    GOOD = "good"
    FAIR = "fair"
    POOR = "poor"
    CRITICAL = "critical"
    UNKNOWN = "unknown"

@dataclass
class SensorContext:
    """Aggregated sensor data context"""
    temperature_avg: Optional[float] = None
    temperature_trend: float = 0.0  # °C per day
    humidity_avg: Optional[float] = None
    humidity_trend: float = 0.0  # % per day
    light_ppfd_avg: Optional[float] = None
    light_trend: float = 0.0  # PPFD per day
    soil_moisture_avg: Optional[float] = None
    soil_moisture_trend: float = 0.0  # % per day
    
    # Data quality metrics
    reading_count: int = 0
    data_freshness_hours: float = 999.0
    reliability_score: float = 0.0  # 0.0-1.0
    missing_sensors: List[str] = field(default_factory=list)

@dataclass
class HealthContext:
    """Plant health metrics context"""
    overall_status: HealthStatus = HealthStatus.UNKNOWN
    health_score: float = 0.5  # 0.0-1.0
    growth_rate: Optional[float] = None  # cm per week
    leaf_condition_score: float = 0.5  # 0.0-1.0
    stress_indicators: List[str] = field(default_factory=list)
    
    # Recent changes
    health_trend: float = 0.0  # positive = improving
    last_assessment_days: int = 999
    assessment_count: int = 0
    
    # Specific metrics
    leaf_count: Optional[int] = None
    height_cm: Optional[float] = None
    width_cm: Optional[float] = None
    new_growth: bool = False

@dataclass
class UserBehaviorContext:
    """User care behavior patterns"""
    watering_consistency: float = 0.5  # 0.0-1.0
    care_frequency_days: float = 7.0
    response_to_alerts: float = 0.5  # 0.0-1.0
    plan_adherence_rate: float = 0.5  # 0.0-1.0
    
    # Historical patterns
    avg_watering_amount_ml: Optional[float] = None
    preferred_care_times: List[int] = field(default_factory=list)  # Hours of day
    seasonal_behavior_changes: Dict[str, float] = field(default_factory=dict)
    
    # Recent activity
    last_care_action_days: int = 999
    total_care_actions: int = 0
    overwatering_tendency: float = 0.0  # -1.0 to 1.0
    underwatering_tendency: float = 0.0

@dataclass
class HistoricalContext:
    """Historical care outcomes and patterns"""
    successful_plans: int = 0
    total_plans: int = 0
    avg_plan_duration_days: float = 14.0
    
    # Success patterns
    best_watering_interval: Optional[int] = None
    best_fertilizer_interval: Optional[int] = None
    seasonal_success_rates: Dict[str, float] = field(default_factory=dict)
    
    # Failure patterns
    common_issues: List[str] = field(default_factory=list)
    failure_reasons: Dict[str, int] = field(default_factory=dict)
    
    # Trends
    success_trend: float = 0.0  # positive = improving
    care_plan_evolution: List[Dict[str, Any]] = field(default_factory=list)

@dataclass
class PlantContext:
    """Comprehensive plant context for care plan generation"""
    plant_id: int
    species: str
    age_days: Optional[int] = None
    pot_size_liters: Optional[float] = None
    location_indoor: bool = True
    
    # Aggregated contexts
    sensor_context: SensorContext = field(default_factory=SensorContext)
    environmental_context: Optional[EnvironmentalContext] = None
    health_context: HealthContext = field(default_factory=HealthContext)
    user_behavior_context: UserBehaviorContext = field(default_factory=UserBehaviorContext)
    historical_context: HistoricalContext = field(default_factory=HistoricalContext)
    
    # Overall metrics
    confidence_score: float = 0.0  # 0.0-1.0
    data_sources: List[str] = field(default_factory=list)
    context_freshness_minutes: int = 0
    
    # Alerts and recommendations
    alerts: List[str] = field(default_factory=list)
    recommendations: List[str] = field(default_factory=list)
    
    # Metadata
    aggregated_at: datetime = field(default_factory=datetime.utcnow)
    cache_ttl_minutes: int = 30

class ContextAggregationService:
    """Service for aggregating plant context from multiple sources"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.env_service = EnvironmentalDataService(db)
        
        # Data source weights for confidence calculation
        self.source_weights = {
            DataSource.SENSOR_TELEMETRY: 0.3,
            DataSource.WEATHER_API: 0.15,
            DataSource.PLANT_HEALTH: 0.25,
            DataSource.USER_BEHAVIOR: 0.15,
            DataSource.HISTORICAL_PLANS: 0.1,
            DataSource.SPECIES_DATABASE: 0.05
        }
    
    async def aggregate_plant_context(
        self, 
        plant_id: int,
        include_environmental: bool = True,
        include_health_metrics: bool = True,
        include_user_behavior: bool = True,
        lookback_days: int = 30
    ) -> PlantContext:
        """Aggregate comprehensive context for a plant
        
        Args:
            plant_id: Plant ID to aggregate context for
            include_environmental: Include environmental data
            include_health_metrics: Include plant health metrics
            include_user_behavior: Include user behavior patterns
            lookback_days: Days of historical data to consider
            
        Returns:
            Complete plant context with all available data
        """
        start_time = datetime.utcnow()
        
        try:
            logger.info(f"Aggregating context for plant {plant_id}")
            
            # Get basic plant information
            plant_info = await self._get_plant_info(plant_id)
            if not plant_info:
                raise ValueError(f"Plant {plant_id} not found")
            
            # Initialize context
            context = PlantContext(
                plant_id=plant_id,
                species=plant_info.get('species', 'unknown'),
                age_days=plant_info.get('age_days'),
                pot_size_liters=plant_info.get('pot_size_liters'),
                location_indoor=plant_info.get('location_indoor', True)
            )
            
            # Aggregate data from all sources concurrently
            tasks = [
                self._aggregate_sensor_context(plant_id, lookback_days),
                self._aggregate_health_context(plant_id, lookback_days) if include_health_metrics else None,
                self._aggregate_user_behavior_context(plant_id, lookback_days) if include_user_behavior else None,
                self._aggregate_historical_context(plant_id, lookback_days),
                self._get_environmental_context(plant_id) if include_environmental else None
            ]
            
            # Filter out None tasks
            tasks = [task for task in tasks if task is not None]
            
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Process results
            sensor_context = results[0] if not isinstance(results[0], Exception) else SensorContext()
            
            result_idx = 1
            health_context = HealthContext()
            if include_health_metrics:
                health_context = results[result_idx] if not isinstance(results[result_idx], Exception) else HealthContext()
                result_idx += 1
            
            user_behavior_context = UserBehaviorContext()
            if include_user_behavior:
                user_behavior_context = results[result_idx] if not isinstance(results[result_idx], Exception) else UserBehaviorContext()
                result_idx += 1
            
            historical_context = results[result_idx] if not isinstance(results[result_idx], Exception) else HistoricalContext()
            result_idx += 1
            
            environmental_context = None
            if include_environmental:
                environmental_context = results[result_idx] if not isinstance(results[result_idx], Exception) else None
            
            # Assign contexts
            context.sensor_context = sensor_context
            context.health_context = health_context
            context.user_behavior_context = user_behavior_context
            context.historical_context = historical_context
            context.environmental_context = environmental_context
            
            # Calculate confidence score and data sources
            context.confidence_score = self._calculate_confidence_score(context)
            context.data_sources = self._identify_data_sources(context)
            
            # Generate alerts and recommendations
            context.alerts = self._generate_alerts(context)
            context.recommendations = self._generate_recommendations(context)
            
            # Set metadata
            context.context_freshness_minutes = int((datetime.utcnow() - start_time).total_seconds() / 60)
            
            logger.info(f"Context aggregated for plant {plant_id} (confidence: {context.confidence_score:.2f})")
            return context
            
        except Exception as e:
            logger.error(f"Error aggregating context for plant {plant_id}: {e}")
            raise
    
    async def _get_plant_info(self, plant_id: int) -> Optional[Dict[str, Any]]:
        """Get basic plant information"""
        query = select(UserPlant).where(UserPlant.id == plant_id)
        result = await self.db.execute(query)
        plant = result.scalar_one_or_none()
        
        if not plant:
            return None
        
        age_days = None
        if plant.acquired_date:
            age_days = (datetime.utcnow().date() - plant.acquired_date).days
        
        return {
            'species': plant.species,
            'age_days': age_days,
            'pot_size_liters': plant.pot_size_liters,
            'location_indoor': plant.location_indoor,
            'nickname': plant.nickname
        }
    
    async def _aggregate_sensor_context(self, plant_id: int, lookback_days: int) -> SensorContext:
        """Aggregate sensor telemetry data"""
        # TODO: Implement when SensorReading model is available
        # For now, return empty sensor context
        readings = []
        
        if not readings:
            return SensorContext(missing_sensors=['all'])
        
        # Extract values
        temperatures = [r.temperature for r in readings if r.temperature is not None]
        humidities = [r.humidity for r in readings if r.humidity is not None]
        light_levels = [r.light_ppfd for r in readings if r.light_ppfd is not None]
        soil_moistures = [r.soil_moisture for r in readings if r.soil_moisture is not None]
        
        # Calculate averages
        temp_avg = statistics.mean(temperatures) if temperatures else None
        humidity_avg = statistics.mean(humidities) if humidities else None
        light_avg = statistics.mean(light_levels) if light_levels else None
        soil_avg = statistics.mean(soil_moistures) if soil_moistures else None
        
        # Calculate trends (simple linear regression slope)
        temp_trend = self._calculate_trend(readings, 'temperature') if len(temperatures) > 1 else 0.0
        humidity_trend = self._calculate_trend(readings, 'humidity') if len(humidities) > 1 else 0.0
        light_trend = self._calculate_trend(readings, 'light_ppfd') if len(light_levels) > 1 else 0.0
        soil_trend = self._calculate_trend(readings, 'soil_moisture') if len(soil_moistures) > 1 else 0.0
        
        # Data quality metrics
        latest_reading = max(readings, key=lambda r: r.timestamp)
        data_freshness_hours = (datetime.utcnow() - latest_reading.timestamp).total_seconds() / 3600
        
        # Reliability based on data completeness and recency
        completeness = len(readings) / (lookback_days * 24)  # Assuming hourly readings ideal
        recency_factor = max(0, 1 - (data_freshness_hours / 24))  # Decay over 24 hours
        reliability_score = min(1.0, completeness * recency_factor)
        
        # Identify missing sensors
        missing_sensors = []
        if not temperatures:
            missing_sensors.append('temperature')
        if not humidities:
            missing_sensors.append('humidity')
        if not light_levels:
            missing_sensors.append('light')
        if not soil_moistures:
            missing_sensors.append('soil_moisture')
        
        return SensorContext(
            temperature_avg=temp_avg,
            temperature_trend=temp_trend,
            humidity_avg=humidity_avg,
            humidity_trend=humidity_trend,
            light_ppfd_avg=light_avg,
            light_trend=light_trend,
            soil_moisture_avg=soil_avg,
            soil_moisture_trend=soil_trend,
            reading_count=len(readings),
            data_freshness_hours=data_freshness_hours,
            reliability_score=reliability_score,
            missing_sensors=missing_sensors
        )
    
    async def _aggregate_health_context(self, plant_id: int, lookback_days: int) -> HealthContext:
        """Aggregate plant health metrics"""
        cutoff_date = datetime.utcnow() - timedelta(days=lookback_days)
        
        # TODO: Implement when PlantHealthMetric and GrowthMeasurement models are available
        # For now, return empty lists
        health_metrics = []
        growth_measurements = []
        
        if not health_metrics and not growth_measurements:
            return HealthContext()
        
        # Process health metrics
        overall_status = HealthStatus.UNKNOWN
        health_score = 0.5
        leaf_condition_score = 0.5
        stress_indicators = []
        
        if health_metrics:
            latest_health = health_metrics[0]
            health_score = latest_health.overall_health_score or 0.5
            leaf_condition_score = latest_health.leaf_condition_score or 0.5
            
            # Determine status from score
            if health_score >= 0.9:
                overall_status = HealthStatus.EXCELLENT
            elif health_score >= 0.7:
                overall_status = HealthStatus.GOOD
            elif health_score >= 0.5:
                overall_status = HealthStatus.FAIR
            elif health_score >= 0.3:
                overall_status = HealthStatus.POOR
            else:
                overall_status = HealthStatus.CRITICAL
            
            # Extract stress indicators
            if latest_health.stress_indicators:
                stress_indicators = latest_health.stress_indicators.split(',')
        
        # Process growth measurements
        growth_rate = None
        leaf_count = None
        height_cm = None
        width_cm = None
        new_growth = False
        
        if growth_measurements:
            latest_growth = growth_measurements[0]
            leaf_count = latest_growth.leaf_count
            height_cm = latest_growth.height_cm
            width_cm = latest_growth.width_cm
            
            # Calculate growth rate if we have multiple measurements
            if len(growth_measurements) > 1:
                older_growth = growth_measurements[-1]
                days_diff = (latest_growth.measurement_date - older_growth.measurement_date).days
                
                if days_diff > 0 and latest_growth.height_cm and older_growth.height_cm:
                    height_diff = latest_growth.height_cm - older_growth.height_cm
                    growth_rate = (height_diff / days_diff) * 7  # cm per week
                    new_growth = height_diff > 0
        
        # Calculate health trend
        health_trend = 0.0
        if len(health_metrics) > 1:
            recent_scores = [m.overall_health_score for m in health_metrics[:5] if m.overall_health_score]
            if len(recent_scores) > 1:
                health_trend = self._calculate_simple_trend(recent_scores)
        
        # Assessment metadata
        last_assessment_days = 999
        if health_metrics:
            last_assessment_days = (datetime.utcnow().date() - health_metrics[0].assessment_date).days
        
        return HealthContext(
            overall_status=overall_status,
            health_score=health_score,
            growth_rate=growth_rate,
            leaf_condition_score=leaf_condition_score,
            stress_indicators=stress_indicators,
            health_trend=health_trend,
            last_assessment_days=last_assessment_days,
            assessment_count=len(health_metrics),
            leaf_count=leaf_count,
            height_cm=height_cm,
            width_cm=width_cm,
            new_growth=new_growth
        )
    
    async def _aggregate_user_behavior_context(self, plant_id: int, lookback_days: int) -> UserBehaviorContext:
        """Aggregate user care behavior patterns"""
        cutoff_date = datetime.utcnow() - timedelta(days=lookback_days)
        
        # TODO: Implement when care action tracking is available
        # For now, return empty lists since CarePlanV2 uses JSON structure
        watering_actions = []
        fertilizer_actions = []
        
        # Get care plans for adherence calculation
        plans_query = select(CarePlanV2).where(
            and_(
                CarePlanV2.plant_id == plant_id,
                CarePlanV2.created_at >= cutoff_date
            )
        )
        
        plans_result = await self.db.execute(plans_query)
        care_plans = plans_result.scalars().all()
        
        if not watering_actions and not fertilizer_actions:
            return UserBehaviorContext()
        
        # Calculate watering consistency
        watering_consistency = 0.5
        avg_watering_amount = None
        
        if watering_actions:
            # Calculate intervals between waterings
            intervals = []
            for i in range(1, len(watering_actions)):
                interval = (watering_actions[i-1].completed_at - watering_actions[i].completed_at).days
                if interval > 0:
                    intervals.append(interval)
            
            if intervals:
                # Consistency based on standard deviation (lower = more consistent)
                std_dev = statistics.stdev(intervals) if len(intervals) > 1 else 0
                avg_interval = statistics.mean(intervals)
                watering_consistency = max(0, 1 - (std_dev / max(avg_interval, 1)))
            
            # Average watering amount
            amounts = [w.amount_ml for w in watering_actions if w.amount_ml]
            if amounts:
                avg_watering_amount = statistics.mean(amounts)
        
        # Calculate care frequency
        all_actions = len(watering_actions) + len(fertilizer_actions)
        care_frequency_days = lookback_days / max(all_actions, 1)
        
        # Calculate plan adherence rate
        # TODO: Implement when care action tracking is available
        plan_adherence_rate = 0.5  # Default value
        
        # Analyze care times
        preferred_care_times = []
        if watering_actions:
            care_hours = [w.completed_at.hour for w in watering_actions]
            # Find most common hours (simplified)
            from collections import Counter
            hour_counts = Counter(care_hours)
            preferred_care_times = [hour for hour, count in hour_counts.most_common(3)]
        
        # Calculate last care action
        last_care_action_days = 999
        if watering_actions or fertilizer_actions:
            all_action_dates = []
            if watering_actions:
                all_action_dates.extend([w.completed_at for w in watering_actions])
            if fertilizer_actions:
                all_action_dates.extend([f.completed_at for f in fertilizer_actions])
            
            if all_action_dates:
                latest_action = max(all_action_dates)
                last_care_action_days = (datetime.utcnow() - latest_action).days
        
        # Analyze watering tendencies (simplified)
        overwatering_tendency = 0.0
        underwatering_tendency = 0.0
        
        if avg_watering_amount and watering_actions:
            # This would need more sophisticated analysis based on plant needs
            # For now, just check if amounts are consistently high or low
            amounts = [w.amount_ml for w in watering_actions if w.amount_ml]
            if amounts:
                avg_amount = statistics.mean(amounts)
                if avg_amount > 500:  # Arbitrary threshold
                    overwatering_tendency = 0.3
                elif avg_amount < 100:
                    underwatering_tendency = 0.3
        
        return UserBehaviorContext(
            watering_consistency=watering_consistency,
            care_frequency_days=care_frequency_days,
            response_to_alerts=0.5,  # Would need alert response tracking
            plan_adherence_rate=plan_adherence_rate,
            avg_watering_amount_ml=avg_watering_amount,
            preferred_care_times=preferred_care_times,
            last_care_action_days=last_care_action_days,
            total_care_actions=all_actions,
            overwatering_tendency=overwatering_tendency,
            underwatering_tendency=underwatering_tendency
        )
    
    async def _aggregate_historical_context(self, plant_id: int, lookback_days: int) -> HistoricalContext:
        """Aggregate historical care outcomes"""
        cutoff_date = datetime.utcnow() - timedelta(days=lookback_days)
        
        # Get historical care plans
        query = select(CarePlanV2).where(
            and_(
                CarePlanV2.plant_id == plant_id,
                CarePlanV2.created_at >= cutoff_date
            )
        ).order_by(desc(CarePlanV2.created_at))
        
        result = await self.db.execute(query)
        care_plans = result.scalars().all()
        
        if not care_plans:
            return HistoricalContext()
        
        # Analyze plan success (simplified - would need more sophisticated metrics)
        successful_plans = 0
        total_plans = len(care_plans)
        
        for plan in care_plans:
            # Consider a plan successful if it was acknowledged and completed
            if plan.status in ['acknowledged', 'completed'] and plan.confidence_score > 0.6:
                successful_plans += 1
        
        # Calculate average plan duration
        durations = []
        for plan in care_plans:
            if plan.valid_until:
                duration = (plan.valid_until - plan.created_at).days
                durations.append(duration)
        
        avg_plan_duration = statistics.mean(durations) if durations else 14.0
        
        # Analyze success patterns (simplified)
        best_watering_interval = None
        best_fertilizer_interval = None
        
        # This would require more sophisticated analysis of successful plans
        # For now, just use defaults
        
        return HistoricalContext(
            successful_plans=successful_plans,
            total_plans=total_plans,
            avg_plan_duration_days=avg_plan_duration,
            best_watering_interval=best_watering_interval,
            best_fertilizer_interval=best_fertilizer_interval
        )
    
    async def _get_environmental_context(self, plant_id: int) -> Optional[EnvironmentalContext]:
        """Get environmental context from environmental data service"""
        try:
            return await self.env_service.get_environmental_context(plant_id)
        except Exception as e:
            logger.error(f"Error getting environmental context for plant {plant_id}: {e}")
            return None
    
    def _calculate_trend(self, readings: List[Any], field: str) -> float:
        """Calculate trend from sensor readings using simple linear regression"""
        values = []
        timestamps = []
        
        for reading in readings:
            value = getattr(reading, field, None)
            if value is not None:
                values.append(value)
                timestamps.append(reading.timestamp.timestamp())
        
        if len(values) < 2:
            return 0.0
        
        # Simple linear regression
        n = len(values)
        x_mean = sum(timestamps) / n
        y_mean = sum(values) / n
        
        numerator = sum((x - x_mean) * (y - y_mean) for x, y in zip(timestamps, values))
        denominator = sum((x - x_mean) ** 2 for x in timestamps)
        
        if denominator == 0:
            return 0.0
        
        slope = numerator / denominator
        
        # Convert to per-day rate
        return slope * 86400  # seconds per day
    
    def _calculate_simple_trend(self, values: List[float]) -> float:
        """Calculate simple trend from a list of values"""
        if len(values) < 2:
            return 0.0
        
        # Simple difference between first and last
        return (values[0] - values[-1]) / len(values)
    
    def _calculate_confidence_score(self, context: PlantContext) -> float:
        """Calculate overall confidence score based on data availability and quality"""
        total_weight = 0.0
        weighted_score = 0.0
        
        # Sensor data contribution
        if context.sensor_context.reading_count > 0:
            sensor_score = context.sensor_context.reliability_score
            weight = self.source_weights[DataSource.SENSOR_TELEMETRY]
            weighted_score += sensor_score * weight
            total_weight += weight
        
        # Environmental data contribution
        if context.environmental_context:
            env_score = context.environmental_context.sensor_reliability_score
            weight = self.source_weights[DataSource.WEATHER_API]
            weighted_score += env_score * weight
            total_weight += weight
        
        # Health data contribution
        if context.health_context.assessment_count > 0:
            health_score = min(1.0, context.health_context.assessment_count / 5.0)  # Up to 5 assessments
            weight = self.source_weights[DataSource.PLANT_HEALTH]
            weighted_score += health_score * weight
            total_weight += weight
        
        # User behavior contribution
        if context.user_behavior_context.total_care_actions > 0:
            behavior_score = min(1.0, context.user_behavior_context.total_care_actions / 10.0)
            weight = self.source_weights[DataSource.USER_BEHAVIOR]
            weighted_score += behavior_score * weight
            total_weight += weight
        
        # Historical data contribution
        if context.historical_context.total_plans > 0:
            historical_score = min(1.0, context.historical_context.total_plans / 5.0)
            weight = self.source_weights[DataSource.HISTORICAL_PLANS]
            weighted_score += historical_score * weight
            total_weight += weight
        
        # Calculate final confidence score
        if total_weight > 0:
            return weighted_score / total_weight
        else:
            return 0.1  # Minimum confidence with no data
    
    def _identify_data_sources(self, context: PlantContext) -> List[str]:
        """Identify which data sources contributed to the context"""
        sources = []
        
        if context.sensor_context.reading_count > 0:
            sources.append(DataSource.SENSOR_TELEMETRY.value)
        
        if context.environmental_context:
            sources.append(DataSource.WEATHER_API.value)
        
        if context.health_context.assessment_count > 0:
            sources.append(DataSource.PLANT_HEALTH.value)
        
        if context.user_behavior_context.total_care_actions > 0:
            sources.append(DataSource.USER_BEHAVIOR.value)
        
        if context.historical_context.total_plans > 0:
            sources.append(DataSource.HISTORICAL_PLANS.value)
        
        return sources
    
    def _generate_alerts(self, context: PlantContext) -> List[str]:
        """Generate alerts based on context analysis"""
        alerts = []
        
        # Sensor-based alerts
        if context.sensor_context.data_freshness_hours > 24:
            alerts.append("Sensor data is stale - check device connectivity")
        
        if 'temperature' in context.sensor_context.missing_sensors:
            alerts.append("Temperature sensor not reporting")
        
        # Health-based alerts
        if context.health_context.overall_status == HealthStatus.CRITICAL:
            alerts.append("Plant health is critical - immediate attention needed")
        elif context.health_context.overall_status == HealthStatus.POOR:
            alerts.append("Plant health is declining - review care routine")
        
        if context.health_context.stress_indicators:
            alerts.append(f"Stress indicators detected: {', '.join(context.health_context.stress_indicators)}")
        
        # Environmental alerts
        if context.environmental_context:
            if context.environmental_context.heatwave_days > 3:
                alerts.append("Extended heatwave - increase watering frequency")
            
            if context.environmental_context.cold_snap_days > 3:
                alerts.append("Cold weather - reduce watering and protect from drafts")
        
        # User behavior alerts
        if context.user_behavior_context.last_care_action_days > 14:
            alerts.append("No recent care actions - plant may need attention")
        
        if context.user_behavior_context.plan_adherence_rate < 0.3:
            alerts.append("Low plan adherence - consider adjusting care schedule")
        
        return alerts
    
    def _generate_recommendations(self, context: PlantContext) -> List[str]:
        """Generate recommendations based on context analysis"""
        recommendations = []
        
        # Data quality recommendations
        if context.confidence_score < 0.5:
            recommendations.append("Consider adding more sensors for better care recommendations")
        
        if context.health_context.last_assessment_days > 7:
            recommendations.append("Perform a health assessment to improve care accuracy")
        
        # Care pattern recommendations
        if context.user_behavior_context.watering_consistency < 0.5:
            recommendations.append("Try to maintain more consistent watering intervals")
        
        if context.user_behavior_context.overwatering_tendency > 0.3:
            recommendations.append("Consider reducing watering amounts - plant may be getting too much water")
        
        if context.user_behavior_context.underwatering_tendency > 0.3:
            recommendations.append("Consider increasing watering amounts - plant may need more water")
        
        # Growth recommendations
        if context.health_context.growth_rate and context.health_context.growth_rate < 0.1:
            recommendations.append("Slow growth detected - consider adjusting light or fertilizer schedule")
        
        return recommendations

# Dependency injection helper
async def get_context_aggregation_service(db: AsyncSession):
    """Get context aggregation service instance"""
    return ContextAggregationService(db)