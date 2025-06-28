import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Individual conversation screen for messaging
/// Displays messages between the current user and another user
class ConversationScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;

  const ConversationScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Mock messages for demonstration
  List<MockMessage> get _mockMessages => [
        MockMessage(
          id: '1',
          content: 'Hey! How are your plants doing?',
          senderId: widget.userId,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromCurrentUser: false,
        ),
        MockMessage(
          id: '2',
          content: 'They\'re doing great! Just repotted my fiddle leaf fig 🌱',
          senderId: 'current_user',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isFromCurrentUser: true,
        ),
        MockMessage(
          id: '3',
          content: 'That\'s awesome! I\'d love to see some photos',
          senderId: widget.userId,
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isFromCurrentUser: false,
        ),
        MockMessage(
          id: '4',
          content: 'Sure! I\'ll take some and share them in my story',
          senderId: 'current_user',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          isFromCurrentUser: true,
        ),
        MockMessage(
          id: '5',
          content: 'Perfect! Can\'t wait to see them 📸',
          senderId: widget.userId,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isFromCurrentUser: false,
        ),
      ];

  /// Send a message (placeholder implementation)
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Clear the input immediately
    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, this would send the message to the backend
      // and update the messages list through a provider

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent! (Demo mode)'),
            duration: Duration(seconds: 1),
          ),
        );

        // Scroll to bottom
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  /// Scroll to the bottom of the conversation
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                widget.userName?.split(' ').map((name) => name[0]).join() ??
                    'U',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName ?? 'User',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Online', // In a real app, this would be dynamic
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice call feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.phone),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video call feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mockMessages.length,
              itemBuilder: (context, index) {
                final message = _mockMessages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sending...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MockMessage message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                widget.userName?.split(' ').map((name) => name[0]).join() ??
                    'U',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isFromCurrentUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isFromCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? theme.colorScheme.onPrimary.withOpacity(0.7)
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File attachment feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.attach_file),
          ),

          // Message input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(
              Icons.send,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Mock message model for demonstration
class MockMessage {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  MockMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isFromCurrentUser,
  });
}
