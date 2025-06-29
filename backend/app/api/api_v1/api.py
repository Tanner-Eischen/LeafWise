
from fastapi import APIRouter

from app.api.api_v1.endpoints import(
    auth, messages, stories, friends, users, websocket,
    plant_species, user_plants, plant_care_logs, plant_identification,
    plant_trades, plant_questions, achievements, nurseries, smart_community,
    content_generation, discovery_feed, ml_enhanced_community, rag_infrastructure,
    ml_plant_health, ml_trending_topics, analytics, plant_measurements)

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(messages.router, prefix="/messages", tags=["messages"])
api_router.include_router(stories.router, prefix="/stories", tags=["stories"])
api_router.include_router(friends.router, prefix="/friends", tags=["friends"])
api_router.include_router(websocket.router, prefix="/ws", tags=["websocket"])

# Plant feature endpoints
api_router.include_router(plant_species.router, prefix="/plant-species", tags=["plant-species"])
api_router.include_router(user_plants.router, prefix="/my-plants", tags=["user-plants"])
api_router.include_router(plant_care_logs.router, prefix="/care-logs", tags=["plant-care"])
api_router.include_router(plant_identification.router, prefix="/plant-id", tags=["plant-identification"])
api_router.include_router(plant_trades.router, prefix="/marketplace", tags=["plant-marketplace"])
api_router.include_router(plant_questions.router, prefix="/plant-qa", tags=["plant-community"])
api_router.include_router(achievements.router, prefix="/achievements", tags=["achievements"])
api_router.include_router(nurseries.router, prefix="/nurseries", tags=["local-nurseries"])

# RAG and AI-powered endpoints
api_router.include_router(smart_community.router, prefix="/smart-community", tags=["smart-community"])
api_router.include_router(content_generation.router, prefix="/content-generation", tags=["content-generation"])
api_router.include_router(discovery_feed.router, prefix="/discovery", tags=["discovery-feed"])

# ML-enhanced endpoints
api_router.include_router(ml_enhanced_community.router, prefix="/ml-community", tags=["ml-enhanced-community"])
api_router.include_router(ml_plant_health.router, prefix="/ml-plant-health", tags=["ml-plant-health"])
api_router.include_router(ml_trending_topics.router, prefix="/ml-trending", tags=["ml-trending-topics"])

# RAG Infrastructure endpoints
api_router.include_router(rag_infrastructure.router, prefix="/rag", tags=["rag-infrastructure"])

# Advanced Analytics endpoints
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])

# Plant Measurement endpoints
api_router.include_router(plant_measurements.router, prefix="/measurements", tags=["plant-measurements"])