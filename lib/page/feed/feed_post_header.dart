import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/model/model_post.dart';
import 'package:nocd/model/model_reply_to.dart';
import 'package:nocd/page/feed/feed_components.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/feed/post_thread_event.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/utils_misc.dart';

class FeedPostHeader extends StatelessWidget {
  final PostThreadBloc _postThreadBloc;

  FeedPostHeader(this._postThreadBloc);

  @override
  Widget build(BuildContext context) {
    final PostModel _postModel = _postThreadBloc.postThread.post;
    final double imageWidth = MediaQuery.of(context).size.width - 48;

    return Container(
      margin: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            child: Row(
              children: <Widget>[
                ...postAvatar(
                  context,
                  _postModel,
                  () => _postThreadBloc.openUserProfile(
                      context, parseToInt(_postModel.userId)),
                ),
              ],
            ),
          ),
          postBody(context, _postModel),
          if (_postModel?.postType == "image_v1")
            Container(
              padding: EdgeInsets.only(top: 8),
              child: postImage(context, _postModel, imageWidth),
            ),
          if (_postModel?.postType == "link")
            Container(
              padding: EdgeInsets.only(top: 8),
              child: postLink(context, _postModel, imageWidth),
            ),
          if (_postModel != null) ...[
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Divider(
                height: 1,
                color: divider,
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: likeButton(_postModel, (bool bool) {
                    _postThreadBloc
                        .add(PostLike(postId: _postModel.id, like: !bool));
                    return Future.value(!bool);
                  }),
                ),
                Container(
                  width: 8,
                ),
                Align(
                  alignment: Alignment.center,
                  child: commentButton(
                    _postModel,
                    () => _postThreadBloc.add(PostComment(replyTo: ReplyTo())),
                  ),
                ),
                if (_postModel.numReplies > 0)
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
                  child: showMoreButton(context, _postModel, (String value) {
                    if (value != null) {
                      print("Show More Selected: $value");
                      switch (value) {
                        case "Delete":
                          _postThreadBloc
                              .add(PostDelete(postId: _postModel.id));
                          break;
                        case "Flag":
                          _postThreadBloc
                              .add(PostReport(postId: _postModel.id));
                          break;
                        case "Bookmark":
                          FlushbarHelperProvider.createInfo(
                                  message: !_postModel.isBookmarked
                                      ? "Bookmark Added"
                                      : "Bookmark Removed",
                                  width: 200)
                              .show(context);
                          _postThreadBloc.add(PostBookmark(
                              postId: _postModel.id,
                              bookmark: !_postModel.isBookmarked));
                          break;
                        case "Copy":
                          FlushbarHelperProvider.createInfo(message: "Copied")
                              .show(context);
                          break;
                      }
                    }
                  }),
                ),
              ],
            ),
            Divider(
              height: 1,
              color: divider,
            ),
          ]
        ],
      ),
    );
  }
}
