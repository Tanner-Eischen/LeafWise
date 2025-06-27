// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_care_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantCareLog _$PlantCareLogFromJson(Map<String, dynamic> json) => PlantCareLog(
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

Map<String, dynamic> _$PlantCareLogToJson(PlantCareLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userPlantId': instance.userPlantId,
      'careType': instance.careType,
      'careDate': instance.careDate.toIso8601String(),
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PlantCareReminder _$PlantCareReminderFromJson(Map<String, dynamic> json) =>
    PlantCareReminder(
      id: json['id'] as String,
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      frequencyDays: (json['frequencyDays'] as num).toInt(),
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String?,
      lastCompletedDate: json['lastCompletedDate'] == null
          ? null
          : DateTime.parse(json['lastCompletedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      plant: json['plant'] == null
          ? null
          : UserPlant.fromJson(json['plant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantCareReminderToJson(PlantCareReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userPlantId': instance.userPlantId,
      'careType': instance.careType,
      'nextDueDate': instance.nextDueDate.toIso8601String(),
      'frequencyDays': instance.frequencyDays,
      'isActive': instance.isActive,
      'notes': instance.notes,
      'lastCompletedDate': instance.lastCompletedDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'plant': instance.plant,
    };

UserPlant _$UserPlantFromJson(Map<String, dynamic> json) => UserPlant(
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
      species: json['species'] == null
          ? null
          : PlantSpecies.fromJson(json['species'] as Map<String, dynamic>),
      careLogs: (json['careLogs'] as List<dynamic>?)
          ?.map((e) => PlantCareLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserPlantToJson(UserPlant instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'speciesId': instance.speciesId,
      'nickname': instance.nickname,
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'acquiredDate': instance.acquiredDate.toIso8601String(),
      'location': instance.location,
      'customCareSchedule': instance.customCareSchedule,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'species': instance.species,
      'careLogs': instance.careLogs,
      'reminders': instance.reminders,
    };

PlantSpecies _$PlantSpeciesFromJson(Map<String, dynamic> json) => PlantSpecies(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String,
      family: json['family'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      alternativeNames: (json['alternativeNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nativeRegions: (json['nativeRegions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxHeight: json['maxHeight'] as String?,
      bloomTime: json['bloomTime'] as String?,
      plantType: json['plantType'] as String?,
      careInfo: json['careInfo'] == null
          ? null
          : PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PlantSpeciesToJson(PlantSpecies instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commonName': instance.commonName,
      'scientificName': instance.scientificName,
      'family': instance.family,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'alternativeNames': instance.alternativeNames,
      'nativeRegions': instance.nativeRegions,
      'maxHeight': instance.maxHeight,
      'bloomTime': instance.bloomTime,
      'plantType': instance.plantType,
      'careInfo': instance.careInfo,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PlantCareInfo _$PlantCareInfoFromJson(Map<String, dynamic> json) =>
    PlantCareInfo(
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

Map<String, dynamic> _$PlantCareInfoToJson(PlantCareInfo instance) =>
    <String, dynamic>{
      'lightRequirement': instance.lightRequirement,
      'waterFrequency': instance.waterFrequency,
      'careLevel': instance.careLevel,
      'humidity': instance.humidity,
      'temperature': instance.temperature,
      'toxicity': instance.toxicity,
      'fertilizer': instance.fertilizer,
      'repotting': instance.repotting,
      'pruning': instance.pruning,
      'additionalCare': instance.additionalCare,
    };

PlantCareRequest _$PlantCareRequestFromJson(Map<String, dynamic> json) =>
    PlantCareRequest(
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      careDate: DateTime.parse(json['careDate'] as String),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PlantCareRequestToJson(PlantCareRequest instance) =>
    <String, dynamic>{
      'userPlantId': instance.userPlantId,
      'careType': instance.careType,
      'careDate': instance.careDate.toIso8601String(),
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'metadata': instance.metadata,
    };

PlantCareReminderRequest _$PlantCareReminderRequestFromJson(
        Map<String, dynamic> json) =>
    PlantCareReminderRequest(
      userPlantId: json['userPlantId'] as String,
      careType: json['careType'] as String,
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      frequencyDays: (json['frequencyDays'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PlantCareReminderRequestToJson(
        PlantCareReminderRequest instance) =>
    <String, dynamic>{
      'userPlantId': instance.userPlantId,
      'careType': instance.careType,
      'nextDueDate': instance.nextDueDate.toIso8601String(),
      'frequencyDays': instance.frequencyDays,
      'notes': instance.notes,
    };

UserPlantRequest _$UserPlantRequestFromJson(Map<String, dynamic> json) =>
    UserPlantRequest(
      speciesId: json['speciesId'] as String,
      nickname: json['nickname'] as String,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      location: json['location'] as String?,
      customCareSchedule: json['customCareSchedule'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserPlantRequestToJson(UserPlantRequest instance) =>
    <String, dynamic>{
      'speciesId': instance.speciesId,
      'nickname': instance.nickname,
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'acquiredDate': instance.acquiredDate.toIso8601String(),
      'location': instance.location,
      'customCareSchedule': instance.customCareSchedule,
    };

PlantCareState _$PlantCareStateFromJson(Map<String, dynamic> json) =>
    PlantCareState(
      userPlants: (json['userPlants'] as List<dynamic>?)
              ?.map((e) => UserPlant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      careLogs: (json['careLogs'] as List<dynamic>?)
              ?.map((e) => PlantCareLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map(
                  (e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      upcomingReminders: (json['upcomingReminders'] as List<dynamic>?)
              ?.map(
                  (e) => PlantCareReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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

Map<String, dynamic> _$PlantCareStateToJson(PlantCareState instance) =>
    <String, dynamic>{
      'userPlants': instance.userPlants,
      'careLogs': instance.careLogs,
      'reminders': instance.reminders,
      'upcomingReminders': instance.upcomingReminders,
      'isLoading': instance.isLoading,
      'isLoadingPlants': instance.isLoadingPlants,
      'isLoadingLogs': instance.isLoadingLogs,
      'isLoadingReminders': instance.isLoadingReminders,
      'isCreating': instance.isCreating,
      'isUpdating': instance.isUpdating,
      'isDeleting': instance.isDeleting,
      'error': instance.error,
      'createError': instance.createError,
      'updateError': instance.updateError,
      'deleteError': instance.deleteError,
    };
