// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$StoryTypeEnumMap, json['type']) ??
          StoryType.image,
      privacyLevel: $enumDecodeNullable(
              _$StoryPrivacyLevelEnumMap, json['privacyLevel']) ??
          StoryPrivacyLevel.public,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      location: json['location'] as String?,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      hasViewed: json['hasViewed'] as bool? ?? false,
      hasLiked: json['hasLiked'] as bool? ?? false,
      plantId: json['plantId'] as String?,
      plantData: json['plantData'] as Map<String, dynamic>?,
      careStage: json['careStage'] as String?,
      careTips: (json['careTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'type': _$StoryTypeEnumMap[instance.type]!,
      'privacyLevel': _$StoryPrivacyLevelEnumMap[instance.privacyLevel]!,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'location': instance.location,
      'viewsCount': instance.viewsCount,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'user': instance.user,
      'hasViewed': instance.hasViewed,
      'hasLiked': instance.hasLiked,
      'plantId': instance.plantId,
      'plantData': instance.plantData,
      'careStage': instance.careStage,
      'careTips': instance.careTips,
    };

const _$StoryTypeEnumMap = {
  StoryType.image: 'image',
  StoryType.video: 'video',
  StoryType.text: 'text',
  StoryType.plant_progress: 'plant_progress',
  StoryType.plant_care_tip: 'plant_care_tip',
  StoryType.plant_identification: 'plant_identification',
};

const _$StoryPrivacyLevelEnumMap = {
  StoryPrivacyLevel.public: 'public',
  StoryPrivacyLevel.friends: 'friends',
  StoryPrivacyLevel.close_friends: 'close_friends',
  StoryPrivacyLevel.private: 'private',
};

_$StoryViewImpl _$$StoryViewImplFromJson(Map<String, dynamic> json) =>
    _$StoryViewImpl(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StoryViewImplToJson(_$StoryViewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'userId': instance.userId,
      'viewedAt': instance.viewedAt.toIso8601String(),
      'user': instance.user,
    };

_$StoryLikeImpl _$$StoryLikeImplFromJson(Map<String, dynamic> json) =>
    _$StoryLikeImpl(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StoryLikeImplToJson(_$StoryLikeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };

_$StoryCommentImpl _$$StoryCommentImplFromJson(Map<String, dynamic> json) =>
    _$StoryCommentImpl(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      hasLiked: json['hasLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => StoryComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StoryCommentImplToJson(_$StoryCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'userId': instance.userId,
      'content': instance.content,
      'parentCommentId': instance.parentCommentId,
      'likesCount': instance.likesCount,
      'hasLiked': instance.hasLiked,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'user': instance.user,
      'replies': instance.replies,
    };

_$CreateStoryRequestImpl _$$CreateStoryRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateStoryRequestImpl(
      content: json['content'] as String,
      type: $enumDecodeNullable(_$StoryTypeEnumMap, json['type']) ??
          StoryType.image,
      privacyLevel: $enumDecodeNullable(
              _$StoryPrivacyLevelEnumMap, json['privacyLevel']) ??
          StoryPrivacyLevel.public,
      mediaUrl: json['mediaUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      location: json['location'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      plantId: json['plantId'] as String?,
      plantData: json['plantData'] as Map<String, dynamic>?,
      careStage: json['careStage'] as String?,
      careTips: (json['careTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CreateStoryRequestImplToJson(
        _$CreateStoryRequestImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'type': _$StoryTypeEnumMap[instance.type]!,
      'privacyLevel': _$StoryPrivacyLevelEnumMap[instance.privacyLevel]!,
      'mediaUrl': instance.mediaUrl,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'location': instance.location,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'plantId': instance.plantId,
      'plantData': instance.plantData,
      'careStage': instance.careStage,
      'careTips': instance.careTips,
    };

_$StoryFeedImpl _$$StoryFeedImplFromJson(Map<String, dynamic> json) =>
    _$StoryFeedImpl(
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      stories: (json['stories'] as List<dynamic>?)
              ?.map((e) => Story.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasUnviewedStories: json['hasUnviewedStories'] as bool? ?? false,
    );

Map<String, dynamic> _$$StoryFeedImplToJson(_$StoryFeedImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'user': instance.user,
      'stories': instance.stories,
      'hasUnviewedStories': instance.hasUnviewedStories,
    };
