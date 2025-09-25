/// Telemetry Providers
/// 
/// This file contains all Riverpod providers for the telemetry feature including
/// service providers, repository providers, state management, and individual providers
/// for specific use cases. Follows established provider patterns with proper dependency injection.
library telemetry_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core service imports
import '../../../core/services/connectivity_service.dart';
import '../../../core/providers/api_provider.dart';
import '../../../core/providers/storage_provider.dart';

// Telemetry service imports
import '../data/services/telemetry_api_service.dart';
import '../data/services/telemetry_local_service.dart';

// Repository imports
import '../domain/repositories/telemetry_repository.dart';
import '../data/repositories/telemetry_repository_impl.dart';

// Model imports
import '../models/telemetry_data_models.dart';
import 'telemetry_state.dart';

// Database provider imports
import '../data/providers/telemetry_database_provider.dart';

// Growth tracker imports
import '../growth_tracker.dart';

// =============================================================================
// SERVICE PROVIDERS
// =============================================================================

/// Provider for the telemetry API service
/// Handles all API communication for telemetry data
final telemetryApiServiceProvider = Provider<TelemetryApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TelemetryApiService(apiService);
});

/// Provider for the telemetry local service
/// Handles local storage and offline operations
final telemetryLocalServiceProvider = Provider<TelemetryLocalService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final database = ref.watch(telemetryDatabaseProvider);
  return TelemetryLocalService(storageService, database);
});

// =============================================================================
// REPOSITORY PROVIDER
// =============================================================================

/// Provider for the telemetry repository
/// Implements offline-first strategy with API fallback and sync capabilities
final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final apiService = ref.watch(telemetryApiServiceProvider);
  final localService = ref.watch(telemetryLocalServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return TelemetryRepositoryImpl(
    apiService: apiService,
    localService: localService,
    connectivityService: connectivityService,
  );
});

// =============================================================================
// STATE MANAGEMENT PROVIDERS
// =============================================================================

/// Notifier for managing telemetry state with comprehensive data operations
class TelemetryNotifier extends StateNotifier<TelemetryState> {
  final TelemetryRepository _repository;

  TelemetryNotifier(this._repository) : super(TelemetryState.initial());

  /// Load telemetry data for a specific plant
  Future<void> loadTelemetryData(String plantId, {TelemetryDataFilter? filter}) async {
    state = state.copyWith(isLoadingData: true, error: null);
    
    try {
      final params = TelemetryQueryParams(plantId: plantId);
      final data = await _repository.query(params);
      
      state = state.copyWith(
        telemetryData: data,
        isLoadingData: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to load telemetry data: $e',
      );
    }
  }

  /// Load light readings for a specific plant
  Future<void> loadLightReadings(String plantId) async {
    state = state.copyWith(isLoadingLightReadings: true, error: null);
    
    try {
      final params = TelemetryQueryParams(plantId: plantId);
      final data = await _repository.query(params);
      
      // Extract light readings from telemetry data
      final lightReadings = data
          .where((item) => item.lightReading != null)
          .map((item) => item.lightReading!)
          .toList();
      
      state = state.copyWith(
        lightReadings: lightReadings,
        isLoadingLightReadings: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLightReadings: false,
        error: 'Failed to load light readings: $e',
      );
    }
  }

  /// Load growth photos for a specific plant
  Future<void> loadGrowthPhotos(String plantId) async {
    state = state.copyWith(isLoadingGrowthPhotos: true, error: null);
    
    try {
      final telemetryData = await _repository.query(TelemetryQueryParams(plantId: plantId));
      // Extract growth photos from telemetry data
      final growthPhotos = telemetryData
          .where((data) => data.growthPhoto != null)
          .map((data) => data.growthPhoto!)
          .toList();
      state = state.copyWith(
        growthPhotos: growthPhotos,
        isLoadingGrowthPhotos: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingGrowthPhotos: false,
        error: e.toString(),
      );
    }
  }

  /// Add new telemetry data
  Future<void> addTelemetryData(TelemetryData data) async {
    state = state.copyWith(isLoadingData: true, error: null);
    
    try {
      final newData = await _repository.create(data);
      final updatedData = [newData, ...state.telemetryData];
      state = state.copyWith(
        telemetryData: updatedData,
        isLoadingData: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: e.toString(),
      );
    }
  }

  /// Add new light reading
  Future<void> addLightReading({
    required String plantId,
    required double luxValue,
    double? ppfdValue,
    LightSource? source,
    String? locationName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isCreatingLightReading: true, error: null);
      
      final lightReading = LightReadingData(
        plantId: plantId,
        luxValue: luxValue,
        ppfdValue: ppfdValue,
        source: source ?? LightSource.manual,
        locationName: locationName,
        measuredAt: DateTime.now(),
        clientTimestamp: DateTime.now(),
      );
      
      final telemetryData = TelemetryData(
        userId: 'current_user', // TODO: Get from auth service
        plantId: plantId,
        lightReading: lightReading,
        offlineCreated: true,
        clientTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      await _repository.create(telemetryData);
      await loadLightReadings(plantId);
      state = state.copyWith(isCreatingLightReading: false);
    } catch (e) {
      state = state.copyWith(
        isCreatingLightReading: false,
        error: 'Failed to add light reading: $e',
      );
    }
  }

  /// Add new growth photo
  Future<void> addGrowthPhoto({
    required String plantId,
    required String filePath,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isCreatingGrowthPhoto: true, error: null);
      
      final growthPhoto = GrowthPhotoData(
        plantId: plantId,
        filePath: filePath,
        notes: notes,
        capturedAt: DateTime.now(),
        clientTimestamp: DateTime.now(),
      );
      
      final telemetryData = TelemetryData(
        userId: 'current_user', // TODO: Get from auth service
        plantId: plantId,
        growthPhoto: growthPhoto,
        offlineCreated: true,
        clientTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      await _repository.create(telemetryData);
      await loadGrowthPhotos(plantId);
      state = state.copyWith(isCreatingGrowthPhoto: false);
    } catch (e) {
      state = state.copyWith(
        isCreatingGrowthPhoto: false,
        error: 'Failed to add growth photo: $e',
      );
    }
  }

  /// Sync telemetry data with remote server
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncTelemetryData() async {
    try {
      state = state.copyWith(
        isSyncing: true,
        error: null,
      );
      
      final result = await _repository.sync(const SyncParams());
      
      state = state.copyWith(
        isSyncing: false,
        lastSuccessfulSync: DateTime.now(),
        failedSyncCount: result.failedCount,
      );
      
      return result.isCompleteSuccess;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Sync failed: $e',
      );
      return false;
    }
  }

  /// Update active filter
  void updateFilter(TelemetryDataFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// Toggle offline mode
  void toggleOfflineMode() {
    state = state.copyWith(isOfflineMode: !state.isOfflineMode);
  }

  /// Delete telemetry data by ID
  Future<void> deleteTelemetryData(String id) async {
    state = state.copyWith(isLoadingData: true, error: null);
    
    try {
      await _repository.delete(id);
      
      // Remove from current state
      final updatedData = state.telemetryData.where((item) => item.id != id).toList();
      state = state.copyWith(
        telemetryData: updatedData,
        isLoadingData: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingData: false,
        error: 'Failed to delete telemetry data: $e',
      );
    }
  }

  /// Sync pending telemetry data with the server
  Future<void> syncPendingData() async {
    state = state.copyWith(isSyncing: true, syncError: null);
    
    try {
      await _repository.syncPendingData();
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Failed to sync data: $e',
      );
    }
  }

  /// Clear errors
  void clearError() {
    state = state.copyWith(error: null, syncError: null);
  }

  /// Reset state to initial
  void reset() {
    state = TelemetryState.initial();
  }
}

/// Provider for the telemetry state notifier
/// Manages comprehensive telemetry state including data, loading states, and operations
final telemetryNotifierProvider = StateNotifierProvider<TelemetryNotifier, TelemetryState>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider);
  return TelemetryNotifier(repository);
});

/// State provider for telemetry operations
/// Tracks loading states, errors, and operation status
final telemetryOperationStateProvider = StateProvider<TelemetryOperationState>((ref) {
  return const TelemetryOperationState.idle();
});

/// Provider for telemetry sync status
/// Provides real-time sync status information
final telemetrySyncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider) as TelemetryRepositoryImpl;
  return repository.syncStatusStream;
});

/// Provider for telemetry data stream
/// Provides real-time telemetry data updates
final telemetryDataStreamProvider = StreamProvider<List<TelemetryData>>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider) as TelemetryRepositoryImpl;
  return repository.telemetryDataStream;
});

// =============================================================================
// INDIVIDUAL PROVIDERS FOR SPECIFIC USE CASES
// =============================================================================

/// Provider for telemetry data by plant ID
/// Returns telemetry data for a specific plant
final telemetryDataByPlantProvider = FutureProvider.family<List<TelemetryData>, String>((
  ref,
  plantId,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  final params = TelemetryQueryParams(
    plantId: plantId,
    limit: 100,
    orderBy: 'timestamp',
    ascending: false,
  );
  return await repository.query(params);
});

/// Provider for telemetry data by user ID
/// Returns all telemetry data for a specific user
final telemetryDataByUserProvider = FutureProvider.family<List<TelemetryData>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  final params = TelemetryQueryParams(
    userId: userId,
    limit: 500,
    orderBy: 'timestamp',
    ascending: false,
  );
  return await repository.query(params);
});

/// Provider for telemetry data count
/// Returns the total count of telemetry data matching the query
final telemetryDataCountProvider = FutureProvider.family<int, TelemetryQueryParams>((
  ref,
  params,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  return await repository.count(params);
});

/// Provider for telemetry statistics
/// Returns statistical information about telemetry data
final telemetryStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  return await repository.getStatistics();
});

/// Provider for pending sync count
/// Returns the number of items pending synchronization
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  const params = TelemetryQueryParams(
    syncStatuses: [SyncStatus.pending, SyncStatus.failed],
  );
  return await repository.count(params);
});

/// Provider for recent telemetry data
/// Returns the most recent telemetry data entries
final recentTelemetryDataProvider = FutureProvider.family<List<TelemetryData>, int>((
  ref,
  limit,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  final params = TelemetryQueryParams(
    limit: limit,
    orderBy: 'timestamp',
    ascending: false,
  );
  return await repository.query(params);
});

/// Provider for telemetry data by date range
/// Returns telemetry data within a specific date range
final telemetryDataByDateRangeProvider = FutureProvider.family<List<TelemetryData>, DateRangeParams>((
  ref,
  dateRange,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  final params = TelemetryQueryParams(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    orderBy: 'timestamp',
    ascending: false,
  );
  return await repository.query(params);
});

/// Provider for telemetry data by sync status
/// Returns telemetry data filtered by sync status
final telemetryDataBySyncStatusProvider = FutureProvider.family<List<TelemetryData>, List<SyncStatus>>((
  ref,
  syncStatuses,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  final params = TelemetryQueryParams(
    syncStatuses: syncStatuses,
    orderBy: 'timestamp',
    ascending: false,
  );
  return await repository.query(params);
});

// =============================================================================
// COMPUTED PROVIDERS
// =============================================================================

/// Provider for telemetry summary data
/// Provides computed summary information from telemetry data
final telemetrySummaryProvider = Provider<Future<TelemetrySummary>>((ref) async {
  final syncStatus = ref.watch(telemetrySyncStatusProvider);
  final operationState = ref.watch(telemetryOperationStateProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final isOnline = await connectivityService.isOnline();
  
  return TelemetrySummary(
    syncStatus: syncStatus.when(
      data: (status) => status,
      loading: () => SyncStatus.pending,
      error: (_, __) => SyncStatus.failed,
    ),
    operationState: operationState,
    isOnline: isOnline,
  );
});

// =============================================================================
// HELPER CLASSES
// =============================================================================

/// State class for telemetry operations
class TelemetryOperationState {
  final bool isLoading;
  final String? error;
  final String? currentOperation;

  const TelemetryOperationState({
    required this.isLoading,
    this.error,
    this.currentOperation,
  });

  const TelemetryOperationState.idle()
      : isLoading = false,
        error = null,
        currentOperation = null;

  const TelemetryOperationState.loading(String operation)
      : isLoading = true,
        error = null,
        currentOperation = operation;

  const TelemetryOperationState.error(String errorMessage)
      : isLoading = false,
        error = errorMessage,
        currentOperation = null;

  TelemetryOperationState copyWith({
    bool? isLoading,
    String? error,
    String? currentOperation,
  }) {
    return TelemetryOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentOperation: currentOperation ?? this.currentOperation,
    );
  }
}

/// Parameters for telemetry statistics queries
class TelemetryStatsParams {
  final String? userId;
  final String? plantId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? metrics;

  const TelemetryStatsParams({
    this.userId,
    this.plantId,
    this.startDate,
    this.endDate,
    this.metrics,
  });
}

/// Parameters for date range queries
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

/// Provider for growth tracking statistics
/// Returns growth tracking statistics for a specific plant
final growthTrackingStatsProvider = FutureProvider.family<GrowthTrackingStats, String>((
  ref,
  plantId,
) async {
  final repository = ref.watch(telemetryRepositoryProvider);
  
  // Query growth photos for the plant
  final params = TelemetryQueryParams(
    plantId: plantId,
    limit: 1000,
    orderBy: 'timestamp',
    ascending: true,
  );
  
  final telemetryData = await repository.query(params);
  final growthPhotos = telemetryData.whereType<GrowthPhotoData>().toList();
  
  // Calculate statistics
  final totalPhotos = growthPhotos.length;
  final processedPhotos = growthPhotos.where((p) => p.isProcessed).length;
  final photosWithMetrics = growthPhotos.where((p) => p.metrics != null).length;
  
  // Calculate average growth rate if we have metrics
  double? averageGrowthRate;
  if (photosWithMetrics >= 2) {
    final photosWithHeight = growthPhotos
        .where((p) => p.metrics?.heightCm != null)
        .toList();
    
    if (photosWithHeight.length >= 2) {
      final firstPhoto = photosWithHeight.first;
      final lastPhoto = photosWithHeight.last;
      final heightDiff = (lastPhoto.metrics!.heightCm! - firstPhoto.metrics!.heightCm!);
      final daysDiff = lastPhoto.capturedAt.difference(firstPhoto.capturedAt).inDays;
      
      if (daysDiff > 0) {
        averageGrowthRate = heightDiff / daysDiff;
      }
    }
  }
  
  return GrowthTrackingStats(
    plantId: plantId,
    totalPhotos: totalPhotos,
    processedPhotos: processedPhotos,
    photosWithMetrics: photosWithMetrics,
    averageGrowthRate: averageGrowthRate,
    firstPhotoDate: growthPhotos.isNotEmpty ? growthPhotos.first.capturedAt : null,
    lastPhotoDate: growthPhotos.isNotEmpty ? growthPhotos.last.capturedAt : null,
    isContinuousTracking: false, // This would need to be tracked separately
    currentSessionId: null,
    currentStreak: 0, // Calculate based on consecutive days with photos
  );
});

/// Summary class for telemetry data
class TelemetrySummary {
  final SyncStatus syncStatus;
  final TelemetryOperationState operationState;
  final bool isOnline;

  const TelemetrySummary({
    required this.syncStatus,
    required this.operationState,
    required this.isOnline,
  });
}