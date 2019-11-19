import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nocd/model/model_group.dart';

abstract class GroupChatState extends Equatable {
  GroupChatState([List props = const []]) : super();
}

class GroupChatEmptyState extends GroupChatState {
  @override
  List<Object> get props => null;
}

class GroupChatLoadingState extends GroupChatState {
  @override
  List<Object> get props => null;
}

class GroupChatRefreshingState extends GroupChatState {
  final GroupChatsModel groupChats;

  GroupChatRefreshingState({@required this.groupChats})
      : assert(groupChats != null),
        super([groupChats]);

  @override
  List<Object> get props => [groupChats];
}

class GroupChatLoadedState extends GroupChatState {
  final GroupChatsModel groupChats;

  GroupChatLoadedState({@required this.groupChats})
      : assert(groupChats != null),
        super([groupChats]);

  @override
  List<Object> get props => [groupChats];
}
