/// Plant Models
///
/// Core plant data models used across the application for plant identification,
/// care tracking, and telemetry data. These models provide the foundation for
/// plant-related functionality throughout the app.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plant_models.freezed.dart';
part 'plant_models.g.dart';

/// Basic plant information model
@freezed
class Plant with _$Plant {
  const factory Plant({
    required String id,
    required String name,
    required String scientificName,
    String? commonName,
    String? description,
    String? imageUrl,
    List<String>? careInstructions,
    Map<String, dynamic>? metadata,
    @Default(false) bool isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Plant;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
}

/// Plant species information
@freezed
class PlantSpecies with _$PlantSpecies {
  const factory PlantSpecies({
    required String id,
    required String scientificName,
    required String commonName,
    String? family,
    String? genus,
    String? species,
    String? description,
    List<String>? images,
    Map<String, dynamic>? careRequirements,
    Map<String, dynamic>? characteristics,
    DateTime? createdAt,
  }) = _PlantSpecies;

  factory PlantSpecies.fromJson(Map<String, dynamic> json) => _$PlantSpeciesFromJson(json);
}

/// Plant identification result
@freezed
class PlantIdentificationResult with _$PlantIdentificationResult {
  const factory PlantIdentificationResult({
    required String id,
    required String plantId,
    required String scientificName,
    required String commonName,
    required double confidence,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
    DateTime? identifiedAt,
  }) = _PlantIdentificationResult;

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) => _$PlantIdentificationResultFromJson(json);
}

/// Plant care log entry
@freezed
class PlantCareEntry with _$PlantCareEntry {
  const factory PlantCareEntry({
    required String id,
    required String plantId,
    required String careType,
    required DateTime careDate,
    String? notes,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _PlantCareEntry;

  factory PlantCareEntry.fromJson(Map<String, dynamic> json) => _$PlantCareEntryFromJson(json);
}

/// Plant health status
enum PlantHealthStatus {
  excellent,
  good,
  fair,
  poor,
  critical,
}

/// Plant care reminder
@freezed
class PlantCareReminder with _$PlantCareReminder {
  const factory PlantCareReminder({
    required String id,
    required String plantId,
    required String careType,
    required DateTime dueDate,
    String? description,
    @Default(false) bool isCompleted,
    @Default(false) bool isOverdue,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _PlantCareReminder;

  factory PlantCareReminder.fromJson(Map<String, dynamic> json) => _$PlantCareReminderFromJson(json);
}