// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonalAIStateImpl _$$SeasonalAIStateImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalAIStateImpl(
      isLoadingPredictions: json['isLoadingPredictions'] as bool? ?? false,
      isLoadingCareAdjustments:
          json['isLoadingCareAdjustments'] as bool? ?? false,
      isLoadingEnvironmentalData:
          json['isLoadingEnvironmentalData'] as bool? ?? false,
      isLoadingClimateData: json['isLoadingClimateData'] as bool? ?? false,
      isLoadingRiskFactors: json['isLoadingRiskFactors'] as bool? ?? false,
      isLoadingTransitions: json['isLoadingTransitions'] as bool? ?? false,
      isLoadingGrowthForecasts:
          json['isLoadingGrowthForecasts'] as bool? ?? false,
      isLoadingWeatherForecast:
          json['isLoadingWeatherForecast'] as bool? ?? false,
      isCreating: json['isCreating'] as bool? ?? false,
      isSyncing: json['isSyncing'] as bool? ?? false,
      seasonalPredictions: (json['seasonalPredictions'] as List<dynamic>?)
              ?.map(
                  (e) => SeasonalPrediction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      careAdjustments: (json['careAdjustments'] as List<dynamic>?)
              ?.map((e) => CareAdjustment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentEnvironmentalData: json['currentEnvironmentalData'] == null
          ? null
          : EnvironmentalData.fromJson(
              json['currentEnvironmentalData'] as Map<String, dynamic>),
      riskFactors: (json['riskFactors'] as List<dynamic>?)
              ?.map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seasonalTransitions: (json['seasonalTransitions'] as List<dynamic>?)
              ?.map(
                  (e) => SeasonalTransition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentSeasonalTransition: json['currentSeasonalTransition'] == null
          ? null
          : SeasonalTransition.fromJson(
              json['currentSeasonalTransition'] as Map<String, dynamic>),
      growthForecasts: (json['growthForecasts'] as List<dynamic>?)
              ?.map((e) => GrowthForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weatherForecast: json['weatherForecast'] == null
          ? null
          : WeatherForecast.fromJson(
              json['weatherForecast'] as Map<String, dynamic>),
      environmentalForecast: (json['environmentalForecast'] as List<dynamic>?)
              ?.map(
                  (e) => EnvironmentalData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      climateData: json['climateData'] == null
          ? null
          : ClimateData.fromJson(json['climateData'] as Map<String, dynamic>),
      syncStatus: json['syncStatus'] as String?,
      error: json['error'] as String?,
      createError: json['createError'] as String?,
      syncError: json['syncError'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$SeasonalAIStateImplToJson(
        _$SeasonalAIStateImpl instance) =>
    <String, dynamic>{
      'isLoadingPredictions': instance.isLoadingPredictions,
      'isLoadingCareAdjustments': instance.isLoadingCareAdjustments,
      'isLoadingEnvironmentalData': instance.isLoadingEnvironmentalData,
      'isLoadingClimateData': instance.isLoadingClimateData,
      'isLoadingRiskFactors': instance.isLoadingRiskFactors,
      'isLoadingTransitions': instance.isLoadingTransitions,
      'isLoadingGrowthForecasts': instance.isLoadingGrowthForecasts,
      'isLoadingWeatherForecast': instance.isLoadingWeatherForecast,
      'isCreating': instance.isCreating,
      'isSyncing': instance.isSyncing,
      'seasonalPredictions': instance.seasonalPredictions,
      'careAdjustments': instance.careAdjustments,
      'currentEnvironmentalData': instance.currentEnvironmentalData,
      'riskFactors': instance.riskFactors,
      'seasonalTransitions': instance.seasonalTransitions,
      'currentSeasonalTransition': instance.currentSeasonalTransition,
      'growthForecasts': instance.growthForecasts,
      'weatherForecast': instance.weatherForecast,
      'environmentalForecast': instance.environmentalForecast,
      'climateData': instance.climateData,
      'syncStatus': instance.syncStatus,
      'error': instance.error,
      'createError': instance.createError,
      'syncError': instance.syncError,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
