import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/plant_care/models/plant_care_models.dart';
import 'package:leafwise/features/plant_care/providers/plant_care_provider.dart';
import 'package:leafwise/features/plant_care/presentation/screens/add_plant_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/plant_detail_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/care_reminders_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/care_logs_screen.dart';
import 'package:leafwise/features/plant_care/presentation/widgets/plant_card.dart';
import 'package:leafwise/features/plant_care/presentation/widgets/care_reminder_card.dart';
import 'package:leafwise/features/seasonal_ai/presentation/widgets/seasonal_predictions_widget.dart';
import 'package:leafwise/features/timelapse/presentation/widgets/timelapse_tracking_widget.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';

class PlantCareDashboardScreen extends ConsumerStatefulWidget {
  const PlantCareDashboardScreen({super.key});

  @override
  ConsumerState<PlantCareDashboardScreen> createState() =>
      _PlantCareDashboardScreenState();
}

class _PlantCareDashboardScreenState
    extends ConsumerState<PlantCareDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantCareProvider.notifier).loadUserPlants();
      ref.read(plantCareProvider.notifier).loadUpcomingReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plantCareProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to plant search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CareRemindersScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Plants', icon: Icon(Icons.eco)),
            Tab(text: 'Reminders', icon: Icon(Icons.schedule)),
            Tab(text: 'Care Log', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlantsTab(state, theme),
          _buildRemindersTab(state, theme),
          _buildCareLogTab(state, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPlantsTab(PlantCareState state, ThemeData theme) {
    if (state.isLoadingPlants) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            ref.read(plantCareProvider.notifier).loadUserPlants();
          },
        ),
      );
    }

    if (state.userPlants.isEmpty) {
      return _buildEmptyPlantsState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(plantCareProvider.notifier).loadUserPlants();
      },
      child: CustomScrollView(
        slivers: [
          // Quick stats
          SliverToBoxAdapter(child: _buildQuickStats(state, theme)),

          // Plants grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final plant = state.userPlants[index];
                return PlantCard(
                  plant: plant,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PlantDetailScreen(plantId: plant.id),
                      ),
                    );
                  },
                );
              }, childCount: state.userPlants.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(PlantCareState state, ThemeData theme) {
    if (state.isLoadingReminders) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            ref.read(plantCareProvider.notifier).loadUpcomingReminders();
          },
        ),
      );
    }

    if (state.upcomingReminders.isEmpty) {
      return _buildEmptyRemindersState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(plantCareProvider.notifier).loadUpcomingReminders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.upcomingReminders.length,
        itemBuilder: (context, index) {
          final reminder = state.upcomingReminders[index];
          return CareReminderCard(
            reminder: reminder,
            onTap: () {},
            onComplete: () {
              ref
                  .read(plantCareProvider.notifier)
                  .completeReminder(reminder.id);
            },
            onSnooze: () {
              ref
                  .read(plantCareProvider.notifier)
                  .snoozeReminder(reminder.id, 1);
            },
          );
        },
      ),
    );
  }

  Widget _buildCareLogTab(PlantCareState state, ThemeData theme) {
    return const CareLogsScreen();
  }

  Widget _buildQuickStats(PlantCareState state, ThemeData theme) {
    final totalPlants = state.userPlants.length;
    final upcomingReminders = state.upcomingReminders.length;
    final overdueReminders = state.upcomingReminders
        .where((r) => r.nextDueDate.isBefore(DateTime.now()))
        .length;

    return Column(
      children: [
        // Enhanced Stats with ML Analytics
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ML-Enhanced Plant Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Plants',
                      totalPlants.toString(),
                      Icons.eco,
                      Colors.white,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'ML Health',
                      '87%',
                      Icons.psychology,
                      Colors.white,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Risk Alerts',
                      overdueReminders.toString(),
                      Icons.warning,
                      overdueReminders > 0 ? Colors.orange[300]! : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Rich Analytics Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ML Health Predictions Card
              _buildMLHealthCard(theme, state),
              const SizedBox(height: 12),

              // RAG Insights Card
              _buildRAGInsightsCard(theme),
              const SizedBox(height: 12),

              // Community Analytics Card
              _buildCommunityAnalyticsCard(theme),
              const SizedBox(height: 12),

              // Seasonal AI Predictions Widget
              const SeasonalPredictionsWidget(),
              const SizedBox(height: 12),

              // Time-lapse Tracking Widget
              const TimelapseTrackingWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyPlantsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No plants yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first plant to start tracking care',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddPlantScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Plant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRemindersState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No upcoming reminders',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your plants are up to date!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMLHealthCard(ThemeData theme, PlantCareState state) {
    // Mock ML health data - would come from backend
    final mockHealthData = {
      'overall_health_score': 0.87,
      'risk_level': 'low',
      'model_confidence': 0.92,
      'feature_scores': {
        'watering_consistency': 0.89,
        'light_exposure': 0.85,
        'soil_nutrients': 0.78,
        'growth_rate': 0.91,
      },
      'risk_factors': [],
      'predictions': {'next_week_health': 0.89, 'care_success_rate': 0.85},
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'ML Plant Health Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
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
                    'LOW RISK',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Overall Health Score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Health Score',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '87%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.health_and_safety,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Model Confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '92%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feature Scores
            Text(
              'Health Factors',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureScore(theme, 'Watering Consistency', 0.89),
            _buildFeatureScore(theme, 'Light Exposure', 0.85),
            _buildFeatureScore(theme, 'Soil Nutrients', 0.78),
            _buildFeatureScore(theme, 'Growth Rate', 0.91),

            const SizedBox(height: 12),

            // Predictions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ML Predictions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Next week health: 89% • Care success rate: 85%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureScore(ThemeData theme, String label, double score) {
    Color scoreColor = score >= 0.8
        ? Colors.green
        : score >= 0.6
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '${(score * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRAGInsightsCard(ThemeData theme) {
    // Mock RAG data - would come from backend
    final mockRAGData = {
      'total_queries': 2847,
      'success_rate': 94,
      'avg_response_time': 245,
      'recent_queries': [
        'Plant Health',
        'Watering Tips',
        'Pest Control',
        'Fertilizer',
      ],
      'response_quality': 0.94,
      'knowledge_coverage': {
        'Plant Care': 89.0,
        'Disease Treatment': 76.0,
        'Nutrition': 82.0,
      },
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'RAG Knowledge Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RAG Statistics
            Row(
              children: [
                Expanded(
                  child: _buildMiniMetric(theme, 'Total Queries', '2,847'),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniMetric(theme, 'Success Rate', '94%')),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniMetric(theme, 'Avg Response', '245ms'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Knowledge Coverage
            Text(
              'Knowledge Coverage',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildKnowledgeItem(theme, 'Plant Care', 89),
            _buildKnowledgeItem(theme, 'Disease Treatment', 76),
            _buildKnowledgeItem(theme, 'Nutrition', 82),

            const SizedBox(height: 12),

            // Response Quality
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response Quality',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < 5 ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '94%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildKnowledgeItem(ThemeData theme, String label, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityAnalyticsCard(ThemeData theme) {
    // Mock community data - would come from backend
    final mockCommunityData = {
      'avg_similarity_score': 0.76,
      'total_matches': 34,
      'top_interests': [
        {'interest': 'Indoor Plants', 'percentage': 78},
        {'interest': 'Succulents', 'percentage': 62},
        {'interest': 'Herbs', 'percentage': 45},
      ],
      'influence_score': 3.2,
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Community Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Matching Score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Matching Score',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '76%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: 0.76,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Shared Interests
            Text(
              'Top Shared Interests',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    'Indoor Plants 78%',
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                Chip(
                  label: Text(
                    'Succulents 62%',
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                Chip(
                  label: Text('Herbs 45%', style: theme.textTheme.bodySmall),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Community Stats
            Row(
              children: [
                Expanded(child: _buildMiniMetric(theme, 'Similar Users', '34')),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniMetric(theme, 'Influence Score', '3.2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(ThemeData theme, String label, String value) {
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
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
