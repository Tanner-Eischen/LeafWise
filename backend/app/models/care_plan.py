"""Care plan database model.

This module defines the CarePlanV2 model for storing context-aware care plans
with deterministic generation and explainable rationale.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Column, String, DateTime, ForeignKey, Integer, JSON, Index
from sqlalchemy.dialects.postgresql import UUID as PostgresUUID
from sqlalchemy.orm import relationship
from sqlalchemy.schema import UniqueConstraint

from app.core.database import Base


class CarePlanV2(Base):
    """Care plan v2 model for context-aware plant care recommendations.
    
    This model stores care plans with deterministic generation logic,
    explainable rationale, and versioning support.
    """
    
    __tablename__ = "care_plans_v2"
    
    id = Column(PostgresUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PostgresUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    plant_id = Column(PostgresUUID(as_uuid=True), ForeignKey("user_plants.id"), nullable=False)
    version = Column(Integer, nullable=False)
    
    # Care plan JSON structure following the specification
    plan = Column(JSON, nullable=False)
    # {
    #   "watering": {"interval_days": 6, "amount_ml": 250, "next_due": "2025-09-07T12:00:00Z"},
    #   "fertilizer": {"interval_days": 30, "type": "balanced_10_10_10"},
    #   "light_target": {"ppfd_min": 100, "ppfd_max": 250, "recommendation": "bright_indirect"},
    #   "alerts": ["heatwave_adjust_-1day", "repot_if_rootbound"],
    #   "review_in_days": 14
    # }
    
    # Rationale JSON for explainable AI
    rationale = Column(JSON, nullable=False)
    # {
    #   "features": {"avg_ppfd": 140, "temp_7d_max": 36},
    #   "rules_fired": ["heatwave_adjustment", "ficus_profile_v3"],
    #   "confidence": 0.78
    # }
    
    valid_from = Column(DateTime, nullable=False)
    valid_to = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    plant = relationship("UserPlant")
    
    # Constraints
    __table_args__ = (
        UniqueConstraint('plant_id', 'version', name='uq_care_plan_plant_version'),
        Index('ix_care_plans_v2_plant_id', 'plant_id'),
        Index('ix_care_plans_v2_user_id', 'user_id'),
        Index('ix_care_plans_v2_valid_from', 'valid_from'),
        Index('ix_care_plans_v2_created_at', 'created_at'),
    )
    
    def __repr__(self) -> str:
        return f"<CarePlanV2(id={self.id}, plant_id={self.plant_id}, version={self.version})>"
    
    @property
    def is_active(self) -> bool:
        """Check if this care plan is currently active.
        
        Returns:
            bool: True if the plan is within its valid date range
        """
        now = datetime.utcnow()
        return (self.valid_from <= now and 
                (self.valid_to is None or now <= self.valid_to))
    
    @property
    def watering_schedule(self) -> dict:
        """Get watering schedule from plan JSON.
        
        Returns:
            dict: Watering schedule details
        """
        return self.plan.get('watering', {})
    
    @property
    def fertilizer_schedule(self) -> dict:
        """Get fertilizer schedule from plan JSON.
        
        Returns:
            dict: Fertilizer schedule details
        """
        return self.plan.get('fertilizer', {})
    
    @property
    def light_requirements(self) -> dict:
        """Get light requirements from plan JSON.
        
        Returns:
            dict: Light target specifications
        """
        return self.plan.get('light_target', {})
    
    @property
    def active_alerts(self) -> list:
        """Get active alerts from plan JSON.
        
        Returns:
            list: List of alert strings
        """
        return self.plan.get('alerts', [])
    
    @property
    def review_due_date(self) -> Optional[datetime]:
        """Calculate when this plan should be reviewed.
        
        Returns:
            Optional[datetime]: Review due date if review_in_days is set
        """
        review_days = self.plan.get('review_in_days')
        if review_days:
            from datetime import timedelta
            return self.created_at + timedelta(days=review_days)
        return None
    
    @property
    def confidence_score(self) -> float:
        """Get confidence score from rationale.
        
        Returns:
            float: Confidence score between 0 and 1
        """
        return self.rationale.get('confidence', 0.0)
    
    @property
    def applied_rules(self) -> list:
        """Get list of rules that were applied in plan generation.
        
        Returns:
            list: List of rule names that were fired
        """
        return self.rationale.get('rules_fired', [])
    
    @property
    def context_features(self) -> dict:
        """Get context features used in plan generation.
        
        Returns:
            dict: Dictionary of feature names and values
        """
        return self.rationale.get('features', {})