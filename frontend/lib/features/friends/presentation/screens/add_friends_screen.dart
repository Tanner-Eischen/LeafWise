import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add friends screen for discovering and connecting with new users
class AddFriendsScreen extends ConsumerStatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  ConsumerState<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends ConsumerState<AddFriendsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<MockUser> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate API search delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _searchResults = _getMockSearchResults(_searchQuery);
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync_contacts',
                child: Row(
                  children: [
                    Icon(Icons.contacts),
                    SizedBox(width: 8),
                    Text('Sync Contacts'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invite_by_link',
                child: Row(
                  children: [
                    Icon(Icons.link),
                    SizedBox(width: 8),
                    Text('Invite by Link'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'qr_code',
                child: Row(
                  children: [
                    Icon(Icons.qr_code),
                    SizedBox(width: 8),
                    Text('QR Code'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          _buildSearchSection(theme),
          
          // Content
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or username...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  theme,
                  Icons.contacts,
                  'Contacts',
                  'Find friends from your contacts',
                  () => _handleMenuAction('sync_contacts'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  theme,
                  Icons.qr_code_scanner,
                  'Scan QR',
                  'Scan a friend\'s QR code',
                  () => _handleMenuAction('qr_code'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_searchQuery.isEmpty) {
      return _buildSuggestionsView(theme);
    }
    
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for users...'),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return _buildEmptySearchResults(theme);
    }
    
    return _buildSearchResults(theme);
  }

  Widget _buildSuggestionsView(ThemeData theme) {
    final suggestions = _getMockSuggestions();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested for You',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'People you might know based on your interests and connections',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          ...suggestions.map((user) => _buildUserCard(user, theme)),
          
          const SizedBox(height: 24),
          
          // Popular plant enthusiasts section
          Text(
            'Popular Plant Enthusiasts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with experienced gardeners and plant lovers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          ...(_getMockPopularUsers().map((user) => _buildUserCard(user, theme))),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_searchResults[index], theme);
      },
    );
  }

  Widget _buildEmptySearchResults(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name or email',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleMenuAction('invite_by_link'),
              child: const Text('Invite Friends'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(MockUser user, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user.displayName.split(' ').map((name) => name[0]).join(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (user.isVerified)
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  if (user.username.isNotEmpty)
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  Text(
                    user.bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (user.mutualFriends > 0)
                    Text(
                      '${user.mutualFriends} mutual friends',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (user.reason.isNotEmpty)
                    Text(
                      user.reason,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Action button
            _buildActionButton(user, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(MockUser user, ThemeData theme) {
    switch (user.status) {
      case UserStatus.notConnected:
        return ElevatedButton(
          onPressed: () => _sendFriendRequest(user),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Add',
            style: TextStyle(fontSize: 12),
          ),
        );
      
      case UserStatus.requestSent:
        return OutlinedButton(
          onPressed: () => _cancelFriendRequest(user),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Requested',
            style: TextStyle(fontSize: 12),
          ),
        );
      
      case UserStatus.friends:
        return OutlinedButton(
          onPressed: () => _viewProfile(user),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Friends',
            style: TextStyle(fontSize: 12),
          ),
        );
    }
  }

  List<MockUser> _getMockSuggestions() {
    return [
      MockUser(
        id: 'suggestion1',
        name: 'Grace Fern',
        username: 'gracefern',
        bio: 'Tropical plant collector 🌴',
        mutualFriends: 6,
        reason: 'Lives in your area',
        isVerified: true,
        status: UserStatus.notConnected,
      ),
      MockUser(
        id: 'suggestion2',
        name: 'Henry Sage',
        username: 'henrysage',
        bio: 'Organic gardener 🥬',
        mutualFriends: 2,
        reason: 'Friend of Alice Green',
        status: UserStatus.notConnected,
      ),
      MockUser(
        id: 'suggestion3',
        name: 'Ivy Mint',
        username: 'ivymint',
        bio: 'Hydroponic enthusiast 💧',
        mutualFriends: 0,
        reason: 'Similar interests',
        status: UserStatus.requestSent,
      ),
    ];
  }

  List<MockUser> _getMockPopularUsers() {
    return [
      MockUser(
        id: 'popular1',
        name: 'Dr. Plant Expert',
        username: 'drplantexpert',
        bio: 'Botanist & Plant Care Specialist 🔬🌿',
        mutualFriends: 0,
        reason: 'Popular in your area',
        isVerified: true,
        status: UserStatus.notConnected,
      ),
      MockUser(
        id: 'popular2',
        name: 'Garden Guru',
        username: 'gardenguru',
        bio: 'Sharing 20+ years of gardening wisdom 🌻',
        mutualFriends: 0,
        reason: 'Trending this week',
        isVerified: true,
        status: UserStatus.friends,
      ),
    ];
  }

  List<MockUser> _getMockSearchResults(String query) {
    final allUsers = [
      ...(_getMockSuggestions()),
      ...(_getMockPopularUsers()),
      MockUser(
        id: 'search1',
        name: 'Plant Lover',
        username: 'plantlover123',
        bio: 'New to plant parenting 🌱',
        status: UserStatus.notConnected,
      ),
      MockUser(
        id: 'search2',
        name: 'Green Thumb',
        username: 'greenthumb',
        bio: 'Cactus collection enthusiast 🌵',
        status: UserStatus.notConnected,
      ),
    ];
    
    return allUsers.where((user) {
      final searchLower = query.toLowerCase();
      return user.displayName.toLowerCase().contains(searchLower) ||
             user.username.toLowerCase().contains(searchLower) ||
             user.bio.toLowerCase().contains(searchLower);
    }).toList();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sync_contacts':
        _showContactSyncDialog();
        break;
      case 'invite_by_link':
        _showInviteLinkDialog();
        break;
      case 'qr_code':
        _showQRCodeDialog();
        break;
    }
  }

  void _sendFriendRequest(MockUser user) {
    setState(() {
      user.status = UserStatus.requestSent;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${user.displayName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelFriendRequest(MockUser user) {
    setState(() {
      user.status = UserStatus.notConnected;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request to ${user.displayName} cancelled'),
      ),
    );
  }

  void _viewProfile(MockUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${user.displayName}\'s profile (Demo mode)'),
      ),
    );
  }

  void _showContactSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Contacts'),
        content: const Text(
          'Allow Plant Social to access your contacts to find friends who are already using the app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Contact Sync');
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _showInviteLinkDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            const Text(
              'Invite Friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://plantsocial.app/invite/abc123',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  Icon(Icons.copy),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoon('Copy Link');
                    },
                    child: const Text('Copy Link'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoon('Share Link');
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QR Code\n(Demo)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this QR code with friends to connect instantly!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('QR Code Sharing');
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
                          content: Text('$feature feature is now available!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

/// User status enum
enum UserStatus {
  notConnected,
  requestSent,
  friends,
}

/// Mock user model for demonstration
class MockUser {
  final String id;
  final String name;
  final String username;
  final String bio;
  final int mutualFriends;
  final String reason;
  final bool isVerified;
  UserStatus status;

  MockUser({
    required this.id,
    required this.name,
    this.username = '',
    required this.bio,
    this.mutualFriends = 0,
    this.reason = '',
    this.isVerified = false,
    this.status = UserStatus.notConnected,
  });

  String get displayName => name;
}