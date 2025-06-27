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
- [ ] Integrate OpenAI Vision API for plant identification
- [ ] Create plant species database and models
- [ ] Build plant identification interface
- [ ] Implement confidence scoring and multiple suggestions
- [ ] Add plant information display (care tips, toxicity, etc.)

**Acceptance Criteria**:
- Camera can identify common houseplants and garden plants
- Results show confidence scores and multiple possibilities
- Plant information includes basic care requirements
- Identification history is saved to user profile
- Works with both photos and real-time camera feed

### 2. Plant Care Recommendations

**Objective**: Provide basic plant care guidance and reminders

**Tasks**:
- [ ] Create plant care database with species-specific information
- [ ] Implement care schedule system
- [ ] Build care reminder notifications
- [ ] Add plant health assessment tools
- [ ] Create care tip content system

**Acceptance Criteria**:
- Users can set up care schedules for their plants
- Push notifications remind users of watering/feeding times
- Care tips are relevant to identified plant species
- Users can track plant health over time
- Seasonal care adjustments are suggested

### 3. Plant-Themed AR Filters

**Objective**: Create engaging plant-focused camera effects and filters

**Tasks**:
- [ ] Develop plant growth time-lapse effect
- [ ] Create plant health overlay filters
- [ ] Implement seasonal plant transformation effects
- [ ] Add plant identification overlay graphics
- [ ] Build plant care reminder overlays

**Acceptance Criteria**:
- Time-lapse effect shows plant growth progression
- Health filters highlight plant condition indicators
- Seasonal effects show plants in different seasons
- Identification overlay shows plant names and info
- Care overlays display watering/light requirements

### 4. Plant Community Features

**Objective**: Build community features specific to plant enthusiasts

**Tasks**:
- [ ] Create plant collection profiles
- [ ] Implement plant trading/sharing system
- [ ] Build local gardening community discovery
- [ ] Add plant care Q&A system
- [ ] Create plant achievement and milestone tracking

**Acceptance Criteria**:
- Users can showcase their plant collections
- Plant trading requests can be posted and responded to
- Local plant communities are discoverable by location
- Q&A system connects beginners with experts
- Achievements motivate continued engagement

### 5. Enhanced Discovery Feed

**Objective**: Curate plant-focused content discovery

**Tasks**:
- [ ] Implement plant interest-based content filtering
- [ ] Create seasonal gardening content curation
- [ ] Build plant care tip recommendation system
- [ ] Add local nursery and garden center integration
- [ ] Implement plant expert user highlighting

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

- [ ] Plant identification accuracy > 80% for common species
- [ ] Users can successfully add plants to their collection
- [ ] Care reminders are delivered on schedule
- [ ] Plant-themed AR filters work smoothly
- [ ] Community features encourage user engagement
- [ ] Discovery feed shows relevant plant content
- [ ] Plant trading system facilitates connections
- [ ] Q&A system provides helpful answers

---

## Relevant Files

**Backend Plant Services**:
- `app/services/plant_identification_service.py` - AI-powered plant identification
- `app/services/plant_care_service.py` - Care scheduling and reminders
- `app/services/plant_community_service.py` - Trading and Q&A features
- `app/models/plant_species.py` - Plant species database model
- `app/models/user_plant.py` - User plant collection model
- `app/models/plant_care.py` - Care schedule and log models
- `app/api/endpoints/plants.py` - Plant-related API endpoints

**Frontend Plant Features**:
- `lib/features/plant_identification/` - Plant ID camera and results
- `lib/features/plant_care/` - Care schedules and reminders
- `lib/features/plant_collection/` - User plant collection management
- `lib/features/plant_community/` - Trading and Q&A interfaces
- `lib/shared/widgets/plant_card.dart` - Plant display components
- `lib/shared/services/plant_service.dart` - Plant API communication

**AR and Camera Enhancements**:
- `lib/features/camera/widgets/plant_filters.dart` - Plant-themed AR filters
- `lib/features/camera/services/plant_overlay_service.dart` - Plant info overlays

**Database and Configuration**:
- `database/migrations/003_plant_features.sql` - Plant-related schema
- `database/seeds/plant_species.sql` - Initial plant species data
- `app/core/plant_config.py` - Plant identification configuration

---

## Next Phase Preview

Phase 3 will implement advanced RAG capabilities:
- Personalized plant care recommendations using user history
- Intelligent content generation for plant posts
- Context-aware plant problem diagnosis
- Advanced plant community matching
- Seasonal care optimization using local weather data

The plant-focused features in Phase 2 provide the data foundation and user engagement patterns needed for sophisticated RAG implementation.