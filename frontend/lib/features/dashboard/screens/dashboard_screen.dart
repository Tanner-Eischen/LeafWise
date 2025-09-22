/// Dashboard Screen with Telemetry Overview Integration
/// 
/// Main dashboard screen that provides an overview of plant care activities,
/// telemetry data, and quick access to key features. Integrates the TelemetryOverviewWidget
/// to display telemetry insights and statistics.
library dashboard_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core imports
import '../../../core/router/app_router.dart';

// Feature imports
import '../../auth/providers/auth_provider.dart';
import '../../telemetry/providers/telemetry_providers.dart';
import '../../telemetry/providers/telemetry_state.dart';
import '../../telemetry/models/telemetry_data_models.dart';


// Widget imports
import '../widgets/telemetry_overview_widget.dart';

/// Main dashboard screen providing overview of plant care and telemetry data
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load telemetry data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(telemetryNotifierProvider.notifier).loadTelemetryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final telemetryState = ref.watch(telemetryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(telemetryNotifierProvider.notifier).loadTelemetryData();
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(telemetryNotifierProvider.notifier).loadTelemetryData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.displayName ?? 'Plant Enthusiast'}! 🌱',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your plant care overview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Telemetry Overview Widget
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TelemetryOverviewWidget(),
              ),

              const SizedBox(height: 24),

              // Quick Actions section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildQuickActionCard(
                          context,
                          theme,
                          'Capture Growth Photo',
                          Icons.camera_alt,
                          () {
                            context.pushNamed(AppRoutes.camera);
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          theme,
                          'Measure Light',
                          Icons.wb_sunny,
                          () {
                            // TODO: Navigate to light measurement
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          theme,
                          'View Telemetry History',
                          Icons.analytics,
                          () {
                            // TODO: Navigate to telemetry history
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          theme,
                          'Plant Care',
                          Icons.eco,
                          () {
                            // TODO: Navigate to plant care
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activity section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivitySection(context, theme, telemetryState),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a quick action card widget
  Widget _buildQuickActionCard(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the recent activity section
  Widget _buildRecentActivitySection(
    BuildContext context,
    ThemeData theme,
    TelemetryState telemetryState,
  ) {
    if (telemetryState.isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Combine and sort recent telemetry data
    final recentItems = <TelemetryData>[];
    recentItems.addAll(telemetryState.lightReadings);
    recentItems.addAll(telemetryState.growthPhotos);
    
    // Sort by creation date (most recent first)
    recentItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Take only the 5 most recent items
    final displayItems = recentItems.take(5).toList();

    if (displayItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No recent activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start capturing growth photos or measuring light to see your activity here',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: displayItems.map((item) {
        return _buildActivityItem(context, theme, item);
      }).toList(),
    );
  }

  /// Build an individual activity item
  Widget _buildActivityItem(
    BuildContext context,
    ThemeData theme,
    TelemetryData item,
  ) {
    IconData icon;
    String title;
    String subtitle;
    Color iconColor;

    if (item is LightReadingData) {
      icon = Icons.wb_sunny;
      title = 'Light Reading';
      subtitle = '${item.ppfdValue.toStringAsFixed(1)} PPFD';
      iconColor = Colors.orange;
    } else if (item is GrowthPhotoData) {
      icon = Icons.camera_alt;
      title = 'Growth Photo';
      subtitle = item.isProcessed ? 'Processed' : 'Processing...';
      iconColor = Colors.green;
    } else {
      icon = Icons.analytics;
      title = 'Telemetry Data';
      subtitle = 'Unknown type';
      iconColor = theme.colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          _formatTimeAgo(item.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onTap: () {
          // TODO: Navigate to detailed view
        },
      ),
    );
  }

  /// Format time ago string
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}