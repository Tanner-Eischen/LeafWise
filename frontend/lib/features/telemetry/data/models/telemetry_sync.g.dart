// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetrySyncStatusImpl _$$TelemetrySyncStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$TelemetrySyncStatusImpl(
      sessionId: json['sessionId'] as String,
      syncState: $enumDecodeNullable(_$SyncStateEnumMap, json['syncState']) ??
          SyncState.idle,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      syncedItems: (json['syncedItems'] as num?)?.toInt() ?? 0,
      failedItems: (json['failedItems'] as num?)?.toInt() ?? 0,
      pendingItems: (json['pendingItems'] as num?)?.toInt() ?? 0,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      lastError: json['lastError'] as String?,
      errorDetails: json['errorDetails'] as Map<String, dynamic>?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
      userId: json['userId'] as String?,
      itemIds:
          (json['itemIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sessionMetadata: json['sessionMetadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? false,
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
      'sessionId': instance.sessionId,
      'syncState': _$SyncStateEnumMap[instance.syncState]!,
      'totalItems': instance.totalItems,
      'syncedItems': instance.syncedItems,
      'failedItems': instance.failedItems,
      'pendingItems': instance.pendingItems,
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'lastError': instance.lastError,
      'errorDetails': instance.errorDetails,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
      'userId': instance.userId,
      'itemIds': instance.itemIds,
      'sessionMetadata': instance.sessionMetadata,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SyncStateEnumMap = {
  SyncState.idle: 'idle',
  SyncState.pending: 'pending',
  SyncState.inProgress: 'in_progress',
  SyncState.synced: 'synced',
  SyncState.failed: 'failed',
  SyncState.conflict: 'conflict',
  SyncState.cancelled: 'cancelled',
  SyncState.retryScheduled: 'retry_scheduled',
};
