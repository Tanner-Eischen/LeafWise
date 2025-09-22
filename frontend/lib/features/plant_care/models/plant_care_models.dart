import 'package:json_annotation/json_annotation.dart';

part 'plant_care_models.g.dart';

@JsonSerializable()
class PlantCareLog {
  final String id;
  final String userPlantId;
  final String careType;
  final DateTime careDate;
  final String? notes;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantCareLog({
    required this.id,
    required this.userPlantId,
    required this.careType,
    required this.careDate,
    this.notes,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantCareLog.fromJson(Map<String, dynamic> json) {
    return PlantCareLog(
      id: json['id'] as String,
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      careDate: DateTime.parse(json['careDate'] as String),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userPlantId': userPlantId,
      'careType': careType,
      'careDate': careDate.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

@JsonSerializable()
class PlantCareReminder {
  final String id;
  final String userPlantId;
  final String careType;
  final DateTime nextDueDate;
  final int frequencyDays;
  final bool isActive;
  final String? notes;
  final DateTime? lastCompletedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Related data
  final UserPlant? plant;

  const PlantCareReminder({
    required this.id,
    required this.userPlantId,
    required this.careType,
    required this.nextDueDate,
    required this.frequencyDays,
    required this.isActive,
    this.notes,
    this.lastCompletedDate,
    required this.createdAt,
    required this.updatedAt,
    this.plant,
  });

  factory PlantCareReminder.fromJson(Map<String, dynamic> json) {
    return PlantCareReminder(
      id: json['id'] as String,
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      frequencyDays: json['frequencyDays'] as int,
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String?,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      plant: json['plant'] != null
          ? UserPlant.fromJson(json['plant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userPlantId': userPlantId,
      'careType': careType,
      'nextDueDate': nextDueDate.toIso8601String(),
      'frequencyDays': frequencyDays,
      'isActive': isActive,
      'notes': notes,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'plant': plant?.toJson(),
    };
  }
}

@JsonSerializable()
class UserPlant {
  final String id;
  final String userId;
  final String speciesId;
  final String nickname;
  final String? notes;
  final String? imageUrl;
  final DateTime acquiredDate;
  final String? location;
  final Map<String, dynamic>? customCareSchedule;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Related data
  final PlantSpecies? species;
  final List<PlantCareLog>? careLogs;
  final List<PlantCareReminder>? reminders;

  const UserPlant({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.nickname,
    this.notes,
    this.imageUrl,
    required this.acquiredDate,
    this.location,
    this.customCareSchedule,
    required this.createdAt,
    required this.updatedAt,
    this.species,
    this.careLogs,
    this.reminders,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      id: json['id'] as String,
      userId: json['userId'] as String,
      speciesId: json['speciesId'] as String,
      nickname: json['nickname'] as String,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      location: json['location'] as String?,
      customCareSchedule: json['customCareSchedule'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      species: json['species'] != null
          ? PlantSpecies.fromJson(json['species'] as Map<String, dynamic>)
          : null,
      careLogs: (json['careLogs'] as List<dynamic>?)
          ?.map((e) => PlantCareLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'speciesId': speciesId,
      'nickname': nickname,
      'notes': notes,
      'imageUrl': imageUrl,
      'acquiredDate': acquiredDate.toIso8601String(),
      'location': location,
      'customCareSchedule': customCareSchedule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'species': species?.toJson(),
      'careLogs': careLogs?.map((e) => e.toJson()).toList(),
      'reminders': reminders?.map((e) => e.toJson()).toList(),
    };
  }
}

@JsonSerializable()
class PlantSpecies {
  final String id;
  final String commonName;
  final String scientificName;
  final String? family;
  final String? description;
  final String? imageUrl;
  final List<String>? alternativeNames;
  final List<String>? nativeRegions;
  final String? maxHeight;
  final String? bloomTime;
  final String? plantType;
  final PlantCareInfo? careInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.family,
    this.description,
    this.imageUrl,
    this.alternativeNames,
    this.nativeRegions,
    this.maxHeight,
    this.bloomTime,
    this.plantType,
    this.careInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantSpecies.fromJson(Map<String, dynamic> json) {
    return PlantSpecies(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String,
      family: json['family'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      alternativeNames: (json['alternativeNames'] as List<dynamic>?)
          ?.cast<String>(),
      nativeRegions: (json['nativeRegions'] as List<dynamic>?)?.cast<String>(),
      maxHeight: json['maxHeight'] as String?,
      bloomTime: json['bloomTime'] as String?,
      plantType: json['plantType'] as String?,
      careInfo: json['careInfo'] != null
          ? PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'family': family,
      'description': description,
      'imageUrl': imageUrl,
      'alternativeNames': alternativeNames,
      'nativeRegions': nativeRegions,
      'maxHeight': maxHeight,
      'bloomTime': bloomTime,
      'plantType': plantType,
      'careInfo': careInfo?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

@JsonSerializable()
class PlantCareInfo {
  final String lightRequirement;
  final String waterFrequency;
  final String careLevel;
  final String? humidity;
  final String? temperature;
  final String? toxicity;
  final String? fertilizer;
  final String? repotting;
  final String? pruning;
  final Map<String, dynamic>? additionalCare;

  const PlantCareInfo({
    required this.lightRequirement,
    required this.waterFrequency,
    required this.careLevel,
    this.humidity,
    this.temperature,
    this.toxicity,
    this.fertilizer,
    this.repotting,
    this.pruning,
    this.additionalCare,
  });

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) {
    return PlantCareInfo(
      lightRequirement: json['lightRequirement'] as String,
      waterFrequency: json['waterFrequency'] as String,
      careLevel: json['careLevel'] as String,
      humidity: json['humidity'] as String?,
      temperature: json['temperature'] as String?,
      toxicity: json['toxicity'] as String?,
      fertilizer: json['fertilizer'] as String?,
      repotting: json['repotting'] as String?,
      pruning: json['pruning'] as String?,
      additionalCare: json['additionalCare'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lightRequirement': lightRequirement,
      'waterFrequency': waterFrequency,
      'careLevel': careLevel,
      'humidity': humidity,
      'temperature': temperature,
      'toxicity': toxicity,
      'fertilizer': fertilizer,
      'repotting': repotting,
      'pruning': pruning,
      'additionalCare': additionalCare,
    };
  }
}

@JsonSerializable()
class PlantCareRequest {
  final String userPlantId;
  final String careType;
  final DateTime careDate;
  final String? notes;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const PlantCareRequest({
    required this.userPlantId,
    required this.careType,
    required this.careDate,
    this.notes,
    this.imageUrl,
    this.metadata,
  });

  factory PlantCareRequest.fromJson(Map<String, dynamic> json) {
    return PlantCareRequest(
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      careDate: DateTime.parse(json['careDate'] as String),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPlantId': userPlantId,
      'careType': careType,
      'careDate': careDate.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

@JsonSerializable()
class PlantCareReminderRequest {
  final String userPlantId;
  final String careType;
  final DateTime nextDueDate;
  final int frequencyDays;
  final String? notes;

  const PlantCareReminderRequest({
    required this.userPlantId,
    required this.careType,
    required this.nextDueDate,
    required this.frequencyDays,
    this.notes,
  });

  factory PlantCareReminderRequest.fromJson(Map<String, dynamic> json) {
    return PlantCareReminderRequest(
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      frequencyDays: json['frequencyDays'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPlantId': userPlantId,
      'careType': careType,
      'nextDueDate': nextDueDate.toIso8601String(),
      'frequencyDays': frequencyDays,
      'notes': notes,
    };
  }
}

@JsonSerializable()
class UserPlantRequest {
  final String speciesId;
  final String nickname;
  final String? notes;
  final String? imageUrl;
  final DateTime acquiredDate;
  final String? location;
  final Map<String, dynamic>? customCareSchedule;

  const UserPlantRequest({
    required this.speciesId,
    required this.nickname,
    this.notes,
    this.imageUrl,
    required this.acquiredDate,
    this.location,
    this.customCareSchedule,
  });

  factory UserPlantRequest.fromJson(Map<String, dynamic> json) {
    return UserPlantRequest(
      speciesId: json['speciesId'] as String,
      nickname: json['nickname'] as String,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      location: json['location'] as String?,
      customCareSchedule: json['customCareSchedule'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesId': speciesId,
      'nickname': nickname,
      'notes': notes,
      'imageUrl': imageUrl,
      'acquiredDate': acquiredDate.toIso8601String(),
      'location': location,
      'customCareSchedule': customCareSchedule,
    };
  }
}

@JsonSerializable()
class PlantCareState {
  final List<UserPlant> userPlants;
  final List<PlantCareLog> careLogs;
  final List<PlantCareReminder> reminders;
  final List<PlantCareReminder> upcomingReminders;
  final bool isLoading;
  final bool isLoadingPlants;
  final bool isLoadingLogs;
  final bool isLoadingReminders;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final String? createError;
  final String? updateError;
  final String? deleteError;

  const PlantCareState({
    this.userPlants = const [],
    this.careLogs = const [],
    this.reminders = const [],
    this.upcomingReminders = const [],
    this.isLoading = false,
    this.isLoadingPlants = false,
    this.isLoadingLogs = false,
    this.isLoadingReminders = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.createError,
    this.updateError,
    this.deleteError,
  });

  factory PlantCareState.fromJson(Map<String, dynamic> json) {
    return PlantCareState(
      userPlants: (json['userPlants'] as List<dynamic>? ?? [])
          .map((e) => UserPlant.fromJson(e as Map<String, dynamic>))
          .toList(),
      careLogs: (json['careLogs'] as List<dynamic>? ?? [])
          .map((e) => PlantCareLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingReminders: (json['upcomingReminders'] as List<dynamic>? ?? [])
          .map((e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLoading: json['isLoading'] as bool? ?? false,
      isLoadingPlants: json['isLoadingPlants'] as bool? ?? false,
      isLoadingLogs: json['isLoadingLogs'] as bool? ?? false,
      isLoadingReminders: json['isLoadingReminders'] as bool? ?? false,
      isCreating: json['isCreating'] as bool? ?? false,
      isUpdating: json['isUpdating'] as bool? ?? false,
      isDeleting: json['isDeleting'] as bool? ?? false,
      error: json['error'] as String?,
      createError: json['createError'] as String?,
      updateError: json['updateError'] as String?,
      deleteError: json['deleteError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPlants': userPlants.map((e) => e.toJson()).toList(),
      'careLogs': careLogs.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      'upcomingReminders': upcomingReminders.map((e) => e.toJson()).toList(),
      'isLoading': isLoading,
      'isLoadingPlants': isLoadingPlants,
      'isLoadingLogs': isLoadingLogs,
      'isLoadingReminders': isLoadingReminders,
      'isCreating': isCreating,
      'isUpdating': isUpdating,
      'isDeleting': isDeleting,
      'error': error,
      'createError': createError,
      'updateError': updateError,
      'deleteError': deleteError,
    };
  }

  PlantCareState copyWith({
    List<UserPlant>? userPlants,
    List<PlantCareLog>? careLogs,
    List<PlantCareReminder>? reminders,
    List<PlantCareReminder>? upcomingReminders,
    bool? isLoading,
    bool? isLoadingPlants,
    bool? isLoadingLogs,
    bool? isLoadingReminders,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    String? createError,
    String? updateError,
    String? deleteError,
  }) {
    return PlantCareState(
      userPlants: userPlants ?? this.userPlants,
      careLogs: careLogs ?? this.careLogs,
      reminders: reminders ?? this.reminders,
      upcomingReminders: upcomingReminders ?? this.upcomingReminders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPlants: isLoadingPlants ?? this.isLoadingPlants,
      isLoadingLogs: isLoadingLogs ?? this.isLoadingLogs,
      isLoadingReminders: isLoadingReminders ?? this.isLoadingReminders,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      createError: createError ?? this.createError,
      updateError: updateError ?? this.updateError,
      deleteError: deleteError ?? this.deleteError,
    );
  }
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
