// Offline Mode Screen
// This screen allows users to manage offline mode settings and view local identifications

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_plant_identification_models.dart';
import '../../providers/enhanced_plant_identification_provider.dart';
import '../widgets/model_management_widget.dart';
import '../widgets/offline_mode_status_widget.dart';

/// Screen for managing offline mode settings and viewing local identifications
class OfflineModeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  
  const OfflineModeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends ConsumerState<OfflineModeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(enhancedPlantIdentificationStateProvider.notifier).loadLocalIdentifications();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'AI Models'),
            Tab(text: 'Local Identifications'),
          ],
        ),
      ),
      body: offlineState.error != null
          ? _buildErrorWidget(context, offlineState.error!)
          : TabBarView(
              controller: _tabController,
              children: [
                // Status Tab
                const SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OfflineModeStatusWidget(),
                    ],
                  ),
                ),
                
                // AI Models Tab
                const SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ModelManagementWidget(),
                    ],
                  ),
                ),
                
                // Local Identifications Tab
                _buildContent(context, ref, offlineState),
              ],
            ),
    );
  }
  
  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Clear error
              Consumer(
                builder: (context, ref, _) {
                  ref.read(enhancedPlantIdentificationStateProvider.notifier).clearError();
                  return const SizedBox.shrink();
                },
              );
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, WidgetRef ref, OfflinePlantIdentificationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Identifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildLocalIdentificationsList(context, ref, state.localIdentifications),
        ],
      ),
    );
  }
  
  Widget _buildLocalIdentificationsList(
    BuildContext context,
    WidgetRef ref,
    List<LocalPlantIdentification> identifications,
  ) {
    if (identifications.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No local identifications yet.'),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: identifications.length,
      itemBuilder: (context, index) {
        final identification = identifications[index];
        return _buildIdentificationCard(context, ref, identification);
      },
    );
  }
  
  Widget _buildIdentificationCard(
    BuildContext context,
    WidgetRef ref,
    LocalPlantIdentification identification,
  ) {
    final theme = Theme.of(context);
    
    // Determine sync status icon and color
    IconData syncIcon = Icons.cloud_upload;
    Color syncColor = Colors.orange;
    String syncText = 'Pending';
    
    identification.syncStatus.when(
      synced: () {
        syncIcon = Icons.cloud_done;
        syncColor = Colors.green;
        syncText = 'Synced';
      },
      notSynced: () {
        syncIcon = Icons.cloud_upload;
        syncColor = Colors.orange;
        syncText = 'Pending';
      },
      syncing: () {
        syncIcon = Icons.sync;
        syncColor = Colors.blue;
        syncText = 'Syncing';
      },
      failed: (error) {
        syncIcon = Icons.cloud_off;
        syncColor = Colors.red;
        syncText = 'Failed';
      },
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to details
          // TODO: Implement navigation to details screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.file(
                File(identification.localImagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name
                  Text(
                    identification.scientificName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    identification.commonName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and confidence
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Identified on ${_formatDate(identification.identifiedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Confidence: ${(identification.confidence * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sync status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(syncIcon, color: syncColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            syncText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: syncColor,
                            ),
                          ),
                        ],
                      ),
                      
                      // Sync button
                      identification.syncStatus.maybeWhen(
                        synced: () => const SizedBox.shrink(),
                        orElse: () => TextButton.icon(
                          icon: const Icon(Icons.sync, size: 16),
                          label: const Text('Sync'),
                          onPressed: () {
                            ref.read(enhancedPlantIdentificationStateProvider.notifier).syncIdentification(identification.localId);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}