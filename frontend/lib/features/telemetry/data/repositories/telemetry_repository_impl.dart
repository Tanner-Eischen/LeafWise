/// Implementation of TelemetryRepository interface
/// Provides offline-first data persistence with sync capabilities
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/telemetry_data_models.dart';
import '../../domain/repositories/telemetry_repository.dart';
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
  Future<TelemetryData> create(TelemetryData data) async {
    try {
      // Save to local storage first
      await _localService.saveTelemetryData(data);
      _updateCache(data);
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final syncedData = await _apiService.createTelemetryData(data);
          if (syncedData != null) {
            await _localService.markAsSynced(data.id!, serverId: syncedData.id);
            _updateCache(syncedData);
            _telemetryUpdatesController.add(syncedData);
            return syncedData;
          }
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
  Future<BatchOperationResult> createBatch(List<TelemetryData> items) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      // Save all to local storage first
      for (int i = 0; i < items.length; i++) {
        final data = items[i];
        try {
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
        }
      }
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final response = await _apiService.createBatch(successful);
          
          // Update successful items with server data
          for (final serverData in response) {
            final localData = successful.firstWhere(
              (item) => item.id == serverData.id,
              orElse: () => serverData,
            );
            await _localService.markAsSynced(localData.id!, serverId: serverData.id);
            _updateCache(serverData);
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
          'total_processed': items.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
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
          final data = await _apiService.queryTelemetryData(params);
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
      final localData = await _localService.queryTelemetryData(params);
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
          return await _apiService.countTelemetryData(params);
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
          if (syncedData != null) {
            await _localService.markAsSynced(data.id!, serverId: syncedData.id);
            _updateCache(syncedData);
            _telemetryUpdatesController.add(syncedData);
            return syncedData;
          }
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
  Future<BatchOperationResult> updateBatch(List<TelemetryData> items) async {
    try {
      final successful = <TelemetryData>[];
      final failed = <BatchOperationError>[];
      
      // Update all in local storage first
      for (int i = 0; i < items.length; i++) {
        final data = items[i];
        try {
          await _localService.updateTelemetryData(data);
          _updateCache(data);
          successful.add(data);
        } catch (e) {
          failed.add(BatchOperationError(
            itemId: data.id,
            index: i,
            error: e.toString(),
            code: 'UPDATE_ERROR',
            type: TelemetryRepositoryErrorType.storage,
          ));
        }
      }
      
      // Try to sync to API if online
      if (await _connectivityService.isOnline()) {
        try {
          final response = await _apiService.updateBatch(successful);
          
          // Update successful items with server data
          for (final serverData in response) {
            final localData = successful.firstWhere(
              (item) => item.id == serverData.id,
              orElse: () => serverData,
            );
            await _localService.markAsSynced(localData.id!, serverId: serverData.id);
            _updateCache(serverData);
          }
        } catch (e) {
          // API call failed, but data is updated locally
          // Will be synced later when connectivity is restored
        }
      }
      
      return BatchOperationResult(
        successful: successful,
        failed: failed,
        metadata: {
          'total_processed': items.length,
          'success_count': successful.length,
          'failure_count': failed.length,
          'timestamp': DateTime.now().toIso8601String(),
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
  Future<bool> delete(String id) async {
    try {
      // Delete from local storage first
      final existed = await _localService.deleteTelemetryData(id);
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
      
      return existed;
    } catch (e) {
      throw TelemetryRepositoryException(
        message: 'Failed to delete telemetry data: $e',
        type: TelemetryRepositoryErrorType.storage,
      );
    }
  }

  // Sync Operations

  @override
  Future<SyncResult> sync({SyncParams? params}) async {
    try {
      if (!await _connectivityService.isOnline()) {
        return const SyncResult(
          success: false,
          syncedCount: 0,
          failedCount: 0,
          errors: [],
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
          final batchResponse = await _apiService.createBatch([data]);
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

  Future<void> syncPendingData() async {
    try {
      if (!await _connectivityService.isOnline()) {
        throw const TelemetryRepositoryException(
          message: 'Cannot sync while offline',
          type: TelemetryRepositoryErrorType.network,
        );
      }

      _syncStatusController.add(SyncStatus.inProgress);
      
      final pendingData = await _localService.getPendingSyncData();
      
      for (final data in pendingData) {
        try {
          // Use createBatch for single item sync
          final batchResponse = await _apiService.createBatch([data]);
          if (batchResponse.successful.isNotEmpty) {
            final syncedData = batchResponse.successful.first;
            await _localService.markAsSynced(data.id!, serverId: syncedData.id);
            _updateCache(syncedData);
          }
        } catch (e) {
          // Continue with other items even if one fails
          continue;
        }
      }
      
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      rethrow;
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
}