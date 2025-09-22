/// Telemetry Data Tile Demo Screen
/// 
/// Demo screen for testing and showcasing the TelemetryDataTile widget
/// with various data types and sync statuses. This screen demonstrates
/// both compact and full display modes with interactive elements.
/// 
/// Features:
/// - Sample light reading and growth photo data
/// - Different sync status examples
/// - Both compact and full display modes
/// - Interactive tile actions
library telemetry_tile_demo_screen;

import 'package:flutter/material.dart';

// Feature imports
import '../models/telemetry_data_models.dart';
import '../widgets/telemetry_data_tile.dart';

/// Demo screen for telemetry data tiles
class TelemetryTileDemoScreen extends StatefulWidget {
  const TelemetryTileDemoScreen({super.key});

  @override
  State<TelemetryTileDemoScreen> createState() => _TelemetryTileDemoScreenState();
}

class _TelemetryTileDemoScreenState extends State<TelemetryTileDemoScreen> {
  TelemetryTileDisplayMode _displayMode = TelemetryTileDisplayMode.compact;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry Data Tiles'),
        actions: [
          IconButton(
            icon: Icon(_displayMode == TelemetryTileDisplayMode.compact 
                ? Icons.view_list 
                : Icons.view_compact),
            onPressed: () {
              setState(() {
                _displayMode = _displayMode == TelemetryTileDisplayMode.compact
                    ? TelemetryTileDisplayMode.full
                    : TelemetryTileDisplayMode.compact;
              });
            },
            tooltip: _displayMode == TelemetryTileDisplayMode.compact 
                ? 'Switch to Full View' 
                : 'Switch to Compact View',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Display Mode: ${_displayMode == TelemetryTileDisplayMode.compact ? 'Compact' : 'Full'}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Light Reading Tiles
            Text(
              'Light Reading Data',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            
            // Synced light reading
            TelemetryDataTile(
              lightData: _createSampleLightReading(SyncStatus.synced),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Light Reading - Synced'),
              onDelete: () => _showDeleteDialog('Light Reading'),
            ),
            const SizedBox(height: 8),
            
            // Pending light reading
            TelemetryDataTile(
              lightData: _createSampleLightReading(SyncStatus.pending),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Light Reading - Pending'),
              onDelete: () => _showDeleteDialog('Light Reading'),
            ),
            const SizedBox(height: 8),
            
            // Syncing light reading
            TelemetryDataTile(
              lightData: _createSampleLightReading(SyncStatus.inProgress),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Light Reading - Syncing'),
              onDelete: () => _showDeleteDialog('Light Reading'),
            ),
            const SizedBox(height: 8),
            
            // Failed light reading
            TelemetryDataTile(
              lightData: _createSampleLightReading(SyncStatus.failed),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Light Reading - Failed'),
              onDelete: () => _showDeleteDialog('Light Reading'),
              onRetrySync: () => _showRetryDialog('Light Reading'),
            ),
            
            const SizedBox(height: 24),
            
            // Growth Photo Tiles
            Text(
              'Growth Photo Data',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            
            // Processed growth photo
            TelemetryDataTile(
              photoData: _createSampleGrowthPhoto(SyncStatus.synced, isProcessed: true),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Growth Photo - Processed'),
              onDelete: () => _showDeleteDialog('Growth Photo'),
            ),
            const SizedBox(height: 8),
            
            // Processing growth photo
            TelemetryDataTile(
              photoData: _createSampleGrowthPhoto(SyncStatus.pending, isProcessed: false),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Growth Photo - Processing'),
              onDelete: () => _showDeleteDialog('Growth Photo'),
            ),
            const SizedBox(height: 8),
            
            // Failed growth photo
            TelemetryDataTile(
              photoData: _createSampleGrowthPhoto(SyncStatus.failed, isProcessed: false),
              displayMode: _displayMode,
              onTap: () => _showTileInfo('Growth Photo - Failed'),
              onDelete: () => _showDeleteDialog('Growth Photo'),
              onRetrySync: () => _showRetryDialog('Growth Photo'),
            ),
            
            const SizedBox(height: 24),
            
            // Interactive Examples
            Text(
              'Interactive Examples',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Selectable tile
            TelemetryDataTile(
              lightData: _createSampleLightReading(SyncStatus.synced),
              displayMode: _displayMode,
              isSelectable: true,
              isSelected: true,
              onTap: () => _showTileInfo('Selectable Light Reading'),
              showActions: false,
            ),
            const SizedBox(height: 8),
            
            // Tile without actions
            TelemetryDataTile(
              photoData: _createSampleGrowthPhoto(SyncStatus.synced, isProcessed: true),
              displayMode: _displayMode,
              showActions: false,
              onTap: () => _showTileInfo('Growth Photo - No Actions'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Create sample light reading data
  LightReadingData _createSampleLightReading(SyncStatus syncStatus) {
    final now = DateTime.now();
    return LightReadingData(
      id: 'light_${syncStatus.name}_${now.millisecondsSinceEpoch}',
      userId: 'demo_user',
      plantId: 'plant_001',
      luxValue: 1250.5 + (syncStatus.index * 100),
      ppfdValue: 45.2 + (syncStatus.index * 5),
      source: LightSource.camera,
      locationName: 'Living Room Window',
      gpsLatitude: 37.7749,
      gpsLongitude: -122.4194,
      temperature: 22.5,
      humidity: 65.0,
      measuredAt: now.subtract(Duration(hours: syncStatus.index + 1)),
      syncStatus: syncStatus,
      offlineCreated: syncStatus != SyncStatus.synced,
      clientTimestamp: now,
      createdAt: now.subtract(Duration(hours: syncStatus.index + 1)),
      updatedAt: now,
    );
  }
  
  /// Create sample growth photo data
  GrowthPhotoData _createSampleGrowthPhoto(SyncStatus syncStatus, {required bool isProcessed}) {
    final now = DateTime.now();
    return GrowthPhotoData(
      id: 'photo_${syncStatus.name}_${now.millisecondsSinceEpoch}',
      userId: 'demo_user',
      plantId: 'plant_001',
      filePath: '/storage/photos/growth_${now.millisecondsSinceEpoch}.jpg',
      fileSize: 2048576,
      imageWidth: 1920,
      imageHeight: 1080,
      isProcessed: isProcessed,
      notes: isProcessed ? 'Healthy growth observed' : 'Processing analysis...',
      locationName: 'Garden Bed A',
      ambientLightLux: 800.0,
      capturedAt: now.subtract(Duration(days: syncStatus.index + 1)),
      processedAt: isProcessed ? now.subtract(Duration(hours: syncStatus.index)) : null,
      syncStatus: syncStatus,
      offlineCreated: syncStatus != SyncStatus.synced,
      clientTimestamp: now,
      createdAt: now.subtract(Duration(days: syncStatus.index + 1)),
      updatedAt: now,
      metrics: isProcessed ? const GrowthMetrics(
        leafAreaCm2: 45.2,
        plantHeightCm: 12.5,
        leafCount: 8,
        stemWidthMm: 3.2,
        healthScore: 0.85,
        chlorophyllIndex: 0.72,
      ) : null,
    );
  }
  
  /// Show tile info dialog
  void _showTileInfo(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tile Tapped'),
        content: Text('You tapped on: $title'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show delete confirmation dialog
  void _showDeleteDialog(String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Data'),
        content: Text('Are you sure you want to delete this $dataType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$dataType deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  /// Show retry sync dialog
  void _showRetryDialog(String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retry Sync'),
        content: Text('Retry syncing this $dataType to the server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Retrying sync for $dataType...')),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}