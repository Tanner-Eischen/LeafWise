import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Story viewer screen for viewing individual stories
/// Displays stories with full-screen media and interaction options
class StoryViewerScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String? userId;
  
  const StoryViewerScreen({
    super.key,
    required this.storyId,
    this.userId,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isPaused = false;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 15), // Story duration
      vsync: this,
    );
    
    _startStoryProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  /// Start the story progress animation
  void _startStoryProgress() {
    _progressController.forward().then((_) {
      if (mounted) {
        _onStoryComplete();
      }
    });
  }

  /// Handle story completion
  void _onStoryComplete() {
    context.pop();
  }

  /// Toggle pause/play
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _progressController.stop();
    } else {
      _progressController.forward();
    }
  }

  /// Toggle UI visibility
  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  /// Mock story data
  MockStory get _mockStory => MockStory(
    id: widget.storyId,
    userId: widget.userId ?? 'user1',
    userName: 'Alice Green',
    caption: 'My beautiful succulent garden is thriving! 🌵✨ #PlantLife #SucculentLove',
    imageUrl: 'https://example.com/story-image.jpg', // Placeholder
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    viewCount: 24,
    isLiked: false,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final story = _mockStory;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        onLongPressStart: (_) => _togglePause(),
        onLongPressEnd: (_) => _togglePause(),
        child: Stack(
          children: [
            // Story content (placeholder image)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade700,
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 120,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '🌵 Succulent Garden 🌵',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Demo Story Content',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Pause indicator
            if (_isPaused)
              const Center(
                child: Icon(
                  Icons.pause_circle_filled,
                  size: 80,
                  color: Colors.white70,
                ),
              ),
            
            // UI overlay
            if (_showUI) ..[
              // Progress bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  },
                ),
              ),
              
              // Header
              Positioned(
                top: MediaQuery.of(context).padding.top + 32,
                left: 16,
                right: 16,
                child: _buildHeader(story, theme),
              ),
              
              // Caption and interactions
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: _buildFooter(story, theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MockStory story, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Text(
            story.userName.split(' ').map((name) => name[0]).join(),
            style: TextStyle(
              color: theme.colorScheme.primary,
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
                story.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTimestamp(story.timestamp),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(MockStory story, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Caption
        if (story.caption.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              story.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Interaction buttons
        Row(
          children: [
            // Like button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Story liked! (Demo mode)'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      story.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: story.isLiked ? Colors.red : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Like',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Reply button
            GestureDetector(
              onTap: () {
                _showReplyBottomSheet(context, story);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // View count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${story.viewCount}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showReplyBottomSheet(BuildContext context, MockStory story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reply to ${story.userName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Send a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply sent! (Demo mode)'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Mock story model for demonstration
class MockStory {
  final String id;
  final String userId;
  final String userName;
  final String caption;
  final String imageUrl;
  final DateTime timestamp;
  final int viewCount;
  final bool isLiked;

  MockStory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.caption,
    required this.imageUrl,
    required this.timestamp,
    required this.viewCount,
    required this.isLiked,
  });
}