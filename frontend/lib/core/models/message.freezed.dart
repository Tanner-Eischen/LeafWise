// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get expiresAt =>
      throw _privateConstructorUsedError; // For disappearing messages
  String? get replyToMessageId => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Sender info (populated from join)
  User? get sender =>
      throw _privateConstructorUsedError; // Plant-specific fields for Phase 2
  String? get plantId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get plantData => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String senderId,
      String receiverId,
      String content,
      MessageType type,
      MessageStatus status,
      String? mediaUrl,
      String? thumbnailUrl,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      String? replyToMessageId,
      bool isEdited,
      DateTime? editedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? sender,
      String? plantId,
      Map<String, dynamic>? plantData});

  $UserCopyWith<$Res>? get sender;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? content = null,
    Object? type = null,
    Object? status = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? replyToMessageId = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? sender = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
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
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as User?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value.plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String senderId,
      String receiverId,
      String content,
      MessageType type,
      MessageStatus status,
      String? mediaUrl,
      String? thumbnailUrl,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      String? replyToMessageId,
      bool isEdited,
      DateTime? editedAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? sender,
      String? plantId,
      Map<String, dynamic>? plantData});

  @override
  $UserCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? content = null,
    Object? type = null,
    Object? status = null,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? replyToMessageId = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? sender = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
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
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as User?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value._plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.content,
      this.type = MessageType.text,
      this.status = MessageStatus.sending,
      this.mediaUrl,
      this.thumbnailUrl,
      final Map<String, dynamic>? metadata,
      this.expiresAt,
      this.replyToMessageId,
      this.isEdited = false,
      this.editedAt,
      required this.createdAt,
      this.updatedAt,
      this.sender,
      this.plantId,
      final Map<String, dynamic>? plantData})
      : _metadata = metadata,
        _plantData = plantData;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String content;
  @override
  @JsonKey()
  final MessageType type;
  @override
  @JsonKey()
  final MessageStatus status;
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

  @override
  final DateTime? expiresAt;
// For disappearing messages
  @override
  final String? replyToMessageId;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  final DateTime? editedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// Sender info (populated from join)
  @override
  final User? sender;
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
  String toString() {
    return 'Message(id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, type: $type, status: $status, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, metadata: $metadata, expiresAt: $expiresAt, replyToMessageId: $replyToMessageId, isEdited: $isEdited, editedAt: $editedAt, createdAt: $createdAt, updatedAt: $updatedAt, sender: $sender, plantId: $plantId, plantData: $plantData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            const DeepCollectionEquality()
                .equals(other._plantData, _plantData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      senderId,
      receiverId,
      content,
      type,
      status,
      mediaUrl,
      thumbnailUrl,
      const DeepCollectionEquality().hash(_metadata),
      expiresAt,
      replyToMessageId,
      isEdited,
      editedAt,
      createdAt,
      updatedAt,
      sender,
      plantId,
      const DeepCollectionEquality().hash(_plantData));

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String senderId,
      required final String receiverId,
      required final String content,
      final MessageType type,
      final MessageStatus status,
      final String? mediaUrl,
      final String? thumbnailUrl,
      final Map<String, dynamic>? metadata,
      final DateTime? expiresAt,
      final String? replyToMessageId,
      final bool isEdited,
      final DateTime? editedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final User? sender,
      final String? plantId,
      final Map<String, dynamic>? plantData}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String get content;
  @override
  MessageType get type;
  @override
  MessageStatus get status;
  @override
  String? get mediaUrl;
  @override
  String? get thumbnailUrl;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get expiresAt; // For disappearing messages
  @override
  String? get replyToMessageId;
  @override
  bool get isEdited;
  @override
  DateTime? get editedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // Sender info (populated from join)
  @override
  User? get sender; // Plant-specific fields for Phase 2
  @override
  String? get plantId;
  @override
  Map<String, dynamic>? get plantData;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get otherUserId => throw _privateConstructorUsedError;
  Message? get lastMessage => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isMuted => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  DateTime? get lastReadAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Other user info (populated from join)
  User? get otherUser => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String otherUserId,
      Message? lastMessage,
      int unreadCount,
      bool isMuted,
      bool isArchived,
      bool isBlocked,
      DateTime? lastReadAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? otherUser});

  $MessageCopyWith<$Res>? get lastMessage;
  $UserCopyWith<$Res>? get otherUser;
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? isMuted = null,
    Object? isArchived = null,
    Object? isBlocked = null,
    Object? lastReadAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? otherUser = freezed,
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
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get otherUser {
    if (_value.otherUser == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.otherUser!, (value) {
      return _then(_value.copyWith(otherUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String otherUserId,
      Message? lastMessage,
      int unreadCount,
      bool isMuted,
      bool isArchived,
      bool isBlocked,
      DateTime? lastReadAt,
      DateTime createdAt,
      DateTime? updatedAt,
      User? otherUser});

  @override
  $MessageCopyWith<$Res>? get lastMessage;
  @override
  $UserCopyWith<$Res>? get otherUser;
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? isMuted = null,
    Object? isArchived = null,
    Object? isBlocked = null,
    Object? lastReadAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? otherUser = freezed,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required this.userId,
      required this.otherUserId,
      this.lastMessage,
      this.unreadCount = 0,
      this.isMuted = false,
      this.isArchived = false,
      this.isBlocked = false,
      this.lastReadAt,
      required this.createdAt,
      this.updatedAt,
      this.otherUser});

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String otherUserId;
  @override
  final Message? lastMessage;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  final DateTime? lastReadAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// Other user info (populated from join)
  @override
  final User? otherUser;

  @override
  String toString() {
    return 'Conversation(id: $id, userId: $userId, otherUserId: $otherUserId, lastMessage: $lastMessage, unreadCount: $unreadCount, isMuted: $isMuted, isArchived: $isArchived, isBlocked: $isBlocked, lastReadAt: $lastReadAt, createdAt: $createdAt, updatedAt: $updatedAt, otherUser: $otherUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.otherUser, otherUser) ||
                other.otherUser == otherUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      otherUserId,
      lastMessage,
      unreadCount,
      isMuted,
      isArchived,
      isBlocked,
      lastReadAt,
      createdAt,
      updatedAt,
      otherUser);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final String userId,
      required final String otherUserId,
      final Message? lastMessage,
      final int unreadCount,
      final bool isMuted,
      final bool isArchived,
      final bool isBlocked,
      final DateTime? lastReadAt,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final User? otherUser}) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get otherUserId;
  @override
  Message? get lastMessage;
  @override
  int get unreadCount;
  @override
  bool get isMuted;
  @override
  bool get isArchived;
  @override
  bool get isBlocked;
  @override
  DateTime? get lastReadAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt; // Other user info (populated from join)
  @override
  User? get otherUser;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) {
  return _SendMessageRequest.fromJson(json);
}

/// @nodoc
mixin _$SendMessageRequest {
  String get receiverId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get replyToMessageId => throw _privateConstructorUsedError;
  String? get plantId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get plantData => throw _privateConstructorUsedError;

  /// Serializes this SendMessageRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendMessageRequestCopyWith<SendMessageRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendMessageRequestCopyWith<$Res> {
  factory $SendMessageRequestCopyWith(
          SendMessageRequest value, $Res Function(SendMessageRequest) then) =
      _$SendMessageRequestCopyWithImpl<$Res, SendMessageRequest>;
  @useResult
  $Res call(
      {String receiverId,
      String content,
      MessageType type,
      String? mediaUrl,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      String? replyToMessageId,
      String? plantId,
      Map<String, dynamic>? plantData});
}

/// @nodoc
class _$SendMessageRequestCopyWithImpl<$Res, $Val extends SendMessageRequest>
    implements $SendMessageRequestCopyWith<$Res> {
  _$SendMessageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? receiverId = null,
    Object? content = null,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? replyToMessageId = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
  }) {
    return _then(_value.copyWith(
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value.plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SendMessageRequestImplCopyWith<$Res>
    implements $SendMessageRequestCopyWith<$Res> {
  factory _$$SendMessageRequestImplCopyWith(_$SendMessageRequestImpl value,
          $Res Function(_$SendMessageRequestImpl) then) =
      __$$SendMessageRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String receiverId,
      String content,
      MessageType type,
      String? mediaUrl,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      String? replyToMessageId,
      String? plantId,
      Map<String, dynamic>? plantData});
}

/// @nodoc
class __$$SendMessageRequestImplCopyWithImpl<$Res>
    extends _$SendMessageRequestCopyWithImpl<$Res, _$SendMessageRequestImpl>
    implements _$$SendMessageRequestImplCopyWith<$Res> {
  __$$SendMessageRequestImplCopyWithImpl(_$SendMessageRequestImpl _value,
      $Res Function(_$SendMessageRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? receiverId = null,
    Object? content = null,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? replyToMessageId = freezed,
    Object? plantId = freezed,
    Object? plantData = freezed,
  }) {
    return _then(_$SendMessageRequestImpl(
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantId: freezed == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String?,
      plantData: freezed == plantData
          ? _value._plantData
          : plantData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SendMessageRequestImpl implements _SendMessageRequest {
  const _$SendMessageRequestImpl(
      {required this.receiverId,
      required this.content,
      this.type = MessageType.text,
      this.mediaUrl,
      final Map<String, dynamic>? metadata,
      this.expiresAt,
      this.replyToMessageId,
      this.plantId,
      final Map<String, dynamic>? plantData})
      : _metadata = metadata,
        _plantData = plantData;

  factory _$SendMessageRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendMessageRequestImplFromJson(json);

  @override
  final String receiverId;
  @override
  final String content;
  @override
  @JsonKey()
  final MessageType type;
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

  @override
  final DateTime? expiresAt;
  @override
  final String? replyToMessageId;
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
  String toString() {
    return 'SendMessageRequest(receiverId: $receiverId, content: $content, type: $type, mediaUrl: $mediaUrl, metadata: $metadata, expiresAt: $expiresAt, replyToMessageId: $replyToMessageId, plantId: $plantId, plantData: $plantData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMessageRequestImpl &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            const DeepCollectionEquality()
                .equals(other._plantData, _plantData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      receiverId,
      content,
      type,
      mediaUrl,
      const DeepCollectionEquality().hash(_metadata),
      expiresAt,
      replyToMessageId,
      plantId,
      const DeepCollectionEquality().hash(_plantData));

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      __$$SendMessageRequestImplCopyWithImpl<_$SendMessageRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SendMessageRequestImplToJson(
      this,
    );
  }
}

abstract class _SendMessageRequest implements SendMessageRequest {
  const factory _SendMessageRequest(
      {required final String receiverId,
      required final String content,
      final MessageType type,
      final String? mediaUrl,
      final Map<String, dynamic>? metadata,
      final DateTime? expiresAt,
      final String? replyToMessageId,
      final String? plantId,
      final Map<String, dynamic>? plantData}) = _$SendMessageRequestImpl;

  factory _SendMessageRequest.fromJson(Map<String, dynamic> json) =
      _$SendMessageRequestImpl.fromJson;

  @override
  String get receiverId;
  @override
  String get content;
  @override
  MessageType get type;
  @override
  String? get mediaUrl;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get expiresAt;
  @override
  String? get replyToMessageId;
  @override
  String? get plantId;
  @override
  Map<String, dynamic>? get plantData;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) {
  return _MessageReaction.fromJson(json);
}

/// @nodoc
mixin _$MessageReaction {
  String get id => throw _privateConstructorUsedError;
  String get messageId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // User info (populated from join)
  User? get user => throw _privateConstructorUsedError;

  /// Serializes this MessageReaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReactionCopyWith<MessageReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReactionCopyWith<$Res> {
  factory $MessageReactionCopyWith(
          MessageReaction value, $Res Function(MessageReaction) then) =
      _$MessageReactionCopyWithImpl<$Res, MessageReaction>;
  @useResult
  $Res call(
      {String id,
      String messageId,
      String userId,
      String emoji,
      DateTime createdAt,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$MessageReactionCopyWithImpl<$Res, $Val extends MessageReaction>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? userId = null,
    Object? emoji = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of MessageReaction
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
abstract class _$$MessageReactionImplCopyWith<$Res>
    implements $MessageReactionCopyWith<$Res> {
  factory _$$MessageReactionImplCopyWith(_$MessageReactionImpl value,
          $Res Function(_$MessageReactionImpl) then) =
      __$$MessageReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageId,
      String userId,
      String emoji,
      DateTime createdAt,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$MessageReactionImplCopyWithImpl<$Res>
    extends _$MessageReactionCopyWithImpl<$Res, _$MessageReactionImpl>
    implements _$$MessageReactionImplCopyWith<$Res> {
  __$$MessageReactionImplCopyWithImpl(
      _$MessageReactionImpl _value, $Res Function(_$MessageReactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? userId = null,
    Object? emoji = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_$MessageReactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
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
class _$MessageReactionImpl implements _MessageReaction {
  const _$MessageReactionImpl(
      {required this.id,
      required this.messageId,
      required this.userId,
      required this.emoji,
      required this.createdAt,
      this.user});

  factory _$MessageReactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReactionImplFromJson(json);

  @override
  final String id;
  @override
  final String messageId;
  @override
  final String userId;
  @override
  final String emoji;
  @override
  final DateTime createdAt;
// User info (populated from join)
  @override
  final User? user;

  @override
  String toString() {
    return 'MessageReaction(id: $id, messageId: $messageId, userId: $userId, emoji: $emoji, createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, messageId, userId, emoji, createdAt, user);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      __$$MessageReactionImplCopyWithImpl<_$MessageReactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReactionImplToJson(
      this,
    );
  }
}

abstract class _MessageReaction implements MessageReaction {
  const factory _MessageReaction(
      {required final String id,
      required final String messageId,
      required final String userId,
      required final String emoji,
      required final DateTime createdAt,
      final User? user}) = _$MessageReactionImpl;

  factory _MessageReaction.fromJson(Map<String, dynamic> json) =
      _$MessageReactionImpl.fromJson;

  @override
  String get id;
  @override
  String get messageId;
  @override
  String get userId;
  @override
  String get emoji;
  @override
  DateTime get createdAt; // User info (populated from join)
  @override
  User? get user;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
