// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipImpl _$$FriendshipImplFromJson(Map<String, dynamic> json) =>
    _$FriendshipImpl(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      addresseeId: json['addresseeId'] as String,
      status: $enumDecodeNullable(_$FriendshipStatusEnumMap, json['status']) ??
          FriendshipStatus.pending,
      message: json['message'] as String?,
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      blockedAt: json['blockedAt'] == null
          ? null
          : DateTime.parse(json['blockedAt'] as String),
      declinedAt: json['declinedAt'] == null
          ? null
          : DateTime.parse(json['declinedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      requester: json['requester'] == null
          ? null
          : User.fromJson(json['requester'] as Map<String, dynamic>),
      addressee: json['addressee'] == null
          ? null
          : User.fromJson(json['addressee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FriendshipImplToJson(_$FriendshipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'addresseeId': instance.addresseeId,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'message': instance.message,
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'blockedAt': instance.blockedAt?.toIso8601String(),
      'declinedAt': instance.declinedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'requester': instance.requester,
      'addressee': instance.addressee,
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.blocked: 'blocked',
  FriendshipStatus.declined: 'declined',
};

_$FriendRequestImpl _$$FriendRequestImplFromJson(Map<String, dynamic> json) =>
    _$FriendRequestImpl(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      message: json['message'] as String?,
      status: $enumDecodeNullable(_$FriendshipStatusEnumMap, json['status']) ??
          FriendshipStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fromUser: json['fromUser'] == null
          ? null
          : User.fromJson(json['fromUser'] as Map<String, dynamic>),
      toUser: json['toUser'] == null
          ? null
          : User.fromJson(json['toUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FriendRequestImplToJson(_$FriendRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'message': instance.message,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'fromUser': instance.fromUser,
      'toUser': instance.toUser,
    };

_$SendFriendRequestRequestImpl _$$SendFriendRequestRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SendFriendRequestRequestImpl(
      toUserId: json['toUserId'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$SendFriendRequestRequestImplToJson(
        _$SendFriendRequestRequestImpl instance) =>
    <String, dynamic>{
      'toUserId': instance.toUserId,
      'message': instance.message,
    };

_$FriendshipResponseImpl _$$FriendshipResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FriendshipResponseImpl(
      friendshipId: json['friendshipId'] as String,
      status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$FriendshipResponseImplToJson(
        _$FriendshipResponseImpl instance) =>
    <String, dynamic>{
      'friendshipId': instance.friendshipId,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
    };

_$FriendsListImpl _$$FriendsListImplFromJson(Map<String, dynamic> json) =>
    _$FriendsListImpl(
      friends: (json['friends'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$$FriendsListImplToJson(_$FriendsListImpl instance) =>
    <String, dynamic>{
      'friends': instance.friends,
      'totalCount': instance.totalCount,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
    };

_$FriendRequestsListImpl _$$FriendRequestsListImplFromJson(
        Map<String, dynamic> json) =>
    _$FriendRequestsListImpl(
      requests: (json['requests'] as List<dynamic>?)
              ?.map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$$FriendRequestsListImplToJson(
        _$FriendRequestsListImpl instance) =>
    <String, dynamic>{
      'requests': instance.requests,
      'totalCount': instance.totalCount,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
    };

_$MutualFriendsImpl _$$MutualFriendsImplFromJson(Map<String, dynamic> json) =>
    _$MutualFriendsImpl(
      friends: (json['friends'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MutualFriendsImplToJson(_$MutualFriendsImpl instance) =>
    <String, dynamic>{
      'friends': instance.friends,
      'count': instance.count,
    };
