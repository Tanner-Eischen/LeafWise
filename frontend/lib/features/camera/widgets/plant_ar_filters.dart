import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:plant_social/features/camera/services/ar_data_service.dart';
import 'package:plant_social/core/network/api_client.dart';

/// Advanced AR filters for plant-focused camera features with real backend data
class PlantARFilters extends StatefulWidget {
  final CameraController cameraController;
  final Function(String filterType) onFilterSelected;
  final String? currentFilter;
  final String? selectedPlantId; // ID of selected plant for personalized data
  final String? userLocation; // User's location for environmental data

  const PlantARFilters({
    Key? key,
    required this.cameraController,
    required this.onFilterSelected,
    this.currentFilter,
    this.selectedPlantId,
    this.userLocation,
  }) : super(key: key);

  @override
  State<PlantARFilters> createState() => _PlantARFiltersState();
}

class _PlantARFiltersState extends State<PlantARFilters>
    with TickerProviderStateMixin {
  late AnimationController _growthAnimationController;
  late AnimationController _healthPulseController;
  late AnimationController _seasonalController;
  late AnimationController _scanningController;

  // AR Data Service
  late ARDataService _arDataService;

  // Real-time data
  Map<String, dynamic>? _identificationData;
  Map<String, dynamic>? _healthData;
  List<Map<String, dynamic>>? _careReminders;
  Map<String, dynamic>? _growthTimeline;
  Map<String, dynamic>? _seasonalData;

  // Loading states
  bool _isIdentifying = false;
  bool _isLoadingHealth = false;
  bool _isLoadingReminders = false;
  bool _isLoadingGrowth = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _growthAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _healthPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _seasonalController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scanningController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Initialize AR data service
    _arDataService = ARDataService(ApiClient());
    
    // Load initial data
    _loadInitialData();
  }

  @override
  void dispose() {
    _growthAnimationController.dispose();
    _healthPulseController.dispose();
    _seasonalController.dispose();
    _scanningController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Load care reminders and seasonal data if plant is selected
    if (widget.selectedPlantId != null) {
      _loadCareReminders();
      _loadGrowthTimeline();
      _loadHealthData();
      _loadSeasonalData();
    }
  }

  Future<void> _loadCareReminders() async {
    if (_isLoadingReminders) return;
    
    setState(() {
      _isLoadingReminders = true;
    });

    try {
      final reminders = await _arDataService.getCareReminders(widget.selectedPlantId);
      setState(() {
        _careReminders = reminders;
        _isLoadingReminders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReminders = false;
      });
    }
  }

  Future<void> _loadHealthData() async {
    if (_isLoadingHealth || widget.selectedPlantId == null) return;
    
    setState(() {
      _isLoadingHealth = true;
    });

    try {
      final healthData = await _arDataService.getPlantHealthAnalysis(widget.selectedPlantId!);
      setState(() {
        _healthData = healthData;
        _isLoadingHealth = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHealth = false;
      });
    }
  }

  Future<void> _loadGrowthTimeline() async {
    if (_isLoadingGrowth || widget.selectedPlantId == null) return;
    
    setState(() {
      _isLoadingGrowth = true;
    });

    try {
      final timeline = await _arDataService.getGrowthTimeline(widget.selectedPlantId!);
      setState(() {
        _growthTimeline = timeline;
        _isLoadingGrowth = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGrowth = false;
      });
    }
  }

  Future<void> _loadSeasonalData() async {
    if (widget.selectedPlantId == null) return;
    
    try {
      final seasonal = await _arDataService.getSeasonalCareData(widget.selectedPlantId!);
      setState(() {
        _seasonalData = seasonal;
      });
    } catch (e) {
      // Handle error silently, seasonal data is not critical
    }
  }

  Future<void> _identifyPlantFromCamera() async {
    if (_isIdentifying) return;

    setState(() {
      _isIdentifying = true;
      _identificationData = null;
    });

    try {
      // Take a picture for identification
      final image = await widget.cameraController.takePicture();
      final imageFile = File(image.path);
      
      // Send to backend for identification
      final identification = await _arDataService.identifyPlantForAR(imageFile);
      
      setState(() {
        _identificationData = identification;
        _isIdentifying = false;
      });

      // Clean up the temporary image
      await imageFile.delete();
    } catch (e) {
      setState(() {
        _isIdentifying = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to identify plant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // AR Filter Overlays
        if (widget.currentFilter != null) _buildFilterOverlay(),
        
        // Filter Selection UI
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: _buildFilterSelector(),
        ),
      ],
    );
  }

  Widget _buildFilterOverlay() {
    switch (widget.currentFilter) {
      case 'growth_timelapse':
        return _buildGrowthTimelapseOverlay();
      case 'health_overlay':
        return _buildHealthOverlay();
      case 'seasonal_transformation':
        return _buildSeasonalTransformation();
      case 'plant_identification':
        return _buildPlantIdentificationOverlay();
      case 'care_reminder':
        return _buildCareReminderOverlay();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGrowthTimelapseOverlay() {
    if (_isLoadingGrowth) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    final timeline = _growthTimeline;
    if (timeline == null) {
      return const Center(
        child: Text(
          'No growth data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _growthAnimationController,
      builder: (context, child) {
        final stages = List<Map<String, dynamic>>.from(timeline['stages'] ?? []);
        final currentStage = timeline['currentStage'] ?? 0;
        final progressPercentage = timeline['progressPercentage'] ?? 0.0;

        return Stack(
          children: [
            // Growth progression indicators
            ...stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isCompleted = stage['isCompleted'] ?? false;
              final isActive = index == currentStage;

              return Positioned(
                bottom: 200 + (index * 50.0),
                left: 50 + (index * 50.0),
                child: _buildGrowthStage(
                  stage['name'] ?? 'Stage ${index + 1}',
                  isActive,
                  isCompleted,
                  stage['description'] ?? '',
                ),
              );
            }).toList(),
            
            // Timeline scrubber with real data
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: _buildTimelineScrubber(progressPercentage),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrowthStage(String label, bool isActive, bool isCompleted, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.8)
            : isActive
                ? Colors.orange.withOpacity(0.8)
                : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineScrubber(double progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Plant Growth Timeline',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _growthAnimationController.reset();
                },
                icon: const Icon(Icons.replay, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: _growthAnimationController.value,
                      onChanged: (value) {
                        _growthAnimationController.value = value;
                      },
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey,
                    ),
                    Text(
                      'Progress: ${progressPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_growthAnimationController.isAnimating) {
                    _growthAnimationController.stop();
                  } else {
                    _growthAnimationController.forward();
                  }
                },
                icon: Icon(
                  _growthAnimationController.isAnimating
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
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
    final metrics = List<Map<String, dynamic>>.from(healthData['metrics'] ?? []);
    final recommendations = List<String>.from(healthData['recommendations'] ?? []);

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
            }).toList(),
            
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

  Widget _buildHealthSummaryPanel(double overallHealth, List<String> recommendations) {
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
                  color: overallHealth > 0.8 ? Colors.green : 
                         overallHealth > 0.6 ? Colors.orange : Colors.red,
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
            ...recommendations.take(3).map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.green)),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )).toList(),
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
    final adjustments = Map<String, String>.from(seasonalData['adjustments'] ?? {});
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
                        Icon(_getSeasonalIcon(currentSeason), color: Colors.white),
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
                    ...adjustments.entries.map((entry) => Padding(
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
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    if (tips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white70),
                      const SizedBox(height: 4),
                      ...tips.take(2).map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
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

  Widget _buildPlantIdentificationOverlay() {
    return Stack(
      children: [
        // Scanning frame with animation
        Center(
          child: AnimatedBuilder(
            animation: _scanningController,
            builder: (context, child) {
              return Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isIdentifying ? Colors.orange : Colors.green, 
                    width: 3
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Scanning line
                    if (_isIdentifying)
                      Positioned(
                        top: _scanningController.value * 220,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.orange,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Instructions
                    Center(
                      child: Text(
                        _isIdentifying 
                          ? 'Analyzing plant...' 
                          : 'Position plant in frame',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Identification results
        if (_identificationData != null)
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: _buildIdentificationResults(),
          )
        else
          // Identification info
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isIdentifying ? Icons.search : Icons.camera_alt,
                        color: _isIdentifying ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isIdentifying ? 'Identifying Plant...' : 'Plant Identification',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isIdentifying 
                      ? 'Please hold steady while we analyze'
                      : 'Tap the capture button to identify',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (!_isIdentifying) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _identifyPlantFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Identify Plant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIdentificationResults() {
    final data = _identificationData!;
    final confidence = data['confidence'] ?? 0.0;
    final careInfo = data['careInfo'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['commonName'] ?? 'Unknown Plant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      data['scientificName'] ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: confidence > 0.8 ? Colors.green : 
                         confidence > 0.6 ? Colors.orange : Colors.red,
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
          const SizedBox(height: 12),
          if (data['description'] != null) ...[
            Text(
              data['description'],
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          // Quick care info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickCareInfo(Icons.wb_sunny, careInfo['light'] ?? 'Unknown'),
              _buildQuickCareInfo(Icons.water_drop, careInfo['water'] ?? 'Unknown'),
              _buildQuickCareInfo(Icons.thermostat, careInfo['temperature'] ?? 'Unknown'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _identificationData = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('New Scan'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save to user's plants
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Plant'),
              ),
            ],
          ),
        ],
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCareReminderOverlay() {
    if (_isLoadingReminders) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
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
                  color: Colors.white
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgentReminder['priority']?.toString().toUpperCase() ?? 'MEDIUM',
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOverdue 
                ? 'Overdue by ${DateTime.now().difference(dueDate).inDays} days'
                : 'Due ${_formatDueDate(dueDate)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Mark as completed
                    _loadCareReminders(); // Refresh reminders
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isOverdue ? Colors.red : Colors.blue,
                  ),
                  child: const Text('Done'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Snooze reminder
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSelector() {
    final filters = [
      {'id': 'growth_timelapse', 'name': 'Growth', 'icon': Icons.timeline},
      {'id': 'health_overlay', 'name': 'Health', 'icon': Icons.favorite},
      {'id': 'seasonal_transformation', 'name': 'Seasons', 'icon': Icons.calendar_today},
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
} 