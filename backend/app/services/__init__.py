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
]