import 'package:flutter/material.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:intl/intl.dart';

/// Care Plan History Card Widget
///
/// Displays a care plan history entry with status indicators and basic information.
/// Features:
/// - Status-based color coding and icons
/// - Plant information display
/// - Next watering due information
/// - Urgent alerts display
/// - Responsive design with proper spacing
class CarePlanHistoryCard extends StatelessWidget {
  final CarePlanHistory plan;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final bool showActions;

  const CarePlanHistoryCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onViewDetails,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 2),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd').format(plan.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Plant information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_florist,
                      size: 20,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.plantNickname,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            plan.speciesName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Next watering and alerts
              Row(
                children: [
                  // Next watering
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Watering',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd').format(plan.nextWateringDue),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (plan.urgentAlerts.isNotEmpty)
                    const SizedBox(width: 8),
                  
                  // Urgent alerts
                  if (plan.urgentAlerts.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Urgent Alerts',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${plan.urgentAlerts.length} alert${plan.urgentAlerts.length != 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Actions
              if (showActions && onViewDetails != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (plan.isActive) {
      return Colors.green;
    } else if (plan.isAcknowledged) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (plan.isActive) {
      return Icons.check_circle;
    } else if (plan.isAcknowledged) {
      return Icons.visibility;
    } else {
      return Icons.schedule;
    }
  }

  String _getStatusText() {
    if (plan.isActive) {
      return 'Active';
    } else if (plan.isAcknowledged) {
      return 'Acknowledged';
    } else {
      return 'Inactive';
    }
  }
}