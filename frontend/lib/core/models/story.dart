import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leafwise/core/models/user.dart';

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

enum StoryPrivacyLevel { public, friends, close_friends, private }

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

  factory StoryView.fromJson(Map<String, dynamic> json) =>
      _$StoryViewFromJson(json);
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

  factory StoryLike.fromJson(Map<String, dynamic> json) =>
      _$StoryLikeFromJson(json);
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

  factory StoryComment.fromJson(Map<String, dynamic> json) =>
      _$StoryCommentFromJson(json);
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

  factory CreateStoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryRequestFromJson(json);
}

@freezed
class StoryFeed with _$StoryFeed {
  const factory StoryFeed({
    required String userId,
    required User user,
    @Default([]) List<Story> stories,
    @Default(false) bool hasUnviewedStories,
  }) = _StoryFeed;

  factory StoryFeed.fromJson(Map<String, dynamic> json) =>
      _$StoryFeedFromJson(json);
}
