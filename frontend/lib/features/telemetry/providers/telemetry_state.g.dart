// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetryStateImpl _$$TelemetryStateImplFromJson(Map<String, dynamic> json) =>
    _$TelemetryStateImpl(
      isLoadingData: json['isLoadingData'] as bool? ?? false,
      isLoadingLightReadings: json['isLoadingLightReadings'] as bool? ?? false,
      isLoadingGrowthPhotos: json['isLoadingGrowthPhotos'] as bool? ?? false,
      isLoadingBatchData: json['isLoadingBatchData'] as bool? ?? false,
      isSyncing: json['isSyncing'] as bool? ?? false,
      isResolvingConflicts: json['isResolvingConflicts'] as bool? ?? false,
      isCreatingLightReading: json['isCreatingLightReading'] as bool? ?? false,
      isCreatingGrowthPhoto: json['isCreatingGrowthPhoto'] as bool? ?? false,
      isUploadingBatch: json['isUploadingBatch'] as bool? ?? false,
      telemetryData: (json['telemetryData'] as List<dynamic>?)
              ?.map((e) => TelemetryData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TelemetryData>[],
      lightReadings: (json['lightReadings'] as List<dynamic>?)
              ?.map((e) => LightReadingData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LightReadingData>[],
      growthPhotos: (json['growthPhotos'] as List<dynamic>?)
              ?.map((e) => GrowthPhotoData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GrowthPhotoData>[],
      batchData: (json['batchData'] as List<dynamic>?)
              ?.map(
                  (e) => TelemetryBatchData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TelemetryBatchData>[],
      syncStatuses: (json['syncStatuses'] as List<dynamic>?)
              ?.map((e) =>
                  TelemetrySyncStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TelemetrySyncStatus>[],
      currentSyncStatus: json['currentSyncStatus'] == null
          ? null
          : TelemetrySyncStatus.fromJson(
              json['currentSyncStatus'] as Map<String, dynamic>),
      isOfflineMode: json['isOfflineMode'] as bool? ?? false,
      pendingSyncCount: (json['pendingSyncCount'] as num?)?.toInt() ?? 0,
      failedSyncCount: (json['failedSyncCount'] as num?)?.toInt() ?? 0,
      conflictCount: (json['conflictCount'] as num?)?.toInt() ?? 0,
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      lastSuccessfulSync: json['lastSuccessfulSync'] == null
          ? null
          : DateTime.parse(json['lastSuccessfulSync'] as String),
      currentOperation: $enumDecodeNullable(
          _$TelemetryOperationTypeEnumMap, json['currentOperation']),
      currentOperationId: json['currentOperationId'] as String?,
      operationProgress: (json['operationProgress'] as num?)?.toDouble(),
      activeFilter: $enumDecodeNullable(
              _$TelemetryDataFilterEnumMap, json['activeFilter']) ??
          TelemetryDataFilter.all,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      hasMoreData: json['hasMoreData'] as bool? ?? false,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      error: json['error'] as String?,
      syncError: json['syncError'] as String?,
      createError: json['createError'] as String?,
      uploadError: json['uploadError'] as String?,
      conflictError: json['conflictError'] as String?,
      fieldErrors: (json['fieldErrors'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      currentSessionId: json['currentSessionId'] as String?,
      sessionMetadata: json['sessionMetadata'] as Map<String, dynamic>?,
      sessionStartedAt: json['sessionStartedAt'] == null
          ? null
          : DateTime.parse(json['sessionStartedAt'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      lastDataRefresh: json['lastDataRefresh'] == null
          ? null
          : DateTime.parse(json['lastDataRefresh'] as String),
    );

Map<String, dynamic> _$$TelemetryStateImplToJson(
        _$TelemetryStateImpl instance) =>
    <String, dynamic>{
      'isLoadingData': instance.isLoadingData,
      'isLoadingLightReadings': instance.isLoadingLightReadings,
      'isLoadingGrowthPhotos': instance.isLoadingGrowthPhotos,
      'isLoadingBatchData': instance.isLoadingBatchData,
      'isSyncing': instance.isSyncing,
      'isResolvingConflicts': instance.isResolvingConflicts,
      'isCreatingLightReading': instance.isCreatingLightReading,
      'isCreatingGrowthPhoto': instance.isCreatingGrowthPhoto,
      'isUploadingBatch': instance.isUploadingBatch,
      'telemetryData': instance.telemetryData,
      'lightReadings': instance.lightReadings,
      'growthPhotos': instance.growthPhotos,
      'batchData': instance.batchData,
      'syncStatuses': instance.syncStatuses,
      'currentSyncStatus': instance.currentSyncStatus,
      'isOfflineMode': instance.isOfflineMode,
      'pendingSyncCount': instance.pendingSyncCount,
      'failedSyncCount': instance.failedSyncCount,
      'conflictCount': instance.conflictCount,
      'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
      'lastSuccessfulSync': instance.lastSuccessfulSync?.toIso8601String(),
      'currentOperation':
          _$TelemetryOperationTypeEnumMap[instance.currentOperation],
      'currentOperationId': instance.currentOperationId,
      'operationProgress': instance.operationProgress,
      'activeFilter': _$TelemetryDataFilterEnumMap[instance.activeFilter]!,
      'currentPage': instance.currentPage,
      'hasMoreData': instance.hasMoreData,
      'pageSize': instance.pageSize,
      'error': instance.error,
      'syncError': instance.syncError,
      'createError': instance.createError,
      'uploadError': instance.uploadError,
      'conflictError': instance.conflictError,
      'fieldErrors': instance.fieldErrors,
      'currentSessionId': instance.currentSessionId,
      'sessionMetadata': instance.sessionMetadata,
      'sessionStartedAt': instance.sessionStartedAt?.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'lastDataRefresh': instance.lastDataRefresh?.toIso8601String(),
    };

const _$TelemetryOperationTypeEnumMap = {
  TelemetryOperationType.lightReading: 'light_reading',
  TelemetryOperationType.growthPhoto: 'growth_photo',
  TelemetryOperationType.batchSync: 'batch_sync',
  TelemetryOperationType.dataFetch: 'data_fetch',
  TelemetryOperationType.conflictResolution: 'conflict_resolution',
};

const _$TelemetryDataFilterEnumMap = {
  TelemetryDataFilter.all: 'all',
  TelemetryDataFilter.synced: 'synced',
  TelemetryDataFilter.pending: 'pending',
  TelemetryDataFilter.failed: 'failed',
  TelemetryDataFilter.conflicts: 'conflicts',
  TelemetryDataFilter.offlineOnly: 'offline_only',
  TelemetryDataFilter.today: 'today',
  TelemetryDataFilter.thisWeek: 'this_week',
  TelemetryDataFilter.thisMonth: 'this_month',
};
