// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offline_plant_identification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalPlantIdentification _$LocalPlantIdentificationFromJson(
    Map<String, dynamic> json) {
  return _LocalPlantIdentification.fromJson(json);
}

/// @nodoc
mixin _$LocalPlantIdentification {
  String get localId =>
      throw _privateConstructorUsedError; // Unique local identifier
  String? get serverId =>
      throw _privateConstructorUsedError; // Server ID after sync (null if not synced)
  String get scientificName =>
      throw _privateConstructorUsedError; // Scientific name from local model
  String get commonName =>
      throw _privateConstructorUsedError; // Common name from local model
  double get confidence =>
      throw _privateConstructorUsedError; // Confidence score
  String get localImagePath =>
      throw _privateConstructorUsedError; // Path to locally stored image
  DateTime get identifiedAt =>
      throw _privateConstructorUsedError; // Timestamp of identification
  SyncStatus get syncStatus =>
      throw _privateConstructorUsedError; // Current synchronization status
  String? get syncError =>
      throw _privateConstructorUsedError; // Error message if sync failed
  Map<String, dynamic> get localModelData => throw _privateConstructorUsedError;

  /// Serializes this LocalPlantIdentification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalPlantIdentificationCopyWith<LocalPlantIdentification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalPlantIdentificationCopyWith<$Res> {
  factory $LocalPlantIdentificationCopyWith(LocalPlantIdentification value,
          $Res Function(LocalPlantIdentification) then) =
      _$LocalPlantIdentificationCopyWithImpl<$Res, LocalPlantIdentification>;
  @useResult
  $Res call(
      {String localId,
      String? serverId,
      String scientificName,
      String commonName,
      double confidence,
      String localImagePath,
      DateTime identifiedAt,
      SyncStatus syncStatus,
      String? syncError,
      Map<String, dynamic> localModelData});

  $SyncStatusCopyWith<$Res> get syncStatus;
}

/// @nodoc
class _$LocalPlantIdentificationCopyWithImpl<$Res,
        $Val extends LocalPlantIdentification>
    implements $LocalPlantIdentificationCopyWith<$Res> {
  _$LocalPlantIdentificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = null,
    Object? serverId = freezed,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? localImagePath = null,
    Object? identifiedAt = null,
    Object? syncStatus = null,
    Object? syncError = freezed,
    Object? localModelData = null,
  }) {
    return _then(_value.copyWith(
      localId: null == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: freezed == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      localImagePath: null == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      identifiedAt: null == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      localModelData: null == localModelData
          ? _value.localModelData
          : localModelData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SyncStatusCopyWith<$Res> get syncStatus {
    return $SyncStatusCopyWith<$Res>(_value.syncStatus, (value) {
      return _then(_value.copyWith(syncStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocalPlantIdentificationImplCopyWith<$Res>
    implements $LocalPlantIdentificationCopyWith<$Res> {
  factory _$$LocalPlantIdentificationImplCopyWith(
          _$LocalPlantIdentificationImpl value,
          $Res Function(_$LocalPlantIdentificationImpl) then) =
      __$$LocalPlantIdentificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String localId,
      String? serverId,
      String scientificName,
      String commonName,
      double confidence,
      String localImagePath,
      DateTime identifiedAt,
      SyncStatus syncStatus,
      String? syncError,
      Map<String, dynamic> localModelData});

  @override
  $SyncStatusCopyWith<$Res> get syncStatus;
}

/// @nodoc
class __$$LocalPlantIdentificationImplCopyWithImpl<$Res>
    extends _$LocalPlantIdentificationCopyWithImpl<$Res,
        _$LocalPlantIdentificationImpl>
    implements _$$LocalPlantIdentificationImplCopyWith<$Res> {
  __$$LocalPlantIdentificationImplCopyWithImpl(
      _$LocalPlantIdentificationImpl _value,
      $Res Function(_$LocalPlantIdentificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localId = null,
    Object? serverId = freezed,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? localImagePath = null,
    Object? identifiedAt = null,
    Object? syncStatus = null,
    Object? syncError = freezed,
    Object? localModelData = null,
  }) {
    return _then(_$LocalPlantIdentificationImpl(
      localId: null == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: freezed == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      localImagePath: null == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      identifiedAt: null == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      localModelData: null == localModelData
          ? _value._localModelData
          : localModelData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalPlantIdentificationImpl implements _LocalPlantIdentification {
  const _$LocalPlantIdentificationImpl(
      {required this.localId,
      this.serverId,
      required this.scientificName,
      required this.commonName,
      required this.confidence,
      required this.localImagePath,
      required this.identifiedAt,
      required this.syncStatus,
      this.syncError,
      final Map<String, dynamic> localModelData = const {}})
      : _localModelData = localModelData;

  factory _$LocalPlantIdentificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalPlantIdentificationImplFromJson(json);

  @override
  final String localId;
// Unique local identifier
  @override
  final String? serverId;
// Server ID after sync (null if not synced)
  @override
  final String scientificName;
// Scientific name from local model
  @override
  final String commonName;
// Common name from local model
  @override
  final double confidence;
// Confidence score
  @override
  final String localImagePath;
// Path to locally stored image
  @override
  final DateTime identifiedAt;
// Timestamp of identification
  @override
  final SyncStatus syncStatus;
// Current synchronization status
  @override
  final String? syncError;
// Error message if sync failed
  final Map<String, dynamic> _localModelData;
// Error message if sync failed
  @override
  @JsonKey()
  Map<String, dynamic> get localModelData {
    if (_localModelData is EqualUnmodifiableMapView) return _localModelData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localModelData);
  }

  @override
  String toString() {
    return 'LocalPlantIdentification(localId: $localId, serverId: $serverId, scientificName: $scientificName, commonName: $commonName, confidence: $confidence, localImagePath: $localImagePath, identifiedAt: $identifiedAt, syncStatus: $syncStatus, syncError: $syncError, localModelData: $localModelData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalPlantIdentificationImpl &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.localImagePath, localImagePath) ||
                other.localImagePath == localImagePath) &&
            (identical(other.identifiedAt, identifiedAt) ||
                other.identifiedAt == identifiedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.syncError, syncError) ||
                other.syncError == syncError) &&
            const DeepCollectionEquality()
                .equals(other._localModelData, _localModelData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      localId,
      serverId,
      scientificName,
      commonName,
      confidence,
      localImagePath,
      identifiedAt,
      syncStatus,
      syncError,
      const DeepCollectionEquality().hash(_localModelData));

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalPlantIdentificationImplCopyWith<_$LocalPlantIdentificationImpl>
      get copyWith => __$$LocalPlantIdentificationImplCopyWithImpl<
          _$LocalPlantIdentificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalPlantIdentificationImplToJson(
      this,
    );
  }
}

abstract class _LocalPlantIdentification implements LocalPlantIdentification {
  const factory _LocalPlantIdentification(
          {required final String localId,
          final String? serverId,
          required final String scientificName,
          required final String commonName,
          required final double confidence,
          required final String localImagePath,
          required final DateTime identifiedAt,
          required final SyncStatus syncStatus,
          final String? syncError,
          final Map<String, dynamic> localModelData}) =
      _$LocalPlantIdentificationImpl;

  factory _LocalPlantIdentification.fromJson(Map<String, dynamic> json) =
      _$LocalPlantIdentificationImpl.fromJson;

  @override
  String get localId; // Unique local identifier
  @override
  String? get serverId; // Server ID after sync (null if not synced)
  @override
  String get scientificName; // Scientific name from local model
  @override
  String get commonName; // Common name from local model
  @override
  double get confidence; // Confidence score
  @override
  String get localImagePath; // Path to locally stored image
  @override
  DateTime get identifiedAt; // Timestamp of identification
  @override
  SyncStatus get syncStatus; // Current synchronization status
  @override
  String? get syncError; // Error message if sync failed
  @override
  Map<String, dynamic> get localModelData;

  /// Create a copy of LocalPlantIdentification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalPlantIdentificationImplCopyWith<_$LocalPlantIdentificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ModelInfo _$ModelInfoFromJson(Map<String, dynamic> json) {
  return _ModelInfo.fromJson(json);
}

/// @nodoc
mixin _$ModelInfo {
  String get modelId =>
      throw _privateConstructorUsedError; // Unique identifier for the model
  String get version => throw _privateConstructorUsedError; // Version string
  DateTime get downloadedAt =>
      throw _privateConstructorUsedError; // When the model was downloaded
  int get sizeInBytes =>
      throw _privateConstructorUsedError; // Size of model on disk
  List<String> get capabilities =>
      throw _privateConstructorUsedError; // What the model can identify
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this ModelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelInfoCopyWith<ModelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelInfoCopyWith<$Res> {
  factory $ModelInfoCopyWith(ModelInfo value, $Res Function(ModelInfo) then) =
      _$ModelInfoCopyWithImpl<$Res, ModelInfo>;
  @useResult
  $Res call(
      {String modelId,
      String version,
      DateTime downloadedAt,
      int sizeInBytes,
      List<String> capabilities,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ModelInfoCopyWithImpl<$Res, $Val extends ModelInfo>
    implements $ModelInfoCopyWith<$Res> {
  _$ModelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelId = null,
    Object? version = null,
    Object? downloadedAt = null,
    Object? sizeInBytes = null,
    Object? capabilities = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sizeInBytes: null == sizeInBytes
          ? _value.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelInfoImplCopyWith<$Res>
    implements $ModelInfoCopyWith<$Res> {
  factory _$$ModelInfoImplCopyWith(
          _$ModelInfoImpl value, $Res Function(_$ModelInfoImpl) then) =
      __$$ModelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String modelId,
      String version,
      DateTime downloadedAt,
      int sizeInBytes,
      List<String> capabilities,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ModelInfoImplCopyWithImpl<$Res>
    extends _$ModelInfoCopyWithImpl<$Res, _$ModelInfoImpl>
    implements _$$ModelInfoImplCopyWith<$Res> {
  __$$ModelInfoImplCopyWithImpl(
      _$ModelInfoImpl _value, $Res Function(_$ModelInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelId = null,
    Object? version = null,
    Object? downloadedAt = null,
    Object? sizeInBytes = null,
    Object? capabilities = null,
    Object? metadata = null,
  }) {
    return _then(_$ModelInfoImpl(
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sizeInBytes: null == sizeInBytes
          ? _value.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelInfoImpl implements _ModelInfo {
  const _$ModelInfoImpl(
      {required this.modelId,
      required this.version,
      required this.downloadedAt,
      required this.sizeInBytes,
      final List<String> capabilities = const [],
      final Map<String, dynamic> metadata = const {}})
      : _capabilities = capabilities,
        _metadata = metadata;

  factory _$ModelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelInfoImplFromJson(json);

  @override
  final String modelId;
// Unique identifier for the model
  @override
  final String version;
// Version string
  @override
  final DateTime downloadedAt;
// When the model was downloaded
  @override
  final int sizeInBytes;
// Size of model on disk
  final List<String> _capabilities;
// Size of model on disk
  @override
  @JsonKey()
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

// What the model can identify
  final Map<String, dynamic> _metadata;
// What the model can identify
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'ModelInfo(modelId: $modelId, version: $version, downloadedAt: $downloadedAt, sizeInBytes: $sizeInBytes, capabilities: $capabilities, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelInfoImpl &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.downloadedAt, downloadedAt) ||
                other.downloadedAt == downloadedAt) &&
            (identical(other.sizeInBytes, sizeInBytes) ||
                other.sizeInBytes == sizeInBytes) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      modelId,
      version,
      downloadedAt,
      sizeInBytes,
      const DeepCollectionEquality().hash(_capabilities),
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      __$$ModelInfoImplCopyWithImpl<_$ModelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelInfoImplToJson(
      this,
    );
  }
}

abstract class _ModelInfo implements ModelInfo {
  const factory _ModelInfo(
      {required final String modelId,
      required final String version,
      required final DateTime downloadedAt,
      required final int sizeInBytes,
      final List<String> capabilities,
      final Map<String, dynamic> metadata}) = _$ModelInfoImpl;

  factory _ModelInfo.fromJson(Map<String, dynamic> json) =
      _$ModelInfoImpl.fromJson;

  @override
  String get modelId; // Unique identifier for the model
  @override
  String get version; // Version string
  @override
  DateTime get downloadedAt; // When the model was downloaded
  @override
  int get sizeInBytes; // Size of model on disk
  @override
  List<String> get capabilities; // What the model can identify
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncStatus _$SyncStatusFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'synced':
      return _Synced.fromJson(json);
    case 'notSynced':
      return _NotSynced.fromJson(json);
    case 'syncing':
      return _Syncing.fromJson(json);
    case 'failed':
      return _Failed.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'SyncStatus',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$SyncStatus {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() synced,
    required TResult Function() notSynced,
    required TResult Function() syncing,
    required TResult Function(String error) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? synced,
    TResult? Function()? notSynced,
    TResult? Function()? syncing,
    TResult? Function(String error)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? synced,
    TResult Function()? notSynced,
    TResult Function()? syncing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Synced value) synced,
    required TResult Function(_NotSynced value) notSynced,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Failed value) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Synced value)? synced,
    TResult? Function(_NotSynced value)? notSynced,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Failed value)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Synced value)? synced,
    TResult Function(_NotSynced value)? notSynced,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this SyncStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStatusCopyWith<$Res> {
  factory $SyncStatusCopyWith(
          SyncStatus value, $Res Function(SyncStatus) then) =
      _$SyncStatusCopyWithImpl<$Res, SyncStatus>;
}

/// @nodoc
class _$SyncStatusCopyWithImpl<$Res, $Val extends SyncStatus>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SyncedImplCopyWith<$Res> {
  factory _$$SyncedImplCopyWith(
          _$SyncedImpl value, $Res Function(_$SyncedImpl) then) =
      __$$SyncedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncedImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$SyncedImpl>
    implements _$$SyncedImplCopyWith<$Res> {
  __$$SyncedImplCopyWithImpl(
      _$SyncedImpl _value, $Res Function(_$SyncedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$SyncedImpl extends _Synced {
  const _$SyncedImpl({final String? $type})
      : $type = $type ?? 'synced',
        super._();

  factory _$SyncedImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncedImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SyncStatus.synced()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncedImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() synced,
    required TResult Function() notSynced,
    required TResult Function() syncing,
    required TResult Function(String error) failed,
  }) {
    return synced();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? synced,
    TResult? Function()? notSynced,
    TResult? Function()? syncing,
    TResult? Function(String error)? failed,
  }) {
    return synced?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? synced,
    TResult Function()? notSynced,
    TResult Function()? syncing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (synced != null) {
      return synced();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Synced value) synced,
    required TResult Function(_NotSynced value) notSynced,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Failed value) failed,
  }) {
    return synced(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Synced value)? synced,
    TResult? Function(_NotSynced value)? notSynced,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Failed value)? failed,
  }) {
    return synced?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Synced value)? synced,
    TResult Function(_NotSynced value)? notSynced,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (synced != null) {
      return synced(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncedImplToJson(
      this,
    );
  }
}

abstract class _Synced extends SyncStatus {
  const factory _Synced() = _$SyncedImpl;
  const _Synced._() : super._();

  factory _Synced.fromJson(Map<String, dynamic> json) = _$SyncedImpl.fromJson;
}

/// @nodoc
abstract class _$$NotSyncedImplCopyWith<$Res> {
  factory _$$NotSyncedImplCopyWith(
          _$NotSyncedImpl value, $Res Function(_$NotSyncedImpl) then) =
      __$$NotSyncedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotSyncedImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$NotSyncedImpl>
    implements _$$NotSyncedImplCopyWith<$Res> {
  __$$NotSyncedImplCopyWithImpl(
      _$NotSyncedImpl _value, $Res Function(_$NotSyncedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$NotSyncedImpl extends _NotSynced {
  const _$NotSyncedImpl({final String? $type})
      : $type = $type ?? 'notSynced',
        super._();

  factory _$NotSyncedImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotSyncedImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SyncStatus.notSynced()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NotSyncedImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() synced,
    required TResult Function() notSynced,
    required TResult Function() syncing,
    required TResult Function(String error) failed,
  }) {
    return notSynced();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? synced,
    TResult? Function()? notSynced,
    TResult? Function()? syncing,
    TResult? Function(String error)? failed,
  }) {
    return notSynced?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? synced,
    TResult Function()? notSynced,
    TResult Function()? syncing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (notSynced != null) {
      return notSynced();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Synced value) synced,
    required TResult Function(_NotSynced value) notSynced,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Failed value) failed,
  }) {
    return notSynced(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Synced value)? synced,
    TResult? Function(_NotSynced value)? notSynced,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Failed value)? failed,
  }) {
    return notSynced?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Synced value)? synced,
    TResult Function(_NotSynced value)? notSynced,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (notSynced != null) {
      return notSynced(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NotSyncedImplToJson(
      this,
    );
  }
}

abstract class _NotSynced extends SyncStatus {
  const factory _NotSynced() = _$NotSyncedImpl;
  const _NotSynced._() : super._();

  factory _NotSynced.fromJson(Map<String, dynamic> json) =
      _$NotSyncedImpl.fromJson;
}

/// @nodoc
abstract class _$$SyncingImplCopyWith<$Res> {
  factory _$$SyncingImplCopyWith(
          _$SyncingImpl value, $Res Function(_$SyncingImpl) then) =
      __$$SyncingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncingImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$SyncingImpl>
    implements _$$SyncingImplCopyWith<$Res> {
  __$$SyncingImplCopyWithImpl(
      _$SyncingImpl _value, $Res Function(_$SyncingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$SyncingImpl extends _Syncing {
  const _$SyncingImpl({final String? $type})
      : $type = $type ?? 'syncing',
        super._();

  factory _$SyncingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncingImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SyncStatus.syncing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncingImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() synced,
    required TResult Function() notSynced,
    required TResult Function() syncing,
    required TResult Function(String error) failed,
  }) {
    return syncing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? synced,
    TResult? Function()? notSynced,
    TResult? Function()? syncing,
    TResult? Function(String error)? failed,
  }) {
    return syncing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? synced,
    TResult Function()? notSynced,
    TResult Function()? syncing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Synced value) synced,
    required TResult Function(_NotSynced value) notSynced,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Failed value) failed,
  }) {
    return syncing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Synced value)? synced,
    TResult? Function(_NotSynced value)? notSynced,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Failed value)? failed,
  }) {
    return syncing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Synced value)? synced,
    TResult Function(_NotSynced value)? notSynced,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncingImplToJson(
      this,
    );
  }
}

abstract class _Syncing extends SyncStatus {
  const factory _Syncing() = _$SyncingImpl;
  const _Syncing._() : super._();

  factory _Syncing.fromJson(Map<String, dynamic> json) = _$SyncingImpl.fromJson;
}

/// @nodoc
abstract class _$$FailedImplCopyWith<$Res> {
  factory _$$FailedImplCopyWith(
          _$FailedImpl value, $Res Function(_$FailedImpl) then) =
      __$$FailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$FailedImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$FailedImpl>
    implements _$$FailedImplCopyWith<$Res> {
  __$$FailedImplCopyWithImpl(
      _$FailedImpl _value, $Res Function(_$FailedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FailedImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FailedImpl extends _Failed {
  const _$FailedImpl(this.error, {final String? $type})
      : $type = $type ?? 'failed',
        super._();

  factory _$FailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$FailedImplFromJson(json);

  @override
  final String error;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SyncStatus.failed(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailedImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      __$$FailedImplCopyWithImpl<_$FailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() synced,
    required TResult Function() notSynced,
    required TResult Function() syncing,
    required TResult Function(String error) failed,
  }) {
    return failed(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? synced,
    TResult? Function()? notSynced,
    TResult? Function()? syncing,
    TResult? Function(String error)? failed,
  }) {
    return failed?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? synced,
    TResult Function()? notSynced,
    TResult Function()? syncing,
    TResult Function(String error)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Synced value) synced,
    required TResult Function(_NotSynced value) notSynced,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Failed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Synced value)? synced,
    TResult? Function(_NotSynced value)? notSynced,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Failed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Synced value)? synced,
    TResult Function(_NotSynced value)? notSynced,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Failed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FailedImplToJson(
      this,
    );
  }
}

abstract class _Failed extends SyncStatus {
  const factory _Failed(final String error) = _$FailedImpl;
  const _Failed._() : super._();

  factory _Failed.fromJson(Map<String, dynamic> json) = _$FailedImpl.fromJson;

  String get error;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailedImplCopyWith<_$FailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConnectivityStatus _$ConnectivityStatusFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'offline':
      return _Offline.fromJson(json);
    case 'mobile':
      return _Mobile.fromJson(json);
    case 'wifi':
      return _Wifi.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ConnectivityStatus',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ConnectivityStatus {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() offline,
    required TResult Function() mobile,
    required TResult Function() wifi,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? offline,
    TResult? Function()? mobile,
    TResult? Function()? wifi,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? offline,
    TResult Function()? mobile,
    TResult Function()? wifi,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Offline value) offline,
    required TResult Function(_Mobile value) mobile,
    required TResult Function(_Wifi value) wifi,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Offline value)? offline,
    TResult? Function(_Mobile value)? mobile,
    TResult? Function(_Wifi value)? wifi,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Offline value)? offline,
    TResult Function(_Mobile value)? mobile,
    TResult Function(_Wifi value)? wifi,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ConnectivityStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectivityStatusCopyWith<$Res> {
  factory $ConnectivityStatusCopyWith(
          ConnectivityStatus value, $Res Function(ConnectivityStatus) then) =
      _$ConnectivityStatusCopyWithImpl<$Res, ConnectivityStatus>;
}

/// @nodoc
class _$ConnectivityStatusCopyWithImpl<$Res, $Val extends ConnectivityStatus>
    implements $ConnectivityStatusCopyWith<$Res> {
  _$ConnectivityStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectivityStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OfflineImplCopyWith<$Res> {
  factory _$$OfflineImplCopyWith(
          _$OfflineImpl value, $Res Function(_$OfflineImpl) then) =
      __$$OfflineImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OfflineImplCopyWithImpl<$Res>
    extends _$ConnectivityStatusCopyWithImpl<$Res, _$OfflineImpl>
    implements _$$OfflineImplCopyWith<$Res> {
  __$$OfflineImplCopyWithImpl(
      _$OfflineImpl _value, $Res Function(_$OfflineImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectivityStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$OfflineImpl extends _Offline {
  const _$OfflineImpl({final String? $type})
      : $type = $type ?? 'offline',
        super._();

  factory _$OfflineImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfflineImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConnectivityStatus.offline()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OfflineImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() offline,
    required TResult Function() mobile,
    required TResult Function() wifi,
  }) {
    return offline();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? offline,
    TResult? Function()? mobile,
    TResult? Function()? wifi,
  }) {
    return offline?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? offline,
    TResult Function()? mobile,
    TResult Function()? wifi,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Offline value) offline,
    required TResult Function(_Mobile value) mobile,
    required TResult Function(_Wifi value) wifi,
  }) {
    return offline(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Offline value)? offline,
    TResult? Function(_Mobile value)? mobile,
    TResult? Function(_Wifi value)? wifi,
  }) {
    return offline?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Offline value)? offline,
    TResult Function(_Mobile value)? mobile,
    TResult Function(_Wifi value)? wifi,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OfflineImplToJson(
      this,
    );
  }
}

abstract class _Offline extends ConnectivityStatus {
  const factory _Offline() = _$OfflineImpl;
  const _Offline._() : super._();

  factory _Offline.fromJson(Map<String, dynamic> json) = _$OfflineImpl.fromJson;
}

/// @nodoc
abstract class _$$MobileImplCopyWith<$Res> {
  factory _$$MobileImplCopyWith(
          _$MobileImpl value, $Res Function(_$MobileImpl) then) =
      __$$MobileImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MobileImplCopyWithImpl<$Res>
    extends _$ConnectivityStatusCopyWithImpl<$Res, _$MobileImpl>
    implements _$$MobileImplCopyWith<$Res> {
  __$$MobileImplCopyWithImpl(
      _$MobileImpl _value, $Res Function(_$MobileImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectivityStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$MobileImpl extends _Mobile {
  const _$MobileImpl({final String? $type})
      : $type = $type ?? 'mobile',
        super._();

  factory _$MobileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MobileImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConnectivityStatus.mobile()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MobileImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() offline,
    required TResult Function() mobile,
    required TResult Function() wifi,
  }) {
    return mobile();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? offline,
    TResult? Function()? mobile,
    TResult? Function()? wifi,
  }) {
    return mobile?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? offline,
    TResult Function()? mobile,
    TResult Function()? wifi,
    required TResult orElse(),
  }) {
    if (mobile != null) {
      return mobile();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Offline value) offline,
    required TResult Function(_Mobile value) mobile,
    required TResult Function(_Wifi value) wifi,
  }) {
    return mobile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Offline value)? offline,
    TResult? Function(_Mobile value)? mobile,
    TResult? Function(_Wifi value)? wifi,
  }) {
    return mobile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Offline value)? offline,
    TResult Function(_Mobile value)? mobile,
    TResult Function(_Wifi value)? wifi,
    required TResult orElse(),
  }) {
    if (mobile != null) {
      return mobile(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MobileImplToJson(
      this,
    );
  }
}

abstract class _Mobile extends ConnectivityStatus {
  const factory _Mobile() = _$MobileImpl;
  const _Mobile._() : super._();

  factory _Mobile.fromJson(Map<String, dynamic> json) = _$MobileImpl.fromJson;
}

/// @nodoc
abstract class _$$WifiImplCopyWith<$Res> {
  factory _$$WifiImplCopyWith(
          _$WifiImpl value, $Res Function(_$WifiImpl) then) =
      __$$WifiImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WifiImplCopyWithImpl<$Res>
    extends _$ConnectivityStatusCopyWithImpl<$Res, _$WifiImpl>
    implements _$$WifiImplCopyWith<$Res> {
  __$$WifiImplCopyWithImpl(_$WifiImpl _value, $Res Function(_$WifiImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectivityStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$WifiImpl extends _Wifi {
  const _$WifiImpl({final String? $type})
      : $type = $type ?? 'wifi',
        super._();

  factory _$WifiImpl.fromJson(Map<String, dynamic> json) =>
      _$$WifiImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConnectivityStatus.wifi()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WifiImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() offline,
    required TResult Function() mobile,
    required TResult Function() wifi,
  }) {
    return wifi();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? offline,
    TResult? Function()? mobile,
    TResult? Function()? wifi,
  }) {
    return wifi?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? offline,
    TResult Function()? mobile,
    TResult Function()? wifi,
    required TResult orElse(),
  }) {
    if (wifi != null) {
      return wifi();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Offline value) offline,
    required TResult Function(_Mobile value) mobile,
    required TResult Function(_Wifi value) wifi,
  }) {
    return wifi(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Offline value)? offline,
    TResult? Function(_Mobile value)? mobile,
    TResult? Function(_Wifi value)? wifi,
  }) {
    return wifi?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Offline value)? offline,
    TResult Function(_Mobile value)? mobile,
    TResult Function(_Wifi value)? wifi,
    required TResult orElse(),
  }) {
    if (wifi != null) {
      return wifi(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WifiImplToJson(
      this,
    );
  }
}

abstract class _Wifi extends ConnectivityStatus {
  const factory _Wifi() = _$WifiImpl;
  const _Wifi._() : super._();

  factory _Wifi.fromJson(Map<String, dynamic> json) = _$WifiImpl.fromJson;
}

OfflinePlantIdentificationState _$OfflinePlantIdentificationStateFromJson(
    Map<String, dynamic> json) {
  return _OfflinePlantIdentificationState.fromJson(json);
}

/// @nodoc
mixin _$OfflinePlantIdentificationState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<LocalPlantIdentification> get localIdentifications =>
      throw _privateConstructorUsedError;
  ModelInfo? get currentModel => throw _privateConstructorUsedError;
  ConnectivityStatus? get connectivityStatus =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this OfflinePlantIdentificationState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfflinePlantIdentificationStateCopyWith<OfflinePlantIdentificationState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfflinePlantIdentificationStateCopyWith<$Res> {
  factory $OfflinePlantIdentificationStateCopyWith(
          OfflinePlantIdentificationState value,
          $Res Function(OfflinePlantIdentificationState) then) =
      _$OfflinePlantIdentificationStateCopyWithImpl<$Res,
          OfflinePlantIdentificationState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<LocalPlantIdentification> localIdentifications,
      ModelInfo? currentModel,
      ConnectivityStatus? connectivityStatus,
      String? error});

  $ModelInfoCopyWith<$Res>? get currentModel;
  $ConnectivityStatusCopyWith<$Res>? get connectivityStatus;
}

/// @nodoc
class _$OfflinePlantIdentificationStateCopyWithImpl<$Res,
        $Val extends OfflinePlantIdentificationState>
    implements $OfflinePlantIdentificationStateCopyWith<$Res> {
  _$OfflinePlantIdentificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? localIdentifications = null,
    Object? currentModel = freezed,
    Object? connectivityStatus = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      localIdentifications: null == localIdentifications
          ? _value.localIdentifications
          : localIdentifications // ignore: cast_nullable_to_non_nullable
              as List<LocalPlantIdentification>,
      currentModel: freezed == currentModel
          ? _value.currentModel
          : currentModel // ignore: cast_nullable_to_non_nullable
              as ModelInfo?,
      connectivityStatus: freezed == connectivityStatus
          ? _value.connectivityStatus
          : connectivityStatus // ignore: cast_nullable_to_non_nullable
              as ConnectivityStatus?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelInfoCopyWith<$Res>? get currentModel {
    if (_value.currentModel == null) {
      return null;
    }

    return $ModelInfoCopyWith<$Res>(_value.currentModel!, (value) {
      return _then(_value.copyWith(currentModel: value) as $Val);
    });
  }

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConnectivityStatusCopyWith<$Res>? get connectivityStatus {
    if (_value.connectivityStatus == null) {
      return null;
    }

    return $ConnectivityStatusCopyWith<$Res>(_value.connectivityStatus!,
        (value) {
      return _then(_value.copyWith(connectivityStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OfflinePlantIdentificationStateImplCopyWith<$Res>
    implements $OfflinePlantIdentificationStateCopyWith<$Res> {
  factory _$$OfflinePlantIdentificationStateImplCopyWith(
          _$OfflinePlantIdentificationStateImpl value,
          $Res Function(_$OfflinePlantIdentificationStateImpl) then) =
      __$$OfflinePlantIdentificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<LocalPlantIdentification> localIdentifications,
      ModelInfo? currentModel,
      ConnectivityStatus? connectivityStatus,
      String? error});

  @override
  $ModelInfoCopyWith<$Res>? get currentModel;
  @override
  $ConnectivityStatusCopyWith<$Res>? get connectivityStatus;
}

/// @nodoc
class __$$OfflinePlantIdentificationStateImplCopyWithImpl<$Res>
    extends _$OfflinePlantIdentificationStateCopyWithImpl<$Res,
        _$OfflinePlantIdentificationStateImpl>
    implements _$$OfflinePlantIdentificationStateImplCopyWith<$Res> {
  __$$OfflinePlantIdentificationStateImplCopyWithImpl(
      _$OfflinePlantIdentificationStateImpl _value,
      $Res Function(_$OfflinePlantIdentificationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? localIdentifications = null,
    Object? currentModel = freezed,
    Object? connectivityStatus = freezed,
    Object? error = freezed,
  }) {
    return _then(_$OfflinePlantIdentificationStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      localIdentifications: null == localIdentifications
          ? _value._localIdentifications
          : localIdentifications // ignore: cast_nullable_to_non_nullable
              as List<LocalPlantIdentification>,
      currentModel: freezed == currentModel
          ? _value.currentModel
          : currentModel // ignore: cast_nullable_to_non_nullable
              as ModelInfo?,
      connectivityStatus: freezed == connectivityStatus
          ? _value.connectivityStatus
          : connectivityStatus // ignore: cast_nullable_to_non_nullable
              as ConnectivityStatus?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OfflinePlantIdentificationStateImpl
    implements _OfflinePlantIdentificationState {
  const _$OfflinePlantIdentificationStateImpl(
      {this.isLoading = false,
      final List<LocalPlantIdentification> localIdentifications = const [],
      this.currentModel = null,
      this.connectivityStatus = null,
      this.error})
      : _localIdentifications = localIdentifications;

  factory _$OfflinePlantIdentificationStateImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$OfflinePlantIdentificationStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<LocalPlantIdentification> _localIdentifications;
  @override
  @JsonKey()
  List<LocalPlantIdentification> get localIdentifications {
    if (_localIdentifications is EqualUnmodifiableListView)
      return _localIdentifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localIdentifications);
  }

  @override
  @JsonKey()
  final ModelInfo? currentModel;
  @override
  @JsonKey()
  final ConnectivityStatus? connectivityStatus;
  @override
  final String? error;

  @override
  String toString() {
    return 'OfflinePlantIdentificationState(isLoading: $isLoading, localIdentifications: $localIdentifications, currentModel: $currentModel, connectivityStatus: $connectivityStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfflinePlantIdentificationStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._localIdentifications, _localIdentifications) &&
            (identical(other.currentModel, currentModel) ||
                other.currentModel == currentModel) &&
            (identical(other.connectivityStatus, connectivityStatus) ||
                other.connectivityStatus == connectivityStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_localIdentifications),
      currentModel,
      connectivityStatus,
      error);

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfflinePlantIdentificationStateImplCopyWith<
          _$OfflinePlantIdentificationStateImpl>
      get copyWith => __$$OfflinePlantIdentificationStateImplCopyWithImpl<
          _$OfflinePlantIdentificationStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfflinePlantIdentificationStateImplToJson(
      this,
    );
  }
}

abstract class _OfflinePlantIdentificationState
    implements OfflinePlantIdentificationState {
  const factory _OfflinePlantIdentificationState(
      {final bool isLoading,
      final List<LocalPlantIdentification> localIdentifications,
      final ModelInfo? currentModel,
      final ConnectivityStatus? connectivityStatus,
      final String? error}) = _$OfflinePlantIdentificationStateImpl;

  factory _OfflinePlantIdentificationState.fromJson(Map<String, dynamic> json) =
      _$OfflinePlantIdentificationStateImpl.fromJson;

  @override
  bool get isLoading;
  @override
  List<LocalPlantIdentification> get localIdentifications;
  @override
  ModelInfo? get currentModel;
  @override
  ConnectivityStatus? get connectivityStatus;
  @override
  String? get error;

  /// Create a copy of OfflinePlantIdentificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfflinePlantIdentificationStateImplCopyWith<
          _$OfflinePlantIdentificationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
