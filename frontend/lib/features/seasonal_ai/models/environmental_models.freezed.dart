// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environmental_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EnvironmentalData _$EnvironmentalDataFromJson(Map<String, dynamic> json) {
  return _EnvironmentalData.fromJson(json);
}

/// @nodoc
mixin _$EnvironmentalData {
  Location get location => throw _privateConstructorUsedError;
  ClimateData get climateData => throw _privateConstructorUsedError;
  DaylightPatterns get daylightPatterns => throw _privateConstructorUsedError;
  WeatherForecast get weatherForecast => throw _privateConstructorUsedError;
  PestRiskData? get pestRiskData => throw _privateConstructorUsedError;

  /// Serializes this EnvironmentalData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnvironmentalDataCopyWith<EnvironmentalData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnvironmentalDataCopyWith<$Res> {
  factory $EnvironmentalDataCopyWith(
          EnvironmentalData value, $Res Function(EnvironmentalData) then) =
      _$EnvironmentalDataCopyWithImpl<$Res, EnvironmentalData>;
  @useResult
  $Res call(
      {Location location,
      ClimateData climateData,
      DaylightPatterns daylightPatterns,
      WeatherForecast weatherForecast,
      PestRiskData? pestRiskData});

  $LocationCopyWith<$Res> get location;
  $ClimateDataCopyWith<$Res> get climateData;
  $DaylightPatternsCopyWith<$Res> get daylightPatterns;
  $WeatherForecastCopyWith<$Res> get weatherForecast;
  $PestRiskDataCopyWith<$Res>? get pestRiskData;
}

/// @nodoc
class _$EnvironmentalDataCopyWithImpl<$Res, $Val extends EnvironmentalData>
    implements $EnvironmentalDataCopyWith<$Res> {
  _$EnvironmentalDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? climateData = null,
    Object? daylightPatterns = null,
    Object? weatherForecast = null,
    Object? pestRiskData = freezed,
  }) {
    return _then(_value.copyWith(
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      climateData: null == climateData
          ? _value.climateData
          : climateData // ignore: cast_nullable_to_non_nullable
              as ClimateData,
      daylightPatterns: null == daylightPatterns
          ? _value.daylightPatterns
          : daylightPatterns // ignore: cast_nullable_to_non_nullable
              as DaylightPatterns,
      weatherForecast: null == weatherForecast
          ? _value.weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as WeatherForecast,
      pestRiskData: freezed == pestRiskData
          ? _value.pestRiskData
          : pestRiskData // ignore: cast_nullable_to_non_nullable
              as PestRiskData?,
    ) as $Val);
  }

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClimateDataCopyWith<$Res> get climateData {
    return $ClimateDataCopyWith<$Res>(_value.climateData, (value) {
      return _then(_value.copyWith(climateData: value) as $Val);
    });
  }

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DaylightPatternsCopyWith<$Res> get daylightPatterns {
    return $DaylightPatternsCopyWith<$Res>(_value.daylightPatterns, (value) {
      return _then(_value.copyWith(daylightPatterns: value) as $Val);
    });
  }

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherForecastCopyWith<$Res> get weatherForecast {
    return $WeatherForecastCopyWith<$Res>(_value.weatherForecast, (value) {
      return _then(_value.copyWith(weatherForecast: value) as $Val);
    });
  }

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PestRiskDataCopyWith<$Res>? get pestRiskData {
    if (_value.pestRiskData == null) {
      return null;
    }

    return $PestRiskDataCopyWith<$Res>(_value.pestRiskData!, (value) {
      return _then(_value.copyWith(pestRiskData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EnvironmentalDataImplCopyWith<$Res>
    implements $EnvironmentalDataCopyWith<$Res> {
  factory _$$EnvironmentalDataImplCopyWith(_$EnvironmentalDataImpl value,
          $Res Function(_$EnvironmentalDataImpl) then) =
      __$$EnvironmentalDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Location location,
      ClimateData climateData,
      DaylightPatterns daylightPatterns,
      WeatherForecast weatherForecast,
      PestRiskData? pestRiskData});

  @override
  $LocationCopyWith<$Res> get location;
  @override
  $ClimateDataCopyWith<$Res> get climateData;
  @override
  $DaylightPatternsCopyWith<$Res> get daylightPatterns;
  @override
  $WeatherForecastCopyWith<$Res> get weatherForecast;
  @override
  $PestRiskDataCopyWith<$Res>? get pestRiskData;
}

/// @nodoc
class __$$EnvironmentalDataImplCopyWithImpl<$Res>
    extends _$EnvironmentalDataCopyWithImpl<$Res, _$EnvironmentalDataImpl>
    implements _$$EnvironmentalDataImplCopyWith<$Res> {
  __$$EnvironmentalDataImplCopyWithImpl(_$EnvironmentalDataImpl _value,
      $Res Function(_$EnvironmentalDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? climateData = null,
    Object? daylightPatterns = null,
    Object? weatherForecast = null,
    Object? pestRiskData = freezed,
  }) {
    return _then(_$EnvironmentalDataImpl(
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      climateData: null == climateData
          ? _value.climateData
          : climateData // ignore: cast_nullable_to_non_nullable
              as ClimateData,
      daylightPatterns: null == daylightPatterns
          ? _value.daylightPatterns
          : daylightPatterns // ignore: cast_nullable_to_non_nullable
              as DaylightPatterns,
      weatherForecast: null == weatherForecast
          ? _value.weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as WeatherForecast,
      pestRiskData: freezed == pestRiskData
          ? _value.pestRiskData
          : pestRiskData // ignore: cast_nullable_to_non_nullable
              as PestRiskData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EnvironmentalDataImpl implements _EnvironmentalData {
  const _$EnvironmentalDataImpl(
      {required this.location,
      required this.climateData,
      required this.daylightPatterns,
      required this.weatherForecast,
      this.pestRiskData});

  factory _$EnvironmentalDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnvironmentalDataImplFromJson(json);

  @override
  final Location location;
  @override
  final ClimateData climateData;
  @override
  final DaylightPatterns daylightPatterns;
  @override
  final WeatherForecast weatherForecast;
  @override
  final PestRiskData? pestRiskData;

  @override
  String toString() {
    return 'EnvironmentalData(location: $location, climateData: $climateData, daylightPatterns: $daylightPatterns, weatherForecast: $weatherForecast, pestRiskData: $pestRiskData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnvironmentalDataImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.climateData, climateData) ||
                other.climateData == climateData) &&
            (identical(other.daylightPatterns, daylightPatterns) ||
                other.daylightPatterns == daylightPatterns) &&
            (identical(other.weatherForecast, weatherForecast) ||
                other.weatherForecast == weatherForecast) &&
            (identical(other.pestRiskData, pestRiskData) ||
                other.pestRiskData == pestRiskData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location, climateData,
      daylightPatterns, weatherForecast, pestRiskData);

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnvironmentalDataImplCopyWith<_$EnvironmentalDataImpl> get copyWith =>
      __$$EnvironmentalDataImplCopyWithImpl<_$EnvironmentalDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnvironmentalDataImplToJson(
      this,
    );
  }
}

abstract class _EnvironmentalData implements EnvironmentalData {
  const factory _EnvironmentalData(
      {required final Location location,
      required final ClimateData climateData,
      required final DaylightPatterns daylightPatterns,
      required final WeatherForecast weatherForecast,
      final PestRiskData? pestRiskData}) = _$EnvironmentalDataImpl;

  factory _EnvironmentalData.fromJson(Map<String, dynamic> json) =
      _$EnvironmentalDataImpl.fromJson;

  @override
  Location get location;
  @override
  ClimateData get climateData;
  @override
  DaylightPatterns get daylightPatterns;
  @override
  WeatherForecast get weatherForecast;
  @override
  PestRiskData? get pestRiskData;

  /// Create a copy of EnvironmentalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnvironmentalDataImplCopyWith<_$EnvironmentalDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? city,
      String? region,
      String? country,
      String? timezone});
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? timezone = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
          _$LocationImpl value, $Res Function(_$LocationImpl) then) =
      __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? city,
      String? region,
      String? country,
      String? timezone});
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
      _$LocationImpl _value, $Res Function(_$LocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? timezone = freezed,
  }) {
    return _then(_$LocationImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl(
      {required this.latitude,
      required this.longitude,
      this.city,
      this.region,
      this.country,
      this.timezone});

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? city;
  @override
  final String? region;
  @override
  final String? country;
  @override
  final String? timezone;

  @override
  String toString() {
    return 'Location(latitude: $latitude, longitude: $longitude, city: $city, region: $region, country: $country, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, latitude, longitude, city, region, country, timezone);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(
      this,
    );
  }
}

abstract class _Location implements Location {
  const factory _Location(
      {required final double latitude,
      required final double longitude,
      final String? city,
      final String? region,
      final String? country,
      final String? timezone}) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get city;
  @override
  String? get region;
  @override
  String? get country;
  @override
  String? get timezone;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClimateData _$ClimateDataFromJson(Map<String, dynamic> json) {
  return _ClimateData.fromJson(json);
}

/// @nodoc
mixin _$ClimateData {
  List<TemperatureData> get temperatureHistory =>
      throw _privateConstructorUsedError;
  List<PrecipitationData> get precipitationHistory =>
      throw _privateConstructorUsedError;
  List<HumidityData> get humidityHistory => throw _privateConstructorUsedError;
  String get climateZone => throw _privateConstructorUsedError;

  /// Serializes this ClimateData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClimateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClimateDataCopyWith<ClimateData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClimateDataCopyWith<$Res> {
  factory $ClimateDataCopyWith(
          ClimateData value, $Res Function(ClimateData) then) =
      _$ClimateDataCopyWithImpl<$Res, ClimateData>;
  @useResult
  $Res call(
      {List<TemperatureData> temperatureHistory,
      List<PrecipitationData> precipitationHistory,
      List<HumidityData> humidityHistory,
      String climateZone});
}

/// @nodoc
class _$ClimateDataCopyWithImpl<$Res, $Val extends ClimateData>
    implements $ClimateDataCopyWith<$Res> {
  _$ClimateDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClimateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperatureHistory = null,
    Object? precipitationHistory = null,
    Object? humidityHistory = null,
    Object? climateZone = null,
  }) {
    return _then(_value.copyWith(
      temperatureHistory: null == temperatureHistory
          ? _value.temperatureHistory
          : temperatureHistory // ignore: cast_nullable_to_non_nullable
              as List<TemperatureData>,
      precipitationHistory: null == precipitationHistory
          ? _value.precipitationHistory
          : precipitationHistory // ignore: cast_nullable_to_non_nullable
              as List<PrecipitationData>,
      humidityHistory: null == humidityHistory
          ? _value.humidityHistory
          : humidityHistory // ignore: cast_nullable_to_non_nullable
              as List<HumidityData>,
      climateZone: null == climateZone
          ? _value.climateZone
          : climateZone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClimateDataImplCopyWith<$Res>
    implements $ClimateDataCopyWith<$Res> {
  factory _$$ClimateDataImplCopyWith(
          _$ClimateDataImpl value, $Res Function(_$ClimateDataImpl) then) =
      __$$ClimateDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TemperatureData> temperatureHistory,
      List<PrecipitationData> precipitationHistory,
      List<HumidityData> humidityHistory,
      String climateZone});
}

/// @nodoc
class __$$ClimateDataImplCopyWithImpl<$Res>
    extends _$ClimateDataCopyWithImpl<$Res, _$ClimateDataImpl>
    implements _$$ClimateDataImplCopyWith<$Res> {
  __$$ClimateDataImplCopyWithImpl(
      _$ClimateDataImpl _value, $Res Function(_$ClimateDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClimateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperatureHistory = null,
    Object? precipitationHistory = null,
    Object? humidityHistory = null,
    Object? climateZone = null,
  }) {
    return _then(_$ClimateDataImpl(
      temperatureHistory: null == temperatureHistory
          ? _value._temperatureHistory
          : temperatureHistory // ignore: cast_nullable_to_non_nullable
              as List<TemperatureData>,
      precipitationHistory: null == precipitationHistory
          ? _value._precipitationHistory
          : precipitationHistory // ignore: cast_nullable_to_non_nullable
              as List<PrecipitationData>,
      humidityHistory: null == humidityHistory
          ? _value._humidityHistory
          : humidityHistory // ignore: cast_nullable_to_non_nullable
              as List<HumidityData>,
      climateZone: null == climateZone
          ? _value.climateZone
          : climateZone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClimateDataImpl implements _ClimateData {
  const _$ClimateDataImpl(
      {required final List<TemperatureData> temperatureHistory,
      required final List<PrecipitationData> precipitationHistory,
      required final List<HumidityData> humidityHistory,
      required this.climateZone})
      : _temperatureHistory = temperatureHistory,
        _precipitationHistory = precipitationHistory,
        _humidityHistory = humidityHistory;

  factory _$ClimateDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClimateDataImplFromJson(json);

  final List<TemperatureData> _temperatureHistory;
  @override
  List<TemperatureData> get temperatureHistory {
    if (_temperatureHistory is EqualUnmodifiableListView)
      return _temperatureHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_temperatureHistory);
  }

  final List<PrecipitationData> _precipitationHistory;
  @override
  List<PrecipitationData> get precipitationHistory {
    if (_precipitationHistory is EqualUnmodifiableListView)
      return _precipitationHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_precipitationHistory);
  }

  final List<HumidityData> _humidityHistory;
  @override
  List<HumidityData> get humidityHistory {
    if (_humidityHistory is EqualUnmodifiableListView) return _humidityHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_humidityHistory);
  }

  @override
  final String climateZone;

  @override
  String toString() {
    return 'ClimateData(temperatureHistory: $temperatureHistory, precipitationHistory: $precipitationHistory, humidityHistory: $humidityHistory, climateZone: $climateZone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClimateDataImpl &&
            const DeepCollectionEquality()
                .equals(other._temperatureHistory, _temperatureHistory) &&
            const DeepCollectionEquality()
                .equals(other._precipitationHistory, _precipitationHistory) &&
            const DeepCollectionEquality()
                .equals(other._humidityHistory, _humidityHistory) &&
            (identical(other.climateZone, climateZone) ||
                other.climateZone == climateZone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_temperatureHistory),
      const DeepCollectionEquality().hash(_precipitationHistory),
      const DeepCollectionEquality().hash(_humidityHistory),
      climateZone);

  /// Create a copy of ClimateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClimateDataImplCopyWith<_$ClimateDataImpl> get copyWith =>
      __$$ClimateDataImplCopyWithImpl<_$ClimateDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClimateDataImplToJson(
      this,
    );
  }
}

abstract class _ClimateData implements ClimateData {
  const factory _ClimateData(
      {required final List<TemperatureData> temperatureHistory,
      required final List<PrecipitationData> precipitationHistory,
      required final List<HumidityData> humidityHistory,
      required final String climateZone}) = _$ClimateDataImpl;

  factory _ClimateData.fromJson(Map<String, dynamic> json) =
      _$ClimateDataImpl.fromJson;

  @override
  List<TemperatureData> get temperatureHistory;
  @override
  List<PrecipitationData> get precipitationHistory;
  @override
  List<HumidityData> get humidityHistory;
  @override
  String get climateZone;

  /// Create a copy of ClimateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClimateDataImplCopyWith<_$ClimateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemperatureData _$TemperatureDataFromJson(Map<String, dynamic> json) {
  return _TemperatureData.fromJson(json);
}

/// @nodoc
mixin _$TemperatureData {
  DateTime get date => throw _privateConstructorUsedError;
  double get averageTemp => throw _privateConstructorUsedError;
  double get minTemp => throw _privateConstructorUsedError;
  double get maxTemp => throw _privateConstructorUsedError;

  /// Serializes this TemperatureData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemperatureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemperatureDataCopyWith<TemperatureData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemperatureDataCopyWith<$Res> {
  factory $TemperatureDataCopyWith(
          TemperatureData value, $Res Function(TemperatureData) then) =
      _$TemperatureDataCopyWithImpl<$Res, TemperatureData>;
  @useResult
  $Res call(
      {DateTime date, double averageTemp, double minTemp, double maxTemp});
}

/// @nodoc
class _$TemperatureDataCopyWithImpl<$Res, $Val extends TemperatureData>
    implements $TemperatureDataCopyWith<$Res> {
  _$TemperatureDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemperatureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? averageTemp = null,
    Object? minTemp = null,
    Object? maxTemp = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageTemp: null == averageTemp
          ? _value.averageTemp
          : averageTemp // ignore: cast_nullable_to_non_nullable
              as double,
      minTemp: null == minTemp
          ? _value.minTemp
          : minTemp // ignore: cast_nullable_to_non_nullable
              as double,
      maxTemp: null == maxTemp
          ? _value.maxTemp
          : maxTemp // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemperatureDataImplCopyWith<$Res>
    implements $TemperatureDataCopyWith<$Res> {
  factory _$$TemperatureDataImplCopyWith(_$TemperatureDataImpl value,
          $Res Function(_$TemperatureDataImpl) then) =
      __$$TemperatureDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, double averageTemp, double minTemp, double maxTemp});
}

/// @nodoc
class __$$TemperatureDataImplCopyWithImpl<$Res>
    extends _$TemperatureDataCopyWithImpl<$Res, _$TemperatureDataImpl>
    implements _$$TemperatureDataImplCopyWith<$Res> {
  __$$TemperatureDataImplCopyWithImpl(
      _$TemperatureDataImpl _value, $Res Function(_$TemperatureDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TemperatureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? averageTemp = null,
    Object? minTemp = null,
    Object? maxTemp = null,
  }) {
    return _then(_$TemperatureDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      averageTemp: null == averageTemp
          ? _value.averageTemp
          : averageTemp // ignore: cast_nullable_to_non_nullable
              as double,
      minTemp: null == minTemp
          ? _value.minTemp
          : minTemp // ignore: cast_nullable_to_non_nullable
              as double,
      maxTemp: null == maxTemp
          ? _value.maxTemp
          : maxTemp // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemperatureDataImpl implements _TemperatureData {
  const _$TemperatureDataImpl(
      {required this.date,
      required this.averageTemp,
      required this.minTemp,
      required this.maxTemp});

  factory _$TemperatureDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemperatureDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double averageTemp;
  @override
  final double minTemp;
  @override
  final double maxTemp;

  @override
  String toString() {
    return 'TemperatureData(date: $date, averageTemp: $averageTemp, minTemp: $minTemp, maxTemp: $maxTemp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemperatureDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.averageTemp, averageTemp) ||
                other.averageTemp == averageTemp) &&
            (identical(other.minTemp, minTemp) || other.minTemp == minTemp) &&
            (identical(other.maxTemp, maxTemp) || other.maxTemp == maxTemp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, averageTemp, minTemp, maxTemp);

  /// Create a copy of TemperatureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemperatureDataImplCopyWith<_$TemperatureDataImpl> get copyWith =>
      __$$TemperatureDataImplCopyWithImpl<_$TemperatureDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemperatureDataImplToJson(
      this,
    );
  }
}

abstract class _TemperatureData implements TemperatureData {
  const factory _TemperatureData(
      {required final DateTime date,
      required final double averageTemp,
      required final double minTemp,
      required final double maxTemp}) = _$TemperatureDataImpl;

  factory _TemperatureData.fromJson(Map<String, dynamic> json) =
      _$TemperatureDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get averageTemp;
  @override
  double get minTemp;
  @override
  double get maxTemp;

  /// Create a copy of TemperatureData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemperatureDataImplCopyWith<_$TemperatureDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrecipitationData _$PrecipitationDataFromJson(Map<String, dynamic> json) {
  return _PrecipitationData.fromJson(json);
}

/// @nodoc
mixin _$PrecipitationData {
  DateTime get date => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this PrecipitationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrecipitationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrecipitationDataCopyWith<PrecipitationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrecipitationDataCopyWith<$Res> {
  factory $PrecipitationDataCopyWith(
          PrecipitationData value, $Res Function(PrecipitationData) then) =
      _$PrecipitationDataCopyWithImpl<$Res, PrecipitationData>;
  @useResult
  $Res call({DateTime date, double amount, String type});
}

/// @nodoc
class _$PrecipitationDataCopyWithImpl<$Res, $Val extends PrecipitationData>
    implements $PrecipitationDataCopyWith<$Res> {
  _$PrecipitationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrecipitationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrecipitationDataImplCopyWith<$Res>
    implements $PrecipitationDataCopyWith<$Res> {
  factory _$$PrecipitationDataImplCopyWith(_$PrecipitationDataImpl value,
          $Res Function(_$PrecipitationDataImpl) then) =
      __$$PrecipitationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double amount, String type});
}

/// @nodoc
class __$$PrecipitationDataImplCopyWithImpl<$Res>
    extends _$PrecipitationDataCopyWithImpl<$Res, _$PrecipitationDataImpl>
    implements _$$PrecipitationDataImplCopyWith<$Res> {
  __$$PrecipitationDataImplCopyWithImpl(_$PrecipitationDataImpl _value,
      $Res Function(_$PrecipitationDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrecipitationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? type = null,
  }) {
    return _then(_$PrecipitationDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrecipitationDataImpl implements _PrecipitationData {
  const _$PrecipitationDataImpl(
      {required this.date, required this.amount, required this.type});

  factory _$PrecipitationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrecipitationDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double amount;
  @override
  final String type;

  @override
  String toString() {
    return 'PrecipitationData(date: $date, amount: $amount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrecipitationDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, amount, type);

  /// Create a copy of PrecipitationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrecipitationDataImplCopyWith<_$PrecipitationDataImpl> get copyWith =>
      __$$PrecipitationDataImplCopyWithImpl<_$PrecipitationDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrecipitationDataImplToJson(
      this,
    );
  }
}

abstract class _PrecipitationData implements PrecipitationData {
  const factory _PrecipitationData(
      {required final DateTime date,
      required final double amount,
      required final String type}) = _$PrecipitationDataImpl;

  factory _PrecipitationData.fromJson(Map<String, dynamic> json) =
      _$PrecipitationDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get amount;
  @override
  String get type;

  /// Create a copy of PrecipitationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrecipitationDataImplCopyWith<_$PrecipitationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HumidityData _$HumidityDataFromJson(Map<String, dynamic> json) {
  return _HumidityData.fromJson(json);
}

/// @nodoc
mixin _$HumidityData {
  DateTime get date => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this HumidityData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HumidityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HumidityDataCopyWith<HumidityData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HumidityDataCopyWith<$Res> {
  factory $HumidityDataCopyWith(
          HumidityData value, $Res Function(HumidityData) then) =
      _$HumidityDataCopyWithImpl<$Res, HumidityData>;
  @useResult
  $Res call({DateTime date, double percentage});
}

/// @nodoc
class _$HumidityDataCopyWithImpl<$Res, $Val extends HumidityData>
    implements $HumidityDataCopyWith<$Res> {
  _$HumidityDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HumidityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HumidityDataImplCopyWith<$Res>
    implements $HumidityDataCopyWith<$Res> {
  factory _$$HumidityDataImplCopyWith(
          _$HumidityDataImpl value, $Res Function(_$HumidityDataImpl) then) =
      __$$HumidityDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double percentage});
}

/// @nodoc
class __$$HumidityDataImplCopyWithImpl<$Res>
    extends _$HumidityDataCopyWithImpl<$Res, _$HumidityDataImpl>
    implements _$$HumidityDataImplCopyWith<$Res> {
  __$$HumidityDataImplCopyWithImpl(
      _$HumidityDataImpl _value, $Res Function(_$HumidityDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HumidityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? percentage = null,
  }) {
    return _then(_$HumidityDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HumidityDataImpl implements _HumidityData {
  const _$HumidityDataImpl({required this.date, required this.percentage});

  factory _$HumidityDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HumidityDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double percentage;

  @override
  String toString() {
    return 'HumidityData(date: $date, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HumidityDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, percentage);

  /// Create a copy of HumidityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HumidityDataImplCopyWith<_$HumidityDataImpl> get copyWith =>
      __$$HumidityDataImplCopyWithImpl<_$HumidityDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HumidityDataImplToJson(
      this,
    );
  }
}

abstract class _HumidityData implements HumidityData {
  const factory _HumidityData(
      {required final DateTime date,
      required final double percentage}) = _$HumidityDataImpl;

  factory _HumidityData.fromJson(Map<String, dynamic> json) =
      _$HumidityDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get percentage;

  /// Create a copy of HumidityData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HumidityDataImplCopyWith<_$HumidityDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DaylightPatterns _$DaylightPatternsFromJson(Map<String, dynamic> json) {
  return _DaylightPatterns.fromJson(json);
}

/// @nodoc
mixin _$DaylightPatterns {
  List<DaylightData> get yearlyPattern => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DaylightPatterns to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DaylightPatterns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DaylightPatternsCopyWith<DaylightPatterns> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DaylightPatternsCopyWith<$Res> {
  factory $DaylightPatternsCopyWith(
          DaylightPatterns value, $Res Function(DaylightPatterns) then) =
      _$DaylightPatternsCopyWithImpl<$Res, DaylightPatterns>;
  @useResult
  $Res call({List<DaylightData> yearlyPattern, DateTime lastUpdated});
}

/// @nodoc
class _$DaylightPatternsCopyWithImpl<$Res, $Val extends DaylightPatterns>
    implements $DaylightPatternsCopyWith<$Res> {
  _$DaylightPatternsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DaylightPatterns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyPattern = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      yearlyPattern: null == yearlyPattern
          ? _value.yearlyPattern
          : yearlyPattern // ignore: cast_nullable_to_non_nullable
              as List<DaylightData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DaylightPatternsImplCopyWith<$Res>
    implements $DaylightPatternsCopyWith<$Res> {
  factory _$$DaylightPatternsImplCopyWith(_$DaylightPatternsImpl value,
          $Res Function(_$DaylightPatternsImpl) then) =
      __$$DaylightPatternsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DaylightData> yearlyPattern, DateTime lastUpdated});
}

/// @nodoc
class __$$DaylightPatternsImplCopyWithImpl<$Res>
    extends _$DaylightPatternsCopyWithImpl<$Res, _$DaylightPatternsImpl>
    implements _$$DaylightPatternsImplCopyWith<$Res> {
  __$$DaylightPatternsImplCopyWithImpl(_$DaylightPatternsImpl _value,
      $Res Function(_$DaylightPatternsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DaylightPatterns
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyPattern = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$DaylightPatternsImpl(
      yearlyPattern: null == yearlyPattern
          ? _value._yearlyPattern
          : yearlyPattern // ignore: cast_nullable_to_non_nullable
              as List<DaylightData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DaylightPatternsImpl implements _DaylightPatterns {
  const _$DaylightPatternsImpl(
      {required final List<DaylightData> yearlyPattern,
      required this.lastUpdated})
      : _yearlyPattern = yearlyPattern;

  factory _$DaylightPatternsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DaylightPatternsImplFromJson(json);

  final List<DaylightData> _yearlyPattern;
  @override
  List<DaylightData> get yearlyPattern {
    if (_yearlyPattern is EqualUnmodifiableListView) return _yearlyPattern;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_yearlyPattern);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'DaylightPatterns(yearlyPattern: $yearlyPattern, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DaylightPatternsImpl &&
            const DeepCollectionEquality()
                .equals(other._yearlyPattern, _yearlyPattern) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_yearlyPattern), lastUpdated);

  /// Create a copy of DaylightPatterns
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DaylightPatternsImplCopyWith<_$DaylightPatternsImpl> get copyWith =>
      __$$DaylightPatternsImplCopyWithImpl<_$DaylightPatternsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DaylightPatternsImplToJson(
      this,
    );
  }
}

abstract class _DaylightPatterns implements DaylightPatterns {
  const factory _DaylightPatterns(
      {required final List<DaylightData> yearlyPattern,
      required final DateTime lastUpdated}) = _$DaylightPatternsImpl;

  factory _DaylightPatterns.fromJson(Map<String, dynamic> json) =
      _$DaylightPatternsImpl.fromJson;

  @override
  List<DaylightData> get yearlyPattern;
  @override
  DateTime get lastUpdated;

  /// Create a copy of DaylightPatterns
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DaylightPatternsImplCopyWith<_$DaylightPatternsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DaylightData _$DaylightDataFromJson(Map<String, dynamic> json) {
  return _DaylightData.fromJson(json);
}

/// @nodoc
mixin _$DaylightData {
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get sunrise => throw _privateConstructorUsedError;
  DateTime get sunset => throw _privateConstructorUsedError;
  double get daylightHours => throw _privateConstructorUsedError;

  /// Serializes this DaylightData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DaylightData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DaylightDataCopyWith<DaylightData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DaylightDataCopyWith<$Res> {
  factory $DaylightDataCopyWith(
          DaylightData value, $Res Function(DaylightData) then) =
      _$DaylightDataCopyWithImpl<$Res, DaylightData>;
  @useResult
  $Res call(
      {DateTime date, DateTime sunrise, DateTime sunset, double daylightHours});
}

/// @nodoc
class _$DaylightDataCopyWithImpl<$Res, $Val extends DaylightData>
    implements $DaylightDataCopyWith<$Res> {
  _$DaylightDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DaylightData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? sunrise = null,
    Object? sunset = null,
    Object? daylightHours = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunrise: null == sunrise
          ? _value.sunrise
          : sunrise // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunset: null == sunset
          ? _value.sunset
          : sunset // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daylightHours: null == daylightHours
          ? _value.daylightHours
          : daylightHours // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DaylightDataImplCopyWith<$Res>
    implements $DaylightDataCopyWith<$Res> {
  factory _$$DaylightDataImplCopyWith(
          _$DaylightDataImpl value, $Res Function(_$DaylightDataImpl) then) =
      __$$DaylightDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, DateTime sunrise, DateTime sunset, double daylightHours});
}

/// @nodoc
class __$$DaylightDataImplCopyWithImpl<$Res>
    extends _$DaylightDataCopyWithImpl<$Res, _$DaylightDataImpl>
    implements _$$DaylightDataImplCopyWith<$Res> {
  __$$DaylightDataImplCopyWithImpl(
      _$DaylightDataImpl _value, $Res Function(_$DaylightDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DaylightData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? sunrise = null,
    Object? sunset = null,
    Object? daylightHours = null,
  }) {
    return _then(_$DaylightDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunrise: null == sunrise
          ? _value.sunrise
          : sunrise // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sunset: null == sunset
          ? _value.sunset
          : sunset // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daylightHours: null == daylightHours
          ? _value.daylightHours
          : daylightHours // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DaylightDataImpl implements _DaylightData {
  const _$DaylightDataImpl(
      {required this.date,
      required this.sunrise,
      required this.sunset,
      required this.daylightHours});

  factory _$DaylightDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DaylightDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final DateTime sunrise;
  @override
  final DateTime sunset;
  @override
  final double daylightHours;

  @override
  String toString() {
    return 'DaylightData(date: $date, sunrise: $sunrise, sunset: $sunset, daylightHours: $daylightHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DaylightDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.sunrise, sunrise) || other.sunrise == sunrise) &&
            (identical(other.sunset, sunset) || other.sunset == sunset) &&
            (identical(other.daylightHours, daylightHours) ||
                other.daylightHours == daylightHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, sunrise, sunset, daylightHours);

  /// Create a copy of DaylightData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DaylightDataImplCopyWith<_$DaylightDataImpl> get copyWith =>
      __$$DaylightDataImplCopyWithImpl<_$DaylightDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DaylightDataImplToJson(
      this,
    );
  }
}

abstract class _DaylightData implements DaylightData {
  const factory _DaylightData(
      {required final DateTime date,
      required final DateTime sunrise,
      required final DateTime sunset,
      required final double daylightHours}) = _$DaylightDataImpl;

  factory _DaylightData.fromJson(Map<String, dynamic> json) =
      _$DaylightDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  DateTime get sunrise;
  @override
  DateTime get sunset;
  @override
  double get daylightHours;

  /// Create a copy of DaylightData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DaylightDataImplCopyWith<_$DaylightDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherForecast _$WeatherForecastFromJson(Map<String, dynamic> json) {
  return _WeatherForecast.fromJson(json);
}

/// @nodoc
mixin _$WeatherForecast {
  List<DailyForecast> get dailyForecasts => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this WeatherForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherForecastCopyWith<WeatherForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherForecastCopyWith<$Res> {
  factory $WeatherForecastCopyWith(
          WeatherForecast value, $Res Function(WeatherForecast) then) =
      _$WeatherForecastCopyWithImpl<$Res, WeatherForecast>;
  @useResult
  $Res call({List<DailyForecast> dailyForecasts, DateTime lastUpdated});
}

/// @nodoc
class _$WeatherForecastCopyWithImpl<$Res, $Val extends WeatherForecast>
    implements $WeatherForecastCopyWith<$Res> {
  _$WeatherForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyForecasts = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      dailyForecasts: null == dailyForecasts
          ? _value.dailyForecasts
          : dailyForecasts // ignore: cast_nullable_to_non_nullable
              as List<DailyForecast>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeatherForecastImplCopyWith<$Res>
    implements $WeatherForecastCopyWith<$Res> {
  factory _$$WeatherForecastImplCopyWith(_$WeatherForecastImpl value,
          $Res Function(_$WeatherForecastImpl) then) =
      __$$WeatherForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DailyForecast> dailyForecasts, DateTime lastUpdated});
}

/// @nodoc
class __$$WeatherForecastImplCopyWithImpl<$Res>
    extends _$WeatherForecastCopyWithImpl<$Res, _$WeatherForecastImpl>
    implements _$$WeatherForecastImplCopyWith<$Res> {
  __$$WeatherForecastImplCopyWithImpl(
      _$WeatherForecastImpl _value, $Res Function(_$WeatherForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyForecasts = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$WeatherForecastImpl(
      dailyForecasts: null == dailyForecasts
          ? _value._dailyForecasts
          : dailyForecasts // ignore: cast_nullable_to_non_nullable
              as List<DailyForecast>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherForecastImpl implements _WeatherForecast {
  const _$WeatherForecastImpl(
      {required final List<DailyForecast> dailyForecasts,
      required this.lastUpdated})
      : _dailyForecasts = dailyForecasts;

  factory _$WeatherForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherForecastImplFromJson(json);

  final List<DailyForecast> _dailyForecasts;
  @override
  List<DailyForecast> get dailyForecasts {
    if (_dailyForecasts is EqualUnmodifiableListView) return _dailyForecasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyForecasts);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'WeatherForecast(dailyForecasts: $dailyForecasts, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherForecastImpl &&
            const DeepCollectionEquality()
                .equals(other._dailyForecasts, _dailyForecasts) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_dailyForecasts), lastUpdated);

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherForecastImplCopyWith<_$WeatherForecastImpl> get copyWith =>
      __$$WeatherForecastImplCopyWithImpl<_$WeatherForecastImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherForecastImplToJson(
      this,
    );
  }
}

abstract class _WeatherForecast implements WeatherForecast {
  const factory _WeatherForecast(
      {required final List<DailyForecast> dailyForecasts,
      required final DateTime lastUpdated}) = _$WeatherForecastImpl;

  factory _WeatherForecast.fromJson(Map<String, dynamic> json) =
      _$WeatherForecastImpl.fromJson;

  @override
  List<DailyForecast> get dailyForecasts;
  @override
  DateTime get lastUpdated;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherForecastImplCopyWith<_$WeatherForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) {
  return _DailyForecast.fromJson(json);
}

/// @nodoc
mixin _$DailyForecast {
  DateTime get date => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  double get humidity => throw _privateConstructorUsedError;
  double get precipitation => throw _privateConstructorUsedError;
  String get conditions => throw _privateConstructorUsedError;

  /// Serializes this DailyForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyForecastCopyWith<DailyForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyForecastCopyWith<$Res> {
  factory $DailyForecastCopyWith(
          DailyForecast value, $Res Function(DailyForecast) then) =
      _$DailyForecastCopyWithImpl<$Res, DailyForecast>;
  @useResult
  $Res call(
      {DateTime date,
      double temperature,
      double humidity,
      double precipitation,
      String conditions});
}

/// @nodoc
class _$DailyForecastCopyWithImpl<$Res, $Val extends DailyForecast>
    implements $DailyForecastCopyWith<$Res> {
  _$DailyForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? temperature = null,
    Object? humidity = null,
    Object? precipitation = null,
    Object? conditions = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double,
      precipitation: null == precipitation
          ? _value.precipitation
          : precipitation // ignore: cast_nullable_to_non_nullable
              as double,
      conditions: null == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyForecastImplCopyWith<$Res>
    implements $DailyForecastCopyWith<$Res> {
  factory _$$DailyForecastImplCopyWith(
          _$DailyForecastImpl value, $Res Function(_$DailyForecastImpl) then) =
      __$$DailyForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double temperature,
      double humidity,
      double precipitation,
      String conditions});
}

/// @nodoc
class __$$DailyForecastImplCopyWithImpl<$Res>
    extends _$DailyForecastCopyWithImpl<$Res, _$DailyForecastImpl>
    implements _$$DailyForecastImplCopyWith<$Res> {
  __$$DailyForecastImplCopyWithImpl(
      _$DailyForecastImpl _value, $Res Function(_$DailyForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? temperature = null,
    Object? humidity = null,
    Object? precipitation = null,
    Object? conditions = null,
  }) {
    return _then(_$DailyForecastImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double,
      precipitation: null == precipitation
          ? _value.precipitation
          : precipitation // ignore: cast_nullable_to_non_nullable
              as double,
      conditions: null == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyForecastImpl implements _DailyForecast {
  const _$DailyForecastImpl(
      {required this.date,
      required this.temperature,
      required this.humidity,
      required this.precipitation,
      required this.conditions});

  factory _$DailyForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyForecastImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double temperature;
  @override
  final double humidity;
  @override
  final double precipitation;
  @override
  final String conditions;

  @override
  String toString() {
    return 'DailyForecast(date: $date, temperature: $temperature, humidity: $humidity, precipitation: $precipitation, conditions: $conditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyForecastImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.precipitation, precipitation) ||
                other.precipitation == precipitation) &&
            (identical(other.conditions, conditions) ||
                other.conditions == conditions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, date, temperature, humidity, precipitation, conditions);

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyForecastImplCopyWith<_$DailyForecastImpl> get copyWith =>
      __$$DailyForecastImplCopyWithImpl<_$DailyForecastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyForecastImplToJson(
      this,
    );
  }
}

abstract class _DailyForecast implements DailyForecast {
  const factory _DailyForecast(
      {required final DateTime date,
      required final double temperature,
      required final double humidity,
      required final double precipitation,
      required final String conditions}) = _$DailyForecastImpl;

  factory _DailyForecast.fromJson(Map<String, dynamic> json) =
      _$DailyForecastImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get temperature;
  @override
  double get humidity;
  @override
  double get precipitation;
  @override
  String get conditions;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyForecastImplCopyWith<_$DailyForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PestRiskData _$PestRiskDataFromJson(Map<String, dynamic> json) {
  return _PestRiskData.fromJson(json);
}

/// @nodoc
mixin _$PestRiskData {
  List<PestRisk> get risks => throw _privateConstructorUsedError;
  DateTime get assessmentDate => throw _privateConstructorUsedError;

  /// Serializes this PestRiskData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PestRiskData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PestRiskDataCopyWith<PestRiskData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PestRiskDataCopyWith<$Res> {
  factory $PestRiskDataCopyWith(
          PestRiskData value, $Res Function(PestRiskData) then) =
      _$PestRiskDataCopyWithImpl<$Res, PestRiskData>;
  @useResult
  $Res call({List<PestRisk> risks, DateTime assessmentDate});
}

/// @nodoc
class _$PestRiskDataCopyWithImpl<$Res, $Val extends PestRiskData>
    implements $PestRiskDataCopyWith<$Res> {
  _$PestRiskDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PestRiskData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? risks = null,
    Object? assessmentDate = null,
  }) {
    return _then(_value.copyWith(
      risks: null == risks
          ? _value.risks
          : risks // ignore: cast_nullable_to_non_nullable
              as List<PestRisk>,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PestRiskDataImplCopyWith<$Res>
    implements $PestRiskDataCopyWith<$Res> {
  factory _$$PestRiskDataImplCopyWith(
          _$PestRiskDataImpl value, $Res Function(_$PestRiskDataImpl) then) =
      __$$PestRiskDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PestRisk> risks, DateTime assessmentDate});
}

/// @nodoc
class __$$PestRiskDataImplCopyWithImpl<$Res>
    extends _$PestRiskDataCopyWithImpl<$Res, _$PestRiskDataImpl>
    implements _$$PestRiskDataImplCopyWith<$Res> {
  __$$PestRiskDataImplCopyWithImpl(
      _$PestRiskDataImpl _value, $Res Function(_$PestRiskDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PestRiskData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? risks = null,
    Object? assessmentDate = null,
  }) {
    return _then(_$PestRiskDataImpl(
      risks: null == risks
          ? _value._risks
          : risks // ignore: cast_nullable_to_non_nullable
              as List<PestRisk>,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PestRiskDataImpl implements _PestRiskData {
  const _$PestRiskDataImpl(
      {required final List<PestRisk> risks, required this.assessmentDate})
      : _risks = risks;

  factory _$PestRiskDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PestRiskDataImplFromJson(json);

  final List<PestRisk> _risks;
  @override
  List<PestRisk> get risks {
    if (_risks is EqualUnmodifiableListView) return _risks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_risks);
  }

  @override
  final DateTime assessmentDate;

  @override
  String toString() {
    return 'PestRiskData(risks: $risks, assessmentDate: $assessmentDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PestRiskDataImpl &&
            const DeepCollectionEquality().equals(other._risks, _risks) &&
            (identical(other.assessmentDate, assessmentDate) ||
                other.assessmentDate == assessmentDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_risks), assessmentDate);

  /// Create a copy of PestRiskData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PestRiskDataImplCopyWith<_$PestRiskDataImpl> get copyWith =>
      __$$PestRiskDataImplCopyWithImpl<_$PestRiskDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PestRiskDataImplToJson(
      this,
    );
  }
}

abstract class _PestRiskData implements PestRiskData {
  const factory _PestRiskData(
      {required final List<PestRisk> risks,
      required final DateTime assessmentDate}) = _$PestRiskDataImpl;

  factory _PestRiskData.fromJson(Map<String, dynamic> json) =
      _$PestRiskDataImpl.fromJson;

  @override
  List<PestRisk> get risks;
  @override
  DateTime get assessmentDate;

  /// Create a copy of PestRiskData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PestRiskDataImplCopyWith<_$PestRiskDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PestRisk _$PestRiskFromJson(Map<String, dynamic> json) {
  return _PestRisk.fromJson(json);
}

/// @nodoc
mixin _$PestRisk {
  String get pestType => throw _privateConstructorUsedError;
  double get riskLevel => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get preventionMethods => throw _privateConstructorUsedError;

  /// Serializes this PestRisk to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PestRisk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PestRiskCopyWith<PestRisk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PestRiskCopyWith<$Res> {
  factory $PestRiskCopyWith(PestRisk value, $Res Function(PestRisk) then) =
      _$PestRiskCopyWithImpl<$Res, PestRisk>;
  @useResult
  $Res call(
      {String pestType,
      double riskLevel,
      String description,
      List<String> preventionMethods});
}

/// @nodoc
class _$PestRiskCopyWithImpl<$Res, $Val extends PestRisk>
    implements $PestRiskCopyWith<$Res> {
  _$PestRiskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PestRisk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pestType = null,
    Object? riskLevel = null,
    Object? description = null,
    Object? preventionMethods = null,
  }) {
    return _then(_value.copyWith(
      pestType: null == pestType
          ? _value.pestType
          : pestType // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preventionMethods: null == preventionMethods
          ? _value.preventionMethods
          : preventionMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PestRiskImplCopyWith<$Res>
    implements $PestRiskCopyWith<$Res> {
  factory _$$PestRiskImplCopyWith(
          _$PestRiskImpl value, $Res Function(_$PestRiskImpl) then) =
      __$$PestRiskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pestType,
      double riskLevel,
      String description,
      List<String> preventionMethods});
}

/// @nodoc
class __$$PestRiskImplCopyWithImpl<$Res>
    extends _$PestRiskCopyWithImpl<$Res, _$PestRiskImpl>
    implements _$$PestRiskImplCopyWith<$Res> {
  __$$PestRiskImplCopyWithImpl(
      _$PestRiskImpl _value, $Res Function(_$PestRiskImpl) _then)
      : super(_value, _then);

  /// Create a copy of PestRisk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pestType = null,
    Object? riskLevel = null,
    Object? description = null,
    Object? preventionMethods = null,
  }) {
    return _then(_$PestRiskImpl(
      pestType: null == pestType
          ? _value.pestType
          : pestType // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      preventionMethods: null == preventionMethods
          ? _value._preventionMethods
          : preventionMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PestRiskImpl implements _PestRisk {
  const _$PestRiskImpl(
      {required this.pestType,
      required this.riskLevel,
      required this.description,
      required final List<String> preventionMethods})
      : _preventionMethods = preventionMethods;

  factory _$PestRiskImpl.fromJson(Map<String, dynamic> json) =>
      _$$PestRiskImplFromJson(json);

  @override
  final String pestType;
  @override
  final double riskLevel;
  @override
  final String description;
  final List<String> _preventionMethods;
  @override
  List<String> get preventionMethods {
    if (_preventionMethods is EqualUnmodifiableListView)
      return _preventionMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preventionMethods);
  }

  @override
  String toString() {
    return 'PestRisk(pestType: $pestType, riskLevel: $riskLevel, description: $description, preventionMethods: $preventionMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PestRiskImpl &&
            (identical(other.pestType, pestType) ||
                other.pestType == pestType) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._preventionMethods, _preventionMethods));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pestType, riskLevel, description,
      const DeepCollectionEquality().hash(_preventionMethods));

  /// Create a copy of PestRisk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PestRiskImplCopyWith<_$PestRiskImpl> get copyWith =>
      __$$PestRiskImplCopyWithImpl<_$PestRiskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PestRiskImplToJson(
      this,
    );
  }
}

abstract class _PestRisk implements PestRisk {
  const factory _PestRisk(
      {required final String pestType,
      required final double riskLevel,
      required final String description,
      required final List<String> preventionMethods}) = _$PestRiskImpl;

  factory _PestRisk.fromJson(Map<String, dynamic> json) =
      _$PestRiskImpl.fromJson;

  @override
  String get pestType;
  @override
  double get riskLevel;
  @override
  String get description;
  @override
  List<String> get preventionMethods;

  /// Create a copy of PestRisk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PestRiskImplCopyWith<_$PestRiskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
