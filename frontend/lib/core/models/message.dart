import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leafwise/core/models/user.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  plant_identification, // Phase 2
  plant_care_tip, // Phase 2
}

enum MessageStatus { sending, sent, delivered, read, failed }

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String senderId,
    required String receiverId,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sending) MessageStatus status,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt, // For disappearing messages
    String? replyToMessageId,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    required DateTime createdAt,
    DateTime? updatedAt,

    // Sender info (populated from join)
    User? sender,

    // Plant-specific fields for Phase 2
    String? plantId,
    Map<String, dynamic>? plantData,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String userId,
    required String otherUserId,
    Message? lastMessage,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isArchived,
    @Default(false) bool isBlocked,
    DateTime? lastReadAt,
    required DateTime createdAt,
    DateTime? updatedAt,

    // Other user info (populated from join)
    User? otherUser,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String receiverId,
    required String content,
    @Default(MessageType.text) MessageType type,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    String? replyToMessageId,
    String? plantId,
    Map<String, dynamic>? plantData,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}

@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String id,
    required String messageId,
    required String userId,
    required String emoji,
    required DateTime createdAt,

    // User info (populated from join)
    User? user,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
}
