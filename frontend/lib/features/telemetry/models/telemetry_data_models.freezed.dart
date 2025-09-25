// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LightReadingData _$LightReadingDataFromJson(Map<String, dynamic> json) {
  return _LightReadingData.fromJson(json);
}

/// @nodoc
mixin _$LightReadingData {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get plantId => throw _privateConstructorUsedError;
  double get luxValue => throw _privateConstructorUsedError;
  double? get ppfdValue => throw _privateConstructorUsedError;
  LightSource get source => throw _privateConstructorUsedError;
  String? get locationName => throw _privateConstructorUsedError;
  double? get gpsLatitude => throw _privateConstructorUsedError;
  double? get gpsLongitude => throw _privateConstructorUsedError;
  double? get altitude => throw _privateConstructorUsedError;
  double? get temperature => throw _privateConstructorUsedError;
  double? get humidity => throw _privateConstructorUsedError;
  String? get calibrationProfileId => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  String? get bleDeviceId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get rawData => throw _privateConstructorUsedError;
  DateTime get measuredAt =>
      throw _privateConstructorUsedError; // Telemetry fields for offline sync
  String? get growthPhotoId => throw _privateConstructorUsedError;
  String? get telemetrySessionId => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  bool get offlineCreated => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conflictResolutionData =>
      throw _privateConstructorUsedError;
  DateTime? get clientTimestamp =>
      throw _privateConstructorUsedError; // Metadata
  String? get processingNotes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LightReadingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LightReadingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LightReadingDataCopyWith<LightReadingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LightReadingDataCopyWith<$Res> {
  factory $LightReadingDataCopyWith(
          LightReadingData value, $Res Function(LightReadingData) then) =
      _$LightReadingDataCopyWithImpl<$Res, LightReadingData>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? plantId,
      double luxValue,
      double? ppfdValue,
      LightSource source,
      String? locationName,
      double? gpsLatitude,
      double? gpsLongitude,
      double? altitude,
      double? temperature,
      double? humidity,
      String? calibrationProfileId,
      String? deviceId,
      String? bleDeviceId,
      Map<String, dynamic>? rawData,
      DateTime measuredAt,
      String? growthPhotoId,
      String? telemetrySessionId,
      SyncStatus syncStatus,
      bool offlineCreated,
      Map<String, dynamic>? conflictResolutionData,
      DateTime? clientTimestamp,
      String? processingNotes,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LightReadingDataCopyWithImpl<$Res, $Val extends LightReadingData>
    implements $LightReadingDataCopyWith<$Res> {
  _$LightReadingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LightReadingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? plantId = freezed,
    Object? luxValue = null,
    Object? ppfdValue = freezed,
    Object? source = null,
    Object? locationName = freezed,
    Object? gpsLatitude = freezed,
    Object? gpsLongitude = freezed,
    Object? altitude = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? calibrationProfileId = freezed,
    Object? deviceId = freezed,
    Object? bleDeviceId = freezed,
    Object? rawData = freezed,
    Object? measuredAt = null,
    Object? growthPhotoId = freezed,
    Object? telemetrySessionId = freezed,
    Object? syncStatus = null,
    Object? offlineCreated = null,
    Object? conflictResolutionData = freezed,
    Object? clientTimestamp = freezed,
    Object? processingNotes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      luxValue: null == luxValue
          ? _value.luxValue
          : luxValue // ignore: cast_nullable_to_non_nullable
              as double,
      ppfdValue: freezed == ppfdValue
          ? _value.ppfdValue
          : ppfdValue // ignore: cast_nullable_to_non_nullable
              as double?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as LightSource,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      gpsLatitude: freezed == gpsLatitude
          ? _value.gpsLatitude
          : gpsLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      gpsLongitude: freezed == gpsLongitude
          ? _value.gpsLongitude
          : gpsLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      calibrationProfileId: freezed == calibrationProfileId
          ? _value.calibrationProfileId
          : calibrationProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      bleDeviceId: freezed == bleDeviceId
          ? _value.bleDeviceId
          : bleDeviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      rawData: freezed == rawData
          ? _value.rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      growthPhotoId: freezed == growthPhotoId
          ? _value.growthPhotoId
          : growthPhotoId // ignore: cast_nullable_to_non_nullable
              as String?,
      telemetrySessionId: freezed == telemetrySessionId
          ? _value.telemetrySessionId
          : telemetrySessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      conflictResolutionData: freezed == conflictResolutionData
          ? _value.conflictResolutionData
          : conflictResolutionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: freezed == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processingNotes: freezed == processingNotes
          ? _value.processingNotes
          : processingNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LightReadingDataImplCopyWith<$Res>
    implements $LightReadingDataCopyWith<$Res> {
  factory _$$LightReadingDataImplCopyWith(_$LightReadingDataImpl value,
          $Res Function(_$LightReadingDataImpl) then) =
      __$$LightReadingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? plantId,
      double luxValue,
      double? ppfdValue,
      LightSource source,
      String? locationName,
      double? gpsLatitude,
      double? gpsLongitude,
      double? altitude,
      double? temperature,
      double? humidity,
      String? calibrationProfileId,
      String? deviceId,
      String? bleDeviceId,
      Map<String, dynamic>? rawData,
      DateTime measuredAt,
      String? growthPhotoId,
      String? telemetrySessionId,
      SyncStatus syncStatus,
      bool offlineCreated,
      Map<String, dynamic>? conflictResolutionData,
      DateTime? clientTimestamp,
      String? processingNotes,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$LightReadingDataImplCopyWithImpl<$Res>
    extends _$LightReadingDataCopyWithImpl<$Res, _$LightReadingDataImpl>
    implements _$$LightReadingDataImplCopyWith<$Res> {
  __$$LightReadingDataImplCopyWithImpl(_$LightReadingDataImpl _value,
      $Res Function(_$LightReadingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of LightReadingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? plantId = freezed,
    Object? luxValue = null,
    Object? ppfdValue = freezed,
    Object? source = null,
    Object? locationName = freezed,
    Object? gpsLatitude = freezed,
    Object? gpsLongitude = freezed,
    Object? altitude = freezed,
    Object? temperature = freezed,
    Object? humidity = freezed,
    Object? calibrationProfileId = freezed,
    Object? deviceId = freezed,
    Object? bleDeviceId = freezed,
    Object? rawData = freezed,
    Object? measuredAt = null,
    Object? growthPhotoId = freezed,
    Object? telemetrySessionId = freezed,
    Object? syncStatus = null,
    Object? offlineCreated = null,
    Object? conflictResolutionData = freezed,
    Object? clientTimestamp = freezed,
    Object? processingNotes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LightReadingDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      luxValue: null == luxValue
          ? _value.luxValue
          : luxValue // ignore: cast_nullable_to_non_nullable
              as double,
      ppfdValue: freezed == ppfdValue
          ? _value.ppfdValue
          : ppfdValue // ignore: cast_nullable_to_non_nullable
              as double?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as LightSource,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      gpsLatitude: freezed == gpsLatitude
          ? _value.gpsLatitude
          : gpsLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      gpsLongitude: freezed == gpsLongitude
          ? _value.gpsLongitude
          : gpsLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      calibrationProfileId: freezed == calibrationProfileId
          ? _value.calibrationProfileId
          : calibrationProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      bleDeviceId: freezed == bleDeviceId
          ? _value.bleDeviceId
          : bleDeviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      rawData: freezed == rawData
          ? _value._rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      growthPhotoId: freezed == growthPhotoId
          ? _value.growthPhotoId
          : growthPhotoId // ignore: cast_nullable_to_non_nullable
              as String?,
      telemetrySessionId: freezed == telemetrySessionId
          ? _value.telemetrySessionId
          : telemetrySessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      conflictResolutionData: freezed == conflictResolutionData
          ? _value._conflictResolutionData
          : conflictResolutionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: freezed == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processingNotes: freezed == processingNotes
          ? _value.processingNotes
          : processingNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LightReadingDataImpl implements _LightReadingData {
  const _$LightReadingDataImpl(
      {this.id,
      this.userId,
      this.plantId,
      required this.luxValue,
      this.ppfdValue,
      required this.source,
      this.locationName,
      this.gpsLatitude,
      this.gpsLongitude,
      this.altitude,
      this.temperature,
      this.humidity,
      this.calibrationProfileId,
      this.deviceId,
      this.bleDeviceId,
      final Map<String, dynamic>? rawData,
      required this.measuredAt,
      this.growthPhotoId,
      this.telemetrySessionId,
      this.syncStatus = SyncStatus.pending,
      this.offlineCreated = false,
      final Map<String, dynamic>? conflictResolutionData,
      this.clientTimestamp,
      this.processingNotes,
      this.createdAt,
      this.updatedAt})
      : _rawData = rawData,
        _conflictResolutionData = conflictResolutionData;

  factory _$LightReadingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LightReadingDataImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? plantId;
  @override
  final double luxValue;
  @override
  final double? ppfdValue;
  @override
  final LightSource source;
  @override
  final String? locationName;
  @override
  final double? gpsLatitude;
  @override
  final double? gpsLongitude;
  @override
  final double? altitude;
  @override
  final double? temperature;
  @override
  final double? humidity;
  @override
  final String? calibrationProfileId;
  @override
  final String? deviceId;
  @override
  final String? bleDeviceId;
  final Map<String, dynamic>? _rawData;
  @override
  Map<String, dynamic>? get rawData {
    final value = _rawData;
    if (value == null) return null;
    if (_rawData is EqualUnmodifiableMapView) return _rawData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime measuredAt;
// Telemetry fields for offline sync
  @override
  final String? growthPhotoId;
  @override
  final String? telemetrySessionId;
  @override
  @JsonKey()
  final SyncStatus syncStatus;
  @override
  @JsonKey()
  final bool offlineCreated;
  final Map<String, dynamic>? _conflictResolutionData;
  @override
  Map<String, dynamic>? get conflictResolutionData {
    final value = _conflictResolutionData;
    if (value == null) return null;
    if (_conflictResolutionData is EqualUnmodifiableMapView)
      return _conflictResolutionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? clientTimestamp;
// Metadata
  @override
  final String? processingNotes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LightReadingData(id: $id, userId: $userId, plantId: $plantId, luxValue: $luxValue, ppfdValue: $ppfdValue, source: $source, locationName: $locationName, gpsLatitude: $gpsLatitude, gpsLongitude: $gpsLongitude, altitude: $altitude, temperature: $temperature, humidity: $humidity, calibrationProfileId: $calibrationProfileId, deviceId: $deviceId, bleDeviceId: $bleDeviceId, rawData: $rawData, measuredAt: $measuredAt, growthPhotoId: $growthPhotoId, telemetrySessionId: $telemetrySessionId, syncStatus: $syncStatus, offlineCreated: $offlineCreated, conflictResolutionData: $conflictResolutionData, clientTimestamp: $clientTimestamp, processingNotes: $processingNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LightReadingDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.luxValue, luxValue) ||
                other.luxValue == luxValue) &&
            (identical(other.ppfdValue, ppfdValue) ||
                other.ppfdValue == ppfdValue) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.gpsLatitude, gpsLatitude) ||
                other.gpsLatitude == gpsLatitude) &&
            (identical(other.gpsLongitude, gpsLongitude) ||
                other.gpsLongitude == gpsLongitude) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.calibrationProfileId, calibrationProfileId) ||
                other.calibrationProfileId == calibrationProfileId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.bleDeviceId, bleDeviceId) ||
                other.bleDeviceId == bleDeviceId) &&
            const DeepCollectionEquality().equals(other._rawData, _rawData) &&
            (identical(other.measuredAt, measuredAt) ||
                other.measuredAt == measuredAt) &&
            (identical(other.growthPhotoId, growthPhotoId) ||
                other.growthPhotoId == growthPhotoId) &&
            (identical(other.telemetrySessionId, telemetrySessionId) ||
                other.telemetrySessionId == telemetrySessionId) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.offlineCreated, offlineCreated) ||
                other.offlineCreated == offlineCreated) &&
            const DeepCollectionEquality().equals(
                other._conflictResolutionData, _conflictResolutionData) &&
            (identical(other.clientTimestamp, clientTimestamp) ||
                other.clientTimestamp == clientTimestamp) &&
            (identical(other.processingNotes, processingNotes) ||
                other.processingNotes == processingNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        plantId,
        luxValue,
        ppfdValue,
        source,
        locationName,
        gpsLatitude,
        gpsLongitude,
        altitude,
        temperature,
        humidity,
        calibrationProfileId,
        deviceId,
        bleDeviceId,
        const DeepCollectionEquality().hash(_rawData),
        measuredAt,
        growthPhotoId,
        telemetrySessionId,
        syncStatus,
        offlineCreated,
        const DeepCollectionEquality().hash(_conflictResolutionData),
        clientTimestamp,
        processingNotes,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of LightReadingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LightReadingDataImplCopyWith<_$LightReadingDataImpl> get copyWith =>
      __$$LightReadingDataImplCopyWithImpl<_$LightReadingDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LightReadingDataImplToJson(
      this,
    );
  }
}

abstract class _LightReadingData implements LightReadingData {
  const factory _LightReadingData(
      {final String? id,
      final String? userId,
      final String? plantId,
      required final double luxValue,
      final double? ppfdValue,
      required final LightSource source,
      final String? locationName,
      final double? gpsLatitude,
      final double? gpsLongitude,
      final double? altitude,
      final double? temperature,
      final double? humidity,
      final String? calibrationProfileId,
      final String? deviceId,
      final String? bleDeviceId,
      final Map<String, dynamic>? rawData,
      required final DateTime measuredAt,
      final String? growthPhotoId,
      final String? telemetrySessionId,
      final SyncStatus syncStatus,
      final bool offlineCreated,
      final Map<String, dynamic>? conflictResolutionData,
      final DateTime? clientTimestamp,
      final String? processingNotes,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$LightReadingDataImpl;

  factory _LightReadingData.fromJson(Map<String, dynamic> json) =
      _$LightReadingDataImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get plantId;
  @override
  double get luxValue;
  @override
  double? get ppfdValue;
  @override
  LightSource get source;
  @override
  String? get locationName;
  @override
  double? get gpsLatitude;
  @override
  double? get gpsLongitude;
  @override
  double? get altitude;
  @override
  double? get temperature;
  @override
  double? get humidity;
  @override
  String? get calibrationProfileId;
  @override
  String? get deviceId;
  @override
  String? get bleDeviceId;
  @override
  Map<String, dynamic>? get rawData;
  @override
  DateTime get measuredAt; // Telemetry fields for offline sync
  @override
  String? get growthPhotoId;
  @override
  String? get telemetrySessionId;
  @override
  SyncStatus get syncStatus;
  @override
  bool get offlineCreated;
  @override
  Map<String, dynamic>? get conflictResolutionData;
  @override
  DateTime? get clientTimestamp; // Metadata
  @override
  String? get processingNotes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of LightReadingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LightReadingDataImplCopyWith<_$LightReadingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrowthMetrics _$GrowthMetricsFromJson(Map<String, dynamic> json) {
  return _GrowthMetrics.fromJson(json);
}

/// @nodoc
mixin _$GrowthMetrics {
  double? get leafAreaCm2 => throw _privateConstructorUsedError;
  double? get plantHeightCm => throw _privateConstructorUsedError;
  int? get leafCount => throw _privateConstructorUsedError;
  double? get stemWidthMm => throw _privateConstructorUsedError;
  double? get healthScore => throw _privateConstructorUsedError;
  double? get chlorophyllIndex => throw _privateConstructorUsedError;
  List<String> get diseaseIndicators =>
      throw _privateConstructorUsedError; // Additional properties for compatibility
  double? get heightCm => throw _privateConstructorUsedError;
  double? get widthCm => throw _privateConstructorUsedError;
  String? get colorAnalysis => throw _privateConstructorUsedError;

  /// Serializes this GrowthMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrowthMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrowthMetricsCopyWith<GrowthMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrowthMetricsCopyWith<$Res> {
  factory $GrowthMetricsCopyWith(
          GrowthMetrics value, $Res Function(GrowthMetrics) then) =
      _$GrowthMetricsCopyWithImpl<$Res, GrowthMetrics>;
  @useResult
  $Res call(
      {double? leafAreaCm2,
      double? plantHeightCm,
      int? leafCount,
      double? stemWidthMm,
      double? healthScore,
      double? chlorophyllIndex,
      List<String> diseaseIndicators,
      double? heightCm,
      double? widthCm,
      String? colorAnalysis});
}

/// @nodoc
class _$GrowthMetricsCopyWithImpl<$Res, $Val extends GrowthMetrics>
    implements $GrowthMetricsCopyWith<$Res> {
  _$GrowthMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrowthMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leafAreaCm2 = freezed,
    Object? plantHeightCm = freezed,
    Object? leafCount = freezed,
    Object? stemWidthMm = freezed,
    Object? healthScore = freezed,
    Object? chlorophyllIndex = freezed,
    Object? diseaseIndicators = null,
    Object? heightCm = freezed,
    Object? widthCm = freezed,
    Object? colorAnalysis = freezed,
  }) {
    return _then(_value.copyWith(
      leafAreaCm2: freezed == leafAreaCm2
          ? _value.leafAreaCm2
          : leafAreaCm2 // ignore: cast_nullable_to_non_nullable
              as double?,
      plantHeightCm: freezed == plantHeightCm
          ? _value.plantHeightCm
          : plantHeightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      leafCount: freezed == leafCount
          ? _value.leafCount
          : leafCount // ignore: cast_nullable_to_non_nullable
              as int?,
      stemWidthMm: freezed == stemWidthMm
          ? _value.stemWidthMm
          : stemWidthMm // ignore: cast_nullable_to_non_nullable
              as double?,
      healthScore: freezed == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as double?,
      chlorophyllIndex: freezed == chlorophyllIndex
          ? _value.chlorophyllIndex
          : chlorophyllIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      diseaseIndicators: null == diseaseIndicators
          ? _value.diseaseIndicators
          : diseaseIndicators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      widthCm: freezed == widthCm
          ? _value.widthCm
          : widthCm // ignore: cast_nullable_to_non_nullable
              as double?,
      colorAnalysis: freezed == colorAnalysis
          ? _value.colorAnalysis
          : colorAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrowthMetricsImplCopyWith<$Res>
    implements $GrowthMetricsCopyWith<$Res> {
  factory _$$GrowthMetricsImplCopyWith(
          _$GrowthMetricsImpl value, $Res Function(_$GrowthMetricsImpl) then) =
      __$$GrowthMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? leafAreaCm2,
      double? plantHeightCm,
      int? leafCount,
      double? stemWidthMm,
      double? healthScore,
      double? chlorophyllIndex,
      List<String> diseaseIndicators,
      double? heightCm,
      double? widthCm,
      String? colorAnalysis});
}

/// @nodoc
class __$$GrowthMetricsImplCopyWithImpl<$Res>
    extends _$GrowthMetricsCopyWithImpl<$Res, _$GrowthMetricsImpl>
    implements _$$GrowthMetricsImplCopyWith<$Res> {
  __$$GrowthMetricsImplCopyWithImpl(
      _$GrowthMetricsImpl _value, $Res Function(_$GrowthMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrowthMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leafAreaCm2 = freezed,
    Object? plantHeightCm = freezed,
    Object? leafCount = freezed,
    Object? stemWidthMm = freezed,
    Object? healthScore = freezed,
    Object? chlorophyllIndex = freezed,
    Object? diseaseIndicators = null,
    Object? heightCm = freezed,
    Object? widthCm = freezed,
    Object? colorAnalysis = freezed,
  }) {
    return _then(_$GrowthMetricsImpl(
      leafAreaCm2: freezed == leafAreaCm2
          ? _value.leafAreaCm2
          : leafAreaCm2 // ignore: cast_nullable_to_non_nullable
              as double?,
      plantHeightCm: freezed == plantHeightCm
          ? _value.plantHeightCm
          : plantHeightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      leafCount: freezed == leafCount
          ? _value.leafCount
          : leafCount // ignore: cast_nullable_to_non_nullable
              as int?,
      stemWidthMm: freezed == stemWidthMm
          ? _value.stemWidthMm
          : stemWidthMm // ignore: cast_nullable_to_non_nullable
              as double?,
      healthScore: freezed == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as double?,
      chlorophyllIndex: freezed == chlorophyllIndex
          ? _value.chlorophyllIndex
          : chlorophyllIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      diseaseIndicators: null == diseaseIndicators
          ? _value._diseaseIndicators
          : diseaseIndicators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      widthCm: freezed == widthCm
          ? _value.widthCm
          : widthCm // ignore: cast_nullable_to_non_nullable
              as double?,
      colorAnalysis: freezed == colorAnalysis
          ? _value.colorAnalysis
          : colorAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrowthMetricsImpl implements _GrowthMetrics {
  const _$GrowthMetricsImpl(
      {this.leafAreaCm2,
      this.plantHeightCm,
      this.leafCount,
      this.stemWidthMm,
      this.healthScore,
      this.chlorophyllIndex,
      final List<String> diseaseIndicators = const [],
      this.heightCm,
      this.widthCm,
      this.colorAnalysis})
      : _diseaseIndicators = diseaseIndicators;

  factory _$GrowthMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrowthMetricsImplFromJson(json);

  @override
  final double? leafAreaCm2;
  @override
  final double? plantHeightCm;
  @override
  final int? leafCount;
  @override
  final double? stemWidthMm;
  @override
  final double? healthScore;
  @override
  final double? chlorophyllIndex;
  final List<String> _diseaseIndicators;
  @override
  @JsonKey()
  List<String> get diseaseIndicators {
    if (_diseaseIndicators is EqualUnmodifiableListView)
      return _diseaseIndicators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diseaseIndicators);
  }

// Additional properties for compatibility
  @override
  final double? heightCm;
  @override
  final double? widthCm;
  @override
  final String? colorAnalysis;

  @override
  String toString() {
    return 'GrowthMetrics(leafAreaCm2: $leafAreaCm2, plantHeightCm: $plantHeightCm, leafCount: $leafCount, stemWidthMm: $stemWidthMm, healthScore: $healthScore, chlorophyllIndex: $chlorophyllIndex, diseaseIndicators: $diseaseIndicators, heightCm: $heightCm, widthCm: $widthCm, colorAnalysis: $colorAnalysis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrowthMetricsImpl &&
            (identical(other.leafAreaCm2, leafAreaCm2) ||
                other.leafAreaCm2 == leafAreaCm2) &&
            (identical(other.plantHeightCm, plantHeightCm) ||
                other.plantHeightCm == plantHeightCm) &&
            (identical(other.leafCount, leafCount) ||
                other.leafCount == leafCount) &&
            (identical(other.stemWidthMm, stemWidthMm) ||
                other.stemWidthMm == stemWidthMm) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            (identical(other.chlorophyllIndex, chlorophyllIndex) ||
                other.chlorophyllIndex == chlorophyllIndex) &&
            const DeepCollectionEquality()
                .equals(other._diseaseIndicators, _diseaseIndicators) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.widthCm, widthCm) || other.widthCm == widthCm) &&
            (identical(other.colorAnalysis, colorAnalysis) ||
                other.colorAnalysis == colorAnalysis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      leafAreaCm2,
      plantHeightCm,
      leafCount,
      stemWidthMm,
      healthScore,
      chlorophyllIndex,
      const DeepCollectionEquality().hash(_diseaseIndicators),
      heightCm,
      widthCm,
      colorAnalysis);

  /// Create a copy of GrowthMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrowthMetricsImplCopyWith<_$GrowthMetricsImpl> get copyWith =>
      __$$GrowthMetricsImplCopyWithImpl<_$GrowthMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrowthMetricsImplToJson(
      this,
    );
  }
}

abstract class _GrowthMetrics implements GrowthMetrics {
  const factory _GrowthMetrics(
      {final double? leafAreaCm2,
      final double? plantHeightCm,
      final int? leafCount,
      final double? stemWidthMm,
      final double? healthScore,
      final double? chlorophyllIndex,
      final List<String> diseaseIndicators,
      final double? heightCm,
      final double? widthCm,
      final String? colorAnalysis}) = _$GrowthMetricsImpl;

  factory _GrowthMetrics.fromJson(Map<String, dynamic> json) =
      _$GrowthMetricsImpl.fromJson;

  @override
  double? get leafAreaCm2;
  @override
  double? get plantHeightCm;
  @override
  int? get leafCount;
  @override
  double? get stemWidthMm;
  @override
  double? get healthScore;
  @override
  double? get chlorophyllIndex;
  @override
  List<String> get diseaseIndicators; // Additional properties for compatibility
  @override
  double? get heightCm;
  @override
  double? get widthCm;
  @override
  String? get colorAnalysis;

  /// Create a copy of GrowthMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrowthMetricsImplCopyWith<_$GrowthMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrowthMetricsData _$GrowthMetricsDataFromJson(Map<String, dynamic> json) {
  return _GrowthMetricsData.fromJson(json);
}

/// @nodoc
mixin _$GrowthMetricsData {
  double? get heightCm => throw _privateConstructorUsedError;
  double? get widthCm => throw _privateConstructorUsedError;
  int? get leafCount => throw _privateConstructorUsedError;
  double? get healthScore => throw _privateConstructorUsedError;
  String? get colorAnalysis => throw _privateConstructorUsedError;
  DateTime get extractedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalMetrics =>
      throw _privateConstructorUsedError;

  /// Serializes this GrowthMetricsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrowthMetricsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrowthMetricsDataCopyWith<GrowthMetricsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrowthMetricsDataCopyWith<$Res> {
  factory $GrowthMetricsDataCopyWith(
          GrowthMetricsData value, $Res Function(GrowthMetricsData) then) =
      _$GrowthMetricsDataCopyWithImpl<$Res, GrowthMetricsData>;
  @useResult
  $Res call(
      {double? heightCm,
      double? widthCm,
      int? leafCount,
      double? healthScore,
      String? colorAnalysis,
      DateTime extractedAt,
      Map<String, dynamic>? additionalMetrics});
}

/// @nodoc
class _$GrowthMetricsDataCopyWithImpl<$Res, $Val extends GrowthMetricsData>
    implements $GrowthMetricsDataCopyWith<$Res> {
  _$GrowthMetricsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrowthMetricsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = freezed,
    Object? widthCm = freezed,
    Object? leafCount = freezed,
    Object? healthScore = freezed,
    Object? colorAnalysis = freezed,
    Object? extractedAt = null,
    Object? additionalMetrics = freezed,
  }) {
    return _then(_value.copyWith(
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      widthCm: freezed == widthCm
          ? _value.widthCm
          : widthCm // ignore: cast_nullable_to_non_nullable
              as double?,
      leafCount: freezed == leafCount
          ? _value.leafCount
          : leafCount // ignore: cast_nullable_to_non_nullable
              as int?,
      healthScore: freezed == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as double?,
      colorAnalysis: freezed == colorAnalysis
          ? _value.colorAnalysis
          : colorAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      extractedAt: null == extractedAt
          ? _value.extractedAt
          : extractedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      additionalMetrics: freezed == additionalMetrics
          ? _value.additionalMetrics
          : additionalMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrowthMetricsDataImplCopyWith<$Res>
    implements $GrowthMetricsDataCopyWith<$Res> {
  factory _$$GrowthMetricsDataImplCopyWith(_$GrowthMetricsDataImpl value,
          $Res Function(_$GrowthMetricsDataImpl) then) =
      __$$GrowthMetricsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? heightCm,
      double? widthCm,
      int? leafCount,
      double? healthScore,
      String? colorAnalysis,
      DateTime extractedAt,
      Map<String, dynamic>? additionalMetrics});
}

/// @nodoc
class __$$GrowthMetricsDataImplCopyWithImpl<$Res>
    extends _$GrowthMetricsDataCopyWithImpl<$Res, _$GrowthMetricsDataImpl>
    implements _$$GrowthMetricsDataImplCopyWith<$Res> {
  __$$GrowthMetricsDataImplCopyWithImpl(_$GrowthMetricsDataImpl _value,
      $Res Function(_$GrowthMetricsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrowthMetricsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = freezed,
    Object? widthCm = freezed,
    Object? leafCount = freezed,
    Object? healthScore = freezed,
    Object? colorAnalysis = freezed,
    Object? extractedAt = null,
    Object? additionalMetrics = freezed,
  }) {
    return _then(_$GrowthMetricsDataImpl(
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      widthCm: freezed == widthCm
          ? _value.widthCm
          : widthCm // ignore: cast_nullable_to_non_nullable
              as double?,
      leafCount: freezed == leafCount
          ? _value.leafCount
          : leafCount // ignore: cast_nullable_to_non_nullable
              as int?,
      healthScore: freezed == healthScore
          ? _value.healthScore
          : healthScore // ignore: cast_nullable_to_non_nullable
              as double?,
      colorAnalysis: freezed == colorAnalysis
          ? _value.colorAnalysis
          : colorAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
      extractedAt: null == extractedAt
          ? _value.extractedAt
          : extractedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      additionalMetrics: freezed == additionalMetrics
          ? _value._additionalMetrics
          : additionalMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrowthMetricsDataImpl implements _GrowthMetricsData {
  const _$GrowthMetricsDataImpl(
      {this.heightCm,
      this.widthCm,
      this.leafCount,
      this.healthScore,
      this.colorAnalysis,
      required this.extractedAt,
      final Map<String, dynamic>? additionalMetrics})
      : _additionalMetrics = additionalMetrics;

  factory _$GrowthMetricsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrowthMetricsDataImplFromJson(json);

  @override
  final double? heightCm;
  @override
  final double? widthCm;
  @override
  final int? leafCount;
  @override
  final double? healthScore;
  @override
  final String? colorAnalysis;
  @override
  final DateTime extractedAt;
  final Map<String, dynamic>? _additionalMetrics;
  @override
  Map<String, dynamic>? get additionalMetrics {
    final value = _additionalMetrics;
    if (value == null) return null;
    if (_additionalMetrics is EqualUnmodifiableMapView)
      return _additionalMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GrowthMetricsData(heightCm: $heightCm, widthCm: $widthCm, leafCount: $leafCount, healthScore: $healthScore, colorAnalysis: $colorAnalysis, extractedAt: $extractedAt, additionalMetrics: $additionalMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrowthMetricsDataImpl &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.widthCm, widthCm) || other.widthCm == widthCm) &&
            (identical(other.leafCount, leafCount) ||
                other.leafCount == leafCount) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            (identical(other.colorAnalysis, colorAnalysis) ||
                other.colorAnalysis == colorAnalysis) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            const DeepCollectionEquality()
                .equals(other._additionalMetrics, _additionalMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      heightCm,
      widthCm,
      leafCount,
      healthScore,
      colorAnalysis,
      extractedAt,
      const DeepCollectionEquality().hash(_additionalMetrics));

  /// Create a copy of GrowthMetricsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrowthMetricsDataImplCopyWith<_$GrowthMetricsDataImpl> get copyWith =>
      __$$GrowthMetricsDataImplCopyWithImpl<_$GrowthMetricsDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrowthMetricsDataImplToJson(
      this,
    );
  }
}

abstract class _GrowthMetricsData implements GrowthMetricsData {
  const factory _GrowthMetricsData(
      {final double? heightCm,
      final double? widthCm,
      final int? leafCount,
      final double? healthScore,
      final String? colorAnalysis,
      required final DateTime extractedAt,
      final Map<String, dynamic>? additionalMetrics}) = _$GrowthMetricsDataImpl;

  factory _GrowthMetricsData.fromJson(Map<String, dynamic> json) =
      _$GrowthMetricsDataImpl.fromJson;

  @override
  double? get heightCm;
  @override
  double? get widthCm;
  @override
  int? get leafCount;
  @override
  double? get healthScore;
  @override
  String? get colorAnalysis;
  @override
  DateTime get extractedAt;
  @override
  Map<String, dynamic>? get additionalMetrics;

  /// Create a copy of GrowthMetricsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrowthMetricsDataImplCopyWith<_$GrowthMetricsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrowthPhotoData _$GrowthPhotoDataFromJson(Map<String, dynamic> json) {
  return _GrowthPhotoData.fromJson(json);
}

/// @nodoc
mixin _$GrowthPhotoData {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get plantId => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  int? get imageWidth => throw _privateConstructorUsedError;
  int? get imageHeight => throw _privateConstructorUsedError;
  GrowthMetrics? get metrics => throw _privateConstructorUsedError;
  String? get processingVersion => throw _privateConstructorUsedError;
  Map<String, double>? get confidenceScores =>
      throw _privateConstructorUsedError;
  int? get analysisDurationMs => throw _privateConstructorUsedError;
  String? get locationName => throw _privateConstructorUsedError;
  double? get ambientLightLux => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isProcessed => throw _privateConstructorUsedError;
  String? get processingError => throw _privateConstructorUsedError;
  String? get growthRateIndicator => throw _privateConstructorUsedError;
  DateTime get capturedAt => throw _privateConstructorUsedError;
  DateTime? get processedAt =>
      throw _privateConstructorUsedError; // Telemetry fields for offline sync
  String? get telemetrySessionId => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  bool get offlineCreated => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conflictResolutionData =>
      throw _privateConstructorUsedError;
  DateTime? get clientTimestamp =>
      throw _privateConstructorUsedError; // Metadata
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GrowthPhotoData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrowthPhotoDataCopyWith<GrowthPhotoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrowthPhotoDataCopyWith<$Res> {
  factory $GrowthPhotoDataCopyWith(
          GrowthPhotoData value, $Res Function(GrowthPhotoData) then) =
      _$GrowthPhotoDataCopyWithImpl<$Res, GrowthPhotoData>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? plantId,
      String filePath,
      int? fileSize,
      int? imageWidth,
      int? imageHeight,
      GrowthMetrics? metrics,
      String? processingVersion,
      Map<String, double>? confidenceScores,
      int? analysisDurationMs,
      String? locationName,
      double? ambientLightLux,
      String? notes,
      bool isProcessed,
      String? processingError,
      String? growthRateIndicator,
      DateTime capturedAt,
      DateTime? processedAt,
      String? telemetrySessionId,
      SyncStatus syncStatus,
      bool offlineCreated,
      Map<String, dynamic>? conflictResolutionData,
      DateTime? clientTimestamp,
      DateTime? createdAt,
      DateTime? updatedAt});

  $GrowthMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class _$GrowthPhotoDataCopyWithImpl<$Res, $Val extends GrowthPhotoData>
    implements $GrowthPhotoDataCopyWith<$Res> {
  _$GrowthPhotoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? plantId = freezed,
    Object? filePath = null,
    Object? fileSize = freezed,
    Object? imageWidth = freezed,
    Object? imageHeight = freezed,
    Object? metrics = freezed,
    Object? processingVersion = freezed,
    Object? confidenceScores = freezed,
    Object? analysisDurationMs = freezed,
    Object? locationName = freezed,
    Object? ambientLightLux = freezed,
    Object? notes = freezed,
    Object? isProcessed = null,
    Object? processingError = freezed,
    Object? growthRateIndicator = freezed,
    Object? capturedAt = null,
    Object? processedAt = freezed,
    Object? telemetrySessionId = freezed,
    Object? syncStatus = null,
    Object? offlineCreated = null,
    Object? conflictResolutionData = freezed,
    Object? clientTimestamp = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      imageWidth: freezed == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int?,
      imageHeight: freezed == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as GrowthMetrics?,
      processingVersion: freezed == processingVersion
          ? _value.processingVersion
          : processingVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      confidenceScores: freezed == confidenceScores
          ? _value.confidenceScores
          : confidenceScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      analysisDurationMs: freezed == analysisDurationMs
          ? _value.analysisDurationMs
          : analysisDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      ambientLightLux: freezed == ambientLightLux
          ? _value.ambientLightLux
          : ambientLightLux // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessed: null == isProcessed
          ? _value.isProcessed
          : isProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
      processingError: freezed == processingError
          ? _value.processingError
          : processingError // ignore: cast_nullable_to_non_nullable
              as String?,
      growthRateIndicator: freezed == growthRateIndicator
          ? _value.growthRateIndicator
          : growthRateIndicator // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: null == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      telemetrySessionId: freezed == telemetrySessionId
          ? _value.telemetrySessionId
          : telemetrySessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      conflictResolutionData: freezed == conflictResolutionData
          ? _value.conflictResolutionData
          : conflictResolutionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: freezed == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GrowthMetricsCopyWith<$Res>? get metrics {
    if (_value.metrics == null) {
      return null;
    }

    return $GrowthMetricsCopyWith<$Res>(_value.metrics!, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GrowthPhotoDataImplCopyWith<$Res>
    implements $GrowthPhotoDataCopyWith<$Res> {
  factory _$$GrowthPhotoDataImplCopyWith(_$GrowthPhotoDataImpl value,
          $Res Function(_$GrowthPhotoDataImpl) then) =
      __$$GrowthPhotoDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? plantId,
      String filePath,
      int? fileSize,
      int? imageWidth,
      int? imageHeight,
      GrowthMetrics? metrics,
      String? processingVersion,
      Map<String, double>? confidenceScores,
      int? analysisDurationMs,
      String? locationName,
      double? ambientLightLux,
      String? notes,
      bool isProcessed,
      String? processingError,
      String? growthRateIndicator,
      DateTime capturedAt,
      DateTime? processedAt,
      String? telemetrySessionId,
      SyncStatus syncStatus,
      bool offlineCreated,
      Map<String, dynamic>? conflictResolutionData,
      DateTime? clientTimestamp,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $GrowthMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class __$$GrowthPhotoDataImplCopyWithImpl<$Res>
    extends _$GrowthPhotoDataCopyWithImpl<$Res, _$GrowthPhotoDataImpl>
    implements _$$GrowthPhotoDataImplCopyWith<$Res> {
  __$$GrowthPhotoDataImplCopyWithImpl(
      _$GrowthPhotoDataImpl _value, $Res Function(_$GrowthPhotoDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? plantId = freezed,
    Object? filePath = null,
    Object? fileSize = freezed,
    Object? imageWidth = freezed,
    Object? imageHeight = freezed,
    Object? metrics = freezed,
    Object? processingVersion = freezed,
    Object? confidenceScores = freezed,
    Object? analysisDurationMs = freezed,
    Object? locationName = freezed,
    Object? ambientLightLux = freezed,
    Object? notes = freezed,
    Object? isProcessed = null,
    Object? processingError = freezed,
    Object? growthRateIndicator = freezed,
    Object? capturedAt = null,
    Object? processedAt = freezed,
    Object? telemetrySessionId = freezed,
    Object? syncStatus = null,
    Object? offlineCreated = null,
    Object? conflictResolutionData = freezed,
    Object? clientTimestamp = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$GrowthPhotoDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      imageWidth: freezed == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int?,
      imageHeight: freezed == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as GrowthMetrics?,
      processingVersion: freezed == processingVersion
          ? _value.processingVersion
          : processingVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      confidenceScores: freezed == confidenceScores
          ? _value._confidenceScores
          : confidenceScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      analysisDurationMs: freezed == analysisDurationMs
          ? _value.analysisDurationMs
          : analysisDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      ambientLightLux: freezed == ambientLightLux
          ? _value.ambientLightLux
          : ambientLightLux // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessed: null == isProcessed
          ? _value.isProcessed
          : isProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
      processingError: freezed == processingError
          ? _value.processingError
          : processingError // ignore: cast_nullable_to_non_nullable
              as String?,
      growthRateIndicator: freezed == growthRateIndicator
          ? _value.growthRateIndicator
          : growthRateIndicator // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: null == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      telemetrySessionId: freezed == telemetrySessionId
          ? _value.telemetrySessionId
          : telemetrySessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      conflictResolutionData: freezed == conflictResolutionData
          ? _value._conflictResolutionData
          : conflictResolutionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: freezed == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrowthPhotoDataImpl implements _GrowthPhotoData {
  const _$GrowthPhotoDataImpl(
      {this.id,
      this.userId,
      this.plantId,
      required this.filePath,
      this.fileSize,
      this.imageWidth,
      this.imageHeight,
      this.metrics,
      this.processingVersion,
      final Map<String, double>? confidenceScores,
      this.analysisDurationMs,
      this.locationName,
      this.ambientLightLux,
      this.notes,
      this.isProcessed = false,
      this.processingError,
      this.growthRateIndicator,
      required this.capturedAt,
      this.processedAt,
      this.telemetrySessionId,
      this.syncStatus = SyncStatus.pending,
      this.offlineCreated = false,
      final Map<String, dynamic>? conflictResolutionData,
      this.clientTimestamp,
      this.createdAt,
      this.updatedAt})
      : _confidenceScores = confidenceScores,
        _conflictResolutionData = conflictResolutionData;

  factory _$GrowthPhotoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrowthPhotoDataImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? plantId;
  @override
  final String filePath;
  @override
  final int? fileSize;
  @override
  final int? imageWidth;
  @override
  final int? imageHeight;
  @override
  final GrowthMetrics? metrics;
  @override
  final String? processingVersion;
  final Map<String, double>? _confidenceScores;
  @override
  Map<String, double>? get confidenceScores {
    final value = _confidenceScores;
    if (value == null) return null;
    if (_confidenceScores is EqualUnmodifiableMapView) return _confidenceScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? analysisDurationMs;
  @override
  final String? locationName;
  @override
  final double? ambientLightLux;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isProcessed;
  @override
  final String? processingError;
  @override
  final String? growthRateIndicator;
  @override
  final DateTime capturedAt;
  @override
  final DateTime? processedAt;
// Telemetry fields for offline sync
  @override
  final String? telemetrySessionId;
  @override
  @JsonKey()
  final SyncStatus syncStatus;
  @override
  @JsonKey()
  final bool offlineCreated;
  final Map<String, dynamic>? _conflictResolutionData;
  @override
  Map<String, dynamic>? get conflictResolutionData {
    final value = _conflictResolutionData;
    if (value == null) return null;
    if (_conflictResolutionData is EqualUnmodifiableMapView)
      return _conflictResolutionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? clientTimestamp;
// Metadata
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'GrowthPhotoData(id: $id, userId: $userId, plantId: $plantId, filePath: $filePath, fileSize: $fileSize, imageWidth: $imageWidth, imageHeight: $imageHeight, metrics: $metrics, processingVersion: $processingVersion, confidenceScores: $confidenceScores, analysisDurationMs: $analysisDurationMs, locationName: $locationName, ambientLightLux: $ambientLightLux, notes: $notes, isProcessed: $isProcessed, processingError: $processingError, growthRateIndicator: $growthRateIndicator, capturedAt: $capturedAt, processedAt: $processedAt, telemetrySessionId: $telemetrySessionId, syncStatus: $syncStatus, offlineCreated: $offlineCreated, conflictResolutionData: $conflictResolutionData, clientTimestamp: $clientTimestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrowthPhotoDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.imageWidth, imageWidth) ||
                other.imageWidth == imageWidth) &&
            (identical(other.imageHeight, imageHeight) ||
                other.imageHeight == imageHeight) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            (identical(other.processingVersion, processingVersion) ||
                other.processingVersion == processingVersion) &&
            const DeepCollectionEquality()
                .equals(other._confidenceScores, _confidenceScores) &&
            (identical(other.analysisDurationMs, analysisDurationMs) ||
                other.analysisDurationMs == analysisDurationMs) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.ambientLightLux, ambientLightLux) ||
                other.ambientLightLux == ambientLightLux) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isProcessed, isProcessed) ||
                other.isProcessed == isProcessed) &&
            (identical(other.processingError, processingError) ||
                other.processingError == processingError) &&
            (identical(other.growthRateIndicator, growthRateIndicator) ||
                other.growthRateIndicator == growthRateIndicator) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.telemetrySessionId, telemetrySessionId) ||
                other.telemetrySessionId == telemetrySessionId) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.offlineCreated, offlineCreated) ||
                other.offlineCreated == offlineCreated) &&
            const DeepCollectionEquality().equals(
                other._conflictResolutionData, _conflictResolutionData) &&
            (identical(other.clientTimestamp, clientTimestamp) ||
                other.clientTimestamp == clientTimestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        plantId,
        filePath,
        fileSize,
        imageWidth,
        imageHeight,
        metrics,
        processingVersion,
        const DeepCollectionEquality().hash(_confidenceScores),
        analysisDurationMs,
        locationName,
        ambientLightLux,
        notes,
        isProcessed,
        processingError,
        growthRateIndicator,
        capturedAt,
        processedAt,
        telemetrySessionId,
        syncStatus,
        offlineCreated,
        const DeepCollectionEquality().hash(_conflictResolutionData),
        clientTimestamp,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrowthPhotoDataImplCopyWith<_$GrowthPhotoDataImpl> get copyWith =>
      __$$GrowthPhotoDataImplCopyWithImpl<_$GrowthPhotoDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrowthPhotoDataImplToJson(
      this,
    );
  }
}

abstract class _GrowthPhotoData implements GrowthPhotoData {
  const factory _GrowthPhotoData(
      {final String? id,
      final String? userId,
      final String? plantId,
      required final String filePath,
      final int? fileSize,
      final int? imageWidth,
      final int? imageHeight,
      final GrowthMetrics? metrics,
      final String? processingVersion,
      final Map<String, double>? confidenceScores,
      final int? analysisDurationMs,
      final String? locationName,
      final double? ambientLightLux,
      final String? notes,
      final bool isProcessed,
      final String? processingError,
      final String? growthRateIndicator,
      required final DateTime capturedAt,
      final DateTime? processedAt,
      final String? telemetrySessionId,
      final SyncStatus syncStatus,
      final bool offlineCreated,
      final Map<String, dynamic>? conflictResolutionData,
      final DateTime? clientTimestamp,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$GrowthPhotoDataImpl;

  factory _GrowthPhotoData.fromJson(Map<String, dynamic> json) =
      _$GrowthPhotoDataImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get plantId;
  @override
  String get filePath;
  @override
  int? get fileSize;
  @override
  int? get imageWidth;
  @override
  int? get imageHeight;
  @override
  GrowthMetrics? get metrics;
  @override
  String? get processingVersion;
  @override
  Map<String, double>? get confidenceScores;
  @override
  int? get analysisDurationMs;
  @override
  String? get locationName;
  @override
  double? get ambientLightLux;
  @override
  String? get notes;
  @override
  bool get isProcessed;
  @override
  String? get processingError;
  @override
  String? get growthRateIndicator;
  @override
  DateTime get capturedAt;
  @override
  DateTime? get processedAt; // Telemetry fields for offline sync
  @override
  String? get telemetrySessionId;
  @override
  SyncStatus get syncStatus;
  @override
  bool get offlineCreated;
  @override
  Map<String, dynamic>? get conflictResolutionData;
  @override
  DateTime? get clientTimestamp; // Metadata
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of GrowthPhotoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrowthPhotoDataImplCopyWith<_$GrowthPhotoDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TelemetryBatchData _$TelemetryBatchDataFromJson(Map<String, dynamic> json) {
  return _TelemetryBatchData.fromJson(json);
}

/// @nodoc
mixin _$TelemetryBatchData {
  String get sessionId => throw _privateConstructorUsedError;
  List<LightReadingData> get lightReadings =>
      throw _privateConstructorUsedError;
  List<GrowthPhotoData> get growthPhotos => throw _privateConstructorUsedError;
  Map<String, dynamic>? get batchMetadata => throw _privateConstructorUsedError;
  DateTime get clientTimestamp => throw _privateConstructorUsedError;
  bool get offlineMode => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  DateTime? get lastSyncAttempt => throw _privateConstructorUsedError;
  DateTime? get nextRetryAt => throw _privateConstructorUsedError;
  int? get retryCount => throw _privateConstructorUsedError;
  String? get syncError => throw _privateConstructorUsedError;

  /// Serializes this TelemetryBatchData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetryBatchData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetryBatchDataCopyWith<TelemetryBatchData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetryBatchDataCopyWith<$Res> {
  factory $TelemetryBatchDataCopyWith(
          TelemetryBatchData value, $Res Function(TelemetryBatchData) then) =
      _$TelemetryBatchDataCopyWithImpl<$Res, TelemetryBatchData>;
  @useResult
  $Res call(
      {String sessionId,
      List<LightReadingData> lightReadings,
      List<GrowthPhotoData> growthPhotos,
      Map<String, dynamic>? batchMetadata,
      DateTime clientTimestamp,
      bool offlineMode,
      SyncStatus syncStatus,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      int? retryCount,
      String? syncError});
}

/// @nodoc
class _$TelemetryBatchDataCopyWithImpl<$Res, $Val extends TelemetryBatchData>
    implements $TelemetryBatchDataCopyWith<$Res> {
  _$TelemetryBatchDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetryBatchData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? lightReadings = null,
    Object? growthPhotos = null,
    Object? batchMetadata = freezed,
    Object? clientTimestamp = null,
    Object? offlineMode = null,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? retryCount = freezed,
    Object? syncError = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      lightReadings: null == lightReadings
          ? _value.lightReadings
          : lightReadings // ignore: cast_nullable_to_non_nullable
              as List<LightReadingData>,
      growthPhotos: null == growthPhotos
          ? _value.growthPhotos
          : growthPhotos // ignore: cast_nullable_to_non_nullable
              as List<GrowthPhotoData>,
      batchMetadata: freezed == batchMetadata
          ? _value.batchMetadata
          : batchMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: null == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      offlineMode: null == offlineMode
          ? _value.offlineMode
          : offlineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: freezed == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TelemetryBatchDataImplCopyWith<$Res>
    implements $TelemetryBatchDataCopyWith<$Res> {
  factory _$$TelemetryBatchDataImplCopyWith(_$TelemetryBatchDataImpl value,
          $Res Function(_$TelemetryBatchDataImpl) then) =
      __$$TelemetryBatchDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      List<LightReadingData> lightReadings,
      List<GrowthPhotoData> growthPhotos,
      Map<String, dynamic>? batchMetadata,
      DateTime clientTimestamp,
      bool offlineMode,
      SyncStatus syncStatus,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      int? retryCount,
      String? syncError});
}

/// @nodoc
class __$$TelemetryBatchDataImplCopyWithImpl<$Res>
    extends _$TelemetryBatchDataCopyWithImpl<$Res, _$TelemetryBatchDataImpl>
    implements _$$TelemetryBatchDataImplCopyWith<$Res> {
  __$$TelemetryBatchDataImplCopyWithImpl(_$TelemetryBatchDataImpl _value,
      $Res Function(_$TelemetryBatchDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TelemetryBatchData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? lightReadings = null,
    Object? growthPhotos = null,
    Object? batchMetadata = freezed,
    Object? clientTimestamp = null,
    Object? offlineMode = null,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? retryCount = freezed,
    Object? syncError = freezed,
  }) {
    return _then(_$TelemetryBatchDataImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      lightReadings: null == lightReadings
          ? _value._lightReadings
          : lightReadings // ignore: cast_nullable_to_non_nullable
              as List<LightReadingData>,
      growthPhotos: null == growthPhotos
          ? _value._growthPhotos
          : growthPhotos // ignore: cast_nullable_to_non_nullable
              as List<GrowthPhotoData>,
      batchMetadata: freezed == batchMetadata
          ? _value._batchMetadata
          : batchMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      clientTimestamp: null == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      offlineMode: null == offlineMode
          ? _value.offlineMode
          : offlineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: freezed == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryBatchDataImpl implements _TelemetryBatchData {
  const _$TelemetryBatchDataImpl(
      {required this.sessionId,
      final List<LightReadingData> lightReadings = const [],
      final List<GrowthPhotoData> growthPhotos = const [],
      final Map<String, dynamic>? batchMetadata,
      required this.clientTimestamp,
      this.offlineMode = false,
      this.syncStatus = SyncStatus.pending,
      this.lastSyncAttempt,
      this.nextRetryAt,
      this.retryCount,
      this.syncError})
      : _lightReadings = lightReadings,
        _growthPhotos = growthPhotos,
        _batchMetadata = batchMetadata;

  factory _$TelemetryBatchDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryBatchDataImplFromJson(json);

  @override
  final String sessionId;
  final List<LightReadingData> _lightReadings;
  @override
  @JsonKey()
  List<LightReadingData> get lightReadings {
    if (_lightReadings is EqualUnmodifiableListView) return _lightReadings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lightReadings);
  }

  final List<GrowthPhotoData> _growthPhotos;
  @override
  @JsonKey()
  List<GrowthPhotoData> get growthPhotos {
    if (_growthPhotos is EqualUnmodifiableListView) return _growthPhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_growthPhotos);
  }

  final Map<String, dynamic>? _batchMetadata;
  @override
  Map<String, dynamic>? get batchMetadata {
    final value = _batchMetadata;
    if (value == null) return null;
    if (_batchMetadata is EqualUnmodifiableMapView) return _batchMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime clientTimestamp;
  @override
  @JsonKey()
  final bool offlineMode;
  @override
  @JsonKey()
  final SyncStatus syncStatus;
  @override
  final DateTime? lastSyncAttempt;
  @override
  final DateTime? nextRetryAt;
  @override
  final int? retryCount;
  @override
  final String? syncError;

  @override
  String toString() {
    return 'TelemetryBatchData(sessionId: $sessionId, lightReadings: $lightReadings, growthPhotos: $growthPhotos, batchMetadata: $batchMetadata, clientTimestamp: $clientTimestamp, offlineMode: $offlineMode, syncStatus: $syncStatus, lastSyncAttempt: $lastSyncAttempt, nextRetryAt: $nextRetryAt, retryCount: $retryCount, syncError: $syncError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryBatchDataImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality()
                .equals(other._lightReadings, _lightReadings) &&
            const DeepCollectionEquality()
                .equals(other._growthPhotos, _growthPhotos) &&
            const DeepCollectionEquality()
                .equals(other._batchMetadata, _batchMetadata) &&
            (identical(other.clientTimestamp, clientTimestamp) ||
                other.clientTimestamp == clientTimestamp) &&
            (identical(other.offlineMode, offlineMode) ||
                other.offlineMode == offlineMode) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.lastSyncAttempt, lastSyncAttempt) ||
                other.lastSyncAttempt == lastSyncAttempt) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.syncError, syncError) ||
                other.syncError == syncError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      const DeepCollectionEquality().hash(_lightReadings),
      const DeepCollectionEquality().hash(_growthPhotos),
      const DeepCollectionEquality().hash(_batchMetadata),
      clientTimestamp,
      offlineMode,
      syncStatus,
      lastSyncAttempt,
      nextRetryAt,
      retryCount,
      syncError);

  /// Create a copy of TelemetryBatchData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetryBatchDataImplCopyWith<_$TelemetryBatchDataImpl> get copyWith =>
      __$$TelemetryBatchDataImplCopyWithImpl<_$TelemetryBatchDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetryBatchDataImplToJson(
      this,
    );
  }
}

abstract class _TelemetryBatchData implements TelemetryBatchData {
  const factory _TelemetryBatchData(
      {required final String sessionId,
      final List<LightReadingData> lightReadings,
      final List<GrowthPhotoData> growthPhotos,
      final Map<String, dynamic>? batchMetadata,
      required final DateTime clientTimestamp,
      final bool offlineMode,
      final SyncStatus syncStatus,
      final DateTime? lastSyncAttempt,
      final DateTime? nextRetryAt,
      final int? retryCount,
      final String? syncError}) = _$TelemetryBatchDataImpl;

  factory _TelemetryBatchData.fromJson(Map<String, dynamic> json) =
      _$TelemetryBatchDataImpl.fromJson;

  @override
  String get sessionId;
  @override
  List<LightReadingData> get lightReadings;
  @override
  List<GrowthPhotoData> get growthPhotos;
  @override
  Map<String, dynamic>? get batchMetadata;
  @override
  DateTime get clientTimestamp;
  @override
  bool get offlineMode;
  @override
  SyncStatus get syncStatus;
  @override
  DateTime? get lastSyncAttempt;
  @override
  DateTime? get nextRetryAt;
  @override
  int? get retryCount;
  @override
  String? get syncError;

  /// Create a copy of TelemetryBatchData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryBatchDataImplCopyWith<_$TelemetryBatchDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TelemetrySyncStatus _$TelemetrySyncStatusFromJson(Map<String, dynamic> json) {
  return _TelemetrySyncStatus.fromJson(json);
}

/// @nodoc
mixin _$TelemetrySyncStatus {
  String get itemId => throw _privateConstructorUsedError;
  String get itemType => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;
  DateTime? get lastSyncAttempt => throw _privateConstructorUsedError;
  DateTime? get nextRetryAt => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get syncError => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conflictData => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TelemetrySyncStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetrySyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetrySyncStatusCopyWith<TelemetrySyncStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetrySyncStatusCopyWith<$Res> {
  factory $TelemetrySyncStatusCopyWith(
          TelemetrySyncStatus value, $Res Function(TelemetrySyncStatus) then) =
      _$TelemetrySyncStatusCopyWithImpl<$Res, TelemetrySyncStatus>;
  @useResult
  $Res call(
      {String itemId,
      String itemType,
      String? sessionId,
      SyncStatus syncStatus,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      int retryCount,
      int maxRetries,
      String? syncError,
      Map<String, dynamic>? conflictData,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TelemetrySyncStatusCopyWithImpl<$Res, $Val extends TelemetrySyncStatus>
    implements $TelemetrySyncStatusCopyWith<$Res> {
  _$TelemetrySyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetrySyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemType = null,
    Object? sessionId = freezed,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? syncError = freezed,
    Object? conflictData = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _value.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      conflictData: freezed == conflictData
          ? _value.conflictData
          : conflictData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TelemetrySyncStatusImplCopyWith<$Res>
    implements $TelemetrySyncStatusCopyWith<$Res> {
  factory _$$TelemetrySyncStatusImplCopyWith(_$TelemetrySyncStatusImpl value,
          $Res Function(_$TelemetrySyncStatusImpl) then) =
      __$$TelemetrySyncStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String itemId,
      String itemType,
      String? sessionId,
      SyncStatus syncStatus,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      int retryCount,
      int maxRetries,
      String? syncError,
      Map<String, dynamic>? conflictData,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TelemetrySyncStatusImplCopyWithImpl<$Res>
    extends _$TelemetrySyncStatusCopyWithImpl<$Res, _$TelemetrySyncStatusImpl>
    implements _$$TelemetrySyncStatusImplCopyWith<$Res> {
  __$$TelemetrySyncStatusImplCopyWithImpl(_$TelemetrySyncStatusImpl _value,
      $Res Function(_$TelemetrySyncStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TelemetrySyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemType = null,
    Object? sessionId = freezed,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? syncError = freezed,
    Object? conflictData = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TelemetrySyncStatusImpl(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _value.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      conflictData: freezed == conflictData
          ? _value._conflictData
          : conflictData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetrySyncStatusImpl implements _TelemetrySyncStatus {
  const _$TelemetrySyncStatusImpl(
      {required this.itemId,
      required this.itemType,
      this.sessionId,
      required this.syncStatus,
      this.lastSyncAttempt,
      this.nextRetryAt,
      this.retryCount = 0,
      this.maxRetries = 3,
      this.syncError,
      final Map<String, dynamic>? conflictData,
      this.createdAt,
      this.updatedAt})
      : _conflictData = conflictData;

  factory _$TelemetrySyncStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetrySyncStatusImplFromJson(json);

  @override
  final String itemId;
  @override
  final String itemType;
  @override
  final String? sessionId;
  @override
  final SyncStatus syncStatus;
  @override
  final DateTime? lastSyncAttempt;
  @override
  final DateTime? nextRetryAt;
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  final String? syncError;
  final Map<String, dynamic>? _conflictData;
  @override
  Map<String, dynamic>? get conflictData {
    final value = _conflictData;
    if (value == null) return null;
    if (_conflictData is EqualUnmodifiableMapView) return _conflictData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TelemetrySyncStatus(itemId: $itemId, itemType: $itemType, sessionId: $sessionId, syncStatus: $syncStatus, lastSyncAttempt: $lastSyncAttempt, nextRetryAt: $nextRetryAt, retryCount: $retryCount, maxRetries: $maxRetries, syncError: $syncError, conflictData: $conflictData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetrySyncStatusImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.lastSyncAttempt, lastSyncAttempt) ||
                other.lastSyncAttempt == lastSyncAttempt) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.syncError, syncError) ||
                other.syncError == syncError) &&
            const DeepCollectionEquality()
                .equals(other._conflictData, _conflictData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemId,
      itemType,
      sessionId,
      syncStatus,
      lastSyncAttempt,
      nextRetryAt,
      retryCount,
      maxRetries,
      syncError,
      const DeepCollectionEquality().hash(_conflictData),
      createdAt,
      updatedAt);

  /// Create a copy of TelemetrySyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetrySyncStatusImplCopyWith<_$TelemetrySyncStatusImpl> get copyWith =>
      __$$TelemetrySyncStatusImplCopyWithImpl<_$TelemetrySyncStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetrySyncStatusImplToJson(
      this,
    );
  }
}

abstract class _TelemetrySyncStatus implements TelemetrySyncStatus {
  const factory _TelemetrySyncStatus(
      {required final String itemId,
      required final String itemType,
      final String? sessionId,
      required final SyncStatus syncStatus,
      final DateTime? lastSyncAttempt,
      final DateTime? nextRetryAt,
      final int retryCount,
      final int maxRetries,
      final String? syncError,
      final Map<String, dynamic>? conflictData,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TelemetrySyncStatusImpl;

  factory _TelemetrySyncStatus.fromJson(Map<String, dynamic> json) =
      _$TelemetrySyncStatusImpl.fromJson;

  @override
  String get itemId;
  @override
  String get itemType;
  @override
  String? get sessionId;
  @override
  SyncStatus get syncStatus;
  @override
  DateTime? get lastSyncAttempt;
  @override
  DateTime? get nextRetryAt;
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get syncError;
  @override
  Map<String, dynamic>? get conflictData;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TelemetrySyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetrySyncStatusImplCopyWith<_$TelemetrySyncStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TelemetryData _$TelemetryDataFromJson(Map<String, dynamic> json) {
  return _TelemetryData.fromJson(json);
}

/// @nodoc
mixin _$TelemetryData {
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get plantId =>
      throw _privateConstructorUsedError; // Light reading data
  LightReadingData? get lightReading => throw _privateConstructorUsedError;
  GrowthPhotoData? get growthPhoto =>
      throw _privateConstructorUsedError; // Batch data
  TelemetryBatchData? get batchData =>
      throw _privateConstructorUsedError; // Sync tracking
  TelemetrySyncStatus? get syncStatus =>
      throw _privateConstructorUsedError; // Session and metadata
  String? get sessionId => throw _privateConstructorUsedError;
  bool get offlineCreated => throw _privateConstructorUsedError;
  DateTime get clientTimestamp => throw _privateConstructorUsedError;
  DateTime? get serverTimestamp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // Timestamps
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TelemetryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetryDataCopyWith<TelemetryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetryDataCopyWith<$Res> {
  factory $TelemetryDataCopyWith(
          TelemetryData value, $Res Function(TelemetryData) then) =
      _$TelemetryDataCopyWithImpl<$Res, TelemetryData>;
  @useResult
  $Res call(
      {String? id,
      String userId,
      String? plantId,
      LightReadingData? lightReading,
      GrowthPhotoData? growthPhoto,
      TelemetryBatchData? batchData,
      TelemetrySyncStatus? syncStatus,
      String? sessionId,
      bool offlineCreated,
      DateTime clientTimestamp,
      DateTime? serverTimestamp,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  $LightReadingDataCopyWith<$Res>? get lightReading;
  $GrowthPhotoDataCopyWith<$Res>? get growthPhoto;
  $TelemetryBatchDataCopyWith<$Res>? get batchData;
  $TelemetrySyncStatusCopyWith<$Res>? get syncStatus;
}

/// @nodoc
class _$TelemetryDataCopyWithImpl<$Res, $Val extends TelemetryData>
    implements $TelemetryDataCopyWith<$Res> {
  _$TelemetryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? plantId = freezed,
    Object? lightReading = freezed,
    Object? growthPhoto = freezed,
    Object? batchData = freezed,
    Object? syncStatus = freezed,
    Object? sessionId = freezed,
    Object? offlineCreated = null,
    Object? clientTimestamp = null,
    Object? serverTimestamp = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      lightReading: freezed == lightReading
          ? _value.lightReading
          : lightReading // ignore: cast_nullable_to_non_nullable
              as LightReadingData?,
      growthPhoto: freezed == growthPhoto
          ? _value.growthPhoto
          : growthPhoto // ignore: cast_nullable_to_non_nullable
              as GrowthPhotoData?,
      batchData: freezed == batchData
          ? _value.batchData
          : batchData // ignore: cast_nullable_to_non_nullable
              as TelemetryBatchData?,
      syncStatus: freezed == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as TelemetrySyncStatus?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      clientTimestamp: null == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serverTimestamp: freezed == serverTimestamp
          ? _value.serverTimestamp
          : serverTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LightReadingDataCopyWith<$Res>? get lightReading {
    if (_value.lightReading == null) {
      return null;
    }

    return $LightReadingDataCopyWith<$Res>(_value.lightReading!, (value) {
      return _then(_value.copyWith(lightReading: value) as $Val);
    });
  }

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GrowthPhotoDataCopyWith<$Res>? get growthPhoto {
    if (_value.growthPhoto == null) {
      return null;
    }

    return $GrowthPhotoDataCopyWith<$Res>(_value.growthPhoto!, (value) {
      return _then(_value.copyWith(growthPhoto: value) as $Val);
    });
  }

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TelemetryBatchDataCopyWith<$Res>? get batchData {
    if (_value.batchData == null) {
      return null;
    }

    return $TelemetryBatchDataCopyWith<$Res>(_value.batchData!, (value) {
      return _then(_value.copyWith(batchData: value) as $Val);
    });
  }

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TelemetrySyncStatusCopyWith<$Res>? get syncStatus {
    if (_value.syncStatus == null) {
      return null;
    }

    return $TelemetrySyncStatusCopyWith<$Res>(_value.syncStatus!, (value) {
      return _then(_value.copyWith(syncStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TelemetryDataImplCopyWith<$Res>
    implements $TelemetryDataCopyWith<$Res> {
  factory _$$TelemetryDataImplCopyWith(
          _$TelemetryDataImpl value, $Res Function(_$TelemetryDataImpl) then) =
      __$$TelemetryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String userId,
      String? plantId,
      LightReadingData? lightReading,
      GrowthPhotoData? growthPhoto,
      TelemetryBatchData? batchData,
      TelemetrySyncStatus? syncStatus,
      String? sessionId,
      bool offlineCreated,
      DateTime clientTimestamp,
      DateTime? serverTimestamp,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $LightReadingDataCopyWith<$Res>? get lightReading;
  @override
  $GrowthPhotoDataCopyWith<$Res>? get growthPhoto;
  @override
  $TelemetryBatchDataCopyWith<$Res>? get batchData;
  @override
  $TelemetrySyncStatusCopyWith<$Res>? get syncStatus;
}

/// @nodoc
class __$$TelemetryDataImplCopyWithImpl<$Res>
    extends _$TelemetryDataCopyWithImpl<$Res, _$TelemetryDataImpl>
    implements _$$TelemetryDataImplCopyWith<$Res> {
  __$$TelemetryDataImplCopyWithImpl(
      _$TelemetryDataImpl _value, $Res Function(_$TelemetryDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? plantId = freezed,
    Object? lightReading = freezed,
    Object? growthPhoto = freezed,
    Object? batchData = freezed,
    Object? syncStatus = freezed,
    Object? sessionId = freezed,
    Object? offlineCreated = null,
    Object? clientTimestamp = null,
    Object? serverTimestamp = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TelemetryDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      lightReading: freezed == lightReading
          ? _value.lightReading
          : lightReading // ignore: cast_nullable_to_non_nullable
              as LightReadingData?,
      growthPhoto: freezed == growthPhoto
          ? _value.growthPhoto
          : growthPhoto // ignore: cast_nullable_to_non_nullable
              as GrowthPhotoData?,
      batchData: freezed == batchData
          ? _value.batchData
          : batchData // ignore: cast_nullable_to_non_nullable
              as TelemetryBatchData?,
      syncStatus: freezed == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as TelemetrySyncStatus?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      offlineCreated: null == offlineCreated
          ? _value.offlineCreated
          : offlineCreated // ignore: cast_nullable_to_non_nullable
              as bool,
      clientTimestamp: null == clientTimestamp
          ? _value.clientTimestamp
          : clientTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serverTimestamp: freezed == serverTimestamp
          ? _value.serverTimestamp
          : serverTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryDataImpl implements _TelemetryData {
  const _$TelemetryDataImpl(
      {this.id,
      required this.userId,
      this.plantId,
      this.lightReading,
      this.growthPhoto,
      this.batchData,
      this.syncStatus,
      this.sessionId,
      required this.offlineCreated,
      required this.clientTimestamp,
      this.serverTimestamp,
      final Map<String, dynamic>? metadata,
      required this.createdAt,
      this.updatedAt})
      : _metadata = metadata;

  factory _$TelemetryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryDataImplFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String? plantId;
// Light reading data
  @override
  final LightReadingData? lightReading;
  @override
  final GrowthPhotoData? growthPhoto;
// Batch data
  @override
  final TelemetryBatchData? batchData;
// Sync tracking
  @override
  final TelemetrySyncStatus? syncStatus;
// Session and metadata
  @override
  final String? sessionId;
  @override
  final bool offlineCreated;
  @override
  final DateTime clientTimestamp;
  @override
  final DateTime? serverTimestamp;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TelemetryData(id: $id, userId: $userId, plantId: $plantId, lightReading: $lightReading, growthPhoto: $growthPhoto, batchData: $batchData, syncStatus: $syncStatus, sessionId: $sessionId, offlineCreated: $offlineCreated, clientTimestamp: $clientTimestamp, serverTimestamp: $serverTimestamp, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.lightReading, lightReading) ||
                other.lightReading == lightReading) &&
            (identical(other.growthPhoto, growthPhoto) ||
                other.growthPhoto == growthPhoto) &&
            (identical(other.batchData, batchData) ||
                other.batchData == batchData) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.offlineCreated, offlineCreated) ||
                other.offlineCreated == offlineCreated) &&
            (identical(other.clientTimestamp, clientTimestamp) ||
                other.clientTimestamp == clientTimestamp) &&
            (identical(other.serverTimestamp, serverTimestamp) ||
                other.serverTimestamp == serverTimestamp) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      plantId,
      lightReading,
      growthPhoto,
      batchData,
      syncStatus,
      sessionId,
      offlineCreated,
      clientTimestamp,
      serverTimestamp,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetryDataImplCopyWith<_$TelemetryDataImpl> get copyWith =>
      __$$TelemetryDataImplCopyWithImpl<_$TelemetryDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetryDataImplToJson(
      this,
    );
  }
}

abstract class _TelemetryData implements TelemetryData {
  const factory _TelemetryData(
      {final String? id,
      required final String userId,
      final String? plantId,
      final LightReadingData? lightReading,
      final GrowthPhotoData? growthPhoto,
      final TelemetryBatchData? batchData,
      final TelemetrySyncStatus? syncStatus,
      final String? sessionId,
      required final bool offlineCreated,
      required final DateTime clientTimestamp,
      final DateTime? serverTimestamp,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$TelemetryDataImpl;

  factory _TelemetryData.fromJson(Map<String, dynamic> json) =
      _$TelemetryDataImpl.fromJson;

  @override
  String? get id;
  @override
  String get userId;
  @override
  String? get plantId; // Light reading data
  @override
  LightReadingData? get lightReading;
  @override
  GrowthPhotoData? get growthPhoto; // Batch data
  @override
  TelemetryBatchData? get batchData; // Sync tracking
  @override
  TelemetrySyncStatus? get syncStatus; // Session and metadata
  @override
  String? get sessionId;
  @override
  bool get offlineCreated;
  @override
  DateTime get clientTimestamp;
  @override
  DateTime? get serverTimestamp;
  @override
  Map<String, dynamic>? get metadata; // Timestamps
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TelemetryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryDataImplCopyWith<_$TelemetryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
