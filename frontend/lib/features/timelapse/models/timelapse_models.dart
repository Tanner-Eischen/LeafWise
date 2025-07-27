library timelapse_models;

/// Time-lapse growth tracking data models
/// 
/// This file contains all data models related to time-lapse photo capture,
/// growth analysis, milestone detection, and video generation.
/// Uses manual class implementations for immutable data classes with JSON serialization.

/// Time-lapse tracking session configuration and state
class TimelapseSession {
  final String sessionId;
  final String plantId;
  final String userId;
  final String sessionName;
  final DateTime startDate;
  final DateTime? endDate;
  final PhotoSchedule photoSchedule;
  final TrackingConfig trackingConfig;
  final GrowthMetrics currentMetrics;
  final List<MilestoneTarget> milestoneTargets;
  final String status; // 'active', 'paused', 'completed', 'cancelled'
  final DateTime? createdAt;

  const TimelapseSession({
    required this.sessionId,
    required this.plantId,
    required this.userId,
    required this.sessionName,
    required this.startDate,
    this.endDate,
    required this.photoSchedule,
    required this.trackingConfig,
    required this.currentMetrics,
    required this.milestoneTargets,
    required this.status,
    this.createdAt,
  });

  factory TimelapseSession.fromJson(Map<String, dynamic> json) {
    return TimelapseSession(
      sessionId: json['sessionId'] as String,
      plantId: json['plantId'] as String,
      userId: json['userId'] as String,
      sessionName: json['sessionName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      photoSchedule: PhotoSchedule.fromJson(json['photoSchedule'] as Map<String, dynamic>),
      trackingConfig: TrackingConfig.fromJson(json['trackingConfig'] as Map<String, dynamic>),
      currentMetrics: GrowthMetrics.fromJson(json['currentMetrics'] as Map<String, dynamic>),
      milestoneTargets: (json['milestoneTargets'] as List)
          .map((e) => MilestoneTarget.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'plantId': plantId,
      'userId': userId,
      'sessionName': sessionName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'photoSchedule': photoSchedule.toJson(),
      'trackingConfig': trackingConfig.toJson(),
      'currentMetrics': currentMetrics.toJson(),
      'milestoneTargets': milestoneTargets.map((e) => e.toJson()).toList(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  TimelapseSession copyWith({
    String? sessionId,
    String? plantId,
    String? userId,
    String? sessionName,
    DateTime? startDate,
    DateTime? endDate,
    PhotoSchedule? photoSchedule,
    TrackingConfig? trackingConfig,
    GrowthMetrics? currentMetrics,
    List<MilestoneTarget>? milestoneTargets,
    String? status,
    DateTime? createdAt,
  }) {
    return TimelapseSession(
      sessionId: sessionId ?? this.sessionId,
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      sessionName: sessionName ?? this.sessionName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      photoSchedule: photoSchedule ?? this.photoSchedule,
      trackingConfig: trackingConfig ?? this.trackingConfig,
      currentMetrics: currentMetrics ?? this.currentMetrics,
      milestoneTargets: milestoneTargets ?? this.milestoneTargets,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Photo capture scheduling configuration
class PhotoSchedule {
  final String frequency; // 'daily', 'weekly', 'custom'
  final int intervalDays;
  final String preferredTime; // '09:00', '12:00', etc.
  final List<String> reminderDays; // ['monday', 'wednesday', 'friday']
  final bool enableReminders;
  final bool adaptToLighting;

  const PhotoSchedule({
    required this.frequency,
    required this.intervalDays,
    required this.preferredTime,
    required this.reminderDays,
    this.enableReminders = true,
    this.adaptToLighting = true,
  });

  factory PhotoSchedule.fromJson(Map<String, dynamic> json) {
    return PhotoSchedule(
      frequency: json['frequency'] as String,
      intervalDays: json['intervalDays'] as int,
      preferredTime: json['preferredTime'] as String,
      reminderDays: List<String>.from(json['reminderDays'] as List),
      enableReminders: json['enableReminders'] as bool? ?? true,
      adaptToLighting: json['adaptToLighting'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'intervalDays': intervalDays,
      'preferredTime': preferredTime,
      'reminderDays': reminderDays,
      'enableReminders': enableReminders,
      'adaptToLighting': adaptToLighting,
    };
  }

  PhotoSchedule copyWith({
    String? frequency,
    int? intervalDays,
    String? preferredTime,
    List<String>? reminderDays,
    bool? enableReminders,
    bool? adaptToLighting,
  }) {
    return PhotoSchedule(
      frequency: frequency ?? this.frequency,
      intervalDays: intervalDays ?? this.intervalDays,
      preferredTime: preferredTime ?? this.preferredTime,
      reminderDays: reminderDays ?? this.reminderDays,
      enableReminders: enableReminders ?? this.enableReminders,
      adaptToLighting: adaptToLighting ?? this.adaptToLighting,
    );
  }
}

/// Tracking configuration for growth analysis
class TrackingConfig {
  final String trackingMode; // 'automatic', 'manual', 'guided'
  final List<String> measurementTypes; // ['height', 'width', 'leaf_count']
  final bool enableGrowthAnalysis;
  final bool enableMilestoneDetection;
  final bool enableAnomalyDetection;
  final Map<String, dynamic>? customSettings;

  const TrackingConfig({
    required this.trackingMode,
    required this.measurementTypes,
    this.enableGrowthAnalysis = true,
    this.enableMilestoneDetection = true,
    this.enableAnomalyDetection = false,
    this.customSettings,
  });

  factory TrackingConfig.fromJson(Map<String, dynamic> json) {
    return TrackingConfig(
      trackingMode: json['trackingMode'] as String,
      measurementTypes: List<String>.from(json['measurementTypes'] as List),
      enableGrowthAnalysis: json['enableGrowthAnalysis'] as bool? ?? true,
      enableMilestoneDetection: json['enableMilestoneDetection'] as bool? ?? true,
      enableAnomalyDetection: json['enableAnomalyDetection'] as bool? ?? false,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingMode': trackingMode,
      'measurementTypes': measurementTypes,
      'enableGrowthAnalysis': enableGrowthAnalysis,
      'enableMilestoneDetection': enableMilestoneDetection,
      'enableAnomalyDetection': enableAnomalyDetection,
      'customSettings': customSettings,
    };
  }

  TrackingConfig copyWith({
    String? trackingMode,
    List<String>? measurementTypes,
    bool? enableGrowthAnalysis,
    bool? enableMilestoneDetection,
    bool? enableAnomalyDetection,
    Map<String, dynamic>? customSettings,
  }) {
    return TrackingConfig(
      trackingMode: trackingMode ?? this.trackingMode,
      measurementTypes: measurementTypes ?? this.measurementTypes,
      enableGrowthAnalysis: enableGrowthAnalysis ?? this.enableGrowthAnalysis,
      enableMilestoneDetection: enableMilestoneDetection ?? this.enableMilestoneDetection,
      enableAnomalyDetection: enableAnomalyDetection ?? this.enableAnomalyDetection,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Current growth metrics for a plant
class GrowthMetrics {
  final PlantMeasurements latestMeasurements;
  final double growthRate; // cm per week
  final int totalPhotos;
  final int daysTracked;
  final DateTime? lastPhotoDate;
  final DateTime? nextScheduledPhoto;

  const GrowthMetrics({
    required this.latestMeasurements,
    required this.growthRate,
    required this.totalPhotos,
    required this.daysTracked,
    this.lastPhotoDate,
    this.nextScheduledPhoto,
  });

  factory GrowthMetrics.fromJson(Map<String, dynamic> json) {
    return GrowthMetrics(
      latestMeasurements: PlantMeasurements.fromJson(json['latestMeasurements'] as Map<String, dynamic>),
      growthRate: (json['growthRate'] as num).toDouble(),
      totalPhotos: json['totalPhotos'] as int,
      daysTracked: json['daysTracked'] as int,
      lastPhotoDate: json['lastPhotoDate'] != null ? DateTime.parse(json['lastPhotoDate'] as String) : null,
      nextScheduledPhoto: json['nextScheduledPhoto'] != null ? DateTime.parse(json['nextScheduledPhoto'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestMeasurements': latestMeasurements.toJson(),
      'growthRate': growthRate,
      'totalPhotos': totalPhotos,
      'daysTracked': daysTracked,
      'lastPhotoDate': lastPhotoDate?.toIso8601String(),
      'nextScheduledPhoto': nextScheduledPhoto?.toIso8601String(),
    };
  }

  GrowthMetrics copyWith({
    PlantMeasurements? latestMeasurements,
    double? growthRate,
    int? totalPhotos,
    int? daysTracked,
    DateTime? lastPhotoDate,
    DateTime? nextScheduledPhoto,
  }) {
    return GrowthMetrics(
      latestMeasurements: latestMeasurements ?? this.latestMeasurements,
      growthRate: growthRate ?? this.growthRate,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      daysTracked: daysTracked ?? this.daysTracked,
      lastPhotoDate: lastPhotoDate ?? this.lastPhotoDate,
      nextScheduledPhoto: nextScheduledPhoto ?? this.nextScheduledPhoto,
    );
  }
}

/// Target milestones for growth tracking
class MilestoneTarget {
  final String milestoneId;
  final String name;
  final String description;
  final String targetType; // 'height', 'flowering', 'leaf_count'
  final double targetValue;
  final String unit;
  final bool isAchieved;
  final DateTime? achievedDate;

  const MilestoneTarget({
    required this.milestoneId,
    required this.name,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.unit,
    this.isAchieved = false,
    this.achievedDate,
  });

  factory MilestoneTarget.fromJson(Map<String, dynamic> json) {
    return MilestoneTarget(
      milestoneId: json['milestoneId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetType: json['targetType'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      isAchieved: json['isAchieved'] as bool? ?? false,
      achievedDate: json['achievedDate'] != null ? DateTime.parse(json['achievedDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'name': name,
      'description': description,
      'targetType': targetType,
      'targetValue': targetValue,
      'unit': unit,
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
    };
  }

  MilestoneTarget copyWith({
    String? milestoneId,
    String? name,
    String? description,
    String? targetType,
    double? targetValue,
    String? unit,
    bool? isAchieved,
    DateTime? achievedDate,
  }) {
    return MilestoneTarget(
      milestoneId: milestoneId ?? this.milestoneId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedDate: achievedDate ?? this.achievedDate,
    );
  }
}

/// Physical measurements of the plant
class PlantMeasurements {
  final double height;
  final double width;
  final int leafCount;
  final double stemDiameter;
  final String? unit; // 'cm', 'inches'
  final Map<String, double>? additionalMeasurements;

  const PlantMeasurements({
    required this.height,
    required this.width,
    required this.leafCount,
    required this.stemDiameter,
    this.unit,
    this.additionalMeasurements,
  });

  factory PlantMeasurements.fromJson(Map<String, dynamic> json) {
    return PlantMeasurements(
      height: (json['height'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      leafCount: json['leafCount'] as int,
      stemDiameter: (json['stemDiameter'] as num).toDouble(),
      unit: json['unit'] as String?,
      additionalMeasurements: json['additionalMeasurements'] != null
          ? Map<String, double>.from(json['additionalMeasurements'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'leafCount': leafCount,
      'stemDiameter': stemDiameter,
      'unit': unit,
      'additionalMeasurements': additionalMeasurements,
    };
  }

  PlantMeasurements copyWith({
    double? height,
    double? width,
    int? leafCount,
    double? stemDiameter,
    String? unit,
    Map<String, double>? additionalMeasurements,
  }) {
    return PlantMeasurements(
      height: height ?? this.height,
      width: width ?? this.width,
      leafCount: leafCount ?? this.leafCount,
      stemDiameter: stemDiameter ?? this.stemDiameter,
      unit: unit ?? this.unit,
      additionalMeasurements: additionalMeasurements ?? this.additionalMeasurements,
    );
  }
}

/// Health indicators from visual analysis
class HealthIndicators {
  final double overallHealth; // 0.0 to 1.0
  final double leafHealth;
  final double stemHealth;
  final String colorAnalysis;
  final List<String> healthConcerns;
  final Map<String, double>? detailedScores;

  const HealthIndicators({
    required this.overallHealth,
    required this.leafHealth,
    required this.stemHealth,
    required this.colorAnalysis,
    required this.healthConcerns,
    this.detailedScores,
  });

  factory HealthIndicators.fromJson(Map<String, dynamic> json) {
    return HealthIndicators(
      overallHealth: (json['overallHealth'] as num).toDouble(),
      leafHealth: (json['leafHealth'] as num).toDouble(),
      stemHealth: (json['stemHealth'] as num).toDouble(),
      colorAnalysis: json['colorAnalysis'] as String,
      healthConcerns: List<String>.from(json['healthConcerns'] as List),
      detailedScores: json['detailedScores'] != null
          ? Map<String, double>.from(json['detailedScores'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallHealth': overallHealth,
      'leafHealth': leafHealth,
      'stemHealth': stemHealth,
      'colorAnalysis': colorAnalysis,
      'healthConcerns': healthConcerns,
      'detailedScores': detailedScores,
    };
  }

  HealthIndicators copyWith({
    double? overallHealth,
    double? leafHealth,
    double? stemHealth,
    String? colorAnalysis,
    List<String>? healthConcerns,
    Map<String, double>? detailedScores,
  }) {
    return HealthIndicators(
      overallHealth: overallHealth ?? this.overallHealth,
      leafHealth: leafHealth ?? this.leafHealth,
      stemHealth: stemHealth ?? this.stemHealth,
      colorAnalysis: colorAnalysis ?? this.colorAnalysis,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      detailedScores: detailedScores ?? this.detailedScores,
    );
  }
}

/// Changes detected between photos
class GrowthChanges {
  final double heightChange;
  final double widthChange;
  final int leafCountChange;
  final double growthRate;
  final String changeDescription;
  final DateTime? comparedToDate;

  const GrowthChanges({
    required this.heightChange,
    required this.widthChange,
    required this.leafCountChange,
    required this.growthRate,
    required this.changeDescription,
    this.comparedToDate,
  });

  factory GrowthChanges.fromJson(Map<String, dynamic> json) {
    return GrowthChanges(
      heightChange: (json['heightChange'] as num).toDouble(),
      widthChange: (json['widthChange'] as num).toDouble(),
      leafCountChange: json['leafCountChange'] as int,
      growthRate: (json['growthRate'] as num).toDouble(),
      changeDescription: json['changeDescription'] as String,
      comparedToDate: json['comparedToDate'] != null ? DateTime.parse(json['comparedToDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heightChange': heightChange,
      'widthChange': widthChange,
      'leafCountChange': leafCountChange,
      'growthRate': growthRate,
      'changeDescription': changeDescription,
      'comparedToDate': comparedToDate?.toIso8601String(),
    };
  }

  GrowthChanges copyWith({
    double? heightChange,
    double? widthChange,
    int? leafCountChange,
    double? growthRate,
    String? changeDescription,
    DateTime? comparedToDate,
  }) {
    return GrowthChanges(
      heightChange: heightChange ?? this.heightChange,
      widthChange: widthChange ?? this.widthChange,
      leafCountChange: leafCountChange ?? this.leafCountChange,
      growthRate: growthRate ?? this.growthRate,
      changeDescription: changeDescription ?? this.changeDescription,
      comparedToDate: comparedToDate ?? this.comparedToDate,
    );
  }
}

/// Anomaly detection flags
class AnomalyFlag {
  final String anomalyType;
  final String severity; // 'low', 'medium', 'high'
  final String description;
  final double confidence;
  final List<String>? recommendations;

  const AnomalyFlag({
    required this.anomalyType,
    required this.severity,
    required this.description,
    required this.confidence,
    this.recommendations,
  });

  factory AnomalyFlag.fromJson(Map<String, dynamic> json) {
    return AnomalyFlag(
      anomalyType: json['anomalyType'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anomalyType': anomalyType,
      'severity': severity,
      'description': description,
      'confidence': confidence,
      'recommendations': recommendations,
    };
  }

  AnomalyFlag copyWith({
    String? anomalyType,
    String? severity,
    String? description,
    double? confidence,
    List<String>? recommendations,
  }) {
    return AnomalyFlag(
      anomalyType: anomalyType ?? this.anomalyType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

/// Growth analysis result from photo processing
class GrowthAnalysis {
  final String photoId;
  final String sessionId;
  final DateTime captureDate;
  final PlantMeasurements plantMeasurements;
  final HealthIndicators healthIndicators;
  final GrowthChanges growthChanges;
  final List<AnomalyFlag> anomalyFlags;
  final double analysisConfidence;

  const GrowthAnalysis({
    required this.photoId,
    required this.sessionId,
    required this.captureDate,
    required this.plantMeasurements,
    required this.healthIndicators,
    required this.growthChanges,
    required this.anomalyFlags,
    required this.analysisConfidence,
  });

  factory GrowthAnalysis.fromJson(Map<String, dynamic> json) {
    return GrowthAnalysis(
      photoId: json['photoId'] as String,
      sessionId: json['sessionId'] as String,
      captureDate: DateTime.parse(json['captureDate'] as String),
      plantMeasurements: PlantMeasurements.fromJson(json['plantMeasurements'] as Map<String, dynamic>),
      healthIndicators: HealthIndicators.fromJson(json['healthIndicators'] as Map<String, dynamic>),
      growthChanges: GrowthChanges.fromJson(json['growthChanges'] as Map<String, dynamic>),
      anomalyFlags: (json['anomalyFlags'] as List)
          .map((e) => AnomalyFlag.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysisConfidence: (json['analysisConfidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'sessionId': sessionId,
      'captureDate': captureDate.toIso8601String(),
      'plantMeasurements': plantMeasurements.toJson(),
      'healthIndicators': healthIndicators.toJson(),
      'growthChanges': growthChanges.toJson(),
      'anomalyFlags': anomalyFlags.map((e) => e.toJson()).toList(),
      'analysisConfidence': analysisConfidence,
    };
  }

  GrowthAnalysis copyWith({
    String? photoId,
    String? sessionId,
    DateTime? captureDate,
    PlantMeasurements? plantMeasurements,
    HealthIndicators? healthIndicators,
    GrowthChanges? growthChanges,
    List<AnomalyFlag>? anomalyFlags,
    double? analysisConfidence,
  }) {
    return GrowthAnalysis(
      photoId: photoId ?? this.photoId,
      sessionId: sessionId ?? this.sessionId,
      captureDate: captureDate ?? this.captureDate,
      plantMeasurements: plantMeasurements ?? this.plantMeasurements,
      healthIndicators: healthIndicators ?? this.healthIndicators,
      growthChanges: growthChanges ?? this.growthChanges,
      anomalyFlags: anomalyFlags ?? this.anomalyFlags,
      analysisConfidence: analysisConfidence ?? this.analysisConfidence,
    );
  }
}

/// Growth milestone achievement
class GrowthMilestone {
  final String milestoneId;
  final String sessionId;
  final String name;
  final String description;
  final DateTime achievedDate;
  final String photoId;
  final Map<String, dynamic> achievementData;

  const GrowthMilestone({
    required this.milestoneId,
    required this.sessionId,
    required this.name,
    required this.description,
    required this.achievedDate,
    required this.photoId,
    required this.achievementData,
  });

  factory GrowthMilestone.fromJson(Map<String, dynamic> json) {
    return GrowthMilestone(
      milestoneId: json['milestoneId'] as String,
      sessionId: json['sessionId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      achievedDate: DateTime.parse(json['achievedDate'] as String),
      photoId: json['photoId'] as String,
      achievementData: Map<String, dynamic>.from(json['achievementData'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'sessionId': sessionId,
      'name': name,
      'description': description,
      'achievedDate': achievedDate.toIso8601String(),
      'photoId': photoId,
      'achievementData': achievementData,
    };
  }

  GrowthMilestone copyWith({
    String? milestoneId,
    String? sessionId,
    String? name,
    String? description,
    DateTime? achievedDate,
    String? photoId,
    Map<String, dynamic>? achievementData,
  }) {
    return GrowthMilestone(
      milestoneId: milestoneId ?? this.milestoneId,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      description: description ?? this.description,
      achievedDate: achievedDate ?? this.achievedDate,
      photoId: photoId ?? this.photoId,
      achievementData: achievementData ?? this.achievementData,
    );
  }
}