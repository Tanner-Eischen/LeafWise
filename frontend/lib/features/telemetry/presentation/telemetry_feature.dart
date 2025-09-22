import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leafwise/core/widgets/breadcrumb_navigation.dart';
import 'package:leafwise/features/telemetry/presentation/screens/growth_photo_capture_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/light_measurement_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_history_screen.dart';

/// Telemetry Feature
///
/// This widget serves as the main entry point for the telemetry feature.
/// It provides navigation to the different telemetry screens and
/// manages the telemetry-related functionality.
class TelemetryFeature extends ConsumerWidget {
  const TelemetryFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final breadcrumbs = BreadcrumbHelper.generateTelemetryBreadcrumbs(currentRoute);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Breadcrumb Navigation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: BreadcrumbNavigation(items: breadcrumbs),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plant Telemetry',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor your plants with environmental sensors and growth tracking.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Measure Light',
                          description: 'Check light levels for optimal growth',
                          icon: Icons.wb_sunny,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LightMeasurementScreen(),
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Track Growth',
                          description: 'Capture and analyze plant growth',
                          icon: Icons.photo_camera,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GrowthPhotoCaptureScreen(),
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'View History',
                          description: 'Review past measurements and photos',
                          icon: Icons.history,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TelemetryHistoryScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
