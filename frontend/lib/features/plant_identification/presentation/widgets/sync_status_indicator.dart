// Sync Status Indicator Widget
// This widget displays synchronization status with animations for sync in progress

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_plant_identification_models.dart';

/// Widget that displays synchronization status with visual feedback
class SyncStatusIndicator extends ConsumerWidget {
  final SyncStatus syncStatus;
  final VoidCallback? onTap;
  final bool showLabel;
  final double size;

  const SyncStatusIndicator({
    super.key,
    required this.syncStatus,
    this.onTap,
    this.showLabel = true,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 12 : 8,
          vertical: showLabel ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(showLabel ? 20 : 12),
          border: Border.all(
            color: _getBackgroundColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the appropriate icon based on sync status
  Widget _buildIcon() {
    return syncStatus.when(
      synced: () => Icon(
        Icons.cloud_done,
        color: _getIconColor(),
        size: size * 0.8,
      ),
      notSynced: () => Icon(
        Icons.cloud_upload,
        color: _getIconColor(),
        size: size * 0.8,
      ),
      syncing: () => SizedBox(
        width: size * 0.8,
        height: size * 0.8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
        ),
      ),
      failed: (error) => Icon(
        Icons.cloud_off,
        color: _getIconColor(),
        size: size * 0.8,
      ),
    );
  }

  /// Get status text based on sync status
  String _getStatusText() {
    return syncStatus.when(
      synced: () => 'Synced',
      notSynced: () => 'Pending',
      syncing: () => 'Syncing...',
      failed: (error) => 'Failed',
    );
  }

  /// Get background color based on sync status
  Color _getBackgroundColor() {
    return syncStatus.when(
      synced: () => Colors.green,
      notSynced: () => Colors.orange,
      syncing: () => Colors.blue,
      failed: (error) => Colors.red,
    );
  }

  /// Get icon color based on sync status
  Color _getIconColor() {
    return syncStatus.when(
      synced: () => Colors.green,
      notSynced: () => Colors.orange,
      syncing: () => Colors.blue,
      failed: (error) => Colors.red,
    );
  }

  /// Get text color based on sync status
  Color _getTextColor() {
    return syncStatus.when(
      synced: () => Colors.green[700]!,
      notSynced: () => Colors.orange[700]!,
      syncing: () => Colors.blue[700]!,
      failed: (error) => Colors.red[700]!,
    );
  }
}

/// Animated sync status indicator with pulsing animation for syncing state
class AnimatedSyncStatusIndicator extends ConsumerStatefulWidget {
  final SyncStatus syncStatus;
  final VoidCallback? onTap;
  final bool showLabel;
  final double size;

  const AnimatedSyncStatusIndicator({
    super.key,
    required this.syncStatus,
    this.onTap,
    this.showLabel = true,
    this.size = 24.0,
  });

  @override
  ConsumerState<AnimatedSyncStatusIndicator> createState() =>
      _AnimatedSyncStatusIndicatorState();
}

class _AnimatedSyncStatusIndicatorState
    extends ConsumerState<AnimatedSyncStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for syncing state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for syncing state
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _updateAnimations();
  }

  @override
  void didUpdateWidget(AnimatedSyncStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncStatus != widget.syncStatus) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    widget.syncStatus.when(
      synced: () {
        _pulseController.stop();
        _rotationController.stop();
      },
      notSynced: () {
        _pulseController.stop();
        _rotationController.stop();
      },
      syncing: () {
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
      },
      failed: (error) {
        _pulseController.stop();
        _rotationController.stop();
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.syncStatus.when(
      synced: () => SyncStatusIndicator(
        syncStatus: widget.syncStatus,
        onTap: widget.onTap,
        showLabel: widget.showLabel,
        size: widget.size,
      ),
      notSynced: () => SyncStatusIndicator(
        syncStatus: widget.syncStatus,
        onTap: widget.onTap,
        showLabel: widget.showLabel,
        size: widget.size,
      ),
      syncing: () => AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: SyncStatusIndicator(
                syncStatus: widget.syncStatus,
                onTap: widget.onTap,
                showLabel: widget.showLabel,
                size: widget.size,
              ),
            ),
          );
        },
      ),
      failed: (error) => SyncStatusIndicator(
        syncStatus: widget.syncStatus,
        onTap: widget.onTap,
        showLabel: widget.showLabel,
        size: widget.size,
      ),
    );
  }
}

/// Compact sync status indicator for use in lists or small spaces
class CompactSyncStatusIndicator extends ConsumerWidget {
  final SyncStatus syncStatus;
  final VoidCallback? onTap;

  const CompactSyncStatusIndicator({
    super.key,
    required this.syncStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SyncStatusIndicator(
      syncStatus: syncStatus,
      onTap: onTap,
      showLabel: false,
      size: 16.0,
    );
  }
}

/// Sync status indicator with tooltip showing detailed information
class DetailedSyncStatusIndicator extends ConsumerWidget {
  final SyncStatus syncStatus;
  final VoidCallback? onTap;
  final String? additionalInfo;

  const DetailedSyncStatusIndicator({
    super.key,
    required this.syncStatus,
    this.onTap,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: _getTooltipMessage(),
      child: SyncStatusIndicator(
        syncStatus: syncStatus,
        onTap: onTap,
        showLabel: true,
        size: 20.0,
      ),
    );
  }

  String _getTooltipMessage() {
    final baseMessage = syncStatus.when(
      synced: () => 'Successfully synchronized with server',
      notSynced: () => 'Waiting to be synchronized',
      syncing: () => 'Synchronizing with server...',
      failed: (error) => 'Synchronization failed: $error',
    );

    if (additionalInfo != null) {
      return '$baseMessage\n$additionalInfo';
    }

    return baseMessage;
  }
}