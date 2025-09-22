// Model Management Screen
// This screen allows users to view model status and manage AI model updates for offline identification

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_plant_identification_models.dart';
import '../../providers/enhanced_plant_identification_provider.dart';

/// Screen for managing AI models used in offline plant identification
class ModelManagementScreen extends ConsumerStatefulWidget {
  const ModelManagementScreen({super.key});

  @override
  ConsumerState<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends ConsumerState<ModelManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load model information when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(enhancedPlantIdentificationStateProvider.notifier).loadAvailableModels();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Model Management'),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(enhancedPlantIdentificationStateProvider.notifier).loadAvailableModels();
            },
            tooltip: 'Refresh models',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.model_training),
              text: 'Current Model',
            ),
            Tab(
              icon: Icon(Icons.cloud_download),
              text: 'Available Models',
            ),
            Tab(
              icon: Icon(Icons.storage),
              text: 'Storage',
            ),
          ],
        ),
      ),
      body: offlineState.error != null
          ? _buildErrorView(context, offlineState.error!)
          : TabBarView(
              controller: _tabController,
              children: [
                // Current Model Tab
                _buildCurrentModelTab(context, offlineState),
                
                // Available Models Tab
                _buildAvailableModelsTab(context, offlineState),
                
                // Storage Tab
                _buildStorageTab(context, offlineState),
              ],
            ),
    );
  }

  /// Build current model tab
  Widget _buildCurrentModelTab(BuildContext context, OfflinePlantIdentificationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current model status
          _buildSectionTitle(context, 'Current Model'),
          _buildCurrentModelCard(context, state.currentModel),
          const SizedBox(height: 24),
          
          // Model performance metrics
          if (state.currentModel != null) ...[
            _buildSectionTitle(context, 'Performance Metrics'),
            _buildPerformanceMetrics(context, state.currentModel!),
            const SizedBox(height: 24),
          ],
          
          // Model actions
          _buildSectionTitle(context, 'Actions'),
          _buildModelActions(context, state),
        ],
      ),
    );
  }

  /// Build available models tab
  Widget _buildAvailableModelsTab(BuildContext context, OfflinePlantIdentificationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Available Models'),
          const SizedBox(height: 8),
          Text(
            'Download models to enable offline plant identification',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Available models list
          _buildAvailableModelsList(context),
        ],
      ),
    );
  }

  /// Build storage tab
  Widget _buildStorageTab(BuildContext context, OfflinePlantIdentificationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Storage Usage'),
          _buildStorageUsage(context, state),
          const SizedBox(height: 24),
          
          _buildSectionTitle(context, 'Storage Management'),
          _buildStorageActions(context),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build current model card
  Widget _buildCurrentModelCard(BuildContext context, ModelInfo? model) {
    final theme = Theme.of(context);
    
    if (model == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.model_training,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Model Installed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Download a model to enable offline plant identification',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1); // Switch to Available Models tab
                },
                icon: const Icon(Icons.download),
                label: const Text('Browse Models'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.model_training,
                  color: theme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.metadata['name'] as String? ?? 'Unknown Model',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${model.version}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Model details
            _buildModelDetailRow('Size', _formatBytes(model.sizeInBytes)),
            _buildModelDetailRow('Accuracy', '${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%'),
            _buildModelDetailRow('Downloaded', _formatDate(model.downloadedAt)),
            if (model.metadata['lastUsedAt'] != null)
              _buildModelDetailRow('Last Used', _formatDate(DateTime.parse(model.metadata['lastUsedAt'] as String))),
          ],
        ),
      ),
    );
  }

  /// Build model detail row
  Widget _buildModelDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Build performance metrics
  Widget _buildPerformanceMetrics(BuildContext context, ModelInfo model) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetricItem('Accuracy', '${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%', Icons.psychology),
            const Divider(),
            _buildMetricItem('Speed', '~2.5s avg', Icons.speed),
            const Divider(),
            _buildMetricItem('Capabilities', model.capabilities.join(', '), Icons.category),
          ],
        ),
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build model actions
  Widget _buildModelActions(BuildContext context, OfflinePlantIdentificationState state) {
    return Column(
      children: [
        if (state.currentModel != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Model'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showRemoveModelDialog(context);
              },
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Check for Updates'),
            subtitle: const Text('Look for newer model versions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement update check
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checking for updates...')),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build available models list
  Widget _buildAvailableModelsList(BuildContext context) {
    // TODO: This should come from a service
    final availableModels = [
      _createSampleModelInfo('Standard Plant Model', '1.2.0', 15 * 1024 * 1024, 0.82),
      _createSampleModelInfo('Enhanced Plant Model', '2.0.1', 45 * 1024 * 1024, 0.94),
      _createSampleModelInfo('Specialized Garden Model', '1.0.5', 22 * 1024 * 1024, 0.88),
    ];

    return Column(
      children: availableModels.map((model) => _buildAvailableModelCard(context, model)).toList(),
    );
  }

  /// Build available model card
  Widget _buildAvailableModelCard(BuildContext context, ModelInfo model) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.model_training, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.metadata['name'] as String? ?? 'Unknown Model',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${model.version} • ${_formatBytes(model.sizeInBytes)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Model description
            Text(
              'Accuracy: ${((model.metadata['accuracy'] as double? ?? 0.0) * 100).toStringAsFixed(1)}% • Capabilities: ${model.capabilities.join(", ")}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Download button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDownloadDialog(context, model);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Model'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build storage usage
  Widget _buildStorageUsage(BuildContext context, OfflinePlantIdentificationState state) {
    final totalUsed = state.currentModel?.sizeInBytes ?? 0;
    const totalAvailable = 1024 * 1024 * 1024; // 1GB example
    final usagePercentage = totalUsed / totalAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Models Storage'),
                Text('${_formatBytes(totalUsed)} / ${_formatBytes(totalAvailable)}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: usagePercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercentage > 0.8 ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(usagePercentage * 100).toStringAsFixed(1)}% used',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Build storage actions
  Widget _buildStorageActions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove temporary files'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Manage Downloads'),
            subtitle: const Text('View and manage downloaded models'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to downloads management
            },
          ),
        ),
      ],
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Error Loading Models',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(enhancedPlantIdentificationStateProvider.notifier).loadAvailableModels();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show download dialog
  void _showDownloadDialog(BuildContext context, ModelInfo model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Download ${model.metadata['name'] as String? ?? 'Unknown Model'}?'),
            const SizedBox(height: 8),
            Text(
              'Size: ${_formatBytes(model.sizeInBytes)}\nThis will enable offline plant identification.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement model download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${model.metadata['name'] as String? ?? 'Unknown Model'}...')),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  /// Show remove model dialog
  void _showRemoveModelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Model'),
        content: const Text(
          'Are you sure you want to remove the current model? This will disable offline plant identification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement model removal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Model removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Show clear cache dialog
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove temporary files and free up storage space. Your downloaded models will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Create sample model info for demonstration
  ModelInfo _createSampleModelInfo(String name, String version, int size, double accuracy) {
    return ModelInfo(
      modelId: name.toLowerCase().replaceAll(' ', '_'),
      version: version,
      downloadedAt: DateTime.now().subtract(const Duration(days: 5)),
      sizeInBytes: size,
      capabilities: ['houseplants', 'garden_plants', 'trees'],
      metadata: {
        'name': name,
        'accuracy': accuracy,
        'framework': 'TensorFlow Lite',
      },
    );
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format date to human readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}