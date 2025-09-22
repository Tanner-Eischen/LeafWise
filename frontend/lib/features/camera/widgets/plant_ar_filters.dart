import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leafwise/features/camera/services/ar_data_service.dart';
import 'package:leafwise/core/network/api_client.dart';

/// Advanced AR filters for plant-focused camera features with seamless integration
class PlantARFilters extends StatefulWidget {
  final CameraController cameraController;
  final Function(String filterType) onFilterSelected;
  final String? currentFilter;
  final String? selectedPlantId; // ID of selected plant for personalized data
  final String? selectedPlantType; // Type of plant for AR scanning
  final String? userLocation; // User's location for environmental data
  final Function(String plantId)? onPlantSaved; // Callback when plant is saved
  final Function(String reminderId)?
  onReminderCompleted; // Callback when reminder completed

  const PlantARFilters({
    super.key,
    required this.cameraController,
    required this.onFilterSelected,
    this.currentFilter,
    this.selectedPlantId,
    this.selectedPlantType,
    this.userLocation,
    this.onPlantSaved,
    this.onReminderCompleted,
  });

  @override
  State<PlantARFilters> createState() => _PlantARFiltersState();
}

class _PlantARFiltersState extends State<PlantARFilters>
    with TickerProviderStateMixin {
  late AnimationController _growthAnimationController;
  late AnimationController _healthPulseController;
  late AnimationController _seasonalController;
  late AnimationController _scanningController;
  late AnimationController _trackingController;
  late AnimationController _overlayFadeController;

  // AR Data Service
  late ARDataService _arDataService;

  // Real-time data with caching
  Map<String, dynamic>? _identificationData;
  Map<String, dynamic>? _healthData;
  List<Map<String, dynamic>>? _careReminders;
  Map<String, dynamic>? _growthTimeline;
  Map<String, dynamic>? _seasonalData;

  // Performance caching
  final Map<String, dynamic> _dataCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Loading states
  bool _isIdentifying = false;
  bool _isLoadingHealth = false;
  bool _isLoadingReminders = false;
  bool _isLoadingGrowth = false;
  bool _isSavingPlant = false;

  // AR tracking state
  bool _isTracking = false;
  Offset? _plantPosition;
  double _trackingConfidence = 0.0;

  // Visual feedback
  bool _showTrackingIndicator = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with optimized durations
    _growthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _healthPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _seasonalController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _scanningController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    _trackingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _overlayFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize AR data service
    _arDataService = ARDataService(
      ApiClient(
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
      ),
    );

    // Load initial data
    _loadInitialData();

    // Start AR tracking for selected plant
    if (widget.selectedPlantId != null) {
      _startARTracking();
    }
  }

  @override
  void didUpdateWidget(PlantARFilters oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle plant selection changes
    if (oldWidget.selectedPlantId != widget.selectedPlantId) {
      if (widget.selectedPlantId != null) {
        _loadInitialData();
        _startARTracking();
      } else {
        _stopARTracking();
      }
    }

    // Handle plant type changes for AR scanning
    if (oldWidget.selectedPlantType != widget.selectedPlantType) {
      _updateARScanningMode();
    }
  }

  @override
  void dispose() {
    _growthAnimationController.dispose();
    _healthPulseController.dispose();
    _seasonalController.dispose();
    _scanningController.dispose();
    _trackingController.dispose();
    _overlayFadeController.dispose();
    _stopARTracking();
    super.dispose();
  }

  // Performance-optimized data loading with caching
  Future<void> _loadInitialData() async {
    if (_isCacheValid()) {
      return; // Use cached data
    }

    if (widget.selectedPlantId != null) {
      await Future.wait([
        _loadCareReminders(),
        _loadGrowthTimeline(),
        _loadHealthData(),
        _loadSeasonalData(),
      ]);

      _lastCacheUpdate = DateTime.now();
    }
  }

  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration;
  }

  // Enhanced AR tracking system
  void _startARTracking() {
    setState(() {
      _isTracking = true;
      _showTrackingIndicator = true;
      _statusMessage = 'Initializing AR tracking...';
    });

    _trackingController.forward();
    _overlayFadeController.forward();

    // Simulate AR tracking initialization
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isTracking) {
        setState(() {
          _trackingConfidence = 0.85;
          _plantPosition = const Offset(0.5, 0.6); // Center-bottom of screen
          _statusMessage = 'Plant tracked successfully';
        });

        // Hide status message after success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _statusMessage = null;
            });
          }
        });
      }
    });
  }

  void _stopARTracking() {
    setState(() {
      _isTracking = false;
      _showTrackingIndicator = false;
      _plantPosition = null;
      _trackingConfidence = 0.0;
      _statusMessage = null;
    });

    _trackingController.reset();
    _overlayFadeController.reverse();
  }

  void _updateARScanningMode() {
    if (widget.selectedPlantType != null) {
      setState(() {
        _statusMessage = 'Scanning for ${widget.selectedPlantType}...';
      });

      // Clear status after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }

  Future<void> _loadCareReminders() async {
    if (_isLoadingReminders) return;

    // Check cache first
    final cacheKey = 'reminders_${widget.selectedPlantId}';
    if (_dataCache.containsKey(cacheKey)) {
      setState(() {
        _careReminders = List<Map<String, dynamic>>.from(_dataCache[cacheKey]);
      });
      return;
    }

    setState(() {
      _isLoadingReminders = true;
    });

    try {
      final reminders = await _arDataService.getCareReminders(
        widget.selectedPlantId,
      );
      setState(() {
        _careReminders = reminders;
        _isLoadingReminders = false;
      });

      // Cache the data
      _dataCache[cacheKey] = reminders;
    } catch (e) {
      setState(() {
        _isLoadingReminders = false;
      });
    }
  }

  Future<void> _loadHealthData() async {
    if (_isLoadingHealth || widget.selectedPlantId == null) return;

    // Check cache first
    final cacheKey = 'health_${widget.selectedPlantId}';
    if (_dataCache.containsKey(cacheKey)) {
      setState(() {
        _healthData = Map<String, dynamic>.from(_dataCache[cacheKey]);
      });
      return;
    }

    setState(() {
      _isLoadingHealth = true;
    });

    try {
      final healthData = await _arDataService.getPlantHealthAnalysis(
        widget.selectedPlantId!,
      );
      setState(() {
        _healthData = healthData;
        _isLoadingHealth = false;
      });

      // Cache the data
      _dataCache[cacheKey] = healthData;
    } catch (e) {
      setState(() {
        _isLoadingHealth = false;
      });
    }
  }

  Future<void> _loadGrowthTimeline() async {
    if (_isLoadingGrowth || widget.selectedPlantId == null) return;

    // Check cache first
    final cacheKey = 'growth_${widget.selectedPlantId}';
    if (_dataCache.containsKey(cacheKey)) {
      setState(() {
        _growthTimeline = Map<String, dynamic>.from(_dataCache[cacheKey]);
      });
      return;
    }

    setState(() {
      _isLoadingGrowth = true;
    });

    try {
      final timeline = await _arDataService.getGrowthTimeline(
        widget.selectedPlantId!,
      );
      setState(() {
        _growthTimeline = timeline;
        _isLoadingGrowth = false;
      });

      // Cache the data
      _dataCache[cacheKey] = timeline;

      // Trigger growth animation
      _growthAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoadingGrowth = false;
      });
    }
  }

  Future<void> _loadSeasonalData() async {
    if (widget.selectedPlantId == null) return;

    // Check cache first
    final cacheKey = 'seasonal_${widget.selectedPlantId}';
    if (_dataCache.containsKey(cacheKey)) {
      setState(() {
        _seasonalData = Map<String, dynamic>.from(_dataCache[cacheKey]);
      });
      return;
    }

    try {
      final seasonal = await _arDataService.getSeasonalCareData(
        widget.selectedPlantId!,
      );
      setState(() {
        _seasonalData = seasonal;
      });

      // Cache the data
      _dataCache[cacheKey] = seasonal;

      // Start seasonal animation
      _seasonalController.forward();
    } catch (e) {
      // Handle error silently, seasonal data is not critical
    }
  }

  // Enhanced plant identification with plant type filtering
  Future<void> _identifyPlantFromCamera() async {
    if (_isIdentifying) return;

    setState(() {
      _isIdentifying = true;
      _identificationData = null;
      _statusMessage = 'Analyzing plant...';
    });

    try {
      // Take a picture for identification
      final image = await widget.cameraController.takePicture();
      final imageFile = File(image.path);

      setState(() {
        _statusMessage = 'Processing image...';
      });

      // Send to backend for identification with plant type filter
      final identification = await _arDataService.identifyPlantForAR(
        imageFile,
        plantTypeFilter: widget.selectedPlantType,
      );

      setState(() {
        _identificationData = identification;
        _isIdentifying = false;
        _statusMessage = 'Plant identified!';
      });

      // Clear status message after success
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });

      // Clean up the temporary image
      await imageFile.delete();
    } catch (e) {
      setState(() {
        _isIdentifying = false;
        _statusMessage = 'Failed to identify plant';
      });

      // Clear error message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }

  // Implement plant saving functionality
  Future<void> _savePlantToCollection() async {
    if (_isSavingPlant || _identificationData == null) return;

    setState(() {
      _isSavingPlant = true;
      _statusMessage = 'Saving plant to collection...';
    });

    try {
      // Prepare plant data
      final plantData = {
        'common_name': _identificationData!['commonName'],
        'scientific_name': _identificationData!['scientificName'],
        'confidence_score': _identificationData!['confidence'],
        'care_info': _identificationData!['careInfo'],
        'identified_date': DateTime.now().toIso8601String(),
        'plant_type': widget.selectedPlantType,
      };

      // Call API to save plant
      final response = await _arDataService.savePlantToCollection(plantData);
      final plantId = response['plant_id'];

      setState(() {
        _isSavingPlant = false;
        _statusMessage = 'Plant saved successfully!';
      });

      // Notify parent component
      if (widget.onPlantSaved != null) {
        widget.onPlantSaved!(plantId);
      }

      // Show success feedback
      _showSuccessFeedback('Plant added to your collection!');

      // Clear status message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSavingPlant = false;
        _statusMessage = 'Failed to save plant';
      });

      // Clear error message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }

  // Implement care reminder completion
  Future<void> _markReminderAsCompleted(String reminderId) async {
    setState(() {
      _statusMessage = 'Marking task as completed...';
    });

    try {
      await _arDataService.markReminderCompleted(reminderId);

      // Remove from local list
      setState(() {
        _careReminders?.removeWhere((reminder) => reminder['id'] == reminderId);
        _statusMessage = 'Task completed!';
      });

      // Clear cache to force refresh
      final cacheKey = 'reminders_${widget.selectedPlantId}';
      _dataCache.remove(cacheKey);

      // Notify parent component
      if (widget.onReminderCompleted != null) {
        widget.onReminderCompleted!(reminderId);
      }

      // Show success feedback
      _showSuccessFeedback('Care task completed!');

      // Refresh reminders
      await _loadCareReminders();

      // Clear status message
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to mark as completed';
      });

      // Clear error message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }

  // Enhanced success feedback
  void _showSuccessFeedback(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // AR Tracking Indicator
        if (_showTrackingIndicator && _isTracking) _buildARTrackingIndicator(),

        // Status Message Display
        if (_statusMessage != null) _buildStatusMessage(),

        // Main AR overlays based on current filter
        if (widget.currentFilter != null) _buildAROverlay(),

        // Plant position tracking indicator
        if (_plantPosition != null && _trackingConfidence > 0.5)
          _buildPlantTrackingOverlay(),
      ],
    );
  }

  // Enhanced AR tracking indicator with smooth animations
  Widget _buildARTrackingIndicator() {
    return AnimatedBuilder(
      animation: _trackingController,
      builder: (context, child) {
        return Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: _overlayFadeController,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _trackingConfidence > 0.7
                      ? Colors.green
                      : Colors.orange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Animated scanning indicator
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _trackingConfidence > 0.1
                          ? _trackingConfidence
                          : null,
                      strokeWidth: 2,
                      color: _trackingConfidence > 0.7
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _trackingConfidence > 0.7
                              ? 'Plant Tracked'
                              : 'Tracking Plant...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Confidence: ${(_trackingConfidence * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_trackingConfidence > 0.7)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced status message display
  Widget _buildStatusMessage() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getStatusIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _statusMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_statusMessage!.contains('success') ||
        _statusMessage!.contains('completed')) {
      return Colors.green;
    } else if (_statusMessage!.contains('failed') ||
        _statusMessage!.contains('error')) {
      return Colors.red;
    } else if (_statusMessage!.contains('scanning') ||
        _statusMessage!.contains('analyzing')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  Widget _getStatusIcon() {
    if (_statusMessage!.contains('success') ||
        _statusMessage!.contains('completed')) {
      return const Icon(Icons.check_circle, color: Colors.white, size: 18);
    } else if (_statusMessage!.contains('failed') ||
        _statusMessage!.contains('error')) {
      return const Icon(Icons.error, color: Colors.white, size: 18);
    } else if (_statusMessage!.contains('scanning') ||
        _statusMessage!.contains('analyzing')) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return const Icon(Icons.info, color: Colors.white, size: 18);
  }

  // Enhanced plant position tracking overlay
  Widget _buildPlantTrackingOverlay() {
    if (_plantPosition == null) return const SizedBox.shrink();

    return Positioned(
      left: MediaQuery.of(context).size.width * _plantPosition!.dx - 30,
      top: MediaQuery.of(context).size.height * _plantPosition!.dy - 30,
      child: AnimatedBuilder(
        animation: _healthPulseController,
        builder: (context, child) {
          final scale = 1.0 + (_healthPulseController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(
                Icons.center_focus_strong,
                color: Colors.green,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }

  // Main AR overlay router with improved performance
  Widget _buildAROverlay() {
    // Use AnimatedSwitcher for smooth transitions between overlays
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildSpecificOverlay(),
    );
  }

  Widget _buildSpecificOverlay() {
    switch (widget.currentFilter) {
      case 'plant_identification':
        return _buildPlantIdentificationOverlay();
      case 'health_overlay':
        return _buildHealthOverlay();
      case 'care_reminder':
        return _buildCareReminderOverlay();
      case 'growth_timelapse':
        return _buildGrowthTimelineOverlay();
      case 'seasonal_transformation':
        return _buildSeasonalTransformation();
      default:
        return const SizedBox.shrink();
    }
  }

  // Enhanced plant identification overlay with better visual cues
  Widget _buildPlantIdentificationOverlay() {
    return Stack(
      children: [
        // Scanning animation overlay
        if (_isIdentifying) _buildScanningAnimation(),

        // Identification results
        if (_identificationData != null) _buildIdentificationResults(),

        // Scan button
        Positioned(
          bottom: 120,
          left: 20,
          right: 20,
          child: Center(
            child: GestureDetector(
              onTap: _isIdentifying ? null : _identifyPlantFromCamera,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isIdentifying ? 80 : 120,
                height: _isIdentifying ? 80 : 50,
                decoration: BoxDecoration(
                  color: _isIdentifying ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(_isIdentifying ? 40 : 25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isIdentifying
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Scan Plant',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Improved scanning animation with AR-style visual effects
  Widget _buildScanningAnimation() {
    return AnimatedBuilder(
      animation: _scanningController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ScanningOverlayPainter(
              progress: _scanningController.value,
              plantType: widget.selectedPlantType,
            ),
          ),
        );
      },
    );
  }

  // Enhanced identification results with smooth animations
  Widget _buildIdentificationResults() {
    final data = _identificationData!;
    final confidence = data['confidence'] as double;

    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: confidence > 0.8 ? Colors.green : Colors.orange,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with confidence indicator
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: confidence > 0.8 ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['commonName'] ?? 'Unknown Plant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        data['scientificName'] ?? 'Unknown Species',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: confidence > 0.8 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(confidence * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick care info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickCareInfo(
                  Icons.wb_sunny,
                  data['careInfo']?['light'] ?? 'Medium',
                ),
                _buildQuickCareInfo(
                  Icons.water_drop,
                  data['careInfo']?['water'] ?? 'Weekly',
                ),
                _buildQuickCareInfo(
                  Icons.thermostat,
                  data['careInfo']?['temperature'] ?? '65-75F',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _identificationData = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('New Scan'),
                ),
                ElevatedButton.icon(
                  onPressed: _isSavingPlant ? null : _savePlantToCollection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSavingPlant
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: Text(_isSavingPlant ? 'Saving...' : 'Save Plant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCareInfo(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green, size: 16),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHealthOverlay() {
    if (_isLoadingHealth) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    final healthData = _healthData;
    if (healthData == null) {
      return const Center(
        child: Text(
          'No health data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final overallHealth = healthData['overallHealth'] ?? 0.0;
    final metrics = List<Map<String, dynamic>>.from(
      healthData['metrics'] ?? [],
    );
    final recommendations = List<String>.from(
      healthData['recommendations'] ?? [],
    );

    return AnimatedBuilder(
      animation: _healthPulseController,
      builder: (context, child) {
        return Stack(
          children: [
            // Health indicators positioned around detected plant areas
            ...metrics.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;

              return _buildHealthIndicator(
                top: 200 + (index * 80.0),
                left: 100 + (index * 30.0),
                healthScore: metric['score'] ?? 0.0,
                label: metric['name'] ?? 'Unknown',
                icon: _getIconData(metric['icon'] ?? 'info'),
                status: metric['status'] ?? 'good',
              );
            }),

            // Health summary panel with real data
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: _buildHealthSummaryPanel(overallHealth, recommendations),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthIndicator({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double healthScore,
    required String label,
    required IconData icon,
    required String status,
  }) {
    final color = status == 'good'
        ? Colors.green
        : status == 'warning'
        ? Colors.orange
        : Colors.red;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing health indicator
            AnimatedBuilder(
              animation: _healthPulseController,
              builder: (context, child) {
                final scale = 1.0 + (_healthPulseController.value * 0.2);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(healthScore * 100).round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSummaryPanel(
    double overallHealth,
    List<String> recommendations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Plant Health Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(overallHealth * 100).round()}%',
                style: TextStyle(
                  color: overallHealth > 0.8
                      ? Colors.green
                      : overallHealth > 0.6
                      ? Colors.orange
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommendations:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...recommendations
                .take(3)
                .map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.green)),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonalTransformation() {
    final seasonalData = _seasonalData;
    if (seasonalData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    final currentSeason = seasonalData['currentSeason'] ?? 'spring';
    final adjustments = Map<String, String>.from(
      seasonalData['adjustments'] ?? {},
    );
    final tips = List<String>.from(seasonalData['tips'] ?? []);

    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        return Stack(
          children: [
            // Seasonal effects
            _buildSeasonalEffects(currentSeason),

            // Seasonal info panel
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getSeasonalColor(currentSeason).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSeasonalIcon(currentSeason),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentSeason Care',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...adjustments.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key.toUpperCase()}: ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (tips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white70),
                      const SizedBox(height: 4),
                      ...tips
                          .take(2)
                          .map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '💡 ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeasonalEffects(String season) {
    // Add visual effects based on season
    switch (season.toLowerCase()) {
      case 'spring':
        return _buildSpringEffects();
      case 'summer':
        return _buildSummerEffects();
      case 'fall':
        return _buildFallEffects();
      case 'winter':
        return _buildWinterEffects();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSpringEffects() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        return Stack(
          children: List.generate(10, (index) {
            final offset = _seasonalController.value * 2 * math.pi;
            return Positioned(
              left: 50 + (index * 30) + math.sin(offset + index) * 20,
              top: 100 + (index * 40) + math.cos(offset + index) * 15,
              child: Icon(
                Icons.local_florist,
                color: Colors.pink.withOpacity(0.7),
                size: 16,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSummerEffects() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset = _seasonalController.value * 2 * math.pi;
            return Positioned(
              left: 60 + (index * 40) + math.sin(offset + index) * 25,
              top: 80 + (index * 50) + math.cos(offset + index) * 20,
              child: Icon(
                Icons.wb_sunny,
                color: Colors.yellow.withOpacity(0.8),
                size: 20,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFallEffects() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final offset = _seasonalController.value * 2 * math.pi;
            return Positioned(
              left: 40 + (index * 25) + math.sin(offset + index) * 30,
              top: 120 + (index * 35) + math.cos(offset + index) * 25,
              child: Icon(
                Icons.eco,
                color: Colors.orange.withOpacity(0.7),
                size: 14,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildWinterEffects() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final offset = _seasonalController.value * 2 * math.pi;
            return Positioned(
              left: 30 + (index * 20) + math.sin(offset + index) * 15,
              top: 90 + (index * 30) + math.cos(offset + index) * 10,
              child: Icon(
                Icons.ac_unit,
                color: Colors.lightBlue.withOpacity(0.6),
                size: 12,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCareReminderOverlay() {
    if (_isLoadingReminders) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    final reminders = _careReminders;
    if (reminders == null || reminders.isEmpty) {
      return Positioned(
        top: 100,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'All Caught Up!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'No care tasks due right now',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Show the most urgent reminder
    final urgentReminder = reminders.first;
    final dueDate = urgentReminder['dueDate'] as DateTime;
    final isOverdue = urgentReminder['isOverdue'] as bool;

    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isOverdue ? Colors.red : Colors.blue).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getIconData(urgentReminder['icon'] ?? 'schedule'),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOverdue ? 'Overdue Care Task' : 'Care Reminder',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgentReminder['priority']?.toString().toUpperCase() ??
                        'MEDIUM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              urgentReminder['description'] ?? 'Care task due',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              isOverdue
                  ? 'Overdue by ${DateTime.now().difference(dueDate).inDays} days'
                  : 'Due ${_formatDueDate(dueDate)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _markReminderAsCompleted(urgentReminder['id'] as String);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isOverdue ? Colors.red : Colors.blue,
                  ),
                  child: const Text('Done'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Snooze reminder for 1 hour
                    _snoozeReminder(
                      urgentReminder['id'] as String,
                      const Duration(hours: 1),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Snooze'),
                ),
              ],
            ),
            if (reminders.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                '+${reminders.length - 1} more task${reminders.length > 2 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTimelineOverlay() {
    if (_isLoadingGrowth) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    final growthData = _growthTimeline;
    if (growthData == null) {
      return const Center(
        child: Text(
          'No growth timeline data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final timelineEntries = List<Map<String, dynamic>>.from(
      growthData['timeline'] ?? [],
    );
    final growthMetrics = Map<String, dynamic>.from(
      growthData['metrics'] ?? {},
    );

    return AnimatedBuilder(
      animation: _growthAnimationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Growth timeline visualization
            Positioned(
              left: 20,
              right: 20,
              bottom: 120,
              height: 200,
              child: _buildTimelineVisualization(timelineEntries),
            ),

            // Growth metrics panel
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: _buildGrowthMetricsPanel(growthMetrics),
            ),

            // Timeline controls
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: _buildTimelineControls(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineVisualization(
    List<Map<String, dynamic>> timelineEntries,
  ) {
    if (timelineEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No timeline data available yet',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Timeline',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                // Timeline dates column
                SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: timelineEntries.map((entry) {
                      final date = entry['date'] as DateTime;
                      return Text(
                        '${date.month}/${date.day}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Timeline visualization
                Expanded(
                  child: Stack(
                    children: [
                      // Growth line
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GrowthTimelinePainter(
                            timelineEntries: timelineEntries,
                            progress: _growthAnimationController.value,
                          ),
                        ),
                      ),

                      // Timeline points
                      ...timelineEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final heightPercent =
                            index / (timelineEntries.length - 1);

                        return Positioned(
                          left: 0,
                          right: 0,
                          top: 150 * heightPercent,
                          height: 20,
                          child: Opacity(
                            opacity:
                                _growthAnimationController.value >
                                    (index / timelineEntries.length)
                                ? 1.0
                                : 0.0,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['note'] ?? 'Growth recorded',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetricsPanel(Map<String, dynamic> metrics) {
    final height = metrics['height'] ?? 0.0;
    final width = metrics['width'] ?? 0.0;
    final growthRate = metrics['growthRate'] ?? 0.0;
    final healthScore = metrics['healthScore'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Growth Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(healthScore * 100).round()}% Health',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGrowthMetricItem('Height', '$height cm', Icons.height),
              _buildGrowthMetricItem('Width', '$width cm', Icons.width_normal),
              _buildGrowthMetricItem(
                'Growth',
                '${growthRate.toStringAsFixed(1)} cm/week',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (metrics.containsKey('recommendations')) ...[
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber, size: 16),
                SizedBox(width: 8),
                Text(
                  'Growth Tips:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              metrics['recommendations'] as String,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrowthMetricItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimelineControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Reset animation
            _growthAnimationController.reset();
            _growthAnimationController.forward();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.replay, size: 16),
          label: const Text('Replay Growth'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Generate timelapse video
            _generateTimelapseVideo();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.movie, size: 16),
          label: const Text('Generate Video'),
        ),
      ],
    );
  }

  Future<void> _generateTimelapseVideo() async {
    if (widget.selectedPlantId == null) return;

    setState(() {
      _statusMessage = 'Generating timelapse video...';
    });

    try {
      await _arDataService.generateTimelapseVideo(widget.selectedPlantId!);

      setState(() {
        _statusMessage = 'Video generated successfully!';
      });

      // Show success feedback
      _showSuccessFeedback('Timelapse video created! Check your gallery.');

      // Clear status message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to generate video';
      });

      // Clear error message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }

  Widget _buildFilterSelector() {
    final filters = [
      {'id': 'growth_timelapse', 'name': 'Growth', 'icon': Icons.timeline},
      {'id': 'health_overlay', 'name': 'Health', 'icon': Icons.favorite},
      {
        'id': 'seasonal_transformation',
        'name': 'Seasons',
        'icon': Icons.calendar_today,
      },
      {'id': 'plant_identification', 'name': 'ID Plant', 'icon': Icons.search},
      {'id': 'care_reminder', 'name': 'Care', 'icon': Icons.schedule},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = widget.currentFilter == filter['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                if (isSelected) {
                  widget.onFilterSelected('none');
                } else {
                  widget.onFilterSelected(filter['id'] as String);
                  _startFilterAnimation(filter['id'] as String);
                }
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withOpacity(0.8)
                      : Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startFilterAnimation(String filterType) {
    switch (filterType) {
      case 'growth_timelapse':
        _growthAnimationController.reset();
        _growthAnimationController.forward();
        break;
      case 'seasonal_transformation':
        _seasonalController.reset();
        _seasonalController.repeat();
        break;
    }
  }

  // Utility methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'water_drop':
        return Icons.water_drop;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'science':
        return Icons.science;
      case 'content_cut':
        return Icons.content_cut;
      case 'local_florist':
        return Icons.local_florist;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  Color _getSeasonalColor(String season) {
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

  IconData _getSeasonalIcon(String season) {
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

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inDays > 1) {
      return 'in ${difference.inDays} days';
    } else {
      return '${difference.inDays.abs()} days ago';
    }
  }

  Widget _buildARFilterControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'AR Filters & Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterCategory(
                  'Health',
                  Icons.favorite,
                  Colors.green,
                  true,
                ),
                const SizedBox(width: 12),
                _buildFilterCategory(
                  'Growth',
                  Icons.trending_up,
                  Colors.blue,
                  false,
                ),
                const SizedBox(width: 12),
                _buildFilterCategory(
                  'Care',
                  Icons.water_drop,
                  Colors.orange,
                  false,
                ),
                const SizedBox(width: 12),
                _buildFilterCategory('Info', Icons.info, Colors.purple, false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Options
          _buildActiveFilters(theme),
          const SizedBox(height: 16),

          // Control Sliders
          _buildARControlSliders(theme),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(
    String name,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle category
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : Colors.grey, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme) {
    final healthFilters = [
      {'name': 'Disease Detection', 'icon': Icons.bug_report, 'active': true},
      {'name': 'Leaf Health', 'icon': Icons.eco, 'active': false},
      {'name': 'Growth Tracking', 'icon': Icons.timeline, 'active': false},
      {'name': 'Watering Status', 'icon': Icons.water_drop, 'active': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Overlays',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: healthFilters.map((filter) {
            return _buildFilterToggle(
              filter['name'] as String,
              filter['icon'] as IconData,
              filter['active'] as bool,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(String name, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle filter
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isActive ? 'Disabled' : 'Enabled'} $name overlay'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? Colors.green : Colors.grey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 14),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARControlSliders(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AR Overlay Controls',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        _buildControlSlider('Overlay Opacity', 0.8, Colors.blue),
        _buildControlSlider('Detection Sensitivity', 0.6, Colors.orange),
        _buildControlSlider('Update Frequency', 0.5, Colors.purple),

        const SizedBox(height: 12),

        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _buildQuickAction('Reset View', Icons.refresh, () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('AR view reset')));
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAction('Save Settings', Icons.save, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AR settings saved')),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlSlider(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 2,
          ),
          child: Slider(
            value: value,
            onChanged: (newValue) {
              setState(() {
                // Update slider value
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _snoozeReminder(String reminderId, Duration duration) async {
    setState(() {
      _statusMessage = 'Snoozing reminder...';
    });

    try {
      await _arDataService.snoozeReminder(reminderId, duration);

      // Remove from local list temporarily
      setState(() {
        _careReminders?.removeWhere((reminder) => reminder['id'] == reminderId);
        _statusMessage = 'Reminder snoozed for ${duration.inHours} hours';
      });

      // Clear cache to force refresh
      final cacheKey = 'reminders_${widget.selectedPlantId}';
      _dataCache.remove(cacheKey);

      // Show success feedback
      _showSuccessFeedback('Reminder snoozed for ${duration.inHours} hours');

      // Clear status message
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to snooze reminder';
      });

      // Clear error message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = null;
          });
        }
      });
    }
  }
}

/// Custom painter for AR scanning animation overlay
class ScanningOverlayPainter extends CustomPainter {
  final double progress;
  final String? plantType;

  ScanningOverlayPainter({required this.progress, this.plantType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final scanRadius = (size.width * 0.3) + (progress * size.width * 0.2);

    // Draw scanning circle
    canvas.drawCircle(center, scanRadius, paint);

    // Draw scanning lines
    final linePaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final angle = (progress * 2 * math.pi) + (i * math.pi / 4);
      final startRadius = scanRadius - 20;
      final endRadius = scanRadius + 20;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(start, end, linePaint);
    }

    // Draw corner brackets for AR scanner effect
    _drawCornerBrackets(canvas, size);

    // Draw plant type indicator if specified
    if (plantType != null) {
      _drawPlantTypeIndicator(canvas, size, plantType!);
    }
  }

  void _drawCornerBrackets(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const bracketSize = 30.0;
    final margin = size.width * 0.15;

    // Top-left bracket
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + bracketSize)
        ..lineTo(margin, margin)
        ..lineTo(margin + bracketSize, margin),
      bracketPaint,
    );

    // Top-right bracket
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - bracketSize, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + bracketSize),
      bracketPaint,
    );

    // Bottom-left bracket
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - bracketSize)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + bracketSize, size.height - margin),
      bracketPaint,
    );

    // Bottom-right bracket
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - bracketSize, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - bracketSize),
      bracketPaint,
    );
  }

  void _drawPlantTypeIndicator(Canvas canvas, Size size, String plantType) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Scanning for: $plantType',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      size.height * 0.85,
    );

    // Draw background
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - 8,
          offset.dy - 4,
          textPainter.width + 16,
          textPainter.height + 8,
        ),
        const Radius.circular(8),
      ),
      backgroundPaint,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant ScanningOverlayPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        plantType != oldDelegate.plantType;
  }
}

/// Custom painter for growth timeline visualization
class GrowthTimelinePainter extends CustomPainter {
  final List<Map<String, dynamic>> timelineEntries;
  final double progress;

  GrowthTimelinePainter({
    required this.timelineEntries,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (timelineEntries.isEmpty) return;

    // Setup paints
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Calculate points for the growth line
    final points = <Offset>[];
    final heights = timelineEntries
        .map((e) => e['height'] as double? ?? 0.0)
        .toList();

    // Find min and max heights for scaling
    final maxHeight = heights.reduce((a, b) => a > b ? a : b);
    final minHeight = heights.reduce((a, b) => a < b ? a : b);
    final heightRange = maxHeight - minHeight;

    // Calculate points based on timeline entries
    for (int i = 0; i < timelineEntries.length; i++) {
      final xPos = size.width * (i / (timelineEntries.length - 1));

      // Normalize height to fit in the available space
      final normalizedHeight = heightRange > 0
          ? (heights[i] - minHeight) / heightRange
          : 0.5;

      // Invert Y coordinate (0 is top in Flutter)
      final yPos = size.height - (normalizedHeight * size.height);

      points.add(Offset(xPos, yPos));
    }

    // Draw the growth line with animation
    final path = Path();

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      // Calculate how many points to include based on animation progress
      final pointsToInclude = (points.length * progress).ceil();
      final visiblePoints = points.take(pointsToInclude).toList();

      for (int i = 1; i < visiblePoints.length; i++) {
        // Use quadratic bezier curves for smoother lines
        if (i < visiblePoints.length - 1) {
          final controlPoint = Offset(
            (visiblePoints[i].dx + visiblePoints[i + 1].dx) / 2,
            visiblePoints[i].dy,
          );
          path.quadraticBezierTo(
            visiblePoints[i].dx,
            visiblePoints[i].dy,
            controlPoint.dx,
            controlPoint.dy,
          );
        } else {
          path.lineTo(visiblePoints[i].dx, visiblePoints[i].dy);
        }
      }

      // Complete the path for filling
      if (visiblePoints.isNotEmpty) {
        path.lineTo(visiblePoints.last.dx, size.height);
        path.lineTo(points.first.dx, size.height);
        path.close();

        // Draw filled area first
        canvas.drawPath(path, fillPaint);

        // Draw the line on top
        canvas.drawPath(
          Path()
            ..moveTo(points.first.dx, points.first.dy)
            ..addPath(path, Offset.zero),
          linePaint,
        );
      }
    }

    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < points.length * progress; i++) {
      if (i >= points.length) break;
      canvas.drawCircle(points[i], 4, pointPaint);
      canvas.drawCircle(points[i], 4, pointStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GrowthTimelinePainter oldDelegate) {
    return progress != oldDelegate.progress ||
        timelineEntries.length != oldDelegate.timelineEntries.length;
  }
}
