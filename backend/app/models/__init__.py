"""Models package initialization.

This module imports all database models to ensure they are
registered with SQLAlchemy when the package is imported.
"""

from app.models.user import User
from app.models.message import Message
from app.models.story import Story, StoryView
from app.models.friendship import Friendship, FriendshipStatus
from app.models.plant_species import PlantSpecies
from app.models.user_plant import UserPlant
from app.models.plant_care_log import PlantCareLog
from app.models.plant_photo import PlantPhoto
from app.models.plant_identification import PlantIdentification
from app.models.plant_trade import PlantTrade, TradeStatus, TradeType
from app.models.plant_question import PlantQuestion, PlantAnswer
from app.models.plant_achievement import PlantAchievement, UserAchievement, PlantMilestone, UserStats
from app.models.local_nursery import LocalNursery, NurseryReview, NurseryEvent, UserNurseryFavorite
from app.models.rag_models import (
    PlantContentEmbedding, 
    UserPreferenceEmbedding, 
    RAGInteraction, 
    PlantKnowledgeBase,
    SemanticSearchCache
)

__all__ = [
    "User",
    "Message", 
    "Story",
    "StoryView",
    "Friendship",
    "FriendshipStatus",
    "PlantSpecies",
    "UserPlant",
    "PlantCareLog",
    "PlantPhoto",
    "PlantIdentification",
    "PlantTrade",
    "TradeStatus",
    "TradeType",
    "PlantQuestion",
    "PlantAnswer",
    "PlantAchievement",
    "UserAchievement", 
    "PlantMilestone",
    "UserStats",
    "LocalNursery",
    "NurseryReview",
    "NurseryEvent",
    "UserNurseryFavorite",
    "PlantContentEmbedding",
    "UserPreferenceEmbedding",
    "RAGInteraction",
    "PlantKnowledgeBase",
    "SemanticSearchCache"
]