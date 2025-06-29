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
            onPressed: () => _startVoiceCall(context),
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
          ),
          IconButton(
            onPressed: () => _startVideoCall(context),
            icon: const Icon(Icons.video_call),
            tooltip: 'Video Call',
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
            onPressed: () => _showAttachmentOptions(context),
            icon: const Icon(Icons.attach_file),
            tooltip: 'Attach File',
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

  void _startVoiceCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Voice Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${widget.userName}...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Connecting...'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.red,
                  heroTag: 'end_call',
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Video Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.userName ?? 'User',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'You',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Connecting...'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Toggle camera
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera toggled')),
                    );
                  },
                  backgroundColor: Colors.grey,
                  heroTag: 'toggle_camera',
                  mini: true,
                  child: const Icon(Icons.videocam, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () {
                    // Toggle microphone
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Microphone toggled')),
                    );
                  },
                  backgroundColor: Colors.grey,
                  heroTag: 'toggle_mic',
                  mini: true,
                  child: const Icon(Icons.mic, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.red,
                  heroTag: 'end_video_call',
                  mini: true,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attach File',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAttachmentOption(
                  context,
                  'Camera',
                  Icons.camera_alt,
                  Colors.blue,
                  () => _attachFromCamera(context),
                ),
                _buildAttachmentOption(
                  context,
                  'Gallery',
                  Icons.photo_library,
                  Colors.purple,
                  () => _attachFromGallery(context),
                ),
                _buildAttachmentOption(
                  context,
                  'Document',
                  Icons.insert_drive_file,
                  Colors.orange,
                  () => _attachDocument(context),
                ),
                _buildAttachmentOption(
                  context,
                  'Location',
                  Icons.location_on,
                  Colors.red,
                  () => _attachLocation(context),
                ),
                _buildAttachmentOption(
                  context,
                  'Plant Info',
                  Icons.local_florist,
                  Colors.green,
                  () => _attachPlantInfo(context),
                ),
                _buildAttachmentOption(
                  context,
                  'Voice Note',
                  Icons.mic,
                  Colors.teal,
                  () => _recordVoiceNote(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _attachFromCamera(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening camera...')),
    );
  }

  void _attachFromGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening gallery...')),
    );
  }

  void _attachDocument(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening document picker...')),
    );
  }

  void _attachLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing current location...')),
    );
  }

  void _attachPlantInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Plant Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('My Monstera'),
              subtitle: const Text('Care tips and photos'),
              onTap: () {
                Navigator.of(context).pop();
                _sharePlantInfo('My Monstera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Snake Plant'),
              subtitle: const Text('Growth progress'),
              onTap: () {
                Navigator.of(context).pop();
                _sharePlantInfo('Snake Plant');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _sharePlantInfo(String plantName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shared $plantName information')),
    );
  }

  void _recordVoiceNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Voice Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text('Recording...'),
            const SizedBox(height: 8),
            const Text('00:15'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice note sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
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
