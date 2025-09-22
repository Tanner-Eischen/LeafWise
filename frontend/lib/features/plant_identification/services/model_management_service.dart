/// Model management service for on-device AI models
/// Handles downloading, updating, and lifecycle management of ML models
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/api_service.dart';
import '../models/offline_plant_identification_models.dart';

/// Provider for the model management service
final modelManagementServiceProvider = Provider<ModelManagementService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return ModelManagementService(storageService, apiService);
});

/// Service for managing on-device AI models
class ModelManagementService {
  final StorageService _storageService;
  final ApiService _apiService;
  
  static const String _modelsDirectoryName = 'ai_models';
  static const String _currentModelKey = 'current_model_info';
  static const String _availableModelsKey = 'available_models';
  static const String _modelMetadataKey = 'model_metadata';
  
  ModelManagementService(this._storageService, this._apiService);

  /// Initialize the model management service
  /// Creates necessary directories and loads current model info
  Future<void> initialize() async {
    await _ensureModelsDirectoryExists();
    await _loadCurrentModelInfo();
  }

  /// Get information about the currently active model
  /// Returns null if no model is currently loaded
  Future<ModelInfo?> getCurrentModel() async {
    try {
      final modelJson = await _storageService.getString(_currentModelKey);
      if (modelJson == null || modelJson.isEmpty) {
        return null;
      }
      
      return ModelInfo.fromJson(json.decode(modelJson));
    } catch (e) {
      throw ModelManagementException('Failed to get current model: $e');
    }
  }

  /// Set the currently active model
  /// Updates the current model reference and metadata
  Future<void> setCurrentModel(ModelInfo modelInfo) async {
    try {
      final modelJson = json.encode(modelInfo.toJson());
      await _storageService.setString(_currentModelKey, modelJson);
    } catch (e) {
      throw ModelManagementException('Failed to set current model: $e');
    }
  }

  /// Get list of available models from the server
  /// Returns models that can be downloaded and installed
  Future<List<AvailableModel>> getAvailableModels() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/models/available');
      final List<dynamic> modelsJson = response['models'] ?? [];
      
      return modelsJson
          .map((json) => AvailableModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ModelManagementException('Failed to get available models: $e');
    }
  }

  /// Get list of locally installed models
  /// Returns models that are currently stored on the device
  Future<List<ModelInfo>> getInstalledModels() async {
    try {
      final modelsDir = await _getModelsDirectory();
      if (!await modelsDir.exists()) {
        return [];
      }
      
      final List<ModelInfo> installedModels = [];
      
      await for (final entity in modelsDir.list()) {
        if (entity is Directory) {
          final modelInfo = await _loadModelInfo(entity.path);
          if (modelInfo != null) {
            installedModels.add(modelInfo);
          }
        }
      }
      
      return installedModels;
    } catch (e) {
      throw ModelManagementException('Failed to get installed models: $e');
    }
  }

  /// Download and install a model
  /// Downloads the model files and sets up the local installation
  Future<ModelInfo> downloadModel(
    AvailableModel availableModel, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final modelsDir = await _getModelsDirectory();
      final modelDir = Directory('${modelsDir.path}/${availableModel.modelId}');
      
      // Create model directory
      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }
      await modelDir.create(recursive: true);
      
      // Download model file
      final modelFile = File('${modelDir.path}/model.tflite');
      await _downloadFile(
        availableModel.downloadUrl,
        modelFile.path,
        onProgress: onProgress,
      );
      
      // Verify model integrity
      await _verifyModelIntegrity(modelFile, availableModel.checksum);
      
      // Download labels file if available
      if (availableModel.labelsUrl != null) {
        final labelsFile = File('${modelDir.path}/labels.txt');
        await _downloadFile(availableModel.labelsUrl!, labelsFile.path);
      }
      
      // Create model info
      final modelInfo = ModelInfo(
        modelId: availableModel.modelId,
        version: availableModel.version,
        downloadedAt: DateTime.now(),
        sizeInBytes: await modelFile.length(),
        capabilities: availableModel.capabilities,
        metadata: {
          'name': availableModel.name,
          'description': availableModel.description,
          'accuracy': availableModel.accuracy,
          'modelPath': modelFile.path,
          'labelsPath': availableModel.labelsUrl != null ? '${modelDir.path}/labels.txt' : null,
        },
      );
      
      // Save model info
      await _saveModelInfo(modelDir.path, modelInfo);
      
      return modelInfo;
    } catch (e) {
      throw ModelManagementException('Failed to download model: $e');
    }
  }

  /// Update a model to the latest version
  /// Checks for updates and downloads if a newer version is available
  Future<ModelInfo?> updateModel(String modelId) async {
    try {
      final availableModels = await getAvailableModels();
      final availableModel = availableModels
          .where((model) => model.modelId == modelId)
          .firstOrNull;
      
      if (availableModel == null) {
        throw ModelManagementException('Model not found: $modelId');
      }
      
      final installedModels = await getInstalledModels();
      final installedModel = installedModels
          .where((model) => model.modelId == modelId)
          .firstOrNull;
      
      // Check if update is needed
      if (installedModel != null && 
          _compareVersions(availableModel.version, installedModel.version) <= 0) {
        return null; // No update needed
      }
      
      // Download updated model
      return await downloadModel(availableModel);
    } catch (e) {
      throw ModelManagementException('Failed to update model: $e');
    }
  }

  /// Delete a model from local storage
  /// Removes all model files and metadata
  Future<void> deleteModel(String modelId) async {
    try {
      final modelsDir = await _getModelsDirectory();
      final modelDir = Directory('${modelsDir.path}/$modelId');
      
      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }
      
      // Clear current model if it was the deleted one
      final currentModel = await getCurrentModel();
      if (currentModel?.modelId == modelId) {
        await _storageService.remove(_currentModelKey);
      }
    } catch (e) {
      throw ModelManagementException('Failed to delete model: $e');
    }
  }

  /// Check for model updates
  /// Returns list of models that have updates available
  Future<List<ModelUpdateInfo>> checkForUpdates() async {
    try {
      final availableModels = await getAvailableModels();
      final installedModels = await getInstalledModels();
      
      final List<ModelUpdateInfo> updates = [];
      
      for (final installed in installedModels) {
        final available = availableModels
            .where((model) => model.modelId == installed.modelId)
            .firstOrNull;
        
        if (available != null && 
            _compareVersions(available.version, installed.version) > 0) {
          updates.add(ModelUpdateInfo(
            modelId: installed.modelId,
            currentVersion: installed.version,
            availableVersion: available.version,
            updateSize: available.sizeInBytes,
          ));
        }
      }
      
      return updates;
    } catch (e) {
      throw ModelManagementException('Failed to check for updates: $e');
    }
  }

  /// Get model storage usage statistics
  /// Returns information about disk usage by models
  Future<ModelStorageStats> getStorageStats() async {
    try {
      final modelsDir = await _getModelsDirectory();
      if (!await modelsDir.exists()) {
        return const ModelStorageStats(
          totalModels: 0,
          totalSizeBytes: 0,
          modelSizes: {},
        );
      }
      
      int totalSize = 0;
      int modelCount = 0;
      final Map<String, int> modelSizes = {};
      
      await for (final entity in modelsDir.list()) {
        if (entity is Directory) {
          final modelInfo = await _loadModelInfo(entity.path);
          if (modelInfo != null) {
            modelCount++;
            final size = await _calculateDirectorySize(entity);
            totalSize += size;
            modelSizes[modelInfo.modelId] = size;
          }
        }
      }
      
      return ModelStorageStats(
        totalModels: modelCount,
        totalSizeBytes: totalSize,
        modelSizes: modelSizes,
      );
    } catch (e) {
      throw ModelManagementException('Failed to get storage stats: $e');
    }
  }

  /// Download a file with progress tracking
  Future<void> _downloadFile(
    String url,
    String savePath, {
    Function(double progress)? onProgress,
  }) async {
    final dio = Dio();
    
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );
  }

  /// Verify model file integrity using checksum
  Future<void> _verifyModelIntegrity(File modelFile, String expectedChecksum) async {
    final bytes = await modelFile.readAsBytes();
    final digest = sha256.convert(bytes);
    final actualChecksum = digest.toString();
    
    if (actualChecksum != expectedChecksum) {
      throw ModelManagementException(
        'Model integrity check failed. Expected: $expectedChecksum, Got: $actualChecksum'
      );
    }
  }

  /// Get the models directory
  Future<Directory> _getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_modelsDirectoryName');
  }

  /// Ensure the models directory exists
  Future<void> _ensureModelsDirectoryExists() async {
    final modelsDir = await _getModelsDirectory();
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
  }

  /// Load current model info from storage
  Future<void> _loadCurrentModelInfo() async {
    // This method can be used for initialization logic
    // Currently just ensures the current model is valid
    final currentModel = await getCurrentModel();
    if (currentModel != null) {
      final modelPath = currentModel.metadata['modelPath'] as String?;
      if (modelPath != null && !await File(modelPath).exists()) {
        // Model file is missing, clear current model
        await _storageService.remove(_currentModelKey);
      }
    }
  }

  /// Save model info to local storage
  Future<void> _saveModelInfo(String modelDirPath, ModelInfo modelInfo) async {
    final infoFile = File('$modelDirPath/model_info.json');
    final jsonString = json.encode(modelInfo.toJson());
    await infoFile.writeAsString(jsonString);
  }

  /// Load model info from local storage
  Future<ModelInfo?> _loadModelInfo(String modelDirPath) async {
    try {
      final infoFile = File('$modelDirPath/model_info.json');
      if (!await infoFile.exists()) {
        return null;
      }
      
      final jsonString = await infoFile.readAsString();
      return ModelInfo.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Calculate total size of a directory
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    
    return totalSize;
  }

  /// Compare version strings
  /// Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    
    return 0;
  }
}

/// Information about an available model for download
class AvailableModel {
  final String modelId;
  final String name;
  final String description;
  final String version;
  final String downloadUrl;
  final String? labelsUrl;
  final String checksum;
  final int sizeInBytes;
  final double accuracy;
  final List<String> capabilities;
  
  const AvailableModel({
    required this.modelId,
    required this.name,
    required this.description,
    required this.version,
    required this.downloadUrl,
    this.labelsUrl,
    required this.checksum,
    required this.sizeInBytes,
    required this.accuracy,
    required this.capabilities,
  });
  
  factory AvailableModel.fromJson(Map<String, dynamic> json) {
    return AvailableModel(
      modelId: json['modelId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      labelsUrl: json['labelsUrl'] as String?,
      checksum: json['checksum'] as String,
      sizeInBytes: json['sizeInBytes'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      capabilities: List<String>.from(json['capabilities'] as List),
    );
  }
}

/// Information about a model update
class ModelUpdateInfo {
  final String modelId;
  final String currentVersion;
  final String availableVersion;
  final int updateSize;
  
  const ModelUpdateInfo({
    required this.modelId,
    required this.currentVersion,
    required this.availableVersion,
    required this.updateSize,
  });
}

/// Model storage statistics
class ModelStorageStats {
  final int totalModels;
  final int totalSizeBytes;
  final Map<String, int> modelSizes;
  
  const ModelStorageStats({
    required this.totalModels,
    required this.totalSizeBytes,
    required this.modelSizes,
  });
  
  /// Get human-readable size string
  String get formattedSize {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Exception thrown by model management operations
class ModelManagementException implements Exception {
  final String message;
  
  const ModelManagementException(this.message);
  
  @override
  String toString() => 'ModelManagementException: $message';
}