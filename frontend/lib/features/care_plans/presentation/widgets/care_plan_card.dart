import 'package:flutter/material.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:intl/intl.dart';

/// Care Plan Card Widget
///
/// Displays a care plan with status indicators, schedule information, and action buttons.
/// Features:
/// - Status-based color coding and icons
/// - Schedule summary with next actions
/// - Acknowledgment and detail view actions
/// - Responsive design with proper spacing
class CarePlanCard extends StatelessWidget {
  final CarePlan plan;
  final VoidCallback onTap;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onViewDetails;
  final bool showActions;

  const CarePlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onAcknowledge,
    this.onViewDetails,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(plan.status);
    final statusIcon = _getStatusIcon(plan.status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withAlpha(77), width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getStatusText(plan.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd').format(plan.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Plant information
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco, color: theme.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Plant ID: ${plan.plantId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Schedule summary
              _buildScheduleSummary(theme),

              const SizedBox(height: 16),

              // Rationale preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Rationale',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.rationale.summary ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (showActions) ...
                [const SizedBox(height: 16), _buildActionButtons(theme)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSummary(ThemeData theme) {
    final schedules = <Widget>[];

    // Watering schedule
    schedules.add(
      _buildScheduleItem(
        Icons.water_drop,
        'Watering',
        'Every ${plan.watering.intervalDays} days',
        '${plan.watering.amountMl}ml',
        Colors.blue,
        theme,
      ),
    );

    // Fertilizer schedule
    schedules.add(
      _buildScheduleItem(
        Icons.grass,
        'Fertilizer',
        'Every ${plan.fertilizer.intervalDays} days',
        plan.fertilizer.type,
        Colors.green,
        theme,
      ),
    );

    // Light target
    schedules.add(
      _buildScheduleItem(
        Icons.wb_sunny,
        'Light',
        '${plan.lightTarget.ppfdMin}-${plan.lightTarget.ppfdMax} PPFD',
        plan.lightTarget.recommendation,
        Colors.orange,
        theme,
      ),
    );

    if (schedules.isEmpty) {
      return Text(
        'No specific schedules defined',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care Schedule',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...schedules.map(
          (schedule) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    IconData icon,
    String title,
    String frequency,
    String details,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                frequency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final buttons = <Widget>[];

    // Acknowledge button for pending plans
    if (plan.status == CarePlanStatus.pending && onAcknowledge != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onAcknowledge,
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Acknowledge'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    // View details button
    if (onViewDetails != null) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: onViewDetails,
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text('Details'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Spacer(),
        ...buttons.map(
          (button) =>
              Padding(padding: const EdgeInsets.only(left: 8), child: button),
        ),
      ],
    );
  }

  Color _getStatusColor(CarePlanStatus status) {
    switch (status) {
      case CarePlanStatus.pending:
        return Colors.orange;
      case CarePlanStatus.acknowledged:
        return Colors.blue;
      case CarePlanStatus.active:
        return Colors.green;
      case CarePlanStatus.completed:
        return Colors.grey;
      case CarePlanStatus.expired:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CarePlanStatus status) {
    switch (status) {
      case CarePlanStatus.pending:
        return Icons.pending_actions;
      case CarePlanStatus.acknowledged:
        return Icons.verified;
      case CarePlanStatus.active:
        return Icons.check_circle;
      case CarePlanStatus.completed:
        return Icons.task_alt;
      case CarePlanStatus.expired:
        return Icons.warning;
    }
  }

  String _getStatusText(CarePlanStatus status) {
    switch (status) {
      case CarePlanStatus.pending:
        return 'Pending Review';
      case CarePlanStatus.acknowledged:
        return 'Acknowledged';
      case CarePlanStatus.active:
        return 'Active';
      case CarePlanStatus.completed:
        return 'Completed';
      case CarePlanStatus.expired:
        return 'Expired';
    }
  }
}
