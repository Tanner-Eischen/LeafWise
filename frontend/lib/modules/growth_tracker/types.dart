/// Growth Tracker Types
/// 
/// This file contains type definitions for the growth tracker module,
/// including data models for growth photos, metrics, and tracking data.
library;

import 'package:collection/collection.dart';

/// Represents a growth photo captured for plant tracking
class GrowthPhoto {
  /// Plant identifier
  final String plantId;
  
  /// Local file URI for the photo
  final String localUri;
  
  /// Timestamp when the photo was taken
  final String takenAt;
  
  /// Upload status of the photo
  final String uploadStatus;
  
  /// Optional metrics extracted from the photo
  final Map<String, dynamic>? metrics;
  
  /// Optional location tag for the photo
  final String? locationTag;

  const GrowthPhoto({
    required this.plantId,
    required this.localUri,
    required this.takenAt,
    required this.uploadStatus,
    this.metrics,
    this.locationTag,
  });

  /// Create a GrowthPhoto from JSON data
  factory GrowthPhoto.fromJson(Map<String, dynamic> json) {
    return GrowthPhoto(
      plantId: json['plant_id'] as String,
      localUri: json['local_uri'] as String,
      takenAt: json['taken_at'] as String,
      uploadStatus: json['upload_status'] as String,
      metrics: json['metrics'] as Map<String, dynamic>?,
      locationTag: json['location_tag'] as String?,
    );
  }

  /// Convert GrowthPhoto to JSON
  Map<String, dynamic> toJson() {
    return {
      'plant_id': plantId,
      'local_uri': localUri,
      'taken_at': takenAt,
      'upload_status': uploadStatus,
      if (metrics != null) 'metrics': metrics,
      if (locationTag != null) 'location_tag': locationTag,
    };
  }

  /// Create a copy of this GrowthPhoto with updated fields
  GrowthPhoto copyWith({
    String? plantId,
    String? localUri,
    String? takenAt,
    String? uploadStatus,
    Map<String, dynamic>? metrics,
    String? locationTag,
  }) {
    return GrowthPhoto(
      plantId: plantId ?? this.plantId,
      localUri: localUri ?? this.localUri,
      takenAt: takenAt ?? this.takenAt,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      metrics: metrics ?? this.metrics,
      locationTag: locationTag ?? this.locationTag,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthPhoto &&
        other.plantId == plantId &&
        other.localUri == localUri &&
        other.takenAt == takenAt &&
        other.uploadStatus == uploadStatus &&
        other.metrics == metrics &&
        other.locationTag == locationTag;
  }

  @override
  int get hashCode {
    return Object.hash(
      plantId,
      localUri,
      takenAt,
      uploadStatus,
      metrics,
      locationTag,
    );
  }

  @override
  String toString() {
    return 'GrowthPhoto(plantId: $plantId, localUri: $localUri, takenAt: $takenAt, uploadStatus: $uploadStatus, metrics: $metrics, locationTag: $locationTag)';
  }
}

/// Represents growth metrics for a plant
class GrowthMetrics {
  /// Plant height in centimeters
  final double? height;
  
  /// Plant width in centimeters
  final double? width;
  
  /// Number of leaves
  final int? leafCount;
  
  /// Health score (0-100)
  final double? healthScore;
  
  /// Growth stage identifier
  final String? growthStage;
  
  /// Additional custom metrics
  final Map<String, dynamic>? customMetrics;

  const GrowthMetrics({
    this.height,
    this.width,
    this.leafCount,
    this.healthScore,
    this.growthStage,
    this.customMetrics,
  });

  /// Create GrowthMetrics from JSON data
  factory GrowthMetrics.fromJson(Map<String, dynamic> json) {
    return GrowthMetrics(
      height: json['height']?.toDouble(),
      width: json['width']?.toDouble(),
      leafCount: json['leaf_count'] as int?,
      healthScore: json['health_score']?.toDouble(),
      growthStage: json['growth_stage'] as String?,
      customMetrics: json['custom_metrics'] as Map<String, dynamic>?,
    );
  }

  /// Convert GrowthMetrics to JSON
  Map<String, dynamic> toJson() {
    return {
      if (height != null) 'height': height,
      if (width != null) 'width': width,
      if (leafCount != null) 'leaf_count': leafCount,
      if (healthScore != null) 'health_score': healthScore,
      if (growthStage != null) 'growth_stage': growthStage,
      if (customMetrics != null) 'custom_metrics': customMetrics,
    };
  }

  /// Create a copy of this GrowthMetrics with updated fields
  GrowthMetrics copyWith({
    double? height,
    double? width,
    int? leafCount,
    double? healthScore,
    String? growthStage,
    Map<String, dynamic>? customMetrics,
  }) {
    return GrowthMetrics(
      height: height ?? this.height,
      width: width ?? this.width,
      leafCount: leafCount ?? this.leafCount,
      healthScore: healthScore ?? this.healthScore,
      growthStage: growthStage ?? this.growthStage,
      customMetrics: customMetrics ?? this.customMetrics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GrowthMetrics &&
        other.height == height &&
        other.width == width &&
        other.leafCount == leafCount &&
        other.healthScore == healthScore &&
        other.growthStage == growthStage &&
        const DeepCollectionEquality().equals(other.customMetrics, customMetrics);
  }

  @override
  int get hashCode {
    return Object.hash(
      height,
      width,
      leafCount,
      healthScore,
      growthStage,
      customMetrics,
    );
  }

  @override
  String toString() {
    return 'GrowthMetrics(height: $height, width: $width, leafCount: $leafCount, healthScore: $healthScore, growthStage: $growthStage, customMetrics: $customMetrics)';
  }
}