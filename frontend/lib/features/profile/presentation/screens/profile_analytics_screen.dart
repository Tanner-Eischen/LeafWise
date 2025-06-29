import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:plant_social/core/widgets/loading_widget.dart';
import 'package:plant_social/core/widgets/error_widget.dart';

class ProfileAnalyticsScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const ProfileAnalyticsScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ProfileAnalyticsScreen> createState() => _ProfileAnalyticsScreenState();
}

class _ProfileAnalyticsScreenState extends ConsumerState<ProfileAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Analytics'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.analytics)),
            Tab(text: 'Behavior', icon: Icon(Icons.psychology)),
            Tab(text: 'Community', icon: Icon(Icons.group)),
            Tab(text: 'AI Insights', icon: Icon(Icons.smart_toy)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildBehaviorTab(theme),
          _buildCommunityTab(theme),
          _buildAIInsightsTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Health Score
          _buildProfileHealthCard(theme),
          const SizedBox(height: 16),
          
          // Activity Overview
          _buildActivityOverviewCard(theme),
          const SizedBox(height: 16),
          
          // Recent Achievements
          _buildRecentAchievementsCard(theme),
          const SizedBox(height: 16),
          
          // Quick Stats Grid
          _buildQuickStatsGrid(theme),
        ],
      ),
    );
  }

  Widget _buildBehaviorTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Engagement Patterns
          _buildEngagementPatternsCard(theme),
          const SizedBox(height: 16),
          
          // Content Preferences
          _buildContentPreferencesCard(theme),
          const SizedBox(height: 16),
          
          // Activity Timeline
          _buildActivityTimelineCard(theme),
          const SizedBox(height: 16),
          
          // Interaction Heatmap
          _buildInteractionHeatmapCard(theme),
        ],
      ),
    );
  }

  Widget _buildCommunityTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Matching Analytics
          _buildCommunityMatchingCard(theme),
          const SizedBox(height: 16),
          
          // Influence Metrics
          _buildInfluenceMetricsCard(theme),
          const SizedBox(height: 16),
          
          // Interest Alignment
          _buildInterestAlignmentCard(theme),
          const SizedBox(height: 16),
          
          // Geographic Distribution
          _buildGeographicDistributionCard(theme),
        ],
      ),
    );
  }

  Widget _buildAIInsightsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RAG Interaction Insights
          _buildRAGInsightsCard(theme),
          const SizedBox(height: 16),
          
          // ML Predictions
          _buildMLPredictionsCard(theme),
          const SizedBox(height: 16),
          
          // Personalization Effectiveness
          _buildPersonalizationCard(theme),
          const SizedBox(height: 16),
          
          // AI Recommendations
          _buildAIRecommendationsCard(theme),
        ],
      ),
    );
  }

  Widget _buildProfileHealthCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profile Health Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Circular Progress Indicator
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.87, // Mock data - would come from backend
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '87',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        'Excellent',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Health Factors
            _buildHealthFactors(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFactors(ThemeData theme) {
    final factors = [
      {'name': 'Profile Completeness', 'score': 95, 'color': Colors.green},
      {'name': 'Community Engagement', 'score': 78, 'color': Colors.blue},
      {'name': 'Content Quality', 'score': 89, 'color': Colors.orange},
      {'name': 'Plant Care Success', 'score': 92, 'color': Colors.teal},
    ];

    return Column(
      children: factors.map((factor) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  factor['name'] as String,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: (factor['score'] as int) / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    factor['color'] as Color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${factor['score']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityOverviewCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Activity Chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3.5),
                        FlSpot(1, 4.2),
                        FlSpot(2, 3.8),
                        FlSpot(3, 5.1),
                        FlSpot(4, 4.7),
                        FlSpot(5, 5.8),
                        FlSpot(6, 4.9),
                      ],
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementPatternsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement Patterns',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Peak Activity Times
            _buildPeakActivityTimes(theme),
            const SizedBox(height: 16),
            
            // Content Type Preferences
            _buildContentTypePreferences(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakActivityTimes(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peak Activity Times',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Time slots with activity levels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTimeSlot(theme, 'Morning', 0.7, '6-12'),
            _buildTimeSlot(theme, 'Afternoon', 0.4, '12-18'),
            _buildTimeSlot(theme, 'Evening', 0.9, '18-24'),
            _buildTimeSlot(theme, 'Night', 0.2, '24-6'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlot(ThemeData theme, String label, double activity, String hours) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 40,
              height: 60 * activity,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hours,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypePreferences(ThemeData theme) {
    final preferences = [
      {'type': 'Plant Care Tips', 'percentage': 85, 'color': Colors.green},
      {'type': 'Community Q&A', 'percentage': 72, 'color': Colors.blue},
      {'type': 'Plant Trades', 'percentage': 58, 'color': Colors.orange},
      {'type': 'Plant Stories', 'percentage': 67, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Type Preferences',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...preferences.map((pref) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: pref['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pref['type'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${pref['percentage']}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRAGInsightsCard(ThemeData theme) {
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
                  'RAG Interaction Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // RAG Statistics
            _buildRAGStatistics(theme),
            const SizedBox(height: 16),
            
            // Query Topics
            _buildQueryTopics(theme),
            const SizedBox(height: 16),
            
            // Response Quality
            _buildResponseQuality(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRAGStatistics(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(theme, 'Total Queries', '2,847'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(theme, 'Avg. Confidence', '87.3%'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(theme, 'Success Rate', '94.2%'),
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQueryTopics(ThemeData theme) {
    final topics = [
      {'topic': 'Plant Health', 'percentage': 32},
      {'topic': 'Watering Care', 'percentage': 28},
      {'topic': 'Pest Control', 'percentage': 18},
      {'topic': 'Fertilization', 'percentage': 14},
      {'topic': 'Propagation', 'percentage': 8},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Queried Topics',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...topics.map((topic) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    topic['topic'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: LinearProgressIndicator(
                    value: (topic['percentage'] as int) / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${topic['percentage']}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResponseQuality(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Quality Metrics',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '4.7',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg. Rating',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 5 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '92%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Helpfulness',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMLPredictionsCard(ThemeData theme) {
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
                  'ML Prediction Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Prediction Accuracy
            _buildPredictionAccuracy(theme),
            const SizedBox(height: 16),
            
            // Model Performance
            _buildModelPerformance(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionAccuracy(ThemeData theme) {
    final predictions = [
      {'model': 'Plant Health', 'accuracy': 87, 'predictions': 245},
      {'model': 'Care Optimization', 'accuracy': 92, 'predictions': 189},
      {'model': 'Risk Assessment', 'accuracy': 84, 'predictions': 156},
      {'model': 'Success Predictor', 'accuracy': 89, 'predictions': 134},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Model Performance',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...predictions.map((pred) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pred['model'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${pred['predictions']} predictions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LinearProgressIndicator(
                    value: (pred['accuracy'] as int) / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAccuracyColor(pred['accuracy'] as int),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${pred['accuracy']}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getAccuracyColor(pred['accuracy'] as int),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildModelPerformance(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPerformanceMetric(theme, 'F1 Score', '0.89'),
              _buildPerformanceMetric(theme, 'Precision', '0.92'),
              _buildPerformanceMetric(theme, 'Recall', '0.86'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  // Placeholder methods for other cards
  Widget _buildRecentAchievementsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Achievements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildAchievementItems(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimelineCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Timeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildTimelineItems(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionHeatmapCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Heatmap',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapVisualization(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityMatchingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Matching Analytics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildCommunityMatchingData(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfluenceMetricsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Influence Metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildInfluenceMetricsData(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestAlignmentCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interest Alignment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildInterestAlignmentData(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicDistributionCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geographic Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildGeographicData(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalization Effectiveness',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildPersonalizationData(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Recommendations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildAIRecommendationsData(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAchievementItems(ThemeData theme) {
    final achievements = [
      {'name': 'Plant Parent', 'progress': 0.8, 'icon': Icons.local_florist, 'color': Colors.green},
      {'name': 'Community Helper', 'progress': 0.6, 'icon': Icons.people_alt, 'color': Colors.blue},
      {'name': 'Green Thumb', 'progress': 0.9, 'icon': Icons.thumb_up, 'color': Colors.orange},
      {'name': 'Knowledge Seeker', 'progress': 0.4, 'icon': Icons.school, 'color': Colors.purple},
    ];

    return achievements.map((achievement) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(achievement['icon'] as IconData, color: achievement['color'] as Color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                LinearProgressIndicator(
                  value: achievement['progress'] as double,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(achievement['color'] as Color),
                ),
              ],
            ),
          ),
          Text(
            '${((achievement['progress'] as double) * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = [
      {'label': 'Plants', 'value': '23', 'icon': Icons.local_florist, 'color': Colors.green},
      {'label': 'Friends', 'value': '47', 'icon': Icons.people, 'color': Colors.blue},
      {'label': 'Posts', 'value': '156', 'icon': Icons.photo_camera, 'color': Colors.purple},
      {'label': 'Answers', 'value': '89', 'icon': Icons.question_answer, 'color': Colors.orange},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: stats.map((stat) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (stat['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (stat['color'] as Color).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat['value'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stat['color'] as Color,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<Widget> _buildTimelineItems(ThemeData theme) {
    final activities = [
      {'time': '2h ago', 'action': 'Shared plant story', 'icon': Icons.photo_camera, 'color': Colors.purple},
      {'time': '1d ago', 'action': 'Answered question', 'icon': Icons.question_answer, 'color': Colors.blue},
      {'time': '2d ago', 'action': 'Added new plant', 'icon': Icons.local_florist, 'color': Colors.green},
      {'time': '3d ago', 'action': 'Made new friend', 'icon': Icons.people, 'color': Colors.orange},
    ];

    return activities.map((activity) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity['action'] as String,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            activity['time'] as String,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildHeatmapVisualization(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [0.3, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4];

    return Column(
      children: [
        Text('Weekly Activity Pattern', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(days.length, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(width: 24, child: Text(days[index], style: theme.textTheme.bodySmall)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: values[index],
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<Widget> _buildCommunityMatchingData(ThemeData theme) {
    final matches = [
      {'name': 'Plant Enthusiasts', 'score': 0.92, 'members': 156},
      {'name': 'Succulent Lovers', 'score': 0.78, 'members': 89},
      {'name': 'Indoor Gardeners', 'score': 0.85, 'members': 234},
    ];

    return matches.map((match) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match['name'] as String, style: theme.textTheme.bodyMedium),
                Text('${match['members']} members', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${((match['score'] as double) * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildInfluenceMetricsData(ThemeData theme) {
    final metrics = [
      {'metric': 'Helpfulness Score', 'value': 4.8, 'icon': Icons.star},
      {'metric': 'Content Quality', 'value': 9.2, 'icon': Icons.quality_vote},
      {'metric': 'Community Impact', 'value': 7.6, 'icon': Icons.trending_up},
    ];

    return metrics.map((metric) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(metric['icon'] as IconData, color: theme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(metric['metric'] as String, style: theme.textTheme.bodyMedium),
          ),
          Text(
            metric['value'].toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildInterestAlignmentData(ThemeData theme) {
    final interests = [
      {'interest': 'Indoor Plants', 'alignment': 0.95, 'color': Colors.green},
      {'interest': 'Plant Care', 'alignment': 0.87, 'color': Colors.blue},
      {'interest': 'Gardening Tips', 'alignment': 0.73, 'color': Colors.orange},
    ];

    return interests.map((interest) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(interest['interest'] as String, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: interest['alignment'] as double,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(interest['color'] as Color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${((interest['alignment'] as double) * 100).toInt()}%',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildGeographicData(ThemeData theme) {
    final locations = [
      {'city': 'San Francisco', 'connections': 23, 'icon': Icons.location_city},
      {'city': 'New York', 'connections': 18, 'icon': Icons.location_city},
      {'city': 'Los Angeles', 'connections': 15, 'icon': Icons.location_city},
    ];

    return locations.map((location) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(location['icon'] as IconData, color: theme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(location['city'] as String, style: theme.textTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${location['connections']} friends',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildPersonalizationData(ThemeData theme) {
    final metrics = [
      {'metric': 'Content Relevance', 'score': 0.89, 'trend': '+12%'},
      {'metric': 'Recommendation Accuracy', 'score': 0.76, 'trend': '+8%'},
      {'metric': 'Engagement Prediction', 'score': 0.82, 'trend': '+15%'},
    ];

    return metrics.map((metric) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(metric['metric'] as String, style: theme.textTheme.bodyMedium),
          ),
          Text(
            '${((metric['score'] as double) * 100).toInt()}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric['trend'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildAIRecommendationsData(ThemeData theme) {
    final recommendations = [
      {'title': 'Try fertilizing your Monstera', 'confidence': 0.91, 'type': 'Care Tip'},
      {'title': 'Connect with Sarah about succulents', 'confidence': 0.84, 'type': 'Social'},
      {'title': 'Check out trending air plants', 'confidence': 0.77, 'type': 'Discovery'},
    ];

    return recommendations.map((rec) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec['title'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    rec['type'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${((rec['confidence'] as double) * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }
} 