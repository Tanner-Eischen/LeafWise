import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leafwise/core/router/app_router.dart';

class RecentConversations extends ConsumerWidget {
  const RecentConversations({super.key});

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
                'Recent Conversations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all conversations
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

          // Sample Conversations
          ..._buildSampleConversations(context, theme),

          // Empty State
          if (_getSampleConversations().isEmpty)
            _buildEmptyState(context, theme),
        ],
      ),
    );
  }

  List<Widget> _buildSampleConversations(
    BuildContext context,
    ThemeData theme,
  ) {
    final conversations = _getSampleConversations();

    return conversations.take(3).map((conversation) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildConversationItem(context, theme, conversation),
      );
    }).toList();
  }

  Widget _buildConversationItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> conversation,
  ) {
    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: (conversation['avatarColor'] as Color)
                  .withOpacity(0.2),
              child: Text(
                conversation['name'][0].toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: conversation['avatarColor'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (conversation['isOnline'] as bool)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation['name'] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          conversation['lastMessage'] as String,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              conversation['time'] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            if (conversation['unreadCount'] as int > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conversation['unreadCount']}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          // TODO: Navigate to conversation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening chat with ${conversation['name']}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.chat_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start chatting with your plant friends!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.friends);
              },
              child: const Text('Find Friends'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleConversations() {
    return [
      {
        'name': 'Alice Green',
        'lastMessage': 'Check out my new succulent! 🌵',
        'time': '2m',
        'unreadCount': 2,
        'isOnline': true,
        'avatarColor': Colors.green,
      },
      {
        'name': 'Bob Plant',
        'lastMessage': 'Thanks for the watering tips!',
        'time': '1h',
        'unreadCount': 0,
        'isOnline': false,
        'avatarColor': Colors.blue,
      },
      {
        'name': 'Carol Bloom',
        'lastMessage': 'My roses are blooming beautifully 🌹',
        'time': '3h',
        'unreadCount': 1,
        'isOnline': true,
        'avatarColor': Colors.pink,
      },
    ];
  }
}
