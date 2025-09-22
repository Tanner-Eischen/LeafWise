/// AR Seasonal Visualization Models
///
/// Data models specifically for AR seasonal overlays and time-lapse preview functionality.
/// These models extend the base seasonal AI models with AR-specific visualization data.
library;

import 'package:leafwise/features/seasonal_ai/models/seasonal_ai_models.dart';
import 'package:leafwise/features/timelapse/models/timelapse_models.dart';

/// AR-specific seasonal overlay data
class ARSeasonalOverlay {
  final String plantId;
  final SeasonalPrediction prediction;
  final ARVisualizationConfig config;
  final List<AROverlayElement> overlayElements;
  final ARTrackingState trackingState;
  final DateTime? lastUpdated;

  const ARSeasonalOverlay({
    required this.plantId,
    required this.prediction,
    required this.config,
    required this.overlayElements,
    required this.trackingState,
    this.lastUpdated,
  });

  ARSeasonalOverlay copyWith({
    String? plantId,
    SeasonalPrediction? prediction,
    ARVisualizationConfig? config,
    List<AROverlayElement>? overlayElements,
    ARTrackingState? trackingState,
    DateTime? lastUpdated,
  }) {
    return ARSeasonalOverlay(
      plantId: plantId ?? this.plantId,
      prediction: prediction ?? this.prediction,
      config: config ?? this.config,
      overlayElements: overlayElements ?? this.overlayElements,
      trackingState: trackingState ?? this.trackingState,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Configuration for AR visualization
class ARVisualizationConfig {
  final double overlayOpacity;
  final bool showPredictions;
  final bool showCareAdjustments;
  final bool showRiskFactors;
  final bool showGrowthProjections;
  final String detailLevel; // 'minimal', 'medium', 'detailed'
  final List<String> enabledOverlayTypes;

  const ARVisualizationConfig({
    this.overlayOpacity = 0.8,
    this.showPredictions = true,
    this.showCareAdjustments = true,
    this.showRiskFactors = true,
    this.showGrowthProjections = false,
    this.detailLevel = 'medium',
    this.enabledOverlayTypes = const [],
  });

  ARVisualizationConfig copyWith({
    double? overlayOpacity,
    bool? showPredictions,
    bool? showCareAdjustments,
    bool? showRiskFactors,
    bool? showGrowthProjections,
    String? detailLevel,
    List<String>? enabledOverlayTypes,
  }) {
    return ARVisualizationConfig(
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      showPredictions: showPredictions ?? this.showPredictions,
      showCareAdjustments: showCareAdjustments ?? this.showCareAdjustments,
      showRiskFactors: showRiskFactors ?? this.showRiskFactors,
      showGrowthProjections:
          showGrowthProjections ?? this.showGrowthProjections,
      detailLevel: detailLevel ?? this.detailLevel,
      enabledOverlayTypes: enabledOverlayTypes ?? this.enabledOverlayTypes,
    );
  }
}

/// Individual AR overlay element
class AROverlayElement {
  final String elementId;
  final String
  type; // 'prediction', 'care_tip', 'risk_warning', 'growth_projection'
  final ARPosition position;
  final String content;
  final ARElementStyle style;
  final double confidence;
  final bool isVisible;
  final DateTime? expiresAt;

  const AROverlayElement({
    required this.elementId,
    required this.type,
    required this.position,
    required this.content,
    required this.style,
    this.confidence = 1.0,
    this.isVisible = true,
    this.expiresAt,
  });
}

/// 3D position in AR space
class ARPosition {
  final double x;
  final double y;
  final double z;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double scale;

  const ARPosition({
    required this.x,
    required this.y,
    required this.z,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.scale = 1.0,
  });
}

/// Styling for AR overlay elements
class ARElementStyle {
  final String backgroundColor;
  final String textColor;
  final String borderColor;
  final double fontSize;
  final double padding;
  final double borderRadius;
  final double borderWidth;
  final String? iconName;
  final String? iconColor;

  const ARElementStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.fontSize = 12.0,
    this.padding = 8.0,
    this.borderRadius = 4.0,
    this.borderWidth = 1.0,
    this.iconName,
    this.iconColor,
  });
}

/// AR tracking state for plant positioning
class ARTrackingState {
  final bool isTracking;
  final double confidence;
  final ARPosition? plantPosition;
  final String status; // 'initializing', 'tracking', 'lost', 'error'
  final DateTime? lastTrackingUpdate;
  final String? errorMessage;

  const ARTrackingState({
    this.isTracking = false,
    this.confidence = 0.0,
    this.plantPosition,
    this.status = 'initializing',
    this.lastTrackingUpdate,
    this.errorMessage,
  });

  ARTrackingState copyWith({
    bool? isTracking,
    double? confidence,
    ARPosition? plantPosition,
    String? status,
    DateTime? lastTrackingUpdate,
    String? errorMessage,
  }) {
    return ARTrackingState(
      isTracking: isTracking ?? this.isTracking,
      confidence: confidence ?? this.confidence,
      plantPosition: plantPosition ?? this.plantPosition,
      status: status ?? this.status,
      lastTrackingUpdate: lastTrackingUpdate ?? this.lastTrackingUpdate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Growth projection visualization data
class ARGrowthProjection {
  final String plantId;
  final List<GrowthStageVisualization> stages;
  final ARProjectionConfig config;
  final int currentStageIndex;
  final DateTime? projectionDate;

  const ARGrowthProjection({
    required this.plantId,
    required this.stages,
    required this.config,
    this.currentStageIndex = 0,
    this.projectionDate,
  });

  ARGrowthProjection copyWith({
    String? plantId,
    List<GrowthStageVisualization>? stages,
    ARProjectionConfig? config,
    int? currentStageIndex,
    DateTime? projectionDate,
  }) {
    return ARGrowthProjection(
      plantId: plantId ?? this.plantId,
      stages: stages ?? this.stages,
      config: config ?? this.config,
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      projectionDate: projectionDate ?? this.projectionDate,
    );
  }
}

/// Individual growth stage for AR visualization
class GrowthStageVisualization {
  final String stageId;
  final String name;
  final DateTime projectedDate;
  final ARPlantModel plantModel;
  final String description;
  final double probability;
  final bool isCurrentStage;

  const GrowthStageVisualization({
    required this.stageId,
    required this.name,
    required this.projectedDate,
    required this.plantModel,
    required this.description,
    this.probability = 1.0,
    this.isCurrentStage = false,
  });
}

/// 3D plant model data for AR
class ARPlantModel {
  final double height;
  final double width;
  final int leafCount;
  final String leafColor;
  final String stemColor;
  final List<ARFlower> flowers;
  final List<ARFruit> fruits;
  final String? modelUrl;
  final String? textureUrl;

  const ARPlantModel({
    required this.height,
    required this.width,
    required this.leafCount,
    required this.leafColor,
    required this.stemColor,
    this.flowers = const [],
    this.fruits = const [],
    this.modelUrl,
    this.textureUrl,
  });
}

/// AR flower representation
class ARFlower {
  final ARPosition position;
  final String color;
  final double size;
  final String type;

  const ARFlower({
    required this.position,
    required this.color,
    required this.size,
    required this.type,
  });
}

/// AR fruit representation
class ARFruit {
  final ARPosition position;
  final String color;
  final double size;
  final String type;
  final double ripeness; // 0.0 to 1.0

  const ARFruit({
    required this.position,
    required this.color,
    required this.size,
    required this.type,
    this.ripeness = 0.0,
  });
}

/// Configuration for growth projections
class ARProjectionConfig {
  final bool showTimeline;
  final bool enableInteraction;
  final bool showProbabilities;
  final String transitionStyle; // 'smooth', 'discrete', 'morphing'
  final double animationDuration;

  const ARProjectionConfig({
    this.showTimeline = true,
    this.enableInteraction = true,
    this.showProbabilities = false,
    this.transitionStyle = 'smooth',
    this.animationDuration = 2.0,
  });
}

/// Time-lapse preview data for AR
class ARTimelapsePreview {
  final String sessionId;
  final List<TimelapseFrame> frames;
  final ARTimelapseControls controls;
  final int currentFrameIndex;
  final bool isPlaying;
  final double playbackSpeed;

  const ARTimelapsePreview({
    required this.sessionId,
    required this.frames,
    required this.controls,
    this.currentFrameIndex = 0,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
  });

  ARTimelapsePreview copyWith({
    String? sessionId,
    List<TimelapseFrame>? frames,
    ARTimelapseControls? controls,
    int? currentFrameIndex,
    bool? isPlaying,
    double? playbackSpeed,
  }) {
    return ARTimelapsePreview(
      sessionId: sessionId ?? this.sessionId,
      frames: frames ?? this.frames,
      controls: controls ?? this.controls,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

/// Individual frame in AR time-lapse
class TimelapseFrame {
  final String frameId;
  final DateTime captureDate;
  final ARPlantModel plantModel;
  final PlantMeasurements measurements;
  final String? thumbnailUrl;
  final String? fullImageUrl;

  const TimelapseFrame({
    required this.frameId,
    required this.captureDate,
    required this.plantModel,
    required this.measurements,
    this.thumbnailUrl,
    this.fullImageUrl,
  });
}

/// Controls for AR time-lapse playback
class ARTimelapseControls {
  final bool showPlayButton;
  final bool showScrubber;
  final bool showSpeedControl;
  final bool showFrameInfo;
  final bool enableLooping;
  final List<double> availableSpeeds;

  const ARTimelapseControls({
    this.showPlayButton = true,
    this.showScrubber = true,
    this.showSpeedControl = true,
    this.showFrameInfo = true,
    this.enableLooping = false,
    this.availableSpeeds = const [0.5, 1.0, 2.0, 4.0],
  });
}

/// Seasonal transformation visualization
class ARSeasonalTransformation {
  final String plantId;
  final String currentSeason;
  final String targetSeason;
  final ARPlantModel beforeModel;
  final ARPlantModel afterModel;
  final List<TransformationStep> steps;
  final double progress; // 0.0 to 1.0

  const ARSeasonalTransformation({
    required this.plantId,
    required this.currentSeason,
    required this.targetSeason,
    required this.beforeModel,
    required this.afterModel,
    required this.steps,
    this.progress = 0.0,
  });

  ARSeasonalTransformation copyWith({
    String? plantId,
    String? currentSeason,
    String? targetSeason,
    ARPlantModel? beforeModel,
    ARPlantModel? afterModel,
    List<TransformationStep>? steps,
    double? progress,
  }) {
    return ARSeasonalTransformation(
      plantId: plantId ?? this.plantId,
      currentSeason: currentSeason ?? this.currentSeason,
      targetSeason: targetSeason ?? this.targetSeason,
      beforeModel: beforeModel ?? this.beforeModel,
      afterModel: afterModel ?? this.afterModel,
      steps: steps ?? this.steps,
      progress: progress ?? this.progress,
    );
  }
}

/// Individual transformation step
class TransformationStep {
  final String stepId;
  final String name;
  final String description;
  final double startProgress;
  final double endProgress;
  final List<String> visualChanges;

  const TransformationStep({
    required this.stepId,
    required this.name,
    required this.description,
    required this.startProgress,
    required this.endProgress,
    required this.visualChanges,
  });
}

/// Interactive care tip overlay
class ARCareTipOverlay {
  final String tipId;
  final String title;
  final String content;
  final String category; // 'watering', 'lighting', 'fertilizing', etc.
  final ARPosition position;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final bool isInteractive;
  final bool isExpanded;
  final DateTime? expiresAt;
  final List<String>? actionButtons;

  const ARCareTipOverlay({
    required this.tipId,
    required this.title,
    required this.content,
    required this.category,
    required this.position,
    required this.priority,
    this.isInteractive = true,
    this.isExpanded = false,
    this.expiresAt,
    this.actionButtons,
  });
}
