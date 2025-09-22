/// AR Seasonal Integration Widget
///
/// Main integration widget that combines all AR seasonal visualization components.
/// Provides a unified interface for seasonal overlays, growth projections, and time-lapse previews.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/camera/models/ar_seasonal_models.dart';
import 'package:leafwise/features/camera/widgets/ar_seasonal_overlay.dart';
import 'package:leafwise/features/camera/widgets/ar_growth_projection.dart';
import 'package:leafwise/features/camera/widgets/ar_timelapse_preview.dart';
import 'package:leafwise/features/camera/widgets/ar_seasonal_transformation.dart';
import 'package:leafwise/features/seasonal_ai/models/seasonal_ai_models.dart';

/// AR mode enumeration
enum ARSeasonalMode {
  overlay,
  growthProjection,
  timelapsePreview,
  seasonalTransformation,
}

/// Main AR seasonal integration widget
class ARSeasonalIntegration extends ConsumerStatefulWidget {
  final String plantId;
  final SeasonalPrediction prediction;
  final Size screenSize;
  final String? timelapseSessionId;
  final ARSeasonalMode initialMode;
  final Function(ARSeasonalMode)? onModeChanged;

  const ARSeasonalIntegration({
    super.key,
    required this.plantId,
    required this.prediction,
    required this.screenSize,
    this.timelapseSessionId,
    this.initialMode = ARSeasonalMode.overlay,
    this.onModeChanged,
  });

  @override
  ConsumerState<ARSeasonalIntegration> createState() =>
      _ARSeasonalIntegrationState();
}

class _ARSeasonalIntegrationState extends ConsumerState<ARSeasonalIntegration>
    with TickerProviderStateMixin {
  late ARSeasonalMode _currentMode;
  late AnimationController _modeTransitionController;

  // AR tracking state
  ARPosition _plantPosition = const ARPosition(x: 0.0, y: 0.0, z: 0.0);
  bool _isTracking = false;

  // Configuration states
  ARVisualizationConfig _overlayConfig = const ARVisualizationConfig();
  final ARProjectionConfig _projectionConfig = const ARProjectionConfig();
  final ARTimelapseControls _timelapseControls = const ARTimelapseControls();

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;

    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _initializeARTracking();
  }

  @override
  void dispose() {
    _modeTransitionController.dispose();
    super.dispose();
  }

  void _initializeARTracking() {
    // Simulate AR tracking initialization
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTracking = true;
          _plantPosition = const ARPosition(x: 0.0, y: 0.0, z: 0.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main AR content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentModeContent(),
        ),

        // Mode selector
        _buildModeSelector(),

        // Settings panel
        _buildSettingsPanel(),

        // AR status indicator
        if (_isTracking) _buildARStatusIndicator(),
      ],
    );
  }

  Widget _buildCurrentModeContent() {
    switch (_currentMode) {
      case ARSeasonalMode.overlay:
        return ARSeasonalOverlayWidget(
          key: const ValueKey('overlay'),
          plantId: widget.plantId,
          prediction: widget.prediction,
          screenSize: widget.screenSize,
          initialConfig: _overlayConfig,
          onConfigTap: () => _showConfigPanel(ARSeasonalMode.overlay),
          onElementTap: (elementId) => _handleElementTap(elementId),
        );

      case ARSeasonalMode.growthProjection:
        return ARGrowthProjectionWidget(
          key: const ValueKey('projection'),
          plantId: widget.plantId,
          prediction: widget.prediction,
          screenSize: widget.screenSize,
          plantPosition: _plantPosition,
          config: _projectionConfig,
          onStageChanged: (stage) => _handleStageChanged(stage),
        );

      case ARSeasonalMode.timelapsePreview:
        if (widget.timelapseSessionId != null) {
          return ARTimelapsePreviewWidget(
            key: const ValueKey('timelapse'),
            sessionId: widget.timelapseSessionId!,
            screenSize: widget.screenSize,
            plantPosition: _plantPosition,
            controls: _timelapseControls,
            onFrameChanged: (frame) => _handleFrameChanged(frame),
            onPlaybackToggle: (isPlaying) => _handlePlaybackToggle(isPlaying),
          );
        } else {
          return _buildNoTimelapseMessage();
        }

      case ARSeasonalMode.seasonalTransformation:
        return ARSeasonalTransformationWidget(
          key: const ValueKey('transformation'),
          plantId: widget.plantId,
          currentSeason: _getCurrentSeason(),
          targetSeason: _getNextSeason(),
          screenSize: widget.screenSize,
          plantPosition: _plantPosition,
          onProgressChanged: (progress) =>
              _handleTransformationProgress(progress),
          onSeasonChanged: (season) => _handleSeasonChanged(season),
        );
    }
  }

  Widget _buildModeSelector() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: ARSeasonalMode.values.map((mode) {
            final isSelected = mode == _currentMode;
            return Expanded(
              child: GestureDetector(
                onTap: () => _switchMode(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getModeIcon(mode), color: Colors.white, size: 16),
                        const SizedBox(height: 2),
                        Text(
                          _getModeLabel(mode),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Positioned(
      top: 100,
      right: 20,
      child: GestureDetector(
        onTap: () => _showConfigPanel(_currentMode),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildARStatusIndicator() {
    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              'AR Active',
              style: TextStyle(
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

  Widget _buildNoTimelapseMessage() {
    return Positioned(
      top: widget.screenSize.height * 0.4,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white70, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No Time-lapse Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start a time-lapse session to preview growth in AR',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startTimelapseSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Time-lapse'),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers

  void _switchMode(ARSeasonalMode mode) {
    if (mode == _currentMode) return;

    setState(() {
      _currentMode = mode;
    });

    widget.onModeChanged?.call(mode);
    _modeTransitionController.forward().then((_) {
      _modeTransitionController.reset();
    });
  }

  void _showConfigPanel(ARSeasonalMode mode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConfigPanelForMode(mode),
    );
  }

  Widget _buildConfigPanelForMode(ARSeasonalMode mode) {
    switch (mode) {
      case ARSeasonalMode.overlay:
        return AROverlayConfigPanel(
          plantId: widget.plantId,
          currentConfig: _overlayConfig,
          onConfigChanged: (config) {
            setState(() {
              _overlayConfig = config;
            });
          },
        );
      default:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_getModeLabel(mode)} Settings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Configuration options coming soon...'),
            ],
          ),
        );
    }
  }

  void _handleElementTap(String elementId) {
    // Handle overlay element tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped element: $elementId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleStageChanged(int stage) {
    // Handle growth projection stage change
  }

  void _handleFrameChanged(int frame) {
    // Handle time-lapse frame change
  }

  void _handlePlaybackToggle(bool isPlaying) {
    // Handle time-lapse playback toggle
  }

  void _handleTransformationProgress(double progress) {
    // Handle seasonal transformation progress
  }

  void _handleSeasonChanged(String season) {
    // Handle season change
  }

  void _startTimelapseSession() {
    // Navigate to time-lapse session creation
    Navigator.of(context).pop(); // Close the modal
    // Add navigation logic here
  }

  // Helper methods

  IconData _getModeIcon(ARSeasonalMode mode) {
    switch (mode) {
      case ARSeasonalMode.overlay:
        return Icons.layers;
      case ARSeasonalMode.growthProjection:
        return Icons.trending_up;
      case ARSeasonalMode.timelapsePreview:
        return Icons.play_circle;
      case ARSeasonalMode.seasonalTransformation:
        return Icons.transform;
    }
  }

  String _getModeLabel(ARSeasonalMode mode) {
    switch (mode) {
      case ARSeasonalMode.overlay:
        return 'Overlay';
      case ARSeasonalMode.growthProjection:
        return 'Growth';
      case ARSeasonalMode.timelapsePreview:
        return 'Timelapse';
      case ARSeasonalMode.seasonalTransformation:
        return 'Seasons';
    }
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  String _getNextSeason() {
    final current = _getCurrentSeason();
    switch (current) {
      case 'Spring':
        return 'Summer';
      case 'Summer':
        return 'Fall';
      case 'Fall':
        return 'Winter';
      case 'Winter':
        return 'Spring';
      default:
        return 'Spring';
    }
  }
}
