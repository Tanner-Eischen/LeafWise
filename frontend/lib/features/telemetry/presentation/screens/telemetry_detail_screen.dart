import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/telemetry_data_models.dart';
import '../../providers/telemetry_providers.dart';

/// Telemetry Detail Screen
/// 
/// Displays comprehensive information about a specific telemetry data entry
/// including light readings, growth photos, and associated metadata.
/// Follows the established detail screen pattern from PlantDetailScreen.
class TelemetryDetailScreen extends ConsumerStatefulWidget {
  final String telemetryId;
  
  const TelemetryDetailScreen({
    required this.telemetryId,
    super.key,
  });

  @override
  ConsumerState<TelemetryDetailScreen> createState() => _TelemetryDetailScreenState();
}

class _TelemetryDetailScreenState extends ConsumerState<TelemetryDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TelemetryData? _telemetryData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTelemetryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load telemetry data from provider
  Future<void> _loadTelemetryData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load telemetry data first
      await ref.read(telemetryNotifierProvider.notifier).loadTelemetryData(widget.telemetryId);
      
      final state = ref.read(telemetryNotifierProvider);
      if (state.telemetryData.isNotEmpty) {
        // Find the specific telemetry data by ID
        final telemetryData = state.telemetryData.firstWhere(
          (data) => data.id == widget.telemetryId,
          orElse: () => throw Exception('Telemetry data not found'),
        );
        
        setState(() {
          _telemetryData = telemetryData;
          _isLoading = false;
        });
      } else {
        throw Exception('No telemetry data available');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Telemetry Details'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Telemetry Details'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading telemetry data',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTelemetryData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _getTelemetryTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: _buildHeaderContent(theme),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
                    Tab(text: 'Data', icon: Icon(Icons.analytics)),
                    Tab(text: 'Metadata', icon: Icon(Icons.settings)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildDataTab(),
            _buildMetadataTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  /// Get appropriate title for the telemetry data
  String _getTelemetryTitle() {
    if (_telemetryData?.lightReading != null) {
      return 'Light Reading';
    } else if (_telemetryData?.growthPhoto != null) {
      return 'Growth Photo';
    } else {
      return 'Telemetry Data';
    }
  }

  /// Build header content with key information
  Widget _buildHeaderContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTelemetryIcon(),
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFormattedDate(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      _getSyncStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getSyncStatusColor(theme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build overview tab with summary information
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_telemetryData?.lightReading != null) _buildLightReadingCard(),
          if (_telemetryData?.growthPhoto != null) _buildGrowthPhotoCard(),
          const SizedBox(height: 16),
          _buildSyncStatusCard(),
          const SizedBox(height: 16),
          if (_telemetryData?.plantId != null) _buildPlantInfoCard(),
        ],
      ),
    );
  }

  /// Build data tab with detailed measurements
  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_telemetryData?.lightReading != null) _buildLightDataCard(),
          if (_telemetryData?.growthPhoto != null) _buildGrowthMetricsCard(),
          const SizedBox(height: 16),
          _buildLocationCard(),
        ],
      ),
    );
  }

  /// Build metadata tab with technical information
  Widget _buildMetadataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTechnicalInfoCard(),
          const SizedBox(height: 16),
          if (_telemetryData?.lightReading?.rawData != null ||
              _telemetryData?.growthPhoto?.confidenceScores != null)
            _buildRawDataCard(),
        ],
      ),
    );
  }

  /// Build light reading information card
  Widget _buildLightReadingCard() {
    final lightReading = _telemetryData!.lightReading!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Light Measurement',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Lux Value',
                    '${lightReading.luxValue.toStringAsFixed(1)} lx',
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                ),
                if (lightReading.ppfdValue != null)
                  Expanded(
                    child: _buildStatItem(
                      'PPFD',
                      '${lightReading.ppfdValue!.toStringAsFixed(1)} μmol/m²/s',
                      Icons.light_mode,
                      Colors.yellow,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.sensors, 'Source', _getLightSourceDisplayName(lightReading.source)),
            if (lightReading.locationName != null)
              _buildInfoRow(Icons.location_on, 'Location', lightReading.locationName!),
            _buildInfoRow(Icons.access_time, 'Measured At', _formatDateTime(lightReading.measuredAt)),
          ],
        ),
      ),
    );
  }

  /// Build growth photo information card
  Widget _buildGrowthPhotoCard() {
    final growthPhoto = _telemetryData!.growthPhoto!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Photo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (File(growthPhoto.filePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(growthPhoto.filePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.photo, 'File Path', growthPhoto.filePath),
            if (growthPhoto.fileSize != null)
              _buildInfoRow(Icons.storage, 'File Size', _formatFileSize(growthPhoto.fileSize!)),
            if (growthPhoto.imageWidth != null && growthPhoto.imageHeight != null)
              _buildInfoRow(Icons.aspect_ratio, 'Dimensions', '${growthPhoto.imageWidth} × ${growthPhoto.imageHeight}'),
            _buildInfoRow(Icons.access_time, 'Captured At', _formatDateTime(growthPhoto.capturedAt)),
            if (growthPhoto.isProcessed)
              _buildInfoRow(Icons.check_circle, 'Processing Status', 'Processed')
            else
              _buildInfoRow(Icons.pending, 'Processing Status', 'Pending'),
          ],
        ),
      ),
    );
  }

  /// Build light data detailed card
  Widget _buildLightDataCard() {
    final lightReading = _telemetryData!.lightReading!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Light Data Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.wb_sunny, 'Lux Value', '${lightReading.luxValue.toStringAsFixed(2)} lx'),
            if (lightReading.ppfdValue != null)
              _buildInfoRow(Icons.light_mode, 'PPFD Value', '${lightReading.ppfdValue!.toStringAsFixed(2)} μmol/m²/s'),
            if (lightReading.temperature != null)
              _buildInfoRow(Icons.thermostat, 'Temperature', '${lightReading.temperature!.toStringAsFixed(1)}°C'),
            if (lightReading.humidity != null)
              _buildInfoRow(Icons.water_drop, 'Humidity', '${lightReading.humidity!.toStringAsFixed(1)}%'),
            if (lightReading.altitude != null)
              _buildInfoRow(Icons.height, 'Altitude', '${lightReading.altitude!.toStringAsFixed(1)}m'),
            if (lightReading.deviceId != null)
              _buildInfoRow(Icons.device_hub, 'Device ID', lightReading.deviceId!),
            if (lightReading.calibrationProfileId != null)
              _buildInfoRow(Icons.tune, 'Calibration Profile', lightReading.calibrationProfileId!),
          ],
        ),
      ),
    );
  }

  /// Build growth metrics detailed card
  Widget _buildGrowthMetricsCard() {
    final growthPhoto = _telemetryData!.growthPhoto!;
    final metrics = growthPhoto.metrics;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Metrics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (metrics != null) ...[
              if (metrics.leafAreaCm2 != null)
                _buildInfoRow(Icons.eco, 'Leaf Area', '${metrics.leafAreaCm2!.toStringAsFixed(2)} cm²'),
              if (metrics.plantHeightCm != null)
                _buildInfoRow(Icons.height, 'Plant Height', '${metrics.plantHeightCm!.toStringAsFixed(2)} cm'),
              if (metrics.leafCount != null)
                _buildInfoRow(Icons.format_list_numbered, 'Leaf Count', '${metrics.leafCount}'),
              if (metrics.stemWidthMm != null)
                _buildInfoRow(Icons.straighten, 'Stem Width', '${metrics.stemWidthMm!.toStringAsFixed(2)} mm'),
              if (metrics.healthScore != null)
                _buildInfoRow(Icons.favorite, 'Health Score', '${(metrics.healthScore! * 100).toStringAsFixed(1)}%'),
              if (metrics.chlorophyllIndex != null)
                _buildInfoRow(Icons.grass, 'Chlorophyll Index', metrics.chlorophyllIndex!.toStringAsFixed(3)),
              if (metrics.diseaseIndicators.isNotEmpty)
                _buildInfoRow(Icons.warning, 'Disease Indicators', metrics.diseaseIndicators.join(', ')),
            ] else
              Text(
                'No metrics available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(height: 16),
            if (growthPhoto.analysisDurationMs != null)
              _buildInfoRow(Icons.timer, 'Analysis Duration', '${growthPhoto.analysisDurationMs}ms'),
            if (growthPhoto.processingVersion != null)
              _buildInfoRow(Icons.code, 'Processing Version', growthPhoto.processingVersion!),
          ],
        ),
      ),
    );
  }

  /// Build sync status card
  Widget _buildSyncStatusCard() {
    final theme = Theme.of(context);
    final syncStatus = _telemetryData?.syncStatus?.syncStatus ?? 
                     _telemetryData?.lightReading?.syncStatus ?? 
                     _telemetryData?.growthPhoto?.syncStatus ?? 
                     SyncStatus.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getSyncStatusIcon(syncStatus),
                  color: _getSyncStatusColor(theme),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSyncStatusText(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getSyncStatusDescription(syncStatus),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build location information card
  Widget _buildLocationCard() {
    final theme = Theme.of(context);
    final lightReading = _telemetryData?.lightReading;
    
    if (lightReading?.gpsLatitude == null && lightReading?.gpsLongitude == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (lightReading?.gpsLatitude != null)
              _buildInfoRow(Icons.my_location, 'Latitude', '${lightReading!.gpsLatitude!.toStringAsFixed(6)}°'),
            if (lightReading?.gpsLongitude != null)
              _buildInfoRow(Icons.my_location, 'Longitude', '${lightReading!.gpsLongitude!.toStringAsFixed(6)}°'),
            if (lightReading?.locationName != null)
              _buildInfoRow(Icons.location_on, 'Location Name', lightReading!.locationName!),
          ],
        ),
      ),
    );
  }

  /// Build plant information card
  Widget _buildPlantInfoCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.eco, 'Plant ID', _telemetryData!.plantId!),
            // TODO: Add plant name and other details when plant data is available
          ],
        ),
      ),
    );
  }

  /// Build technical information card
  Widget _buildTechnicalInfoCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_telemetryData?.id != null)
              _buildInfoRow(Icons.fingerprint, 'Telemetry ID', _telemetryData!.id!),
            _buildInfoRow(Icons.person, 'User ID', _telemetryData!.userId),
            if (_telemetryData?.lightReading?.clientTimestamp != null)
              _buildInfoRow(Icons.schedule, 'Client Timestamp', 
                _formatDateTime(_telemetryData!.lightReading!.clientTimestamp!)),
            if (_telemetryData?.growthPhoto?.clientTimestamp != null)
              _buildInfoRow(Icons.schedule, 'Client Timestamp', 
                _formatDateTime(_telemetryData!.growthPhoto!.clientTimestamp!)),
          ],
        ),
      ),
    );
  }

  /// Build raw data card
  Widget _buildRawDataCard() {
    final theme = Theme.of(context);
    final lightReading = _telemetryData?.lightReading;
    final growthPhoto = _telemetryData?.growthPhoto;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raw Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (lightReading?.rawData != null) ...[
              Text(
                'Light Reading Raw Data:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatJsonData(lightReading!.rawData!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (growthPhoto?.confidenceScores != null) ...[
              if (lightReading?.rawData != null) const SizedBox(height: 16),
              Text(
                'Confidence Scores:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatJsonData(growthPhoto!.confidenceScores!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build stat item widget
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build info row widget following the established pattern
  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: _showActionOptions,
      child: const Icon(Icons.more_vert),
    );
  }

  /// Show action options
  void _showActionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              onTap: () {
                Navigator.pop(context);
                _syncData();
              },
            ),
            if (_telemetryData?.growthPhoto != null)
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('View Full Image'),
                onTap: () {
                  Navigator.pop(context);
                  _viewFullImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  /// Get telemetry icon based on data type
  IconData _getTelemetryIcon() {
    if (_telemetryData?.lightReading != null) {
      return Icons.wb_sunny;
    } else if (_telemetryData?.growthPhoto != null) {
      return Icons.photo_camera;
    } else {
      return Icons.sensors;
    }
  }

  /// Get formatted date string
  String _getFormattedDate() {
    final date = _telemetryData?.lightReading?.measuredAt ?? 
                 _telemetryData?.growthPhoto?.capturedAt ?? 
                 DateTime.now();
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  /// Get sync status text
  String _getSyncStatusText() {
    final syncStatus = _telemetryData?.syncStatus?.syncStatus ?? 
                     _telemetryData?.lightReading?.syncStatus ?? 
                     _telemetryData?.growthPhoto?.syncStatus ?? 
                     SyncStatus.pending;
    
    switch (syncStatus) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending Sync';
      case SyncStatus.inProgress:
        return 'Syncing...';
      case SyncStatus.failed:
        return 'Sync Failed';
      case SyncStatus.conflict:
        return 'Sync Conflict';
      case SyncStatus.cancelled:
        return 'Sync Cancelled';
    }
  }

  /// Get sync status color
  Color _getSyncStatusColor(ThemeData theme) {
    final syncStatus = _telemetryData?.syncStatus?.syncStatus ?? 
                     _telemetryData?.lightReading?.syncStatus ?? 
                     _telemetryData?.growthPhoto?.syncStatus ?? 
                     SyncStatus.pending;
    
    switch (syncStatus) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.inProgress:
        return Colors.blue;
      case SyncStatus.failed:
        return theme.colorScheme.error;
      case SyncStatus.conflict:
        return Colors.red;
      case SyncStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Get sync status icon
  IconData _getSyncStatusIcon(SyncStatus syncStatus) {
    switch (syncStatus) {
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.pending:
        return Icons.cloud_upload;
      case SyncStatus.inProgress:
        return Icons.cloud_sync;
      case SyncStatus.failed:
        return Icons.cloud_off;
      case SyncStatus.conflict:
        return Icons.warning;
      case SyncStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get sync status description
  String _getSyncStatusDescription(SyncStatus syncStatus) {
    switch (syncStatus) {
      case SyncStatus.synced:
        return 'Data has been successfully synchronized';
      case SyncStatus.pending:
        return 'Waiting to be synchronized';
      case SyncStatus.inProgress:
        return 'Currently synchronizing data';
      case SyncStatus.failed:
        return 'Synchronization failed, will retry';
      case SyncStatus.conflict:
        return 'Conflict detected, manual resolution needed';
      case SyncStatus.cancelled:
        return 'Synchronization was cancelled';
    }
  }

  /// Get light source display name
  String _getLightSourceDisplayName(LightSource source) {
    switch (source) {
      case LightSource.camera:
        return 'Camera';
      case LightSource.als:
        return 'Ambient Light Sensor';
      case LightSource.ble:
        return 'Bluetooth Device';
      case LightSource.manual:
        return 'Manual Entry';
    }
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm:ss').format(dateTime);
  }

  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format JSON data for display
  String _formatJsonData(Map<String, dynamic> data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  // Action methods

  /// Share telemetry data
  void _shareData() {
    // TODO: Implement data sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  /// Sync telemetry data
  void _syncData() {
    // TODO: Implement manual sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual sync functionality coming soon!')),
    );
  }

  /// View full image
  void _viewFullImage() {
    if (_telemetryData?.growthPhoto?.filePath != null) {
      // TODO: Navigate to full image viewer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full image viewer coming soon!')),
      );
    }
  }
}

/// Custom sliver app bar delegate for persistent tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}