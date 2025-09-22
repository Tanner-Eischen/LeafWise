/// State management models for seasonal AI
///
/// This file contains state management classes for seasonal AI features.
/// Uses Freezed for immutable data classes with JSON serialization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leafwise/features/seasonal_ai/models/care_models.dart';
import 'prediction_models.dart';
import 'environmental_models.dart';
import 'transition_and_phase_models.dart';

part 'state_models.freezed.dart';
part 'state_models.g.dart';

/// State management for seasonal AI features
@freezed
class SeasonalAIState with _$SeasonalAIState {
  const factory SeasonalAIState({
    // Loading states
    @Default(false) bool isLoadingPredictions,
    @Default(false) bool isLoadingCareAdjustments,
    @Default(false) bool isLoadingEnvironmentalData,
    @Default(false) bool isLoadingClimateData,
    @Default(false) bool isLoadingRiskFactors,
    @Default(false) bool isLoadingTransitions,
    @Default(false) bool isLoadingGrowthForecasts,
    @Default(false) bool isLoadingWeatherForecast,
    @Default(false) bool isCreating,
    @Default(false) bool isSyncing,

    // Data fields
    @Default([]) List<SeasonalPrediction> seasonalPredictions,
    @Default([]) List<CareAdjustment> careAdjustments,
    EnvironmentalData? currentEnvironmentalData,
    @Default([]) List<RiskFactor> riskFactors,
    @Default([]) List<SeasonalTransition> seasonalTransitions,
    SeasonalTransition? currentSeasonalTransition,
    @Default([]) List<GrowthForecast> growthForecasts,
    WeatherForecast? weatherForecast,
    @Default([]) List<EnvironmentalData> environmentalForecast,
    ClimateData? climateData,

    // Status and error fields
    String? syncStatus,
    String? error,
    String? createError,
    String? syncError,
    DateTime? lastUpdated,
  }) = _SeasonalAIState;

  factory SeasonalAIState.fromJson(Map<String, dynamic> json) =>
      _$SeasonalAIStateFromJson(json);
}
