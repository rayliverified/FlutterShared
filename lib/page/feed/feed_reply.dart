import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/model/model_post.dart';
import 'package:nocd/model/model_reply_to.dart';
import 'package:nocd/page/feed/feed_components.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/feed/post_thread_event.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/utils_misc.dart';

class FeedReply extends StatelessWidget {
  final PostModel _postModel;

  FeedReply(this._postModel);

  @override
  Widget build(BuildContext context) {
    final postThreadBloc = BlocProvider.of<PostThreadBloc>(context);

    return Container(
      margin: EdgeInsets.only(
          left: (_postModel.depth ?? 1) >= 2 ? 48 : 16, top: 8, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                ...postAvatar(
                  context,
                  _postModel,
                  () => postThreadBloc.openUserProfile(
                      context, parseToInt(this._postModel.userId)),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 2,
                  margin: EdgeInsets.only(left: 13, top: 6),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(3),
                    color: ((_postModel.depth ?? 1) >= 2 &&
                            _postModel.itemLast == false)
                        ? Color(0xFFDEDDDD)
                        : Colors.transparent,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(left: 10),
                        child:
                            postBody(context, _postModel, placeholderLines: 1),
                      ),
                      if (_postModel.loading != true) ...[
                        Visibility(
                          visible: _postModel.type != "flag_text_reply",
                          child: Container(
                            margin: EdgeInsets.only(left: 14),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: likeButton(_postModel, (bool bool) {
                                    postThreadBloc.add(PostLike(
                                        postId: _postModel.id, like: !bool));
                                    return Future.value(!bool);
                                  }, size: 20),
                                ),
                                Container(
                                  width: 8,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: commentButton(
                                      _postModel,
                                      () => postThreadBloc.add(
                                            PostComment(
                                                replyTo: ReplyTo(
                                                    id: _postModel.depth < 2
                                                        ? _postModel.id
                                                        : _postModel
                                                            .postRepliedTo,
                                                    communityHandle: _postModel
                                                        .communityHandle,
                                                    level: _postModel.depth)),
                                          ),
                                      size: 36),
                                ),
                                if ((_postModel.numReplies ?? 0) > 0)
                                  Container(
                                    child: Text(
                                      _postModel.numReplies.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: postIcon,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Container(),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: showMoreButton(context, _postModel,
                                      (String value) {
                                    if (value != null && value != "Cancel") {
                                      print("Show More Selected: $value");
                                      switch (value) {
                                        case "Delete":
                                          postThreadBloc.add(PostDelete(
                                              postId: _postModel.id));
                                          break;
                                        case "Flag":
                                          postThreadBloc.add(PostReport(
                                              postId: _postModel.id));
                                          break;
                                        case "Bookmark":
                                          FlushbarHelperProvider.createInfo(
                                                  message:
                                                      !_postModel.isBookmarked
                                                          ? "Bookmark Added"
                                                          : "Bookmark Removed",
                                                  width: 200)
                                              .show(context);
                                          postThreadBloc.add(PostBookmark(
                                              postId: _postModel.id,
                                              bookmark:
                                                  !_postModel.isBookmarked));
                                          break;
                                        case "Copy":
                                          FlushbarHelperProvider.createInfo(
                                                  message: "Copied")
                                              .show(context);
                                          break;
                                      }
                                    }
                                  }, size: 36),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // bottom divider
                        if ((_postModel.depth ?? 2) < 2 ||
                            _postModel.itemLast == false)
                          Container(
                            margin: _postModel.type == "flag_text_reply"
                                ? EdgeInsets.fromLTRB(0, 12, 0, 8)
                                : EdgeInsets.only(bottom: 8),
                            child: Divider(
                              indent: 16,
                              height: 1,
                              color: divider,
                            ),
                          ),
                      ],
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
