// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_plan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarePlanImpl _$$CarePlanImplFromJson(Map<String, dynamic> json) =>
    _$CarePlanImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      userId: json['userId'] as String,
      version: (json['version'] as num).toInt(),
      watering:
          WateringSchedule.fromJson(json['watering'] as Map<String, dynamic>),
      fertilizer: FertilizerSchedule.fromJson(
          json['fertilizer'] as Map<String, dynamic>),
      lightTarget:
          LightTarget.fromJson(json['lightTarget'] as Map<String, dynamic>),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reviewInDays: (json['reviewInDays'] as num).toInt(),
      rationale:
          CarePlanRationale.fromJson(json['rationale'] as Map<String, dynamic>),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: json['validTo'] == null
          ? null
          : DateTime.parse(json['validTo'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      status: $enumDecodeNullable(_$CarePlanStatusEnumMap, json['status']) ??
          CarePlanStatus.pending,
    );

Map<String, dynamic> _$$CarePlanImplToJson(_$CarePlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'userId': instance.userId,
      'version': instance.version,
      'watering': instance.watering,
      'fertilizer': instance.fertilizer,
      'lightTarget': instance.lightTarget,
      'alerts': instance.alerts,
      'reviewInDays': instance.reviewInDays,
      'rationale': instance.rationale,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'status': _$CarePlanStatusEnumMap[instance.status]!,
    };

const _$CarePlanStatusEnumMap = {
  CarePlanStatus.pending: 'pending',
  CarePlanStatus.acknowledged: 'acknowledged',
  CarePlanStatus.active: 'active',
  CarePlanStatus.completed: 'completed',
  CarePlanStatus.expired: 'expired',
};

_$WateringScheduleImpl _$$WateringScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$WateringScheduleImpl(
      intervalDays: (json['intervalDays'] as num).toInt(),
      amountMl: (json['amountMl'] as num).toInt(),
      nextDue: DateTime.parse(json['nextDue'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$WateringScheduleImplToJson(
        _$WateringScheduleImpl instance) =>
    <String, dynamic>{
      'intervalDays': instance.intervalDays,
      'amountMl': instance.amountMl,
      'nextDue': instance.nextDue.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

_$FertilizerScheduleImpl _$$FertilizerScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$FertilizerScheduleImpl(
      intervalDays: (json['intervalDays'] as num).toInt(),
      type: json['type'] as String,
      nextDue: json['nextDue'] == null
          ? null
          : DateTime.parse(json['nextDue'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$FertilizerScheduleImplToJson(
        _$FertilizerScheduleImpl instance) =>
    <String, dynamic>{
      'intervalDays': instance.intervalDays,
      'type': instance.type,
      'nextDue': instance.nextDue?.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

_$LightTargetImpl _$$LightTargetImplFromJson(Map<String, dynamic> json) =>
    _$LightTargetImpl(
      ppfdMin: (json['ppfdMin'] as num).toInt(),
      ppfdMax: (json['ppfdMax'] as num).toInt(),
      recommendation: json['recommendation'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$LightTargetImplToJson(_$LightTargetImpl instance) =>
    <String, dynamic>{
      'ppfdMin': instance.ppfdMin,
      'ppfdMax': instance.ppfdMax,
      'recommendation': instance.recommendation,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

_$CarePlanRationaleImpl _$$CarePlanRationaleImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanRationaleImpl(
      features: json['features'] as Map<String, dynamic>,
      rulesFired: (json['rulesFired'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      mlAdjustments: json['mlAdjustments'] as Map<String, dynamic>? ?? const {},
      environmentalFactors: (json['environmentalFactors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      explanation: json['explanation'] as String?,
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$$CarePlanRationaleImplToJson(
        _$CarePlanRationaleImpl instance) =>
    <String, dynamic>{
      'features': instance.features,
      'rulesFired': instance.rulesFired,
      'confidence': instance.confidence,
      'mlAdjustments': instance.mlAdjustments,
      'environmentalFactors': instance.environmentalFactors,
      'explanation': instance.explanation,
      'summary': instance.summary,
    };

_$CarePlanGenerationRequestImpl _$$CarePlanGenerationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanGenerationRequestImpl(
      userPlantId: json['userPlantId'] as String,
      includeEnvironmentalData:
          json['includeEnvironmentalData'] as bool? ?? false,
      includeHistoricalData: json['includeHistoricalData'] as bool? ?? false,
      enableAdaptiveLearning: json['enableAdaptiveLearning'] as bool? ?? false,
      focusAreas: (json['focusAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CarePlanGenerationRequestImplToJson(
        _$CarePlanGenerationRequestImpl instance) =>
    <String, dynamic>{
      'userPlantId': instance.userPlantId,
      'includeEnvironmentalData': instance.includeEnvironmentalData,
      'includeHistoricalData': instance.includeHistoricalData,
      'enableAdaptiveLearning': instance.enableAdaptiveLearning,
      'focusAreas': instance.focusAreas,
      'notes': instance.notes,
    };

_$CarePlanGenerationResponseImpl _$$CarePlanGenerationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanGenerationResponseImpl(
      carePlan: CarePlan.fromJson(json['carePlan'] as Map<String, dynamic>),
      isNewVersion: json['isNewVersion'] as bool,
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      generationTimeMs: (json['generationTimeMs'] as num).toInt(),
    );

Map<String, dynamic> _$$CarePlanGenerationResponseImplToJson(
        _$CarePlanGenerationResponseImpl instance) =>
    <String, dynamic>{
      'carePlan': instance.carePlan,
      'isNewVersion': instance.isNewVersion,
      'changes': instance.changes,
      'generationTimeMs': instance.generationTimeMs,
    };

_$CarePlanHistoryImpl _$$CarePlanHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanHistoryImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      version: (json['version'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAcknowledged: json['isAcknowledged'] as bool,
      isActive: json['isActive'] as bool,
      plantNickname: json['plantNickname'] as String,
      speciesName: json['speciesName'] as String,
      nextWateringDue: DateTime.parse(json['nextWateringDue'] as String),
      urgentAlerts: (json['urgentAlerts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CarePlanHistoryImplToJson(
        _$CarePlanHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'isAcknowledged': instance.isAcknowledged,
      'isActive': instance.isActive,
      'plantNickname': instance.plantNickname,
      'speciesName': instance.speciesName,
      'nextWateringDue': instance.nextWateringDue.toIso8601String(),
      'urgentAlerts': instance.urgentAlerts,
    };

_$CarePlanHistoryParamsImpl _$$CarePlanHistoryParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanHistoryParamsImpl(
      userPlantId: json['userPlantId'] as String,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$$CarePlanHistoryParamsImplToJson(
        _$CarePlanHistoryParamsImpl instance) =>
    <String, dynamic>{
      'userPlantId': instance.userPlantId,
      'page': instance.page,
      'limit': instance.limit,
    };

_$CarePlanHistoryResponseImpl _$$CarePlanHistoryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanHistoryResponseImpl(
      plantId: json['plantId'] as String,
      plans: (json['plans'] as List<dynamic>)
          .map((e) => CarePlanHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      currentVersion: (json['currentVersion'] as num).toInt(),
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$$CarePlanHistoryResponseImplToJson(
        _$CarePlanHistoryResponseImpl instance) =>
    <String, dynamic>{
      'plantId': instance.plantId,
      'plans': instance.plans,
      'totalCount': instance.totalCount,
      'currentVersion': instance.currentVersion,
      'hasMore': instance.hasMore,
    };

_$CarePlanStateImpl _$$CarePlanStateImplFromJson(Map<String, dynamic> json) =>
    _$CarePlanStateImpl(
      isLoadingPlans: json['isLoadingPlans'] as bool? ?? false,
      isLoadingHistory: json['isLoadingHistory'] as bool? ?? false,
      isLoadingNotifications: json['isLoadingNotifications'] as bool? ?? false,
      isGenerating: json['isGenerating'] as bool? ?? false,
      activePlans: (json['activePlans'] as List<dynamic>?)
              ?.map((e) => CarePlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CarePlan>[],
      planHistory: (json['planHistory'] as List<dynamic>?)
              ?.map((e) => CarePlanHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CarePlanHistory>[],
      pendingNotifications: (json['pendingNotifications'] as List<dynamic>?)
              ?.map((e) =>
                  CarePlanNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CarePlanNotification>[],
      hasMoreHistory: json['hasMoreHistory'] as bool? ?? false,
      currentHistoryPage: (json['currentHistoryPage'] as num?)?.toInt() ?? 1,
      error: json['error'] as String?,
      generateError: json['generateError'] as String?,
      acknowledgeError: json['acknowledgeError'] as String?,
      historyError: json['historyError'] as String?,
      notificationError: json['notificationError'] as String?,
      lastGeneratedPlanId: json['lastGeneratedPlanId'] as String?,
    );

Map<String, dynamic> _$$CarePlanStateImplToJson(_$CarePlanStateImpl instance) =>
    <String, dynamic>{
      'isLoadingPlans': instance.isLoadingPlans,
      'isLoadingHistory': instance.isLoadingHistory,
      'isLoadingNotifications': instance.isLoadingNotifications,
      'isGenerating': instance.isGenerating,
      'activePlans': instance.activePlans,
      'planHistory': instance.planHistory,
      'pendingNotifications': instance.pendingNotifications,
      'hasMoreHistory': instance.hasMoreHistory,
      'currentHistoryPage': instance.currentHistoryPage,
      'error': instance.error,
      'generateError': instance.generateError,
      'acknowledgeError': instance.acknowledgeError,
      'historyError': instance.historyError,
      'notificationError': instance.notificationError,
      'lastGeneratedPlanId': instance.lastGeneratedPlanId,
    };

_$CarePlanNotificationImpl _$$CarePlanNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$CarePlanNotificationImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      planId: json['planId'] as String,
      type: $enumDecode(_$CarePlanNotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isActioned: json['isActioned'] as bool? ?? false,
      actionData: json['actionData'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CarePlanNotificationImplToJson(
        _$CarePlanNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'planId': instance.planId,
      'type': _$CarePlanNotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'scheduledFor': instance.scheduledFor.toIso8601String(),
      'isRead': instance.isRead,
      'isActioned': instance.isActioned,
      'actionData': instance.actionData,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CarePlanNotificationTypeEnumMap = {
  CarePlanNotificationType.planGenerated: 'planGenerated',
  CarePlanNotificationType.planUpdated: 'planUpdated',
  CarePlanNotificationType.wateringDue: 'wateringDue',
  CarePlanNotificationType.fertilizingDue: 'fertilizingDue',
  CarePlanNotificationType.urgentAlert: 'urgentAlert',
  CarePlanNotificationType.reviewDue: 'reviewDue',
};
