/// Telemetry History Screen for displaying and managing telemetry data.
/// 
/// This screen provides comprehensive telemetry data management with filtering,
/// sorting, infinite scrolling, and bulk operations. It displays both light
/// readings and growth photos in a tabbed interface with advanced data management.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leafwise/core/widgets/breadcrumb_navigation.dart';
import 'package:leafwise/features/telemetry/models/telemetry_data_models.dart';
import 'package:leafwise/features/telemetry/providers/telemetry_providers.dart';
import 'package:leafwise/features/telemetry/widgets/telemetry_data_tile.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_detail_screen.dart';
import 'package:leafwise/core/widgets/custom_search_bar.dart';

class TelemetryHistoryScreen extends ConsumerStatefulWidget {
  const TelemetryHistoryScreen({super.key});

  @override
  ConsumerState<TelemetryHistoryScreen> createState() => _TelemetryHistoryScreenState();
}

class _TelemetryHistoryScreenState extends ConsumerState<TelemetryHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Selection state for bulk operations
  final Set<String> _selectedItems = <String>{};
  bool _isSelectionMode = false;
  
  // Filter and sort state
  TelemetryDataFilter _activeFilter = TelemetryDataFilter.all;
  String _sortBy = 'date_desc';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTelemetryData(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Handle infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(telemetryNotifierProvider);
      if (!state.isLoadingData && state.hasMoreData) {
        _loadTelemetryData();
      }
    }
  }

  /// Load telemetry data with current filters
  Future<void> _loadTelemetryData({bool refresh = false}) async {
    final notifier = ref.read(telemetryNotifierProvider.notifier);
    
    if (refresh) {
      await notifier.loadTelemetryData(
        filter: _activeFilter,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        sortBy: _sortBy,
        refresh: true,
      );
    } else {
      await notifier.loadMoreTelemetryData(
        filter: _activeFilter,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        sortBy: _sortBy,
      );
    }
  }

  /// Handle search input changes
  void _onSearchChanged(String value) {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _loadTelemetryData(refresh: true);
      }
    });
  }

  /// Handle search submission
  void _onSearchSubmitted(String value) {
    _loadTelemetryData(refresh: true);
  }

  /// Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  /// Toggle item selection
  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  /// Select all visible items
  void _selectAllItems(List<TelemetryData> items) {
    setState(() {
      _selectedItems.addAll(items.map((item) => item.id));
    });
  }

  /// Clear all selections
  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  /// Handle bulk delete operation
  Future<void> _handleBulkDelete() async {
    if (_selectedItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Items'),
        content: Text('Are you sure you want to delete ${_selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(telemetryNotifierProvider.notifier);
      await notifier.bulkDeleteTelemetryData(_selectedItems.toList());
      _clearSelection();
      _toggleSelectionMode();
    }
  }

  /// Handle bulk sync operation
  Future<void> _handleBulkSync() async {
    if (_selectedItems.isEmpty) return;

    final notifier = ref.read(telemetryNotifierProvider.notifier);
    await notifier.bulkSyncTelemetryData(_selectedItems.toList());
    _clearSelection();
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Telemetry Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter by sync status
            DropdownButtonFormField<TelemetryDataFilter>(
              value: _activeFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
              items: TelemetryDataFilter.values.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(_getFilterDisplayName(filter)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _activeFilter = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Sort options
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'date_desc', child: Text('Newest First')),
                DropdownMenuItem(value: 'date_asc', child: Text('Oldest First')),
                DropdownMenuItem(value: 'sync_status', child: Text('Sync Status')),
                DropdownMenuItem(value: 'type', child: Text('Data Type')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _activeFilter = TelemetryDataFilter.all;
                _sortBy = 'date_desc';
              });
              Navigator.of(context).pop();
              _loadTelemetryData(refresh: true);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadTelemetryData(refresh: true);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// Get display name for filter
  String _getFilterDisplayName(TelemetryDataFilter filter) {
    switch (filter) {
      case TelemetryDataFilter.all:
        return 'All Data';
      case TelemetryDataFilter.synced:
        return 'Synced';
      case TelemetryDataFilter.pending:
        return 'Pending Sync';
      case TelemetryDataFilter.failed:
        return 'Failed Sync';
      case TelemetryDataFilter.conflicts:
        return 'Conflicts';
      case TelemetryDataFilter.offlineOnly:
        return 'Offline Only';
      case TelemetryDataFilter.today:
        return 'Today';
      case TelemetryDataFilter.thisWeek:
        return 'This Week';
      case TelemetryDataFilter.thisMonth:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final telemetryState = ref.watch(telemetryNotifierProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();
    
    final breadcrumbs = BreadcrumbHelper.generateTelemetryBreadcrumbs(currentRoute);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text('${_selectedItems.length} selected')
            : const Text('Telemetry History'),
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                onPressed: _toggleSelectionMode,
                icon: const Icon(Icons.close),
              )
            : null,
        actions: _isSelectionMode
            ? [
                if (_selectedItems.isNotEmpty) ...[
                  IconButton(
                    onPressed: _handleBulkSync,
                    icon: const Icon(Icons.sync),
                    tooltip: 'Sync Selected',
                  ),
                  IconButton(
                    onPressed: _handleBulkDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Selected',
                  ),
                ],
              ]
            : [
                IconButton(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                  tooltip: 'Filters',
                ),
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: const Icon(Icons.checklist),
                  tooltip: 'Select Items',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'refresh':
                        _loadTelemetryData(refresh: true);
                        break;
                      case 'sync_all':
                        ref.read(telemetryNotifierProvider.notifier).syncAllPendingData();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'sync_all',
                      child: Row(
                        children: [
                          Icon(Icons.cloud_upload),
                          SizedBox(width: 8),
                          Text('Sync All'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Light Readings', icon: Icon(Icons.wb_sunny)),
            Tab(text: 'Growth Photos', icon: Icon(Icons.photo_camera)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Breadcrumb Navigation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: BreadcrumbNavigation(items: breadcrumbs),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search telemetry data...',
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Filter chips (when filters are shown)
          if (_showFilters) _buildFilterChips(theme),

          // Selection toolbar
          if (_isSelectionMode && _selectedItems.isNotEmpty)
            _buildSelectionToolbar(theme),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLightReadingsList(telemetryState),
                _buildGrowthPhotosList(telemetryState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters:',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: _showFilterDialog,
                child: const Text('More Filters'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(_getFilterDisplayName(_activeFilter)),
                selected: _activeFilter != TelemetryDataFilter.all,
                onSelected: (_) => _showFilterDialog(),
              ),
              FilterChip(
                label: Text(_getSortDisplayName(_sortBy)),
                selected: _sortBy != 'date_desc',
                onSelected: (_) => _showFilterDialog(),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Get sort display name
  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'date_desc':
        return 'Newest First';
      case 'date_asc':
        return 'Oldest First';
      case 'sync_status':
        return 'By Sync Status';
      case 'type':
        return 'By Type';
      default:
        return 'Sort';
    }
  }

  /// Build selection toolbar
  Widget _buildSelectionToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              final telemetryState = ref.read(telemetryNotifierProvider);
              _selectAllItems(telemetryState.filteredTelemetryData);
            },
            icon: const Icon(Icons.select_all),
            label: const Text('Select All'),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          ),
          const Spacer(),
          Text(
            '${_selectedItems.length} selected',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build light readings list
  Widget _buildLightReadingsList(TelemetryState state) {
    final lightReadings = state.filteredTelemetryData
        .where((data) => data is LightReadingData)
        .cast<LightReadingData>()
        .toList();

    if (state.isLoadingData && lightReadings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lightReadings.isEmpty) {
      return _buildEmptyState('No light readings found', Icons.wb_sunny);
    }

    return RefreshIndicator(
      onRefresh: () => _loadTelemetryData(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: lightReadings.length + (state.isLoadingData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= lightReadings.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final reading = lightReadings[index];
          final isSelected = _selectedItems.contains(reading.id);

          return TelemetryDataTile(
            data: reading,
            displayMode: TelemetryTileDisplayMode.full,
            isSelected: _isSelectionMode ? isSelected : null,
            onTap: _isSelectionMode
                ? () => _toggleItemSelection(reading.id)
                : () => _navigateToDetail(reading),
            onLongPress: _isSelectionMode ? null : () {
              _toggleSelectionMode();
              _toggleItemSelection(reading.id);
            },
          );
        },
      ),
    );
  }

  /// Build growth photos list
  Widget _buildGrowthPhotosList(TelemetryState state) {
    final growthPhotos = state.filteredTelemetryData
        .where((data) => data is GrowthPhotoData)
        .cast<GrowthPhotoData>()
        .toList();

    if (state.isLoadingData && growthPhotos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (growthPhotos.isEmpty) {
      return _buildEmptyState('No growth photos found', Icons.photo_camera);
    }

    return RefreshIndicator(
      onRefresh: () => _loadTelemetryData(refresh: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: growthPhotos.length + (state.isLoadingData ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= growthPhotos.length) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final photo = growthPhotos[index];
          final isSelected = _selectedItems.contains(photo.id);

          return TelemetryDataTile(
            data: photo,
            displayMode: TelemetryTileDisplayMode.compact,
            isSelected: _isSelectionMode ? isSelected : null,
            onTap: _isSelectionMode
                ? () => _toggleItemSelection(photo.id)
                : () => _navigateToDetail(photo),
            onLongPress: _isSelectionMode ? null : () {
              _toggleSelectionMode();
              _toggleItemSelection(photo.id);
            },
          );
        },
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create new telemetry data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Navigate to telemetry detail screen
  void _navigateToDetail(TelemetryData data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TelemetryDetailScreen(telemetryData: data),
      ),
    );
  }
}