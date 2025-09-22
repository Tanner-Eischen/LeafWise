import 'package:flutter/material.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';

/// Widget that displays the rationale behind a care plan
class CarePlanRationaleWidget extends StatelessWidget {
  final CarePlanRationale rationale;

  const CarePlanRationaleWidget({super.key, required this.rationale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Plan Rationale',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (rationale.explanation != null) ...[
              Text(rationale.explanation!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            _buildFactorsList(
              'Environmental Factors',
              rationale.environmentalFactors,
              theme,
            ),
            const SizedBox(height: 12),
            _buildFactorsList('Rules Applied', rationale.rulesFired, theme),
            const SizedBox(height: 12),
            Text(
              'Confidence: ${(rationale.confidence * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorsList(String title, List<String> items, ThemeData theme) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyMedium),
                Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
