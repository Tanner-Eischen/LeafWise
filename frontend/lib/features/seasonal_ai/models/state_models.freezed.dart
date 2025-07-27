// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SeasonalAIState _$SeasonalAIStateFromJson(Map<String, dynamic> json) {
  return _SeasonalAIState.fromJson(json);
}

/// @nodoc
mixin _$SeasonalAIState {
// Loading states
  bool get isLoadingPredictions => throw _privateConstructorUsedError;
  bool get isLoadingCareAdjustments => throw _privateConstructorUsedError;
  bool get isLoadingEnvironmentalData => throw _privateConstructorUsedError;
  bool get isLoadingClimateData => throw _privateConstructorUsedError;
  bool get isLoadingRiskFactors => throw _privateConstructorUsedError;
  bool get isLoadingTransitions => throw _privateConstructorUsedError;
  bool get isLoadingGrowthForecasts => throw _privateConstructorUsedError;
  bool get isLoadingWeatherForecast => throw _privateConstructorUsedError;
  bool get isCreating => throw _privateConstructorUsedError;
  bool get isSyncing => throw _privateConstructorUsedError; // Data fields
  List<SeasonalPrediction> get seasonalPredictions =>
      throw _privateConstructorUsedError;
  List<CareAdjustment> get careAdjustments =>
      throw _privateConstructorUsedError;
  EnvironmentalData? get currentEnvironmentalData =>
      throw _privateConstructorUsedError;
  List<RiskFactor> get riskFactors => throw _privateConstructorUsedError;
  List<SeasonalTransition> get seasonalTransitions =>
      throw _privateConstructorUsedError;
  SeasonalTransition? get currentSeasonalTransition =>
      throw _privateConstructorUsedError;
  List<GrowthForecast> get growthForecasts =>
      throw _privateConstructorUsedError;
  WeatherForecast? get weatherForecast => throw _privateConstructorUsedError;
  List<EnvironmentalData> get environmentalForecast =>
      throw _privateConstructorUsedError;
  ClimateData? get climateData =>
      throw _privateConstructorUsedError; // Status and error fields
  String? get syncStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get createError => throw _privateConstructorUsedError;
  String? get syncError => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this SeasonalAIState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonalAIStateCopyWith<SeasonalAIState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonalAIStateCopyWith<$Res> {
  factory $SeasonalAIStateCopyWith(
          SeasonalAIState value, $Res Function(SeasonalAIState) then) =
      _$SeasonalAIStateCopyWithImpl<$Res, SeasonalAIState>;
  @useResult
  $Res call(
      {bool isLoadingPredictions,
      bool isLoadingCareAdjustments,
      bool isLoadingEnvironmentalData,
      bool isLoadingClimateData,
      bool isLoadingRiskFactors,
      bool isLoadingTransitions,
      bool isLoadingGrowthForecasts,
      bool isLoadingWeatherForecast,
      bool isCreating,
      bool isSyncing,
      List<SeasonalPrediction> seasonalPredictions,
      List<CareAdjustment> careAdjustments,
      EnvironmentalData? currentEnvironmentalData,
      List<RiskFactor> riskFactors,
      List<SeasonalTransition> seasonalTransitions,
      SeasonalTransition? currentSeasonalTransition,
      List<GrowthForecast> growthForecasts,
      WeatherForecast? weatherForecast,
      List<EnvironmentalData> environmentalForecast,
      ClimateData? climateData,
      String? syncStatus,
      String? error,
      String? createError,
      String? syncError,
      DateTime? lastUpdated});

  $EnvironmentalDataCopyWith<$Res>? get currentEnvironmentalData;
  $SeasonalTransitionCopyWith<$Res>? get currentSeasonalTransition;
  $WeatherForecastCopyWith<$Res>? get weatherForecast;
  $ClimateDataCopyWith<$Res>? get climateData;
}

/// @nodoc
class _$SeasonalAIStateCopyWithImpl<$Res, $Val extends SeasonalAIState>
    implements $SeasonalAIStateCopyWith<$Res> {
  _$SeasonalAIStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingPredictions = null,
    Object? isLoadingCareAdjustments = null,
    Object? isLoadingEnvironmentalData = null,
    Object? isLoadingClimateData = null,
    Object? isLoadingRiskFactors = null,
    Object? isLoadingTransitions = null,
    Object? isLoadingGrowthForecasts = null,
    Object? isLoadingWeatherForecast = null,
    Object? isCreating = null,
    Object? isSyncing = null,
    Object? seasonalPredictions = null,
    Object? careAdjustments = null,
    Object? currentEnvironmentalData = freezed,
    Object? riskFactors = null,
    Object? seasonalTransitions = null,
    Object? currentSeasonalTransition = freezed,
    Object? growthForecasts = null,
    Object? weatherForecast = freezed,
    Object? environmentalForecast = null,
    Object? climateData = freezed,
    Object? syncStatus = freezed,
    Object? error = freezed,
    Object? createError = freezed,
    Object? syncError = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      isLoadingPredictions: null == isLoadingPredictions
          ? _value.isLoadingPredictions
          : isLoadingPredictions // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingCareAdjustments: null == isLoadingCareAdjustments
          ? _value.isLoadingCareAdjustments
          : isLoadingCareAdjustments // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingEnvironmentalData: null == isLoadingEnvironmentalData
          ? _value.isLoadingEnvironmentalData
          : isLoadingEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingClimateData: null == isLoadingClimateData
          ? _value.isLoadingClimateData
          : isLoadingClimateData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRiskFactors: null == isLoadingRiskFactors
          ? _value.isLoadingRiskFactors
          : isLoadingRiskFactors // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTransitions: null == isLoadingTransitions
          ? _value.isLoadingTransitions
          : isLoadingTransitions // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingGrowthForecasts: null == isLoadingGrowthForecasts
          ? _value.isLoadingGrowthForecasts
          : isLoadingGrowthForecasts // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingWeatherForecast: null == isLoadingWeatherForecast
          ? _value.isLoadingWeatherForecast
          : isLoadingWeatherForecast // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      seasonalPredictions: null == seasonalPredictions
          ? _value.seasonalPredictions
          : seasonalPredictions // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPrediction>,
      careAdjustments: null == careAdjustments
          ? _value.careAdjustments
          : careAdjustments // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
      currentEnvironmentalData: freezed == currentEnvironmentalData
          ? _value.currentEnvironmentalData
          : currentEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as EnvironmentalData?,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      seasonalTransitions: null == seasonalTransitions
          ? _value.seasonalTransitions
          : seasonalTransitions // ignore: cast_nullable_to_non_nullable
              as List<SeasonalTransition>,
      currentSeasonalTransition: freezed == currentSeasonalTransition
          ? _value.currentSeasonalTransition
          : currentSeasonalTransition // ignore: cast_nullable_to_non_nullable
              as SeasonalTransition?,
      growthForecasts: null == growthForecasts
          ? _value.growthForecasts
          : growthForecasts // ignore: cast_nullable_to_non_nullable
              as List<GrowthForecast>,
      weatherForecast: freezed == weatherForecast
          ? _value.weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as WeatherForecast?,
      environmentalForecast: null == environmentalForecast
          ? _value.environmentalForecast
          : environmentalForecast // ignore: cast_nullable_to_non_nullable
              as List<EnvironmentalData>,
      climateData: freezed == climateData
          ? _value.climateData
          : climateData // ignore: cast_nullable_to_non_nullable
              as ClimateData?,
      syncStatus: freezed == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createError: freezed == createError
          ? _value.createError
          : createError // ignore: cast_nullable_to_non_nullable
              as String?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EnvironmentalDataCopyWith<$Res>? get currentEnvironmentalData {
    if (_value.currentEnvironmentalData == null) {
      return null;
    }

    return $EnvironmentalDataCopyWith<$Res>(_value.currentEnvironmentalData!,
        (value) {
      return _then(_value.copyWith(currentEnvironmentalData: value) as $Val);
    });
  }

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeasonalTransitionCopyWith<$Res>? get currentSeasonalTransition {
    if (_value.currentSeasonalTransition == null) {
      return null;
    }

    return $SeasonalTransitionCopyWith<$Res>(_value.currentSeasonalTransition!,
        (value) {
      return _then(_value.copyWith(currentSeasonalTransition: value) as $Val);
    });
  }

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherForecastCopyWith<$Res>? get weatherForecast {
    if (_value.weatherForecast == null) {
      return null;
    }

    return $WeatherForecastCopyWith<$Res>(_value.weatherForecast!, (value) {
      return _then(_value.copyWith(weatherForecast: value) as $Val);
    });
  }

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClimateDataCopyWith<$Res>? get climateData {
    if (_value.climateData == null) {
      return null;
    }

    return $ClimateDataCopyWith<$Res>(_value.climateData!, (value) {
      return _then(_value.copyWith(climateData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeasonalAIStateImplCopyWith<$Res>
    implements $SeasonalAIStateCopyWith<$Res> {
  factory _$$SeasonalAIStateImplCopyWith(_$SeasonalAIStateImpl value,
          $Res Function(_$SeasonalAIStateImpl) then) =
      __$$SeasonalAIStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoadingPredictions,
      bool isLoadingCareAdjustments,
      bool isLoadingEnvironmentalData,
      bool isLoadingClimateData,
      bool isLoadingRiskFactors,
      bool isLoadingTransitions,
      bool isLoadingGrowthForecasts,
      bool isLoadingWeatherForecast,
      bool isCreating,
      bool isSyncing,
      List<SeasonalPrediction> seasonalPredictions,
      List<CareAdjustment> careAdjustments,
      EnvironmentalData? currentEnvironmentalData,
      List<RiskFactor> riskFactors,
      List<SeasonalTransition> seasonalTransitions,
      SeasonalTransition? currentSeasonalTransition,
      List<GrowthForecast> growthForecasts,
      WeatherForecast? weatherForecast,
      List<EnvironmentalData> environmentalForecast,
      ClimateData? climateData,
      String? syncStatus,
      String? error,
      String? createError,
      String? syncError,
      DateTime? lastUpdated});

  @override
  $EnvironmentalDataCopyWith<$Res>? get currentEnvironmentalData;
  @override
  $SeasonalTransitionCopyWith<$Res>? get currentSeasonalTransition;
  @override
  $WeatherForecastCopyWith<$Res>? get weatherForecast;
  @override
  $ClimateDataCopyWith<$Res>? get climateData;
}

/// @nodoc
class __$$SeasonalAIStateImplCopyWithImpl<$Res>
    extends _$SeasonalAIStateCopyWithImpl<$Res, _$SeasonalAIStateImpl>
    implements _$$SeasonalAIStateImplCopyWith<$Res> {
  __$$SeasonalAIStateImplCopyWithImpl(
      _$SeasonalAIStateImpl _value, $Res Function(_$SeasonalAIStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingPredictions = null,
    Object? isLoadingCareAdjustments = null,
    Object? isLoadingEnvironmentalData = null,
    Object? isLoadingClimateData = null,
    Object? isLoadingRiskFactors = null,
    Object? isLoadingTransitions = null,
    Object? isLoadingGrowthForecasts = null,
    Object? isLoadingWeatherForecast = null,
    Object? isCreating = null,
    Object? isSyncing = null,
    Object? seasonalPredictions = null,
    Object? careAdjustments = null,
    Object? currentEnvironmentalData = freezed,
    Object? riskFactors = null,
    Object? seasonalTransitions = null,
    Object? currentSeasonalTransition = freezed,
    Object? growthForecasts = null,
    Object? weatherForecast = freezed,
    Object? environmentalForecast = null,
    Object? climateData = freezed,
    Object? syncStatus = freezed,
    Object? error = freezed,
    Object? createError = freezed,
    Object? syncError = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$SeasonalAIStateImpl(
      isLoadingPredictions: null == isLoadingPredictions
          ? _value.isLoadingPredictions
          : isLoadingPredictions // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingCareAdjustments: null == isLoadingCareAdjustments
          ? _value.isLoadingCareAdjustments
          : isLoadingCareAdjustments // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingEnvironmentalData: null == isLoadingEnvironmentalData
          ? _value.isLoadingEnvironmentalData
          : isLoadingEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingClimateData: null == isLoadingClimateData
          ? _value.isLoadingClimateData
          : isLoadingClimateData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRiskFactors: null == isLoadingRiskFactors
          ? _value.isLoadingRiskFactors
          : isLoadingRiskFactors // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTransitions: null == isLoadingTransitions
          ? _value.isLoadingTransitions
          : isLoadingTransitions // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingGrowthForecasts: null == isLoadingGrowthForecasts
          ? _value.isLoadingGrowthForecasts
          : isLoadingGrowthForecasts // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingWeatherForecast: null == isLoadingWeatherForecast
          ? _value.isLoadingWeatherForecast
          : isLoadingWeatherForecast // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      seasonalPredictions: null == seasonalPredictions
          ? _value._seasonalPredictions
          : seasonalPredictions // ignore: cast_nullable_to_non_nullable
              as List<SeasonalPrediction>,
      careAdjustments: null == careAdjustments
          ? _value._careAdjustments
          : careAdjustments // ignore: cast_nullable_to_non_nullable
              as List<CareAdjustment>,
      currentEnvironmentalData: freezed == currentEnvironmentalData
          ? _value.currentEnvironmentalData
          : currentEnvironmentalData // ignore: cast_nullable_to_non_nullable
              as EnvironmentalData?,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      seasonalTransitions: null == seasonalTransitions
          ? _value._seasonalTransitions
          : seasonalTransitions // ignore: cast_nullable_to_non_nullable
              as List<SeasonalTransition>,
      currentSeasonalTransition: freezed == currentSeasonalTransition
          ? _value.currentSeasonalTransition
          : currentSeasonalTransition // ignore: cast_nullable_to_non_nullable
              as SeasonalTransition?,
      growthForecasts: null == growthForecasts
          ? _value._growthForecasts
          : growthForecasts // ignore: cast_nullable_to_non_nullable
              as List<GrowthForecast>,
      weatherForecast: freezed == weatherForecast
          ? _value.weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as WeatherForecast?,
      environmentalForecast: null == environmentalForecast
          ? _value._environmentalForecast
          : environmentalForecast // ignore: cast_nullable_to_non_nullable
              as List<EnvironmentalData>,
      climateData: freezed == climateData
          ? _value.climateData
          : climateData // ignore: cast_nullable_to_non_nullable
              as ClimateData?,
      syncStatus: freezed == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createError: freezed == createError
          ? _value.createError
          : createError // ignore: cast_nullable_to_non_nullable
              as String?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonalAIStateImpl implements _SeasonalAIState {
  const _$SeasonalAIStateImpl(
      {this.isLoadingPredictions = false,
      this.isLoadingCareAdjustments = false,
      this.isLoadingEnvironmentalData = false,
      this.isLoadingClimateData = false,
      this.isLoadingRiskFactors = false,
      this.isLoadingTransitions = false,
      this.isLoadingGrowthForecasts = false,
      this.isLoadingWeatherForecast = false,
      this.isCreating = false,
      this.isSyncing = false,
      final List<SeasonalPrediction> seasonalPredictions = const [],
      final List<CareAdjustment> careAdjustments = const [],
      this.currentEnvironmentalData,
      final List<RiskFactor> riskFactors = const [],
      final List<SeasonalTransition> seasonalTransitions = const [],
      this.currentSeasonalTransition,
      final List<GrowthForecast> growthForecasts = const [],
      this.weatherForecast,
      final List<EnvironmentalData> environmentalForecast = const [],
      this.climateData,
      this.syncStatus,
      this.error,
      this.createError,
      this.syncError,
      this.lastUpdated})
      : _seasonalPredictions = seasonalPredictions,
        _careAdjustments = careAdjustments,
        _riskFactors = riskFactors,
        _seasonalTransitions = seasonalTransitions,
        _growthForecasts = growthForecasts,
        _environmentalForecast = environmentalForecast;

  factory _$SeasonalAIStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonalAIStateImplFromJson(json);

// Loading states
  @override
  @JsonKey()
  final bool isLoadingPredictions;
  @override
  @JsonKey()
  final bool isLoadingCareAdjustments;
  @override
  @JsonKey()
  final bool isLoadingEnvironmentalData;
  @override
  @JsonKey()
  final bool isLoadingClimateData;
  @override
  @JsonKey()
  final bool isLoadingRiskFactors;
  @override
  @JsonKey()
  final bool isLoadingTransitions;
  @override
  @JsonKey()
  final bool isLoadingGrowthForecasts;
  @override
  @JsonKey()
  final bool isLoadingWeatherForecast;
  @override
  @JsonKey()
  final bool isCreating;
  @override
  @JsonKey()
  final bool isSyncing;
// Data fields
  final List<SeasonalPrediction> _seasonalPredictions;
// Data fields
  @override
  @JsonKey()
  List<SeasonalPrediction> get seasonalPredictions {
    if (_seasonalPredictions is EqualUnmodifiableListView)
      return _seasonalPredictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasonalPredictions);
  }

  final List<CareAdjustment> _careAdjustments;
  @override
  @JsonKey()
  List<CareAdjustment> get careAdjustments {
    if (_careAdjustments is EqualUnmodifiableListView) return _careAdjustments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_careAdjustments);
  }

  @override
  final EnvironmentalData? currentEnvironmentalData;
  final List<RiskFactor> _riskFactors;
  @override
  @JsonKey()
  List<RiskFactor> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  final List<SeasonalTransition> _seasonalTransitions;
  @override
  @JsonKey()
  List<SeasonalTransition> get seasonalTransitions {
    if (_seasonalTransitions is EqualUnmodifiableListView)
      return _seasonalTransitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasonalTransitions);
  }

  @override
  final SeasonalTransition? currentSeasonalTransition;
  final List<GrowthForecast> _growthForecasts;
  @override
  @JsonKey()
  List<GrowthForecast> get growthForecasts {
    if (_growthForecasts is EqualUnmodifiableListView) return _growthForecasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_growthForecasts);
  }

  @override
  final WeatherForecast? weatherForecast;
  final List<EnvironmentalData> _environmentalForecast;
  @override
  @JsonKey()
  List<EnvironmentalData> get environmentalForecast {
    if (_environmentalForecast is EqualUnmodifiableListView)
      return _environmentalForecast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_environmentalForecast);
  }

  @override
  final ClimateData? climateData;
// Status and error fields
  @override
  final String? syncStatus;
  @override
  final String? error;
  @override
  final String? createError;
  @override
  final String? syncError;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'SeasonalAIState(isLoadingPredictions: $isLoadingPredictions, isLoadingCareAdjustments: $isLoadingCareAdjustments, isLoadingEnvironmentalData: $isLoadingEnvironmentalData, isLoadingClimateData: $isLoadingClimateData, isLoadingRiskFactors: $isLoadingRiskFactors, isLoadingTransitions: $isLoadingTransitions, isLoadingGrowthForecasts: $isLoadingGrowthForecasts, isLoadingWeatherForecast: $isLoadingWeatherForecast, isCreating: $isCreating, isSyncing: $isSyncing, seasonalPredictions: $seasonalPredictions, careAdjustments: $careAdjustments, currentEnvironmentalData: $currentEnvironmentalData, riskFactors: $riskFactors, seasonalTransitions: $seasonalTransitions, currentSeasonalTransition: $currentSeasonalTransition, growthForecasts: $growthForecasts, weatherForecast: $weatherForecast, environmentalForecast: $environmentalForecast, climateData: $climateData, syncStatus: $syncStatus, error: $error, createError: $createError, syncError: $syncError, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonalAIStateImpl &&
            (identical(other.isLoadingPredictions, isLoadingPredictions) ||
                other.isLoadingPredictions == isLoadingPredictions) &&
            (identical(other.isLoadingCareAdjustments, isLoadingCareAdjustments) ||
                other.isLoadingCareAdjustments == isLoadingCareAdjustments) &&
            (identical(other.isLoadingEnvironmentalData, isLoadingEnvironmentalData) ||
                other.isLoadingEnvironmentalData ==
                    isLoadingEnvironmentalData) &&
            (identical(other.isLoadingClimateData, isLoadingClimateData) ||
                other.isLoadingClimateData == isLoadingClimateData) &&
            (identical(other.isLoadingRiskFactors, isLoadingRiskFactors) ||
                other.isLoadingRiskFactors == isLoadingRiskFactors) &&
            (identical(other.isLoadingTransitions, isLoadingTransitions) ||
                other.isLoadingTransitions == isLoadingTransitions) &&
            (identical(other.isLoadingGrowthForecasts, isLoadingGrowthForecasts) ||
                other.isLoadingGrowthForecasts == isLoadingGrowthForecasts) &&
            (identical(other.isLoadingWeatherForecast, isLoadingWeatherForecast) ||
                other.isLoadingWeatherForecast == isLoadingWeatherForecast) &&
            (identical(other.isCreating, isCreating) ||
                other.isCreating == isCreating) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            const DeepCollectionEquality()
                .equals(other._seasonalPredictions, _seasonalPredictions) &&
            const DeepCollectionEquality()
                .equals(other._careAdjustments, _careAdjustments) &&
            (identical(other.currentEnvironmentalData, currentEnvironmentalData) ||
                other.currentEnvironmentalData == currentEnvironmentalData) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            const DeepCollectionEquality()
                .equals(other._seasonalTransitions, _seasonalTransitions) &&
            (identical(other.currentSeasonalTransition, currentSeasonalTransition) ||
                other.currentSeasonalTransition == currentSeasonalTransition) &&
            const DeepCollectionEquality()
                .equals(other._growthForecasts, _growthForecasts) &&
            (identical(other.weatherForecast, weatherForecast) ||
                other.weatherForecast == weatherForecast) &&
            const DeepCollectionEquality()
                .equals(other._environmentalForecast, _environmentalForecast) &&
            (identical(other.climateData, climateData) ||
                other.climateData == climateData) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createError, createError) ||
                other.createError == createError) &&
            (identical(other.syncError, syncError) || other.syncError == syncError) &&
            (identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoadingPredictions,
        isLoadingCareAdjustments,
        isLoadingEnvironmentalData,
        isLoadingClimateData,
        isLoadingRiskFactors,
        isLoadingTransitions,
        isLoadingGrowthForecasts,
        isLoadingWeatherForecast,
        isCreating,
        isSyncing,
        const DeepCollectionEquality().hash(_seasonalPredictions),
        const DeepCollectionEquality().hash(_careAdjustments),
        currentEnvironmentalData,
        const DeepCollectionEquality().hash(_riskFactors),
        const DeepCollectionEquality().hash(_seasonalTransitions),
        currentSeasonalTransition,
        const DeepCollectionEquality().hash(_growthForecasts),
        weatherForecast,
        const DeepCollectionEquality().hash(_environmentalForecast),
        climateData,
        syncStatus,
        error,
        createError,
        syncError,
        lastUpdated
      ]);

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonalAIStateImplCopyWith<_$SeasonalAIStateImpl> get copyWith =>
      __$$SeasonalAIStateImplCopyWithImpl<_$SeasonalAIStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonalAIStateImplToJson(
      this,
    );
  }
}

abstract class _SeasonalAIState implements SeasonalAIState {
  const factory _SeasonalAIState(
      {final bool isLoadingPredictions,
      final bool isLoadingCareAdjustments,
      final bool isLoadingEnvironmentalData,
      final bool isLoadingClimateData,
      final bool isLoadingRiskFactors,
      final bool isLoadingTransitions,
      final bool isLoadingGrowthForecasts,
      final bool isLoadingWeatherForecast,
      final bool isCreating,
      final bool isSyncing,
      final List<SeasonalPrediction> seasonalPredictions,
      final List<CareAdjustment> careAdjustments,
      final EnvironmentalData? currentEnvironmentalData,
      final List<RiskFactor> riskFactors,
      final List<SeasonalTransition> seasonalTransitions,
      final SeasonalTransition? currentSeasonalTransition,
      final List<GrowthForecast> growthForecasts,
      final WeatherForecast? weatherForecast,
      final List<EnvironmentalData> environmentalForecast,
      final ClimateData? climateData,
      final String? syncStatus,
      final String? error,
      final String? createError,
      final String? syncError,
      final DateTime? lastUpdated}) = _$SeasonalAIStateImpl;

  factory _SeasonalAIState.fromJson(Map<String, dynamic> json) =
      _$SeasonalAIStateImpl.fromJson;

// Loading states
  @override
  bool get isLoadingPredictions;
  @override
  bool get isLoadingCareAdjustments;
  @override
  bool get isLoadingEnvironmentalData;
  @override
  bool get isLoadingClimateData;
  @override
  bool get isLoadingRiskFactors;
  @override
  bool get isLoadingTransitions;
  @override
  bool get isLoadingGrowthForecasts;
  @override
  bool get isLoadingWeatherForecast;
  @override
  bool get isCreating;
  @override
  bool get isSyncing; // Data fields
  @override
  List<SeasonalPrediction> get seasonalPredictions;
  @override
  List<CareAdjustment> get careAdjustments;
  @override
  EnvironmentalData? get currentEnvironmentalData;
  @override
  List<RiskFactor> get riskFactors;
  @override
  List<SeasonalTransition> get seasonalTransitions;
  @override
  SeasonalTransition? get currentSeasonalTransition;
  @override
  List<GrowthForecast> get growthForecasts;
  @override
  WeatherForecast? get weatherForecast;
  @override
  List<EnvironmentalData> get environmentalForecast;
  @override
  ClimateData? get climateData; // Status and error fields
  @override
  String? get syncStatus;
  @override
  String? get error;
  @override
  String? get createError;
  @override
  String? get syncError;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of SeasonalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonalAIStateImplCopyWith<_$SeasonalAIStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
