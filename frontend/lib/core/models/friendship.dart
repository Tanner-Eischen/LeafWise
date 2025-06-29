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