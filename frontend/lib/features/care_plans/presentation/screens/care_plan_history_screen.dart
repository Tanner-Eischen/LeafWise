import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:leafwise/features/care_plans/providers/care_plan_provider.dart';
import 'package:leafwise/features/care_plans/presentation/widgets/care_plan_history_card.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';
import 'package:leafwise/core/widgets/error_widget.dart';
import 'package:intl/intl.dart';

/// Care Plan History Screen
/// 
/// Displays historical care plans with version comparison and filtering options.
/// Features:
/// - Chronological list of past care plans
/// - Version comparison between different plans
/// - Filtering by plant, date range, and status
/// - Detailed view with rationale for each plan
class CarePlanHistoryScreen extends ConsumerStatefulWidget {
  final String? userPlantId;
  
  const CarePlanHistoryScreen({
    super.key,
    this.userPlantId,
  });

  @override
  ConsumerState<CarePlanHistoryScreen> createState() =>
      _CarePlanHistoryScreenState();
}

class _CarePlanHistoryScreenState
    extends ConsumerState<CarePlanHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  CarePlanHistory? _selectedPlanForComparison;
  CarePlanHistory? _comparisonPlan;
  bool _showComparison = false;
  
  // Filters
  String? _statusFilter;
  DateTimeRange? _dateFilter;
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carePlanProvider.notifier).loadPlanHistory(
        userPlantId: widget.userPlantId,
      );
    });
    
    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(carePlanProvider.notifier).loadMoreHistory(
        userPlantId: widget.userPlantId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(carePlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userPlantId != null 
            ? 'Plant Care History' 
            : 'All Care History'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          if (_showComparison)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showComparison = false;
                  _selectedPlanForComparison = null;
                  _comparisonPlan = null;
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: _showComparison ? 'Compare' : 'History',
              icon: Icon(_showComparison ? Icons.compare : Icons.history),
            ),
            const Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(theme),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _showComparison
                    ? _buildComparisonView(state, theme)
                    : _buildHistoryList(state, theme),
                _buildTimelineView(state, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search care plans...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = null;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.isEmpty ? null : value;
          });
        },
      ),
    );
  }

  Widget _buildHistoryList(CarePlanState state, ThemeData theme) {
    if (state.isLoadingHistory && state.planHistory.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (state.historyError != null) {
      return Center(
        child: CustomErrorWidget(
          message: state.historyError!,
          onRetry: () {
            ref.read(carePlanProvider.notifier).loadPlanHistory(
              userPlantId: widget.userPlantId,
            );
          },
        ),
      );
    }

    final filteredPlans = _filterPlans(state.planHistory);

    if (filteredPlans.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(carePlanProvider.notifier).loadPlanHistory(
          userPlantId: widget.userPlantId,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredPlans.length + (state.hasMoreHistory ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredPlans.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            );
          }

          final plan = filteredPlans[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CarePlanHistoryCard(
              plan: plan,
              onTap: () => _showPlanDetails(plan),
              onViewDetails: () => _showPlanDetails(plan),
              showActions: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonView(CarePlanState state, ThemeData theme) {
    if (_selectedPlanForComparison == null || _comparisonPlan == null) {
      return _buildComparisonSelection(state, theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Comparison',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Comparison cards
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Plan A',
                  _selectedPlanForComparison!,
                  Colors.blue,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  'Plan B',
                  _comparisonPlan!,
                  Colors.green,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Detailed comparison
          _buildDetailedComparison(
            _selectedPlanForComparison!,
            _comparisonPlan!,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(CarePlanState state, ThemeData theme) {
    final filteredPlans = _filterPlans(state.planHistory);
    
    if (filteredPlans.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        final plan = filteredPlans[index];
        final isLast = index == filteredPlans.length - 1;
        
        return _buildTimelineItem(plan, isLast, theme);
      },
    );
  }

  Widget _buildTimelineItem(CarePlanHistory plan, bool isLast, ThemeData theme) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColorFromHistory(plan),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(plan.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColorFromHistory(plan).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusTextFromHistory(plan),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColorFromHistory(plan),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Plan Generated',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${plan.version} - ${plan.urgentAlerts.length} alerts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _showPlanDetails(plan),
                              child: const Text('View Details'),
                            ),
                            TextButton(
                              onPressed: () => _selectForComparison(plan),
                              child: const Text('Compare'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSelection(CarePlanState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Plans to Compare',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose two care plans to compare their recommendations and rationale',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_selectedPlanForComparison != null) ...[
            Text(
              'Plan A Selected:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CarePlanHistoryCard(
              plan: _selectedPlanForComparison!,
              onTap: () {},
              showActions: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Select Plan B:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          Expanded(
            child: ListView.builder(
              itemCount: state.planHistory.length,
              itemBuilder: (context, index) {
                final plan = state.planHistory[index];
                final isSelected = plan.id == _selectedPlanForComparison?.id;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CarePlanHistoryCard(
                      plan: plan,
                      onTap: () {
                        if (_selectedPlanForComparison == null) {
                          setState(() {
                            _selectedPlanForComparison = plan;
                          });
                        } else if (plan.id != _selectedPlanForComparison!.id) {
                          setState(() {
                            _comparisonPlan = plan;
                            _showComparison = true;
                          });
                        }
                      },
                      showActions: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    CarePlanHistory plan,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd').format(plan.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusTextFromHistory(plan),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.plantNickname,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            plan.speciesName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedComparison(
    CarePlanHistory planA,
    CarePlanHistory planB,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Comparison',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Basic information comparison
        _buildComparisonSection(
          'Plant Information',
          '${planA.plantNickname} (${planA.speciesName})',
          '${planB.plantNickname} (${planB.speciesName})',
          theme,
        ),
        
        _buildComparisonSection(
          'Next Watering',
          DateFormat('MMM dd, yyyy').format(planA.nextWateringDue),
          DateFormat('MMM dd, yyyy').format(planB.nextWateringDue),
          theme,
        ),
        
        _buildComparisonSection(
          'Status',
          _getStatusTextFromHistory(planA),
          _getStatusTextFromHistory(planB),
          theme,
        ),
        
        _buildComparisonSection(
          'Urgent Alerts',
          '${planA.urgentAlerts.length} alert${planA.urgentAlerts.length != 1 ? 's' : ''}',
          '${planB.urgentAlerts.length} alert${planB.urgentAlerts.length != 1 ? 's' : ''}',
          theme,
        ),
      ],
    );
  }

  Widget _buildComparisonSection(
    String title,
    String valueA,
    String valueB,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan A',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valueA,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan B',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        valueB,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No care plan history',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first care plan to see it here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<CarePlanHistory> _filterPlans(List<CarePlanHistory> plans) {
    var filtered = plans;
    
    if (_statusFilter != null) {
      // CarePlanHistory doesn't have status field, filter by isActive instead
      if (_statusFilter.toString().toLowerCase() == 'active') {
        filtered = filtered.where((plan) => plan.isActive).toList();
      } else {
        filtered = filtered.where((plan) => !plan.isActive).toList();
      }
    }
    
    if (_dateFilter != null) {
      filtered = filtered.where((plan) {
        return plan.createdAt.isAfter(_dateFilter!.start) &&
               plan.createdAt.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered.where((plan) {
        // Search by plant nickname or species name since CarePlanHistory doesn't have rationale
        return plan.plantNickname.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
               plan.speciesName.toLowerCase().contains(_searchQuery!.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Care Plans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status filter
            DropdownButtonFormField<String?>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...CarePlanStatus.values.map((status) => DropdownMenuItem(
                  value: status.name,
                  child: Text(_getStatusText(status.name)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _statusFilter = null;
                _dateFilter = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(CarePlanHistory plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Plan Details\n\nVersion: ${plan.version}\nCreated: ${DateFormat('MMM dd, yyyy').format(plan.createdAt)}\nActive: ${plan.isActive ? 'Yes' : 'No'}\nAlerts: ${plan.urgentAlerts.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  void _selectForComparison(CarePlanHistory plan) {
    setState(() {
      if (_selectedPlanForComparison == null) {
        _selectedPlanForComparison = plan;
      } else {
        _comparisonPlan = plan;
        _showComparison = true;
      }
    });
    _tabController.animateTo(0);
  }

  // Helper methods
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'acknowledged':
        return 'Acknowledged';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColorFromHistory(CarePlanHistory plan) {
    if (plan.isActive) {
      return Colors.green;
    } else if (plan.isAcknowledged) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusTextFromHistory(CarePlanHistory plan) {
    if (plan.isActive) {
      return 'Active';
    } else {
      return 'Inactive';
    }
  }


}