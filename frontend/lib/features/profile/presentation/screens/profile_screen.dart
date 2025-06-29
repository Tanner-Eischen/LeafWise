import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user.dart';
import '../../../auth/providers/auth_provider.dart';

/// Profile screen displaying user information and settings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'privacy',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip),
                    SizedBox(width: 8),
                    Text('Privacy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help & Support'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, theme, authState, ref),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, AuthState authState, WidgetRef ref) {
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading profile: ${authState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(authProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildProfileContent(context, theme, authState);
  }

  Widget _buildProfileContent(BuildContext context, ThemeData theme, AuthState state) {
    // Mock user data for demonstration
    final mockUser = MockUser(
      id: state.user?.id ?? 'user1',
      name: state.user?.displayName ?? 'Plant Lover',
      email: state.user?.email ?? 'plantlover@example.com',
      bio: 'Passionate about plants and sustainable living 🌱\nSharing my green journey with fellow plant enthusiasts!',
      location: 'San Francisco, CA',
      joinDate: DateTime(2023, 1, 15),
      followersCount: 1247,
      followingCount: 892,
      postsCount: 156,
      plantsCount: 23,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          _buildProfileHeader(context, theme, mockUser),
          const SizedBox(height: 24),
          
          // Stats section
          _buildStatsSection(theme, mockUser),
          const SizedBox(height: 24),
          
          // Bio section
          _buildBioSection(theme, mockUser),
          const SizedBox(height: 24),
          
          // Quick actions
          _buildQuickActions(context, theme),
          const SizedBox(height: 24),
          
          // Recent activity
          _buildRecentActivity(theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, MockUser user) {
    return Column(
      children: [
        // Profile picture
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user.displayName.split(' ').map((name) => name[0]).join(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Change profile picture (Demo mode)'),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Name and verification
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.verified,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Email
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        
        // Location and join date
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              user.location,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Joined ${_formatJoinDate(user.joinDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme, MockUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(theme, 'Posts', user.postsCount.toString()),
            _buildStatDivider(theme),
            _buildStatItem(theme, 'Plants', user.plantsCount.toString()),
            _buildStatDivider(theme),
            _buildStatItem(theme, 'Followers', _formatCount(user.followersCount)),
            _buildStatDivider(theme),
            _buildStatItem(theme, 'Following', _formatCount(user.followingCount)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.colorScheme.outline.withOpacity(0.3),
    );
  }

  Widget _buildBioSection(ThemeData theme, MockUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.bio,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  theme,
                  Icons.eco,
                  'My Plants',
                  () => _showComingSoon(context, 'My Plants'),
                ),
                _buildActionButton(
                  context,
                  theme,
                  Icons.bookmark,
                  'Saved',
                  () => _showComingSoon(context, 'Saved Posts'),
                ),
                _buildActionButton(
                  context,
                  theme,
                  Icons.analytics,
                  'Insights',
                  () => _showProfileInsights(context),
                ),
                _buildActionButton(
                  context,
                  theme,
                  Icons.share,
                  'Share',
                  () => _showShareProfile(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildActivityItems(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityItems(ThemeData theme) {
    final activities = [
      ('Posted a new plant photo', '2 hours ago', Icons.camera_alt),
      ('Liked 5 posts', '1 day ago', Icons.favorite),
      ('Added new plant to collection', '3 days ago', Icons.eco),
      ('Followed 3 new gardeners', '1 week ago', Icons.person_add),
    ];

    return activities.map((activity) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity.$3,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.$1,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    activity.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'settings':
        _showComingSoon(context, 'Settings');
        break;
      case 'privacy':
        _showComingSoon(context, 'Privacy Settings');
        break;
      case 'help':
        _showComingSoon(context, 'Help & Support');
        break;
      case 'logout':
        _showLogoutDialog(context, ref);
        break;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
                          content: Text('$feature functionality activated!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showProfileInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _buildProfileInsightsSheet(context, scrollController);
        },
      ),
    );
  }

  Widget _buildProfileInsightsSheet(BuildContext context, ScrollController scrollController) {
    final theme = Theme.of(context);
    
    // Mock analytics data - would come from backend API calls
    final mockAnalyticsData = {
      'profile_health_score': 0.87,
      'engagement_score': 0.82,
      'ml_health_data': {
        'overall_health_score': 0.89,
        'risk_level': 'low',
        'model_confidence': 0.94,
        'feature_scores': {
          'activity_consistency': 0.91,
          'content_quality': 0.85,
          'community_interaction': 0.78,
          'learning_engagement': 0.88,
        },
        'predictions': {
          'next_week_engagement': 0.86,
          'content_success_rate': 0.82,
        }
      },
      'rag_insights': {
        'total_queries': 147,
        'success_rate': 96,
        'avg_response_time': 234,
        'recent_topics': ['Plant Care', 'Disease Treatment', 'Fertilizers', 'Watering'],
        'response_quality': 0.93,
        'knowledge_coverage': {
          'Plant Care': 92.0,
          'Disease Treatment': 78.0,
          'Nutrition': 85.0,
        }
      },
      'community_data': {
        'avg_similarity_score': 0.73,
        'total_matches': 28,
        'top_interests': [
          {'interest': 'Indoor Gardening', 'percentage': 82},
          {'interest': 'Sustainable Living', 'percentage': 67},
          {'interest': 'Plant Photography', 'percentage': 54},
        ],
        'influence_score': 2.8,
      }
    };

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.analytics, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profile Analytics & Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Health Overview
                  _buildProfileHealthOverview(theme, mockAnalyticsData),
                  const SizedBox(height: 20),
                  
                  // ML Health Analytics
                  _buildMLHealthAnalytics(theme, mockAnalyticsData['ml_health_data'] as Map<String, dynamic>),
                  const SizedBox(height: 20),
                  
                  // RAG Knowledge Insights
                  _buildRAGKnowledgeInsights(theme, mockAnalyticsData['rag_insights'] as Map<String, dynamic>),
                  const SizedBox(height: 20),
                  
                  // Community Analytics
                  _buildCommunityAnalytics(theme, mockAnalyticsData['community_data'] as Map<String, dynamic>),
                  const SizedBox(height: 20),
                  
                  // Behavior Patterns
                  _buildBehaviorPatterns(theme),
                  const SizedBox(height: 20),
                  
                  // Recommendations
                  _buildRecommendations(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHealthOverview(ThemeData theme, Map<String, dynamic> data) {
    final healthScore = data['profile_health_score'] ?? 0.87;
    final engagementScore = data['engagement_score'] ?? 0.82;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profile Health Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(healthScore * 100).toInt()}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Profile Health',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(engagementScore * 100).toInt()}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        'Engagement',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMLHealthAnalytics(ThemeData theme, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'ML Behavior Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Behavioral Factors',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            ...(data['feature_scores'] as Map<String, dynamic>).entries.map((entry) {
              final score = entry.value as double;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatFeatureName(entry.key),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: score,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          score >= 0.8 ? Colors.green : score >= 0.6 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(score * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRAGKnowledgeInsights(ThemeData theme, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Knowledge Interaction Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildInsightMetric(theme, 'Queries', '${data['total_queries']}')),
                Expanded(child: _buildInsightMetric(theme, 'Success Rate', '${data['success_rate']}%')),
                Expanded(child: _buildInsightMetric(theme, 'Quality', '${(data['response_quality'] * 100).toInt()}%')),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              'Recent Query Topics',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (data['recent_topics'] as List<dynamic>).map<Widget>((topic) {
                return Chip(
                  label: Text(topic.toString(), style: theme.textTheme.bodySmall),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityAnalytics(ThemeData theme, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Community Connection Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Match Score',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      Text(
                        '${(data['avg_similarity_score'] * 100).toInt()}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('Similar Users', style: theme.textTheme.bodySmall),
                    Text('${data['total_matches']}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              'Top Shared Interests',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            ...(data['top_interests'] as List<dynamic>).map<Widget>((interest) {
              final interestData = interest as Map<String, dynamic>;
              return Chip(
                label: Text(
                  '${interestData['interest']} ${interestData['percentage']}%',
                  style: theme.textTheme.bodySmall,
                ),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorPatterns(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Activity Patterns',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Peak Activity Times',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityTime(theme, 'Morning', 0.7),
                _buildActivityTime(theme, 'Afternoon', 0.4),
                _buildActivityTime(theme, 'Evening', 0.9),
                _buildActivityTime(theme, 'Night', 0.2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTime(ThemeData theme, String label, double activity) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 30,
              height: 50 * activity,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRecommendations(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildRecommendationItem(theme, 'Increase morning engagement', 'Your activity is highest in evenings. Try morning interactions to boost consistency.'),
            _buildRecommendationItem(theme, 'Explore fertilizer topics', 'Based on your interests, you might enjoy learning about organic fertilizers.'),
            _buildRecommendationItem(theme, 'Connect with similar users', 'We found 8 users with 85%+ similar interests. Consider following them!'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetric(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatFeatureName(String key) {
    return key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  void _showShareProfile(BuildContext context) {
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
              'Share Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
                  _buildSharingInterface(context, theme),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildSharingInterface(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Your Plant Journey',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShareOption(
                context,
                'QR Code',
                Icons.qr_code,
                'Quick profile share',
                () => _shareViaQR(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShareOption(
                context,
                'Link',
                Icons.link,
                'Share profile URL',
                () => _shareViaLink(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildShareOption(
                context,
                'Social Media',
                Icons.share,
                'Post to social networks',
                () => _shareToSocial(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShareOption(
                context,
                'Plant Card',
                Icons.local_florist,
                'Share plant collection',
                () => _sharePlantCard(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareOption(BuildContext context, String title, IconData icon, String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _shareViaQR(BuildContext context) {
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code, size: 100),
            ),
            const SizedBox(height: 16),
            const Text('Scan to view my plant profile!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR code saved to gallery!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareViaLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile link copied to clipboard!'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: null,
        ),
      ),
    );
  }

  void _shareToSocial(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share to Social Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialShareButton('Instagram', Icons.camera_alt, Colors.purple),
                _buildSocialShareButton('Facebook', Icons.facebook, Colors.blue),
                _buildSocialShareButton('Twitter', Icons.alternate_email, Colors.lightBlue),
                _buildSocialShareButton('TikTok', Icons.music_note, Colors.black),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialShareButton(String platform, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 4),
        Text(platform, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _sharePlantCard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating shareable plant collection card...'),
        action: SnackBarAction(
          label: 'Preview',
          onPressed: null,
        ),
      ),
    );
  }
}

/// Mock user model for demonstration
class MockUser {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String location;
  final DateTime joinDate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int plantsCount;

  MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.location,
    required this.joinDate,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.plantsCount,
  });

  String get displayName => name;
}