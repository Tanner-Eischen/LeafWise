// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SeasonalPrediction _$SeasonalPredictionFromJson(Map<String, dynamic> json) {
  return _SeasonalPrediction.fromJson(json);
}

/// @nodoc
mixin _$SeasonalPrediction {
  String get plantId => throw _privateConstructorUsedError;
  DateRange get predictionPeriod => throw _privateConstructorUsedError;
  GrowthForecast get growthForecast => throw _privateConstructorUsedError;
  List<CareAdjustment> get careAdjustments =>
      throw _privateConstructorUsedError;
  List<RiskFactor> get riskFactors => throw _privateConstructorUsedError;
  List<PlantActivity> get optimalActivities =>
      throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this SeasonalPrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonalPredictionCopyWith<SeasonalPrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalPredictionCopyWith<$Res> {
  factory $SeasonalPredictionCopyWith(
          SeasonalPrediction value, $Res Function(SeasonalPrediction) then) =
      _$SeasonalPredictionCopyWithImpl<$Res, SeasonalPrediction>;
  @useResult
  $Res call(
      {String plantId,
      DateRange predictionPeriod,
      GrowthForecast growthForecast,
      List<CareAdjustment> careAdjustments,
      List<RiskFactor> riskFactors,
      List<PlantActivity> optimalActivities,
      double confidenceScore,
      DateTime? generatedAt});

  $DateRangeCopyWith<$Res> get predictionPeriod;
  $GrowthForecastCopyWith<$Res> get growthForecast;
}

/// @nodoc
class _$SeasonalPredictionCopyWithImpl<$Res, $Val extends SeasonalPrediction>
    implements $SeasonalPredictionCopyWith<$Res> {
  _$SeasonalPredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plantId = null,
    Object? predictionPeriod = null,
    Object? growthForecast = null,
    Object? careAdjustments = null,
    Object? riskFactors = null,
    Object? optimalActivities = null,
    Object? confidenceScore = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      predictionPeriod: null == predictionPeriod
          ? _value.predictionPeriod
          : predictionPeriod // ignore: cast_nullable_to_non_nullable
              as DateRange,
      growthForecast: null == growthForecast
          ? _value.growthForecast
          : growthForecast // ignore: cast_nullable_to_non_nullable
              as GrowthForecast,
      careAdjustments: null == careAdjustments
          ? _value.careAdjustments
          : careAdjustments // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      optimalActivities: null == optimalActivities
          ? _value.optimalActivities
          : optimalActivities // ignore: cast_nullable_to_non_nullable
              as List<PlantActivity>,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get predictionPeriod {
    return $DateRangeCopyWith<$Res>(_value.predictionPeriod, (value) {
      return _then(_value.copyWith(predictionPeriod: value) as $Val);
    });
  }

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GrowthForecastCopyWith<$Res> get growthForecast {
    return $GrowthForecastCopyWith<$Res>(_value.growthForecast, (value) {
      return _then(_value.copyWith(growthForecast: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeasonalPredictionImplCopyWith<$Res>
    implements $SeasonalPredictionCopyWith<$Res> {
  factory _$$SeasonalPredictionImplCopyWith(_$SeasonalPredictionImpl value,
          $Res Function(_$SeasonalPredictionImpl) then) =
      __$$SeasonalPredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String plantId,
      DateRange predictionPeriod,
      GrowthForecast growthForecast,
      List<CareAdjustment> careAdjustments,
      List<RiskFactor> riskFactors,
      List<PlantActivity> optimalActivities,
      double confidenceScore,
      DateTime? generatedAt});

  @override
  $DateRangeCopyWith<$Res> get predictionPeriod;
  @override
  $GrowthForecastCopyWith<$Res> get growthForecast;
}

/// @nodoc
class __$$SeasonalPredictionImplCopyWithImpl<$Res>
    extends _$SeasonalPredictionCopyWithImpl<$Res, _$SeasonalPredictionImpl>
    implements _$$SeasonalPredictionImplCopyWith<$Res> {
  __$$SeasonalPredictionImplCopyWithImpl(_$SeasonalPredictionImpl _value,
      $Res Function(_$SeasonalPredictionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plantId = null,
    Object? predictionPeriod = null,
    Object? growthForecast = null,
    Object? careAdjustments = null,
    Object? riskFactors = null,
    Object? optimalActivities = null,
    Object? confidenceScore = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_$SeasonalPredictionImpl(
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      predictionPeriod: null == predictionPeriod
          ? _value.predictionPeriod
          : predictionPeriod // ignore: cast_nullable_to_non_nullable
              as DateRange,
      growthForecast: null == growthForecast
          ? _value.growthForecast
          : growthForecast // ignore: cast_nullable_to_non_nullable
              as GrowthForecast,
      careAdjustments: null == careAdjustments
          ? _value._careAdjustments
          : careAdjustments // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      optimalActivities: null == optimalActivities
          ? _value._optimalActivities
          : optimalActivities // ignore: cast_nullable_to_non_nullable
              as List<PlantActivity>,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalPredictionImpl implements _SeasonalPrediction {
  const _$SeasonalPredictionImpl(
      {required this.plantId,
      required this.predictionPeriod,
      required this.growthForecast,
      required final List<CareAdjustment> careAdjustments,
      required final List<RiskFactor> riskFactors,
      required final List<PlantActivity> optimalActivities,
      required this.confidenceScore,
      this.generatedAt})
      : _careAdjustments = careAdjustments,
        _riskFactors = riskFactors,
        _optimalActivities = optimalActivities;

  factory _$SeasonalPredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalPredictionImplFromJson(json);

  @override
  final String plantId;
  @override
  final DateRange predictionPeriod;
  @override
  final GrowthForecast growthForecast;
  final List<CareAdjustment> _careAdjustments;
  @override
  List<CareAdjustment> get careAdjustments {
    if (_careAdjustments is EqualUnmodifiableListView) return _careAdjustments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_careAdjustments);
  }

  final List<RiskFactor> _riskFactors;
  @override
  List<RiskFactor> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  final List<PlantActivity> _optimalActivities;
  @override
  List<PlantActivity> get optimalActivities {
    if (_optimalActivities is EqualUnmodifiableListView)
      return _optimalActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optimalActivities);
  }

  @override
  final double confidenceScore;
  @override
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'SeasonalPrediction(plantId: $plantId, predictionPeriod: $predictionPeriod, growthForecast: $growthForecast, careAdjustments: $careAdjustments, riskFactors: $riskFactors, optimalActivities: $optimalActivities, confidenceScore: $confidenceScore, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalPredictionImpl &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.predictionPeriod, predictionPeriod) ||
                other.predictionPeriod == predictionPeriod) &&
            (identical(other.growthForecast, growthForecast) ||
                other.growthForecast == growthForecast) &&
            const DeepCollectionEquality()
                .equals(other._careAdjustments, _careAdjustments) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            const DeepCollectionEquality()
                .equals(other._optimalActivities, _optimalActivities) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      plantId,
      predictionPeriod,
      growthForecast,
      const DeepCollectionEquality().hash(_careAdjustments),
      const DeepCollectionEquality().hash(_riskFactors),
      const DeepCollectionEquality().hash(_optimalActivities),
      confidenceScore,
      generatedAt);

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalPredictionImplCopyWith<_$SeasonalPredictionImpl> get copyWith =>
      __$$SeasonalPredictionImplCopyWithImpl<_$SeasonalPredictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalPredictionImplToJson(
      this,
    );
  }
}

abstract class _SeasonalPrediction implements SeasonalPrediction {
  const factory _SeasonalPrediction(
      {required final String plantId,
      required final DateRange predictionPeriod,
      required final GrowthForecast growthForecast,
      required final List<CareAdjustment> careAdjustments,
      required final List<RiskFactor> riskFactors,
      required final List<PlantActivity> optimalActivities,
      required final double confidenceScore,
      final DateTime? generatedAt}) = _$SeasonalPredictionImpl;

  factory _SeasonalPrediction.fromJson(Map<String, dynamic> json) =
      _$SeasonalPredictionImpl.fromJson;

  @override
  String get plantId;
  @override
  DateRange get predictionPeriod;
  @override
  GrowthForecast get growthForecast;
  @override
  List<CareAdjustment> get careAdjustments;
  @override
  List<RiskFactor> get riskFactors;
  @override
  List<PlantActivity> get optimalActivities;
  @override
  double get confidenceScore;
  @override
  DateTime? get generatedAt;

  /// Create a copy of SeasonalPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonalPredictionImplCopyWith<_$SeasonalPredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DateRange _$DateRangeFromJson(Map<String, dynamic> json) {
  return _DateRange.fromJson(json);
}

/// @nodoc
mixin _$DateRange {
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Serializes this DateRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DateRangeCopyWith<DateRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DateRangeCopyWith<$Res> {
  factory $DateRangeCopyWith(DateRange value, $Res Function(DateRange) then) =
      _$DateRangeCopyWithImpl<$Res, DateRange>;
  @useResult
  $Res call({DateTime startDate, DateTime endDate});
}

/// @nodoc
class _$DateRangeCopyWithImpl<$Res, $Val extends DateRange>
    implements $DateRangeCopyWith<$Res> {
  _$DateRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_value.copyWith(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DateRangeImplCopyWith<$Res>
    implements $DateRangeCopyWith<$Res> {
  factory _$$DateRangeImplCopyWith(
          _$DateRangeImpl value, $Res Function(_$DateRangeImpl) then) =
      __$$DateRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime startDate, DateTime endDate});
}

/// @nodoc
class __$$DateRangeImplCopyWithImpl<$Res>
    extends _$DateRangeCopyWithImpl<$Res, _$DateRangeImpl>
    implements _$$DateRangeImplCopyWith<$Res> {
  __$$DateRangeImplCopyWithImpl(
      _$DateRangeImpl _value, $Res Function(_$DateRangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$DateRangeImpl(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DateRangeImpl implements _DateRange {
  const _$DateRangeImpl({required this.startDate, required this.endDate});

  factory _$DateRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DateRangeImplFromJson(json);

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'DateRange(startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DateRangeImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate);

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DateRangeImplCopyWith<_$DateRangeImpl> get copyWith =>
      __$$DateRangeImplCopyWithImpl<_$DateRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DateRangeImplToJson(
      this,
    );
  }
}

abstract class _DateRange implements DateRange {
  const factory _DateRange(
      {required final DateTime startDate,
      required final DateTime endDate}) = _$DateRangeImpl;

  factory _DateRange.fromJson(Map<String, dynamic> json) =
      _$DateRangeImpl.fromJson;

  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DateRangeImplCopyWith<_$DateRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrowthForecast _$GrowthForecastFromJson(Map<String, dynamic> json) {
  return _GrowthForecast.fromJson(json);
}

/// @nodoc
mixin _$GrowthForecast {
  double get expectedGrowthRate => throw _privateConstructorUsedError;
  List<SizeProjection> get sizeProjections =>
      throw _privateConstructorUsedError;
  List<FloweringPeriod> get floweringPredictions =>
      throw _privateConstructorUsedError;
  List<DormancyPeriod> get dormancyPeriods =>
      throw _privateConstructorUsedError;
  double get stressLikelihood => throw _privateConstructorUsedError;

  /// Serializes this GrowthForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrowthForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrowthForecastCopyWith<GrowthForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrowthForecastCopyWith<$Res> {
  factory $GrowthForecastCopyWith(
          GrowthForecast value, $Res Function(GrowthForecast) then) =
      _$GrowthForecastCopyWithImpl<$Res, GrowthForecast>;
  @useResult
  $Res call(
      {double expectedGrowthRate,
      List<SizeProjection> sizeProjections,
      List<FloweringPeriod> floweringPredictions,
      List<DormancyPeriod> dormancyPeriods,
      double stressLikelihood});
}

/// @nodoc
class _$GrowthForecastCopyWithImpl<$Res, $Val extends GrowthForecast>
    implements $GrowthForecastCopyWith<$Res> {
  _$GrowthForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrowthForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedGrowthRate = null,
    Object? sizeProjections = null,
    Object? floweringPredictions = null,
    Object? dormancyPeriods = null,
    Object? stressLikelihood = null,
  }) {
    return _then(_value.copyWith(
      expectedGrowthRate: null == expectedGrowthRate
          ? _value.expectedGrowthRate
          : expectedGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      sizeProjections: null == sizeProjections
          ? _value.sizeProjections
          : sizeProjections // ignore: cast_nullable_to_non_nullable
              as List<SizeProjection>,
      floweringPredictions: null == floweringPredictions
          ? _value.floweringPredictions
          : floweringPredictions // ignore: cast_nullable_to_non_nullable
              as List<FloweringPeriod>,
      dormancyPeriods: null == dormancyPeriods
          ? _value.dormancyPeriods
          : dormancyPeriods // ignore: cast_nullable_to_non_nullable
              as List<DormancyPeriod>,
      stressLikelihood: null == stressLikelihood
          ? _value.stressLikelihood
          : stressLikelihood // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrowthForecastImplCopyWith<$Res>
    implements $GrowthForecastCopyWith<$Res> {
  factory _$$GrowthForecastImplCopyWith(_$GrowthForecastImpl value,
          $Res Function(_$GrowthForecastImpl) then) =
      __$$GrowthForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double expectedGrowthRate,
      List<SizeProjection> sizeProjections,
      List<FloweringPeriod> floweringPredictions,
      List<DormancyPeriod> dormancyPeriods,
      double stressLikelihood});
}

/// @nodoc
class __$$GrowthForecastImplCopyWithImpl<$Res>
    extends _$GrowthForecastCopyWithImpl<$Res, _$GrowthForecastImpl>
    implements _$$GrowthForecastImplCopyWith<$Res> {
  __$$GrowthForecastImplCopyWithImpl(
      _$GrowthForecastImpl _value, $Res Function(_$GrowthForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrowthForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expectedGrowthRate = null,
    Object? sizeProjections = null,
    Object? floweringPredictions = null,
    Object? dormancyPeriods = null,
    Object? stressLikelihood = null,
  }) {
    return _then(_$GrowthForecastImpl(
      expectedGrowthRate: null == expectedGrowthRate
          ? _value.expectedGrowthRate
          : expectedGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      sizeProjections: null == sizeProjections
          ? _value._sizeProjections
          : sizeProjections // ignore: cast_nullable_to_non_nullable
              as List<SizeProjection>,
      floweringPredictions: null == floweringPredictions
          ? _value._floweringPredictions
          : floweringPredictions // ignore: cast_nullable_to_non_nullable
              as List<FloweringPeriod>,
      dormancyPeriods: null == dormancyPeriods
          ? _value._dormancyPeriods
          : dormancyPeriods // ignore: cast_nullable_to_non_nullable
              as List<DormancyPeriod>,
      stressLikelihood: null == stressLikelihood
          ? _value.stressLikelihood
          : stressLikelihood // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrowthForecastImpl implements _GrowthForecast {
  const _$GrowthForecastImpl(
      {required this.expectedGrowthRate,
      required final List<SizeProjection> sizeProjections,
      required final List<FloweringPeriod> floweringPredictions,
      required final List<DormancyPeriod> dormancyPeriods,
      required this.stressLikelihood})
      : _sizeProjections = sizeProjections,
        _floweringPredictions = floweringPredictions,
        _dormancyPeriods = dormancyPeriods;

  factory _$GrowthForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrowthForecastImplFromJson(json);

  @override
  final double expectedGrowthRate;
  final List<SizeProjection> _sizeProjections;
  @override
  List<SizeProjection> get sizeProjections {
    if (_sizeProjections is EqualUnmodifiableListView) return _sizeProjections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sizeProjections);
  }

  final List<FloweringPeriod> _floweringPredictions;
  @override
  List<FloweringPeriod> get floweringPredictions {
    if (_floweringPredictions is EqualUnmodifiableListView)
      return _floweringPredictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_floweringPredictions);
  }

  final List<DormancyPeriod> _dormancyPeriods;
  @override
  List<DormancyPeriod> get dormancyPeriods {
    if (_dormancyPeriods is EqualUnmodifiableListView) return _dormancyPeriods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dormancyPeriods);
  }

  @override
  final double stressLikelihood;

  @override
  String toString() {
    return 'GrowthForecast(expectedGrowthRate: $expectedGrowthRate, sizeProjections: $sizeProjections, floweringPredictions: $floweringPredictions, dormancyPeriods: $dormancyPeriods, stressLikelihood: $stressLikelihood)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrowthForecastImpl &&
            (identical(other.expectedGrowthRate, expectedGrowthRate) ||
                other.expectedGrowthRate == expectedGrowthRate) &&
            const DeepCollectionEquality()
                .equals(other._sizeProjections, _sizeProjections) &&
            const DeepCollectionEquality()
                .equals(other._floweringPredictions, _floweringPredictions) &&
            const DeepCollectionEquality()
                .equals(other._dormancyPeriods, _dormancyPeriods) &&
            (identical(other.stressLikelihood, stressLikelihood) ||
                other.stressLikelihood == stressLikelihood));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      expectedGrowthRate,
      const DeepCollectionEquality().hash(_sizeProjections),
      const DeepCollectionEquality().hash(_floweringPredictions),
      const DeepCollectionEquality().hash(_dormancyPeriods),
      stressLikelihood);

  /// Create a copy of GrowthForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrowthForecastImplCopyWith<_$GrowthForecastImpl> get copyWith =>
      __$$GrowthForecastImplCopyWithImpl<_$GrowthForecastImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrowthForecastImplToJson(
      this,
    );
  }
}

abstract class _GrowthForecast implements GrowthForecast {
  const factory _GrowthForecast(
      {required final double expectedGrowthRate,
      required final List<SizeProjection> sizeProjections,
      required final List<FloweringPeriod> floweringPredictions,
      required final List<DormancyPeriod> dormancyPeriods,
      required final double stressLikelihood}) = _$GrowthForecastImpl;

  factory _GrowthForecast.fromJson(Map<String, dynamic> json) =
      _$GrowthForecastImpl.fromJson;

  @override
  double get expectedGrowthRate;
  @override
  List<SizeProjection> get sizeProjections;
  @override
  List<FloweringPeriod> get floweringPredictions;
  @override
  List<DormancyPeriod> get dormancyPeriods;
  @override
  double get stressLikelihood;

  /// Create a copy of GrowthForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrowthForecastImplCopyWith<_$GrowthForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SizeProjection _$SizeProjectionFromJson(Map<String, dynamic> json) {
  return _SizeProjection.fromJson(json);
}

/// @nodoc
mixin _$SizeProjection {
  DateTime get projectionDate => throw _privateConstructorUsedError;
  double get estimatedHeight => throw _privateConstructorUsedError;
  double get estimatedWidth => throw _privateConstructorUsedError;
  double get confidenceLevel => throw _privateConstructorUsedError;

  /// Serializes this SizeProjection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SizeProjection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SizeProjectionCopyWith<SizeProjection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SizeProjectionCopyWith<$Res> {
  factory $SizeProjectionCopyWith(
          SizeProjection value, $Res Function(SizeProjection) then) =
      _$SizeProjectionCopyWithImpl<$Res, SizeProjection>;
  @useResult
  $Res call(
      {DateTime projectionDate,
      double estimatedHeight,
      double estimatedWidth,
      double confidenceLevel});
}

/// @nodoc
class _$SizeProjectionCopyWithImpl<$Res, $Val extends SizeProjection>
    implements $SizeProjectionCopyWith<$Res> {
  _$SizeProjectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SizeProjection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projectionDate = null,
    Object? estimatedHeight = null,
    Object? estimatedWidth = null,
    Object? confidenceLevel = null,
  }) {
    return _then(_value.copyWith(
      projectionDate: null == projectionDate
          ? _value.projectionDate
          : projectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedHeight: null == estimatedHeight
          ? _value.estimatedHeight
          : estimatedHeight // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedWidth: null == estimatedWidth
          ? _value.estimatedWidth
          : estimatedWidth // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceLevel: null == confidenceLevel
          ? _value.confidenceLevel
          : confidenceLevel // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SizeProjectionImplCopyWith<$Res>
    implements $SizeProjectionCopyWith<$Res> {
  factory _$$SizeProjectionImplCopyWith(_$SizeProjectionImpl value,
          $Res Function(_$SizeProjectionImpl) then) =
      __$$SizeProjectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime projectionDate,
      double estimatedHeight,
      double estimatedWidth,
      double confidenceLevel});
}

/// @nodoc
class __$$SizeProjectionImplCopyWithImpl<$Res>
    extends _$SizeProjectionCopyWithImpl<$Res, _$SizeProjectionImpl>
    implements _$$SizeProjectionImplCopyWith<$Res> {
  __$$SizeProjectionImplCopyWithImpl(
      _$SizeProjectionImpl _value, $Res Function(_$SizeProjectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SizeProjection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projectionDate = null,
    Object? estimatedHeight = null,
    Object? estimatedWidth = null,
    Object? confidenceLevel = null,
  }) {
    return _then(_$SizeProjectionImpl(
      projectionDate: null == projectionDate
          ? _value.projectionDate
          : projectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedHeight: null == estimatedHeight
          ? _value.estimatedHeight
          : estimatedHeight // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedWidth: null == estimatedWidth
          ? _value.estimatedWidth
          : estimatedWidth // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceLevel: null == confidenceLevel
          ? _value.confidenceLevel
          : confidenceLevel // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SizeProjectionImpl implements _SizeProjection {
  const _$SizeProjectionImpl(
      {required this.projectionDate,
      required this.estimatedHeight,
      required this.estimatedWidth,
      required this.confidenceLevel});

  factory _$SizeProjectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SizeProjectionImplFromJson(json);

  @override
  final DateTime projectionDate;
  @override
  final double estimatedHeight;
  @override
  final double estimatedWidth;
  @override
  final double confidenceLevel;

  @override
  String toString() {
    return 'SizeProjection(projectionDate: $projectionDate, estimatedHeight: $estimatedHeight, estimatedWidth: $estimatedWidth, confidenceLevel: $confidenceLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SizeProjectionImpl &&
            (identical(other.projectionDate, projectionDate) ||
                other.projectionDate == projectionDate) &&
            (identical(other.estimatedHeight, estimatedHeight) ||
                other.estimatedHeight == estimatedHeight) &&
            (identical(other.estimatedWidth, estimatedWidth) ||
                other.estimatedWidth == estimatedWidth) &&
            (identical(other.confidenceLevel, confidenceLevel) ||
                other.confidenceLevel == confidenceLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, projectionDate, estimatedHeight,
      estimatedWidth, confidenceLevel);

  /// Create a copy of SizeProjection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SizeProjectionImplCopyWith<_$SizeProjectionImpl> get copyWith =>
      __$$SizeProjectionImplCopyWithImpl<_$SizeProjectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SizeProjectionImplToJson(
      this,
    );
  }
}

abstract class _SizeProjection implements SizeProjection {
  const factory _SizeProjection(
      {required final DateTime projectionDate,
      required final double estimatedHeight,
      required final double estimatedWidth,
      required final double confidenceLevel}) = _$SizeProjectionImpl;

  factory _SizeProjection.fromJson(Map<String, dynamic> json) =
      _$SizeProjectionImpl.fromJson;

  @override
  DateTime get projectionDate;
  @override
  double get estimatedHeight;
  @override
  double get estimatedWidth;
  @override
  double get confidenceLevel;

  /// Create a copy of SizeProjection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SizeProjectionImplCopyWith<_$SizeProjectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FloweringPeriod _$FloweringPeriodFromJson(Map<String, dynamic> json) {
  return _FloweringPeriod.fromJson(json);
}

/// @nodoc
mixin _$FloweringPeriod {
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get flowerType => throw _privateConstructorUsedError;
  double get probability => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this FloweringPeriod to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FloweringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FloweringPeriodCopyWith<FloweringPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FloweringPeriodCopyWith<$Res> {
  factory $FloweringPeriodCopyWith(
          FloweringPeriod value, $Res Function(FloweringPeriod) then) =
      _$FloweringPeriodCopyWithImpl<$Res, FloweringPeriod>;
  @useResult
  $Res call(
      {DateTime startDate,
      DateTime endDate,
      String flowerType,
      double probability,
      String? description});
}

/// @nodoc
class _$FloweringPeriodCopyWithImpl<$Res, $Val extends FloweringPeriod>
    implements $FloweringPeriodCopyWith<$Res> {
  _$FloweringPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FloweringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? flowerType = null,
    Object? probability = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flowerType: null == flowerType
          ? _value.flowerType
          : flowerType // ignore: cast_nullable_to_non_nullable
              as String,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FloweringPeriodImplCopyWith<$Res>
    implements $FloweringPeriodCopyWith<$Res> {
  factory _$$FloweringPeriodImplCopyWith(_$FloweringPeriodImpl value,
          $Res Function(_$FloweringPeriodImpl) then) =
      __$$FloweringPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startDate,
      DateTime endDate,
      String flowerType,
      double probability,
      String? description});
}

/// @nodoc
class __$$FloweringPeriodImplCopyWithImpl<$Res>
    extends _$FloweringPeriodCopyWithImpl<$Res, _$FloweringPeriodImpl>
    implements _$$FloweringPeriodImplCopyWith<$Res> {
  __$$FloweringPeriodImplCopyWithImpl(
      _$FloweringPeriodImpl _value, $Res Function(_$FloweringPeriodImpl) _then)
      : super(_value, _then);

  /// Create a copy of FloweringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? flowerType = null,
    Object? probability = null,
    Object? description = freezed,
  }) {
    return _then(_$FloweringPeriodImpl(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flowerType: null == flowerType
          ? _value.flowerType
          : flowerType // ignore: cast_nullable_to_non_nullable
              as String,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FloweringPeriodImpl implements _FloweringPeriod {
  const _$FloweringPeriodImpl(
      {required this.startDate,
      required this.endDate,
      required this.flowerType,
      required this.probability,
      this.description});

  factory _$FloweringPeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$FloweringPeriodImplFromJson(json);

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String flowerType;
  @override
  final double probability;
  @override
  final String? description;

  @override
  String toString() {
    return 'FloweringPeriod(startDate: $startDate, endDate: $endDate, flowerType: $flowerType, probability: $probability, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FloweringPeriodImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.flowerType, flowerType) ||
                other.flowerType == flowerType) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, startDate, endDate, flowerType, probability, description);

  /// Create a copy of FloweringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FloweringPeriodImplCopyWith<_$FloweringPeriodImpl> get copyWith =>
      __$$FloweringPeriodImplCopyWithImpl<_$FloweringPeriodImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FloweringPeriodImplToJson(
      this,
    );
  }
}

abstract class _FloweringPeriod implements FloweringPeriod {
  const factory _FloweringPeriod(
      {required final DateTime startDate,
      required final DateTime endDate,
      required final String flowerType,
      required final double probability,
      final String? description}) = _$FloweringPeriodImpl;

  factory _FloweringPeriod.fromJson(Map<String, dynamic> json) =
      _$FloweringPeriodImpl.fromJson;

  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get flowerType;
  @override
  double get probability;
  @override
  String? get description;

  /// Create a copy of FloweringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FloweringPeriodImplCopyWith<_$FloweringPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DormancyPeriod _$DormancyPeriodFromJson(Map<String, dynamic> json) {
  return _DormancyPeriod.fromJson(json);
}

/// @nodoc
mixin _$DormancyPeriod {
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get dormancyType => throw _privateConstructorUsedError;
  List<String> get careModifications => throw _privateConstructorUsedError;

  /// Serializes this DormancyPeriod to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DormancyPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DormancyPeriodCopyWith<DormancyPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DormancyPeriodCopyWith<$Res> {
  factory $DormancyPeriodCopyWith(
          DormancyPeriod value, $Res Function(DormancyPeriod) then) =
      _$DormancyPeriodCopyWithImpl<$Res, DormancyPeriod>;
  @useResult
  $Res call(
      {DateTime startDate,
      DateTime endDate,
      String dormancyType,
      List<String> careModifications});
}

/// @nodoc
class _$DormancyPeriodCopyWithImpl<$Res, $Val extends DormancyPeriod>
    implements $DormancyPeriodCopyWith<$Res> {
  _$DormancyPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DormancyPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? dormancyType = null,
    Object? careModifications = null,
  }) {
    return _then(_value.copyWith(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dormancyType: null == dormancyType
          ? _value.dormancyType
          : dormancyType // ignore: cast_nullable_to_non_nullable
              as String,
      careModifications: null == careModifications
          ? _value.careModifications
          : careModifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DormancyPeriodImplCopyWith<$Res>
    implements $DormancyPeriodCopyWith<$Res> {
  factory _$$DormancyPeriodImplCopyWith(_$DormancyPeriodImpl value,
          $Res Function(_$DormancyPeriodImpl) then) =
      __$$DormancyPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startDate,
      DateTime endDate,
      String dormancyType,
      List<String> careModifications});
}

/// @nodoc
class __$$DormancyPeriodImplCopyWithImpl<$Res>
    extends _$DormancyPeriodCopyWithImpl<$Res, _$DormancyPeriodImpl>
    implements _$$DormancyPeriodImplCopyWith<$Res> {
  __$$DormancyPeriodImplCopyWithImpl(
      _$DormancyPeriodImpl _value, $Res Function(_$DormancyPeriodImpl) _then)
      : super(_value, _then);

  /// Create a copy of DormancyPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? dormancyType = null,
    Object? careModifications = null,
  }) {
    return _then(_$DormancyPeriodImpl(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dormancyType: null == dormancyType
          ? _value.dormancyType
          : dormancyType // ignore: cast_nullable_to_non_nullable
              as String,
      careModifications: null == careModifications
          ? _value._careModifications
          : careModifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DormancyPeriodImpl implements _DormancyPeriod {
  const _$DormancyPeriodImpl(
      {required this.startDate,
      required this.endDate,
      required this.dormancyType,
      required final List<String> careModifications})
      : _careModifications = careModifications;

  factory _$DormancyPeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$DormancyPeriodImplFromJson(json);

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String dormancyType;
  final List<String> _careModifications;
  @override
  List<String> get careModifications {
    if (_careModifications is EqualUnmodifiableListView)
      return _careModifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_careModifications);
  }

  @override
  String toString() {
    return 'DormancyPeriod(startDate: $startDate, endDate: $endDate, dormancyType: $dormancyType, careModifications: $careModifications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DormancyPeriodImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.dormancyType, dormancyType) ||
                other.dormancyType == dormancyType) &&
            const DeepCollectionEquality()
                .equals(other._careModifications, _careModifications));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate, dormancyType,
      const DeepCollectionEquality().hash(_careModifications));

  /// Create a copy of DormancyPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DormancyPeriodImplCopyWith<_$DormancyPeriodImpl> get copyWith =>
      __$$DormancyPeriodImplCopyWithImpl<_$DormancyPeriodImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DormancyPeriodImplToJson(
      this,
    );
  }
}

abstract class _DormancyPeriod implements DormancyPeriod {
  const factory _DormancyPeriod(
      {required final DateTime startDate,
      required final DateTime endDate,
      required final String dormancyType,
      required final List<String> careModifications}) = _$DormancyPeriodImpl;

  factory _DormancyPeriod.fromJson(Map<String, dynamic> json) =
      _$DormancyPeriodImpl.fromJson;

  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get dormancyType;
  @override
  List<String> get careModifications;

  /// Create a copy of DormancyPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DormancyPeriodImplCopyWith<_$DormancyPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
