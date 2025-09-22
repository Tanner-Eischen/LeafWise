import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leafwise/core/router/app_router.dart';

class FriendSuggestions extends ConsumerWidget {
  const FriendSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Friends',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go(AppRoutes.friends);
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal scrollable suggestions
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getSampleSuggestions().length,
              itemBuilder: (context, index) {
                final suggestion = _getSampleSuggestions()[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _getSampleSuggestions().length - 1 ? 12 : 0,
                  ),
                  child: _buildSuggestionCard(context, theme, suggestion),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> suggestion,
  ) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: (suggestion['avatarColor'] as Color)
                    .withOpacity(0.2),
                child: Text(
                  suggestion['name'][0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: suggestion['avatarColor'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                suggestion['name'] as String,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Mutual friends or connection reason
              Text(
                suggestion['connection'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _handleIgnoreSuggestion(
                          context,
                          suggestion['name'] as String,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'Ignore',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleAddFriend(context, suggestion['name'] as String);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text(
                        'Add',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddFriend(BuildContext context, String name) {
    // TODO: Implement add friend functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to $name'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleIgnoreSuggestion(BuildContext context, String name) {
    // TODO: Implement ignore suggestion functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from suggestions'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleSuggestions() {
    return [
      {
        'name': 'Emma Wilson',
        'connection': '3 mutual friends',
        'avatarColor': Colors.purple,
      },
      {
        'name': 'David Chen',
        'connection': 'Plant enthusiast',
        'avatarColor': Colors.orange,
      },
      {
        'name': 'Sarah Johnson',
        'connection': '2 mutual friends',
        'avatarColor': Colors.teal,
      },
      {
        'name': 'Mike Brown',
        'connection': 'Gardening expert',
        'avatarColor': Colors.indigo,
      },
      {
        'name': 'Lisa Garcia',
        'connection': '1 mutual friend',
        'avatarColor': Colors.red,
      },
    ];
  }
}
