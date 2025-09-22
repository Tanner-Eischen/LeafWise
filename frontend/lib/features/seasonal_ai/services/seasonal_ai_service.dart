import 'package:dio/dio.dart';
import 'package:leafwise/core/services/api_service.dart';
import 'package:leafwise/features/seasonal_ai/models/seasonal_ai_models.dart';

/// Service for handling seasonal AI predictions and environmental data integration
class SeasonalAIService {
  final ApiService _apiService;

  SeasonalAIService(this._apiService);

  // Seasonal Predictions
  Future<List<SeasonalPrediction>> getSeasonalPredictions(
    String plantId,
  ) async {
    try {
      final response = await _apiService.get(
        '/v1/plants/$plantId/seasonal-predictions',
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => SeasonalPrediction.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SeasonalPrediction> createCustomPrediction({
    required String plantId,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? customParameters,
  }) async {
    try {
      final requestData = {
        'plant_id': plantId,
        'location': location,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (customParameters != null) ...customParameters,
      };

      final response = await _apiService.post(
        '/v1/seasonal-ai/predict',
        data: requestData,
      );
      return SeasonalPrediction.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Care Adjustments
  Future<List<CareAdjustment>> getCareAdjustments(String plantId) async {
    try {
      final response = await _apiService.get(
        '/v1/seasonal-ai/care-adjustments/$plantId',
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CareAdjustment.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<CareAdjustment>> getSeasonalCareRecommendations({
    required String plantId,
    required String season,
    String? location,
  }) async {
    try {
      final queryParams = {
        'season': season,
        if (location != null) 'location': location,
      };

      final response = await _apiService.get(
        '/v1/seasonal-ai/care-adjustments/$plantId/recommendations',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CareAdjustment.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Environmental Data
  Future<EnvironmentalData> getCurrentEnvironmentalData(String location) async {
    try {
      final response = await _apiService.get(
        '/v1/environmental-data/current',
        queryParameters: {'location': location},
      );
      return EnvironmentalData.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EnvironmentalData>> getEnvironmentalForecast({
    required String location,
    required int days,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/environmental-data/forecast',
        queryParameters: {'location': location, 'days': days},
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => EnvironmentalData.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ClimateData> getClimateData({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/environmental-data/climate',
        queryParameters: {
          'location': location,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return ClimateData.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Risk Factors
  Future<List<RiskFactor>> getRiskFactors({
    required String plantId,
    String? location,
    String? season,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (location != null) queryParams['location'] = location;
      if (season != null) queryParams['season'] = season;

      final response = await _apiService.get(
        '/v1/seasonal-ai/risk-factors/$plantId',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => RiskFactor.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Seasonal Transitions
  Future<List<SeasonalTransition>> getSeasonalTransitions({
    required String location,
    required int year,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/seasonal-ai/transitions',
        queryParameters: {'location': location, 'year': year},
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => SeasonalTransition.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SeasonalTransition?> getCurrentSeasonalTransition(
    String location,
  ) async {
    try {
      final response = await _apiService.get(
        '/v1/seasonal-ai/transitions/current',
        queryParameters: {'location': location},
      );
      final data = response['data'];
      return data != null ? SeasonalTransition.fromJson(data) : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Growth Forecasts
  Future<List<GrowthForecast>> getGrowthForecasts({
    required String plantId,
    required String season,
    String? location,
  }) async {
    try {
      final queryParams = {
        'season': season,
        if (location != null) 'location': location,
      };

      final response = await _apiService.get(
        '/v1/seasonal-ai/growth-forecasts/$plantId',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => GrowthForecast.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Pest Risk Data
  Future<List<PestRisk>> getPestRisks({
    required String plantId,
    required String location,
    String? season,
  }) async {
    try {
      final queryParams = {
        'location': location,
        if (season != null) 'season': season,
      };

      final response = await _apiService.get(
        '/v1/seasonal-ai/pest-risks/$plantId',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PestRisk.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Weather Forecast
  Future<WeatherForecast> getWeatherForecast({
    required String location,
    required int days,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/environmental-data/weather-forecast',
        queryParameters: {'location': location, 'days': days},
      );
      return WeatherForecast.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Synchronization
  Future<void> syncEnvironmentalData(String location) async {
    try {
      await _apiService.post(
        '/v1/environmental-data/sync',
        data: {'location': location},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDataSyncStatus(String location) async {
    try {
      final response = await _apiService.get(
        '/v1/environmental-data/sync-status',
        queryParameters: {'location': location},
      );
      return response['data'] ?? {};
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
