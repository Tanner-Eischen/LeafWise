# Services Architecture

This directory contains service modules that implement the core business logic of the application. The services are organized to minimize duplication and promote separation of concerns.

## Core Services

- `seasonal_ai_service.py` - ML-based seasonal prediction for plant care optimization
- `seasonal_pattern_service.py` - Seasonal transition detection and microclimate adjustments
- `environmental_data_service.py` - Environmental data collection and processing
- `smart_community_service.py` - Community matching and recommendations

## Plant Analysis Services

- `image_processing_service.py` - Computer vision for plant image analysis
- `growth_analysis_service.py` - Growth pattern detection and milestone tracking
- `plant_measurement_service.py` - Plant measurement extraction and tracking
- `ml_plant_health_service.py` - ML-enhanced plant health prediction

## Media Services

- `video_generation_service.py` - Timelapse video creation
- `file_service.py` - File storage and management

## Integration Services

- `timelapse_service.py` - Coordinates timelapse tracking (uses multiple services)
- `personalized_plant_care_service.py` - Personalized plant care recommendations
- `plant_care_log_service.py` - Plant care logging and tracking

## Content Services

- `content_generation_service.py` - Intelligent content generation
- `rag_service.py` - Retrieval-augmented generation for plant care
- `rag_content_pipeline.py` - Content indexing and embedding generation

## User Services

- `user_service.py` - User management
- `auth_service.py` - Authentication and authorization
- `notification_service.py` - User notifications

## Community Services

- `community_challenge_service.py` - Community challenges and events
- `plant_trade_service.py` - Plant trading functionality
- `story_service.py` - User stories and content sharing

## Service Design Principles

1. **Single Responsibility**: Each service should focus on a specific domain or functionality
2. **Dependency Injection**: Services should receive their dependencies through constructors
3. **Testability**: Services should be designed for easy unit testing
4. **Error Handling**: Services should handle errors gracefully and log appropriately
5. **Async First**: Services should use async/await for database and I/O operations

## Avoiding Duplication

To avoid duplication:

1. Don't create new services with overlapping functionality
2. Use existing services as dependencies when needed
3. Extract common functionality into shared services
4. Check this README before creating new services

## Adding New Services

When adding a new service:

1. Check if the functionality already exists in another service
2. Follow the naming convention: `{domain}_service.py`
3. Update this README with the new service
4. Add appropriate tests in the `tests` directory