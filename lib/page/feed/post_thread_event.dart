import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/model/model_reply_to.dart';

abstract class PostThreadEvent extends Equatable {
  PostThreadEvent([List props = const []]) : super();
}

class PostThreadGetData extends PostThreadEvent {
  PostThreadGetData() : super();

  @override
  List<Object> get props => null;
}

class PostLike extends PostThreadEvent {
  final int postId;
  final bool like;

  PostLike({@required this.postId, @required this.like})
      : assert(postId != null),
        super([postId]);

  @override
  List<Object> get props => [postId, like];
}

class PostComment extends PostThreadEvent {
  final ReplyTo replyTo;

  PostComment({@required this.replyTo}) : super([replyTo]);

  @override
  List<Object> get props => [replyTo];
}

class PostBookmark extends PostThreadEvent {
  final int postId;
  final bool bookmark;

  PostBookmark({@required this.postId, @required this.bookmark})
      : assert(postId != null, bookmark != null),
        super([postId, bookmark]);

  @override
  List<Object> get props => [postId, bookmark];
}

class PostDelete extends PostThreadEvent {
  final int postId;

  PostDelete({@required this.postId})
      : assert(postId != null),
        super([postId]);

  @override
  List<Object> get props => [postId];
}

class PostReport extends PostThreadEvent {
  final int postId;

  PostReport({@required this.postId})
      : assert(postId != null),
        super([postId]);

  @override
  List<Object> get props => [postId];
}

class PostThreadRefresh extends PostThreadEvent {
  PostThreadRefresh() : super();

  @override
  List<Object> get props => null;
}

class PostReply extends PostThreadEvent {
  final int postId;
  final String text;

  PostReply({@required this.postId, @required this.text})
      : assert(postId != null),
        assert(text != null),
        super([postId, text]);

  @override
  List<Object> get props => [postId, text];
}
