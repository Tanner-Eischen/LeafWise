// Care Plan Models
// This file contains data models for context-aware care plans including
// watering schedules, fertilizer recommendations, and explainable rationale

import 'package:freezed_annotation/freezed_annotation.dart';
import 'care_plan_status.dart';
export 'care_plan_status.dart';

part 'care_plan_models.freezed.dart';
part 'care_plan_models.g.dart';

// Helper function for JSON serialization of CarePlanStatus
String _statusToJson(CarePlanStatus status) => status.toJson();

/// Represents a complete care plan for a user's plant
@freezed
class CarePlan with _$CarePlan {
  const factory CarePlan({
    required String id,
    required String plantId,
    required String userId,
    required int version,
    required WateringSchedule watering,
    required FertilizerSchedule fertilizer,
    required LightTarget lightTarget,
    @Default([]) List<String> alerts,
    required int reviewInDays,
    required CarePlanRationale rationale,
    required DateTime validFrom,
    DateTime? validTo,
    required DateTime createdAt,
    @Default(false) bool isAcknowledged,
    DateTime? acknowledgedAt,
    @Default(CarePlanStatus.pending)
    CarePlanStatus status,
  }) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);
}

/// Watering schedule recommendations
@freezed
class WateringSchedule with _$WateringSchedule {
  const factory WateringSchedule({
    required int intervalDays,
    required int amountMl,
    required DateTime nextDue,
    String? notes,
    @Default({}) Map<String, dynamic> metadata,
  }) = _WateringSchedule;

  factory WateringSchedule.fromJson(Map<String, dynamic> json) =>
      _$WateringScheduleFromJson(json);
}

/// Fertilizer schedule recommendations
@freezed
class FertilizerSchedule with _$FertilizerSchedule {
  const factory FertilizerSchedule({
    required int intervalDays,
    required String type,
    DateTime? nextDue,
    String? notes,
    @Default({}) Map<String, dynamic> metadata,
  }) = _FertilizerSchedule;

  factory FertilizerSchedule.fromJson(Map<String, dynamic> json) =>
      _$FertilizerScheduleFromJson(json);
}

/// Light requirements and recommendations
@freezed
class LightTarget with _$LightTarget {
  const factory LightTarget({
    required int ppfdMin,
    required int ppfdMax,
    required String recommendation,
    String? notes,
    @Default({}) Map<String, dynamic> metadata,
  }) = _LightTarget;

  factory LightTarget.fromJson(Map<String, dynamic> json) =>
      _$LightTargetFromJson(json);
}

/// Explainable AI rationale for care plan decisions
@freezed
class CarePlanRationale with _$CarePlanRationale {
  const factory CarePlanRationale({
    required Map<String, dynamic> features,
    required List<String> rulesFired,
    required double confidence,
    @Default({}) Map<String, dynamic> mlAdjustments,
    @Default([]) List<String> environmentalFactors,
    String? explanation,
    String? summary,
  }) = _CarePlanRationale;

  factory CarePlanRationale.fromJson(Map<String, dynamic> json) =>
      _$CarePlanRationaleFromJson(json);
}

/// Request model for generating a new care plan
@freezed
class CarePlanGenerationRequest with _$CarePlanGenerationRequest {
  const factory CarePlanGenerationRequest({
    required String userPlantId,
    @Default(false) bool includeEnvironmentalData,
    @Default(false) bool includeHistoricalData,
    @Default(false) bool enableAdaptiveLearning,
    @Default(<String>[]) List<String> focusAreas,
    String? notes,
  }) = _CarePlanGenerationRequest;

  factory CarePlanGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$CarePlanGenerationRequestFromJson(json);
}

/// Response model for care plan generation
@freezed
class CarePlanGenerationResponse with _$CarePlanGenerationResponse {
  const factory CarePlanGenerationResponse({
    required CarePlan carePlan,
    required bool isNewVersion,
    @Default([]) List<String> changes,
    required int generationTimeMs,
  }) = _CarePlanGenerationResponse;

  factory CarePlanGenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$CarePlanGenerationResponseFromJson(json);
}

/// Summary model for care plan lists
@freezed
class CarePlanHistory with _$CarePlanHistory {
  const factory CarePlanHistory({
    required String id,
    required String plantId,
    required int version,
    required DateTime createdAt,
    required bool isAcknowledged,
    required bool isActive,
    required String plantNickname,
    required String speciesName,
    required DateTime nextWateringDue,
    @Default([]) List<String> urgentAlerts,
  }) = _CarePlanHistory;

  factory CarePlanHistory.fromJson(Map<String, dynamic> json) =>
      _$CarePlanHistoryFromJson(json);
}

/// Parameters for care plan history requests
@freezed
class CarePlanHistoryParams with _$CarePlanHistoryParams {
  const factory CarePlanHistoryParams({
    required String userPlantId,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _CarePlanHistoryParams;

  factory CarePlanHistoryParams.fromJson(Map<String, dynamic> json) =>
      _$CarePlanHistoryParamsFromJson(json);
}

/// Response model for care plan history with pagination
@freezed
class CarePlanHistoryResponse with _$CarePlanHistoryResponse {
  const factory CarePlanHistoryResponse({
    required String plantId,
    required List<CarePlanHistory> plans,
    required int totalCount,
    required int currentVersion,
    @Default(false) bool hasMore,
  }) = _CarePlanHistoryResponse;

  factory CarePlanHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CarePlanHistoryResponseFromJson(json);
}

/// State for care plan provider
@freezed
class CarePlanState with _$CarePlanState {
  const factory CarePlanState({
    // Loading flags
    @Default(false) bool isLoadingPlans,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isLoadingNotifications,
    @Default(false) bool isGenerating,

    // Data collections
    @Default(<CarePlan>[]) List<CarePlan> activePlans,
    @Default(<CarePlanHistory>[]) List<CarePlanHistory> planHistory,
    @Default(<CarePlanNotification>[]) List<CarePlanNotification> pendingNotifications,

    // Pagination
    @Default(false) bool hasMoreHistory,
    @Default(1) int currentHistoryPage,

    // Errors
    String? error,
    String? generateError,
    String? acknowledgeError,
    String? historyError,
    String? notificationError,

    // Metadata
    String? lastGeneratedPlanId,
  }) = _CarePlanState;

  factory CarePlanState.fromJson(Map<String, dynamic> json) =>
      _$CarePlanStateFromJson(json);
}

/// Care plan notification types
enum CarePlanNotificationType {
  planGenerated,
  planUpdated,
  wateringDue,
  fertilizingDue,
  urgentAlert,
  reviewDue,
}

/// Care plan notification model
@freezed
class CarePlanNotification with _$CarePlanNotification {
  const factory CarePlanNotification({
    required String id,
    required String plantId,
    required String planId,
    required CarePlanNotificationType type,
    required String title,
    required String message,
    required DateTime scheduledFor,
    @Default(false) bool isRead,
    @Default(false) bool isActioned,
    @Default({}) Map<String, dynamic> actionData,
    required DateTime createdAt,
  }) = _CarePlanNotification;

  factory CarePlanNotification.fromJson(Map<String, dynamic> json) =>
      _$CarePlanNotificationFromJson(json);
}
