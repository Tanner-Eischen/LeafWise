import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/features/plant_identification/models/plant_identification_models.dart';
import 'package:plant_social/features/plant_identification/providers/plant_identification_provider.dart';
import 'package:plant_social/core/widgets/loading_widget.dart';
import 'package:plant_social/core/widgets/error_widget.dart';

class PlantIdentificationHistoryScreen extends ConsumerStatefulWidget {
  const PlantIdentificationHistoryScreen({super.key});

  @override
  ConsumerState<PlantIdentificationHistoryScreen> createState() =>
      _PlantIdentificationHistoryScreenState();
}

class _PlantIdentificationHistoryScreenState
    extends ConsumerState<PlantIdentificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantIdentificationProvider.notifier).loadIdentificationHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plantIdentificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification History'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(plantIdentificationProvider.notifier).loadIdentificationHistory();
            },
          ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(PlantIdentificationState state, ThemeData theme) {
    if (state.isLoading && state.history.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (state.error != null && state.history.isEmpty) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            ref.read(plantIdentificationProvider.notifier).loadIdentificationHistory();
          },
        ),
      );
    }

    if (state.history.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(plantIdentificationProvider.notifier).loadIdentificationHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.history.length,
        itemBuilder: (context, index) {
          final identification = state.history[index];
          return _buildHistoryItem(identification, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            'No identifications yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start identifying plants to see your history here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Identify a Plant'),
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

  Widget _buildHistoryItem(PlantIdentification identification, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showIdentificationDetails(identification);
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
                  child: identification.imageUrl != null
                      ? Image.network(
                          identification.imageUrl,
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
                      identification.commonName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      identification.scientificName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildConfidenceBadge(identification.confidence, theme),
                        const Spacer(),
                        Text(
                          _formatDate(identification.identifiedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Widget _buildConfidenceBadge(double confidence, ThemeData theme) {
    Color badgeColor;
    String badgeText;

    if (confidence >= 0.8) {
      badgeColor = Colors.green;
      badgeText = 'High';
    } else if (confidence >= 0.6) {
      badgeColor = Colors.orange;
      badgeText = 'Medium';
    } else {
      badgeColor = Colors.red;
      badgeText = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        '$badgeText (${(confidence * 100).toInt()}%)',
        style: theme.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showIdentificationDetails(PlantIdentification identification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          identification.commonName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          identification.scientificName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          identification.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.eco,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confidence
                    _buildDetailSection(
                      'Confidence',
                      '${(identification.confidence * 100).toInt()}%',
                      Icons.verified,
                    ),

                    // Date
                    _buildDetailSection(
                      'Identified',
                      _formatDate(identification.identifiedAt),
                      Icons.schedule,
                    ),

                    // Care info
                    ...[
                    const SizedBox(height: 16),
                    Text(
                      'Care Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailSection(
                      'Light',
                      identification.careInfo.lightRequirement,
                      Icons.wb_sunny,
                    ),
                    _buildDetailSection(
                      'Water',
                      identification.careInfo.waterFrequency,
                      Icons.water_drop,
                    ),
                    _buildDetailSection(
                      'Care Level',
                      identification.careInfo.careLevel,
                      Icons.trending_up,
                    ),
                  ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}