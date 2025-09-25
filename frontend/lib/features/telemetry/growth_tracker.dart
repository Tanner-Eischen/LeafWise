/// Growth Tracker Telemetry Integration Extension
/// 
/// This extension integrates the existing GrowthTracker functionality with telemetry
/// data management, providing automatic data creation, continuous tracking mode,
/// and device status tracking following existing device integration patterns.
library growth_tracker_telemetry_integration;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Core imports
import '../../modules/growth_tracker/growth_tracker.dart';

// Telemetry imports
import 'models/telemetry_data_models.dart' as telemetry_models;
import 'providers/telemetry_notifier.dart';
import 'providers/growth_tracker_notifier.dart';

/// Extension class that integrates GrowthTracker with telemetry system
/// Provides automatic telemetry data creation and enhanced tracking capabilities
class GrowthTrackerTelemetryIntegration {
  final GrowthTracker _growthTracker;
  final WidgetRef _ref;
  
  /// Timer for continuous tracking mode
  Timer? _continuousTrackingTimer;
  
  /// Current tracking session ID
  String? _currentSessionId;
  
  /// Whether continuous tracking is active
  bool _isContinuousTracking = false;
  
  GrowthTrackerTelemetryIntegration({
    required GrowthTracker growthTracker,
    required WidgetRef ref,
  }) : _growthTracker = growthTracker,
       _ref = ref;

  /// Capture growth photo with automatic telemetry data creation
  /// 
  /// [plantId] The ID of the plant being tracked
  /// [useCamera] Whether to use camera or pick from gallery
  /// [notes] Optional notes about the growth record
  /// [locationName] Optional location where photo was taken
  /// [ambientLightLux] Optional ambient light measurement
  /// 
  /// Returns the created telemetry growth photo data
  Future<telemetry_models.GrowthPhotoData?> captureGrowthPhotoWithTelemetry({
    required String plantId,
    required bool useCamera,
    String? notes,
    String? locationName,
    double? ambientLightLux,
  }) async {
    try {
      // Capture the growth photo using the base tracker
      final growthRecord = await _growthTracker.captureGrowthPhoto(
        useCamera: useCamera,
        notes: notes,
      );
      
      if (growthRecord == null) {
        return null; // User cancelled
      }
      
      // Get file information
      final file = File(growthRecord.photoPath);
      final fileSize = await file.length();
      
      // Create telemetry growth photo data
      final growthPhotoData = telemetry_models.GrowthPhotoData(
        id: const Uuid().v4(),
        userId: 'current_user', // This should come from auth provider
        plantId: plantId,
        filePath: growthRecord.photoPath,
        fileSize: fileSize,
        locationName: locationName,
        ambientLightLux: ambientLightLux,
        notes: notes,
        isProcessed: false,
        capturedAt: growthRecord.timestamp,
        syncStatus: telemetry_models.SyncStatus.pending,
        offlineCreated: true,
        clientTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Add to telemetry system
      final telemetryNotifier = _ref.read(telemetryNotifierProvider.notifier);
      await telemetryNotifier.addGrowthPhoto(growthPhotoData);
      
      return growthPhotoData;
    } catch (e) {
      throw Exception('Failed to capture growth photo with telemetry: $e');
    }
  }

  /// Analyze growth photo and update telemetry data with metrics
  /// 
  /// [growthPhotoData] The growth photo data to analyze
  /// 
  /// Returns updated growth photo data with metrics
  Future<telemetry_models.GrowthPhotoData> analyzeGrowthPhotoWithTelemetry(
    telemetry_models.GrowthPhotoData growthPhotoData,
  ) async {
    try {
      // Create a growth record for analysis
      final growthRecord = GrowthRecord(
        id: growthPhotoData.id ?? const Uuid().v4(),
        timestamp: growthPhotoData.capturedAt,
        photoPath: growthPhotoData.filePath,
        notes: growthPhotoData.notes,
      );
      
      // Analyze using the base tracker
      final analyzedRecord = await _growthTracker.analyzeGrowthRecord(growthRecord);
      
      // Convert metrics to telemetry format if available
      telemetry_models.GrowthMetrics? metricsData;
      if (analyzedRecord.metrics != null) {
        metricsData = telemetry_models.GrowthMetrics(
          heightCm: analyzedRecord.metrics!.height,
          widthCm: analyzedRecord.metrics!.width,
          leafCount: analyzedRecord.metrics!.leafCount,
          healthScore: analyzedRecord.metrics!.healthScore,
          colorAnalysis: analyzedRecord.metrics!.customMetrics?['colorAnalysis'] as String?,
          leafAreaCm2: analyzedRecord.metrics!.customMetrics?['leafAreaCm2'] as double?,
          plantHeightCm: analyzedRecord.metrics!.height,
          stemWidthMm: analyzedRecord.metrics!.customMetrics?['stemWidthMm'] as double?,
          chlorophyllIndex: analyzedRecord.metrics!.customMetrics?['chlorophyllIndex'] as double?,
          diseaseIndicators: analyzedRecord.metrics!.customMetrics?['diseaseIndicators'] as List<String>? ?? [],
        );
      }
      
      // Update growth photo data with metrics
      final updatedData = growthPhotoData.copyWith(
        metrics: metricsData,
        isProcessed: true,
        processedAt: DateTime.now(),
      );
      
      // Update in telemetry system
      final telemetryNotifier = _ref.read(telemetryNotifierProvider.notifier);
      await telemetryNotifier.updateGrowthPhoto(updatedData);
      
      return updatedData;
    } catch (e) {
      // Update with processing error
      final errorData = growthPhotoData.copyWith(
        processingError: e.toString(),
        processedAt: DateTime.now(),
      );
      
      final telemetryNotifier = _ref.read(telemetryNotifierProvider.notifier);
      await telemetryNotifier.updateGrowthPhoto(errorData);
      
      throw Exception('Failed to analyze growth photo: $e');
    }
  }

  /// Start continuous growth tracking mode
  /// 
  /// [plantId] The ID of the plant being tracked
  /// [intervalMinutes] Interval between automatic captures (default: 60 minutes)
  /// [locationName] Optional location name for all captures
  /// 
  /// Returns the session ID for the continuous tracking
  String startContinuousTracking({
    required String plantId,
    int intervalMinutes = 60,
    String? locationName,
  }) {
    if (_isContinuousTracking) {
      throw Exception('Continuous tracking is already active');
    }
    
    _currentSessionId = const Uuid().v4();
    _isContinuousTracking = true;
    
    // Start periodic timer
    _continuousTrackingTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (timer) async {
        try {
          await captureGrowthPhotoWithTelemetry(
            plantId: plantId,
            useCamera: true,
            notes: 'Continuous tracking - Session: $_currentSessionId',
            locationName: locationName,
          );
        } catch (e) {
          // Log error but continue tracking
          print('Continuous tracking capture failed: $e');
        }
      },
    );
    
    return _currentSessionId!;
  }

  /// Stop continuous growth tracking mode
  void stopContinuousTracking() {
    _continuousTrackingTimer?.cancel();
    _continuousTrackingTimer = null;
    _isContinuousTracking = false;
    _currentSessionId = null;
  }

  /// Get growth tracking statistics for a plant
  /// 
  /// [plantId] The ID of the plant to get statistics for
  /// [fromDate] Optional start date for statistics
  /// [toDate] Optional end date for statistics
  /// 
  /// Returns growth tracking statistics
  Future<GrowthTrackingStats> getGrowthTrackingStats({
    required String plantId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final telemetryState = _ref.read(telemetryNotifierProvider);
      
      // Filter growth photos for the plant and date range
      var growthPhotos = telemetryState.growthPhotos
          .where((photo) => photo.plantId == plantId);
      
      if (fromDate != null) {
        growthPhotos = growthPhotos.where(
          (photo) => photo.capturedAt.isAfter(fromDate),
        );
      }
      
      if (toDate != null) {
        growthPhotos = growthPhotos.where(
          (photo) => photo.capturedAt.isBefore(toDate),
        );
      }
      
      final photoList = growthPhotos.toList();
      photoList.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      
      // Calculate statistics
      final totalPhotos = photoList.length;
      final processedPhotos = photoList.where((p) => p.isProcessed).length;
      final photosWithMetrics = photoList.where((p) => p.metrics != null).length;
      
      // Calculate growth rate if we have metrics
      double? averageGrowthRate;
      if (photosWithMetrics >= 2) {
        final firstWithMetrics = photoList.firstWhere((p) => p.metrics != null);
        final lastWithMetrics = photoList.lastWhere((p) => p.metrics != null);
        
        if (firstWithMetrics.metrics != null && lastWithMetrics.metrics != null) {
          final heightDiff = (lastWithMetrics.metrics!.heightCm ?? 0.0) - (firstWithMetrics.metrics!.heightCm ?? 0.0);
          final daysDiff = lastWithMetrics.capturedAt.difference(firstWithMetrics.capturedAt).inDays;
          
          if (daysDiff > 0) {
            averageGrowthRate = heightDiff / daysDiff; // cm per day
          }
        }
      }
      
      return GrowthTrackingStats(
        plantId: plantId,
        totalPhotos: totalPhotos,
        processedPhotos: processedPhotos,
        photosWithMetrics: photosWithMetrics,
        averageGrowthRate: averageGrowthRate,
        firstPhotoDate: photoList.isNotEmpty ? photoList.first.capturedAt : null,
        lastPhotoDate: photoList.isNotEmpty ? photoList.last.capturedAt : null,
        isContinuousTracking: _isContinuousTracking && _currentSessionId != null,
        currentSessionId: _currentSessionId,
      );
    } catch (e) {
      throw Exception('Failed to get growth tracking stats: $e');
    }
  }

  /// Check if continuous tracking is active
  bool get isContinuousTracking => _isContinuousTracking;
  
  /// Get current tracking session ID
  String? get currentSessionId => _currentSessionId;
  
  /// Dispose resources
  void dispose() {
    stopContinuousTracking();
  }
}

/// Statistics for growth tracking
class GrowthTrackingStats {
  final String plantId;
  final int totalPhotos;
  final int processedPhotos;
  final int photosWithMetrics;
  final double? averageGrowthRate; // cm per day
  final DateTime? firstPhotoDate;
  final DateTime? lastPhotoDate;
  final bool isContinuousTracking;
  final String? currentSessionId;
  final int currentStreak; // days of continuous tracking
  
  const GrowthTrackingStats({
    required this.plantId,
    required this.totalPhotos,
    required this.processedPhotos,
    required this.photosWithMetrics,
    this.averageGrowthRate,
    this.firstPhotoDate,
    this.lastPhotoDate,
    required this.isContinuousTracking,
    this.currentSessionId,
    this.currentStreak = 0,
  });
}

/// Provider for growth tracker telemetry integration
final growthTrackerTelemetryIntegrationProvider = Provider.family<GrowthTrackerTelemetryIntegration, WidgetRef>((ref, widgetRef) {
  final growthTracker = ref.watch(growthTrackerProvider);
  return GrowthTrackerTelemetryIntegration(
    growthTracker: growthTracker,
    ref: widgetRef,
  );
});