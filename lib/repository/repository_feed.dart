import 'dart:async';

import 'package:nocd/main.dart';
import 'package:nocd/model/model_post.dart';
import 'package:nocd/model/model_post_thread.dart';
import 'package:nocd/utils/network_provider.dart';

class FeedRepository {
  /// Fetch post thread by [postId] data and map to
  /// [PostThread] object. Return a [ResponseWrapper]
  /// to handle errors.
  Future<ResponseWrapper> getPostThread(int postId) async {
    StatusResponse statusResponse = await networkProvider.getPostThread(postId);
    if (statusResponse.status != null) {
      Map<String, dynamic> data = (statusResponse as DataResponse).data;
      PostModel post = PostModel.fromMap(data["post"]);
      List<PostModel> replies =
          PostModel.listDeserializer(data["nested_replies"]);
      replies = processPostThreadReplies(replies);
      PostThread postThread = PostThread(postId, post, replies);
      return ResponseWrapper(StatusResponse.success(), object: postThread);
    }

    return ResponseWrapper(statusResponse);
  }

  /// Process replies to [PostModel] objects.
  /// Expand nested replies and append styling properly.
  List<PostModel> processPostThreadReplies(List<PostModel> replies) {
    List<PostModel> repliesHolder = List();
    for (PostModel reply in replies) {
      List<PostModel> replyReplies = reply.replies;
      repliesHolder.add(reply);
      if (replyReplies != null && replyReplies.length > 0) {
        repliesHolder.addAll(replyReplies.sublist(0, replyReplies.length - 1));
        repliesHolder.add(
            replyReplies[replyReplies.length - 1].updateWith(itemLast: true));
      }
    }
    return repliesHolder;
  }
}
