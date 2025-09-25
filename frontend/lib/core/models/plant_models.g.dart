// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlantImpl _$$PlantImplFromJson(Map<String, dynamic> json) => _$PlantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      careInstructions: (json['careInstructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlantImplToJson(_$PlantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'careInstructions': instance.careInstructions,
      'metadata': instance.metadata,
      'isFavorite': instance.isFavorite,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PlantSpeciesImpl _$$PlantSpeciesImplFromJson(Map<String, dynamic> json) =>
    _$PlantSpeciesImpl(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      family: json['family'] as String?,
      genus: json['genus'] as String?,
      species: json['species'] as String?,
      description: json['description'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      careRequirements: json['careRequirements'] as Map<String, dynamic>?,
      characteristics: json['characteristics'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlantSpeciesImplToJson(_$PlantSpeciesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'family': instance.family,
      'genus': instance.genus,
      'species': instance.species,
      'description': instance.description,
      'images': instance.images,
      'careRequirements': instance.careRequirements,
      'characteristics': instance.characteristics,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlantIdentificationResultImpl _$$PlantIdentificationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PlantIdentificationResultImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      identifiedAt: json['identifiedAt'] == null
          ? null
          : DateTime.parse(json['identifiedAt'] as String),
    );

Map<String, dynamic> _$$PlantIdentificationResultImplToJson(
        _$PlantIdentificationResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'confidence': instance.confidence,
      'imageUrl': instance.imageUrl,
      'additionalInfo': instance.additionalInfo,
      'identifiedAt': instance.identifiedAt?.toIso8601String(),
    };

_$PlantCareEntryImpl _$$PlantCareEntryImplFromJson(Map<String, dynamic> json) =>
    _$PlantCareEntryImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      careType: json['careType'] as String,
      careDate: DateTime.parse(json['careDate'] as String),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlantCareEntryImplToJson(
        _$PlantCareEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'careType': instance.careType,
      'careDate': instance.careDate.toIso8601String(),
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$PlantCareReminderImpl _$$PlantCareReminderImplFromJson(
        Map<String, dynamic> json) =>
    _$PlantCareReminderImpl(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      careType: json['careType'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isOverdue: json['isOverdue'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlantCareReminderImplToJson(
        _$PlantCareReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plantId': instance.plantId,
      'careType': instance.careType,
      'dueDate': instance.dueDate.toIso8601String(),
      'description': instance.description,
      'isCompleted': instance.isCompleted,
      'isOverdue': instance.isOverdue,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
