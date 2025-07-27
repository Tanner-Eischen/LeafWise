import 'package:flutter/material.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';

class CareReminderCard extends StatelessWidget {
  final PlantCareReminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onSnooze;

  const CareReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    this.onComplete,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = reminder.nextDueDate.isBefore(DateTime.now());
    final isUpcoming = reminder.nextDueDate.isAfter(DateTime.now()) &&
        reminder.nextDueDate.isBefore(DateTime.now().add(const Duration(days: 1)));

    return Card(
      elevation: isOverdue ? 6 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : isUpcoming
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.transparent,
          width: isOverdue || isUpcoming ? 1 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Care type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCareTypeColor(reminder.careType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCareTypeIcon(reminder.careType),
                  color: _getCareTypeColor(reminder.careType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Reminder details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Care type and plant name
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getCareTypeDisplayName(reminder.careType),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverdue ? Colors.red[700] : null,
                            ),
                          ),
                        ),
                        if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          )
                        else if (isUpcoming)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DUE SOON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Plant nickname
                    Text(
                      reminder.plant?.nickname ?? 'Unknown Plant',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Due date and frequency
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFormattedDueDate(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? Colors.red[600]
                                : isUpcoming
                                    ? Colors.orange[600]
                                    : Colors.grey[600],
                            fontWeight: isOverdue || isUpcoming
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFrequencyText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Notes if available
                    if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        reminder.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onComplete != null)
                    IconButton(
                      onPressed: onComplete,
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                      ),
                      tooltip: 'Mark as completed',
                    ),
                  if (onSnooze != null && (isOverdue || isUpcoming))
                    IconButton(
                      onPressed: onSnooze,
                      icon: Icon(
                        Icons.snooze,
                        color: Colors.orange[600],
                      ),
                      tooltip: 'Snooze reminder',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCareTypeIcon(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.eco;
      case 'pruning':
        return Icons.content_cut;
      case 'repotting':
        return Icons.grass;
      case 'pest_check':
        return Icons.bug_report;
      case 'rotation':
        return Icons.rotate_right;
      case 'misting':
        return Icons.cloud;
      case 'cleaning':
        return Icons.cleaning_services;
      default:
        return Icons.schedule;
    }
  }

  Color _getCareTypeColor(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return Colors.blue;
      case 'fertilizing':
        return Colors.green;
      case 'pruning':
        return Colors.orange;
      case 'repotting':
        return Colors.brown;
      case 'pest_check':
        return Colors.red;
      case 'rotation':
        return Colors.purple;
      case 'misting':
        return Colors.lightBlue;
      case 'cleaning':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCareTypeDisplayName(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return 'Watering';
      case 'fertilizing':
        return 'Fertilizing';
      case 'pruning':
        return 'Pruning';
      case 'repotting':
        return 'Repotting';
      case 'pest_check':
        return 'Pest Check';
      case 'rotation':
        return 'Rotation';
      case 'misting':
        return 'Misting';
      case 'cleaning':
        return 'Cleaning';
      default:
        return careType.replaceAll('_', ' ').split(' ').map((word) {
          return word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word;
        }).join(' ');
    }
  }

  String _getFormattedDueDate() {
    final now = DateTime.now();
    final dueDate = reminder.nextDueDate;
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return 'Due today';
      } else if (daysPast == 1) {
        return '1 day overdue';
      } else {
        return '$daysPast days overdue';
      }
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Due ${dueDate.day}/${dueDate.month}';
    }
  }

  String _getFrequencyText() {
    final frequency = reminder.frequencyDays;
    if (frequency == 1) {
      return 'Daily';
    } else if (frequency == 7) {
      return 'Weekly';
    } else if (frequency == 14) {
      return 'Bi-weekly';
    } else if (frequency == 30) {
      return 'Monthly';
    } else if (frequency < 7) {
      return 'Every $frequency days';
    } else {
      final weeks = (frequency / 7).round();
      return 'Every $weeks weeks';
    }
  }
}