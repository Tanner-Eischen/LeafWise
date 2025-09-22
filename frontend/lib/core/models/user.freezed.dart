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

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get profilePictureUrl => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  int get followingCount => throw _privateConstructorUsedError;
  int get postsCount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Role-based access control fields
  bool get isAdmin => throw _privateConstructorUsedError;
  bool get isExpert => throw _privateConstructorUsedError;
  bool get isModerator => throw _privateConstructorUsedError;
  bool get isSuperuser => throw _privateConstructorUsedError;
  String? get adminPermissions =>
      throw _privateConstructorUsedError; // JSON string of admin permissions
  String? get expertSpecialties =>
      throw _privateConstructorUsedError; // JSON string of expert specialties
// Plant-specific fields for Phase 2
  List<String> get plantInterests => throw _privateConstructorUsedError;
  String? get experienceLevel =>
      throw _privateConstructorUsedError; // 'beginner', 'intermediate', 'expert'
  List<String> get favoriteGenres => throw _privateConstructorUsedError;
  String? get gardenType =>
      throw _privateConstructorUsedError; // 'indoor', 'outdoor', 'balcony', 'greenhouse'
  String? get climate => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String email,
      String username,
      String? displayName,
      String? bio,
      String? profilePictureUrl,
      String? location,
      DateTime? dateOfBirth,
      bool isPrivate,
      int followersCount,
      int followingCount,
      int postsCount,
      bool isActive,
      bool isVerified,
      DateTime? lastSeen,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isAdmin,
      bool isExpert,
      bool isModerator,
      bool isSuperuser,
      String? adminPermissions,
      String? expertSpecialties,
      List<String> plantInterests,
      String? experienceLevel,
      List<String> favoriteGenres,
      String? gardenType,
      String? climate});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? bio = freezed,
    Object? profilePictureUrl = freezed,
    Object? location = freezed,
    Object? dateOfBirth = freezed,
    Object? isPrivate = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? postsCount = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? lastSeen = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isAdmin = null,
    Object? isExpert = null,
    Object? isModerator = null,
    Object? isSuperuser = null,
    Object? adminPermissions = freezed,
    Object? expertSpecialties = freezed,
    Object? plantInterests = null,
    Object? experienceLevel = freezed,
    Object? favoriteGenres = null,
    Object? gardenType = freezed,
    Object? climate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isExpert: null == isExpert
          ? _value.isExpert
          : isExpert // ignore: cast_nullable_to_non_nullable
              as bool,
      isModerator: null == isModerator
          ? _value.isModerator
          : isModerator // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuperuser: null == isSuperuser
          ? _value.isSuperuser
          : isSuperuser // ignore: cast_nullable_to_non_nullable
              as bool,
      adminPermissions: freezed == adminPermissions
          ? _value.adminPermissions
          : adminPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      expertSpecialties: freezed == expertSpecialties
          ? _value.expertSpecialties
          : expertSpecialties // ignore: cast_nullable_to_non_nullable
              as String?,
      plantInterests: null == plantInterests
          ? _value.plantInterests
          : plantInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceLevel: freezed == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteGenres: null == favoriteGenres
          ? _value.favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String username,
      String? displayName,
      String? bio,
      String? profilePictureUrl,
      String? location,
      DateTime? dateOfBirth,
      bool isPrivate,
      int followersCount,
      int followingCount,
      int postsCount,
      bool isActive,
      bool isVerified,
      DateTime? lastSeen,
      DateTime createdAt,
      DateTime? updatedAt,
      bool isAdmin,
      bool isExpert,
      bool isModerator,
      bool isSuperuser,
      String? adminPermissions,
      String? expertSpecialties,
      List<String> plantInterests,
      String? experienceLevel,
      List<String> favoriteGenres,
      String? gardenType,
      String? climate});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? bio = freezed,
    Object? profilePictureUrl = freezed,
    Object? location = freezed,
    Object? dateOfBirth = freezed,
    Object? isPrivate = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? postsCount = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? lastSeen = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isAdmin = null,
    Object? isExpert = null,
    Object? isModerator = null,
    Object? isSuperuser = null,
    Object? adminPermissions = freezed,
    Object? expertSpecialties = freezed,
    Object? plantInterests = null,
    Object? experienceLevel = freezed,
    Object? favoriteGenres = null,
    Object? gardenType = freezed,
    Object? climate = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      isExpert: null == isExpert
          ? _value.isExpert
          : isExpert // ignore: cast_nullable_to_non_nullable
              as bool,
      isModerator: null == isModerator
          ? _value.isModerator
          : isModerator // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuperuser: null == isSuperuser
          ? _value.isSuperuser
          : isSuperuser // ignore: cast_nullable_to_non_nullable
              as bool,
      adminPermissions: freezed == adminPermissions
          ? _value.adminPermissions
          : adminPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      expertSpecialties: freezed == expertSpecialties
          ? _value.expertSpecialties
          : expertSpecialties // ignore: cast_nullable_to_non_nullable
              as String?,
      plantInterests: null == plantInterests
          ? _value._plantInterests
          : plantInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceLevel: freezed == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteGenres: null == favoriteGenres
          ? _value._favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.email,
      required this.username,
      this.displayName,
      this.bio,
      this.profilePictureUrl,
      this.location,
      this.dateOfBirth,
      this.isPrivate = false,
      this.followersCount = 0,
      this.followingCount = 0,
      this.postsCount = 0,
      this.isActive = true,
      this.isVerified = false,
      this.lastSeen,
      required this.createdAt,
      this.updatedAt,
      this.isAdmin = false,
      this.isExpert = false,
      this.isModerator = false,
      this.isSuperuser = false,
      this.adminPermissions,
      this.expertSpecialties,
      final List<String> plantInterests = const [],
      this.experienceLevel,
      final List<String> favoriteGenres = const [],
      this.gardenType,
      this.climate})
      : _plantInterests = plantInterests,
        _favoriteGenres = favoriteGenres;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final String? bio;
  @override
  final String? profilePictureUrl;
  @override
  final String? location;
  @override
  final DateTime? dateOfBirth;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final int followersCount;
  @override
  @JsonKey()
  final int followingCount;
  @override
  @JsonKey()
  final int postsCount;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final DateTime? lastSeen;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// Role-based access control fields
  @override
  @JsonKey()
  final bool isAdmin;
  @override
  @JsonKey()
  final bool isExpert;
  @override
  @JsonKey()
  final bool isModerator;
  @override
  @JsonKey()
  final bool isSuperuser;
  @override
  final String? adminPermissions;
// JSON string of admin permissions
  @override
  final String? expertSpecialties;
// JSON string of expert specialties
// Plant-specific fields for Phase 2
  final List<String> _plantInterests;
// JSON string of expert specialties
// Plant-specific fields for Phase 2
  @override
  @JsonKey()
  List<String> get plantInterests {
    if (_plantInterests is EqualUnmodifiableListView) return _plantInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plantInterests);
  }

  @override
  final String? experienceLevel;
// 'beginner', 'intermediate', 'expert'
  final List<String> _favoriteGenres;
// 'beginner', 'intermediate', 'expert'
  @override
  @JsonKey()
  List<String> get favoriteGenres {
    if (_favoriteGenres is EqualUnmodifiableListView) return _favoriteGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteGenres);
  }

  @override
  final String? gardenType;
// 'indoor', 'outdoor', 'balcony', 'greenhouse'
  @override
  final String? climate;

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, displayName: $displayName, bio: $bio, profilePictureUrl: $profilePictureUrl, location: $location, dateOfBirth: $dateOfBirth, isPrivate: $isPrivate, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount, isActive: $isActive, isVerified: $isVerified, lastSeen: $lastSeen, createdAt: $createdAt, updatedAt: $updatedAt, isAdmin: $isAdmin, isExpert: $isExpert, isModerator: $isModerator, isSuperuser: $isSuperuser, adminPermissions: $adminPermissions, expertSpecialties: $expertSpecialties, plantInterests: $plantInterests, experienceLevel: $experienceLevel, favoriteGenres: $favoriteGenres, gardenType: $gardenType, climate: $climate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profilePictureUrl, profilePictureUrl) ||
                other.profilePictureUrl == profilePictureUrl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.postsCount, postsCount) ||
                other.postsCount == postsCount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.isExpert, isExpert) ||
                other.isExpert == isExpert) &&
            (identical(other.isModerator, isModerator) ||
                other.isModerator == isModerator) &&
            (identical(other.isSuperuser, isSuperuser) ||
                other.isSuperuser == isSuperuser) &&
            (identical(other.adminPermissions, adminPermissions) ||
                other.adminPermissions == adminPermissions) &&
            (identical(other.expertSpecialties, expertSpecialties) ||
                other.expertSpecialties == expertSpecialties) &&
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
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        email,
        username,
        displayName,
        bio,
        profilePictureUrl,
        location,
        dateOfBirth,
        isPrivate,
        followersCount,
        followingCount,
        postsCount,
        isActive,
        isVerified,
        lastSeen,
        createdAt,
        updatedAt,
        isAdmin,
        isExpert,
        isModerator,
        isSuperuser,
        adminPermissions,
        expertSpecialties,
        const DeepCollectionEquality().hash(_plantInterests),
        experienceLevel,
        const DeepCollectionEquality().hash(_favoriteGenres),
        gardenType,
        climate
      ]);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String email,
      required final String username,
      final String? displayName,
      final String? bio,
      final String? profilePictureUrl,
      final String? location,
      final DateTime? dateOfBirth,
      final bool isPrivate,
      final int followersCount,
      final int followingCount,
      final int postsCount,
      final bool isActive,
      final bool isVerified,
      final DateTime? lastSeen,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final bool isAdmin,
      final bool isExpert,
      final bool isModerator,
      final bool isSuperuser,
      final String? adminPermissions,
      final String? expertSpecialties,
      final List<String> plantInterests,
      final String? experienceLevel,
      final List<String> favoriteGenres,
      final String? gardenType,
      final String? climate}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  String? get bio;
  @override
  String? get profilePictureUrl;
  @override
  String? get location;
  @override
  DateTime? get dateOfBirth;
  @override
  bool get isPrivate;
  @override
  int get followersCount;
  @override
  int get followingCount;
  @override
  int get postsCount;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override
  DateTime? get lastSeen;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // Role-based access control fields
  @override
  bool get isAdmin;
  @override
  bool get isExpert;
  @override
  bool get isModerator;
  @override
  bool get isSuperuser;
  @override
  String? get adminPermissions; // JSON string of admin permissions
  @override
  String? get expertSpecialties; // JSON string of expert specialties
// Plant-specific fields for Phase 2
  @override
  List<String> get plantInterests;
  @override
  String? get experienceLevel; // 'beginner', 'intermediate', 'expert'
  @override
  List<String> get favoriteGenres;
  @override
  String? get gardenType; // 'indoor', 'outdoor', 'balcony', 'greenhouse'
  @override
  String? get climate;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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

  $UserCopyWith<$Res> get user;
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

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
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

  @override
  $UserCopyWith<$Res> get user;
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
