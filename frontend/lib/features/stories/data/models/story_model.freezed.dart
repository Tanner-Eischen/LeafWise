// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_model.dart';

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
  String get username => throw _privateConstructorUsedError;
  String? get userProfilePicture => throw _privateConstructorUsedError;
  String get mediaUrl => throw _privateConstructorUsedError;
  String get mediaType =>
      throw _privateConstructorUsedError; // 'image' or 'video'
  String? get caption => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  List<String> get viewedBy => throw _privateConstructorUsedError;
  bool get isViewed => throw _privateConstructorUsedError;
  bool get isOwner => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

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
      String username,
      String? userProfilePicture,
      String mediaUrl,
      String mediaType,
      String? caption,
      DateTime createdAt,
      DateTime expiresAt,
      int viewCount,
      List<String> viewedBy,
      bool isViewed,
      bool isOwner,
      Map<String, dynamic>? metadata});
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
    Object? username = null,
    Object? userProfilePicture = freezed,
    Object? mediaUrl = null,
    Object? mediaType = null,
    Object? caption = freezed,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? viewCount = null,
    Object? viewedBy = null,
    Object? isViewed = null,
    Object? isOwner = null,
    Object? metadata = freezed,
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
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userProfilePicture: freezed == userProfilePicture
          ? _value.userProfilePicture
          : userProfilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewedBy: null == viewedBy
          ? _value.viewedBy
          : viewedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isViewed: null == isViewed
          ? _value.isViewed
          : isViewed // ignore: cast_nullable_to_non_nullable
              as bool,
      isOwner: null == isOwner
          ? _value.isOwner
          : isOwner // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
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
      String username,
      String? userProfilePicture,
      String mediaUrl,
      String mediaType,
      String? caption,
      DateTime createdAt,
      DateTime expiresAt,
      int viewCount,
      List<String> viewedBy,
      bool isViewed,
      bool isOwner,
      Map<String, dynamic>? metadata});
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
    Object? username = null,
    Object? userProfilePicture = freezed,
    Object? mediaUrl = null,
    Object? mediaType = null,
    Object? caption = freezed,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? viewCount = null,
    Object? viewedBy = null,
    Object? isViewed = null,
    Object? isOwner = null,
    Object? metadata = freezed,
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
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userProfilePicture: freezed == userProfilePicture
          ? _value.userProfilePicture
          : userProfilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewedBy: null == viewedBy
          ? _value._viewedBy
          : viewedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isViewed: null == isViewed
          ? _value.isViewed
          : isViewed // ignore: cast_nullable_to_non_nullable
              as bool,
      isOwner: null == isOwner
          ? _value.isOwner
          : isOwner // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryImpl implements _Story {
  const _$StoryImpl(
      {required this.id,
      required this.userId,
      required this.username,
      this.userProfilePicture,
      required this.mediaUrl,
      required this.mediaType,
      this.caption,
      required this.createdAt,
      required this.expiresAt,
      this.viewCount = 0,
      final List<String> viewedBy = const [],
      this.isViewed = false,
      this.isOwner = false,
      final Map<String, dynamic>? metadata})
      : _viewedBy = viewedBy,
        _metadata = metadata;

  factory _$StoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String username;
  @override
  final String? userProfilePicture;
  @override
  final String mediaUrl;
  @override
  final String mediaType;
// 'image' or 'video'
  @override
  final String? caption;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final int viewCount;
  final List<String> _viewedBy;
  @override
  @JsonKey()
  List<String> get viewedBy {
    if (_viewedBy is EqualUnmodifiableListView) return _viewedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_viewedBy);
  }

  @override
  @JsonKey()
  final bool isViewed;
  @override
  @JsonKey()
  final bool isOwner;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Story(id: $id, userId: $userId, username: $username, userProfilePicture: $userProfilePicture, mediaUrl: $mediaUrl, mediaType: $mediaType, caption: $caption, createdAt: $createdAt, expiresAt: $expiresAt, viewCount: $viewCount, viewedBy: $viewedBy, isViewed: $isViewed, isOwner: $isOwner, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userProfilePicture, userProfilePicture) ||
                other.userProfilePicture == userProfilePicture) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            const DeepCollectionEquality().equals(other._viewedBy, _viewedBy) &&
            (identical(other.isViewed, isViewed) ||
                other.isViewed == isViewed) &&
            (identical(other.isOwner, isOwner) || other.isOwner == isOwner) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      username,
      userProfilePicture,
      mediaUrl,
      mediaType,
      caption,
      createdAt,
      expiresAt,
      viewCount,
      const DeepCollectionEquality().hash(_viewedBy),
      isViewed,
      isOwner,
      const DeepCollectionEquality().hash(_metadata));

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
      required final String username,
      final String? userProfilePicture,
      required final String mediaUrl,
      required final String mediaType,
      final String? caption,
      required final DateTime createdAt,
      required final DateTime expiresAt,
      final int viewCount,
      final List<String> viewedBy,
      final bool isViewed,
      final bool isOwner,
      final Map<String, dynamic>? metadata}) = _$StoryImpl;

  factory _Story.fromJson(Map<String, dynamic> json) = _$StoryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get username;
  @override
  String? get userProfilePicture;
  @override
  String get mediaUrl;
  @override
  String get mediaType; // 'image' or 'video'
  @override
  String? get caption;
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  int get viewCount;
  @override
  List<String> get viewedBy;
  @override
  bool get isViewed;
  @override
  bool get isOwner;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateStoryRequest _$CreateStoryRequestFromJson(Map<String, dynamic> json) {
  return _CreateStoryRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStoryRequest {
  String get mediaUrl => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

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
      {String mediaUrl,
      String mediaType,
      String? caption,
      Map<String, dynamic>? metadata});
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
    Object? mediaUrl = null,
    Object? mediaType = null,
    Object? caption = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
      {String mediaUrl,
      String mediaType,
      String? caption,
      Map<String, dynamic>? metadata});
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
    Object? mediaUrl = null,
    Object? mediaType = null,
    Object? caption = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$CreateStoryRequestImpl(
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStoryRequestImpl implements _CreateStoryRequest {
  const _$CreateStoryRequestImpl(
      {required this.mediaUrl,
      required this.mediaType,
      this.caption,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$CreateStoryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStoryRequestImplFromJson(json);

  @override
  final String mediaUrl;
  @override
  final String mediaType;
  @override
  final String? caption;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CreateStoryRequest(mediaUrl: $mediaUrl, mediaType: $mediaType, caption: $caption, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStoryRequestImpl &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mediaUrl, mediaType, caption,
      const DeepCollectionEquality().hash(_metadata));

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
      {required final String mediaUrl,
      required final String mediaType,
      final String? caption,
      final Map<String, dynamic>? metadata}) = _$CreateStoryRequestImpl;

  factory _CreateStoryRequest.fromJson(Map<String, dynamic> json) =
      _$CreateStoryRequestImpl.fromJson;

  @override
  String get mediaUrl;
  @override
  String get mediaType;
  @override
  String? get caption;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of CreateStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateStoryRequestImplCopyWith<_$CreateStoryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ViewStoryRequest _$ViewStoryRequestFromJson(Map<String, dynamic> json) {
  return _ViewStoryRequest.fromJson(json);
}

/// @nodoc
mixin _$ViewStoryRequest {
  String get storyId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this ViewStoryRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ViewStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ViewStoryRequestCopyWith<ViewStoryRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewStoryRequestCopyWith<$Res> {
  factory $ViewStoryRequestCopyWith(
          ViewStoryRequest value, $Res Function(ViewStoryRequest) then) =
      _$ViewStoryRequestCopyWithImpl<$Res, ViewStoryRequest>;
  @useResult
  $Res call({String storyId, String userId});
}

/// @nodoc
class _$ViewStoryRequestCopyWithImpl<$Res, $Val extends ViewStoryRequest>
    implements $ViewStoryRequestCopyWith<$Res> {
  _$ViewStoryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ViewStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyId = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewStoryRequestImplCopyWith<$Res>
    implements $ViewStoryRequestCopyWith<$Res> {
  factory _$$ViewStoryRequestImplCopyWith(_$ViewStoryRequestImpl value,
          $Res Function(_$ViewStoryRequestImpl) then) =
      __$$ViewStoryRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String storyId, String userId});
}

/// @nodoc
class __$$ViewStoryRequestImplCopyWithImpl<$Res>
    extends _$ViewStoryRequestCopyWithImpl<$Res, _$ViewStoryRequestImpl>
    implements _$$ViewStoryRequestImplCopyWith<$Res> {
  __$$ViewStoryRequestImplCopyWithImpl(_$ViewStoryRequestImpl _value,
      $Res Function(_$ViewStoryRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ViewStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyId = null,
    Object? userId = null,
  }) {
    return _then(_$ViewStoryRequestImpl(
      storyId: null == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ViewStoryRequestImpl implements _ViewStoryRequest {
  const _$ViewStoryRequestImpl({required this.storyId, required this.userId});

  factory _$ViewStoryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ViewStoryRequestImplFromJson(json);

  @override
  final String storyId;
  @override
  final String userId;

  @override
  String toString() {
    return 'ViewStoryRequest(storyId: $storyId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewStoryRequestImpl &&
            (identical(other.storyId, storyId) || other.storyId == storyId) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, storyId, userId);

  /// Create a copy of ViewStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewStoryRequestImplCopyWith<_$ViewStoryRequestImpl> get copyWith =>
      __$$ViewStoryRequestImplCopyWithImpl<_$ViewStoryRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ViewStoryRequestImplToJson(
      this,
    );
  }
}

abstract class _ViewStoryRequest implements ViewStoryRequest {
  const factory _ViewStoryRequest(
      {required final String storyId,
      required final String userId}) = _$ViewStoryRequestImpl;

  factory _ViewStoryRequest.fromJson(Map<String, dynamic> json) =
      _$ViewStoryRequestImpl.fromJson;

  @override
  String get storyId;
  @override
  String get userId;

  /// Create a copy of ViewStoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewStoryRequestImplCopyWith<_$ViewStoryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoriesResponse _$StoriesResponseFromJson(Map<String, dynamic> json) {
  return _StoriesResponse.fromJson(json);
}

/// @nodoc
mixin _$StoriesResponse {
  List<Story> get stories => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  /// Serializes this StoriesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoriesResponseCopyWith<StoriesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoriesResponseCopyWith<$Res> {
  factory $StoriesResponseCopyWith(
          StoriesResponse value, $Res Function(StoriesResponse) then) =
      _$StoriesResponseCopyWithImpl<$Res, StoriesResponse>;
  @useResult
  $Res call(
      {List<Story> stories, bool hasMore, String? nextCursor, int totalCount});
}

/// @nodoc
class _$StoriesResponseCopyWithImpl<$Res, $Val extends StoriesResponse>
    implements $StoriesResponseCopyWith<$Res> {
  _$StoriesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stories = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
    Object? totalCount = null,
  }) {
    return _then(_value.copyWith(
      stories: null == stories
          ? _value.stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoriesResponseImplCopyWith<$Res>
    implements $StoriesResponseCopyWith<$Res> {
  factory _$$StoriesResponseImplCopyWith(_$StoriesResponseImpl value,
          $Res Function(_$StoriesResponseImpl) then) =
      __$$StoriesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Story> stories, bool hasMore, String? nextCursor, int totalCount});
}

/// @nodoc
class __$$StoriesResponseImplCopyWithImpl<$Res>
    extends _$StoriesResponseCopyWithImpl<$Res, _$StoriesResponseImpl>
    implements _$$StoriesResponseImplCopyWith<$Res> {
  __$$StoriesResponseImplCopyWithImpl(
      _$StoriesResponseImpl _value, $Res Function(_$StoriesResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stories = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
    Object? totalCount = null,
  }) {
    return _then(_$StoriesResponseImpl(
      stories: null == stories
          ? _value._stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoriesResponseImpl implements _StoriesResponse {
  const _$StoriesResponseImpl(
      {required final List<Story> stories,
      this.hasMore = false,
      this.nextCursor,
      this.totalCount = 0})
      : _stories = stories;

  factory _$StoriesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoriesResponseImplFromJson(json);

  final List<Story> _stories;
  @override
  List<Story> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? nextCursor;
  @override
  @JsonKey()
  final int totalCount;

  @override
  String toString() {
    return 'StoriesResponse(stories: $stories, hasMore: $hasMore, nextCursor: $nextCursor, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoriesResponseImpl &&
            const DeepCollectionEquality().equals(other._stories, _stories) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_stories),
      hasMore,
      nextCursor,
      totalCount);

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoriesResponseImplCopyWith<_$StoriesResponseImpl> get copyWith =>
      __$$StoriesResponseImplCopyWithImpl<_$StoriesResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoriesResponseImplToJson(
      this,
    );
  }
}

abstract class _StoriesResponse implements StoriesResponse {
  const factory _StoriesResponse(
      {required final List<Story> stories,
      final bool hasMore,
      final String? nextCursor,
      final int totalCount}) = _$StoriesResponseImpl;

  factory _StoriesResponse.fromJson(Map<String, dynamic> json) =
      _$StoriesResponseImpl.fromJson;

  @override
  List<Story> get stories;
  @override
  bool get hasMore;
  @override
  String? get nextCursor;
  @override
  int get totalCount;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoriesResponseImplCopyWith<_$StoriesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStoriesGroup _$UserStoriesGroupFromJson(Map<String, dynamic> json) {
  return _UserStoriesGroup.fromJson(json);
}

/// @nodoc
mixin _$UserStoriesGroup {
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get userProfilePicture => throw _privateConstructorUsedError;
  List<Story> get stories => throw _privateConstructorUsedError;
  bool get hasUnviewedStories => throw _privateConstructorUsedError;
  DateTime? get lastStoryTime => throw _privateConstructorUsedError;

  /// Serializes this UserStoriesGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStoriesGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStoriesGroupCopyWith<UserStoriesGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStoriesGroupCopyWith<$Res> {
  factory $UserStoriesGroupCopyWith(
          UserStoriesGroup value, $Res Function(UserStoriesGroup) then) =
      _$UserStoriesGroupCopyWithImpl<$Res, UserStoriesGroup>;
  @useResult
  $Res call(
      {String userId,
      String username,
      String? userProfilePicture,
      List<Story> stories,
      bool hasUnviewedStories,
      DateTime? lastStoryTime});
}

/// @nodoc
class _$UserStoriesGroupCopyWithImpl<$Res, $Val extends UserStoriesGroup>
    implements $UserStoriesGroupCopyWith<$Res> {
  _$UserStoriesGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStoriesGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? userProfilePicture = freezed,
    Object? stories = null,
    Object? hasUnviewedStories = null,
    Object? lastStoryTime = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userProfilePicture: freezed == userProfilePicture
          ? _value.userProfilePicture
          : userProfilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      stories: null == stories
          ? _value.stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasUnviewedStories: null == hasUnviewedStories
          ? _value.hasUnviewedStories
          : hasUnviewedStories // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStoryTime: freezed == lastStoryTime
          ? _value.lastStoryTime
          : lastStoryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStoriesGroupImplCopyWith<$Res>
    implements $UserStoriesGroupCopyWith<$Res> {
  factory _$$UserStoriesGroupImplCopyWith(_$UserStoriesGroupImpl value,
          $Res Function(_$UserStoriesGroupImpl) then) =
      __$$UserStoriesGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String username,
      String? userProfilePicture,
      List<Story> stories,
      bool hasUnviewedStories,
      DateTime? lastStoryTime});
}

/// @nodoc
class __$$UserStoriesGroupImplCopyWithImpl<$Res>
    extends _$UserStoriesGroupCopyWithImpl<$Res, _$UserStoriesGroupImpl>
    implements _$$UserStoriesGroupImplCopyWith<$Res> {
  __$$UserStoriesGroupImplCopyWithImpl(_$UserStoriesGroupImpl _value,
      $Res Function(_$UserStoriesGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserStoriesGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? userProfilePicture = freezed,
    Object? stories = null,
    Object? hasUnviewedStories = null,
    Object? lastStoryTime = freezed,
  }) {
    return _then(_$UserStoriesGroupImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userProfilePicture: freezed == userProfilePicture
          ? _value.userProfilePicture
          : userProfilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      stories: null == stories
          ? _value._stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
      hasUnviewedStories: null == hasUnviewedStories
          ? _value.hasUnviewedStories
          : hasUnviewedStories // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStoryTime: freezed == lastStoryTime
          ? _value.lastStoryTime
          : lastStoryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStoriesGroupImpl implements _UserStoriesGroup {
  const _$UserStoriesGroupImpl(
      {required this.userId,
      required this.username,
      this.userProfilePicture,
      required final List<Story> stories,
      this.hasUnviewedStories = false,
      this.lastStoryTime})
      : _stories = stories;

  factory _$UserStoriesGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStoriesGroupImplFromJson(json);

  @override
  final String userId;
  @override
  final String username;
  @override
  final String? userProfilePicture;
  final List<Story> _stories;
  @override
  List<Story> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  @JsonKey()
  final bool hasUnviewedStories;
  @override
  final DateTime? lastStoryTime;

  @override
  String toString() {
    return 'UserStoriesGroup(userId: $userId, username: $username, userProfilePicture: $userProfilePicture, stories: $stories, hasUnviewedStories: $hasUnviewedStories, lastStoryTime: $lastStoryTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStoriesGroupImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userProfilePicture, userProfilePicture) ||
                other.userProfilePicture == userProfilePicture) &&
            const DeepCollectionEquality().equals(other._stories, _stories) &&
            (identical(other.hasUnviewedStories, hasUnviewedStories) ||
                other.hasUnviewedStories == hasUnviewedStories) &&
            (identical(other.lastStoryTime, lastStoryTime) ||
                other.lastStoryTime == lastStoryTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      username,
      userProfilePicture,
      const DeepCollectionEquality().hash(_stories),
      hasUnviewedStories,
      lastStoryTime);

  /// Create a copy of UserStoriesGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStoriesGroupImplCopyWith<_$UserStoriesGroupImpl> get copyWith =>
      __$$UserStoriesGroupImplCopyWithImpl<_$UserStoriesGroupImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStoriesGroupImplToJson(
      this,
    );
  }
}

abstract class _UserStoriesGroup implements UserStoriesGroup {
  const factory _UserStoriesGroup(
      {required final String userId,
      required final String username,
      final String? userProfilePicture,
      required final List<Story> stories,
      final bool hasUnviewedStories,
      final DateTime? lastStoryTime}) = _$UserStoriesGroupImpl;

  factory _UserStoriesGroup.fromJson(Map<String, dynamic> json) =
      _$UserStoriesGroupImpl.fromJson;

  @override
  String get userId;
  @override
  String get username;
  @override
  String? get userProfilePicture;
  @override
  List<Story> get stories;
  @override
  bool get hasUnviewedStories;
  @override
  DateTime? get lastStoryTime;

  /// Create a copy of UserStoriesGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStoriesGroupImplCopyWith<_$UserStoriesGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
