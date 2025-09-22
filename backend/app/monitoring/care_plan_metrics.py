"""Performance monitoring and metrics collection for care plan services.

This module provides comprehensive monitoring capabilities for care plan
generation, including response times, success rates, and resource usage.
"""

import time
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from functools import wraps
from collections import defaultdict, deque
from dataclasses import dataclass, field
from threading import Lock

from prometheus_client import Counter, Histogram, Gauge, Summary
from app.core.config import settings


# Prometheus metrics
care_plan_requests_total = Counter(
    'care_plan_requests_total',
    'Total number of care plan requests',
    ['endpoint', 'method', 'status']
)

care_plan_generation_duration = Histogram(
    'care_plan_generation_duration_seconds',
    'Time spent generating care plans',
    ['plant_species', 'complexity']
)

care_plan_generation_errors = Counter(
    'care_plan_generation_errors_total',
    'Total number of care plan generation errors',
    ['error_type', 'plant_species']
)

care_plan_cache_hits = Counter(
    'care_plan_cache_hits_total',
    'Total number of cache hits for care plans',
    ['cache_type']
)

care_plan_ml_adjustment_time = Histogram(
    'care_plan_ml_adjustment_duration_seconds',
    'Time spent on ML adjustments',
    ['model_type']
)

care_plan_rule_engine_time = Histogram(
    'care_plan_rule_engine_duration_seconds',
    'Time spent in rule engine evaluation',
    ['rule_complexity']
)

care_plan_confidence_score = Histogram(
    'care_plan_confidence_score',
    'Confidence scores of generated care plans',
    ['plant_species']
)

active_care_plan_generations = Gauge(
    'active_care_plan_generations',
    'Number of currently active care plan generations'
)


@dataclass
class PerformanceMetrics:
    """Container for performance metrics data."""
    
    request_count: int = 0
    success_count: int = 0
    error_count: int = 0
    total_duration: float = 0.0
    min_duration: float = float('inf')
    max_duration: float = 0.0
    recent_durations: deque = field(default_factory=lambda: deque(maxlen=100))
    
    @property
    def success_rate(self) -> float:
        """Calculate success rate percentage."""
        if self.request_count == 0:
            return 0.0
        return (self.success_count / self.request_count) * 100
    
    @property
    def average_duration(self) -> float:
        """Calculate average duration."""
        if self.request_count == 0:
            return 0.0
        return self.total_duration / self.request_count
    
    @property
    def p95_duration(self) -> float:
        """Calculate 95th percentile duration."""
        if not self.recent_durations:
            return 0.0
        sorted_durations = sorted(self.recent_durations)
        index = int(len(sorted_durations) * 0.95)
        return sorted_durations[min(index, len(sorted_durations) - 1)]


class CarePlanMetricsCollector:
    """Centralized metrics collection for care plan operations."""
    
    def __init__(self):
        self.metrics: Dict[str, PerformanceMetrics] = defaultdict(PerformanceMetrics)
        self.lock = Lock()
        self.logger = logging.getLogger(__name__)
        
        # Performance thresholds
        self.generation_threshold_ms = 300
        self.ml_adjustment_threshold_ms = 100
        self.rule_engine_threshold_ms = 50
        
        # Alert thresholds
        self.error_rate_threshold = 5.0  # 5%
        self.response_time_threshold = 500  # 500ms
    
    def record_request(self, endpoint: str, method: str, status_code: int, 
                      duration: float, **kwargs):
        """Record API request metrics."""
        with self.lock:
            key = f"{endpoint}_{method}"
            metrics = self.metrics[key]
            
            metrics.request_count += 1
            metrics.total_duration += duration
            metrics.recent_durations.append(duration)
            
            if status_code < 400:
                metrics.success_count += 1
            else:
                metrics.error_count += 1
            
            metrics.min_duration = min(metrics.min_duration, duration)
            metrics.max_duration = max(metrics.max_duration, duration)
            
            # Update Prometheus metrics
            status = 'success' if status_code < 400 else 'error'
            care_plan_requests_total.labels(
                endpoint=endpoint, 
                method=method, 
                status=status
            ).inc()
            
            # Check for performance alerts
            self._check_performance_alerts(key, metrics, duration)
    
    def record_generation_metrics(self, plant_species: str, duration: float, 
                                confidence: float, complexity: str = 'medium',
                                success: bool = True, error_type: Optional[str] = None):
        """Record care plan generation specific metrics."""
        # Record generation duration
        care_plan_generation_duration.labels(
            plant_species=plant_species,
            complexity=complexity
        ).observe(duration)
        
        # Record confidence score
        if success:
            care_plan_confidence_score.labels(
                plant_species=plant_species
            ).observe(confidence)
        
        # Record errors
        if not success and error_type:
            care_plan_generation_errors.labels(
                error_type=error_type,
                plant_species=plant_species
            ).inc()
        
        # Performance alerting
        duration_ms = duration * 1000
        if duration_ms > self.generation_threshold_ms:
            self.logger.warning(
                f"Care plan generation exceeded threshold: {duration_ms:.2f}ms "
                f"for {plant_species} (threshold: {self.generation_threshold_ms}ms)"
            )
    
    def record_ml_adjustment_metrics(self, model_type: str, duration: float):
        """Record ML adjustment performance metrics."""
        care_plan_ml_adjustment_time.labels(
            model_type=model_type
        ).observe(duration)
        
        duration_ms = duration * 1000
        if duration_ms > self.ml_adjustment_threshold_ms:
            self.logger.warning(
                f"ML adjustment exceeded threshold: {duration_ms:.2f}ms "
                f"for {model_type} (threshold: {self.ml_adjustment_threshold_ms}ms)"
            )
    
    def record_rule_engine_metrics(self, complexity: str, duration: float, 
                                  rules_fired: int):
        """Record rule engine performance metrics."""
        care_plan_rule_engine_time.labels(
            rule_complexity=complexity
        ).observe(duration)
        
        duration_ms = duration * 1000
        if duration_ms > self.rule_engine_threshold_ms:
            self.logger.warning(
                f"Rule engine exceeded threshold: {duration_ms:.2f}ms "
                f"for {complexity} complexity with {rules_fired} rules "
                f"(threshold: {self.rule_engine_threshold_ms}ms)"
            )
    
    def record_cache_hit(self, cache_type: str):
        """Record cache hit metrics."""
        care_plan_cache_hits.labels(cache_type=cache_type).inc()
    
    def get_metrics_summary(self) -> Dict[str, Any]:
        """Get comprehensive metrics summary."""
        with self.lock:
            summary = {}
            
            for key, metrics in self.metrics.items():
                summary[key] = {
                    'request_count': metrics.request_count,
                    'success_rate': metrics.success_rate,
                    'average_duration_ms': metrics.average_duration * 1000,
                    'p95_duration_ms': metrics.p95_duration * 1000,
                    'min_duration_ms': metrics.min_duration * 1000,
                    'max_duration_ms': metrics.max_duration * 1000,
                    'error_count': metrics.error_count
                }
            
            return summary
    
    def _check_performance_alerts(self, key: str, metrics: PerformanceMetrics, 
                                 duration: float):
        """Check for performance alerts and log warnings."""
        # Check error rate
        if metrics.request_count >= 10:  # Only check after sufficient requests
            error_rate = (metrics.error_count / metrics.request_count) * 100
            if error_rate > self.error_rate_threshold:
                self.logger.error(
                    f"High error rate detected for {key}: {error_rate:.2f}% "
                    f"(threshold: {self.error_rate_threshold}%)"
                )
        
        # Check response time
        duration_ms = duration * 1000
        if duration_ms > self.response_time_threshold:
            self.logger.warning(
                f"Slow response detected for {key}: {duration_ms:.2f}ms "
                f"(threshold: {self.response_time_threshold}ms)"
            )
    
    def reset_metrics(self):
        """Reset all collected metrics."""
        with self.lock:
            self.metrics.clear()
            self.logger.info("Care plan metrics reset")


# Global metrics collector instance
metrics_collector = CarePlanMetricsCollector()


def monitor_performance(operation_name: str = None, 
                       plant_species: str = None,
                       complexity: str = 'medium'):
    """Decorator to monitor function performance."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            operation = operation_name or func.__name__
            
            # Increment active operations
            if 'generation' in operation:
                active_care_plan_generations.inc()
            
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start_time
                
                # Record success metrics
                if 'generation' in operation and plant_species:
                    confidence = getattr(result, 'confidence', 0.8) if hasattr(result, 'confidence') else 0.8
                    metrics_collector.record_generation_metrics(
                        plant_species=plant_species,
                        duration=duration,
                        confidence=confidence,
                        complexity=complexity,
                        success=True
                    )
                
                return result
                
            except Exception as e:
                duration = time.time() - start_time
                
                # Record error metrics
                if 'generation' in operation and plant_species:
                    metrics_collector.record_generation_metrics(
                        plant_species=plant_species,
                        duration=duration,
                        confidence=0.0,
                        complexity=complexity,
                        success=False,
                        error_type=type(e).__name__
                    )
                
                raise
            
            finally:
                # Decrement active operations
                if 'generation' in operation:
                    active_care_plan_generations.dec()
        
        return wrapper
    return decorator


def get_health_status() -> Dict[str, Any]:
    """Get overall health status of care plan services."""
    summary = metrics_collector.get_metrics_summary()
    
    # Calculate overall health score
    health_score = 100.0
    issues = []
    
    for endpoint, metrics in summary.items():
        if metrics['request_count'] > 0:
            # Check success rate
            if metrics['success_rate'] < 95.0:
                health_score -= 20
                issues.append(f"Low success rate for {endpoint}: {metrics['success_rate']:.1f}%")
            
            # Check response time
            if metrics['p95_duration_ms'] > 500:
                health_score -= 15
                issues.append(f"Slow response time for {endpoint}: {metrics['p95_duration_ms']:.1f}ms")
    
    health_score = max(0, health_score)
    
    status = 'healthy'
    if health_score < 50:
        status = 'unhealthy'
    elif health_score < 80:
        status = 'degraded'
    
    return {
        'status': status,
        'health_score': health_score,
        'issues': issues,
        'metrics_summary': summary,
        'timestamp': datetime.utcnow().isoformat()
    }


def log_performance_summary():
    """Log periodic performance summary."""
    summary = metrics_collector.get_metrics_summary()
    
    if not summary:
        return
    
    logger = logging.getLogger(__name__)
    logger.info("=== Care Plan Performance Summary ===")
    
    for endpoint, metrics in summary.items():
        logger.info(
            f"{endpoint}: {metrics['request_count']} requests, "
            f"{metrics['success_rate']:.1f}% success rate, "
            f"{metrics['average_duration_ms']:.1f}ms avg response time"
        )
    
    health = get_health_status()
    logger.info(f"Overall health: {health['status']} (score: {health['health_score']:.1f})")
    
    if health['issues']:
        logger.warning(f"Issues detected: {', '.join(health['issues'])}")