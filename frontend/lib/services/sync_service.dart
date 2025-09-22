/// Sync Service
/// 
/// This service provides functionality for queuing and synchronizing data with the backend server.
/// It supports offline operation with persistence and implements retry mechanisms with exponential backoff.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/api_service.dart';
import '../core/exceptions/api_exception.dart';
import '../modules/light_meter/types.dart';

/// Provider for the sync queue service singleton
final syncQueueProvider = Provider<SyncQueue>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SyncQueue(storageService: storageService);
});

/// Represents an item in the sync queue
class SyncQueueItem<T> {
  /// Unique identifier for the queue item
  final String id;
  
  /// The data to be synchronized
  final T data;
  
  /// The type of data being synchronized
  final String type;
  
  /// Current status of the sync operation
  String status;
  
  /// When the item was created
  final DateTime createdAt;
  
  /// When the item was last updated
  DateTime updatedAt;
  
  /// Number of retry attempts made
  int retryCount;
  
  /// Optional error message if sync failed
  String? errorMessage;
  
  /// Optional timestamp of last sync attempt
  DateTime? lastAttempt;

  SyncQueueItem({
    required this.id,
    required this.data,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    this.errorMessage,
    this.lastAttempt,
  });

  /// Create a SyncQueueItem from JSON
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      data: json['data'] as T,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      retryCount: json['retry_count'] as int,
      errorMessage: json['error_message'] as String?,
      lastAttempt: json['last_attempt'] != null
          ? DateTime.parse(json['last_attempt'] as String)
          : null,
    );
  }

  /// Convert SyncQueueItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'retry_count': retryCount,
      'error_message': errorMessage,
      'last_attempt': lastAttempt?.toIso8601String(),
    };
  }
}

/// Options for the sync queue
class SyncQueueOptions {
  /// Maximum number of retry attempts
  final int maxRetries;
  
  /// Initial delay between retries in milliseconds
  final int initialRetryDelay;
  
  /// Maximum delay between retries in milliseconds
  final int maxRetryDelay;
  
  /// Key used for persistent storage
  final String persistenceKey;

  const SyncQueueOptions({
    required this.maxRetries,
    required this.initialRetryDelay,
    required this.maxRetryDelay,
    required this.persistenceKey,
  });
}

/// Default options for the sync queue
const DEFAULT_SYNC_QUEUE_OPTIONS = SyncQueueOptions(
  maxRetries: 5,
  initialRetryDelay: 1000, // 1 second
  maxRetryDelay: 60000, // 1 minute
  persistenceKey: 'sync_queue',
);

/// Result of a sync operation
class SyncResult {
  /// Whether the operation was successful
  final bool success;
  
  /// Optional message describing the result
  final String? message;
  
  /// Whether the operation should be retried
  final bool shouldRetry;
  
  /// Number of items successfully synchronized
  final int succeeded;
  
  /// Number of items that failed to synchronize
  final int failed;
  
  /// Number of items still pending synchronization
  final int pending;
  
  /// IDs of items that failed to synchronize
  final List<String> failedIds;
  
  /// Total number of items processed
  final int total;

  SyncResult({
    required this.success,
    this.message,
    this.shouldRetry = true,
    this.succeeded = 0,
    this.failed = 0,
    this.pending = 0,
    this.failedIds = const [],
    this.total = 0,
  });
}

/// SyncQueue class for managing offline data synchronization
class SyncQueue {
  final List<SyncQueueItem<dynamic>> _queue = [];
  final SyncQueueOptions _options;
  final StorageService _storageService;
  final _uuid = const Uuid();
  static SyncQueue? _instance;

  /// Constructor for SyncQueue
  SyncQueue({
    required StorageService storageService,
    SyncQueueOptions options = DEFAULT_SYNC_QUEUE_OPTIONS,
  }) : _options = options,
       _storageService = storageService {
    _loadFromStorage();
  }

  /// Get the singleton instance of SyncQueue
  static SyncQueue getInstance({
    required StorageService storageService,
    SyncQueueOptions options = DEFAULT_SYNC_QUEUE_OPTIONS,
  }) {
    _instance ??= SyncQueue(
      storageService: storageService,
      options: options,
    );
    return _instance!;
  }

  /// Add a light reading to the sync queue
  String queueLightReading(LightReading reading) {
    final id = _generateId();
    final item = SyncQueueItem<LightReading>(
      id: id,
      data: reading,
      type: 'light_reading',
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      retryCount: 0,
    );
    _queue.add(item);
    _saveToStorage();
    return id;
  }
  
  /// Sync light readings to the server
  /// Handles uploading light readings with retry logic
  Future<SyncResult> syncLightReading(SyncQueueItem item) async {
    try {
      final apiService = ApiService();
      final connectivityService = ConnectivityService();
      
      // Check for connectivity before attempting sync
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return SyncResult(
          success: false,
          message: 'No internet connection',
          shouldRetry: true,
        );
      }
      
      // Make API call to upload light reading
      final response = await apiService.post(
        '/api/v1/telemetry/light',
        data: item.data,
      );
      
      return SyncResult(
        success: true,
        message: 'Light reading synced successfully',
        shouldRetry: false,
      );
    } catch (e) {
      // Handle different error types
      bool shouldRetry = true;
      String errorMessage = 'Failed to sync light reading';
      
      if (e is ApiException) {
        // Don't retry for client errors except network/timeout issues
        shouldRetry = e.isNetworkError || e.isTimeoutError || e.isServerError;
        errorMessage = e.message;
        
        // Don't retry for validation errors
        if (e.isValidationError) {
          shouldRetry = false;
        }
      }
      
      return SyncResult(
        success: false,
        message: errorMessage,
        shouldRetry: shouldRetry,
      );
    }
  }

  /// Queue a growth photo for sync
  /// @param plantId The ID of the plant
  /// @param localUri The local URI of the photo file
  /// @param takenAt When the photo was taken
  /// @param metrics Optional growth metrics extracted from the photo
  /// @returns The ID of the queued item
  Future<String> queueGrowthPhoto({
    required String plantId,
    required String localUri,
    required DateTime takenAt,
    Map<String, dynamic>? metrics,
    String? locationTag,
  }) async {
    final id = _generateId();
    final item = SyncQueueItem<Map<String, dynamic>>(
      id: id,
      data: {
        'plant_id': plantId,
        'local_uri': localUri,
        'taken_at': takenAt.toIso8601String(),
        if (metrics != null) 'metrics': metrics,
        if (locationTag != null) 'location_tag': locationTag,
        'upload_status': 'pending',
      },
      type: 'growth_photo',
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      retryCount: 0,
    );
    _queue.add(item);
    await _saveToStorage();
    return id;
  }
  
  /// Sync growth photos to the server
  /// Handles uploading growth photos with retry logic
  Future<SyncResult> syncGrowthPhoto(SyncQueueItem item) async {
    try {
      final apiService = ApiService();
      final connectivityService = ConnectivityService();
      
      // Check for connectivity before attempting sync
      final isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        return SyncResult(
          success: false,
          message: 'No internet connection',
          shouldRetry: true,
        );
      }
      
      // Extract the growth photo data
      final growthPhoto = item.data;
      
      // Check if we have a local file URI
      if (growthPhoto['local_uri'] == null) {
        return SyncResult(
          success: false,
          message: 'Missing local file URI',
          shouldRetry: false,
        );
      }
      
      // Prepare form data for file upload
      final formData = {
        'plant_id': growthPhoto['plant_id'],
        'captured_at': growthPhoto['taken_at'],
      };
      
      // If metrics are available, include them
      if (growthPhoto['metrics'] != null) {
        formData['metrics'] = growthPhoto['metrics'];
      }
      
      // Upload the file using multipart form data
      final response = await apiService.uploadFile(
        '/api/v1/telemetry/growth-photo:upload',
        growthPhoto['local_uri'],
        additionalData: formData,
      );
      
      return SyncResult(
        success: true,
        message: 'Growth photo synced successfully',
        shouldRetry: false,
      );
    } catch (e) {
      // Handle different error types
      bool shouldRetry = true;
      String errorMessage = 'Failed to sync growth photo';
      
      if (e is ApiException) {
        // Don't retry for client errors except network/timeout issues
        shouldRetry = e.isNetworkError || e.isTimeoutError || e.isServerError;
        errorMessage = e.message;
        
        // Don't retry for validation errors or not found errors
        if (e.isValidationError || e.type == ApiExceptionType.notFound) {
          shouldRetry = false;
        }
        
        // Don't retry if the file doesn't exist or is inaccessible
        if (e.statusCode == 400 && e.message.contains('file')) {
          shouldRetry = false;
        }
      }
      
      return SyncResult(
        success: false,
        message: errorMessage,
        shouldRetry: shouldRetry,
      );
    }
  }

  /// Get all items in the sync queue
  List<SyncQueueItem<T>> getItems<T>({String? type, String? status}) {
    List<SyncQueueItem<dynamic>> filteredQueue = _queue;
    
    if (type != null) {
      filteredQueue = filteredQueue.where((item) => item.type == type).toList();
    }
    
    if (status != null) {
      filteredQueue = filteredQueue.where((item) => item.status == status).toList();
    }
    
    return filteredQueue.whereType<SyncQueueItem<T>>().toList();
  }

  /// Get the count of items in the queue
  int getCount({String? type, String? status}) {
    return getItems(type: type, status: status).length;
  }

  /// Synchronize all pending items in the queue
  Future<SyncResult> sync() async {
    final pendingItems = getItems(status: 'pending');
    var successCount = 0;
    var failedCount = 0;
    var pendingCount = 0;
    final failedIds = <String>[];
    
    if (pendingItems.isEmpty) {
      return SyncResult(
        success: true, 
        message: 'No items to sync', 
        total: 0, 
        succeeded: 0, 
        failed: 0,
        pending: 0,
        failedIds: [],
      );
    }
    
    for (final item in pendingItems) {
      try {
        // Mark item as in progress
        _updateItemStatus(item.id, 'in_progress');
        
        // Process based on item type
        SyncResult result;
        switch (item.type) {
          case 'light_reading':
            result = await syncLightReading(item);
            break;
          case 'growth_photo':
            result = await syncGrowthPhoto(item);
            break;
          default:
            result = SyncResult(
              success: false,
              message: 'Unknown item type: ${item.type}',
              shouldRetry: false
            );
        }
        
        if (result.success) {
          _updateItemStatus(item.id, 'completed');
          successCount++;
        } else if (result.shouldRetry && item.retryCount < _options.maxRetries) {
          _updateItemRetry(item.id, result.message ?? 'Sync failed');
          pendingCount++;
        } else {
          _updateItemStatus(item.id, 'failed');
          failedCount++;
          failedIds.add(item.id);
        }
      } catch (error) {
        final errorMessage = error.toString();
        
        // Update retry count and status
        final updatedItem = _updateItemRetry(item.id, errorMessage);
        
        if (updatedItem.retryCount >= _options.maxRetries) {
          _updateItemStatus(item.id, 'failed');
          failedCount++;
          failedIds.add(item.id);
        } else {
          _updateItemStatus(item.id, 'pending');
          pendingCount++;
        }
      }
    }

    _saveToStorage();
    return SyncResult(
      success: failedCount == 0,
      message: failedCount == 0 ? 'Sync completed successfully' : 'Some items failed to sync',
      succeeded: successCount,
      failed: failedCount,
      pending: pendingCount,
      failedIds: failedIds,
      total: pendingItems.length
    );
  }

  /// Clear items from the queue
  void clearItems({String? status}) {
    if (status != null) {
      _queue.removeWhere((item) => item.status == status);
    } else {
      _queue.clear();
    }
    _saveToStorage();
  }

  /// Remove a specific item from the queue
  bool removeItem(String id) {
    final initialLength = _queue.length;
    _queue.removeWhere((item) => item.id == id);
    final removed = initialLength > _queue.length;
    
    if (removed) {
      _saveToStorage();
    }
    
    return removed;
  }

  /// Calculate the retry delay using exponential backoff with jitter
  int calculateRetryDelay(int retryCount) {
    // Exponential backoff: initialDelay * 2^retryCount
    final exponentialDelay = _options.initialRetryDelay * pow(2, retryCount);
    
    // Apply maximum delay cap
    final cappedDelay = min(exponentialDelay, _options.maxRetryDelay);
    
    // Add jitter (±20%) to prevent thundering herd problem
    final jitterFactor = 0.8 + (Random().nextDouble() * 0.4); // Random value between 0.8 and 1.2
    
    return (cappedDelay * jitterFactor).floor();
  }

  /// Update the status of an item in the queue
  SyncQueueItem<dynamic>? _updateItemStatus(String id, String status) {
    try {
      final item = _queue.firstWhere((item) => item.id == id);
      item.status = status;
      item.updatedAt = DateTime.now();
      _saveToStorage();
      return item;
    } catch (e) {
      return null;
    }
  }

  /// Update the retry count and error message of an item in the queue
  SyncQueueItem<dynamic> _updateItemRetry(String id, String errorMessage) {
    final item = _queue.firstWhere((item) => item.id == id);
    
    item.retryCount++;
    item.errorMessage = errorMessage;
    item.lastAttempt = DateTime.now();
    item.updatedAt = DateTime.now();
    _saveToStorage();
    
    return item;
  }

  /// Generate a unique ID for a queue item
  String _generateId() {
    return 'sync_${_uuid.v4()}';
  }

  /// Save the queue to local storage
  Future<void> _saveToStorage() async {
    try {
      final queueJson = _queue.map((item) => item.toJson()).toList();
      final queueString = jsonEncode(queueJson);
      await _storageService.setString(_options.persistenceKey, queueString);
    } catch (error) {
      print('Failed to save sync queue to storage: $error');
    }
  }

  /// Load the queue from local storage
  Future<void> _loadFromStorage() async {
    try {
      final queueString = await _storageService.getString(_options.persistenceKey);
      
      if (queueString != null) {
        final queueJson = jsonDecode(queueString) as List<dynamic>;
        _queue.clear();
        _queue.addAll(queueJson.map((item) => SyncQueueItem.fromJson(item as Map<String, dynamic>)));
      }
    } catch (error) {
      print('Failed to load sync queue from storage: $error');
      _queue.clear();
    }
  }
}

/// Convenience function to get the SyncQueue instance
SyncQueue getSyncQueue({
  required StorageService storageService,
  SyncQueueOptions options = DEFAULT_SYNC_QUEUE_OPTIONS,
}) {
  return SyncQueue.getInstance(
    storageService: storageService,
    options: options,
  );
}