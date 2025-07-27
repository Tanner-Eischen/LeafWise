/// AR Seasonal Overlay Widget
///
/// Main widget for displaying seasonal predictions and care tips in AR space.
/// Integrates with ARCore/ARKit for plant tracking and overlay positioning.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plant_social/features/camera/models/ar_seasonal_models.dart';
import 'package:plant_social/features/camera/services/ar_seasonal_service.dart';
import 'package:plant_social/features/seasonal_ai/models/seasonal_ai_models.dart';
import 'package:plant_social/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for AR seasonal service
final arSeasonalServiceProvider = Provider<ARSeasonalService>((ref) {
  return ARSeasonalService(
    ApiClient(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      ),
    ),
  );
});

/// Provider for AR seasonal overlay state
final arSeasonalOverlayProvider =
    StateNotifierProvider.family<
      ARSeasonalOverlayNotifier,
      AsyncValue<ARSeasonalOverlay>,
      String
    >(
      (ref, plantId) => ARSeasonalOverlayNotifier(
        ref.read(arSeasonalServiceProvider),
        plantId,
      ),
    );

/// State notifier for AR seasonal overlay
class ARSeasonalOverlayNotifier
    extends StateNotifier<AsyncValue<ARSeasonalOverlay>> {
  final ARSeasonalService _service;
  final String _plantId;

  ARSeasonalOverlayNotifier(this._service, this._plantId)
    : super(const AsyncValue.loading());

  Future<void> generateOverlay(
    SeasonalPrediction prediction, {
    ARVisualizationConfig? config,
  }) async {
    try {
      state = const AsyncValue.loading();
      final overlay = await _service.generateSeasonalOverlay(
        _plantId,
        prediction,
        config: config,
      );
      state = AsyncValue.data(overlay);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateConfig(ARVisualizationConfig config) async {
    try {
      final overlay = await _service.updateOverlayConfig(_plantId, config);
      state = AsyncValue.data(overlay);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTracking(ARTrackingState trackingState) async {
    await _service.updateTrackingState(_plantId, trackingState);
  }
}

/// Main AR seasonal overlay widget
class ARSeasonalOverlayWidget extends ConsumerStatefulWidget {
  final String plantId;
  final SeasonalPrediction prediction;
  final Size screenSize;
  final VoidCallback? onConfigTap;
  final Function(String)? onElementTap;
  final ARVisualizationConfig? initialConfig;

  const ARSeasonalOverlayWidget({
    super.key,
    required this.plantId,
    required this.prediction,
    required this.screenSize,
    this.onConfigTap,
    this.onElementTap,
    this.initialConfig,
  });

  @override
  ConsumerState<ARSeasonalOverlayWidget> createState() =>
      _ARSeasonalOverlayState();
}

class _ARSeasonalOverlayState extends ConsumerState<ARSeasonalOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _trackingController;

  bool _isInitialized = false;
  ARTrackingState _trackingState = const ARTrackingState();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _trackingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _initializeOverlay();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _initializeOverlay() async {
    final notifier = ref.read(
      arSeasonalOverlayProvider(widget.plantId).notifier,
    );
    await notifier.generateOverlay(
      widget.prediction,
      config: widget.initialConfig,
    );

    setState(() {
      _isInitialized = true;
    });

    _fadeController.forward();
    _simulateTracking();
  }

  void _simulateTracking() {
    // Simulate AR tracking initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _trackingState = const ARTrackingState(
            isTracking: true,
            confidence: 0.3,
            status: 'tracking',
            plantPosition: ARPosition(x: 0.0, y: 0.0, z: 0.0),
          );
        });

        _trackingController.forward();

        // Improve tracking confidence over time
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _trackingState = _trackingState.copyWith(
                confidence: 0.85,
                status: 'tracking',
              );
            });

            final notifier = ref.read(
              arSeasonalOverlayProvider(widget.plantId).notifier,
            );
            notifier.updateTracking(_trackingState);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlayState = ref.watch(arSeasonalOverlayProvider(widget.plantId));

    return Stack(
      children: [
        // Tracking indicator
        if (_trackingState.isTracking) _buildTrackingIndicator(),

        // Main overlay content
        overlayState.when(
          data: (overlay) => _buildOverlayContent(overlay),
          loading: () => _buildLoadingIndicator(),
          error: (error, _) => _buildErrorIndicator(error),
        ),

        // Configuration button
        if (_isInitialized) _buildConfigButton(),
      ],
    );
  }

  Widget _buildTrackingIndicator() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _trackingController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _trackingState.confidence > 0.7
                      ? Colors.green
                      : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: _trackingState.confidence,
                      strokeWidth: 2,
                      color: _trackingState.confidence > 0.7
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _trackingState.confidence > 0.7
                        ? 'Plant Tracked'
                        : 'Tracking...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_trackingState.confidence * 100).round()}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayContent(ARSeasonalOverlay overlay) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // Overlay elements
          ...overlay.overlayElements.map(
            (element) => _buildOverlayElement(element),
          ),

          // Plant position indicator (if tracking)
          if (_trackingState.plantPosition != null &&
              _trackingState.confidence > 0.5)
            _buildPlantPositionIndicator(_trackingState.plantPosition!),
        ],
      ),
    );
  }

  Widget _buildOverlayElement(AROverlayElement element) {
    if (!element.isVisible) return const SizedBox.shrink();

    final screenPosition = _convertARPositionToScreen(element.position);

    return Positioned(
      left: screenPosition.dx,
      top: screenPosition.dy,
      child: GestureDetector(
        onTap: () => widget.onElementTap?.call(element.elementId),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = element.type == 'risk_warning'
                ? 1.0 + (_pulseController.value * 0.05)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: _buildElementContent(element),
            );
          },
        ),
      ),
    );
  }

  Widget _buildElementContent(AROverlayElement element) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.all(element.style.padding),
      decoration: BoxDecoration(
        color: _parseColor(element.style.backgroundColor).withOpacity(0.9),
        borderRadius: BorderRadius.circular(element.style.borderRadius),
        border: Border.all(
          color: _parseColor(element.style.borderColor),
          width: element.style.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (element.style.iconName != null) ...[
            Icon(
              _getIconData(element.style.iconName!),
              color: _parseColor(
                element.style.iconColor ?? element.style.textColor,
              ),
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              element.content,
              style: TextStyle(
                color: _parseColor(element.style.textColor),
                fontSize: element.style.fontSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (element.confidence < 1.0) ...[
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: element.confidence > 0.7 ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlantPositionIndicator(ARPosition position) {
    final screenPosition = _convertARPositionToScreen(position);

    return Positioned(
      left: screenPosition.dx - 25,
      top: screenPosition.dy - 25,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(
                Icons.center_focus_strong,
                color: Colors.green,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
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
                'Initializing AR overlay...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
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
                'AR overlay error: ${error.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigButton() {
    return Positioned(
      top: 120,
      right: 20,
      child: FadeTransition(
        opacity: _fadeController,
        child: GestureDetector(
          onTap: widget.onConfigTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  // Helper methods

  Offset _convertARPositionToScreen(ARPosition arPosition) {
    // Convert AR coordinates to screen coordinates
    // This is a simplified conversion - real implementation would use AR SDK
    final centerX = widget.screenSize.width / 2;
    final centerY = widget.screenSize.height / 2;

    final screenX = centerX + (arPosition.x * widget.screenSize.width * 0.4);
    final screenY = centerY + (arPosition.y * widget.screenSize.height * 0.3);

    return Offset(
      screenX.clamp(0, widget.screenSize.width - 200),
      screenY.clamp(60, widget.screenSize.height - 100),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'trending_up':
        return Icons.trending_up;
      case 'local_florist':
        return Icons.local_florist;
      case 'water_drop':
        return Icons.water_drop;
      case 'science':
        return Icons.science;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'thermostat':
        return Icons.thermostat;
      case 'warning':
        return Icons.warning;
      case 'height':
        return Icons.height;
      case 'info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }
}

/// Configuration panel for AR overlay settings
class AROverlayConfigPanel extends ConsumerWidget {
  final String plantId;
  final ARVisualizationConfig currentConfig;
  final Function(ARVisualizationConfig) onConfigChanged;

  const AROverlayConfigPanel({
    super.key,
    required this.plantId,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AR Overlay Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Opacity slider
          Text(
            'Overlay Opacity: ${(currentConfig.overlayOpacity * 100).round()}%',
          ),
          Slider(
            value: currentConfig.overlayOpacity,
            onChanged: (value) {
              onConfigChanged(currentConfig.copyWith(overlayOpacity: value));
            },
          ),

          const SizedBox(height: 16),

          // Toggle switches
          _buildToggleOption(
            'Show Predictions',
            currentConfig.showPredictions,
            (value) =>
                onConfigChanged(currentConfig.copyWith(showPredictions: value)),
          ),

          _buildToggleOption(
            'Show Care Adjustments',
            currentConfig.showCareAdjustments,
            (value) => onConfigChanged(
              currentConfig.copyWith(showCareAdjustments: value),
            ),
          ),

          _buildToggleOption(
            'Show Risk Factors',
            currentConfig.showRiskFactors,
            (value) =>
                onConfigChanged(currentConfig.copyWith(showRiskFactors: value)),
          ),

          _buildToggleOption(
            'Show Growth Projections',
            currentConfig.showGrowthProjections,
            (value) => onConfigChanged(
              currentConfig.copyWith(showGrowthProjections: value),
            ),
          ),

          const SizedBox(height: 16),

          // Detail level
          const Text('Detail Level'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'minimal', label: Text('Minimal')),
              ButtonSegment(value: 'medium', label: Text('Medium')),
              ButtonSegment(value: 'detailed', label: Text('Detailed')),
            ],
            selected: {currentConfig.detailLevel},
            onSelectionChanged: (Set<String> selection) {
              onConfigChanged(
                currentConfig.copyWith(detailLevel: selection.first),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
