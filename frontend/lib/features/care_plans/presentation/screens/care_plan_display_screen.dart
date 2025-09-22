import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:leafwise/features/care_plans/providers/care_plan_provider.dart';
import 'package:leafwise/features/care_plans/presentation/screens/care_plan_generation_screen.dart';
import 'package:leafwise/features/care_plans/presentation/screens/care_plan_history_screen.dart';
import 'package:leafwise/features/care_plans/presentation/widgets/care_plan_card.dart';
import 'package:leafwise/features/care_plans/presentation/widgets/care_plan_rationale_widget.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';

/// Care Plan Display Screen
///
/// Main screen for displaying active care plans with rationale and management options.
/// Features:
/// - Active care plans list with status indicators
/// - Care plan rationale display with explainable AI insights
/// - Quick actions for acknowledgment and plan generation
/// - Navigation to history and detailed views
class CarePlanDisplayScreen extends ConsumerStatefulWidget {
  final String? userPlantId;

  const CarePlanDisplayScreen({super.key, this.userPlantId});

  @override
  ConsumerState<CarePlanDisplayScreen> createState() =>
      _CarePlanDisplayScreenState();
}

class _CarePlanDisplayScreenState extends ConsumerState<CarePlanDisplayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userPlantId != null) {
        ref
            .read(carePlanProvider.notifier)
            .getCurrentCarePlan(userPlantId: widget.userPlantId!);
      }
      ref.read(carePlanProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carePlanProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userPlantId != null ? 'Plant Care Plans' : 'All Care Plans',
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CarePlanHistoryScreen(userPlantId: widget.userPlantId),
                ),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (state.pendingNotifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${state.pendingNotifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showNotificationsBottomSheet(context, state.pendingNotifications);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active Plans', icon: Icon(Icons.assignment)),
            Tab(text: 'Rationale', icon: Icon(Icons.psychology)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivePlansTab(state, theme),
          _buildRationaleTab(state, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CarePlanGenerationScreen(userPlantId: widget.userPlantId),
            ),
          );
        },
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Generate Plan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActivePlansTab(CarePlanState state, ThemeData theme) {
    if (state.isLoadingPlans) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            if (widget.userPlantId != null) {
              ref
                  .read(carePlanProvider.notifier)
                  .getCurrentCarePlan(userPlantId: widget.userPlantId!);
            }
          },
        ),
      );
    }

    if (state.activePlans.isEmpty) {
      return _buildEmptyPlansState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.userPlantId != null) {
          await ref
              .read(carePlanProvider.notifier)
              .getCurrentCarePlan(userPlantId: widget.userPlantId!);
        }
      },
      child: CustomScrollView(
        slivers: [
          // Quick stats
          SliverToBoxAdapter(child: _buildQuickStats(state, theme)),

          // Active plans list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final plan = state.activePlans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CarePlanCard(
                    plan: plan,
                    onTap: () {
                      setState(() {
                        _selectedPlanId = plan.id;
                      });
                      _tabController.animateTo(1); // Switch to rationale tab
                    },
                    onAcknowledge: plan.status == CarePlanStatus.pending
                        ? () => _acknowledgePlan(plan)
                        : null,
                    showActions: true,
                  ),
                );
              }, childCount: state.activePlans.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRationaleTab(CarePlanState state, ThemeData theme) {
    if (_selectedPlanId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a care plan to view rationale',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on any active care plan to see the AI reasoning\nand recommendations behind it',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final selectedPlan = state.activePlans.firstWhere(
      (plan) => plan.id == _selectedPlanId,
      orElse: () => throw StateError('Plan not found in active plans'),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CarePlanRationaleWidget(
        rationale: selectedPlan.rationale,
      ),
    );
  }

  Widget _buildQuickStats(CarePlanState state, ThemeData theme) {
    final pendingCount = state.activePlans
        .where((plan) => plan.status == CarePlanStatus.pending)
        .length;
    final acknowledgedCount = state.activePlans
        .where((plan) => plan.status == CarePlanStatus.acknowledged)
        .length;
    final activeCount = state.activePlans
        .where((plan) => plan.status == CarePlanStatus.active)
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Pending',
              pendingCount.toString(),
              Icons.pending_actions,
              Colors.orange,
              theme,
            ),
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(
            child: _buildStatItem(
              'Active',
              activeCount.toString(),
              Icons.check_circle,
              Colors.green,
              theme,
            ),
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(
            child: _buildStatItem(
              'Acknowledged',
              acknowledgedCount.toString(),
              Icons.verified,
              Colors.blue,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlansState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: theme.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No active care plans',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first AI-powered care plan\nto get personalized plant care recommendations',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CarePlanGenerationScreen(userPlantId: widget.userPlantId),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Care Plan'),
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

  void _acknowledgePlan(CarePlan plan) async {
    try {
      await ref.read(carePlanProvider.notifier).acknowledgeCarePlan(planId: plan.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Care plan acknowledged successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to acknowledge plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNotificationsBottomSheet(
    BuildContext context,
    List<CarePlanNotification> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.notifications),
                  const SizedBox(width: 8),
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Mark all as read
                      for (final notification in notifications) {
                        ref
                            .read(carePlanProvider.notifier)
                            .markNotificationAsRead(notification.id);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                    ),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref
                            .read(carePlanProvider.notifier)
                            .markNotificationAsRead(notification.id);
                      },
                    ),
                    onTap: () {
                      // Handle notification tap
                      ref
                          .read(carePlanProvider.notifier)
                          .markNotificationAsRead(notification.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(CarePlanNotificationType type) {
    switch (type) {
      case CarePlanNotificationType.planGenerated:
        return Icons.auto_awesome;
      case CarePlanNotificationType.planUpdated:
        return Icons.update;
      case CarePlanNotificationType.wateringDue:
        return Icons.schedule;
      case CarePlanNotificationType.fertilizingDue:
        return Icons.warning;
      case CarePlanNotificationType.urgentAlert:
        return Icons.error;
      case CarePlanNotificationType.reviewDue:
        return Icons.rate_review;
    }
  }

  Color _getNotificationColor(CarePlanNotificationType type) {
    switch (type) {
      case CarePlanNotificationType.planGenerated:
        return Colors.green;
      case CarePlanNotificationType.planUpdated:
        return Colors.teal;
      case CarePlanNotificationType.wateringDue:
        return Colors.blue;
      case CarePlanNotificationType.fertilizingDue:
        return Colors.orange;
      case CarePlanNotificationType.urgentAlert:
        return Colors.red;
      case CarePlanNotificationType.reviewDue:
        return Colors.purple;
    }
  }
}
