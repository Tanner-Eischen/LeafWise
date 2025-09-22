/// Local storage service for offline plant identification data
/// Handles persistent storage and retrieval of local identifications and images
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/storage_service.dart';
import '../models/offline_plant_identification_models.dart';

/// Provider for the local storage service
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LocalStorageService(storageService);
});

/// Service for managing local plant identification data and images
class LocalStorageService {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  
  static const String _identificationsKey = 'local_plant_identifications';
  static const String _imagesDirectoryName = 'plant_images';
  
  LocalStorageService(this._storageService);

  /// Initialize the local storage service
  /// Creates necessary directories and performs cleanup if needed
  Future<void> initialize() async {
    await _ensureImageDirectoryExists();
    await _cleanupOrphanedImages();
  }

  /// Store a local plant identification
  /// Saves the identification data and optionally copies the image to local storage
  Future<LocalPlantIdentification> storeIdentification(
    LocalPlantIdentification identification, {
    File? imageFile,
  }) async {
    try {
      // Copy image to local storage if provided
      String? localImagePath = identification.localImagePath;
      if (imageFile != null) {
        localImagePath = await _storeImage(imageFile);
      }
      
      // Update identification with local image path
      final updatedIdentification = identification.copyWith(
        localImagePath: localImagePath ?? identification.localImagePath,
      );
      
      // Get existing identifications
      final identifications = await getAllIdentifications();
      
      // Add or update the identification
      final updatedList = _updateIdentificationInList(identifications, updatedIdentification);
      
      // Save to storage
      await _saveIdentifications(updatedList);
      
      return updatedIdentification;
    } catch (e) {
      throw LocalStorageException('Failed to store identification: $e');
    }
  }

  /// Retrieve all local plant identifications
  /// Returns a list of all stored identifications, sorted by identification date
  Future<List<LocalPlantIdentification>> getAllIdentifications() async {
    try {
      final jsonString = await _storageService.getString(_identificationsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final identifications = jsonList
          .map((json) => LocalPlantIdentification.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by identification date (newest first)
      identifications.sort((a, b) => b.identifiedAt.compareTo(a.identifiedAt));
      
      return identifications;
    } catch (e) {
      throw LocalStorageException('Failed to retrieve identifications: $e');
    }
  }

  /// Get a specific identification by local ID
  /// Returns the identification if found, null otherwise
  Future<LocalPlantIdentification?> getIdentificationById(String localId) async {
    try {
      final identifications = await getAllIdentifications();
      return identifications.where((id) => id.localId == localId).firstOrNull;
    } catch (e) {
      throw LocalStorageException('Failed to get identification by ID: $e');
    }
  }

  /// Update an existing identification
  /// Merges the provided data with existing identification
  Future<LocalPlantIdentification> updateIdentification(
    String localId,
    LocalPlantIdentification updatedIdentification,
  ) async {
    try {
      final identifications = await getAllIdentifications();
      final index = identifications.indexWhere((id) => id.localId == localId);
      
      if (index == -1) {
        throw LocalStorageException('Identification not found: $localId');
      }
      
      identifications[index] = updatedIdentification;
      await _saveIdentifications(identifications);
      
      return updatedIdentification;
    } catch (e) {
      throw LocalStorageException('Failed to update identification: $e');
    }
  }

  /// Delete an identification and its associated image
  /// Removes both the data record and the local image file
  Future<void> deleteIdentification(String localId) async {
    try {
      final identifications = await getAllIdentifications();
      final identification = identifications.where((id) => id.localId == localId).firstOrNull;
      
      if (identification != null) {
        // Delete associated image
        await _deleteImage(identification.localImagePath);
        
        // Remove from list
        identifications.removeWhere((id) => id.localId == localId);
        await _saveIdentifications(identifications);
      }
    } catch (e) {
      throw LocalStorageException('Failed to delete identification: $e');
    }
  }

  /// Get identifications by sync status
  /// Useful for finding identifications that need to be synced
  Future<List<LocalPlantIdentification>> getIdentificationsBySyncStatus(
    SyncStatus Function() statusMatcher,
  ) async {
    try {
      final identifications = await getAllIdentifications();
      return identifications.where((id) => id.syncStatus.runtimeType == statusMatcher().runtimeType).toList();
    } catch (e) {
      throw LocalStorageException('Failed to get identifications by sync status: $e');
    }
  }

  /// Get unsynced identifications
  /// Returns all identifications that haven't been synced to the server
  Future<List<LocalPlantIdentification>> getUnsyncedIdentifications() async {
    try {
      final identifications = await getAllIdentifications();
      return identifications.where((id) => id.syncStatus.maybeWhen(
        notSynced: () => true,
        orElse: () => false,
      )).toList();
    } catch (e) {
      throw LocalStorageException('Failed to get unsynced identifications: $e');
    }
  }

  /// Get failed sync identifications
  /// Returns all identifications that failed to sync
  Future<List<LocalPlantIdentification>> getFailedSyncIdentifications() async {
    try {
      final identifications = await getAllIdentifications();
      return identifications.where((id) => id.syncStatus.maybeWhen(
        failed: (_) => true,
        orElse: () => false,
      )).toList();
    } catch (e) {
      throw LocalStorageException('Failed to get failed sync identifications: $e');
    }
  }

  /// Clear all local identifications and images
  /// WARNING: This will permanently delete all local data
  Future<void> clearAllData() async {
    try {
      // Delete all images
      final imageDir = await _getImageDirectory();
      if (await imageDir.exists()) {
        await imageDir.delete(recursive: true);
      }
      
      // Clear identifications data
      await _storageService.remove(_identificationsKey);
      
      // Recreate image directory
      await _ensureImageDirectoryExists();
    } catch (e) {
      throw LocalStorageException('Failed to clear all data: $e');
    }
  }

  /// Get storage usage statistics
  /// Returns information about local storage usage
  Future<StorageStats> getStorageStats() async {
    try {
      final identifications = await getAllIdentifications();
      final imageDir = await _getImageDirectory();
      
      int totalImages = 0;
      int totalSizeBytes = 0;
      
      if (await imageDir.exists()) {
        final imageFiles = imageDir.listSync().whereType<File>();
        totalImages = imageFiles.length;
        
        for (final file in imageFiles) {
          final stat = await file.stat();
          totalSizeBytes += stat.size;
        }
      }
      
      return StorageStats(
        totalIdentifications: identifications.length,
        totalImages: totalImages,
        totalSizeBytes: totalSizeBytes,
        unsyncedCount: identifications.where((id) => id.syncStatus.maybeWhen(
          notSynced: () => true,
          orElse: () => false,
        )).length,
        failedSyncCount: identifications.where((id) => id.syncStatus.maybeWhen(
          failed: (_) => true,
          orElse: () => false,
        )).length,
      );
    } catch (e) {
      throw LocalStorageException('Failed to get storage stats: $e');
    }
  }

  /// Store an image file in local storage
  /// Returns the path to the stored image
  Future<String> _storeImage(File imageFile) async {
    try {
      final imageDir = await _getImageDirectory();
      final fileName = '${_uuid.v4()}.jpg';
      final localFile = File('${imageDir.path}/$fileName');
      
      await imageFile.copy(localFile.path);
      return localFile.path;
    } catch (e) {
      throw LocalStorageException('Failed to store image: $e');
    }
  }

  /// Delete an image file from local storage
  Future<void> _deleteImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Log error but don't throw - image deletion is not critical
    }
  }

  /// Get the directory for storing images
  Future<Directory> _getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_imagesDirectoryName');
  }

  /// Ensure the image directory exists
  Future<void> _ensureImageDirectoryExists() async {
    final imageDir = await _getImageDirectory();
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
  }

  /// Clean up orphaned images that don't have corresponding identifications
  Future<void> _cleanupOrphanedImages() async {
    try {
      final identifications = await getAllIdentifications();
      final imageDir = await _getImageDirectory();
      
      if (!await imageDir.exists()) return;
      
      final imageFiles = imageDir.listSync().whereType<File>();
      final usedImagePaths = identifications.map((id) => id.localImagePath).toSet();
      
      for (final imageFile in imageFiles) {
        if (!usedImagePaths.contains(imageFile.path)) {
          await imageFile.delete();
        }
      }
    } catch (e) {
      // Log error but don't throw - cleanup is not critical
    }
  }

  /// Save identifications list to storage
  Future<void> _saveIdentifications(List<LocalPlantIdentification> identifications) async {
    final jsonString = json.encode(identifications.map((id) => id.toJson()).toList());
    await _storageService.setString(_identificationsKey, jsonString);
  }

  /// Update or add identification in list
  List<LocalPlantIdentification> _updateIdentificationInList(
    List<LocalPlantIdentification> identifications,
    LocalPlantIdentification identification,
  ) {
    final index = identifications.indexWhere((id) => id.localId == identification.localId);
    
    if (index >= 0) {
      identifications[index] = identification;
    } else {
      identifications.add(identification);
    }
    
    return identifications;
  }
}

/// Storage statistics data class
class StorageStats {
  final int totalIdentifications;
  final int totalImages;
  final int totalSizeBytes;
  final int unsyncedCount;
  final int failedSyncCount;
  
  const StorageStats({
    required this.totalIdentifications,
    required this.totalImages,
    required this.totalSizeBytes,
    required this.unsyncedCount,
    required this.failedSyncCount,
  });
  
  /// Get human-readable size string
  String get formattedSize {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Exception thrown by local storage operations
class LocalStorageException implements Exception {
  final String message;
  
  const LocalStorageException(this.message);
  
  @override
  String toString() => 'LocalStorageException: $message';
}