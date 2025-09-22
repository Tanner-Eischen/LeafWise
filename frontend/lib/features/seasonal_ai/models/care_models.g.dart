// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CareAdjustmentImpl _$$CareAdjustmentImplFromJson(Map<String, dynamic> json) =>
    _$CareAdjustmentImpl(
      careType: json['careType'] as String,
      adjustmentType: json['adjustmentType'] as String,
      description: json['description'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      priority: json['priority'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CareAdjustmentImplToJson(
        _$CareAdjustmentImpl instance) =>
    <String, dynamic>{
      'careType': instance.careType,
      'adjustmentType': instance.adjustmentType,
      'description': instance.description,
      'effectiveDate': instance.effectiveDate.toIso8601String(),
      'priority': instance.priority,
      'parameters': instance.parameters,
    };

_$RiskFactorImpl _$$RiskFactorImplFromJson(Map<String, dynamic> json) =>
    _$RiskFactorImpl(
      riskType: json['riskType'] as String,
      severity: json['severity'] as String,
      probability: (json['probability'] as num).toDouble(),
      description: json['description'] as String,
      preventiveMeasures: (json['preventiveMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      expectedDate: json['expectedDate'] == null
          ? null
          : DateTime.parse(json['expectedDate'] as String),
    );

Map<String, dynamic> _$$RiskFactorImplToJson(_$RiskFactorImpl instance) =>
    <String, dynamic>{
      'riskType': instance.riskType,
      'severity': instance.severity,
      'probability': instance.probability,
      'description': instance.description,
      'preventiveMeasures': instance.preventiveMeasures,
      'expectedDate': instance.expectedDate?.toIso8601String(),
    };

_$PlantActivityImpl _$$PlantActivityImplFromJson(Map<String, dynamic> json) =>
    _$PlantActivityImpl(
      activityType: json['activityType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      optimalDate: DateTime.parse(json['optimalDate'] as String),
      difficulty: json['difficulty'] as String,
      requiredSupplies: (json['requiredSupplies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PlantActivityImplToJson(_$PlantActivityImpl instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'title': instance.title,
      'description': instance.description,
      'optimalDate': instance.optimalDate.toIso8601String(),
      'difficulty': instance.difficulty,
      'requiredSupplies': instance.requiredSupplies,
    };
