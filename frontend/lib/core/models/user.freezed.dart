// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  User get user => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  bool get isFollowedBy => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  bool get hasBlockedMe => throw _privateConstructorUsedError;
  String? get friendshipStatus => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {User user,
      bool isFollowing,
      bool isFollowedBy,
      bool isBlocked,
      bool hasBlockedMe,
      String? friendshipStatus});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? isFollowing = null,
    Object? isFollowedBy = null,
    Object? isBlocked = null,
    Object? hasBlockedMe = null,
    Object? friendshipStatus = freezed,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedBy: null == isFollowedBy
          ? _value.isFollowedBy
          : isFollowedBy // ignore: cast_nullable_to_non_nullable
              as bool,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      hasBlockedMe: null == hasBlockedMe
          ? _value.hasBlockedMe
          : hasBlockedMe // ignore: cast_nullable_to_non_nullable
              as bool,
      friendshipStatus: freezed == friendshipStatus
          ? _value.friendshipStatus
          : friendshipStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User user,
      bool isFollowing,
      bool isFollowedBy,
      bool isBlocked,
      bool hasBlockedMe,
      String? friendshipStatus});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? isFollowing = null,
    Object? isFollowedBy = null,
    Object? isBlocked = null,
    Object? hasBlockedMe = null,
    Object? friendshipStatus = freezed,
  }) {
    return _then(_$UserProfileImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedBy: null == isFollowedBy
          ? _value.isFollowedBy
          : isFollowedBy // ignore: cast_nullable_to_non_nullable
              as bool,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      hasBlockedMe: null == hasBlockedMe
          ? _value.hasBlockedMe
          : hasBlockedMe // ignore: cast_nullable_to_non_nullable
              as bool,
      friendshipStatus: freezed == friendshipStatus
          ? _value.friendshipStatus
          : friendshipStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.user,
      this.isFollowing = false,
      this.isFollowedBy = false,
      this.isBlocked = false,
      this.hasBlockedMe = false,
      this.friendshipStatus});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final User user;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  @JsonKey()
  final bool isFollowedBy;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  @JsonKey()
  final bool hasBlockedMe;
  @override
  final String? friendshipStatus;

  @override
  String toString() {
    return 'UserProfile(user: $user, isFollowing: $isFollowing, isFollowedBy: $isFollowedBy, isBlocked: $isBlocked, hasBlockedMe: $hasBlockedMe, friendshipStatus: $friendshipStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollowedBy, isFollowedBy) ||
                other.isFollowedBy == isFollowedBy) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.hasBlockedMe, hasBlockedMe) ||
                other.hasBlockedMe == hasBlockedMe) &&
            (identical(other.friendshipStatus, friendshipStatus) ||
                other.friendshipStatus == friendshipStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, isFollowing, isFollowedBy,
      isBlocked, hasBlockedMe, friendshipStatus);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final User user,
      final bool isFollowing,
      final bool isFollowedBy,
      final bool isBlocked,
      final bool hasBlockedMe,
      final String? friendshipStatus}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  User get user;
  @override
  bool get isFollowing;
  @override
  bool get isFollowedBy;
  @override
  bool get isBlocked;
  @override
  bool get hasBlockedMe;
  @override
  String? get friendshipStatus;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSearchResult _$UserSearchResultFromJson(Map<String, dynamic> json) {
  return _UserSearchResult.fromJson(json);
}

/// @nodoc
mixin _$UserSearchResult {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get profilePictureUrl => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  String? get mutualFriendsCount => throw _privateConstructorUsedError;

  /// Serializes this UserSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSearchResultCopyWith<UserSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSearchResultCopyWith<$Res> {
  factory $UserSearchResultCopyWith(
          UserSearchResult value, $Res Function(UserSearchResult) then) =
      _$UserSearchResultCopyWithImpl<$Res, UserSearchResult>;
  @useResult
  $Res call(
      {String id,
      String username,
      String? fullName,
      String? profilePictureUrl,
      bool isVerified,
      bool isFollowing,
      String? mutualFriendsCount});
}

/// @nodoc
class _$UserSearchResultCopyWithImpl<$Res, $Val extends UserSearchResult>
    implements $UserSearchResultCopyWith<$Res> {
  _$UserSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? fullName = freezed,
    Object? profilePictureUrl = freezed,
    Object? isVerified = null,
    Object? isFollowing = null,
    Object? mutualFriendsCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      mutualFriendsCount: freezed == mutualFriendsCount
          ? _value.mutualFriendsCount
          : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSearchResultImplCopyWith<$Res>
    implements $UserSearchResultCopyWith<$Res> {
  factory _$$UserSearchResultImplCopyWith(_$UserSearchResultImpl value,
          $Res Function(_$UserSearchResultImpl) then) =
      __$$UserSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      String? fullName,
      String? profilePictureUrl,
      bool isVerified,
      bool isFollowing,
      String? mutualFriendsCount});
}

/// @nodoc
class __$$UserSearchResultImplCopyWithImpl<$Res>
    extends _$UserSearchResultCopyWithImpl<$Res, _$UserSearchResultImpl>
    implements _$$UserSearchResultImplCopyWith<$Res> {
  __$$UserSearchResultImplCopyWithImpl(_$UserSearchResultImpl _value,
      $Res Function(_$UserSearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? fullName = freezed,
    Object? profilePictureUrl = freezed,
    Object? isVerified = null,
    Object? isFollowing = null,
    Object? mutualFriendsCount = freezed,
  }) {
    return _then(_$UserSearchResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      mutualFriendsCount: freezed == mutualFriendsCount
          ? _value.mutualFriendsCount
          : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSearchResultImpl implements _UserSearchResult {
  const _$UserSearchResultImpl(
      {required this.id,
      required this.username,
      this.fullName,
      this.profilePictureUrl,
      this.isVerified = false,
      this.isFollowing = false,
      this.mutualFriendsCount});

  factory _$UserSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSearchResultImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? fullName;
  @override
  final String? profilePictureUrl;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  final String? mutualFriendsCount;

  @override
  String toString() {
    return 'UserSearchResult(id: $id, username: $username, fullName: $fullName, profilePictureUrl: $profilePictureUrl, isVerified: $isVerified, isFollowing: $isFollowing, mutualFriendsCount: $mutualFriendsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSearchResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.profilePictureUrl, profilePictureUrl) ||
                other.profilePictureUrl == profilePictureUrl) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.mutualFriendsCount, mutualFriendsCount) ||
                other.mutualFriendsCount == mutualFriendsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, fullName,
      profilePictureUrl, isVerified, isFollowing, mutualFriendsCount);

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      __$$UserSearchResultImplCopyWithImpl<_$UserSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSearchResultImplToJson(
      this,
    );
  }
}

abstract class _UserSearchResult implements UserSearchResult {
  const factory _UserSearchResult(
      {required final String id,
      required final String username,
      final String? fullName,
      final String? profilePictureUrl,
      final bool isVerified,
      final bool isFollowing,
      final String? mutualFriendsCount}) = _$UserSearchResultImpl;

  factory _UserSearchResult.fromJson(Map<String, dynamic> json) =
      _$UserSearchResultImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get fullName;
  @override
  String? get profilePictureUrl;
  @override
  bool get isVerified;
  @override
  bool get isFollowing;
  @override
  String? get mutualFriendsCount;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) {
  return _UpdateUserRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateUserRequest {
  String? get fullName => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  bool? get isPrivate => throw _privateConstructorUsedError;
  List<String>? get plantInterests => throw _privateConstructorUsedError;
  String? get experienceLevel => throw _privateConstructorUsedError;
  List<String>? get favoriteGenres => throw _privateConstructorUsedError;
  String? get gardenType => throw _privateConstructorUsedError;
  String? get climate => throw _privateConstructorUsedError;

  /// Serializes this UpdateUserRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateUserRequestCopyWith<UpdateUserRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateUserRequestCopyWith<$Res> {
  factory $UpdateUserRequestCopyWith(
          UpdateUserRequest value, $Res Function(UpdateUserRequest) then) =
      _$UpdateUserRequestCopyWithImpl<$Res, UpdateUserRequest>;
  @useResult
  $Res call(
      {String? fullName,
      String? bio,
      String? location,
      DateTime? dateOfBirth,
      bool? isPrivate,
      List<String>? plantInterests,
      String? experienceLevel,
      List<String>? favoriteGenres,
      String? gardenType,
      String? climate});
}

/// @nodoc
class _$UpdateUserRequestCopyWithImpl<$Res, $Val extends UpdateUserRequest>
    implements $UpdateUserRequestCopyWith<$Res> {
  _$UpdateUserRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? bio = freezed,
    Object? location = freezed,
    Object? dateOfBirth = freezed,
    Object? isPrivate = freezed,
    Object? plantInterests = freezed,
    Object? experienceLevel = freezed,
    Object? favoriteGenres = freezed,
    Object? gardenType = freezed,
    Object? climate = freezed,
  }) {
    return _then(_value.copyWith(
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPrivate: freezed == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool?,
      plantInterests: freezed == plantInterests
          ? _value.plantInterests
          : plantInterests // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      experienceLevel: freezed == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteGenres: freezed == favoriteGenres
          ? _value.favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      gardenType: freezed == gardenType
          ? _value.gardenType
          : gardenType // ignore: cast_nullable_to_non_nullable
              as String?,
      climate: freezed == climate
          ? _value.climate
          : climate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateUserRequestImplCopyWith<$Res>
    implements $UpdateUserRequestCopyWith<$Res> {
  factory _$$UpdateUserRequestImplCopyWith(_$UpdateUserRequestImpl value,
          $Res Function(_$UpdateUserRequestImpl) then) =
      __$$UpdateUserRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? fullName,
      String? bio,
      String? location,
      DateTime? dateOfBirth,
      bool? isPrivate,
      List<String>? plantInterests,
      String? experienceLevel,
      List<String>? favoriteGenres,
      String? gardenType,
      String? climate});
}

/// @nodoc
class __$$UpdateUserRequestImplCopyWithImpl<$Res>
    extends _$UpdateUserRequestCopyWithImpl<$Res, _$UpdateUserRequestImpl>
    implements _$$UpdateUserRequestImplCopyWith<$Res> {
  __$$UpdateUserRequestImplCopyWithImpl(_$UpdateUserRequestImpl _value,
      $Res Function(_$UpdateUserRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? bio = freezed,
    Object? location = freezed,
    Object? dateOfBirth = freezed,
    Object? isPrivate = freezed,
    Object? plantInterests = freezed,
    Object? experienceLevel = freezed,
    Object? favoriteGenres = freezed,
    Object? gardenType = freezed,
    Object? climate = freezed,
  }) {
    return _then(_$UpdateUserRequestImpl(
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPrivate: freezed == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool?,
      plantInterests: freezed == plantInterests
          ? _value._plantInterests
          : plantInterests // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      experienceLevel: freezed == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteGenres: freezed == favoriteGenres
          ? _value._favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      gardenType: freezed == gardenType
          ? _value.gardenType
          : gardenType // ignore: cast_nullable_to_non_nullable
              as String?,
      climate: freezed == climate
          ? _value.climate
          : climate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateUserRequestImpl implements _UpdateUserRequest {
  const _$UpdateUserRequestImpl(
      {this.fullName,
      this.bio,
      this.location,
      this.dateOfBirth,
      this.isPrivate,
      final List<String>? plantInterests,
      this.experienceLevel,
      final List<String>? favoriteGenres,
      this.gardenType,
      this.climate})
      : _plantInterests = plantInterests,
        _favoriteGenres = favoriteGenres;

  factory _$UpdateUserRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateUserRequestImplFromJson(json);

  @override
  final String? fullName;
  @override
  final String? bio;
  @override
  final String? location;
  @override
  final DateTime? dateOfBirth;
  @override
  final bool? isPrivate;
  final List<String>? _plantInterests;
  @override
  List<String>? get plantInterests {
    final value = _plantInterests;
    if (value == null) return null;
    if (_plantInterests is EqualUnmodifiableListView) return _plantInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? experienceLevel;
  final List<String>? _favoriteGenres;
  @override
  List<String>? get favoriteGenres {
    final value = _favoriteGenres;
    if (value == null) return null;
    if (_favoriteGenres is EqualUnmodifiableListView) return _favoriteGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? gardenType;
  @override
  final String? climate;

  @override
  String toString() {
    return 'UpdateUserRequest(fullName: $fullName, bio: $bio, location: $location, dateOfBirth: $dateOfBirth, isPrivate: $isPrivate, plantInterests: $plantInterests, experienceLevel: $experienceLevel, favoriteGenres: $favoriteGenres, gardenType: $gardenType, climate: $climate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserRequestImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            const DeepCollectionEquality()
                .equals(other._plantInterests, _plantInterests) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            const DeepCollectionEquality()
                .equals(other._favoriteGenres, _favoriteGenres) &&
            (identical(other.gardenType, gardenType) ||
                other.gardenType == gardenType) &&
            (identical(other.climate, climate) || other.climate == climate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      fullName,
      bio,
      location,
      dateOfBirth,
      isPrivate,
      const DeepCollectionEquality().hash(_plantInterests),
      experienceLevel,
      const DeepCollectionEquality().hash(_favoriteGenres),
      gardenType,
      climate);

  /// Create a copy of UpdateUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserRequestImplCopyWith<_$UpdateUserRequestImpl> get copyWith =>
      __$$UpdateUserRequestImplCopyWithImpl<_$UpdateUserRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateUserRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateUserRequest implements UpdateUserRequest {
  const factory _UpdateUserRequest(
      {final String? fullName,
      final String? bio,
      final String? location,
      final DateTime? dateOfBirth,
      final bool? isPrivate,
      final List<String>? plantInterests,
      final String? experienceLevel,
      final List<String>? favoriteGenres,
      final String? gardenType,
      final String? climate}) = _$UpdateUserRequestImpl;

  factory _UpdateUserRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateUserRequestImpl.fromJson;

  @override
  String? get fullName;
  @override
  String? get bio;
  @override
  String? get location;
  @override
  DateTime? get dateOfBirth;
  @override
  bool? get isPrivate;
  @override
  List<String>? get plantInterests;
  @override
  String? get experienceLevel;
  @override
  List<String>? get favoriteGenres;
  @override
  String? get gardenType;
  @override
  String? get climate;

  /// Create a copy of UpdateUserRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateUserRequestImplCopyWith<_$UpdateUserRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
