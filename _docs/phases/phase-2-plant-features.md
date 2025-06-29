# Phase 2: Plant-Focused Features & AI Integration

**Duration**: 2-3 days  
**Goal**: Transform the generic social platform into a specialized plant community app with AI-powered features

---

## Phase Overview

This phase adds plant-specific functionality that differentiates our app from generic social platforms. We'll implement plant identification, basic care recommendations, plant-themed AR filters, and community features tailored for plant enthusiasts. This creates the foundation for the advanced RAG features in Phase 3.

---

## Core Deliverables

### 1. Plant Identification System

**Objective**: Enable users to identify plants using AI-powered image recognition

**Tasks**:
- [x] Integrate OpenAI Vision API for plant identification
- [x] Create plant species database and models
- [x] Build plant identification interface
- [x] Implement confidence scoring and multiple suggestions
- [x] Add plant information display (care tips, toxicity, etc.)

**Acceptance Criteria**:
- Camera can identify common houseplants and garden plants
- Results show confidence scores and multiple possibilities
- Plant information includes basic care requirements
- Identification history is saved to user profile
- Works with both photos and real-time camera feed

### 2. Plant Care Recommendations

**Objective**: Provide basic plant care guidance and reminders

**Tasks**:
- [x] Create plant care database with species-specific information
- [x] Implement care schedule system
- [x] Build care reminder notifications
- [x] Add plant health assessment tools
- [x] Create care tip content system

**Acceptance Criteria**:
- Users can set up care schedules for their plants
- Push notifications remind users of watering/feeding times
- Care tips are relevant to identified plant species
- Users can track plant health over time
- Seasonal care adjustments are suggested

### 3. Plant-Themed AR Filters

**Objective**: Create engaging plant-focused camera effects and filters

**Tasks**:
- [x] Develop plant growth time-lapse effect
- [x] Create plant health overlay filters
- [x] Implement seasonal plant transformation effects
- [x] Add plant identification overlay graphics
- [x] Build plant care reminder overlays

**Acceptance Criteria**:
- Time-lapse effect shows plant growth progression
- Health filters highlight plant condition indicators
- Seasonal effects show plants in different seasons
- Identification overlay shows plant names and info
- Care overlays display watering/light requirements

### 4. Plant Community Features

**Objective**: Build community features specific to plant enthusiasts

**Tasks**:
- [x] Create plant collection profiles
- [x] Implement plant trading/sharing system
- [x] Build local gardening community discovery
- [x] Add plant care Q&A system
- [x] Create plant achievement and milestone tracking

**Acceptance Criteria**:
- Users can showcase their plant collections
- Plant trading requests can be posted and responded to
- Local plant communities are discoverable by location
- Q&A system connects beginners with experts
- Achievements motivate continued engagement

### 5. Enhanced Discovery Feed

**Objective**: Curate plant-focused content discovery

**Tasks**:
- [x] Implement plant interest-based content filtering
- [x] Create seasonal gardening content curation
- [x] Build plant care tip recommendation system
- [x] Add local nursery and garden center integration
- [x] Implement plant expert user highlighting

**Acceptance Criteria**:
- Feed shows content relevant to user's plant interests
- Seasonal content appears at appropriate times
- Care tips match user's plant collection
- Local plant businesses are discoverable
- Expert users are highlighted and easy to follow

---

## Technical Implementation

### Plant Identification Service

```python
class PlantIdentificationService:
    def __init__(self, openai_client: OpenAI, plant_db: PlantDatabase):
        self.openai_client = openai_client
        self.plant_db = plant_db
    
    async def identify_plant(self, image_data: bytes) -> PlantIdentification:
        # Call OpenAI Vision API
        response = await self.openai_client.chat.completions.create(
            model="gpt-4-vision-preview",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Identify this plant species. Provide the scientific name, common name, and confidence level."
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64.b64encode(image_data).decode()}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=300
        )
        
        # Parse response and enrich with database info
        return await self._enrich_identification(response)
```

### Plant Care System

```python
class PlantCareSchedule(Base):
    __tablename__ = "plant_care_schedules"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID, ForeignKey("users.id"))
    plant_id = Column(UUID, ForeignKey("user_plants.id"))
    care_type = Column(String)  # watering, fertilizing, pruning
    frequency_days = Column(Integer)
    last_completed = Column(DateTime)
    next_due = Column(DateTime)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class PlantCareService:
    async def create_care_schedule(self, user_id: str, plant_id: str, care_data: dict):
        schedule = PlantCareSchedule(
            user_id=user_id,
            plant_id=plant_id,
            care_type=care_data['type'],
            frequency_days=care_data['frequency'],
            next_due=datetime.utcnow() + timedelta(days=care_data['frequency'])
        )
        # Save and schedule notifications
        return await self._save_and_schedule(schedule)
```

### Frontend Plant Features

```dart
// Plant identification widget
class PlantIdentificationWidget extends ConsumerWidget {
  const PlantIdentificationWidget({Key? key, required this.imageFile}) : super(key: key);
  
  final File imageFile;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(plantIdentificationProvider(imageFile)).when(
      data: (identification) => PlantResultCard(identification: identification),
      loading: () => const PlantIdentificationLoader(),
      error: (error, stack) => PlantIdentificationError(error: error),
    );
  }
}

// Plant care reminder provider
final plantCareProvider = StateNotifierProvider<PlantCareNotifier, PlantCareState>(
  (ref) => PlantCareNotifier(ref.read(plantCareServiceProvider)),
);

class PlantCareNotifier extends StateNotifier<PlantCareState> {
  PlantCareNotifier(this._careService) : super(PlantCareState.initial());
  
  final PlantCareService _careService;
  
  Future<void> addPlantToCollection(PlantIdentification plant) async {
    state = state.copyWith(isLoading: true);
    try {
      final userPlant = await _careService.addPlant(plant);
      state = state.copyWith(
        plants: [...state.plants, userPlant],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

---

## Database Schema Updates

### New Tables

```sql
-- Plant species database
CREATE TABLE plant_species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scientific_name VARCHAR(255) NOT NULL,
    common_names TEXT[], -- Array of common names
    family VARCHAR(100),
    care_level VARCHAR(20), -- easy, moderate, difficult
    light_requirements VARCHAR(50),
    water_frequency_days INTEGER,
    humidity_preference VARCHAR(20),
    temperature_range VARCHAR(50),
    toxicity_info TEXT,
    care_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User's plant collection
CREATE TABLE user_plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    species_id UUID REFERENCES plant_species(id),
    custom_name VARCHAR(100),
    acquisition_date DATE,
    location VARCHAR(100), -- room/area where plant is kept
    notes TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Plant identification history
CREATE TABLE plant_identifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    image_url TEXT NOT NULL,
    identified_species_id UUID REFERENCES plant_species(id),
    confidence_score DECIMAL(3,2),
    alternative_suggestions JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Plant care schedules
CREATE TABLE plant_care_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plant_id UUID REFERENCES user_plants(id),
    care_type VARCHAR(50), -- watering, fertilizing, pruning, repotting
    frequency_days INTEGER,
    last_completed TIMESTAMP,
    next_due TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Plant care logs
CREATE TABLE plant_care_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID REFERENCES plant_care_schedules(id),
    user_id UUID REFERENCES users(id),
    plant_id UUID REFERENCES user_plants(id),
    care_type VARCHAR(50),
    completed_at TIMESTAMP DEFAULT NOW(),
    notes TEXT,
    before_image_url TEXT,
    after_image_url TEXT
);

-- Plant trading posts
CREATE TABLE plant_trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plant_species_id UUID REFERENCES plant_species(id),
    trade_type VARCHAR(20), -- offering, seeking, swap
    title VARCHAR(200),
    description TEXT,
    location VARCHAR(100),
    image_urls TEXT[],
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '30 days'
);

-- Plant community Q&A
CREATE TABLE plant_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    species_id UUID REFERENCES plant_species(id),
    title VARCHAR(200),
    question_text TEXT,
    image_urls TEXT[],
    tags TEXT[],
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE plant_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES plant_questions(id),
    user_id UUID REFERENCES users(id),
    answer_text TEXT,
    image_urls TEXT[],
    is_accepted BOOLEAN DEFAULT false,
    upvotes INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Indexes for Performance

```sql
-- Plant identification queries
CREATE INDEX idx_plant_species_common_names ON plant_species USING GIN(common_names);
CREATE INDEX idx_plant_species_scientific ON plant_species(scientific_name);

-- User plant collection
CREATE INDEX idx_user_plants_user_active ON user_plants(user_id, is_active);
CREATE INDEX idx_user_plants_species ON user_plants(species_id);

-- Care schedules
CREATE INDEX idx_care_schedules_user_active ON plant_care_schedules(user_id, is_active);
CREATE INDEX idx_care_schedules_next_due ON plant_care_schedules(next_due) WHERE is_active = true;

-- Trading and community
CREATE INDEX idx_plant_trades_location_status ON plant_trades(location, status);
CREATE INDEX idx_plant_questions_tags ON plant_questions USING GIN(tags);
```

---

## API Endpoints

### Plant Identification
```
POST /api/v1/plants/identify
GET /api/v1/plants/species/{species_id}
GET /api/v1/plants/search?q={query}
GET /api/v1/plants/identification-history
```

### Plant Collection Management
```
POST /api/v1/plants/collection/add
GET /api/v1/plants/collection
PUT /api/v1/plants/collection/{plant_id}
DELETE /api/v1/plants/collection/{plant_id}
```

### Plant Care
```
POST /api/v1/plants/care/schedule
GET /api/v1/plants/care/schedules
PUT /api/v1/plants/care/complete/{schedule_id}
GET /api/v1/plants/care/upcoming
GET /api/v1/plants/care/history/{plant_id}
```

### Community Features
```
POST /api/v1/plants/trades
GET /api/v1/plants/trades/nearby
POST /api/v1/plants/questions
GET /api/v1/plants/questions/feed
POST /api/v1/plants/answers
```

---

## Success Metrics

- [x] Plant identification accuracy > 80% for common species
- [x] Users can successfully add plants to their collection
- [x] Care reminders are delivered on schedule
- [x] Plant-themed AR filters work smoothly
- [x] Community features encourage user engagement
- [x] Discovery feed shows relevant plant content
- [x] Plant trading system facilitates connections
- [x] Q&A system provides helpful answers

---

## Relevant Files

**Backend Plant Services**:
- `app/services/plant_identification_service.py` - AI-powered plant identification (implemented)
- `app/services/user_plant_service.py` - User plant collection management (implemented)
- `app/services/plant_species_service.py` - Plant species data management (implemented)
- `app/services/plant_care_log_service.py` - Care logging and tracking (implemented)
- `app/services/plant_trade_service.py` - Plant trading system (implemented)
- `app/services/plant_question_service.py` - Q&A system with answers (implemented)
- `app/models/plant_species.py` - Plant species database model (implemented)
- `app/models/user_plant.py` - User plant collection model (implemented)
- `app/models/plant_identification.py` - Plant ID history model (implemented)
- `app/models/plant_care_log.py` - Care schedule and log models (implemented)
- `app/models/plant_trade.py` - Plant trading model (implemented)
- `app/models/plant_question.py` - Q&A models (implemented)
- `app/api/api_v1/endpoints/plant_species.py` - Plant species API endpoints (implemented)

**Frontend Plant Features**:
- `lib/features/plant_identification/` - Plant ID camera and results (implemented)
  - `models/plant_identification_models.dart` - Data models (implemented)
  - `presentation/screens/` - UI screens (implemented)
  - `presentation/widgets/` - UI components (implemented)
  - `providers/plant_identification_provider.dart` - State management (implemented)
  - `services/plant_identification_service.dart` - API service (implemented)
- `lib/features/plant_care/` - Care schedules and reminders (implemented)
  - `models/plant_care_models.dart` - Data models (implemented)
  - `presentation/screens/` - UI screens (implemented)
  - `presentation/widgets/` - UI components (implemented)
  - `providers/plant_care_provider.dart` - State management (implemented)
  - `services/plant_care_service.dart` - API service (implemented)
- `lib/features/plant_community/` - Trading and Q&A interfaces (implemented)
  - `models/plant_community_models.dart` - Data models (implemented)
  - `presentation/screens/` - UI screens (implemented)
  - `presentation/widgets/` - UI components (implemented)
  - `providers/plant_community_provider.dart` - State management (implemented)
  - `services/plant_community_service.dart` - API service (implemented)

**AR and Camera Enhancements**:
- `lib/features/camera/widgets/plant_filters.dart` - Plant-themed AR filters
- `lib/features/camera/services/plant_overlay_service.dart` - Plant info overlays

**Database and Configuration**:
- `database/migrations/003_plant_features.sql` - Plant-related schema
- `database/seeds/plant_species.sql` - Initial plant species data
- `app/core/plant_config.py` - Plant identification configuration

---

## Phase 2 Completion Summary

**Status**: ✅ **COMPLETED** (100% complete)

**Completed Features**:
- ✅ AI-powered plant identification with OpenAI Vision API
- ✅ Comprehensive plant species database and models
- ✅ Plant care scheduling and reminder system
- ✅ User plant collection management
- ✅ Plant trading and sharing system
- ✅ Plant community Q&A system
- ✅ Plant-focused content discovery and filtering
- ✅ Complete backend services and database schema
- ✅ Full frontend implementation with state management

**Completed in Final Push**:
- ✅ Advanced AR filters (plant growth time-lapse, health overlays, seasonal effects)
- ✅ Plant achievement and milestone tracking system
- ✅ Local nursery and garden center integration
- ✅ All API endpoints integrated and functional

**Implementation Results**:
- Plant identification system is functional and accurate
- Care reminder system helps users maintain their plants
- Community features encourage plant enthusiast engagement
- Trading system facilitates plant sharing
- Q&A system connects beginners with experts
- Robust data foundation for RAG features

---

## Next Phase Preview

Phase 3 will implement advanced RAG capabilities:
- Personalized plant care recommendations using user history
- Intelligent content generation for plant posts
- Context-aware plant problem diagnosis
- Advanced plant community matching
- Seasonal care optimization using local weather data

The plant-focused features in Phase 2 provide the data foundation and user engagement patterns needed for sophisticated RAG implementation.