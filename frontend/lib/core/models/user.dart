import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? bio;
  final String? profilePictureUrl;
  final String? location;
  final DateTime? dateOfBirth;
  final bool isPrivate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Plant-related fields for Phase 2
  final List<String> plantInterests;
  final String? experienceLevel; // 'beginner', 'intermediate', 'expert'
  final List<String> favoriteGenres;
  final String? gardenType; // 'indoor', 'outdoor', 'balcony', 'greenhouse'
  final String? climate; // 'tropical', 'temperate', 'arid', 'continental'

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
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
    this.plantInterests = const [],
    this.experienceLevel,
    this.favoriteGenres = const [],
    this.gardenType,
    this.climate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      plantInterests: (json['plantInterests'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      experienceLevel: json['experienceLevel'] as String?,
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      gardenType: json['gardenType'] as String?,
      climate: json['climate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'location': location,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isPrivate': isPrivate,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isActive': isActive,
      'isVerified': isVerified,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'plantInterests': plantInterests,
      'experienceLevel': experienceLevel,
      'favoriteGenres': favoriteGenres,
      'gardenType': gardenType,
      'climate': climate,
    };
  }
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
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;
  
  String get initials {
    if (fullName?.isNotEmpty == true) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
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