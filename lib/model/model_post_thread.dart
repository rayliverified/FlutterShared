import 'package:equatable/equatable.dart';
import 'package:nocd/model/model_post.dart';

class PostThread extends Equatable {
  final int postId;
  final PostModel post;
  final List<PostModel> replies;

  PostThread(this.postId, this.post, this.replies);

  PostThread copyWith({int postID, PostModel post, List<PostModel> replies}) {
    return PostThread(
        postID ?? this.postId, post ?? this.post, replies ?? this.replies);
  }

  @override
  List<Object> get props => [postId];
}
