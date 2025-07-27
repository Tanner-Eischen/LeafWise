import 'package:json_annotation/json_annotation.dart';

part 'ar_overlay_models.g.dart';

/// AR-specific plant identification data
@JsonSerializable()
class PlantARIdentification {
  final String scientificName;
  final String commonName;
  final double confidence;
  final List<String> alternativeNames;
  final PlantCareInfo careInfo;
  final String? description;
  final List<String> tags;
  final List<PlantHealthIndicator> healthIndicators;
  final String? imageUrl;

  const PlantARIdentification({
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    required this.alternativeNames,
    required this.careInfo,
    this.description,
    required this.tags,
    required this.healthIndicators,
    this.imageUrl,
  });

  factory PlantARIdentification.fromJson(Map<String, dynamic> json) =>
      _$PlantARIdentificationFromJson(json);

  Map<String, dynamic> toJson() => _$PlantARIdentificationToJson(this);
}

/// Plant care information for AR display
@JsonSerializable()
class PlantCareInfo {
  final String lightRequirement;
  final String wateringFrequency;
  final String soilType;
  final String humidityLevel;
  final String temperatureRange;
  final String fertilizingSchedule;
  final List<String> specialCareNotes;

  const PlantCareInfo({
    required this.lightRequirement,
    required this.wateringFrequency,
    required this.soilType,
    required this.humidityLevel,
    required this.temperatureRange,
    required this.fertilizingSchedule,
    required this.specialCareNotes,
  });

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) =>
      _$PlantCareInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PlantCareInfoToJson(this);
}

/// Plant health indicator for AR visualization
@JsonSerializable()
class PlantHealthIndicator {
  final String type;
  final double value;
  final String status;
  final String description;
  final String recommendation;

  const PlantHealthIndicator({
    required this.type,
    required this.value,
    required this.status,
    required this.description,
    required this.recommendation,
  });

  factory PlantHealthIndicator.fromJson(Map<String, dynamic> json) =>
      _$PlantHealthIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$PlantHealthIndicatorToJson(this);
}
