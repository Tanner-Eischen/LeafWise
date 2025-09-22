/// Telemetry Data Display Tile
/// 
/// Reusable tile component for displaying telemetry data with sync status indicators,
/// compact/full display modes, and interactive elements. Follows existing tile patterns
/// and design conventions from the codebase.
/// 
/// Features:
/// - Sync status indicators with color-coded chips
/// - Compact and full display modes
/// - Interactive elements (tap, delete, retry sync)
/// - Consistent styling with existing tile components
/// - Support for different telemetry data types
library telemetry_data_tile;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Feature imports
import '../models/telemetry_data_models.dart';

/// Display mode for the telemetry data tile
enum TelemetryTileDisplayMode {
  /// Compact mode showing minimal information
  compact,
  /// Full mode showing detailed information
  full,
}

/// Base class for telemetry data that can be displayed in tiles
abstract class TelemetryTileData {
  String get id;
  DateTime get createdAt;
  SyncStatus get syncStatus;
}

/// Extension to make existing models compatible with tile display
extension LightReadingTileData on LightReadingData {
  String get tileId => id ?? '';
  DateTime get tileCreatedAt => measuredAt;
  SyncStatus get tileSyncStatus => syncStatus;
}

extension GrowthPhotoTileData on GrowthPhotoData {
  String get tileId => id ?? '';
  DateTime get tileCreatedAt => capturedAt;
  SyncStatus get tileSyncStatus => syncStatus;
}

/// Telemetry data tile widget for consistent display across screens
class TelemetryDataTile extends StatelessWidget {
  /// The light reading data to display
  final LightReadingData? lightData;
  
  /// The growth photo data to display
  final GrowthPhotoData? photoData;
  
  /// Display mode (compact or full)
  final TelemetryTileDisplayMode displayMode;
  
  /// Callback when tile is tapped
  final VoidCallback? onTap;
  
  /// Callback when delete action is triggered
  final VoidCallback? onDelete;
  
  /// Callback when retry sync is triggered
  final VoidCallback? onRetrySync;
  
  /// Whether to show action buttons
  final bool showActions;
  
  /// Whether the tile is selectable
  final bool isSelectable;
  
  /// Whether the tile is currently selected
  final bool isSelected;

  const TelemetryDataTile({
    super.key,
    this.lightData,
    this.photoData,
    this.displayMode = TelemetryTileDisplayMode.compact,
    this.onTap,
    this.onDelete,
    this.onRetrySync,
    this.showActions = true,
    this.isSelectable = false,
    this.isSelected = false,
  }) : assert(lightData != null || photoData != null, 'Either lightData or photoData must be provided');

  /// Get the current data item (light or photo)
  dynamic get _currentData => lightData ?? photoData;
  
  /// Get the current sync status
  SyncStatus get _syncStatus => lightData?.syncStatus ?? photoData?.syncStatus ?? SyncStatus.pending;
  
  /// Get the creation timestamp
  DateTime get _createdAt => lightData?.measuredAt ?? photoData?.capturedAt ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
          ? BorderSide(color: theme.colorScheme.primary, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: displayMode == TelemetryTileDisplayMode.compact
              ? _buildCompactLayout(context, theme)
              : _buildFullLayout(context, theme),
        ),
      ),
    );
  }

  /// Build compact layout for the tile
  Widget _buildCompactLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Data type icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getDataTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDataTypeIcon(),
            color: _getDataTypeColor(),
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Main content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getDataTypeTitle(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSyncStatusChip(context, theme),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getCompactSubtitle(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Timestamp and actions
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                _formatTimeAgo(_createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (showActions) ...[
              const SizedBox(height: 8),
              _buildActionButtons(context, theme, compact: true),
            ],
          ],
        ),
      ],
    );
  }

  /// Build full layout for the tile
  Widget _buildFullLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon, title, and sync status
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getDataTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDataTypeIcon(),
                color: _getDataTypeColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDataTypeTitle(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(_createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            _buildSyncStatusChip(context, theme),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Data details
        _buildDataDetails(context, theme),
        
        if (showActions) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context, theme, compact: false),
        ],
      ],
    );
  }

  /// Build sync status chip
  Widget _buildSyncStatusChip(BuildContext context, ThemeData theme) {
    switch (_syncStatus) {
      case SyncStatus.synced:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_done, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Synced',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
      case SyncStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_upload, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Pending',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
      case SyncStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Syncing',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
      case SyncStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Failed',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
      case SyncStatus.conflict:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Conflict',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
      case SyncStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Cancelled',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        );
    }
  }

  /// Build data-specific details section
  Widget _buildDataDetails(BuildContext context, ThemeData theme) {
    if (lightData != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Light Measurement',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  context,
                  theme,
                  'LUX',
                  '${lightData!.luxValue.toStringAsFixed(1)}',
                ),
                if (lightData!.ppfdValue != null)
                  _buildDetailItem(
                    context,
                    theme,
                    'PPFD',
                    '${lightData!.ppfdValue!.toStringAsFixed(1)} μmol/m²/s',
                  ),
              ],
            ),
            if (lightData!.locationName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lightData!.locationName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    } else if (photoData != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Growth Photo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  context,
                  theme,
                  'Status',
                  photoData!.isProcessed ? 'Processed' : 'Processing',
                ),
                if (photoData!.plantId != null)
                  _buildDetailItem(
                    context,
                    theme,
                    'Plant ID',
                    photoData!.plantId!,
                  ),
              ],
            ),
            if (photoData!.notes != null && photoData!.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                photoData!.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    }

    // Generic telemetry data display
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Telemetry Data',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail item widget
  Widget _buildDetailItem(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme, {
    required bool compact,
  }) {
    final buttons = <Widget>[];

    // Retry sync button for failed sync
    if (_syncStatus == SyncStatus.failed && onRetrySync != null) {
      buttons.add(
        compact
            ? IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: onRetrySync,
                tooltip: 'Retry Sync',
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              )
            : TextButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                onPressed: onRetrySync,
              ),
      );
    }

    // Delete button
    if (onDelete != null) {
      buttons.add(
        compact
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                onPressed: onDelete,
                tooltip: 'Delete',
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              )
            : TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return compact
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: buttons,
          )
        : Wrap(
            spacing: 8,
            children: buttons,
          );
  }

  /// Get data type color based on telemetry data type
  Color _getDataTypeColor() {
    if (lightData != null) {
      return Colors.orange;
    } else if (photoData != null) {
      return Colors.green;
    }
    return Colors.blue;
  }

  /// Get data type icon based on telemetry data type
  IconData _getDataTypeIcon() {
    if (lightData != null) {
      return Icons.wb_sunny;
    } else if (photoData != null) {
      return Icons.camera_alt;
    }
    return Icons.analytics;
  }

  /// Get data type title based on telemetry data type
  String _getDataTypeTitle() {
    if (lightData != null) {
      return 'Light Reading';
    } else if (photoData != null) {
      return 'Growth Photo';
    }
    return 'Telemetry Data';
  }

  /// Get compact subtitle text
  String _getCompactSubtitle() {
    if (lightData != null) {
      return '${lightData!.luxValue.toStringAsFixed(1)} LUX';
    } else if (photoData != null) {
      return photoData!.isProcessed ? 'Processed' : 'Processing...';
    }
    return 'Telemetry measurement';
  }

  /// Format time ago string
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}