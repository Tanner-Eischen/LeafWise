import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plant_social/core/models/user.dart';

part 'story.freezed.dart';
part 'story.g.dart';

enum StoryType {
  image,
  video,
  text,
  plant_progress, // Phase 2
  plant_care_tip, // Phase 2
  plant_identification, // Phase 2
}

enum StoryPrivacyLevel {
  public,
  friends,
  close_friends,
  private,
}

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String userId,
    required String content,
    @Default(StoryType.image) StoryType type,
    @Default(StoryPrivacyLevel.public) StoryPrivacyLevel privacyLevel,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    @Default([]) List<String> tags,
    String? location,
    @Default(0) int viewsCount,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    DateTime? expiresAt,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info (populated from join)
    User? user,
    
    // Viewer's interaction status
    @Default(false) bool hasViewed,
    @Default(false) bool hasLiked,
    
    // Plant-specific fields for Phase 2
    String? plantId,
    Map<String, dynamic>? plantData,
    String? careStage, // 'seedling', 'growing', 'flowering', 'fruiting'
    List<String>? careTips,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}

@freezed
class StoryView with _$StoryView {
  const factory StoryView({
    required String id,
    required String storyId,
    required String userId,
    required DateTime viewedAt,
    
    // User info (populated from join)
    User? user,
  }) = _StoryView;

  factory StoryView.fromJson(Map<String, dynamic> json) => _$StoryViewFromJson(json);
}

@freezed
class StoryLike with _$StoryLike {
  const factory StoryLike({
    required String id,
    required String storyId,
    required String userId,
    required DateTime createdAt,
    
    // User info (populated from join)
    User? user,
  }) = _StoryLike;

  factory StoryLike.fromJson(Map<String, dynamic> json) => _$StoryLikeFromJson(json);
}

@freezed
class StoryComment with _$StoryComment {
  const factory StoryComment({
    required String id,
    required String storyId,
    required String userId,
    required String content,
    String? parentCommentId,
    @Default(0) int likesCount,
    @Default(false) bool hasLiked,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info (populated from join)
    User? user,
    
    // Replies (if it's a parent comment)
    @Default([]) List<StoryComment> replies,
  }) = _StoryComment;

  factory StoryComment.fromJson(Map<String, dynamic> json) => _$StoryCommentFromJson(json);
}

@freezed
class CreateStoryRequest with _$CreateStoryRequest {
  const factory CreateStoryRequest({
    required String content,
    @Default(StoryType.image) StoryType type,
    @Default(StoryPrivacyLevel.public) StoryPrivacyLevel privacyLevel,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? location,
    DateTime? expiresAt,
    String? plantId,
    Map<String, dynamic>? plantData,
    String? careStage,
    List<String>? careTips,
  }) = _CreateStoryRequest;

  factory CreateStoryRequest.fromJson(Map<String, dynamic> json) => _$CreateStoryRequestFromJson(json);
}

@freezed
class StoryFeed with _$StoryFeed {
  const factory StoryFeed({
    required String userId,
    required User user,
    @Default([]) List<Story> stories,
    @Default(false) bool hasUnviewedStories,
  }) = _StoryFeed;

  factory StoryFeed.fromJson(Map<String, dynamic> json) => _$StoryFeedFromJson(json);
}

// Extension methods for Story
extension StoryExtension on Story {
  bool get isImage => type == StoryType.image;
  bool get isVideo => type == StoryType.video;
  bool get isText => type == StoryType.text;
  bool get isPlantRelated => [StoryType.plant_progress, StoryType.plant_care_tip, StoryType.plant_identification].contains(type);
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  bool get isActive => !isExpired && !isArchived;
  
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  String get displayContent {
    switch (type) {
      case StoryType.image:
        return content.isNotEmpty ? content : 'Shared a photo';
      case StoryType.video:
        return content.isNotEmpty ? content : 'Shared a video';
      case StoryType.text:
        return content;
      case StoryType.plant_progress:
        return content.isNotEmpty ? content : 'Plant progress update';
      case StoryType.plant_care_tip:
        return content.isNotEmpty ? content : 'Shared a plant care tip';
      case StoryType.plant_identification:
        return content.isNotEmpty ? content : 'Plant identification';
    }
  }
  
  String get typeIcon {
    switch (type) {
      case StoryType.image:
        return '📷';
      case StoryType.video:
        return '🎥';
      case StoryType.text:
        return '📝';
      case StoryType.plant_progress:
        return '🌱';
      case StoryType.plant_care_tip:
        return '💡';
      case StoryType.plant_identification:
        return '🔍';
    }
  }
  
  String get privacyIcon {
    switch (privacyLevel) {
      case StoryPrivacyLevel.public:
        return '🌍';
      case StoryPrivacyLevel.friends:
        return '👥';
      case StoryPrivacyLevel.close_friends:
        return '⭐';
      case StoryPrivacyLevel.private:
        return '🔒';
    }
  }
  
  String get careStageDisplay {
    switch (careStage?.toLowerCase()) {
      case 'seedling':
        return '🌱 Seedling';
      case 'growing':
        return '🌿 Growing';
      case 'flowering':
        return '🌸 Flowering';
      case 'fruiting':
        return '🍎 Fruiting';
      default:
        return '🌱 Plant';
    }
  }
}

// Extension methods for StoryFeed
extension StoryFeedExtension on StoryFeed {
  Story? get latestStory {
    if (stories.isEmpty) return null;
    return stories.first;
  }
  
  int get unviewedCount {
    return stories.where((story) => !story.hasViewed && story.isActive).length;
  }
  
  bool get hasActiveStories {
    return stories.any((story) => story.isActive);
  }
  
  List<Story> get activeStories {
    return stories.where((story) => story.isActive).toList();
  }
}

// Extension methods for StoryComment
extension StoryCommentExtension on StoryComment {
  bool get isReply => parentCommentId != null;
  bool get hasReplies => replies.isNotEmpty;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}';
    }
  }
}