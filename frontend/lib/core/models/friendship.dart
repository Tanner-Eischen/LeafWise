import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plant_social/core/models/user.dart';

part 'friendship.freezed.dart';
part 'friendship.g.dart';

enum FriendshipStatus {
  pending,
  accepted,
  blocked,
  declined,
}

@freezed
class Friendship with _$Friendship {
  const factory Friendship({
    required String id,
    required String requesterId,
    required String addresseeId,
    @Default(FriendshipStatus.pending) FriendshipStatus status,
    String? message,
    DateTime? acceptedAt,
    DateTime? blockedAt,
    DateTime? declinedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // User info (populated from join)
    User? requester,
    User? addressee,
  }) = _Friendship;

  factory Friendship.fromJson(Map<String, dynamic> json) => _$FriendshipFromJson(json);
}

@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required String fromUserId,
    required String toUserId,
    String? message,
    @Default(FriendshipStatus.pending) FriendshipStatus status,
    required DateTime createdAt,
    
    // User info (populated from join)
    User? fromUser,
    User? toUser,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);
}

@freezed
class SendFriendRequestRequest with _$SendFriendRequestRequest {
  const factory SendFriendRequestRequest({
    required String toUserId,
    String? message,
  }) = _SendFriendRequestRequest;

  factory SendFriendRequestRequest.fromJson(Map<String, dynamic> json) => _$SendFriendRequestRequestFromJson(json);
}

@freezed
class FriendshipResponse with _$FriendshipResponse {
  const factory FriendshipResponse({
    required String friendshipId,
    required FriendshipStatus status,
  }) = _FriendshipResponse;

  factory FriendshipResponse.fromJson(Map<String, dynamic> json) => _$FriendshipResponseFromJson(json);
}

@freezed
class FriendsList with _$FriendsList {
  const factory FriendsList({
    @Default([]) List<User> friends,
    @Default(0) int totalCount,
    @Default(false) bool hasMore,
    String? nextCursor,
  }) = _FriendsList;

  factory FriendsList.fromJson(Map<String, dynamic> json) => _$FriendsListFromJson(json);
}

@freezed
class FriendRequestsList with _$FriendRequestsList {
  const factory FriendRequestsList({
    @Default([]) List<FriendRequest> requests,
    @Default(0) int totalCount,
    @Default(false) bool hasMore,
    String? nextCursor,
  }) = _FriendRequestsList;

  factory FriendRequestsList.fromJson(Map<String, dynamic> json) => _$FriendRequestsListFromJson(json);
}

@freezed
class MutualFriends with _$MutualFriends {
  const factory MutualFriends({
    @Default([]) List<User> friends,
    @Default(0) int count,
  }) = _MutualFriends;

  factory MutualFriends.fromJson(Map<String, dynamic> json) => _$MutualFriendsFromJson(json);
}

// Extension methods for Friendship
extension FriendshipExtension on Friendship {
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isBlocked => status == FriendshipStatus.blocked;
  bool get isDeclined => status == FriendshipStatus.declined;
  
  bool get isActive => isAccepted;
  
  String get statusText {
    switch (status) {
      case FriendshipStatus.pending:
        return 'Pending';
      case FriendshipStatus.accepted:
        return 'Friends';
      case FriendshipStatus.blocked:
        return 'Blocked';
      case FriendshipStatus.declined:
        return 'Declined';
    }
  }
  
  String get statusIcon {
    switch (status) {
      case FriendshipStatus.pending:
        return '⏳';
      case FriendshipStatus.accepted:
        return '✅';
      case FriendshipStatus.blocked:
        return '🚫';
      case FriendshipStatus.declined:
        return '❌';
    }
  }
  
  User? getOtherUser(String currentUserId) {
    if (requesterId == currentUserId) {
      return addressee;
    } else if (addresseeId == currentUserId) {
      return requester;
    }
    return null;
  }
  
  bool isRequester(String userId) {
    return requesterId == userId;
  }
  
  bool isAddressee(String userId) {
    return addresseeId == userId;
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

// Extension methods for FriendRequest
extension FriendRequestExtension on FriendRequest {
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isDeclined => status == FriendshipStatus.declined;
  
  String get statusText {
    switch (status) {
      case FriendshipStatus.pending:
        return 'Pending';
      case FriendshipStatus.accepted:
        return 'Accepted';
      case FriendshipStatus.blocked:
        return 'Blocked';
      case FriendshipStatus.declined:
        return 'Declined';
    }
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

// Extension methods for FriendsList
extension FriendsListExtension on FriendsList {
  bool get isEmpty => friends.isEmpty;
  bool get isNotEmpty => friends.isNotEmpty;
  
  List<User> get onlineFriends {
    return friends.where((friend) => friend.isOnline).toList();
  }
  
  List<User> get offlineFriends {
    return friends.where((friend) => !friend.isOnline).toList();
  }
  
  int get onlineCount => onlineFriends.length;
  int get offlineCount => offlineFriends.length;
}

// Extension methods for FriendRequestsList
extension FriendRequestsListExtension on FriendRequestsList {
  bool get isEmpty => requests.isEmpty;
  bool get isNotEmpty => requests.isNotEmpty;
  
  List<FriendRequest> get pendingRequests {
    return requests.where((request) => request.isPending).toList();
  }
  
  int get pendingCount => pendingRequests.length;
}