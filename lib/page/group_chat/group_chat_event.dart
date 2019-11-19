import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class GroupChatEvent extends Equatable {
  GroupChatEvent([List props = const []]) : super();
}

class GroupChatUpdate extends GroupChatEvent {
  GroupChatUpdate() : super();

  @override
  List<Object> get props => null;
}

class GroupChatGetData extends GroupChatEvent {
  final String requestType;

  GroupChatGetData(this.requestType) : super([requestType]);

  @override
  List<Object> get props => [requestType];
}

class GroupChatReply extends GroupChatEvent {
  final String text;

  GroupChatReply({@required this.text})
      : assert(text != null),
        super([text]);

  @override
  List<Object> get props => [text];
}

class GroupChatDelete extends GroupChatEvent {
  final int id;

  GroupChatDelete({@required this.id})
      : assert(id != null),
        super([id]);

  @override
  List<Object> get props => [id];
}

class GroupChatReport extends GroupChatEvent {
  final int id;

  GroupChatReport({@required this.id})
      : assert(id != null),
        super([id]);

  @override
  List<Object> get props => [id];
}
