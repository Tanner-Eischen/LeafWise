import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Friends',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              _showAddFriendDialog(context, theme);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Friends'),
                  Tab(text: 'Requests'),
                  Tab(text: 'Suggestions'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(context, theme),
          _buildRequestsTab(context, theme),
          _buildSuggestionsTab(context, theme),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context, ThemeData theme) {
    final friends = _getFilteredFriends();
    
    if (friends.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.people_outline,
        'No friends yet',
        'Start connecting with other plant lovers!',
        'Find Friends',
        () => _tabController.animateTo(2),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendItem(context, theme, friend, 'friend');
      },
    );
  }

  Widget _buildRequestsTab(BuildContext context, ThemeData theme) {
    final requests = _getSampleRequests();
    
    if (requests.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.person_add_outlined,
        'No friend requests',
        'Friend requests will appear here',
        null,
        null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildFriendItem(context, theme, request, 'request');
      },
    );
  }

  Widget _buildSuggestionsTab(BuildContext context, ThemeData theme) {
    final suggestions = _getSampleSuggestions();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildFriendItem(context, theme, suggestion, 'suggestion');
      },
    );
  }

  Widget _buildFriendItem(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> person,
    String type,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: (person['avatarColor'] as Color).withOpacity(0.2),
              child: Text(
                person['name'][0].toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: person['avatarColor'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (type == 'friend' && person['isOnline'] == true)
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
          person['name'] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          person['subtitle'] as String,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: _buildTrailingActions(context, theme, person, type),
        onTap: () {
          // TODO: Navigate to user profile
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing ${person['name']}\'s profile'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailingActions(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> person,
    String type,
  ) {
    switch (type) {
      case 'friend':
        return PopupMenuButton<String>(
          onSelected: (value) {
            _handleFriendAction(context, person['name'] as String, value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'message',
              child: Text('Send Message'),
            ),
            const PopupMenuItem(
              value: 'unfriend',
              child: Text('Unfriend'),
            ),
          ],
        );
      
      case 'request':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.error,
              ),
              onPressed: () {
                _handleRequestAction(context, person['name'] as String, 'decline');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.green,
              ),
              onPressed: () {
                _handleRequestAction(context, person['name'] as String, 'accept');
              },
            ),
          ],
        );
      
      case 'suggestion':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                _handleSuggestionAction(context, person['name'] as String, 'ignore');
              },
              child: Text(
                'Ignore',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _handleSuggestionAction(context, person['name'] as String, 'add');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    String? buttonText,
    VoidCallback? onButtonPressed,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, ThemeData theme) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter username or email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement add friend functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Friend request sent to ${controller.text}'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _handleFriendAction(BuildContext context, String name, String action) {
    // TODO: Implement friend actions
    String message = '';
    switch (action) {
      case 'message':
        message = 'Opening chat with $name';
        break;
      case 'unfriend':
        message = 'Unfriended $name';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleRequestAction(BuildContext context, String name, String action) {
    // TODO: Implement request actions
    String message = action == 'accept'
        ? 'Accepted friend request from $name'
        : 'Declined friend request from $name';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: action == 'accept' ? Colors.green : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSuggestionAction(BuildContext context, String name, String action) {
    // TODO: Implement suggestion actions
    String message = action == 'add'
        ? 'Friend request sent to $name'
        : '$name removed from suggestions';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: action == 'add' ? Colors.green : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFriends() {
    final friends = _getSampleFriends();
    if (_searchQuery.isEmpty) return friends;
    
    return friends.where((friend) {
      return (friend['name'] as String)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getSampleFriends() {
    return [
      {
        'name': 'Alice Green',
        'subtitle': 'Plant enthusiast • 2 mutual friends',
        'isOnline': true,
        'avatarColor': Colors.green,
      },
      {
        'name': 'Bob Plant',
        'subtitle': 'Gardening expert • 5 mutual friends',
        'isOnline': false,
        'avatarColor': Colors.blue,
      },
      {
        'name': 'Carol Bloom',
        'subtitle': 'Rose lover • 1 mutual friend',
        'isOnline': true,
        'avatarColor': Colors.pink,
      },
    ];
  }

  List<Map<String, dynamic>> _getSampleRequests() {
    return [
      {
        'name': 'David Chen',
        'subtitle': 'Wants to be your friend',
        'avatarColor': Colors.orange,
      },
      {
        'name': 'Emma Wilson',
        'subtitle': 'Sent you a friend request',
        'avatarColor': Colors.purple,
      },
    ];
  }

  List<Map<String, dynamic>> _getSampleSuggestions() {
    return [
      {
        'name': 'Sarah Johnson',
        'subtitle': '3 mutual friends',
        'avatarColor': Colors.teal,
      },
      {
        'name': 'Mike Brown',
        'subtitle': 'Plant collector',
        'avatarColor': Colors.indigo,
      },
      {
        'name': 'Lisa Garcia',
        'subtitle': '1 mutual friend',
        'avatarColor': Colors.red,
      },
    ];
  }
}