// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Friendship _$FriendshipFromJson(Map<String, dynamic> json) {
  return _Friendship.fromJson(json);
}

/// @nodoc
mixin _$Friendship {
  String get id => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String get addresseeId => throw _privateConstructorUsedError;
  FriendshipStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get blockedAt => throw _privateConstructorUsedError;
  DateTime? get declinedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get requester => throw _privateConstructorUsedError;
  User? get addressee => throw _privateConstructorUsedError;

  /// Serializes this Friendship to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipCopyWith<Friendship> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipCopyWith<$Res> {
  factory $FriendshipCopyWith(
          Friendship value, $Res Function(Friendship) then) =
      _$FriendshipCopyWithImpl<$Res, Friendship>;
  @useResult
  $Res call(
      {String id,
      String requesterId,
      String addresseeId,
      FriendshipStatus status,
      String? message,
      DateTime? acceptedAt,
      DateTime? blockedAt,
      DateTime? declinedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? requester,
      User? addressee});

  $UserCopyWith<$Res>? get requester;
  $UserCopyWith<$Res>? get addressee;
}

/// @nodoc
class _$FriendshipCopyWithImpl<$Res, $Val extends Friendship>
    implements $FriendshipCopyWith<$Res> {
  _$FriendshipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? addresseeId = null,
    Object? status = null,
    Object? message = freezed,
    Object? acceptedAt = freezed,
    Object? blockedAt = freezed,
    Object? declinedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? requester = freezed,
    Object? addressee = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterId: null == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String,
      addresseeId: null == addresseeId
          ? _value.addresseeId
          : addresseeId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockedAt: freezed == blockedAt
          ? _value.blockedAt
          : blockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      declinedAt: freezed == declinedAt
          ? _value.declinedAt
          : declinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      requester: freezed == requester
          ? _value.requester
          : requester // ignore: cast_nullable_to_non_nullable
              as User?,
      addressee: freezed == addressee
          ? _value.addressee
          : addressee // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get requester {
    if (_value.requester == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.requester!, (value) {
      return _then(_value.copyWith(requester: value) as $Val);
    });
  }

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get addressee {
    if (_value.addressee == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.addressee!, (value) {
      return _then(_value.copyWith(addressee: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FriendshipImplCopyWith<$Res>
    implements $FriendshipCopyWith<$Res> {
  factory _$$FriendshipImplCopyWith(
          _$FriendshipImpl value, $Res Function(_$FriendshipImpl) then) =
      __$$FriendshipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String requesterId,
      String addresseeId,
      FriendshipStatus status,
      String? message,
      DateTime? acceptedAt,
      DateTime? blockedAt,
      DateTime? declinedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? requester,
      User? addressee});

  @override
  $UserCopyWith<$Res>? get requester;
  @override
  $UserCopyWith<$Res>? get addressee;
}

/// @nodoc
class __$$FriendshipImplCopyWithImpl<$Res>
    extends _$FriendshipCopyWithImpl<$Res, _$FriendshipImpl>
    implements _$$FriendshipImplCopyWith<$Res> {
  __$$FriendshipImplCopyWithImpl(
      _$FriendshipImpl _value, $Res Function(_$FriendshipImpl) _then)
      : super(_value, _then);

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? addresseeId = null,
    Object? status = null,
    Object? message = freezed,
    Object? acceptedAt = freezed,
    Object? blockedAt = freezed,
    Object? declinedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? requester = freezed,
    Object? addressee = freezed,
  }) {
    return _then(_$FriendshipImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterId: null == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String,
      addresseeId: null == addresseeId
          ? _value.addresseeId
          : addresseeId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockedAt: freezed == blockedAt
          ? _value.blockedAt
          : blockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      declinedAt: freezed == declinedAt
          ? _value.declinedAt
          : declinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      requester: freezed == requester
          ? _value.requester
          : requester // ignore: cast_nullable_to_non_nullable
              as User?,
      addressee: freezed == addressee
          ? _value.addressee
          : addressee // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipImpl implements _Friendship {
  const _$FriendshipImpl(
      {required this.id,
      required this.requesterId,
      required this.addresseeId,
      this.status = FriendshipStatus.pending,
      this.message,
      this.acceptedAt,
      this.blockedAt,
      this.declinedAt,
      required this.createdAt,
      this.updatedAt,
      this.requester,
      this.addressee});

  factory _$FriendshipImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipImplFromJson(json);

  @override
  final String id;
  @override
  final String requesterId;
  @override
  final String addresseeId;
  @override
  @JsonKey()
  final FriendshipStatus status;
  @override
  final String? message;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? blockedAt;
  @override
  final DateTime? declinedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// User info (populated from join)
  @override
  final User? requester;
  @override
  final User? addressee;

  @override
  String toString() {
    return 'Friendship(id: $id, requesterId: $requesterId, addresseeId: $addresseeId, status: $status, message: $message, acceptedAt: $acceptedAt, blockedAt: $blockedAt, declinedAt: $declinedAt, createdAt: $createdAt, updatedAt: $updatedAt, requester: $requester, addressee: $addressee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.addresseeId, addresseeId) ||
                other.addresseeId == addresseeId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.blockedAt, blockedAt) ||
                other.blockedAt == blockedAt) &&
            (identical(other.declinedAt, declinedAt) ||
                other.declinedAt == declinedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.requester, requester) ||
                other.requester == requester) &&
            (identical(other.addressee, addressee) ||
                other.addressee == addressee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      requesterId,
      addresseeId,
      status,
      message,
      acceptedAt,
      blockedAt,
      declinedAt,
      createdAt,
      updatedAt,
      requester,
      addressee);

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipImplCopyWith<_$FriendshipImpl> get copyWith =>
      __$$FriendshipImplCopyWithImpl<_$FriendshipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipImplToJson(
      this,
    );
  }
}

abstract class _Friendship implements Friendship {
  const factory _Friendship(
      {required final String id,
      required final String requesterId,
      required final String addresseeId,
      final FriendshipStatus status,
      final String? message,
      final DateTime? acceptedAt,
      final DateTime? blockedAt,
      final DateTime? declinedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final User? requester,
      final User? addressee}) = _$FriendshipImpl;

  factory _Friendship.fromJson(Map<String, dynamic> json) =
      _$FriendshipImpl.fromJson;

  @override
  String get id;
  @override
  String get requesterId;
  @override
  String get addresseeId;
  @override
  FriendshipStatus get status;
  @override
  String? get message;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get blockedAt;
  @override
  DateTime? get declinedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // User info (populated from join)
  @override
  User? get requester;
  @override
  User? get addressee;

  /// Create a copy of Friendship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipImplCopyWith<_$FriendshipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) {
  return _FriendRequest.fromJson(json);
}

/// @nodoc
mixin _$FriendRequest {
  String get id => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  FriendshipStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get fromUser => throw _privateConstructorUsedError;
  User? get toUser => throw _privateConstructorUsedError;

  /// Serializes this FriendRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendRequestCopyWith<FriendRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestCopyWith<$Res> {
  factory $FriendRequestCopyWith(
          FriendRequest value, $Res Function(FriendRequest) then) =
      _$FriendRequestCopyWithImpl<$Res, FriendRequest>;
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      String? message,
      FriendshipStatus status,
      DateTime createdAt,
      User? fromUser,
      User? toUser});

  $UserCopyWith<$Res>? get fromUser;
  $UserCopyWith<$Res>? get toUser;
}

/// @nodoc
class _$FriendRequestCopyWithImpl<$Res, $Val extends FriendRequest>
    implements $FriendRequestCopyWith<$Res> {
  _$FriendRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? fromUser = freezed,
    Object? toUser = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromUser: freezed == fromUser
          ? _value.fromUser
          : fromUser // ignore: cast_nullable_to_non_nullable
              as User?,
      toUser: freezed == toUser
          ? _value.toUser
          : toUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get fromUser {
    if (_value.fromUser == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.fromUser!, (value) {
      return _then(_value.copyWith(fromUser: value) as $Val);
    });
  }

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get toUser {
    if (_value.toUser == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.toUser!, (value) {
      return _then(_value.copyWith(toUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FriendRequestImplCopyWith<$Res>
    implements $FriendRequestCopyWith<$Res> {
  factory _$$FriendRequestImplCopyWith(
          _$FriendRequestImpl value, $Res Function(_$FriendRequestImpl) then) =
      __$$FriendRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      String? message,
      FriendshipStatus status,
      DateTime createdAt,
      User? fromUser,
      User? toUser});

  @override
  $UserCopyWith<$Res>? get fromUser;
  @override
  $UserCopyWith<$Res>? get toUser;
}

/// @nodoc
class __$$FriendRequestImplCopyWithImpl<$Res>
    extends _$FriendRequestCopyWithImpl<$Res, _$FriendRequestImpl>
    implements _$$FriendRequestImplCopyWith<$Res> {
  __$$FriendRequestImplCopyWithImpl(
      _$FriendRequestImpl _value, $Res Function(_$FriendRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? fromUser = freezed,
    Object? toUser = freezed,
  }) {
    return _then(_$FriendRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromUser: freezed == fromUser
          ? _value.fromUser
          : fromUser // ignore: cast_nullable_to_non_nullable
              as User?,
      toUser: freezed == toUser
          ? _value.toUser
          : toUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendRequestImpl implements _FriendRequest {
  const _$FriendRequestImpl(
      {required this.id,
      required this.fromUserId,
      required this.toUserId,
      this.message,
      this.status = FriendshipStatus.pending,
      required this.createdAt,
      this.fromUser,
      this.toUser});

  factory _$FriendRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String fromUserId;
  @override
  final String toUserId;
  @override
  final String? message;
  @override
  @JsonKey()
  final FriendshipStatus status;
  @override
  final DateTime createdAt;
// User info (populated from join)
  @override
  final User? fromUser;
  @override
  final User? toUser;

  @override
  String toString() {
    return 'FriendRequest(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, message: $message, status: $status, createdAt: $createdAt, fromUser: $fromUser, toUser: $toUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fromUser, fromUser) ||
                other.fromUser == fromUser) &&
            (identical(other.toUser, toUser) || other.toUser == toUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fromUserId, toUserId,
      message, status, createdAt, fromUser, toUser);

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestImplCopyWith<_$FriendRequestImpl> get copyWith =>
      __$$FriendRequestImplCopyWithImpl<_$FriendRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendRequestImplToJson(
      this,
    );
  }
}

abstract class _FriendRequest implements FriendRequest {
  const factory _FriendRequest(
      {required final String id,
      required final String fromUserId,
      required final String toUserId,
      final String? message,
      final FriendshipStatus status,
      required final DateTime createdAt,
      final User? fromUser,
      final User? toUser}) = _$FriendRequestImpl;

  factory _FriendRequest.fromJson(Map<String, dynamic> json) =
      _$FriendRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get fromUserId;
  @override
  String get toUserId;
  @override
  String? get message;
  @override
  FriendshipStatus get status;
  @override
  DateTime get createdAt; // User info (populated from join)
  @override
  User? get fromUser;
  @override
  User? get toUser;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestImplCopyWith<_$FriendRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendFriendRequestRequest _$SendFriendRequestRequestFromJson(
    Map<String, dynamic> json) {
  return _SendFriendRequestRequest.fromJson(json);
}

/// @nodoc
mixin _$SendFriendRequestRequest {
  String get toUserId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this SendFriendRequestRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendFriendRequestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendFriendRequestRequestCopyWith<SendFriendRequestRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendFriendRequestRequestCopyWith<$Res> {
  factory $SendFriendRequestRequestCopyWith(SendFriendRequestRequest value,
          $Res Function(SendFriendRequestRequest) then) =
      _$SendFriendRequestRequestCopyWithImpl<$Res, SendFriendRequestRequest>;
  @useResult
  $Res call({String toUserId, String? message});
}

/// @nodoc
class _$SendFriendRequestRequestCopyWithImpl<$Res,
        $Val extends SendFriendRequestRequest>
    implements $SendFriendRequestRequestCopyWith<$Res> {
  _$SendFriendRequestRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendFriendRequestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toUserId = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SendFriendRequestRequestImplCopyWith<$Res>
    implements $SendFriendRequestRequestCopyWith<$Res> {
  factory _$$SendFriendRequestRequestImplCopyWith(
          _$SendFriendRequestRequestImpl value,
          $Res Function(_$SendFriendRequestRequestImpl) then) =
      __$$SendFriendRequestRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String toUserId, String? message});
}

/// @nodoc
class __$$SendFriendRequestRequestImplCopyWithImpl<$Res>
    extends _$SendFriendRequestRequestCopyWithImpl<$Res,
        _$SendFriendRequestRequestImpl>
    implements _$$SendFriendRequestRequestImplCopyWith<$Res> {
  __$$SendFriendRequestRequestImplCopyWithImpl(
      _$SendFriendRequestRequestImpl _value,
      $Res Function(_$SendFriendRequestRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SendFriendRequestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toUserId = null,
    Object? message = freezed,
  }) {
    return _then(_$SendFriendRequestRequestImpl(
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SendFriendRequestRequestImpl implements _SendFriendRequestRequest {
  const _$SendFriendRequestRequestImpl({required this.toUserId, this.message});

  factory _$SendFriendRequestRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendFriendRequestRequestImplFromJson(json);

  @override
  final String toUserId;
  @override
  final String? message;

  @override
  String toString() {
    return 'SendFriendRequestRequest(toUserId: $toUserId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendFriendRequestRequestImpl &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, toUserId, message);

  /// Create a copy of SendFriendRequestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendFriendRequestRequestImplCopyWith<_$SendFriendRequestRequestImpl>
      get copyWith => __$$SendFriendRequestRequestImplCopyWithImpl<
          _$SendFriendRequestRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SendFriendRequestRequestImplToJson(
      this,
    );
  }
}

abstract class _SendFriendRequestRequest implements SendFriendRequestRequest {
  const factory _SendFriendRequestRequest(
      {required final String toUserId,
      final String? message}) = _$SendFriendRequestRequestImpl;

  factory _SendFriendRequestRequest.fromJson(Map<String, dynamic> json) =
      _$SendFriendRequestRequestImpl.fromJson;

  @override
  String get toUserId;
  @override
  String? get message;

  /// Create a copy of SendFriendRequestRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendFriendRequestRequestImplCopyWith<_$SendFriendRequestRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FriendshipResponse _$FriendshipResponseFromJson(Map<String, dynamic> json) {
  return _FriendshipResponse.fromJson(json);
}

/// @nodoc
mixin _$FriendshipResponse {
  String get friendshipId => throw _privateConstructorUsedError;
  FriendshipStatus get status => throw _privateConstructorUsedError;

  /// Serializes this FriendshipResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipResponseCopyWith<FriendshipResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipResponseCopyWith<$Res> {
  factory $FriendshipResponseCopyWith(
          FriendshipResponse value, $Res Function(FriendshipResponse) then) =
      _$FriendshipResponseCopyWithImpl<$Res, FriendshipResponse>;
  @useResult
  $Res call({String friendshipId, FriendshipStatus status});
}

/// @nodoc
class _$FriendshipResponseCopyWithImpl<$Res, $Val extends FriendshipResponse>
    implements $FriendshipResponseCopyWith<$Res> {
  _$FriendshipResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendshipId = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      friendshipId: null == friendshipId
          ? _value.friendshipId
          : friendshipId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendshipResponseImplCopyWith<$Res>
    implements $FriendshipResponseCopyWith<$Res> {
  factory _$$FriendshipResponseImplCopyWith(_$FriendshipResponseImpl value,
          $Res Function(_$FriendshipResponseImpl) then) =
      __$$FriendshipResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String friendshipId, FriendshipStatus status});
}

/// @nodoc
class __$$FriendshipResponseImplCopyWithImpl<$Res>
    extends _$FriendshipResponseCopyWithImpl<$Res, _$FriendshipResponseImpl>
    implements _$$FriendshipResponseImplCopyWith<$Res> {
  __$$FriendshipResponseImplCopyWithImpl(_$FriendshipResponseImpl _value,
      $Res Function(_$FriendshipResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendshipId = null,
    Object? status = null,
  }) {
    return _then(_$FriendshipResponseImpl(
      friendshipId: null == friendshipId
          ? _value.friendshipId
          : friendshipId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendshipStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipResponseImpl implements _FriendshipResponse {
  const _$FriendshipResponseImpl(
      {required this.friendshipId, required this.status});

  factory _$FriendshipResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipResponseImplFromJson(json);

  @override
  final String friendshipId;
  @override
  final FriendshipStatus status;

  @override
  String toString() {
    return 'FriendshipResponse(friendshipId: $friendshipId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipResponseImpl &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, friendshipId, status);

  /// Create a copy of FriendshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipResponseImplCopyWith<_$FriendshipResponseImpl> get copyWith =>
      __$$FriendshipResponseImplCopyWithImpl<_$FriendshipResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipResponseImplToJson(
      this,
    );
  }
}

abstract class _FriendshipResponse implements FriendshipResponse {
  const factory _FriendshipResponse(
      {required final String friendshipId,
      required final FriendshipStatus status}) = _$FriendshipResponseImpl;

  factory _FriendshipResponse.fromJson(Map<String, dynamic> json) =
      _$FriendshipResponseImpl.fromJson;

  @override
  String get friendshipId;
  @override
  FriendshipStatus get status;

  /// Create a copy of FriendshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipResponseImplCopyWith<_$FriendshipResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FriendsList _$FriendsListFromJson(Map<String, dynamic> json) {
  return _FriendsList.fromJson(json);
}

/// @nodoc
mixin _$FriendsList {
  List<User> get friends => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;

  /// Serializes this FriendsList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendsListCopyWith<FriendsList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendsListCopyWith<$Res> {
  factory $FriendsListCopyWith(
          FriendsList value, $Res Function(FriendsList) then) =
      _$FriendsListCopyWithImpl<$Res, FriendsList>;
  @useResult
  $Res call(
      {List<User> friends, int totalCount, bool hasMore, String? nextCursor});
}

/// @nodoc
class _$FriendsListCopyWithImpl<$Res, $Val extends FriendsList>
    implements $FriendsListCopyWith<$Res> {
  _$FriendsListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? totalCount = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_value.copyWith(
      friends: null == friends
          ? _value.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<User>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendsListImplCopyWith<$Res>
    implements $FriendsListCopyWith<$Res> {
  factory _$$FriendsListImplCopyWith(
          _$FriendsListImpl value, $Res Function(_$FriendsListImpl) then) =
      __$$FriendsListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<User> friends, int totalCount, bool hasMore, String? nextCursor});
}

/// @nodoc
class __$$FriendsListImplCopyWithImpl<$Res>
    extends _$FriendsListCopyWithImpl<$Res, _$FriendsListImpl>
    implements _$$FriendsListImplCopyWith<$Res> {
  __$$FriendsListImplCopyWithImpl(
      _$FriendsListImpl _value, $Res Function(_$FriendsListImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? totalCount = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_$FriendsListImpl(
      friends: null == friends
          ? _value._friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<User>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendsListImpl implements _FriendsList {
  const _$FriendsListImpl(
      {final List<User> friends = const [],
      this.totalCount = 0,
      this.hasMore = false,
      this.nextCursor})
      : _friends = friends;

  factory _$FriendsListImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendsListImplFromJson(json);

  final List<User> _friends;
  @override
  @JsonKey()
  List<User> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'FriendsList(friends: $friends, totalCount: $totalCount, hasMore: $hasMore, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendsListImpl &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_friends),
      totalCount,
      hasMore,
      nextCursor);

  /// Create a copy of FriendsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendsListImplCopyWith<_$FriendsListImpl> get copyWith =>
      __$$FriendsListImplCopyWithImpl<_$FriendsListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendsListImplToJson(
      this,
    );
  }
}

abstract class _FriendsList implements FriendsList {
  const factory _FriendsList(
      {final List<User> friends,
      final int totalCount,
      final bool hasMore,
      final String? nextCursor}) = _$FriendsListImpl;

  factory _FriendsList.fromJson(Map<String, dynamic> json) =
      _$FriendsListImpl.fromJson;

  @override
  List<User> get friends;
  @override
  int get totalCount;
  @override
  bool get hasMore;
  @override
  String? get nextCursor;

  /// Create a copy of FriendsList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendsListImplCopyWith<_$FriendsListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FriendRequestsList _$FriendRequestsListFromJson(Map<String, dynamic> json) {
  return _FriendRequestsList.fromJson(json);
}

/// @nodoc
mixin _$FriendRequestsList {
  List<FriendRequest> get requests => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;

  /// Serializes this FriendRequestsList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendRequestsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendRequestsListCopyWith<FriendRequestsList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestsListCopyWith<$Res> {
  factory $FriendRequestsListCopyWith(
          FriendRequestsList value, $Res Function(FriendRequestsList) then) =
      _$FriendRequestsListCopyWithImpl<$Res, FriendRequestsList>;
  @useResult
  $Res call(
      {List<FriendRequest> requests,
      int totalCount,
      bool hasMore,
      String? nextCursor});
}

/// @nodoc
class _$FriendRequestsListCopyWithImpl<$Res, $Val extends FriendRequestsList>
    implements $FriendRequestsListCopyWith<$Res> {
  _$FriendRequestsListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendRequestsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? totalCount = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_value.copyWith(
      requests: null == requests
          ? _value.requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<FriendRequest>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendRequestsListImplCopyWith<$Res>
    implements $FriendRequestsListCopyWith<$Res> {
  factory _$$FriendRequestsListImplCopyWith(_$FriendRequestsListImpl value,
          $Res Function(_$FriendRequestsListImpl) then) =
      __$$FriendRequestsListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<FriendRequest> requests,
      int totalCount,
      bool hasMore,
      String? nextCursor});
}

/// @nodoc
class __$$FriendRequestsListImplCopyWithImpl<$Res>
    extends _$FriendRequestsListCopyWithImpl<$Res, _$FriendRequestsListImpl>
    implements _$$FriendRequestsListImplCopyWith<$Res> {
  __$$FriendRequestsListImplCopyWithImpl(_$FriendRequestsListImpl _value,
      $Res Function(_$FriendRequestsListImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendRequestsList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requests = null,
    Object? totalCount = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_$FriendRequestsListImpl(
      requests: null == requests
          ? _value._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<FriendRequest>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendRequestsListImpl implements _FriendRequestsList {
  const _$FriendRequestsListImpl(
      {final List<FriendRequest> requests = const [],
      this.totalCount = 0,
      this.hasMore = false,
      this.nextCursor})
      : _requests = requests;

  factory _$FriendRequestsListImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendRequestsListImplFromJson(json);

  final List<FriendRequest> _requests;
  @override
  @JsonKey()
  List<FriendRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'FriendRequestsList(requests: $requests, totalCount: $totalCount, hasMore: $hasMore, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestsListImpl &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_requests),
      totalCount,
      hasMore,
      nextCursor);

  /// Create a copy of FriendRequestsList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestsListImplCopyWith<_$FriendRequestsListImpl> get copyWith =>
      __$$FriendRequestsListImplCopyWithImpl<_$FriendRequestsListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendRequestsListImplToJson(
      this,
    );
  }
}

abstract class _FriendRequestsList implements FriendRequestsList {
  const factory _FriendRequestsList(
      {final List<FriendRequest> requests,
      final int totalCount,
      final bool hasMore,
      final String? nextCursor}) = _$FriendRequestsListImpl;

  factory _FriendRequestsList.fromJson(Map<String, dynamic> json) =
      _$FriendRequestsListImpl.fromJson;

  @override
  List<FriendRequest> get requests;
  @override
  int get totalCount;
  @override
  bool get hasMore;
  @override
  String? get nextCursor;

  /// Create a copy of FriendRequestsList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestsListImplCopyWith<_$FriendRequestsListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MutualFriends _$MutualFriendsFromJson(Map<String, dynamic> json) {
  return _MutualFriends.fromJson(json);
}

/// @nodoc
mixin _$MutualFriends {
  List<User> get friends => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this MutualFriends to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MutualFriends
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MutualFriendsCopyWith<MutualFriends> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MutualFriendsCopyWith<$Res> {
  factory $MutualFriendsCopyWith(
          MutualFriends value, $Res Function(MutualFriends) then) =
      _$MutualFriendsCopyWithImpl<$Res, MutualFriends>;
  @useResult
  $Res call({List<User> friends, int count});
}

/// @nodoc
class _$MutualFriendsCopyWithImpl<$Res, $Val extends MutualFriends>
    implements $MutualFriendsCopyWith<$Res> {
  _$MutualFriendsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MutualFriends
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      friends: null == friends
          ? _value.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<User>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MutualFriendsImplCopyWith<$Res>
    implements $MutualFriendsCopyWith<$Res> {
  factory _$$MutualFriendsImplCopyWith(
          _$MutualFriendsImpl value, $Res Function(_$MutualFriendsImpl) then) =
      __$$MutualFriendsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<User> friends, int count});
}

/// @nodoc
class __$$MutualFriendsImplCopyWithImpl<$Res>
    extends _$MutualFriendsCopyWithImpl<$Res, _$MutualFriendsImpl>
    implements _$$MutualFriendsImplCopyWith<$Res> {
  __$$MutualFriendsImplCopyWithImpl(
      _$MutualFriendsImpl _value, $Res Function(_$MutualFriendsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MutualFriends
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? count = null,
  }) {
    return _then(_$MutualFriendsImpl(
      friends: null == friends
          ? _value._friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<User>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MutualFriendsImpl implements _MutualFriends {
  const _$MutualFriendsImpl(
      {final List<User> friends = const [], this.count = 0})
      : _friends = friends;

  factory _$MutualFriendsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MutualFriendsImplFromJson(json);

  final List<User> _friends;
  @override
  @JsonKey()
  List<User> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'MutualFriends(friends: $friends, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MutualFriendsImpl &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_friends), count);

  /// Create a copy of MutualFriends
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MutualFriendsImplCopyWith<_$MutualFriendsImpl> get copyWith =>
      __$$MutualFriendsImplCopyWithImpl<_$MutualFriendsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MutualFriendsImplToJson(
      this,
    );
  }
}

abstract class _MutualFriends implements MutualFriends {
  const factory _MutualFriends({final List<User> friends, final int count}) =
      _$MutualFriendsImpl;

  factory _MutualFriends.fromJson(Map<String, dynamic> json) =
      _$MutualFriendsImpl.fromJson;

  @override
  List<User> get friends;
  @override
  int get count;

  /// Create a copy of MutualFriends
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MutualFriendsImplCopyWith<_$MutualFriendsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
