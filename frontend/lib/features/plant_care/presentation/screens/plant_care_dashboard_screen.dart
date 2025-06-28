import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';
import 'package:plant_social/features/plant_care/providers/plant_care_provider.dart';
import 'package:plant_social/features/plant_care/presentation/screens/add_plant_screen.dart';
import 'package:plant_social/features/plant_care/presentation/screens/plant_detail_screen.dart';
import 'package:plant_social/features/plant_care/presentation/screens/care_reminders_screen.dart';
import 'package:plant_social/features/plant_care/presentation/screens/care_logs_screen.dart';
import 'package:plant_social/features/plant_care/presentation/widgets/plant_card.dart';
import 'package:plant_social/features/plant_care/presentation/widgets/care_reminder_card.dart';
import 'package:plant_social/core/widgets/loading_widget.dart';
import 'package:plant_social/core/widgets/error_widget.dart';

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
            MaterialPageRoute(
              builder: (context) => const AddPlantScreen(),
            ),
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
          SliverToBoxAdapter(
            child: _buildQuickStats(state, theme),
          ),

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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final plant = state.userPlants[index];
                  return PlantCard(
                    plant: plant,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlantDetailScreen(plantId: plant.id),
                        ),
                      );
                    },
                  );
                },
                childCount: state.userPlants.length,
              ),
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
              ref.read(plantCareProvider.notifier).completeReminder(reminder.id);
            },
            onSnooze: () {
              ref.read(plantCareProvider.notifier).snoozeReminder(reminder.id, 1);
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

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
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
      child: Row(
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
              'Upcoming',
              upcomingReminders.toString(),
              Icons.schedule,
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
              'Overdue',
              overdueReminders.toString(),
              Icons.warning,
              overdueReminders > 0 ? Colors.orange[300]! : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
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
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlantsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: Colors.grey[400],
          ),
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
                MaterialPageRoute(
                  builder: (context) => const AddPlantScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Plant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
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
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.grey[400],
          ),
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
}