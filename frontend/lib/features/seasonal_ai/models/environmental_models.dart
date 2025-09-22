/// Environmental data models for seasonal AI
/// 
/// This file contains data models related to location, climate, weather, and pest risks.
/// Uses Freezed for immutable data classes with JSON serialization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'environmental_models.freezed.dart';
part 'environmental_models.g.dart';

/// Environmental data for seasonal predictions
@freezed
class EnvironmentalData with _$EnvironmentalData {
  const factory EnvironmentalData({
    required Location location,
    required ClimateData climateData,
    required DaylightPatterns daylightPatterns,
    required WeatherForecast weatherForecast,
    PestRiskData? pestRiskData,
  }) = _EnvironmentalData;

  factory EnvironmentalData.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalDataFromJson(json);
}

/// Geographic location information
@freezed
class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    String? city,
    String? region,
    String? country,
    String? timezone,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

/// Climate data for seasonal analysis
@freezed
class ClimateData with _$ClimateData {
  const factory ClimateData({
    required List<TemperatureData> temperatureHistory,
    required List<PrecipitationData> precipitationHistory,
    required List<HumidityData> humidityHistory,
    required String climateZone,
  }) = _ClimateData;

  factory ClimateData.fromJson(Map<String, dynamic> json) =>
      _$ClimateDataFromJson(json);
}

/// Temperature data point
@freezed
class TemperatureData with _$TemperatureData {
  const factory TemperatureData({
    required DateTime date,
    required double averageTemp,
    required double minTemp,
    required double maxTemp,
  }) = _TemperatureData;

  factory TemperatureData.fromJson(Map<String, dynamic> json) =>
      _$TemperatureDataFromJson(json);
}

/// Precipitation data point
@freezed
class PrecipitationData with _$PrecipitationData {
  const factory PrecipitationData({
    required DateTime date,
    required double amount,
    required String type,
  }) = _PrecipitationData;

  factory PrecipitationData.fromJson(Map<String, dynamic> json) =>
      _$PrecipitationDataFromJson(json);
}

/// Humidity data point
@freezed
class HumidityData with _$HumidityData {
  const factory HumidityData({
    required DateTime date,
    required double percentage,
  }) = _HumidityData;

  factory HumidityData.fromJson(Map<String, dynamic> json) =>
      _$HumidityDataFromJson(json);
}

/// Daylight patterns for seasonal calculations
@freezed
class DaylightPatterns with _$DaylightPatterns {
  const factory DaylightPatterns({
    required List<DaylightData> yearlyPattern,
    required DateTime lastUpdated,
  }) = _DaylightPatterns;

  factory DaylightPatterns.fromJson(Map<String, dynamic> json) =>
      _$DaylightPatternsFromJson(json);
}

/// Daily daylight information
@freezed
class DaylightData with _$DaylightData {
  const factory DaylightData({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    required double daylightHours,
  }) = _DaylightData;

  factory DaylightData.fromJson(Map<String, dynamic> json) =>
      _$DaylightDataFromJson(json);
}

/// Weather forecast data
@freezed
class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    required List<DailyForecast> dailyForecasts,
    required DateTime lastUpdated,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}

/// Daily weather forecast
@freezed
class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required DateTime date,
    required double temperature,
    required double humidity,
    required double precipitation,
    required String conditions,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
}

/// Pest risk assessment data
@freezed
class PestRiskData with _$PestRiskData {
  const factory PestRiskData({
    required List<PestRisk> risks,
    required DateTime assessmentDate,
  }) = _PestRiskData;

  factory PestRiskData.fromJson(Map<String, dynamic> json) =>
      _$PestRiskDataFromJson(json);
}

/// Individual pest risk
@freezed
class PestRisk with _$PestRisk {
  const factory PestRisk({
    required String pestType,
    required double riskLevel,
    required String description,
    required List<String> preventionMethods,
  }) = _PestRisk;

  factory PestRisk.fromJson(Map<String, dynamic> json) =>
      _$PestRiskFromJson(json);
}