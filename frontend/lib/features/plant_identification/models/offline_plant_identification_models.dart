// Offline Plant Identification Models
// This file contains data models for offline functionality including local plant identification,
// sync status, and model information

import 'package:freezed_annotation/freezed_annotation.dart';

part 'offline_plant_identification_models.freezed.dart';
part 'offline_plant_identification_models.g.dart';

/// Represents a plant identification performed and stored locally on the device
@freezed
class LocalPlantIdentification with _$LocalPlantIdentification {
  const factory LocalPlantIdentification({
    required String localId,          // Unique local identifier
    String? serverId,                // Server ID after sync (null if not synced)
    required String scientificName,  // Scientific name from local model
    required String commonName,      // Common name from local model
    required double confidence,      // Confidence score
    required String localImagePath,  // Path to locally stored image
    required DateTime identifiedAt,  // Timestamp of identification
    required SyncStatus syncStatus,  // Current synchronization status
    String? syncError,               // Error message if sync failed
    @Default({}) Map<String, dynamic> localModelData, // Additional model output data
  }) = _LocalPlantIdentification;

  factory LocalPlantIdentification.fromJson(Map<String, dynamic> json) =>
      _$LocalPlantIdentificationFromJson(json);
}

/// Information about an on-device AI model
@freezed
class ModelInfo with _$ModelInfo {
  const factory ModelInfo({
    required String modelId,          // Unique identifier for the model
    required String version,          // Version string
    required DateTime downloadedAt,   // When the model was downloaded
    required int sizeInBytes,         // Size of model on disk
    @Default([]) List<String> capabilities, // What the model can identify
    @Default({}) Map<String, dynamic> metadata, // Additional model metadata
  }) = _ModelInfo;

  factory ModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ModelInfoFromJson(json);
}

/// Represents the synchronization status of a local identification
@freezed
class SyncStatus with _$SyncStatus {
  const SyncStatus._();
  
  /// The identification has been successfully synced with the server
  const factory SyncStatus.synced() = _Synced;
  
  /// The identification has not been synced yet
  const factory SyncStatus.notSynced() = _NotSynced;
  
  /// The identification is currently being synced
  const factory SyncStatus.syncing() = _Syncing;
  
  /// Synchronization failed with an error
  const factory SyncStatus.failed(String error) = _Failed;

  factory SyncStatus.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusFromJson(json);
}

/// Represents the current connectivity status
@freezed
class ConnectivityStatus with _$ConnectivityStatus {
  const ConnectivityStatus._();
  
  /// No internet connection available
  const factory ConnectivityStatus.offline() = _Offline;
  
  /// Connected via mobile data
  const factory ConnectivityStatus.mobile() = _Mobile;
  
  /// Connected via WiFi
  const factory ConnectivityStatus.wifi() = _Wifi;

  factory ConnectivityStatus.fromJson(Map<String, dynamic> json) =>
      _$ConnectivityStatusFromJson(json);
}

/// State for the enhanced plant identification provider
@freezed
class OfflinePlantIdentificationState with _$OfflinePlantIdentificationState {
  const factory OfflinePlantIdentificationState({
    @Default(false) bool isLoading,
    @Default([]) List<LocalPlantIdentification> localIdentifications,
    @Default(null) ModelInfo? currentModel,
    @Default(null) ConnectivityStatus? connectivityStatus,
    String? error,
  }) = _OfflinePlantIdentificationState;

  factory OfflinePlantIdentificationState.fromJson(Map<String, dynamic> json) =>
      _$OfflinePlantIdentificationStateFromJson(json);
}