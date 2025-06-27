import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_community/models/plant_community_models.dart';
import 'package:plant_social/features/plant_community/providers/plant_community_provider.dart';
import 'package:plant_social/features/plant_community/presentation/widgets/trade_card.dart';
import 'package:plant_social/core/theme/app_theme.dart';
import 'package:plant_social/core/widgets/custom_search_bar.dart';

class PlantTradesScreen extends ConsumerStatefulWidget {
  const PlantTradesScreen({super.key});

  @override
  ConsumerState<PlantTradesScreen> createState() => _PlantTradesScreenState();
}

class _PlantTradesScreenState extends ConsumerState<PlantTradesScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  String? _selectedTradeType;
  String? _selectedSort = SortOption.newest;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial trades
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantCommunityProvider.notifier).loadTrades(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(plantCommunityProvider);
      if (!state.isLoading && state.hasMoreTrades) {
        ref.read(plantCommunityProvider.notifier).loadTrades(
          tradeType: _selectedTradeType,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          sortBy: _selectedSort,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(plantCommunityProvider);
    final trades = ref.watch(tradesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Trades'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
          ),
          IconButton(
            onPressed: _navigateToCreateTrade,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search plants to trade...',
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Filters
          if (_showFilters) _buildFilters(theme),

          // Trades list
          Expanded(
            child: _buildTradesList(trades, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrade,
        child: const Icon(Icons.add),
        tooltip: 'Create Trade',
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trade types
          Text(
            'Trade Types',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TradeType.all.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTradeTypeChip(
                    'All',
                    _selectedTradeType == null,
                    () => _selectTradeType(null),
                  );
                }
                
                final tradeType = TradeType.all[index - 1];
                return _buildTradeTypeChip(
                  TradeType.getDisplayName(tradeType),
                  _selectedTradeType == tradeType,
                  () => _selectTradeType(tradeType),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sort options
          Row(
            children: [
              Text(
                'Sort by:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: SortOption.tradeSortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(SortOption.getDisplayName(option)),
                    );
                  }).toList(),
                  onChanged: _selectSort,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTypeChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: theme.primaryColor.withOpacity(0.2),
        checkmarkColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? theme.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTradesList(
    List<PlantTrade> trades,
    PlantCommunityState state,
  ) {
    if (state.isLoading && trades.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load trades',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshTrades,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No trades available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create a trade!',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToCreateTrade,
              child: const Text('Create Trade'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTrades,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: trades.length + (state.hasMoreTrades ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= trades.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final trade = trades[index];
          return TradeCard(
            trade: trade,
            onTap: () => _navigateToTradeDetail(trade),
            onBookmark: () => _bookmarkTrade(trade.id),
            onInterest: () => _expressInterest(trade.id),
          );
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    // Implement debounced search if needed
  }

  void _onSearchSubmitted(String value) {
    _refreshTrades();
  }

  void _selectTradeType(String? tradeType) {
    setState(() {
      _selectedTradeType = tradeType;
    });
    _refreshTrades();
  }

  void _selectSort(String? sortBy) {
    setState(() {
      _selectedSort = sortBy;
    });
    _refreshTrades();
  }

  Future<void> _refreshTrades() async {
    await ref.read(plantCommunityProvider.notifier).loadTrades(
      refresh: true,
      tradeType: _selectedTradeType,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      sortBy: _selectedSort,
    );
  }

  void _bookmarkTrade(String tradeId) {
    ref.read(plantCommunityProvider.notifier).bookmarkTrade(tradeId);
  }

  void _expressInterest(String tradeId) {
    ref.read(plantCommunityProvider.notifier).expressInterestInTrade(tradeId);
  }

  void _navigateToCreateTrade() {
    Navigator.pushNamed(
      context,
      '/create-trade',
    ).then((result) {
      if (result == true) {
        _refreshTrades();
      }
    });
  }

  void _navigateToTradeDetail(PlantTrade trade) {
    Navigator.pushNamed(
      context,
      '/trade-detail',
      arguments: trade.id,
    );
  }
}