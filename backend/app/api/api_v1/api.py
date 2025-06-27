"""Main API router for version 1.

This module combines all API endpoints into a single router
for the FastAPI application.
"""

from fastapi import APIRouter

from app.api.api_v1.endpoints import (
    auth, messages, stories, friends, users, websocket,
    plant_species, user_plants, plant_care_logs, plant_identification,
    plant_trades, plant_questions
)

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