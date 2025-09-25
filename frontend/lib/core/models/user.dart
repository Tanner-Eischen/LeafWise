import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    String? bio,
    @JsonKey(name: 'profile_picture_url') String? profilePictureUrl,
    String? location,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'is_private') @Default(false) bool isPrivate,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'posts_count') @Default(0) int postsCount,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'last_seen') DateTime? lastSeen,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    
    // Role-based access control fields
    @JsonKey(name: 'is_admin') @Default(false) bool isAdmin,
    @JsonKey(name: 'is_expert') @Default(false) bool isExpert,
    @JsonKey(name: 'is_moderator') @Default(false) bool isModerator,
    @JsonKey(name: 'is_superuser') @Default(false) bool isSuperuser,
    @JsonKey(name: 'has_telemetry_access') @Default(false) bool hasTelemetryAccess,
    @JsonKey(name: 'admin_permissions') String? adminPermissions, // JSON string of admin permissions
    @JsonKey(name: 'expert_specialties') String? expertSpecialties, // JSON string of expert specialties
    
    // Plant-specific fields for Phase 2
    @JsonKey(name: 'plant_interests') @Default([]) List<String> plantInterests,
    @JsonKey(name: 'experience_level') String? experienceLevel, // 'beginner', 'intermediate', 'expert'
    @JsonKey(name: 'favorite_genres') @Default([]) List<String> favoriteGenres,
    @JsonKey(name: 'garden_type') String? gardenType, // 'indoor', 'outdoor', 'balcony', 'greenhouse'
    String? climate, // 'tropical', 'temperate', 'arid', 'continental'
    
    // Additional backend fields that might be missing
    @JsonKey(name: 'gardening_experience') String? gardeningExperience,
    @JsonKey(name: 'favorite_plants') String? favoritePlants,
    @JsonKey(name: 'allow_plant_id_requests') @Default(true) bool allowPlantIdRequests,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required User user,
    @Default(false) bool isFollowing,
    @Default(false) bool isFollowedBy,
    @Default(false) bool isBlocked,
    @Default(false) bool hasBlockedMe,
    String? friendshipStatus, // 'none', 'pending', 'accepted', 'blocked'
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

@freezed
class UserSearchResult with _$UserSearchResult {
  const factory UserSearchResult({
    required String id,
    required String username,
    String? fullName,
    String? profilePictureUrl,
    @Default(false) bool isVerified,
    @Default(false) bool isFollowing,
    String? mutualFriendsCount,
  }) = _UserSearchResult;

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => _$UserSearchResultFromJson(json);
}

@freezed
class UpdateUserRequest with _$UpdateUserRequest {
  const factory UpdateUserRequest({
    String? fullName,
    String? bio,
    String? location,
    DateTime? dateOfBirth,
    bool? isPrivate,
    List<String>? plantInterests,
    String? experienceLevel,
    List<String>? favoriteGenres,
    String? gardenType,
    String? climate,
  }) = _UpdateUserRequest;

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestFromJson(json);
}

// Extension methods for User
extension UserExtension on User {
  String get name => displayName ?? username;
  
  String get initials {
    if (displayName?.isNotEmpty == true) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return username[0].toUpperCase();
  }
  
  bool get hasProfilePicture => profilePictureUrl?.isNotEmpty == true;
  
  /// Check if user has telemetry access (expert, admin, or moderator)
  bool get hasTelemetryAccess => isExpert || isAdmin || isModerator;
  
  /// Check if user has admin privileges
  bool get hasAdminAccess => isAdmin || isSuperuser;
  
  /// Check if user can moderate content
  bool get canModerate => isModerator || isAdmin || isSuperuser;
  
  bool get isOnline {
    if (lastSeen == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    return difference.inMinutes < 5; // Consider online if last seen within 5 minutes
  }
  
  String get lastSeenText {
    if (lastSeen == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Long time ago';
    }
  }
  
  String get experienceLevelDisplay {
    switch (experienceLevel?.toLowerCase()) {
      case 'beginner':
        return '🌱 Beginner';
      case 'intermediate':
        return '🌿 Intermediate';
      case 'expert':
        return '🌳 Expert';
      default:
        return '🌱 New to plants';
    }
  }
  
  String get gardenTypeDisplay {
    switch (gardenType?.toLowerCase()) {
      case 'indoor':
        return '🏠 Indoor Garden';
      case 'outdoor':
        return '🌳 Outdoor Garden';
      case 'balcony':
        return '🪴 Balcony Garden';
      case 'greenhouse':
        return '🏡 Greenhouse';
      default:
        return '🌱 Garden';
    }
  }
}