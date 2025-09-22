// Care Plan API Service
// This service handles all API communication for context-aware care plans
// including generation, retrieval, acknowledgment, and history management

import 'package:dio/dio.dart';
import 'package:leafwise/core/services/api_service.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';

/// Exception thrown when care plan operations fail
class CarePlanException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const CarePlanException(this.message, {this.code, this.statusCode});

  @override
  String toString() => 'CarePlanException: $message';
}

/// Service for care plan API operations
class CarePlanApiService {
  final ApiService _apiService;
  static const String _basePath = '/care-plans';

  CarePlanApiService(this._apiService);

  /// Generate a new care plan for a plant
  /// Throws [CarePlanException] if generation fails
  Future<CarePlanGenerationResponse> generateCarePlan(
    String plantId, {
    bool forceRegenerate = false,
    Map<String, dynamic>? contextOverrides,
  }) async {
    try {
      final request = CarePlanGenerationRequest(
        userPlantId: plantId,
      );

      final response = await _apiService.post(
        '$_basePath/$plantId:generate',
        data: request.toJson(),
      );

      return CarePlanGenerationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to generate care plan');
    }
  }

  /// Get the current care plan for a plant
  /// Returns null if no plan exists
  Future<CarePlan?> getCurrentCarePlan(String plantId) async {
    try {
      final response = await _apiService.get(
        '$_basePath/$plantId',
        queryParameters: {'latest': 'true'},
      );

      if (response.data['data'] == null) {
        return null;
      }

      return CarePlan.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e, 'Failed to get current care plan');
    }
  }

  /// Get a specific care plan by ID
  Future<CarePlan> getCarePlan(String planId) async {
    try {
      final response = await _apiService.get('$_basePath/plan/$planId');
      return CarePlan.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to get care plan');
    }
  }

  /// Acknowledge a care plan (user accepts the recommendations)
  Future<CarePlan> acknowledgeCarePlan(String planId) async {
    try {
      final response = await _apiService.post(
        '$_basePath/plan/$planId:acknowledge',
        data: {'acknowledged_at': DateTime.now().toIso8601String()},
      );
      return CarePlan.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e, 'Failed to acknowledge care plan');
    }
  }

  /// Get care plan history for a plant
  Future<CarePlanHistoryResponse> getCarePlanHistory(
    String plantId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '$_basePath/$plantId/history',
        queryParameters: queryParams,
      );

      // Parse the response according to the backend CarePlanHistoryResponse structure
      final responseData = response.data;
      return CarePlanHistoryResponse(
        plantId: responseData['plant_id'] ?? plantId,
        plans: (responseData['plans'] as List<dynamic>? ?? [])
            .map((json) => CarePlanHistory.fromJson(json))
            .toList(),
        totalCount: responseData['total_count'] ?? 0,
        currentVersion: responseData['current_version'] ?? 1,
        hasMore: (responseData['plans'] as List<dynamic>? ?? []).length >= (limit ?? 20),
      );
    } catch (e) {
      throw _handleError(e, 'Failed to get care plan history');
    }
  }

  /// Get care plan summaries for multiple plants
  Future<List<CarePlanHistory>> getCareplanHistory({
    List<String>? plantIds,
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (plantIds != null && plantIds.isNotEmpty) {
        queryParams['plant_ids'] = plantIds.join(',');
      }
      if (activeOnly != null) queryParams['active_only'] = activeOnly;

      final response = await _apiService.get(
        '$_basePath/summaries',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CarePlanHistory.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, 'Failed to get care plan summaries');
    }
  }

  /// Compare two care plan versions
  Future<Map<String, dynamic>> compareCarePlans(
    String planId1,
    String planId2,
  ) async {
    try {
      final response = await _apiService.get(
        '$_basePath/compare',
        queryParameters: {'plan1': planId1, 'plan2': planId2},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e, 'Failed to compare care plans');
    }
  }

  /// Get care plan metrics and performance data
  Future<Map<String, dynamic>> getCarePlanMetrics(String plantId) async {
    try {
      final response = await _apiService.get('$_basePath/$plantId/metrics');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e, 'Failed to get care plan metrics');
    }
  }

  /// Batch generate care plans for multiple plants
  Future<List<CarePlanGenerationResponse>> batchGenerateCarePlans(
    List<String> plantIds, {
    bool forceRegenerate = false,
  }) async {
    try {
      final response = await _apiService.post(
        '$_basePath:batch-generate',
        data: {'plant_ids': plantIds, 'force_regenerate': forceRegenerate},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((json) => CarePlanGenerationResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e, 'Failed to batch generate care plans');
    }
  }

  /// Handle API errors and convert to CarePlanException
  CarePlanException _handleError(dynamic error, String defaultMessage) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data is Map<String, dynamic>) {
        final errorData = response!.data as Map<String, dynamic>;
        return CarePlanException(
          errorData['detail'] ?? errorData['message'] ?? defaultMessage,
          code: errorData['code']?.toString(),
          statusCode: response.statusCode,
        );
      }
      return CarePlanException(
        error.message ?? defaultMessage,
        statusCode: response?.statusCode,
      );
    }
    return CarePlanException(defaultMessage);
  }


}
