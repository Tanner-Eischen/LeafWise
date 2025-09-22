/// Growth Tracker Notifier for managing growth tracking with telemetry integration
/// Provides state management for growth photo capture, analysis, and sync operations
library;

// Remove unused imports
// import 'dart:io';
// import '../../../features/plant_identification/models/offline_plant_identification_models.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../modules/growth_tracker/growth_tracker.dart';
import '../domain/repositories/telemetry_repository.dart';
import '../models/telemetry_data_models.dart' hide SyncStatus;
import '../models/telemetry_data_models.dart' as telemetry_models;
import 'telemetry_providers.dart';

/// State for growth tracker operations
@immutable
class GrowthTrackerState {
  /// Recent growth photos
  final List<GrowthPhotoData> recentPhotos;
  
  /// Total number of photos
  final int totalPhotos;
  
  /// Number of pending sync operations
  final int pendingSyncCount;
  
  /// Whether a photo capture is in progress
  final bool isCapturing;
  
  /// Whether data is being synced to the server
  final bool isSyncing;
  
  /// Whether the device is in offline mode
  final bool isOfflineMode;
  
  /// Current error message, if any
  final String errorMessage;
  
  /// Last successful sync timestamp
  final DateTime? lastSuccessfulSync;

  const GrowthTrackerState({
    this.recentPhotos = const [],
    this.totalPhotos = 0,
    this.pendingSyncCount = 0,
    this.isCapturing = false,
    this.isSyncing = false,
    this.isOfflineMode = false,
    this.errorMessage = '',
    this.lastSuccessfulSync,
  });

  /// Create a copy of this state with updated fields
  GrowthTrackerState copyWith({
    List<GrowthPhotoData>? recentPhotos,
    int? totalPhotos,
    int? pendingSyncCount,
    bool? isCapturing,
    bool? isSyncing,
    bool? isOfflineMode,
    String? errorMessage,
    DateTime? lastSuccessfulSync,
  }) {
    return GrowthTrackerState(
      recentPhotos: recentPhotos ?? this.recentPhotos,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isCapturing: isCapturing ?? this.isCapturing,
      isSyncing: isSyncing ?? this.isSyncing,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
    );
  }

  /// Check if there are any errors
  bool get hasError => errorMessage.isNotEmpty;

  /// Check if sync is needed
  bool get needsSync => pendingSyncCount > 0;

  /// Check if operations are in progress
  bool get isBusy => isCapturing || isSyncing;
}

/// Growth Tracker Notifier class for managing growth tracking operations
class GrowthTrackerNotifier extends StateNotifier<GrowthTrackerState> {
  final GrowthTracker _growthTracker;
  final TelemetryRepository _telemetryRepository;
  final ConnectivityService _connectivityService;
  // Remove unused field
  // final String _userId;

  GrowthTrackerNotifier({
    required GrowthTracker growthTracker,
    required TelemetryRepository telemetryRepository,
    required ConnectivityService connectivityService,
    // required String userId,
  })  : _growthTracker = growthTracker,
        _telemetryRepository = telemetryRepository,
        _connectivityService = connectivityService,
        // _userId = userId,
        super(const GrowthTrackerState()) {
    _initialize();
  }

  /// Initialize the notifier
  void _initialize() {
    _initializeConnectivityListener();
    _loadPendingSyncCount();
  }

  /// Initialize connectivity listener to update offline mode status
  void _initializeConnectivityListener() {
    _connectivityService.connectivityStream.listen((status) {
      final isOffline = status.isOffline;
      if (state.isOfflineMode != isOffline) {
        state = state.copyWith(isOfflineMode: isOffline);
      }
    });
  }

  /// Load pending sync count from repository
  Future<void> _loadPendingSyncCount() async {
    try {
      final pendingData = await _telemetryRepository.getPendingSync();
      state = state.copyWith(pendingSyncCount: pendingData.length);
    } catch (e) {
      debugPrint('Error loading pending sync count: $e');
    }
  }

  /// Capture and process a growth photo
  Future<GrowthPhotoData?> captureGrowthPhoto({
    required String plantId,
    String? notes,
  }) async {
    if (state.isCapturing) {
      return null;
    }

    try {
      state = state.copyWith(
        isCapturing: true,
        errorMessage: '',
      );

      // Use GrowthTracker to capture photo
       final growthRecord = await _growthTracker.captureGrowthPhoto(
         useCamera: true, // Default to camera for now
         notes: notes,
       );

      if (growthRecord == null) {
        state = state.copyWith(
          isCapturing: false,
          errorMessage: 'Failed to capture growth photo',
        );
        return null;
      }

      // Convert to telemetry data
      final growthPhotoData = _convertToGrowthPhotoData(growthRecord, plantId);

      // Store in telemetry repository
       final telemetryData = TelemetryData(
         userId: 'current_user', // TODO: Get from auth service
         plantId: plantId,
         growthPhoto: growthPhotoData,
         sessionId: const Uuid().v4(),
         offlineCreated: state.isOfflineMode,
         clientTimestamp: DateTime.now(),
         createdAt: DateTime.now(),
       );
       await _telemetryRepository.create(telemetryData);

      // Update state
      state = state.copyWith(
        isCapturing: false,
        recentPhotos: [growthPhotoData, ...state.recentPhotos.take(9)],
        totalPhotos: state.totalPhotos + 1,
        pendingSyncCount: state.pendingSyncCount + 1,
      );

      return growthPhotoData;
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        errorMessage: 'Error capturing photo: $e',
      );
      debugPrint('Error capturing growth photo: $e');
      return null;
    }
  }

  GrowthPhotoData _convertToGrowthPhotoData(GrowthRecord record, String plantId) {
    return GrowthPhotoData(
      id: const Uuid().v4(),
      plantId: plantId,
      filePath: record.photoPath,
      capturedAt: record.timestamp,
      processedAt: DateTime.now(),
      metrics: record.metrics != null ? telemetry_models.GrowthMetrics(
         leafAreaCm2: record.metrics!.height ?? 0.0, // Using height as leaf area for now
         plantHeightCm: record.metrics!.height ?? 0.0,
         leafCount: record.metrics!.leafCount ?? 0,
         stemWidthMm: record.metrics!.width, // Using width as stem width for now
         healthScore: record.metrics!.healthScore ?? 0.0,
         chlorophyllIndex: record.metrics!.healthScore ?? 0.0, // Using health score as chlorophyll index
         diseaseIndicators: (record.metrics!.customMetrics?['disease_indicators'] as List<dynamic>?)
             ?.map((e) => e.toString()).toList() ?? [],
       ) : null,
      notes: record.notes,
      syncStatus: telemetry_models.SyncStatus.pending,
      offlineCreated: state.isOfflineMode,
    );
  }

  /// Sync pending telemetry data to the server
  Future<void> syncPendingData() async {
    if (state.isSyncing || state.isOfflineMode) {
      return;
    }

    await _syncPendingData();
  }

  /// Internal sync method
  Future<void> _syncPendingData() async {
    try {
      state = state.copyWith(
        isSyncing: true,
        errorMessage: '',
      );

      final result = await _telemetryRepository.sync(
        const SyncParams(forceSync: false, batchSize: 50),
      );

      if (result.isCompleteSuccess) {
        state = state.copyWith(
          isSyncing: false,
          pendingSyncCount: 0,
          lastSuccessfulSync: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          errorMessage: 'Sync failed: ${result.failures.isNotEmpty ? result.failures.first.error : 'Unknown error'}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync error: $e',
      );
      debugPrint('Error syncing data: $e');
    }
  }

  /// Load recent growth photos from repository
  Future<void> loadRecentPhotos() async {
    try {
      const queryParams = TelemetryQueryParams(
         userId: 'current_user', // TODO: Get from auth service
         plantId: null, // Load all plants for now
         limit: 10,
         ascending: false,
       );

      final recentPhotos = await _telemetryRepository.query(queryParams);
      final photos = recentPhotos
           .where((data) => data.growthPhoto != null)
           .map((data) => data.growthPhoto!)
           .toList();
       
       state = state.copyWith(
        recentPhotos: photos,
        totalPhotos: photos.length,
      );
    } catch (e) {
      debugPrint('Error loading recent photos: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load recent photos: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: '');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadRecentPhotos(),
      _loadPendingSyncCount(),
    ]);
  }
}

/// Providers for growth tracker functionality
final growthTrackerProvider = Provider<GrowthTracker>((ref) {
  return GrowthTracker();
});

final growthTrackerNotifierProvider = StateNotifierProvider<GrowthTrackerNotifier, GrowthTrackerState>((ref) {
  return GrowthTrackerNotifier(
    growthTracker: ref.watch(growthTrackerProvider),
    telemetryRepository: ref.watch(telemetryRepositoryProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    // userId: 'current_user', // This should come from auth provider
  );
});

/// Provider for the current user's growth tracker state
final currentGrowthTrackerStateProvider = Provider<GrowthTrackerState>((ref) {
  return ref.watch(growthTrackerNotifierProvider);
});