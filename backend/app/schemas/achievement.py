"""Achievement schemas."""

from datetime import datetime
from typing import Optional, Dict, Any, List
from uuid import UUID

from pydantic import BaseModel, Field


class PlantAchievementBase(BaseModel):
    """Base schema for plant achievements."""
    achievement_type: str = Field(..., max_length=50)
    title: str = Field(..., max_length=100)
    description: Optional[str] = None
    icon: Optional[str] = Field(None, max_length=50)
    badge_color: str = Field(default="green", max_length=20)
    points: int = Field(default=0, ge=0)
    unlock_criteria: Optional[Dict[str, Any]] = None


class PlantAchievementResponse(PlantAchievementBase):
    """Achievement response schema."""
    id: UUID
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserAchievementResponse(BaseModel):
    """User achievement response schema."""
    id: UUID
    user_id: UUID
    achievement_id: UUID
    earned_at: datetime
    progress_data: Optional[Dict[str, Any]] = None
    is_featured: bool
    achievement: PlantAchievementResponse

    class Config:
        from_attributes = True


class PlantMilestoneBase(BaseModel):
    """Base schema for plant milestones."""
    milestone_type: str = Field(..., max_length=50)
    title: str = Field(..., max_length=100)
    description: Optional[str] = None
    photo_url: Optional[str] = Field(None, max_length=500)
    notes: Optional[str] = None


class PlantMilestoneCreate(PlantMilestoneBase):
    """Schema for creating plant milestones."""
    pass


class PlantMilestoneResponse(PlantMilestoneBase):
    """Plant milestone response schema."""
    id: UUID
    plant_id: UUID
    achieved_at: datetime

    class Config:
        from_attributes = True


class UserStatsResponse(BaseModel):
    """User statistics response schema."""
    id: UUID
    user_id: UUID
    
    # Plant collection stats
    total_plants: int
    active_plants: int
    plants_identified: int
    
    # Care activity stats
    total_care_logs: int
    care_streak_days: int
    longest_care_streak: int
    last_care_activity: Optional[datetime]
    
    # Community stats
    questions_asked: int
    questions_answered: int
    helpful_answers: int
    trades_completed: int
    
    # Achievement stats
    total_achievements: int
    total_points: int
    level: int
    
    # Timestamps
    last_updated: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class AchievementProgress(BaseModel):
    """Schema for tracking achievement progress."""
    achievement_id: UUID
    current_progress: Dict[str, Any]
    completion_percentage: float = Field(..., ge=0.0, le=100.0)
    is_completed: bool = False


class LeaderboardEntry(BaseModel):
    """Schema for leaderboard entries."""
    user_id: UUID
    username: str
    display_name: Optional[str]
    profile_picture_url: Optional[str]
    total_points: int
    level: int
    rank: int 