/// Telemetry API Service
/// 
/// This service handles all API communication for telemetry data including
/// batch operations, sync status management, telemetry history, and conflict resolution.
/// Follows established API service patterns with proper error handling and retry logic.
library telemetry_api_service;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/services/api_service.dart';
import 'package:leafwise/features/telemetry/models/telemetry_data_models.dart';

/// Provider for TelemetryApiService
final telemetryApiServiceProvider = Provider<TelemetryApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TelemetryApiService(apiService);
});

/// Exception thrown when telemetry operations fail
class TelemetryException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const TelemetryException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'TelemetryException: $message';

  bool get isConflictError => statusCode == 409;
  bool get isValidationError => statusCode == 400;
  bool get isNetworkError => statusCode == null || statusCode! >= 500;
}

/// Response model for batch operations
class BatchOperationResponse {
  final List<TelemetryData> successful;
  final List<ApiServiceBatchOperationError> failed;
  final Map<String, dynamic> metadata;

  const BatchOperationResponse({
    required this.successful,
    required this.failed,
    required this.metadata,
  });

  factory BatchOperationResponse.fromJson(Map<String, dynamic> json) {
    return BatchOperationResponse(
      successful: (json['successful'] as List<dynamic>? ?? [])
          .map((item) => TelemetryDataExtensions.fromBackendLightReading(item))
          .toList(),
      failed: (json['failed'] as List<dynamic>? ?? [])
          .map((item) => ApiServiceBatchOperationError.fromJson(item))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Error details for failed batch operations
class ApiServiceBatchOperationError {
  final String? itemId;
  final int index;
  final String error;
  final String? code;
  final Map<String, dynamic>? details;

  const ApiServiceBatchOperationError({
    this.itemId,
    required this.index,
    required this.error,
    this.code,
    this.details,
  });

  factory ApiServiceBatchOperationError.fromJson(Map<String, dynamic> json) {
    return ApiServiceBatchOperationError(
      itemId: json['item_id']?.toString(),
      index: json['index'] as int,
      error: json['error'] as String,
      code: json['code']?.toString(),
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

/// Response model for sync status queries
class SyncStatusResponse {
  final List<SyncStatusItem> items;
  final Map<String, int> statusCounts;
  final DateTime lastSyncAttempt;
  final Map<String, dynamic> metadata;

  const SyncStatusResponse({
    required this.items,
    required this.statusCounts,
    required this.lastSyncAttempt,
    required this.metadata,
  });

  factory SyncStatusResponse.fromJson(Map<String, dynamic> json) {
    return SyncStatusResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => SyncStatusItem.fromJson(item))
          .toList(),
      statusCounts: Map<String, int>.from(json['status_counts'] ?? {}),
      lastSyncAttempt: DateTime.parse(json['last_sync_attempt']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Individual sync status item
class SyncStatusItem {
  final String id;
  final String type; // 'light_reading' or 'growth_photo'
  final SyncStatus status;
  final DateTime lastAttempt;
  final String? error;
  final int retryCount;
  final Map<String, dynamic>? conflictData;

  const SyncStatusItem({
    required this.id,
    required this.type,
    required this.status,
    required this.lastAttempt,
    this.error,
    required this.retryCount,
    this.conflictData,
  });

  factory SyncStatusItem.fromJson(Map<String, dynamic> json) {
    return SyncStatusItem(
      id: json['id'] as String,
      type: json['type'] as String,
      status: _parseSyncStatus(json['status']),
      lastAttempt: DateTime.parse(json['last_attempt']),
      error: json['error']?.toString(),
      retryCount: json['retry_count'] as int? ?? 0,
      conflictData: json['conflict_data'] as Map<String, dynamic>?,
    );
  }
}

/// Response model for telemetry history
class TelemetryHistoryResponse {
  final List<TelemetryData> items;
  final int totalCount;
  final bool hasMore;
  final String? nextCursor;
  final Map<String, dynamic> aggregations;

  const TelemetryHistoryResponse({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    this.nextCursor,
    required this.aggregations,
  });

  factory TelemetryHistoryResponse.fromJson(Map<String, dynamic> json) {
    final items = <TelemetryData>[];
    
    // Handle mixed response with both light readings and growth photos
    if (json['light_readings'] != null) {
      for (final item in json['light_readings'] as List<dynamic>) {
        items.add(TelemetryDataExtensions.fromBackendLightReading(item));
      }
    }
    
    if (json['growth_photos'] != null) {
      for (final item in json['growth_photos'] as List<dynamic>) {
        items.add(TelemetryDataExtensions.fromBackendGrowthPhoto(item));
      }
    }

    return TelemetryHistoryResponse(
      items: items,
      totalCount: json['total_count'] as int? ?? items.length,
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor']?.toString(),
      aggregations: json['aggregations'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Service for telemetry API operations
class TelemetryApiService {
  final ApiService _apiService;
  static const String _basePath = '/telemetry';

  TelemetryApiService(this._apiService);

  /// Create a batch of telemetry data (light readings and growth photos)
  /// Supports mixed batches and handles partial failures gracefully
  Future<BatchOperationResponse> createBatch(
    List<TelemetryData> telemetryData, {
    bool continueOnError = true,
    Map<String, dynamic>? options,
  }) async {
    try {
      final lightReadings = <Map<String, dynamic>>[];
      final growthPhotos = <Map<String, dynamic>>[];

      // Separate light readings and growth photos
      for (final data in telemetryData) {
        if (data.lightReading != null) {
          lightReadings.add(data.toLightReadingApiFormat());
        }
        if (data.growthPhoto != null) {
          growthPhotos.add(data.toGrowthPhotoApiFormat());
        }
      }

      final requestData = <String, dynamic>{
        'continue_on_error': continueOnError,
        if (lightReadings.isNotEmpty) 'light_readings': lightReadings,
        if (growthPhotos.isNotEmpty) 'growth_photos': growthPhotos,
        if (options != null) 'options': options,
      };

      final response = await _apiService.post(
        '$_basePath/batch',
        data: requestData,
      );

      return BatchOperationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to create telemetry batch');
    }
  }

  /// Get sync status for telemetry data with filtering options
  Future<SyncStatusResponse> getSyncStatus({
    String? userId,
    String? plantId,
    List<SyncStatus>? statusFilter,
    DateTime? since,
    int? limit,
    String? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status'] = statusFilter.map((s) => s.name).join(',');
      }
      if (since != null) queryParams['since'] = since.toIso8601String();
      if (limit != null) queryParams['limit'] = limit;
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await _apiService.get(
        '$_basePath/sync-status',
        queryParameters: queryParams,
      );

      return SyncStatusResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to get sync status');
    }
  }

  /// Get telemetry history with comprehensive filtering and pagination
  Future<TelemetryHistoryResponse> getTelemetryHistory({
    String? userId,
    String? plantId,
    List<String>? dataTypes, // ['light_readings', 'growth_photos']
    DateTime? startDate,
    DateTime? endDate,
    List<SyncStatus>? syncStatusFilter,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortOrder,
    int? limit,
    String? cursor,
    bool includeAggregations = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (dataTypes != null && dataTypes.isNotEmpty) {
        queryParams['data_types'] = dataTypes.join(',');
      }
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (syncStatusFilter != null && syncStatusFilter.isNotEmpty) {
        queryParams['sync_status'] = syncStatusFilter.map((s) => s.name).join(',');
      }
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      if (limit != null) queryParams['limit'] = limit;
      if (cursor != null) queryParams['cursor'] = cursor;
      if (includeAggregations) queryParams['include_aggregations'] = 'true';
      
      // Add custom filters
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams['filter_${entry.key}'] = entry.value;
        }
      }

      final response = await _apiService.get(
        '$_basePath/history',
        queryParameters: queryParams,
      );

      return TelemetryHistoryResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to get telemetry history');
    }
  }

  /// Resolve conflicts for telemetry data with flexible resolution strategies
  Future<List<TelemetryData>> resolveConflicts(
    List<ConflictResolution> resolutions,
  ) async {
    try {
      final requestData = {
        'resolutions': resolutions.map((r) => r.toJson()).toList(),
      };

      final response = await _apiService.post(
        '$_basePath/resolve-conflicts',
        data: requestData,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        // Determine if it's a light reading or growth photo based on response structure
        if (json['lux_value'] != null) {
          return TelemetryDataExtensions.fromBackendLightReading(json);
        } else {
          return TelemetryDataExtensions.fromBackendGrowthPhoto(json);
        }
      }).toList();
    } catch (e) {
      throw _handleError(e, 'Failed to resolve conflicts');
    }
  }

  /// Retry failed sync operations with exponential backoff
  Future<BatchOperationResponse> retryFailedSync({
    String? userId,
    String? plantId,
    List<String>? specificIds,
    int? maxRetries,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (userId != null) requestData['user_id'] = userId;
      if (plantId != null) requestData['plant_id'] = plantId;
      if (specificIds != null) requestData['item_ids'] = specificIds;
      if (maxRetries != null) requestData['max_retries'] = maxRetries;

      final response = await _apiService.post(
        '$_basePath/retry-sync',
        data: requestData,
      );

      return BatchOperationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to retry sync operations');
    }
  }

  /// Get telemetry statistics and analytics
  Future<Map<String, dynamic>> getTelemetryStats({
    String? userId,
    String? plantId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (metrics != null && metrics.isNotEmpty) {
        queryParams['metrics'] = metrics.join(',');
      }

      final response = await _apiService.get(
        '$_basePath/stats',
        queryParameters: queryParams,
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e, 'Failed to get telemetry statistics');
    }
  }

  /// Create a single telemetry data item
  Future<TelemetryData> createTelemetryData(TelemetryData data) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (data.lightReading != null) {
        requestData['light_reading'] = data.toLightReadingApiFormat();
      }
      if (data.growthPhoto != null) {
        requestData['growth_photo'] = data.toGrowthPhotoApiFormat();
      }

      final response = await _apiService.post(
        '$_basePath/create',
        data: requestData,
      );

      final responseData = response.data['data'];
      
      // Determine if it's a light reading or growth photo based on response structure
      if (responseData['lux_value'] != null) {
        return TelemetryDataExtensions.fromBackendLightReading(responseData);
      } else {
        return TelemetryDataExtensions.fromBackendGrowthPhoto(responseData);
      }
    } catch (e) {
      throw _handleError(e, 'Failed to create telemetry data');
    }
  }

  /// Get a single telemetry data item by ID
  Future<TelemetryData?> getTelemetryData(String id) async {
    try {
      final response = await _apiService.get('$_basePath/$id');
      
      if (response.data['data'] == null) {
        return null;
      }
      
      final responseData = response.data['data'];
      
      // Determine if it's a light reading or growth photo based on response structure
      if (responseData['lux_value'] != null) {
        return TelemetryDataExtensions.fromBackendLightReading(responseData);
      } else {
        return TelemetryDataExtensions.fromBackendGrowthPhoto(responseData);
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e, 'Failed to get telemetry data');
    }
  }

  /// Get multiple telemetry data items by IDs
  Future<List<TelemetryData>> getTelemetryDataBatch(List<String> ids) async {
    try {
      final response = await _apiService.post(
        '$_basePath/batch-get',
        data: {'ids': ids},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        // Determine if it's a light reading or growth photo based on response structure
        if (json['lux_value'] != null) {
          return TelemetryDataExtensions.fromBackendLightReading(json);
        } else {
          return TelemetryDataExtensions.fromBackendGrowthPhoto(json);
        }
      }).toList();
    } catch (e) {
      throw _handleError(e, 'Failed to get telemetry data batch');
    }
  }

  /// Update a telemetry data item
  Future<TelemetryData> updateTelemetryData(TelemetryData data) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (data.lightReading != null) {
        requestData['light_reading'] = data.toLightReadingApiFormat();
      }
      if (data.growthPhoto != null) {
        requestData['growth_photo'] = data.toGrowthPhotoApiFormat();
      }

      final response = await _apiService.put(
        '$_basePath/${data.id}',
        data: requestData,
      );

      final responseData = response.data['data'];
      
      // Determine if it's a light reading or growth photo based on response structure
      if (responseData['lux_value'] != null) {
        return TelemetryDataExtensions.fromBackendLightReading(responseData);
      } else {
        return TelemetryDataExtensions.fromBackendGrowthPhoto(responseData);
      }
    } catch (e) {
      throw _handleError(e, 'Failed to update telemetry data');
    }
  }

  /// Delete a telemetry data item
  Future<void> deleteTelemetryData(String id) async {
    try {
      await _apiService.delete('$_basePath/$id');
    } catch (e) {
      throw _handleError(e, 'Failed to delete telemetry data');
    }
  }

  /// Query telemetry data with filtering and pagination
  /// Supports comprehensive filtering options and returns paginated results
  Future<List<TelemetryData>> queryTelemetryData({
    String? userId,
    String? plantId,
    List<String>? dataTypes, // ['light_readings', 'growth_photos']
    DateTime? startDate,
    DateTime? endDate,
    List<SyncStatus>? syncStatusFilter,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortOrder,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (dataTypes != null && dataTypes.isNotEmpty) {
        queryParams['data_types'] = dataTypes.join(',');
      }
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (syncStatusFilter != null && syncStatusFilter.isNotEmpty) {
        queryParams['sync_status'] = syncStatusFilter.map((s) => s.name).join(',');
      }
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      
      // Add custom filters
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams['filter_${entry.key}'] = entry.value;
        }
      }

      final response = await _apiService.get(
        '$_basePath/query',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        // Determine if it's a light reading or growth photo based on response structure
        if (json['lux_value'] != null) {
          return TelemetryDataExtensions.fromBackendLightReading(json);
        } else {
          return TelemetryDataExtensions.fromBackendGrowthPhoto(json);
        }
      }).toList();
    } catch (e) {
      throw _handleError(e, 'Failed to query telemetry data');
    }
  }

  /// Count telemetry data entries matching the specified criteria
  /// Returns the total count without fetching the actual data
  Future<int> countTelemetryData({
    String? userId,
    String? plantId,
    List<String>? dataTypes, // ['light_readings', 'growth_photos']
    DateTime? startDate,
    DateTime? endDate,
    List<SyncStatus>? syncStatusFilter,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (dataTypes != null && dataTypes.isNotEmpty) {
        queryParams['data_types'] = dataTypes.join(',');
      }
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (syncStatusFilter != null && syncStatusFilter.isNotEmpty) {
        queryParams['sync_status'] = syncStatusFilter.map((s) => s.name).join(',');
      }
      
      // Add custom filters
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams['filter_${entry.key}'] = entry.value;
        }
      }

      final response = await _apiService.get(
        '$_basePath/count',
        queryParameters: queryParams,
      );

      return response.data['data']['count'] as int? ?? 0;
    } catch (e) {
      throw _handleError(e, 'Failed to count telemetry data');
    }
  }

  /// Update multiple telemetry data entries in a batch operation
  /// Supports mixed batches and handles partial failures gracefully
  Future<BatchOperationResponse> updateBatch(
    List<TelemetryData> telemetryData, {
    bool continueOnError = true,
    Map<String, dynamic>? options,
  }) async {
    try {
      final lightReadings = <Map<String, dynamic>>[];
      final growthPhotos = <Map<String, dynamic>>[];

      // Separate light readings and growth photos
      for (final data in telemetryData) {
        if (data.lightReading != null) {
          lightReadings.add(data.toLightReadingApiFormat());
        }
        if (data.growthPhoto != null) {
          growthPhotos.add(data.toGrowthPhotoApiFormat());
        }
      }

      final requestData = <String, dynamic>{
        'continue_on_error': continueOnError,
        if (lightReadings.isNotEmpty) 'light_readings': lightReadings,
        if (growthPhotos.isNotEmpty) 'growth_photos': growthPhotos,
        if (options != null) 'options': options,
      };

      final response = await _apiService.put(
        '$_basePath/batch',
        data: requestData,
      );

      return BatchOperationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to update telemetry batch');
    }
  }

  /// Handle API errors and convert to TelemetryException
  TelemetryException _handleError(dynamic error, String defaultMessage) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data is Map<String, dynamic>) {
        final errorData = response!.data as Map<String, dynamic>;
        return TelemetryException(
          errorData['detail'] ?? errorData['message'] ?? defaultMessage,
          code: errorData['code']?.toString(),
          statusCode: response.statusCode,
          details: errorData['details'] as Map<String, dynamic>?,
        );
      }
      return TelemetryException(
        error.message ?? defaultMessage,
        statusCode: response?.statusCode,
      );
    }
    return TelemetryException(defaultMessage);
  }
}

/// Model for conflict resolution requests
class ConflictResolution {
  final String itemId;
  final String itemType; // 'light_reading' or 'growth_photo'
  final String strategy; // 'client_wins', 'server_wins', 'merge', 'manual'
  final Map<String, dynamic>? mergeData;
  final String? reason;

  const ConflictResolution({
    required this.itemId,
    required this.itemType,
    required this.strategy,
    this.mergeData,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_type': itemType,
      'strategy': strategy,
      if (mergeData != null) 'merge_data': mergeData,
      if (reason != null) 'reason': reason,
    };
  }
}

/// Helper function to parse sync status from API response
SyncStatus _parseSyncStatus(dynamic status) {
  if (status == null) return SyncStatus.pending;
  
  switch (status.toString().toLowerCase()) {
    case 'in_progress':
      return SyncStatus.inProgress;
    case 'synced':
      return SyncStatus.synced;
    case 'failed':
      return SyncStatus.failed;
    case 'conflict':
      return SyncStatus.conflict;
    case 'cancelled':
      return SyncStatus.cancelled;
    case 'pending':
    default:
      return SyncStatus.pending;
  }
}