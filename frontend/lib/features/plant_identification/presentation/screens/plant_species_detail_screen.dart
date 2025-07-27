import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_care/models/plant_care_models.dart';
import 'package:plant_social/features/plant_identification/providers/plant_identification_provider.dart';
import 'package:plant_social/core/widgets/loading_widget.dart';
import 'package:plant_social/core/widgets/error_widget.dart';

class PlantSpeciesDetailScreen extends ConsumerStatefulWidget {
  final String speciesId;
  final String? speciesName;

  const PlantSpeciesDetailScreen({
    super.key,
    required this.speciesId,
    this.speciesName,
  });

  @override
  ConsumerState<PlantSpeciesDetailScreen> createState() =>
      _PlantSpeciesDetailScreenState();
}

class _PlantSpeciesDetailScreenState
    extends ConsumerState<PlantSpeciesDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Species details will be automatically loaded by the provider
  }

  @override
  Widget build(BuildContext context) {
    final speciesDetailAsync = ref.watch(plantSpeciesProvider(widget.speciesId));
    final theme = Theme.of(context);

    return Scaffold(
      body: speciesDetailAsync.when(
        data: (species) => _buildContent(species, theme),
        loading: () => _buildLoadingState(theme),
        error: (error, stackTrace) => _buildErrorState(error.toString(), theme),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speciesName ?? 'Plant Species'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: LoadingWidget()),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speciesName ?? 'Plant Species'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: CustomErrorWidget(
          message: error,
          onRetry: () {
              ref.invalidate(plantSpeciesProvider(widget.speciesId));
            },
        ),
      ),
    );
  }

  Widget _buildContent(PlantSpecies species, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              species.commonName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                species.imageUrl != null
                    ? Image.network(
                        species.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.primaryColor,
                            child: Icon(
                              Icons.eco,
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: theme.primaryColor,
                        child: Icon(
                          Icons.eco,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share species
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Add to favorites
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scientific name
                Text(
                  species.scientificName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                if (species.description != null)
                  Text(
                    'Description: ${species.description}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 24),

                // Description
                if (species.description != null) ...[
                  _buildSection(
                    'Description',
                    species.description!,
                    Icons.description,
                    theme,
                  ),
                  const SizedBox(height: 24),
                ],

                // Care information
                if (species.careInfo != null) ...[
                  _buildCareSection(species.careInfo!, theme),
                  const SizedBox(height: 24),
                ],

                // Alternative names
                if (species.alternativeNames != null && species.alternativeNames!.isNotEmpty) ...[
                  _buildAlternativeNamesSection(species.alternativeNames!, theme),
                  const SizedBox(height: 24),
                ],

                // Native regions
                if (species.nativeRegions != null && species.nativeRegions!.isNotEmpty) ...[
                  _buildNativeRegionsSection(species.nativeRegions!, theme),
                  const SizedBox(height: 24),
                ],

                // Growth characteristics
                _buildGrowthCharacteristics(species, theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, IconData icon, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildCareSection(PlantCareInfo careInfo, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.spa,
              size: 24,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Care Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCareGrid(careInfo, theme),
      ],
    );
  }

  Widget _buildCareGrid(PlantCareInfo careInfo, ThemeData theme) {
    final careItems = [
      _CareItem(Icons.wb_sunny, 'Light', careInfo.lightRequirement),
      _CareItem(Icons.water_drop, 'Water', careInfo.waterFrequency),
      _CareItem(Icons.trending_up, 'Care Level', careInfo.careLevel),
      if (careInfo.humidity != null)
        _CareItem(Icons.opacity, 'Humidity', careInfo.humidity!),
      if (careInfo.temperature != null)
        _CareItem(Icons.thermostat, 'Temperature', careInfo.temperature!),
      if (careInfo.toxicity != null)
        _CareItem(Icons.warning, 'Toxicity', careInfo.toxicity!),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: careItems.length,
      itemBuilder: (context, index) {
        final item = careItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      item.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativeNamesSection(List<String> names, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.label,
              size: 24,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Also known as',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: names.map((name) {
            return Chip(
              label: Text(
                name,
                style: theme.textTheme.bodyMedium,
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNativeRegionsSection(List<String> regions, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.public,
              size: 24,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Native Regions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: regions.map((region) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Text(
                region,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGrowthCharacteristics(PlantSpecies species, ThemeData theme) {
    final characteristics = <String>[];
    
    characteristics.add('Scientific Name: ${species.scientificName}');
    
    if (species.family != null) {
      characteristics.add('Family: ${species.family}');
    }
    
    if (species.alternativeNames != null && species.alternativeNames!.isNotEmpty) {
      characteristics.add('Alternative Names: ${species.alternativeNames!.join(', ')}');
    }
    
    if (species.maxHeight != null) {
      characteristics.add('Max Height: ${species.maxHeight}');
    }
    
    if (species.bloomTime != null) {
      characteristics.add('Bloom Time: ${species.bloomTime}');
    }
    
    if (species.plantType != null) {
      characteristics.add('Plant Type: ${species.plantType}');
    }

    if (characteristics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.nature,
              size: 24,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Growth Characteristics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...characteristics.map((characteristic) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    characteristic,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CareItem {
  final IconData icon;
  final String label;
  final String value;

  _CareItem(this.icon, this.label, this.value);
}