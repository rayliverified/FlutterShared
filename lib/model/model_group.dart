import 'dart:convert';

import 'package:equatable/equatable.dart';

class GroupChatsModel extends Equatable {
  final List<GroupChatItemModel> messages;
  final bool loadMore;

  GroupChatsModel({this.messages, this.loadMore});

  GroupChatsModel copyWith({List<GroupChatItemModel> messages, bool loadMore}) {
    return GroupChatsModel(
      messages: messages ?? this.messages,
      loadMore: loadMore ?? this.loadMore,
    );
  }

  @override
  List<Object> get props => [messages, loadMore];
}

class GroupChatModel {
  final int groupId;
  final String channelId;
  final String groupName;

  GroupChatModel({
    this.groupId,
    this.channelId,
    this.groupName,
  });

  factory GroupChatModel.fromJson(String str) =>
      GroupChatModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GroupChatModel.fromMap(Map<String, dynamic> json) => GroupChatModel(
        groupId: json["id"] == null ? null : json["id"],
        channelId: json["channel_id"] == null ? null : json["channel_id"],
        groupName: json["channel_name"] == null ? null : json["channel_name"],
      );

  Map<String, dynamic> toMap() => {
        "id": groupId == null ? null : groupId,
        "channel_id": channelId == null ? null : channelId,
        "channel_name": groupName == null ? null : groupName,
      };
}

class GroupChatItemModel extends Equatable {
  final int id;
  final String message;
  final String createdAt;
  final UserAvatar user;
  final bool isCurrentUsersPost;
  final bool loading;

  GroupChatItemModel({
    this.id,
    this.message,
    this.createdAt,
    this.user,
    this.isCurrentUsersPost,
    this.loading = false,
  });

  factory GroupChatItemModel.fromJson(String str) =>
      GroupChatItemModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  static List<GroupChatItemModel> listDeserializerFromJson(String str) =>
      GroupChatItemModel.listDeserializer(json.decode(str));

  static List<GroupChatItemModel> listDeserializer(List list) {
    return List<GroupChatItemModel>.generate(
        list.length, (index) => GroupChatItemModel.fromMap(list[index]));
  }

  factory GroupChatItemModel.fromMap(Map<String, dynamic> json) =>
      GroupChatItemModel(
        id: json["id"] == null ? null : json["id"],
        message: json["message"] == null ? null : json["message"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        user: json["user"] == null ? null : UserAvatar.fromMap(json["user"]),
        isCurrentUsersPost: json["is_current_users_post"] == null
            ? null
            : json["is_current_users_post"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "message": message == null ? null : message,
        "created_at": createdAt == null ? null : createdAt,
        "user": user == null ? null : user.toMap(),
        "is_current_users_post":
            isCurrentUsersPost == null ? null : isCurrentUsersPost,
      };

  @override
  List<Object> get props => [id];
}

class UserAvatar extends Equatable {
  final int userId;
  final String userType;
  final String userAvatar;
  final String userHandle;

  UserAvatar({
    this.userId,
    this.userType,
    this.userAvatar,
    this.userHandle,
  });

  factory UserAvatar.fromJson(String str) =>
      UserAvatar.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserAvatar.fromMap(Map<String, dynamic> json) => UserAvatar(
        userId: json["user_id"] == null ? null : json["user_id"],
        userType: json["user_type"] == null ? null : json["user_type"],
        userAvatar: json["user_avatar"] == null ? null : json["user_avatar"],
        userHandle: json["user_handle"] == null ? null : json["user_handle"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId == null ? null : userId,
        "user_type": userType == null ? null : userType,
        "user_avatar": userAvatar == null ? null : userAvatar,
        "user_handle": userHandle == null ? null : userHandle,
      };

  @override
  List<Object> get props => [userId];
}
