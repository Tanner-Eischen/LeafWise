/// AR Time-lapse Preview Widget
///
/// Widget for displaying time-lapse growth progression in AR space with scrubbing controls.
/// Shows plant growth over time with interactive playback and seasonal transformation visualization.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:plant_social/features/camera/models/ar_seasonal_models.dart';
import 'package:plant_social/features/camera/services/ar_seasonal_service.dart';
import 'package:plant_social/features/timelapse/models/timelapse_models.dart';

/// Provider for AR time-lapse preview state
final arTimelapsePreviewProvider =
    StateNotifierProvider.family<
      ARTimelapsePreviewNotifier,
      AsyncValue<ARTimelapsePreview>,
      String
    >(
      (ref, sessionId) => ARTimelapsePreviewNotifier(
        ref.read(arSeasonalServiceProvider),
        sessionId,
      ),
    );

/// State notifier for AR time-lapse preview
class ARTimelapsePreviewNotifier
    extends StateNotifier<AsyncValue<ARTimelapsePreview>> {
  final ARSeasonalService _service;
  final String _sessionId;
  Timer? _playbackTimer;

  ARTimelapsePreviewNotifier(this._service, this._sessionId)
    : super(const AsyncValue.loading());

  Future<void> generatePreview({ARTimelapseControls? controls}) async {
    try {
      state = const AsyncValue.loading();
      final preview = await _service.generateTimelapsePreview(
        _sessionId,
        controls: controls,
      );
      state = AsyncValue.data(preview);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void updateCurrentFrame(int frameIndex) {
    state.whenData((preview) {
      state = AsyncValue.data(preview.copyWith(currentFrameIndex: frameIndex));
    });
  }

  void togglePlayback() {
    state.whenData((preview) {
      final isPlaying = !preview.isPlaying;
      state = AsyncValue.data(preview.copyWith(isPlaying: isPlaying));

      if (isPlaying) {
        _startPlayback();
      } else {
        _stopPlayback();
      }
    });
  }

  void setPlaybackSpeed(double speed) {
    state.whenData((preview) {
      state = AsyncValue.data(preview.copyWith(playbackSpeed: speed));

      if (preview.isPlaying) {
        _stopPlayback();
        _startPlayback();
      }
    });
  }

  void _startPlayback() {
    _playbackTimer?.cancel();

    state.whenData((preview) {
      final frameDuration = Duration(
        milliseconds: (1000 / preview.playbackSpeed).round(),
      );

      _playbackTimer = Timer.periodic(frameDuration, (timer) {
        final currentPreview = state.value;
        if (currentPreview != null) {
          final nextFrame =
              (currentPreview.currentFrameIndex + 1) %
              currentPreview.frames.length;
          updateCurrentFrame(nextFrame);

          // Stop at end if not looping
          if (!currentPreview.controls.enableLooping && nextFrame == 0) {
            _stopPlayback();
          }
        }
      });
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
  }
}

/// Main AR time-lapse preview widget
class ARTimelapsePreviewWidget extends ConsumerStatefulWidget {
  final String sessionId;
  final Size screenSize;
  final ARPosition plantPosition;
  final Function(int)? onFrameChanged;
  final Function(bool)? onPlaybackToggle;
  final ARTimelapseControls? controls;

  const ARTimelapsePreviewWidget({
    super.key,
    required this.sessionId,
    required this.screenSize,
    required this.plantPosition,
    this.onFrameChanged,
    this.onPlaybackToggle,
    this.controls,
  });

  @override
  ConsumerState<ARTimelapsePreviewWidget> createState() =>
      _ARTimelapsePreviewState();
}

class _ARTimelapsePreviewState extends ConsumerState<ARTimelapsePreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _morphController;
  late AnimationController _pulseController;

  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _initializePreview();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _morphController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializePreview() async {
    final notifier = ref.read(
      arTimelapsePreviewProvider(widget.sessionId).notifier,
    );
    await notifier.generatePreview(controls: widget.controls);

    setState(() {
      _isInitialized = true;
    });

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final previewState = ref.watch(
      arTimelapsePreviewProvider(widget.sessionId),
    );

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        children: [
          previewState.when(
            data: (preview) => _buildPreviewContent(preview),
            loading: () => _buildLoadingIndicator(),
            error: (error, _) => _buildErrorIndicator(error),
          ),

          // Controls overlay
          if (_showControls && _isInitialized)
            previewState.whenOrNull(
                  data: (preview) => _buildControlsOverlay(preview),
                ) ??
                const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(ARTimelapsePreview preview) {
    return Stack(
      children: [
        // Main plant visualization
        _buildPlantVisualization(preview),

        // Growth progression indicator
        _buildGrowthProgressIndicator(preview),

        // Frame information
        if (preview.controls.showFrameInfo) _buildFrameInfo(preview),

        // Seasonal transformation overlay
        _buildSeasonalTransformationOverlay(preview),
      ],
    );
  }

  Widget _buildPlantVisualization(ARTimelapsePreview preview) {
    if (preview.frames.isEmpty) return const SizedBox.shrink();

    final currentFrame = preview.frames[preview.currentFrameIndex];
    final screenPosition = _convertARPositionToScreen(widget.plantPosition);

    return Positioned(
      left: screenPosition.dx - 60,
      top: screenPosition.dy - 120,
      child: AnimatedBuilder(
        animation: _morphController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeController,
            child: Container(
              width: 120,
              height: 160,
              child: CustomPaint(
                painter: TimelapseFramePainter(
                  frame: currentFrame,
                  morphValue: _morphController.value,
                  isPlaying: preview.isPlaying,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrowthProgressIndicator(ARTimelapsePreview preview) {
    final progress = preview.frames.isNotEmpty
        ? preview.currentFrameIndex / (preview.frames.length - 1)
        : 0.0;

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
                  'Growth Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                preview.isPlaying ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameInfo(ARTimelapsePreview preview) {
    if (preview.frames.isEmpty) return const SizedBox.shrink();

    final currentFrame = preview.frames[preview.currentFrameIndex];

    return Positioned(
      top: 160,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Frame ${preview.currentFrameIndex + 1}/${preview.frames.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(currentFrame.captureDate),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              'H: ${currentFrame.measurements.height.toStringAsFixed(1)}cm',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              'Leaves: ${currentFrame.measurements.leafCount}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalTransformationOverlay(ARTimelapsePreview preview) {
    if (preview.frames.isEmpty) return const SizedBox.shrink();

    final currentFrame = preview.frames[preview.currentFrameIndex];
    final season = _getSeasonFromDate(currentFrame.captureDate);

    return Positioned(
      top: 120,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSeasonColor(season).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getSeasonIcon(season), color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    season,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlsOverlay(ARTimelapsePreview preview) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrubber
              if (preview.controls.showScrubber) _buildScrubber(preview),

              const SizedBox(height: 12),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous frame
                  _buildControlButton(
                    icon: Icons.skip_previous,
                    onTap: () => _previousFrame(preview),
                  ),

                  // Play/Pause
                  if (preview.controls.showPlayButton)
                    _buildControlButton(
                      icon: preview.isPlaying ? Icons.pause : Icons.play_arrow,
                      onTap: () => _togglePlayback(),
                      isPrimary: true,
                    ),

                  // Next frame
                  _buildControlButton(
                    icon: Icons.skip_next,
                    onTap: () => _nextFrame(preview),
                  ),

                  // Speed control
                  if (preview.controls.showSpeedControl)
                    _buildSpeedControl(preview),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrubber(ARTimelapsePreview preview) {
    if (preview.frames.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(preview.frames.first.captureDate),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              _formatDate(preview.frames.last.captureDate),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.green.withOpacity(0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: preview.currentFrameIndex.toDouble(),
            min: 0,
            max: (preview.frames.length - 1).toDouble(),
            divisions: preview.frames.length - 1,
            onChanged: (value) => _seekToFrame(value.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 56 : 48,
        height: isPrimary ? 56 : 48,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.green : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: isPrimary ? 28 : 24),
      ),
    );
  }

  Widget _buildSpeedControl(ARTimelapsePreview preview) {
    return PopupMenuButton<double>(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            '${preview.playbackSpeed}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => preview.controls.availableSpeeds
          .map(
            (speed) =>
                PopupMenuItem<double>(value: speed, child: Text('${speed}x')),
          )
          .toList(),
      onSelected: (speed) => _setPlaybackSpeed(speed),
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
              'Loading time-lapse...',
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
                'Time-lapse error: ${error.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Control methods

  void _togglePlayback() {
    final notifier = ref.read(
      arTimelapsePreviewProvider(widget.sessionId).notifier,
    );
    notifier.togglePlayback();

    final preview = ref
        .read(arTimelapsePreviewProvider(widget.sessionId))
        .value;
    widget.onPlaybackToggle?.call(preview?.isPlaying ?? false);
  }

  void _previousFrame(ARTimelapsePreview preview) {
    if (preview.currentFrameIndex > 0) {
      _seekToFrame(preview.currentFrameIndex - 1);
    }
  }

  void _nextFrame(ARTimelapsePreview preview) {
    if (preview.currentFrameIndex < preview.frames.length - 1) {
      _seekToFrame(preview.currentFrameIndex + 1);
    }
  }

  void _seekToFrame(int frameIndex) {
    final notifier = ref.read(
      arTimelapsePreviewProvider(widget.sessionId).notifier,
    );
    notifier.updateCurrentFrame(frameIndex);

    widget.onFrameChanged?.call(frameIndex);

    _morphController.reset();
    _morphController.forward();
  }

  void _setPlaybackSpeed(double speed) {
    final notifier = ref.read(
      arTimelapsePreviewProvider(widget.sessionId).notifier,
    );
    notifier.setPlaybackSpeed(speed);
  }

  // Helper methods

  Offset _convertARPositionToScreen(ARPosition arPosition) {
    final centerX = widget.screenSize.width / 2;
    final centerY = widget.screenSize.height / 2;

    final screenX = centerX + (arPosition.x * widget.screenSize.width * 0.4);
    final screenY = centerY + (arPosition.y * widget.screenSize.height * 0.3);

    return Offset(
      screenX.clamp(60, widget.screenSize.width - 120),
      screenY.clamp(120, widget.screenSize.height - 200),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getSeasonFromDate(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
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

/// Custom painter for time-lapse frame visualization
class TimelapseFramePainter extends CustomPainter {
  final TimelapseFrame frame;
  final double morphValue;
  final bool isPlaying;

  TimelapseFramePainter({
    required this.frame,
    required this.morphValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height);

    // Draw plant based on measurements
    _drawPlantFromMeasurements(canvas, size, frame.measurements, paint);

    // Draw morphing effect if playing
    if (isPlaying) {
      _drawMorphingEffect(canvas, size, morphValue);
    }

    // Draw frame border
    _drawFrameBorder(canvas, size);
  }

  void _drawPlantFromMeasurements(
    Canvas canvas,
    Size size,
    PlantMeasurements measurements,
    Paint paint,
  ) {
    final center = Offset(size.width / 2, size.height);

    // Draw stem
    paint.color = const Color(0xFF8BC34A);
    final stemHeight = (measurements.height / 30) * size.height;
    final stemWidth = math.max(2.0, measurements.stemDiameter * 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - stemHeight / 2),
          width: stemWidth,
          height: stemHeight,
        ),
        const Radius.circular(1),
      ),
      paint,
    );

    // Draw leaves
    paint.color = const Color(0xFF4CAF50);
    final leafCount = measurements.leafCount;

    for (int i = 0; i < leafCount; i++) {
      final angle = (i * 45.0) * (math.pi / 180.0);
      final leafDistance = 10.0 + (i * 3.0);
      final leafY = center.dy - (stemHeight * 0.2) - (i * 6.0);

      final leafCenter = Offset(
        center.dx + math.cos(angle) * leafDistance,
        leafY,
      );

      _drawLeaf(canvas, leafCenter, paint, angle, measurements.width / 20);
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    Paint paint,
    double angle,
    double size,
  ) {
    final leafPath = Path();
    final leafSize = math.max(4.0, size * 6);

    leafPath.moveTo(center.dx, center.dy);
    leafPath.quadraticBezierTo(
      center.dx + math.cos(angle) * leafSize,
      center.dy - leafSize / 2,
      center.dx + math.cos(angle) * leafSize * 1.2,
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

  void _drawMorphingEffect(Canvas canvas, Size size, double morphValue) {
    final morphPaint = Paint()
      ..color = Colors.green.withOpacity(0.3 * morphValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      morphPaint,
    );
  }

  void _drawFrameBorder(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(TimelapseFramePainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.morphValue != morphValue ||
        oldDelegate.isPlaying != isPlaying;
  }
}
