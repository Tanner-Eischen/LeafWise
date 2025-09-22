/// Data models for telemetry data and sync status
/// Provides structured data classes with serialization and validation
library;

import 'dart:convert';

/// Telemetry data model representing sensor readings and measurements
/// Used for storing and transferring telemetry information
class TelemetryDataModel {
  final int? id;
  final String deviceId;
  final String sensorType;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TelemetryDataModel({
    this.id,
    required this.deviceId,
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a new instance with updated values
  TelemetryDataModel copyWith({
    int? id,
    String? deviceId,
    String? sensorType,
    double? value,
    String? unit,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TelemetryDataModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates instance from database map
  factory TelemetryDataModel.fromMap(Map<String, dynamic> map) {
    return TelemetryDataModel(
      id: map['id']?.toInt(),
      deviceId: map['device_id'] ?? '',
      sensorType: map['sensor_type'] ?? '',
      value: map['value']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(map['metadata']))
          : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      accuracy: map['accuracy']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  /// Converts instance to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'sensor_type': sensorType,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates instance from JSON string
  factory TelemetryDataModel.fromJson(String source) {
    return TelemetryDataModel.fromMap(jsonDecode(source));
  }

  /// Converts instance to JSON string
  String toJson() => jsonEncode(toMap());

  /// Validates the telemetry data
  bool isValid() {
    return deviceId.isNotEmpty &&
           sensorType.isNotEmpty &&
           unit.isNotEmpty &&
           value.isFinite &&
           timestamp.isBefore(DateTime.now().add(const Duration(minutes: 5)));
  }

  /// Gets a human-readable description
  String get description {
    return '$sensorType: $value $unit from $deviceId';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TelemetryDataModel &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.sensorType == sensorType &&
        other.value == value &&
        other.unit == unit &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        sensorType.hashCode ^
        value.hashCode ^
        unit.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'TelemetryDataModel(id: $id, deviceId: $deviceId, sensorType: $sensorType, value: $value, unit: $unit, timestamp: $timestamp)';
  }
}

/// Sync status model for tracking data synchronization
/// Manages the state of data synchronization with remote servers
class TelemetrySyncStatusModel {
  final int? id;
  final int telemetryDataId;
  final SyncStatus status;
  final DateTime lastSyncAttempt;
  final DateTime? lastSuccessfulSync;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TelemetrySyncStatusModel({
    this.id,
    required this.telemetryDataId,
    required this.status,
    required this.lastSyncAttempt,
    this.lastSuccessfulSync,
    required this.retryCount,
    this.errorMessage,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a new instance with updated values
  TelemetrySyncStatusModel copyWith({
    int? id,
    int? telemetryDataId,
    SyncStatus? status,
    DateTime? lastSyncAttempt,
    DateTime? lastSuccessfulSync,
    int? retryCount,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TelemetrySyncStatusModel(
      id: id ?? this.id,
      telemetryDataId: telemetryDataId ?? this.telemetryDataId,
      status: status ?? this.status,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates instance from database map
  factory TelemetrySyncStatusModel.fromMap(Map<String, dynamic> map) {
    return TelemetrySyncStatusModel(
      id: map['id']?.toInt(),
      telemetryDataId: map['telemetry_data_id']?.toInt() ?? 0,
      status: SyncStatus.fromString(map['status'] ?? 'pending'),
      lastSyncAttempt: DateTime.fromMillisecondsSinceEpoch(map['last_sync_attempt']),
      lastSuccessfulSync: map['last_successful_sync'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_successful_sync'])
          : null,
      retryCount: map['retry_count']?.toInt() ?? 0,
      errorMessage: map['error_message'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  /// Converts instance to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'telemetry_data_id': telemetryDataId,
      'status': status.value,
      'last_sync_attempt': lastSyncAttempt.millisecondsSinceEpoch,
      'last_successful_sync': lastSuccessfulSync?.millisecondsSinceEpoch,
      'retry_count': retryCount,
      'error_message': errorMessage,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates instance from JSON string
  factory TelemetrySyncStatusModel.fromJson(String source) {
    return TelemetrySyncStatusModel.fromMap(jsonDecode(source));
  }

  /// Converts instance to JSON string
  String toJson() => jsonEncode(toMap());

  /// Checks if sync should be retried
  bool shouldRetry({int maxRetries = 3}) {
    return status == SyncStatus.failed && retryCount < maxRetries;
  }

  /// Checks if sync is overdue
  bool isOverdue({Duration threshold = const Duration(hours: 1)}) {
    return status == SyncStatus.pending && 
           DateTime.now().difference(lastSyncAttempt) > threshold;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TelemetrySyncStatusModel &&
        other.id == id &&
        other.telemetryDataId == telemetryDataId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ telemetryDataId.hashCode ^ status.hashCode;
  }

  @override
  String toString() {
    return 'TelemetrySyncStatusModel(id: $id, telemetryDataId: $telemetryDataId, status: $status, retryCount: $retryCount)';
  }
}

/// Enumeration for sync status values
/// Represents the current state of data synchronization
enum SyncStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed');

  const SyncStatus(this.value);
  
  final String value;

  /// Creates SyncStatus from string value
  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SyncStatus.pending,
    );
  }

  /// Gets display name for UI
  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.inProgress:
        return 'In Progress';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
    }
  }

  /// Gets color indicator for UI
  String get colorIndicator {
    switch (this) {
      case SyncStatus.pending:
        return 'orange';
      case SyncStatus.inProgress:
        return 'blue';
      case SyncStatus.completed:
        return 'green';
      case SyncStatus.failed:
        return 'red';
    }
  }
}