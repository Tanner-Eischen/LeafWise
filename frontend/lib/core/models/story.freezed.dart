// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Story _$StoryFromJson(Map<String, dynamic> json) {
  return _Story.fromJson(json);
}

/// @nodoc
mixin _$Story {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  StoryType get type => throw _privateConstructorUsedError;
  StoryPrivacyLevel get privacyLevel => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int get viewsCount => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  int get commentsCount => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get user =>
      throw _privateConstructorUsedError; // Viewer's interaction status
  bool get hasViewed => throw _privateConstructorUsedError;
  bool get hasLiked =>
      throw _privateConstructorUsedError; // Plant-specific fields for Phase 2
  String? get plantId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get plantData => throw _privateConstructorUsedError;
  String? get careStage =>
      throw _privateConstructorUsedError; // 'seedling', 'growing', 'flowering', 'fruiting'
  List<String>? get careTips => throw _privateConstructorUsedError;

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryCopyWith<Story> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCopyWith<$Res> {
  factory $StoryCopyWith(Story value, $Res Function(Story) then) =
      _$StoryCopyWithImpl<$Res, Story>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String content,
      StoryType type,
      StoryPrivacyLevel privacyLevel,
      String? mediaUrl,
      String? thumbnailUrl,
      Map<String, dynamic>? metadata,
      List<String> tags,
      String? location,
      int viewsCount,
      int likesCount,
      int commentsCount,
      DateTime? expiresAt,
      bool isArchived,
      DateTime createdAt,
      DateTime? updatedAt,
      User? user,
      bool hasViewed,
      bool hasLiked,
      String? plantId,
      Map<String, dynamic>? plantData,
      String? careStage,
      List<String>? careTips});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$StoryCopyWithImpl<$Res, $Val extends Story>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? type = null,
    Object? privacyLevel = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? metadata = freezed,
    Object? tags = null,
    Object? location = freezed,
    Object? viewsCount = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? expiresAt = freezed,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? user = freezed,
    Object? hasViewed = null,
    Object? hasLiked = null,
    Object? plantId = freezed,
    Object? plantData = freezed,
    Object? careStage = freezed,
    Object? careTips = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as StoryPrivacyLevel,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      viewsCount: null == viewsCount
          ? _value.viewsCount
          : viewsCount // ignore: cast_nullable_to_non_nullable
              as int,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentsCount: null == commentsCount
          ? _value.commentsCount
          : commentsCount // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      hasViewed: null == hasViewed
          ? _value.hasViewed
          : hasViewed // ignore: cast_nullable_to_non_nullable
              as bool,
      hasLiked: null == hasLiked
          ? _value.hasLiked
          : hasLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value.plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      careStage: freezed == careStage
          ? _value.careStage
          : careStage // ignore: cast_nullable_to_non_nullable
              as String?,
      careTips: freezed == careTips
          ? _value.careTips
          : careTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryImplCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$$StoryImplCopyWith(
          _$StoryImpl value, $Res Function(_$StoryImpl) then) =
      __$$StoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String content,
      StoryType type,
      StoryPrivacyLevel privacyLevel,
      String? mediaUrl,
      String? thumbnailUrl,
      Map<String, dynamic>? metadata,
      List<String> tags,
      String? location,
      int viewsCount,
      int likesCount,
      int commentsCount,
      DateTime? expiresAt,
      bool isArchived,
      DateTime createdAt,
      DateTime? updatedAt,
      User? user,
      bool hasViewed,
      bool hasLiked,
      String? plantId,
      Map<String, dynamic>? plantData,
      String? careStage,
      List<String>? careTips});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$StoryImplCopyWithImpl<$Res>
    extends _$StoryCopyWithImpl<$Res, _$StoryImpl>
    implements _$$StoryImplCopyWith<$Res> {
  __$$StoryImplCopyWithImpl(
      _$StoryImpl _value, $Res Function(_$StoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? type = null,
    Object? privacyLevel = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? metadata = freezed,
    Object? tags = null,
    Object? location = freezed,
    Object? viewsCount = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? expiresAt = freezed,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? user = freezed,
    Object? hasViewed = null,
    Object? hasLiked = null,
    Object? plantId = freezed,
    Object? plantData = freezed,
    Object? careStage = freezed,
    Object? careTips = freezed,
  }) {
    return _then(_$StoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as StoryPrivacyLevel,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      viewsCount: null == viewsCount
          ? _value.viewsCount
          : viewsCount // ignore: cast_nullable_to_non_nullable
              as int,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentsCount: null == commentsCount
          ? _value.commentsCount
          : commentsCount // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      hasViewed: null == hasViewed
          ? _value.hasViewed
          : hasViewed // ignore: cast_nullable_to_non_nullable
              as bool,
      hasLiked: null == hasLiked
          ? _value.hasLiked
          : hasLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value._plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      careStage: freezed == careStage
          ? _value.careStage
          : careStage // ignore: cast_nullable_to_non_nullable
              as String?,
      careTips: freezed == careTips
          ? _value._careTips
          : careTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryImpl implements _Story {
  const _$StoryImpl(
      {required this.id,
      required this.userId,
      required this.content,
      this.type = StoryType.image,
      this.privacyLevel = StoryPrivacyLevel.public,
      this.mediaUrl,
      this.thumbnailUrl,
      final Map<String, dynamic>? metadata,
      final List<String> tags = const [],
      this.location,
      this.viewsCount = 0,
      this.likesCount = 0,
      this.commentsCount = 0,
      this.expiresAt,
      this.isArchived = false,
      required this.createdAt,
      this.updatedAt,
      this.user,
      this.hasViewed = false,
      this.hasLiked = false,
      this.plantId,
      final Map<String, dynamic>? plantData,
      this.careStage,
      final List<String>? careTips})
      : _metadata = metadata,
        _tags = tags,
        _plantData = plantData,
        _careTips = careTips;

  factory _$StoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String content;
  @override
  @JsonKey()
  final StoryType type;
  @override
  @JsonKey()
  final StoryPrivacyLevel privacyLevel;
  @override
  final String? mediaUrl;
  @override
  final String? thumbnailUrl;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? location;
  @override
  @JsonKey()
  final int viewsCount;
  @override
  @JsonKey()
  final int likesCount;
  @override
  @JsonKey()
  final int commentsCount;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// User info (populated from join)
  @override
  final User? user;
// Viewer's interaction status
  @override
  @JsonKey()
  final bool hasViewed;
  @override
  @JsonKey()
  final bool hasLiked;
// Plant-specific fields for Phase 2
  @override
  final String? plantId;
  final Map<String, dynamic>? _plantData;
  @override
  Map<String, dynamic>? get plantData {
    final value = _plantData;
    if (value == null) return null;
    if (_plantData is EqualUnmodifiableMapView) return _plantData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? careStage;
// 'seedling', 'growing', 'flowering', 'fruiting'
  final List<String>? _careTips;
// 'seedling', 'growing', 'flowering', 'fruiting'
  @override
  List<String>? get careTips {
    final value = _careTips;
    if (value == null) return null;
    if (_careTips is EqualUnmodifiableListView) return _careTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Story(id: $id, userId: $userId, content: $content, type: $type, privacyLevel: $privacyLevel, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, metadata: $metadata, tags: $tags, location: $location, viewsCount: $viewsCount, likesCount: $likesCount, commentsCount: $commentsCount, expiresAt: $expiresAt, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, hasViewed: $hasViewed, hasLiked: $hasLiked, plantId: $plantId, plantData: $plantData, careStage: $careStage, careTips: $careTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.privacyLevel, privacyLevel) ||
                other.privacyLevel == privacyLevel) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.viewsCount, viewsCount) ||
                other.viewsCount == viewsCount) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.hasViewed, hasViewed) ||
                other.hasViewed == hasViewed) &&
            (identical(other.hasLiked, hasLiked) ||
                other.hasLiked == hasLiked) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            const DeepCollectionEquality()
                .equals(other._plantData, _plantData) &&
            (identical(other.careStage, careStage) ||
                other.careStage == careStage) &&
            const DeepCollectionEquality().equals(other._careTips, _careTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        content,
        type,
        privacyLevel,
        mediaUrl,
        thumbnailUrl,
        const DeepCollectionEquality().hash(_metadata),
        const DeepCollectionEquality().hash(_tags),
        location,
        viewsCount,
        likesCount,
        commentsCount,
        expiresAt,
        isArchived,
        createdAt,
        updatedAt,
        user,
        hasViewed,
        hasLiked,
        plantId,
        const DeepCollectionEquality().hash(_plantData),
        careStage,
        const DeepCollectionEquality().hash(_careTips)
      ]);

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      __$$StoryImplCopyWithImpl<_$StoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryImplToJson(
      this,
    );
  }
}

abstract class _Story implements Story {
  const factory _Story(
      {required final String id,
      required final String userId,
      required final String content,
      final StoryType type,
      final StoryPrivacyLevel privacyLevel,
      final String? mediaUrl,
      final String? thumbnailUrl,
      final Map<String, dynamic>? metadata,
      final List<String> tags,
      final String? location,
      final int viewsCount,
      final int likesCount,
      final int commentsCount,
      final DateTime? expiresAt,
      final bool isArchived,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final User? user,
      final bool hasViewed,
      final bool hasLiked,
      final String? plantId,
      final Map<String, dynamic>? plantData,
      final String? careStage,
      final List<String>? careTips}) = _$StoryImpl;

  factory _Story.fromJson(Map<String, dynamic> json) = _$StoryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get content;
  @override
  StoryType get type;
  @override
  StoryPrivacyLevel get privacyLevel;
  @override
  String? get mediaUrl;
  @override
  String? get thumbnailUrl;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String> get tags;
  @override
  String? get location;
  @override
  int get viewsCount;
  @override
  int get likesCount;
  @override
  int get commentsCount;
  @override
  DateTime? get expiresAt;
  @override
  bool get isArchived;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // User info (populated from join)
  @override
  User? get user; // Viewer's interaction status
  @override
  bool get hasViewed;
  @override
  bool get hasLiked; // Plant-specific fields for Phase 2
  @override
  String? get plantId;
  @override
  Map<String, dynamic>? get plantData;
  @override
  String? get careStage; // 'seedling', 'growing', 'flowering', 'fruiting'
  @override
  List<String>? get careTips;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryView _$StoryViewFromJson(Map<String, dynamic> json) {
  return _StoryView.fromJson(json);
}

/// @nodoc
mixin _$StoryView {
  String get id => throw _privateConstructorUsedError;
  String get storyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get viewedAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get user => throw _privateConstructorUsedError;

  /// Serializes this StoryView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryViewCopyWith<StoryView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryViewCopyWith<$Res> {
  factory $StoryViewCopyWith(StoryView value, $Res Function(StoryView) then) =
      _$StoryViewCopyWithImpl<$Res, StoryView>;
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      DateTime viewedAt,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$StoryViewCopyWithImpl<$Res, $Val extends StoryView>
    implements $StoryViewCopyWith<$Res> {
  _$StoryViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? viewedAt = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      viewedAt: null == viewedAt
          ? _value.viewedAt
          : viewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryViewImplCopyWith<$Res>
    implements $StoryViewCopyWith<$Res> {
  factory _$$StoryViewImplCopyWith(
          _$StoryViewImpl value, $Res Function(_$StoryViewImpl) then) =
      __$$StoryViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      DateTime viewedAt,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$StoryViewImplCopyWithImpl<$Res>
    extends _$StoryViewCopyWithImpl<$Res, _$StoryViewImpl>
    implements _$$StoryViewImplCopyWith<$Res> {
  __$$StoryViewImplCopyWithImpl(
      _$StoryViewImpl _value, $Res Function(_$StoryViewImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? viewedAt = null,
    Object? user = freezed,
  }) {
    return _then(_$StoryViewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      viewedAt: null == viewedAt
          ? _value.viewedAt
          : viewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryViewImpl implements _StoryView {
  const _$StoryViewImpl(
      {required this.id,
      required this.storyId,
      required this.userId,
      required this.viewedAt,
      this.user});

  factory _$StoryViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryViewImplFromJson(json);

  @override
  final String id;
  @override
  final String storyId;
  @override
  final String userId;
  @override
  final DateTime viewedAt;
// User info (populated from join)
  @override
  final User? user;

  @override
  String toString() {
    return 'StoryView(id: $id, storyId: $storyId, userId: $userId, viewedAt: $viewedAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryViewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storyId, storyId) || other.storyId == storyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.viewedAt, viewedAt) ||
                other.viewedAt == viewedAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, storyId, userId, viewedAt, user);

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryViewImplCopyWith<_$StoryViewImpl> get copyWith =>
      __$$StoryViewImplCopyWithImpl<_$StoryViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryViewImplToJson(
      this,
    );
  }
}

abstract class _StoryView implements StoryView {
  const factory _StoryView(
      {required final String id,
      required final String storyId,
      required final String userId,
      required final DateTime viewedAt,
      final User? user}) = _$StoryViewImpl;

  factory _StoryView.fromJson(Map<String, dynamic> json) =
      _$StoryViewImpl.fromJson;

  @override
  String get id;
  @override
  String get storyId;
  @override
  String get userId;
  @override
  DateTime get viewedAt; // User info (populated from join)
  @override
  User? get user;

  /// Create a copy of StoryView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryViewImplCopyWith<_$StoryViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryLike _$StoryLikeFromJson(Map<String, dynamic> json) {
  return _StoryLike.fromJson(json);
}

/// @nodoc
mixin _$StoryLike {
  String get id => throw _privateConstructorUsedError;
  String get storyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get user => throw _privateConstructorUsedError;

  /// Serializes this StoryLike to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryLikeCopyWith<StoryLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryLikeCopyWith<$Res> {
  factory $StoryLikeCopyWith(StoryLike value, $Res Function(StoryLike) then) =
      _$StoryLikeCopyWithImpl<$Res, StoryLike>;
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      DateTime createdAt,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$StoryLikeCopyWithImpl<$Res, $Val extends StoryLike>
    implements $StoryLikeCopyWith<$Res> {
  _$StoryLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryLikeImplCopyWith<$Res>
    implements $StoryLikeCopyWith<$Res> {
  factory _$$StoryLikeImplCopyWith(
          _$StoryLikeImpl value, $Res Function(_$StoryLikeImpl) then) =
      __$$StoryLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      DateTime createdAt,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$StoryLikeImplCopyWithImpl<$Res>
    extends _$StoryLikeCopyWithImpl<$Res, _$StoryLikeImpl>
    implements _$$StoryLikeImplCopyWith<$Res> {
  __$$StoryLikeImplCopyWithImpl(
      _$StoryLikeImpl _value, $Res Function(_$StoryLikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_$StoryLikeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryLikeImpl implements _StoryLike {
  const _$StoryLikeImpl(
      {required this.id,
      required this.storyId,
      required this.userId,
      required this.createdAt,
      this.user});

  factory _$StoryLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryLikeImplFromJson(json);

  @override
  final String id;
  @override
  final String storyId;
  @override
  final String userId;
  @override
  final DateTime createdAt;
// User info (populated from join)
  @override
  final User? user;

  @override
  String toString() {
    return 'StoryLike(id: $id, storyId: $storyId, userId: $userId, createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryLikeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storyId, storyId) || other.storyId == storyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, storyId, userId, createdAt, user);

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryLikeImplCopyWith<_$StoryLikeImpl> get copyWith =>
      __$$StoryLikeImplCopyWithImpl<_$StoryLikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryLikeImplToJson(
      this,
    );
  }
}

abstract class _StoryLike implements StoryLike {
  const factory _StoryLike(
      {required final String id,
      required final String storyId,
      required final String userId,
      required final DateTime createdAt,
      final User? user}) = _$StoryLikeImpl;

  factory _StoryLike.fromJson(Map<String, dynamic> json) =
      _$StoryLikeImpl.fromJson;

  @override
  String get id;
  @override
  String get storyId;
  @override
  String get userId;
  @override
  DateTime get createdAt; // User info (populated from join)
  @override
  User? get user;

  /// Create a copy of StoryLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryLikeImplCopyWith<_$StoryLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryComment _$StoryCommentFromJson(Map<String, dynamic> json) {
  return _StoryComment.fromJson(json);
}

/// @nodoc
mixin _$StoryComment {
  String get id => throw _privateConstructorUsedError;
  String get storyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get parentCommentId => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  bool get hasLiked => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get user =>
      throw _privateConstructorUsedError; // Replies (if it's a parent comment)
  List<StoryComment> get replies => throw _privateConstructorUsedError;

  /// Serializes this StoryComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryCommentCopyWith<StoryComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCommentCopyWith<$Res> {
  factory $StoryCommentCopyWith(
          StoryComment value, $Res Function(StoryComment) then) =
      _$StoryCommentCopyWithImpl<$Res, StoryComment>;
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      String content,
      String? parentCommentId,
      int likesCount,
      bool hasLiked,
      DateTime createdAt,
      DateTime? updatedAt,
      User? user,
      List<StoryComment> replies});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$StoryCommentCopyWithImpl<$Res, $Val extends StoryComment>
    implements $StoryCommentCopyWith<$Res> {
  _$StoryCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? content = null,
    Object? parentCommentId = freezed,
    Object? likesCount = null,
    Object? hasLiked = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? user = freezed,
    Object? replies = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasLiked: null == hasLiked
          ? _value.hasLiked
          : hasLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<StoryComment>,
    ) as $Val);
  }

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryCommentImplCopyWith<$Res>
    implements $StoryCommentCopyWith<$Res> {
  factory _$$StoryCommentImplCopyWith(
          _$StoryCommentImpl value, $Res Function(_$StoryCommentImpl) then) =
      __$$StoryCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storyId,
      String userId,
      String content,
      String? parentCommentId,
      int likesCount,
      bool hasLiked,
      DateTime createdAt,
      DateTime? updatedAt,
      User? user,
      List<StoryComment> replies});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$StoryCommentImplCopyWithImpl<$Res>
    extends _$StoryCommentCopyWithImpl<$Res, _$StoryCommentImpl>
    implements _$$StoryCommentImplCopyWith<$Res> {
  __$$StoryCommentImplCopyWithImpl(
      _$StoryCommentImpl _value, $Res Function(_$StoryCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storyId = null,
    Object? userId = null,
    Object? content = null,
    Object? parentCommentId = freezed,
    Object? likesCount = null,
    Object? hasLiked = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? user = freezed,
    Object? replies = null,
  }) {
    return _then(_$StoryCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      likesCount: null == likesCount
          ? _value.likesCount
          : likesCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasLiked: null == hasLiked
          ? _value.hasLiked
          : hasLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<StoryComment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryCommentImpl implements _StoryComment {
  const _$StoryCommentImpl(
      {required this.id,
      required this.storyId,
      required this.userId,
      required this.content,
      this.parentCommentId,
      this.likesCount = 0,
      this.hasLiked = false,
      required this.createdAt,
      this.updatedAt,
      this.user,
      final List<StoryComment> replies = const []})
      : _replies = replies;

  factory _$StoryCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String storyId;
  @override
  final String userId;
  @override
  final String content;
  @override
  final String? parentCommentId;
  @override
  @JsonKey()
  final int likesCount;
  @override
  @JsonKey()
  final bool hasLiked;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// User info (populated from join)
  @override
  final User? user;
// Replies (if it's a parent comment)
  final List<StoryComment> _replies;
// Replies (if it's a parent comment)
  @override
  @JsonKey()
  List<StoryComment> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  String toString() {
    return 'StoryComment(id: $id, storyId: $storyId, userId: $userId, content: $content, parentCommentId: $parentCommentId, likesCount: $likesCount, hasLiked: $hasLiked, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, replies: $replies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storyId, storyId) || other.storyId == storyId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.parentCommentId, parentCommentId) ||
                other.parentCommentId == parentCommentId) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.hasLiked, hasLiked) ||
                other.hasLiked == hasLiked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      storyId,
      userId,
      content,
      parentCommentId,
      likesCount,
      hasLiked,
      createdAt,
      updatedAt,
      user,
      const DeepCollectionEquality().hash(_replies));

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryCommentImplCopyWith<_$StoryCommentImpl> get copyWith =>
      __$$StoryCommentImplCopyWithImpl<_$StoryCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryCommentImplToJson(
      this,
    );
  }
}

abstract class _StoryComment implements StoryComment {
  const factory _StoryComment(
      {required final String id,
      required final String storyId,
      required final String userId,
      required final String content,
      final String? parentCommentId,
      final int likesCount,
      final bool hasLiked,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final User? user,
      final List<StoryComment> replies}) = _$StoryCommentImpl;

  factory _StoryComment.fromJson(Map<String, dynamic> json) =
      _$StoryCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get storyId;
  @override
  String get userId;
  @override
  String get content;
  @override
  String? get parentCommentId;
  @override
  int get likesCount;
  @override
  bool get hasLiked;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // User info (populated from join)
  @override
  User? get user; // Replies (if it's a parent comment)
  @override
  List<StoryComment> get replies;

  /// Create a copy of StoryComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryCommentImplCopyWith<_$StoryCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateStoryRequest _$CreateStoryRequestFromJson(Map<String, dynamic> json) {
  return _CreateStoryRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStoryRequest {
  String get content => throw _privateConstructorUsedError;
  StoryType get type => throw _privateConstructorUsedError;
  StoryPrivacyLevel get privacyLevel => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get plantId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get plantData => throw _privateConstructorUsedError;
  String? get careStage => throw _privateConstructorUsedError;
  List<String>? get careTips => throw _privateConstructorUsedError;

  /// Serializes this CreateStoryRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateStoryRequestCopyWith<CreateStoryRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStoryRequestCopyWith<$Res> {
  factory $CreateStoryRequestCopyWith(
          CreateStoryRequest value, $Res Function(CreateStoryRequest) then) =
      _$CreateStoryRequestCopyWithImpl<$Res, CreateStoryRequest>;
  @useResult
  $Res call(
      {String content,
      StoryType type,
      StoryPrivacyLevel privacyLevel,
      String? mediaUrl,
      Map<String, dynamic>? metadata,
      List<String>? tags,
      String? location,
      DateTime? expiresAt,
      String? plantId,
      Map<String, dynamic>? plantData,
      String? careStage,
      List<String>? careTips});
}

/// @nodoc
class _$CreateStoryRequestCopyWithImpl<$Res, $Val extends CreateStoryRequest>
    implements $CreateStoryRequestCopyWith<$Res> {
  _$CreateStoryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? type = null,
    Object? privacyLevel = null,
    Object? mediaUrl = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? location = freezed,
    Object? expiresAt = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
    Object? careStage = freezed,
    Object? careTips = freezed,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as StoryPrivacyLevel,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value.plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      careStage: freezed == careStage
          ? _value.careStage
          : careStage // ignore: cast_nullable_to_non_nullable
              as String?,
      careTips: freezed == careTips
          ? _value.careTips
          : careTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateStoryRequestImplCopyWith<$Res>
    implements $CreateStoryRequestCopyWith<$Res> {
  factory _$$CreateStoryRequestImplCopyWith(_$CreateStoryRequestImpl value,
          $Res Function(_$CreateStoryRequestImpl) then) =
      __$$CreateStoryRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String content,
      StoryType type,
      StoryPrivacyLevel privacyLevel,
      String? mediaUrl,
      Map<String, dynamic>? metadata,
      List<String>? tags,
      String? location,
      DateTime? expiresAt,
      String? plantId,
      Map<String, dynamic>? plantData,
      String? careStage,
      List<String>? careTips});
}

/// @nodoc
class __$$CreateStoryRequestImplCopyWithImpl<$Res>
    extends _$CreateStoryRequestCopyWithImpl<$Res, _$CreateStoryRequestImpl>
    implements _$$CreateStoryRequestImplCopyWith<$Res> {
  __$$CreateStoryRequestImplCopyWithImpl(_$CreateStoryRequestImpl _value,
      $Res Function(_$CreateStoryRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? type = null,
    Object? privacyLevel = null,
    Object? mediaUrl = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? location = freezed,
    Object? expiresAt = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
    Object? careStage = freezed,
    Object? careTips = freezed,
  }) {
    return _then(_$CreateStoryRequestImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      privacyLevel: null == privacyLevel
          ? _value.privacyLevel
          : privacyLevel // ignore: cast_nullable_to_non_nullable
              as StoryPrivacyLevel,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value._plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      careStage: freezed == careStage
          ? _value.careStage
          : careStage // ignore: cast_nullable_to_non_nullable
              as String?,
      careTips: freezed == careTips
          ? _value._careTips
          : careTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStoryRequestImpl implements _CreateStoryRequest {
  const _$CreateStoryRequestImpl(
      {required this.content,
      this.type = StoryType.image,
      this.privacyLevel = StoryPrivacyLevel.public,
      this.mediaUrl,
      final Map<String, dynamic>? metadata,
      final List<String>? tags,
      this.location,
      this.expiresAt,
      this.plantId,
      final Map<String, dynamic>? plantData,
      this.careStage,
      final List<String>? careTips})
      : _metadata = metadata,
        _tags = tags,
        _plantData = plantData,
        _careTips = careTips;

  factory _$CreateStoryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStoryRequestImplFromJson(json);

  @override
  final String content;
  @override
  @JsonKey()
  final StoryType type;
  @override
  @JsonKey()
  final StoryPrivacyLevel privacyLevel;
  @override
  final String? mediaUrl;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? location;
  @override
  final DateTime? expiresAt;
  @override
  final String? plantId;
  final Map<String, dynamic>? _plantData;
  @override
  Map<String, dynamic>? get plantData {
    final value = _plantData;
    if (value == null) return null;
    if (_plantData is EqualUnmodifiableMapView) return _plantData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? careStage;
  final List<String>? _careTips;
  @override
  List<String>? get careTips {
    final value = _careTips;
    if (value == null) return null;
    if (_careTips is EqualUnmodifiableListView) return _careTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateStoryRequest(content: $content, type: $type, privacyLevel: $privacyLevel, mediaUrl: $mediaUrl, metadata: $metadata, tags: $tags, location: $location, expiresAt: $expiresAt, plantId: $plantId, plantData: $plantData, careStage: $careStage, careTips: $careTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStoryRequestImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.privacyLevel, privacyLevel) ||
                other.privacyLevel == privacyLevel) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            const DeepCollectionEquality()
                .equals(other._plantData, _plantData) &&
            (identical(other.careStage, careStage) ||
                other.careStage == careStage) &&
            const DeepCollectionEquality().equals(other._careTips, _careTips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      content,
      type,
      privacyLevel,
      mediaUrl,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_tags),
      location,
      expiresAt,
      plantId,
      const DeepCollectionEquality().hash(_plantData),
      careStage,
      const DeepCollectionEquality().hash(_careTips));

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStoryRequestImplCopyWith<_$CreateStoryRequestImpl> get copyWith =>
      __$$CreateStoryRequestImplCopyWithImpl<_$CreateStoryRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStoryRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateStoryRequest implements CreateStoryRequest {
  const factory _CreateStoryRequest(
      {required final String content,
      final StoryType type,
      final StoryPrivacyLevel privacyLevel,
      final String? mediaUrl,
      final Map<String, dynamic>? metadata,
      final List<String>? tags,
      final String? location,
      final DateTime? expiresAt,
      final String? plantId,
      final Map<String, dynamic>? plantData,
      final String? careStage,
      final List<String>? careTips}) = _$CreateStoryRequestImpl;

  factory _CreateStoryRequest.fromJson(Map<String, dynamic> json) =
      _$CreateStoryRequestImpl.fromJson;

  @override
  String get content;
  @override
  StoryType get type;
  @override
  StoryPrivacyLevel get privacyLevel;
  @override
  String? get mediaUrl;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String>? get tags;
  @override
  String? get location;
  @override
  DateTime? get expiresAt;
  @override
  String? get plantId;
  @override
  Map<String, dynamic>? get plantData;
  @override
  String? get careStage;
  @override
  List<String>? get careTips;

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateStoryRequestImplCopyWith<_$CreateStoryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryFeed _$StoryFeedFromJson(Map<String, dynamic> json) {
  return _StoryFeed.fromJson(json);
}

/// @nodoc
mixin _$StoryFeed {
  String get userId => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;
  List<Story> get stories => throw _privateConstructorUsedError;
  bool get hasUnviewedStories => throw _privateConstructorUsedError;

  /// Serializes this StoryFeed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryFeedCopyWith<StoryFeed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryFeedCopyWith<$Res> {
  factory $StoryFeedCopyWith(StoryFeed value, $Res Function(StoryFeed) then) =
      _$StoryFeedCopyWithImpl<$Res, StoryFeed>;
  @useResult
  $Res call(
      {String userId, User user, List<Story> stories, bool hasUnviewedStories});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$StoryFeedCopyWithImpl<$Res, $Val extends StoryFeed>
    implements $StoryFeedCopyWith<$Res> {
  _$StoryFeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? user = null,
    Object? stories = null,
    Object? hasUnviewedStories = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      stories: null == stories
          ? _value.stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasUnviewedStories: null == hasUnviewedStories
          ? _value.hasUnviewedStories
          : hasUnviewedStories // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryFeedImplCopyWith<$Res>
    implements $StoryFeedCopyWith<$Res> {
  factory _$$StoryFeedImplCopyWith(
          _$StoryFeedImpl value, $Res Function(_$StoryFeedImpl) then) =
      __$$StoryFeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId, User user, List<Story> stories, bool hasUnviewedStories});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$StoryFeedImplCopyWithImpl<$Res>
    extends _$StoryFeedCopyWithImpl<$Res, _$StoryFeedImpl>
    implements _$$StoryFeedImplCopyWith<$Res> {
  __$$StoryFeedImplCopyWithImpl(
      _$StoryFeedImpl _value, $Res Function(_$StoryFeedImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? user = null,
    Object? stories = null,
    Object? hasUnviewedStories = null,
  }) {
    return _then(_$StoryFeedImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      stories: null == stories
          ? _value._stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasUnviewedStories: null == hasUnviewedStories
          ? _value.hasUnviewedStories
          : hasUnviewedStories // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryFeedImpl implements _StoryFeed {
  const _$StoryFeedImpl(
      {required this.userId,
      required this.user,
      final List<Story> stories = const [],
      this.hasUnviewedStories = false})
      : _stories = stories;

  factory _$StoryFeedImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryFeedImplFromJson(json);

  @override
  final String userId;
  @override
  final User user;
  final List<Story> _stories;
  @override
  @JsonKey()
  List<Story> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  @JsonKey()
  final bool hasUnviewedStories;

  @override
  String toString() {
    return 'StoryFeed(userId: $userId, user: $user, stories: $stories, hasUnviewedStories: $hasUnviewedStories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryFeedImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._stories, _stories) &&
            (identical(other.hasUnviewedStories, hasUnviewedStories) ||
                other.hasUnviewedStories == hasUnviewedStories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, user,
      const DeepCollectionEquality().hash(_stories), hasUnviewedStories);

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryFeedImplCopyWith<_$StoryFeedImpl> get copyWith =>
      __$$StoryFeedImplCopyWithImpl<_$StoryFeedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryFeedImplToJson(
      this,
    );
  }
}

abstract class _StoryFeed implements StoryFeed {
  const factory _StoryFeed(
      {required final String userId,
      required final User user,
      final List<Story> stories,
      final bool hasUnviewedStories}) = _$StoryFeedImpl;

  factory _StoryFeed.fromJson(Map<String, dynamic> json) =
      _$StoryFeedImpl.fromJson;

  @override
  String get userId;
  @override
  User get user;
  @override
  List<Story> get stories;
  @override
  bool get hasUnviewedStories;

  /// Create a copy of StoryFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryFeedImplCopyWith<_$StoryFeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
