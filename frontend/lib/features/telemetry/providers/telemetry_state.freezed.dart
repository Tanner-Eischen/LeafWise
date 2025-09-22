// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TelemetryState _$TelemetryStateFromJson(Map<String, dynamic> json) {
  return _TelemetryState.fromJson(json);
}

/// @nodoc
mixin _$TelemetryState {
// Loading states for different operations
  bool get isLoadingData => throw _privateConstructorUsedError;
  bool get isLoadingLightReadings => throw _privateConstructorUsedError;
  bool get isLoadingGrowthPhotos => throw _privateConstructorUsedError;
  bool get isLoadingBatchData => throw _privateConstructorUsedError;
  bool get isSyncing => throw _privateConstructorUsedError;
  bool get isResolvingConflicts => throw _privateConstructorUsedError;
  bool get isCreatingLightReading => throw _privateConstructorUsedError;
  bool get isCreatingGrowthPhoto => throw _privateConstructorUsedError;
  bool get isUploadingBatch =>
      throw _privateConstructorUsedError; // Data collections
  List<TelemetryData> get telemetryData => throw _privateConstructorUsedError;
  List<LightReadingData> get lightReadings =>
      throw _privateConstructorUsedError;
  List<GrowthPhotoData> get growthPhotos => throw _privateConstructorUsedError;
  List<TelemetryBatchData> get batchData => throw _privateConstructorUsedError;
  List<TelemetrySyncStatus> get syncStatuses =>
      throw _privateConstructorUsedError; // Sync and offline state
  TelemetrySyncStatus? get currentSyncStatus =>
      throw _privateConstructorUsedError;
  bool get isOfflineMode => throw _privateConstructorUsedError;
  int get pendingSyncCount => throw _privateConstructorUsedError;
  int get failedSyncCount => throw _privateConstructorUsedError;
  int get conflictCount => throw _privateConstructorUsedError;
  DateTime? get lastSyncAttempt => throw _privateConstructorUsedError;
  DateTime? get lastSuccessfulSync =>
      throw _privateConstructorUsedError; // Current operation tracking
  TelemetryOperationType? get currentOperation =>
      throw _privateConstructorUsedError;
  String? get currentOperationId => throw _privateConstructorUsedError;
  double? get operationProgress =>
      throw _privateConstructorUsedError; // Filtering and pagination
  TelemetryDataFilter get activeFilter => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get hasMoreData => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError; // Error states
  String? get error => throw _privateConstructorUsedError;
  String? get syncError => throw _privateConstructorUsedError;
  String? get createError => throw _privateConstructorUsedError;
  String? get uploadError => throw _privateConstructorUsedError;
  String? get conflictError => throw _privateConstructorUsedError;
  Map<String, String>? get fieldErrors =>
      throw _privateConstructorUsedError; // Session and metadata
  String? get currentSessionId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get sessionMetadata =>
      throw _privateConstructorUsedError;
  DateTime? get sessionStartedAt =>
      throw _privateConstructorUsedError; // Timestamps
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  DateTime? get lastDataRefresh => throw _privateConstructorUsedError;

  /// Serializes this TelemetryState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetryStateCopyWith<TelemetryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetryStateCopyWith<$Res> {
  factory $TelemetryStateCopyWith(
          TelemetryState value, $Res Function(TelemetryState) then) =
      _$TelemetryStateCopyWithImpl<$Res, TelemetryState>;
  @useResult
  $Res call(
      {bool isLoadingData,
      bool isLoadingLightReadings,
      bool isLoadingGrowthPhotos,
      bool isLoadingBatchData,
      bool isSyncing,
      bool isResolvingConflicts,
      bool isCreatingLightReading,
      bool isCreatingGrowthPhoto,
      bool isUploadingBatch,
      List<TelemetryData> telemetryData,
      List<LightReadingData> lightReadings,
      List<GrowthPhotoData> growthPhotos,
      List<TelemetryBatchData> batchData,
      List<TelemetrySyncStatus> syncStatuses,
      TelemetrySyncStatus? currentSyncStatus,
      bool isOfflineMode,
      int pendingSyncCount,
      int failedSyncCount,
      int conflictCount,
      DateTime? lastSyncAttempt,
      DateTime? lastSuccessfulSync,
      TelemetryOperationType? currentOperation,
      String? currentOperationId,
      double? operationProgress,
      TelemetryDataFilter activeFilter,
      int currentPage,
      bool hasMoreData,
      int pageSize,
      String? error,
      String? syncError,
      String? createError,
      String? uploadError,
      String? conflictError,
      Map<String, String>? fieldErrors,
      String? currentSessionId,
      Map<String, dynamic>? sessionMetadata,
      DateTime? sessionStartedAt,
      DateTime? lastUpdated,
      DateTime? lastDataRefresh});

  $TelemetrySyncStatusCopyWith<$Res>? get currentSyncStatus;
}

/// @nodoc
class _$TelemetryStateCopyWithImpl<$Res, $Val extends TelemetryState>
    implements $TelemetryStateCopyWith<$Res> {
  _$TelemetryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingData = null,
    Object? isLoadingLightReadings = null,
    Object? isLoadingGrowthPhotos = null,
    Object? isLoadingBatchData = null,
    Object? isSyncing = null,
    Object? isResolvingConflicts = null,
    Object? isCreatingLightReading = null,
    Object? isCreatingGrowthPhoto = null,
    Object? isUploadingBatch = null,
    Object? telemetryData = null,
    Object? lightReadings = null,
    Object? growthPhotos = null,
    Object? batchData = null,
    Object? syncStatuses = null,
    Object? currentSyncStatus = freezed,
    Object? isOfflineMode = null,
    Object? pendingSyncCount = null,
    Object? failedSyncCount = null,
    Object? conflictCount = null,
    Object? lastSyncAttempt = freezed,
    Object? lastSuccessfulSync = freezed,
    Object? currentOperation = freezed,
    Object? currentOperationId = freezed,
    Object? operationProgress = freezed,
    Object? activeFilter = null,
    Object? currentPage = null,
    Object? hasMoreData = null,
    Object? pageSize = null,
    Object? error = freezed,
    Object? syncError = freezed,
    Object? createError = freezed,
    Object? uploadError = freezed,
    Object? conflictError = freezed,
    Object? fieldErrors = freezed,
    Object? currentSessionId = freezed,
    Object? sessionMetadata = freezed,
    Object? sessionStartedAt = freezed,
    Object? lastUpdated = freezed,
    Object? lastDataRefresh = freezed,
  }) {
    return _then(_value.copyWith(
      isLoadingData: null == isLoadingData
          ? _value.isLoadingData
          : isLoadingData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingLightReadings: null == isLoadingLightReadings
          ? _value.isLoadingLightReadings
          : isLoadingLightReadings // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingGrowthPhotos: null == isLoadingGrowthPhotos
          ? _value.isLoadingGrowthPhotos
          : isLoadingGrowthPhotos // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingBatchData: null == isLoadingBatchData
          ? _value.isLoadingBatchData
          : isLoadingBatchData // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      isResolvingConflicts: null == isResolvingConflicts
          ? _value.isResolvingConflicts
          : isResolvingConflicts // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreatingLightReading: null == isCreatingLightReading
          ? _value.isCreatingLightReading
          : isCreatingLightReading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreatingGrowthPhoto: null == isCreatingGrowthPhoto
          ? _value.isCreatingGrowthPhoto
          : isCreatingGrowthPhoto // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploadingBatch: null == isUploadingBatch
          ? _value.isUploadingBatch
          : isUploadingBatch // ignore: cast_nullable_to_non_nullable
              as bool,
      telemetryData: null == telemetryData
          ? _value.telemetryData
          : telemetryData // ignore: cast_nullable_to_non_nullable
              as List<TelemetryData>,
      lightReadings: null == lightReadings
          ? _value.lightReadings
          : lightReadings // ignore: cast_nullable_to_non_nullable
              as List<LightReadingData>,
      growthPhotos: null == growthPhotos
          ? _value.growthPhotos
          : growthPhotos // ignore: cast_nullable_to_non_nullable
              as List<GrowthPhotoData>,
      batchData: null == batchData
          ? _value.batchData
          : batchData // ignore: cast_nullable_to_non_nullable
              as List<TelemetryBatchData>,
      syncStatuses: null == syncStatuses
          ? _value.syncStatuses
          : syncStatuses // ignore: cast_nullable_to_non_nullable
              as List<TelemetrySyncStatus>,
      currentSyncStatus: freezed == currentSyncStatus
          ? _value.currentSyncStatus
          : currentSyncStatus // ignore: cast_nullable_to_non_nullable
              as TelemetrySyncStatus?,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingSyncCount: null == pendingSyncCount
          ? _value.pendingSyncCount
          : pendingSyncCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedSyncCount: null == failedSyncCount
          ? _value.failedSyncCount
          : failedSyncCount // ignore: cast_nullable_to_non_nullable
              as int,
      conflictCount: null == conflictCount
          ? _value.conflictCount
          : conflictCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessfulSync: freezed == lastSuccessfulSync
          ? _value.lastSuccessfulSync
          : lastSuccessfulSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentOperation: freezed == currentOperation
          ? _value.currentOperation
          : currentOperation // ignore: cast_nullable_to_non_nullable
              as TelemetryOperationType?,
      currentOperationId: freezed == currentOperationId
          ? _value.currentOperationId
          : currentOperationId // ignore: cast_nullable_to_non_nullable
              as String?,
      operationProgress: freezed == operationProgress
          ? _value.operationProgress
          : operationProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      activeFilter: null == activeFilter
          ? _value.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as TelemetryDataFilter,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreData: null == hasMoreData
          ? _value.hasMoreData
          : hasMoreData // ignore: cast_nullable_to_non_nullable
              as bool,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      createError: freezed == createError
          ? _value.createError
          : createError // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadError: freezed == uploadError
          ? _value.uploadError
          : uploadError // ignore: cast_nullable_to_non_nullable
              as String?,
      conflictError: freezed == conflictError
          ? _value.conflictError
          : conflictError // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldErrors: freezed == fieldErrors
          ? _value.fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      currentSessionId: freezed == currentSessionId
          ? _value.currentSessionId
          : currentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionMetadata: freezed == sessionMetadata
          ? _value.sessionMetadata
          : sessionMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sessionStartedAt: freezed == sessionStartedAt
          ? _value.sessionStartedAt
          : sessionStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastDataRefresh: freezed == lastDataRefresh
          ? _value.lastDataRefresh
          : lastDataRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TelemetrySyncStatusCopyWith<$Res>? get currentSyncStatus {
    if (_value.currentSyncStatus == null) {
      return null;
    }

    return $TelemetrySyncStatusCopyWith<$Res>(_value.currentSyncStatus!,
        (value) {
      return _then(_value.copyWith(currentSyncStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TelemetryStateImplCopyWith<$Res>
    implements $TelemetryStateCopyWith<$Res> {
  factory _$$TelemetryStateImplCopyWith(_$TelemetryStateImpl value,
          $Res Function(_$TelemetryStateImpl) then) =
      __$$TelemetryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoadingData,
      bool isLoadingLightReadings,
      bool isLoadingGrowthPhotos,
      bool isLoadingBatchData,
      bool isSyncing,
      bool isResolvingConflicts,
      bool isCreatingLightReading,
      bool isCreatingGrowthPhoto,
      bool isUploadingBatch,
      List<TelemetryData> telemetryData,
      List<LightReadingData> lightReadings,
      List<GrowthPhotoData> growthPhotos,
      List<TelemetryBatchData> batchData,
      List<TelemetrySyncStatus> syncStatuses,
      TelemetrySyncStatus? currentSyncStatus,
      bool isOfflineMode,
      int pendingSyncCount,
      int failedSyncCount,
      int conflictCount,
      DateTime? lastSyncAttempt,
      DateTime? lastSuccessfulSync,
      TelemetryOperationType? currentOperation,
      String? currentOperationId,
      double? operationProgress,
      TelemetryDataFilter activeFilter,
      int currentPage,
      bool hasMoreData,
      int pageSize,
      String? error,
      String? syncError,
      String? createError,
      String? uploadError,
      String? conflictError,
      Map<String, String>? fieldErrors,
      String? currentSessionId,
      Map<String, dynamic>? sessionMetadata,
      DateTime? sessionStartedAt,
      DateTime? lastUpdated,
      DateTime? lastDataRefresh});

  @override
  $TelemetrySyncStatusCopyWith<$Res>? get currentSyncStatus;
}

/// @nodoc
class __$$TelemetryStateImplCopyWithImpl<$Res>
    extends _$TelemetryStateCopyWithImpl<$Res, _$TelemetryStateImpl>
    implements _$$TelemetryStateImplCopyWith<$Res> {
  __$$TelemetryStateImplCopyWithImpl(
      _$TelemetryStateImpl _value, $Res Function(_$TelemetryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoadingData = null,
    Object? isLoadingLightReadings = null,
    Object? isLoadingGrowthPhotos = null,
    Object? isLoadingBatchData = null,
    Object? isSyncing = null,
    Object? isResolvingConflicts = null,
    Object? isCreatingLightReading = null,
    Object? isCreatingGrowthPhoto = null,
    Object? isUploadingBatch = null,
    Object? telemetryData = null,
    Object? lightReadings = null,
    Object? growthPhotos = null,
    Object? batchData = null,
    Object? syncStatuses = null,
    Object? currentSyncStatus = freezed,
    Object? isOfflineMode = null,
    Object? pendingSyncCount = null,
    Object? failedSyncCount = null,
    Object? conflictCount = null,
    Object? lastSyncAttempt = freezed,
    Object? lastSuccessfulSync = freezed,
    Object? currentOperation = freezed,
    Object? currentOperationId = freezed,
    Object? operationProgress = freezed,
    Object? activeFilter = null,
    Object? currentPage = null,
    Object? hasMoreData = null,
    Object? pageSize = null,
    Object? error = freezed,
    Object? syncError = freezed,
    Object? createError = freezed,
    Object? uploadError = freezed,
    Object? conflictError = freezed,
    Object? fieldErrors = freezed,
    Object? currentSessionId = freezed,
    Object? sessionMetadata = freezed,
    Object? sessionStartedAt = freezed,
    Object? lastUpdated = freezed,
    Object? lastDataRefresh = freezed,
  }) {
    return _then(_$TelemetryStateImpl(
      isLoadingData: null == isLoadingData
          ? _value.isLoadingData
          : isLoadingData // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingLightReadings: null == isLoadingLightReadings
          ? _value.isLoadingLightReadings
          : isLoadingLightReadings // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingGrowthPhotos: null == isLoadingGrowthPhotos
          ? _value.isLoadingGrowthPhotos
          : isLoadingGrowthPhotos // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingBatchData: null == isLoadingBatchData
          ? _value.isLoadingBatchData
          : isLoadingBatchData // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      isResolvingConflicts: null == isResolvingConflicts
          ? _value.isResolvingConflicts
          : isResolvingConflicts // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreatingLightReading: null == isCreatingLightReading
          ? _value.isCreatingLightReading
          : isCreatingLightReading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreatingGrowthPhoto: null == isCreatingGrowthPhoto
          ? _value.isCreatingGrowthPhoto
          : isCreatingGrowthPhoto // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploadingBatch: null == isUploadingBatch
          ? _value.isUploadingBatch
          : isUploadingBatch // ignore: cast_nullable_to_non_nullable
              as bool,
      telemetryData: null == telemetryData
          ? _value._telemetryData
          : telemetryData // ignore: cast_nullable_to_non_nullable
              as List<TelemetryData>,
      lightReadings: null == lightReadings
          ? _value._lightReadings
          : lightReadings // ignore: cast_nullable_to_non_nullable
              as List<LightReadingData>,
      growthPhotos: null == growthPhotos
          ? _value._growthPhotos
          : growthPhotos // ignore: cast_nullable_to_non_nullable
              as List<GrowthPhotoData>,
      batchData: null == batchData
          ? _value._batchData
          : batchData // ignore: cast_nullable_to_non_nullable
              as List<TelemetryBatchData>,
      syncStatuses: null == syncStatuses
          ? _value._syncStatuses
          : syncStatuses // ignore: cast_nullable_to_non_nullable
              as List<TelemetrySyncStatus>,
      currentSyncStatus: freezed == currentSyncStatus
          ? _value.currentSyncStatus
          : currentSyncStatus // ignore: cast_nullable_to_non_nullable
              as TelemetrySyncStatus?,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingSyncCount: null == pendingSyncCount
          ? _value.pendingSyncCount
          : pendingSyncCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedSyncCount: null == failedSyncCount
          ? _value.failedSyncCount
          : failedSyncCount // ignore: cast_nullable_to_non_nullable
              as int,
      conflictCount: null == conflictCount
          ? _value.conflictCount
          : conflictCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessfulSync: freezed == lastSuccessfulSync
          ? _value.lastSuccessfulSync
          : lastSuccessfulSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentOperation: freezed == currentOperation
          ? _value.currentOperation
          : currentOperation // ignore: cast_nullable_to_non_nullable
              as TelemetryOperationType?,
      currentOperationId: freezed == currentOperationId
          ? _value.currentOperationId
          : currentOperationId // ignore: cast_nullable_to_non_nullable
              as String?,
      operationProgress: freezed == operationProgress
          ? _value.operationProgress
          : operationProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      activeFilter: null == activeFilter
          ? _value.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as TelemetryDataFilter,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreData: null == hasMoreData
          ? _value.hasMoreData
          : hasMoreData // ignore: cast_nullable_to_non_nullable
              as bool,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      syncError: freezed == syncError
          ? _value.syncError
          : syncError // ignore: cast_nullable_to_non_nullable
              as String?,
      createError: freezed == createError
          ? _value.createError
          : createError // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadError: freezed == uploadError
          ? _value.uploadError
          : uploadError // ignore: cast_nullable_to_non_nullable
              as String?,
      conflictError: freezed == conflictError
          ? _value.conflictError
          : conflictError // ignore: cast_nullable_to_non_nullable
              as String?,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      currentSessionId: freezed == currentSessionId
          ? _value.currentSessionId
          : currentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionMetadata: freezed == sessionMetadata
          ? _value._sessionMetadata
          : sessionMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sessionStartedAt: freezed == sessionStartedAt
          ? _value.sessionStartedAt
          : sessionStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastDataRefresh: freezed == lastDataRefresh
          ? _value.lastDataRefresh
          : lastDataRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryStateImpl extends _TelemetryState {
  const _$TelemetryStateImpl(
      {this.isLoadingData = false,
      this.isLoadingLightReadings = false,
      this.isLoadingGrowthPhotos = false,
      this.isLoadingBatchData = false,
      this.isSyncing = false,
      this.isResolvingConflicts = false,
      this.isCreatingLightReading = false,
      this.isCreatingGrowthPhoto = false,
      this.isUploadingBatch = false,
      final List<TelemetryData> telemetryData = const <TelemetryData>[],
      final List<LightReadingData> lightReadings = const <LightReadingData>[],
      final List<GrowthPhotoData> growthPhotos = const <GrowthPhotoData>[],
      final List<TelemetryBatchData> batchData = const <TelemetryBatchData>[],
      final List<TelemetrySyncStatus> syncStatuses =
          const <TelemetrySyncStatus>[],
      this.currentSyncStatus,
      this.isOfflineMode = false,
      this.pendingSyncCount = 0,
      this.failedSyncCount = 0,
      this.conflictCount = 0,
      this.lastSyncAttempt,
      this.lastSuccessfulSync,
      this.currentOperation,
      this.currentOperationId,
      this.operationProgress,
      this.activeFilter = TelemetryDataFilter.all,
      this.currentPage = 1,
      this.hasMoreData = false,
      this.pageSize = 20,
      this.error,
      this.syncError,
      this.createError,
      this.uploadError,
      this.conflictError,
      final Map<String, String>? fieldErrors,
      this.currentSessionId,
      final Map<String, dynamic>? sessionMetadata,
      this.sessionStartedAt,
      this.lastUpdated,
      this.lastDataRefresh})
      : _telemetryData = telemetryData,
        _lightReadings = lightReadings,
        _growthPhotos = growthPhotos,
        _batchData = batchData,
        _syncStatuses = syncStatuses,
        _fieldErrors = fieldErrors,
        _sessionMetadata = sessionMetadata,
        super._();

  factory _$TelemetryStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryStateImplFromJson(json);

// Loading states for different operations
  @override
  @JsonKey()
  final bool isLoadingData;
  @override
  @JsonKey()
  final bool isLoadingLightReadings;
  @override
  @JsonKey()
  final bool isLoadingGrowthPhotos;
  @override
  @JsonKey()
  final bool isLoadingBatchData;
  @override
  @JsonKey()
  final bool isSyncing;
  @override
  @JsonKey()
  final bool isResolvingConflicts;
  @override
  @JsonKey()
  final bool isCreatingLightReading;
  @override
  @JsonKey()
  final bool isCreatingGrowthPhoto;
  @override
  @JsonKey()
  final bool isUploadingBatch;
// Data collections
  final List<TelemetryData> _telemetryData;
// Data collections
  @override
  @JsonKey()
  List<TelemetryData> get telemetryData {
    if (_telemetryData is EqualUnmodifiableListView) return _telemetryData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_telemetryData);
  }

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

  final List<TelemetryBatchData> _batchData;
  @override
  @JsonKey()
  List<TelemetryBatchData> get batchData {
    if (_batchData is EqualUnmodifiableListView) return _batchData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_batchData);
  }

  final List<TelemetrySyncStatus> _syncStatuses;
  @override
  @JsonKey()
  List<TelemetrySyncStatus> get syncStatuses {
    if (_syncStatuses is EqualUnmodifiableListView) return _syncStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_syncStatuses);
  }

// Sync and offline state
  @override
  final TelemetrySyncStatus? currentSyncStatus;
  @override
  @JsonKey()
  final bool isOfflineMode;
  @override
  @JsonKey()
  final int pendingSyncCount;
  @override
  @JsonKey()
  final int failedSyncCount;
  @override
  @JsonKey()
  final int conflictCount;
  @override
  final DateTime? lastSyncAttempt;
  @override
  final DateTime? lastSuccessfulSync;
// Current operation tracking
  @override
  final TelemetryOperationType? currentOperation;
  @override
  final String? currentOperationId;
  @override
  final double? operationProgress;
// Filtering and pagination
  @override
  @JsonKey()
  final TelemetryDataFilter activeFilter;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool hasMoreData;
  @override
  @JsonKey()
  final int pageSize;
// Error states
  @override
  final String? error;
  @override
  final String? syncError;
  @override
  final String? createError;
  @override
  final String? uploadError;
  @override
  final String? conflictError;
  final Map<String, String>? _fieldErrors;
  @override
  Map<String, String>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Session and metadata
  @override
  final String? currentSessionId;
  final Map<String, dynamic>? _sessionMetadata;
  @override
  Map<String, dynamic>? get sessionMetadata {
    final value = _sessionMetadata;
    if (value == null) return null;
    if (_sessionMetadata is EqualUnmodifiableMapView) return _sessionMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? sessionStartedAt;
// Timestamps
  @override
  final DateTime? lastUpdated;
  @override
  final DateTime? lastDataRefresh;

  @override
  String toString() {
    return 'TelemetryState(isLoadingData: $isLoadingData, isLoadingLightReadings: $isLoadingLightReadings, isLoadingGrowthPhotos: $isLoadingGrowthPhotos, isLoadingBatchData: $isLoadingBatchData, isSyncing: $isSyncing, isResolvingConflicts: $isResolvingConflicts, isCreatingLightReading: $isCreatingLightReading, isCreatingGrowthPhoto: $isCreatingGrowthPhoto, isUploadingBatch: $isUploadingBatch, telemetryData: $telemetryData, lightReadings: $lightReadings, growthPhotos: $growthPhotos, batchData: $batchData, syncStatuses: $syncStatuses, currentSyncStatus: $currentSyncStatus, isOfflineMode: $isOfflineMode, pendingSyncCount: $pendingSyncCount, failedSyncCount: $failedSyncCount, conflictCount: $conflictCount, lastSyncAttempt: $lastSyncAttempt, lastSuccessfulSync: $lastSuccessfulSync, currentOperation: $currentOperation, currentOperationId: $currentOperationId, operationProgress: $operationProgress, activeFilter: $activeFilter, currentPage: $currentPage, hasMoreData: $hasMoreData, pageSize: $pageSize, error: $error, syncError: $syncError, createError: $createError, uploadError: $uploadError, conflictError: $conflictError, fieldErrors: $fieldErrors, currentSessionId: $currentSessionId, sessionMetadata: $sessionMetadata, sessionStartedAt: $sessionStartedAt, lastUpdated: $lastUpdated, lastDataRefresh: $lastDataRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryStateImpl &&
            (identical(other.isLoadingData, isLoadingData) ||
                other.isLoadingData == isLoadingData) &&
            (identical(other.isLoadingLightReadings, isLoadingLightReadings) ||
                other.isLoadingLightReadings == isLoadingLightReadings) &&
            (identical(other.isLoadingGrowthPhotos, isLoadingGrowthPhotos) ||
                other.isLoadingGrowthPhotos == isLoadingGrowthPhotos) &&
            (identical(other.isLoadingBatchData, isLoadingBatchData) ||
                other.isLoadingBatchData == isLoadingBatchData) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.isResolvingConflicts, isResolvingConflicts) ||
                other.isResolvingConflicts == isResolvingConflicts) &&
            (identical(other.isCreatingLightReading, isCreatingLightReading) ||
                other.isCreatingLightReading == isCreatingLightReading) &&
            (identical(other.isCreatingGrowthPhoto, isCreatingGrowthPhoto) ||
                other.isCreatingGrowthPhoto == isCreatingGrowthPhoto) &&
            (identical(other.isUploadingBatch, isUploadingBatch) ||
                other.isUploadingBatch == isUploadingBatch) &&
            const DeepCollectionEquality()
                .equals(other._telemetryData, _telemetryData) &&
            const DeepCollectionEquality()
                .equals(other._lightReadings, _lightReadings) &&
            const DeepCollectionEquality()
                .equals(other._growthPhotos, _growthPhotos) &&
            const DeepCollectionEquality()
                .equals(other._batchData, _batchData) &&
            const DeepCollectionEquality()
                .equals(other._syncStatuses, _syncStatuses) &&
            (identical(other.currentSyncStatus, currentSyncStatus) ||
                other.currentSyncStatus == currentSyncStatus) &&
            (identical(other.isOfflineMode, isOfflineMode) ||
                other.isOfflineMode == isOfflineMode) &&
            (identical(other.pendingSyncCount, pendingSyncCount) ||
                other.pendingSyncCount == pendingSyncCount) &&
            (identical(other.failedSyncCount, failedSyncCount) ||
                other.failedSyncCount == failedSyncCount) &&
            (identical(other.conflictCount, conflictCount) ||
                other.conflictCount == conflictCount) &&
            (identical(other.lastSyncAttempt, lastSyncAttempt) ||
                other.lastSyncAttempt == lastSyncAttempt) &&
            (identical(other.lastSuccessfulSync, lastSuccessfulSync) ||
                other.lastSuccessfulSync == lastSuccessfulSync) &&
            (identical(other.currentOperation, currentOperation) ||
                other.currentOperation == currentOperation) &&
            (identical(other.currentOperationId, currentOperationId) ||
                other.currentOperationId == currentOperationId) &&
            (identical(other.operationProgress, operationProgress) ||
                other.operationProgress == operationProgress) &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMoreData, hasMoreData) ||
                other.hasMoreData == hasMoreData) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.syncError, syncError) ||
                other.syncError == syncError) &&
            (identical(other.createError, createError) ||
                other.createError == createError) &&
            (identical(other.uploadError, uploadError) ||
                other.uploadError == uploadError) &&
            (identical(other.conflictError, conflictError) ||
                other.conflictError == conflictError) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors) &&
            (identical(other.currentSessionId, currentSessionId) ||
                other.currentSessionId == currentSessionId) &&
            const DeepCollectionEquality()
                .equals(other._sessionMetadata, _sessionMetadata) &&
            (identical(other.sessionStartedAt, sessionStartedAt) ||
                other.sessionStartedAt == sessionStartedAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.lastDataRefresh, lastDataRefresh) ||
                other.lastDataRefresh == lastDataRefresh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoadingData,
        isLoadingLightReadings,
        isLoadingGrowthPhotos,
        isLoadingBatchData,
        isSyncing,
        isResolvingConflicts,
        isCreatingLightReading,
        isCreatingGrowthPhoto,
        isUploadingBatch,
        const DeepCollectionEquality().hash(_telemetryData),
        const DeepCollectionEquality().hash(_lightReadings),
        const DeepCollectionEquality().hash(_growthPhotos),
        const DeepCollectionEquality().hash(_batchData),
        const DeepCollectionEquality().hash(_syncStatuses),
        currentSyncStatus,
        isOfflineMode,
        pendingSyncCount,
        failedSyncCount,
        conflictCount,
        lastSyncAttempt,
        lastSuccessfulSync,
        currentOperation,
        currentOperationId,
        operationProgress,
        activeFilter,
        currentPage,
        hasMoreData,
        pageSize,
        error,
        syncError,
        createError,
        uploadError,
        conflictError,
        const DeepCollectionEquality().hash(_fieldErrors),
        currentSessionId,
        const DeepCollectionEquality().hash(_sessionMetadata),
        sessionStartedAt,
        lastUpdated,
        lastDataRefresh
      ]);

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetryStateImplCopyWith<_$TelemetryStateImpl> get copyWith =>
      __$$TelemetryStateImplCopyWithImpl<_$TelemetryStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetryStateImplToJson(
      this,
    );
  }
}

abstract class _TelemetryState extends TelemetryState {
  const factory _TelemetryState(
      {final bool isLoadingData,
      final bool isLoadingLightReadings,
      final bool isLoadingGrowthPhotos,
      final bool isLoadingBatchData,
      final bool isSyncing,
      final bool isResolvingConflicts,
      final bool isCreatingLightReading,
      final bool isCreatingGrowthPhoto,
      final bool isUploadingBatch,
      final List<TelemetryData> telemetryData,
      final List<LightReadingData> lightReadings,
      final List<GrowthPhotoData> growthPhotos,
      final List<TelemetryBatchData> batchData,
      final List<TelemetrySyncStatus> syncStatuses,
      final TelemetrySyncStatus? currentSyncStatus,
      final bool isOfflineMode,
      final int pendingSyncCount,
      final int failedSyncCount,
      final int conflictCount,
      final DateTime? lastSyncAttempt,
      final DateTime? lastSuccessfulSync,
      final TelemetryOperationType? currentOperation,
      final String? currentOperationId,
      final double? operationProgress,
      final TelemetryDataFilter activeFilter,
      final int currentPage,
      final bool hasMoreData,
      final int pageSize,
      final String? error,
      final String? syncError,
      final String? createError,
      final String? uploadError,
      final String? conflictError,
      final Map<String, String>? fieldErrors,
      final String? currentSessionId,
      final Map<String, dynamic>? sessionMetadata,
      final DateTime? sessionStartedAt,
      final DateTime? lastUpdated,
      final DateTime? lastDataRefresh}) = _$TelemetryStateImpl;
  const _TelemetryState._() : super._();

  factory _TelemetryState.fromJson(Map<String, dynamic> json) =
      _$TelemetryStateImpl.fromJson;

// Loading states for different operations
  @override
  bool get isLoadingData;
  @override
  bool get isLoadingLightReadings;
  @override
  bool get isLoadingGrowthPhotos;
  @override
  bool get isLoadingBatchData;
  @override
  bool get isSyncing;
  @override
  bool get isResolvingConflicts;
  @override
  bool get isCreatingLightReading;
  @override
  bool get isCreatingGrowthPhoto;
  @override
  bool get isUploadingBatch; // Data collections
  @override
  List<TelemetryData> get telemetryData;
  @override
  List<LightReadingData> get lightReadings;
  @override
  List<GrowthPhotoData> get growthPhotos;
  @override
  List<TelemetryBatchData> get batchData;
  @override
  List<TelemetrySyncStatus> get syncStatuses; // Sync and offline state
  @override
  TelemetrySyncStatus? get currentSyncStatus;
  @override
  bool get isOfflineMode;
  @override
  int get pendingSyncCount;
  @override
  int get failedSyncCount;
  @override
  int get conflictCount;
  @override
  DateTime? get lastSyncAttempt;
  @override
  DateTime? get lastSuccessfulSync; // Current operation tracking
  @override
  TelemetryOperationType? get currentOperation;
  @override
  String? get currentOperationId;
  @override
  double? get operationProgress; // Filtering and pagination
  @override
  TelemetryDataFilter get activeFilter;
  @override
  int get currentPage;
  @override
  bool get hasMoreData;
  @override
  int get pageSize; // Error states
  @override
  String? get error;
  @override
  String? get syncError;
  @override
  String? get createError;
  @override
  String? get uploadError;
  @override
  String? get conflictError;
  @override
  Map<String, String>? get fieldErrors; // Session and metadata
  @override
  String? get currentSessionId;
  @override
  Map<String, dynamic>? get sessionMetadata;
  @override
  DateTime? get sessionStartedAt; // Timestamps
  @override
  DateTime? get lastUpdated;
  @override
  DateTime? get lastDataRefresh;

  /// Create a copy of TelemetryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryStateImplCopyWith<_$TelemetryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
