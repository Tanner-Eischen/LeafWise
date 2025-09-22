/// Synchronization service for offline plant identification data
/// Handles syncing local identifications with the server when connectivity is available
library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/offline_plant_identification_models.dart';
import 'local_storage_service.dart';
import 'plant_identification_service.dart';

/// Provider for the sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  final plantIdentificationService = ref.watch(plantIdentificationServiceProvider);
  return SyncService(
    apiService,
    connectivityService,
    localStorageService,
    plantIdentificationService,
  );
});

/// Provider for sync status stream
final syncStatusStreamProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.syncStatusStream;
});

/// Service for synchronizing local plant identifications with the server
class SyncService {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;
  final LocalStorageService _localStorageService;
  final PlantIdentificationService _plantIdentificationService;
  
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  Timer? _autoSyncTimer;
  bool _isSyncing = false;
  
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  SyncService(
    this._apiService,
    this._connectivityService,
    this._localStorageService,
    this._plantIdentificationService,
  );

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Initialize the sync service
  /// Sets up automatic syncing when connectivity is available
  Future<void> initialize() async {
    try {
      // Listen to connectivity changes
      _connectivityService.connectivityStream.listen(_handleConnectivityChange);
      
      // Start auto-sync timer
      _startAutoSync();
      
      // Perform initial sync if online
      final isOnline = await _connectivityService.isOnline();
      if (isOnline) {
        unawaited(_syncAll());
      }
    } catch (e) {
      _emitSyncStatus(SyncStatus.failed('Failed to initialize sync service: $e'));
    }
  }

  /// Manually trigger synchronization of all pending identifications
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncAll() async {
    return await _syncAll();
  }

  /// Sync a specific identification by local ID
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncIdentification(String localId) async {
    if (_isSyncing) {
      return false;
    }
    
    try {
      _isSyncing = true;
      _emitSyncStatus(const SyncStatus.syncing());
      
      final identification = await _localStorageService.getIdentificationById(localId);
      if (identification == null) {
        throw SyncException('Identification not found: $localId');
      }
      
      final success = await _syncSingleIdentification(identification);
      
      if (success) {
        _emitSyncStatus(const SyncStatus.synced());
      } else {
        _emitSyncStatus(const SyncStatus.failed('Failed to sync identification'));
      }
      
      return success;
    } catch (e) {
      _emitSyncStatus(SyncStatus.failed('Sync failed: $e'));
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Get sync statistics
  /// Returns information about sync status and pending items
  Future<SyncStats> getSyncStats() async {
    try {
      final allIdentifications = await _localStorageService.getAllIdentifications();
      
      final pendingSync = allIdentifications.where((id) => id.syncStatus.maybeWhen(
        notSynced: () => true,
        orElse: () => false,
      )).length;
      final failedSync = allIdentifications.where((id) => id.syncStatus.maybeWhen(
        failed: (_) => true,
        orElse: () => false,
      )).length;
      final synced = allIdentifications.where((id) => id.syncStatus.maybeWhen(
        synced: () => true,
        orElse: () => false,
      )).length;
      final syncing = allIdentifications.where((id) => id.syncStatus.maybeWhen(
        syncing: () => true,
        orElse: () => false,
      )).length;
      
      return SyncStats(
        totalIdentifications: allIdentifications.length,
        pendingSync: pendingSync,
        failedSync: failedSync,
        synced: synced,
        syncing: syncing,
        lastSyncAttempt: await _getLastSyncAttempt(),
        isOnline: await _connectivityService.isOnline(),
      );
    } catch (e) {
      throw SyncException('Failed to get sync stats: $e');
    }
  }

  /// Retry failed synchronizations
  /// Attempts to sync all identifications that previously failed
  Future<int> retryFailedSync() async {
    try {
      final failedIdentifications = await _localStorageService.getFailedSyncIdentifications();
      int successCount = 0;
      
      for (final identification in failedIdentifications) {
        // Reset status to not synced for retry
        final resetIdentification = identification.copyWith(
          syncStatus: const SyncStatus.notSynced(),
          syncError: null,
        );
        
        await _localStorageService.updateIdentification(
          identification.localId,
          resetIdentification,
        );
        
        if (await _syncSingleIdentification(resetIdentification)) {
          successCount++;
        }
      }
      
      return successCount;
    } catch (e) {
      throw SyncException('Failed to retry failed sync: $e');
    }
  }

  /// Clear all sync errors
  /// Resets failed identifications to pending status
  Future<void> clearSyncErrors() async {
    try {
      final failedIdentifications = await _localStorageService.getFailedSyncIdentifications();
      
      for (final identification in failedIdentifications) {
        final resetIdentification = identification.copyWith(
          syncStatus: const SyncStatus.notSynced(),
          syncError: null,
        );
        
        await _localStorageService.updateIdentification(
          identification.localId,
          resetIdentification,
        );
      }
    } catch (e) {
      throw SyncException('Failed to clear sync errors: $e');
    }
  }

  /// Dispose of resources
  /// Stops timers and closes streams
  Future<void> dispose() async {
    _autoSyncTimer?.cancel();
    await _syncStatusController.close();
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityStatus status) {
    if (status.isOnline && !_isSyncing) {
      // Connectivity restored, trigger sync
      unawaited(_syncAll());
    }
  }

  /// Start automatic synchronization timer
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (_) {
      if (!_isSyncing) {
        unawaited(_syncAll());
      }
    });
  }

  /// Perform synchronization of all pending identifications
  Future<bool> _syncAll() async {
    if (_isSyncing) {
      return false;
    }
    
    try {
      _isSyncing = true;
      _emitSyncStatus(const SyncStatus.syncing());
      
      // Check connectivity
      final isOnline = await _connectivityService.isOnline();
      if (!isOnline) {
        _emitSyncStatus(const SyncStatus.failed('No internet connection'));
        return false;
      }
      
      // Get unsynced identifications
      final unsyncedIdentifications = await _localStorageService.getUnsyncedIdentifications();
      
      if (unsyncedIdentifications.isEmpty) {
        _emitSyncStatus(const SyncStatus.synced());
        return true;
      }
      
      // Sync each identification
      int successCount = 0;
      int failureCount = 0;
      
      for (final identification in unsyncedIdentifications) {
        final success = await _syncSingleIdentification(identification);
        if (success) {
          successCount++;
        } else {
          failureCount++;
        }
        
        // Add small delay between requests to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Update last sync attempt timestamp
      await _setLastSyncAttempt(DateTime.now());
      
      if (failureCount == 0) {
        _emitSyncStatus(const SyncStatus.synced());
        return true;
      } else {
        _emitSyncStatus(SyncStatus.failed(
          'Synced $successCount, failed $failureCount identifications'
        ));
        return false;
      }
    } catch (e) {
      _emitSyncStatus(SyncStatus.failed('Sync failed: $e'));
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single identification with retry logic
  Future<bool> _syncSingleIdentification(LocalPlantIdentification identification) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        // Mark as syncing
        final syncingIdentification = identification.copyWith(
          syncStatus: const SyncStatus.syncing(),
        );
        
        await _localStorageService.updateIdentification(
          identification.localId,
          syncingIdentification,
        );
        
        // Upload image if it exists
        String? serverImageUrl;
        final imageFile = File(identification.localImagePath);
        if (await imageFile.exists()) {
          serverImageUrl = await _uploadImage(imageFile);
        }
        
        // Create server identification request
        final serverRequest = {
          'localId': identification.localId,
          'scientificName': identification.scientificName,
          'commonName': identification.commonName,
          'confidence': identification.confidence,
          'identifiedAt': identification.identifiedAt.toIso8601String(),
          'imageUrl': serverImageUrl,
          'localModelData': identification.localModelData,
        };
        
        // Send to server
        final response = await _apiService.post<Map<String, dynamic>>(
          '/plant-identifications/sync',
          data: serverRequest,
        );
        
        // Update with server response
        final syncedIdentification = identification.copyWith(
          serverId: response['id'] as String?,
          syncStatus: const SyncStatus.synced(),
          syncError: null,
        );
        
        await _localStorageService.updateIdentification(
          identification.localId,
          syncedIdentification,
        );
        
        return true;
      } catch (e) {
        retryCount++;
        
        if (retryCount >= _maxRetries) {
          // Mark as failed after max retries
          final failedIdentification = identification.copyWith(
            syncStatus: SyncStatus.failed(e.toString()),
            syncError: e.toString(),
          );
          
          await _localStorageService.updateIdentification(
            identification.localId,
            failedIdentification,
          );
          
          return false;
        }
        
        // Wait before retry with exponential backoff
        final delay = Duration(
          milliseconds: _retryDelay.inMilliseconds * math.pow(2, retryCount - 1).toInt(),
        );
        await Future.delayed(delay);
      }
    }
    
    return false;
  }

  /// Upload image to server
  Future<String> _uploadImage(File imageFile) async {
    try {
      final response = await _apiService.uploadFile<Map<String, dynamic>>(
        '/images/upload',
        imageFile.path,
        additionalData: {
          'type': 'plant_identification',
        },
      );
      
      return response['url'] as String;
    } catch (e) {
      throw SyncException('Failed to upload image: $e');
    }
  }

  /// Emit sync status to stream
  void _emitSyncStatus(SyncStatus status) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }

  /// Get last sync attempt timestamp
  Future<DateTime?> _getLastSyncAttempt() async {
    try {
      // We'll need to add a method to LocalStorageService to access this
      // For now, return null as a placeholder
      return null;
    } catch (e) {
      // Ignore errors, return null
    }
    return null;
  }

  /// Set last sync attempt timestamp
  Future<void> _setLastSyncAttempt(DateTime timestamp) async {
    try {
      // We'll need to add a method to LocalStorageService to access this
      // For now, do nothing as a placeholder
    } catch (e) {
      // Ignore errors
    }
  }
}

/// Synchronization statistics
class SyncStats {
  final int totalIdentifications;
  final int pendingSync;
  final int failedSync;
  final int synced;
  final int syncing;
  final DateTime? lastSyncAttempt;
  final bool isOnline;
  
  const SyncStats({
    required this.totalIdentifications,
    required this.pendingSync,
    required this.failedSync,
    required this.synced,
    required this.syncing,
    this.lastSyncAttempt,
    required this.isOnline,
  });
  
  /// Get sync completion percentage
  double get syncPercentage {
    if (totalIdentifications == 0) return 1.0;
    return synced / totalIdentifications;
  }
  
  /// Check if all identifications are synced
  bool get isFullySynced => pendingSync == 0 && failedSync == 0 && syncing == 0;
  
  /// Check if there are any sync issues
  bool get hasSyncIssues => failedSync > 0;
}

/// Exception thrown by sync operations
class SyncException implements Exception {
  final String message;
  
  const SyncException(this.message);
  
  @override
  String toString() => 'SyncException: $message';
}

/// Extension for unawaited futures
extension UnawaiteExtension on Future {
  void get unawaited => {};
}