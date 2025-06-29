// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sending,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      replyToMessageId: json['replyToMessageId'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      sender: json['sender'] == null
          ? null
          : User.fromJson(json['sender'] as Map<String, dynamic>),
      plantId: json['plantId'] as String?,
      plantData: json['plantData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'replyToMessageId': instance.replyToMessageId,
      'isEdited': instance.isEdited,
      'editedAt': instance.editedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'sender': instance.sender,
      'plantId': instance.plantId,
      'plantData': instance.plantData,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.file: 'file',
  MessageType.location: 'location',
  MessageType.plant_identification: 'plant_identification',
  MessageType.plant_care_tip: 'plant_care_tip',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      otherUserId: json['otherUserId'] as String,
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      lastReadAt: json['lastReadAt'] == null
          ? null
          : DateTime.parse(json['lastReadAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      otherUser: json['otherUser'] == null
          ? null
          : User.fromJson(json['otherUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'otherUserId': instance.otherUserId,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'isMuted': instance.isMuted,
      'isArchived': instance.isArchived,
      'isBlocked': instance.isBlocked,
      'lastReadAt': instance.lastReadAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'otherUser': instance.otherUser,
    };

_$SendMessageRequestImpl _$$SendMessageRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SendMessageRequestImpl(
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      mediaUrl: json['mediaUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      replyToMessageId: json['replyToMessageId'] as String?,
      plantId: json['plantId'] as String?,
      plantData: json['plantData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SendMessageRequestImplToJson(
        _$SendMessageRequestImpl instance) =>
    <String, dynamic>{
      'receiverId': instance.receiverId,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'mediaUrl': instance.mediaUrl,
      'metadata': instance.metadata,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'replyToMessageId': instance.replyToMessageId,
      'plantId': instance.plantId,
      'plantData': instance.plantData,
    };

_$MessageReactionImpl _$$MessageReactionImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageReactionImpl(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MessageReactionImplToJson(
        _$MessageReactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'emoji': instance.emoji,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };
