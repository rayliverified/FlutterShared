import 'dart:convert';

class ReplyTo {
  int id;
  String communityHandle;
  int level;

  ReplyTo({
    this.id,
    this.communityHandle,
    this.level,
  });

  factory ReplyTo.fromJson(String str) => ReplyTo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReplyTo.fromMap(Map<String, dynamic> json) => ReplyTo(
        id: json["id"] == null ? null : json["id"],
        communityHandle:
            json["community_handle"] == null ? null : json["community_handle"],
        level: json["level"] == null ? null : json["level"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "community_handle": communityHandle == null ? null : communityHandle,
        "level": level == null ? null : level,
      };
}
