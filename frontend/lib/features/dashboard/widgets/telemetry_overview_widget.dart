/// Telemetry Overview Widget
/// 
/// Displays a comprehensive overview of telemetry data including light readings,
/// growth tracking statistics, and key insights. Provides visual charts and
/// metrics to help users understand their plant care patterns.
library telemetry_overview_widget;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Feature imports
import '../../telemetry/providers/telemetry_providers.dart';
import '../../telemetry/providers/telemetry_state.dart';
import '../../telemetry/models/telemetry_data_models.dart';
import '../../telemetry/growth_tracker.dart';

/// Widget that displays telemetry overview with key metrics and insights
class TelemetryOverviewWidget extends ConsumerWidget {
  const TelemetryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final telemetryState = ref.watch(telemetryNotifierProvider);
    final growthStats = ref.watch(growthTrackingStatsProvider);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Telemetry Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (telemetryState.isLoadingData)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Error state
            if (telemetryState.error != null)
              _buildErrorState(context, theme, telemetryState.error!),

            // Loading state
            if (telemetryState.isLoadingData && telemetryState.error == null)
              _buildLoadingState(context, theme),

            // Data state
            if (!telemetryState.isLoadingData && telemetryState.error == null)
              _buildDataOverview(context, theme, telemetryState, growthStats),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error loading telemetry data: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading telemetry data...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Build data overview widget
  Widget _buildDataOverview(
    BuildContext context,
    ThemeData theme,
    TelemetryState telemetryState,
    AsyncValue<GrowthTrackingStats> growthStats,
  ) {
    return Column(
      children: [
        // Key metrics row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                theme,
                'Light Readings',
                telemetryState.lightReadings.length.toString(),
                Icons.wb_sunny,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                theme,
                'Growth Photos',
                telemetryState.growthPhotos.length.toString(),
                Icons.camera_alt,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Growth tracking stats
        growthStats.when(
          data: (stats) => _buildGrowthStatsSection(context, theme, stats),
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text(
            'Error loading growth stats: $error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Recent insights
        _buildInsightsSection(context, theme, telemetryState),
      ],
    );
  }

  /// Build metric card widget
  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build growth stats section
  Widget _buildGrowthStatsSection(
    BuildContext context,
    ThemeData theme,
    GrowthTrackingStats stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Growth Tracking',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                theme,
                'Total Photos',
                stats.totalPhotos.toString(),
              ),
              _buildStatItem(
                context,
                theme,
                'Avg Growth',
                '${stats.averageGrowthRate.toStringAsFixed(1)}%',
              ),
              _buildStatItem(
                context,
                theme,
                'Streak',
                '${stats.currentStreak} days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Build insights section
  Widget _buildInsightsSection(
    BuildContext context,
    ThemeData theme,
    TelemetryState telemetryState,
  ) {
    final insights = _generateInsights(telemetryState);

    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Collect more data to see insights',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: theme.colorScheme.tertiary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Recent Insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...insights.take(2).map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Generate insights based on telemetry data
  List<String> _generateInsights(TelemetryState telemetryState) {
    final insights = <String>[];

    // Light reading insights
    if (telemetryState.lightReadings.isNotEmpty) {
      final recentReadings = telemetryState.lightReadings
          .where((reading) => DateTime.now()
              .difference(reading.createdAt)
              .inDays < 7)
          .toList();

      if (recentReadings.isNotEmpty) {
        final avgLight = recentReadings
            .map((r) => r.ppfdValue)
            .reduce((a, b) => a + b) / recentReadings.length;

        if (avgLight < 200) {
          insights.add('Your plants may need more light. Consider moving them closer to a window.');
        } else if (avgLight > 800) {
          insights.add('Light levels are excellent for most plants!');
        }
      }
    }

    // Growth photo insights
    if (telemetryState.growthPhotos.isNotEmpty) {
      final recentPhotos = telemetryState.growthPhotos
          .where((photo) => DateTime.now()
              .difference(photo.createdAt)
              .inDays < 7)
          .toList();

      if (recentPhotos.length >= 3) {
        insights.add('Great job tracking growth! Keep up the consistent monitoring.');
      } else if (recentPhotos.isEmpty) {
        insights.add('Consider taking a growth photo to track your plant\'s progress.');
      }
    }

    // General insights
    if (telemetryState.lightReadings.isEmpty && telemetryState.growthPhotos.isEmpty) {
      insights.add('Start by taking light measurements and growth photos to get personalized insights.');
    }

    return insights;
  }
}