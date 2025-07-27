/// Transition and growth phase models for seasonal AI
/// 
/// This file contains data models related to seasonal transitions and growth phases.
/// Uses Freezed for immutable data classes with JSON serialization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'care_models.dart';

part 'transition_and_phase_models.freezed.dart';
part 'transition_and_phase_models.g.dart';

/// Seasonal transition detection
@freezed
class SeasonalTransition with _$SeasonalTransition {
  const factory SeasonalTransition({
    required String fromSeason,
    required String toSeason,
    required DateTime transitionDate,
    required List<String> indicators,
    required double confidence,
  }) = _SeasonalTransition;

  factory SeasonalTransition.fromJson(Map<String, dynamic> json) =>
      _$SeasonalTransitionFromJson(json);
}

/// Growth phase prediction
@freezed
class GrowthPhase with _$GrowthPhase {
  const factory GrowthPhase({
    required String phaseName,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    required List<String> characteristics,
    required List<CareAdjustment> recommendedCare,
  }) = _GrowthPhase;

  factory GrowthPhase.fromJson(Map<String, dynamic> json) =>
      _$GrowthPhaseFromJson(json);
}