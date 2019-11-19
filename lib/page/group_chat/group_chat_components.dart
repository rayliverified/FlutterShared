import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/model/model_group_information.dart';
import 'package:nocd/page/feed/feed_components.dart';
import 'package:nocd/page/group_chat/group_chat_event.dart';
import 'package:nocd/page/group_chat/page_group_chat.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/utils_text.dart';

Widget groupChatDisclaimerPage(Function onNext) {
  return PageWrapper(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(height: 42),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            child: Image.network(
              "https://res.cloudinary.com/nocdcloud/image/upload/v1571169543/static/icon_group_color.png",
              fit: BoxFit.contain,
              height: 65,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 38, vertical: 16),
            child: Text(
              "Welcome to Groups Beta! This is a place to learn from others and get to know them too.\n\nSome groups offer Group Therapy, pairing you with a licensed therapist and a few others interested in getting personalized, structured help. This feature may not be available in your location yet.\n\nYou now have exclusive access to the Groups Beta for testing purposes. With your help, we'll be able to make it even better. Note that all posts in Groups Beta will be cleared upon its completion.",
              style: TextStyle(fontSize: 20),
            ),
          ),
          NextButton(true, () => {onNext()}),
        ],
      ),
    ),
  );
}

class GroupChatMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupChatBloc = BlocProvider.of<GroupChatBloc>(context);
    List<GroupChatItemModel> messages = groupChatBloc.groupChatsModel?.messages;
    return Container(
      margin: EdgeInsets.only(top: 52),
      child: Column(children: [
        Visibility(
          visible: groupChatBloc.groupDailyModule?.isNotEmpty ?? false,
          child: Container(
            width: double.infinity,
            color: primary,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text(
                groupChatBloc.groupDailyModule?.isNotEmpty ?? false
                    ? groupChatBloc.groupDailyModule
                    : "",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        Expanded(
          // wrap in Expanded
          child: ListView.builder(
              reverse: true,
              controller: groupChatBloc.groupChatMessagesController,
              itemBuilder: (BuildContext context, int index) {
                // Display Loading Indicator if the following conditions are met:
                // - Loading more is true which means there could be more messages.
                // - Current item is the top most item.
                // - Enough items exist that loading more can be triggered.
                if (groupChatBloc.groupChatsModel?.loadMore ??
                    true &&
                        (index > ((messages?.length ?? 0) - 1)) &&
                        ((messages?.length ?? 0) >= GroupChatBloc.pageSize)) {
                  return LoadingFeedItem();
                }
                if (index == 0) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 80),
                      child: groupChatItem(
                          context, groupChatBloc, messages[index]));
                }
                // Safety check for messages index.
                if (index < messages.length) {
                  return groupChatItem(context, groupChatBloc, messages[index]);
                }

                return Container();
              },
              // If chat feed is paginating and loading more, return messages length + 1 (loading indicator).
              // Return 0 if messages is null.
              itemCount: groupChatBloc.groupChatsModel?.loadMore ?? true
                  ? (messages?.length ?? 0) + 1
                  : messages?.length ?? 0),
        ),
      ]),
    );
  }
}

Widget groupChatItem(BuildContext context, GroupChatBloc groupChatBloc,
    GroupChatItemModel model) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: model.isCurrentUsersPost
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: <Widget>[
      Flexible(
        child: Container(
          margin: EdgeInsets.only(left: 16, top: 4, right: 16),
          child: Row(
            mainAxisAlignment: model.isCurrentUsersPost
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              if (model.isCurrentUsersPost)
                showMoreButtonWrapper(context, groupChatBloc, model),
              GestureDetector(
                onTap: () => groupChatBloc.openUserProfile(context,
                    model.isCurrentUsersPost ? null : model.user.userId),
                child: Container(
                  width: 30,
                  height: 30,
                  child: getAvatarImage(model.user.userAvatar),
                ),
              ),
              Container(width: 8),
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: GestureDetector(
                  onTap: () =>
                      groupChatBloc.openUserProfile(context, model.user.userId),
                  child: Text(
                      model.isCurrentUsersPost ? "Me" : model.user.userHandle,
                      style: TextStyle(fontSize: 16, color: divider)),
                ),
              ),
              if (!model.isCurrentUsersPost)
                showMoreButtonWrapper(context, groupChatBloc, model),
            ],
          ),
        ),
      ),
      Flexible(
        child: Container(
          margin: model.isCurrentUsersPost
              ? EdgeInsets.only(top: 4, left: 16, bottom: 4)
              : EdgeInsets.only(top: 4, right: 16, bottom: 4),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(model.isCurrentUsersPost
                  ? "assets/images/bg_group_chat_user.png"
                  : "assets/images/bg_group_chat.png"),
              centerSlice: model.isCurrentUsersPost
                  ? Rect.fromLTWH(11, 12, 2, 7)
                  : Rect.fromLTWH(37, 12, 2, 7),
              colorFilter: model.isCurrentUsersPost
                  ? ColorFilter.mode(primary, BlendMode.srcATop)
                  : null,
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Container(
            margin: model.isCurrentUsersPost
                ? EdgeInsets.only(left: 16, top: 12, right: 42, bottom: 8)
                : EdgeInsets.only(left: 42, top: 12, right: 16, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: model.isCurrentUsersPost
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    model.message,
                    style: TextStyle(
                        fontSize: 18,
                        color: model.isCurrentUsersPost
                            ? Colors.white
                            : textSecondary),
                  ),
                ),
                Text(
                  TextUtils().iso8601ToShortDate(model.createdAt),
                  style: TextStyle(
                      fontSize: 14,
                      color: model.isCurrentUsersPost ? Colors.white : divider),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget showMoreButtonWrapper(
    BuildContext context, GroupChatBloc groupChatBloc, GroupChatItemModel model,
    {double size = 48}) {
  return showMoreButton(
    context,
    model,
    (String value) {
      if (value != null) {
        print("Show More Selected: $value");
        switch (value) {
          case "Delete":
            groupChatBloc.add(GroupChatDelete(id: model.id));
            break;
          case "Flag":
            groupChatBloc.openReportMessage(context, model);
            break;
          case "Copy":
            FlushbarHelperProvider.createInfo(message: "Copied").show(context);
            break;
        }
      }
    },
    size: 40,
  );
}

/**
 * Post show more button to display actionsheet.
 */
Widget showMoreButton(
    BuildContext context, GroupChatItemModel model, Function onSelected,
    {double size = 48}) {
  return Container(
    width: size,
    height: size,
    child: IconButton(
      onPressed: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        showMoreActionSheet(context, model).then(onSelected);
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: Image.asset(
        "assets/images/icon_more.png",
        color: textSecondary,
        fit: BoxFit.fill,
      ),
    ),
  );
}

/**
 * Components for ost show more ActionSheet.
 *
 * Display "Flag" option or "Delete" if post is user's.
 */
Future<String> showMoreActionSheet(
    BuildContext context, GroupChatItemModel groupChatItemModel) {
  return actionSheetBuilder(
    context: context,
    child: CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Copy'),
          onPressed: () {
            Clipboard.setData(
                new ClipboardData(text: groupChatItemModel.message));
            Navigator.pop(context, 'Copy');
          },
        ),
        if (groupChatItemModel.isCurrentUsersPost)
          CupertinoActionSheetAction(
            child: Text('Delete'),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, 'Delete'),
          )
        else
          CupertinoActionSheetAction(
            child: Text('Flag'),
            onPressed: () => Navigator.pop(context, 'Flag'),
          )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context, 'Cancel'),
      ),
    ),
  );
}

class ReplyBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final groupChatBloc = BlocProvider.of<GroupChatBloc>(context);

    return Container(
      margin: EdgeInsets.only(left: 16, top: 16, bottom: 12, right: 16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(128, 218, 218, 218),
            blurRadius: 5,
          ),
        ],
        border: Border.all(
            color: textSecondaryLight, width: 1, style: BorderStyle.solid),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: EdgeInsets.only(left: 12, top: 2, right: 8, bottom: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: TextField(
              focusNode: groupChatBloc.replyTextFocus,
              controller: groupChatBloc.replyTextController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: 16, color: textSecondary),
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Start a message...'),
            ),
          ),
          Container(
            height: 32,
            width: 76,
            child: FlatButton(
              onPressed: () {
                if (groupChatBloc.replyTextController.text.isNotEmpty) {
                  groupChatBloc.add(GroupChatReply(
                      text: groupChatBloc.replyTextController.text));
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(
                "Send",
                style: TextStyle(fontSize: 16),
              ),
              textColor: Colors.white,
              color: primary,
            ),
          )
        ]),
      ),
    );
  }
}

List<Widget> groupInformationBody(GroupInformation groupInformation) {
  return [
    Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 24, top: 8, right: 32, bottom: 8),
      child: Text(
        groupInformation.name ?? "",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        groupInformation.description ?? "",
        style: TextStyle(fontSize: 16, color: textSecondaryLight),
      ),
    ),
    Container(height: 16),
    Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Creator",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                "assets/images/image_nocd_circle.png",
                width: 35,
                height: 35,
              ),
              Text(
                "NOCD",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    Divider(height: 1, indent: 24, endIndent: 24),
    Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Total Members",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            groupInformation.totalMembers == null
                ? ""
                : groupInformation.totalMembers.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    Divider(height: 1, indent: 24, endIndent: 24),
    Container(height: 24)
  ];
}
