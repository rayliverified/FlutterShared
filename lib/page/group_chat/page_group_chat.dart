import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pubnub/pubnub.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/model/model_user_data.dart';
import 'package:nocd/page/group_chat/group_chat_components.dart';
import 'package:nocd/page/group_chat/group_chat_event.dart';
import 'package:nocd/page/group_chat/group_chat_state.dart';
import 'package:nocd/page/group_chat/page_group_chat_menu.dart';
import 'package:nocd/page/page_report_message.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/repository/repository_group_chat.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/LifecycleObserver.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart' as prefix0;
import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:uuid/uuid.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  static const int pageSize = 20;
  static const int scrollThreshold = 200;
  AppBloc appBloc;
  final String screenEventName = "goup_chat_chat";
  GroupChatRepository groupChatRepository;
  GroupChatModel groupChatModel;
  BuildContext context;
  StreamSubscription backEventListener;
  LifecycleObserver lifecycleObserver;
  FocusNode replyTextFocus = FocusNode();
  TextEditingController replyTextController;
  ScrollController groupChatMessagesController;
  GroupChatsModel groupChatsModel;
  UserDataModel userDataModel;
  String groupDailyModule;
  PubNub pubNub;
  bool loading = false;

  GroupChatBloc(
      BuildContext context, int groupId, GroupChatModel groupChatModel) {
    print("Group Chat Bloc Built");
    this.context = context;
    appBloc = prefix0.BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      Navigator.maybePop(context);
    });
    initLifecycleObserver();
    WidgetsBinding.instance.addObserver(lifecycleObserver);
    groupChatRepository = GroupChatRepository();
    replyTextController = TextEditingController();
    groupChatMessagesController = ScrollController();
    groupChatMessagesController.addListener(onScroll);
    pubNub = PubNub(PubNubConfig(appBloc.flavorConfig.values.pubnubPublishKey,
        appBloc.flavorConfig.values.pubnubSubscribeKey,
        presenceTimeout: 60, uuid: appBloc.flutterConfig.guid));
    getData(groupId, groupChatModel);
    getUserDataRequest();
    getDailyModuleRequest(groupId);
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  @override
  Future<void> close() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    backEventListener.cancel();
    pubNub.dispose();
    replyTextFocus.dispose();
    replyTextController.dispose();
    groupChatMessagesController.dispose();
    return super.close();
  }

  /// Get [GroupChatModel] data.
  /// Load model from [groupChatModel] or fetch model from network via [groupId].
  void getData(int groupId, GroupChatModel groupChatModel) {
    if (groupChatModel != null) {
      this.groupChatModel = groupChatModel;
      add(GroupChatGetData("latest"));
      subscribePubNub();
      return;
    }
  }

  void initLifecycleObserver() {
    AsyncCallback onResumeCallback = () {
      print("Group Chat OnResume");
      add(GroupChatGetData("greater_than"));
      return;
    };
    AsyncCallback onPauseCallback = () {
      print("Group Chat OnPause");
      return;
    };
    lifecycleObserver = LifecycleObserver(
        onResumeCallback: onResumeCallback, onPauseCallback: onPauseCallback);
  }

  void showError(String errorMessage) {
    // PostFrameCallback enables dialog on page load error.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      alertError(context, errorMessage, () {
        add(GroupChatGetData("latest"));
        Navigator.pop(context);
      });
    });
  }

  @override
  GroupChatState get initialState => GroupChatLoadingState();

  @override
  Stream<GroupChatState> mapEventToState(GroupChatEvent event) async* {
    // Load messages if not currently loading.
    if (event is GroupChatGetData && !loading) {
      loading = true;
      yield* groupChatLoad(event.requestType);
    }
    if (event is GroupChatUpdate) {
      yield* refreshGroupChatLoaded(groupChatsModel);
    }
    // Remove message and update UI.
    if (event is GroupChatDelete) {
      print("Delete: ${event.id}");
      StatusResponse response =
          await networkProvider.postDeleteGroupChatMessage(event.id);
      if (response.status != null) {
        // Remove message by message ID.
        List<GroupChatItemModel> messageHolder = groupChatsModel.messages;
        messageHolder.remove(GroupChatItemModel(id: event.id));
        groupChatsModel = groupChatsModel.copyWith(messages: messageHolder);
      } else {
        showError(response.error?.errorMessage);
        return;
      }
      yield* refreshGroupChatLoaded(groupChatsModel);
    }
    // Display user reply immediately in UI and send to backend.
    if (event is GroupChatReply) {
      print("Reply: ${event.text}");
      // Save reply object because original needs to be cleared.
      // Clear reply and reset UI.
      replyTextController.clear();
      // Create reply copy.
      List<GroupChatItemModel> repliesHolder = groupChatsModel.messages;
      // Add placeholder reply.
      repliesHolder.insert(
          0,
          GroupChatItemModel(
              message: event.text,
              user: UserAvatar(
                  userAvatar: userDataModel.avatar,
                  userHandle: "Me",
                  userId: userDataModel.userId,
                  userType: ""),
              createdAt: DateTime.now().toIso8601String(),
              isCurrentUsersPost: true,
              loading: true));
      // Update post thread with new replies.
      groupChatsModel = groupChatsModel.copyWith(messages: repliesHolder);
      // Update UI with placeholder reply immediately.
      yield* refreshGroupChatLoaded(groupChatsModel);
      // Jump immediately to bottom because there could be a lot of replies
      // Scrolling to bottom creates a floating behavior when scroll distance is large.
      groupChatMessagesController
          .jumpTo(groupChatMessagesController.position.minScrollExtent);
      // Smooth scroll reply into final position.
      scrollToTopAsync(groupChatMessagesController, 300);
      // Send reply to server.
      // Generate UUID to ensure message is unique.
      var uuid = new Uuid();
      StatusResponse response = await networkProvider.postGroupChatMessage(
          groupChatModel.groupId, event.text, uuid.v4());
      if (response.status != null) {
        print("Group Chat Post Response OK");
      } else {
        showError(response.error.errorMessage);
        return;
      }
      // Refresh request.
      yield* groupChatLoad("latest");
      // Smooth scroll to final position because placeholder
      // and actual reply size is not exactly the same.
      scrollToTopAsync(groupChatMessagesController, 100);
    }
  }

  Stream<GroupChatState> refreshGroupChatLoaded(
      GroupChatsModel groupChatsModel) async* {
    if (state is GroupChatLoadedState) {
      yield GroupChatRefreshingState(groupChats: groupChatsModel);
    } else {
      yield GroupChatLoadedState(groupChats: groupChatsModel);
    }
  }

  // BEGIN: Navigation Methods.
  void savePage() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    backEventListener.cancel();
  }

  void restorePage(BuildContext context) {
    appBloc.sendFlutterScreenStartEvent(screenEventName);
    WidgetsBinding.instance.addObserver(lifecycleObserver);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Group Chat Back Event Received");
      Navigator.maybePop(context);
    });
  }

  void openUserProfile(BuildContext context, int userId) async {
    savePage();
    final userProfilePage = UserProfilePageWrapper(userId: userId);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userProfilePage),
    ).then((_) {
      WidgetsBinding.instance.addObserver(lifecycleObserver);
      backEventListener = appBloc.backEventController.listen((_) {
        print("Group Chat Back Event Received");
        Navigator.maybePop(context);
      });
      add(GroupChatGetData("greater_than"));
    });
  }

  void openReportMessage(
      BuildContext context, GroupChatItemModel groupChatItemModel) async {
    savePage();
    final reportMessagePage =
        ReportMessagePageWrapper(groupChatItemModel: groupChatItemModel);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => reportMessagePage),
    ).then((_) {
      restorePage(context);
      // Refresh feed because feed contents could have changed.
      add(GroupChatGetData("latest"));
    });
  }

  void openGroupChatSettings(
      BuildContext context, GroupChatModel groupChatModel) async {
    savePage();
    final groupChatSettingsPage =
        GroupChatMenuPageWrapper(groupChatModel: groupChatModel);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => groupChatSettingsPage),
    ).then((_) {
      restorePage(context);
      // Refresh feed because feed contents could have changed.
      add(GroupChatGetData("greater_than"));
    });
  }
  // END: Navigation Methods.

  // BEGIN: Network Methods.
  /*
   * Load user data.
   *
   * User data information for user handle and avatar.
   */
  void getUserDataRequest() async {
    await networkProvider.getUserData().then((value) {
      if (value.status != null) {
        var data = (value as DataResponse).data;
        debugPrint("User Data Response: ${data}");
        userDataModel = UserDataModel.fromMap(data);
      } else {
        alertError(context, value.error.errorMessage, () {
          getUserDataRequest();
          Navigator.pop(context);
        });
      }
    });
  }

  /*
   * Get Daily Module Content.
   *
   * Get Daily Module by [groupId] and show
   * banner if response is not empty.
   */
  void getDailyModuleRequest(int groupId) async {
    await networkProvider.getGroupDailyModule(groupId).then((value) {
      if (value.status != null) {
        var data = (value as DataResponse).data;
        groupDailyModule = data["daily_module"];
        add(GroupChatUpdate());
      } else {
        alertError(context, value.error.errorMessage, () {
          getDailyModuleRequest(groupId);
          Navigator.pop(context);
        });
      }
    });
  }

  /*
   * Load Messages Request Method.
   *
   * Construct message request based on [requestType]
   * and update [groupChatsModel.messages].
   */
  Stream<GroupChatState> groupChatLoad(String requestType) async* {
    print("Group Chat Refresh: $requestType");
    print("Request Type: " + requestType);
    // No more messages to load. Terminate request.
    if (requestType == "less_than" &&
        (groupChatsModel?.loadMore ?? true) == false) {
      loading = false;
      return;
    }
    // Calculate correct pagination ID.
    int paginationId = 0;
    switch (requestType) {
      case "greater_than":
        if (groupChatsModel?.messages != null &&
            groupChatsModel.messages.length > 0) {
          paginationId = groupChatsModel.messages[0].id;
        }
        break;
      case "less_than":
        if (groupChatsModel?.messages != null &&
            groupChatsModel.messages.length > 0) {
          paginationId =
              groupChatsModel.messages[groupChatsModel.messages.length - 1].id;
        }
        break;
      default:
        break;
    }
    // Get Messages Network Request.
    ResponseWrapper response = await groupChatRepository.getGroupChat(
        groupChatModel.groupId,
        requestType: requestType,
        limit: 20,
        paginationId: paginationId);
    if (response.statusResponse.status != null) {
      loading = false;
      debugPrint("Group Chat Response: ${response.object}");
      switch (requestType) {
        // Load new messages.
        case "greater_than":
          List<GroupChatItemModel> messageHolder = groupChatsModel.messages;
          messageHolder.insertAll(
              0, (response.object as GroupChatsModel).messages);
          groupChatsModel = groupChatsModel.copyWith(messages: messageHolder);
          break;
        // Paginate messages and load more.
        case "less_than":
          if ((response.object as GroupChatsModel).messages.length > 0) {
            List<GroupChatItemModel> messageHolder = groupChatsModel.messages;
            messageHolder.addAll((response.object as GroupChatsModel).messages);
            groupChatsModel = groupChatsModel.copyWith(messages: messageHolder);
          } else {
            groupChatsModel = groupChatsModel.copyWith(loadMore: false);
          }
          break;
        // Initial state. Load all messages.
        // Default is "latest", refresh entire feed.
        default:
          groupChatsModel = response.object;
          break;
      }
    } else {
      loading = false;
      showError(response.statusResponse.error.errorMessage);
      return;
    }
    print("Set Group Chat Loaded");
    yield* refreshGroupChatLoaded(groupChatsModel);
  }
  // END: Network Methods.

  // BEGIN: PubNub Methods.
  /// Subscribe to PubNub channel.
  void subscribePubNub() {
    print("subscribing to ${groupChatModel.channelId}");
    pubNub.subscribe([groupChatModel.channelId]);
    pubNub.onPresenceReceived
        .listen((presence) => print('Presence:${presence.toString()}'));
    pubNub.onMessageReceived
        .listen((message) => onPubnubMessageReceived(message));
    pubNub.onErrorReceived.listen((error) => print('Error:$error'));
  }

  /// Pubnub signal [message] to fetch new messages.
  void onPubnubMessageReceived(Map message) {
    print('Message: $message');
    // Load only new messages because user could be scrolling.
    add(GroupChatGetData("greater_than"));
  }
  // END: PubNub Methods.

  // BEGIN: Pagination Methods.
  void onScroll() {
    final maxScroll = groupChatMessagesController.position.maxScrollExtent;
    final currentScroll = groupChatMessagesController.position.pixels;
    if (maxScroll - currentScroll <= scrollThreshold) {
      print('Loading More');
      add(GroupChatGetData("less_than"));
    }
  }
// END: Pagination Methods.
}

class GroupChatPage extends StatelessWidget {
  final int groupId;
  final GroupChatModel groupChatModel;

  GroupChatPage({Key key, this.groupId, this.groupChatModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build GroupChatPage");
    return PageWrapper(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BlocProvider(
          builder: (context) => GroupChatBloc(context, groupId, groupChatModel),
          child: BlocBuilder<GroupChatBloc, GroupChatState>(
              builder: (context, state) {
            // ignore: close_sinks
            final groupChatBloc = BlocProvider.of<GroupChatBloc>(context);
            return Stack(
              children: [
                if (state is GroupChatLoadingState) loadingIndicator(),
                if (state is GroupChatRefreshingState) GroupChatMessages(),
                if (state is GroupChatLoadedState) GroupChatMessages(),
                Container(
                  height: 52,
                  decoration:
                      BoxDecoration(color: Color(0xFFFFFFFF), boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(128, 218, 218, 218),
                        blurRadius: 2,
                        offset: Offset(0.0, 2)),
                  ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackHelper(
                        child: BackButtonCustom(
                            Image.asset("assets/images/back_blue.png"),
                            () => BackHelper.navigateBack(context)),
                      ),
                      Flexible(
                        child: Text(
                            groupChatModel.groupName != null
                                ? groupChatModel.groupName
                                : "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Material(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Container(
                          width: 48,
                          height: 48,
                          margin: EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () =>
                                groupChatBloc.openGroupChatSettings(
                                    context, groupChatBloc.groupChatModel),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            icon: Image.asset(
                              "assets/images/icon_more.png",
                              color: textSecondary,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Align(alignment: Alignment.bottomCenter, child: ReplyBox()),
              ],
            );
          }),
        ),
      ),
    );
  }
}
