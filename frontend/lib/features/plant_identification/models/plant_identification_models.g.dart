// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_identification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantIdentificationResult _$PlantIdentificationResultFromJson(
        Map<String, dynamic> json) =>
    PlantIdentificationResult(
      identifiedName: json['identifiedName'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      speciesSuggestions: (json['speciesSuggestions'] as List<dynamic>)
          .map(
              (e) => PlantSpeciesSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      careRecommendations: json['careRecommendations'] as String?,
    );

Map<String, dynamic> _$PlantIdentificationResultToJson(
        PlantIdentificationResult instance) =>
    <String, dynamic>{
      'identifiedName': instance.identifiedName,
      'confidenceScore': instance.confidenceScore,
      'speciesSuggestions': instance.speciesSuggestions,
      'careRecommendations': instance.careRecommendations,
    };

PlantSpeciesSuggestion _$PlantSpeciesSuggestionFromJson(
        Map<String, dynamic> json) =>
    PlantSpeciesSuggestion(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      description: json['description'] as String?,
      commonNames: (json['commonNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PlantSpeciesSuggestionToJson(
        PlantSpeciesSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'description': instance.description,
      'commonNames': instance.commonNames,
    };

_$PlantIdentificationImpl _$$PlantIdentificationImplFromJson(
        Map<String, dynamic> json) =>
    _$PlantIdentificationImpl(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      alternativeNames: (json['alternativeNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      careInfo:
          PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>),
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PlantIdentificationImplToJson(
        _$PlantIdentificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'confidence': instance.confidence,
      'alternativeNames': instance.alternativeNames,
      'imageUrl': instance.imageUrl,
      'careInfo': instance.careInfo,
      'identifiedAt': instance.identifiedAt.toIso8601String(),
      'description': instance.description,
      'tags': instance.tags,
    };

_$PlantCareInfoImpl _$$PlantCareInfoImplFromJson(Map<String, dynamic> json) =>
    _$PlantCareInfoImpl(
      lightRequirement: json['lightRequirement'] as String,
      waterFrequency: json['waterFrequency'] as String,
      careLevel: json['careLevel'] as String,
      humidity: json['humidity'] as String?,
      temperature: json['temperature'] as String?,
      toxicity: json['toxicity'] as String?,
      careNotes: (json['careNotes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PlantCareInfoImplToJson(_$PlantCareInfoImpl instance) =>
    <String, dynamic>{
      'lightRequirement': instance.lightRequirement,
      'waterFrequency': instance.waterFrequency,
      'careLevel': instance.careLevel,
      'humidity': instance.humidity,
      'temperature': instance.temperature,
      'toxicity': instance.toxicity,
      'careNotes': instance.careNotes,
    };

_$PlantIdentificationRequestImpl _$$PlantIdentificationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PlantIdentificationRequestImpl(
      imageBase64: json['imageBase64'] as String,
      location: json['location'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PlantIdentificationRequestImplToJson(
        _$PlantIdentificationRequestImpl instance) =>
    <String, dynamic>{
      'imageBase64': instance.imageBase64,
      'location': instance.location,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$PlantIdentificationStateImpl _$$PlantIdentificationStateImplFromJson(
        Map<String, dynamic> json) =>
    _$PlantIdentificationStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      identifications: (json['identifications'] as List<dynamic>?)
              ?.map((e) =>
                  PlantIdentification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      history: (json['history'] as List<dynamic>?)
              ?.map((e) =>
                  PlantIdentification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      error: json['error'] as String?,
      currentIdentification: json['currentIdentification'] == null
          ? null
          : PlantIdentification.fromJson(
              json['currentIdentification'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PlantIdentificationStateImplToJson(
        _$PlantIdentificationStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'identifications': instance.identifications,
      'history': instance.history,
      'error': instance.error,
      'currentIdentification': instance.currentIdentification,
    };
