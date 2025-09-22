"""Core care plan service.

This module provides the main orchestration service for generating context-aware care plans.
It coordinates between context aggregation, rule engine, ML adjustments, and rationale building
to produce comprehensive, explainable care recommendations.
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID, uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import and_, desc

from app.models.care_plan import CarePlanV2
from app.models.user_plant import UserPlant
from app.services.context_aggregation_service import ContextAggregationService
from app.services.rule_engine_service import RuleEngineService, CareRecommendation
from app.services.ml_adjustment_service import MLAdjustmentService
from app.services.rationale_builder_service import RationaleBuilderService


class CarePlanService:
    """Main service for generating and managing context-aware care plans."""
    
    def __init__(self, db: AsyncSession):
        """Initialize the care plan service.
        
        Args:
            db: Database session
        """
        self.db = db
        self.context_service = ContextAggregationService(db)
        self.rule_engine = RuleEngineService(db)
        self.ml_service = MLAdjustmentService(db)
        self.rationale_service = RationaleBuilderService()
    
    async def generate_care_plan(
        self,
        plant_id: UUID,
        user_id: UUID,
        context_window_days: int = 30,
        force_regenerate: bool = False
    ) -> Dict[str, Any]:
        """Generate a comprehensive context-aware care plan.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            context_window_days: Days of historical data to consider
            force_regenerate: Force regeneration even if recent plan exists
            
        Returns:
            Complete care plan with recommendations and rationale
        """
        # Check if recent plan exists (unless force regenerate)
        if not force_regenerate:
            existing_plan = await self._get_recent_plan(plant_id, hours_threshold=24)
            if existing_plan:
                return await self._format_existing_plan(existing_plan)
        
        # Step 1: Aggregate context data
        context = await self.context_service.aggregate_plant_context(
            plant_id, user_id, context_window_days
        )
        
        # Step 2: Generate base recommendations using rule engine
        base_recommendations, rule_metadata = await self.rule_engine.generate_care_recommendations(
            plant_id, user_id, context_window_days
        )
        
        # Step 3: Apply ML adjustments
        adjusted_recommendations, ml_metadata = await self.ml_service.adjust_recommendations(
            plant_id, user_id, base_recommendations, context
        )
        
        # Step 4: Build rationale and explanations
        rationale = self.rationale_service.build_care_plan_rationale(
            adjusted_recommendations,
            context,
            rule_metadata.get("applied_rules", []),
            ml_metadata.get("predictions", {}),
            ml_metadata.get("adjustment_details", [])
        )
        
        # Step 5: Structure the care plan
        care_plan = await self._structure_care_plan(
            plant_id,
            user_id,
            adjusted_recommendations,
            context,
            rule_metadata,
            ml_metadata,
            rationale
        )
        
        # Step 6: Save to database
        saved_plan = await self._save_care_plan(care_plan)
        
        # Step 7: Format response
        return await self._format_care_plan_response(saved_plan, care_plan)
    
    async def get_care_plan(
        self,
        plant_id: UUID,
        user_id: UUID,
        version: Optional[int] = None
    ) -> Optional[Dict[str, Any]]:
        """Get existing care plan for a plant.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            version: Specific version to retrieve (latest if None)
            
        Returns:
            Care plan data or None if not found
        """
        query = select(CarePlanV2).where(
            and_(
                CarePlanV2.plant_id == plant_id,
                CarePlanV2.user_id == user_id
            )
        )
        
        if version is not None:
            query = query.where(CarePlanV2.version == version)
        else:
            query = query.order_by(desc(CarePlanV2.version)).limit(1)
        
        result = await self.db.execute(query)
        plan = result.scalar_one_or_none()
        
        if not plan:
            return None
        
        return await self._format_existing_plan(plan)
    
    async def get_active_care_plan(
        self,
        plant_id: UUID,
        user_id: UUID
    ) -> Optional[Dict[str, Any]]:
        """Get currently active care plan for a plant.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            
        Returns:
            Active care plan or None if not found
        """
        now = datetime.utcnow()
        
        result = await self.db.execute(
            select(CarePlanV2).where(
                and_(
                    CarePlanV2.plant_id == plant_id,
                    CarePlanV2.user_id == user_id,
                    CarePlanV2.valid_from <= now,
                    CarePlanV2.valid_to.is_(None) | (CarePlanV2.valid_to > now)
                )
            ).order_by(desc(CarePlanV2.version)).limit(1)
        )
        
        plan = result.scalar_one_or_none()
        
        if not plan:
            return None
        
        return await self._format_existing_plan(plan)
    
    async def get_care_plan_history(
        self,
        plant_id: UUID,
        user_id: UUID,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get care plan history for a plant.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            limit: Maximum number of plans to return
            
        Returns:
            List of historical care plans
        """
        result = await self.db.execute(
            select(CarePlanV2).where(
                and_(
                    CarePlanV2.plant_id == plant_id,
                    CarePlanV2.user_id == user_id
                )
            ).order_by(desc(CarePlanV2.created_at)).limit(limit)
        )
        
        plans = result.scalars().all()
        
        history = []
        for plan in plans:
            formatted_plan = await self._format_existing_plan(plan)
            history.append(formatted_plan)
        
        return history
    
    async def invalidate_care_plan(
        self,
        plant_id: UUID,
        user_id: UUID,
        version: Optional[int] = None
    ) -> bool:
        """Invalidate a care plan (mark as expired).
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            version: Specific version to invalidate (latest if None)
            
        Returns:
            True if plan was invalidated, False if not found
        """
        query = select(CarePlanV2).where(
            and_(
                CarePlanV2.plant_id == plant_id,
                CarePlanV2.user_id == user_id,
                CarePlanV2.valid_to.is_(None)  # Only active plans
            )
        )
        
        if version is not None:
            query = query.where(CarePlanV2.version == version)
        else:
            query = query.order_by(desc(CarePlanV2.version)).limit(1)
        
        result = await self.db.execute(query)
        plan = result.scalar_one_or_none()
        
        if not plan:
            return False
        
        plan.valid_to = datetime.utcnow()
        await self.db.commit()
        
        return True
    
    async def _get_recent_plan(
        self,
        plant_id: UUID,
        hours_threshold: int = 24
    ) -> Optional[CarePlanV2]:
        """Get recent care plan within threshold.
        
        Args:
            plant_id: Plant ID
            hours_threshold: Hours threshold for "recent"
            
        Returns:
            Recent care plan or None
        """
        cutoff_time = datetime.utcnow() - timedelta(hours=hours_threshold)
        
        result = await self.db.execute(
            select(CarePlanV2).where(
                and_(
                    CarePlanV2.plant_id == plant_id,
                    CarePlanV2.created_at >= cutoff_time
                )
            ).order_by(desc(CarePlanV2.created_at)).limit(1)
        )
        
        return result.scalar_one_or_none()
    
    async def _structure_care_plan(
        self,
        plant_id: UUID,
        user_id: UUID,
        recommendations: List[CareRecommendation],
        context: Dict[str, Any],
        rule_metadata: Dict[str, Any],
        ml_metadata: Dict[str, Any],
        rationale: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Structure the complete care plan.
        
        Args:
            plant_id: Plant ID
            user_id: User ID
            recommendations: Final recommendations
            context: Plant context data
            rule_metadata: Rule engine metadata
            ml_metadata: ML service metadata
            rationale: Rationale and explanations
            
        Returns:
            Structured care plan
        """
        # Get next version number
        next_version = await self._get_next_version(plant_id)
        
        # Structure watering schedule
        watering_recs = [r for r in recommendations if r.action_type == "watering"]
        watering_schedule = self._build_watering_schedule(watering_recs)
        
        # Structure fertilizer schedule
        fertilizer_recs = [r for r in recommendations if r.action_type == "fertilizing"]
        fertilizer_schedule = self._build_fertilizer_schedule(fertilizer_recs)
        
        # Structure light requirements
        light_recs = [r for r in recommendations if r.action_type == "light_adjustment"]
        light_requirements = self._build_light_requirements(light_recs, context)
        
        # Extract alerts
        alerts = self._extract_alerts(recommendations)
        
        # Calculate review date
        review_date = self._calculate_review_date(recommendations, context)
        
        # Build plan structure
        plan_data = {
            "watering": watering_schedule,
            "fertilizer": fertilizer_schedule,
            "light_target": light_requirements,
            "alerts": alerts,
            "review_in_days": review_date,
            "environmental_targets": self._build_environmental_targets(context),
            "care_calendar": self._build_care_calendar(recommendations),
            "priority_actions": self._extract_priority_actions(recommendations)
        }
        
        return {
            "id": str(uuid4()),
            "user_id": str(user_id),
            "plant_id": str(plant_id),
            "version": next_version,
            "plan": plan_data,
            "rationale": rationale,
            "valid_from": datetime.utcnow(),
            "valid_to": None,  # Active until replaced or invalidated
            "metadata": {
                "generation_timestamp": datetime.utcnow().isoformat(),
                "context_window_days": context.get("contextual_metadata", {}).get("context_window_days", 30),
                "data_completeness_score": context.get("contextual_metadata", {}).get("data_completeness_score", 0.5),
                "rules_applied": rule_metadata.get("rules_applied", 0),
                "ml_adjustments": ml_metadata.get("adjustments_made", 0),
                "total_recommendations": len(recommendations),
                "confidence_distribution": self._calculate_confidence_distribution(recommendations)
            }
        }
    
    def _build_watering_schedule(self, watering_recs: List[CareRecommendation]) -> Dict[str, Any]:
        """Build watering schedule from recommendations.
        
        Args:
            watering_recs: Watering recommendations
            
        Returns:
            Watering schedule structure
        """
        if not watering_recs:
            return {
                "interval_days": 7,
                "amount_ml": 200,
                "next_due": (datetime.utcnow() + timedelta(days=7)).isoformat(),
                "confidence": 0.5,
                "notes": "Default watering schedule"
            }
        
        # Use the highest confidence watering recommendation
        best_rec = max(watering_recs, key=lambda r: r.confidence)
        
        interval_days = best_rec.parameters.get("interval_days", 7)
        amount_ml = best_rec.parameters.get("amount_ml", 200)
        
        return {
            "interval_days": interval_days,
            "amount_ml": amount_ml,
            "next_due": (datetime.utcnow() + timedelta(days=interval_days)).isoformat(),
            "confidence": best_rec.confidence,
            "notes": best_rec.recommendation,
            "ml_adjusted": best_rec.parameters.get("ml_adjusted", False)
        }
    
    def _build_fertilizer_schedule(self, fertilizer_recs: List[CareRecommendation]) -> Dict[str, Any]:
        """Build fertilizer schedule from recommendations.
        
        Args:
            fertilizer_recs: Fertilizer recommendations
            
        Returns:
            Fertilizer schedule structure
        """
        if not fertilizer_recs:
            return {
                "interval_days": 14,
                "type": "balanced",
                "next_due": (datetime.utcnow() + timedelta(days=14)).isoformat(),
                "confidence": 0.5,
                "notes": "Default fertilizer schedule"
            }
        
        best_rec = max(fertilizer_recs, key=lambda r: r.confidence)
        
        interval_days = best_rec.parameters.get("interval_days", 14)
        fertilizer_type = best_rec.parameters.get("fertilizer_type", "balanced")
        
        return {
            "interval_days": interval_days,
            "type": fertilizer_type,
            "next_due": (datetime.utcnow() + timedelta(days=interval_days)).isoformat(),
            "confidence": best_rec.confidence,
            "notes": best_rec.recommendation
        }
    
    def _build_light_requirements(
        self,
        light_recs: List[CareRecommendation],
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Build light requirements from recommendations and context.
        
        Args:
            light_recs: Light adjustment recommendations
            context: Plant context data
            
        Returns:
            Light requirements structure
        """
        # Get species light requirements
        plant_info = context.get("plant_info", {})
        light_req = plant_info.get("light_requirements", "medium")
        
        # Default ranges based on species requirements
        light_ranges = {
            "low": {"ppfd_min": 100, "ppfd_max": 300},
            "medium": {"ppfd_min": 300, "ppfd_max": 600},
            "high": {"ppfd_min": 600, "ppfd_max": 1000}
        }
        
        default_range = light_ranges.get(light_req, light_ranges["medium"])
        
        if light_recs:
            best_rec = max(light_recs, key=lambda r: r.confidence)
            target_ppfd = best_rec.parameters.get("target_ppfd", default_range["ppfd_min"])
            
            return {
                "ppfd_min": max(default_range["ppfd_min"], target_ppfd - 100),
                "ppfd_max": min(default_range["ppfd_max"], target_ppfd + 100),
                "recommendation": best_rec.recommendation,
                "confidence": best_rec.confidence
            }
        
        return {
            "ppfd_min": default_range["ppfd_min"],
            "ppfd_max": default_range["ppfd_max"],
            "recommendation": f"Maintain {light_req} light levels for optimal growth",
            "confidence": 0.7
        }
    
    def _extract_alerts(self, recommendations: List[CareRecommendation]) -> List[str]:
        """Extract alerts from recommendations.
        
        Args:
            recommendations: List of recommendations
            
        Returns:
            List of alert messages
        """
        alerts = []
        
        # High priority recommendations become alerts
        high_priority = [r for r in recommendations if r.priority == "high"]
        for rec in high_priority:
            alerts.append(f"High Priority: {rec.recommendation}")
        
        # Health-related recommendations
        health_recs = [r for r in recommendations if r.action_type in ["health_check", "preventive_care"]]
        for rec in health_recs:
            alerts.append(f"Health Alert: {rec.recommendation}")
        
        return alerts[:5]  # Limit to 5 alerts
    
    def _calculate_review_date(self, recommendations: List[CareRecommendation], context: Dict[str, Any]) -> int:
        """Calculate when the care plan should be reviewed.
        
        Args:
            recommendations: List of recommendations
            context: Plant context data
            
        Returns:
            Days until review
        """
        # Base review period
        base_days = 14
        
        # Adjust based on plant health
        health_indicators = context.get("plant_health_indicators", {})
        health_trend = health_indicators.get("health_trend", "stable")
        
        if health_trend == "declining":
            base_days = 7  # Review sooner if health declining
        elif health_trend == "improving":
            base_days = 21  # Can wait longer if improving
        
        # Adjust based on recommendation confidence
        avg_confidence = sum(r.confidence for r in recommendations) / len(recommendations) if recommendations else 0.5
        
        if avg_confidence < 0.6:
            base_days = max(7, base_days - 3)  # Review sooner if low confidence
        
        return base_days
    
    def _build_environmental_targets(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """Build environmental targets from context.
        
        Args:
            context: Plant context data
            
        Returns:
            Environmental targets
        """
        plant_info = context.get("plant_info", {})
        
        return {
            "temperature": {
                "min": 18,
                "max": 26,
                "optimal": 22
            },
            "humidity": {
                "min": 40,
                "max": 70,
                "optimal": 55
            },
            "air_circulation": "moderate",
            "notes": f"Environmental targets for {plant_info.get('species_name', 'this plant')}"
        }
    
    def _build_care_calendar(self, recommendations: List[CareRecommendation]) -> List[Dict[str, Any]]:
        """Build care calendar from recommendations.
        
        Args:
            recommendations: List of recommendations
            
        Returns:
            Care calendar entries
        """
        calendar = []
        now = datetime.utcnow()
        
        for rec in recommendations:
            if rec.action_type in ["watering", "fertilizing"]:
                interval = rec.parameters.get("interval_days", 7)
                next_due = now + timedelta(days=interval)
                
                calendar.append({
                    "action": rec.action_type,
                    "due_date": next_due.isoformat(),
                    "priority": rec.priority,
                    "description": rec.recommendation
                })
        
        # Sort by due date
        calendar.sort(key=lambda x: x["due_date"])
        
        return calendar[:10]  # Limit to next 10 activities
    
    def _extract_priority_actions(self, recommendations: List[CareRecommendation]) -> List[Dict[str, Any]]:
        """Extract priority actions from recommendations.
        
        Args:
            recommendations: List of recommendations
            
        Returns:
            Priority actions
        """
        priority_actions = []
        
        # Get high priority recommendations
        high_priority = [r for r in recommendations if r.priority == "high"]
        
        for rec in high_priority:
            priority_actions.append({
                "action": rec.action_type,
                "description": rec.recommendation,
                "confidence": rec.confidence,
                "urgency": "immediate" if rec.confidence > 0.8 else "soon"
            })
        
        return priority_actions
    
    def _calculate_confidence_distribution(self, recommendations: List[CareRecommendation]) -> Dict[str, int]:
        """Calculate confidence distribution of recommendations.
        
        Args:
            recommendations: List of recommendations
            
        Returns:
            Confidence distribution
        """
        if not recommendations:
            return {"high": 0, "medium": 0, "low": 0}
        
        high = len([r for r in recommendations if r.confidence > 0.8])
        medium = len([r for r in recommendations if 0.6 <= r.confidence <= 0.8])
        low = len([r for r in recommendations if r.confidence < 0.6])
        
        return {"high": high, "medium": medium, "low": low}
    
    async def _get_next_version(self, plant_id: UUID) -> int:
        """Get next version number for a plant's care plan.
        
        Args:
            plant_id: Plant ID
            
        Returns:
            Next version number
        """
        result = await self.db.execute(
            select(CarePlanV2.version).where(
                CarePlanV2.plant_id == plant_id
            ).order_by(desc(CarePlanV2.version)).limit(1)
        )
        
        latest_version = result.scalar_one_or_none()
        return (latest_version or 0) + 1
    
    async def _save_care_plan(self, care_plan_data: Dict[str, Any]) -> CarePlanV2:
        """Save care plan to database.
        
        Args:
            care_plan_data: Care plan data to save
            
        Returns:
            Saved care plan model
        """
        care_plan = CarePlanV2(
            id=UUID(care_plan_data["id"]),
            user_id=UUID(care_plan_data["user_id"]),
            plant_id=UUID(care_plan_data["plant_id"]),
            version=care_plan_data["version"],
            plan=care_plan_data["plan"],
            rationale=care_plan_data["rationale"],
            valid_from=care_plan_data["valid_from"],
            valid_to=care_plan_data["valid_to"],
            created_at=datetime.utcnow()
        )
        
        self.db.add(care_plan)
        await self.db.commit()
        await self.db.refresh(care_plan)
        
        return care_plan
    
    async def _format_care_plan_response(self, saved_plan: CarePlanV2, care_plan_data: Dict[str, Any]) -> Dict[str, Any]:
        """Format care plan response.
        
        Args:
            saved_plan: Saved care plan model
            care_plan_data: Original care plan data
            
        Returns:
            Formatted response
        """
        return {
            "id": str(saved_plan.id),
            "plant_id": str(saved_plan.plant_id),
            "version": saved_plan.version,
            "plan": saved_plan.plan,
            "rationale": saved_plan.rationale,
            "valid_from": saved_plan.valid_from.isoformat(),
            "valid_to": saved_plan.valid_to.isoformat() if saved_plan.valid_to else None,
            "created_at": saved_plan.created_at.isoformat(),
            "is_active": saved_plan.is_active,
            "metadata": care_plan_data.get("metadata", {})
        }
    
    async def _format_existing_plan(self, plan: CarePlanV2) -> Dict[str, Any]:
        """Format existing care plan for response.
        
        Args:
            plan: Care plan model
            
        Returns:
            Formatted plan data
        """
        return {
            "id": str(plan.id),
            "plant_id": str(plan.plant_id),
            "version": plan.version,
            "plan": plan.plan,
            "rationale": plan.rationale,
            "valid_from": plan.valid_from.isoformat(),
            "valid_to": plan.valid_to.isoformat() if plan.valid_to else None,
            "created_at": plan.created_at.isoformat(),
            "is_active": plan.is_active,
            "watering_schedule": plan.watering_schedule,
            "fertilizer_schedule": plan.fertilizer_schedule,
            "light_requirements": plan.light_requirements,
            "active_alerts": plan.active_alerts,
            "review_due_date": plan.review_due_date.isoformat() if plan.review_due_date else None,
            "confidence_score": plan.confidence_score,
            "applied_rules": plan.applied_rules,
            "context_features": plan.context_features
        }