import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/model/model_post_thread.dart';
import 'package:nocd/page/feed/feed_post.dart';

class PostThreadLoadingPage extends StatelessWidget {
  final PostThread postThread;

  PostThreadLoadingPage(this.postThread) : assert(postThread != null);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: FeedPost(postThread.post));
  }
}
