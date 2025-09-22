/// Light Meter Telemetry Integration Extension
/// 
/// This extension integrates the existing LightMeter functionality with telemetry
/// data management, providing automatic data creation, continuous measurement mode,
/// and device status tracking following existing device integration patterns.
library light_meter_telemetry_integration;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core imports
import '../../modules/light_meter/light_meter.dart';
import '../../modules/light_meter/types.dart';

// Telemetry imports
import 'models/telemetry_data_models.dart' as telemetry_models;
import 'providers/telemetry_providers.dart';

/// Extension on LightMeter to add telemetry integration capabilities
/// Provides seamless integration with telemetry data collection and sync
extension LightMeterTelemetryIntegration on LightMeter {
  
  /// Take a light measurement and automatically create telemetry data
  /// 
  /// This method combines the existing measureLux functionality with automatic
  /// telemetry data creation, following the established device integration patterns.
  /// 
  /// Parameters:
  /// - [ref]: Riverpod reference for accessing telemetry repository
  /// - [plantId]: Optional plant identifier to associate with the measurement
  /// - [locationName]: Optional location name for the measurement
  /// - [lightSource]: Light source profile for calibration (default: 'sunlight')
  /// - [includeEnvironmentalData]: Whether to include temperature/humidity if available
  /// 
  /// Returns: [LightReadingData] with the measurement and telemetry metadata
  /// 
  /// Throws: [Exception] if measurement fails or telemetry creation fails
  Future<telemetry_models.LightReadingData> takeMeasurementWithTelemetry(
    WidgetRef ref, {
    String? plantId,
    String? locationName,
    String lightSource = 'sunlight',
    bool includeEnvironmentalData = true,
  }) async {
    try {
      // Get telemetry repository
      final telemetryRepository = ref.read(telemetryRepositoryProvider);
      
      // Take the light measurement using existing functionality
      final luxValue = await measureLux();
      final ppfdValue = luxToPpfd(luxValue, lightSource: lightSource);
      
      // Determine light source based on current strategy
      final lightSourceEnum = _mapStrategyToLightSource(currentStrategy);
      
      // Get device information
      final deviceId = await _getDeviceId();
      
      // Create light reading data
      final lightReadingData = telemetry_models.LightReadingData(
        plantId: plantId,
        luxValue: luxValue,
        ppfdValue: ppfdValue,
        source: lightSourceEnum,
        locationName: locationName,
        deviceId: deviceId,
        measuredAt: DateTime.now(),
        clientTimestamp: DateTime.now(),
        offlineCreated: true,
        syncStatus: telemetry_models.SyncStatus.pending,
        rawData: {
          'strategy': currentStrategy.toString(),
          'light_source_profile': lightSource,
          'calibration_applied': true,
        },
      );
      
      // Wrap in TelemetryData for repository
      final telemetryData = telemetry_models.TelemetryData(
        userId: 'current_user', // TODO: Get from auth service
        plantId: plantId,
        lightReading: lightReadingData,
        offlineCreated: true,
        clientTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Save to telemetry repository and extract the light reading data
      final savedData = await telemetryRepository.create(telemetryData);
      
      return savedData.lightReading!;
    } catch (e) {
      throw Exception('Failed to take measurement with telemetry: $e');
    }
  }
  
  /// Create a continuous measurement stream with telemetry integration
  /// 
  /// This method provides continuous light measurements with automatic telemetry
  /// data creation at specified intervals, supporting device status tracking.
  /// 
  /// Parameters:
  /// - [ref]: Riverpod reference for accessing telemetry repository
  /// - [interval]: Duration between measurements (default: 30 seconds)
  /// - [plantId]: Optional plant identifier to associate with measurements
  /// - [locationName]: Optional location name for measurements
  /// - [lightSource]: Light source profile for calibration (default: 'sunlight')
  /// - [maxMeasurements]: Maximum number of measurements (null for unlimited)
  /// 
  /// Returns: [Stream<LightReadingData>] of continuous measurements with telemetry
  Stream<telemetry_models.LightReadingData> continuousMeasurementStream(
    WidgetRef ref, {
    Duration interval = const Duration(seconds: 30),
    String? plantId,
    String? locationName,
    String lightSource = 'sunlight',
    int? maxMeasurements,
  }) async* {
    int measurementCount = 0;
    
    // Create a periodic timer for measurements
    final timer = Stream.periodic(interval);
    
    await for (final _ in timer) {
      try {
        // Check if we've reached the maximum number of measurements
        if (maxMeasurements != null && measurementCount >= maxMeasurements) {
          break;
        }
        
        // Take measurement with telemetry
        final measurement = await takeMeasurementWithTelemetry(
          ref,
          plantId: plantId,
          locationName: locationName,
          lightSource: lightSource,
        );
        
        measurementCount++;
        yield measurement;
        
      } catch (e) {
        // Log error but continue stream
        // Optionally yield an error measurement or skip
        continue;
      }
    }
  }
  
  /// Get device status information for telemetry tracking
  /// 
  /// This method provides device status information that can be used for
  /// telemetry data enrichment and device tracking.
  /// 
  /// Returns: [Map<String, dynamic>] with device status information
  Future<Map<String, dynamic>> getDeviceStatusForTelemetry() async {
    try {
      final deviceId = await _getDeviceId();
      final strategyName = await getCurrentStrategyName();
      final strategyAvailable = await isStrategyAvailable(currentStrategy);
      
      return {
        'device_id': deviceId,
        'current_strategy': currentStrategy.toString(),
        'strategy_name': strategyName,
        'strategy_available': strategyAvailable,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      };
    } catch (e) {
      return {
        'error': 'Failed to get device status: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Create a batch of measurements with telemetry integration
  /// 
  /// This method allows taking multiple measurements in sequence and creating
  /// telemetry data for each, useful for calibration or validation scenarios.
  /// 
  /// Parameters:
  /// - [ref]: Riverpod reference for accessing telemetry repository
  /// - [count]: Number of measurements to take
  /// - [interval]: Duration between measurements (default: 5 seconds)
  /// - [plantId]: Optional plant identifier to associate with measurements
  /// - [locationName]: Optional location name for measurements
  /// - [lightSource]: Light source profile for calibration (default: 'sunlight')
  /// 
  /// Returns: [List<LightReadingData>] of all measurements with telemetry
  Future<List<telemetry_models.LightReadingData>> takeBatchMeasurementsWithTelemetry(
    WidgetRef ref, {
    required int count,
    Duration interval = const Duration(seconds: 5),
    String? plantId,
    String? locationName,
    String lightSource = 'sunlight',
  }) async {
    final measurements = <telemetry_models.LightReadingData>[];
    
    for (int i = 0; i < count; i++) {
      try {
        final measurement = await takeMeasurementWithTelemetry(
          ref,
          plantId: plantId,
          locationName: locationName,
          lightSource: lightSource,
        );
        
        measurements.add(measurement);
        
        // Wait before next measurement (except for the last one)
        if (i < count - 1) {
          await Future.delayed(interval);
        }
      } catch (e) {
        // Continue with remaining measurements
      }
    }
    
    return measurements;
  }
  
  // Private helper methods
  
  /// Map LightMeterStrategy to LightSource enum
  telemetry_models.LightSource _mapStrategyToLightSource(LightMeterStrategy strategy) {
    switch (strategy) {
      case LightMeterStrategy.ambientLightSensor:
        return telemetry_models.LightSource.als;
      case LightMeterStrategy.camera:
        return telemetry_models.LightSource.camera;
    }
  }
  
  /// Get device identifier for telemetry tracking
  Future<String> _getDeviceId() async {
    try {
      // Use platform-specific device identification
      if (Platform.isAndroid || Platform.isIOS) {
        // In a real implementation, you would use device_info_plus package
        // For now, return a placeholder based on platform
        return '${Platform.operatingSystem}_device_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        return 'desktop_device_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}

/// Utility class for light meter telemetry operations
/// 
/// Provides static methods for common telemetry operations that don't require
/// a LightMeter instance, following the established utility patterns.
class LightMeterTelemetryUtils {
  
  /// Convert LightReading to LightReadingData for telemetry
  /// 
  /// This utility method converts the light_meter module's LightReading
  /// to the telemetry module's LightReadingData format.
  static telemetry_models.LightReadingData convertLightReadingToTelemetry(
    LightReading lightReading, {
    String? plantId,
    telemetry_models.SyncStatus syncStatus = telemetry_models.SyncStatus.pending,
    bool offlineCreated = true,
  }) {
    return telemetry_models.LightReadingData(
      plantId: plantId,
      luxValue: lightReading.lux,
      ppfdValue: lightReading.ppfdValue,
      source: _mapStringToLightSource(lightReading.source),
      locationName: lightReading.locationName,
      gpsLatitude: lightReading.gpsLatitude,
      gpsLongitude: lightReading.gpsLongitude,
      altitude: lightReading.altitude,
      temperature: lightReading.temperature,
      humidity: lightReading.humidity,
      deviceId: lightReading.deviceId,
      measuredAt: DateTime.parse(lightReading.takenAt),
      clientTimestamp: DateTime.now(),
      syncStatus: syncStatus,
      offlineCreated: offlineCreated,
      rawData: lightReading.rawData,
    );
  }
  
  /// Map string source to LightSource enum
  static telemetry_models.LightSource _mapStringToLightSource(String source) {
    switch (source.toLowerCase()) {
      case 'als':
      case 'ambient_light_sensor':
        return telemetry_models.LightSource.als;
      case 'camera':
        return telemetry_models.LightSource.camera;
      case 'ble':
      case 'bluetooth':
        return telemetry_models.LightSource.ble;
      case 'manual':
        return telemetry_models.LightSource.manual;
      default:
        return telemetry_models.LightSource.manual;
    }
  }
  
  /// Create telemetry session ID for grouping related measurements
  static String createTelemetrySessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
  
  /// Validate telemetry data before saving
  static bool validateTelemetryData(telemetry_models.LightReadingData data) {
    // Basic validation rules
    if (data.luxValue < 0 || data.luxValue > 200000) {
      return false;
    }
    
    if (data.ppfdValue != null && (data.ppfdValue! < 0 || data.ppfdValue! > 3000)) {
      return false;
    }
    
    if (data.temperature != null && (data.temperature! < -50 || data.temperature! > 70)) {
      return false;
    }
    
    if (data.humidity != null && (data.humidity! < 0 || data.humidity! > 100)) {
      return false;
    }
    
    return true;
  }
}