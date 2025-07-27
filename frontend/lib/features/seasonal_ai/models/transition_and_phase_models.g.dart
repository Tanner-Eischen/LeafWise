// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transition_and_phase_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonalTransitionImpl _$$SeasonalTransitionImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonalTransitionImpl(
      fromSeason: json['fromSeason'] as String,
      toSeason: json['toSeason'] as String,
      transitionDate: DateTime.parse(json['transitionDate'] as String),
      indicators: (json['indicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$$SeasonalTransitionImplToJson(
        _$SeasonalTransitionImpl instance) =>
    <String, dynamic>{
      'fromSeason': instance.fromSeason,
      'toSeason': instance.toSeason,
      'transitionDate': instance.transitionDate.toIso8601String(),
      'indicators': instance.indicators,
      'confidence': instance.confidence,
    };

_$GrowthPhaseImpl _$$GrowthPhaseImplFromJson(Map<String, dynamic> json) =>
    _$GrowthPhaseImpl(
      phaseName: json['phaseName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      description: json['description'] as String,
      characteristics: (json['characteristics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendedCare: (json['recommendedCare'] as List<dynamic>)
          .map((e) => CareAdjustment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GrowthPhaseImplToJson(_$GrowthPhaseImpl instance) =>
    <String, dynamic>{
      'phaseName': instance.phaseName,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'description': instance.description,
      'characteristics': instance.characteristics,
      'recommendedCare': instance.recommendedCare,
    };
