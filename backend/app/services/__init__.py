"""Services package.

This package contains business logic services for the application.
"""

# Plant services
from .plant_species_service import (
    PlantSpeciesService,
    get_species_by_id,
    get_species_by_scientific_name,
    search_species,
    create_species,
    update_species,
    get_popular_species
)

from .user_plant_service import (
    UserPlantService,
    get_plant_by_id,
    get_user_plants,
    create_plant,
    update_plant,
    get_care_reminders,
    update_care_activity,
    get_plant_stats
)

from .plant_care_log_service import (
    PlantCareLogService,
    create_care_log,
    get_care_log_by_id,
    get_plant_care_logs,
    get_user_care_logs,
    get_care_statistics
)

from .plant_identification_service import (
    PlantIdentificationService,
    create_identification,
    get_identification_by_id,
    get_user_identifications,
    verify_identification,
    get_pending_verifications,
    get_identification_statistics
)

from .plant_trade_service import (
    PlantTradeService,
    create_trade,
    get_trade_by_id,
    search_trades,
    express_interest,
    get_trade_statistics
)

from .plant_question_service import (
    PlantQuestionService,
    PlantAnswerService,
    create_question,
    get_question_by_id,
    search_questions,
    create_answer,
    vote_answer,
    mark_question_solved
)

# Context-Aware Care Plans v2 services
# Note: These are the new services we've implemented
from .context_aggregation import (
    ContextAggregationService,
    get_context_aggregation_service
)

from .rule_engine import (
    RuleEngineService,
    get_rule_engine_service
)

from .ml_adjustment import (
    MLAdjustmentService,
    get_ml_adjustment_service
)

from .rationale_builder import (
    RationaleBuilderService,
    get_rationale_builder_service
)

from .care_plan import (
    CarePlanService,
    get_care_plan_service
)

from .environmental_data import (
    EnvironmentalDataService,
    get_environmental_data_service
)

from .cache_layer import (
    CacheLayerService,
    get_cache_service
)

# Telemetry services
from .light_reading_service import (
    LightReadingService
)

from .growth_photo_service import (
    GrowthPhotoService
)

from .telemetry_service import (
    TelemetryService
)

from .metrics_service import (
    MetricsService
)

__all__ = [
    # Plant species
    "PlantSpeciesService",
    "get_species_by_id",
    "get_species_by_scientific_name",
    "search_species",
    "create_species",
    "update_species",
    "get_popular_species",
    
    # User plants
    "UserPlantService",
    "get_plant_by_id",
    "get_user_plants",
    "create_plant",
    "update_plant",
    "get_care_reminders",
    "update_care_activity",
    "get_plant_stats",
    
    # Plant care logs
    "PlantCareLogService",
    "create_care_log",
    "get_care_log_by_id",
    "get_plant_care_logs",
    "get_user_care_logs",
    "get_care_statistics",
    
    # Plant identification
    "PlantIdentificationService",
    "create_identification",
    "get_identification_by_id",
    "get_user_identifications",
    "verify_identification",
    "get_pending_verifications",
    "get_identification_statistics",
    
    # Plant trades
    "PlantTradeService",
    "create_trade",
    "get_trade_by_id",
    "search_trades",
    "express_interest",
    "get_trade_statistics",
    
    # Plant questions and answers
    "PlantQuestionService",
    "PlantAnswerService",
    "create_question",
    "get_question_by_id",
    "search_questions",
    "create_answer",
    "vote_answer",
    "mark_question_solved",
    
    # Context-Aware Care Plans v2 services
    "ContextAggregationService",
    "get_context_aggregation_service",
    "RuleEngineService",
    "get_rule_engine_service",
    "MLAdjustmentService",
    "get_ml_adjustment_service",
    "RationaleBuilderService",
    "get_rationale_builder_service",
    "CarePlanService",
    "get_care_plan_service",
    "EnvironmentalDataService",
    "get_environmental_data_service",
    "CacheLayerService",
    "get_cache_service",
    
    # Telemetry services
    "LightReadingService",
    "GrowthPhotoService",
    "TelemetryService",
    "MetricsService",
]