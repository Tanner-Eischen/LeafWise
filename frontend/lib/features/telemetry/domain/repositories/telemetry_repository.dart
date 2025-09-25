/// Abstract repository interface for telemetry data operations
/// 
/// This interface defines the contract for all telemetry data access operations
/// including CRUD operations, sync methods, and stream-based data access.
/// Follows the established domain architecture patterns in the LeafWise application.
library telemetry_repository;

import 'dart:async';

import '../../models/telemetry_data_models.dart';
import '../../data/services/telemetry_api_service.dart';

/// Exception thrown when telemetry repository operations fail
class TelemetryRepositoryException implements Exception {
  final String message;
  final String? code;
  final TelemetryRepositoryErrorType type;
  final Map<String, dynamic>? details;
  final Exception? originalException;

  const TelemetryRepositoryException({
    required this.message,
    this.code,
    required this.type,
    this.details,
    this.originalException,
  });

  @override
  String toString() => 'TelemetryRepositoryException: $message (Type: $type)';

  bool get isNetworkError => type == TelemetryRepositoryErrorType.network;
  bool get isSyncError => type == TelemetryRepositoryErrorType.sync;
  bool get isStorageError => type == TelemetryRepositoryErrorType.storage;
  bool get isValidationError => type == TelemetryRepositoryErrorType.validation;
  bool get isConflictError => type == TelemetryRepositoryErrorType.conflict;
}

/// Types of telemetry repository errors
enum TelemetryRepositoryErrorType {
  network,
  storage,
  sync,
  validation,
  conflict,
  notFound,
  unauthorized,
  unknown,
}

/// Parameters for querying telemetry data
class TelemetryQueryParams {
  final String? userId;
  final String? plantId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<SyncStatus>? syncStatuses;
  final int? limit;
  final int? offset;
  final String? orderBy;
  final bool? ascending;
  final String? itemType;
  final SyncStatus? syncStatus;
  final String? sessionId;

  const TelemetryQueryParams({
    this.userId,
    this.plantId,
    this.startDate,
    this.endDate,
    this.syncStatuses,
    this.limit,
    this.offset,
    this.orderBy,
    this.ascending,
    this.itemType,
    this.syncStatus,
    this.sessionId,
  });
}

/// Parameters for batch operations
class BatchOperationParams {
  final List<TelemetryData> items;
  final bool validateBeforeOperation;
  final bool continueOnError;
  final Map<String, dynamic>? metadata;

  const BatchOperationParams({
    required this.items,
    this.validateBeforeOperation = true,
    this.continueOnError = false,
    this.metadata,
  });
}

/// Result of batch operations
class BatchOperationResult {
  final List<TelemetryData> successful;
  final List<BatchOperationError> failed;
  final Map<String, dynamic> metadata;

  const BatchOperationResult({
    required this.successful,
    required this.failed,
    required this.metadata,
  });

  bool get hasFailures => failed.isNotEmpty;
  bool get isCompleteSuccess => failed.isEmpty;
  int get successCount => successful.length;
  int get failureCount => failed.length;
}

/// Error details for failed batch operations
class BatchOperationError {
  final String? itemId;
  final int index;
  final String error;
  final String? code;
  final TelemetryRepositoryErrorType type;
  final Map<String, dynamic>? details;

  const BatchOperationError({
    this.itemId,
    required this.index,
    required this.error,
    this.code,
    required this.type,
    this.details,
  });
}

/// Sync operation parameters
class SyncParams {
  final bool forceSync;
  final List<String>? specificIds;
  final DateTime? syncSince;
  final int? batchSize;
  final Duration? timeout;

  const SyncParams({
    this.forceSync = false,
    this.specificIds,
    this.syncSince,
    this.batchSize,
    this.timeout,
  });
}

/// Result of sync operations
class SyncResult {
  final int syncedCount;
  final int failedCount;
  final List<String> syncedIds;
  final List<BatchOperationError> failures;
  final DateTime syncTimestamp;
  final Map<String, dynamic> metadata;

  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.syncedIds,
    required this.failures,
    required this.syncTimestamp,
    required this.metadata,
  });

  bool get hasFailures => failedCount > 0;
  bool get isCompleteSuccess => failedCount == 0;
  bool get hasConflicts => failures.any((failure) => failure.type == TelemetryRepositoryErrorType.conflict);
}

/// Abstract repository interface for telemetry data operations
abstract class TelemetryRepository {
  // CRUD Operations
  
  /// Create a new telemetry data entry
  /// Throws [TelemetryRepositoryException] on failure
  Future<TelemetryData> create(TelemetryData data);

  /// Create multiple telemetry data entries in a batch operation
  /// Returns [BatchOperationResult] with success/failure details
  Future<BatchOperationResult> createBatch(BatchOperationParams params);

  /// Retrieve a telemetry data entry by ID
  /// Returns null if not found
  /// Throws [TelemetryRepositoryException] on failure
  Future<TelemetryData?> getById(String id);

  /// Retrieve multiple telemetry data entries by IDs
  /// Returns list of found entries (may be partial if some IDs don't exist)
  /// Throws [TelemetryRepositoryException] on failure
  Future<List<TelemetryData>> getByIds(List<String> ids);

  /// Query telemetry data with filtering and pagination
  /// Throws [TelemetryRepositoryException] on failure
  Future<List<TelemetryData>> query(TelemetryQueryParams params);

  /// Get total count of telemetry data entries matching query
  /// Throws [TelemetryRepositoryException] on failure
  Future<int> count(TelemetryQueryParams params);

  /// Update an existing telemetry data entry
  /// Throws [TelemetryRepositoryException] on failure
  Future<TelemetryData> update(TelemetryData data);

  /// Update an existing growth photo data entry
  /// Throws [TelemetryRepositoryException] on failure
  Future<GrowthPhotoData> updateGrowthPhoto(GrowthPhotoData data);

  /// Update multiple telemetry data entries in a batch operation
  /// Returns [BatchOperationResult] with success/failure details
  Future<BatchOperationResult> updateBatch(BatchOperationParams params);

  /// Delete a telemetry data entry by ID
  /// Returns true if deleted, false if not found
  /// Throws [TelemetryRepositoryException] on failure
  Future<bool> delete(String id);

  /// Delete multiple telemetry data entries by IDs
  /// Returns [BatchOperationResult] with success/failure details
  Future<BatchOperationResult> deleteBatch(List<String> ids);

  // Stream-based Data Access

  /// Stream of telemetry data changes for real-time updates
  /// Emits new data when telemetry entries are created, updated, or deleted
  Stream<List<TelemetryData>> watchTelemetryData(TelemetryQueryParams params);

  /// Stream of telemetry data for a specific plant
  /// Provides real-time updates for plant-specific telemetry
  Stream<List<TelemetryData>> watchPlantTelemetry(String plantId);

  /// Stream of telemetry data for a specific user
  /// Provides real-time updates for user-specific telemetry
  Stream<List<TelemetryData>> watchUserTelemetry(String userId);

  /// Stream of sync status changes
  /// Emits updates when sync operations start, complete, or fail
  Stream<List<TelemetryData>> watchSyncStatus(List<SyncStatus> statuses);

  /// Stream of pending sync data
  /// Emits telemetry data that needs to be synchronized
  Stream<List<TelemetryData>> watchPendingSync();

  /// Stream of sync status changes
  /// Emits sync status updates (pending, inProgress, synced, failed)
  Stream<SyncStatus> get syncStatusStream;

  // Sync Operations

  /// Synchronize telemetry data with remote server
  /// Returns [SyncResult] with operation details
  Future<SyncResult> sync(SyncParams params);

  /// Get telemetry data pending synchronization
  /// Throws [TelemetryRepositoryException] on failure
  Future<List<TelemetryData>> getPendingSync();

  /// Synchronize all pending telemetry data with remote server
  /// Throws [TelemetryRepositoryException] on failure
  Future<void> syncPendingData();

  /// Mark telemetry data as synced
  /// Updates sync status and server metadata
  Future<void> markAsSynced(String id, {String? serverId, DateTime? syncTimestamp});

  /// Mark multiple telemetry data entries as synced
  /// Returns [BatchOperationResult] with success/failure details
  Future<BatchOperationResult> markBatchAsSynced(
    List<String> ids, {
    Map<String, String>? serverIds,
    DateTime? syncTimestamp,
  });

  /// Mark telemetry data as sync failed
  /// Updates sync status with error information
  Future<void> markSyncFailed(String id, String error, {String? code});

  /// Resolve sync conflicts
  /// Handles conflicts between local and remote data
  Future<TelemetryData> resolveSyncConflict(
    String id,
    TelemetryData localData,
    TelemetryData remoteData,
    ConflictResolutionStrategy strategy,
  );

  /// Resolve multiple conflicts using conflict resolution data
  /// Processes a list of conflict resolutions
  Future<void> resolveConflicts(List<ConflictResolution> resolutions);

  // Utility Operations

  /// Get repository statistics
  /// Returns metadata about stored telemetry data
  Future<Map<String, dynamic>> getStatistics();

  /// Clean up old telemetry data
  /// Removes data older than specified date
  Future<int> cleanup(DateTime olderThan);

  /// Validate telemetry data
  /// Checks data integrity and format
  Future<bool> validate(TelemetryData data);

  /// Export telemetry data
  /// Returns data in specified format for backup/export
  Future<Map<String, dynamic>> export(TelemetryQueryParams params);

  /// Import telemetry data
  /// Imports data from external source with validation
  Future<BatchOperationResult> import(
    Map<String, dynamic> data, {
    bool validateBeforeImport = true,
    bool overwriteExisting = false,
  });
}

/// Strategy for resolving sync conflicts
enum ConflictResolutionStrategy {
  useLocal,
  useRemote,
  merge,
  manual,
}