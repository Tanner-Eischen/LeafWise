import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant_care_models.freezed.dart';
part 'plant_care_models.g.dart';

@freezed
class PlantCareLog with _$PlantCareLog {
  const factory PlantCareLog({
    required String id,
    required String userPlantId,
    required String careType,
    required DateTime careDate,
    String? notes,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlantCareLog;

  factory PlantCareLog.fromJson(Map<String, dynamic> json) =>
      _$PlantCareLogFromJson(json);
}

@freezed
class PlantCareReminder with _$PlantCareReminder {
  const factory PlantCareReminder({
    required String id,
    required String userPlantId,
    required String careType,
    required DateTime nextDueDate,
    required int frequencyDays,
    required bool isActive,
    String? notes,
    DateTime? lastCompletedDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlantCareReminder;

  factory PlantCareReminder.fromJson(Map<String, dynamic> json) =>
      _$PlantCareReminderFromJson(json);
}

@freezed
class UserPlant with _$UserPlant {
  const factory UserPlant({
    required String id,
    required String userId,
    required String speciesId,
    required String nickname,
    String? notes,
    String? imageUrl,
    required DateTime acquiredDate,
    String? location,
    Map<String, dynamic>? customCareSchedule,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Related data
    PlantSpecies? species,
    List<PlantCareLog>? careLogs,
    List<PlantCareReminder>? reminders,
  }) = _UserPlant;

  factory UserPlant.fromJson(Map<String, dynamic> json) =>
      _$UserPlantFromJson(json);
}

@freezed
class PlantSpecies with _$PlantSpecies {
  const factory PlantSpecies({
    required String id,
    required String commonName,
    required String scientificName,
    String? family,
    String? description,
    String? imageUrl,
    List<String>? alternativeNames,
    List<String>? nativeRegions,
    String? maxHeight,
    String? bloomTime,
    String? plantType,
    PlantCareInfo? careInfo,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlantSpecies;

  factory PlantSpecies.fromJson(Map<String, dynamic> json) =>
      _$PlantSpeciesFromJson(json);
}

@freezed
class PlantCareInfo with _$PlantCareInfo {
  const factory PlantCareInfo({
    required String lightRequirement,
    required String waterFrequency,
    required String careLevel,
    String? humidity,
    String? temperature,
    String? toxicity,
    String? fertilizer,
    String? repotting,
    String? pruning,
    Map<String, dynamic>? additionalCare,
  }) = _PlantCareInfo;

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) =>
      _$PlantCareInfoFromJson(json);
}

@freezed
class PlantCareRequest with _$PlantCareRequest {
  const factory PlantCareRequest({
    required String userPlantId,
    required String careType,
    required DateTime careDate,
    String? notes,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) = _PlantCareRequest;

  factory PlantCareRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantCareRequestFromJson(json);
}

@freezed
class PlantCareReminderRequest with _$PlantCareReminderRequest {
  const factory PlantCareReminderRequest({
    required String userPlantId,
    required String careType,
    required DateTime nextDueDate,
    required int frequencyDays,
    String? notes,
  }) = _PlantCareReminderRequest;

  factory PlantCareReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantCareReminderRequestFromJson(json);
}

@freezed
class UserPlantRequest with _$UserPlantRequest {
  const factory UserPlantRequest({
    required String speciesId,
    required String nickname,
    String? notes,
    String? imageUrl,
    required DateTime acquiredDate,
    String? location,
    Map<String, dynamic>? customCareSchedule,
  }) = _UserPlantRequest;

  factory UserPlantRequest.fromJson(Map<String, dynamic> json) =>
      _$UserPlantRequestFromJson(json);
}

@freezed
class PlantCareState with _$PlantCareState {
  const factory PlantCareState({
    @Default([]) List<UserPlant> userPlants,
    @Default([]) List<PlantCareLog> careLogs,
    @Default([]) List<PlantCareReminder> reminders,
    @Default([]) List<PlantCareReminder> upcomingReminders,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingPlants,
    @Default(false) bool isLoadingLogs,
    @Default(false) bool isLoadingReminders,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    String? error,
    String? createError,
    String? updateError,
    String? deleteError,
  }) = _PlantCareState;

  factory PlantCareState.fromJson(Map<String, dynamic> json) =>
      _$PlantCareStateFromJson(json);
}

// Care type constants
class CareType {
  static const String watering = 'watering';
  static const String fertilizing = 'fertilizing';
  static const String pruning = 'pruning';
  static const String repotting = 'repotting';
  static const String pestControl = 'pest_control';
  static const String observation = 'observation';
  static const String other = 'other';

  static const List<String> all = [
    watering,
    fertilizing,
    pruning,
    repotting,
    pestControl,
    observation,
    other,
  ];

  static String getDisplayName(String careType) {
    switch (careType) {
      case watering:
        return 'Watering';
      case fertilizing:
        return 'Fertilizing';
      case pruning:
        return 'Pruning';
      case repotting:
        return 'Repotting';
      case pestControl:
        return 'Pest Control';
      case observation:
        return 'Observation';
      case other:
        return 'Other';
      default:
        return careType;
    }
  }

  static String getIcon(String careType) {
    switch (careType) {
      case watering:
        return '💧';
      case fertilizing:
        return '🌱';
      case pruning:
        return '✂️';
      case repotting:
        return '🪴';
      case pestControl:
        return '🐛';
      case observation:
        return '👁️';
      case other:
        return '📝';
      default:
        return '🌿';
    }
  }
}