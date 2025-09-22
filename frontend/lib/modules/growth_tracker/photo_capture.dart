// Photo capture module for the growth tracker
// This module provides functionality to capture photos using camera or gallery

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Class for capturing photos for growth tracking
class PhotoCapture {
  final ImagePicker _picker = ImagePicker();
  
  /// Capture a photo using camera or pick from gallery
  /// 
  /// [useCamera] Whether to use the camera or pick from gallery
  /// 
  /// Returns the path to the captured photo, or null if cancelled
  Future<String?> capturePhoto({required bool useCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80, // Reduce quality slightly for storage efficiency
      );
      
      if (image == null) {
        return null; // User cancelled
      }
      
      // Copy the image to app storage for persistence
      final storedPath = await _storeImage(File(image.path));
      return storedPath;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      rethrow;
    }
  }
  
  /// Store an image in the app's documents directory
  /// 
  /// [imageFile] The image file to store
  /// 
  /// Returns the path to the stored image
  Future<String> _storeImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final growthDir = Directory('${appDir.path}/growth_photos');
      
      if (!await growthDir.exists()) {
        await growthDir.create(recursive: true);
      }
      
      final fileName = 'growth_${const Uuid().v4()}${path.extension(imageFile.path)}';
      final storedImage = await imageFile.copy('${growthDir.path}/$fileName');
      
      return storedImage.path;
    } catch (e) {
      debugPrint('Error storing image: $e');
      rethrow;
    }
  }
  
  /// Delete a photo from storage
  /// 
  /// [photoPath] The path to the photo to delete
  Future<void> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      rethrow;
    }
  }
  
  /// Dispose resources used by the photo capture
  Future<void> dispose() async {
    // No resources to dispose currently
  }
}