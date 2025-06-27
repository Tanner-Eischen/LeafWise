"""Schemas package.

This module makes all Pydantic schemas available for import.
"""

from .auth import (
    UserBase,
    UserCreate,
    UserUpdate,
    UserRead,
    UserInDB,
    Token,
    TokenData,
    PasswordReset,
    PasswordResetConfirm,
    EmailVerification,
    ChangePassword,
    LoginRequest,
    RefreshTokenRequest,
    LogoutRequest,
)

from .user import (
    UserBase as UserSchemaBase,
    UserRead as UserSchemaRead,
    UserSearch,
    UserPublicResponse,
    UserUpdate as UserSchemaUpdate,
    UserProfile,
    UserStats,
    UserPreferences,
    UserActivity,
    UserBlock,
    UserReport,
    UserSearchFilters,
    UserBatchOperation,
)

from .message import (
    MessageType,
    MessageStatus,
    MessageBase,
    MessageCreate,
    MessageUpdate,
    MessageRead,
    MessageThread,
    MessageReaction,
    MessageReactionCreate,
    MessageSearch,
    MessageDeliveryStatus,
    MessageBatch,
    PlantIdentificationMessage,
    PlantCareMessage,
    MessageAnalytics,
)

from .story import (
    StoryType,
    StoryPrivacyLevel,
    StoryBase,
    StoryCreate,
    StoryUpdate,
    StoryRead,
    StoryViewCreate,
    StoryView,
    StoryFeed,
    StoryHighlight,
    StoryHighlightCreate,
    StoryHighlightUpdate,
    PlantStoryData,
    StoryAnalytics,
    StorySearch,
    StoryBatch,
)

from .friendship import (
    FriendshipStatus,
    FriendshipBase,
    FriendRequestCreate,
    FriendshipRead,
    FriendshipUpdate,
    FriendProfile,
    FriendsList,
    FriendRequestsList,
    MutualFriends,
    FriendshipStats,
    FriendSuggestion,
    FriendActivity,
    BlockedUser,
    FriendshipSearch,
    FriendshipBatch,
    FriendshipNotification,
    FriendshipAnalytics,
)

from .plant_species import (
    PlantSpeciesBase,
    PlantSpeciesCreate,
    PlantSpeciesUpdate,
    PlantSpeciesResponse,
    PlantSpeciesListResponse,
)

from .user_plant import (
    UserPlantBase,
    UserPlantCreate,
    UserPlantUpdate,
    UserPlantResponse,
    UserPlantListResponse,
    PlantCareReminderResponse,
)

from .plant_care_log import (
    PlantCareLogBase,
    PlantCareLogCreate,
    PlantCareLogUpdate,
    PlantCareLogResponse,
    PlantCareLogListResponse,
    CareTypeStatsResponse,
)

from .plant_identification import (
    PlantIdentificationBase,
    PlantIdentificationCreate,
    PlantIdentificationUpdate,
    PlantIdentificationResponse,
    PlantIdentificationListResponse,
    PlantIdentificationResultResponse,
)

from .plant_trade import (
    PlantTradeBase,
    PlantTradeCreate,
    PlantTradeUpdate,
    PlantTradeResponse,
    PlantTradeListResponse,
    PlantTradeSearchRequest,
    PlantTradeInterestRequest,
)

from .plant_question import (
    PlantQuestionBase,
    PlantQuestionCreate,
    PlantQuestionUpdate,
    PlantAnswerBase,
    PlantAnswerCreate,
    PlantAnswerUpdate,
    PlantAnswerResponse,
    PlantQuestionResponse,
    PlantQuestionListResponse,
    PlantQuestionSearchRequest,
    PlantAnswerVoteRequest,
)

__all__ = [
    # Auth schemas
    "UserBase",
    "UserCreate",
    "UserUpdate",
    "UserRead",
    "UserInDB",
    "Token",
    "TokenData",
    "PasswordReset",
    "PasswordResetConfirm",
    "EmailVerification",
    "ChangePassword",
    "LoginRequest",
    "RefreshTokenRequest",
    "LogoutRequest",
    
    # User schemas
    "UserSchemaBase",
    "UserSchemaRead",
    "UserSearch",
    "UserPublicResponse",
    "UserSchemaUpdate",
    "UserProfile",
    "UserStats",
    "UserPreferences",
    "UserActivity",
    "UserBlock",
    "UserReport",
    "UserSearchFilters",
    "UserBatchOperation",
    
    # Message schemas
    "MessageType",
    "MessageStatus",
    "MessageBase",
    "MessageCreate",
    "MessageUpdate",
    "MessageRead",
    "MessageThread",
    "MessageReaction",
    "MessageReactionCreate",
    "MessageSearch",
    "MessageDeliveryStatus",
    "MessageBatch",
    "PlantIdentificationMessage",
    "PlantCareMessage",
    "MessageAnalytics",
    
    # Story schemas
    "StoryType",
    "StoryPrivacyLevel",
    "StoryBase",
    "StoryCreate",
    "StoryUpdate",
    "StoryRead",
    "StoryViewCreate",
    "StoryView",
    "StoryFeed",
    "StoryHighlight",
    "StoryHighlightCreate",
    "StoryHighlightUpdate",
    "PlantStoryData",
    "StoryAnalytics",
    "StorySearch",
    "StoryBatch",
    
    # Friendship schemas
    "FriendshipStatus",
    "FriendshipBase",
    "FriendRequestCreate",
    "FriendshipRead",
    "FriendshipUpdate",
    "FriendProfile",
    "FriendsList",
    "FriendRequestsList",
    "MutualFriends",
    "FriendshipStats",
    "FriendSuggestion",
    "FriendActivity",
    "BlockedUser",
    "FriendshipSearch",
    "FriendshipBatch",
    "FriendshipNotification",
    "FriendshipAnalytics",
    
    # Plant species schemas
    "PlantSpeciesBase",
    "PlantSpeciesCreate",
    "PlantSpeciesUpdate",
    "PlantSpeciesResponse",
    "PlantSpeciesListResponse",
    
    # User plant schemas
    "UserPlantBase",
    "UserPlantCreate",
    "UserPlantUpdate",
    "UserPlantResponse",
    "UserPlantListResponse",
    "PlantCareReminderResponse",
    
    # Plant care log schemas
    "PlantCareLogBase",
    "PlantCareLogCreate",
    "PlantCareLogUpdate",
    "PlantCareLogResponse",
    "PlantCareLogListResponse",
    "CareTypeStatsResponse",
    
    # Plant identification schemas
    "PlantIdentificationBase",
    "PlantIdentificationCreate",
    "PlantIdentificationUpdate",
    "PlantIdentificationResponse",
    "PlantIdentificationListResponse",
    "PlantIdentificationResultResponse",
    
    # Plant trade schemas
    "PlantTradeBase",
    "PlantTradeCreate",
    "PlantTradeUpdate",
    "PlantTradeResponse",
    "PlantTradeListResponse",
    "PlantTradeSearchRequest",
    "PlantTradeInterestRequest",
    
    # Plant question schemas
    "PlantQuestionBase",
    "PlantQuestionCreate",
    "PlantQuestionUpdate",
    "PlantAnswerBase",
    "PlantAnswerCreate",
    "PlantAnswerUpdate",
    "PlantAnswerResponse",
    "PlantQuestionResponse",
    "PlantQuestionListResponse",
    "PlantQuestionSearchRequest",
    "PlantAnswerVoteRequest",
]