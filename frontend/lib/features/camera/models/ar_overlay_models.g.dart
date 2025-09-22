// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ar_overlay_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantARIdentification _$PlantARIdentificationFromJson(
        Map<String, dynamic> json) =>
    PlantARIdentification(
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      alternativeNames: (json['alternativeNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      careInfo:
          PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>),
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      healthIndicators: (json['healthIndicators'] as List<dynamic>)
          .map((e) => PlantHealthIndicator.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PlantARIdentificationToJson(
        PlantARIdentification instance) =>
    <String, dynamic>{
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'confidence': instance.confidence,
      'alternativeNames': instance.alternativeNames,
      'careInfo': instance.careInfo,
      'description': instance.description,
      'tags': instance.tags,
      'healthIndicators': instance.healthIndicators,
      'imageUrl': instance.imageUrl,
    };

PlantCareInfo _$PlantCareInfoFromJson(Map<String, dynamic> json) =>
    PlantCareInfo(
      lightRequirement: json['lightRequirement'] as String,
      wateringFrequency: json['wateringFrequency'] as String,
      soilType: json['soilType'] as String,
      humidityLevel: json['humidityLevel'] as String,
      temperatureRange: json['temperatureRange'] as String,
      fertilizingSchedule: json['fertilizingSchedule'] as String,
      specialCareNotes: (json['specialCareNotes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PlantCareInfoToJson(PlantCareInfo instance) =>
    <String, dynamic>{
      'lightRequirement': instance.lightRequirement,
      'wateringFrequency': instance.wateringFrequency,
      'soilType': instance.soilType,
      'humidityLevel': instance.humidityLevel,
      'temperatureRange': instance.temperatureRange,
      'fertilizingSchedule': instance.fertilizingSchedule,
      'specialCareNotes': instance.specialCareNotes,
    };

PlantHealthIndicator _$PlantHealthIndicatorFromJson(
        Map<String, dynamic> json) =>
    PlantHealthIndicator(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String,
      recommendation: json['recommendation'] as String,
    );

Map<String, dynamic> _$PlantHealthIndicatorToJson(
        PlantHealthIndicator instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'status': instance.status,
      'description': instance.description,
      'recommendation': instance.recommendation,
    };
