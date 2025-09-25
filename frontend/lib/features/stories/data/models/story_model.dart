// Story model for API integration and data management
// Handles story data structure, serialization, and deserialization

import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_model.freezed.dart';
part 'story_model.g.dart';

/// Story model representing a user's story post
@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String userId,
    required String username,
    String? userProfilePicture,
    required String mediaUrl,
    required String mediaType, // 'image' or 'video'
    String? caption,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(0) int viewCount,
    @Default([]) List<String> viewedBy,
    @Default(false) bool isViewed,
    @Default(false) bool isOwner,
    Map<String, dynamic>? metadata,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}

/// Story creation request model
@freezed
class CreateStoryRequest with _$CreateStoryRequest {
  const factory CreateStoryRequest({
    required String mediaUrl,
    required String mediaType,
    String? caption,
    Map<String, dynamic>? metadata,
  }) = _CreateStoryRequest;

  factory CreateStoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryRequestFromJson(json);
}

/// Story view request model
@freezed
class ViewStoryRequest with _$ViewStoryRequest {
  const factory ViewStoryRequest({
    required String storyId,
    required String userId,
  }) = _ViewStoryRequest;

  factory ViewStoryRequest.fromJson(Map<String, dynamic> json) =>
      _$ViewStoryRequestFromJson(json);
}

/// Stories response model for paginated results
@freezed
class StoriesResponse with _$StoriesResponse {
  const factory StoriesResponse({
    required List<Story> stories,
    @Default(false) bool hasMore,
    String? nextCursor,
    @Default(0) int totalCount,
  }) = _StoriesResponse;

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoriesResponseFromJson(json);
}

/// User stories group model for organizing stories by user
@freezed
class UserStoriesGroup with _$UserStoriesGroup {
  const factory UserStoriesGroup({
    required String userId,
    required String username,
    String? userProfilePicture,
    required List<Story> stories,
    @Default(false) bool hasUnviewedStories,
    DateTime? lastStoryTime,
  }) = _UserStoriesGroup;

  factory UserStoriesGroup.fromJson(Map<String, dynamic> json) =>
      _$UserStoriesGroupFromJson(json);
}