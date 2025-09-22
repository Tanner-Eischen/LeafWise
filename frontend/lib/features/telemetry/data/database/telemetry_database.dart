/// SQLite database setup for telemetry data persistence
/// Handles local storage of telemetry data and sync status with offline support
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'migrations/telemetry_migrations.dart';

/// Database configuration constants
class TelemetryDatabaseConfig {
  static const String databaseName = 'telemetry.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String telemetryDataTable = 'telemetry_data';
  static const String telemetrySyncStatusTable = 'telemetry_sync_status';
}

/// Main database class for telemetry data management
/// Provides SQLite database operations with proper schema and migrations
class TelemetryDatabase {
  static TelemetryDatabase? _instance;
  static Database? _database;

  TelemetryDatabase._internal();

  /// Singleton instance getter
  static TelemetryDatabase get instance {
    _instance ??= TelemetryDatabase._internal();
    return _instance!;
  }

  /// Get database instance, initializing if necessary
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database with proper configuration
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, TelemetryDatabaseConfig.databaseName);
    
    return await openDatabase(
      path,
      version: TelemetryMigrations.currentVersion,
      onCreate: _onCreate,
      onUpgrade: TelemetryMigrations.migrate,
      onDowngrade: _onDowngrade,
      onOpen: _onOpen,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings before opening
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Set WAL mode for better concurrency
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Set synchronous mode for better performance
    await db.execute('PRAGMA synchronous = NORMAL');
  }

  /// Called when database is created for the first time
  /// Uses migration system to set up initial schema
  Future<void> _onCreate(Database db, int version) async {
    await TelemetryMigrations.migrate(db, 0, version);
  }

  /// Called when database is opened
  /// Enables foreign key constraints and performs integrity checks
  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Perform integrity check on database open
    final integrityCheck = await TelemetryMigrations.performIntegrityCheck(db);
    if (integrityCheck['status'] != 'success') {
      // Log integrity issues but don't fail
      print('Database integrity issues detected: ${integrityCheck['error']}');
    }
  }

  /// Called when database version is downgraded
  /// Handles backward compatibility or prevents downgrade
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // For now, prevent downgrades to avoid data loss
    throw Exception('Database downgrade from version $oldVersion to $newVersion is not supported');
  }

  /// Create the telemetry_data table
  Future<void> _createTelemetryDataTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${TelemetryDatabaseConfig.telemetryDataTable} (
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
  }

  /// Create the telemetry_sync_status table
  Future<void> _createTelemetrySyncStatusTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (
        id TEXT PRIMARY KEY CHECK(length(id) > 0),
        item_id TEXT NOT NULL CHECK(length(item_id) > 0),
        item_type TEXT NOT NULL CHECK (item_type IN ('light_reading', 'growth_photo', 'environmental_data')),
        session_id TEXT NOT NULL CHECK(length(session_id) > 0),
        
        -- Sync state management
        sync_status TEXT NOT NULL CHECK (sync_status IN ('pending', 'syncing', 'synced', 'failed', 'conflict', 'retry', 'cancelled', 'partial')) DEFAULT 'pending',
        
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
        sync_error TEXT,
        error_code TEXT,
        
        -- Conflict resolution
        conflict_data TEXT CHECK(conflict_data IS NULL OR json_valid(conflict_data)),
        
        -- Timestamps
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(created_at > 0),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000) CHECK(updated_at >= created_at),
        
        -- Foreign key constraint
        FOREIGN KEY (item_id) REFERENCES ${TelemetryDatabaseConfig.telemetryDataTable}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Creates database indexes for optimal query performance
  /// Indexes are created on frequently queried columns
  Future<void> _createIndexes(Database db) async {
    // Telemetry data indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_device_timestamp 
      ON ${TelemetryDatabaseConfig.telemetryDataTable} (device_id, timestamp DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_sensor_type 
      ON ${TelemetryDatabaseConfig.telemetryDataTable} (sensor_type);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_timestamp 
      ON ${TelemetryDatabaseConfig.telemetryDataTable} (timestamp DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_created_at 
      ON ${TelemetryDatabaseConfig.telemetryDataTable} (created_at DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_telemetry_location 
      ON ${TelemetryDatabaseConfig.telemetryDataTable} (latitude, longitude) 
      WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
    ''');

    // Sync status indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_status_item_id 
      ON ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (item_id);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_status_state 
      ON ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (sync_state);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_retry_at 
      ON ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (next_retry_at) 
      WHERE next_retry_at IS NOT NULL;
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_last_attempt 
      ON ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (last_sync_attempt DESC);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_session_type 
      ON ${TelemetryDatabaseConfig.telemetrySyncStatusTable} (session_id, item_type);
    ''');
  }

  /// Close the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete the database file (for testing or reset purposes)
  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, TelemetryDatabaseConfig.databaseName);
    
    if (await File(path).exists()) {
      await File(path).delete();
    }
    
    _database = null;
  }

  /// Get database file size in bytes
  Future<int> getDatabaseSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, TelemetryDatabaseConfig.databaseName);
    
    if (await File(path).exists()) {
      return await File(path).length();
    }
    
    return 0;
  }

  /// Vacuum the database to reclaim space
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final telemetryDataCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetryDataTable}')
    ) ?? 0;
    
    final syncStatusCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetrySyncStatusTable}')
    ) ?? 0;
    
    final unsyncedCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TelemetryDatabaseConfig.telemetryDataTable} WHERE is_synced = 0')
    ) ?? 0;
    
    final databaseSize = await getDatabaseSize();
    
    return {
      'telemetry_data_count': telemetryDataCount,
      'sync_status_count': syncStatusCount,
      'unsynced_count': unsyncedCount,
      'database_size_bytes': databaseSize,
      'database_version': TelemetryDatabaseConfig.databaseVersion,
    };
  }
}