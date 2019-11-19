import 'dart:convert';

class GroupUnjoined {
  int id;
  String name;
  String iconUrl;

  GroupUnjoined({
    this.id,
    this.name,
    this.iconUrl,
  });

  factory GroupUnjoined.fromJson(String str) =>
      GroupUnjoined.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GroupUnjoined.fromMap(Map<String, dynamic> json) => GroupUnjoined(
        id: json["id"],
        name: json["name"],
        iconUrl: json["icon_url"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "icon_url": iconUrl,
      };
}
