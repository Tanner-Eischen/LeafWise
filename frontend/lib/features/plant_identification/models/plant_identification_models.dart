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