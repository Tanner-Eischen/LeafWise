# Light Meter Module

The Light Meter module provides functionality for measuring light intensity using various strategies (ALS, Camera) and converting measurements to PPFD (Photosynthetic Photon Flux Density) estimates. It implements the strategy pattern for hardware interactions and provides a clean interface for the rest of the application.

## Features

- Multiple measurement strategies:
  - Ambient Light Sensor (ALS)
  - Camera-based measurement
- Conversion from lux to PPFD estimates
- Calibration system for improved accuracy
- Plant recommendations based on light levels

## Usage

```dart
import 'package:leafwise/modules/light_meter/index.dart';

Future<void> measureLight() async {
  final lightMeter = LightMeter();
  
  // Check available strategies
  final bestStrategy = await lightMeter.getBestAvailableStrategy();
  
  // Initialize with the best strategy
  await lightMeter.initialize(bestStrategy);
  
  try {
    // Take a lux measurement
    final luxReading = await lightMeter.measureLux();
    print('Light reading (lux): $luxReading');
    
    // Convert to PPFD with specific light source
    final ppfdReading = lightMeter.luxToPpfd(luxReading, lightSource: 'sunlight');
    print('Light reading (PPFD): $ppfdReading μmol/m²/s');
    
    // Or measure PPFD directly
    final directPpfd = await lightMeter.measurePpfd(lightSource: 'led_full_spectrum');
    print('Direct PPFD reading: $directPpfd μmol/m²/s');
    
    // Get plant recommendations
    final calibration = LightCalibration();
    final recommendations = calibration.getPlantRecommendations(ppfdReading);
    print('Recommended plants: $recommendations');
    
    return directPpfd;
  } catch (e) {
    print('Error measuring light: $e');
    rethrow;
  } finally {
    // Clean up resources
    await lightMeter.dispose();
  }
}
      
      // Take a measurement
      const reading = await lightMeter.measure(strategy, context);
      console.log('Light reading:', reading);
      
      // Use the reading...
      return reading;
    } catch (cameraError) {
      console.error('Light measurement failed:', cameraError);
      throw cameraError;
    }
  }
}
```

## Calibration

To improve measurement accuracy, you can run the calibration wizard:

```typescript
import { getLightMeter } from './modules/light_meter';

async function calibrateLightMeter() {
  const lightMeter = getLightMeter();
  
  // Run the calibration wizard
  const calibrationProfileId = await lightMeter.runCalibrationWizard('CAMERA');
  console.log('Created calibration profile:', calibrationProfileId);
  
  // Use the calibration profile with a strategy
  const strategy = lightMeter.getStrategy('CAMERA', calibrationProfileId);
  
  // Now measurements will use the calibration
}
```

### Using the Calibration Wizard Directly

For more control over the calibration process, you can use the calibration wizard directly:

```typescript
import { createCalibrationWizard } from './modules/light_meter/calibration';

async function manualCalibration() {
  // Create a calibration wizard for the camera strategy
  const wizard = createCalibrationWizard('CAMERA');
  
  // Get the first step
  let currentStep = wizard.getCurrentStep();
  console.log(`Step: ${currentStep.title}`);
  console.log(`Instructions: ${currentStep.instructions}`);
  
  // Navigate through steps
  while (wizard.hasNextStep()) {
    currentStep = wizard.nextStep();
    console.log(`Step: ${currentStep.title}`);
    console.log(`Instructions: ${currentStep.instructions}`);
    
    // If this step requires a measurement
    if (currentStep.requiresMeasurement) {
      if (currentStep.referenceLux) {
        // This is a reference step where the user would input a value
        const referenceValue = 500; // This would come from user input
        wizard.recordMeasurement(referenceValue);
      } else {
        // Take a measurement using the strategy
        const lux = await wizard.takeMeasurement();
        wizard.recordMeasurement(lux);
      }
    }
  }
  
  // Complete the calibration
  const profile = wizard.completeCalibration('My Custom Calibration');
  console.log(`Calibration complete. Profile ID: ${profile.id}`);
}
```

## API Reference

### LightMeter

The main class that provides a unified interface for light measurement.

#### Methods

- `static getInstance()`: Gets the singleton instance of LightMeter
- `getStrategy(type, calibrationProfileId?)`: Gets a strategy for light measurement
- `measure(strategy, context)`: Measures light with the selected strategy
- `convertLuxToPPFD(lux, profile)`: Converts lux to PPFD estimate
- `runCalibrationWizard(strategyType)`: Runs a calibration wizard for the specified strategy
- `getCalibrationProfiles()`: Gets all available calibration profiles
- `saveCalibrationProfiles(profiles)`: Saves calibration profiles

### CalibrationWizard

A class that guides users through the calibration process.

#### Methods

- `getCurrentStep()`: Gets the current calibration step
- `hasNextStep()`: Checks if there are more steps in the calibration process
- `nextStep()`: Advances to the next calibration step
- `hasPreviousStep()`: Checks if there are previous steps in the calibration process
- `previousStep()`: Returns to the previous calibration step
- `takeMeasurement()`: Takes a measurement using the current strategy
- `recordMeasurement(lux)`: Records a measurement for the current step
- `completeCalibration(name)`: Completes the calibration and creates a profile

#### Factory Function

- `createCalibrationWizard(strategyType)`: Creates a new calibration wizard for the specified strategy

### LightMeterStrategy

An interface that defines the contract for light measurement strategies.

#### Methods

- `measure(context)`: Measures the current light intensity with context
- `isAvailable()`: Checks if this measurement strategy is available
- `getCalibrationFactor()`: Gets the current calibration factor
- `loadCalibrationProfile(profile)`: Loads a calibration profile

### Types

- `LightReading`: Represents a light measurement with lux, PPFD estimate, and context
- `CalibrationProfile`: Represents a calibration profile with factor and device model
- `MeasurementContext`: Context information for a light measurement
- `CalibrationStep`: Represents a step in the calibration process
- `CalibrationWizardState`: Represents the state of the calibration wizard

See `types.ts` for complete type definitions.

## File Structure

- `index.ts`: Main module entry point and LightMeter implementation
- `types.ts`: Type definitions and interfaces
- `calibration.ts`: Calibration wizard implementation
- `calibration.test.ts`: Tests for the calibration wizard
- `README.md`: This documentation file
- `strategies/`: Folder containing measurement strategy implementations
  - `als_strategy.ts`: Ambient Light Sensor strategy
  - `als_strategy.test.ts`: Tests for the ALS strategy
  - `camera_strategy.ts`: Camera-based strategy
  - `camera_strategy.test.ts`: Tests for the camera strategy