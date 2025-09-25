import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../stories/data/models/story_model.dart';
import '../../../stories/data/repositories/stories_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
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

  void _loadInitialData() {
    // Load both following and explore stories
    ref.read(followingStoriesProvider.notifier).loadFollowingStories();
    ref.read(exploreStoriesProvider.notifier).loadExploreStories();
  }

  void _loadMoreStories() {
    // Load more stories based on current tab
    if (_tabController.index == 0) {
      ref.read(followingStoriesProvider.notifier).loadFollowingStories();
    } else {
      ref.read(exploreStoriesProvider.notifier).loadExploreStories();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onSelected: (action) => _handleMenuAction(context, action),
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
        tooltip: 'Create Story',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildFollowingTab() {
    final storiesAsync = ref.watch(followingStoriesProvider);
    
    return storiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (storyGroups) {
        if (storyGroups.isEmpty) {
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
              child: _buildActiveStoriesRow(storyGroups),
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
                    if (index < storyGroups.length) {
                      return _buildStoryGroupCard(storyGroups[index]);
                    }
                    return null;
                  },
                  childCount: storyGroups.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExploreTab() {
    final storiesAsync = ref.watch(exploreStoriesProvider);
    
    return storiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (storyGroups) {
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
                    if (index < storyGroups.length) {
                      return _buildStoryGroupCard(storyGroups[index]);
                    }
                    return null;
                  },
                  childCount: storyGroups.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load stories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStoriesRow(List<UserStoriesGroup> storyGroups) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: storyGroups.length + 1, // +1 for "Your Story" button
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildYourStoryButton();
          }
          return _buildActiveStoryItem(storyGroups[index - 1]);
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

  Widget _buildActiveStoryItem(UserStoriesGroup storyGroup) {
    final theme = Theme.of(context);
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => context.push('/story/${storyGroup.stories.first.id}'),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: storyGroup.hasUnviewedStories
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      )
                    : null,
                border: !storyGroup.hasUnviewedStories
                    ? Border.all(color: Colors.grey, width: 1)
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: storyGroup.userProfilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(storyGroup.userProfilePicture!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: storyGroup.userProfilePicture == null
                    ? Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurface,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              storyGroup.username,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
                onTap: () => _searchByTopic(context, topic),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(77),
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

  Widget _buildStoryGroupCard(UserStoriesGroup storyGroup) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.push('/story/${storyGroup.stories.first.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Story background
            Positioned.fill(
              child: Image.network(
                storyGroup.stories.first.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withAlpha(179),
                              theme.colorScheme.secondary.withAlpha(179),
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
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.7),
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
                        backgroundImage: storyGroup.userProfilePicture != null
                            ? NetworkImage(storyGroup.userProfilePicture!)
                            : null,
                        child: storyGroup.userProfilePicture == null
                            ? Text(
                                storyGroup.username.split(' ').map((name) => name[0]).join(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          storyGroup.username,
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
                  
                  // Story count
                  Text(
                    '${storyGroup.stories.length} ${storyGroup.stories.length == 1 ? 'story' : 'stories'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stats
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${storyGroup.stories.first.viewCount}',
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
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
              color: theme.colorScheme.onSurface.withAlpha(77),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'archive':
        _showComingSoon(context, 'Story Archive');
        break;
      case 'settings':
        _showComingSoon(context, 'Story Settings');
        break;
    }
  }

  void _searchByTopic(BuildContext context, String topic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for $topic stories (Demo mode)'),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature now live!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }


}