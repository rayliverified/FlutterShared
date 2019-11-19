import 'dart:convert';

class GroupInformation {
  int id;
  String channelId;
  String name;
  String description;
  int totalMembers;
  bool isMember;

  GroupInformation({
    this.id,
    this.channelId,
    this.name,
    this.description,
    this.totalMembers,
    this.isMember,
  });

  factory GroupInformation.fromJson(String str) => GroupInformation.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GroupInformation.fromMap(Map<String, dynamic> json) => GroupInformation(
    id: json["id"],
    channelId: json["channel_id"],
    name: json["name"],
    description: json["description"],
    totalMembers: json["total_members"],
    isMember: json["is_member"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "channel_id": channelId,
    "name": name,
    "description": description,
    "total_members": totalMembers,
    "is_member": isMember,
  };
}
