/// Telemetry sync status models for tracking synchronization state and progress.
/// 
/// This file contains the SyncState enum and TelemetrySyncStatus freezed model
/// for managing telemetry data synchronization with the backend, including
/// progress tracking, error handling, and retry mechanisms.
library telemetry_sync;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_sync.freezed.dart';
part 'telemetry_sync.g.dart';

/// Enumeration for sync state tracking with detailed status information
enum SyncState {
  @JsonValue('idle')
  idle,
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('synced')
  synced,
  @JsonValue('failed')
  failed,
  @JsonValue('conflict')
  conflict,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('retry_scheduled')
  retryScheduled,
}

/// Comprehensive telemetry sync status model with session tracking and progress counters
@freezed
class TelemetrySyncStatus with _$TelemetrySyncStatus {
  const factory TelemetrySyncStatus({
    /// Unique identifier for the sync session
    required String sessionId,
    
    /// Current sync state
    @Default(SyncState.idle) SyncState syncState,
    
    /// Progress counters
    @Default(0) int totalItems,
    @Default(0) int syncedItems,
    @Default(0) int failedItems,
    @Default(0) int pendingItems,
    
    /// Retry and error tracking
    @Default(0) int retryCount,
    @Default(3) int maxRetries,
    String? lastError,
    Map<String, dynamic>? errorDetails,
    
    /// Timing information
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastSyncAttempt,
    DateTime? nextRetryAt,
    
    /// Session metadata
    String? userId,
    List<String>? itemIds,
    Map<String, dynamic>? sessionMetadata,
    
    /// Timestamps
    @Default(false) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TelemetrySyncStatus;

  factory TelemetrySyncStatus.fromJson(Map<String, dynamic> json) =>
      _$TelemetrySyncStatusFromJson(json);
}

/// Extension methods for TelemetrySyncStatus with utility functions
extension TelemetrySyncStatusExtensions on TelemetrySyncStatus {
  /// Calculate sync progress as a percentage (0.0 to 1.0)
  double get progress {
    if (totalItems == 0) return 0.0;
    return syncedItems / totalItems;
  }
  
  /// Check if sync is currently in progress
  bool get isInProgress => syncState == SyncState.inProgress;
  
  /// Check if sync has completed successfully
  bool get isCompleted => syncState == SyncState.synced && syncedItems == totalItems;
  
  /// Check if sync has failed
  bool get hasFailed => syncState == SyncState.failed;
  
  /// Check if sync has conflicts
  bool get hasConflicts => syncState == SyncState.conflict;
  
  /// Check if retry is available
  bool get canRetry => retryCount < maxRetries && (hasFailed || hasConflicts);
  
  /// Get remaining retry attempts
  int get remainingRetries => maxRetries - retryCount;
  
  /// Check if sync session is still active
  bool get isSessionActive => isActive && !isCompleted && !hasFailed;
  
  /// Get sync duration if completed
  Duration? get syncDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }
  
  /// Create a new sync status with updated progress
  TelemetrySyncStatus updateProgress({
    int? newSyncedItems,
    int? newFailedItems,
    int? newPendingItems,
  }) {
    final synced = newSyncedItems ?? syncedItems;
    final failed = newFailedItems ?? failedItems;
    final pending = newPendingItems ?? pendingItems;
    
    // Determine new sync state based on progress
    SyncState newState = syncState;
    if (synced + failed == totalItems) {
      newState = failed > 0 ? SyncState.failed : SyncState.synced;
    } else if (synced > 0 || failed > 0) {
      newState = SyncState.inProgress;
    }
    
    return copyWith(
      syncedItems: synced,
      failedItems: failed,
      pendingItems: pending,
      syncState: newState,
      updatedAt: DateTime.now(),
      completedAt: newState == SyncState.synced || newState == SyncState.failed 
          ? DateTime.now() 
          : null,
    );
  }
  
  /// Create a new sync status with error information
  TelemetrySyncStatus withError(String error, {Map<String, dynamic>? details}) {
    return copyWith(
      syncState: SyncState.failed,
      lastError: error,
      errorDetails: details,
      lastSyncAttempt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Create a new sync status for retry attempt
  TelemetrySyncStatus scheduleRetry({Duration? retryDelay}) {
    final delay = retryDelay ?? Duration(minutes: (retryCount + 1) * 2);
    return copyWith(
      syncState: SyncState.retryScheduled,
      retryCount: retryCount + 1,
      nextRetryAt: DateTime.now().add(delay),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Start a new sync session
  TelemetrySyncStatus startSync() {
    return copyWith(
      syncState: SyncState.inProgress,
      isActive: true,
      startedAt: DateTime.now(),
      lastSyncAttempt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Complete the sync session
  TelemetrySyncStatus completeSync() {
    return copyWith(
      syncState: SyncState.synced,
      isActive: false,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Cancel the sync session
  TelemetrySyncStatus cancelSync() {
    return copyWith(
      syncState: SyncState.cancelled,
      isActive: false,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}