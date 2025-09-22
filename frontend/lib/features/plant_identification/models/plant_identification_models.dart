import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant_identification_models.freezed.dart';
part 'plant_identification_models.g.dart';

@freezed
class PlantIdentification with _$PlantIdentification {
  const factory PlantIdentification({
    required String id,
    required String scientificName,
    required String commonName,
    required double confidence,
    required List<String> alternativeNames,
    required String imageUrl,
    required PlantCareInfo careInfo,
    required DateTime identifiedAt,
    String? description,
    List<String>? tags,
  }) = _PlantIdentification;

  factory PlantIdentification.fromJson(Map<String, dynamic> json) =>
      _$PlantIdentificationFromJson(json);
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
    List<String>? careNotes,
  }) = _PlantCareInfo;

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) =>
      _$PlantCareInfoFromJson(json);
}

@freezed
class PlantIdentificationRequest with _$PlantIdentificationRequest {
  const factory PlantIdentificationRequest({
    required String imageBase64,
    String? location,
    DateTime? timestamp,
  }) = _PlantIdentificationRequest;

  factory PlantIdentificationRequest.fromJson(Map<String, dynamic> json) =>
      _$PlantIdentificationRequestFromJson(json);
}

@freezed
class PlantIdentificationState with _$PlantIdentificationState {
  const factory PlantIdentificationState({
    @Default(false) bool isLoading,
    @Default([]) List<PlantIdentification> identifications,
    @Default([]) List<PlantIdentification> history,
    String? error,
    PlantIdentification? currentIdentification,
  }) = _PlantIdentificationState;

  factory PlantIdentificationState.fromJson(Map<String, dynamic> json) =>
      _$PlantIdentificationStateFromJson(json);
}

@JsonSerializable()
class PlantIdentificationResult {
  final String identifiedName;
  final double confidenceScore;
  final List<PlantSpeciesSuggestion> speciesSuggestions;
  final String? careRecommendations;

  const PlantIdentificationResult({
    required this.identifiedName,
    required this.confidenceScore,
    required this.speciesSuggestions,
    this.careRecommendations,
  });

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationResult(
      identifiedName: json['identified_name'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      speciesSuggestions: (json['species_suggestions'] as List<dynamic>? ?? [])
          .map(
              (e) => PlantSpeciesSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      careRecommendations: json['care_recommendations'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identified_name': identifiedName,
      'confidence_score': confidenceScore,
      'species_suggestions': speciesSuggestions.map((e) => e.toJson()).toList(),
      'care_recommendations': careRecommendations,
    };
  }
}

@JsonSerializable()
class PlantSpeciesSuggestion {
  final String id;
  final String scientificName;
  final String commonName;
  final String? description;
  final List<String>? commonNames;

  const PlantSpeciesSuggestion({
    required this.id,
    required this.scientificName,
    required this.commonName,
    this.description,
    this.commonNames,
  });

  factory PlantSpeciesSuggestion.fromJson(Map<String, dynamic> json) {
    return PlantSpeciesSuggestion(
      id: json['id'].toString(),
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      description: json['description'] as String?,
      commonNames: (json['common_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientific_name': scientificName,
      'common_name': commonName,
      'description': description,
      'common_names': commonNames,
    };
  }
}
