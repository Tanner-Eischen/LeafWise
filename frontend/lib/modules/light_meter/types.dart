// Light meter types and data models
// This module defines the data structures used for light measurements and telemetry

import 'package:uuid/uuid.dart';

/// Enum representing different light measurement sources
enum LightSource {
  als('als'),           // Ambient Light Sensor
  camera('camera'),     // Camera-based estimation
  ble('ble'),          // Bluetooth Low Energy sensor
  manual('manual');     // Manual input

  const LightSource(this.value);
  final String value;

  /// Convert string to LightSource enum
  static LightSource fromString(String value) {
    switch (value.toLowerCase()) {
      case 'als':
        return LightSource.als;
      case 'camera':
        return LightSource.camera;
      case 'ble':
        return LightSource.ble;
      case 'manual':
        return LightSource.manual;
      default:
        throw ArgumentError('Unknown light source: $value');
    }
  }
}

/// Light reading data model for telemetry
/// 
/// Represents a light measurement with all associated metadata
/// including location, environmental conditions, and calibration data
class LightReading {
  /// Unique identifier for the reading
  final String? id;
  
  /// Associated plant identifier (optional)
  final String? plantId;
  
  /// Light intensity in lux
  final double lux;
  
  /// Photosynthetic Photon Flux Density in μmol/m²/s (optional)
  final double? ppfdValue;
  
  /// Estimated PPFD calculated from lux (optional)
  final double? estimatedPpfd;
  
  /// Light measurement source
  final String source;
  
  /// Light source profile for calibration (e.g., 'sunlight', 'led_full_spectrum')
  final String? lightSourceProfile;
  
  /// Location name (e.g., 'Living room window')
  final String? locationName;
  
  /// GPS latitude
  final double? gpsLatitude;
  
  /// GPS longitude
  final double? gpsLongitude;
  
  /// Altitude in meters above sea level
  final double? altitude;
  
  /// Temperature in Celsius
  final double? temperature;
  
  /// Humidity percentage
  final double? humidity;
  
  /// Accuracy estimate percentage
  final double? accuracyEstimate;
  
  /// ML confidence score (0-1)
  final double? confidenceScore;
  
  /// Whether calibration was applied
  final bool isCalibrated;
  
  /// Device identifier/model
  final String? deviceModel;
  
  /// Device ID for the measurement
  final String? deviceId;
  
  /// Raw sensor data (JSON)
  final Map<String, dynamic>? rawData;
  
  /// Measurement timestamp (ISO 8601 string)
  final String takenAt;
  
  /// Creation timestamp (ISO 8601 string)
  final String? createdAt;

  /// Constructor for LightReading
  LightReading({
    this.id,
    this.plantId,
    required this.lux,
    this.ppfdValue,
    this.estimatedPpfd,
    required this.source,
    this.lightSourceProfile,
    this.locationName,
    this.gpsLatitude,
    this.gpsLongitude,
    this.altitude,
    this.temperature,
    this.humidity,
    this.accuracyEstimate,
    this.confidenceScore,
    this.isCalibrated = false,
    this.deviceModel,
    this.deviceId,
    this.rawData,
    required this.takenAt,
    this.createdAt,
  });

  /// Create LightReading from JSON
  factory LightReading.fromJson(Map<String, dynamic> json) {
    return LightReading(
      id: json['id']?.toString(),
      plantId: json['plant_id']?.toString(),
      lux: (json['lux_value'] ?? json['lux'])?.toDouble() ?? 0.0,
      ppfdValue: json['ppfd_value']?.toDouble(),
      estimatedPpfd: json['estimated_ppfd']?.toDouble(),
      source: json['source']?.toString() ?? 'manual',
      lightSourceProfile: json['light_source_profile']?.toString(),
      locationName: json['location_name']?.toString(),
      gpsLatitude: json['gps_latitude']?.toDouble(),
      gpsLongitude: json['gps_longitude']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      accuracyEstimate: json['accuracy_estimate']?.toDouble(),
      confidenceScore: json['confidence_score']?.toDouble(),
      isCalibrated: json['is_calibrated'] ?? false,
      deviceModel: json['device_model']?.toString(),
      deviceId: json['device_id']?.toString(),
      rawData: json['raw_data'] as Map<String, dynamic>?,
      takenAt: json['taken_at']?.toString() ?? json['measured_at']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: json['created_at']?.toString(),
    );
  }

  /// Convert LightReading to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      'lux_value': lux,
      if (ppfdValue != null) 'ppfd_value': ppfdValue,
      if (estimatedPpfd != null) 'estimated_ppfd': estimatedPpfd,
      'source': source,
      if (lightSourceProfile != null) 'light_source_profile': lightSourceProfile,
      if (locationName != null) 'location_name': locationName,
      if (gpsLatitude != null) 'gps_latitude': gpsLatitude,
      if (gpsLongitude != null) 'gps_longitude': gpsLongitude,
      if (altitude != null) 'altitude': altitude,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (accuracyEstimate != null) 'accuracy_estimate': accuracyEstimate,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      'is_calibrated': isCalibrated,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceId != null) 'device_id': deviceId,
      if (rawData != null) 'raw_data': rawData,
      'measured_at': takenAt,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  /// Create a copy of this LightReading with updated fields
  LightReading copyWith({
    String? id,
    String? plantId,
    double? lux,
    double? ppfdValue,
    double? estimatedPpfd,
    String? source,
    String? lightSourceProfile,
    String? locationName,
    double? gpsLatitude,
    double? gpsLongitude,
    double? altitude,
    double? temperature,
    double? humidity,
    double? accuracyEstimate,
    double? confidenceScore,
    bool? isCalibrated,
    String? deviceModel,
    String? deviceId,
    Map<String, dynamic>? rawData,
    String? takenAt,
    String? createdAt,
  }) {
    return LightReading(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      lux: lux ?? this.lux,
      ppfdValue: ppfdValue ?? this.ppfdValue,
      estimatedPpfd: estimatedPpfd ?? this.estimatedPpfd,
      source: source ?? this.source,
      lightSourceProfile: lightSourceProfile ?? this.lightSourceProfile,
      locationName: locationName ?? this.locationName,
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      altitude: altitude ?? this.altitude,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      accuracyEstimate: accuracyEstimate ?? this.accuracyEstimate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceId: deviceId ?? this.deviceId,
      rawData: rawData ?? this.rawData,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'LightReading(id: $id, lux: $lux, source: $source, takenAt: $takenAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LightReading &&
        other.id == id &&
        other.lux == lux &&
        other.source == source &&
        other.takenAt == takenAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, lux, source, takenAt);
  }
}

/// Light measurement context for additional metadata
class LightMeasurementContext {
  /// Environmental temperature in Celsius
  final double? temperature;
  
  /// Environmental humidity percentage
  final double? humidity;
  
  /// Location name
  final String? locationName;
  
  /// GPS coordinates
  final double? latitude;
  final double? longitude;
  
  /// Altitude in meters
  final double? altitude;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const LightMeasurementContext({
    this.temperature,
    this.humidity,
    this.locationName,
    this.latitude,
    this.longitude,
    this.altitude,
    this.metadata,
  });

  /// Create context from JSON
  factory LightMeasurementContext.fromJson(Map<String, dynamic> json) {
    return LightMeasurementContext(
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      locationName: json['location_name']?.toString(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert context to JSON
  Map<String, dynamic> toJson() {
    return {
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Calibration profile for light measurements
class CalibrationProfile {
  /// Profile identifier
  final String id;
  
  /// Profile name
  final String name;
  
  /// Device model this profile applies to
  final String deviceModel;
  
  /// Calibration factor
  final double factor;
  
  /// Light source type
  final String lightSource;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Whether this profile is active
  final bool isActive;

  const CalibrationProfile({
    required this.id,
    required this.name,
    required this.deviceModel,
    required this.factor,
    required this.lightSource,
    required this.createdAt,
    this.isActive = true,
  });

  /// Create profile from JSON
  factory CalibrationProfile.fromJson(Map<String, dynamic> json) {
    return CalibrationProfile(
      id: json['id'].toString(),
      name: json['name'].toString(),
      deviceModel: json['device_model'].toString(),
      factor: json['factor'].toDouble(),
      lightSource: json['light_source'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Convert profile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'device_model': deviceModel,
      'factor': factor,
      'light_source': lightSource,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}