// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      isPrivate: json['isPrivate'] as bool? ?? false,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isAdmin: json['isAdmin'] as bool? ?? false,
      isExpert: json['isExpert'] as bool? ?? false,
      isModerator: json['isModerator'] as bool? ?? false,
      isSuperuser: json['isSuperuser'] as bool? ?? false,
      adminPermissions: json['adminPermissions'] as String?,
      expertSpecialties: json['expertSpecialties'] as String?,
      plantInterests: (json['plantInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      experienceLevel: json['experienceLevel'] as String?,
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      gardenType: json['gardenType'] as String?,
      climate: json['climate'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
      'location': instance.location,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'isPrivate': instance.isPrivate,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'postsCount': instance.postsCount,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isAdmin': instance.isAdmin,
      'isExpert': instance.isExpert,
      'isModerator': instance.isModerator,
      'isSuperuser': instance.isSuperuser,
      'adminPermissions': instance.adminPermissions,
      'expertSpecialties': instance.expertSpecialties,
      'plantInterests': instance.plantInterests,
      'experienceLevel': instance.experienceLevel,
      'favoriteGenres': instance.favoriteGenres,
      'gardenType': instance.gardenType,
      'climate': instance.climate,
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowedBy: json['isFollowedBy'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      hasBlockedMe: json['hasBlockedMe'] as bool? ?? false,
      friendshipStatus: json['friendshipStatus'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'isFollowing': instance.isFollowing,
      'isFollowedBy': instance.isFollowedBy,
      'isBlocked': instance.isBlocked,
      'hasBlockedMe': instance.hasBlockedMe,
      'friendshipStatus': instance.friendshipStatus,
    };

_$UserSearchResultImpl _$$UserSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSearchResultImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      mutualFriendsCount: json['mutualFriendsCount'] as String?,
    );

Map<String, dynamic> _$$UserSearchResultImplToJson(
        _$UserSearchResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
      'profilePictureUrl': instance.profilePictureUrl,
      'isVerified': instance.isVerified,
      'isFollowing': instance.isFollowing,
      'mutualFriendsCount': instance.mutualFriendsCount,
    };

_$UpdateUserRequestImpl _$$UpdateUserRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateUserRequestImpl(
      fullName: json['fullName'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      isPrivate: json['isPrivate'] as bool?,
      plantInterests: (json['plantInterests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      experienceLevel: json['experienceLevel'] as String?,
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gardenType: json['gardenType'] as String?,
      climate: json['climate'] as String?,
    );

Map<String, dynamic> _$$UpdateUserRequestImplToJson(
        _$UpdateUserRequestImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'bio': instance.bio,
      'location': instance.location,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'isPrivate': instance.isPrivate,
      'plantInterests': instance.plantInterests,
      'experienceLevel': instance.experienceLevel,
      'favoriteGenres': instance.favoriteGenres,
      'gardenType': instance.gardenType,
      'climate': instance.climate,
    };
