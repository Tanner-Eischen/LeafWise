# Project Rules & Development Guidelines

Comprehensive development standards and conventions for our AI-first plant-focused Snapchat clone with RAG capabilities. This document consolidates all project rules, directory structures, naming conventions, and best practices to ensure modular, scalable, and maintainable code.

---

## Project Philosophy

### AI-First Development Principles

**Modular Architecture**
- Maximum file size: 500 lines
- Single responsibility principle for all modules
- Clear separation of concerns
- Dependency injection for testability

**Scalable Design**
- Feature-first organization over file-type grouping
- Horizontal scaling considerations from day one
- Stateless service design where possible
- Event-driven architecture for real-time features

**Maintainable Codebase**
- Self-documenting code with descriptive names
- Comprehensive inline documentation
- Consistent patterns across all modules
- Easy navigation for AI tools and developers

---

## Directory Structure

### Frontend (Flutter) Structure

```
lib/
├── core/                           # Core application infrastructure
│   ├── constants/                  # App-wide constants and configuration
│   │   ├── api_constants.dart      # API endpoints and keys
│   │   ├── app_constants.dart      # General app constants
│   │   └── theme_constants.dart    # Theme-related constants
│   ├── errors/                     # Error handling and exceptions
│   │   ├── exceptions.dart         # Custom exception classes
│   │   ├── failures.dart          # Failure handling
│   │   └── error_handler.dart      # Global error handling
│   ├── network/                    # Network layer and API clients
│   │   ├── api_client.dart         # HTTP client configuration
│   │   ├── network_info.dart       # Network connectivity
│   │   └── interceptors.dart       # Request/response interceptors
│   └── utils/                      # Utility functions and helpers
│       ├── validators.dart         # Input validation utilities
│       ├── formatters.dart         # Data formatting utilities
│       └── extensions.dart         # Dart extensions
├── features/                       # Feature-based modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Remote and local data sources
│   │   │   ├── models/             # Data models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/                 # Business logic layer
│   │   │   ├── entities/           # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/           # Business use cases
│   │   └── presentation/           # UI layer
│   │       ├── pages/              # Screen widgets
│   │       ├── widgets/            # Feature-specific widgets
│   │       └── providers/          # State management
│   ├── camera/                     # Camera and AR features
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── chat/                       # Messaging functionality
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── discover/                   # Content discovery with RAG
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/                    # User profile management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── plant_care/                 # Plant care and RAG features
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                         # Shared components across features
│   ├── widgets/                    # Reusable UI components
│   │   ├── buttons/                # Button components
│   │   ├── cards/                  # Card components
│   │   ├── forms/                  # Form components
│   │   └── common/                 # Common widgets
│   ├── models/                     # Shared data models
│   ├── services/                   # Shared services
│   │   ├── storage_service.dart    # Local storage
│   │   ├── notification_service.dart # Push notifications
│   │   └── analytics_service.dart  # Analytics tracking
│   └── providers/                  # Global state providers
└── main.dart                       # Application entry point
```

### Backend (FastAPI) Structure

```
app/
├── api/                            # API layer
│   ├── deps.py                     # Dependency injection
│   ├── endpoints/                  # API endpoint modules
│   │   ├── auth.py                 # Authentication endpoints
│   │   ├── users.py                # User management endpoints
│   │   ├── plants.py               # Plant-related endpoints
│   │   ├── chat.py                 # Chat and messaging endpoints
│   │   ├── content.py              # Content sharing endpoints
│   │   └── rag.py                  # RAG and AI endpoints
│   └── middleware/                 # Custom middleware
│       ├── auth_middleware.py      # Authentication middleware
│       ├── cors_middleware.py      # CORS configuration
│       └── rate_limit_middleware.py # Rate limiting
├── core/                           # Core application configuration
│   ├── config.py                   # Application configuration
│   ├── security.py                 # Security utilities
│   ├── database.py                 # Database configuration
│   └── events.py                   # Application lifecycle events
├── models/                         # SQLAlchemy models
│   ├── user.py                     # User model
│   ├── plant.py                    # Plant model
│   ├── message.py                  # Message model
│   ├── content.py                  # Content model
│   └── base.py                     # Base model class
├── schemas/                        # Pydantic schemas
│   ├── user.py                     # User schemas
│   ├── plant.py                    # Plant schemas
│   ├── message.py                  # Message schemas
│   ├── content.py                  # Content schemas
│   └── common.py                   # Common schemas
├── services/                       # Business logic services
│   ├── auth_service.py             # Authentication service
│   ├── user_service.py             # User management service
│   ├── plant_service.py            # Plant care service
│   ├── chat_service.py             # Chat service
│   ├── content_service.py          # Content management service
│   ├── rag_service.py              # RAG and AI service
│   ├── notification_service.py     # Push notification service
│   └── storage_service.py          # File storage service
├── utils/                          # Utility functions
│   ├── validators.py               # Input validation
│   ├── formatters.py               # Data formatting
│   ├── helpers.py                  # General helpers
│   └── constants.py                # Application constants
├── tests/                          # Test modules
│   ├── unit/                       # Unit tests
│   ├── integration/                # Integration tests
│   └── e2e/                        # End-to-end tests
└── main.py                         # Application entry point
```

### Database Structure

```
database/
├── migrations/                     # Alembic migrations
│   ├── versions/                   # Migration versions
│   └── env.py                      # Migration environment
├── seeds/                          # Database seed data
│   ├── users.sql                   # Sample user data
│   ├── plants.sql                  # Plant species data
│   └── care_guides.sql             # Plant care information
└── scripts/                        # Database utility scripts
    ├── backup.py                   # Backup scripts
    ├── restore.py                  # Restore scripts
    └── maintenance.py              # Maintenance tasks
```

### Documentation Structure

```
_docs/
├── phases/                         # Development phase documentation
│   ├── phase-1-core-clone.md      # Phase 1 tasks and deliverables
│   ├── phase-2-rag-enhancement.md # Phase 2 tasks and deliverables
│   └── phase-3-optimization.md    # Phase 3 tasks and deliverables
├── api/                            # API documentation
│   ├── endpoints.md                # Endpoint documentation
│   ├── authentication.md          # Auth documentation
│   └── schemas.md                  # Schema documentation
├── deployment/                     # Deployment guides
│   ├── local-setup.md              # Local development setup
│   ├── staging-deployment.md       # Staging deployment
│   └── production-deployment.md    # Production deployment
└── architecture/                   # Architecture documentation
    ├── system-design.md            # Overall system design
    ├── database-design.md          # Database schema design
    └── security-design.md          # Security architecture
```

---

## Naming Conventions

### File Naming

**Flutter/Dart Files**
- Use `snake_case` for all file names
- Descriptive names indicating purpose
- Suffix conventions:
  - `_screen.dart` for screen widgets
  - `_widget.dart` for reusable widgets
  - `_model.dart` for data models
  - `_service.dart` for service classes
  - `_provider.dart` for state providers
  - `_repository.dart` for repository classes
  - `_usecase.dart` for use case classes

**Examples:**
```
user_profile_screen.dart
plant_identification_widget.dart
user_model.dart
auth_service.dart
plant_care_provider.dart
user_repository.dart
get_plant_details_usecase.dart
```

**Python Files**
- Use `snake_case` for all file names
- Descriptive names indicating purpose
- Suffix conventions:
  - `_service.py` for service classes
  - `_model.py` for SQLAlchemy models
  - `_schema.py` for Pydantic schemas
  - `_repository.py` for repository classes
  - `_utils.py` for utility functions

**Examples:**
```
user_service.py
plant_model.py
auth_schema.py
plant_repository.py
validation_utils.py
```

### Code Naming

**Variables and Functions**
- Use `camelCase` in Dart/Flutter
- Use `snake_case` in Python
- Descriptive names with auxiliary verbs
- Boolean variables start with `is`, `has`, `can`, `should`

**Examples:**
```dart
// Dart/Flutter
bool isLoading = false;
bool hasError = false;
bool canEditProfile = true;
String userName = '';
List<Plant> userPlants = [];

void getUserPlants() {}
Future<void> updatePlantCare() async {}
```

```python
# Python
is_authenticated = False
has_permission = True
can_access_feature = False
user_name = ""
plant_collection = []

def get_user_plants():
    pass

async def update_plant_care():
    pass
```

**Classes and Types**
- Use `PascalCase` for all class names
- Descriptive names indicating purpose
- Suffix conventions:
  - `Screen` for screen widgets
  - `Widget` for reusable widgets
  - `Model` for data models
  - `Service` for service classes
  - `Provider` for state providers
  - `Repository` for repository classes
  - `UseCase` for use case classes

**Examples:**
```dart
// Dart/Flutter
class UserProfileScreen extends StatelessWidget {}
class PlantIdentificationWidget extends StatefulWidget {}
class UserModel {}
class AuthService {}
class PlantCareProvider extends StateNotifier {}
class UserRepository {}
class GetPlantDetailsUseCase {}
```

```python
# Python
class UserService:
    pass

class PlantModel(Base):
    pass

class AuthSchema(BaseModel):
    pass

class PlantRepository:
    pass
```

**Constants**
- Use `SCREAMING_SNAKE_CASE` for constants
- Group related constants in dedicated files
- Prefix with context when needed

**Examples:**
```dart
// Dart/Flutter
const String API_BASE_URL = 'https://api.plantsnap.com';
const int MAX_UPLOAD_SIZE = 10485760; // 10MB
const Duration CACHE_DURATION = Duration(hours: 1);
const Color FOREST_GREEN = Color(0xFF2D5A27);
```

```python
# Python
API_BASE_URL = "https://api.plantsnap.com"
MAX_UPLOAD_SIZE = 10485760  # 10MB
CACHE_DURATION = 3600  # 1 hour in seconds
FOREST_GREEN = "#2D5A27"
```

### Database Naming

**Tables**
- Use `snake_case` with plural nouns
- Descriptive names indicating content
- Avoid abbreviations

**Examples:**
```sql
users
plant_collections
care_schedules
message_threads
content_items
rag_embeddings
```

**Columns**
- Use `snake_case` for all column names
- Descriptive names indicating purpose
- Standard suffixes:
  - `_id` for primary/foreign keys
  - `_at` for timestamps
  - `_count` for counters
  - `_url` for URLs
  - `_json` for JSON columns

**Examples:**
```sql
user_id
email_address
created_at
updated_at
plant_count
profile_image_url
metadata_json
```

**Indexes and Constraints**
- Use descriptive names with prefixes
- Prefixes:
  - `idx_` for indexes
  - `fk_` for foreign keys
  - `uk_` for unique constraints
  - `ck_` for check constraints

**Examples:**
```sql
idx_users_email
idx_plants_species_name
fk_plants_user_id
uk_users_username
ck_users_age_positive
```

---

## Code Documentation Standards

### File Headers

Every file must start with a comprehensive header comment explaining its purpose, contents, and usage.

**Dart/Flutter Example:**
```dart
/// Plant Care Service
/// 
/// Handles all plant care related operations including:
/// - Plant identification and species lookup
/// - Care schedule management and reminders
/// - RAG-enhanced care recommendations
/// - Integration with external plant databases
/// 
/// Dependencies:
/// - OpenAI API for plant identification
/// - Local database for care schedules
/// - Push notification service for reminders
/// 
/// Usage:
/// ```dart
/// final plantCareService = PlantCareService();
/// final plant = await plantCareService.identifyPlant(imageFile);
/// await plantCareService.createCareSchedule(plant.id, schedule);
/// ```
/// 
/// Author: Development Team
/// Created: 2024-01-01
/// Last Modified: 2024-01-15

import 'package:flutter/material.dart';
// ... rest of file
```

**Python Example:**
```python
"""
Plant Care Service Module

Handles all plant care related operations including:
- Plant identification and species lookup
- Care schedule management and reminders  
- RAG-enhanced care recommendations
- Integration with external plant databases

Dependencies:
    - OpenAI API for plant identification
    - PostgreSQL database for data persistence
    - Redis for caching and real-time features
    - Celery for background task processing

Usage:
    from services.plant_care_service import PlantCareService
    
    service = PlantCareService()
    plant = await service.identify_plant(image_data)
    schedule = await service.create_care_schedule(plant.id, care_data)

Author: Development Team
Created: 2024-01-01
Last Modified: 2024-01-15
"""

from typing import List, Optional
# ... rest of file
```

### Function Documentation

**Dart/Flutter (DartDoc):**
```dart
/// Identifies a plant species from an uploaded image using AI.
/// 
/// Uses OpenAI's vision API to analyze the plant image and returns
/// detailed species information including care requirements.
/// 
/// Parameters:
/// - [imageFile]: The plant image file to analyze
/// - [confidence]: Minimum confidence threshold (0.0-1.0)
/// - [includeCareTips]: Whether to include care recommendations
/// 
/// Returns:
/// A [PlantIdentification] object containing species info and care data.
/// 
/// Throws:
/// - [PlantIdentificationException] if analysis fails
/// - [NetworkException] if API request fails
/// - [ValidationException] if image format is invalid
/// 
/// Example:
/// ```dart
/// final identification = await identifyPlant(
///   imageFile: selectedImage,
///   confidence: 0.8,
///   includeCareTips: true,
/// );
/// print('Species: ${identification.speciesName}');
/// ```
Future<PlantIdentification> identifyPlant({
  required File imageFile,
  double confidence = 0.7,
  bool includeCareTips = true,
}) async {
  // Implementation
}
```

**Python (Google Style):**
```python
async def identify_plant(
    image_data: bytes,
    confidence: float = 0.7,
    include_care_tips: bool = True
) -> PlantIdentification:
    """Identifies a plant species from uploaded image data using AI.
    
    Uses OpenAI's vision API to analyze the plant image and returns
    detailed species information including care requirements.
    
    Args:
        image_data: Binary image data to analyze
        confidence: Minimum confidence threshold (0.0-1.0)
        include_care_tips: Whether to include care recommendations
        
    Returns:
        PlantIdentification object containing species info and care data
        
    Raises:
        PlantIdentificationError: If analysis fails
        NetworkError: If API request fails  
        ValidationError: If image format is invalid
        
    Example:
        >>> identification = await identify_plant(
        ...     image_data=image_bytes,
        ...     confidence=0.8,
        ...     include_care_tips=True
        ... )
        >>> print(f"Species: {identification.species_name}")
    """
    # Implementation
```

### Class Documentation

**Dart/Flutter:**
```dart
/// Plant Care Provider for state management.
/// 
/// Manages the application state for plant care features including:
/// - User's plant collection
/// - Care schedules and reminders
/// - RAG-generated recommendations
/// - Real-time care notifications
/// 
/// This provider uses Riverpod for dependency injection and state management.
/// It automatically syncs with the backend API and local storage.
/// 
/// State Properties:
/// - [plants]: List of user's plants
/// - [careSchedules]: Active care schedules
/// - [recommendations]: AI-generated care tips
/// - [isLoading]: Loading state indicator
/// - [error]: Error state information
/// 
/// Example:
/// ```dart
/// final plantCareProvider = ref.watch(plantCareProviderProvider);
/// final plants = plantCareProvider.plants;
/// await plantCareProvider.addPlant(newPlant);
/// ```
class PlantCareProvider extends StateNotifier<PlantCareState> {
  // Implementation
}
```

**Python:**
```python
class PlantCareService:
    """Service for managing plant care operations.
    
    Handles all plant care related functionality including:
    - Plant identification and species lookup
    - Care schedule management and reminders
    - RAG-enhanced care recommendations  
    - Integration with external plant databases
    
    This service integrates with multiple external APIs and maintains
    local caching for performance optimization.
    
    Attributes:
        db_session: Database session for data persistence
        openai_client: OpenAI API client for AI operations
        redis_client: Redis client for caching
        notification_service: Service for push notifications
        
    Example:
        >>> service = PlantCareService(db_session=session)
        >>> plant = await service.identify_plant(image_data)
        >>> schedule = await service.create_care_schedule(plant.id, care_data)
    """
    
    def __init__(
        self,
        db_session: AsyncSession,
        openai_client: OpenAI,
        redis_client: Redis,
        notification_service: NotificationService
    ):
        # Implementation
```

---

## Code Quality Standards

### General Principles

**Functional and Declarative Programming**
- Prefer pure functions over stateful classes
- Use immutable data structures where possible
- Avoid side effects in business logic
- Favor composition over inheritance

**Error Handling**
- Throw specific exceptions instead of generic ones
- Never use fallback values that hide errors
- Implement comprehensive error logging
- Provide meaningful error messages to users

**Performance Considerations**
- Lazy loading for large datasets
- Efficient algorithms and data structures
- Proper memory management
- Caching strategies for expensive operations

### Flutter-Specific Standards

**Widget Design**
```dart
/// Good: Functional widget with clear purpose
Widget buildPlantCard(Plant plant, VoidCallback onTap) {
  return Card(
    child: ListTile(
      leading: CachedNetworkImage(imageUrl: plant.imageUrl),
      title: Text(plant.name),
      subtitle: Text(plant.species),
      onTap: onTap,
    ),
  );
}

/// Avoid: Overly complex stateful widgets
class ComplexPlantWidget extends StatefulWidget {
  // Too many responsibilities in one widget
}
```

**State Management**
```dart
/// Good: Clear state management with Riverpod
final plantListProvider = StateNotifierProvider<PlantListNotifier, List<Plant>>(
  (ref) => PlantListNotifier(ref.read(plantRepositoryProvider)),
);

class PlantListNotifier extends StateNotifier<List<Plant>> {
  PlantListNotifier(this._repository) : super([]);
  
  final PlantRepository _repository;
  
  Future<void> loadPlants() async {
    try {
      final plants = await _repository.getAllPlants();
      state = plants;
    } catch (e) {
      // Handle error appropriately
      throw PlantLoadException('Failed to load plants: $e');
    }
  }
}
```

**Performance Optimization**
```dart
/// Good: Optimized list building
Widget buildPlantList(List<Plant> plants) {
  return ListView.builder(
    itemCount: plants.length,
    itemBuilder: (context, index) {
      final plant = plants[index];
      return PlantListItem(key: ValueKey(plant.id), plant: plant);
    },
  );
}

/// Good: Const constructors for static widgets
class PlantIcon extends StatelessWidget {
  const PlantIcon({Key? key, required this.type}) : super(key: key);
  
  final PlantType type;
  
  @override
  Widget build(BuildContext context) {
    return Icon(type.icon);
  }
}
```

### Python-Specific Standards

**Service Layer Design**
```python
# Good: Clear service with single responsibility
class PlantIdentificationService:
    """Service for identifying plants using AI."""
    
    def __init__(self, openai_client: OpenAI, cache: Redis):
        self._openai_client = openai_client
        self._cache = cache
    
    async def identify_plant(self, image_data: bytes) -> PlantIdentification:
        """Identify plant species from image data."""
        # Check cache first
        cache_key = self._generate_cache_key(image_data)
        cached_result = await self._cache.get(cache_key)
        
        if cached_result:
            return PlantIdentification.from_json(cached_result)
        
        # Call AI service
        result = await self._call_openai_vision(image_data)
        
        # Cache result
        await self._cache.setex(
            cache_key, 
            CACHE_DURATION, 
            result.to_json()
        )
        
        return result
```

**Error Handling**
```python
# Good: Specific exceptions with context
class PlantServiceError(Exception):
    """Base exception for plant service errors."""
    pass

class PlantNotFoundError(PlantServiceError):
    """Raised when a plant cannot be found."""
    
    def __init__(self, plant_id: str):
        super().__init__(f"Plant with ID {plant_id} not found")
        self.plant_id = plant_id

class PlantIdentificationError(PlantServiceError):
    """Raised when plant identification fails."""
    
    def __init__(self, reason: str, confidence: float = 0.0):
        super().__init__(f"Plant identification failed: {reason}")
        self.reason = reason
        self.confidence = confidence

# Usage in service
async def get_plant_by_id(self, plant_id: str) -> Plant:
    plant = await self._repository.get_by_id(plant_id)
    if not plant:
        raise PlantNotFoundError(plant_id)
    return plant
```

**Async/Await Patterns**
```python
# Good: Proper async patterns
async def process_plant_care_batch(self, plant_ids: List[str]) -> List[CareResult]:
    """Process care updates for multiple plants concurrently."""
    tasks = [
        self._process_single_plant_care(plant_id) 
        for plant_id in plant_ids
    ]
    
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    # Handle any exceptions
    processed_results = []
    for i, result in enumerate(results):
        if isinstance(result, Exception):
            logger.error(f"Failed to process plant {plant_ids[i]}: {result}")
            processed_results.append(CareResult.error(plant_ids[i], str(result)))
        else:
            processed_results.append(result)
    
    return processed_results
```

---

## Testing Standards

### Test Organization

**Flutter Tests**
```
test/
├── unit/                           # Unit tests
│   ├── models/                     # Model tests
│   ├── services/                   # Service tests
│   ├── providers/                  # Provider tests
│   └── utils/                      # Utility tests
├── widget/                         # Widget tests
│   ├── screens/                    # Screen widget tests
│   ├── components/                 # Component tests
│   └── common/                     # Common widget tests
├── integration/                    # Integration tests
│   ├── auth_flow_test.dart         # Authentication flow
│   ├── plant_care_flow_test.dart   # Plant care flow
│   └── chat_flow_test.dart         # Chat functionality
└── test_helpers/                   # Test utilities
    ├── mock_data.dart              # Mock data generators
    ├── test_utils.dart             # Test helper functions
    └── widget_test_utils.dart      # Widget testing utilities
```

**Python Tests**
```
tests/
├── unit/                           # Unit tests
│   ├── services/                   # Service tests
│   ├── models/                     # Model tests
│   ├── schemas/                    # Schema tests
│   └── utils/                      # Utility tests
├── integration/                    # Integration tests
│   ├── api/                        # API endpoint tests
│   ├── database/                   # Database tests
│   └── external/                   # External service tests
├── e2e/                            # End-to-end tests
│   ├── auth_flow_test.py           # Authentication flow
│   ├── plant_care_flow_test.py     # Plant care flow
│   └── chat_flow_test.py           # Chat functionality
└── fixtures/                       # Test fixtures
    ├── sample_data.py              # Sample data
    ├── mock_responses.py           # Mock API responses
    └── test_database.py            # Test database setup
```

### Test Naming and Documentation

**Test Function Naming**
- Use descriptive names that explain what is being tested
- Follow pattern: `test_[method]_[scenario]_[expected_result]`
- Include edge cases and error conditions

**Examples:**
```dart
// Flutter/Dart
void main() {
  group('PlantIdentificationService', () {
    test('identifyPlant_withValidImage_returnsPlantIdentification', () async {
      // Test implementation
    });
    
    test('identifyPlant_withInvalidImage_throwsValidationException', () async {
      // Test implementation
    });
    
    test('identifyPlant_withNetworkError_throwsNetworkException', () async {
      // Test implementation
    });
  });
}
```

```python
# Python
class TestPlantIdentificationService:
    """Tests for PlantIdentificationService."""
    
    async def test_identify_plant_with_valid_image_returns_identification(self):
        """Test that valid image returns plant identification."""
        # Test implementation
        pass
    
    async def test_identify_plant_with_invalid_image_raises_validation_error(self):
        """Test that invalid image raises ValidationError."""
        # Test implementation
        pass
    
    async def test_identify_plant_with_network_error_raises_network_error(self):
        """Test that network issues raise NetworkError."""
        # Test implementation
        pass
```

---

## Security Standards

### Authentication and Authorization

**JWT Token Management**
```python
# Secure token configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")  # Must be in environment
JWT_ALGORITHM = "HS256"
JWT_ACCESS_TOKEN_EXPIRE_MINUTES = 30
JWT_REFRESH_TOKEN_EXPIRE_DAYS = 7

# Token validation
async def validate_token(token: str) -> UserClaims:
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise InvalidTokenError("Token missing user ID")
        return UserClaims(user_id=user_id, **payload)
    except JWTError as e:
        raise InvalidTokenError(f"Token validation failed: {e}")
```

**Input Validation**
```python
# Pydantic schemas for validation
class PlantCreateSchema(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    species: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    image_url: Optional[HttpUrl] = None
    
    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()
    
    @validator('description')
    def validate_description(cls, v):
        if v and len(v.strip()) == 0:
            return None
        return v
```

**Data Protection**
```python
# Sensitive data handling
class UserModel(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)  # Never store plain passwords
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def set_password(self, password: str) -> None:
        """Hash and set user password."""
        self.password_hash = get_password_hash(password)
    
    def verify_password(self, password: str) -> bool:
        """Verify user password against hash."""
        return verify_password(password, self.password_hash)
```

### API Security

**Rate Limiting**
```python
# Rate limiting middleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Apply rate limits to endpoints
@app.post("/api/v1/plants/identify")
@limiter.limit("10/minute")  # Limit AI calls
async def identify_plant(
    request: Request,
    image: UploadFile,
    current_user: User = Depends(get_current_user)
):
    # Implementation
```

**CORS Configuration**
```python
# Secure CORS setup
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # Development
        "https://plantsnap.com",  # Production
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
    expose_headers=["X-Total-Count"],
)
```

---

## Performance Standards

### Database Optimization

**Query Optimization**
```sql
-- Good: Efficient queries with proper indexes
CREATE INDEX CONCURRENTLY idx_plants_user_id_species 
ON plants(user_id, species_name) 
WHERE deleted_at IS NULL;

-- Good: Optimized pagination
SELECT * FROM plants 
WHERE user_id = $1 
  AND created_at < $2 
ORDER BY created_at DESC 
LIMIT 20;

-- Avoid: N+1 queries
-- Bad: Loading plants then care schedules separately
-- Good: Use JOINs or eager loading
SELECT p.*, cs.* 
FROM plants p 
LEFT JOIN care_schedules cs ON p.id = cs.plant_id 
WHERE p.user_id = $1;
```

**Connection Management**
```python
# Database connection pooling
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=3600,
)

AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

# Proper session management
async def get_db_session() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Caching Strategies

**Redis Caching**
```python
# Efficient caching patterns
class PlantCacheService:
    """Service for caching plant-related data."""
    
    def __init__(self, redis_client: Redis):
        self._redis = redis_client
    
    async def get_plant_details(self, plant_id: str) -> Optional[PlantDetails]:
        """Get plant details from cache."""
        cache_key = f"plant:details:{plant_id}"
        cached_data = await self._redis.get(cache_key)
        
        if cached_data:
            return PlantDetails.from_json(cached_data)
        return None
    
    async def set_plant_details(
        self, 
        plant_id: str, 
        details: PlantDetails,
        ttl: int = 3600
    ) -> None:
        """Cache plant details with TTL."""
        cache_key = f"plant:details:{plant_id}"
        await self._redis.setex(
            cache_key, 
            ttl, 
            details.to_json()
        )
    
    async def invalidate_plant_cache(self, plant_id: str) -> None:
        """Invalidate all cached data for a plant."""
        pattern = f"plant:*:{plant_id}"
        keys = await self._redis.keys(pattern)
        if keys:
            await self._redis.delete(*keys)
```

### Frontend Performance

**Flutter Optimization**
```dart
// Efficient list rendering
class OptimizedPlantList extends StatelessWidget {
  const OptimizedPlantList({Key? key, required this.plants}) : super(key: key);
  
  final List<Plant> plants;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use item extent for better performance
      itemExtent: 120.0,
      itemCount: plants.length,
      // Cache extent for smooth scrolling
      cacheExtent: 1000.0,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantListItem(
          key: ValueKey(plant.id), // Stable keys for efficient updates
          plant: plant,
        );
      },
    );
  }
}

// Optimized image loading
class OptimizedPlantImage extends StatelessWidget {
  const OptimizedPlantImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
  }) : super(key: key);
  
  final String imageUrl;
  final double? width;
  final double? height;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      // Progressive loading
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: progress.progress,
            ),
          ),
        );
      },
      // Error handling
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
      // Memory cache configuration
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
```

---

## Deployment and Environment Standards

### Environment Configuration

**Environment Variables**
```bash
# .env.example - Template for environment variables

# Database Configuration
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/plantsnap
REDIS_URL=redis://localhost:6379/0

# API Keys (Never commit actual keys)
OPENAI_API_KEY=your_openai_api_key_here
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
AWS_S3_BUCKET=your_s3_bucket_name

# Security
JWT_SECRET_KEY=your_jwt_secret_key_here
ENCRYPTION_KEY=your_encryption_key_here

# Application Settings
APP_ENV=development
DEBUG=true
LOG_LEVEL=INFO
API_VERSION=v1

# External Services
PUSH_NOTIFICATION_KEY=your_fcm_key_here
ANALYTICS_KEY=your_analytics_key_here
```

**Docker Configuration**
```dockerfile
# Dockerfile for FastAPI backend
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Start application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml for local development
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:password@db:5432/plantsnap
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./app:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=plantsnap
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### CI/CD Pipeline

**GitHub Actions Example**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_plantsnap
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Run linting
      run: |
        flake8 app/
        black --check app/
        isort --check-only app/
    
    - name: Run type checking
      run: mypy app/
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/test_plantsnap
        REDIS_URL: redis://localhost:6379/0
      run: |
        pytest tests/ --cov=app --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml

  flutter-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run analyzer
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

This comprehensive project rules document ensures consistent development practices, maintainable code structure, and scalable architecture for our AI-first plant-focused social platform.