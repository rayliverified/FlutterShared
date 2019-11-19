import 'dart:convert';

import 'package:equatable/equatable.dart';

class ReplyNotification extends Equatable {
  final String createdAt;
  final String message;
  final String sourceUserAvatarName;
  final String sourceUserHandle;
  final int sourceUserId;
  final int threadId;
  final String timestamp;
  final String type;
  final bool unseen;

  ReplyNotification({
    this.createdAt,
    this.message,
    this.sourceUserAvatarName,
    this.sourceUserHandle,
    this.sourceUserId,
    this.threadId,
    this.timestamp,
    this.type,
    this.unseen,
  });

  factory ReplyNotification.fromJson(String str) =>
      ReplyNotification.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReplyNotification.fromMap(Map<String, dynamic> json) =>
      ReplyNotification(
        createdAt: json["created_at"],
        message: json["message"],
        sourceUserAvatarName: json["source_user_avatar_name"],
        sourceUserHandle: json["source_user_handle"],
        sourceUserId: json["source_user_id"],
        threadId: json["thread_id"],
        timestamp: json["timestamp"],
        type: json["type"],
        unseen: json["unseen"],
      );

  Map<String, dynamic> toMap() => {
        "created_at": createdAt,
        "message": message,
        "source_user_avatar_name": sourceUserAvatarName,
        "source_user_handle": sourceUserHandle,
        "source_user_id": sourceUserId,
        "thread_id": threadId,
        "timestamp": timestamp,
        "type": type,
        "unseen": unseen,
      };

  @override
  List<Object> get props => [
        createdAt,
        message,
        sourceUserAvatarName,
        sourceUserHandle,
        sourceUserId,
        threadId,
        timestamp,
        type,
        unseen
      ];
}

class LikeNotification extends Equatable {
  final String createdAt;
  final String message;
  final int postId;
  final String sourceUserAvatarName;
  final String sourceUserHandle;
  final int sourceUserId;
  final int threadId;
  final String timestamp;
  final String type;
  final bool unseen;

  LikeNotification({
    this.createdAt,
    this.message,
    this.postId,
    this.sourceUserAvatarName,
    this.sourceUserHandle,
    this.sourceUserId,
    this.threadId,
    this.timestamp,
    this.type,
    this.unseen,
  });

  factory LikeNotification.fromJson(String str) =>
      LikeNotification.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LikeNotification.fromMap(Map<String, dynamic> json) =>
      LikeNotification(
        createdAt: json["created_at"],
        message: json["message"],
        postId: json["post_id"],
        sourceUserAvatarName: json["source_user_avatar_name"],
        sourceUserHandle: json["source_user_handle"],
        sourceUserId: json["source_user_id"],
        threadId: json["thread_id"],
        timestamp: json["timestamp"],
        type: json["type"],
        unseen: json["unseen"],
      );

  Map<String, dynamic> toMap() => {
        "created_at": createdAt,
        "message": message,
        "post_id": postId,
        "source_user_avatar_name": sourceUserAvatarName,
        "source_user_handle": sourceUserHandle,
        "source_user_id": sourceUserId,
        "thread_id": threadId,
        "timestamp": timestamp,
        "type": type,
        "unseen": unseen,
      };

  @override
  List<Object> get props => [
        createdAt,
        message,
        postId,
        sourceUserAvatarName,
        sourceUserHandle,
        sourceUserId,
        threadId,
        timestamp,
        type,
        unseen
      ];
}

class FlagNotification extends Equatable {
  final String createdAt;
  final String message;
  final int postId;
  final int threadId;
  final String timestamp;
  final String type;
  final bool unseen;

  FlagNotification({
    this.createdAt,
    this.message,
    this.postId,
    this.threadId,
    this.timestamp,
    this.type,
    this.unseen,
  });

  factory FlagNotification.fromJson(String str) =>
      FlagNotification.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FlagNotification.fromMap(Map<String, dynamic> json) =>
      FlagNotification(
        createdAt: json["created_at"],
        message: json["message"],
        postId: json["post_id"],
        threadId: json["thread_id"],
        timestamp: json["timestamp"],
        type: json["type"],
        unseen: json["unseen"],
      );

  Map<String, dynamic> toMap() => {
        "created_at": createdAt,
        "message": message,
        "post_id": postId,
        "thread_id": threadId,
        "timestamp": timestamp,
        "type": type,
        "unseen": unseen,
      };

  @override
  List<Object> get props =>
      [createdAt, message, postId, threadId, timestamp, type, unseen];
}
