// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      isPrivate: json['is_private'] as bool? ?? false,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
      isExpert: json['is_expert'] as bool? ?? false,
      isModerator: json['is_moderator'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      hasTelemetryAccess: json['has_telemetry_access'] as bool? ?? false,
      adminPermissions: json['admin_permissions'] as String?,
      expertSpecialties: json['expert_specialties'] as String?,
      plantInterests: (json['plant_interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      experienceLevel: json['experience_level'] as String?,
      favoriteGenres: (json['favorite_genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      gardenType: json['garden_type'] as String?,
      climate: json['climate'] as String?,
      gardeningExperience: json['gardening_experience'] as String?,
      favoritePlants: json['favorite_plants'] as String?,
      allowPlantIdRequests: json['allow_plant_id_requests'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'profile_picture_url': instance.profilePictureUrl,
      'location': instance.location,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'is_private': instance.isPrivate,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'posts_count': instance.postsCount,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
      'last_seen': instance.lastSeen?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_admin': instance.isAdmin,
      'is_expert': instance.isExpert,
      'is_moderator': instance.isModerator,
      'is_superuser': instance.isSuperuser,
      'has_telemetry_access': instance.hasTelemetryAccess,
      'admin_permissions': instance.adminPermissions,
      'expert_specialties': instance.expertSpecialties,
      'plant_interests': instance.plantInterests,
      'experience_level': instance.experienceLevel,
      'favorite_genres': instance.favoriteGenres,
      'garden_type': instance.gardenType,
      'climate': instance.climate,
      'gardening_experience': instance.gardeningExperience,
      'favorite_plants': instance.favoritePlants,
      'allow_plant_id_requests': instance.allowPlantIdRequests,
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
