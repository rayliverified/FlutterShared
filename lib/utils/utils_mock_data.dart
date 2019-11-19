import 'package:nocd/model/model_group.dart';

String user1AvatarJson =
    '{"user_id":17914,"user_type":"","user_avatar":"avatar_1","user_handle":"User 1"}';
UserAvatar user1Avatar = UserAvatar.fromJson(user1AvatarJson);
String user2AvatarJson =
    '{"user_id":17915,"user_type":"","user_avatar":"avatar_2","user_handle":"User 2"}';
UserAvatar user2Avatar = UserAvatar.fromJson(user2AvatarJson);
String user3AvatarJson =
    '{"user_id":18038,"user_type":"","user_avatar":"avatar_3","user_handle":"User 3"}';
UserAvatar user3Avatar = UserAvatar.fromJson(user3AvatarJson);
String currentUserAvatarJson =
    '{"user_id":21764,"user_type":"","user_avatar":"avatar_4","user_handle":"Current User"}';
UserAvatar currentUserAvatar = UserAvatar.fromJson(currentUserAvatarJson);

String groupChatItem1Json =
    '{"id":1,"message":"Message 1","created_at":"Fri, 25 Oct 2019 17:01:00 GMT","user":$user1AvatarJson,"current_users_post":false}';
GroupChatItemModel groupChatItem1 =
    GroupChatItemModel.fromJson(groupChatItem1Json);
String groupChatItem2Json =
    '{"id":2,"message":"Message 2 with longer text.","created_at":"Fri, 25 Oct 2019 17:02:00 GMT","user":$currentUserAvatarJson,"current_users_post":true}';
GroupChatItemModel groupChatItem2 =
    GroupChatItemModel.fromJson(groupChatItem1Json);
String groupChatItem3Json =
    '{"id":3,"message":"Message 3 short text.","created_at":"Fri, 25 Oct 2019 17:03:00 GMT","user":$user2AvatarJson,"current_users_post":false}';
GroupChatItemModel groupChatItem3 =
    GroupChatItemModel.fromJson(groupChatItem3Json);
String groupChatItem4Json =
    '{"id":4,"message":"Message 4 is a paragraph that will contain 5 sentences. Paragraphs are usually between three and 8 sentences. They have no line breaks between the sentences and appear visually as a block of text. A 5 sentence paragraph is the standard but they can be as short as 3 sentences. 8 sentences is the upper bound for a standardized paragraph. The number of sentences is one of the many important factors in composing a paragraph.","created_at":"Fri, 25 Oct 2019 17:04:00 GMT","user":$user3AvatarJson,"current_users_post":false}';
GroupChatItemModel groupChatItem4 =
    GroupChatItemModel.fromJson(groupChatItem4Json);
String groupChatItem5Json =
    '{"id":5,"message":"Message 5 is a message with line breaks.\\n\\nNew lines are created with blank space between them.\\n\\nThese message snippets help separate ideas and makes it easier to read.","created_at":"Fri, 25 Oct 2019 17:05:00 GMT","user":$currentUserAvatarJson,"current_users_post":true}';
GroupChatItemModel groupChatItem5 =
    GroupChatItemModel.fromJson(groupChatItem5Json);
String groupChatItem6Json =
    '{"id":6,"message":"Message 6 has fun emojis 😀 😃 😄 😁 😆","created_at":"Fri, 25 Oct 2019 17:06:00 GMT","user":$user3AvatarJson,"current_users_post":false}';
GroupChatItemModel groupChatItem6 =
    GroupChatItemModel.fromJson(groupChatItem6Json);

List groupChats = [
  groupChatItem1Json,
  groupChatItem2Json,
  groupChatItem3Json,
  groupChatItem4Json,
  groupChatItem5Json,
  groupChatItem6Json
];
