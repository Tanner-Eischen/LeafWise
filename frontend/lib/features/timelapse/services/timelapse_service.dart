import 'package:dio/dio.dart';
import 'package:plant_social/core/services/api_service.dart';
import 'package:plant_social/features/timelapse/models/timelapse_models.dart';
import 'package:plant_social/features/timelapse/models/timelapse_models_extended.dart';

/// Service for handling time-lapse photo management and video generation
class TimelapseService {
  final ApiService _apiService;

  TimelapseService(this._apiService);

  // Timelapse Sessions
  Future<TimelapseSession> createSession({
    required String plantId,
    required String name,
    required TrackingConfig config,
    String? description,
  }) async {
    try {
      final requestData = {
        'plant_id': plantId,
        'name': name,
        'config': config.toJson(),
        if (description != null) 'description': description,
      };

      final response = await _apiService.post(
        '/v1/timelapse/sessions',
        data: requestData,
      );
      return TimelapseSession.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TimelapseSession>> getSessions({
    String? plantId,
    String? status,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (plantId != null) queryParams['plant_id'] = plantId;
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        '/v1/timelapse/sessions',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => TimelapseSession.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelapseSession> getSession(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/sessions/$sessionId',
      );
      return TimelapseSession.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelapseSession> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put(
        '/v1/timelapse/sessions/$sessionId',
        data: updates,
      );
      return TimelapseSession.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _apiService.delete('/v1/timelapse/sessions/$sessionId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Photo Management
  Future<Map<String, dynamic>> uploadPhoto({
    required String sessionId,
    required String filePath,
    DateTime? capturedAt,
    PlantMeasurements? measurements,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
        'session_id': sessionId,
        if (capturedAt != null) 'captured_at': capturedAt.toIso8601String(),
        if (measurements != null) 'measurements': measurements.toJson(),
        if (metadata != null) 'metadata': metadata,
      });

      final response = await _apiService.post(
        '/v1/timelapse/$sessionId/photos',
        data: formData,
      );
      return response['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPhotos({
    required String sessionId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/photos',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePhoto(String sessionId, String photoId) async {
    try {
      await _apiService.delete('/v1/timelapse/$sessionId/photos/$photoId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Video Generation
  Future<Map<String, dynamic>> generateVideo({
    required String sessionId,
    required VideoOptions options,
  }) async {
    try {
      final response = await _apiService.post(
        '/v1/timelapse/$sessionId/video',
        data: {'options': options.toJson()},
      );
      return response['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getVideoStatus(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/video/status',
      );
      return response['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelapseVideo?> getVideo(String sessionId) async {
    try {
      final response = await _apiService.get('/v1/timelapse/$sessionId/video');
      final data = response['data'];
      return data != null ? TimelapseVideo.fromJson(data) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Growth Analysis
  Future<GrowthAnalysis> getGrowthAnalysis(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/analysis',
      );
      return GrowthAnalysis.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GrowthAnalysis> triggerGrowthAnalysis(String sessionId) async {
    try {
      final response = await _apiService.post(
        '/v1/timelapse/$sessionId/analysis/trigger',
      );
      return GrowthAnalysis.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Growth Milestones
  Future<List<GrowthMilestone>> getMilestones(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/milestones',
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => GrowthMilestone.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GrowthMilestone> createMilestone({
    required String sessionId,
    required String name,
    required String description,
    required DateTime targetDate,
    Map<String, dynamic>? criteria,
  }) async {
    try {
      final requestData = {
        'name': name,
        'description': description,
        'target_date': targetDate.toIso8601String(),
        if (criteria != null) 'criteria': criteria,
      };

      final response = await _apiService.post(
        '/v1/timelapse/$sessionId/milestones',
        data: requestData,
      );
      return GrowthMilestone.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GrowthMilestone> updateMilestone(
    String sessionId,
    String milestoneId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put(
        '/v1/timelapse/$sessionId/milestones/$milestoneId',
        data: updates,
      );
      return GrowthMilestone.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Growth Analytics
  Future<GrowthAnalytics> getGrowthAnalytics({
    required String sessionId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/analytics',
        queryParameters: queryParams,
      );
      return GrowthAnalytics.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<GrowthComparison>> compareGrowth({
    required List<String> sessionIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final requestData = {
        'session_ids': sessionIds,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.post(
        '/v1/timelapse/compare',
        data: requestData,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => GrowthComparison.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Photo Schedule Management
  Future<PhotoSchedule> createPhotoSchedule({
    required String sessionId,
    required String frequency,
    required DateTime startTime,
    DateTime? endTime,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final requestData = {
        'frequency': frequency,
        'start_time': startTime.toIso8601String(),
        if (endTime != null) 'end_time': endTime.toIso8601String(),
        if (settings != null) 'settings': settings,
      };

      final response = await _apiService.post(
        '/v1/timelapse/$sessionId/schedule',
        data: requestData,
      );
      return PhotoSchedule.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PhotoSchedule?> getPhotoSchedule(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/schedule',
      );
      final data = response['data'];
      return data != null ? PhotoSchedule.fromJson(data) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PhotoSchedule> updatePhotoSchedule(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put(
        '/v1/timelapse/$sessionId/schedule',
        data: updates,
      );
      return PhotoSchedule.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePhotoSchedule(String sessionId) async {
    try {
      await _apiService.delete('/v1/timelapse/$sessionId/schedule');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Utility Methods
  Future<Map<String, dynamic>> getSessionStatistics(String sessionId) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/$sessionId/statistics',
      );
      return response['data'] ?? {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/v1/timelapse/sessions/recent',
        queryParameters: {'limit': limit},
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        }
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}
