// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'care_plan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CarePlan _$CarePlanFromJson(Map<String, dynamic> json) {
  return _CarePlan.fromJson(json);
}

/// @nodoc
mixin _$CarePlan {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  WateringSchedule get watering => throw _privateConstructorUsedError;
  FertilizerSchedule get fertilizer => throw _privateConstructorUsedError;
  LightTarget get lightTarget => throw _privateConstructorUsedError;
  List<String> get alerts => throw _privateConstructorUsedError;
  int get reviewInDays => throw _privateConstructorUsedError;
  CarePlanRationale get rationale => throw _privateConstructorUsedError;
  DateTime get validFrom => throw _privateConstructorUsedError;
  DateTime? get validTo => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isAcknowledged => throw _privateConstructorUsedError;
  DateTime? get acknowledgedAt => throw _privateConstructorUsedError;
  CarePlanStatus get status => throw _privateConstructorUsedError;

  /// Serializes this CarePlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanCopyWith<CarePlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanCopyWith<$Res> {
  factory $CarePlanCopyWith(CarePlan value, $Res Function(CarePlan) then) =
      _$CarePlanCopyWithImpl<$Res, CarePlan>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      String userId,
      int version,
      WateringSchedule watering,
      FertilizerSchedule fertilizer,
      LightTarget lightTarget,
      List<String> alerts,
      int reviewInDays,
      CarePlanRationale rationale,
      DateTime validFrom,
      DateTime? validTo,
      DateTime createdAt,
      bool isAcknowledged,
      DateTime? acknowledgedAt,
      CarePlanStatus status});

  $WateringScheduleCopyWith<$Res> get watering;
  $FertilizerScheduleCopyWith<$Res> get fertilizer;
  $LightTargetCopyWith<$Res> get lightTarget;
  $CarePlanRationaleCopyWith<$Res> get rationale;
}

/// @nodoc
class _$CarePlanCopyWithImpl<$Res, $Val extends CarePlan>
    implements $CarePlanCopyWith<$Res> {
  _$CarePlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? userId = null,
    Object? version = null,
    Object? watering = null,
    Object? fertilizer = null,
    Object? lightTarget = null,
    Object? alerts = null,
    Object? reviewInDays = null,
    Object? rationale = null,
    Object? validFrom = null,
    Object? validTo = freezed,
    Object? createdAt = null,
    Object? isAcknowledged = null,
    Object? acknowledgedAt = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      watering: null == watering
          ? _value.watering
          : watering // ignore: cast_nullable_to_non_nullable
              as WateringSchedule,
      fertilizer: null == fertilizer
          ? _value.fertilizer
          : fertilizer // ignore: cast_nullable_to_non_nullable
              as FertilizerSchedule,
      lightTarget: null == lightTarget
          ? _value.lightTarget
          : lightTarget // ignore: cast_nullable_to_non_nullable
              as LightTarget,
      alerts: null == alerts
          ? _value.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewInDays: null == reviewInDays
          ? _value.reviewInDays
          : reviewInDays // ignore: cast_nullable_to_non_nullable
              as int,
      rationale: null == rationale
          ? _value.rationale
          : rationale // ignore: cast_nullable_to_non_nullable
              as CarePlanRationale,
      validFrom: null == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      acknowledgedAt: freezed == acknowledgedAt
          ? _value.acknowledgedAt
          : acknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CarePlanStatus,
    ) as $Val);
  }

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WateringScheduleCopyWith<$Res> get watering {
    return $WateringScheduleCopyWith<$Res>(_value.watering, (value) {
      return _then(_value.copyWith(watering: value) as $Val);
    });
  }

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FertilizerScheduleCopyWith<$Res> get fertilizer {
    return $FertilizerScheduleCopyWith<$Res>(_value.fertilizer, (value) {
      return _then(_value.copyWith(fertilizer: value) as $Val);
    });
  }

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LightTargetCopyWith<$Res> get lightTarget {
    return $LightTargetCopyWith<$Res>(_value.lightTarget, (value) {
      return _then(_value.copyWith(lightTarget: value) as $Val);
    });
  }

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CarePlanRationaleCopyWith<$Res> get rationale {
    return $CarePlanRationaleCopyWith<$Res>(_value.rationale, (value) {
      return _then(_value.copyWith(rationale: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CarePlanImplCopyWith<$Res>
    implements $CarePlanCopyWith<$Res> {
  factory _$$CarePlanImplCopyWith(
          _$CarePlanImpl value, $Res Function(_$CarePlanImpl) then) =
      __$$CarePlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      String userId,
      int version,
      WateringSchedule watering,
      FertilizerSchedule fertilizer,
      LightTarget lightTarget,
      List<String> alerts,
      int reviewInDays,
      CarePlanRationale rationale,
      DateTime validFrom,
      DateTime? validTo,
      DateTime createdAt,
      bool isAcknowledged,
      DateTime? acknowledgedAt,
      CarePlanStatus status});

  @override
  $WateringScheduleCopyWith<$Res> get watering;
  @override
  $FertilizerScheduleCopyWith<$Res> get fertilizer;
  @override
  $LightTargetCopyWith<$Res> get lightTarget;
  @override
  $CarePlanRationaleCopyWith<$Res> get rationale;
}

/// @nodoc
class __$$CarePlanImplCopyWithImpl<$Res>
    extends _$CarePlanCopyWithImpl<$Res, _$CarePlanImpl>
    implements _$$CarePlanImplCopyWith<$Res> {
  __$$CarePlanImplCopyWithImpl(
      _$CarePlanImpl _value, $Res Function(_$CarePlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? userId = null,
    Object? version = null,
    Object? watering = null,
    Object? fertilizer = null,
    Object? lightTarget = null,
    Object? alerts = null,
    Object? reviewInDays = null,
    Object? rationale = null,
    Object? validFrom = null,
    Object? validTo = freezed,
    Object? createdAt = null,
    Object? isAcknowledged = null,
    Object? acknowledgedAt = freezed,
    Object? status = null,
  }) {
    return _then(_$CarePlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      watering: null == watering
          ? _value.watering
          : watering // ignore: cast_nullable_to_non_nullable
              as WateringSchedule,
      fertilizer: null == fertilizer
          ? _value.fertilizer
          : fertilizer // ignore: cast_nullable_to_non_nullable
              as FertilizerSchedule,
      lightTarget: null == lightTarget
          ? _value.lightTarget
          : lightTarget // ignore: cast_nullable_to_non_nullable
              as LightTarget,
      alerts: null == alerts
          ? _value._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewInDays: null == reviewInDays
          ? _value.reviewInDays
          : reviewInDays // ignore: cast_nullable_to_non_nullable
              as int,
      rationale: null == rationale
          ? _value.rationale
          : rationale // ignore: cast_nullable_to_non_nullable
              as CarePlanRationale,
      validFrom: null == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      acknowledgedAt: freezed == acknowledgedAt
          ? _value.acknowledgedAt
          : acknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CarePlanStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanImpl implements _CarePlan {
  const _$CarePlanImpl(
      {required this.id,
      required this.plantId,
      required this.userId,
      required this.version,
      required this.watering,
      required this.fertilizer,
      required this.lightTarget,
      final List<String> alerts = const [],
      required this.reviewInDays,
      required this.rationale,
      required this.validFrom,
      this.validTo,
      required this.createdAt,
      this.isAcknowledged = false,
      this.acknowledgedAt,
      this.status = CarePlanStatus.pending})
      : _alerts = alerts;

  factory _$CarePlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final String userId;
  @override
  final int version;
  @override
  final WateringSchedule watering;
  @override
  final FertilizerSchedule fertilizer;
  @override
  final LightTarget lightTarget;
  final List<String> _alerts;
  @override
  @JsonKey()
  List<String> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  final int reviewInDays;
  @override
  final CarePlanRationale rationale;
  @override
  final DateTime validFrom;
  @override
  final DateTime? validTo;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isAcknowledged;
  @override
  final DateTime? acknowledgedAt;
  @override
  @JsonKey()
  final CarePlanStatus status;

  @override
  String toString() {
    return 'CarePlan(id: $id, plantId: $plantId, userId: $userId, version: $version, watering: $watering, fertilizer: $fertilizer, lightTarget: $lightTarget, alerts: $alerts, reviewInDays: $reviewInDays, rationale: $rationale, validFrom: $validFrom, validTo: $validTo, createdAt: $createdAt, isAcknowledged: $isAcknowledged, acknowledgedAt: $acknowledgedAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.watering, watering) ||
                other.watering == watering) &&
            (identical(other.fertilizer, fertilizer) ||
                other.fertilizer == fertilizer) &&
            (identical(other.lightTarget, lightTarget) ||
                other.lightTarget == lightTarget) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.reviewInDays, reviewInDays) ||
                other.reviewInDays == reviewInDays) &&
            (identical(other.rationale, rationale) ||
                other.rationale == rationale) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validTo, validTo) || other.validTo == validTo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isAcknowledged, isAcknowledged) ||
                other.isAcknowledged == isAcknowledged) &&
            (identical(other.acknowledgedAt, acknowledgedAt) ||
                other.acknowledgedAt == acknowledgedAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      plantId,
      userId,
      version,
      watering,
      fertilizer,
      lightTarget,
      const DeepCollectionEquality().hash(_alerts),
      reviewInDays,
      rationale,
      validFrom,
      validTo,
      createdAt,
      isAcknowledged,
      acknowledgedAt,
      status);

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanImplCopyWith<_$CarePlanImpl> get copyWith =>
      __$$CarePlanImplCopyWithImpl<_$CarePlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanImplToJson(
      this,
    );
  }
}

abstract class _CarePlan implements CarePlan {
  const factory _CarePlan(
      {required final String id,
      required final String plantId,
      required final String userId,
      required final int version,
      required final WateringSchedule watering,
      required final FertilizerSchedule fertilizer,
      required final LightTarget lightTarget,
      final List<String> alerts,
      required final int reviewInDays,
      required final CarePlanRationale rationale,
      required final DateTime validFrom,
      final DateTime? validTo,
      required final DateTime createdAt,
      final bool isAcknowledged,
      final DateTime? acknowledgedAt,
      final CarePlanStatus status}) = _$CarePlanImpl;

  factory _CarePlan.fromJson(Map<String, dynamic> json) =
      _$CarePlanImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  String get userId;
  @override
  int get version;
  @override
  WateringSchedule get watering;
  @override
  FertilizerSchedule get fertilizer;
  @override
  LightTarget get lightTarget;
  @override
  List<String> get alerts;
  @override
  int get reviewInDays;
  @override
  CarePlanRationale get rationale;
  @override
  DateTime get validFrom;
  @override
  DateTime? get validTo;
  @override
  DateTime get createdAt;
  @override
  bool get isAcknowledged;
  @override
  DateTime? get acknowledgedAt;
  @override
  CarePlanStatus get status;

  /// Create a copy of CarePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanImplCopyWith<_$CarePlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WateringSchedule _$WateringScheduleFromJson(Map<String, dynamic> json) {
  return _WateringSchedule.fromJson(json);
}

/// @nodoc
mixin _$WateringSchedule {
  int get intervalDays => throw _privateConstructorUsedError;
  int get amountMl => throw _privateConstructorUsedError;
  DateTime get nextDue => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this WateringSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WateringSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WateringScheduleCopyWith<WateringSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WateringScheduleCopyWith<$Res> {
  factory $WateringScheduleCopyWith(
          WateringSchedule value, $Res Function(WateringSchedule) then) =
      _$WateringScheduleCopyWithImpl<$Res, WateringSchedule>;
  @useResult
  $Res call(
      {int intervalDays,
      int amountMl,
      DateTime nextDue,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$WateringScheduleCopyWithImpl<$Res, $Val extends WateringSchedule>
    implements $WateringScheduleCopyWith<$Res> {
  _$WateringScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WateringSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalDays = null,
    Object? amountMl = null,
    Object? nextDue = null,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      amountMl: null == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as int,
      nextDue: null == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WateringScheduleImplCopyWith<$Res>
    implements $WateringScheduleCopyWith<$Res> {
  factory _$$WateringScheduleImplCopyWith(_$WateringScheduleImpl value,
          $Res Function(_$WateringScheduleImpl) then) =
      __$$WateringScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int intervalDays,
      int amountMl,
      DateTime nextDue,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$WateringScheduleImplCopyWithImpl<$Res>
    extends _$WateringScheduleCopyWithImpl<$Res, _$WateringScheduleImpl>
    implements _$$WateringScheduleImplCopyWith<$Res> {
  __$$WateringScheduleImplCopyWithImpl(_$WateringScheduleImpl _value,
      $Res Function(_$WateringScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of WateringSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalDays = null,
    Object? amountMl = null,
    Object? nextDue = null,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_$WateringScheduleImpl(
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      amountMl: null == amountMl
          ? _value.amountMl
          : amountMl // ignore: cast_nullable_to_non_nullable
              as int,
      nextDue: null == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WateringScheduleImpl implements _WateringSchedule {
  const _$WateringScheduleImpl(
      {required this.intervalDays,
      required this.amountMl,
      required this.nextDue,
      this.notes,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$WateringScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$WateringScheduleImplFromJson(json);

  @override
  final int intervalDays;
  @override
  final int amountMl;
  @override
  final DateTime nextDue;
  @override
  final String? notes;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'WateringSchedule(intervalDays: $intervalDays, amountMl: $amountMl, nextDue: $nextDue, notes: $notes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WateringScheduleImpl &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.amountMl, amountMl) ||
                other.amountMl == amountMl) &&
            (identical(other.nextDue, nextDue) || other.nextDue == nextDue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, intervalDays, amountMl, nextDue,
      notes, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of WateringSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WateringScheduleImplCopyWith<_$WateringScheduleImpl> get copyWith =>
      __$$WateringScheduleImplCopyWithImpl<_$WateringScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WateringScheduleImplToJson(
      this,
    );
  }
}

abstract class _WateringSchedule implements WateringSchedule {
  const factory _WateringSchedule(
      {required final int intervalDays,
      required final int amountMl,
      required final DateTime nextDue,
      final String? notes,
      final Map<String, dynamic> metadata}) = _$WateringScheduleImpl;

  factory _WateringSchedule.fromJson(Map<String, dynamic> json) =
      _$WateringScheduleImpl.fromJson;

  @override
  int get intervalDays;
  @override
  int get amountMl;
  @override
  DateTime get nextDue;
  @override
  String? get notes;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of WateringSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WateringScheduleImplCopyWith<_$WateringScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FertilizerSchedule _$FertilizerScheduleFromJson(Map<String, dynamic> json) {
  return _FertilizerSchedule.fromJson(json);
}

/// @nodoc
mixin _$FertilizerSchedule {
  int get intervalDays => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime? get nextDue => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this FertilizerSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FertilizerSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FertilizerScheduleCopyWith<FertilizerSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FertilizerScheduleCopyWith<$Res> {
  factory $FertilizerScheduleCopyWith(
          FertilizerSchedule value, $Res Function(FertilizerSchedule) then) =
      _$FertilizerScheduleCopyWithImpl<$Res, FertilizerSchedule>;
  @useResult
  $Res call(
      {int intervalDays,
      String type,
      DateTime? nextDue,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$FertilizerScheduleCopyWithImpl<$Res, $Val extends FertilizerSchedule>
    implements $FertilizerScheduleCopyWith<$Res> {
  _$FertilizerScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FertilizerSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalDays = null,
    Object? type = null,
    Object? nextDue = freezed,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      nextDue: freezed == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FertilizerScheduleImplCopyWith<$Res>
    implements $FertilizerScheduleCopyWith<$Res> {
  factory _$$FertilizerScheduleImplCopyWith(_$FertilizerScheduleImpl value,
          $Res Function(_$FertilizerScheduleImpl) then) =
      __$$FertilizerScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int intervalDays,
      String type,
      DateTime? nextDue,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$FertilizerScheduleImplCopyWithImpl<$Res>
    extends _$FertilizerScheduleCopyWithImpl<$Res, _$FertilizerScheduleImpl>
    implements _$$FertilizerScheduleImplCopyWith<$Res> {
  __$$FertilizerScheduleImplCopyWithImpl(_$FertilizerScheduleImpl _value,
      $Res Function(_$FertilizerScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of FertilizerSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalDays = null,
    Object? type = null,
    Object? nextDue = freezed,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_$FertilizerScheduleImpl(
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      nextDue: freezed == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FertilizerScheduleImpl implements _FertilizerSchedule {
  const _$FertilizerScheduleImpl(
      {required this.intervalDays,
      required this.type,
      this.nextDue,
      this.notes,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$FertilizerScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$FertilizerScheduleImplFromJson(json);

  @override
  final int intervalDays;
  @override
  final String type;
  @override
  final DateTime? nextDue;
  @override
  final String? notes;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'FertilizerSchedule(intervalDays: $intervalDays, type: $type, nextDue: $nextDue, notes: $notes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FertilizerScheduleImpl &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.nextDue, nextDue) || other.nextDue == nextDue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, intervalDays, type, nextDue,
      notes, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of FertilizerSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FertilizerScheduleImplCopyWith<_$FertilizerScheduleImpl> get copyWith =>
      __$$FertilizerScheduleImplCopyWithImpl<_$FertilizerScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FertilizerScheduleImplToJson(
      this,
    );
  }
}

abstract class _FertilizerSchedule implements FertilizerSchedule {
  const factory _FertilizerSchedule(
      {required final int intervalDays,
      required final String type,
      final DateTime? nextDue,
      final String? notes,
      final Map<String, dynamic> metadata}) = _$FertilizerScheduleImpl;

  factory _FertilizerSchedule.fromJson(Map<String, dynamic> json) =
      _$FertilizerScheduleImpl.fromJson;

  @override
  int get intervalDays;
  @override
  String get type;
  @override
  DateTime? get nextDue;
  @override
  String? get notes;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of FertilizerSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FertilizerScheduleImplCopyWith<_$FertilizerScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LightTarget _$LightTargetFromJson(Map<String, dynamic> json) {
  return _LightTarget.fromJson(json);
}

/// @nodoc
mixin _$LightTarget {
  int get ppfdMin => throw _privateConstructorUsedError;
  int get ppfdMax => throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this LightTarget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LightTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LightTargetCopyWith<LightTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LightTargetCopyWith<$Res> {
  factory $LightTargetCopyWith(
          LightTarget value, $Res Function(LightTarget) then) =
      _$LightTargetCopyWithImpl<$Res, LightTarget>;
  @useResult
  $Res call(
      {int ppfdMin,
      int ppfdMax,
      String recommendation,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$LightTargetCopyWithImpl<$Res, $Val extends LightTarget>
    implements $LightTargetCopyWith<$Res> {
  _$LightTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LightTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ppfdMin = null,
    Object? ppfdMax = null,
    Object? recommendation = null,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      ppfdMin: null == ppfdMin
          ? _value.ppfdMin
          : ppfdMin // ignore: cast_nullable_to_non_nullable
              as int,
      ppfdMax: null == ppfdMax
          ? _value.ppfdMax
          : ppfdMax // ignore: cast_nullable_to_non_nullable
              as int,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LightTargetImplCopyWith<$Res>
    implements $LightTargetCopyWith<$Res> {
  factory _$$LightTargetImplCopyWith(
          _$LightTargetImpl value, $Res Function(_$LightTargetImpl) then) =
      __$$LightTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int ppfdMin,
      int ppfdMax,
      String recommendation,
      String? notes,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$LightTargetImplCopyWithImpl<$Res>
    extends _$LightTargetCopyWithImpl<$Res, _$LightTargetImpl>
    implements _$$LightTargetImplCopyWith<$Res> {
  __$$LightTargetImplCopyWithImpl(
      _$LightTargetImpl _value, $Res Function(_$LightTargetImpl) _then)
      : super(_value, _then);

  /// Create a copy of LightTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ppfdMin = null,
    Object? ppfdMax = null,
    Object? recommendation = null,
    Object? notes = freezed,
    Object? metadata = null,
  }) {
    return _then(_$LightTargetImpl(
      ppfdMin: null == ppfdMin
          ? _value.ppfdMin
          : ppfdMin // ignore: cast_nullable_to_non_nullable
              as int,
      ppfdMax: null == ppfdMax
          ? _value.ppfdMax
          : ppfdMax // ignore: cast_nullable_to_non_nullable
              as int,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LightTargetImpl implements _LightTarget {
  const _$LightTargetImpl(
      {required this.ppfdMin,
      required this.ppfdMax,
      required this.recommendation,
      this.notes,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$LightTargetImpl.fromJson(Map<String, dynamic> json) =>
      _$$LightTargetImplFromJson(json);

  @override
  final int ppfdMin;
  @override
  final int ppfdMax;
  @override
  final String recommendation;
  @override
  final String? notes;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'LightTarget(ppfdMin: $ppfdMin, ppfdMax: $ppfdMax, recommendation: $recommendation, notes: $notes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LightTargetImpl &&
            (identical(other.ppfdMin, ppfdMin) || other.ppfdMin == ppfdMin) &&
            (identical(other.ppfdMax, ppfdMax) || other.ppfdMax == ppfdMax) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ppfdMin, ppfdMax, recommendation,
      notes, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of LightTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LightTargetImplCopyWith<_$LightTargetImpl> get copyWith =>
      __$$LightTargetImplCopyWithImpl<_$LightTargetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LightTargetImplToJson(
      this,
    );
  }
}

abstract class _LightTarget implements LightTarget {
  const factory _LightTarget(
      {required final int ppfdMin,
      required final int ppfdMax,
      required final String recommendation,
      final String? notes,
      final Map<String, dynamic> metadata}) = _$LightTargetImpl;

  factory _LightTarget.fromJson(Map<String, dynamic> json) =
      _$LightTargetImpl.fromJson;

  @override
  int get ppfdMin;
  @override
  int get ppfdMax;
  @override
  String get recommendation;
  @override
  String? get notes;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of LightTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LightTargetImplCopyWith<_$LightTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CarePlanRationale _$CarePlanRationaleFromJson(Map<String, dynamic> json) {
  return _CarePlanRationale.fromJson(json);
}

/// @nodoc
mixin _$CarePlanRationale {
  Map<String, dynamic> get features => throw _privateConstructorUsedError;
  List<String> get rulesFired => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  Map<String, dynamic> get mlAdjustments => throw _privateConstructorUsedError;
  List<String> get environmentalFactors => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;

  /// Serializes this CarePlanRationale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanRationale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanRationaleCopyWith<CarePlanRationale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanRationaleCopyWith<$Res> {
  factory $CarePlanRationaleCopyWith(
          CarePlanRationale value, $Res Function(CarePlanRationale) then) =
      _$CarePlanRationaleCopyWithImpl<$Res, CarePlanRationale>;
  @useResult
  $Res call(
      {Map<String, dynamic> features,
      List<String> rulesFired,
      double confidence,
      Map<String, dynamic> mlAdjustments,
      List<String> environmentalFactors,
      String? explanation,
      String? summary});
}

/// @nodoc
class _$CarePlanRationaleCopyWithImpl<$Res, $Val extends CarePlanRationale>
    implements $CarePlanRationaleCopyWith<$Res> {
  _$CarePlanRationaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanRationale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? features = null,
    Object? rulesFired = null,
    Object? confidence = null,
    Object? mlAdjustments = null,
    Object? environmentalFactors = null,
    Object? explanation = freezed,
    Object? summary = freezed,
  }) {
    return _then(_value.copyWith(
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      rulesFired: null == rulesFired
          ? _value.rulesFired
          : rulesFired // ignore: cast_nullable_to_non_nullable
              as List<String>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      mlAdjustments: null == mlAdjustments
          ? _value.mlAdjustments
          : mlAdjustments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      environmentalFactors: null == environmentalFactors
          ? _value.environmentalFactors
          : environmentalFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanRationaleImplCopyWith<$Res>
    implements $CarePlanRationaleCopyWith<$Res> {
  factory _$$CarePlanRationaleImplCopyWith(_$CarePlanRationaleImpl value,
          $Res Function(_$CarePlanRationaleImpl) then) =
      __$$CarePlanRationaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, dynamic> features,
      List<String> rulesFired,
      double confidence,
      Map<String, dynamic> mlAdjustments,
      List<String> environmentalFactors,
      String? explanation,
      String? summary});
}

/// @nodoc
class __$$CarePlanRationaleImplCopyWithImpl<$Res>
    extends _$CarePlanRationaleCopyWithImpl<$Res, _$CarePlanRationaleImpl>
    implements _$$CarePlanRationaleImplCopyWith<$Res> {
  __$$CarePlanRationaleImplCopyWithImpl(_$CarePlanRationaleImpl _value,
      $Res Function(_$CarePlanRationaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanRationale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? features = null,
    Object? rulesFired = null,
    Object? confidence = null,
    Object? mlAdjustments = null,
    Object? environmentalFactors = null,
    Object? explanation = freezed,
    Object? summary = freezed,
  }) {
    return _then(_$CarePlanRationaleImpl(
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      rulesFired: null == rulesFired
          ? _value._rulesFired
          : rulesFired // ignore: cast_nullable_to_non_nullable
              as List<String>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      mlAdjustments: null == mlAdjustments
          ? _value._mlAdjustments
          : mlAdjustments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      environmentalFactors: null == environmentalFactors
          ? _value._environmentalFactors
          : environmentalFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanRationaleImpl implements _CarePlanRationale {
  const _$CarePlanRationaleImpl(
      {required final Map<String, dynamic> features,
      required final List<String> rulesFired,
      required this.confidence,
      final Map<String, dynamic> mlAdjustments = const {},
      final List<String> environmentalFactors = const [],
      this.explanation,
      this.summary})
      : _features = features,
        _rulesFired = rulesFired,
        _mlAdjustments = mlAdjustments,
        _environmentalFactors = environmentalFactors;

  factory _$CarePlanRationaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanRationaleImplFromJson(json);

  final Map<String, dynamic> _features;
  @override
  Map<String, dynamic> get features {
    if (_features is EqualUnmodifiableMapView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_features);
  }

  final List<String> _rulesFired;
  @override
  List<String> get rulesFired {
    if (_rulesFired is EqualUnmodifiableListView) return _rulesFired;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rulesFired);
  }

  @override
  final double confidence;
  final Map<String, dynamic> _mlAdjustments;
  @override
  @JsonKey()
  Map<String, dynamic> get mlAdjustments {
    if (_mlAdjustments is EqualUnmodifiableMapView) return _mlAdjustments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_mlAdjustments);
  }

  final List<String> _environmentalFactors;
  @override
  @JsonKey()
  List<String> get environmentalFactors {
    if (_environmentalFactors is EqualUnmodifiableListView)
      return _environmentalFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_environmentalFactors);
  }

  @override
  final String? explanation;
  @override
  final String? summary;

  @override
  String toString() {
    return 'CarePlanRationale(features: $features, rulesFired: $rulesFired, confidence: $confidence, mlAdjustments: $mlAdjustments, environmentalFactors: $environmentalFactors, explanation: $explanation, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanRationaleImpl &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            const DeepCollectionEquality()
                .equals(other._rulesFired, _rulesFired) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._mlAdjustments, _mlAdjustments) &&
            const DeepCollectionEquality()
                .equals(other._environmentalFactors, _environmentalFactors) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_features),
      const DeepCollectionEquality().hash(_rulesFired),
      confidence,
      const DeepCollectionEquality().hash(_mlAdjustments),
      const DeepCollectionEquality().hash(_environmentalFactors),
      explanation,
      summary);

  /// Create a copy of CarePlanRationale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanRationaleImplCopyWith<_$CarePlanRationaleImpl> get copyWith =>
      __$$CarePlanRationaleImplCopyWithImpl<_$CarePlanRationaleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanRationaleImplToJson(
      this,
    );
  }
}

abstract class _CarePlanRationale implements CarePlanRationale {
  const factory _CarePlanRationale(
      {required final Map<String, dynamic> features,
      required final List<String> rulesFired,
      required final double confidence,
      final Map<String, dynamic> mlAdjustments,
      final List<String> environmentalFactors,
      final String? explanation,
      final String? summary}) = _$CarePlanRationaleImpl;

  factory _CarePlanRationale.fromJson(Map<String, dynamic> json) =
      _$CarePlanRationaleImpl.fromJson;

  @override
  Map<String, dynamic> get features;
  @override
  List<String> get rulesFired;
  @override
  double get confidence;
  @override
  Map<String, dynamic> get mlAdjustments;
  @override
  List<String> get environmentalFactors;
  @override
  String? get explanation;
  @override
  String? get summary;

  /// Create a copy of CarePlanRationale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanRationaleImplCopyWith<_$CarePlanRationaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CarePlanGenerationRequest _$CarePlanGenerationRequestFromJson(
    Map<String, dynamic> json) {
  return _CarePlanGenerationRequest.fromJson(json);
}

/// @nodoc
mixin _$CarePlanGenerationRequest {
  String get userPlantId => throw _privateConstructorUsedError;
  bool get includeEnvironmentalData => throw _privateConstructorUsedError;
  bool get includeHistoricalData => throw _privateConstructorUsedError;
  bool get enableAdaptiveLearning => throw _privateConstructorUsedError;
  List<String> get focusAreas => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CarePlanGenerationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanGenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanGenerationRequestCopyWith<CarePlanGenerationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanGenerationRequestCopyWith<$Res> {
  factory $CarePlanGenerationRequestCopyWith(CarePlanGenerationRequest value,
          $Res Function(CarePlanGenerationRequest) then) =
      _$CarePlanGenerationRequestCopyWithImpl<$Res, CarePlanGenerationRequest>;
  @useResult
  $Res call(
      {String userPlantId,
      bool includeEnvironmentalData,
      bool includeHistoricalData,
      bool enableAdaptiveLearning,
      List<String> focusAreas,
      String? notes});
}

/// @nodoc
class _$CarePlanGenerationRequestCopyWithImpl<$Res,
        $Val extends CarePlanGenerationRequest>
    implements $CarePlanGenerationRequestCopyWith<$Res> {
  _$CarePlanGenerationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanGenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPlantId = null,
    Object? includeEnvironmentalData = null,
    Object? includeHistoricalData = null,
    Object? enableAdaptiveLearning = null,
    Object? focusAreas = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      userPlantId: null == userPlantId
          ? _value.userPlantId
          : userPlantId // ignore: cast_nullable_to_non_nullable
              as String,
      includeEnvironmentalData: null == includeEnvironmentalData
          ? _value.includeEnvironmentalData
          : includeEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as bool,
      includeHistoricalData: null == includeHistoricalData
          ? _value.includeHistoricalData
          : includeHistoricalData // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAdaptiveLearning: null == enableAdaptiveLearning
          ? _value.enableAdaptiveLearning
          : enableAdaptiveLearning // ignore: cast_nullable_to_non_nullable
              as bool,
      focusAreas: null == focusAreas
          ? _value.focusAreas
          : focusAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanGenerationRequestImplCopyWith<$Res>
    implements $CarePlanGenerationRequestCopyWith<$Res> {
  factory _$$CarePlanGenerationRequestImplCopyWith(
          _$CarePlanGenerationRequestImpl value,
          $Res Function(_$CarePlanGenerationRequestImpl) then) =
      __$$CarePlanGenerationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userPlantId,
      bool includeEnvironmentalData,
      bool includeHistoricalData,
      bool enableAdaptiveLearning,
      List<String> focusAreas,
      String? notes});
}

/// @nodoc
class __$$CarePlanGenerationRequestImplCopyWithImpl<$Res>
    extends _$CarePlanGenerationRequestCopyWithImpl<$Res,
        _$CarePlanGenerationRequestImpl>
    implements _$$CarePlanGenerationRequestImplCopyWith<$Res> {
  __$$CarePlanGenerationRequestImplCopyWithImpl(
      _$CarePlanGenerationRequestImpl _value,
      $Res Function(_$CarePlanGenerationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanGenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPlantId = null,
    Object? includeEnvironmentalData = null,
    Object? includeHistoricalData = null,
    Object? enableAdaptiveLearning = null,
    Object? focusAreas = null,
    Object? notes = freezed,
  }) {
    return _then(_$CarePlanGenerationRequestImpl(
      userPlantId: null == userPlantId
          ? _value.userPlantId
          : userPlantId // ignore: cast_nullable_to_non_nullable
              as String,
      includeEnvironmentalData: null == includeEnvironmentalData
          ? _value.includeEnvironmentalData
          : includeEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as bool,
      includeHistoricalData: null == includeHistoricalData
          ? _value.includeHistoricalData
          : includeHistoricalData // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAdaptiveLearning: null == enableAdaptiveLearning
          ? _value.enableAdaptiveLearning
          : enableAdaptiveLearning // ignore: cast_nullable_to_non_nullable
              as bool,
      focusAreas: null == focusAreas
          ? _value._focusAreas
          : focusAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanGenerationRequestImpl implements _CarePlanGenerationRequest {
  const _$CarePlanGenerationRequestImpl(
      {required this.userPlantId,
      this.includeEnvironmentalData = false,
      this.includeHistoricalData = false,
      this.enableAdaptiveLearning = false,
      final List<String> focusAreas = const <String>[],
      this.notes})
      : _focusAreas = focusAreas;

  factory _$CarePlanGenerationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanGenerationRequestImplFromJson(json);

  @override
  final String userPlantId;
  @override
  @JsonKey()
  final bool includeEnvironmentalData;
  @override
  @JsonKey()
  final bool includeHistoricalData;
  @override
  @JsonKey()
  final bool enableAdaptiveLearning;
  final List<String> _focusAreas;
  @override
  @JsonKey()
  List<String> get focusAreas {
    if (_focusAreas is EqualUnmodifiableListView) return _focusAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_focusAreas);
  }

  @override
  final String? notes;

  @override
  String toString() {
    return 'CarePlanGenerationRequest(userPlantId: $userPlantId, includeEnvironmentalData: $includeEnvironmentalData, includeHistoricalData: $includeHistoricalData, enableAdaptiveLearning: $enableAdaptiveLearning, focusAreas: $focusAreas, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanGenerationRequestImpl &&
            (identical(other.userPlantId, userPlantId) ||
                other.userPlantId == userPlantId) &&
            (identical(
                    other.includeEnvironmentalData, includeEnvironmentalData) ||
                other.includeEnvironmentalData == includeEnvironmentalData) &&
            (identical(other.includeHistoricalData, includeHistoricalData) ||
                other.includeHistoricalData == includeHistoricalData) &&
            (identical(other.enableAdaptiveLearning, enableAdaptiveLearning) ||
                other.enableAdaptiveLearning == enableAdaptiveLearning) &&
            const DeepCollectionEquality()
                .equals(other._focusAreas, _focusAreas) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userPlantId,
      includeEnvironmentalData,
      includeHistoricalData,
      enableAdaptiveLearning,
      const DeepCollectionEquality().hash(_focusAreas),
      notes);

  /// Create a copy of CarePlanGenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanGenerationRequestImplCopyWith<_$CarePlanGenerationRequestImpl>
      get copyWith => __$$CarePlanGenerationRequestImplCopyWithImpl<
          _$CarePlanGenerationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanGenerationRequestImplToJson(
      this,
    );
  }
}

abstract class _CarePlanGenerationRequest implements CarePlanGenerationRequest {
  const factory _CarePlanGenerationRequest(
      {required final String userPlantId,
      final bool includeEnvironmentalData,
      final bool includeHistoricalData,
      final bool enableAdaptiveLearning,
      final List<String> focusAreas,
      final String? notes}) = _$CarePlanGenerationRequestImpl;

  factory _CarePlanGenerationRequest.fromJson(Map<String, dynamic> json) =
      _$CarePlanGenerationRequestImpl.fromJson;

  @override
  String get userPlantId;
  @override
  bool get includeEnvironmentalData;
  @override
  bool get includeHistoricalData;
  @override
  bool get enableAdaptiveLearning;
  @override
  List<String> get focusAreas;
  @override
  String? get notes;

  /// Create a copy of CarePlanGenerationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanGenerationRequestImplCopyWith<_$CarePlanGenerationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CarePlanGenerationResponse _$CarePlanGenerationResponseFromJson(
    Map<String, dynamic> json) {
  return _CarePlanGenerationResponse.fromJson(json);
}

/// @nodoc
mixin _$CarePlanGenerationResponse {
  CarePlan get carePlan => throw _privateConstructorUsedError;
  bool get isNewVersion => throw _privateConstructorUsedError;
  List<String> get changes => throw _privateConstructorUsedError;
  int get generationTimeMs => throw _privateConstructorUsedError;

  /// Serializes this CarePlanGenerationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanGenerationResponseCopyWith<CarePlanGenerationResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanGenerationResponseCopyWith<$Res> {
  factory $CarePlanGenerationResponseCopyWith(CarePlanGenerationResponse value,
          $Res Function(CarePlanGenerationResponse) then) =
      _$CarePlanGenerationResponseCopyWithImpl<$Res,
          CarePlanGenerationResponse>;
  @useResult
  $Res call(
      {CarePlan carePlan,
      bool isNewVersion,
      List<String> changes,
      int generationTimeMs});

  $CarePlanCopyWith<$Res> get carePlan;
}

/// @nodoc
class _$CarePlanGenerationResponseCopyWithImpl<$Res,
        $Val extends CarePlanGenerationResponse>
    implements $CarePlanGenerationResponseCopyWith<$Res> {
  _$CarePlanGenerationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carePlan = null,
    Object? isNewVersion = null,
    Object? changes = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_value.copyWith(
      carePlan: null == carePlan
          ? _value.carePlan
          : carePlan // ignore: cast_nullable_to_non_nullable
              as CarePlan,
      isNewVersion: null == isNewVersion
          ? _value.isNewVersion
          : isNewVersion // ignore: cast_nullable_to_non_nullable
              as bool,
      changes: null == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      generationTimeMs: null == generationTimeMs
          ? _value.generationTimeMs
          : generationTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CarePlanCopyWith<$Res> get carePlan {
    return $CarePlanCopyWith<$Res>(_value.carePlan, (value) {
      return _then(_value.copyWith(carePlan: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CarePlanGenerationResponseImplCopyWith<$Res>
    implements $CarePlanGenerationResponseCopyWith<$Res> {
  factory _$$CarePlanGenerationResponseImplCopyWith(
          _$CarePlanGenerationResponseImpl value,
          $Res Function(_$CarePlanGenerationResponseImpl) then) =
      __$$CarePlanGenerationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CarePlan carePlan,
      bool isNewVersion,
      List<String> changes,
      int generationTimeMs});

  @override
  $CarePlanCopyWith<$Res> get carePlan;
}

/// @nodoc
class __$$CarePlanGenerationResponseImplCopyWithImpl<$Res>
    extends _$CarePlanGenerationResponseCopyWithImpl<$Res,
        _$CarePlanGenerationResponseImpl>
    implements _$$CarePlanGenerationResponseImplCopyWith<$Res> {
  __$$CarePlanGenerationResponseImplCopyWithImpl(
      _$CarePlanGenerationResponseImpl _value,
      $Res Function(_$CarePlanGenerationResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carePlan = null,
    Object? isNewVersion = null,
    Object? changes = null,
    Object? generationTimeMs = null,
  }) {
    return _then(_$CarePlanGenerationResponseImpl(
      carePlan: null == carePlan
          ? _value.carePlan
          : carePlan // ignore: cast_nullable_to_non_nullable
              as CarePlan,
      isNewVersion: null == isNewVersion
          ? _value.isNewVersion
          : isNewVersion // ignore: cast_nullable_to_non_nullable
              as bool,
      changes: null == changes
          ? _value._changes
          : changes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      generationTimeMs: null == generationTimeMs
          ? _value.generationTimeMs
          : generationTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanGenerationResponseImpl implements _CarePlanGenerationResponse {
  const _$CarePlanGenerationResponseImpl(
      {required this.carePlan,
      required this.isNewVersion,
      final List<String> changes = const [],
      required this.generationTimeMs})
      : _changes = changes;

  factory _$CarePlanGenerationResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CarePlanGenerationResponseImplFromJson(json);

  @override
  final CarePlan carePlan;
  @override
  final bool isNewVersion;
  final List<String> _changes;
  @override
  @JsonKey()
  List<String> get changes {
    if (_changes is EqualUnmodifiableListView) return _changes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_changes);
  }

  @override
  final int generationTimeMs;

  @override
  String toString() {
    return 'CarePlanGenerationResponse(carePlan: $carePlan, isNewVersion: $isNewVersion, changes: $changes, generationTimeMs: $generationTimeMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanGenerationResponseImpl &&
            (identical(other.carePlan, carePlan) ||
                other.carePlan == carePlan) &&
            (identical(other.isNewVersion, isNewVersion) ||
                other.isNewVersion == isNewVersion) &&
            const DeepCollectionEquality().equals(other._changes, _changes) &&
            (identical(other.generationTimeMs, generationTimeMs) ||
                other.generationTimeMs == generationTimeMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, carePlan, isNewVersion,
      const DeepCollectionEquality().hash(_changes), generationTimeMs);

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanGenerationResponseImplCopyWith<_$CarePlanGenerationResponseImpl>
      get copyWith => __$$CarePlanGenerationResponseImplCopyWithImpl<
          _$CarePlanGenerationResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanGenerationResponseImplToJson(
      this,
    );
  }
}

abstract class _CarePlanGenerationResponse
    implements CarePlanGenerationResponse {
  const factory _CarePlanGenerationResponse(
      {required final CarePlan carePlan,
      required final bool isNewVersion,
      final List<String> changes,
      required final int generationTimeMs}) = _$CarePlanGenerationResponseImpl;

  factory _CarePlanGenerationResponse.fromJson(Map<String, dynamic> json) =
      _$CarePlanGenerationResponseImpl.fromJson;

  @override
  CarePlan get carePlan;
  @override
  bool get isNewVersion;
  @override
  List<String> get changes;
  @override
  int get generationTimeMs;

  /// Create a copy of CarePlanGenerationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanGenerationResponseImplCopyWith<_$CarePlanGenerationResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CarePlanHistory _$CarePlanHistoryFromJson(Map<String, dynamic> json) {
  return _CarePlanHistory.fromJson(json);
}

/// @nodoc
mixin _$CarePlanHistory {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isAcknowledged => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get plantNickname => throw _privateConstructorUsedError;
  String get speciesName => throw _privateConstructorUsedError;
  DateTime get nextWateringDue => throw _privateConstructorUsedError;
  List<String> get urgentAlerts => throw _privateConstructorUsedError;

  /// Serializes this CarePlanHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanHistoryCopyWith<CarePlanHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanHistoryCopyWith<$Res> {
  factory $CarePlanHistoryCopyWith(
          CarePlanHistory value, $Res Function(CarePlanHistory) then) =
      _$CarePlanHistoryCopyWithImpl<$Res, CarePlanHistory>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      int version,
      DateTime createdAt,
      bool isAcknowledged,
      bool isActive,
      String plantNickname,
      String speciesName,
      DateTime nextWateringDue,
      List<String> urgentAlerts});
}

/// @nodoc
class _$CarePlanHistoryCopyWithImpl<$Res, $Val extends CarePlanHistory>
    implements $CarePlanHistoryCopyWith<$Res> {
  _$CarePlanHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? version = null,
    Object? createdAt = null,
    Object? isAcknowledged = null,
    Object? isActive = null,
    Object? plantNickname = null,
    Object? speciesName = null,
    Object? nextWateringDue = null,
    Object? urgentAlerts = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      plantNickname: null == plantNickname
          ? _value.plantNickname
          : plantNickname // ignore: cast_nullable_to_non_nullable
              as String,
      speciesName: null == speciesName
          ? _value.speciesName
          : speciesName // ignore: cast_nullable_to_non_nullable
              as String,
      nextWateringDue: null == nextWateringDue
          ? _value.nextWateringDue
          : nextWateringDue // ignore: cast_nullable_to_non_nullable
              as DateTime,
      urgentAlerts: null == urgentAlerts
          ? _value.urgentAlerts
          : urgentAlerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanHistoryImplCopyWith<$Res>
    implements $CarePlanHistoryCopyWith<$Res> {
  factory _$$CarePlanHistoryImplCopyWith(_$CarePlanHistoryImpl value,
          $Res Function(_$CarePlanHistoryImpl) then) =
      __$$CarePlanHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      int version,
      DateTime createdAt,
      bool isAcknowledged,
      bool isActive,
      String plantNickname,
      String speciesName,
      DateTime nextWateringDue,
      List<String> urgentAlerts});
}

/// @nodoc
class __$$CarePlanHistoryImplCopyWithImpl<$Res>
    extends _$CarePlanHistoryCopyWithImpl<$Res, _$CarePlanHistoryImpl>
    implements _$$CarePlanHistoryImplCopyWith<$Res> {
  __$$CarePlanHistoryImplCopyWithImpl(
      _$CarePlanHistoryImpl _value, $Res Function(_$CarePlanHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? version = null,
    Object? createdAt = null,
    Object? isAcknowledged = null,
    Object? isActive = null,
    Object? plantNickname = null,
    Object? speciesName = null,
    Object? nextWateringDue = null,
    Object? urgentAlerts = null,
  }) {
    return _then(_$CarePlanHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      plantNickname: null == plantNickname
          ? _value.plantNickname
          : plantNickname // ignore: cast_nullable_to_non_nullable
              as String,
      speciesName: null == speciesName
          ? _value.speciesName
          : speciesName // ignore: cast_nullable_to_non_nullable
              as String,
      nextWateringDue: null == nextWateringDue
          ? _value.nextWateringDue
          : nextWateringDue // ignore: cast_nullable_to_non_nullable
              as DateTime,
      urgentAlerts: null == urgentAlerts
          ? _value._urgentAlerts
          : urgentAlerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanHistoryImpl implements _CarePlanHistory {
  const _$CarePlanHistoryImpl(
      {required this.id,
      required this.plantId,
      required this.version,
      required this.createdAt,
      required this.isAcknowledged,
      required this.isActive,
      required this.plantNickname,
      required this.speciesName,
      required this.nextWateringDue,
      final List<String> urgentAlerts = const []})
      : _urgentAlerts = urgentAlerts;

  factory _$CarePlanHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final bool isAcknowledged;
  @override
  final bool isActive;
  @override
  final String plantNickname;
  @override
  final String speciesName;
  @override
  final DateTime nextWateringDue;
  final List<String> _urgentAlerts;
  @override
  @JsonKey()
  List<String> get urgentAlerts {
    if (_urgentAlerts is EqualUnmodifiableListView) return _urgentAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_urgentAlerts);
  }

  @override
  String toString() {
    return 'CarePlanHistory(id: $id, plantId: $plantId, version: $version, createdAt: $createdAt, isAcknowledged: $isAcknowledged, isActive: $isActive, plantNickname: $plantNickname, speciesName: $speciesName, nextWateringDue: $nextWateringDue, urgentAlerts: $urgentAlerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isAcknowledged, isAcknowledged) ||
                other.isAcknowledged == isAcknowledged) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.plantNickname, plantNickname) ||
                other.plantNickname == plantNickname) &&
            (identical(other.speciesName, speciesName) ||
                other.speciesName == speciesName) &&
            (identical(other.nextWateringDue, nextWateringDue) ||
                other.nextWateringDue == nextWateringDue) &&
            const DeepCollectionEquality()
                .equals(other._urgentAlerts, _urgentAlerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      plantId,
      version,
      createdAt,
      isAcknowledged,
      isActive,
      plantNickname,
      speciesName,
      nextWateringDue,
      const DeepCollectionEquality().hash(_urgentAlerts));

  /// Create a copy of CarePlanHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanHistoryImplCopyWith<_$CarePlanHistoryImpl> get copyWith =>
      __$$CarePlanHistoryImplCopyWithImpl<_$CarePlanHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanHistoryImplToJson(
      this,
    );
  }
}

abstract class _CarePlanHistory implements CarePlanHistory {
  const factory _CarePlanHistory(
      {required final String id,
      required final String plantId,
      required final int version,
      required final DateTime createdAt,
      required final bool isAcknowledged,
      required final bool isActive,
      required final String plantNickname,
      required final String speciesName,
      required final DateTime nextWateringDue,
      final List<String> urgentAlerts}) = _$CarePlanHistoryImpl;

  factory _CarePlanHistory.fromJson(Map<String, dynamic> json) =
      _$CarePlanHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  int get version;
  @override
  DateTime get createdAt;
  @override
  bool get isAcknowledged;
  @override
  bool get isActive;
  @override
  String get plantNickname;
  @override
  String get speciesName;
  @override
  DateTime get nextWateringDue;
  @override
  List<String> get urgentAlerts;

  /// Create a copy of CarePlanHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanHistoryImplCopyWith<_$CarePlanHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CarePlanHistoryParams _$CarePlanHistoryParamsFromJson(
    Map<String, dynamic> json) {
  return _CarePlanHistoryParams.fromJson(json);
}

/// @nodoc
mixin _$CarePlanHistoryParams {
  String get userPlantId => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  /// Serializes this CarePlanHistoryParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanHistoryParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanHistoryParamsCopyWith<CarePlanHistoryParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanHistoryParamsCopyWith<$Res> {
  factory $CarePlanHistoryParamsCopyWith(CarePlanHistoryParams value,
          $Res Function(CarePlanHistoryParams) then) =
      _$CarePlanHistoryParamsCopyWithImpl<$Res, CarePlanHistoryParams>;
  @useResult
  $Res call({String userPlantId, int page, int limit});
}

/// @nodoc
class _$CarePlanHistoryParamsCopyWithImpl<$Res,
        $Val extends CarePlanHistoryParams>
    implements $CarePlanHistoryParamsCopyWith<$Res> {
  _$CarePlanHistoryParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanHistoryParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPlantId = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      userPlantId: null == userPlantId
          ? _value.userPlantId
          : userPlantId // ignore: cast_nullable_to_non_nullable
              as String,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanHistoryParamsImplCopyWith<$Res>
    implements $CarePlanHistoryParamsCopyWith<$Res> {
  factory _$$CarePlanHistoryParamsImplCopyWith(
          _$CarePlanHistoryParamsImpl value,
          $Res Function(_$CarePlanHistoryParamsImpl) then) =
      __$$CarePlanHistoryParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userPlantId, int page, int limit});
}

/// @nodoc
class __$$CarePlanHistoryParamsImplCopyWithImpl<$Res>
    extends _$CarePlanHistoryParamsCopyWithImpl<$Res,
        _$CarePlanHistoryParamsImpl>
    implements _$$CarePlanHistoryParamsImplCopyWith<$Res> {
  __$$CarePlanHistoryParamsImplCopyWithImpl(_$CarePlanHistoryParamsImpl _value,
      $Res Function(_$CarePlanHistoryParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanHistoryParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userPlantId = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_$CarePlanHistoryParamsImpl(
      userPlantId: null == userPlantId
          ? _value.userPlantId
          : userPlantId // ignore: cast_nullable_to_non_nullable
              as String,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanHistoryParamsImpl implements _CarePlanHistoryParams {
  const _$CarePlanHistoryParamsImpl(
      {required this.userPlantId, this.page = 1, this.limit = 20});

  factory _$CarePlanHistoryParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanHistoryParamsImplFromJson(json);

  @override
  final String userPlantId;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'CarePlanHistoryParams(userPlantId: $userPlantId, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanHistoryParamsImpl &&
            (identical(other.userPlantId, userPlantId) ||
                other.userPlantId == userPlantId) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userPlantId, page, limit);

  /// Create a copy of CarePlanHistoryParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanHistoryParamsImplCopyWith<_$CarePlanHistoryParamsImpl>
      get copyWith => __$$CarePlanHistoryParamsImplCopyWithImpl<
          _$CarePlanHistoryParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanHistoryParamsImplToJson(
      this,
    );
  }
}

abstract class _CarePlanHistoryParams implements CarePlanHistoryParams {
  const factory _CarePlanHistoryParams(
      {required final String userPlantId,
      final int page,
      final int limit}) = _$CarePlanHistoryParamsImpl;

  factory _CarePlanHistoryParams.fromJson(Map<String, dynamic> json) =
      _$CarePlanHistoryParamsImpl.fromJson;

  @override
  String get userPlantId;
  @override
  int get page;
  @override
  int get limit;

  /// Create a copy of CarePlanHistoryParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanHistoryParamsImplCopyWith<_$CarePlanHistoryParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CarePlanHistoryResponse _$CarePlanHistoryResponseFromJson(
    Map<String, dynamic> json) {
  return _CarePlanHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$CarePlanHistoryResponse {
  String get plantId => throw _privateConstructorUsedError;
  List<CarePlanHistory> get plans => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get currentVersion => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this CarePlanHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanHistoryResponseCopyWith<CarePlanHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanHistoryResponseCopyWith<$Res> {
  factory $CarePlanHistoryResponseCopyWith(CarePlanHistoryResponse value,
          $Res Function(CarePlanHistoryResponse) then) =
      _$CarePlanHistoryResponseCopyWithImpl<$Res, CarePlanHistoryResponse>;
  @useResult
  $Res call(
      {String plantId,
      List<CarePlanHistory> plans,
      int totalCount,
      int currentVersion,
      bool hasMore});
}

/// @nodoc
class _$CarePlanHistoryResponseCopyWithImpl<$Res,
        $Val extends CarePlanHistoryResponse>
    implements $CarePlanHistoryResponseCopyWith<$Res> {
  _$CarePlanHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plantId = null,
    Object? plans = null,
    Object? totalCount = null,
    Object? currentVersion = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      plans: null == plans
          ? _value.plans
          : plans // ignore: cast_nullable_to_non_nullable
              as List<CarePlanHistory>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanHistoryResponseImplCopyWith<$Res>
    implements $CarePlanHistoryResponseCopyWith<$Res> {
  factory _$$CarePlanHistoryResponseImplCopyWith(
          _$CarePlanHistoryResponseImpl value,
          $Res Function(_$CarePlanHistoryResponseImpl) then) =
      __$$CarePlanHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String plantId,
      List<CarePlanHistory> plans,
      int totalCount,
      int currentVersion,
      bool hasMore});
}

/// @nodoc
class __$$CarePlanHistoryResponseImplCopyWithImpl<$Res>
    extends _$CarePlanHistoryResponseCopyWithImpl<$Res,
        _$CarePlanHistoryResponseImpl>
    implements _$$CarePlanHistoryResponseImplCopyWith<$Res> {
  __$$CarePlanHistoryResponseImplCopyWithImpl(
      _$CarePlanHistoryResponseImpl _value,
      $Res Function(_$CarePlanHistoryResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plantId = null,
    Object? plans = null,
    Object? totalCount = null,
    Object? currentVersion = null,
    Object? hasMore = null,
  }) {
    return _then(_$CarePlanHistoryResponseImpl(
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      plans: null == plans
          ? _value._plans
          : plans // ignore: cast_nullable_to_non_nullable
              as List<CarePlanHistory>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanHistoryResponseImpl implements _CarePlanHistoryResponse {
  const _$CarePlanHistoryResponseImpl(
      {required this.plantId,
      required final List<CarePlanHistory> plans,
      required this.totalCount,
      required this.currentVersion,
      this.hasMore = false})
      : _plans = plans;

  factory _$CarePlanHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanHistoryResponseImplFromJson(json);

  @override
  final String plantId;
  final List<CarePlanHistory> _plans;
  @override
  List<CarePlanHistory> get plans {
    if (_plans is EqualUnmodifiableListView) return _plans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plans);
  }

  @override
  final int totalCount;
  @override
  final int currentVersion;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'CarePlanHistoryResponse(plantId: $plantId, plans: $plans, totalCount: $totalCount, currentVersion: $currentVersion, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanHistoryResponseImpl &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            const DeepCollectionEquality().equals(other._plans, _plans) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.currentVersion, currentVersion) ||
                other.currentVersion == currentVersion) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      plantId,
      const DeepCollectionEquality().hash(_plans),
      totalCount,
      currentVersion,
      hasMore);

  /// Create a copy of CarePlanHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanHistoryResponseImplCopyWith<_$CarePlanHistoryResponseImpl>
      get copyWith => __$$CarePlanHistoryResponseImplCopyWithImpl<
          _$CarePlanHistoryResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanHistoryResponseImplToJson(
      this,
    );
  }
}

abstract class _CarePlanHistoryResponse implements CarePlanHistoryResponse {
  const factory _CarePlanHistoryResponse(
      {required final String plantId,
      required final List<CarePlanHistory> plans,
      required final int totalCount,
      required final int currentVersion,
      final bool hasMore}) = _$CarePlanHistoryResponseImpl;

  factory _CarePlanHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$CarePlanHistoryResponseImpl.fromJson;

  @override
  String get plantId;
  @override
  List<CarePlanHistory> get plans;
  @override
  int get totalCount;
  @override
  int get currentVersion;
  @override
  bool get hasMore;

  /// Create a copy of CarePlanHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanHistoryResponseImplCopyWith<_$CarePlanHistoryResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CarePlanState _$CarePlanStateFromJson(Map<String, dynamic> json) {
  return _CarePlanState.fromJson(json);
}

/// @nodoc
mixin _$CarePlanState {
// Loading flags
  bool get isLoadingPlans => throw _privateConstructorUsedError;
  bool get isLoadingHistory => throw _privateConstructorUsedError;
  bool get isLoadingNotifications => throw _privateConstructorUsedError;
  bool get isGenerating =>
      throw _privateConstructorUsedError; // Data collections
  List<CarePlan> get activePlans => throw _privateConstructorUsedError;
  List<CarePlanHistory> get planHistory => throw _privateConstructorUsedError;
  List<CarePlanNotification> get pendingNotifications =>
      throw _privateConstructorUsedError; // Pagination
  bool get hasMoreHistory => throw _privateConstructorUsedError;
  int get currentHistoryPage => throw _privateConstructorUsedError; // Errors
  String? get error => throw _privateConstructorUsedError;
  String? get generateError => throw _privateConstructorUsedError;
  String? get acknowledgeError => throw _privateConstructorUsedError;
  String? get historyError => throw _privateConstructorUsedError;
  String? get notificationError =>
      throw _privateConstructorUsedError; // Metadata
  String? get lastGeneratedPlanId => throw _privateConstructorUsedError;

  /// Serializes this CarePlanState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanStateCopyWith<CarePlanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanStateCopyWith<$Res> {
  factory $CarePlanStateCopyWith(
          CarePlanState value, $Res Function(CarePlanState) then) =
      _$CarePlanStateCopyWithImpl<$Res, CarePlanState>;
  @useResult
  $Res call(
      {bool isLoadingPlans,
      bool isLoadingHistory,
      bool isLoadingNotifications,
      bool isGenerating,
      List<CarePlan> activePlans,
      List<CarePlanHistory> planHistory,
      List<CarePlanNotification> pendingNotifications,
      bool hasMoreHistory,
      int currentHistoryPage,
      String? error,
      String? generateError,
      String? acknowledgeError,
      String? historyError,
      String? notificationError,
      String? lastGeneratedPlanId});
}

/// @nodoc
class _$CarePlanStateCopyWithImpl<$Res, $Val extends CarePlanState>
    implements $CarePlanStateCopyWith<$Res> {
  _$CarePlanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingPlans = null,
    Object? isLoadingHistory = null,
    Object? isLoadingNotifications = null,
    Object? isGenerating = null,
    Object? activePlans = null,
    Object? planHistory = null,
    Object? pendingNotifications = null,
    Object? hasMoreHistory = null,
    Object? currentHistoryPage = null,
    Object? error = freezed,
    Object? generateError = freezed,
    Object? acknowledgeError = freezed,
    Object? historyError = freezed,
    Object? notificationError = freezed,
    Object? lastGeneratedPlanId = freezed,
  }) {
    return _then(_value.copyWith(
      isLoadingPlans: null == isLoadingPlans
          ? _value.isLoadingPlans
          : isLoadingPlans // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingHistory: null == isLoadingHistory
          ? _value.isLoadingHistory
          : isLoadingHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingNotifications: null == isLoadingNotifications
          ? _value.isLoadingNotifications
          : isLoadingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      isGenerating: null == isGenerating
          ? _value.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      activePlans: null == activePlans
          ? _value.activePlans
          : activePlans // ignore: cast_nullable_to_non_nullable
              as List<CarePlan>,
      planHistory: null == planHistory
          ? _value.planHistory
          : planHistory // ignore: cast_nullable_to_non_nullable
              as List<CarePlanHistory>,
      pendingNotifications: null == pendingNotifications
          ? _value.pendingNotifications
          : pendingNotifications // ignore: cast_nullable_to_non_nullable
              as List<CarePlanNotification>,
      hasMoreHistory: null == hasMoreHistory
          ? _value.hasMoreHistory
          : hasMoreHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      currentHistoryPage: null == currentHistoryPage
          ? _value.currentHistoryPage
          : currentHistoryPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      generateError: freezed == generateError
          ? _value.generateError
          : generateError // ignore: cast_nullable_to_non_nullable
              as String?,
      acknowledgeError: freezed == acknowledgeError
          ? _value.acknowledgeError
          : acknowledgeError // ignore: cast_nullable_to_non_nullable
              as String?,
      historyError: freezed == historyError
          ? _value.historyError
          : historyError // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationError: freezed == notificationError
          ? _value.notificationError
          : notificationError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastGeneratedPlanId: freezed == lastGeneratedPlanId
          ? _value.lastGeneratedPlanId
          : lastGeneratedPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanStateImplCopyWith<$Res>
    implements $CarePlanStateCopyWith<$Res> {
  factory _$$CarePlanStateImplCopyWith(
          _$CarePlanStateImpl value, $Res Function(_$CarePlanStateImpl) then) =
      __$$CarePlanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoadingPlans,
      bool isLoadingHistory,
      bool isLoadingNotifications,
      bool isGenerating,
      List<CarePlan> activePlans,
      List<CarePlanHistory> planHistory,
      List<CarePlanNotification> pendingNotifications,
      bool hasMoreHistory,
      int currentHistoryPage,
      String? error,
      String? generateError,
      String? acknowledgeError,
      String? historyError,
      String? notificationError,
      String? lastGeneratedPlanId});
}

/// @nodoc
class __$$CarePlanStateImplCopyWithImpl<$Res>
    extends _$CarePlanStateCopyWithImpl<$Res, _$CarePlanStateImpl>
    implements _$$CarePlanStateImplCopyWith<$Res> {
  __$$CarePlanStateImplCopyWithImpl(
      _$CarePlanStateImpl _value, $Res Function(_$CarePlanStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingPlans = null,
    Object? isLoadingHistory = null,
    Object? isLoadingNotifications = null,
    Object? isGenerating = null,
    Object? activePlans = null,
    Object? planHistory = null,
    Object? pendingNotifications = null,
    Object? hasMoreHistory = null,
    Object? currentHistoryPage = null,
    Object? error = freezed,
    Object? generateError = freezed,
    Object? acknowledgeError = freezed,
    Object? historyError = freezed,
    Object? notificationError = freezed,
    Object? lastGeneratedPlanId = freezed,
  }) {
    return _then(_$CarePlanStateImpl(
      isLoadingPlans: null == isLoadingPlans
          ? _value.isLoadingPlans
          : isLoadingPlans // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingHistory: null == isLoadingHistory
          ? _value.isLoadingHistory
          : isLoadingHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingNotifications: null == isLoadingNotifications
          ? _value.isLoadingNotifications
          : isLoadingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      isGenerating: null == isGenerating
          ? _value.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      activePlans: null == activePlans
          ? _value._activePlans
          : activePlans // ignore: cast_nullable_to_non_nullable
              as List<CarePlan>,
      planHistory: null == planHistory
          ? _value._planHistory
          : planHistory // ignore: cast_nullable_to_non_nullable
              as List<CarePlanHistory>,
      pendingNotifications: null == pendingNotifications
          ? _value._pendingNotifications
          : pendingNotifications // ignore: cast_nullable_to_non_nullable
              as List<CarePlanNotification>,
      hasMoreHistory: null == hasMoreHistory
          ? _value.hasMoreHistory
          : hasMoreHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      currentHistoryPage: null == currentHistoryPage
          ? _value.currentHistoryPage
          : currentHistoryPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      generateError: freezed == generateError
          ? _value.generateError
          : generateError // ignore: cast_nullable_to_non_nullable
              as String?,
      acknowledgeError: freezed == acknowledgeError
          ? _value.acknowledgeError
          : acknowledgeError // ignore: cast_nullable_to_non_nullable
              as String?,
      historyError: freezed == historyError
          ? _value.historyError
          : historyError // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationError: freezed == notificationError
          ? _value.notificationError
          : notificationError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastGeneratedPlanId: freezed == lastGeneratedPlanId
          ? _value.lastGeneratedPlanId
          : lastGeneratedPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanStateImpl implements _CarePlanState {
  const _$CarePlanStateImpl(
      {this.isLoadingPlans = false,
      this.isLoadingHistory = false,
      this.isLoadingNotifications = false,
      this.isGenerating = false,
      final List<CarePlan> activePlans = const <CarePlan>[],
      final List<CarePlanHistory> planHistory = const <CarePlanHistory>[],
      final List<CarePlanNotification> pendingNotifications =
          const <CarePlanNotification>[],
      this.hasMoreHistory = false,
      this.currentHistoryPage = 1,
      this.error,
      this.generateError,
      this.acknowledgeError,
      this.historyError,
      this.notificationError,
      this.lastGeneratedPlanId})
      : _activePlans = activePlans,
        _planHistory = planHistory,
        _pendingNotifications = pendingNotifications;

  factory _$CarePlanStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanStateImplFromJson(json);

// Loading flags
  @override
  @JsonKey()
  final bool isLoadingPlans;
  @override
  @JsonKey()
  final bool isLoadingHistory;
  @override
  @JsonKey()
  final bool isLoadingNotifications;
  @override
  @JsonKey()
  final bool isGenerating;
// Data collections
  final List<CarePlan> _activePlans;
// Data collections
  @override
  @JsonKey()
  List<CarePlan> get activePlans {
    if (_activePlans is EqualUnmodifiableListView) return _activePlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activePlans);
  }

  final List<CarePlanHistory> _planHistory;
  @override
  @JsonKey()
  List<CarePlanHistory> get planHistory {
    if (_planHistory is EqualUnmodifiableListView) return _planHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planHistory);
  }

  final List<CarePlanNotification> _pendingNotifications;
  @override
  @JsonKey()
  List<CarePlanNotification> get pendingNotifications {
    if (_pendingNotifications is EqualUnmodifiableListView)
      return _pendingNotifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingNotifications);
  }

// Pagination
  @override
  @JsonKey()
  final bool hasMoreHistory;
  @override
  @JsonKey()
  final int currentHistoryPage;
// Errors
  @override
  final String? error;
  @override
  final String? generateError;
  @override
  final String? acknowledgeError;
  @override
  final String? historyError;
  @override
  final String? notificationError;
// Metadata
  @override
  final String? lastGeneratedPlanId;

  @override
  String toString() {
    return 'CarePlanState(isLoadingPlans: $isLoadingPlans, isLoadingHistory: $isLoadingHistory, isLoadingNotifications: $isLoadingNotifications, isGenerating: $isGenerating, activePlans: $activePlans, planHistory: $planHistory, pendingNotifications: $pendingNotifications, hasMoreHistory: $hasMoreHistory, currentHistoryPage: $currentHistoryPage, error: $error, generateError: $generateError, acknowledgeError: $acknowledgeError, historyError: $historyError, notificationError: $notificationError, lastGeneratedPlanId: $lastGeneratedPlanId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanStateImpl &&
            (identical(other.isLoadingPlans, isLoadingPlans) ||
                other.isLoadingPlans == isLoadingPlans) &&
            (identical(other.isLoadingHistory, isLoadingHistory) ||
                other.isLoadingHistory == isLoadingHistory) &&
            (identical(other.isLoadingNotifications, isLoadingNotifications) ||
                other.isLoadingNotifications == isLoadingNotifications) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            const DeepCollectionEquality()
                .equals(other._activePlans, _activePlans) &&
            const DeepCollectionEquality()
                .equals(other._planHistory, _planHistory) &&
            const DeepCollectionEquality()
                .equals(other._pendingNotifications, _pendingNotifications) &&
            (identical(other.hasMoreHistory, hasMoreHistory) ||
                other.hasMoreHistory == hasMoreHistory) &&
            (identical(other.currentHistoryPage, currentHistoryPage) ||
                other.currentHistoryPage == currentHistoryPage) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.generateError, generateError) ||
                other.generateError == generateError) &&
            (identical(other.acknowledgeError, acknowledgeError) ||
                other.acknowledgeError == acknowledgeError) &&
            (identical(other.historyError, historyError) ||
                other.historyError == historyError) &&
            (identical(other.notificationError, notificationError) ||
                other.notificationError == notificationError) &&
            (identical(other.lastGeneratedPlanId, lastGeneratedPlanId) ||
                other.lastGeneratedPlanId == lastGeneratedPlanId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoadingPlans,
      isLoadingHistory,
      isLoadingNotifications,
      isGenerating,
      const DeepCollectionEquality().hash(_activePlans),
      const DeepCollectionEquality().hash(_planHistory),
      const DeepCollectionEquality().hash(_pendingNotifications),
      hasMoreHistory,
      currentHistoryPage,
      error,
      generateError,
      acknowledgeError,
      historyError,
      notificationError,
      lastGeneratedPlanId);

  /// Create a copy of CarePlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanStateImplCopyWith<_$CarePlanStateImpl> get copyWith =>
      __$$CarePlanStateImplCopyWithImpl<_$CarePlanStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanStateImplToJson(
      this,
    );
  }
}

abstract class _CarePlanState implements CarePlanState {
  const factory _CarePlanState(
      {final bool isLoadingPlans,
      final bool isLoadingHistory,
      final bool isLoadingNotifications,
      final bool isGenerating,
      final List<CarePlan> activePlans,
      final List<CarePlanHistory> planHistory,
      final List<CarePlanNotification> pendingNotifications,
      final bool hasMoreHistory,
      final int currentHistoryPage,
      final String? error,
      final String? generateError,
      final String? acknowledgeError,
      final String? historyError,
      final String? notificationError,
      final String? lastGeneratedPlanId}) = _$CarePlanStateImpl;

  factory _CarePlanState.fromJson(Map<String, dynamic> json) =
      _$CarePlanStateImpl.fromJson;

// Loading flags
  @override
  bool get isLoadingPlans;
  @override
  bool get isLoadingHistory;
  @override
  bool get isLoadingNotifications;
  @override
  bool get isGenerating; // Data collections
  @override
  List<CarePlan> get activePlans;
  @override
  List<CarePlanHistory> get planHistory;
  @override
  List<CarePlanNotification> get pendingNotifications; // Pagination
  @override
  bool get hasMoreHistory;
  @override
  int get currentHistoryPage; // Errors
  @override
  String? get error;
  @override
  String? get generateError;
  @override
  String? get acknowledgeError;
  @override
  String? get historyError;
  @override
  String? get notificationError; // Metadata
  @override
  String? get lastGeneratedPlanId;

  /// Create a copy of CarePlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanStateImplCopyWith<_$CarePlanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CarePlanNotification _$CarePlanNotificationFromJson(Map<String, dynamic> json) {
  return _CarePlanNotification.fromJson(json);
}

/// @nodoc
mixin _$CarePlanNotification {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  CarePlanNotificationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get scheduledFor => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isActioned => throw _privateConstructorUsedError;
  Map<String, dynamic> get actionData => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CarePlanNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarePlanNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarePlanNotificationCopyWith<CarePlanNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarePlanNotificationCopyWith<$Res> {
  factory $CarePlanNotificationCopyWith(CarePlanNotification value,
          $Res Function(CarePlanNotification) then) =
      _$CarePlanNotificationCopyWithImpl<$Res, CarePlanNotification>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      String planId,
      CarePlanNotificationType type,
      String title,
      String message,
      DateTime scheduledFor,
      bool isRead,
      bool isActioned,
      Map<String, dynamic> actionData,
      DateTime createdAt});
}

/// @nodoc
class _$CarePlanNotificationCopyWithImpl<$Res,
        $Val extends CarePlanNotification>
    implements $CarePlanNotificationCopyWith<$Res> {
  _$CarePlanNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarePlanNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? planId = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? scheduledFor = null,
    Object? isRead = null,
    Object? isActioned = null,
    Object? actionData = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CarePlanNotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledFor: null == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isActioned: null == isActioned
          ? _value.isActioned
          : isActioned // ignore: cast_nullable_to_non_nullable
              as bool,
      actionData: null == actionData
          ? _value.actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarePlanNotificationImplCopyWith<$Res>
    implements $CarePlanNotificationCopyWith<$Res> {
  factory _$$CarePlanNotificationImplCopyWith(_$CarePlanNotificationImpl value,
          $Res Function(_$CarePlanNotificationImpl) then) =
      __$$CarePlanNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      String planId,
      CarePlanNotificationType type,
      String title,
      String message,
      DateTime scheduledFor,
      bool isRead,
      bool isActioned,
      Map<String, dynamic> actionData,
      DateTime createdAt});
}

/// @nodoc
class __$$CarePlanNotificationImplCopyWithImpl<$Res>
    extends _$CarePlanNotificationCopyWithImpl<$Res, _$CarePlanNotificationImpl>
    implements _$$CarePlanNotificationImplCopyWith<$Res> {
  __$$CarePlanNotificationImplCopyWithImpl(_$CarePlanNotificationImpl _value,
      $Res Function(_$CarePlanNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarePlanNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? planId = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? scheduledFor = null,
    Object? isRead = null,
    Object? isActioned = null,
    Object? actionData = null,
    Object? createdAt = null,
  }) {
    return _then(_$CarePlanNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CarePlanNotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledFor: null == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isActioned: null == isActioned
          ? _value.isActioned
          : isActioned // ignore: cast_nullable_to_non_nullable
              as bool,
      actionData: null == actionData
          ? _value._actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarePlanNotificationImpl implements _CarePlanNotification {
  const _$CarePlanNotificationImpl(
      {required this.id,
      required this.plantId,
      required this.planId,
      required this.type,
      required this.title,
      required this.message,
      required this.scheduledFor,
      this.isRead = false,
      this.isActioned = false,
      final Map<String, dynamic> actionData = const {},
      required this.createdAt})
      : _actionData = actionData;

  factory _$CarePlanNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarePlanNotificationImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final String planId;
  @override
  final CarePlanNotificationType type;
  @override
  final String title;
  @override
  final String message;
  @override
  final DateTime scheduledFor;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isActioned;
  final Map<String, dynamic> _actionData;
  @override
  @JsonKey()
  Map<String, dynamic> get actionData {
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_actionData);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CarePlanNotification(id: $id, plantId: $plantId, planId: $planId, type: $type, title: $title, message: $message, scheduledFor: $scheduledFor, isRead: $isRead, isActioned: $isActioned, actionData: $actionData, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarePlanNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.scheduledFor, scheduledFor) ||
                other.scheduledFor == scheduledFor) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isActioned, isActioned) ||
                other.isActioned == isActioned) &&
            const DeepCollectionEquality()
                .equals(other._actionData, _actionData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      plantId,
      planId,
      type,
      title,
      message,
      scheduledFor,
      isRead,
      isActioned,
      const DeepCollectionEquality().hash(_actionData),
      createdAt);

  /// Create a copy of CarePlanNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarePlanNotificationImplCopyWith<_$CarePlanNotificationImpl>
      get copyWith =>
          __$$CarePlanNotificationImplCopyWithImpl<_$CarePlanNotificationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarePlanNotificationImplToJson(
      this,
    );
  }
}

abstract class _CarePlanNotification implements CarePlanNotification {
  const factory _CarePlanNotification(
      {required final String id,
      required final String plantId,
      required final String planId,
      required final CarePlanNotificationType type,
      required final String title,
      required final String message,
      required final DateTime scheduledFor,
      final bool isRead,
      final bool isActioned,
      final Map<String, dynamic> actionData,
      required final DateTime createdAt}) = _$CarePlanNotificationImpl;

  factory _CarePlanNotification.fromJson(Map<String, dynamic> json) =
      _$CarePlanNotificationImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  String get planId;
  @override
  CarePlanNotificationType get type;
  @override
  String get title;
  @override
  String get message;
  @override
  DateTime get scheduledFor;
  @override
  bool get isRead;
  @override
  bool get isActioned;
  @override
  Map<String, dynamic> get actionData;
  @override
  DateTime get createdAt;

  /// Create a copy of CarePlanNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarePlanNotificationImplCopyWith<_$CarePlanNotificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
