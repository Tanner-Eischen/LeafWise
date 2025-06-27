import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? displayName,
    String? bio,
    String? profilePictureUrl,
    String? location,
    DateTime? dateOfBirth,
    @Default(false) bool isPrivate,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int postsCount,
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    DateTime? lastSeen,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // Plant-specific fields for Phase 2
    @Default([]) List<String> plantInterests,
    String? experienceLevel, // 'beginner', 'intermediate', 'expert'
    @Default([]) List<String> favoriteGenres,
    String? gardenType, // 'indoor', 'outdoor', 'balcony', 'greenhouse'
    String? climate, // 'tropical', 'temperate', 'arid', 'continental'
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