import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PlantIdentification {
  final String id;
  final String scientificName;
  final String commonName;
  final double confidence;
  final List<String> alternativeNames;
  final String imageUrl;
  final PlantCareInfo careInfo;
  final DateTime identifiedAt;
  final String? description;
  final List<String>? tags;

  const PlantIdentification({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    required this.alternativeNames,
    required this.imageUrl,
    required this.careInfo,
    required this.identifiedAt,
    this.description,
    this.tags,
  });

  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    return PlantIdentification(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      alternativeNames: (json['alternativeNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      careInfo: PlantCareInfo.fromJson(json['careInfo'] as Map<String, dynamic>),
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientificName': scientificName,
      'commonName': commonName,
      'confidence': confidence,
      'alternativeNames': alternativeNames,
      'imageUrl': imageUrl,
      'careInfo': careInfo.toJson(),
      'identifiedAt': identifiedAt.toIso8601String(),
      'description': description,
      'tags': tags,
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
  final List<String>? careNotes;

  const PlantCareInfo({
    required this.lightRequirement,
    required this.waterFrequency,
    required this.careLevel,
    this.humidity,
    this.temperature,
    this.toxicity,
    this.careNotes,
  });

  factory PlantCareInfo.fromJson(Map<String, dynamic> json) {
    return PlantCareInfo(
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
  }

  Map<String, dynamic> toJson() {
    return {
      'lightRequirement': lightRequirement,
      'waterFrequency': waterFrequency,
      'careLevel': careLevel,
      'humidity': humidity,
      'temperature': temperature,
      'toxicity': toxicity,
      'careNotes': careNotes,
    };
  }
}

@JsonSerializable()
class PlantIdentificationRequest {
  final String imageBase64;
  final String? location;
  final DateTime? timestamp;

  const PlantIdentificationRequest({
    required this.imageBase64,
    this.location,
    this.timestamp,
  });

  factory PlantIdentificationRequest.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationRequest(
      imageBase64: json['imageBase64'] as String,
      location: json['location'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'location': location,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

@JsonSerializable()
class PlantIdentificationState {
  final bool isLoading;
  final List<PlantIdentification> identifications;
  final List<PlantIdentification> history;
  final String? error;
  final PlantIdentification? currentIdentification;

  const PlantIdentificationState({
    this.isLoading = false,
    this.identifications = const [],
    this.history = const [],
    this.error,
    this.currentIdentification,
  });

  factory PlantIdentificationState.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationState(
      isLoading: json['isLoading'] as bool? ?? false,
      identifications: (json['identifications'] as List<dynamic>? ?? [])
          .map((e) => PlantIdentification.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => PlantIdentification.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
      currentIdentification: json['currentIdentification'] != null
          ? PlantIdentification.fromJson(json['currentIdentification'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'identifications': identifications.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
      'error': error,
      'currentIdentification': currentIdentification?.toJson(),
    };
  }

  PlantIdentificationState copyWith({
    bool? isLoading,
    List<PlantIdentification>? identifications,
    List<PlantIdentification>? history,
    String? error,
    PlantIdentification? currentIdentification,
  }) {
    return PlantIdentificationState(
      isLoading: isLoading ?? this.isLoading,
      identifications: identifications ?? this.identifications,
      history: history ?? this.history,
      error: error ?? this.error,
      currentIdentification: currentIdentification ?? this.currentIdentification,
    );
  }
}