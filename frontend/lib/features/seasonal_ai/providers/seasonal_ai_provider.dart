import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/core/services/api_service.dart';
import 'package:plant_social/features/seasonal_ai/models/seasonal_ai_models.dart';
import 'package:plant_social/features/seasonal_ai/services/seasonal_ai_service.dart';

// Service provider
final seasonalAIServiceProvider = Provider<SeasonalAIService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SeasonalAIService(apiService);
});

// Main state provider
final seasonalAIProvider =
    StateNotifierProvider<SeasonalAINotifier, SeasonalAIState>((ref) {
      final service = ref.watch(seasonalAIServiceProvider);
      return SeasonalAINotifier(service);
    });

// Individual providers for specific use cases
final seasonalPredictionsProvider = Provider<List<SeasonalPrediction>>((ref) {
  return ref.watch(seasonalAIProvider).seasonalPredictions;
});

final careAdjustmentsProvider = Provider<List<CareAdjustment>>((ref) {
  return ref.watch(seasonalAIProvider).careAdjustments;
});

final environmentalDataProvider = Provider<EnvironmentalData?>((ref) {
  return ref.watch(seasonalAIProvider).currentEnvironmentalData;
});

final riskFactorsProvider = Provider<List<RiskFactor>>((ref) {
  return ref.watch(seasonalAIProvider).riskFactors;
});

// Individual seasonal prediction provider
final plantSeasonalPredictionsProvider =
    FutureProvider.family<List<SeasonalPrediction>, String>((
      ref,
      plantId,
    ) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getSeasonalPredictions(plantId);
    });

// Single seasonal prediction provider for a specific plant
final seasonalPredictionProvider =
    FutureProvider.family<SeasonalPrediction, String>((ref, plantId) async {
      final service = ref.watch(seasonalAIServiceProvider);
      final predictions = await service.getSeasonalPredictions(plantId);
      // Return the most recent prediction or throw an error if none exists
      if (predictions.isEmpty) {
        throw Exception('No seasonal predictions available for this plant');
      }
      return predictions.first;
    });

// Care adjustments provider for specific plant
final plantCareAdjustmentsProvider =
    FutureProvider.family<List<CareAdjustment>, String>((ref, plantId) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getCareAdjustments(plantId);
    });

// Environmental data provider for location
final locationEnvironmentalDataProvider =
    FutureProvider.family<EnvironmentalData, String>((ref, location) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getCurrentEnvironmentalData(location);
    });

// Weather forecast provider
final weatherForecastProvider =
    FutureProvider.family<WeatherForecast, WeatherForecastParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getWeatherForecast(
        location: params.location,
        days: params.days,
      );
    });

// Risk factors provider for plant and location
final plantRiskFactorsProvider =
    FutureProvider.family<List<RiskFactor>, RiskFactorParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getRiskFactors(
        plantId: params.plantId,
        location: params.location,
        season: params.season,
      );
    });

// Growth forecasts provider
final growthForecastsProvider =
    FutureProvider.family<List<GrowthForecast>, GrowthForecastParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getGrowthForecasts(
        plantId: params.plantId,
        season: params.season,
        location: params.location,
      );
    });

// Seasonal transitions provider
final seasonalTransitionsProvider =
    FutureProvider.family<List<SeasonalTransition>, SeasonalTransitionParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getSeasonalTransitions(
        location: params.location,
        year: params.year,
      );
    });

// Current seasonal transition provider
final currentSeasonalTransitionProvider =
    FutureProvider.family<SeasonalTransition?, String>((ref, location) async {
      final service = ref.watch(seasonalAIServiceProvider);
      return service.getCurrentSeasonalTransition(location);
    });

class SeasonalAINotifier extends StateNotifier<SeasonalAIState> {
  final SeasonalAIService _service;

  SeasonalAINotifier(this._service) : super(const SeasonalAIState());

  // Seasonal Predictions
  Future<void> loadSeasonalPredictions(String plantId) async {
    state = state.copyWith(isLoadingPredictions: true, error: null);
    try {
      final predictions = await _service.getSeasonalPredictions(plantId);
      state = state.copyWith(
        seasonalPredictions: predictions,
        isLoadingPredictions: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingPredictions: false, error: e.toString());
    }
  }

  Future<void> createCustomPrediction({
    required String plantId,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? customParameters,
  }) async {
    state = state.copyWith(isCreating: true, createError: null);
    try {
      final prediction = await _service.createCustomPrediction(
        plantId: plantId,
        location: location,
        startDate: startDate,
        endDate: endDate,
        customParameters: customParameters,
      );
      state = state.copyWith(
        seasonalPredictions: [...state.seasonalPredictions, prediction],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(isCreating: false, createError: e.toString());
      rethrow;
    }
  }

  // Care Adjustments
  Future<void> loadCareAdjustments(String plantId) async {
    state = state.copyWith(isLoadingCareAdjustments: true, error: null);
    try {
      final adjustments = await _service.getCareAdjustments(plantId);
      state = state.copyWith(
        careAdjustments: adjustments,
        isLoadingCareAdjustments: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCareAdjustments: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadSeasonalCareRecommendations({
    required String plantId,
    required String season,
    String? location,
  }) async {
    state = state.copyWith(isLoadingCareAdjustments: true, error: null);
    try {
      final recommendations = await _service.getSeasonalCareRecommendations(
        plantId: plantId,
        season: season,
        location: location,
      );
      state = state.copyWith(
        careAdjustments: recommendations,
        isLoadingCareAdjustments: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCareAdjustments: false,
        error: e.toString(),
      );
    }
  }

  // Environmental Data
  Future<void> loadCurrentEnvironmentalData(String location) async {
    state = state.copyWith(isLoadingEnvironmentalData: true, error: null);
    try {
      final data = await _service.getCurrentEnvironmentalData(location);
      state = state.copyWith(
        currentEnvironmentalData: data,
        isLoadingEnvironmentalData: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingEnvironmentalData: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadEnvironmentalForecast({
    required String location,
    required int days,
  }) async {
    state = state.copyWith(isLoadingEnvironmentalData: true, error: null);
    try {
      final forecast = await _service.getEnvironmentalForecast(
        location: location,
        days: days,
      );
      state = state.copyWith(
        environmentalForecast: forecast,
        isLoadingEnvironmentalData: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingEnvironmentalData: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadClimateData({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoadingClimateData: true, error: null);
    try {
      final data = await _service.getClimateData(
        location: location,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(climateData: data, isLoadingClimateData: false);
    } catch (e) {
      state = state.copyWith(isLoadingClimateData: false, error: e.toString());
    }
  }

  // Risk Factors
  Future<void> loadRiskFactors({
    required String plantId,
    String? location,
    String? season,
  }) async {
    state = state.copyWith(isLoadingRiskFactors: true, error: null);
    try {
      final risks = await _service.getRiskFactors(
        plantId: plantId,
        location: location,
        season: season,
      );
      state = state.copyWith(riskFactors: risks, isLoadingRiskFactors: false);
    } catch (e) {
      state = state.copyWith(isLoadingRiskFactors: false, error: e.toString());
    }
  }

  // Seasonal Transitions
  Future<void> loadSeasonalTransitions({
    required String location,
    required int year,
  }) async {
    state = state.copyWith(isLoadingTransitions: true, error: null);
    try {
      final transitions = await _service.getSeasonalTransitions(
        location: location,
        year: year,
      );
      state = state.copyWith(
        seasonalTransitions: transitions,
        isLoadingTransitions: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingTransitions: false, error: e.toString());
    }
  }

  Future<void> loadCurrentSeasonalTransition(String location) async {
    state = state.copyWith(isLoadingTransitions: true, error: null);
    try {
      final transition = await _service.getCurrentSeasonalTransition(location);
      state = state.copyWith(
        currentSeasonalTransition: transition,
        isLoadingTransitions: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingTransitions: false, error: e.toString());
    }
  }

  // Growth Forecasts
  Future<void> loadGrowthForecasts({
    required String plantId,
    required String season,
    String? location,
  }) async {
    state = state.copyWith(isLoadingGrowthForecasts: true, error: null);
    try {
      final forecasts = await _service.getGrowthForecasts(
        plantId: plantId,
        season: season,
        location: location,
      );
      state = state.copyWith(
        growthForecasts: forecasts,
        isLoadingGrowthForecasts: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingGrowthForecasts: false,
        error: e.toString(),
      );
    }
  }

  // Weather Forecast
  Future<void> loadWeatherForecast({
    required String location,
    required int days,
  }) async {
    state = state.copyWith(isLoadingWeatherForecast: true, error: null);
    try {
      final forecast = await _service.getWeatherForecast(
        location: location,
        days: days,
      );
      state = state.copyWith(
        weatherForecast: forecast,
        isLoadingWeatherForecast: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingWeatherForecast: false,
        error: e.toString(),
      );
    }
  }

  // Synchronization
  Future<void> syncEnvironmentalData(String location) async {
    state = state.copyWith(isSyncing: true, syncError: null);
    try {
      await _service.syncEnvironmentalData(location);
      state = state.copyWith(isSyncing: false);
      // Reload current environmental data after sync
      await loadCurrentEnvironmentalData(location);
    } catch (e) {
      state = state.copyWith(isSyncing: false, syncError: e.toString());
    }
  }

  Future<void> checkDataSyncStatus(String location) async {
    try {
      final statusData = await _service.getDataSyncStatus(location);
      // Extract status string from the response data
      final status = statusData['status']?.toString() ?? 'unknown';
      state = state.copyWith(syncStatus: status);
    } catch (e) {
      state = state.copyWith(syncError: e.toString());
    }
  }

  // Utility methods
  void clearErrors() {
    state = state.copyWith(error: null, createError: null, syncError: null);
  }

  void reset() {
    state = const SeasonalAIState();
  }

  // Auto-refresh functionality
  Future<void> refreshAllData({
    required String plantId,
    required String location,
  }) async {
    await Future.wait([
      loadSeasonalPredictions(plantId),
      loadCareAdjustments(plantId),
      loadCurrentEnvironmentalData(location),
      loadRiskFactors(plantId: plantId, location: location),
      loadCurrentSeasonalTransition(location),
    ]);
  }
}

// Helper classes for provider parameters
class WeatherForecastParams {
  final String location;
  final int days;

  const WeatherForecastParams({required this.location, required this.days});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherForecastParams &&
        other.location == location &&
        other.days == days;
  }

  @override
  int get hashCode => Object.hash(location, days);
}

class RiskFactorParams {
  final String plantId;
  final String? location;
  final String? season;

  const RiskFactorParams({required this.plantId, this.location, this.season});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RiskFactorParams &&
        other.plantId == plantId &&
        other.location == location &&
        other.season == season;
  }

  @override
  int get hashCode => Object.hash(plantId, location, season);
}

class GrowthForecastParams {
  final String plantId;
  final String season;
  final String? location;

  const GrowthForecastParams({
    required this.plantId,
    required this.season,
    this.location,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthForecastParams &&
        other.plantId == plantId &&
        other.season == season &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(plantId, season, location);
}

class SeasonalTransitionParams {
  final String location;
  final int year;

  const SeasonalTransitionParams({required this.location, required this.year});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonalTransitionParams &&
        other.location == location &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(location, year);
}
