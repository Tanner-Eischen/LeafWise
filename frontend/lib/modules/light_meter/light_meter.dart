// Light meter module for measuring light intensity using different strategies
// This module provides functionality to measure light using ambient light sensor or camera

import 'dart:async';

import 'strategies/als_strategy.dart';
import 'strategies/camera_strategy.dart';
import 'calibration.dart';

/// Enum representing different light measurement strategies
enum LightMeterStrategy {
  ambientLightSensor,
  camera,
}

/// Class for measuring light intensity using different strategies
class LightMeter {
  static final LightMeter _instance = LightMeter._internal();
  
  /// Factory constructor to return the singleton instance
  factory LightMeter() {
    return _instance;
  }
  
  LightMeter._internal();
  
  ALSStrategy? _alsStrategy;
  CameraStrategy? _cameraStrategy;
  LightMeterStrategy _currentStrategy = LightMeterStrategy.ambientLightSensor;
  final LightCalibration _calibration = LightCalibration();
  
  /// Initialize the light meter with the specified strategy
  Future<void> initialize(LightMeterStrategy strategy) async {
    _currentStrategy = strategy;
    
    if (strategy == LightMeterStrategy.ambientLightSensor) {
      _alsStrategy ??= ALSStrategy();
      await _alsStrategy!.initialize();
    } else {
      _cameraStrategy ??= CameraStrategy();
      await _cameraStrategy!.initialize();
    }
  }
  
  /// Check if the current strategy is available on the device
  Future<bool> isStrategyAvailable(LightMeterStrategy strategy) async {
    if (strategy == LightMeterStrategy.ambientLightSensor) {
      _alsStrategy ??= ALSStrategy();
      return await _alsStrategy!.isAvailable();
    } else {
      _cameraStrategy ??= CameraStrategy();
      return await _cameraStrategy!.isAvailable();
    }
  }
  
  /// Get the name of the current strategy
  Future<String> getCurrentStrategyName() async {
    return _currentStrategy == LightMeterStrategy.ambientLightSensor
        ? 'Ambient Light Sensor'
        : 'Camera';
  }
  
  /// Measure light intensity in lux using the current strategy
  Future<double> measureLux() async {
    if (_currentStrategy == LightMeterStrategy.ambientLightSensor) {
      if (_alsStrategy == null) {
        throw Exception('ALS Strategy not initialized');
      }
      return await _alsStrategy!.measureLux();
    } else {
      if (_cameraStrategy == null) {
        throw Exception('Camera Strategy not initialized');
      }
      return await _cameraStrategy!.measureLux();
    }
  }
  
  /// Convert lux to PPFD (Photosynthetic Photon Flux Density) in μmol/m²/s
  double luxToPpfd(double lux, {String lightSource = 'sunlight'}) {
    return _calibration.luxToPpfd(lux, lightSource: lightSource);
  }
  
  /// Get a description of the light intensity based on PPFD value
  String getLightIntensityDescription(double ppfd) {
    return _calibration.getLightIntensityDescription(ppfd);
  }
  
  /// Get plant recommendations based on PPFD value
  String getPlantRecommendation(double ppfd) {
    return _calibration.getPlantRecommendation(ppfd);
  }
  
  /// Get the best available strategy for the current device
  Future<LightMeterStrategy> getBestAvailableStrategy() async {
    if (await isStrategyAvailable(LightMeterStrategy.ambientLightSensor)) {
      return LightMeterStrategy.ambientLightSensor;
    } else if (await isStrategyAvailable(LightMeterStrategy.camera)) {
      return LightMeterStrategy.camera;
    } else {
      throw Exception('No light measurement strategy available on this device');
    }
  }
  
  /// Set the current strategy
  Future<void> setStrategy(LightMeterStrategy strategy) async {
    if (await isStrategyAvailable(strategy)) {
      _currentStrategy = strategy;
      await initialize(strategy);
    } else {
      throw Exception('Selected strategy is not available on this device');
    }
  }
  
  /// Get the current strategy
  LightMeterStrategy get currentStrategy => _currentStrategy;
  
  // These methods are already defined above, removing duplicates
  
  /// Measure light intensity in PPFD
  Future<double> measurePpfd({String lightSource = 'sunlight'}) async {
    final lux = await measureLux();
    return luxToPpfd(lux, lightSource: lightSource);
  }
  
  /// Dispose resources used by the light meter
  Future<void> dispose() async {
    if (_alsStrategy != null) {
      await _alsStrategy!.dispose();
      _alsStrategy = null;
    }
    
    if (_cameraStrategy != null) {
      await _cameraStrategy!.dispose();
      _cameraStrategy = null;
    }
  }
}