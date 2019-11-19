import 'dart:convert';

class UserDataModel {
  final int userId;
  final String email;
  final String handle;
  final String avatar;
  final String guid;

  UserDataModel({
    this.userId,
    this.email,
    this.handle,
    this.avatar,
    this.guid,
  });

  factory UserDataModel.fromJson(String str) =>
      UserDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserDataModel.fromMap(Map<String, dynamic> json) => UserDataModel(
        userId: json["user_id"] == null ? null : json["user_id"],
        email: json["email"] == null ? null : json["email"],
        handle: json["handle"] == null ? null : json["handle"],
        avatar: json["avatar"] == null ? null : json["avatar"],
        guid: json["guid"] == null ? null : json["guid"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId == null ? null : userId,
        "email": email == null ? null : email,
        "handle": handle == null ? null : handle,
        "avatar": avatar == null ? null : avatar,
        "guid": guid == null ? null : guid,
      };
}
