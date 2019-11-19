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

class FeedPost extends StatelessWidget {
  final PostModel _postModel;

  FeedPost(this._postModel);

  @override
  Widget build(BuildContext context) {
    final postThreadBloc = BlocProvider.of<PostThreadBloc>(context);
    final double imageWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            margin: EdgeInsets.symmetric(horizontal: 16),
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
          postBody(context, _postModel),
          if (_postModel?.postType == "image_v1")
            Container(
              child: postImage(context, _postModel, imageWidth),
            ),
          if (_postModel?.postType == "link")
            Container(
              padding: EdgeInsets.only(top: 8),
              child: postLink(context, _postModel, imageWidth),
            ),
          if (_postModel.loading != true)
            Container(
              margin: EdgeInsets.only(left: 62, right: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: likeButton(_postModel, (bool bool) {
                      postThreadBloc
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
                        () => postThreadBloc.add(PostComment(
                            replyTo: ReplyTo(
                                id: _postModel.id,
                                communityHandle: _postModel.communityHandle,
                                level: _postModel?.replyTo?.level ?? 1)))),
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
                    child: showMoreButton(context, _postModel, (String value) {
                      if (value != null && value != "Cancel") {
                        print("Show More Selected: $value");
                        switch (value) {
                          case "Delete":
                            postThreadBloc
                                .add(PostDelete(postId: _postModel.id));
                            break;
                          case "Flag":
                            postThreadBloc
                                .add(PostReport(postId: _postModel.id));
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
            ),
          Visibility(
            child: Divider(
              indent: 62,
              height: 1,
              color: divider,
            ),
            visible: _postModel.loading != true,
          )
        ],
      ),
    );
  }
}
