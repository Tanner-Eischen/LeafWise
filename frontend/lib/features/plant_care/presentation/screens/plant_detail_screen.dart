/// Plant Detail Screen
///
/// Displays comprehensive plant information including overview, care log, reminders,
/// and telemetry data. Provides quick actions for plant management and navigation
/// to detailed views. Follows established screen patterns with tab-based navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/plant_models.dart';
import '../../../../core/providers/plant_provider.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/color_utils.dart';

// Telemetry imports
import '../../../telemetry/providers/telemetry_providers.dart';
import '../../../telemetry/models/telemetry_data_models.dart';

import 'package:leafwise/features/plant_care/models/plant_care_models.dart' as plant_care;
import 'package:leafwise/features/plant_care/providers/plant_care_provider.dart';
import 'package:leafwise/features/plant_care/presentation/widgets/care_reminder_card.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  plant_care.UserPlant? _plant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPlantDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantDetails() async {
    try {
      final plant = await ref
          .read(plantCareServiceProvider)
          .getUserPlant(widget.plantId);

      setState(() {
        _plant = plant;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plant Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plant Details')),
        body: const Center(child: Text('Plant not found')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(theme),
        ],
        body: Column(
          children: [
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildCareLogTab(),
                  _buildRemindersTab(),
                  _buildTelemetryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _plant!.nickname,
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
            _plant!.imageUrl != null
                ? Image.network(
                    _plant!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder(theme);
                    },
                  )
                : _buildImagePlaceholder(theme),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showPlantOptions,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.eco,
        size: 80,
        color: theme.primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: theme.primaryColor,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Care Log'),
          Tab(text: 'Reminders'),
          Tab(text: 'Telemetry'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant info card
          _buildInfoCard(),
          const SizedBox(height: 16),

          // Species info card
          if (_plant!.species != null) _buildSpeciesCard(),
          const SizedBox(height: 16),

          // Care statistics
          _buildCareStatsCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
            _buildInfoRow(Icons.pets, 'Nickname', _plant!.nickname),
            if (_plant!.location != null)
              _buildInfoRow(Icons.location_on, 'Location', _plant!.location!),
            _buildInfoRow(
              Icons.calendar_today,
              'Acquired',
              _formatDate(_plant!.acquiredDate),
            ),
            _buildInfoRow(
              Icons.schedule,
              'Days with you',
              '${DateTime.now().difference(_plant!.acquiredDate).inDays} days',
            ),
            if (_plant!.notes != null && _plant!.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_plant!.notes!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesCard() {
    final theme = Theme.of(context);
    final species = _plant!.species!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Species Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.eco, 'Common Name', species.commonName),
            _buildInfoRow(
              Icons.science,
              'Scientific Name',
              species.scientificName,
            ),
            if (species.family != null)
              _buildInfoRow(Icons.category, 'Family', species.family!),
            if (species.description != null &&
                species.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Description',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(species.description!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCareStatsCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Care Logs',
                    '${_plant!.careLogs?.length ?? 0}',
                    Icons.history,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active Reminders',
                    '${_plant!.reminders?.where((r) => r.isActive).length ?? 0}',
                    Icons.notifications,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_plant!.careLogs != null && _plant!.careLogs!.isNotEmpty)
              _buildInfoRow(
                Icons.water_drop,
                'Last Watered',
                _getLastCareDate('watering') ?? 'Never',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildCareLogTab() {
    if (_plant!.careLogs == null || _plant!.careLogs!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No care logs yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start logging your plant care activities',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedLogs = List<plant_care.PlantCareLog>.from(_plant!.careLogs!)
      ..sort((a, b) => b.careDate.compareTo(a.careDate));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLogs.length,
      itemBuilder: (context, index) {
        final log = sortedLogs[index];
        return _buildCareLogCard(log);
      },
    );
  }

  Widget _buildCareLogCard(plant_care.PlantCareLog log) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCareTypeColor(log.careType).withOpacity(0.1),
          child: Icon(
            _getCareTypeIcon(log.careType),
            color: _getCareTypeColor(log.careType),
          ),
        ),
        title: Text(_getCareTypeDisplayName(log.careType)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(log.careDate)),
            if (log.notes != null && log.notes!.isNotEmpty)
              Text(
                log.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        isThreeLine: log.notes != null && log.notes!.isNotEmpty,
      ),
    );
  }

  Widget _buildRemindersTab() {
    if (_plant!.reminders == null || _plant!.reminders!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reminders set',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Set up care reminders to never forget',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plant!.reminders!.length,
      itemBuilder: (context, index) {
        final reminder = _plant!.reminders![index];
        return CareReminderCard(
          reminder: reminder,
          onTap: () => _editReminder(reminder),
          onComplete: () => _completeReminder(reminder),
          onSnooze: () => _snoozeReminder(reminder),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: _showAddCareOptions,
      child: const Icon(Icons.add),
    );
  }

  void _showPlantOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Plant'),
              onTap: () {
                Navigator.pop(context);
                _editPlant();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Update Photo'),
              onTap: () {
                Navigator.pop(context);
                _updatePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Plant',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePlant();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Log Care Activity'),
              onTap: () {
                Navigator.pop(context);
                _addCareLog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Add Reminder'),
              onTap: () {
                Navigator.pop(context);
                _addReminder();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _getLastCareDate(String careType) {
    if (_plant!.careLogs == null || _plant!.careLogs!.isEmpty) return null;

    final logs =
        _plant!.careLogs!
            .where(
              (log) => log.careType.toLowerCase() == careType.toLowerCase(),
            )
            .toList()
          ..sort((a, b) => b.careDate.compareTo(a.careDate));

    if (logs.isEmpty) return null;

    return _formatDate(logs.first.careDate);
  }

  IconData _getCareTypeIcon(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.eco;
      case 'pruning':
        return Icons.content_cut;
      case 'repotting':
        return Icons.grass;
      default:
        return Icons.schedule;
    }
  }

  Color _getCareTypeColor(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return Colors.blue;
      case 'fertilizing':
        return Colors.green;
      case 'pruning':
        return Colors.orange;
      case 'repotting':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getCareTypeDisplayName(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return 'Watering';
      case 'fertilizing':
        return 'Fertilizing';
      case 'pruning':
        return 'Pruning';
      case 'repotting':
        return 'Repotting';
      default:
        return careType;
    }
  }

  // Action methods (to be implemented)
  void _editPlant() {
    // TODO: Navigate to edit plant screen
  }

  void _updatePhoto() {
    // TODO: Implement photo update
  }

  void _deletePlant() {
    // TODO: Implement plant deletion with confirmation
  }

  void _addCareLog() {
    // TODO: Navigate to add care log screen
  }

  void _addReminder() {
    // TODO: Navigate to add reminder screen
  }

  void _editReminder(plant_care.PlantCareReminder reminder) {
    // TODO: Navigate to edit reminder screen
  }

  void _completeReminder(plant_care.PlantCareReminder reminder) {
    // TODO: Mark reminder as completed and log care activity
  }

  void _snoozeReminder(plant_care.PlantCareReminder reminder) {
    // TODO: Snooze reminder for a specified duration
  }

  /// Build telemetry tab with recent data and quick actions
  Widget _buildTelemetryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final telemetryDataAsync = ref.watch(
          telemetryDataByPlantProvider(widget.plantId),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent telemetry data preview
              _buildRecentTelemetryCard(telemetryDataAsync),
              const SizedBox(height: 16),

              // Quick action buttons
              _buildTelemetryQuickActions(),
              const SizedBox(height: 16),

              // Navigation to full history
              _buildTelemetryHistoryCard(),
            ],
          ),
        );
      },
    );
  }

  /// Build recent telemetry data card
  Widget _buildRecentTelemetryCard(
    AsyncValue<List<TelemetryData>> telemetryDataAsync,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recent Telemetry Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            telemetryDataAsync.when(
              data: (telemetryData) {
                if (telemetryData.isEmpty) {
                  return _buildEmptyTelemetryState();
                }

                // Show the 3 most recent entries
                final recentData = telemetryData.take(3).toList();
                return Column(
                  children: recentData
                      .map((data) => _buildTelemetryDataItem(data))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading telemetry data: $error',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual telemetry data item
  Widget _buildTelemetryDataItem(TelemetryData data) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          // Data type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              data.lightReading != null ? Icons.wb_sunny : Icons.photo_camera,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Data details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.lightReading != null
                      ? 'Light Reading: ${data.lightReading!.luxValue.toStringAsFixed(0)} lux'
                      : 'Growth Photo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelativeTime(data.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Sync status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getSyncStatusColor(
                data.syncStatus?.syncStatus ?? SyncStatus.pending,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getSyncStatusText(
                data.syncStatus?.syncStatus ?? SyncStatus.pending,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getSyncStatusColor(
                  data.syncStatus?.syncStatus ?? SyncStatus.pending,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty telemetry state
  Widget _buildEmptyTelemetryState() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off,
            size: 48,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No telemetry data yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start collecting light readings and growth photos to track your plant\'s progress.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build telemetry quick actions
  Widget _buildTelemetryQuickActions() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.wb_sunny,
                    label: 'Light Meter',
                    onTap: () => _navigateToLightMeter(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.photo_camera,
                    label: 'Growth Tracker',
                    onTap: () => _navigateToGrowthTracker(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build telemetry history navigation card
  Widget _buildTelemetryHistoryCard() {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _navigateToTelemetryHistory(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.history, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Full History',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See all telemetry data, trends, and analytics',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to light meter screen
  void _navigateToLightMeter() {
    // TODO: Navigate to light meter screen with plant context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Light meter feature coming soon')),
    );
  }

  /// Navigate to growth tracker screen
  void _navigateToGrowthTracker() {
    // TODO: Navigate to growth tracker screen with plant context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Growth tracker feature coming soon')),
    );
  }

  /// Navigate to telemetry history screen
  void _navigateToTelemetryHistory() {
    // TODO: Navigate to telemetry history screen with plant filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telemetry history feature coming soon')),
    );
  }

  /// Get sync status color
  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
      case SyncStatus.inProgress:
        return Colors.orange;
      case SyncStatus.failed:
      case SyncStatus.conflict:
        return Colors.red;
      case SyncStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Get sync status text
  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.inProgress:
        return 'Syncing';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Format relative time for display
  String _formatRelativeTime(DateTime dateTime) {
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
