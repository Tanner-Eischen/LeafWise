/// Providers for telemetry database services
/// Provides dependency injection for database and repository instances
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/telemetry_database.dart';
import '../repositories/telemetry_data_repository.dart';

/// Provider for the telemetry database singleton
/// Manages the SQLite database instance for telemetry data
final telemetryDatabaseProvider = Provider<TelemetryDatabase>((ref) {
  return TelemetryDatabase.instance;
});

/// Provider for the telemetry data repository
/// Handles CRUD operations for telemetry data and sync status
final telemetryDataRepositoryProvider = Provider<TelemetryDataRepository>((ref) {
  return TelemetryDataRepository();
});

/// Provider for database initialization state
/// Tracks whether the database has been properly initialized
final databaseInitializationProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(telemetryDatabaseProvider);
  
  try {
    // Initialize database by getting the instance
    await database.database;
    return true;
  } catch (e) {
    // Log error in production
    return false;
  }
});

/// Provider for database statistics
/// Provides real-time statistics about the database state
final databaseStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(telemetryDatabaseProvider);
  return await database.getStatistics();
});

/// Provider for repository statistics
/// Provides detailed statistics about telemetry data and sync status
final repositoryStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(telemetryDataRepositoryProvider);
  return await repository.getRepositoryStatistics();
});

/// State provider for database operations
/// Tracks loading states and errors for database operations
final databaseOperationStateProvider = StateProvider<DatabaseOperationState>((ref) {
  return const DatabaseOperationState.idle();
});

/// Database operation state management
/// Represents the current state of database operations
class DatabaseOperationState {
  final bool isLoading;
  final String? error;
  final String? message;
  final String? operation;

  const DatabaseOperationState({
    required this.isLoading,
    this.error,
    this.message,
    this.operation,
  });

  const DatabaseOperationState.idle() : this(isLoading: false);
  
  const DatabaseOperationState.loading(String operation) 
      : this(isLoading: true, operation: operation);
  
  const DatabaseOperationState.error(String error, {String? operation}) 
      : this(isLoading: false, error: error, operation: operation);
  
  const DatabaseOperationState.success(String message, {String? operation}) 
      : this(isLoading: false, message: message, operation: operation);

  DatabaseOperationState copyWith({
    bool? isLoading,
    String? error,
    String? message,
    String? operation,
  }) {
    return DatabaseOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      message: message ?? this.message,
      operation: operation ?? this.operation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DatabaseOperationState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.message == message &&
        other.operation == operation;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        error.hashCode ^
        message.hashCode ^
        operation.hashCode;
  }

  @override
  String toString() {
    return 'DatabaseOperationState(isLoading: $isLoading, error: $error, message: $message, operation: $operation)';
  }
}