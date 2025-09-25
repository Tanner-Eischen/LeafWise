/// Implementation of TelemetryRepository interface
/// Provides offline-first data persistence with sync capabilities
library telemetry_repository_impl;

import 'dart:async';

import '../../domain/repositories/telemetry_repository.dart';
import '../../models/telemetry_data_models.dart';
import '../services/telemetry_local_service.dart';
import '../services/telemetry_api_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// Concrete implementation of TelemetryRepository
/// Implements offline-first strategy with API fallback and offline synchronization
class TelemetryRepositoryImpl implements TelemetryRepository {
  final TelemetryApiService _apiService;
  final TelemetryLocalService _localService;
  final ConnectivityService _connectivityService;
  
  // Stream controllers for reactive data
  final StreamController<List<TelemetryData>> _telemetryStreamController = 
      StreamController<List<TelemetryData>>.broadcast();
  final StreamController<TelemetryData> _telemetryUpdatesController = 
      StreamController<TelemetryData>.broadcast();
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  
  // Cache for telemetry data
  final Map<String, TelemetryData> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache configuration
  static const Duration _cacheTimeout = Duration(minutes: 5);

  TelemetryRepositoryImpl({
    required TelemetryApiService apiService,
    required TelemetryLocalService localService,
    required ConnectivityService connectivityService,
  }) : _apiService = apiService,
       _localService = localService,
       _connectivityService = connectivityService;

  // CRUD Operations

  @override
  Future<bool> delete(String id) async {
    try {
      // Check if item exists before deletion
      final existingItem = await _localService.getTelemetryData(id);
      final existed = existingItem != null;
      
      if (existed) {
        // Delete from local storage first
        await _localService.deleteTelemetryData(id);
        _cache.remove(id);
        _cacheTimestamps.remove(id);
        
        // Try to delete from API if online
        if (await _connectivityService.isOnline()) {
          try {
            await _apiService.deleteTelemetryData(id);
          } catch (e) {
            // API call failed, but local deletion succeeded
            // Deletion will be synced later
          }
        }
      }
      
      return existed;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to delete telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<void> resolveConflicts(List<ConflictResolution> resolutions) async {
    try {
      await _apiService.resolveConflicts(resolutions);
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to resolve conflicts: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  @override
  Future<TelemetryData> create(TelemetryData data) async {
    try {
      // Save to local storage first
      await _localService.saveTelemetryData(data);
      _updateCache(data);
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final syncedData = await _apiService.createTelemetryData(data);
          await _localService.markAsSynced(data.id!, serverId: syncedData.id);
          _updateCache(syncedData);
          _telemetryUpdatesController.add(syncedData);
          return syncedData;
        } catch (e) {
          // API call failed, but data is saved locally
          // Will be synced later when connectivity is restored
        }
      }
      
      _telemetryUpdatesController.add(data);
      return data;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to create telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<BatchOperationResult> createBatch(BatchOperationParams params) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      // Save all to local storage first
      for (int i = 0; i < params.items.length; i++) {
        final data = params.items[i];
        try {
          // Validate before operation if requested
          if (params.validateBeforeOperation) {
            // Add validation logic here if needed
          }
          
          await _localService.saveTelemetryData(data);
          _updateCache(data);
          successful.add(data);
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: data.id,
            index: i,
            error: e.toString(),
            code: 'STORAGE_ERROR',
            type: TelemetryRepositoryErrorType.storage,
          ));
          
          // Stop on first error if continueOnError is false
          if (!params.continueOnError) {
            break;
          }
        }
      }
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final response = await _apiService.createBatch(
            successful,
            continueOnError: params.continueOnError,
          );
          
          // Update successful items with server data
          if (response.successful.isNotEmpty) {
            for (final serverData in response.successful) {
              final localData = successful.firstWhere(
                (item) => item.id == serverData.id,
                orElse: () => serverData,
              );
              await _localService.markAsSynced(localData.id!, serverId: serverData.id);
              _updateCache(serverData);
            }
          }
        } catch (e) {
          // API call failed, but data is saved locally
          // Will be synced later when connectivity is restored
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': params.items.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
          'validate_before_operation': params.validateBeforeOperation,
          'continue_on_error': params.continueOnError,
          ...?params.metadata,
        },
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to create batch: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<TelemetryData?> getById(String id) async {
    try {
      // Check cache first
      if (_isCacheValid(id)) {
        return _cache[id];
      }
      
      // Try API first if online
      if (await _connectivityService.isOnline()) {
        try {
          final data = await _apiService.getTelemetryData(id);
          if (data != null) {
            _updateCache(data);
            return data;
          }
        } catch (e) {
          // API call failed, fall back to local storage
        }
      }
      
      // Fall back to local storage
      final localData = await _localService.getTelemetryData(id);
      if (localData != null) {
        _updateCache(localData);
      }
      return localData;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to get telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<List<TelemetryData>> getByIds(List<String> ids) async {
    try {
      final results = <TelemetryData>[];
      final uncachedIds = <String>[];
      
      // Check cache first
      for (final id in ids) {
        if (_isCacheValid(id)) {
          results.add(_cache[id]!);
        } else {
          uncachedIds.add(id);
        }
      }
      
      if (uncachedIds.isEmpty) {
        return results;
      }
      
      // Try API for uncached items if online
      if (await _connectivityService.isOnline()) {
        try {
          final apiData = await _apiService.getTelemetryDataBatch(uncachedIds);
          for (final data in apiData) {
            _updateCache(data);
            results.add(data);
          }
          return results;
        } catch (e) {
          // API call failed, fall back to local storage
        }
      }
      
      // Fall back to local storage for uncached items
      for (final id in uncachedIds) {
        final localData = await _localService.getTelemetryData(id);
        if (localData != null) {
          _updateCache(localData);
          results.add(localData);
        }
      }
      
      return results;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to get telemetry data batch: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<List<TelemetryData>> query(TelemetryQueryParams params) async {
    try {
      // Try API first if online
      if (await _connectivityService.isOnline()) {
        try {
          final data = await _apiService.queryTelemetryData(
            userId: params.userId,
            plantId: params.plantId,
            startDate: params.startDate,
            endDate: params.endDate,
            syncStatusFilter: params.syncStatuses,
            sortBy: params.orderBy,
            sortOrder: params.ascending == true ? 'asc' : 'desc',
            limit: params.limit,
            offset: params.offset,
          );
          // Update cache with results
          for (final item in data) {
            _updateCache(item);
          }
          _telemetryStreamController.add(data);
          return data;
        } catch (e) {
          // API call failed, fall back to local storage
        }
      }
      
      // Fall back to local storage
      final localData = await _localService.queryTelemetryData(
        itemType: params.itemType,
        startDate: params.startDate,
        endDate: params.endDate,
        isSynced: params.syncStatus == SyncStatus.synced,
        sessionId: params.sessionId,
        limit: params.limit,
        offset: params.offset,
        orderBy: params.orderBy,
        ascending: params.ascending ?? true,
      );
      _telemetryStreamController.add(localData);
      return localData;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to query telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<int> count(TelemetryQueryParams params) async {
    try {
      // Try API first if online
      if (await _connectivityService.isOnline()) {
        try {
          return await _apiService.countTelemetryData(
            userId: params.userId,
            plantId: params.plantId,
            startDate: params.startDate,
            endDate: params.endDate,
            syncStatusFilter: params.syncStatuses,
          );
        } catch (e) {
          // API call failed, fall back to local storage
        }
      }
      
      // Fall back to local storage
      return await _localService.countTelemetryData(
        itemType: params.itemType,
        startDate: params.startDate,
        endDate: params.endDate,
        isSynced: params.syncStatus == SyncStatus.synced,
        sessionId: params.sessionId,
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to count telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<TelemetryData> update(TelemetryData data) async {
    try {
      // Update local storage first
      await _localService.updateTelemetryData(data);
      _updateCache(data);
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final syncedData = await _apiService.updateTelemetryData(data);
          await _localService.markAsSynced(data.id!, serverId: syncedData.id);
          _updateCache(syncedData);
          _telemetryUpdatesController.add(syncedData);
          return syncedData;
        } catch (e) {
          // API call failed, but data is updated locally
          // Will be synced later when connectivity is restored
        }
      }
      
      _telemetryUpdatesController.add(data);
      return data;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to update telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<GrowthPhotoData> updateGrowthPhoto(GrowthPhotoData data) async {
    try {
      // Convert to TelemetryData for storage
      final telemetryData = TelemetryData(
        id: data.id,
        userId: data.userId ?? '',
        plantId: data.plantId,
        growthPhoto: data,
        sessionId: data.telemetrySessionId,
        offlineCreated: data.offlineCreated,
        clientTimestamp: data.clientTimestamp ?? DateTime.now(),
        serverTimestamp: data.updatedAt,
        metadata: data.conflictResolutionData,
        createdAt: data.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Update using the base update method
      final updatedTelemetryData = await update(telemetryData);
      
      // Return the updated growth photo data
      return updatedTelemetryData.growthPhoto ?? data;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to update growth photo data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<BatchOperationResult> updateBatch(BatchOperationParams params) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      for (int i = 0; i < params.items.length; i++) {
        final data = params.items[i];
        try {
          if (params.validateBeforeOperation) {
            final isValid = await validate(data);
            if (!isValid) {
              throw Exception('Data validation failed');
            }
          }
          
          final updatedData = await _localService.updateTelemetryData(data);
          _updateCache(updatedData);
          successful.add(updatedData);
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: data.id,
            index: i,
            error: e.toString(),
            code: 'UPDATE_ERROR',
            type: TelemetryRepositoryErrorType.storage,
          ));
          
          if (!params.continueOnError) break;
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': params.items.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
          ...?params.metadata,
        },
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to update batch: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<BatchOperationResult> deleteBatch(List<String> ids) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      for (int i = 0; i < ids.length; i++) {
        final id = ids[i];
        try {
          final data = await _localService.getTelemetryData(id);
          if (data != null) {
            await _localService.deleteTelemetryData(id);
            _cache.remove(id);
            _cacheTimestamps.remove(id);
            successful.add(data);
          } else {
            failed.add(BatchOperationError(
              itemId: id,
              index: i,
              error: 'Item not found',
              code: 'NOT_FOUND',
              type: TelemetryRepositoryErrorType.notFound,
            ));
          }
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: id,
            index: i,
            error: e.toString(),
            code: 'DELETE_ERROR',
            type: TelemetryRepositoryErrorType.storage,
          ));
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': ids.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to delete batch: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<List<TelemetryData>> getPendingSync() async {
    try {
      return await _localService.getPendingSyncData();
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to get pending sync data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<void> syncPendingData() async {
    try {
      final pendingData = await _localService.getPendingSyncData();
      
      if (pendingData.isEmpty) {
        return;
      }
      
      // Check if online before attempting sync
      if (!await _connectivityService.isOnline()) {
        throw const TelemetryRepositoryException(
          message: 'Cannot sync: device is offline',
          type: TelemetryRepositoryErrorType.network,
        );
      }
      
      // Sync each pending item
      for (final data in pendingData) {
        try {
          final syncedData = await _apiService.createTelemetryData(data);
          await _localService.markAsSynced(data.id!, serverId: syncedData.id);
          _updateCache(syncedData);
          _syncStatusController.add(SyncStatus.synced);
        } catch (e) {
          // Mark this item as sync failed
          await _localService.markSyncFailed(data.id!, 'Sync failed: $e');
          _syncStatusController.add(SyncStatus.failed);
        }
      }
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to sync pending data: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  @override
  Future<BatchOperationResult> markBatchAsSynced(
    List<String> ids, {
    Map<String, String>? serverIds,
    DateTime? syncTimestamp,
  }) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      for (int i = 0; i < ids.length; i++) {
        final id = ids[i];
        try {
          final serverId = serverIds?[id];
          await _localService.markAsSynced(id, serverId: serverId);
          
          final data = await _localService.getTelemetryData(id);
          if (data != null) {
            successful.add(data);
          }
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: id,
            index: i,
            error: e.toString(),
            code: 'SYNC_ERROR',
            type: TelemetryRepositoryErrorType.sync,
          ));
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': ids.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to mark batch as synced: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  @override
  Future<void> markSyncFailed(String id, String error, {String? code}) async {
    try {
      await _localService.markSyncFailed(id, error, errorCode: code);
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to mark sync as failed: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  @override
  Future<TelemetryData> resolveSyncConflict(
    String id,
    TelemetryData localData,
    TelemetryData remoteData,
    ConflictResolutionStrategy strategy,
  ) async {
    try {
      // Apply resolution strategy
      TelemetryData resolvedData;
      switch (strategy) {
        case ConflictResolutionStrategy.useLocal:
          resolvedData = localData;
          break;
        case ConflictResolutionStrategy.useRemote:
          resolvedData = remoteData;
          break;
        case ConflictResolutionStrategy.merge:
          // Merge local and remote data - use remote data with local metadata
          resolvedData = remoteData.copyWith(
            metadata: {...?localData.metadata, ...?remoteData.metadata},
          );
          break;
        case ConflictResolutionStrategy.manual:
          // For manual resolution, use local data as base
          resolvedData = localData;
          break;
      }
      
      // Update local storage with resolved data
      final updatedData = await _localService.updateTelemetryData(resolvedData);
      _updateCache(updatedData);
      
      return updatedData;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to resolve sync conflict: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final stats = await _localService.getSyncStats();
      return {
        'total_items': stats.totalItems,
        'synced_items': stats.syncedItems,
        'pending_items': stats.pendingItems,
        'failed_items': stats.failedItems,
        'sync_percentage': stats.syncPercentage,
        'is_fully_synced': stats.isFullySynced,
        'has_failures': stats.hasFailures,
        'summary': stats.summary,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw const TelemetryRepositoryException(
        message: 'Failed to get statistics',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<bool> validate(TelemetryData data) async {
    try {
      // Basic validation
      if (data.userId.isEmpty) return false;
      if (data.clientTimestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
        return false; // Future timestamp not allowed
      }
      
      // Validate specific data types
      if (data.lightReading != null) {
        final reading = data.lightReading!;
        if (reading.luxValue < 0 || reading.luxValue > 200000) return false;
      }
      
      if (data.growthPhoto != null) {
        final photo = data.growthPhoto!;
        if (photo.filePath.isEmpty) return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> export(TelemetryQueryParams params) async {
    try {
      final data = await _localService.queryTelemetryData(
        itemType: null, // Export all types
        startDate: params.startDate,
        endDate: params.endDate,
        sessionId: null,
        limit: params.limit,
        offset: params.offset,
      );
      
      return {
        'data': data.map((item) => item.toJson()).toList(),
        'metadata': {
          'export_timestamp': DateTime.now().toIso8601String(),
          'total_items': data.length,
          'query_params': {
            'user_id': params.userId,
            'plant_id': params.plantId,
            'start_date': params.startDate?.toIso8601String(),
            'end_date': params.endDate?.toIso8601String(),
            'limit': params.limit,
            'offset': params.offset,
          },
        },
      };
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to export data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<BatchOperationResult> import(
    Map<String, dynamic> data, {
    bool validateBeforeImport = true,
    bool overwriteExisting = false,
  }) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      // Extract telemetry data from the import data
      final telemetryItems = data['telemetry_data'] as List<dynamic>? ?? [];
      
      for (int i = 0; i < telemetryItems.length; i++) {
        final itemData = telemetryItems[i] as Map<String, dynamic>;
        try {
          final telemetryData = TelemetryData.fromJson(itemData);
          
          if (validateBeforeImport) {
            final isValid = await validate(telemetryData);
            if (!isValid) {
              throw Exception('Data validation failed');
            }
          }
          
          // Check if item exists
          final existingData = await _localService.getTelemetryData(telemetryData.id!);
          
          if (existingData != null && !overwriteExisting) {
            failed.add(BatchOperationError(
              itemId: telemetryData.id,
              index: i,
              error: 'Item already exists and overwriteExisting is false',
              code: 'ALREADY_EXISTS',
              type: TelemetryRepositoryErrorType.validation,
            ));
            continue;
          }
          
          // Save or update the data
          if (existingData != null) {
            await _localService.updateTelemetryData(telemetryData);
          } else {
            await _localService.saveTelemetryData(telemetryData);
          }
          
          _updateCache(telemetryData);
          successful.add(telemetryData);
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: null,
            index: i,
            error: e.toString(),
            code: 'IMPORT_ERROR',
            type: TelemetryRepositoryErrorType.validation,
          ));
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': telemetryItems.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'validate_before_import': validateBeforeImport,
          'overwrite_existing': overwriteExisting,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to import data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  // Sync Operations
  @override
  Future<SyncResult> sync(SyncParams params) async {
    try {
      if (!await _connectivityService.isOnline()) {
        return SyncResult(
          syncedCount: 0,
          failedCount: 0,
          syncedIds: [],
          failures: [],
          syncTimestamp: DateTime.now(),
          metadata: {'error': 'Device is offline'},
        );
      }

      _syncStatusController.add(SyncStatus.inProgress);
      
      final pendingData = await _localService.getPendingSyncData();
      final successful = <String>[];
      final failed = <String>[];
      final errors = <String>[];
      
      for (final data in pendingData) {
        try {
          // Use createBatch for single item sync
          final batchResponse = await _apiService.createBatch(
            [data],
            continueOnError: false,
          );
          if (batchResponse.successful.isNotEmpty) {
            final syncedData = batchResponse.successful.first;
            await _localService.markAsSynced(data.id!, serverId: syncedData.id);
            successful.add(data.id!);
            _updateCache(syncedData);
          } else if (batchResponse.failed.isNotEmpty) {
            failed.add(data.id!);
            errors.add('Failed to sync ${data.id}: ${batchResponse.failed.first.error}');
          }
        } catch (e) {
          failed.add(data.id!);
          errors.add('Failed to sync ${data.id}: $e');
        }
      }
      
      final result = SyncResult(
        syncedCount: successful.length,
        failedCount: failed.length,
        syncedIds: successful,
        failures: errors.map((error) => BatchOperationError(
           itemId: null,
           index: 0,
           error: error,
           code: 'SYNC_ERROR',
           type: TelemetryRepositoryErrorType.sync,
         )).toList(),
        syncTimestamp: DateTime.now(),
        metadata: {
          'total_pending': pendingData.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      _syncStatusController.add(failed.isEmpty ? SyncStatus.synced : SyncStatus.failed);
      return result;
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      throw TelemetryRepositoryException(
        message: 'Sync failed: $e',
        type: TelemetryRepositoryErrorType.sync,
      );
    }
  }

  Future<SyncStatus> getSyncStatus() async {
    try {
      final pendingCount = await _localService.getPendingSyncCount();
      if (pendingCount == 0) {
        return SyncStatus.synced;
      } else if (await _connectivityService.isOnline()) {
        return SyncStatus.pending;
      } else {
        return SyncStatus.failed;
      }
    } catch (e) {
      return SyncStatus.failed;
    }
  }

  Future<int> getPendingSyncCount() async {
    try {
      return await _localService.getPendingSyncCount();
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to get pending sync count: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Future<int> cleanup(DateTime olderThan) async {
    try {
      await _localService.cleanupOldData(retentionPeriod: DateTime.now().difference(olderThan));
      _clearCache();
      return 1; // Return count of cleanup operations performed
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Cleanup failed: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  // Stream getters
  Stream<List<TelemetryData>> get telemetryDataStream => _telemetryStreamController.stream;

  Stream<TelemetryData> get telemetryUpdatesStream => _telemetryUpdatesController.stream;

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  Stream<int> get pendingSyncCountStream {
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => _localService.getPendingSyncCount());
  }

  // Additional methods
  Future<void> clearCache() async {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  void _clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> clearLocalData() async {
    try {
      await _localService.clearLocalData();
      _clearCache();
    } catch (e) {
      throw const TelemetryRepositoryException(
        message: 'Failed to clear local data',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  void _updateCache(TelemetryData data) {
    if (data.id != null) {
      _cache[data.id!] = data;
      _cacheTimestamps[data.id!] = DateTime.now();
    }
  }

  bool _isCacheValid(String id) {
    if (!_cache.containsKey(id) || !_cacheTimestamps.containsKey(id)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[id]!;
    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  void dispose() {
    _telemetryStreamController.close();
    _telemetryUpdatesController.close();
    _syncStatusController.close();
  }
@override
  Future<void> markAsSynced(String id, {String? serverId, DateTime? syncTimestamp}) async {
    try {
      await _localService.markAsSynced(id, serverId: serverId);
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to mark as synced: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  @override
  Stream<List<TelemetryData>> watchPendingSync() {
    return Stream.periodic(const Duration(seconds: 10))
        .asyncMap((_) => _localService.getPendingSyncData());
  }

  @override
  Stream<List<TelemetryData>> watchPlantTelemetry(String plantId) {
    return watchTelemetryData(TelemetryQueryParams(plantId: plantId));
  }

  @override
  Stream<List<TelemetryData>> watchSyncStatus(List<SyncStatus> statuses) {
    return watchTelemetryData(TelemetryQueryParams(syncStatuses: statuses));
  }

  @override
  Stream<List<TelemetryData>> watchUserTelemetry(String userId) {
    return watchTelemetryData(TelemetryQueryParams(userId: userId));
  }

  @override
  Stream<List<TelemetryData>> watchTelemetryData(TelemetryQueryParams params) {
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => query(params));
  }
}