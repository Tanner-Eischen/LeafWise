import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plant_social/core/models/user.dart';

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

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

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

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
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

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
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

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);
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

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
}

// Extension methods for Message
extension MessageExtension on Message {
  bool get isText => type == MessageType.text;
  bool get isMedia => [MessageType.image, MessageType.video, MessageType.audio].contains(type);
  bool get isFile => type == MessageType.file;
  bool get isLocation => type == MessageType.location;
  bool get isPlantRelated => [MessageType.plant_identification, MessageType.plant_care_tip].contains(type);
  
  bool get isSent => [MessageStatus.sent, MessageStatus.delivered, MessageStatus.read].contains(status);
  bool get isDelivered => [MessageStatus.delivered, MessageStatus.read].contains(status);
  bool get isRead => status == MessageStatus.read;
  bool get isFailed => status == MessageStatus.failed;
  bool get isPending => status == MessageStatus.sending;
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  bool get isReply => replyToMessageId != null;
  
  String get displayContent {
    if (isExpired) return 'This message has expired';
    
    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.plant_identification:
        return '🌿 Plant Identification';
      case MessageType.plant_care_tip:
        return '💡 Plant Care Tip';
    }
  }
  
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
  
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }
}

// Extension methods for Conversation
extension ConversationExtension on Conversation {
  bool get hasUnreadMessages => unreadCount > 0;
  
  String get displayName {
    return otherUser?.displayName ?? 'Unknown User';
  }
  
  String? get displayPicture {
    return otherUser?.profilePictureUrl;
  }
  
  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';
    return lastMessage!.displayContent;
  }
  
  String get lastMessageTime {
    if (lastMessage == null) return '';
    return lastMessage!.timeAgo;
  }
  
  bool get isOnline {
    return otherUser?.isOnline ?? false;
  }
}