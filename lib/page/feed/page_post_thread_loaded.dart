import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocd/page/feed/feed_post_header.dart';
import 'package:nocd/page/feed/feed_reply.dart';
import 'package:nocd/page/feed/page_post_thread.dart';

class PostThreadLoadedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postThreadBloc = BlocProvider.of<PostThreadBloc>(context);

    return Expanded(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // Post has no replies. Add padding to bottom.
              if (postThreadBloc.postThread.replies.length == 0) {
                return Container(
                    padding: EdgeInsets.only(bottom: 60),
                    child: FeedPostHeader(postThreadBloc));
              }

              return FeedPostHeader(postThreadBloc);
            } else if (index == postThreadBloc.postThread.replies.length) {
              // Add padding to last reply.
              return Container(
                  padding: EdgeInsets.only(bottom: 60),
                  child:
                      FeedReply(postThreadBloc.postThread.replies[index - 1]));
            } else {
              return FeedReply(postThreadBloc.postThread.replies[index - 1]);
            }
          },
          controller: postThreadBloc.postThreadController,
          itemCount: postThreadBloc.postThread.replies.length + 1),
    );
  }
}
