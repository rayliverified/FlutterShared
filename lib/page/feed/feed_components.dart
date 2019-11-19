import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:like_button/like_button.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_post.dart';
import 'package:nocd/model/model_reply_to.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/feed/post_thread_event.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_image.dart';
import 'package:nocd/ui/ui_misc.dart';
import 'package:nocd/ui/ui_shimmer_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/utils_image.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:nocd/utils/utils_text.dart';

Widget postBody(BuildContext context, PostModel postModel,
    {int placeholderLines = 3}) {
  final double lineHeight = 20;

  return Align(
    alignment: Alignment.topLeft,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: visibilityWrapper(
          Container(
            height: (lineHeight + 4) * placeholderLines,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerText(
              lineCount: placeholderLines,
              lineHeight: lineHeight,
              lineRadius: lineHeight / 2,
            ),
          ),
          Visibility(
            child: postModel.type == "flag_text_reply"
                ? Html(
                    data: postModel?.body,
                    onLinkTap: (url) {
                      AppBloc appBloc = BlocProvider.of<AppBloc>(context);
                      DeviceUtils().openUrl(appBloc, url);
                    },
                    defaultTextStyle: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  )
                : Linkify(
                    text: postModel?.body,
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.left,
                    onOpen: (link) {
                      AppBloc appBloc = BlocProvider.of<AppBloc>(context);
                      DeviceUtils().openUrl(appBloc, link.url);
                    }),
            visible: postModel?.body?.isNotEmpty ?? false,
          ),
          postModel.loading),
    ),
  );
}

Widget postImage(BuildContext context, PostModel postModel, double imageWidth) {
  return GestureDetector(
    onTap: () {
      AppBloc appBloc = BlocProvider.of<AppBloc>(context);
      DeviceUtils()
          .openUrl(appBloc, (postModel.postTypeData as PostImageData).link);
    },
    child: Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      child: ImageFixedWidth(
          ImageUtils.getCloudinaryThumbnail(
              (postModel.postTypeData as PostImageData).imagePublicId),
          imageWidth,
          imageRatio:
              1 / (postModel.postTypeData as PostImageData).aspectRatio),
    ),
  );
}

Widget postLink(BuildContext context, PostModel postModel, double imageWidth) {
  return GestureDetector(
    onTap: () {
      AppBloc appBloc = BlocProvider.of<AppBloc>(context);
      DeviceUtils().openUrl(
          appBloc, PostLinkData.fromPostTypeData(postModel.postTypeData).url);
    },
    child: Container(
      decoration:
          BoxDecoration(border: Border.all(color: postOutline, width: 1)),
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        children: <Widget>[
          ImageFixedWidth(
              ImageUtils.getCloudinaryThumbnail(
                  (postModel.postTypeData as PostLinkData).imagePublicId),
              imageWidth,
              imageRatio:
                  1 / (postModel.postTypeData as PostLinkData).aspectRatio),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 4),
            child: Text(
              (postModel.postTypeData as PostLinkData).title,
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              TextUtils.getDomainName(
                  (postModel.postTypeData as PostLinkData).url),
              style: TextStyle(
                color: textSecondaryLight,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

List<Widget> postAvatar(
    BuildContext context, PostModel postModel, Function onOpenUserProfile) {
  List<TextSpan> getTextSpans(PostModel postModel) {
    List<TextSpan> l = [];
    if (postModel.communityHandle != null) {
      l.add(TextSpan(
          text: postModel.communityHandle,
          recognizer: TapGestureRecognizer()..onTap = onOpenUserProfile));
      if (postModel.humanTimestamp != null) {
        l.add(TextSpan(text: " • " + postModel.humanTimestamp));
      }
    } else {
      l.add(TextSpan(text: ""));
    }

    return l;
  }

  return [
    Align(
      alignment: Alignment.center,
      child: GestureDetector(
          onTap: onOpenUserProfile,
          child: Container(
              decoration: (postModel.avatarType == "nocd_advocate" ||
                      postModel.avatarType == "nocd_pro")
                  ? BoxDecoration(shape: BoxShape.circle, color: blue)
                  : null,
              width: 28,
              height: 28,
              margin: EdgeInsets.only(
                  right: (postModel.avatarType == "nocd_advocate" ||
                          postModel.avatarType == "nocd_pro")
                      ? 8
                      : 4),
              padding: EdgeInsets.all(2),
              child: visibilityWrapper(
                  ShimmerRound(),
                  getPostAvatar(postModel.avatarType,
                      avatarName: postModel.avatarName,
                      avatarImg: postModel.avatarImg,
                      res: 50),
                  postModel.loading))),
    ),
    visibilityWrapper(
        ShimmerRectangle(height: 16, width: 120),
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            children: <Widget>[
              if (postModel.avatarType == "nocd_advocate" ||
                  postModel.avatarType == "nocd_pro")
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(right: 4),
                  child: Image.asset("assets/images/icon_profile.png"),
                ),
              RichText(
                text: TextSpan(
                  text: "",
                  style: TextStyle(
                    color: (postModel.avatarType == "nocd_advocate" ||
                            postModel.avatarType == "nocd_pro")
                        ? blue
                        : textSecondaryLight,
                    fontSize: 12,
                  ),
                  children: getTextSpans(postModel),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        postModel.loading),
  ];
}

LikeButton likeButton(PostModel postModel, Function onTap, {double size = 24}) {
  return LikeButton(
    isLiked: postModel?.isLiked ?? false,
    likeBuilder: (bool isLiked) {
      return ImageIcon(
        AssetImage(
          !isLiked
              ? "assets/images/icon_heart.png"
              : "assets/images/icon_heart_selected.png",
        ),
        color: !isLiked ? postIcon : postIconSelected,
      );
    },
    size: size,
    likeCount: postModel?.likes,
    likeCountPadding: EdgeInsets.only(left: 8),
    countBuilder: (int count, bool isLiked, String text) {
      return (count > 0)
          ? Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                color: postIcon,
              ),
            )
          : Container(
              width: 8,
            );
    },
    onTap: onTap,
  );
}

class BookmarkButton extends StatelessWidget {
  final PostModel postModel;
  final Function onPressed;
  bool pressed = false;
  double size;

  BookmarkButton(this.postModel, this.onPressed, {double size = 48}) {
    pressed = postModel?.isBookmarked;
    this.size = size;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: size,
        height: size,
        child: IconButton(
          onPressed: () {
            setState(() {
              pressed = !pressed;
            });
            onPressed();
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          icon: ImageIcon(
            AssetImage(
              !pressed
                  ? "assets/images/icon_bookmark_outline.png"
                  : "assets/images/icon_bookmark.png",
            ),
            color: !pressed ? postIcon : primary,
          ),
        ),
      );
    });
  }
}

Widget commentButton(PostModel postModel, Function onTap, {double size = 48}) {
  return Container(
    width: size,
    height: size,
    child: IconButton(
      onPressed: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: ImageIcon(
        AssetImage(
          (postModel?.currentUserRepliedOnEntry ?? false)
              ? "assets/images/icon_comment_selected.png"
              : "assets/images/icon_comment.png",
        ),
        color: postModel?.currentUserRepliedOnEntry ?? false
            ? postIconSelected
            : postIcon,
      ),
    ),
  );
}

/**
 * Post show more button to display actionsheet.
 */
Widget showMoreButton(
    BuildContext context, PostModel postModel, Function onSelected,
    {double size = 48}) {
  return Container(
    width: size,
    height: size,
    child: IconButton(
      onPressed: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        showMoreActionSheet(context, postModel).then(onSelected);
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: Image.asset(
        "assets/images/icon_more.png",
        color: postIconLightshift,
        fit: BoxFit.fill,
      ),
    ),
  );
}

/**
 * ActionSheet wrapper for [CupertinoActionSheet].
 */
Future<String> actionSheetBuilder({BuildContext context, Widget child}) {
  return showCupertinoModalPopup<String>(
    context: context,
    builder: (BuildContext context) => child,
  );
}

/**
 * Components for ost show more ActionSheet.
 *
 * Display "Flag" option or "Delete" if post is user's.
 */
Future<String> showMoreActionSheet(BuildContext context, PostModel postModel) {
  return actionSheetBuilder(
    context: context,
    child: CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Copy'),
          onPressed: () {
            Clipboard.setData(new ClipboardData(text: postModel.body));
            Navigator.pop(context, 'Copy');
          },
        ),
        if (postModel.currentUsersPost)
          CupertinoActionSheetAction(
            child: Text('Delete'),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, 'Delete'),
          )
        else ...[
          CupertinoActionSheetAction(
            child:
                Text(!postModel.isBookmarked ? 'Bookmark' : 'Remove Bookmark'),
            onPressed: () => Navigator.pop(context, 'Bookmark'),
          ),
          CupertinoActionSheetAction(
            child: Text('Flag'),
            onPressed: () => Navigator.pop(context, 'Flag'),
          )
        ]
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
    final postThreadBloc =
        flutter_bloc.BlocProvider.of<PostThreadBloc>(context);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder(
            stream: postThreadBloc.getReplyTo,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null &&
                  (snapshot.data as ReplyTo).communityHandle != null) {
                return Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  padding: EdgeInsets.only(top: 4, bottom: 3),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(width: 1, color: divider)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          margin: EdgeInsets.only(left: 4),
                          child: RichText(
                            text: TextSpan(
                              text: "Replying to ",
                              style: TextStyle(
                                  color: textSecondaryLight, fontSize: 14),
                              children: <TextSpan>[
                                TextSpan(
                                    text: (snapshot.data as ReplyTo)
                                        .communityHandle,
                                    style: TextStyle(color: textPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          onPressed: () {
                            postThreadBloc.updateReplyTo(null);
                          },
                          icon: Image.asset(
                            "assets/images/close_blue.png",
                            color: textSecondary,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }

              return Container(width: 0, height: 0);
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.only(left: 12, top: 2, right: 8, bottom: 2),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: TextField(
                  focusNode: postThreadBloc.replyTextFocus,
                  controller: postThreadBloc.replyTextController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(fontSize: 16, color: textSecondary),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add your comment...'),
                ),
              ),
              Container(
                height: 32,
                width: 76,
                child: FlatButton(
                  onPressed: () {
                    if (postThreadBloc.replyTextController.text.isNotEmpty) {
                      postThreadBloc.add(PostReply(
                          postId: postThreadBloc.postId,
                          text: ((postThreadBloc.replyTo != null &&
                                      postThreadBloc.replyTo.level == 2)
                                  ? "@" +
                                      postThreadBloc.replyTo.communityHandle +
                                      " "
                                  : "") +
                              postThreadBloc.replyTextController.text));
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Text(
                    "Share",
                    style: TextStyle(fontSize: 16),
                  ),
                  textColor: Colors.white,
                  color: primary,
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
