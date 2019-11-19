import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nocd/model/model_post_thread.dart';

abstract class PostThreadState extends Equatable {
  PostThreadState([List props = const []]) : super();
}

class PostThreadEmptyState extends PostThreadState {
  @override
  List<Object> get props => null;
}

class PostThreadLoadingState extends PostThreadState {
  @override
  List<Object> get props => null;
}

class PostThreadRefreshingState extends PostThreadState {
  final PostThread postThread;

  PostThreadRefreshingState({@required this.postThread})
      : assert(postThread != null),
        super([postThread]);

  @override
  List<Object> get props => [postThread];
}

class PostThreadLoadedState extends PostThreadState {
  final PostThread postThread;

  PostThreadLoadedState({@required this.postThread})
      : assert(postThread != null),
        super([postThread]);

  @override
  List<Object> get props => [postThread];
}
