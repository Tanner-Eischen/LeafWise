import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_social/core/router/app_router.dart';
import 'package:plant_social/features/auth/providers/auth_provider.dart';

class StoriesBar extends ConsumerWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Story Button
          _buildAddStoryItem(context, theme, user),
          const SizedBox(width: 12),
          
          // Sample Stories (placeholder)
          ..._buildSampleStories(context, theme),
        ],
      ),
    );
  }

  Widget _buildAddStoryItem(BuildContext context, ThemeData theme, dynamic user) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.camera);
      },
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(77),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withAlpha(26),
                    child: Text(
                      user?.initials ?? 'U',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Story',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSampleStories(BuildContext context, ThemeData theme) {
    final sampleStories = [
      {'name': 'Alice', 'hasStory': true, 'color': Colors.green},
      {'name': 'Bob', 'hasStory': true, 'color': Colors.blue},
      {'name': 'Carol', 'hasStory': false, 'color': Colors.orange},
      {'name': 'David', 'hasStory': true, 'color': Colors.purple},
      {'name': 'Emma', 'hasStory': false, 'color': Colors.red},
    ];

    return sampleStories.map((story) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _buildStoryItem(
          context,
          theme,
          story['name'] as String,
          story['hasStory'] as bool,
          story['color'] as Color,
        ),
      );
    }).toList();
  }

  Widget _buildStoryItem(
    BuildContext context,
    ThemeData theme,
    String name,
    bool hasStory,
    Color avatarColor,
  ) {
    return GestureDetector(
      onTap: () {
        if (hasStory) {
          // TODO: Navigate to story viewer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing $name\'s story'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasStory
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: !hasStory
                  ? Border.all(
                      color: theme.colorScheme.outline.withAlpha(77),
                      width: 2,
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(hasStory ? 3 : 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: hasStory
                      ? Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        )
                      : null,
                ),
                child: CircleAvatar(
                  radius: hasStory ? 31 : 34,
                  backgroundColor: avatarColor.withAlpha(51),
                  child: Text(
                    name[0].toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: avatarColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}