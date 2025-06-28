import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Stories screen displaying user stories in a feed format
class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreStories();
    }
  }

  void _loadMoreStories() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading more stories
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Simulate no more stories after some loads
        _hasMore = DateTime.now().millisecond % 3 != 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          IconButton(
            onPressed: () => context.push('/home/camera/story-creation'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create Story',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Story Archive'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Story Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Explore'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildExploreTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/camera'),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Create Story',
      ),
    );
  }

  Widget _buildFollowingTab() {
    final stories = _getMockFollowingStories();
    
    if (stories.isEmpty) {
      return _buildEmptyState(
        Icons.people_outline,
        'No stories from friends',
        'When your friends share stories, they\'ll appear here',
        actionLabel: 'Explore Stories',
        onAction: () => _tabController.animateTo(1),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Active stories row
        SliverToBoxAdapter(
          child: _buildActiveStoriesRow(),
        ),
        
        // Stories grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < stories.length) {
                  return _buildStoryCard(stories[index]);
                }
                return null;
              },
              childCount: stories.length,
            ),
          ),
        ),
        
        // Loading indicator
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildExploreTab() {
    final stories = _getMockExploreStories();
    
    return CustomScrollView(
      slivers: [
        // Trending section
        SliverToBoxAdapter(
          child: _buildTrendingSection(),
        ),
        
        // Explore grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < stories.length) {
                  return _buildStoryCard(stories[index]);
                }
                return null;
              },
              childCount: stories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStoriesRow() {
    final activeStories = _getMockActiveStories();
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: activeStories.length + 1, // +1 for "Your Story" button
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildYourStoryButton();
          }
          return _buildActiveStoryItem(activeStories[index - 1]);
        },
      ),
    );
  }

  Widget _buildYourStoryButton() {
    final theme = Theme.of(context);
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: IconButton(
              onPressed: () => context.push('/home/camera'),
              icon: Icon(
                Icons.add,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Story',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStoryItem(MockStory story) {
    final theme = Theme.of(context);
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => context.push('/story/${story.id}'),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: story.isViewed
                      ? [Colors.grey, Colors.grey]
                      : [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    story.userName.split(' ').map((name) => name[0]).join(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              story.userName.split(' ').first,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: story.isViewed
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    final theme = Theme.of(context);
    final trendingTopics = ['#PlantCare', '#SucculentLove', '#IndoorGarden', '#PlantParent'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Topics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trendingTopics.map((topic) {
              return GestureDetector(
                onTap: () => _searchByTopic(topic),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(MockStory story) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.push('/story/${story.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Story background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.7),
                      theme.colorScheme.secondary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // Story info
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Text(
                          story.userName.split(' ').map((name) => name[0]).join(),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          story.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Caption
                  if (story.caption.isNotEmpty)
                    Text(
                      story.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Stats
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.viewCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.favorite,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.likeCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(story.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Viewed indicator
            if (story.isViewed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<MockStory> _getMockActiveStories() {
    return [
      MockStory(
        id: 'active1',
        userId: 'user1',
        userName: 'Alice Green',
        caption: '',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        viewCount: 24,
        likeCount: 8,
        isViewed: false,
      ),
      MockStory(
        id: 'active2',
        userId: 'user2',
        userName: 'Bob Plant',
        caption: '',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        viewCount: 15,
        likeCount: 5,
        isViewed: true,
      ),
      MockStory(
        id: 'active3',
        userId: 'user3',
        userName: 'Carol Bloom',
        caption: '',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        viewCount: 32,
        likeCount: 12,
        isViewed: false,
      ),
    ];
  }

  List<MockStory> _getMockFollowingStories() {
    return [
      MockStory(
        id: 'following1',
        userId: 'user1',
        userName: 'Alice Green',
        caption: 'My succulent garden is thriving! 🌵✨',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        viewCount: 24,
        likeCount: 8,
        isViewed: false,
      ),
      MockStory(
        id: 'following2',
        userId: 'user2',
        userName: 'Bob Plant',
        caption: 'New additions to my indoor jungle 🌿',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        viewCount: 15,
        likeCount: 5,
        isViewed: true,
      ),
      MockStory(
        id: 'following3',
        userId: 'user3',
        userName: 'Carol Bloom',
        caption: 'Spring flowers are blooming beautifully 🌸',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        viewCount: 32,
        likeCount: 12,
        isViewed: false,
      ),
      MockStory(
        id: 'following4',
        userId: 'user4',
        userName: 'David Leaf',
        caption: 'Harvesting fresh herbs from my garden 🌱',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        viewCount: 18,
        likeCount: 7,
        isViewed: false,
      ),
    ];
  }

  List<MockStory> _getMockExploreStories() {
    return [
      MockStory(
        id: 'explore1',
        userId: 'explore_user1',
        userName: 'Plant Expert',
        caption: 'Tips for caring for your monstera 🌿 #PlantCare',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        viewCount: 156,
        likeCount: 42,
        isViewed: false,
      ),
      MockStory(
        id: 'explore2',
        userId: 'explore_user2',
        userName: 'Garden Guru',
        caption: 'Amazing succulent arrangement ideas 🌵 #SucculentLove',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        viewCount: 89,
        likeCount: 28,
        isViewed: false,
      ),
      MockStory(
        id: 'explore3',
        userId: 'explore_user3',
        userName: 'Indoor Gardener',
        caption: 'Creating the perfect indoor garden space 🏠 #IndoorGarden',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        viewCount: 203,
        likeCount: 67,
        isViewed: false,
      ),
      MockStory(
        id: 'explore4',
        userId: 'explore_user4',
        userName: 'Plant Parent',
        caption: 'My plant babies are growing so fast! 🌱 #PlantParent',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
        viewCount: 124,
        likeCount: 35,
        isViewed: false,
      ),
    ];
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'archive':
        _showComingSoon('Story Archive');
        break;
      case 'settings':
        _showComingSoon('Story Settings');
        break;
    }
  }

  void _searchByTopic(String topic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for $topic stories (Demo mode)'),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
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
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

/// Mock story model for demonstration
class MockStory {
  final String id;
  final String userId;
  final String userName;
  final String caption;
  final DateTime timestamp;
  final int viewCount;
  final int likeCount;
  final bool isViewed;

  MockStory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.caption,
    required this.timestamp,
    required this.viewCount,
    required this.likeCount,
    this.isViewed = false,
  });
}