/// Core telemetry data models for the LeafWise application.
/// 
/// This file contains freezed data models for handling telemetry data including
/// light readings, growth photos, and batch operations with offline sync support.
/// All models follow the established patterns in the codebase for consistency.
library telemetry_data_models;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_data_models.freezed.dart';
part 'telemetry_data_models.g.dart';

/// Enumeration for light measurement sources
enum LightSource {
  @JsonValue('CAMERA')
  camera,
  @JsonValue('ALS')
  als,
  @JsonValue('BLE')
  ble,
  @JsonValue('MANUAL')
  manual,
}

/// Enumeration for sync status tracking
enum SyncStatus {
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
}

/// Core light reading data model
@freezed
class LightReadingData with _$LightReadingData {
  const factory LightReadingData({
    String? id,
    String? userId,
    String? plantId,
    required double luxValue,
    double? ppfdValue,
    required LightSource source,
    String? locationName,
    double? gpsLatitude,
    double? gpsLongitude,
    double? altitude,
    double? temperature,
    double? humidity,
    String? calibrationProfileId,
    String? deviceId,
    String? bleDeviceId,
    Map<String, dynamic>? rawData,
    required DateTime measuredAt,
    
    // Telemetry fields for offline sync
    String? growthPhotoId,
    String? telemetrySessionId,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    @Default(false) bool offlineCreated,
    Map<String, dynamic>? conflictResolutionData,
    DateTime? clientTimestamp,
    
    // Metadata
    String? processingNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LightReadingData;

  factory LightReadingData.fromJson(Map<String, dynamic> json) =>
      _$LightReadingDataFromJson(json);
}

/// Growth metrics extracted from photos
@freezed
class GrowthMetrics with _$GrowthMetrics {
  const factory GrowthMetrics({
    double? leafAreaCm2,
    double? plantHeightCm,
    int? leafCount,
    double? stemWidthMm,
    double? healthScore,
    double? chlorophyllIndex,
    @Default([]) List<String> diseaseIndicators,
  }) = _GrowthMetrics;

  factory GrowthMetrics.fromJson(Map<String, dynamic> json) =>
      _$GrowthMetricsFromJson(json);
}

/// Growth photo data model
@freezed
class GrowthPhotoData with _$GrowthPhotoData {
  const factory GrowthPhotoData({
    String? id,
    String? userId,
    String? plantId,
    required String filePath,
    int? fileSize,
    int? imageWidth,
    int? imageHeight,
    GrowthMetrics? metrics,
    String? processingVersion,
    Map<String, double>? confidenceScores,
    int? analysisDurationMs,
    String? locationName,
    double? ambientLightLux,
    String? notes,
    @Default(false) bool isProcessed,
    String? processingError,
    String? growthRateIndicator,
    required DateTime capturedAt,
    DateTime? processedAt,
    
    // Telemetry fields for offline sync
    String? telemetrySessionId,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    @Default(false) bool offlineCreated,
    Map<String, dynamic>? conflictResolutionData,
    DateTime? clientTimestamp,
    
    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _GrowthPhotoData;

  factory GrowthPhotoData.fromJson(Map<String, dynamic> json) =>
      _$GrowthPhotoDataFromJson(json);
}

/// Batch telemetry request for offline sync
@freezed
class TelemetryBatchData with _$TelemetryBatchData {
  const factory TelemetryBatchData({
    required String sessionId,
    @Default([]) List<LightReadingData> lightReadings,
    @Default([]) List<GrowthPhotoData> growthPhotos,
    Map<String, dynamic>? batchMetadata,
    required DateTime clientTimestamp,
    @Default(false) bool offlineMode,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    DateTime? lastSyncAttempt,
    DateTime? nextRetryAt,
    int? retryCount,
    String? syncError,
  }) = _TelemetryBatchData;

  factory TelemetryBatchData.fromJson(Map<String, dynamic> json) =>
      _$TelemetryBatchDataFromJson(json);
}

/// Telemetry sync status tracking
@freezed
class TelemetrySyncStatus with _$TelemetrySyncStatus {
  const factory TelemetrySyncStatus({
    required String itemId,
    required String itemType,
    String? sessionId,
    required SyncStatus syncStatus,
    DateTime? lastSyncAttempt,
    DateTime? nextRetryAt,
    @Default(0) int retryCount,
    @Default(3) int maxRetries,
    String? syncError,
    Map<String, dynamic>? conflictData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TelemetrySyncStatus;

  factory TelemetrySyncStatus.fromJson(Map<String, dynamic> json) =>
      _$TelemetrySyncStatusFromJson(json);
}

/// Comprehensive telemetry data container
@freezed
class TelemetryData with _$TelemetryData {
  const factory TelemetryData({
    String? id,
    required String userId,
    String? plantId,
    
    // Light reading data
    LightReadingData? lightReading,                                                                                                                
    GrowthPhotoData? growthPhoto,
    
    // Batch data
    TelemetryBatchData? batchData,
    
    // Sync tracking
    TelemetrySyncStatus? syncStatus,
    
    // Session and metadata
    String? sessionId,
    required bool offlineCreated,
    required DateTime clientTimestamp,
    DateTime? serverTimestamp,
    Map<String, dynamic>? metadata,
    
    // Timestamps
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TelemetryData;

  factory TelemetryData.fromJson(Map<String, dynamic> json) =>
      _$TelemetryDataFromJson(json);
}

/// Extension methods for TelemetryData with factory methods and utilities
extension TelemetryDataExtensions on TelemetryData {
  /// Create TelemetryData from backend light reading response
  static TelemetryData fromBackendLightReading(Map<String, dynamic> json) {
    final lightReading = LightReadingData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      plantId: json['plant_id']?.toString(),
      luxValue: (json['lux_value'] as num).toDouble(),
      ppfdValue: json['ppfd_value'] != null ? (json['ppfd_value'] as num).toDouble() : null,
      source: _parseLightSource(json['source']),
      locationName: json['location_name']?.toString(),
      gpsLatitude: json['gps_latitude'] != null ? (json['gps_latitude'] as num).toDouble() : null,
      gpsLongitude: json['gps_longitude'] != null ? (json['gps_longitude'] as num).toDouble() : null,
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      calibrationProfileId: json['calibration_profile_id']?.toString(),
      deviceId: json['device_id']?.toString(),
      bleDeviceId: json['ble_device_id']?.toString(),
      rawData: json['raw_data'] as Map<String, dynamic>?,
      measuredAt: DateTime.parse(json['measured_at']),
      growthPhotoId: json['growth_photo_id']?.toString(),
      telemetrySessionId: json['telemetry_session_id']?.toString(),
      syncStatus: _parseSyncStatus(json['sync_status']),
      offlineCreated: json['offline_created'] ?? false,
      conflictResolutionData: json['conflict_resolution_data'] as Map<String, dynamic>?,
      clientTimestamp: json['client_timestamp'] != null ? DateTime.parse(json['client_timestamp']) : null,
      processingNotes: json['processing_notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );

    return TelemetryData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      plantId: json['plant_id']?.toString(),
      lightReading: lightReading,
      sessionId: json['telemetry_session_id']?.toString(),
      offlineCreated: json['offline_created'] ?? false,
      clientTimestamp: json['client_timestamp'] != null ? DateTime.parse(json['client_timestamp']) : DateTime.now(),
      serverTimestamp: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Create TelemetryData from backend growth photo response
  static TelemetryData fromBackendGrowthPhoto(Map<String, dynamic> json) {
    final metrics = json['metrics'] != null ? GrowthMetrics(
      leafAreaCm2: json['metrics']['leaf_area_cm2'] != null ? (json['metrics']['leaf_area_cm2'] as num).toDouble() : null,
      plantHeightCm: json['metrics']['plant_height_cm'] != null ? (json['metrics']['plant_height_cm'] as num).toDouble() : null,
      leafCount: json['metrics']['leaf_count'] as int?,
      stemWidthMm: json['metrics']['stem_width_mm'] != null ? (json['metrics']['stem_width_mm'] as num).toDouble() : null,
      healthScore: json['metrics']['health_score'] != null ? (json['metrics']['health_score'] as num).toDouble() : null,
      chlorophyllIndex: json['metrics']['chlorophyll_index'] != null ? (json['metrics']['chlorophyll_index'] as num).toDouble() : null,
      diseaseIndicators: json['metrics']['disease_indicators'] != null 
          ? List<String>.from(json['metrics']['disease_indicators']) 
          : [],
    ) : null;

    final growthPhoto = GrowthPhotoData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      plantId: json['plant_id']?.toString(),
      filePath: json['file_path'],
      fileSize: json['file_size'] as int?,
      imageWidth: json['image_width'] as int?,
      imageHeight: json['image_height'] as int?,
      metrics: metrics,
      processingVersion: json['processing_version']?.toString(),
      confidenceScores: json['confidence_scores'] != null 
          ? Map<String, double>.from(json['confidence_scores'].map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      analysisDurationMs: json['analysis_duration_ms'] as int?,
      locationName: json['location_name']?.toString(),
      ambientLightLux: json['ambient_light_lux'] != null ? (json['ambient_light_lux'] as num).toDouble() : null,
      notes: json['notes']?.toString(),
      isProcessed: json['is_processed'] ?? false,
      processingError: json['processing_error']?.toString(),
      growthRateIndicator: json['growth_rate_indicator']?.toString(),
      capturedAt: DateTime.parse(json['captured_at']),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
      telemetrySessionId: json['telemetry_session_id']?.toString(),
      syncStatus: _parseSyncStatus(json['sync_status']),
      offlineCreated: json['offline_created'] ?? false,
      conflictResolutionData: json['conflict_resolution_data'] as Map<String, dynamic>?,
      clientTimestamp: json['client_timestamp'] != null ? DateTime.parse(json['client_timestamp']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );

    return TelemetryData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      plantId: json['plant_id']?.toString(),
      growthPhoto: growthPhoto,
      sessionId: json['telemetry_session_id']?.toString(),
      offlineCreated: json['offline_created'] ?? false,
      clientTimestamp: json['client_timestamp'] != null ? DateTime.parse(json['client_timestamp']) : DateTime.now(),
      serverTimestamp: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Create TelemetryData for a new light reading
  static TelemetryData createLightReading({
    required String userId,
    String? plantId,
    required double luxValue,
    double? ppfdValue,
    required LightSource source,
    String? locationName,
    double? gpsLatitude,
    double? gpsLongitude,
    double? altitude,
    double? temperature,
    double? humidity,
    String? calibrationProfileId,
    String? deviceId,
    String? bleDeviceId,
    Map<String, dynamic>? rawData,
    DateTime? measuredAt,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final lightReading = LightReadingData(
      userId: userId,
      plantId: plantId,
      luxValue: luxValue,
      ppfdValue: ppfdValue,
      source: source,
      locationName: locationName,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      altitude: altitude,
      temperature: temperature,
      humidity: humidity,
      calibrationProfileId: calibrationProfileId,
      deviceId: deviceId,
      bleDeviceId: bleDeviceId,
      rawData: rawData,
      measuredAt: measuredAt ?? now,
      telemetrySessionId: sessionId,
      syncStatus: SyncStatus.pending,
      offlineCreated: true,
      clientTimestamp: now,
      createdAt: now,
    );

    return TelemetryData(
      userId: userId,
      plantId: plantId,
      lightReading: lightReading,
      sessionId: sessionId,
      offlineCreated: true,
      clientTimestamp: now,
      metadata: metadata,
      createdAt: now,
    );
  }

  /// Create TelemetryData for a new growth photo
  static TelemetryData createGrowthPhoto({
    required String userId,
    String? plantId,
    required String filePath,
    int? fileSize,
    int? imageWidth,
    int? imageHeight,
    String? locationName,
    double? ambientLightLux,
    String? notes,
    DateTime? capturedAt,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final growthPhoto = GrowthPhotoData(
      userId: userId,
      plantId: plantId,
      filePath: filePath,
      fileSize: fileSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      locationName: locationName,
      ambientLightLux: ambientLightLux,
      notes: notes,
      isProcessed: false,
      capturedAt: capturedAt ?? now,
      telemetrySessionId: sessionId,
      syncStatus: SyncStatus.pending,
      offlineCreated: true,
      clientTimestamp: now,
      createdAt: now,
    );

    return TelemetryData(
      userId: userId,
      plantId: plantId,
      growthPhoto: growthPhoto,
      sessionId: sessionId,
      offlineCreated: true,
      clientTimestamp: now,
      metadata: metadata,
      createdAt: now,
    );
  }

  /// Convert light reading to backend API format
  Map<String, dynamic> toLightReadingApiFormat() {
    if (lightReading == null) {
      throw StateError('No light reading data available');
    }

    return {
      'plant_id': plantId,
      'lux_value': lightReading!.luxValue,
      'ppfd_value': lightReading!.ppfdValue,
      'source': lightReading!.source.name.toUpperCase(),
      'location_name': lightReading!.locationName,
      'temperature': lightReading!.temperature,
      'humidity': lightReading!.humidity,
      'measured_at': lightReading!.measuredAt.toIso8601String(),
      'telemetry_session_id': sessionId,
      'client_timestamp': clientTimestamp?.toIso8601String(),
    };
  }

  /// Convert growth photo to backend API format
  Map<String, dynamic> toGrowthPhotoApiFormat() {
    if (growthPhoto == null) {
      throw StateError('No growth photo data available');
    }

    return {
      'plant_id': plantId,
      'file_path': growthPhoto!.filePath,
      'file_size': growthPhoto!.fileSize,
      'image_width': growthPhoto!.imageWidth,
      'image_height': growthPhoto!.imageHeight,
      'location_name': growthPhoto!.locationName,
      'ambient_light_lux': growthPhoto!.ambientLightLux,
      'notes': growthPhoto!.notes,
      'captured_at': growthPhoto!.capturedAt.toIso8601String(),
      'telemetry_session_id': sessionId,
      'client_timestamp': clientTimestamp?.toIso8601String(),
    };
  }

  /// Check if this telemetry data needs to be synced
  bool get needsSync {
    return (lightReading?.syncStatus == SyncStatus.pending ||
            lightReading?.syncStatus == SyncStatus.failed) ||
        (growthPhoto?.syncStatus == SyncStatus.pending ||
            growthPhoto?.syncStatus == SyncStatus.failed);
  }

  /// Check if this data was created offline
  bool get isOfflineData => offlineCreated;

  /// Get the item type based on the data content
  String get itemType {
    if (lightReading != null) {
      return 'light_reading';
    } else if (growthPhoto != null) {
      return 'growth_photo';
    } else if (batchData != null) {
      return 'batch';
    } else {
      return 'unknown';
    }
  }
}

/// Helper functions for parsing backend data
LightSource _parseLightSource(dynamic source) {
  if (source == null) return LightSource.manual;
  
  switch (source.toString().toUpperCase()) {
    case 'CAMERA':
      return LightSource.camera;
    case 'ALS':
      return LightSource.als;
    case 'BLE':
      return LightSource.ble;
    case 'MANUAL':
    default:
      return LightSource.manual;
  }
}

SyncStatus _parseSyncStatus(dynamic status) {
  if (status == null) return SyncStatus.pending;
  
  switch (status.toString().toLowerCase()) {
    case 'in_progress':
      return SyncStatus.inProgress;
    case 'synced':
      return SyncStatus.synced;
    case 'failed':
      return SyncStatus.failed;
    case 'conflict':
      return SyncStatus.conflict;
    case 'cancelled':
      return SyncStatus.cancelled;
    case 'pending':
    default:
      return SyncStatus.pending;
  }
}