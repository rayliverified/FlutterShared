import 'dart:convert';

class NotificationSettingsModel {
  bool postsAndComments;
  bool bookmarks;
  bool fromPro;
  bool reminders;
  bool fromNocd;

  NotificationSettingsModel({
    postsAndComments,
    bookmarks,
    fromPro,
    reminders,
    fromNocd,
  })  : this.postsAndComments = postsAndComments,
        this.bookmarks = bookmarks,
        this.fromPro = fromPro,
        this.reminders = reminders,
        this.fromNocd = fromNocd;

  factory NotificationSettingsModel.fromJson(String str) =>
      NotificationSettingsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> json) =>
      NotificationSettingsModel(
        postsAndComments: json["posts_and_comments"],
        bookmarks: json["bookmarks"],
        fromPro: json["from_pro"],
        reminders: json["reminders"],
        fromNocd: json["from_nocd"],
      );

  Map<String, dynamic> toMap() => {
        "posts_and_comments": postsAndComments,
        "bookmarks": bookmarks,
        "from_pro": fromPro,
        "reminders": reminders,
        "from_nocd": fromNocd,
      };

  copyWith({
    bool postsAndComments,
    bool bookmarks,
    bool fromPro,
    bool reminders,
    bool fromNocd,
  }) {
    this.postsAndComments = postsAndComments ?? this.postsAndComments;
    this.bookmarks = bookmarks ?? this.bookmarks;
    this.fromPro = fromPro ?? this.fromPro;
    this.reminders = reminders ?? this.reminders;
    this.fromNocd = fromNocd ?? this.fromNocd;
  }
}
