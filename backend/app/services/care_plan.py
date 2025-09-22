"""Core Care Plan Service for Context-Aware Care Plans v2

This service orchestrates the generation of deterministic, context-aware care plans by integrating:
- Context aggregation from multiple data sources
- Species-specific rule engine processing
- ML-based adjustments and optimizations
- Explainable rationale generation
- Performance monitoring and caching

Key Features:
- Deterministic plan generation with consistent results
- Multi-source context integration (sensors, weather, plant health)
- Species-specific rule application with environmental modifiers
- ML-enhanced adjustments with confidence scoring
- Comprehensive rationale and explanation generation
- Sub-300ms response time with intelligent caching
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import yaml
import json

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc, func
from sqlalchemy.orm import selectinload

from app.models.care_plan import CarePlanV2
from app.models.user_plant import UserPlant
# Note: CarePlanV2 uses JSON structure instead of separate detail tables
from app.services.context_aggregation import ContextAggregationService, PlantContext
from app.services.rule_engine import RuleEngineService, RuleResult
from app.services.ml_adjustment import MLAdjustmentService, MLPrediction
from app.services.rationale_builder import RationaleBuilderService, RationaleData
from app.services.environmental_data import EnvironmentalDataService, EnvironmentalContext
from app.services.cache_layer import CacheLayerService
from app.core.config import settings

logger = logging.getLogger(__name__)

class CarePlanStatus(Enum):
    """Care plan status enumeration"""
    DRAFT = "draft"
    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    EXPIRED = "expired"
    SUPERSEDED = "superseded"

class GenerationMode(Enum):
    """Care plan generation mode"""
    STANDARD = "standard"          # Normal generation
    EMERGENCY = "emergency"        # Fast generation for urgent needs
    DETAILED = "detailed"          # Comprehensive analysis
    REFRESH = "refresh"            # Update existing plan

@dataclass
class CarePlanRequest:
    """Care plan generation request"""
    plant_id: int
    user_id: int
    generation_mode: GenerationMode = GenerationMode.STANDARD
    force_regenerate: bool = False
    include_rationale: bool = True
    target_days: int = 14  # Plan duration in days
    preferences: Optional[Dict[str, Any]] = None

@dataclass
class CarePlanResponse:
    """Complete care plan response"""
    plan_id: str
    plant_id: int
    status: CarePlanStatus
    generated_at: datetime
    valid_until: datetime
    
    # Core plan data
    watering_schedule: Dict[str, Any]
    fertilizer_schedule: Dict[str, Any]
    light_targets: Dict[str, Any]
    
    # Metadata
    confidence_score: float
    generation_time_ms: float
    data_sources: List[str]
    
    # Rationale and explanations
    rationale: Optional[Dict[str, Any]] = None
    alerts: List[str] = None
    recommendations: List[str] = None
    
    # Version and tracking
    version: str = "v2.0"
    previous_plan_id: Optional[str] = None

class CarePlanService:
    """Core service for generating context-aware care plans"""
    
    def __init__(
        self, 
        db: AsyncSession,
        cache_service: Optional[CacheLayerService] = None
    ):
        self.db = db
        self.cache = cache_service or CacheLayerService()
        
        # Initialize dependent services
        self.context_service = ContextAggregationService(db)
        self.rule_engine = RuleEngineService()
        self.ml_service = MLAdjustmentService()
        self.rationale_service = RationaleBuilderService()
        self.env_service = EnvironmentalDataService(db)
        
        # Load species rules configuration
        self.species_rules = None
        asyncio.create_task(self._load_species_rules())
    
    async def generate_care_plan(self, request: CarePlanRequest) -> CarePlanResponse:
        """Generate a comprehensive care plan for a plant
        
        Args:
            request: Care plan generation request
            
        Returns:
            Complete care plan response with schedules and rationale
        """
        start_time = datetime.utcnow()
        generation_start = start_time.timestamp() * 1000
        
        try:
            logger.info(f"Generating care plan for plant {request.plant_id} (mode: {request.generation_mode.value})")
            
            # Check cache first (unless force regenerate)
            if not request.force_regenerate:
                cached_plan = await self._get_cached_plan(request.plant_id)
                if cached_plan and self._is_plan_valid(cached_plan):
                    logger.info(f"Returning cached plan for plant {request.plant_id}")
                    return cached_plan
            
            # Step 1: Aggregate context from all sources
            context = await self._aggregate_context(request)
            
            # Step 2: Apply species-specific rules
            rule_result = await self._apply_species_rules(context, request)
            
            # Step 3: Apply ML adjustments
            ml_adjustments = await self._apply_ml_adjustments(context, rule_result, request)
            
            # Step 4: Generate final schedules
            schedules = await self._generate_schedules(rule_result, ml_adjustments, request)
            
            # Step 5: Build rationale and explanations
            rationale = None
            if request.include_rationale:
                rationale = await self._build_rationale(context, rule_result, ml_adjustments, request)
            
            # Step 6: Create and persist care plan
            care_plan = await self._create_care_plan(request, schedules, rationale, context)
            
            # Step 7: Build response
            generation_time = (datetime.utcnow().timestamp() * 1000) - generation_start
            response = await self._build_response(care_plan, generation_time, context)
            
            # Step 8: Cache the result
            await self._cache_plan(response)
            
            logger.info(f"Care plan generated for plant {request.plant_id} in {generation_time:.1f}ms")
            return response
            
        except Exception as e:
            logger.error(f"Error generating care plan for plant {request.plant_id}: {e}")
            raise
    
    async def get_care_plan(self, plant_id: int, plan_id: Optional[str] = None) -> Optional[CarePlanResponse]:
        """Get existing care plan by ID or latest for plant
        
        Args:
            plant_id: Plant ID
            plan_id: Specific plan ID (optional, defaults to latest)
            
        Returns:
            Care plan response or None if not found
        """
        try:
            # Try cache first
            if not plan_id:
                cached_plan = await self._get_cached_plan(plant_id)
                if cached_plan:
                    return cached_plan
            
            # Query database
            query = select(CarePlanV2)
            
            if plan_id:
                query = query.where(CarePlanV2.id == plan_id)
            else:
                query = query.where(
                    CarePlanV2.plant_id == plant_id
                ).order_by(desc(CarePlanV2.created_at)).limit(1)
            
            result = await self.db.execute(query)
            care_plan = result.scalar_one_or_none()
            
            if not care_plan:
                return None
            
            # Convert to response format
            response = await self._db_to_response(care_plan)
            
            # Cache if it's the latest plan
            if not plan_id:
                await self._cache_plan(response)
            
            return response
            
        except Exception as e:
            logger.error(f"Error getting care plan for plant {plant_id}: {e}")
            return None
    
    async def acknowledge_care_plan(self, plant_id: int, plan_id: str, user_id: int) -> bool:
        """Mark care plan as acknowledged by user
        
        Args:
            plant_id: Plant ID
            plan_id: Plan ID to acknowledge
            user_id: User ID
            
        Returns:
            True if successful, False otherwise
        """
        try:
            query = select(CarePlanV2).where(
                and_(
                    CarePlanV2.id == plan_id,
                    CarePlanV2.plant_id == plant_id
                )
            )
            
            result = await self.db.execute(query)
            care_plan = result.scalar_one_or_none()
            
            if not care_plan:
                return False
            
            # TODO: Add acknowledgment tracking to CarePlanV2 model
            # For now, just log the acknowledgment
            logger.info(f"Care plan {plan_id} acknowledged by user {user_id}")
            
            await self.db.commit()
            
            # Invalidate cache
            await self.cache.invalidate_by_tags([f"plant:{plant_id}"])
            
            logger.info(f"Care plan {plan_id} acknowledged by user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error acknowledging care plan {plan_id}: {e}")
            await self.db.rollback()
            return False
    
    async def get_care_plan_history(
        self, 
        plant_id: int, 
        limit: int = 10,
        offset: int = 0
    ) -> List[Dict[str, Any]]:
        """Get care plan history for a plant
        
        Args:
            plant_id: Plant ID
            limit: Maximum number of plans to return
            offset: Number of plans to skip
            
        Returns:
            List of care plan summaries
        """
        try:
            query = select(CarePlanV2).where(
                CarePlanV2.plant_id == plant_id
            ).order_by(desc(CarePlanV2.created_at)).limit(limit).offset(offset)
            
            result = await self.db.execute(query)
            care_plans = result.scalars().all()
            
            history = []
            for plan in care_plans:
                history.append({
                    'plan_id': str(plan.id),
                    'version': plan.version,
                    'created_at': plan.created_at.isoformat(),
                    'valid_from': plan.valid_from.isoformat(),
                    'valid_to': plan.valid_to.isoformat() if plan.valid_to else None,
                    'confidence_score': plan.confidence_score,
                    'is_active': plan.is_active
                })
            
            return history
            
        except Exception as e:
            logger.error(f"Error getting care plan history for plant {plant_id}: {e}")
            return []
    
    async def _aggregate_context(self, request: CarePlanRequest) -> PlantContext:
        """Aggregate context from all available sources"""
        return await self.context_service.aggregate_plant_context(
            request.plant_id,
            include_environmental=True,
            include_health_metrics=True,
            include_user_behavior=True
        )
    
    async def _apply_species_rules(self, context: PlantContext, request: CarePlanRequest) -> RuleResult:
        """Apply species-specific care rules"""
        if not self.species_rules:
            await self._load_species_rules()
        
        return await self.rule_engine.apply_rules(
            context,
            self.species_rules,
            generation_mode=request.generation_mode
        )
    
    async def _apply_ml_adjustments(
        self, 
        context: PlantContext, 
        rule_result: RuleResult, 
        request: CarePlanRequest
    ) -> MLPrediction:
        """Apply ML-based adjustments to rule-based recommendations"""
        return await self.ml_service.predict_adjustments(
            context,
            rule_result,
            target_days=request.target_days
        )
    
    async def _generate_schedules(
        self, 
        rule_result: RuleResult, 
        ml_adjustments: MLPrediction, 
        request: CarePlanRequest
    ) -> Dict[str, Any]:
        """Generate final watering and fertilizer schedules"""
        # Apply ML adjustments to rule-based recommendations
        watering_interval = rule_result.watering_interval_days
        watering_amount = rule_result.watering_amount_ml
        fertilizer_interval = rule_result.fertilizer_interval_days
        
        # Apply ML adjustments if confidence is high enough
        if ml_adjustments.confidence_score >= 0.7:
            watering_interval = max(1, int(watering_interval * (1 + ml_adjustments.watering_adjustment)))
            watering_amount = max(50, int(watering_amount * (1 + ml_adjustments.amount_adjustment)))
            fertilizer_interval = max(7, int(fertilizer_interval * (1 + ml_adjustments.fertilizer_adjustment)))
        
        # Generate schedule dates
        start_date = datetime.utcnow().date()
        watering_dates = []
        fertilizer_dates = []
        
        # Generate watering schedule
        current_date = start_date
        for _ in range(request.target_days // watering_interval + 1):
            if (current_date - start_date).days <= request.target_days:
                watering_dates.append({
                    'date': current_date.isoformat(),
                    'amount_ml': watering_amount,
                    'notes': rule_result.watering_notes
                })
            current_date += timedelta(days=watering_interval)
        
        # Generate fertilizer schedule
        current_date = start_date + timedelta(days=fertilizer_interval)
        for _ in range(request.target_days // fertilizer_interval + 1):
            if (current_date - start_date).days <= request.target_days:
                fertilizer_dates.append({
                    'date': current_date.isoformat(),
                    'type': rule_result.fertilizer_type,
                    'notes': rule_result.fertilizer_notes
                })
            current_date += timedelta(days=fertilizer_interval)
        
        return {
            'watering': {
                'interval_days': watering_interval,
                'amount_ml': watering_amount,
                'schedule': watering_dates,
                'soil_moisture_target': rule_result.soil_moisture_target
            },
            'fertilizer': {
                'interval_days': fertilizer_interval,
                'type': rule_result.fertilizer_type,
                'schedule': fertilizer_dates
            },
            'light': {
                'ppfd_min': rule_result.light_ppfd_min,
                'ppfd_max': rule_result.light_ppfd_max,
                'recommendation': rule_result.light_recommendation
            }
        }
    
    async def _build_rationale(
        self, 
        context: PlantContext, 
        rule_result: RuleResult, 
        ml_adjustments: MLPrediction, 
        request: CarePlanRequest
    ) -> Dict[str, Any]:
        """Build comprehensive rationale for the care plan"""
        rationale_data = RationaleData(
            plant_context=context,
            rule_result=rule_result,
            ml_prediction=ml_adjustments,
            generation_mode=request.generation_mode
        )
        
        return await self.rationale_service.build_rationale(rationale_data)
    
    async def _create_care_plan(
        self, 
        request: CarePlanRequest, 
        schedules: Dict[str, Any], 
        rationale: Optional[Dict[str, Any]],
        context: PlantContext
    ) -> CarePlanV2:
        """Create and persist care plan in database"""
        
        # Get the latest version for this plant
        latest_version_query = select(func.max(CarePlanV2.version)).where(
            CarePlanV2.plant_id == request.plant_id
        )
        result = await self.db.execute(latest_version_query)
        latest_version = result.scalar() or 0
        new_version = latest_version + 1
        
        # Build plan JSON structure
        plan_json = {
            "watering": {
                "interval_days": schedules['watering']['interval_days'],
                "amount_ml": schedules['watering']['amount_ml'],
                "schedule": schedules['watering']['schedule']
            },
            "fertilizer": {
                "interval_days": schedules['fertilizer']['interval_days'],
                "type": schedules['fertilizer']['type'],
                "schedule": schedules['fertilizer']['schedule']
            },
            "light_target": {
                "ppfd_min": schedules['light']['ppfd_min'],
                "ppfd_max": schedules['light']['ppfd_max'],
                "recommendation": schedules['light']['recommendation']
            },
            "alerts": getattr(context, 'alerts', []),
            "review_in_days": request.target_days
        }
        
        # Build rationale JSON structure
        rationale_json = {
            "features": {
                "confidence_score": context.confidence_score,
                "data_sources": context.data_sources
            },
            "rules_fired": [],  # Would be populated from rule engine
            "confidence": context.confidence_score
        }
        
        if rationale:
            rationale_json.update(rationale)
        
        # Create main care plan record
        care_plan = CarePlanV2(
            user_id=request.user_id,
            plant_id=request.plant_id,
            version=new_version,
            plan=plan_json,
            rationale=rationale_json,
            valid_from=datetime.utcnow(),
            valid_to=datetime.utcnow() + timedelta(days=request.target_days)
        )
        
        self.db.add(care_plan)
        await self.db.commit()
        return care_plan
    
    async def _build_response(
        self, 
        care_plan: CarePlanV2, 
        generation_time_ms: float,
        context: PlantContext
    ) -> CarePlanResponse:
        """Build care plan response from database model"""
        
        # Extract data from JSON structure
        plan_data = care_plan.plan
        rationale_data = care_plan.rationale
        
        return CarePlanResponse(
            plan_id=str(care_plan.id),
            plant_id=care_plan.plant_id,
            status=CarePlanStatus.ACTIVE,  # CarePlanV2 uses is_active property
            generated_at=care_plan.created_at,
            valid_until=care_plan.valid_to,
            watering_schedule=plan_data.get('watering', {}),
            fertilizer_schedule=plan_data.get('fertilizer', {}),
            light_targets=plan_data.get('light_target', {}),
            confidence_score=care_plan.confidence_score,
            generation_time_ms=generation_time_ms,
            data_sources=rationale_data.get('features', {}).get('data_sources', []),
            rationale=rationale_data,
            alerts=plan_data.get('alerts', []),
            recommendations=getattr(context, 'recommendations', []),
            version=f"v2.{care_plan.version}"
        )
    
    async def _get_cached_plan(self, plant_id: int) -> Optional[CarePlanResponse]:
        """Get cached care plan for plant"""
        return await self.cache.get_care_plan(plant_id)
    
    async def _cache_plan(self, response: CarePlanResponse):
        """Cache care plan response"""
        await self.cache.set_care_plan(
            response.plant_id,
            asdict(response)
        )
    
    def _is_plan_valid(self, plan: CarePlanResponse) -> bool:
        """Check if cached plan is still valid"""
        return (
            plan.valid_until > datetime.utcnow() and
            plan.status in [CarePlanStatus.ACTIVE, CarePlanStatus.ACKNOWLEDGED]
        )
    
    async def _db_to_response(self, care_plan: CarePlanV2) -> CarePlanResponse:
        """Convert database model to response format"""
        # This is a simplified version - implement full conversion
        return CarePlanResponse(
            plan_id=str(care_plan.id),
            plant_id=care_plan.plant_id,
            status=CarePlanStatus.ACTIVE if care_plan.is_active else CarePlanStatus.EXPIRED,
            generated_at=care_plan.created_at,
            valid_until=care_plan.valid_to,
            watering_schedule=care_plan.plan.get('watering', {}),
            fertilizer_schedule=care_plan.plan.get('fertilizer', {}),
            light_targets=care_plan.plan.get('light_target', {}),
            confidence_score=care_plan.confidence_score,
            generation_time_ms=0.0,  # Not stored in CarePlanV2
            data_sources=care_plan.rationale.get('features', {}).get('data_sources', []),
            version=f"v2.{care_plan.version}"
        )
    
    async def _load_species_rules(self):
        """Load species rules from configuration file"""
        try:
            import os
            rules_path = os.path.join(settings.BASE_DIR, 'backend', 'config', 'species_rules.yaml')
            
            if os.path.exists(rules_path):
                with open(rules_path, 'r') as f:
                    self.species_rules = yaml.safe_load(f)
                logger.info("Species rules loaded successfully")
            else:
                logger.warning(f"Species rules file not found: {rules_path}")
                self.species_rules = {}  # Empty rules as fallback
                
        except Exception as e:
            logger.error(f"Error loading species rules: {e}")
            self.species_rules = {}

# Dependency injection helper
async def get_care_plan_service(db: AsyncSession):
    """Get care plan service instance"""
    return CarePlanService(db)