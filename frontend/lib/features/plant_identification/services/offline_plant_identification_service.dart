/// Offline plant identification service using on-device AI models
/// Handles local plant identification without requiring internet connectivity
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/offline_plant_identification_models.dart';
import 'model_management_service.dart';
import 'local_storage_service.dart';

/// Provider for the offline plant identification service
final offlinePlantIdentificationServiceProvider = Provider<OfflinePlantIdentificationService>((ref) {
  final modelManagementService = ref.watch(modelManagementServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return OfflinePlantIdentificationService(modelManagementService, localStorageService);
});

/// Service for performing plant identification using on-device AI models
class OfflinePlantIdentificationService {
  final ModelManagementService _modelManagementService;
  final LocalStorageService _localStorageService;
  final Uuid _uuid = const Uuid();
  
  Interpreter? _interpreter;
  List<String>? _labels;
  ModelInfo? _currentModel;
  
  static const int _inputSize = 224; // Standard input size for most plant models
  static const int _numChannels = 3; // RGB channels
  static const double _confidenceThreshold = 0.1; // Minimum confidence to consider
  
  OfflinePlantIdentificationService(
    this._modelManagementService,
    this._localStorageService,
  );

  /// Initialize the offline identification service
  /// Loads the current model and prepares for inference
  Future<void> initialize() async {
    try {
      await _loadCurrentModel();
    } catch (e) {
      throw OfflineIdentificationException('Failed to initialize service: $e');
    }
  }

  /// Check if the service is ready for identification
  /// Returns true if a model is loaded and ready
  bool get isReady => _interpreter != null && _labels != null;

  /// Get information about the currently loaded model
  /// Returns null if no model is loaded
  ModelInfo? get currentModel => _currentModel;

  /// Identify a plant from an image file
  /// Processes the image using the loaded model and returns identification results
  Future<LocalPlantIdentification> identifyPlant(
    File imageFile, {
    int maxResults = 5,
    double minConfidence = 0.1,
  }) async {
    if (!isReady) {
      throw const OfflineIdentificationException('Service not ready. No model loaded.');
    }
    
    try {
      // Preprocess the image
      final inputData = await _preprocessImage(imageFile);
      
      // Run inference
      final predictions = await _runInference(inputData);
      
      // Process results
      final results = _processResults(predictions, maxResults, minConfidence);
      
      if (results.isEmpty) {
        throw const OfflineIdentificationException('No confident predictions found');
      }
      
      // Get the top result
      final topResult = results.first;
      
      // Create identification record
      final identification = LocalPlantIdentification(
        localId: _uuid.v4(),
        scientificName: topResult.scientificName,
        commonName: topResult.commonName,
        confidence: topResult.confidence,
        localImagePath: imageFile.path,
        identifiedAt: DateTime.now(),
        syncStatus: const SyncStatus.notSynced(),
        localModelData: {
          'modelId': _currentModel!.modelId,
          'modelVersion': _currentModel!.version,
          'allPredictions': results.map((r) => r.toJson()).toList(),
          'processingTime': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      // Store the identification locally
      await _localStorageService.storeIdentification(identification);
      
      return identification;
    } catch (e) {
      throw OfflineIdentificationException('Failed to identify plant: $e');
    }
  }

  /// Identify multiple plants from a batch of images
  /// Processes multiple images efficiently and returns all results
  Future<List<LocalPlantIdentification>> identifyPlantBatch(
    List<File> imageFiles, {
    int maxResults = 5,
    double minConfidence = 0.1,
    Function(int processed, int total)? onProgress,
  }) async {
    if (!isReady) {
      throw const OfflineIdentificationException('Service not ready. No model loaded.');
    }
    
    final List<LocalPlantIdentification> identifications = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final identification = await identifyPlant(
          imageFiles[i],
          maxResults: maxResults,
          minConfidence: minConfidence,
        );
        identifications.add(identification);
        
        onProgress?.call(i + 1, imageFiles.length);
      } catch (e) {
        // Continue with other images even if one fails
        onProgress?.call(i + 1, imageFiles.length);
      }
    }
    
    return identifications;
  }

  /// Load a specific model for identification
  /// Switches to the specified model if it's different from the current one
  Future<void> loadModel(String modelId) async {
    try {
      final installedModels = await _modelManagementService.getInstalledModels();
      final modelInfo = installedModels
          .where((model) => model.modelId == modelId)
          .firstOrNull;
      
      if (modelInfo == null) {
        throw OfflineIdentificationException('Model not found: $modelId');
      }
      
      await _loadModelFromInfo(modelInfo);
      await _modelManagementService.setCurrentModel(modelInfo);
    } catch (e) {
      throw OfflineIdentificationException('Failed to load model: $e');
    }
  }

  /// Reload the current model
  /// Useful for refreshing the model after updates
  Future<void> reloadCurrentModel() async {
    try {
      await _loadCurrentModel();
    } catch (e) {
      throw OfflineIdentificationException('Failed to reload model: $e');
    }
  }

  /// Get model performance statistics
  /// Returns information about model accuracy and usage
  Future<ModelPerformanceStats> getModelStats() async {
    if (_currentModel == null) {
      throw const OfflineIdentificationException('No model loaded');
    }
    
    try {
      final identifications = await _localStorageService.getAllIdentifications();
      final modelIdentifications = identifications
          .where((id) => id.localModelData['modelId'] == _currentModel!.modelId)
          .toList();
      
      if (modelIdentifications.isEmpty) {
        return ModelPerformanceStats(
          modelId: _currentModel!.modelId,
          totalIdentifications: 0,
          averageConfidence: 0.0,
          averageProcessingTime: 0.0,
          confidenceDistribution: {},
        );
      }
      
      final totalConfidence = modelIdentifications
          .map((id) => id.confidence)
          .reduce((a, b) => a + b);
      
      final averageConfidence = totalConfidence / modelIdentifications.length;
      
      final processingTimes = modelIdentifications
          .map((id) => id.localModelData['processingTime'] as int? ?? 0)
          .where((time) => time > 0)
          .toList();
      
      final averageProcessingTime = processingTimes.isNotEmpty
          ? processingTimes.reduce((a, b) => a + b) / processingTimes.length
          : 0.0;
      
      // Calculate confidence distribution
      final Map<String, int> confidenceDistribution = {};
      for (final identification in modelIdentifications) {
        final confidenceRange = _getConfidenceRange(identification.confidence);
        confidenceDistribution[confidenceRange] = 
            (confidenceDistribution[confidenceRange] ?? 0) + 1;
      }
      
      return ModelPerformanceStats(
        modelId: _currentModel!.modelId,
        totalIdentifications: modelIdentifications.length,
        averageConfidence: averageConfidence,
        averageProcessingTime: averageProcessingTime,
        confidenceDistribution: confidenceDistribution,
      );
    } catch (e) {
      throw OfflineIdentificationException('Failed to get model stats: $e');
    }
  }

  /// Dispose of resources
  /// Cleans up the interpreter and releases memory
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _currentModel = null;
  }

  /// Load the current model from model management service
  Future<void> _loadCurrentModel() async {
    final modelInfo = await _modelManagementService.getCurrentModel();
    if (modelInfo != null) {
      await _loadModelFromInfo(modelInfo);
    }
  }

  /// Load model from ModelInfo
  Future<void> _loadModelFromInfo(ModelInfo modelInfo) async {
    try {
      // Dispose of current model if loaded
      _interpreter?.close();
      
      // Load model file
      final modelPath = modelInfo.metadata['modelPath'] as String?;
      if (modelPath == null || !await File(modelPath).exists()) {
        throw OfflineIdentificationException('Model file not found: $modelPath');
      }
      
      _interpreter = Interpreter.fromFile(File(modelPath));
      
      // Load labels if available
      final labelsPath = modelInfo.metadata['labelsPath'] as String?;
      if (labelsPath != null && await File(labelsPath).exists()) {
        final labelsContent = await File(labelsPath).readAsString();
        _labels = labelsContent.split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
      } else {
        // Generate default labels if none provided
        _labels = List.generate(1000, (index) => 'Plant_$index');
      }
      
      _currentModel = modelInfo;
      
      // Update last used timestamp
      final updatedModel = modelInfo.copyWith(
        metadata: {
          ...modelInfo.metadata,
          'lastUsedAt': DateTime.now().toIso8601String(),
        },
      );
      await _modelManagementService.setCurrentModel(updatedModel);
    } catch (e) {
      throw OfflineIdentificationException('Failed to load model from info: $e');
    }
  }

  /// Preprocess image for model input
  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    try {
      // Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw const OfflineIdentificationException('Failed to decode image');
      }
      
      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );
      
      // Convert to normalized float array
      final input = List.generate(
        1, // batch size
        (b) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) => List.generate(
              _numChannels,
              (c) {
                final pixel = resizedImage.getPixel(x, y);
                late double value;
                switch (c) {
                  case 0:
                    value = pixel.r.toDouble();
                    break;
                  case 1:
                    value = pixel.g.toDouble();
                    break;
                  case 2:
                    value = pixel.b.toDouble();
                    break;
                }
                // Normalize to [0, 1] or [-1, 1] depending on model requirements
                return (value / 255.0 - 0.5) * 2.0; // [-1, 1] normalization
              },
            ),
          ),
        ),
      );
      
      return input;
    } catch (e) {
      throw OfflineIdentificationException('Failed to preprocess image: $e');
    }
  }

  /// Run inference on preprocessed input
  Future<List<double>> _runInference(List<List<List<List<double>>>> input) async {
    try {
      final output = List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);
      
      _interpreter!.run(input, output);
      
      return output[0];
    } catch (e) {
      throw OfflineIdentificationException('Failed to run inference: $e');
    }
  }

  /// Process model output into identification results
  List<PlantPrediction> _processResults(
    List<double> predictions,
    int maxResults,
    double minConfidence,
  ) {
    final List<PlantPrediction> results = [];
    
    // Create list of predictions with indices
    final indexedPredictions = predictions
        .asMap()
        .entries
        .where((entry) => entry.value >= minConfidence)
        .toList();
    
    // Sort by confidence (descending)
    indexedPredictions.sort((a, b) => b.value.compareTo(a.value));
    
    // Take top results
    final topPredictions = indexedPredictions.take(maxResults);
    
    for (final prediction in topPredictions) {
      final labelIndex = prediction.key;
      final confidence = prediction.value;
      
      if (labelIndex < _labels!.length) {
        final label = _labels![labelIndex];
        final parts = label.split('_'); // Assuming format: "ScientificName_CommonName"
        
        results.add(PlantPrediction(
          scientificName: parts.isNotEmpty ? parts[0] : label,
          commonName: parts.length > 1 ? parts.sublist(1).join(' ') : label,
          confidence: confidence,
          labelIndex: labelIndex,
        ));
      }
    }
    
    return results;
  }

  /// Get confidence range for statistics
  String _getConfidenceRange(double confidence) {
    if (confidence >= 0.9) return '90-100%';
    if (confidence >= 0.8) return '80-89%';
    if (confidence >= 0.7) return '70-79%';
    if (confidence >= 0.6) return '60-69%';
    if (confidence >= 0.5) return '50-59%';
    return '<50%';
  }
}

/// Plant prediction result from model inference
class PlantPrediction {
  final String scientificName;
  final String commonName;
  final double confidence;
  final int labelIndex;
  
  const PlantPrediction({
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    required this.labelIndex,
  });
  
  Map<String, dynamic> toJson() => {
    'scientificName': scientificName,
    'commonName': commonName,
    'confidence': confidence,
    'labelIndex': labelIndex,
  };
}

/// Model performance statistics
class ModelPerformanceStats {
  final String modelId;
  final int totalIdentifications;
  final double averageConfidence;
  final double averageProcessingTime;
  final Map<String, int> confidenceDistribution;
  
  const ModelPerformanceStats({
    required this.modelId,
    required this.totalIdentifications,
    required this.averageConfidence,
    required this.averageProcessingTime,
    required this.confidenceDistribution,
  });
}

/// Exception thrown by offline identification operations
class OfflineIdentificationException implements Exception {
  final String message;
  
  const OfflineIdentificationException(this.message);
  
  @override
  String toString() => 'OfflineIdentificationException: $message';
}

/// Extension for reshaping lists (utility for tensor operations)
extension ListReshape<T> on List<T> {
  List<List<T>> reshape(List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Only 2D reshape supported');
    }
    
    final rows = shape[0];
    final cols = shape[1];
    
    if (length != rows * cols) {
      throw ArgumentError('Cannot reshape list of length $length to $rows x $cols');
    }
    
    return List.generate(
      rows,
      (i) => sublist(i * cols, (i + 1) * cols),
    );
  }
}