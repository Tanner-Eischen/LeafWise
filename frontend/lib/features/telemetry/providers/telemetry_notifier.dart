/// Telemetry Notifier
/// 
/// Business logic layer for telemetry state management and synchronization.
/// Provides comprehensive telemetry operations including data loading, adding telemetry,
/// syncing, conflict resolution, connectivity management, and periodic sync.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/connectivity_service.dart';
import '../domain/repositories/telemetry_repository.dart';
import '../models/telemetry_data_models.dart';
import '../../plant_identification/models/offline_plant_identification_models.dart';
import 'telemetry_state.dart';
import 'telemetry_providers.dart';

/// Provider for the telemetry notifier
final telemetryNotifierProvider = StateNotifierProvider<TelemetryNotifier, TelemetryState>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return TelemetryNotifier(repository, connectivityService);
});

/// Notifier for managing telemetry data operations and synchronization
class TelemetryNotifier extends StateNotifier<TelemetryState> {
  final TelemetryRepository _repository;
  final ConnectivityService _connectivityService;
  
  // Stream subscriptions for cleanup
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  StreamSubscription<List<TelemetryData>>? _telemetryStreamSubscription;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  
  // Timer for periodic sync
  Timer? _periodicSyncTimer;
  
  // Sync configuration
  static const Duration _periodicSyncInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  TelemetryNotifier(this._repository, this._connectivityService) 
      : super(const TelemetryState()) {
    _initialize();
  }

  /// Initialize the notifier with connectivity monitoring and data streams
  Future<void> _initialize() async {
    try {
      // Start connectivity monitoring
      _connectivitySubscription = _connectivityService.connectivityStream.listen(
        _handleConnectivityChange,
        onError: (error) {
          state = state.copyWith(
            error: 'Connectivity monitoring error: $error',
          );
        },
      );
      
      // Subscribe to telemetry data stream
      _telemetryStreamSubscription = _repository.telemetryStream.listen(
        (telemetryData) {
          state = state.copyWith(telemetryData: telemetryData);
        },
        onError: (error) {
          state = state.copyWith(
            error: 'Telemetry stream error: $error',
          );
        },
      );
      
      // Subscribe to sync status stream
      _syncStatusSubscription = _repository.syncStatusStream.listen(
        (syncStatus) {
          state = state.copyWith(
            isSyncing: syncStatus.isSyncing,
            syncError: syncStatus.isError ? syncStatus.message : null,
            lastSuccessfulSync: syncStatus.isSuccess ? DateTime.now() : state.lastSuccessfulSync,
          );
        },
        onError: (error) {
          state = state.copyWith(
            syncError: 'Sync status error: $error',
          );
        },
      );
      
      // Get initial connectivity status
      final connectivityStatus = await _connectivityService.getCurrentConnectivityStatus();
      state = state.copyWith(isOfflineMode: !connectivityStatus.isOnline);
      
      // Start periodic sync if online
      if (connectivityStatus.isOnline) {
        _startPeriodicSync();
      }
      
      // Load initial data
      await loadTelemetryData();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize telemetry notifier: $e',
      );
    }
  }

  /// Load telemetry data from repository
  Future<void> loadTelemetryData({TelemetryDataFilter? filter}) async {
    if (state.isLoadingData) return;
    
    state = state.copyWith(
      isLoadingData: true,
      error: null,
    );
    
    try {
      // Create query params from filter
      final queryParams = TelemetryQueryParams(
        plantId: filter?.plantId,
        startDate: filter?.startDate,
        endDate: filter?.endDate,
        limit: filter?.limit ?? 100,
        offset: filter?.offset ?? 0,
      );
      
      final telemetryData = await _repository.query(queryParams);
      
      // Get sync statistics
      final pendingSync = await _repository.getPendingSync();
      final pendingSyncCount = pendingSync.length;
      
      state = state.copyWith(
        isLoadingData: false,
        telemetryData: telemetryData,
        pendingSyncCount: pendingSyncCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to load telemetry data: $e',
      );
    }
  }

  /// Add new telemetry data
  Future<void> addTelemetryData(TelemetryData telemetryData) async {
    if (state.isLoadingData) return;
    
    state = state.copyWith(
      isLoadingData: true,
      error: null,
    );
    
    try {
      await _repository.addTelemetryData(telemetryData);
      
      // Update local state immediately for better UX
      final updatedTelemetryData = [telemetryData, ...state.telemetryData];
      final updatedPendingSyncCount = state.pendingSyncCount + 1;
      
      state = state.copyWith(
        isLoadingData: false,
        telemetryData: updatedTelemetryData,
        pendingSyncCount: updatedPendingSyncCount,
      );
      
      // Trigger sync if online
      if (!state.isOfflineMode) {
        unawaited(syncPendingData());
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to add telemetry data: $e',
      );
    }
  }

  /// Add light reading
  Future<void> addLightReading(LightReading lightReading) async {
    if (state.isLoadingData) return;
    
    state = state.copyWith(
      isLoadingData: true,
      error: null,
    );
    
    try {
      await _repository.addLightReading(lightReading);
      
      // Update local state immediately
      final updatedLightReadings = [lightReading, ...state.lightReadings];
      final updatedPendingSyncCount = state.pendingSyncCount + 1;
      
      state = state.copyWith(
        isLoadingData: false,
        lightReadings: updatedLightReadings,
        pendingSyncCount: updatedPendingSyncCount,
      );
      
      // Trigger sync if online
      if (!state.isOfflineMode) {
        unawaited(syncPendingData());
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to add light reading: $e',
      );
    }
  }

  /// Add growth photo
  Future<void> addGrowthPhoto(GrowthPhoto growthPhoto) async {
    if (state.isLoadingData) return;
    
    state = state.copyWith(
      isLoadingData: true,
      error: null,
    );
    
    try {
      await _repository.addGrowthPhoto(growthPhoto);
      
      // Update local state immediately
      final updatedGrowthPhotos = [growthPhoto, ...state.growthPhotos];
      final updatedPendingSyncCount = state.pendingSyncCount + 1;
      
      state = state.copyWith(
        isLoadingData: false,
        growthPhotos: updatedGrowthPhotos,
        pendingSyncCount: updatedPendingSyncCount,
      );
      
      // Trigger sync if online
      if (!state.isOfflineMode) {
        unawaited(syncPendingData());
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to add growth photo: $e',
      );
    }
  }

  /// Sync pending data with the server
  Future<bool> syncPendingData() async {
    if (state.isSyncing || state.isOfflineMode) return false;
    
    state = state.copyWith(
      isSyncing: true,
      syncError: null,
    );
    
    try {
      final result = await _repository.sync(const SyncParams(forceSync: false, batchSize: 50));
      
      if (result.isCompleteSuccess) {
        // Update sync counts
        final updatedPendingSyncCount = state.pendingSyncCount - result.syncedCount;
        
        state = state.copyWith(
          isSyncing: false,
          pendingSyncCount: updatedPendingSyncCount.clamp(0, 999999),
          lastSuccessfulSync: DateTime.now(),
        );
        
        // Reload data to get updated sync status
        await loadTelemetryData();
        
        return true;
      } else {
        // Handle partial success or conflicts
        if (result.hasConflicts) {
          state = state.copyWith(
            isSyncing: false,
            syncError: 'Sync completed with conflicts that need resolution',
          );
        } else {
          state = state.copyWith(
            isSyncing: false,
            syncError: 'Sync completed with some failures',
            failedSyncCount: state.failedSyncCount + result.failedCount,
          );
        }
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Sync failed: $e',
      );
      return false;
    }
  }

  /// Resolve data conflicts
  Future<void> resolveConflicts(List<ConflictResolution> resolutions) async {
    if (state.isSyncing) return;
    
    state = state.copyWith(
      isSyncing: true,
      syncError: null,
    );
    
    try {
      await _repository.resolveConflicts(resolutions);
      
      state = state.copyWith(
        isSyncing: false,
      );
      
      // Reload data after conflict resolution
      await loadTelemetryData();
      
      // Attempt sync again
      await syncPendingData();
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Failed to resolve conflicts: $e',
      );
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityStatus connectivityStatus) {
    final wasOffline = state.isOfflineMode;
    final isNowOnline = connectivityStatus.isOnline;
    
    state = state.copyWith(isOfflineMode: !isNowOnline);
    
    // If we just came online, trigger sync and start periodic sync
    if (wasOffline && isNowOnline) {
      _startPeriodicSync();
      unawaited(syncPendingData());
    }
    
    // If we went offline, stop periodic sync
    if (!wasOffline && !isNowOnline) {
      _stopPeriodicSync();
    }
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _stopPeriodicSync(); // Ensure no duplicate timers
    
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (_) {
      if (!state.isOfflineMode && !state.isSyncing && state.pendingSyncCount > 0) {
        unawaited(syncPendingData());
      }
    });
  }

  /// Stop periodic sync timer
  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  /// Clear error messages
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear sync error
  void clearSyncError() {
    state = state.copyWith(syncError: null);
  }

  /// Refresh telemetry data
  Future<void> refresh() async {
    await loadTelemetryData();
    
    if (state.isOnline) {
      await syncPendingData();
    }
  }

  /// Get telemetry statistics
  TelemetryStats getStats() {
    return TelemetryStats(
      totalTelemetryData: state.telemetryData.length,
      totalLightReadings: state.lightReadings.length,
      totalGrowthPhotos: state.growthPhotos.length,
      pendingSyncCount: state.pendingSyncCount,
      failedSyncCount: state.failedSyncCount,
      lastSuccessfulSync: state.lastSuccessfulSync,
      isOnline: state.isOnline,
    );
  }

  @override
  void dispose() {
    // Cancel all subscriptions and timers
    _connectivitySubscription?.cancel();
    _telemetryStreamSubscription?.cancel();
    _syncStatusSubscription?.cancel();
    _stopPeriodicSync();
    super.dispose();
  }
}

/// Statistics for telemetry data
class TelemetryStats {
  final int totalTelemetryData;
  final int totalLightReadings;
  final int totalGrowthPhotos;
  final int pendingSyncCount;
  final int failedSyncCount;
  final DateTime? lastSuccessfulSync;
  final bool isOnline;

  const TelemetryStats({
    required this.totalTelemetryData,
    required this.totalLightReadings,
    required this.totalGrowthPhotos,
    required this.pendingSyncCount,
    required this.failedSyncCount,
    this.lastSuccessfulSync,
    required this.isOnline,
  });

  /// Get sync completion percentage
  double get syncPercentage {
    final total = totalTelemetryData + totalLightReadings + totalGrowthPhotos;
    if (total == 0) return 1.0;
    final synced = total - pendingSyncCount - failedSyncCount;
    return synced / total;
  }

  /// Check if all data is synced
  bool get isFullySynced => pendingSyncCount == 0 && failedSyncCount == 0;

  /// Check if there are sync issues
  bool get hasSyncIssues => failedSyncCount > 0;
}