/// AR Seasonal Service
///
/// Service for managing AR seasonal overlays, growth projections, and time-lapse previews.
/// Integrates with seasonal AI predictions and time-lapse data to provide AR visualizations.
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:leafwise/core/network/api_client.dart';
import 'package:leafwise/features/camera/models/ar_seasonal_models.dart';
import 'package:leafwise/features/seasonal_ai/models/seasonal_ai_models.dart';
import 'package:leafwise/features/timelapse/models/timelapse_models.dart';

class ARSeasonalService {
  final ApiClient _apiClient;
  final StreamController<ARSeasonalOverlay> _overlayController =
      StreamController.broadcast();
  final StreamController<ARTrackingState> _trackingController =
      StreamController.broadcast();

  // Cache for performance
  final Map<String, ARSeasonalOverlay> _overlayCache = {};
  final Map<String, ARGrowthProjection> _projectionCache = {};

  ARSeasonalService(this._apiClient);

  /// Stream of AR overlay updates
  Stream<ARSeasonalOverlay> get overlayStream => _overlayController.stream;

  /// Stream of AR tracking state updates
  Stream<ARTrackingState> get trackingStream => _trackingController.stream;

  /// Generate AR seasonal overlay for a plant
  Future<ARSeasonalOverlay> generateSeasonalOverlay(
    String plantId,
    SeasonalPrediction prediction, {
    ARVisualizationConfig? config,
  }) async {
    try {
      // Check cache first
      final cacheKey =
          '${plantId}_${prediction.generatedAt?.millisecondsSinceEpoch}';
      if (_overlayCache.containsKey(cacheKey)) {
        return _overlayCache[cacheKey]!;
      }

      final visualConfig = config ?? const ARVisualizationConfig();

      // Generate overlay elements from prediction data
      final overlayElements = await _generateOverlayElements(
        prediction,
        visualConfig,
      );

      // Create tracking state
      const trackingState = ARTrackingState(
        status: 'initializing',
        confidence: 0.0,
      );

      final overlay = ARSeasonalOverlay(
        plantId: plantId,
        prediction: prediction,
        config: visualConfig,
        overlayElements: overlayElements,
        trackingState: trackingState,
        lastUpdated: DateTime.now(),
      );

      // Cache the result
      _overlayCache[cacheKey] = overlay;

      // Emit to stream
      _overlayController.add(overlay);

      return overlay;
    } catch (e) {
      throw Exception('Failed to generate seasonal overlay: $e');
    }
  }

  /// Update AR tracking state
  Future<void> updateTrackingState(
    String plantId,
    ARTrackingState newState,
  ) async {
    _trackingController.add(newState);

    // Update cached overlay if exists
    final cachedOverlay = _overlayCache.values
        .where((overlay) => overlay.plantId == plantId)
        .firstOrNull;

    if (cachedOverlay != null) {
      final updatedOverlay = cachedOverlay.copyWith(
        trackingState: newState,
        lastUpdated: DateTime.now(),
      );

      _overlayCache[plantId] = updatedOverlay;
      _overlayController.add(updatedOverlay);
    }
  }

  /// Generate growth projection visualization
  Future<ARGrowthProjection> generateGrowthProjection(
    String plantId,
    SeasonalPrediction prediction, {
    ARProjectionConfig? config,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${plantId}_projection';
      if (_projectionCache.containsKey(cacheKey)) {
        return _projectionCache[cacheKey]!;
      }

      const projectionConfig = ARProjectionConfig();

      // Generate growth stages from prediction
      final stages = await _generateGrowthStages(prediction);

      final projection = ARGrowthProjection(
        plantId: plantId,
        stages: stages,
        config: projectionConfig,
        currentStageIndex: _getCurrentStageIndex(stages),
        projectionDate: DateTime.now(),
      );

      // Cache the result
      _projectionCache[cacheKey] = projection;

      return projection;
    } catch (e) {
      throw Exception('Failed to generate growth projection: $e');
    }
  }

  /// Generate time-lapse preview for AR
  Future<ARTimelapsePreview> generateTimelapsePreview(
    String sessionId, {
    ARTimelapseControls? controls,
  }) async {
    try {
      // Mock time-lapse frames for now
      final frames = await _generateMockTimelapseFrames(sessionId);

      const timelapseControls = ARTimelapseControls();

      return ARTimelapsePreview(
        sessionId: sessionId,
        frames: frames,
        controls: timelapseControls,
        currentFrameIndex: 0,
        isPlaying: false,
        playbackSpeed: 1.0,
      );
    } catch (e) {
      throw Exception('Failed to generate time-lapse preview: $e');
    }
  }

  /// Generate seasonal transformation visualization
  Future<ARSeasonalTransformation> generateSeasonalTransformation(
    String plantId,
    String currentSeason,
    String targetSeason,
  ) async {
    try {
      // Get plant data for current season
      final currentModel = await _generatePlantModelForSeason(
        plantId,
        currentSeason,
      );

      // Get plant data for target season
      final targetModel = await _generatePlantModelForSeason(
        plantId,
        targetSeason,
      );

      // Generate transformation steps
      final steps = _generateTransformationSteps(currentSeason, targetSeason);

      return ARSeasonalTransformation(
        plantId: plantId,
        currentSeason: currentSeason,
        targetSeason: targetSeason,
        beforeModel: currentModel,
        afterModel: targetModel,
        steps: steps,
        progress: 0.0,
      );
    } catch (e) {
      throw Exception('Failed to generate seasonal transformation: $e');
    }
  }

  /// Update overlay configuration
  Future<ARSeasonalOverlay> updateOverlayConfig(
    String plantId,
    ARVisualizationConfig newConfig,
  ) async {
    final cachedOverlay = _overlayCache.values
        .where((overlay) => overlay.plantId == plantId)
        .firstOrNull;

    if (cachedOverlay == null) {
      throw Exception('No overlay found for plant $plantId');
    }

    // Regenerate overlay elements with new config
    final newElements = await _generateOverlayElements(
      cachedOverlay.prediction,
      newConfig,
    );

    final updatedOverlay = cachedOverlay.copyWith(
      config: newConfig,
      overlayElements: newElements,
      lastUpdated: DateTime.now(),
    );

    _overlayCache[plantId] = updatedOverlay;
    _overlayController.add(updatedOverlay);

    return updatedOverlay;
  }

  /// Private helper methods

  Future<List<AROverlayElement>> _generateOverlayElements(
    SeasonalPrediction prediction,
    ARVisualizationConfig config,
  ) async {
    final elements = <AROverlayElement>[];

    if (config.showPredictions) {
      elements.addAll(await _createPredictionElements(prediction));
    }

    if (config.showCareAdjustments) {
      elements.addAll(
        await _createCareAdjustmentElements(prediction.careAdjustments),
      );
    }

    if (config.showRiskFactors) {
      elements.addAll(await _createRiskFactorElements(prediction.riskFactors));
    }

    if (config.showGrowthProjections) {
      elements.addAll(
        await _createGrowthProjectionElements(prediction.growthForecast),
      );
    }

    return elements;
  }

  Future<List<AROverlayElement>> _createPredictionElements(
    SeasonalPrediction prediction,
  ) async {
    final elements = <AROverlayElement>[];

    // Main prediction summary
    elements.add(
      AROverlayElement(
        elementId: 'prediction_summary',
        type: 'prediction',
        position: const ARPosition(x: 0.0, y: 0.3, z: 0.0),
        content:
            'Growth Rate: ${(prediction.growthForecast.expectedGrowthRate * 100).toStringAsFixed(1)}%',
        style: const ARElementStyle(
          backgroundColor: '#2196F3',
          textColor: '#FFFFFF',
          borderColor: '#1976D2',
          iconName: 'trending_up',
          iconColor: '#FFFFFF',
        ),
        confidence: prediction.confidenceScore,
      ),
    );

    // Flowering predictions
    if (prediction.growthForecast.floweringPredictions.isNotEmpty) {
      final flowering = prediction.growthForecast.floweringPredictions.first;
      elements.add(
        AROverlayElement(
          elementId: 'flowering_prediction',
          type: 'prediction',
          position: const ARPosition(x: 0.2, y: 0.4, z: 0.0),
          content: 'Flowering: ${_formatDate(flowering.startDate)}',
          style: const ARElementStyle(
            backgroundColor: '#E91E63',
            textColor: '#FFFFFF',
            borderColor: '#C2185B',
            iconName: 'local_florist',
            iconColor: '#FFFFFF',
          ),
          confidence: flowering.probability,
        ),
      );
    }

    return elements;
  }

  Future<List<AROverlayElement>> _createCareAdjustmentElements(
    List<dynamic> adjustments,
  ) async {
    final elements = <AROverlayElement>[];

    for (int i = 0; i < adjustments.length && i < 3; i++) {
      final adjustment = adjustments[i];
      final adjustmentType = adjustment.adjustmentType ?? 'general';
      final newValue = adjustment.newValue ?? 'Adjust as needed';

      elements.add(
        AROverlayElement(
          elementId: 'care_${adjustmentType}_$i',
          type: 'care_tip',
          position: ARPosition(x: -0.3, y: 0.2 + (i * 0.15), z: 0.0),
          content: '${_formatCareTitle(adjustmentType)}: $newValue',
          style: ARElementStyle(
            backgroundColor: _getCareColor(adjustmentType),
            textColor: '#FFFFFF',
            borderColor: _getCareColor(adjustmentType),
            iconName: _getCareIcon(adjustmentType),
            iconColor: '#FFFFFF',
          ),
          confidence: 1.0,
        ),
      );
    }

    return elements;
  }

  Future<List<AROverlayElement>> _createRiskFactorElements(
    List<dynamic> risks,
  ) async {
    final elements = <AROverlayElement>[];

    for (int i = 0; i < risks.length && i < 2; i++) {
      final risk = risks[i];
      final riskType = risk.riskType ?? 'Unknown Risk';
      final severity = risk.severity ?? 'medium';

      elements.add(
        AROverlayElement(
          elementId: 'risk_${riskType}_$i',
          type: 'risk_warning',
          position: ARPosition(x: 0.3, y: 0.2 + (i * 0.15), z: 0.0),
          content: '⚠️ $riskType: $severity',
          style: ARElementStyle(
            backgroundColor: _getRiskColor(severity),
            textColor: '#FFFFFF',
            borderColor: _getRiskColor(severity),
            iconName: 'warning',
            iconColor: '#FFFFFF',
          ),
          confidence: risk.probability ?? 0.8,
        ),
      );
    }

    return elements;
  }

  Future<List<AROverlayElement>> _createGrowthProjectionElements(
    GrowthForecast forecast,
  ) async {
    final elements = <AROverlayElement>[];

    // Size projection indicator
    if (forecast.sizeProjections.isNotEmpty) {
      final projection = forecast.sizeProjections.first;

      elements.add(
        AROverlayElement(
          elementId: 'size_projection',
          type: 'growth_projection',
          position: const ARPosition(x: 0.0, y: -0.2, z: 0.0),
          content:
              'Projected: ${projection.estimatedHeight.toStringAsFixed(1)}cm',
          style: const ARElementStyle(
            backgroundColor: '#4CAF50',
            textColor: '#FFFFFF',
            borderColor: '#388E3C',
            iconName: 'height',
            iconColor: '#FFFFFF',
          ),
          confidence: projection.confidenceLevel,
        ),
      );
    }

    return elements;
  }

  Future<List<GrowthStageVisualization>> _generateGrowthStages(
    SeasonalPrediction prediction,
  ) async {
    final stages = <GrowthStageVisualization>[];
    final now = DateTime.now();

    // Generate stages based on growth forecast
    final forecast = prediction.growthForecast;

    // Current stage
    stages.add(
      GrowthStageVisualization(
        stageId: 'current',
        name: 'Current State',
        projectedDate: now,
        plantModel: await _generateCurrentPlantModel(prediction.plantId),
        description: 'Current plant state',
        probability: 1.0,
        isCurrentStage: true,
      ),
    );

    // Future stages based on size projections
    // Mock future stages instead of using forecast.sizeProjections
    for (int i = 1; i <= 3; i++) {
      final projectionDate = now.add(Duration(days: 30 * i));
      final height = 12.0 + (i * 3.0);
      final width = 8.0 + (i * 2.0);
      stages.add(
        GrowthStageVisualization(
          stageId: 'projection_${projectionDate.millisecondsSinceEpoch}',
          name: 'Growth Stage ${stages.length}',
          projectedDate: projectionDate,
          plantModel: ARPlantModel(
            height: height,
            width: width,
            leafCount: (height * 2).round(),
            leafColor: '#4CAF50',
            stemColor: '#8BC34A',
          ),
          description: 'Projected growth at ${_formatDate(projectionDate)}',
          probability:
              0.8 - (i * 0.1), // Decreasing confidence for future projections
        ),
      );
    }

    return stages;
  }

  Future<List<TimelapseFrame>> _generateMockTimelapseFrames(
    String sessionId,
  ) async {
    final frames = <TimelapseFrame>[];
    final now = DateTime.now();

    // Generate mock frames
    for (int i = 0; i < 10; i++) {
      final captureDate = now.subtract(Duration(days: 30 - (i * 3)));
      final height = 10.0 + (i * 2.0);
      final leafCount = 5 + i;

      frames.add(
        TimelapseFrame(
          frameId: 'frame_$i',
          captureDate: captureDate,
          plantModel: ARPlantModel(
            height: height,
            width: height * 0.8,
            leafCount: leafCount,
            leafColor: '#4CAF50',
            stemColor: '#8BC34A',
          ),
          measurements: PlantMeasurements(
            height: height,
            width: height * 0.8,
            leafCount: leafCount,
            stemDiameter: 1.0 + (i * 0.1),
          ),
        ),
      );
    }

    return frames;
  }

  Future<ARPlantModel> _generatePlantModelForSeason(
    String plantId,
    String season,
  ) async {
    // Mock implementation - in real app, this would use ML models
    const baseHeight = 15.0;
    final seasonMultiplier = _getSeasonalGrowthMultiplier(season);

    return ARPlantModel(
      height: baseHeight * seasonMultiplier,
      width: (baseHeight * seasonMultiplier) * 0.8,
      leafCount: (10 * seasonMultiplier).round(),
      leafColor: _getSeasonalLeafColor(season),
      stemColor: '#8BC34A',
      flowers: season == 'spring'
          ? [
              const ARFlower(
                position: ARPosition(x: 0.0, y: 0.8, z: 0.0),
                color: '#E91E63',
                size: 2.0,
                type: 'bloom',
              ),
            ]
          : [],
    );
  }

  Future<ARPlantModel> _generateCurrentPlantModel(String plantId) async {
    // Mock current plant model
    return const ARPlantModel(
      height: 12.0,
      width: 10.0,
      leafCount: 8,
      leafColor: '#4CAF50',
      stemColor: '#8BC34A',
    );
  }

  List<TransformationStep> _generateTransformationSteps(
    String currentSeason,
    String targetSeason,
  ) {
    // Mock transformation steps
    return [
      const TransformationStep(
        stepId: 'color_change',
        name: 'Leaf Color Change',
        description: 'Leaves gradually change color',
        startProgress: 0.0,
        endProgress: 0.3,
        visualChanges: ['leaf_color'],
      ),
      const TransformationStep(
        stepId: 'size_change',
        name: 'Growth Change',
        description: 'Plant size adjusts to season',
        startProgress: 0.3,
        endProgress: 0.7,
        visualChanges: ['height', 'width'],
      ),
      const TransformationStep(
        stepId: 'flowering',
        name: 'Seasonal Features',
        description: 'Flowers or dormancy features appear',
        startProgress: 0.7,
        endProgress: 1.0,
        visualChanges: ['flowers', 'dormancy_indicators'],
      ),
    ];
  }

  int _getCurrentStageIndex(List<GrowthStageVisualization> stages) {
    final now = DateTime.now();
    for (int i = 0; i < stages.length; i++) {
      if (stages[i].projectedDate.isAfter(now)) {
        return math.max(0, i - 1);
      }
    }
    return stages.length - 1;
  }

  // Utility methods for formatting and colors

  String _formatCareTitle(String adjustmentType) {
    return adjustmentType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _getCareColor(String adjustmentType) {
    switch (adjustmentType.toLowerCase()) {
      case 'watering':
        return '#2196F3';
      case 'fertilizing':
        return '#FF9800';
      case 'lighting':
        return '#FFC107';
      case 'temperature':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  String _getCareIcon(String adjustmentType) {
    switch (adjustmentType.toLowerCase()) {
      case 'watering':
        return 'water_drop';
      case 'fertilizing':
        return 'science';
      case 'lighting':
        return 'wb_sunny';
      case 'temperature':
        return 'thermostat';
      default:
        return 'info';
    }
  }

  String _getRiskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return '#FFC107';
      case 'medium':
        return '#FF9800';
      case 'high':
        return '#F44336';
      case 'critical':
        return '#D32F2F';
      default:
        return '#9E9E9E';
    }
  }

  double _getSeasonalGrowthMultiplier(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return 1.2;
      case 'summer':
        return 1.0;
      case 'fall':
        return 0.8;
      case 'winter':
        return 0.6;
      default:
        return 1.0;
    }
  }

  String _getSeasonalLeafColor(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return '#8BC34A';
      case 'summer':
        return '#4CAF50';
      case 'fall':
        return '#FF9800';
      case 'winter':
        return '#795548';
      default:
        return '#4CAF50';
    }
  }

  void dispose() {
    _overlayController.close();
    _trackingController.close();
    _overlayCache.clear();
    _projectionCache.clear();
  }
}
