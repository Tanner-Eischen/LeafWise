/// AR Seasonal Transformation Widget
///
/// Widget for displaying seasonal plant transformations in AR space with before/after comparisons.
/// Shows how plants change appearance across different seasons with smooth transitions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:leafwise/features/camera/models/ar_seasonal_models.dart';
import 'package:leafwise/features/camera/services/ar_seasonal_service.dart';
import 'package:leafwise/features/camera/providers/ar_providers.dart';

/// Provider for AR seasonal transformation state
final arSeasonalTransformationProvider =
    StateNotifierProvider.family<
      ARSeasonalTransformationNotifier,
      AsyncValue<ARSeasonalTransformation>,
      String
    >(
      (ref, plantId) => ARSeasonalTransformationNotifier(
        ref.read(arSeasonalServiceProvider),
        plantId,
      ),
    );

/// State notifier for AR seasonal transformation
class ARSeasonalTransformationNotifier
    extends StateNotifier<AsyncValue<ARSeasonalTransformation>> {
  final ARSeasonalService _service;
  final String _plantId;

  ARSeasonalTransformationNotifier(this._service, this._plantId)
    : super(const AsyncValue.loading());

  Future<void> generateTransformation(
    String currentSeason,
    String targetSeason,
  ) async {
    try {
      state = const AsyncValue.loading();
      final transformation = await _service.generateSeasonalTransformation(
        _plantId,
        currentSeason,
        targetSeason,
      );
      state = AsyncValue.data(transformation);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void updateProgress(double progress) {
    state.whenData((transformation) {
      state = AsyncValue.data(
        transformation.copyWith(progress: progress.clamp(0.0, 1.0)),
      );
    });
  }

  void resetTransformation() {
    updateProgress(0.0);
  }

  void completeTransformation() {
    updateProgress(1.0);
  }
}

/// Main AR seasonal transformation widget
class ARSeasonalTransformationWidget extends ConsumerStatefulWidget {
  final String plantId;
  final String currentSeason;
  final String targetSeason;
  final Size screenSize;
  final ARPosition plantPosition;
  final Function(double)? onProgressChanged;
  final Function(String)? onSeasonChanged;

  const ARSeasonalTransformationWidget({
    super.key,
    required this.plantId,
    required this.currentSeason,
    required this.targetSeason,
    required this.screenSize,
    required this.plantPosition,
    this.onProgressChanged,
    this.onSeasonChanged,
  });

  @override
  ConsumerState<ARSeasonalTransformationWidget> createState() =>
      _ARSeasonalTransformationState();
}

class _ARSeasonalTransformationState
    extends ConsumerState<ARSeasonalTransformationWidget>
    with TickerProviderStateMixin {
  late AnimationController _transformationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  bool _isInitialized = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _transformationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _transformationController.addListener(() {
      final notifier = ref.read(
        arSeasonalTransformationProvider(widget.plantId).notifier,
      );
      notifier.updateProgress(_transformationController.value);
      widget.onProgressChanged?.call(_transformationController.value);
    });

    _initializeTransformation();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _initializeTransformation() async {
    final notifier = ref.read(
      arSeasonalTransformationProvider(widget.plantId).notifier,
    );
    await notifier.generateTransformation(
      widget.currentSeason,
      widget.targetSeason,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transformationState = ref.watch(
      arSeasonalTransformationProvider(widget.plantId),
    );

    return transformationState.when(
      data: (transformation) => _buildTransformationContent(transformation),
      loading: () => _buildLoadingIndicator(),
      error: (error, _) => _buildErrorIndicator(error),
    );
  }

  Widget _buildTransformationContent(ARSeasonalTransformation transformation) {
    return Stack(
      children: [
        // Before/After plant models
        _buildPlantComparison(transformation),

        // Transformation progress indicator
        _buildProgressIndicator(transformation),

        // Season labels
        _buildSeasonLabels(transformation),

        // Transformation steps
        _buildTransformationSteps(transformation),

        // Control buttons
        _buildControlButtons(transformation),

        // Particle effects during transformation
        if (_isAnimating) _buildParticleEffects(transformation),
      ],
    );
  }

  Widget _buildPlantComparison(ARSeasonalTransformation transformation) {
    final screenPosition = _convertARPositionToScreen(widget.plantPosition);

    return Positioned(
      left: screenPosition.dx - 80,
      top: screenPosition.dy - 120,
      child: SizedBox(
        width: 160,
        height: 160,
        child: AnimatedBuilder(
          animation: _transformationController,
          builder: (context, child) {
            return CustomPaint(
              painter: SeasonalTransformationPainter(
                transformation: transformation,
                progress: transformation.progress,
                pulseValue: _pulseController.value,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ARSeasonalTransformation transformation) {
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seasonal Transformation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(transformation.progress * 100).round()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: transformation.progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getSeasonColor(transformation.targetSeason),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transformation.currentSeason,
                  style: TextStyle(
                    color: _getSeasonColor(transformation.currentSeason),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white70,
                  size: 16,
                ),
                Text(
                  transformation.targetSeason,
                  style: TextStyle(
                    color: _getSeasonColor(transformation.targetSeason),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonLabels(ARSeasonalTransformation transformation) {
    final screenPosition = _convertARPositionToScreen(widget.plantPosition);

    return Stack(
      children: [
        // Current season label
        Positioned(
          left: screenPosition.dx - 120,
          top: screenPosition.dy + 50,
          child: AnimatedOpacity(
            opacity: 1.0 - transformation.progress,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSeasonColor(
                  transformation.currentSeason,
                ).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSeasonIcon(transformation.currentSeason),
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transformation.currentSeason,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Target season label
        Positioned(
          left: screenPosition.dx + 40,
          top: screenPosition.dy + 50,
          child: AnimatedOpacity(
            opacity: transformation.progress,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSeasonColor(
                  transformation.targetSeason,
                ).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSeasonIcon(transformation.targetSeason),
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transformation.targetSeason,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransformationSteps(ARSeasonalTransformation transformation) {
    return Positioned(
      top: 180,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: transformation.steps.length,
          itemBuilder: (context, index) {
            final step = transformation.steps[index];
            final isActive =
                transformation.progress >= step.startProgress &&
                transformation.progress <= step.endProgress;
            final isCompleted = transformation.progress > step.endProgress;

            return Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.blue.withOpacity(0.8)
                    : isCompleted
                    ? Colors.green.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (isCompleted)
                    const Icon(Icons.check, color: Colors.white, size: 12)
                  else if (isActive)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: Colors.white,
                        value:
                            (transformation.progress - step.startProgress) /
                            (step.endProgress - step.startProgress),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButtons(ARSeasonalTransformation transformation) {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            onTap: _resetTransformation,
          ),

          // Play/Pause button
          _buildControlButton(
            icon: _isAnimating ? Icons.pause : Icons.play_arrow,
            label: _isAnimating ? 'Pause' : 'Play',
            onTap: _toggleAnimation,
            isPrimary: true,
          ),

          // Complete button
          _buildControlButton(
            icon: Icons.fast_forward,
            label: 'Complete',
            onTap: _completeTransformation,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blue : Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticleEffects(ARSeasonalTransformation transformation) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticleEffectPainter(
              progress: _particleController.value,
              transformation: transformation,
              screenSize: widget.screenSize,
              plantPosition: widget.plantPosition,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 200,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: const Row(
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
              'Loading transformation...',
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
                'Transformation error: ${error.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Control methods

  void _resetTransformation() {
    _transformationController.reset();
    final notifier = ref.read(
      arSeasonalTransformationProvider(widget.plantId).notifier,
    );
    notifier.resetTransformation();

    setState(() {
      _isAnimating = false;
    });

    _particleController.reset();
  }

  void _toggleAnimation() {
    if (_isAnimating) {
      _transformationController.stop();
      _particleController.stop();
    } else {
      _transformationController.forward();
      _particleController.repeat();
    }

    setState(() {
      _isAnimating = !_isAnimating;
    });
  }

  void _completeTransformation() {
    _transformationController.forward();
    final notifier = ref.read(
      arSeasonalTransformationProvider(widget.plantId).notifier,
    );
    notifier.completeTransformation();

    setState(() {
      _isAnimating = false;
    });

    _particleController.forward();
  }

  // Helper methods

  Offset _convertARPositionToScreen(ARPosition arPosition) {
    final centerX = widget.screenSize.width / 2;
    final centerY = widget.screenSize.height / 2;

    final screenX = centerX + (arPosition.x * widget.screenSize.width * 0.4);
    final screenY = centerY + (arPosition.y * widget.screenSize.height * 0.3);

    return Offset(
      screenX.clamp(80, widget.screenSize.width - 80),
      screenY.clamp(120, widget.screenSize.height - 200),
    );
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Colors.green;
      case 'summer':
        return Colors.orange;
      case 'fall':
        return Colors.brown;
      case 'winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeasonIcon(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Icons.local_florist;
      case 'summer':
        return Icons.wb_sunny;
      case 'fall':
        return Icons.eco;
      case 'winter':
        return Icons.ac_unit;
      default:
        return Icons.calendar_today;
    }
  }
}

/// Custom painter for seasonal transformation visualization
class SeasonalTransformationPainter extends CustomPainter {
  final ARSeasonalTransformation transformation;
  final double progress;
  final double pulseValue;

  SeasonalTransformationPainter({
    required this.transformation,
    required this.progress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);

    // Interpolate between before and after models
    final currentModel = _interpolateModels(
      transformation.beforeModel,
      transformation.afterModel,
      progress,
    );

    // Draw the interpolated plant
    _drawPlantModel(canvas, size, currentModel, center);

    // Draw transformation glow effect
    if (progress > 0 && progress < 1) {
      _drawTransformationGlow(canvas, size, center);
    }
  }

  ARPlantModel _interpolateModels(
    ARPlantModel before,
    ARPlantModel after,
    double t,
  ) {
    return ARPlantModel(
      height: _lerp(before.height, after.height, t),
      width: _lerp(before.width, after.width, t),
      leafCount: _lerpInt(before.leafCount, after.leafCount, t),
      leafColor: _lerpColor(before.leafColor, after.leafColor, t),
      stemColor: _lerpColor(before.stemColor, after.stemColor, t),
      flowers: t > 0.5 ? after.flowers : before.flowers,
      fruits: t > 0.7 ? after.fruits : before.fruits,
    );
  }

  void _drawPlantModel(
    Canvas canvas,
    Size size,
    ARPlantModel model,
    Offset center,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw stem
    paint.color = _parseColor(model.stemColor);
    final stemHeight = (model.height / 20) * size.height;
    const stemWidth = 4.0;

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
    paint.color = _parseColor(model.leafColor);
    for (int i = 0; i < model.leafCount; i++) {
      final angle = (i * 45.0) * (math.pi / 180.0);
      final leafDistance = 15.0 + (i * 4.0);
      final leafY = center.dy - (stemHeight * 0.3) - (i * 8.0);

      final leafCenter = Offset(
        center.dx + math.cos(angle) * leafDistance,
        leafY,
      );

      _drawLeaf(canvas, leafCenter, paint, angle);
    }

    // Draw flowers
    for (final flower in model.flowers) {
      _drawFlower(canvas, center, flower);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, Paint paint, double angle) {
    final leafPath = Path();
    const leafSize = 8.0;

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

  void _drawFlower(Canvas canvas, Offset stemBase, ARFlower flower) {
    final flowerPaint = Paint()
      ..color = _parseColor(flower.color)
      ..style = PaintingStyle.fill;

    final flowerCenter = Offset(
      stemBase.dx + flower.position.x * 20,
      stemBase.dy - 60 + flower.position.y * 20,
    );

    canvas.drawCircle(flowerCenter, flower.size, flowerPaint);
  }

  void _drawTransformationGlow(Canvas canvas, Size size, Offset center) {
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    canvas.drawCircle(center, 60, glowPaint);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  int _lerpInt(int a, int b, double t) => (a + (b - a) * t).round();

  String _lerpColor(String colorA, String colorB, double t) {
    final a = _parseColor(colorA);
    final b = _parseColor(colorB);

    final r = (_lerp(a.red.toDouble(), b.red.toDouble(), t)).round();
    final g = (_lerp(a.green.toDouble(), b.green.toDouble(), t)).round();
    final blue = (_lerp(a.blue.toDouble(), b.blue.toDouble(), t)).round();

    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }

  @override
  bool shouldRepaint(SeasonalTransformationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseValue != pulseValue;
  }
}

/// Custom painter for particle effects during transformation
class ParticleEffectPainter extends CustomPainter {
  final double progress;
  final ARSeasonalTransformation transformation;
  final Size screenSize;
  final ARPosition plantPosition;

  ParticleEffectPainter({
    required this.progress,
    required this.transformation,
    required this.screenSize,
    required this.plantPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final centerX =
        screenSize.width / 2 + (plantPosition.x * screenSize.width * 0.4);
    final centerY =
        screenSize.height / 2 + (plantPosition.y * screenSize.height * 0.3);

    // Draw seasonal particles
    const particleCount = 20;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final radius = 50 + (progress * 30);

      final x = centerX + math.cos(angle + progress * 2 * math.pi) * radius;
      final y = centerY + math.sin(angle + progress * 2 * math.pi) * radius;

      paint.color = _getSeasonColor(
        transformation.targetSeason,
      ).withOpacity(0.6 * (1 - progress));

      canvas.drawCircle(
        Offset(x, y),
        2 + (math.sin(progress * 4 * math.pi) * 1),
        paint,
      );
    }
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Colors.green;
      case 'summer':
        return Colors.orange;
      case 'fall':
        return Colors.brown;
      case 'winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
