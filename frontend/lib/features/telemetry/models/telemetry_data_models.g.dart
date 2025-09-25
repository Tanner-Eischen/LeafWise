// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LightReadingDataImpl _$$LightReadingDataImplFromJson(
        Map<String, dynamic> json) =>
    _$LightReadingDataImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      plantId: json['plantId'] as String?,
      luxValue: (json['luxValue'] as num).toDouble(),
      ppfdValue: (json['ppfdValue'] as num?)?.toDouble(),
      source: $enumDecode(_$LightSourceEnumMap, json['source']),
      locationName: json['locationName'] as String?,
      gpsLatitude: (json['gpsLatitude'] as num?)?.toDouble(),
      gpsLongitude: (json['gpsLongitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      calibrationProfileId: json['calibrationProfileId'] as String?,
      deviceId: json['deviceId'] as String?,
      bleDeviceId: json['bleDeviceId'] as String?,
      rawData: json['rawData'] as Map<String, dynamic>?,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      growthPhotoId: json['growthPhotoId'] as String?,
      telemetrySessionId: json['telemetrySessionId'] as String?,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      offlineCreated: json['offlineCreated'] as bool? ?? false,
      conflictResolutionData:
          json['conflictResolutionData'] as Map<String, dynamic>?,
      clientTimestamp: json['clientTimestamp'] == null
          ? null
          : DateTime.parse(json['clientTimestamp'] as String),
      processingNotes: json['processingNotes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LightReadingDataImplToJson(
        _$LightReadingDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plantId': instance.plantId,
      'luxValue': instance.luxValue,
      'ppfdValue': instance.ppfdValue,
      'source': _$LightSourceEnumMap[instance.source]!,
      'locationName': instance.locationName,
      'gpsLatitude': instance.gpsLatitude,
      'gpsLongitude': instance.gpsLongitude,
      'altitude': instance.altitude,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'calibrationProfileId': instance.calibrationProfileId,
      'deviceId': instance.deviceId,
      'bleDeviceId': instance.bleDeviceId,
      'rawData': instance.rawData,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'growthPhotoId': instance.growthPhotoId,
      'telemetrySessionId': instance.telemetrySessionId,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'offlineCreated': instance.offlineCreated,
      'conflictResolutionData': instance.conflictResolutionData,
      'clientTimestamp': instance.clientTimestamp?.toIso8601String(),
      'processingNotes': instance.processingNotes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$LightSourceEnumMap = {
  LightSource.camera: 'CAMERA',
  LightSource.als: 'ALS',
  LightSource.ble: 'BLE',
  LightSource.manual: 'MANUAL',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.inProgress: 'in_progress',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
  SyncStatus.cancelled: 'cancelled',
};

_$GrowthMetricsImpl _$$GrowthMetricsImplFromJson(Map<String, dynamic> json) =>
    _$GrowthMetricsImpl(
      leafAreaCm2: (json['leafAreaCm2'] as num?)?.toDouble(),
      plantHeightCm: (json['plantHeightCm'] as num?)?.toDouble(),
      leafCount: (json['leafCount'] as num?)?.toInt(),
      stemWidthMm: (json['stemWidthMm'] as num?)?.toDouble(),
      healthScore: (json['healthScore'] as num?)?.toDouble(),
      chlorophyllIndex: (json['chlorophyllIndex'] as num?)?.toDouble(),
      diseaseIndicators: (json['diseaseIndicators'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      colorAnalysis: json['colorAnalysis'] as String?,
    );

Map<String, dynamic> _$$GrowthMetricsImplToJson(_$GrowthMetricsImpl instance) =>
    <String, dynamic>{
      'leafAreaCm2': instance.leafAreaCm2,
      'plantHeightCm': instance.plantHeightCm,
      'leafCount': instance.leafCount,
      'stemWidthMm': instance.stemWidthMm,
      'healthScore': instance.healthScore,
      'chlorophyllIndex': instance.chlorophyllIndex,
      'diseaseIndicators': instance.diseaseIndicators,
      'heightCm': instance.heightCm,
      'widthCm': instance.widthCm,
      'colorAnalysis': instance.colorAnalysis,
    };

_$GrowthMetricsDataImpl _$$GrowthMetricsDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GrowthMetricsDataImpl(
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      leafCount: (json['leafCount'] as num?)?.toInt(),
      healthScore: (json['healthScore'] as num?)?.toDouble(),
      colorAnalysis: json['colorAnalysis'] as String?,
      extractedAt: DateTime.parse(json['extractedAt'] as String),
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GrowthMetricsDataImplToJson(
        _$GrowthMetricsDataImpl instance) =>
    <String, dynamic>{
      'heightCm': instance.heightCm,
      'widthCm': instance.widthCm,
      'leafCount': instance.leafCount,
      'healthScore': instance.healthScore,
      'colorAnalysis': instance.colorAnalysis,
      'extractedAt': instance.extractedAt.toIso8601String(),
      'additionalMetrics': instance.additionalMetrics,
    };

_$GrowthPhotoDataImpl _$$GrowthPhotoDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GrowthPhotoDataImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      plantId: json['plantId'] as String?,
      filePath: json['filePath'] as String,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      imageWidth: (json['imageWidth'] as num?)?.toInt(),
      imageHeight: (json['imageHeight'] as num?)?.toInt(),
      metrics: json['metrics'] == null
          ? null
          : GrowthMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      processingVersion: json['processingVersion'] as String?,
      confidenceScores:
          (json['confidenceScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      analysisDurationMs: (json['analysisDurationMs'] as num?)?.toInt(),
      locationName: json['locationName'] as String?,
      ambientLightLux: (json['ambientLightLux'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isProcessed: json['isProcessed'] as bool? ?? false,
      processingError: json['processingError'] as String?,
      growthRateIndicator: json['growthRateIndicator'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      telemetrySessionId: json['telemetrySessionId'] as String?,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      offlineCreated: json['offlineCreated'] as bool? ?? false,
      conflictResolutionData:
          json['conflictResolutionData'] as Map<String, dynamic>?,
      clientTimestamp: json['clientTimestamp'] == null
          ? null
          : DateTime.parse(json['clientTimestamp'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GrowthPhotoDataImplToJson(
        _$GrowthPhotoDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plantId': instance.plantId,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'imageWidth': instance.imageWidth,
      'imageHeight': instance.imageHeight,
      'metrics': instance.metrics,
      'processingVersion': instance.processingVersion,
      'confidenceScores': instance.confidenceScores,
      'analysisDurationMs': instance.analysisDurationMs,
      'locationName': instance.locationName,
      'ambientLightLux': instance.ambientLightLux,
      'notes': instance.notes,
      'isProcessed': instance.isProcessed,
      'processingError': instance.processingError,
      'growthRateIndicator': instance.growthRateIndicator,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'telemetrySessionId': instance.telemetrySessionId,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'offlineCreated': instance.offlineCreated,
      'conflictResolutionData': instance.conflictResolutionData,
      'clientTimestamp': instance.clientTimestamp?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$TelemetryBatchDataImpl _$$TelemetryBatchDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TelemetryBatchDataImpl(
      sessionId: json['sessionId'] as String,
      lightReadings: (json['lightReadings'] as List<dynamic>?)
              ?.map((e) => LightReadingData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      growthPhotos: (json['growthPhotos'] as List<dynamic>?)
              ?.map((e) => GrowthPhotoData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      batchMetadata: json['batchMetadata'] as Map<String, dynamic>?,
      clientTimestamp: DateTime.parse(json['clientTimestamp'] as String),
      offlineMode: json['offlineMode'] as bool? ?? false,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt(),
      syncError: json['syncError'] as String?,
    );

Map<String, dynamic> _$$TelemetryBatchDataImplToJson(
        _$TelemetryBatchDataImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'lightReadings': instance.lightReadings,
      'growthPhotos': instance.growthPhotos,
      'batchMetadata': instance.batchMetadata,
      'clientTimestamp': instance.clientTimestamp.toIso8601String(),
      'offlineMode': instance.offlineMode,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'syncError': instance.syncError,
    };

_$TelemetrySyncStatusImpl _$$TelemetrySyncStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$TelemetrySyncStatusImpl(
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      sessionId: json['sessionId'] as String?,
      syncStatus: $enumDecode(_$SyncStatusEnumMap, json['syncStatus']),
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      syncError: json['syncError'] as String?,
      conflictData: json['conflictData'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TelemetrySyncStatusImplToJson(
        _$TelemetrySyncStatusImpl instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'itemType': instance.itemType,
      'sessionId': instance.sessionId,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'syncError': instance.syncError,
      'conflictData': instance.conflictData,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$TelemetryDataImpl _$$TelemetryDataImplFromJson(Map<String, dynamic> json) =>
    _$TelemetryDataImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      plantId: json['plantId'] as String?,
      lightReading: json['lightReading'] == null
          ? null
          : LightReadingData.fromJson(
              json['lightReading'] as Map<String, dynamic>),
      growthPhoto: json['growthPhoto'] == null
          ? null
          : GrowthPhotoData.fromJson(
              json['growthPhoto'] as Map<String, dynamic>),
      batchData: json['batchData'] == null
          ? null
          : TelemetryBatchData.fromJson(
              json['batchData'] as Map<String, dynamic>),
      syncStatus: json['syncStatus'] == null
          ? null
          : TelemetrySyncStatus.fromJson(
              json['syncStatus'] as Map<String, dynamic>),
      sessionId: json['sessionId'] as String?,
      offlineCreated: json['offlineCreated'] as bool,
      clientTimestamp: DateTime.parse(json['clientTimestamp'] as String),
      serverTimestamp: json['serverTimestamp'] == null
          ? null
          : DateTime.parse(json['serverTimestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TelemetryDataImplToJson(_$TelemetryDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plantId': instance.plantId,
      'lightReading': instance.lightReading,
      'growthPhoto': instance.growthPhoto,
      'batchData': instance.batchData,
      'syncStatus': instance.syncStatus,
      'sessionId': instance.sessionId,
      'offlineCreated': instance.offlineCreated,
      'clientTimestamp': instance.clientTimestamp.toIso8601String(),
      'serverTimestamp': instance.serverTimestamp?.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
