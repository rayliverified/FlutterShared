import 'dart:convert' as model_group_joined;

class GroupJoined {
  int id;
  String channelId;
  String name;
  String iconUrl;
  int badgeCount;
  String lastMessage;
  String lastMessageTimestamp;

  GroupJoined({
    this.id,
    this.channelId,
    this.name,
    this.iconUrl,
    this.badgeCount,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  factory GroupJoined.fromJson(String str) =>
      GroupJoined.fromMap(model_group_joined.json.decode(str));

  String toJson() => model_group_joined.json.encode(toMap());

  factory GroupJoined.fromMap(Map<String, dynamic> json) => GroupJoined(
        id: json["id"],
        channelId: json["channel_id"],
        name: json["name"],
        iconUrl: json["icon_url"],
        badgeCount: json["badge_count"],
        lastMessage: json["last_message"],
        lastMessageTimestamp: json["last_message_timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "channel_id": channelId,
        "name": name,
        "icon_name": iconUrl,
        "badge_count": badgeCount,
        "last_message": lastMessage,
        "last_message_timestamp": lastMessageTimestamp,
      };
}
