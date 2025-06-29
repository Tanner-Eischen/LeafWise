import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

/// Advanced AR filters for plant-focused camera features
class PlantARFilters extends StatefulWidget {
  final CameraController cameraController;
  final Function(String filterType) onFilterSelected;
  final String? currentFilter;

  const PlantARFilters({
    Key? key,
    required this.cameraController,
    required this.onFilterSelected,
    this.currentFilter,
  }) : super(key: key);

  @override
  State<PlantARFilters> createState() => _PlantARFiltersState();
}

class _PlantARFiltersState extends State<PlantARFilters>
    with TickerProviderStateMixin {
  late AnimationController _growthAnimationController;
  late AnimationController _healthPulseController;
  late AnimationController _seasonalController;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _growthAnimationController.dispose();
    _healthPulseController.dispose();
    _seasonalController.dispose();
    super.dispose();
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
    return AnimatedBuilder(
      animation: _growthAnimationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Growth progression indicators
            Positioned(
              bottom: 200,
              left: 50,
              child: _buildGrowthStage(
                'Seedling',
                _growthAnimationController.value >= 0.0,
                _growthAnimationController.value >= 0.25,
              ),
            ),
            Positioned(
              bottom: 250,
              left: 100,
              child: _buildGrowthStage(
                'Young Plant',
                _growthAnimationController.value >= 0.25,
                _growthAnimationController.value >= 0.5,
              ),
            ),
            Positioned(
              bottom: 300,
              left: 150,
              child: _buildGrowthStage(
                'Mature',
                _growthAnimationController.value >= 0.5,
                _growthAnimationController.value >= 0.75,
              ),
            ),
            Positioned(
              bottom: 350,
              left: 200,
              child: _buildGrowthStage(
                'Flowering',
                _growthAnimationController.value >= 0.75,
                _growthAnimationController.value >= 1.0,
              ),
            ),
            
            // Timeline scrubber
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: _buildTimelineScrubber(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrowthStage(String label, bool isActive, bool isCompleted) {
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
      child: Row(
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
    );
  }

  Widget _buildTimelineScrubber() {
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
                child: Slider(
                  value: _growthAnimationController.value,
                  onChanged: (value) {
                    _growthAnimationController.value = value;
                  },
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
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
    return AnimatedBuilder(
      animation: _healthPulseController,
      builder: (context, child) {
        return Stack(
          children: [
            // Health indicators positioned around detected plant areas
            _buildHealthIndicator(
              top: 200,
              left: 100,
              healthScore: 0.85,
              label: 'Leaf Health',
              icon: Icons.eco,
            ),
            _buildHealthIndicator(
              top: 350,
              left: 150,
              healthScore: 0.6,
              label: 'Soil Moisture',
              icon: Icons.water_drop,
            ),
            _buildHealthIndicator(
              top: 300,
              right: 100,
              healthScore: 0.9,
              label: 'Light Exposure',
              icon: Icons.wb_sunny,
            ),
            
            // Health summary panel
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: _buildHealthSummaryPanel(),
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
  }) {
    final color = healthScore >= 0.8
        ? Colors.green
        : healthScore >= 0.6
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

  Widget _buildHealthSummaryPanel() {
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
          const Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Plant Health Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHealthMetric('Overall', 0.78, Colors.green),
              _buildHealthMetric('Hydration', 0.6, Colors.orange),
              _buildHealthMetric('Growth', 0.85, Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommendation: Water in 2-3 days',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalTransformation() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        final seasons = ['Spring', 'Summer', 'Fall', 'Winter'];
        final colors = [
          Colors.lightGreen,
          Colors.green,
          Colors.orange,
          Colors.blueGrey,
        ];
        
        final currentSeasonIndex = (_seasonalController.value * 4).floor() % 4;
        final currentSeason = seasons[currentSeasonIndex];
        final currentColor = colors[currentSeasonIndex];

        return Stack(
          children: [
            // Seasonal overlay effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      currentColor.withOpacity(0.0),
                      currentColor.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
            
            // Seasonal particles
            ...List.generate(20, (index) {
              return _buildSeasonalParticle(index, currentSeasonIndex);
            }),
            
            // Season info panel
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: _buildSeasonInfoPanel(currentSeason, currentColor),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeasonalParticle(int index, int seasonIndex) {
    final random = math.Random(index);
    final x = random.nextDouble() * 300 + 50;
    final y = random.nextDouble() * 500 + 100;
    
    IconData icon;
    Color color;
    
    switch (seasonIndex) {
      case 0: // Spring
        icon = Icons.local_florist;
        color = Colors.pink;
        break;
      case 1: // Summer
        icon = Icons.wb_sunny;
        color = Colors.yellow;
        break;
      case 2: // Fall
        icon = Icons.eco;
        color = Colors.orange;
        break;
      default: // Winter
        icon = Icons.ac_unit;
        color = Colors.lightBlue;
    }

    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _seasonalController,
        builder: (context, child) {
          final offset = _seasonalController.value * 50;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: 0.7,
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonInfoPanel(String season, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$season Transformation',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getSeasonalDescription(season),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _seasonalController.forward();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next Season'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _seasonalController.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSeasonalDescription(String season) {
    switch (season) {
      case 'Spring':
        return 'New growth, fresh leaves, perfect time for repotting';
      case 'Summer':
        return 'Peak growing season, increase watering frequency';
      case 'Fall':
        return 'Prepare for dormancy, reduce fertilizing';
      case 'Winter':
        return 'Dormant period, minimal watering needed';
      default:
        return '';
    }
  }

  Widget _buildPlantIdentificationOverlay() {
    return Stack(
      children: [
        // Scanning frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Position plant in frame',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Plant Identification',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Hold steady for best results',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCareReminderOverlay() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Care Reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Your Monstera needs watering!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text('Done'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Snooze'),
                ),
              ],
            ),
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
} 