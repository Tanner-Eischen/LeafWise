# Growth Tracker Module

The Growth Tracker module provides functionality for capturing, processing, and managing plant growth photos. It enables users to track plant growth over time through periodic photos and extract metrics for analysis.

## Features

- Photo capture for plant growth tracking (camera or gallery)
- Metric extraction from photos (height, width, leaf count, color analysis)
- Local storage and management of growth photos
- Growth stage estimation
- Growth rate calculation between records

## Usage

```dart
import 'package:leafwise/modules/growth_tracker/index.dart';

// Get the growth tracker instance
final growthTracker = GrowthTracker();

// Capture a growth photo
Future<void> captureGrowthPhoto() async {
  try {
    // Capture using camera
    final record = await growthTracker.captureGrowthPhoto(
      useCamera: true,
      notes: 'Weekly growth check',
    );
    
    if (record != null) {
      print('Photo captured: ${record.photoPath}');
      
      // Analyze the photo to extract metrics
      final analyzedRecord = await growthTracker.analyzeGrowthRecord(record);
      print('Photo analyzed with metrics:');
      print('Height: ${analyzedRecord.metrics?.height} cm');
      print('Width: ${analyzedRecord.metrics?.width} cm');
      print('Leaf count: ${analyzedRecord.metrics?.leafCount}');
      print('Health score: ${analyzedRecord.metrics?.healthScore}');
      
      // Get growth stage
      final stage = growthTracker.getGrowthStage(
        analyzedRecord.metrics!,
        'generic', // Plant type
      );
      print('Growth stage: $stage');
      
      return analyzedRecord;
    } else {
      print('Photo capture cancelled');
      return null;
    }
  } catch (e) {
    print('Error capturing growth photo: $e');
    rethrow;
  }
}

// Compare two growth records
void compareGrowthRecords(GrowthRecord oldRecord, GrowthRecord newRecord) {
  final growthRates = growthTracker.compareGrowthRecords(oldRecord, newRecord);
  
  print('Growth rates:');
  print('Height: ${growthRates['height']?.toStringAsFixed(2)} cm/day');
  print('Width: ${growthRates['width']?.toStringAsFixed(2)} cm/day');
  print('Leaf count: ${growthRates['leafCount']?.toStringAsFixed(2)} leaves/day');
}
  return result;
}

// Get photos for a specific plant
async function getPlantPhotos(plantId: string) {
  const photos = await growthTracker.getPhotosByPlantId(plantId);
  console.log(`Found ${photos.length} photos for plant ${plantId}`);
  return photos;
}
```

## Configuration

The Growth Tracker module can be configured with custom options:

```typescript
import { getGrowthTracker } from './modules/growth_tracker';

const growthTracker = getGrowthTracker({
  default_upload_options: {
    auto_retry: true,
    max_retries: 5,
    wifi_only: true,
    compress: true,
    compression_quality: 85,
  },
  auto_process: true,
  auto_queue: true,
  max_local_photos: 200,
});
```

## API Reference

See the `types.ts` file for detailed interface definitions and the `index.ts` file for implementation details.