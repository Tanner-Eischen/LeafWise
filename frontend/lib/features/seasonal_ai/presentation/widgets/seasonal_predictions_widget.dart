import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/seasonal_ai/models/seasonal_ai_models.dart';
import 'package:leafwise/features/seasonal_ai/providers/seasonal_ai_provider.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';

class SeasonalPredictionsWidget extends ConsumerWidget {
  final String? plantId;
  final bool showFullDetails;

  const SeasonalPredictionsWidget({
    super.key,
    this.plantId,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (plantId != null) {
      final predictionAsync = ref.watch(seasonalPredictionProvider(plantId!));

      return predictionAsync.when(
        data: (prediction) => _buildPredictionCard(context, theme, prediction),
        loading: () => _buildLoadingCard(theme),
        error: (error, stack) => _buildErrorCard(theme, error.toString()),
      );
    }

    // Show general seasonal insights when no specific plant is selected
    return _buildGeneralSeasonalCard(context, theme, ref);
  }

  Widget _buildPredictionCard(
    BuildContext context,
    ThemeData theme,
    SeasonalPrediction prediction,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeasonIcon(_getCurrentSeason()),
                  color: _getSeasonColor(_getCurrentSeason()),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seasonal Predictions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeasonColor(
                      _getCurrentSeason(),
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSeasonColor(
                        _getCurrentSeason(),
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getCurrentSeason().toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getSeasonColor(_getCurrentSeason()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Season Overview
            _buildSeasonOverview(theme, prediction),
            const SizedBox(height: 16),

            // Growth Forecast
            _buildGrowthForecast(theme, prediction.growthForecast),

            const SizedBox(height: 16),

            // Care Adjustments Preview
            _buildCareAdjustmentsPreview(theme, prediction),

            if (showFullDetails) ...[
              const SizedBox(height: 16),
              _buildRiskFactors(theme, prediction),
            ],

            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to detailed seasonal view
                  _showDetailedPredictions(context);
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Detailed Predictions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonOverview(ThemeData theme, SeasonalPrediction prediction) {
    // Get the current season since it's not directly in the prediction model
    final currentSeason = _getCurrentSeason();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeasonColor(currentSeason).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeasonColor(currentSeason).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.thermostat,
                color: _getSeasonColor(currentSeason),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Season Outlook',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _generateSeasonalDescription(prediction, currentSeason),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  theme,
                  'Confidence',
                  '${(prediction.confidenceScore * 100).toInt()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetric(
                  theme,
                  'Valid Until',
                  _formatDate(prediction.predictionPeriod.endDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthForecast(ThemeData theme, GrowthForecast forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Growth Forecast',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGrowthMetric(
                theme,
                'Expected Growth',
                '${forecast.expectedGrowthRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGrowthMetric(
                theme,
                'Stress Risk',
                '${(forecast.stressLikelihood * 100).toInt()}%',
                Icons.health_and_safety,
                _getStressColor(forecast.stressLikelihood),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthMetric(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareAdjustmentsPreview(
    ThemeData theme,
    SeasonalPrediction prediction,
  ) {
    // Show top 3 care adjustments
    final adjustments = prediction.careAdjustments.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recommended Adjustments',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...adjustments.map(
          (adjustment) => _buildAdjustmentItem(theme, adjustment),
        ),
        if (prediction.careAdjustments.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${prediction.careAdjustments.length - 3} more adjustments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdjustmentItem(ThemeData theme, CareAdjustment adjustment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _getCareTypeIcon(adjustment.adjustmentType),
            size: 16,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              adjustment.description,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(
                adjustment.priority,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              adjustment.priority,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getPriorityColor(adjustment.priority),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactors(ThemeData theme, SeasonalPrediction prediction) {
    if (prediction.riskFactors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'No risk factors detected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
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
            const Icon(Icons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Risk Factors',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...prediction.riskFactors.map((risk) => _buildRiskItem(theme, risk)),
      ],
    );
  }

  Widget _buildRiskItem(ThemeData theme, RiskFactor risk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRiskColor(risk.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRiskColor(risk.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(risk.riskType),
                color: _getRiskColor(risk.severity),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  risk.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRiskColor(risk.severity),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk.severity.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (risk.preventiveMeasures.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Mitigation: ${risk.preventiveMeasures.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralSeasonalCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Seasonal Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current season info
            _buildCurrentSeasonInfo(theme),
            const SizedBox(height: 16),

            // General recommendations
            _buildGeneralRecommendations(theme),

            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to seasonal AI features
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Seasonal Features'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSeasonInfo(ThemeData theme) {
    final currentSeason = _getCurrentSeason();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeasonColor(currentSeason).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeasonColor(currentSeason).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getSeasonIcon(currentSeason),
            color: _getSeasonColor(currentSeason),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Season: $currentSeason',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSeasonDescription(currentSeason),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralRecommendations(ThemeData theme) {
    final recommendations = _getGeneralRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Care Tips',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => _buildRecommendationItem(theme, rec)),
      ],
    );
  }

  Widget _buildRecommendationItem(ThemeData theme, String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: theme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recommendation, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Loading Seasonal Predictions...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LoadingWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Seasonal Predictions Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomErrorWidget(
              message: error,
              onRetry: () {
                // Retry logic would be handled by the parent
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Helper methods
  IconData _getSeasonIcon(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Icons.local_florist;
      case 'summer':
        return Icons.wb_sunny;
      case 'autumn':
      case 'fall':
        return Icons.park;
      case 'winter':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Colors.green;
      case 'summer':
        return Colors.orange;
      case 'autumn':
      case 'fall':
        return Colors.brown;
      case 'winter':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Color _getHealthColor(double healthScore) {
    if (healthScore >= 0.8) return Colors.green;
    if (healthScore >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getStressColor(double stressLikelihood) {
    if (stressLikelihood <= 0.3) return Colors.green;
    if (stressLikelihood <= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getCareTypeIcon(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.grass;
      case 'pruning':
        return Icons.content_cut;
      case 'repotting':
        return Icons.home_work;
      case 'lighting':
        return Icons.wb_incandescent;
      default:
        return Icons.eco;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskType) {
    switch (riskType.toLowerCase()) {
      case 'pest':
        return Icons.bug_report;
      case 'disease':
        return Icons.healing;
      case 'environmental':
        return Icons.cloud;
      case 'care':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Autumn';
    return 'Winter';
  }

  String _getSeasonDescription(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return 'Growth season - increase watering and fertilizing';
      case 'summer':
        return 'Peak growth - monitor for heat stress and pests';
      case 'autumn':
        return 'Preparation season - reduce feeding and watering';
      case 'winter':
        return 'Dormant season - minimal care required';
      default:
        return 'Monitor your plants according to seasonal needs';
    }
  }

  List<String> _getGeneralRecommendations() {
    final season = _getCurrentSeason().toLowerCase();
    switch (season) {
      case 'spring':
        return [
          'Increase watering frequency as plants resume growth',
          'Start regular fertilizing schedule',
          'Check for new growth and adjust lighting',
          'Repot plants that have outgrown their containers',
        ];
      case 'summer':
        return [
          'Monitor soil moisture more frequently',
          'Provide shade during extreme heat',
          'Watch for pest activity and treat promptly',
          'Ensure adequate ventilation',
        ];
      case 'autumn':
        return [
          'Gradually reduce watering frequency',
          'Stop or reduce fertilizing',
          'Prepare plants for dormancy',
          'Clean and inspect for pests',
        ];
      case 'winter':
        return [
          'Water sparingly - soil should dry between waterings',
          'Avoid fertilizing during dormancy',
          'Provide adequate light with grow lights if needed',
          'Maintain stable temperatures',
        ];
      default:
        return [
          'Monitor your plants regularly',
          'Adjust care based on seasonal changes',
          'Keep track of watering and feeding schedules',
        ];
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return '${difference}d';
    if (difference < 30) return '${(difference / 7).round()}w';
    return '${(difference / 30).round()}m';
  }

  String _generateSeasonalDescription(
    SeasonalPrediction prediction,
    String currentSeason,
  ) {
    final growthRate = prediction.growthForecast.expectedGrowthRate;
    final stressRisk = prediction.growthForecast.stressLikelihood;
    final adjustmentCount = prediction.careAdjustments.length;
    final riskCount = prediction.riskFactors.length;

    String description = 'Your plant is expected to have ';

    if (growthRate > 15) {
      description += 'excellent growth';
    } else if (growthRate > 8) {
      description += 'good growth';
    } else if (growthRate > 3) {
      description += 'moderate growth';
    } else {
      description += 'slow growth';
    }

    description += ' this $currentSeason. ';

    if (stressRisk > 0.7) {
      description += 'High stress risk detected - extra care needed.';
    } else if (stressRisk > 0.4) {
      description += 'Moderate stress risk - monitor closely.';
    } else {
      description += 'Low stress risk - conditions look favorable.';
    }

    if (adjustmentCount > 0) {
      description += ' $adjustmentCount care adjustments recommended.';
    }

    if (riskCount > 0) {
      description += ' $riskCount risk factors to monitor.';
    }

    return description;
  }

  void _showDetailedPredictions(BuildContext context) {
    // Navigate to detailed seasonal predictions screen
    // This would be implemented when creating the detailed screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed predictions screen coming soon!')),
    );
  }
}
