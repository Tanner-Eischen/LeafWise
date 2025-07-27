import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_identification/models/plant_identification_models.dart';
import 'package:plant_social/features/plant_identification/providers/plant_identification_provider.dart';
import 'package:plant_social/features/plant_identification/presentation/screens/plant_species_detail_screen.dart';
import 'package:plant_social/core/widgets/loading_widget.dart';
import 'package:plant_social/core/widgets/error_widget.dart';

class PlantSearchScreen extends ConsumerStatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  ConsumerState<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends ConsumerState<PlantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plantIdentificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Plants'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildSearchBar(theme),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search for plants...',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          suffixIcon: _currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _currentQuery = '';
                    });
                    ref.read(plantIdentificationProvider.notifier).clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _currentQuery = query;
          });
          if (query.trim().isNotEmpty) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == query && query.trim().isNotEmpty) {
                ref.read(plantIdentificationProvider.notifier).searchPlants(query);
              }
            });
          } else {
            ref.read(plantIdentificationProvider.notifier).clearSearch();
          }
        },
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            ref.read(plantIdentificationProvider.notifier).searchPlants(query);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(PlantIdentificationState state, ThemeData theme) {
    if (_currentQuery.isEmpty) {
      return _buildEmptyState(theme);
    }

    if (state.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            if (_currentQuery.isNotEmpty) {
              ref.read(plantIdentificationProvider.notifier).searchPlants(_currentQuery);
            }
          },
        ),
      );
    }

    if (state.identifications.isEmpty) {
      return _buildNoResultsState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.identifications.length,
      itemBuilder: (context, index) {
        final species = state.identifications[index];
        return _buildSearchResultItem(species, theme);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for Plants',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a plant name to start searching',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSearchSuggestions(theme),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    final suggestions = [
      'Rose',
      'Monstera',
      'Fiddle Leaf Fig',
      'Snake Plant',
      'Pothos',
      'Peace Lily',
    ];

    return Column(
      children: [
        Text(
          'Popular searches:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                setState(() {
                  _currentQuery = suggestion;
                });
                ref.read(plantIdentificationProvider.notifier).searchPlants(suggestion);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No plants found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _currentQuery = '';
              });
              ref.read(plantIdentificationProvider.notifier).clearSearch();
              _searchFocusNode.requestFocus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(PlantIdentification species, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantSpeciesDetailScreen(
                speciesId: species.id,
                speciesName: species.commonName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Plant image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: species.imageUrl != null
                      ? Image.network(
                          species.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.eco,
                              color: Colors.grey[400],
                              size: 30,
                            );
                          },
                        )
                      : Icon(
                          Icons.eco,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Plant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.commonName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species.scientificName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scientific: ${species.scientificName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}