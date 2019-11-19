import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nocd/model/model_reply_to.dart';

class PostModel extends Equatable {
  String avatarHandle;
  String avatarImg;
  String avatarName;
  String avatarType;
  String body;
  String communityHandle;
  String createdAt;
  int createdByModerator;
  bool currentUserRepliedOnEntry;
  bool currentUsersPost;
  int depth;
  String humanTimestamp;
  int id;
  bool isBookmarked;
  int isDeleted;
  bool isLiked;
  int likes;
  int numReplies;
  String positionType;
  int postRepliedTo;
  String postType;
  PostTypeData postTypeData;
  List<PostModel> replies;
  int reviewed;
  String reviewedBy;
  List<Topic> topics;
  bool triggerWarning;
  String type;
  String updatedAt;
  String userId;
  bool itemLast;
  bool loading;
  ReplyTo replyTo;

  PostModel({
    this.avatarHandle,
    this.avatarImg,
    this.avatarName,
    this.avatarType,
    this.body,
    this.communityHandle,
    this.createdAt,
    this.createdByModerator,
    this.currentUserRepliedOnEntry,
    this.currentUsersPost,
    this.depth,
    this.humanTimestamp,
    this.id,
    this.isBookmarked,
    this.isDeleted,
    this.isLiked,
    this.likes,
    this.numReplies,
    this.positionType,
    this.postRepliedTo,
    this.postType,
    this.postTypeData,
    this.replies,
    this.reviewed,
    this.reviewedBy,
    this.topics,
    this.triggerWarning,
    this.type,
    this.updatedAt,
    this.userId,
    this.itemLast,
    this.loading,
    this.replyTo,
  });

  factory PostModel.fromJson(String str) => PostModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostModel.fromMap(Map<String, dynamic> json) => new PostModel(
        avatarHandle:
            json["avatar_handle"] == null ? null : json["avatar_handle"],
        avatarImg: json["avatar_img"] == null ? null : json["avatar_img"],
        avatarName: json["avatar_name"] == null ? null : json["avatar_name"],
        avatarType: json["avatar_type"] == null ? null : json["avatar_type"],
        body: json["body"] == null ? null : json["body"],
        communityHandle:
            json["community_handle"] == null ? null : json["community_handle"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        createdByModerator: json["created_by_moderator"] == null
            ? null
            : json["created_by_moderator"],
        currentUserRepliedOnEntry: json["current_user_replied_on_entry"] == null
            ? null
            : json["current_user_replied_on_entry"],
        currentUsersPost: json["current_users_post"] == null
            ? null
            : json["current_users_post"],
        depth: json["depth"] == null ? null : json["depth"],
        humanTimestamp:
            json["human_timestamp"] == null ? null : json["human_timestamp"],
        id: json["id"] == null ? null : json["id"],
        isBookmarked:
            json["isBookmarked"] == null ? null : json["isBookmarked"],
        isDeleted: json["is_deleted"] == null ? null : json["is_deleted"],
        isLiked: json["is_liked"] == null ? null : json["is_liked"],
        likes: json["likes"] == null ? null : json["likes"],
        numReplies: json["num_replies"] == null ? null : json["num_replies"],
        positionType:
            json["position_type"] == null ? null : json["position_type"],
        postRepliedTo:
            json["post_replied_to"] == null ? null : json["post_replied_to"],
        postType: json["post_type"] == null ? null : json["post_type"],
        postTypeData: json["post_type_data"] == null
            ? null
            : postTypeDataConverter(json["post_type"], json["post_type_data"]),
        replies: json["replies"] == null
            ? null
            : List<PostModel>.from(
                json["replies"].map((x) => PostModel.fromMap(x))),
        reviewed: json["reviewed"] == null ? null : json["reviewed"],
        reviewedBy: json["reviewed_by"] == null ? null : json["reviewed_by"],
        topics: json["topics"] == null
            ? null
            : List<Topic>.from(json["topics"].map((x) => Topic.fromMap(x))),
        triggerWarning:
            json["trigger_warning"] == null ? null : json["trigger_warning"],
        type: json["type"] == null ? null : json["type"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        userId: json["user_id"] == null ? null : json["user_id"],
        itemLast: false,
        loading: false,
        replyTo: null,
      );

  Map<String, dynamic> toMap() => {
        "avatar_handle": avatarHandle == null ? null : avatarHandle,
        "avatar_img": avatarImg == null ? null : avatarImg,
        "avatar_name": avatarName == null ? null : avatarName,
        "avatar_type": avatarType == null ? null : avatarType,
        "body": body == null ? null : body,
        "community_handle": communityHandle == null ? null : communityHandle,
        "created_at": createdAt == null ? null : createdAt,
        "created_by_moderator":
            createdByModerator == null ? null : createdByModerator,
        "current_user_replied_on_entry": currentUserRepliedOnEntry == null
            ? null
            : currentUserRepliedOnEntry,
        "current_users_post":
            currentUsersPost == null ? null : currentUsersPost,
        "depth": depth == null ? null : depth,
        "human_timestamp": humanTimestamp == null ? null : humanTimestamp,
        "id": id == null ? null : id,
        "isBookmarked": isBookmarked == null ? null : isBookmarked,
        "is_deleted": isDeleted == null ? null : isDeleted,
        "is_liked": isLiked == null ? null : isLiked,
        "likes": likes == null ? null : likes,
        "num_replies": numReplies == null ? null : numReplies,
        "position_type": positionType == null ? null : positionType,
        "post_replied_to": postRepliedTo == null ? null : postRepliedTo,
        "post_type": postType == null ? null : postType,
        "post_type_data": postTypeData == null ? null : postTypeData,
        "replies": replies == null
            ? null
            : List<dynamic>.from(replies.map((x) => x.toMap())),
        "reviewed": reviewed == null ? null : reviewed,
        "reviewed_by": reviewedBy == null ? null : reviewedBy,
        "topics": topics == null
            ? null
            : List<dynamic>.from(topics.map((x) => x.toMap())),
        "trigger_warning": triggerWarning == null ? null : triggerWarning,
        "type": type == null ? null : type,
        "updated_at": updatedAt == null ? null : updatedAt,
        "user_id": userId == null ? null : userId,
        "item_last": itemLast ?? this.itemLast,
        "loadng": loading ?? this.loading,
        "reply_to": replyTo == null ? null : replyTo.toMap(),
      };

  PostModel updateWith({bool itemLast, bool loading, ReplyTo replyTo}) {
    this.itemLast = itemLast ?? this.itemLast;
    this.loading = loading ?? this.loading;
    this.replyTo = replyTo ?? this.replyTo;
    return this;
  }

  static List<PostModel> listDeserializerFromJson(String str) =>
      PostModel.listDeserializer(json.decode(str));

  static List<PostModel> listDeserializer(List list) {
    return List<PostModel>.generate(
        list.length, (index) => PostModel.fromMap(list[index]));
  }

  static PostTypeData postTypeDataConverter(
      String type, Map<String, dynamic> data) {
    switch (type) {
      case "link":
        return PostLinkData.fromMap(data);
      case "image_v1":
        return PostImageData.fromMap(data);
      default:
        return PostTypeData(data);
    }
  }

  @override
  List<Object> get props => [id];
}

class PostTypeData extends Equatable {
  final Map<String, dynamic> data;

  PostTypeData(this.data);

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {"data": data};

  @override
  List<Object> get props => [data];
}

class PostImageData extends PostTypeData {
  final double aspectRatio;
  final String imagePublicId;
  final String url;
  final String link;

  PostImageData({this.aspectRatio, this.imagePublicId, this.url, this.link})
      : super({
          "aspect_ratio": aspectRatio,
          "image_public_id": imagePublicId,
          "url": url,
          "link": link
        });

  factory PostImageData.fromJson(String str) =>
      PostImageData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostImageData.fromMap(Map<String, dynamic> json) => PostImageData(
        aspectRatio: json["aspect_ratio"] == null ? null : json["aspect_ratio"],
        imagePublicId:
            json["image_public_id"] == null ? null : json["image_public_id"],
        url: json["url"] == null ? null : json["url"],
        link: json["link"] == null ? null : json["link"],
      );

  Map<String, dynamic> toMap() => {
        "aspect_ratio": aspectRatio == null ? null : aspectRatio,
        "image_public_id": imagePublicId == null ? null : imagePublicId,
        "url": url == null ? null : url,
        "link": link == null ? null : link,
      };

  factory PostImageData.fromPostTypeData(PostTypeData data) =>
      PostImageData.fromMap(data.toMap());
}

class PostLinkData extends PostTypeData {
  final double aspectRatio;
  final String description;
  final String imagePublicId;
  final String title;
  final String url;

  PostLinkData({
    this.aspectRatio,
    this.description,
    this.imagePublicId,
    this.title,
    this.url,
  }) : super({
          "aspect_ratio": aspectRatio,
          "description": description,
          "image_public_id": imagePublicId,
          "title": title,
          "url": url
        });

  factory PostLinkData.fromJson(String str) =>
      PostLinkData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostLinkData.fromMap(Map<String, dynamic> json) => PostLinkData(
        aspectRatio: json["aspect_ratio"] == null ? null : json["aspect_ratio"],
        description: json["description"] == null ? null : json["description"],
        imagePublicId:
            json["image_public_id"] == null ? null : json["image_public_id"],
        title: json["title"] == null ? null : json["title"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toMap() => {
        "aspect_ratio": aspectRatio == null ? null : aspectRatio,
        "description": description == null ? null : description,
        "image_public_id": imagePublicId == null ? null : imagePublicId,
        "title": title == null ? null : title,
        "url": url == null ? null : url,
      };

  factory PostLinkData.fromPostTypeData(PostTypeData data) =>
      PostLinkData.fromMap(data.toMap());
}

class Topic {
  String topicId;
  String topicTitle;

  Topic({
    this.topicId,
    this.topicTitle,
  });

  factory Topic.fromJson(String str) => Topic.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        topicId: json["topic_id"] == null ? null : json["topic_id"],
        topicTitle: json["topic_title"] == null ? null : json["topic_title"],
      );

  Map<String, dynamic> toMap() => {
        "topic_id": topicId == null ? null : topicId,
        "topic_title": topicTitle == null ? null : topicTitle,
      };
}
