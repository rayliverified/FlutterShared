import 'dart:convert';

class UserProfileModel {
  String avatarName;
  String communityHandle;
  String caption;
  String about;
  String avatarType;
  String avatarImg;
  String ctaText;
  String ctaUrl;
  List<String> tags;
  bool canEdit;

  UserProfileModel({
    avatarName,
    communityHandle,
    caption,
    about,
    avatarType,
    avatarImg,
    ctaText,
    ctaUrl,
    tags,
    canEdit,
  })  : this.avatarName = avatarName,
        this.communityHandle = communityHandle,
        this.caption = caption,
        this.about = about,
        this.avatarType = avatarType,
        this.avatarImg = avatarImg,
        this.ctaText = ctaText,
        this.ctaUrl = ctaUrl,
        this.tags = tags ?? [],
        this.canEdit = canEdit;

  factory UserProfileModel.fromJson(String str) =>
      UserProfileModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromMap(Map<String, dynamic> json) =>
      new UserProfileModel(
        avatarName: json["avatar_name"],
        communityHandle: json["community_handle"],
        caption: json["caption"],
        about: json["about"],
        avatarType: json["avatar_type"] == null ? null : json["avatar_type"],
        avatarImg: json["avatar_img"] == null ? null : json["avatar_img"],
        ctaText: json["cta_text"] == null ? null : json["cta_text"],
        ctaUrl: json["cta_url"] == null ? null : json["cta_url"],
        tags: new List<String>.from(json["tags"].map((x) => x)),
        canEdit: json["can_edit"],
      );

  Map<String, dynamic> toMap() => {
        "avatar_name": avatarName,
        "community_handle": communityHandle,
        "caption": caption,
        "about": about,
        "avatar_type": avatarType,
        "avatar_img": avatarImg,
        "cta_text": ctaText,
        "cta_url": ctaUrl,
        "tags": new List<dynamic>.from(tags.map((x) => x)),
        "can_edit": canEdit,
      };

  copyWith({
    String avatarName,
    String communityHandle,
    String caption,
    String about,
    String avatarType,
    String avatarImg,
    String ctaText,
    String ctaUrl,
    List<String> tags,
    bool canEdit,
  }) {
    this.avatarName = avatarName ?? this.avatarName;
    this.communityHandle = communityHandle ?? this.communityHandle;
    this.caption = caption ?? this.caption;
    this.about = about ?? this.about;
    this.avatarType = avatarType ?? this.avatarType;
    this.avatarImg = avatarImg ?? this.avatarImg;
    this.ctaText = ctaText ?? this.ctaText;
    this.ctaUrl = ctaUrl ?? this.ctaUrl;
    this.tags = tags ?? this.tags;
    this.canEdit = canEdit ?? this.canEdit;
  }

  bool get isNOCDPro =>
      this.avatarType == "nocd_pro" || this.avatarType == "nocd_advocate";
}
