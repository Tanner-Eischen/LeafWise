// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      viewedBy: (json['viewedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isViewed: json['isViewed'] as bool? ?? false,
      isOwner: json['isOwner'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'userProfilePicture': instance.userProfilePicture,
      'mediaUrl': instance.mediaUrl,
      'mediaType': instance.mediaType,
      'caption': instance.caption,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'viewedBy': instance.viewedBy,
      'isViewed': instance.isViewed,
      'isOwner': instance.isOwner,
      'metadata': instance.metadata,
    };

_$CreateStoryRequestImpl _$$CreateStoryRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateStoryRequestImpl(
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      caption: json['caption'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CreateStoryRequestImplToJson(
        _$CreateStoryRequestImpl instance) =>
    <String, dynamic>{
      'mediaUrl': instance.mediaUrl,
      'mediaType': instance.mediaType,
      'caption': instance.caption,
      'metadata': instance.metadata,
    };

_$ViewStoryRequestImpl _$$ViewStoryRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ViewStoryRequestImpl(
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$ViewStoryRequestImplToJson(
        _$ViewStoryRequestImpl instance) =>
    <String, dynamic>{
      'storyId': instance.storyId,
      'userId': instance.userId,
    };

_$StoriesResponseImpl _$$StoriesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$StoriesResponseImpl(
      stories: (json['stories'] as List<dynamic>)
          .map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StoriesResponseImplToJson(
        _$StoriesResponseImpl instance) =>
    <String, dynamic>{
      'stories': instance.stories,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
      'totalCount': instance.totalCount,
    };

_$UserStoriesGroupImpl _$$UserStoriesGroupImplFromJson(
        Map<String, dynamic> json) =>
    _$UserStoriesGroupImpl(
      userId: json['userId'] as String,
      username: json['username'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      stories: (json['stories'] as List<dynamic>)
          .map((e) => Story.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasUnviewedStories: json['hasUnviewedStories'] as bool? ?? false,
      lastStoryTime: json['lastStoryTime'] == null
          ? null
          : DateTime.parse(json['lastStoryTime'] as String),
    );

Map<String, dynamic> _$$UserStoriesGroupImplToJson(
        _$UserStoriesGroupImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'userProfilePicture': instance.userProfilePicture,
      'stories': instance.stories,
      'hasUnviewedStories': instance.hasUnviewedStories,
      'lastStoryTime': instance.lastStoryTime?.toIso8601String(),
    };
