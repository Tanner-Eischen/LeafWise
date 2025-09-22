// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant_identification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlantIdentification _$PlantIdentificationFromJson(Map<String, dynamic> json) {
  return _PlantIdentification.fromJson(json);
}

/// @nodoc
mixin _$PlantIdentification {
  String get id => throw _privateConstructorUsedError;
  String get scientificName => throw _privateConstructorUsedError;
  String get commonName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  List<String> get alternativeNames => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  PlantCareInfo get careInfo => throw _privateConstructorUsedError;
  DateTime get identifiedAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this PlantIdentification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantIdentificationCopyWith<PlantIdentification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantIdentificationCopyWith<$Res> {
  factory $PlantIdentificationCopyWith(
          PlantIdentification value, $Res Function(PlantIdentification) then) =
      _$PlantIdentificationCopyWithImpl<$Res, PlantIdentification>;
  @useResult
  $Res call(
      {String id,
      String scientificName,
      String commonName,
      double confidence,
      List<String> alternativeNames,
      String imageUrl,
      PlantCareInfo careInfo,
      DateTime identifiedAt,
      String? description,
      List<String>? tags});

  $PlantCareInfoCopyWith<$Res> get careInfo;
}

/// @nodoc
class _$PlantIdentificationCopyWithImpl<$Res, $Val extends PlantIdentification>
    implements $PlantIdentificationCopyWith<$Res> {
  _$PlantIdentificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? alternativeNames = null,
    Object? imageUrl = null,
    Object? careInfo = null,
    Object? identifiedAt = null,
    Object? description = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      alternativeNames: null == alternativeNames
          ? _value.alternativeNames
          : alternativeNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      careInfo: null == careInfo
          ? _value.careInfo
          : careInfo // ignore: cast_nullable_to_non_nullable
              as PlantCareInfo,
      identifiedAt: null == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlantCareInfoCopyWith<$Res> get careInfo {
    return $PlantCareInfoCopyWith<$Res>(_value.careInfo, (value) {
      return _then(_value.copyWith(careInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlantIdentificationImplCopyWith<$Res>
    implements $PlantIdentificationCopyWith<$Res> {
  factory _$$PlantIdentificationImplCopyWith(_$PlantIdentificationImpl value,
          $Res Function(_$PlantIdentificationImpl) then) =
      __$$PlantIdentificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String scientificName,
      String commonName,
      double confidence,
      List<String> alternativeNames,
      String imageUrl,
      PlantCareInfo careInfo,
      DateTime identifiedAt,
      String? description,
      List<String>? tags});

  @override
  $PlantCareInfoCopyWith<$Res> get careInfo;
}

/// @nodoc
class __$$PlantIdentificationImplCopyWithImpl<$Res>
    extends _$PlantIdentificationCopyWithImpl<$Res, _$PlantIdentificationImpl>
    implements _$$PlantIdentificationImplCopyWith<$Res> {
  __$$PlantIdentificationImplCopyWithImpl(_$PlantIdentificationImpl _value,
      $Res Function(_$PlantIdentificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? alternativeNames = null,
    Object? imageUrl = null,
    Object? careInfo = null,
    Object? identifiedAt = null,
    Object? description = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$PlantIdentificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      alternativeNames: null == alternativeNames
          ? _value._alternativeNames
          : alternativeNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      careInfo: null == careInfo
          ? _value.careInfo
          : careInfo // ignore: cast_nullable_to_non_nullable
              as PlantCareInfo,
      identifiedAt: null == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantIdentificationImpl implements _PlantIdentification {
  const _$PlantIdentificationImpl(
      {required this.id,
      required this.scientificName,
      required this.commonName,
      required this.confidence,
      required final List<String> alternativeNames,
      required this.imageUrl,
      required this.careInfo,
      required this.identifiedAt,
      this.description,
      final List<String>? tags})
      : _alternativeNames = alternativeNames,
        _tags = tags;

  factory _$PlantIdentificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantIdentificationImplFromJson(json);

  @override
  final String id;
  @override
  final String scientificName;
  @override
  final String commonName;
  @override
  final double confidence;
  final List<String> _alternativeNames;
  @override
  List<String> get alternativeNames {
    if (_alternativeNames is EqualUnmodifiableListView)
      return _alternativeNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeNames);
  }

  @override
  final String imageUrl;
  @override
  final PlantCareInfo careInfo;
  @override
  final DateTime identifiedAt;
  @override
  final String? description;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PlantIdentification(id: $id, scientificName: $scientificName, commonName: $commonName, confidence: $confidence, alternativeNames: $alternativeNames, imageUrl: $imageUrl, careInfo: $careInfo, identifiedAt: $identifiedAt, description: $description, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantIdentificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._alternativeNames, _alternativeNames) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.careInfo, careInfo) ||
                other.careInfo == careInfo) &&
            (identical(other.identifiedAt, identifiedAt) ||
                other.identifiedAt == identifiedAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scientificName,
      commonName,
      confidence,
      const DeepCollectionEquality().hash(_alternativeNames),
      imageUrl,
      careInfo,
      identifiedAt,
      description,
      const DeepCollectionEquality().hash(_tags));

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantIdentificationImplCopyWith<_$PlantIdentificationImpl> get copyWith =>
      __$$PlantIdentificationImplCopyWithImpl<_$PlantIdentificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantIdentificationImplToJson(
      this,
    );
  }
}

abstract class _PlantIdentification implements PlantIdentification {
  const factory _PlantIdentification(
      {required final String id,
      required final String scientificName,
      required final String commonName,
      required final double confidence,
      required final List<String> alternativeNames,
      required final String imageUrl,
      required final PlantCareInfo careInfo,
      required final DateTime identifiedAt,
      final String? description,
      final List<String>? tags}) = _$PlantIdentificationImpl;

  factory _PlantIdentification.fromJson(Map<String, dynamic> json) =
      _$PlantIdentificationImpl.fromJson;

  @override
  String get id;
  @override
  String get scientificName;
  @override
  String get commonName;
  @override
  double get confidence;
  @override
  List<String> get alternativeNames;
  @override
  String get imageUrl;
  @override
  PlantCareInfo get careInfo;
  @override
  DateTime get identifiedAt;
  @override
  String? get description;
  @override
  List<String>? get tags;

  /// Create a copy of PlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantIdentificationImplCopyWith<_$PlantIdentificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantCareInfo _$PlantCareInfoFromJson(Map<String, dynamic> json) {
  return _PlantCareInfo.fromJson(json);
}

/// @nodoc
mixin _$PlantCareInfo {
  String get lightRequirement => throw _privateConstructorUsedError;
  String get waterFrequency => throw _privateConstructorUsedError;
  String get careLevel => throw _privateConstructorUsedError;
  String? get humidity => throw _privateConstructorUsedError;
  String? get temperature => throw _privateConstructorUsedError;
  String? get toxicity => throw _privateConstructorUsedError;
  List<String>? get careNotes => throw _privateConstructorUsedError;

  /// Serializes this PlantCareInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantCareInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantCareInfoCopyWith<PlantCareInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCareInfoCopyWith<$Res> {
  factory $PlantCareInfoCopyWith(
          PlantCareInfo value, $Res Function(PlantCareInfo) then) =
      _$PlantCareInfoCopyWithImpl<$Res, PlantCareInfo>;
  @useResult
  $Res call(
      {String lightRequirement,
      String waterFrequency,
      String careLevel,
      String? humidity,
      String? temperature,
      String? toxicity,
      List<String>? careNotes});
}

/// @nodoc
class _$PlantCareInfoCopyWithImpl<$Res, $Val extends PlantCareInfo>
    implements $PlantCareInfoCopyWith<$Res> {
  _$PlantCareInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantCareInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lightRequirement = null,
    Object? waterFrequency = null,
    Object? careLevel = null,
    Object? humidity = freezed,
    Object? temperature = freezed,
    Object? toxicity = freezed,
    Object? careNotes = freezed,
  }) {
    return _then(_value.copyWith(
      lightRequirement: null == lightRequirement
          ? _value.lightRequirement
          : lightRequirement // ignore: cast_nullable_to_non_nullable
              as String,
      waterFrequency: null == waterFrequency
          ? _value.waterFrequency
          : waterFrequency // ignore: cast_nullable_to_non_nullable
              as String,
      careLevel: null == careLevel
          ? _value.careLevel
          : careLevel // ignore: cast_nullable_to_non_nullable
              as String,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as String?,
      toxicity: freezed == toxicity
          ? _value.toxicity
          : toxicity // ignore: cast_nullable_to_non_nullable
              as String?,
      careNotes: freezed == careNotes
          ? _value.careNotes
          : careNotes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantCareInfoImplCopyWith<$Res>
    implements $PlantCareInfoCopyWith<$Res> {
  factory _$$PlantCareInfoImplCopyWith(
          _$PlantCareInfoImpl value, $Res Function(_$PlantCareInfoImpl) then) =
      __$$PlantCareInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String lightRequirement,
      String waterFrequency,
      String careLevel,
      String? humidity,
      String? temperature,
      String? toxicity,
      List<String>? careNotes});
}

/// @nodoc
class __$$PlantCareInfoImplCopyWithImpl<$Res>
    extends _$PlantCareInfoCopyWithImpl<$Res, _$PlantCareInfoImpl>
    implements _$$PlantCareInfoImplCopyWith<$Res> {
  __$$PlantCareInfoImplCopyWithImpl(
      _$PlantCareInfoImpl _value, $Res Function(_$PlantCareInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantCareInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lightRequirement = null,
    Object? waterFrequency = null,
    Object? careLevel = null,
    Object? humidity = freezed,
    Object? temperature = freezed,
    Object? toxicity = freezed,
    Object? careNotes = freezed,
  }) {
    return _then(_$PlantCareInfoImpl(
      lightRequirement: null == lightRequirement
          ? _value.lightRequirement
          : lightRequirement // ignore: cast_nullable_to_non_nullable
              as String,
      waterFrequency: null == waterFrequency
          ? _value.waterFrequency
          : waterFrequency // ignore: cast_nullable_to_non_nullable
              as String,
      careLevel: null == careLevel
          ? _value.careLevel
          : careLevel // ignore: cast_nullable_to_non_nullable
              as String,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as String?,
      toxicity: freezed == toxicity
          ? _value.toxicity
          : toxicity // ignore: cast_nullable_to_non_nullable
              as String?,
      careNotes: freezed == careNotes
          ? _value._careNotes
          : careNotes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantCareInfoImpl implements _PlantCareInfo {
  const _$PlantCareInfoImpl(
      {required this.lightRequirement,
      required this.waterFrequency,
      required this.careLevel,
      this.humidity,
      this.temperature,
      this.toxicity,
      final List<String>? careNotes})
      : _careNotes = careNotes;

  factory _$PlantCareInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantCareInfoImplFromJson(json);

  @override
  final String lightRequirement;
  @override
  final String waterFrequency;
  @override
  final String careLevel;
  @override
  final String? humidity;
  @override
  final String? temperature;
  @override
  final String? toxicity;
  final List<String>? _careNotes;
  @override
  List<String>? get careNotes {
    final value = _careNotes;
    if (value == null) return null;
    if (_careNotes is EqualUnmodifiableListView) return _careNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PlantCareInfo(lightRequirement: $lightRequirement, waterFrequency: $waterFrequency, careLevel: $careLevel, humidity: $humidity, temperature: $temperature, toxicity: $toxicity, careNotes: $careNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantCareInfoImpl &&
            (identical(other.lightRequirement, lightRequirement) ||
                other.lightRequirement == lightRequirement) &&
            (identical(other.waterFrequency, waterFrequency) ||
                other.waterFrequency == waterFrequency) &&
            (identical(other.careLevel, careLevel) ||
                other.careLevel == careLevel) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.toxicity, toxicity) ||
                other.toxicity == toxicity) &&
            const DeepCollectionEquality()
                .equals(other._careNotes, _careNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lightRequirement,
      waterFrequency,
      careLevel,
      humidity,
      temperature,
      toxicity,
      const DeepCollectionEquality().hash(_careNotes));

  /// Create a copy of PlantCareInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantCareInfoImplCopyWith<_$PlantCareInfoImpl> get copyWith =>
      __$$PlantCareInfoImplCopyWithImpl<_$PlantCareInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantCareInfoImplToJson(
      this,
    );
  }
}

abstract class _PlantCareInfo implements PlantCareInfo {
  const factory _PlantCareInfo(
      {required final String lightRequirement,
      required final String waterFrequency,
      required final String careLevel,
      final String? humidity,
      final String? temperature,
      final String? toxicity,
      final List<String>? careNotes}) = _$PlantCareInfoImpl;

  factory _PlantCareInfo.fromJson(Map<String, dynamic> json) =
      _$PlantCareInfoImpl.fromJson;

  @override
  String get lightRequirement;
  @override
  String get waterFrequency;
  @override
  String get careLevel;
  @override
  String? get humidity;
  @override
  String? get temperature;
  @override
  String? get toxicity;
  @override
  List<String>? get careNotes;

  /// Create a copy of PlantCareInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantCareInfoImplCopyWith<_$PlantCareInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantIdentificationRequest _$PlantIdentificationRequestFromJson(
    Map<String, dynamic> json) {
  return _PlantIdentificationRequest.fromJson(json);
}

/// @nodoc
mixin _$PlantIdentificationRequest {
  String get imageBase64 => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PlantIdentificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantIdentificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantIdentificationRequestCopyWith<PlantIdentificationRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantIdentificationRequestCopyWith<$Res> {
  factory $PlantIdentificationRequestCopyWith(PlantIdentificationRequest value,
          $Res Function(PlantIdentificationRequest) then) =
      _$PlantIdentificationRequestCopyWithImpl<$Res,
          PlantIdentificationRequest>;
  @useResult
  $Res call({String imageBase64, String? location, DateTime? timestamp});
}

/// @nodoc
class _$PlantIdentificationRequestCopyWithImpl<$Res,
        $Val extends PlantIdentificationRequest>
    implements $PlantIdentificationRequestCopyWith<$Res> {
  _$PlantIdentificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantIdentificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageBase64 = null,
    Object? location = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      imageBase64: null == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantIdentificationRequestImplCopyWith<$Res>
    implements $PlantIdentificationRequestCopyWith<$Res> {
  factory _$$PlantIdentificationRequestImplCopyWith(
          _$PlantIdentificationRequestImpl value,
          $Res Function(_$PlantIdentificationRequestImpl) then) =
      __$$PlantIdentificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String imageBase64, String? location, DateTime? timestamp});
}

/// @nodoc
class __$$PlantIdentificationRequestImplCopyWithImpl<$Res>
    extends _$PlantIdentificationRequestCopyWithImpl<$Res,
        _$PlantIdentificationRequestImpl>
    implements _$$PlantIdentificationRequestImplCopyWith<$Res> {
  __$$PlantIdentificationRequestImplCopyWithImpl(
      _$PlantIdentificationRequestImpl _value,
      $Res Function(_$PlantIdentificationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantIdentificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageBase64 = null,
    Object? location = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_$PlantIdentificationRequestImpl(
      imageBase64: null == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantIdentificationRequestImpl implements _PlantIdentificationRequest {
  const _$PlantIdentificationRequestImpl(
      {required this.imageBase64, this.location, this.timestamp});

  factory _$PlantIdentificationRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PlantIdentificationRequestImplFromJson(json);

  @override
  final String imageBase64;
  @override
  final String? location;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'PlantIdentificationRequest(imageBase64: $imageBase64, location: $location, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantIdentificationRequestImpl &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, imageBase64, location, timestamp);

  /// Create a copy of PlantIdentificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantIdentificationRequestImplCopyWith<_$PlantIdentificationRequestImpl>
      get copyWith => __$$PlantIdentificationRequestImplCopyWithImpl<
          _$PlantIdentificationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantIdentificationRequestImplToJson(
      this,
    );
  }
}

abstract class _PlantIdentificationRequest
    implements PlantIdentificationRequest {
  const factory _PlantIdentificationRequest(
      {required final String imageBase64,
      final String? location,
      final DateTime? timestamp}) = _$PlantIdentificationRequestImpl;

  factory _PlantIdentificationRequest.fromJson(Map<String, dynamic> json) =
      _$PlantIdentificationRequestImpl.fromJson;

  @override
  String get imageBase64;
  @override
  String? get location;
  @override
  DateTime? get timestamp;

  /// Create a copy of PlantIdentificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantIdentificationRequestImplCopyWith<_$PlantIdentificationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PlantIdentificationState _$PlantIdentificationStateFromJson(
    Map<String, dynamic> json) {
  return _PlantIdentificationState.fromJson(json);
}

/// @nodoc
mixin _$PlantIdentificationState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<PlantIdentification> get identifications =>
      throw _privateConstructorUsedError;
  List<PlantIdentification> get history => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  PlantIdentification? get currentIdentification =>
      throw _privateConstructorUsedError;

  /// Serializes this PlantIdentificationState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantIdentificationStateCopyWith<PlantIdentificationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantIdentificationStateCopyWith<$Res> {
  factory $PlantIdentificationStateCopyWith(PlantIdentificationState value,
          $Res Function(PlantIdentificationState) then) =
      _$PlantIdentificationStateCopyWithImpl<$Res, PlantIdentificationState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<PlantIdentification> identifications,
      List<PlantIdentification> history,
      String? error,
      PlantIdentification? currentIdentification});

  $PlantIdentificationCopyWith<$Res>? get currentIdentification;
}

/// @nodoc
class _$PlantIdentificationStateCopyWithImpl<$Res,
        $Val extends PlantIdentificationState>
    implements $PlantIdentificationStateCopyWith<$Res> {
  _$PlantIdentificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? identifications = null,
    Object? history = null,
    Object? error = freezed,
    Object? currentIdentification = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      identifications: null == identifications
          ? _value.identifications
          : identifications // ignore: cast_nullable_to_non_nullable
              as List<PlantIdentification>,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<PlantIdentification>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentIdentification: freezed == currentIdentification
          ? _value.currentIdentification
          : currentIdentification // ignore: cast_nullable_to_non_nullable
              as PlantIdentification?,
    ) as $Val);
  }

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlantIdentificationCopyWith<$Res>? get currentIdentification {
    if (_value.currentIdentification == null) {
      return null;
    }

    return $PlantIdentificationCopyWith<$Res>(_value.currentIdentification!,
        (value) {
      return _then(_value.copyWith(currentIdentification: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlantIdentificationStateImplCopyWith<$Res>
    implements $PlantIdentificationStateCopyWith<$Res> {
  factory _$$PlantIdentificationStateImplCopyWith(
          _$PlantIdentificationStateImpl value,
          $Res Function(_$PlantIdentificationStateImpl) then) =
      __$$PlantIdentificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<PlantIdentification> identifications,
      List<PlantIdentification> history,
      String? error,
      PlantIdentification? currentIdentification});

  @override
  $PlantIdentificationCopyWith<$Res>? get currentIdentification;
}

/// @nodoc
class __$$PlantIdentificationStateImplCopyWithImpl<$Res>
    extends _$PlantIdentificationStateCopyWithImpl<$Res,
        _$PlantIdentificationStateImpl>
    implements _$$PlantIdentificationStateImplCopyWith<$Res> {
  __$$PlantIdentificationStateImplCopyWithImpl(
      _$PlantIdentificationStateImpl _value,
      $Res Function(_$PlantIdentificationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? identifications = null,
    Object? history = null,
    Object? error = freezed,
    Object? currentIdentification = freezed,
  }) {
    return _then(_$PlantIdentificationStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      identifications: null == identifications
          ? _value._identifications
          : identifications // ignore: cast_nullable_to_non_nullable
              as List<PlantIdentification>,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<PlantIdentification>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentIdentification: freezed == currentIdentification
          ? _value.currentIdentification
          : currentIdentification // ignore: cast_nullable_to_non_nullable
              as PlantIdentification?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantIdentificationStateImpl implements _PlantIdentificationState {
  const _$PlantIdentificationStateImpl(
      {this.isLoading = false,
      final List<PlantIdentification> identifications = const [],
      final List<PlantIdentification> history = const [],
      this.error,
      this.currentIdentification})
      : _identifications = identifications,
        _history = history;

  factory _$PlantIdentificationStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantIdentificationStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<PlantIdentification> _identifications;
  @override
  @JsonKey()
  List<PlantIdentification> get identifications {
    if (_identifications is EqualUnmodifiableListView) return _identifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_identifications);
  }

  final List<PlantIdentification> _history;
  @override
  @JsonKey()
  List<PlantIdentification> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  final String? error;
  @override
  final PlantIdentification? currentIdentification;

  @override
  String toString() {
    return 'PlantIdentificationState(isLoading: $isLoading, identifications: $identifications, history: $history, error: $error, currentIdentification: $currentIdentification)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantIdentificationStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._identifications, _identifications) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentIdentification, currentIdentification) ||
                other.currentIdentification == currentIdentification));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_identifications),
      const DeepCollectionEquality().hash(_history),
      error,
      currentIdentification);

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantIdentificationStateImplCopyWith<_$PlantIdentificationStateImpl>
      get copyWith => __$$PlantIdentificationStateImplCopyWithImpl<
          _$PlantIdentificationStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantIdentificationStateImplToJson(
      this,
    );
  }
}

abstract class _PlantIdentificationState implements PlantIdentificationState {
  const factory _PlantIdentificationState(
          {final bool isLoading,
          final List<PlantIdentification> identifications,
          final List<PlantIdentification> history,
          final String? error,
          final PlantIdentification? currentIdentification}) =
      _$PlantIdentificationStateImpl;

  factory _PlantIdentificationState.fromJson(Map<String, dynamic> json) =
      _$PlantIdentificationStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  List<PlantIdentification> get identifications;
  @override
  List<PlantIdentification> get history;
  @override
  String? get error;
  @override
  PlantIdentification? get currentIdentification;

  /// Create a copy of PlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantIdentificationStateImplCopyWith<_$PlantIdentificationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
