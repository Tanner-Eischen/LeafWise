// Model Management Widget
// This widget allows users to manage AI models for offline plant identification

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_plant_identification_models.dart';
import '../../providers/enhanced_plant_identification_provider.dart';

/// Widget for managing AI models used in offline plant identification
class ModelManagementWidget extends ConsumerWidget {
  const ModelManagementWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Model
        _buildSectionTitle(context, 'Current Model'),
        _buildCurrentModel(context, offlineState.currentModel),
        const SizedBox(height: 24),
        
        // Available Models
        _buildSectionTitle(context, 'Available Models'),
        _buildAvailableModels(context, ref),
        const SizedBox(height: 24),
        
        // Model Management Actions
        _buildActions(context, ref),
      ],
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildCurrentModel(BuildContext context, ModelInfo? model) {
    if (model == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No model currently loaded',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.model_training, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  model.metadata['name'] as String? ?? 'Unknown Model',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildModelDetailRow(context, 'Version', model.version),
            _buildModelDetailRow(context, 'Size', _formatSize(model.sizeInBytes)),
            _buildModelDetailRow(
              context, 
              'Accuracy', 
              '${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%',
            ),
            _buildModelDetailRow(
              context, 
              'Downloaded', 
              _formatDate(model.downloadedAt),
            ),
            _buildModelDetailRow(
              context, 
              'Last Used', 
              'Never', // ModelInfo doesn't track lastUsedAt
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModelDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildAvailableModels(BuildContext context, WidgetRef ref) {
    // TODO: Implement fetching available models from server
    // This is placeholder data for demonstration
    final availableModels = [
      _createSampleModel(
        'Standard Plant Model', 
        '1.2.0', 
        15 * 1024 * 1024, 
        0.82,
        isDownloaded: false,
      ),
      _createSampleModel(
        'Enhanced Plant Model', 
        '2.0.1', 
        45 * 1024 * 1024, 
        0.94,
        isDownloaded: false,
      ),
      _createSampleModel(
        'Specialized Garden Model', 
        '1.0.5', 
        22 * 1024 * 1024, 
        0.88,
        isDownloaded: false,
      ),
    ];
    
    return Column(
      children: availableModels.map((model) => _buildModelCard(context, ref, model)).toList(),
    );
  }
  
  Widget _buildModelCard(BuildContext context, WidgetRef ref, ModelInfo model) {
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(
          Icons.model_training,
          color: Colors.green,
        ),
        title: Text(model.metadata['name'] as String? ?? 'Unknown Model'),
        subtitle: Text(
          'Version: ${model.version} • Size: ${_formatSize(model.sizeInBytes)} • ' 
          'Accuracy: ${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%',
        ),
        trailing: TextButton.icon(
          onPressed: () {
            // TODO: Implement model activation
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Activate'),
        ),
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Model Management'),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement check for updates
              },
              icon: const Icon(Icons.update),
              label: const Text('Check for Updates'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement model cleanup
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Clean Up Models'),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  ModelInfo _createSampleModel(String name, String version, int size, double accuracy, {bool isDownloaded = false}) {
    return ModelInfo(
      modelId: name.toLowerCase().replaceAll(' ', '_'),
      version: version,
      sizeInBytes: size,
      downloadedAt: isDownloaded ? DateTime.now().subtract(const Duration(days: 5)) : DateTime.now(),
      metadata: {
        'name': name,
        'accuracy': accuracy,
      },
    );
  }
}