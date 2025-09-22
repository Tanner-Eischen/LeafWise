import 'package:dio/dio.dart';
import 'package:leafwise/core/services/api_service.dart';
import 'package:leafwise/features/plant_care/models/plant_care_models.dart';

class PlantCareService {
  final ApiService _apiService;

  PlantCareService(this._apiService);

  // User Plants
  Future<List<UserPlant>> getUserPlants() async {
    try {
      final response = await _apiService.get('/user-plants');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => UserPlant.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserPlant> getUserPlant(String plantId) async {
    try {
      final response = await _apiService.get('/user-plants/$plantId');
      return UserPlant.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserPlant> createUserPlant(UserPlantRequest request) async {
    try {
      final response = await _apiService.post(
        '/user-plants',
        data: request.toJson(),
      );
      return UserPlant.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserPlant> updateUserPlant(
    String plantId,
    UserPlantRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/user-plants/$plantId',
        data: request.toJson(),
      );
      return UserPlant.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteUserPlant(String plantId) async {
    try {
      await _apiService.delete('/user-plants/$plantId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Care Logs
  Future<List<PlantCareLog>> getCareLogs({
    String? userPlantId,
    String? careType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userPlantId != null) queryParams['user_plant_id'] = userPlantId;
      if (careType != null) queryParams['care_type'] = careType;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        '/care-logs',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PlantCareLog.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareLog> getCareLog(String logId) async {
    try {
      final response = await _apiService.get('/care-logs/$logId');
      return PlantCareLog.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareLog> createCareLog(PlantCareRequest request) async {
    try {
      final response = await _apiService.post(
        '/care-logs',
        data: request.toJson(),
      );
      return PlantCareLog.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareLog> updateCareLog(
    String logId,
    PlantCareRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/care-logs/$logId',
        data: request.toJson(),
      );
      return PlantCareLog.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCareLog(String logId) async {
    try {
      await _apiService.delete('/care-logs/$logId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Care Reminders
  Future<List<PlantCareReminder>> getReminders({
    String? userPlantId,
    String? careType,
    bool? isActive,
    bool? isDue,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userPlantId != null) queryParams['user_plant_id'] = userPlantId;
      if (careType != null) queryParams['care_type'] = careType;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (isDue != null) queryParams['is_due'] = isDue;

      final response = await _apiService.get(
        '/care-reminders',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PlantCareReminder.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PlantCareReminder>> getUpcomingReminders({int? days}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (days != null) queryParams['days'] = days;

      final response = await _apiService.get(
        '/care-reminders/upcoming',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PlantCareReminder.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareReminder> getReminder(String reminderId) async {
    try {
      final response = await _apiService.get('/care-reminders/$reminderId');
      return PlantCareReminder.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareReminder> createReminder(
    PlantCareReminderRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/care-reminders',
        data: request.toJson(),
      );
      return PlantCareReminder.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareReminder> updateReminder(
    String reminderId,
    PlantCareReminderRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/care-reminders/$reminderId',
        data: request.toJson(),
      );
      return PlantCareReminder.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _apiService.delete('/care-reminders/$reminderId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareReminder> completeReminder(String reminderId) async {
    try {
      final response = await _apiService.post(
        '/care-reminders/$reminderId/complete',
      );
      return PlantCareReminder.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantCareReminder> snoozeReminder(String reminderId, int days) async {
    try {
      final response = await _apiService.post(
        '/care-reminders/$reminderId/snooze',
        data: {'days': days},
      );
      return PlantCareReminder.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Plant Species (for reference)
  Future<List<PlantSpecies>> searchPlantSpecies({
    String? search,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        '/plant-species',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PlantSpecies.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlantSpecies> getPlantSpecies(String speciesId) async {
    try {
      final response = await _apiService.get('/plant-species/$speciesId');
      return PlantSpecies.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getCareStatistics({
    String? userPlantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userPlantId != null) queryParams['user_plant_id'] = userPlantId;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/care-logs/statistics',
        queryParameters: queryParams,
      );
      return response.data['data'] ?? {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Image upload
  Future<String> uploadPlantImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.post(
        '/upload/plant-image',
        data: formData,
      );
      return response.data['data']['url'];
    } catch (e) {
      throw _handleError(e);
    }
  }

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
