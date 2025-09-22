/// Care and risk models for seasonal AI
/// 
/// This file contains data models related to care adjustments, risk factors, and plant activities.
/// Uses Freezed for immutable data classes with JSON serialization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'care_models.freezed.dart';
part 'care_models.g.dart';

/// Care adjustment recommendations
@freezed
class CareAdjustment with _$CareAdjustment {
  const factory CareAdjustment({
    required String careType,
    required String adjustmentType,
    required String description,
    required DateTime effectiveDate,
    required String priority,
    Map<String, dynamic>? parameters,
  }) = _CareAdjustment;

  factory CareAdjustment.fromJson(Map<String, dynamic> json) =>
      _$CareAdjustmentFromJson(json);
}

/// Risk factors for seasonal challenges
@freezed
class RiskFactor with _$RiskFactor {
  const factory RiskFactor({
    required String riskType,
    required String severity,
    required double probability,
    required String description,
    required List<String> preventiveMeasures,
    DateTime? expectedDate,
  }) = _RiskFactor;

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);
}

/// Optimal plant activities for seasonal periods
@freezed
class PlantActivity with _$PlantActivity {
  const factory PlantActivity({
    required String activityType,
    required String title,
    required String description,
    required DateTime optimalDate,
    required String difficulty,
    List<String>? requiredSupplies,
  }) = _PlantActivity;

  factory PlantActivity.fromJson(Map<String, dynamic> json) =>
      _$PlantActivityFromJson(json);
}