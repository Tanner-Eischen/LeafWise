// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_plant_identification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalPlantIdentificationImpl _$$LocalPlantIdentificationImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalPlantIdentificationImpl(
      localId: json['localId'] as String,
      serverId: json['serverId'] as String?,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      localImagePath: json['localImagePath'] as String,
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
      syncStatus:
          SyncStatus.fromJson(json['syncStatus'] as Map<String, dynamic>),
      syncError: json['syncError'] as String?,
      localModelData:
          json['localModelData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$LocalPlantIdentificationImplToJson(
        _$LocalPlantIdentificationImpl instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'serverId': instance.serverId,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'confidence': instance.confidence,
      'localImagePath': instance.localImagePath,
      'identifiedAt': instance.identifiedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'syncError': instance.syncError,
      'localModelData': instance.localModelData,
    };

_$ModelInfoImpl _$$ModelInfoImplFromJson(Map<String, dynamic> json) =>
    _$ModelInfoImpl(
      modelId: json['modelId'] as String,
      version: json['version'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ModelInfoImplToJson(_$ModelInfoImpl instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'version': instance.version,
      'downloadedAt': instance.downloadedAt.toIso8601String(),
      'sizeInBytes': instance.sizeInBytes,
      'capabilities': instance.capabilities,
      'metadata': instance.metadata,
    };

_$SyncedImpl _$$SyncedImplFromJson(Map<String, dynamic> json) => _$SyncedImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SyncedImplToJson(_$SyncedImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$NotSyncedImpl _$$NotSyncedImplFromJson(Map<String, dynamic> json) =>
    _$NotSyncedImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$NotSyncedImplToJson(_$NotSyncedImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$SyncingImpl _$$SyncingImplFromJson(Map<String, dynamic> json) =>
    _$SyncingImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SyncingImplToJson(_$SyncingImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$FailedImpl _$$FailedImplFromJson(Map<String, dynamic> json) => _$FailedImpl(
      json['error'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FailedImplToJson(_$FailedImpl instance) =>
    <String, dynamic>{
      'error': instance.error,
      'runtimeType': instance.$type,
    };

_$OfflineImpl _$$OfflineImplFromJson(Map<String, dynamic> json) =>
    _$OfflineImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$OfflineImplToJson(_$OfflineImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$MobileImpl _$$MobileImplFromJson(Map<String, dynamic> json) => _$MobileImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$MobileImplToJson(_$MobileImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$WifiImpl _$$WifiImplFromJson(Map<String, dynamic> json) => _$WifiImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WifiImplToJson(_$WifiImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$OfflinePlantIdentificationStateImpl
    _$$OfflinePlantIdentificationStateImplFromJson(Map<String, dynamic> json) =>
        _$OfflinePlantIdentificationStateImpl(
          isLoading: json['isLoading'] as bool? ?? false,
          localIdentifications: (json['localIdentifications'] as List<dynamic>?)
                  ?.map((e) => LocalPlantIdentification.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              const [],
          currentModel: json['currentModel'] == null
              ? null
              : ModelInfo.fromJson(
                  json['currentModel'] as Map<String, dynamic>),
          connectivityStatus: json['connectivityStatus'] == null
              ? null
              : ConnectivityStatus.fromJson(
                  json['connectivityStatus'] as Map<String, dynamic>),
          error: json['error'] as String?,
        );

Map<String, dynamic> _$$OfflinePlantIdentificationStateImplToJson(
        _$OfflinePlantIdentificationStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'localIdentifications': instance.localIdentifications,
      'currentModel': instance.currentModel,
      'connectivityStatus': instance.connectivityStatus,
      'error': instance.error,
    };
