# Sensor & Photo Telemetry - Tasks

## Database Setup

- [x] 1.1 Create light_readings table
  - File: backend/db/migrations/create_light_readings_table.sql
  - Implement table schema with proper indexes
  - Add constraints for source and light_source_profile
  - _Requirements: 3.1, 3.2_

- [x] 1.2 Create growth_photos table
  - File: backend/db/migrations/create_growth_photos_table.sql
  - Implement table schema with proper indexes
  - Add foreign key constraints
  - _Requirements: 3.1, 3.2_

- [x] 1.3 Create database models
  - File: backend/app/models/light_reading.py
  - File: backend/app/models/growth_photo.py
  - Implement SQLAlchemy models
  - Add validation methods
  - _Requirements: 3.1, 3.2_

## Backend API Implementation

### Light Readings API

- [x] 2.1 Implement light reading POST endpoint
  - File: backend/app/api/routes/telemetry.py
  - Add validation schema
  - Implement error handling
  - _Requirements: 4.1, 4.4_

- [x] 2.2 Implement light reading batch POST endpoint
  - File: backend/app/api/routes/telemetry.py
  - Add validation schema
  - Implement multi-status response
  - _Requirements: 4.1, 4.4_

- [x] 2.3 Implement light reading GET endpoint
  - File: backend/app/api/routes/telemetry.py
  - Add filtering and pagination
  - Optimize query performance
  - _Requirements: 4.3, 4.4_

### Growth Photos API

- [x] 2.4 Implement growth photo upload endpoint
  - File: backend/app/api/routes/telemetry.py
  - Generate pre-signed S3 URLs
  - Implement validation
  - _Requirements: 4.2, 4.4_

- [x] 2.5 Implement growth photo complete endpoint
  - File: backend/app/api/routes/telemetry.py
  - Trigger photo processing
  - Update database record
  - _Requirements: 4.2, 4.4_

- [x] 2.6 Implement growth photo GET endpoint
  - File: backend/app/api/routes/telemetry.py
  - Add filtering and pagination
  - Include photo metrics in response
  - _Requirements: 4.3, 4.4_

## Service Layer Implementation

- [x] 3.1 Implement light reading service
  - File: backend/app/services/telemetry_service.py
  - Add methods for creating and retrieving readings
  - Implement PPFD conversion logic
  - _Requirements: 1.1, 1.3, 3.3_

- [x] 3.2 Implement growth photo service
  - File: backend/app/services/telemetry_service.py
  - Add methods for photo upload and retrieval
  - Implement S3 integration
  - _Requirements: 2.1, 2.3, 3.3_

- [x] 3.3 Implement photo metrics extraction service
  - File: backend/app/services/metrics_service.py
  - Extract leaf area and height metrics
  - Implement image processing pipeline
  - _Requirements: 2.2_

## Client Module Implementation

### Light Meter Module

- [x] 4.1 Create light meter interface
  - File: frontend/src/modules/light_meter/types.ts
  - Define interfaces and types
  - Document API contract
  - _Requirements: 5.1, 5.3_

- [x] 4.2 Implement ambient light sensor strategy
  - File: frontend/src/modules/light_meter/strategies/als_strategy.ts
  - Access device ALS sensor
  - Implement calibration
  - _Requirements: 1.1, 1.2_

- [x] 4.3 Implement camera-based strategy
  - File: frontend/src/modules/light_meter/strategies/camera_strategy.ts
  - Use camera API for light measurement
  - Implement image processing for lux estimation
  - _Requirements: 1.1, 1.2_

- [x] 4.4 Implement BLE device strategy
  - File: frontend/src/modules/light_meter/strategies/ble_strategy.ts
  - Connect to BLE light sensors
  - Handle device discovery and connection
  - _Requirements: 1.1, 1.2_

- [x] 4.5 Implement light meter core module
  - File: frontend/src/modules/light_meter/light_meter.ts
  - Implement strategy selection logic
  - Add lux to PPFD conversion
  - _Requirements: 1.1, 1.3, 5.1_

- [x] 4.6 Implement calibration wizard
  - File: frontend/src/modules/light_meter/calibration.ts
  - Create step-by-step calibration flow
  - Store and manage calibration profiles
  - _Requirements: 1.2_

### Growth Tracker Module

- [x] 4.7 Create growth tracker interface
  - File: frontend/src/modules/growth_tracker/types.ts
  - Define interfaces and types
  - Document API contract
  - _Requirements: 5.1, 5.3_

- [x] 4.8 Implement photo capture functionality
  - File: frontend/src/modules/growth_tracker/photo_capture.ts
  - Access device camera
  - Store photos locally
  - _Requirements: 2.1_

- [x] 4.9 Implement basic metrics extraction
  - File: frontend/src/modules/growth_tracker/metrics.ts
  - Extract leaf area and height
  - Implement image processing utilities
  - _Requirements: 2.2_

- [x] 4.10 Implement growth tracker core module
  - File: frontend/src/modules/growth_tracker/growth_tracker.ts
  - Integrate photo capture and processing
  - Manage photo metadata
  - _Requirements: 2.1, 2.3, 5.1_

## Synchronization Implementation

- [x] 5.1 Implement sync queue
  - File: frontend/src/services/sync_service.ts
  - Create queue data structure
  - Add persistence for offline operation
  - _Requirements: 2.3, 3.3_

- [x] 5.2 Implement light readings sync
  - File: frontend/src/services/sync_service.ts
  - Add methods for syncing readings
  - Implement retry with exponential backoff
  - _Requirements: 4.1, 4.2_

- [x] 5.3 Implement growth photos sync
  - File: frontend/src/services/sync_service.ts
  - Add methods for uploading photos
  - Handle large file uploads with progress tracking
  - _Requirements: 4.2_

## UI Implementation

- [x] 6.1 Create light measurement UI
  - File: frontend/src/screens/LightMeasurement.tsx
  - Implement measurement controls
  - Display results with PPFD conversion
  - _Requirements: 1.1, 1.3_

- [x] 6.2 Create growth photo capture UI
  - File: frontend/src/screens/GrowthCapture.tsx
  - Implement camera view and controls
  - Add plant selection
  - _Requirements: 2.1_

- [-] 6.3 Create telemetry history view
  - File: frontend/src/screens/TelemetryHistory.tsx
  - Display light readings history
  - Show growth photos with metrics
  - _Requirements: 3.2, 3.3_

## Testing

- [-] 7.1 Write unit tests for light meter module
  - File: frontend/tests/modules/light_meter.test.ts
  - Test all strategies
  - Mock hardware dependencies
  - _Requirements: 5.2_

- [-] 7.2 Write unit tests for growth tracker module
  - File: frontend/tests/modules/growth_tracker.test.ts
  - Test photo capture and processing
  - Mock camera and file system
  - _Requirements: 5.2_

- [ ] 7.3 Write API integration tests
  - File: backend/tests/api/test_telemetry.py
  - Test all endpoints
  - Verify error handling
  - _Requirements: 4.4_

- [ ] 7.4 Write end-to-end tests
  - File: e2e/telemetry.spec.ts
  - Test complete workflows
  - Verify offline functionality
  - _Requirements: 5.2_

## Monitoring and Metrics

- [ ] 8.1 Implement telemetry metrics collection
  - File: backend/app/services/metrics_service.py
  - Track API usage and performance
  - Monitor error rates
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 8.2 Create dashboard for telemetry metrics
  - File: backend/app/api/routes/admin.py
  - Display key performance indicators
  - Add filtering and time range selection
  - _Requirements: 6.1, 6.2, 6.3_

## Deployment

- [ ] 9.1 Implement feature flags
  - File: backend/app/services/feature_service.py
  - Add flags for gradual rollout
  - Implement A/B testing capability
  - _Requirements: 5.2_

- [ ] 9.2 Create deployment documentation
  - File: docs/deployment/telemetry.md
  - Document deployment steps
  - Include rollback procedures
  - _Requirements: 5.2_