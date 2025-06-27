import 'package:flutter/material.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';
import 'package:plant_social/core/theme/app_theme.dart';

class PlantCard extends StatelessWidget {
  final UserPlant plant;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: plant.imageUrl != null
                      ? Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(theme);
                          },
                        )
                      : _buildPlaceholder(theme),
                ),
              ),
            ),

            // Plant info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant nickname
                    Text(
                      plant.nickname,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Species name
                    if (plant.species != null)
                      Text(
                        plant.species!.commonName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Care status or location
                    Row(
                      children: [
                        if (plant.location != null) ..[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              plant.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ..[
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getAcquiredDateText(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Care indicators
            if (plant.reminders != null && plant.reminders!.isNotEmpty)
              _buildCareIndicators(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.eco,
        size: 40,
        color: theme.primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildCareIndicators(ThemeData theme) {
    final activeReminders = plant.reminders!
        .where((reminder) => reminder.isActive)
        .toList();

    if (activeReminders.isEmpty) return const SizedBox.shrink();

    final overdueCount = activeReminders
        .where((reminder) => reminder.nextDueDate.isBefore(DateTime.now()))
        .length;

    final upcomingCount = activeReminders
        .where((reminder) => 
            reminder.nextDueDate.isAfter(DateTime.now()) &&
            reminder.nextDueDate.isBefore(DateTime.now().add(const Duration(days: 3))))
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (overdueCount > 0) ..[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning,
                    size: 12,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    overdueCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (upcomingCount > 0) ..[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    upcomingCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${activeReminders.length} reminder${activeReminders.length != 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getAcquiredDateText() {
    final now = DateTime.now();
    final difference = now.difference(plant.acquiredDate);

    if (difference.inDays == 0) {
      return 'Added today';
    } else if (difference.inDays == 1) {
      return 'Added yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months != 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years != 1 ? 's' : ''} ago';
    }
  }
}