import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/timelapse/models/timelapse_models.dart';
import 'package:leafwise/features/timelapse/providers/timelapse_provider.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';
import 'package:leafwise/features/timelapse/presentation/screens/timelapse_session_detail_screen.dart';

class TimelapseTrackingWidget extends ConsumerWidget {
  final String? plantId;
  final bool showActiveSessionsOnly;

  const TimelapseTrackingWidget({
    super.key,
    this.plantId,
    this.showActiveSessionsOnly = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (plantId != null) {
      final sessionsAsync = ref.watch(plantTimelapseSessionsProvider(plantId!));

      return sessionsAsync.when(
        data: (sessions) => _buildTrackingCard(context, theme, ref, sessions),
        loading: () => _buildLoadingCard(theme),
        error: (error, stack) => _buildErrorCard(theme, error.toString()),
      );
    }

    // Show general time-lapse overview when no specific plant is selected
    return _buildGeneralTimelapseCard(context, theme, ref);
  }

  Widget _buildTrackingCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    List<TimelapseSession> sessions,
  ) {
    final activeSessions = sessions.where((s) => s.status == 'active').toList();
    final displaySessions = showActiveSessionsOnly ? activeSessions : sessions;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Time-lapse Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (activeSessions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${activeSessions.length} ACTIVE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (displaySessions.isEmpty)
              _buildEmptyState(context, theme)
            else ...[
              // Sessions overview
              _buildSessionsOverview(theme, displaySessions),
              const SizedBox(height: 16),

              // Active session details
              if (activeSessions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildActiveSessionDetails(theme, activeSessions.first),
              ],

              // Recent progress
              const SizedBox(height: 16),
              _buildRecentProgress(theme, displaySessions),
            ],

            const SizedBox(height: 12),

            // Action buttons
            _buildActionButtons(context, theme, ref, activeSessions),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsOverview(
    ThemeData theme,
    List<TimelapseSession> sessions,
  ) {
    final totalPhotos = sessions.fold<int>(
      0,
      (sum, session) => sum + session.currentMetrics.totalPhotos,
    );
    final completedSessions = sessions
        .where((s) => s.status == 'completed')
        .length;
    final activeSessions = sessions.where((s) => s.status == 'active').length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tracking Overview',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  theme,
                  'Total Photos',
                  totalPhotos.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetric(
                  theme,
                  'Active Sessions',
                  activeSessions.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetric(
                  theme,
                  'Completed',
                  completedSessions.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionDetails(ThemeData theme, TimelapseSession session) {
    final daysRunning = DateTime.now().difference(session.startDate).inDays;
    final nextCaptureTime = _getNextCaptureTime(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Session Details',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.sessionName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Running for $daysRunning days',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${session.currentMetrics.totalPhotos} photos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        session.photoSchedule.frequency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Next capture: $nextCaptureTime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProgress(
    ThemeData theme,
    List<TimelapseSession> sessions,
  ) {
    // Get the most recent photos from active sessions
    final recentPhotos = sessions
        .where((s) => s.status == 'active')
        .map(
          (s) => {
            'session': s.sessionName,
            'lastPhoto': s.currentMetrics.lastPhotoDate,
            'photoCount': s.currentMetrics.totalPhotos,
          },
        )
        .toList();

    if (recentPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recent Progress',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentPhotos
            .take(3)
            .map((photo) => _buildProgressItem(theme, photo)),
      ],
    );
  }

  Widget _buildProgressItem(ThemeData theme, Map<String, dynamic> photo) {
    final lastPhoto = photo['lastPhoto'] as DateTime?;
    final timeAgo = lastPhoto != null
        ? _getTimeAgo(lastPhoto)
        : 'No photos yet';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
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
                  photo['session'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${photo['photoCount']} photos • Last: $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    List<TimelapseSession> activeSessions,
  ) {
    return Column(
      children: [
        if (activeSessions.isEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startNewSession(context, ref),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Start Time-lapse Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _capturePhoto(context, ref, activeSessions.first),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewSession(context, activeSessions.first),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Session'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showAllSessions(context),
            icon: const Icon(Icons.history),
            label: const Text('View All Sessions'),
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          'No time-lapse sessions yet',
          style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          'Start tracking your plant\'s growth over time',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGeneralTimelapseCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.movie_creation, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Time-lapse Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feature highlights
            _buildFeatureHighlights(theme),
            const SizedBox(height: 16),

            // Getting started tips
            _buildGettingStartedTips(theme),

            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exploreTimelapseFeatures(context),
                icon: const Icon(Icons.explore),
                label: const Text('Explore Time-lapse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(ThemeData theme) {
    final features = [
      {
        'icon': Icons.schedule,
        'title': 'Automated Capture',
        'description': 'Set custom schedules for automatic photo capture',
      },
      {
        'icon': Icons.analytics,
        'title': 'Growth Analysis',
        'description': 'Track growth patterns and milestones over time',
      },
      {
        'icon': Icons.video_library,
        'title': 'Video Generation',
        'description': 'Create stunning time-lapse videos of plant growth',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => _buildFeatureItem(theme, feature)),
      ],
    );
  }

  Widget _buildFeatureItem(ThemeData theme, Map<String, dynamic> feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  feature['description'] as String,
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

  Widget _buildGettingStartedTips(ThemeData theme) {
    final tips = [
      'Choose a consistent location with good lighting',
      'Set up a regular capture schedule (daily recommended)',
      'Keep your phone steady for best results',
      'Be patient - growth takes time to show!',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Getting Started Tips',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...tips.map((tip) => _buildTipItem(theme, tip)),
      ],
    );
  }

  Widget _buildTipItem(ThemeData theme, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: theme.primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Loading Time-lapse Data...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LoadingWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Time-lapse Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomErrorWidget(
              message: error,
              onRetry: () {
                // Retry logic would be handled by the parent
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Helper methods
  String _getNextCaptureTime(TimelapseSession session) {
    // Mock implementation - would calculate based on session schedule
    final now = DateTime.now();
    final nextCapture = now.add(const Duration(hours: 24));

    final difference = nextCapture.difference(now);
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).round()}w ago';
    }
  }

  // Action methods
  void _startNewSession(BuildContext context, WidgetRef ref) {
    // Navigate to session setup wizard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session setup wizard coming soon!')),
    );
  }

  void _capturePhoto(
    BuildContext context,
    WidgetRef ref,
    TimelapseSession session,
  ) {
    // Trigger manual photo capture
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Capturing photo for ${session.sessionName}...')),
    );
  }

  void _viewSession(BuildContext context, TimelapseSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TimelapseSessionDetailScreen(sessionId: session.sessionId),
      ),
    );
  }

  void _showAllSessions(BuildContext context) {
    // Navigate to all sessions view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All sessions view coming soon!')),
    );
  }

  void _exploreTimelapseFeatures(BuildContext context) {
    // Navigate to time-lapse features overview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time-lapse features overview coming soon!'),
      ),
    );
  }
}
