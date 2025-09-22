// Ambient Light Sensor strategy for light meter
// This strategy uses the device's ambient light sensor to measure light intensity

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:light/light.dart';
import 'dart:io' show Platform;

/// Strategy for measuring light using the device's ambient light sensor
class ALSStrategy {
  Light? _light;
  StreamSubscription<int>? _subscription;
  int _lastLuxValue = 0;
  final _luxController = StreamController<double>.broadcast();
  
  /// Initialize the ambient light sensor
  Future<void> initialize() async {
    try {
      // Only initialize on Android platform
      if (!kIsWeb && Platform.isAndroid) {
        _light = Light();
        _subscription = _light!.lightSensorStream.listen(_onLuxData);
      } else {
        throw Exception('Light sensor API only available on Android.');
      }
    } catch (e) {
      debugPrint('Error initializing ambient light sensor: $e');
      rethrow;
    }
  }
  
  /// Check if the ambient light sensor is available on the device
  Future<bool> isAvailable() async {
    try {
      // Only check for sensor on Android platform
      if (!kIsWeb && Platform.isAndroid) {
        _light ??= Light();
        // If we can get a value, the sensor is available
        await _light!.lightSensorStream.first.timeout(
          const Duration(seconds: 1),
          onTimeout: () => -1,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Ambient light sensor not available: $e');
      return false;
    }
  }
  
  /// Handle incoming lux data from the sensor
  void _onLuxData(int luxValue) {
    if (luxValue >= 0) {
      _lastLuxValue = luxValue;
      _luxController.add(luxValue.toDouble());
    }
  }
  
  /// Get a stream of lux values
  Stream<double> get luxStream => _luxController.stream;
  
  /// Measure light intensity in lux
  Future<double> measureLux() async {
    if (_light == null) {
      await initialize();
    }
    
    // If we already have a value, return it immediately
    if (_lastLuxValue > 0) {
      return _lastLuxValue.toDouble();
    }
    
    // Otherwise, wait for the next value with a timeout
    try {
      final value = await _luxController.stream.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException('Timeout waiting for light sensor data'),
      );
      return value;
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Could not get light sensor reading in time');
      }
      rethrow;
    }
  }
  
  /// Dispose resources used by the strategy
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _luxController.close();
  }
}