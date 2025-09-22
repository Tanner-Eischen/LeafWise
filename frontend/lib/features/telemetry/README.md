# Telemetry Feature

## Overview

The Telemetry feature provides functionality for capturing, viewing, and analyzing plant telemetry data including light measurements and growth photos. It integrates with the light_meter and growth_tracker modules to provide a complete telemetry solution for plant care.

## Components

### Screens

1. **LightMeasurementScreen** - Provides UI for measuring light intensity using device sensors and converting measurements to PPFD (Photosynthetic Photon Flux Density).

2. **GrowthPhotoCaptureScreen** - Enables users to capture and analyze plant growth photos, extracting metrics like height, width, leaf count, and color analysis.

3. **TelemetryHistoryScreen** - Displays historical telemetry data including light readings and growth photos with visualization and filtering options.

### Navigation

- **TelemetryNavigator** - Provides navigation routes for the telemetry feature screens and helper methods for navigation.

### Main Component

- **TelemetryFeature** - Main entry point for the telemetry feature that can be integrated into the app's main navigation structure.

## Integration

To integrate the Telemetry feature into the main app:

```dart
import 'package:leafwise/features/telemetry/index.dart';

// In your main navigation
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => const TelemetryFeature()),
);

// Or using the navigator helper
TelemetryNavigator.navigateToTelemetry(context);
```

## Data Flow

1. **Data Capture**:
   - Light readings are captured using the LightMeter module
   - Growth photos are captured using the GrowthTracker module

2. **Data Persistence**:
   - Captured data is queued for syncing using the SyncQueue service
   - Data is synced to the backend when connectivity is available

3. **Data Visualization**:
   - Historical data is displayed in the TelemetryHistory screen
   - Charts and graphs provide visual representation of plant growth and light conditions

## Usage

You can navigate directly to specific screens using the TelemetryNavigator:

```dart
// Navigate to light measurement screen
TelemetryNavigator.navigateToLightMeasurement(context);

// Navigate to growth photo capture for a specific plant
TelemetryNavigator.navigateToGrowthPhotoCapture(context, plantId: 'plant-123');

// Navigate to telemetry history for a specific plant
TelemetryNavigator.navigateToTelemetryHistory(context, plantId: 'plant-123');
```

## Dependencies

- **light_meter** module - For capturing light readings
- **growth_tracker** module - For capturing and analyzing growth photos
- **sync_service** - For data persistence and synchronization
- **@react-navigation/stack** - For screen navigation
- **react-native-paper** - For UI components
- **react-native-chart-kit** - For data visualization