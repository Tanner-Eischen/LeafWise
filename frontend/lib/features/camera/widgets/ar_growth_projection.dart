/// AR Growth Projection Widget
///
/// Widget for displaying 3D plant growth projections in AR space.
/// Shows future plant states based on seasonal predictions and growth forecasts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:plant_social/features/camera/models/ar_seasonal_models.dart';
import 'package:plant_social/features/camera/services/ar_seasonal_service.dart';
import 'package:plant_social/features/seasonal_ai/models/seasonal_ai_models.dart';

/// Provider for AR growth projection state
final arGrowthProjectionProvider =
    StateNotifierProvider.family<
      ARGrowthProjectionNotifier,
      AsyncValue<ARGrowthProjection>,
      String
    >(
      (ref, plantId) => ARGrowthProjectionNotifier(
        ref.read(arSeasonalServiceProvider),
        plantId,
      ),
    );

/// State notifier for AR growth projection
class ARGrowthProjectionNotifier
    extends StateNotifier<AsyncValue<ARGrowthProjection>> {
  final ARSeasonalService _service;
  final String _plantId;

  ARGrowthProjectionNotifier(this._service, this._plantId)
    : super(const AsyncValue.loading());

  Future<void> generateProjection(
    SeasonalPrediction prediction, {
    ARProjectionConfig? config,
  }) async {
    try {
      state = const AsyncValue.loading();
      final projection = await _service.generateGrowthProjection(
        _plantId,
        prediction,
        config: config,
      );
      state = AsyncValue.data(projection);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void updateCurrentStage(int stageIndex) {
    state.whenData((projection) {
      state = AsyncValue.data(
        projection.copyWith(currentStageIndex: stageIndex),
      );
    });
  }
}

/// Main AR growth projection widget
class ARGrowthProjectionWidget extends ConsumerStatefulWidget {
  final String plantId;
  final SeasonalPrediction prediction;
  final Size screenSize;
  final ARPosition plantPosition;
  final Function(int)? onStageChanged;
  final ARProjectionConfig? config;

  const ARGrowthProjectionWidget({
    super.key,
    required this.plantId,
    required this.prediction,
    required this.screenSize,
    required this.plantPosition,
    this.onStageChanged,
    this.config,
  });

  @override
  ConsumerState<ARGrowthProjectionWidget> createState() =>
      _ARGrowthProjectionState();
}

class _ARGrowthProjectionState extends ConsumerState<ARGrowthProjectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late AnimationController _transitionController;
  late AnimationController _pulseController;

  bool _isInitialized = false;
  int _selectedStageIndex = 0;

  @override
  void initState() {
    super.initState();

    _growthController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _initializeProjection();
  }

  @override
  void dispose() {
    _growthController.dispose();
    _transitionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeProjection() async {
    final notifier = ref.read(
      arGrowthProjectionProvider(widget.plantId).notifier,
    );
    await notifier.generateProjection(widget.prediction, config: widget.config);

    setState(() {
      _isInitialized = true;
    });

    _growthController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final projectionState = ref.watch(
      arGrowthProjectionProvider(widget.plantId),
    );

    return projectionState.when(
      data: (projection) => _buildProjectionContent(projection),
      loading: () => _buildLoadingIndicator(),
      error: (error, _) => _buildErrorIndicator(error),
    );
  }

  Widget _buildProjectionContent(ARGrowthProjection projection) {
    return Stack(
      children: [
        // 3D plant model visualization
        _build3DPlantModel(projection),

        // Growth timeline
        if (projection.config.showTimeline) _buildGrowthTimeline(projection),

        // Stage controls
        _buildStageControls(projection),

        // Growth metrics overlay
        _buildGrowthMetrics(projection),
      ],
    );
  }

  Widget _build3DPlantModel(ARGrowthProjection projection) {
    final currentStage = projection.stages[projection.currentStageIndex];
    final screenPosition = _convertARPositionToScreen(widget.plantPosition);

    return Positioned(
      left: screenPosition.dx - 50,
      top: screenPosition.dy - 100,
      child: AnimatedBuilder(
        animation: _growthController,
        builder: (context, child) {
          return AnimatedBuilder(
            animation: _transitionController,
            builder: (context, child) {
              return _buildPlantVisualization(
                currentStage.plantModel,
                projection,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlantVisualization(
    ARPlantModel model,
    ARGrowthProjection projection,
  ) {
    final scale = _growthController.value;
    final currentStage = projection.stages[projection.currentStageIndex];

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 150,
        child: CustomPaint(
          painter: PlantModelPainter(
            model: model,
            animationValue: _transitionController.value,
            isCurrentStage: currentStage.isCurrentStage,
            probability: currentStage.probability,
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthTimeline(ARGrowthProjection projection) {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Text(
              'Growth Timeline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: projection.stages.length,
                itemBuilder: (context, index) {
                  return _buildTimelineItem(
                    projection.stages[index],
                    index,
                    projection,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    GrowthStageVisualization stage,
    int index,
    ARGrowthProjection projection,
  ) {
    final isSelected = index == projection.currentStageIndex;
    final isCompleted = index < projection.currentStageIndex;

    return GestureDetector(
      onTap: () => _selectStage(index),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // Stage indicator
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isSelected
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isSelected
                          ? Colors.blue
                          : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Stage name
            Text(
              stage.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageControls(ARGrowthProjection projection) {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous stage
          _buildControlButton(
            icon: Icons.skip_previous,
            onTap: projection.currentStageIndex > 0
                ? () => _selectStage(projection.currentStageIndex - 1)
                : null,
          ),

          // Play/Pause animation
          _buildControlButton(
            icon: _transitionController.isAnimating
                ? Icons.pause
                : Icons.play_arrow,
            onTap: _toggleAnimation,
          ),

          // Next stage
          _buildControlButton(
            icon: Icons.skip_next,
            onTap: projection.currentStageIndex < projection.stages.length - 1
                ? () => _selectStage(projection.currentStageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.blue : Colors.grey,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildGrowthMetrics(ARGrowthProjection projection) {
    final currentStage = projection.stages[projection.currentStageIndex];

    return Positioned(
      top: 120,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStage.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentStage.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Height',
              '${currentStage.plantModel.height.toStringAsFixed(1)} cm',
            ),
            _buildMetricRow(
              'Width',
              '${currentStage.plantModel.width.toStringAsFixed(1)} cm',
            ),
            _buildMetricRow('Leaves', '${currentStage.plantModel.leafCount}'),
            if (projection.config.showProbabilities)
              _buildMetricRow(
                'Probability',
                '${(currentStage.probability * 100).round()}%',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 200,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading growth projection...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(Object error) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Growth projection error: ${error.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  void _selectStage(int index) {
    setState(() {
      _selectedStageIndex = index;
    });

    final notifier = ref.read(
      arGrowthProjectionProvider(widget.plantId).notifier,
    );
    notifier.updateCurrentStage(index);

    widget.onStageChanged?.call(index);

    _transitionController.reset();
    _transitionController.forward();
  }

  void _toggleAnimation() {
    if (_transitionController.isAnimating) {
      _transitionController.stop();
    } else {
      _transitionController.forward();
    }
  }

  Offset _convertARPositionToScreen(ARPosition arPosition) {
    final centerX = widget.screenSize.width / 2;
    final centerY = widget.screenSize.height / 2;

    final screenX = centerX + (arPosition.x * widget.screenSize.width * 0.4);
    final screenY = centerY + (arPosition.y * widget.screenSize.height * 0.3);

    return Offset(
      screenX.clamp(50, widget.screenSize.width - 150),
      screenY.clamp(100, widget.screenSize.height - 200),
    );
  }
}

/// Custom painter for 3D plant model visualization
class PlantModelPainter extends CustomPainter {
  final ARPlantModel model;
  final double animationValue;
  final bool isCurrentStage;
  final double probability;

  PlantModelPainter({
    required this.model,
    required this.animationValue,
    required this.isCurrentStage,
    required this.probability,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height);

    // Draw stem
    paint.color = _parseColor(model.stemColor).withOpacity(0.8);
    final stemHeight = (model.height / 20) * size.height * animationValue;
    final stemWidth = 4.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - stemHeight / 2),
          width: stemWidth,
          height: stemHeight,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw leaves
    paint.color = _parseColor(model.leafColor).withOpacity(0.7);
    final leafCount = (model.leafCount * animationValue).round();

    for (int i = 0; i < leafCount; i++) {
      final angle = (i * 60.0) * (math.pi / 180.0);
      final leafDistance = 15.0 + (i * 5.0);
      final leafY = center.dy - (stemHeight * 0.3) - (i * 8.0);

      final leafCenter = Offset(
        center.dx + math.cos(angle) * leafDistance,
        leafY,
      );

      _drawLeaf(canvas, leafCenter, paint, angle);
    }

    // Draw flowers if present
    for (final flower in model.flowers) {
      _drawFlower(canvas, center, flower, animationValue);
    }

    // Draw probability indicator
    if (!isCurrentStage) {
      _drawProbabilityIndicator(canvas, size, probability);
    }

    // Draw glow effect for current stage
    if (isCurrentStage) {
      _drawGlowEffect(canvas, size);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, Paint paint, double angle) {
    final leafPath = Path();
    final leafSize = 8.0;

    leafPath.moveTo(center.dx, center.dy);
    leafPath.quadraticBezierTo(
      center.dx + math.cos(angle) * leafSize,
      center.dy - leafSize / 2,
      center.dx + math.cos(angle) * leafSize * 1.5,
      center.dy,
    );
    leafPath.quadraticBezierTo(
      center.dx + math.cos(angle) * leafSize,
      center.dy + leafSize / 2,
      center.dx,
      center.dy,
    );

    canvas.drawPath(leafPath, paint);
  }

  void _drawFlower(
    Canvas canvas,
    Offset stemBase,
    ARFlower flower,
    double animationValue,
  ) {
    final flowerPaint = Paint()
      ..color = _parseColor(flower.color).withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.fill;

    final flowerCenter = Offset(
      stemBase.dx + flower.position.x * 20,
      stemBase.dy - 60 + flower.position.y * 20,
    );

    // Draw flower petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72.0) * (math.pi / 180.0);
      final petalCenter = Offset(
        flowerCenter.dx + math.cos(angle) * flower.size,
        flowerCenter.dy + math.sin(angle) * flower.size,
      );

      canvas.drawCircle(petalCenter, flower.size * animationValue, flowerPaint);
    }

    // Draw flower center
    flowerPaint.color = Colors.yellow.withOpacity(0.9 * animationValue);
    canvas.drawCircle(
      flowerCenter,
      flower.size * 0.5 * animationValue,
      flowerPaint,
    );
  }

  void _drawProbabilityIndicator(Canvas canvas, Size size, double probability) {
    final indicatorPaint = Paint()
      ..color = probability > 0.7 ? Colors.green : Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final indicatorRect = Rect.fromLTWH(size.width - 20, 10, 10, 10);

    canvas.drawArc(
      indicatorRect,
      -math.pi / 2,
      2 * math.pi * probability,
      false,
      indicatorPaint,
    );
  }

  void _drawGlowEffect(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      glowPaint,
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }

  @override
  bool shouldRepaint(PlantModelPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isCurrentStage != isCurrentStage ||
        oldDelegate.probability != probability;
  }
}
