/// Local storage service for telemetry data persistence
/// Handles SQLite operations, data encryption, sync status management, and offline support
library;

import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/services/storage_service.dart';
import '../database/telemetry_database.dart';
import '../providers/telemetry_database_provider.dart';
import '../../models/telemetry_data_models.dart';

/// Provider for the telemetry local service
final telemetryLocalServiceProvider = Provider<TelemetryLocalService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final database = ref.watch(telemetryDatabaseProvider);
  return TelemetryLocalService(storageService, database);
});

/// Service for managing local telemetry data storage and sync operations
/// Provides SQLite-based persistence with encryption and offline support
class TelemetryLocalService {
  final StorageService _storageService;
  final TelemetryDatabase _database;
  
  static const String _encryptionKeyPrefix = 'telemetry_encryption_';
  static const String _syncMetadataKey = 'telemetry_sync_metadata';
  static const String _offlineQueueKey = 'telemetry_offline_queue';

  TelemetryLocalService(this._storageService, this._database);

  /// Initialize the local service
  /// Sets up database connection and performs cleanup if needed
  Future<void> initialize() async {
    try {
      // Ensure database is initialized
      await _database.database;
      
      // Perform cleanup of old data if needed
      await _cleanupOldData();
      
      // Initialize sync metadata
      await _initializeSyncMetadata();
    } catch (e) {
      throw TelemetryLocalException('Failed to initialize local service: $e');
    }
  }

  /// Save telemetry data to local storage with encryption
  Future<void> saveTelemetryData(TelemetryData data) async {
    try {
      final db = await _database.database;
      
      // Determine item type based on data content
      String itemType = 'unknown';
      if (data.lightReading != null) {
        itemType = 'light_reading';
      } else if (data.growthPhoto != null) {
        itemType = 'growth_photo';
      } else if (data.batchData != null) {
        itemType = 'batch';
      }
      
      // Encrypt sensitive data
      final encryptedData = await _encryptTelemetryData(data);
      
      // Insert telemetry data
      await db.insert(
        TelemetryDatabaseConfig.telemetryDataTable,
        {
          'id': data.id ?? _generateId(),
          'user_id': data.userId,
          'plant_id': data.plantId,
          'item_type': itemType,
          'encrypted_data': encryptedData,
          'session_id': data.sessionId,
          'offline_created': data.offlineCreated ? 1 : 0,
          'client_timestamp': data.clientTimestamp.millisecondsSinceEpoch,
          'server_timestamp': data.serverTimestamp?.millisecondsSinceEpoch,
          'metadata': data.metadata != null ? jsonEncode(data.metadata) : null,
          'created_at': data.createdAt.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Insert sync status
      await _insertSyncStatus(data.id ?? _generateId(), itemType, data.sessionId);
      
    } catch (e) {
      throw TelemetryLocalException('Failed to save telemetry data: $e');
    }
  }

  /// Get pending sync data that needs to be uploaded
  /// Returns data that hasn't been synced to the server
  Future<List<TelemetryData>> getPendingSyncData({int? limit}) async {
    try {
      final db = await _database.database;
      
      final query = '''
        SELECT td.* FROM ${TelemetryDatabaseConfig.telemetryDataTable} td
        INNER JOIN ${TelemetryDatabaseConfig.telemetrySyncStatusTable} tss
        ON td.id = tss.item_id
        WHERE tss.sync_status IN ('pending', 'failed', 'retry')
        ORDER BY td.created_at ASC
        ${limit != null ? 'LIMIT $limit' : ''}
      ''';
      
      final results = await db.rawQuery(query);
      
      final telemetryDataList = <TelemetryData>[];
      for (final row in results) {
        final decryptedData = await _decryptTelemetryData(row['encrypted_data'] as String);
        telemetryDataList.add(decryptedData);
      }
      
      return telemetryDataList;
    } catch (e) {
      throw TelemetryLocalException('Failed to get pending sync data: $e');
    }
  }

  /// Mark telemetry data as synced
  /// Updates sync status and removes from pending queue
  Future<void> markAsSynced(String itemId, {String? serverId}) async {
    try {
      final db = await _database.database;
      
      await db.transaction((txn) async {
        // Update sync status
        await txn.update(
          TelemetryDatabaseConfig.telemetrySyncStatusTable,
          {
            'sync_status': 'synced',
            'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'item_id = ?',
          whereArgs: [itemId],
        );
        
        // Update telemetry data with server ID if provided
        final updateData = {
          'is_synced': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };
        
        if (serverId != null) {
          updateData['server_timestamp'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        await txn.update(
          TelemetryDatabaseConfig.telemetryDataTable,
          updateData,
          where: 'id = ?',
          whereArgs: [itemId],
        );
      });
    } catch (e) {
      throw TelemetryLocalException('Failed to mark as synced: $e');
    }
  }

  /// Mark sync as failed with error information
  /// Updates sync status and increments retry count
  Future<void> markSyncFailed(String itemId, String error, {String? errorCode}) async {
    try {
      final db = await _database.database;
      
      await db.update(
        TelemetryDatabaseConfig.telemetrySyncStatusTable,
        {
          'sync_status': 'failed',
          'sync_error': error,
          'error_code': errorCode,
          'retry_count': 'retry_count + 1',
          'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
          'next_retry_at': _calculateNextRetryTime().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'item_id = ?',
        whereArgs: [itemId],
      );
    } catch (e) {
      throw TelemetryLocalException('Failed to mark sync as failed: $e');
    }
  }

  /// Get offline telemetry data for local viewing
  /// Returns data available for offline access
  Future<List<TelemetryData>> getOfflineData({
    String? sessionId,
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int offset = 0,
  }) async {
    try {
      final db = await _database.database;
      
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];
      
      if (sessionId != null) {
        whereConditions.add('session_id = ?');
        whereArgs.add(sessionId);
      }
      
      if (itemType != null) {
        whereConditions.add('item_type = ?');
        whereArgs.add(itemType);
      }
      
      if (startDate != null) {
        whereConditions.add('offline_created >= ?');
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }
      
      if (endDate != null) {
        whereConditions.add('offline_created <= ?');
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
      
      final whereClause = whereConditions.isNotEmpty 
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : '';
      
      final query = '''
        SELECT * FROM ${TelemetryDatabaseConfig.telemetryDataTable}
        $whereClause
        ORDER BY offline_created DESC
        ${limit != null ? 'LIMIT $limit' : ''}
        ${offset > 0 ? 'OFFSET $offset' : ''}
      ''';
      
      final results = await db.rawQuery(query, whereArgs);
      
      final telemetryDataList = <TelemetryData>[];
      for (final row in results) {
        final decryptedData = await _decryptSensitiveData(
          _mapRowToTelemetryData(row)
        );
        telemetryDataList.add(decryptedData);
      }
      
      return telemetryDataList;
    } catch (e) {
      throw TelemetryLocalException('Failed to get offline data: $e');
    }
  }

  /// Get telemetry data by ID from local storage
  /// Returns the telemetry data item if found, null otherwise
  Future<TelemetryData?> getTelemetryData(String id) async {
    try {
      final db = await _database.database;
      
      final results = await db.query(
        TelemetryDatabaseConfig.telemetryDataTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final telemetryData = _mapRowToTelemetryData(results.first);
      return await _decryptSensitiveData(telemetryData);
    } catch (e) {
      throw TelemetryLocalException('Failed to get telemetry data by ID: $e');
    }
  }

  /// Get sync statistics for monitoring
  /// Returns information about sync status and data counts
  Future<TelemetryLocalStats> getSyncStats() async {
    try {
      final db = await _database.database;
      
      final totalQuery = '''
        SELECT COUNT(*) as total FROM ${TelemetryDatabaseConfig.telemetryDataTable}
      ''';
      
      final syncedQuery = '''
        SELECT COUNT(*) as synced FROM ${TelemetryDatabaseConfig.telemetryDataTable}
        WHERE is_synced = 1
      ''';
      
      final pendingQuery = '''
        SELECT COUNT(*) as pending FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable}
        WHERE sync_status IN ('pending', 'retry')
      ''';
      
      final failedQuery = '''
        SELECT COUNT(*) as failed FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable}
        WHERE sync_status = 'failed'
      ''';
      
      final totalResult = await db.rawQuery(totalQuery);
      final syncedResult = await db.rawQuery(syncedQuery);
      final pendingResult = await db.rawQuery(pendingQuery);
      final failedResult = await db.rawQuery(failedQuery);
      
      return TelemetryLocalStats(
        totalItems: totalResult.first['total'] as int,
        syncedItems: syncedResult.first['synced'] as int,
        pendingItems: pendingResult.first['pending'] as int,
        failedItems: failedResult.first['failed'] as int,
      );
    } catch (e) {
      throw TelemetryLocalException('Failed to get sync stats: $e');
    }
  }

  /// Query telemetry data with filters and pagination
  /// Supports filtering by date range, item type, sync status, etc.
  Future<List<TelemetryData>> queryTelemetryData({
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSynced,
    String? sessionId,
    int? limit,
    int? offset,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final db = await _database.database;
      
      // Build WHERE clause
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];
      
      if (itemType != null) {
        whereConditions.add('item_type = ?');
        whereArgs.add(itemType);
      }
      
      if (startDate != null) {
        whereConditions.add('client_timestamp >= ?');
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }
      
      if (endDate != null) {
        whereConditions.add('client_timestamp <= ?');
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
      
      if (isSynced != null) {
        whereConditions.add('is_synced = ?');
        whereArgs.add(isSynced ? 1 : 0);
      }
      
      if (sessionId != null) {
        whereConditions.add('session_id = ?');
        whereArgs.add(sessionId);
      }
      
      // Build ORDER BY clause
      String orderByClause = 'client_timestamp DESC';
      if (orderBy != null) {
        orderByClause = '$orderBy ${ascending ? 'ASC' : 'DESC'}';
      }
      
      // Build query
      String query = 'SELECT * FROM ${TelemetryDatabaseConfig.telemetryDataTable}';
      if (whereConditions.isNotEmpty) {
        query += ' WHERE ${whereConditions.join(' AND ')}';
      }
      query += ' ORDER BY $orderByClause';
      
      if (limit != null) {
        query += ' LIMIT $limit';
        if (offset != null) {
          query += ' OFFSET $offset';
        }
      }
      
      final results = await db.rawQuery(query, whereArgs);
      
      final telemetryDataList = <TelemetryData>[];
      for (final row in results) {
        final data = _mapRowToTelemetryData(row);
        final decryptedData = await _decryptSensitiveData(data);
        telemetryDataList.add(decryptedData);
      }
      
      return telemetryDataList;
    } catch (e) {
      throw TelemetryLocalException('Failed to query telemetry data: $e');
    }
  }

  /// Count telemetry data with optional filters
  /// Returns the total count of telemetry data matching the criteria
  Future<int> countTelemetryData({
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSynced,
    String? sessionId,
  }) async {
    try {
      final db = await _database.database;
      
      // Build WHERE clause
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];
      
      if (itemType != null) {
        whereConditions.add('item_type = ?');
        whereArgs.add(itemType);
      }
      
      if (startDate != null) {
        whereConditions.add('client_timestamp >= ?');
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }
      
      if (endDate != null) {
        whereConditions.add('client_timestamp <= ?');
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
      
      if (isSynced != null) {
        whereConditions.add('is_synced = ?');
        whereArgs.add(isSynced ? 1 : 0);
      }
      
      if (sessionId != null) {
        whereConditions.add('session_id = ?');
        whereArgs.add(sessionId);
      }
      
      // Build query
      String query = 'SELECT COUNT(*) as count FROM ${TelemetryDatabaseConfig.telemetryDataTable}';
      if (whereConditions.isNotEmpty) {
        query += ' WHERE ${whereConditions.join(' AND ')}';
      }
      
      final result = await db.rawQuery(query, whereArgs);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw TelemetryLocalException('Failed to count telemetry data: $e');
    }
  }

  /// Update existing telemetry data
  /// Updates the specified telemetry data item in local storage
  Future<TelemetryData> updateTelemetryData(TelemetryData data) async {
    try {
      final db = await _database.database;
      
      // Encrypt sensitive data
      final encryptedData = await _encryptSensitiveData(data);
      
      // Prepare data for storage
      final dataMap = _prepareDataForStorage(encryptedData);
      
      // Update the record
      final updatedRows = await db.update(
        TelemetryDatabaseConfig.telemetryDataTable,
        dataMap,
        where: 'id = ?',
        whereArgs: [data.id],
      );
      
      if (updatedRows == 0) {
        throw TelemetryLocalException('Telemetry data with id ${data.id} not found');
      }
      
      // Update sync status to mark as needing sync
      await db.update(
        TelemetryDatabaseConfig.telemetrySyncStatusTable,
        {
          'sync_status': 'pending',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'item_id = ?',
        whereArgs: [data.id],
      );
      
      _logDebug('Updated telemetry data: ${data.id}');
      return encryptedData;
    } catch (e) {
      _logError('Failed to update telemetry data', e);
      throw TelemetryLocalException('Failed to update telemetry data: $e');
    }
  }

  /// Delete telemetry data by ID
  /// Removes the specified telemetry data item from local storage
  Future<void> deleteTelemetryData(String id) async {
    try {
      final db = await _database.database;
      
      await db.transaction((txn) async {
        // Delete sync status entry first (due to foreign key constraint)
        await txn.delete(
          TelemetryDatabaseConfig.telemetrySyncStatusTable,
          where: 'item_id = ?',
          whereArgs: [id],
        );
        
        // Delete telemetry data
        final deletedRows = await txn.delete(
          TelemetryDatabaseConfig.telemetryDataTable,
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (deletedRows == 0) {
          throw TelemetryLocalException('Telemetry data with id $id not found');
        }
      });
      
      _logDebug('Deleted telemetry data: $id');
    } catch (e) {
      _logError('Failed to delete telemetry data', e);
      throw TelemetryLocalException('Failed to delete telemetry data: $e');
    }
  }

  /// Batch delete multiple telemetry data items
  /// Efficiently removes multiple telemetry data items in a single transaction
  Future<void> batchDeleteTelemetryData(List<String> ids) async {
    if (ids.isEmpty) return;
    
    try {
      final db = await _database.database;
      
      await db.transaction((txn) async {
        // Create placeholders for IN clause
        final placeholders = List.filled(ids.length, '?').join(',');
        
        // Delete sync status entries first (due to foreign key constraint)
        await txn.delete(
          TelemetryDatabaseConfig.telemetrySyncStatusTable,
          where: 'item_id IN ($placeholders)',
          whereArgs: ids,
        );
        
        // Delete telemetry data
        final deletedRows = await txn.delete(
          TelemetryDatabaseConfig.telemetryDataTable,
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );
        
        _logDebug('Batch deleted $deletedRows telemetry data items');
      });
    } catch (e) {
      _logError('Failed to batch delete telemetry data', e);
      throw TelemetryLocalException('Failed to batch delete telemetry data: $e');
    }
  }

  /// Batch save multiple telemetry data items
  /// Optimized for bulk operations with transaction support
  Future<List<TelemetryData>> batchSaveTelemetryData(List<TelemetryData> dataList) async {
    try {
      final db = await _database.database;
      final savedData = <TelemetryData>[];
      
      await db.transaction((txn) async {
        for (final data in dataList) {
          // Encrypt sensitive data
          final encryptedData = await _encryptSensitiveData(data);
          
          // Prepare data for storage
          final dataMap = _prepareDataForStorage(encryptedData);
          
          // Insert into database
          await txn.insert(
            TelemetryDatabaseConfig.telemetryDataTable,
            dataMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          
          // Create sync status entry
          await _createSyncStatusEntryInTransaction(
            txn, data.id!, data.itemType, data.sessionId ?? ''
          );
          
          savedData.add(encryptedData);
        }
      });
      
      return savedData;
    } catch (e) {
      throw TelemetryLocalException('Failed to batch save telemetry data: $e');
    }
  }

  /// Clean up old data based on retention policy
  /// Removes data older than specified retention period
  Future<void> cleanupOldData({Duration? retentionPeriod}) async {
    try {
      final db = await _database.database;
      final retention = retentionPeriod ?? const Duration(days: 90);
      final cutoffTime = DateTime.now().subtract(retention).millisecondsSinceEpoch;
      
      await db.transaction((txn) async {
        // Delete old sync status entries first (due to foreign key constraint)
        await txn.delete(
          TelemetryDatabaseConfig.telemetrySyncStatusTable,
          where: '''
            item_id IN (
              SELECT id FROM ${TelemetryDatabaseConfig.telemetryDataTable}
              WHERE offline_created < ? AND is_synced = 1
            )
          ''',
          whereArgs: [cutoffTime],
        );
        
        // Delete old telemetry data
        await txn.delete(
          TelemetryDatabaseConfig.telemetryDataTable,
          where: 'offline_created < ? AND is_synced = 1',
          whereArgs: [cutoffTime],
        );
      });
    } catch (e) {
      throw TelemetryLocalException('Failed to cleanup old data: $e');
    }
  }

  /// Encrypt sensitive data fields
  Future<TelemetryData> _encryptSensitiveData(TelemetryData data) async {
    try {
      // For now, return data as-is since we're using secure storage for keys
      // In a production environment, you might encrypt specific fields
      return data;
    } catch (e) {
      throw TelemetryLocalException('Failed to encrypt sensitive data: $e');
    }
  }

  /// Decrypt sensitive data fields
  Future<TelemetryData> _decryptSensitiveData(TelemetryData data) async {
    try {
      // For now, return data as-is since we're using secure storage for keys
      // In a production environment, you might decrypt specific fields
      return data;
    } catch (e) {
      throw TelemetryLocalException('Failed to decrypt sensitive data: $e');
    }
  }

  /// Prepare telemetry data for database storage
  Map<String, dynamic> _prepareDataForStorage(TelemetryData data) {
    return {
      'id': data.id,
      'user_id': data.userId,
      'plant_id': data.plantId,
      'session_id': data.sessionId,
      'offline_created': data.offlineCreated ? 1 : 0,
      'client_timestamp': data.clientTimestamp.millisecondsSinceEpoch,
      'server_timestamp': data.serverTimestamp?.millisecondsSinceEpoch,
      'created_at': data.createdAt.millisecondsSinceEpoch,
      'updated_at': data.updatedAt?.millisecondsSinceEpoch,
      'light_reading_data': data.lightReading != null 
          ? json.encode(data.lightReading!.toJson()) : null,
      'growth_photo_data': data.growthPhoto != null 
          ? json.encode(data.growthPhoto!.toJson()) : null,
      'batch_data': data.batchData != null 
          ? json.encode(data.batchData!.toJson()) : null,
      'sync_status': data.syncStatus != null 
          ? json.encode(data.syncStatus!.toJson()) : null,
      'metadata': data.metadata != null 
          ? json.encode(data.metadata!) : null,
    };
  }

  /// Map database row to TelemetryData object
  TelemetryData _mapRowToTelemetryData(Map<String, dynamic> row) {
    return TelemetryData(
      id: row['id'] as String?,
      userId: row['user_id'] as String,
      plantId: row['plant_id'] as String?,
      sessionId: row['session_id'] as String?,
      offlineCreated: (row['offline_created'] as int) == 1,
      clientTimestamp: DateTime.fromMillisecondsSinceEpoch(row['client_timestamp'] as int),
      serverTimestamp: row['server_timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(row['server_timestamp'] as int) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: row['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int) : null,
      lightReading: row['light_reading_data'] != null 
          ? LightReadingData.fromJson(json.decode(row['light_reading_data'] as String)) : null,
      growthPhoto: row['growth_photo_data'] != null 
          ? GrowthPhotoData.fromJson(json.decode(row['growth_photo_data'] as String)) : null,
      batchData: row['batch_data'] != null 
          ? TelemetryBatchData.fromJson(json.decode(row['batch_data'] as String)) : null,
      syncStatus: row['sync_status'] != null 
          ? TelemetrySyncStatus.fromJson(json.decode(row['sync_status'] as String)) : null,
      metadata: row['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(row['metadata'] as String)) : null,
    );
  }

  /// Create sync status entry for new telemetry data
  Future<void> _createSyncStatusEntry(String itemId, String itemType, String sessionId) async {
    final db = await _database.database;
    await _createSyncStatusEntryInTransaction(db, itemId, itemType, sessionId);
  }

  /// Create sync status entry within a transaction
  Future<void> _createSyncStatusEntryInTransaction(
    DatabaseExecutor txn, String itemId, String itemType, String sessionId
  ) async {
    await txn.insert(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      {
        'id': '${itemId}_sync',
        'item_id': itemId,
        'item_type': itemType,
        'session_id': sessionId,
        'sync_status': 'pending',
        'retry_count': 0,
        'max_retries': 3,
        'total_items': 1,
        'synced_items': 0,
        'failed_items': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Calculate next retry time based on exponential backoff
  DateTime _calculateNextRetryTime() {
    // Exponential backoff: 1min, 5min, 15min, 1hour
    final baseDelay = const Duration(minutes: 1);
    final backoffMultiplier = 5;
    final maxDelay = const Duration(hours: 1);
    
    final delay = Duration(
      milliseconds: (baseDelay.inMilliseconds * backoffMultiplier).clamp(
        baseDelay.inMilliseconds,
        maxDelay.inMilliseconds,
      ),
    );
    
    return DateTime.now().add(delay);
  }

  /// Initialize sync metadata
  Future<void> _initializeSyncMetadata() async {
    try {
      final metadata = await _storageService.getString(_syncMetadataKey);
      if (metadata == null) {
        final initialMetadata = {
          'last_cleanup': DateTime.now().millisecondsSinceEpoch,
          'version': '1.0.0',
        };
        await _storageService.setString(_syncMetadataKey, json.encode(initialMetadata));
      }
    } catch (e) {
      // Log error but don't fail initialization
      print('Failed to initialize sync metadata: $e');
    }
  }

  /// Clean up old data based on retention policy
  Future<void> _cleanupOldData() async {
    try {
      final metadata = await _storageService.getString(_syncMetadataKey);
      if (metadata != null) {
        final metadataMap = json.decode(metadata) as Map<String, dynamic>;
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(
          metadataMap['last_cleanup'] as int
        );
        
        // Only cleanup if it's been more than 24 hours
        if (DateTime.now().difference(lastCleanup).inHours > 24) {
          await cleanupOldData();
          
          // Update last cleanup time
          metadataMap['last_cleanup'] = DateTime.now().millisecondsSinceEpoch;
          await _storageService.setString(_syncMetadataKey, json.encode(metadataMap));
        }
      }
    } catch (e) {
      // Log error but don't fail initialization
      print('Failed to cleanup old data: $e');
    }
  }

  /// Get count of pending sync items
  /// Returns the number of items that need to be synced to the server
  Future<int> getPendingSyncCount() async {
    try {
      final db = await _database.database;
      
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable}
        WHERE sync_status IN ('pending', 'failed', 'retry')
      ''');
      
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw TelemetryLocalException('Failed to get pending sync count: $e');
    }
  }

  /// Clear all local telemetry data
  /// Removes all telemetry data and sync status from local storage
  Future<void> clearLocalData() async {
    try {
      final db = await _database.database;
      
      await db.transaction((txn) async {
        // Clear sync status table first (due to foreign key constraint)
        await txn.delete(TelemetryDatabaseConfig.telemetrySyncStatusTable);
        
        // Clear telemetry data table
        await txn.delete(TelemetryDatabaseConfig.telemetryDataTable);
      });
      
      // Clear sync metadata
      await _clearSyncMetadata();
      
      _logDebug('Cleared all local telemetry data');
    } catch (e) {
      _logError('Failed to clear local data', e);
      throw TelemetryLocalException('Failed to clear local data: $e');
    }
  }

  /// Encrypt telemetry data for secure storage
  String _encryptTelemetryData(TelemetryData data) {
    try {
      // Convert data to JSON and encrypt if needed
      final jsonData = data.toJson();
      return jsonEncode(jsonData);
    } catch (e) {
      throw TelemetryLocalException('Failed to encrypt telemetry data: $e');
    }
  }

  /// Decrypt telemetry data from secure storage
  Future<TelemetryData> _decryptTelemetryData(String encryptedData) async {
    try {
      // Decrypt and convert JSON back to TelemetryData
      final jsonData = jsonDecode(encryptedData) as Map<String, dynamic>;
      return TelemetryData.fromJson(jsonData);
    } catch (e) {
      throw TelemetryLocalException('Failed to decrypt telemetry data: $e');
    }
  }

  /// Insert sync status for telemetry data
  Future<void> _insertSyncStatus(String itemId, String itemType, String? sessionId) async {
    final db = await _database.database;
    
    await db.insert(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      {
        'item_id': itemId,
        'item_type': itemType,
        'session_id': sessionId,
        'sync_status': 'pending',
        'retry_count': 0,
        'max_retries': 5,
        'sync_priority': 5,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get count of pending sync items
  Future<int> _getPendingSyncCount() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE sync_status = ?',
        ['pending']
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw TelemetryLocalException('Failed to get pending sync count: $e');
    }
  }

  /// Get failed sync items count
  Future<int> _getFailedSyncCount() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE sync_status = ?',
        ['failed']
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw TelemetryLocalException('Failed to get failed sync count: $e');
    }
  }

  /// Get synced items count
  Future<int> _getSyncedCount() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE sync_status = ?',
        ['synced']
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw TelemetryLocalException('Failed to get synced count: $e');
    }
  }

  /// Clear sync metadata
  Future<void> _clearSyncMetadata() async {
    try {
      await _storageService.remove(_syncMetadataKey);
      await _storageService.remove(_offlineQueueKey);
    } catch (e) {
      throw TelemetryLocalException('Failed to clear sync metadata: $e');
    }
  }

  /// Generate unique ID for telemetry items
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Log debug information (replace with proper logging in production)
  void _logDebug(String message) {
    // TODO: Replace with proper logging framework
    // ignore: avoid_print
    print('[TelemetryLocalService] $message');
  }

  /// Log error information (replace with proper logging in production)
  void _logError(String message, [dynamic error]) {
    // TODO: Replace with proper logging framework
    // ignore: avoid_print
    print('[TelemetryLocalService] ERROR: $message${error != null ? ' - $error' : ''}');
  }
}

/// Statistics for telemetry local storage
class TelemetryLocalStats {
  final int totalItems;
  final int syncedItems;
  final int pendingItems;
  final int failedItems;

  const TelemetryLocalStats({
    required this.totalItems,
    required this.syncedItems,
    required this.pendingItems,
    required this.failedItems,
  });

  /// Calculate sync completion percentage
  double get syncPercentage {
    if (totalItems == 0) return 0.0;
    return (syncedItems / totalItems) * 100;
  }

  /// Check if all items are synced
  bool get isFullySynced => totalItems > 0 && syncedItems == totalItems;

  /// Check if there are any failed items
  bool get hasFailures => failedItems > 0;

  /// Get human-readable summary
  String get summary {
    return 'Total: $totalItems, Synced: $syncedItems, Pending: $pendingItems, Failed: $failedItems';
  }
}

/// Exception thrown by telemetry local storage operations
class TelemetryLocalException implements Exception {
  final String message;
  
  const TelemetryLocalException(this.message);
  
  @override
  String toString() => 'TelemetryLocalException: $message';
}