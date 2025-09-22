/// Database migration system for telemetry data
/// Handles schema changes and data migrations for telemetry database
library;

import 'package:sqflite/sqflite.dart';

/// Migration manager for telemetry database schema changes
/// Provides versioned migrations and rollback capabilities
class TelemetryMigrations {
  /// Current database version
  static const int currentVersion = 1;
  
  /// Initial database version
  static const int initialVersion = 1;

  /// Executes migrations from oldVersion to newVersion
  /// Called automatically by sqflite when database version changes
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _executeMigration(db, version);
    }
  }

  /// Executes a specific migration version
  /// Each version represents a set of schema changes
  static Future<void> _executeMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _migrationV1(db);
        break;
      default:
        throw Exception('Unknown migration version: $version');
    }
  }

  /// Migration V1: Initial database schema
  /// Creates telemetry_data and telemetry_sync_status tables with indexes
  static Future<void> _migrationV1(Database db) async {
    // Create telemetry_data table
    await db.execute('''
      CREATE TABLE telemetry_data (
        id TEXT PRIMARY KEY CHECK(length(id) > 0),
        session_id TEXT NOT NULL CHECK(length(session_id) > 0),
        item_type TEXT NOT NULL CHECK (item_type IN ('light_reading', 'growth_photo', 'environmental_data')),
        
        -- Timing fields
        offline_created INTEGER NOT NULL CHECK(offline_created > 0),
        client_timestamp INTEGER NOT NULL CHECK(client_timestamp > 0),
        created_at INTEGER CHECK(created_at IS NULL OR created_at > 0),
        
        -- Light reading data (JSON when item_type = 'light_reading')
        light_reading_data TEXT CHECK(light_reading_data IS NULL OR json_valid(light_reading_data)),
        
        -- Growth photo data (JSON when item_type = 'growth_photo')
        growth_photo_data TEXT CHECK(growth_photo_data IS NULL OR json_valid(growth_photo_data)),
        
        -- Environmental data (JSON when item_type = 'environmental_data')
        environmental_data TEXT CHECK(environmental_data IS NULL OR json_valid(environmental_data)),
        
        -- Metadata
        device_info TEXT CHECK(device_info IS NULL OR json_valid(device_info)),
        app_version TEXT CHECK(app_version IS NULL OR length(app_version) > 0),
        
        -- Sync tracking
        is_synced INTEGER NOT NULL DEFAULT 0 CHECK(is_synced IN (0, 1)),
        sync_attempts INTEGER NOT NULL DEFAULT 0 CHECK(sync_attempts >= 0),
        last_sync_attempt INTEGER CHECK(last_sync_attempt IS NULL OR last_sync_attempt > 0),
        
        -- Timestamps
        local_created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(local_created_at > 0),
        local_updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(local_updated_at >= local_created_at)
      )
    ''');

    // Create telemetry_sync_status table
    await db.execute('''
      CREATE TABLE telemetry_sync_status (
        id TEXT PRIMARY KEY CHECK(length(id) > 0),
        item_id TEXT NOT NULL CHECK(length(item_id) > 0),
        item_type TEXT NOT NULL CHECK (item_type IN ('light_reading', 'growth_photo', 'environmental_data')),
        session_id TEXT NOT NULL CHECK(length(session_id) > 0),
        
        -- Sync state management
        sync_state TEXT NOT NULL DEFAULT 'pending' CHECK (sync_state IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
        
        -- Timing fields
        last_sync_attempt INTEGER CHECK(last_sync_attempt IS NULL OR last_sync_attempt > 0),
        next_retry_at INTEGER CHECK(next_retry_at IS NULL OR next_retry_at > 0),
        
        -- Progress tracking
        retry_count INTEGER NOT NULL DEFAULT 0 CHECK(retry_count >= 0),
        max_retries INTEGER NOT NULL DEFAULT 3 CHECK(max_retries > 0),
        total_items INTEGER NOT NULL DEFAULT 1 CHECK(total_items > 0),
        synced_items INTEGER NOT NULL DEFAULT 0 CHECK(synced_items >= 0 AND synced_items <= total_items),
        failed_items INTEGER NOT NULL DEFAULT 0 CHECK(failed_items >= 0 AND failed_items <= total_items),
        
        -- Error handling
        error_message TEXT,
        error_code TEXT,
        
        -- Conflict resolution
        conflict_data TEXT CHECK(conflict_data IS NULL OR json_valid(conflict_data)),
        
        -- Timestamps
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(created_at > 0),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(updated_at >= created_at),
        
        -- Foreign key constraint
        FOREIGN KEY (item_id) REFERENCES telemetry_data (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance
    await _createIndexesV1(db);
  }

  /// Creates indexes for V1 schema
  /// Optimizes common query patterns for telemetry data
  static Future<void> _createIndexesV1(Database db) async {
    // Telemetry data indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_session_id 
      ON telemetry_data (session_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_item_type 
      ON telemetry_data (item_type);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_sync_status 
      ON telemetry_data (is_synced);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_created_at 
      ON telemetry_data (local_created_at DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_timestamp 
      ON telemetry_data (client_timestamp DESC);
    ''');

    // Sync status indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_status_item_id 
      ON telemetry_sync_status (item_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_status_state 
      ON telemetry_sync_status (sync_state);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_retry_at 
      ON telemetry_sync_status (next_retry_at) 
      WHERE next_retry_at IS NOT NULL;
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_last_attempt 
      ON telemetry_sync_status (last_sync_attempt DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_session_type 
      ON telemetry_sync_status (session_id, item_type);
    ''');
  }

  /// Validates database schema integrity
  /// Checks if all required tables and indexes exist
  static Future<bool> validateSchema(Database db) async {
    try {
      // Check if required tables exist
      final tables = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name IN ('telemetry_data', 'telemetry_sync_status')
      ''');
      
      if (tables.length != 2) {
        return false;
      }

      // Check if required indexes exist
      final indexes = await db.rawQuery('''
        SELECT name FROM sqlite_master 
        WHERE type='index' AND name LIKE 'idx_%'
      ''');
      
      // Should have at least the core indexes
      if (indexes.length < 8) {
        return false;
      }

      // Validate foreign key constraints
      final pragmaResult = await db.rawQuery('PRAGMA foreign_key_check');
      if (pragmaResult.isNotEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets current database schema version
  /// Returns the version stored in user_version pragma
  static Future<int> getCurrentVersion(Database db) async {
    final result = await db.rawQuery('PRAGMA user_version');
    return result.first['user_version'] as int;
  }

  /// Sets database schema version
  /// Updates the user_version pragma
  static Future<void> setVersion(Database db, int version) async {
    await db.execute('PRAGMA user_version = $version');
  }

  /// Performs database integrity check
  /// Validates database structure and data consistency
  static Future<Map<String, dynamic>> performIntegrityCheck(Database db) async {
    final results = <String, dynamic>{};
    
    try {
      // SQLite integrity check
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      results['integrity_check'] = integrityResult.first['integrity_check'];
      
      // Foreign key check
      final foreignKeyResult = await db.rawQuery('PRAGMA foreign_key_check');
      results['foreign_key_violations'] = foreignKeyResult.length;
      
      // Table statistics
      final telemetryCount = await db.rawQuery('SELECT COUNT(*) as count FROM telemetry_data');
      results['telemetry_data_count'] = telemetryCount.first['count'];
      
      final syncStatusCount = await db.rawQuery('SELECT COUNT(*) as count FROM telemetry_sync_status');
      results['sync_status_count'] = syncStatusCount.first['count'];
      
      // Schema validation
      results['schema_valid'] = await validateSchema(db);
      
      // Database size
      final sizeResult = await db.rawQuery('PRAGMA page_count');
      final pageSize = await db.rawQuery('PRAGMA page_size');
      results['database_size_bytes'] = 
          (sizeResult.first['page_count'] as int) * (pageSize.first['page_size'] as int);
      
      results['status'] = 'success';
    } catch (e) {
      results['status'] = 'error';
      results['error'] = e.toString();
    }
    
    return results;
  }

  /// Repairs database if possible
  /// Attempts to fix common database issues
  static Future<bool> repairDatabase(Database db) async {
    try {
      // Vacuum database to reclaim space and fix minor corruption
      await db.execute('VACUUM');
      
      // Reindex all indexes
      await db.execute('REINDEX');
      
      // Analyze tables for query optimization
      await db.execute('ANALYZE');
      
      return true;
    } catch (e) {
      return false;
    }
  }
}