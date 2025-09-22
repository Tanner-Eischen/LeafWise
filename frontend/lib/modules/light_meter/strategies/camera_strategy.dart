// Camera strategy for light meter
// This strategy uses the device's camera to estimate light intensity

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Strategy for measuring light using the device's camera
class CameraStrategy {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  
  /// Initialize the camera
  Future<void> initialize() async {
    try {
      // Only initialize on mobile platforms
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _cameras = await availableCameras();
        if (_cameras == null || _cameras!.isEmpty) {
          throw Exception('No cameras available on this device');
        }
        
        // Use the back camera by default
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
        
        _controller = CameraController(
          backCamera,
          ResolutionPreset.low, // Lower resolution for faster processing
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
      } else {
        throw Exception('Camera API only available on mobile platforms');
      }
      
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      rethrow;
    }
  }
  
  /// Check if the camera is available on the device
  Future<bool> isAvailable() async {
    try {
      // Only check on mobile platforms
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final cameras = await availableCameras();
        return cameras.isNotEmpty;
      }
      return false;
    } catch (e) {
      debugPrint('Camera not available: $e');
      return false;
    }
  }
  
  /// Measure light intensity in lux using the camera
  Future<double> measureLux() async {
    if (!_isInitialized || _controller == null) {
      await initialize();
    }
    
    if (!_controller!.value.isInitialized) {
      throw Exception('Camera controller is not initialized');
    }
    
    try {
      // Capture an image
      final file = await _controller!.takePicture();
      
      // Process the image to estimate light intensity
      final lux = await _processImageForLux(file.path);
      return lux;
    } catch (e) {
      debugPrint('Error measuring lux with camera: $e');
      rethrow;
    }
  }
  
  /// Process image file to estimate light intensity in lux
  Future<double> _processImageForLux(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes.buffer.asUint8List());
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Calculate average brightness
      double totalBrightness = 0;
      int pixelCount = 0;
      
      // Sample pixels for efficiency (every 10th pixel)
      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          
          // Calculate perceived brightness using the luminance formula
          final brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b;
          totalBrightness += brightness;
          pixelCount++;
        }
      }
      
      final averageBrightness = totalBrightness / pixelCount;
      
      // Convert brightness to lux (approximate)
      // This is a very rough approximation and would need calibration
      // The formula is based on empirical testing and should be calibrated for each device
      final lux = math.pow(averageBrightness / 10, 2) * 50;
      
      // Clean up the image file
      await File(imagePath).delete();
      
      return lux.toDouble();
    } catch (e) {
      debugPrint('Error processing image for lux: $e');
      rethrow;
    }
  }
  
  /// Dispose resources used by the strategy
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }
}