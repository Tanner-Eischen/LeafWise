// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'care_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CareAdjustment _$CareAdjustmentFromJson(Map<String, dynamic> json) {
  return _CareAdjustment.fromJson(json);
}

/// @nodoc
mixin _$CareAdjustment {
  String get careType => throw _privateConstructorUsedError;
  String get adjustmentType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get effectiveDate => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  Map<String, dynamic>? get parameters => throw _privateConstructorUsedError;

  /// Serializes this CareAdjustment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CareAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CareAdjustmentCopyWith<CareAdjustment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CareAdjustmentCopyWith<$Res> {
  factory $CareAdjustmentCopyWith(
          CareAdjustment value, $Res Function(CareAdjustment) then) =
      _$CareAdjustmentCopyWithImpl<$Res, CareAdjustment>;
  @useResult
  $Res call(
      {String careType,
      String adjustmentType,
      String description,
      DateTime effectiveDate,
      String priority,
      Map<String, dynamic>? parameters});
}

/// @nodoc
class _$CareAdjustmentCopyWithImpl<$Res, $Val extends CareAdjustment>
    implements $CareAdjustmentCopyWith<$Res> {
  _$CareAdjustmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CareAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? careType = null,
    Object? adjustmentType = null,
    Object? description = null,
    Object? effectiveDate = null,
    Object? priority = null,
    Object? parameters = freezed,
  }) {
    return _then(_value.copyWith(
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      adjustmentType: null == adjustmentType
          ? _value.adjustmentType
          : adjustmentType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      effectiveDate: null == effectiveDate
          ? _value.effectiveDate
          : effectiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: freezed == parameters
          ? _value.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CareAdjustmentImplCopyWith<$Res>
    implements $CareAdjustmentCopyWith<$Res> {
  factory _$$CareAdjustmentImplCopyWith(_$CareAdjustmentImpl value,
          $Res Function(_$CareAdjustmentImpl) then) =
      __$$CareAdjustmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String careType,
      String adjustmentType,
      String description,
      DateTime effectiveDate,
      String priority,
      Map<String, dynamic>? parameters});
}

/// @nodoc
class __$$CareAdjustmentImplCopyWithImpl<$Res>
    extends _$CareAdjustmentCopyWithImpl<$Res, _$CareAdjustmentImpl>
    implements _$$CareAdjustmentImplCopyWith<$Res> {
  __$$CareAdjustmentImplCopyWithImpl(
      _$CareAdjustmentImpl _value, $Res Function(_$CareAdjustmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of CareAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? careType = null,
    Object? adjustmentType = null,
    Object? description = null,
    Object? effectiveDate = null,
    Object? priority = null,
    Object? parameters = freezed,
  }) {
    return _then(_$CareAdjustmentImpl(
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      adjustmentType: null == adjustmentType
          ? _value.adjustmentType
          : adjustmentType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      effectiveDate: null == effectiveDate
          ? _value.effectiveDate
          : effectiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: freezed == parameters
          ? _value._parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CareAdjustmentImpl implements _CareAdjustment {
  const _$CareAdjustmentImpl(
      {required this.careType,
      required this.adjustmentType,
      required this.description,
      required this.effectiveDate,
      required this.priority,
      final Map<String, dynamic>? parameters})
      : _parameters = parameters;

  factory _$CareAdjustmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CareAdjustmentImplFromJson(json);

  @override
  final String careType;
  @override
  final String adjustmentType;
  @override
  final String description;
  @override
  final DateTime effectiveDate;
  @override
  final String priority;
  final Map<String, dynamic>? _parameters;
  @override
  Map<String, dynamic>? get parameters {
    final value = _parameters;
    if (value == null) return null;
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CareAdjustment(careType: $careType, adjustmentType: $adjustmentType, description: $description, effectiveDate: $effectiveDate, priority: $priority, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CareAdjustmentImpl &&
            (identical(other.careType, careType) ||
                other.careType == careType) &&
            (identical(other.adjustmentType, adjustmentType) ||
                other.adjustmentType == adjustmentType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.effectiveDate, effectiveDate) ||
                other.effectiveDate == effectiveDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality()
                .equals(other._parameters, _parameters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      careType,
      adjustmentType,
      description,
      effectiveDate,
      priority,
      const DeepCollectionEquality().hash(_parameters));

  /// Create a copy of CareAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CareAdjustmentImplCopyWith<_$CareAdjustmentImpl> get copyWith =>
      __$$CareAdjustmentImplCopyWithImpl<_$CareAdjustmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CareAdjustmentImplToJson(
      this,
    );
  }
}

abstract class _CareAdjustment implements CareAdjustment {
  const factory _CareAdjustment(
      {required final String careType,
      required final String adjustmentType,
      required final String description,
      required final DateTime effectiveDate,
      required final String priority,
      final Map<String, dynamic>? parameters}) = _$CareAdjustmentImpl;

  factory _CareAdjustment.fromJson(Map<String, dynamic> json) =
      _$CareAdjustmentImpl.fromJson;

  @override
  String get careType;
  @override
  String get adjustmentType;
  @override
  String get description;
  @override
  DateTime get effectiveDate;
  @override
  String get priority;
  @override
  Map<String, dynamic>? get parameters;

  /// Create a copy of CareAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CareAdjustmentImplCopyWith<_$CareAdjustmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) {
  return _RiskFactor.fromJson(json);
}

/// @nodoc
mixin _$RiskFactor {
  String get riskType => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  double get probability => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get preventiveMeasures => throw _privateConstructorUsedError;
  DateTime? get expectedDate => throw _privateConstructorUsedError;

  /// Serializes this RiskFactor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RiskFactor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RiskFactorCopyWith<RiskFactor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskFactorCopyWith<$Res> {
  factory $RiskFactorCopyWith(
          RiskFactor value, $Res Function(RiskFactor) then) =
      _$RiskFactorCopyWithImpl<$Res, RiskFactor>;
  @useResult
  $Res call(
      {String riskType,
      String severity,
      double probability,
      String description,
      List<String> preventiveMeasures,
      DateTime? expectedDate});
}

/// @nodoc
class _$RiskFactorCopyWithImpl<$Res, $Val extends RiskFactor>
    implements $RiskFactorCopyWith<$Res> {
  _$RiskFactorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RiskFactor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskType = null,
    Object? severity = null,
    Object? probability = null,
    Object? description = null,
    Object? preventiveMeasures = null,
    Object? expectedDate = freezed,
  }) {
    return _then(_value.copyWith(
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preventiveMeasures: null == preventiveMeasures
          ? _value.preventiveMeasures
          : preventiveMeasures // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expectedDate: freezed == expectedDate
          ? _value.expectedDate
          : expectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskFactorImplCopyWith<$Res>
    implements $RiskFactorCopyWith<$Res> {
  factory _$$RiskFactorImplCopyWith(
          _$RiskFactorImpl value, $Res Function(_$RiskFactorImpl) then) =
      __$$RiskFactorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String riskType,
      String severity,
      double probability,
      String description,
      List<String> preventiveMeasures,
      DateTime? expectedDate});
}

/// @nodoc
class __$$RiskFactorImplCopyWithImpl<$Res>
    extends _$RiskFactorCopyWithImpl<$Res, _$RiskFactorImpl>
    implements _$$RiskFactorImplCopyWith<$Res> {
  __$$RiskFactorImplCopyWithImpl(
      _$RiskFactorImpl _value, $Res Function(_$RiskFactorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RiskFactor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskType = null,
    Object? severity = null,
    Object? probability = null,
    Object? description = null,
    Object? preventiveMeasures = null,
    Object? expectedDate = freezed,
  }) {
    return _then(_$RiskFactorImpl(
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preventiveMeasures: null == preventiveMeasures
          ? _value._preventiveMeasures
          : preventiveMeasures // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expectedDate: freezed == expectedDate
          ? _value.expectedDate
          : expectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskFactorImpl implements _RiskFactor {
  const _$RiskFactorImpl(
      {required this.riskType,
      required this.severity,
      required this.probability,
      required this.description,
      required final List<String> preventiveMeasures,
      this.expectedDate})
      : _preventiveMeasures = preventiveMeasures;

  factory _$RiskFactorImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskFactorImplFromJson(json);

  @override
  final String riskType;
  @override
  final String severity;
  @override
  final double probability;
  @override
  final String description;
  final List<String> _preventiveMeasures;
  @override
  List<String> get preventiveMeasures {
    if (_preventiveMeasures is EqualUnmodifiableListView)
      return _preventiveMeasures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preventiveMeasures);
  }

  @override
  final DateTime? expectedDate;

  @override
  String toString() {
    return 'RiskFactor(riskType: $riskType, severity: $severity, probability: $probability, description: $description, preventiveMeasures: $preventiveMeasures, expectedDate: $expectedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskFactorImpl &&
            (identical(other.riskType, riskType) ||
                other.riskType == riskType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._preventiveMeasures, _preventiveMeasures) &&
            (identical(other.expectedDate, expectedDate) ||
                other.expectedDate == expectedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      riskType,
      severity,
      probability,
      description,
      const DeepCollectionEquality().hash(_preventiveMeasures),
      expectedDate);

  /// Create a copy of RiskFactor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskFactorImplCopyWith<_$RiskFactorImpl> get copyWith =>
      __$$RiskFactorImplCopyWithImpl<_$RiskFactorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskFactorImplToJson(
      this,
    );
  }
}

abstract class _RiskFactor implements RiskFactor {
  const factory _RiskFactor(
      {required final String riskType,
      required final String severity,
      required final double probability,
      required final String description,
      required final List<String> preventiveMeasures,
      final DateTime? expectedDate}) = _$RiskFactorImpl;

  factory _RiskFactor.fromJson(Map<String, dynamic> json) =
      _$RiskFactorImpl.fromJson;

  @override
  String get riskType;
  @override
  String get severity;
  @override
  double get probability;
  @override
  String get description;
  @override
  List<String> get preventiveMeasures;
  @override
  DateTime? get expectedDate;

  /// Create a copy of RiskFactor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RiskFactorImplCopyWith<_$RiskFactorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantActivity _$PlantActivityFromJson(Map<String, dynamic> json) {
  return _PlantActivity.fromJson(json);
}

/// @nodoc
mixin _$PlantActivity {
  String get activityType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get optimalDate => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  List<String>? get requiredSupplies => throw _privateConstructorUsedError;

  /// Serializes this PlantActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantActivityCopyWith<PlantActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantActivityCopyWith<$Res> {
  factory $PlantActivityCopyWith(
          PlantActivity value, $Res Function(PlantActivity) then) =
      _$PlantActivityCopyWithImpl<$Res, PlantActivity>;
  @useResult
  $Res call(
      {String activityType,
      String title,
      String description,
      DateTime optimalDate,
      String difficulty,
      List<String>? requiredSupplies});
}

/// @nodoc
class _$PlantActivityCopyWithImpl<$Res, $Val extends PlantActivity>
    implements $PlantActivityCopyWith<$Res> {
  _$PlantActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityType = null,
    Object? title = null,
    Object? description = null,
    Object? optimalDate = null,
    Object? difficulty = null,
    Object? requiredSupplies = freezed,
  }) {
    return _then(_value.copyWith(
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      optimalDate: null == optimalDate
          ? _value.optimalDate
          : optimalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      requiredSupplies: freezed == requiredSupplies
          ? _value.requiredSupplies
          : requiredSupplies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantActivityImplCopyWith<$Res>
    implements $PlantActivityCopyWith<$Res> {
  factory _$$PlantActivityImplCopyWith(
          _$PlantActivityImpl value, $Res Function(_$PlantActivityImpl) then) =
      __$$PlantActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String activityType,
      String title,
      String description,
      DateTime optimalDate,
      String difficulty,
      List<String>? requiredSupplies});
}

/// @nodoc
class __$$PlantActivityImplCopyWithImpl<$Res>
    extends _$PlantActivityCopyWithImpl<$Res, _$PlantActivityImpl>
    implements _$$PlantActivityImplCopyWith<$Res> {
  __$$PlantActivityImplCopyWithImpl(
      _$PlantActivityImpl _value, $Res Function(_$PlantActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityType = null,
    Object? title = null,
    Object? description = null,
    Object? optimalDate = null,
    Object? difficulty = null,
    Object? requiredSupplies = freezed,
  }) {
    return _then(_$PlantActivityImpl(
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      optimalDate: null == optimalDate
          ? _value.optimalDate
          : optimalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      requiredSupplies: freezed == requiredSupplies
          ? _value._requiredSupplies
          : requiredSupplies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantActivityImpl implements _PlantActivity {
  const _$PlantActivityImpl(
      {required this.activityType,
      required this.title,
      required this.description,
      required this.optimalDate,
      required this.difficulty,
      final List<String>? requiredSupplies})
      : _requiredSupplies = requiredSupplies;

  factory _$PlantActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantActivityImplFromJson(json);

  @override
  final String activityType;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime optimalDate;
  @override
  final String difficulty;
  final List<String>? _requiredSupplies;
  @override
  List<String>? get requiredSupplies {
    final value = _requiredSupplies;
    if (value == null) return null;
    if (_requiredSupplies is EqualUnmodifiableListView)
      return _requiredSupplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PlantActivity(activityType: $activityType, title: $title, description: $description, optimalDate: $optimalDate, difficulty: $difficulty, requiredSupplies: $requiredSupplies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantActivityImpl &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.optimalDate, optimalDate) ||
                other.optimalDate == optimalDate) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._requiredSupplies, _requiredSupplies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activityType,
      title,
      description,
      optimalDate,
      difficulty,
      const DeepCollectionEquality().hash(_requiredSupplies));

  /// Create a copy of PlantActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantActivityImplCopyWith<_$PlantActivityImpl> get copyWith =>
      __$$PlantActivityImplCopyWithImpl<_$PlantActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantActivityImplToJson(
      this,
    );
  }
}

abstract class _PlantActivity implements PlantActivity {
  const factory _PlantActivity(
      {required final String activityType,
      required final String title,
      required final String description,
      required final DateTime optimalDate,
      required final String difficulty,
      final List<String>? requiredSupplies}) = _$PlantActivityImpl;

  factory _PlantActivity.fromJson(Map<String, dynamic> json) =
      _$PlantActivityImpl.fromJson;

  @override
  String get activityType;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get optimalDate;
  @override
  String get difficulty;
  @override
  List<String>? get requiredSupplies;

  /// Create a copy of PlantActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantActivityImplCopyWith<_$PlantActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
