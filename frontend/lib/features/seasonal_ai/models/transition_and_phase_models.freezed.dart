// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transition_and_phase_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SeasonalTransition _$SeasonalTransitionFromJson(Map<String, dynamic> json) {
  return _SeasonalTransition.fromJson(json);
}

/// @nodoc
mixin _$SeasonalTransition {
  String get fromSeason => throw _privateConstructorUsedError;
  String get toSeason => throw _privateConstructorUsedError;
  DateTime get transitionDate => throw _privateConstructorUsedError;
  List<String> get indicators => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this SeasonalTransition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonalTransition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonalTransitionCopyWith<SeasonalTransition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalTransitionCopyWith<$Res> {
  factory $SeasonalTransitionCopyWith(
          SeasonalTransition value, $Res Function(SeasonalTransition) then) =
      _$SeasonalTransitionCopyWithImpl<$Res, SeasonalTransition>;
  @useResult
  $Res call(
      {String fromSeason,
      String toSeason,
      DateTime transitionDate,
      List<String> indicators,
      double confidence});
}

/// @nodoc
class _$SeasonalTransitionCopyWithImpl<$Res, $Val extends SeasonalTransition>
    implements $SeasonalTransitionCopyWith<$Res> {
  _$SeasonalTransitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonalTransition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromSeason = null,
    Object? toSeason = null,
    Object? transitionDate = null,
    Object? indicators = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      fromSeason: null == fromSeason
          ? _value.fromSeason
          : fromSeason // ignore: cast_nullable_to_non_nullable
              as String,
      toSeason: null == toSeason
          ? _value.toSeason
          : toSeason // ignore: cast_nullable_to_non_nullable
              as String,
      transitionDate: null == transitionDate
          ? _value.transitionDate
          : transitionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      indicators: null == indicators
          ? _value.indicators
          : indicators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonalTransitionImplCopyWith<$Res>
    implements $SeasonalTransitionCopyWith<$Res> {
  factory _$$SeasonalTransitionImplCopyWith(_$SeasonalTransitionImpl value,
          $Res Function(_$SeasonalTransitionImpl) then) =
      __$$SeasonalTransitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fromSeason,
      String toSeason,
      DateTime transitionDate,
      List<String> indicators,
      double confidence});
}

/// @nodoc
class __$$SeasonalTransitionImplCopyWithImpl<$Res>
    extends _$SeasonalTransitionCopyWithImpl<$Res, _$SeasonalTransitionImpl>
    implements _$$SeasonalTransitionImplCopyWith<$Res> {
  __$$SeasonalTransitionImplCopyWithImpl(_$SeasonalTransitionImpl _value,
      $Res Function(_$SeasonalTransitionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonalTransition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromSeason = null,
    Object? toSeason = null,
    Object? transitionDate = null,
    Object? indicators = null,
    Object? confidence = null,
  }) {
    return _then(_$SeasonalTransitionImpl(
      fromSeason: null == fromSeason
          ? _value.fromSeason
          : fromSeason // ignore: cast_nullable_to_non_nullable
              as String,
      toSeason: null == toSeason
          ? _value.toSeason
          : toSeason // ignore: cast_nullable_to_non_nullable
              as String,
      transitionDate: null == transitionDate
          ? _value.transitionDate
          : transitionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      indicators: null == indicators
          ? _value._indicators
          : indicators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalTransitionImpl implements _SeasonalTransition {
  const _$SeasonalTransitionImpl(
      {required this.fromSeason,
      required this.toSeason,
      required this.transitionDate,
      required final List<String> indicators,
      required this.confidence})
      : _indicators = indicators;

  factory _$SeasonalTransitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalTransitionImplFromJson(json);

  @override
  final String fromSeason;
  @override
  final String toSeason;
  @override
  final DateTime transitionDate;
  final List<String> _indicators;
  @override
  List<String> get indicators {
    if (_indicators is EqualUnmodifiableListView) return _indicators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_indicators);
  }

  @override
  final double confidence;

  @override
  String toString() {
    return 'SeasonalTransition(fromSeason: $fromSeason, toSeason: $toSeason, transitionDate: $transitionDate, indicators: $indicators, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalTransitionImpl &&
            (identical(other.fromSeason, fromSeason) ||
                other.fromSeason == fromSeason) &&
            (identical(other.toSeason, toSeason) ||
                other.toSeason == toSeason) &&
            (identical(other.transitionDate, transitionDate) ||
                other.transitionDate == transitionDate) &&
            const DeepCollectionEquality()
                .equals(other._indicators, _indicators) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      fromSeason,
      toSeason,
      transitionDate,
      const DeepCollectionEquality().hash(_indicators),
      confidence);

  /// Create a copy of SeasonalTransition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalTransitionImplCopyWith<_$SeasonalTransitionImpl> get copyWith =>
      __$$SeasonalTransitionImplCopyWithImpl<_$SeasonalTransitionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalTransitionImplToJson(
      this,
    );
  }
}

abstract class _SeasonalTransition implements SeasonalTransition {
  const factory _SeasonalTransition(
      {required final String fromSeason,
      required final String toSeason,
      required final DateTime transitionDate,
      required final List<String> indicators,
      required final double confidence}) = _$SeasonalTransitionImpl;

  factory _SeasonalTransition.fromJson(Map<String, dynamic> json) =
      _$SeasonalTransitionImpl.fromJson;

  @override
  String get fromSeason;
  @override
  String get toSeason;
  @override
  DateTime get transitionDate;
  @override
  List<String> get indicators;
  @override
  double get confidence;

  /// Create a copy of SeasonalTransition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonalTransitionImplCopyWith<_$SeasonalTransitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrowthPhase _$GrowthPhaseFromJson(Map<String, dynamic> json) {
  return _GrowthPhase.fromJson(json);
}

/// @nodoc
mixin _$GrowthPhase {
  String get phaseName => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get characteristics => throw _privateConstructorUsedError;
  List<CareAdjustment> get recommendedCare =>
      throw _privateConstructorUsedError;

  /// Serializes this GrowthPhase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrowthPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrowthPhaseCopyWith<GrowthPhase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrowthPhaseCopyWith<$Res> {
  factory $GrowthPhaseCopyWith(
          GrowthPhase value, $Res Function(GrowthPhase) then) =
      _$GrowthPhaseCopyWithImpl<$Res, GrowthPhase>;
  @useResult
  $Res call(
      {String phaseName,
      DateTime startDate,
      DateTime endDate,
      String description,
      List<String> characteristics,
      List<CareAdjustment> recommendedCare});
}

/// @nodoc
class _$GrowthPhaseCopyWithImpl<$Res, $Val extends GrowthPhase>
    implements $GrowthPhaseCopyWith<$Res> {
  _$GrowthPhaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrowthPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phaseName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? description = null,
    Object? characteristics = null,
    Object? recommendedCare = null,
  }) {
    return _then(_value.copyWith(
      phaseName: null == phaseName
          ? _value.phaseName
          : phaseName // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      characteristics: null == characteristics
          ? _value.characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedCare: null == recommendedCare
          ? _value.recommendedCare
          : recommendedCare // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrowthPhaseImplCopyWith<$Res>
    implements $GrowthPhaseCopyWith<$Res> {
  factory _$$GrowthPhaseImplCopyWith(
          _$GrowthPhaseImpl value, $Res Function(_$GrowthPhaseImpl) then) =
      __$$GrowthPhaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String phaseName,
      DateTime startDate,
      DateTime endDate,
      String description,
      List<String> characteristics,
      List<CareAdjustment> recommendedCare});
}

/// @nodoc
class __$$GrowthPhaseImplCopyWithImpl<$Res>
    extends _$GrowthPhaseCopyWithImpl<$Res, _$GrowthPhaseImpl>
    implements _$$GrowthPhaseImplCopyWith<$Res> {
  __$$GrowthPhaseImplCopyWithImpl(
      _$GrowthPhaseImpl _value, $Res Function(_$GrowthPhaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrowthPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phaseName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? description = null,
    Object? characteristics = null,
    Object? recommendedCare = null,
  }) {
    return _then(_$GrowthPhaseImpl(
      phaseName: null == phaseName
          ? _value.phaseName
          : phaseName // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      characteristics: null == characteristics
          ? _value._characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendedCare: null == recommendedCare
          ? _value._recommendedCare
          : recommendedCare // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrowthPhaseImpl implements _GrowthPhase {
  const _$GrowthPhaseImpl(
      {required this.phaseName,
      required this.startDate,
      required this.endDate,
      required this.description,
      required final List<String> characteristics,
      required final List<CareAdjustment> recommendedCare})
      : _characteristics = characteristics,
        _recommendedCare = recommendedCare;

  factory _$GrowthPhaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrowthPhaseImplFromJson(json);

  @override
  final String phaseName;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String description;
  final List<String> _characteristics;
  @override
  List<String> get characteristics {
    if (_characteristics is EqualUnmodifiableListView) return _characteristics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_characteristics);
  }

  final List<CareAdjustment> _recommendedCare;
  @override
  List<CareAdjustment> get recommendedCare {
    if (_recommendedCare is EqualUnmodifiableListView) return _recommendedCare;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedCare);
  }

  @override
  String toString() {
    return 'GrowthPhase(phaseName: $phaseName, startDate: $startDate, endDate: $endDate, description: $description, characteristics: $characteristics, recommendedCare: $recommendedCare)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrowthPhaseImpl &&
            (identical(other.phaseName, phaseName) ||
                other.phaseName == phaseName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._characteristics, _characteristics) &&
            const DeepCollectionEquality()
                .equals(other._recommendedCare, _recommendedCare));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      phaseName,
      startDate,
      endDate,
      description,
      const DeepCollectionEquality().hash(_characteristics),
      const DeepCollectionEquality().hash(_recommendedCare));

  /// Create a copy of GrowthPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrowthPhaseImplCopyWith<_$GrowthPhaseImpl> get copyWith =>
      __$$GrowthPhaseImplCopyWithImpl<_$GrowthPhaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrowthPhaseImplToJson(
      this,
    );
  }
}

abstract class _GrowthPhase implements GrowthPhase {
  const factory _GrowthPhase(
      {required final String phaseName,
      required final DateTime startDate,
      required final DateTime endDate,
      required final String description,
      required final List<String> characteristics,
      required final List<CareAdjustment> recommendedCare}) = _$GrowthPhaseImpl;

  factory _GrowthPhase.fromJson(Map<String, dynamic> json) =
      _$GrowthPhaseImpl.fromJson;

  @override
  String get phaseName;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get description;
  @override
  List<String> get characteristics;
  @override
  List<CareAdjustment> get recommendedCare;

  /// Create a copy of GrowthPhase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrowthPhaseImplCopyWith<_$GrowthPhaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
