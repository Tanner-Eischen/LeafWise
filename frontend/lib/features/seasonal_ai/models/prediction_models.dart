/// Core prediction models for seasonal AI
/// 
/// This file contains data models related to seasonal predictions and growth forecasts.
/// Uses Freezed for immutable data classes with JSON serialization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'care_models.dart';

part 'prediction_models.freezed.dart';
part 'prediction_models.g.dart';

/// Represents a comprehensive seasonal prediction for a plant
@freezed
class SeasonalPrediction with _$SeasonalPrediction {
  const factory SeasonalPrediction({
    required String plantId,
    required DateRange predictionPeriod,
    required GrowthForecast growthForecast,
    required List<CareAdjustment> careAdjustments,
    required List<RiskFactor> riskFactors,
    required List<PlantActivity> optimalActivities,
    required double confidenceScore,
    DateTime? generatedAt,
  }) = _SeasonalPrediction;

  factory SeasonalPrediction.fromJson(Map<String, dynamic> json) =>
      _$SeasonalPredictionFromJson(json);
}

/// Date range for predictions and seasonal periods
@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) = _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
}

/// Growth forecast with detailed projections
@freezed
class GrowthForecast with _$GrowthForecast {
  const factory GrowthForecast({
    required double expectedGrowthRate,
    required List<SizeProjection> sizeProjections,
    required List<FloweringPeriod> floweringPredictions,
    required List<DormancyPeriod> dormancyPeriods,
    required double stressLikelihood,
  }) = _GrowthForecast;

  factory GrowthForecast.fromJson(Map<String, dynamic> json) =>
      _$GrowthForecastFromJson(json);
}

/// Size projection for specific time periods
@freezed
class SizeProjection with _$SizeProjection {
  const factory SizeProjection({
    required DateTime projectionDate,
    required double estimatedHeight,
    required double estimatedWidth,
    required double confidenceLevel,
  }) = _SizeProjection;

  factory SizeProjection.fromJson(Map<String, dynamic> json) =>
      _$SizeProjectionFromJson(json);
}

/// Flowering period predictions
@freezed
class FloweringPeriod with _$FloweringPeriod {
  const factory FloweringPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String flowerType,
    required double probability,
    String? description,
  }) = _FloweringPeriod;

  factory FloweringPeriod.fromJson(Map<String, dynamic> json) =>
      _$FloweringPeriodFromJson(json);
}

/// Dormancy period predictions
@freezed
class DormancyPeriod with _$DormancyPeriod {
  const factory DormancyPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String dormancyType,
    required List<String> careModifications,
  }) = _DormancyPeriod;

  factory DormancyPeriod.fromJson(Map<String, dynamic> json) =>
      _$DormancyPeriodFromJson(json);
}