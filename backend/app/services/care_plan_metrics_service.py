"""Care Plan Metrics Service for LeafWise Platform.

This service provides async methods for recording care plan generation metrics,
performance tracking, SLA monitoring, and error reporting. It wraps the 
monitoring functionality from app.monitoring.care_plan_metrics.
"""

import logging
from typing import Optional, Dict, Any
from uuid import UUID
from datetime import datetime

from app.monitoring.care_plan_metrics import (
    metrics_collector,
    care_plan_requests_total,
    care_plan_generation_errors
)

logger = logging.getLogger(__name__)


class CarePlanMetricsService:
    """Service for recording care plan generation metrics and performance data."""
    
    def __init__(self):
        """Initialize the metrics service."""
        self.collector = metrics_collector
    
    async def record_generation_metrics(
        self,
        plant_id: UUID,
        user_id: UUID,
        generation_time_ms: float,
        request_id: Optional[str] = None,
        plant_species: Optional[str] = None,
        complexity: str = "medium"
    ) -> None:
        """Record metrics for a successful care plan generation.
        
        Args:
            plant_id: ID of the plant
            user_id: ID of the user
            generation_time_ms: Time taken to generate the plan in milliseconds
            request_id: Optional request ID for tracing
            plant_species: Optional plant species for categorization
            complexity: Complexity level of the generation (low, medium, high)
        """
        try:
            # Convert to seconds for Prometheus histogram
            duration_seconds = generation_time_ms / 1000.0
            
            # Record success in Prometheus counter
            care_plan_requests_total.labels(
                endpoint="generate",
                method="POST", 
                status="success"
            ).inc()
            
            # Record generation metrics using the collector
            self.collector.record_generation_metrics(
                plant_species=plant_species or "unknown",
                duration=duration_seconds,
                confidence=0.8,  # Default confidence for successful generation
                complexity=complexity,
                success=True
            )
            
            logger.info(
                f"Recorded care plan generation metrics: "
                f"plant_id={plant_id}, user_id={user_id}, "
                f"duration={generation_time_ms}ms, request_id={request_id}"
            )
            
        except Exception as e:
            logger.error(f"Failed to record generation metrics: {e}")
    
    async def record_sla_violation(
        self,
        plant_id: UUID,
        generation_time_ms: float,
        request_id: Optional[str] = None,
        sla_threshold_ms: float = 300.0
    ) -> None:
        """Record an SLA violation for care plan generation.
        
        Args:
            plant_id: ID of the plant
            generation_time_ms: Time taken to generate the plan in milliseconds
            request_id: Optional request ID for tracing
            sla_threshold_ms: SLA threshold in milliseconds (default 300ms)
        """
        try:
            # Record SLA violation
            self.collector.record_sla_violation(
                operation="care_plan_generation",
                duration_ms=generation_time_ms,
                threshold_ms=sla_threshold_ms
            )
            
            logger.warning(
                f"Care plan generation SLA violation: "
                f"plant_id={plant_id}, duration={generation_time_ms}ms, "
                f"threshold={sla_threshold_ms}ms, request_id={request_id}"
            )
            
        except Exception as e:
            logger.error(f"Failed to record SLA violation: {e}")
    
    async def record_generation_error(
        self,
        plant_id: UUID,
        user_id: UUID,
        error: str,
        request_id: Optional[str] = None,
        plant_species: Optional[str] = None,
        error_type: Optional[str] = None
    ) -> None:
        """Record an error during care plan generation.
        
        Args:
            plant_id: ID of the plant
            user_id: ID of the user
            error: Error message or description
            request_id: Optional request ID for tracing
            plant_species: Optional plant species for categorization
            error_type: Optional error type classification
        """
        try:
            # Determine error type from error message if not provided
            if not error_type:
                if "timeout" in error.lower():
                    error_type = "timeout"
                elif "database" in error.lower():
                    error_type = "database"
                elif "validation" in error.lower():
                    error_type = "validation"
                else:
                    error_type = "unknown"
            
            # Record error in Prometheus counter
            care_plan_requests_total.labels(
                endpoint="generate",
                method="POST",
                status="error"
            ).inc()
            
            care_plan_generation_errors.labels(
                error_type=error_type,
                plant_species=plant_species or "unknown"
            ).inc()
            
            # Record error using the collector
            self.collector.record_generation_metrics(
                plant_species=plant_species or "unknown",
                duration=0.0,
                confidence=0.0,
                complexity="unknown",
                success=False,
                error_type=error_type
            )
            
            logger.error(
                f"Recorded care plan generation error: "
                f"plant_id={plant_id}, user_id={user_id}, "
                f"error_type={error_type}, error={error}, request_id={request_id}"
            )
            
        except Exception as e:
            logger.error(f"Failed to record generation error: {e}")
    
    async def get_generation_stats(
        self,
        plant_species: Optional[str] = None,
        time_window_hours: int = 24
    ) -> Dict[str, Any]:
        """Get care plan generation statistics.
        
        Args:
            plant_species: Optional plant species filter
            time_window_hours: Time window for statistics in hours
            
        Returns:
            Dictionary containing generation statistics
        """
        try:
            # Get stats from the collector
            stats = self.collector.get_performance_stats()
            
            # Filter by plant species if specified
            if plant_species and plant_species in stats.get("by_species", {}):
                species_stats = stats["by_species"][plant_species]
                return {
                    "plant_species": plant_species,
                    "time_window_hours": time_window_hours,
                    "total_generations": species_stats.get("total_requests", 0),
                    "success_rate": species_stats.get("success_rate", 0.0),
                    "average_duration_ms": species_stats.get("avg_duration_ms", 0.0),
                    "sla_violations": species_stats.get("sla_violations", 0)
                }
            
            # Return overall stats
            return {
                "time_window_hours": time_window_hours,
                "total_generations": stats.get("total_requests", 0),
                "success_rate": stats.get("success_rate", 0.0),
                "average_duration_ms": stats.get("avg_duration_ms", 0.0),
                "sla_violations": stats.get("sla_violations", 0),
                "by_species": stats.get("by_species", {})
            }
            
        except Exception as e:
            logger.error(f"Failed to get generation stats: {e}")
            return {}


# Convenience function to get service instance
def get_care_plan_metrics_service() -> CarePlanMetricsService:
    """Get CarePlanMetricsService instance.
    
    Returns:
        CarePlanMetricsService instance
    """
    return CarePlanMetricsService()