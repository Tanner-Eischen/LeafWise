# LeafWise Core Module

This directory contains the core functionality of the LeafWise application, including API clients, hooks, utility functions, and TypeScript type definitions.

## Plant Identification

The plant identification feature allows users to identify plants by submitting images to the Plant.id API. The implementation follows a layered architecture:

### Architecture

```
UI Components
    ↓
usePlantIdentification Hook
    ↓
PlantIdentificationService
    ↓
PlantIdClient
    ↓
Plant.id API
```

### Key Components

#### Types (`/types/plantIdentification.ts`)

Contains all TypeScript interfaces and types for the plant identification feature, including:

- `PlantIdentificationRequest` - Request payload for the API
- `PlantIdentificationResponse` - Response from the API
- `PlantInfo` - Simplified plant information for UI display
- `PlantIdError` - Standardized error format

#### API Client (`/api/plantIdClient.ts`)

Handles direct communication with the Plant.id API:

- Authentication with API key
- Image submission
- Response parsing
- Error handling

#### Service Layer (`/api/plantIdentificationService.ts`)

Provides higher-level functionality:

- Caching of identification results
- Business logic for confidence thresholds
- Formatting of API responses for application use
- Comprehensive error handling

#### React Hook (`/hooks/usePlantIdentification.ts`)

Provides a React interface for the plant identification feature:

- State management for loading, results, and errors
- Automatic initialization
- Methods for identification and result management
- Caching statistics

### Usage Example

```typescript
import { usePlantIdentification } from '../core/hooks/usePlantIdentification';
import { ImageData, Location } from '../core/types';

function PlantIdentificationScreen() {
  const {
    isLoading,
    result,
    error,
    identifyPlant,
    clearResult,
    clearError
  } = usePlantIdentification();

  const handleIdentify = async (imageData: ImageData, location?: Location) => {
    try {
      await identifyPlant(imageData, location);
    } catch (err) {
      console.error('Identification failed:', err);
    }
  };

  // Render UI based on state...
}
```

### Configuration

The plant identification feature is configured in `config/plantId.ts` with the following options:

- `apiKey` - Plant.id API key
- `baseUrl` - API endpoint URL
- `timeout` - Request timeout in milliseconds
- `retryAttempts` - Number of retry attempts for failed requests
- `enableCaching` - Whether to cache identification results
- `cacheTTL` - Time-to-live for cached results in milliseconds

### Error Handling

Errors are standardized using the `PlantIdError` interface with the following properties:

- `code` - Error code for programmatic handling
- `message` - Human-readable error message
- `details` - Additional error information

Common error codes include:

- `api_error` - General API communication error
- `authentication_error` - Invalid API key
- `rate_limit_exceeded` - Too many requests
- `invalid_image` - Image format or size not supported
- `no_plant_detected` - No plant found in the image

## Testing

The plant identification feature includes comprehensive tests:

- Unit tests for the API client
- Integration tests for the service layer
- Hook tests using React Testing Library

Run tests with:

```bash
npm test -- --testPathPattern=plantIdentification
```