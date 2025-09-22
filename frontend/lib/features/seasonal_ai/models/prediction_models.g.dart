// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonalPredictionImpl _$$SeasonalPredictionImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalPredictionImpl(
      plantId: json['plantId'] as String,
      predictionPeriod:
          DateRange.fromJson(json['predictionPeriod'] as Map<String, dynamic>),
      growthForecast: GrowthForecast.fromJson(
          json['growthForecast'] as Map<String, dynamic>),
      careAdjustments: (json['careAdjustments'] as List<dynamic>)
          .map((e) => CareAdjustment.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      optimalActivities: (json['optimalActivities'] as List<dynamic>)
          .map((e) => PlantActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$SeasonalPredictionImplToJson(
        _$SeasonalPredictionImpl instance) =>
    <String, dynamic>{
      'plantId': instance.plantId,
      'predictionPeriod': instance.predictionPeriod,
      'growthForecast': instance.growthForecast,
      'careAdjustments': instance.careAdjustments,
      'riskFactors': instance.riskFactors,
      'optimalActivities': instance.optimalActivities,
      'confidenceScore': instance.confidenceScore,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };

_$DateRangeImpl _$$DateRangeImplFromJson(Map<String, dynamic> json) =>
    _$DateRangeImpl(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$DateRangeImplToJson(_$DateRangeImpl instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

_$GrowthForecastImpl _$$GrowthForecastImplFromJson(Map<String, dynamic> json) =>
    _$GrowthForecastImpl(
      expectedGrowthRate: (json['expectedGrowthRate'] as num).toDouble(),
      sizeProjections: (json['sizeProjections'] as List<dynamic>)
          .map((e) => SizeProjection.fromJson(e as Map<String, dynamic>))
          .toList(),
      floweringPredictions: (json['floweringPredictions'] as List<dynamic>)
          .map((e) => FloweringPeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
      dormancyPeriods: (json['dormancyPeriods'] as List<dynamic>)
          .map((e) => DormancyPeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressLikelihood: (json['stressLikelihood'] as num).toDouble(),
    );

Map<String, dynamic> _$$GrowthForecastImplToJson(
        _$GrowthForecastImpl instance) =>
    <String, dynamic>{
      'expectedGrowthRate': instance.expectedGrowthRate,
      'sizeProjections': instance.sizeProjections,
      'floweringPredictions': instance.floweringPredictions,
      'dormancyPeriods': instance.dormancyPeriods,
      'stressLikelihood': instance.stressLikelihood,
    };

_$SizeProjectionImpl _$$SizeProjectionImplFromJson(Map<String, dynamic> json) =>
    _$SizeProjectionImpl(
      projectionDate: DateTime.parse(json['projectionDate'] as String),
      estimatedHeight: (json['estimatedHeight'] as num).toDouble(),
      estimatedWidth: (json['estimatedWidth'] as num).toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num).toDouble(),
    );

Map<String, dynamic> _$$SizeProjectionImplToJson(
        _$SizeProjectionImpl instance) =>
    <String, dynamic>{
      'projectionDate': instance.projectionDate.toIso8601String(),
      'estimatedHeight': instance.estimatedHeight,
      'estimatedWidth': instance.estimatedWidth,
      'confidenceLevel': instance.confidenceLevel,
    };

_$FloweringPeriodImpl _$$FloweringPeriodImplFromJson(
        Map<String, dynamic> json) =>
    _$FloweringPeriodImpl(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      flowerType: json['flowerType'] as String,
      probability: (json['probability'] as num).toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$FloweringPeriodImplToJson(
        _$FloweringPeriodImpl instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'flowerType': instance.flowerType,
      'probability': instance.probability,
      'description': instance.description,
    };

_$DormancyPeriodImpl _$$DormancyPeriodImplFromJson(Map<String, dynamic> json) =>
    _$DormancyPeriodImpl(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      dormancyType: json['dormancyType'] as String,
      careModifications: (json['careModifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DormancyPeriodImplToJson(
        _$DormancyPeriodImpl instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'dormancyType': instance.dormancyType,
      'careModifications': instance.careModifications,
    };
