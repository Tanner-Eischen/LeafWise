/// Telemetry state management models for comprehensive data tracking.
/// 
/// This file contains the TelemetryState freezed model for managing telemetry data,
/// sync status, loading states, conflicts, and computed properties for filtering
/// and aggregation following existing state patterns in the codebase.
library telemetry_state;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/telemetry_data_models.dart' show TelemetryData, LightReadingData, GrowthPhotoData, TelemetryBatchData, SyncStatus;
import '../data/models/telemetry_sync.dart';

part 'telemetry_state.freezed.dart';
part 'telemetry_state.g.dart';

/// Enumeration for telemetry operation types
enum TelemetryOperationType {
  @JsonValue('light_reading')
  lightReading,
  @JsonValue('growth_photo')
  growthPhoto,
  @JsonValue('batch_sync')
  batchSync,
  @JsonValue('data_fetch')
  dataFetch,
  @JsonValue('conflict_resolution')
  conflictResolution,
}

/// Enumeration for data filter types
enum TelemetryDataFilter {
  @JsonValue('all')
  all,
  @JsonValue('synced')
  synced,
  @JsonValue('pending')
  pending,
  @JsonValue('failed')
  failed,
  @JsonValue('conflicts')
  conflicts,
  @JsonValue('offline_only')
  offlineOnly,
  @JsonValue('today')
  today,
  @JsonValue('this_week')
  thisWeek,
  @JsonValue('this_month')
  thisMonth,
}

/// Comprehensive telemetry state model with data management and sync tracking
@freezed
class TelemetryState with _$TelemetryState {
  const TelemetryState._();

  const factory TelemetryState({
    // Loading states for different operations
    @Default(false) bool isLoadingData,
    @Default(false) bool isLoadingLightReadings,
    @Default(false) bool isLoadingGrowthPhotos,
    @Default(false) bool isLoadingBatchData,
    @Default(false) bool isSyncing,
    @Default(false) bool isResolvingConflicts,
    @Default(false) bool isCreatingLightReading,
    @Default(false) bool isCreatingGrowthPhoto,
    @Default(false) bool isUploadingBatch,

    // Data collections
    @Default(<TelemetryData>[]) List<TelemetryData> telemetryData,
    @Default(<LightReadingData>[]) List<LightReadingData> lightReadings,
    @Default(<GrowthPhotoData>[]) List<GrowthPhotoData> growthPhotos,
    @Default(<TelemetryBatchData>[]) List<TelemetryBatchData> batchData,
    @Default(<TelemetrySyncStatus>[]) List<TelemetrySyncStatus> syncStatuses,

    // Sync and offline state
    TelemetrySyncStatus? currentSyncStatus,
    @Default(false) bool isOfflineMode,
    @Default(0) int pendingSyncCount,
    @Default(0) int failedSyncCount,
    @Default(0) int conflictCount,
    DateTime? lastSyncAttempt,
    DateTime? lastSuccessfulSync,

    // Current operation tracking
    TelemetryOperationType? currentOperation,
    String? currentOperationId,
    double? operationProgress,

    // Filtering and pagination
    @Default(TelemetryDataFilter.all) TelemetryDataFilter activeFilter,
    @Default(1) int currentPage,
    @Default(false) bool hasMoreData,
    @Default(20) int pageSize,

    // Error states
    String? error,
    String? syncError,
    String? createError,
    String? uploadError,
    String? conflictError,
    Map<String, String>? fieldErrors,

    // Session and metadata
    String? currentSessionId,
    Map<String, dynamic>? sessionMetadata,
    DateTime? sessionStartedAt,

    // Timestamps
    DateTime? lastUpdated,
    DateTime? lastDataRefresh,
  }) = _TelemetryState;

  factory TelemetryState.fromJson(Map<String, dynamic> json) =>
      _$TelemetryStateFromJson(json);

  /// Factory constructor for initial idle state
  factory TelemetryState.initial() => const TelemetryState();

  /// Factory constructor for loading state
  factory TelemetryState.loading() => const TelemetryState(
        isLoadingData: true,
      );

  /// Factory constructor for offline mode
  factory TelemetryState.offline() => const TelemetryState(
        isOfflineMode: true,
      );

  /// Factory constructor for sync in progress
  factory TelemetryState.syncing({
    required TelemetrySyncStatus syncStatus,
  }) =>
      TelemetryState(
        isSyncing: true,
        currentSyncStatus: syncStatus,
      );

  /// Factory constructor for error state
  factory TelemetryState.error(String errorMessage) => TelemetryState(
        error: errorMessage,
      );

  // Computed properties for data filtering and aggregation

  /// Get filtered telemetry data based on active filter
  List<TelemetryData> get filteredTelemetryData {
    switch (activeFilter) {
      case TelemetryDataFilter.all:
        return telemetryData;
      case TelemetryDataFilter.synced:
        return telemetryData
            .where((data) =>
                data.syncStatus?.syncStatus == SyncStatus.synced ||
                (!data.offlineCreated && data.serverTimestamp != null))
            .toList();
      case TelemetryDataFilter.pending:
        return telemetryData
            .where((data) =>
                data.syncStatus?.syncStatus == SyncStatus.pending ||
                data.syncStatus?.syncStatus == SyncStatus.inProgress)
            .toList();
      case TelemetryDataFilter.failed:
        return telemetryData
            .where((data) => data.syncStatus?.syncStatus == SyncStatus.failed)
            .toList();
      case TelemetryDataFilter.conflicts:
        return telemetryData
            .where((data) => data.syncStatus?.syncStatus == SyncStatus.conflict)
            .toList();
      case TelemetryDataFilter.offlineOnly:
        return telemetryData.where((data) => data.offlineCreated).toList();
      case TelemetryDataFilter.today:
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return telemetryData
            .where((data) =>
                data.clientTimestamp.isAfter(startOfDay) &&
                data.clientTimestamp.isBefore(endOfDay))
            .toList();
      case TelemetryDataFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return telemetryData
            .where((data) => data.clientTimestamp.isAfter(startOfWeekDay))
            .toList();
      case TelemetryDataFilter.thisMonth:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return telemetryData
            .where((data) => data.clientTimestamp.isAfter(startOfMonth))
            .toList();
    }
  }

  /// Get filtered light readings based on active filter
  List<LightReadingData> get filteredLightReadings {
    switch (activeFilter) {
      case TelemetryDataFilter.all:
        return lightReadings;
      case TelemetryDataFilter.synced:
        return lightReadings
            .where((reading) => reading.syncStatus == SyncStatus.synced)
            .toList();
      case TelemetryDataFilter.pending:
        return lightReadings
            .where((reading) =>
                reading.syncStatus == SyncStatus.pending ||
                reading.syncStatus == SyncStatus.inProgress)
            .toList();
      case TelemetryDataFilter.failed:
        return lightReadings
            .where((reading) => reading.syncStatus == SyncStatus.failed)
            .toList();
      case TelemetryDataFilter.conflicts:
        return lightReadings
            .where((reading) => reading.syncStatus == SyncStatus.conflict)
            .toList();
      case TelemetryDataFilter.offlineOnly:
        return lightReadings.where((reading) => reading.offlineCreated).toList();
      case TelemetryDataFilter.today:
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return lightReadings
            .where((reading) =>
                reading.measuredAt.isAfter(startOfDay) &&
                reading.measuredAt.isBefore(endOfDay))
            .toList();
      case TelemetryDataFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return lightReadings
            .where((reading) => reading.measuredAt.isAfter(startOfWeekDay))
            .toList();
      case TelemetryDataFilter.thisMonth:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return lightReadings
            .where((reading) => reading.measuredAt.isAfter(startOfMonth))
            .toList();
    }
  }

  /// Get filtered growth photos based on active filter
  List<GrowthPhotoData> get filteredGrowthPhotos {
    switch (activeFilter) {
      case TelemetryDataFilter.all:
        return growthPhotos;
      case TelemetryDataFilter.synced:
        return growthPhotos
            .where((photo) => photo.syncStatus == SyncStatus.synced)
            .toList();
      case TelemetryDataFilter.pending:
        return growthPhotos
            .where((photo) =>
                photo.syncStatus == SyncStatus.pending ||
                photo.syncStatus == SyncStatus.inProgress)
            .toList();
      case TelemetryDataFilter.failed:
        return growthPhotos
            .where((photo) => photo.syncStatus == SyncStatus.failed)
            .toList();
      case TelemetryDataFilter.conflicts:
        return growthPhotos
            .where((photo) => photo.syncStatus == SyncStatus.conflict)
            .toList();
      case TelemetryDataFilter.offlineOnly:
        return growthPhotos.where((photo) => photo.offlineCreated).toList();
      case TelemetryDataFilter.today:
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return growthPhotos
            .where((photo) =>
                photo.capturedAt.isAfter(startOfDay) &&
                photo.capturedAt.isBefore(endOfDay))
            .toList();
      case TelemetryDataFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return growthPhotos
            .where((photo) => photo.capturedAt.isAfter(startOfWeekDay))
            .toList();
      case TelemetryDataFilter.thisMonth:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return growthPhotos
            .where((photo) => photo.capturedAt.isAfter(startOfMonth))
            .toList();
    }
  }

  // Aggregation computed properties

  /// Total count of all telemetry items
  int get totalItemCount =>
      telemetryData.length + lightReadings.length + growthPhotos.length;

  /// Count of synced items
  int get syncedItemCount {
    final syncedTelemetry = telemetryData
        .where((data) =>
            data.syncStatus?.syncStatus == SyncStatus.synced ||
            (!data.offlineCreated && data.serverTimestamp != null))
        .length;
    final syncedLightReadings = lightReadings
        .where((reading) => reading.syncStatus == SyncStatus.synced)
        .length;
    final syncedGrowthPhotos = growthPhotos
        .where((photo) => photo.syncStatus == SyncStatus.synced)
        .length;
    return syncedTelemetry + syncedLightReadings + syncedGrowthPhotos;
  }

  /// Count of items pending sync
  int get pendingItemCount {
    final pendingTelemetry = telemetryData
        .where((data) =>
            data.syncStatus?.syncStatus == SyncStatus.pending ||
            data.syncStatus?.syncStatus == SyncStatus.inProgress)
        .length;
    final pendingLightReadings = lightReadings
        .where((reading) =>
            reading.syncStatus == SyncStatus.pending ||
            reading.syncStatus == SyncStatus.inProgress)
        .length;
    final pendingGrowthPhotos = growthPhotos
        .where((photo) =>
            photo.syncStatus == SyncStatus.pending ||
            photo.syncStatus == SyncStatus.inProgress)
        .length;
    return pendingTelemetry + pendingLightReadings + pendingGrowthPhotos;
  }

  /// Count of failed sync items
  int get failedItemCount {
    final failedTelemetry = telemetryData
        .where((data) => data.syncStatus?.syncStatus == SyncStatus.failed)
        .length;
    final failedLightReadings = lightReadings
        .where((reading) => reading.syncStatus == SyncStatus.failed)
        .length;
    final failedGrowthPhotos = growthPhotos
        .where((photo) => photo.syncStatus == SyncStatus.failed)
        .length;
    return failedTelemetry + failedLightReadings + failedGrowthPhotos;
  }

  /// Count of conflict items
  int get conflictItemCount {
    final conflictTelemetry = telemetryData
        .where((data) => data.syncStatus?.syncStatus == SyncStatus.conflict)
        .length;
    final conflictLightReadings = lightReadings
        .where((reading) => reading.syncStatus == SyncStatus.conflict)
        .length;
    final conflictGrowthPhotos = growthPhotos
        .where((photo) => photo.syncStatus == SyncStatus.conflict)
        .length;
    return conflictTelemetry + conflictLightReadings + conflictGrowthPhotos;
  }

  /// Sync progress as a percentage (0.0 to 1.0)
  double get syncProgress {
    if (totalItemCount == 0) return 1.0;
    return syncedItemCount / totalItemCount;
  }

  /// Check if any operation is currently in progress
  bool get isAnyOperationInProgress =>
      isLoadingData ||
      isLoadingLightReadings ||
      isLoadingGrowthPhotos ||
      isLoadingBatchData ||
      isSyncing ||
      isResolvingConflicts ||
      isCreatingLightReading ||
      isCreatingGrowthPhoto ||
      isUploadingBatch;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      syncError != null ||
      createError != null ||
      uploadError != null ||
      conflictError != null ||
      (fieldErrors?.isNotEmpty ?? false);

  /// Check if sync is needed
  bool get needsSync => pendingItemCount > 0 || failedItemCount > 0;

  /// Check if there are conflicts to resolve
  bool get hasConflicts => conflictItemCount > 0;

  /// Get the most recent telemetry data item
  TelemetryData? get mostRecentTelemetryData {
    if (telemetryData.isEmpty) return null;
    return telemetryData.reduce((a, b) =>
        a.clientTimestamp.isAfter(b.clientTimestamp) ? a : b);
  }

  /// Get the most recent light reading
  LightReadingData? get mostRecentLightReading {
    if (lightReadings.isEmpty) return null;
    return lightReadings.reduce((a, b) =>
        a.measuredAt.isAfter(b.measuredAt) ? a : b);
  }

  /// Get the most recent growth photo
  GrowthPhotoData? get mostRecentGrowthPhoto {
    if (growthPhotos.isEmpty) return null;
    return growthPhotos.reduce((a, b) =>
        a.capturedAt.isAfter(b.capturedAt) ? a : b);
  }

  /// Get average lux value from light readings
  double? get averageLuxValue {
    if (lightReadings.isEmpty) return null;
    final totalLux = lightReadings.fold<double>(
        0.0, (sum, reading) => sum + reading.luxValue);
    return totalLux / lightReadings.length;
  }

  /// Get light readings grouped by date
  Map<DateTime, List<LightReadingData>> get lightReadingsByDate {
    final Map<DateTime, List<LightReadingData>> grouped = {};
    for (final reading in lightReadings) {
      final date = DateTime(
        reading.measuredAt.year,
        reading.measuredAt.month,
        reading.measuredAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(reading);
    }
    return grouped;
  }

  /// Get growth photos grouped by date
  Map<DateTime, List<GrowthPhotoData>> get growthPhotosByDate {
    final Map<DateTime, List<GrowthPhotoData>> grouped = {};
    for (final photo in growthPhotos) {
      final date = DateTime(
        photo.capturedAt.year,
        photo.capturedAt.month,
        photo.capturedAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(photo);
    }
    return grouped;
  }
}