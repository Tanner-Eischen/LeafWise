import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/timelapse/models/timelapse_models.dart';
import 'package:leafwise/features/timelapse/providers/timelapse_provider.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';

class GrowthAnalysisWidget extends ConsumerWidget {
  final String sessionId;

  const GrowthAnalysisWidget({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growthAnalysisAsync = ref.watch(
      sessionGrowthAnalysisProvider(sessionId),
    );

    return growthAnalysisAsync.when(
      data: (growthAnalysis) => _buildAnalysisCard(context, growthAnalysis),
      loading: () => const LoadingWidget(),
      error: (error, stack) => CustomErrorWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(sessionGrowthAnalysisProvider(sessionId)),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, GrowthAnalysis analysis) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth Analysis', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildMetrics(
              context,
              analysis.plantMeasurements,
              analysis.growthChanges,
            ),
            const SizedBox(height: 16),
            _buildAnomalyFlags(context, analysis.anomalyFlags),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(
    BuildContext context,
    PlantMeasurements measurements,
    GrowthChanges changes,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest Measurements', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Height: ${measurements.height.toStringAsFixed(1)} ${measurements.unit ?? 'cm'} (+${changes.heightChange.toStringAsFixed(1)})',
        ),
        Text(
          'Width: ${measurements.width.toStringAsFixed(1)} ${measurements.unit ?? 'cm'} (+${changes.widthChange.toStringAsFixed(1)})',
        ),
        Text(
          'Leaf Count: ${measurements.leafCount} (+${changes.leafCountChange})',
        ),
        Text('Growth Rate: ${changes.growthRate.toStringAsFixed(2)} cm/week'),
      ],
    );
  }

  Widget _buildAnomalyFlags(BuildContext context, List<AnomalyFlag> flags) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Anomaly Flags', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (flags.isEmpty)
          const Text('No anomalies detected.')
        else
          ...flags.map(
            (flag) => Text('${flag.anomalyType}: ${flag.description}'),
          ),
      ],
    );
  }
}
