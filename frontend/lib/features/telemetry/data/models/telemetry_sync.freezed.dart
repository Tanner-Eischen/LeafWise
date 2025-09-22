// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_sync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TelemetrySyncStatus _$TelemetrySyncStatusFromJson(Map<String, dynamic> json) {
  return _TelemetrySyncStatus.fromJson(json);
}

/// @nodoc
mixin _$TelemetrySyncStatus {
  /// Unique identifier for the sync session
  String get sessionId => throw _privateConstructorUsedError;

  /// Current sync state
  SyncState get syncState => throw _privateConstructorUsedError;

  /// Progress counters
  int get totalItems => throw _privateConstructorUsedError;
  int get syncedItems => throw _privateConstructorUsedError;
  int get failedItems => throw _privateConstructorUsedError;
  int get pendingItems => throw _privateConstructorUsedError;

  /// Retry and error tracking
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  Map<String, dynamic>? get errorDetails => throw _privateConstructorUsedError;

  /// Timing information
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get lastSyncAttempt => throw _privateConstructorUsedError;
  DateTime? get nextRetryAt => throw _privateConstructorUsedError;

  /// Session metadata
  String? get userId => throw _privateConstructorUsedError;
  List<String>? get itemIds => throw _privateConstructorUsedError;
  Map<String, dynamic>? get sessionMetadata =>
      throw _privateConstructorUsedError;

  /// Timestamps
  bool get isActive => throw _privateConstructorUsedError;
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
      {String sessionId,
      SyncState syncState,
      int totalItems,
      int syncedItems,
      int failedItems,
      int pendingItems,
      int retryCount,
      int maxRetries,
      String? lastError,
      Map<String, dynamic>? errorDetails,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      String? userId,
      List<String>? itemIds,
      Map<String, dynamic>? sessionMetadata,
      bool isActive,
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
    Object? sessionId = null,
    Object? syncState = null,
    Object? totalItems = null,
    Object? syncedItems = null,
    Object? failedItems = null,
    Object? pendingItems = null,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? lastError = freezed,
    Object? errorDetails = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? userId = freezed,
    Object? itemIds = freezed,
    Object? sessionMetadata = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      syncState: null == syncState
          ? _value.syncState
          : syncState // ignore: cast_nullable_to_non_nullable
              as SyncState,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
      syncedItems: null == syncedItems
          ? _value.syncedItems
          : syncedItems // ignore: cast_nullable_to_non_nullable
              as int,
      failedItems: null == failedItems
          ? _value.failedItems
          : failedItems // ignore: cast_nullable_to_non_nullable
              as int,
      pendingItems: null == pendingItems
          ? _value.pendingItems
          : pendingItems // ignore: cast_nullable_to_non_nullable
              as int,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      errorDetails: freezed == errorDetails
          ? _value.errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: freezed == itemIds
          ? _value.itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sessionMetadata: freezed == sessionMetadata
          ? _value.sessionMetadata
          : sessionMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {String sessionId,
      SyncState syncState,
      int totalItems,
      int syncedItems,
      int failedItems,
      int pendingItems,
      int retryCount,
      int maxRetries,
      String? lastError,
      Map<String, dynamic>? errorDetails,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime? lastSyncAttempt,
      DateTime? nextRetryAt,
      String? userId,
      List<String>? itemIds,
      Map<String, dynamic>? sessionMetadata,
      bool isActive,
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
    Object? sessionId = null,
    Object? syncState = null,
    Object? totalItems = null,
    Object? syncedItems = null,
    Object? failedItems = null,
    Object? pendingItems = null,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? lastError = freezed,
    Object? errorDetails = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? lastSyncAttempt = freezed,
    Object? nextRetryAt = freezed,
    Object? userId = freezed,
    Object? itemIds = freezed,
    Object? sessionMetadata = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TelemetrySyncStatusImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      syncState: null == syncState
          ? _value.syncState
          : syncState // ignore: cast_nullable_to_non_nullable
              as SyncState,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
      syncedItems: null == syncedItems
          ? _value.syncedItems
          : syncedItems // ignore: cast_nullable_to_non_nullable
              as int,
      failedItems: null == failedItems
          ? _value.failedItems
          : failedItems // ignore: cast_nullable_to_non_nullable
              as int,
      pendingItems: null == pendingItems
          ? _value.pendingItems
          : pendingItems // ignore: cast_nullable_to_non_nullable
              as int,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      errorDetails: freezed == errorDetails
          ? _value._errorDetails
          : errorDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncAttempt: freezed == lastSyncAttempt
          ? _value.lastSyncAttempt
          : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      itemIds: freezed == itemIds
          ? _value._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sessionMetadata: freezed == sessionMetadata
          ? _value._sessionMetadata
          : sessionMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {required this.sessionId,
      this.syncState = SyncState.idle,
      this.totalItems = 0,
      this.syncedItems = 0,
      this.failedItems = 0,
      this.pendingItems = 0,
      this.retryCount = 0,
      this.maxRetries = 3,
      this.lastError,
      final Map<String, dynamic>? errorDetails,
      this.startedAt,
      this.completedAt,
      this.lastSyncAttempt,
      this.nextRetryAt,
      this.userId,
      final List<String>? itemIds,
      final Map<String, dynamic>? sessionMetadata,
      this.isActive = false,
      this.createdAt,
      this.updatedAt})
      : _errorDetails = errorDetails,
        _itemIds = itemIds,
        _sessionMetadata = sessionMetadata;

  factory _$TelemetrySyncStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetrySyncStatusImplFromJson(json);

  /// Unique identifier for the sync session
  @override
  final String sessionId;

  /// Current sync state
  @override
  @JsonKey()
  final SyncState syncState;

  /// Progress counters
  @override
  @JsonKey()
  final int totalItems;
  @override
  @JsonKey()
  final int syncedItems;
  @override
  @JsonKey()
  final int failedItems;
  @override
  @JsonKey()
  final int pendingItems;

  /// Retry and error tracking
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  final String? lastError;
  final Map<String, dynamic>? _errorDetails;
  @override
  Map<String, dynamic>? get errorDetails {
    final value = _errorDetails;
    if (value == null) return null;
    if (_errorDetails is EqualUnmodifiableMapView) return _errorDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Timing information
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? lastSyncAttempt;
  @override
  final DateTime? nextRetryAt;

  /// Session metadata
  @override
  final String? userId;
  final List<String>? _itemIds;
  @override
  List<String>? get itemIds {
    final value = _itemIds;
    if (value == null) return null;
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _sessionMetadata;
  @override
  Map<String, dynamic>? get sessionMetadata {
    final value = _sessionMetadata;
    if (value == null) return null;
    if (_sessionMetadata is EqualUnmodifiableMapView) return _sessionMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Timestamps
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TelemetrySyncStatus(sessionId: $sessionId, syncState: $syncState, totalItems: $totalItems, syncedItems: $syncedItems, failedItems: $failedItems, pendingItems: $pendingItems, retryCount: $retryCount, maxRetries: $maxRetries, lastError: $lastError, errorDetails: $errorDetails, startedAt: $startedAt, completedAt: $completedAt, lastSyncAttempt: $lastSyncAttempt, nextRetryAt: $nextRetryAt, userId: $userId, itemIds: $itemIds, sessionMetadata: $sessionMetadata, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetrySyncStatusImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.syncState, syncState) ||
                other.syncState == syncState) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            (identical(other.syncedItems, syncedItems) ||
                other.syncedItems == syncedItems) &&
            (identical(other.failedItems, failedItems) ||
                other.failedItems == failedItems) &&
            (identical(other.pendingItems, pendingItems) ||
                other.pendingItems == pendingItems) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            const DeepCollectionEquality()
                .equals(other._errorDetails, _errorDetails) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.lastSyncAttempt, lastSyncAttempt) ||
                other.lastSyncAttempt == lastSyncAttempt) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            const DeepCollectionEquality()
                .equals(other._sessionMetadata, _sessionMetadata) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        sessionId,
        syncState,
        totalItems,
        syncedItems,
        failedItems,
        pendingItems,
        retryCount,
        maxRetries,
        lastError,
        const DeepCollectionEquality().hash(_errorDetails),
        startedAt,
        completedAt,
        lastSyncAttempt,
        nextRetryAt,
        userId,
        const DeepCollectionEquality().hash(_itemIds),
        const DeepCollectionEquality().hash(_sessionMetadata),
        isActive,
        createdAt,
        updatedAt
      ]);

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
      {required final String sessionId,
      final SyncState syncState,
      final int totalItems,
      final int syncedItems,
      final int failedItems,
      final int pendingItems,
      final int retryCount,
      final int maxRetries,
      final String? lastError,
      final Map<String, dynamic>? errorDetails,
      final DateTime? startedAt,
      final DateTime? completedAt,
      final DateTime? lastSyncAttempt,
      final DateTime? nextRetryAt,
      final String? userId,
      final List<String>? itemIds,
      final Map<String, dynamic>? sessionMetadata,
      final bool isActive,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TelemetrySyncStatusImpl;

  factory _TelemetrySyncStatus.fromJson(Map<String, dynamic> json) =
      _$TelemetrySyncStatusImpl.fromJson;

  /// Unique identifier for the sync session
  @override
  String get sessionId;

  /// Current sync state
  @override
  SyncState get syncState;

  /// Progress counters
  @override
  int get totalItems;
  @override
  int get syncedItems;
  @override
  int get failedItems;
  @override
  int get pendingItems;

  /// Retry and error tracking
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get lastError;
  @override
  Map<String, dynamic>? get errorDetails;

  /// Timing information
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get lastSyncAttempt;
  @override
  DateTime? get nextRetryAt;

  /// Session metadata
  @override
  String? get userId;
  @override
  List<String>? get itemIds;
  @override
  Map<String, dynamic>? get sessionMetadata;

  /// Timestamps
  @override
  bool get isActive;
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
