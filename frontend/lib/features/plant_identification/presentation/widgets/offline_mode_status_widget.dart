// Offline Mode Status Widget
// This widget displays the current offline mode status including connectivity and model information

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_plant_identification_models.dart';
import '../../providers/enhanced_plant_identification_provider.dart';

/// Widget that displays the current offline mode status
class OfflineModeStatusWidget extends ConsumerWidget {
  const OfflineModeStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connectivity Status
        _buildSectionTitle(context, 'Connectivity Status'),
        _buildConnectivityStatus(context, offlineState.connectivityStatus),
        const SizedBox(height: 24),
        
        // Model Status
        _buildSectionTitle(context, 'AI Model Status'),
        _buildModelStatus(context, offlineState.currentModel),
        const SizedBox(height: 24),
        
        // Sync Status
        _buildSectionTitle(context, 'Synchronization'),
        _buildSyncStatus(context, offlineState),
        const SizedBox(height: 24),
        
        // Actions
        _buildActions(context, ref, offlineState),
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
  
  Widget _buildConnectivityStatus(BuildContext context, ConnectivityStatus? status) {
    if (status == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.signal_wifi_statusbar_null),
          title: Text('Unknown'),
          subtitle: Text('Connectivity status is being determined...'),
        ),
      );
    }
    
    return status.when(
      offline: () => const Card(
        child: ListTile(
          leading: Icon(Icons.signal_wifi_off, color: Colors.red),
          title: Text('Offline'),
          subtitle: Text('No internet connection available'),
          trailing: Icon(Icons.warning, color: Colors.orange),
        ),
      ),
      mobile: () => const Card(
        child: ListTile(
          leading: Icon(Icons.signal_cellular_alt, color: Colors.green),
          title: Text('Mobile Data'),
          subtitle: Text('Connected via mobile network'),
        ),
      ),
      wifi: () => const Card(
        child: ListTile(
          leading: Icon(Icons.wifi, color: Colors.green),
          title: Text('WiFi'),
          subtitle: Text('Connected via WiFi network'),
        ),
      ),
    );
  }
  
  Widget _buildModelStatus(BuildContext context, ModelInfo? model) {
    if (model == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.model_training, color: Colors.grey),
          title: Text('No Model Loaded'),
          subtitle: Text('Download a model to enable offline identification'),
        ),
      );
    }
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.model_training, color: Colors.green),
        title: Text(model.metadata['name'] as String? ?? 'Unknown Model'),
        subtitle: Text(
          'Version: ${model.version} • Size: ${_formatSize(model.sizeInBytes)} • ' 
          'Accuracy: ${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%',
        ),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
  
  Widget _buildSyncStatus(BuildContext context, OfflinePlantIdentificationState state) {
    final pendingCount = state.localIdentifications
        .where((id) => id.syncStatus.maybeWhen(
          notSynced: () => true,
          orElse: () => false,
        ))
        .length;
    
    final failedCount = state.localIdentifications
        .where((id) => id.syncStatus.maybeWhen(
          failed: (_) => true,
          orElse: () => false,
        ))
        .length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pendingCount > 0 ? Icons.sync_problem : Icons.sync,
                  color: pendingCount > 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total identifications: ${state.localIdentifications.length}'),
            Text('Pending sync: $pendingCount'),
            if (failedCount > 0)
              Text(
                'Failed sync: $failedCount',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, WidgetRef ref, OfflinePlantIdentificationState state) {
    final isOffline = state.connectivityStatus?.maybeWhen(
      offline: () => true,
      orElse: () => false,
    ) ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Actions'),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement check connectivity
              },
              icon: const Icon(Icons.network_check),
              label: const Text('Check Connectivity'),
            ),
            ElevatedButton.icon(
              onPressed: isOffline
                  ? null
                  : () {
                      // TODO: Implement sync all
                    },
              icon: const Icon(Icons.sync),
              label: const Text('Sync All Identifications'),
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
}