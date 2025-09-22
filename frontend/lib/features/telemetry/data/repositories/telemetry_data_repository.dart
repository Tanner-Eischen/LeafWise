/// Repository for telemetry data operations
/// Provides CRUD operations for telemetry data with offline support and sync management
library;

import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/telemetry_database.dart';
import '../models/telemetry_data_model.dart';

/// Repository class for managing telemetry data persistence
/// Handles all database operations for telemetry data and sync status
class TelemetryDataRepository {
  final TelemetryDatabase _database = TelemetryDatabase.instance;

  /// Insert telemetry data into the database
  /// Returns the inserted data with generated timestamps
  Future<TelemetryDataModel> insertTelemetryData(TelemetryDataModel data) async {
    final db = await _database.database;
    
    // Add timestamps if not present
    final now = DateTime.now();
    final dataWithTimestamps = data.copyWith(
      createdAt: data.createdAt,
      updatedAt: now,
    );
    
    final dataMap = _telemetryDataToMap(dataWithTimestamps);
    
    await db.insert(
      TelemetryDatabaseConfig.telemetryDataTable,
      dataMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return dataWithTimestamps;
  }

  /// Get telemetry data by ID
  /// Returns null if not found
  Future<TelemetryDataModel?> getTelemetryDataById(String id) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    
    return _mapToTelemetryData(maps.first);
  }

  /// Get all telemetry data for a session
  /// Returns list sorted by creation time (newest first)
  Future<List<TelemetryDataModel>> getTelemetryDataBySession(String sessionId) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'local_created_at DESC',
    );
    
    return maps.map(_mapToTelemetryData).toList();
  }

  /// Get telemetry data by sensor type
  /// Optionally filter by date range
  Future<List<TelemetryDataModel>> getTelemetryDataByType(
    String sensorType, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final db = await _database.database;
    
    String whereClause = 'sensor_type = ?';
    List<dynamic> whereArgs = [sensorType];
    
    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return maps.map(_mapToTelemetryData).toList();
  }

  /// Get unsynced telemetry data
  /// Returns data that hasn't been synchronized yet
  Future<List<TelemetryDataModel>> getUnsyncedTelemetryData({int? limit}) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'id NOT IN (SELECT telemetry_data_id FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE status = ?)',
      whereArgs: [SyncStatus.completed.value],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    
    return maps.map(_mapToTelemetryData).toList();
  }

  /// Update telemetry data sync status
  /// Marks data as synced and updates sync attempt tracking
  Future<void> updateSyncStatus(
    String id, {
    required bool isSynced,
    int? syncAttempts,
    DateTime? lastSyncAttempt,
  }) async {
    final db = await _database.database;
    
    final updateData = <String, dynamic>{
      'is_synced': isSynced ? 1 : 0,
      'local_updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (syncAttempts != null) {
      updateData['sync_attempts'] = syncAttempts;
    }
    
    if (lastSyncAttempt != null) {
      updateData['last_sync_attempt'] = lastSyncAttempt.millisecondsSinceEpoch;
    }
    
    await db.update(
      TelemetryDatabaseConfig.telemetryDataTable,
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete telemetry data by ID
  /// Returns true if data was deleted, false if not found
  Future<bool> deleteTelemetryData(String id) async {
    final db = await _database.database;
    
    final deletedRows = await db.delete(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    return deletedRows > 0;
  }

  /// Delete old telemetry data
  /// Removes data older than the specified number of days
  Future<int> deleteOldTelemetryData(int daysOld) async {
    final db = await _database.database;
    
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch;
    
    return await db.delete(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'local_created_at < ? AND is_synced = ?',
      whereArgs: [cutoffTime, 1], // Only delete synced data
    );
  }

  /// Insert or update sync status
  /// Creates or updates sync status tracking for telemetry data
  Future<TelemetrySyncStatusModel> upsertSyncStatus(TelemetrySyncStatusModel syncStatus) async {
    final db = await _database.database;
    
    final now = DateTime.now();
    final statusWithTimestamps = syncStatus.copyWith(
      updatedAt: now,
    );
    
    final statusMap = _syncStatusToMap(statusWithTimestamps);
    
    await db.insert(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      statusMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return statusWithTimestamps;
  }

  /// Get sync status by item ID
  /// Returns null if not found
  Future<TelemetrySyncStatusModel?> getSyncStatusByItemId(String itemId) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      where: 'telemetry_data_id = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    
    return _mapToSyncStatus(maps.first);
  }

  /// Get sync statuses by session
  /// Returns all sync statuses for a given session
  Future<List<TelemetrySyncStatusModel>> getSyncStatusesBySession(String sessionId) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'updated_at DESC',
    );
    
    return maps.map(_mapToSyncStatus).toList();
  }

  /// Get telemetry data by sync status
  /// Useful for finding items that need retry or are in specific states
  Future<List<TelemetryDataModel>> getTelemetryDataBySyncStatus(
    SyncStatus syncStatus, {
    int? limit,
    int? offset,
  }) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetryDataTable,
      where: 'id IN (SELECT telemetry_data_id FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE status = ?)',
      whereArgs: [syncStatus.value],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    
    return maps.map(_mapToTelemetryData).toList();
  }

  /// Get sync statuses by status
  /// Useful for finding items that need retry or are in specific states
  Future<List<TelemetrySyncStatusModel>> getSyncStatusesByStatus(
    SyncStatus syncStatus, {
    int? limit,
  }) async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      where: 'status = ?',
      whereArgs: [syncStatus.value],
      orderBy: 'updated_at ASC', // Process oldest first
      limit: limit,
    );
    
    return maps.map(_mapToSyncStatus).toList();
  }

  /// Get items ready for retry
  /// Returns sync statuses where retry time has passed
  Future<List<TelemetrySyncStatusModel>> getItemsReadyForRetry() async {
    final db = await _database.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      where: 'status = ? AND retry_count < ?',
      whereArgs: [SyncStatus.failed.value, 3],
      orderBy: 'last_sync_attempt ASC',
    );
    
    return maps.map(_mapToSyncStatus).toList();
  }

  /// Delete sync status by item ID
  /// Returns true if status was deleted, false if not found
  Future<bool> deleteSyncStatus(String itemId) async {
    final db = await _database.database;
    
    final deletedRows = await db.delete(
      TelemetryDatabaseConfig.telemetrySyncStatusTable,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    
    return deletedRows > 0;
  }

  /// Get repository statistics
  /// Returns counts and metrics for monitoring
  Future<Map<String, dynamic>> getRepositoryStatistics() async {
    final db = await _database.database;
    
    // Get telemetry data counts by sensor type
    final lightSensorCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetryDataTable} WHERE sensor_type = ?',
        ['light'],
      ),
    ) ?? 0;
    
    final temperatureCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetryDataTable} WHERE sensor_type = ?',
        ['temperature'],
      ),
    ) ?? 0;
    
    // Get sync status counts
    final pendingCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE status = ?',
        [SyncStatus.pending.value],
      ),
    ) ?? 0;
    
    final syncedCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE status = ?',
        [SyncStatus.completed.value],
      ),
    ) ?? 0;
    
    final failedCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable} WHERE status = ?',
        [SyncStatus.failed.value],
      ),
    ) ?? 0;
    
    return {
      'light_sensor_count': lightSensorCount,
      'temperature_count': temperatureCount,
      'pending_sync_count': pendingCount,
      'synced_count': syncedCount,
      'failed_sync_count': failedCount,
    };
  }

  /// Convert TelemetryData to database map
  Map<String, dynamic> _telemetryDataToMap(TelemetryDataModel data) {
    return {
      'id': data.id,
      'device_id': data.deviceId,
      'sensor_type': data.sensorType,
      'value': data.value,
      'unit': data.unit,
      'timestamp': data.timestamp.millisecondsSinceEpoch,
      'metadata': data.metadata != null ? json.encode(data.metadata!) : null,
      'latitude': data.latitude,
      'longitude': data.longitude,
      'accuracy': data.accuracy,
      'notes': data.notes,
      'created_at': data.createdAt.millisecondsSinceEpoch,
      'updated_at': data.updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Convert database map to TelemetryData
  TelemetryDataModel _mapToTelemetryData(Map<String, dynamic> map) {
    return TelemetryDataModel(
      id: map['id'] as int?,
      deviceId: map['device_id'] as String,
      sensorType: map['sensor_type'] as String,
      value: map['value'] as double,
      unit: map['unit'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata'] as String))
          : null,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      accuracy: map['accuracy'] as double?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// Convert TelemetrySyncStatus to database map
  Map<String, dynamic> _syncStatusToMap(TelemetrySyncStatusModel status) {
    return {
      'id': status.id,
      'telemetry_data_id': status.telemetryDataId,
      'status': status.status.value,
      'last_sync_attempt': status.lastSyncAttempt.millisecondsSinceEpoch,
      'last_successful_sync': status.lastSuccessfulSync?.millisecondsSinceEpoch,
      'retry_count': status.retryCount,
      'error_message': status.errorMessage,
      'created_at': status.createdAt.millisecondsSinceEpoch,
      'updated_at': status.updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Convert database map to TelemetrySyncStatus
  TelemetrySyncStatusModel _mapToSyncStatus(Map<String, dynamic> map) {
    return TelemetrySyncStatusModel(
      id: map['id'] as int?,
      telemetryDataId: map['telemetry_data_id'] as int,
      status: SyncStatus.fromString(map['status'] as String),
      lastSyncAttempt: DateTime.fromMillisecondsSinceEpoch(map['last_sync_attempt'] as int),
      lastSuccessfulSync: map['last_successful_sync'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_successful_sync'] as int)
          : null,
      retryCount: map['retry_count'] as int,
      errorMessage: map['error_message'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }
}