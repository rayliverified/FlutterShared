import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/model/model_group_joined.dart';
import 'package:nocd/model/model_group_unjoined.dart';
import 'package:nocd/page/group_chat/group_chat_components.dart';
import 'package:nocd/page/group_chat/page_group_chat.dart';
import 'package:nocd/page/group_chat/page_group_chat_information.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/LifecycleObserver.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/error_helper.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

/*
 * Group Chat Home Page Model.
 *
 * [myGroups] -
        JoinedGroup(
        id: 1,
        name: "Beginners with OCD",
        iconName: "group_chat_icon_1",
        badgeCount: 27,
        lastMessage:
        "OCD Warrior: I totally agree with you in that the issue is complicated",
        lastMessageTimestamp: "Just now"),
 * [selectGroups] -
        UnjoinedGroup(
        id: 1, name: "Beginners with OCD", iconName: "group_chat_icon_1"),
 */
class GroupChatHomePageModel with ChangeNotifier {
  AppBloc appBloc;
  BuildContext context;
  StreamSubscription backEventListener;
  bool showDisclaimer = false;
  bool loading = false;
  LifecycleObserver lifecycleObserver;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final String screenEventName = "group_chat_home";

  List<GroupJoined> myGroups = [];
  List<GroupUnjoined> selectGroups = [];

  GroupChatHomePageModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Notifications Overview Back Event Received");
      Navigator.maybePop(context);
    });
    this.context = context;
    initLifecycleObserver();
    WidgetsBinding.instance.addObserver(lifecycleObserver);

    if (appBloc.data.isNotEmpty) {
      try {
        Map jsonMap = json.decode(appBloc.data);
        if (jsonMap.containsKey("showGroupChatDisclaimer")) {
          showDisclaimer = jsonMap["showGroupChatDisclaimer"];
        }
      } on FormatException catch (e) {
        ErrorHelper().reportException(e);
      }
    }

    getGroupChatHomeRequest(context);
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    backEventListener.cancel();
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    super.dispose();
  }

  void initLifecycleObserver() {
    AsyncCallback onResumeCallback = () {
      print("Lifecycle OnResume");
      getGroupChatHomeRequest(context);
      return;
    };
    AsyncCallback onPauseCallback = () {
      print("Lifecycle OnPause");
      return;
    };
    lifecycleObserver = LifecycleObserver(
        onResumeCallback: onResumeCallback, onPauseCallback: onPauseCallback);
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
      print("Group Chat Home Back Event Received");
      Navigator.maybePop(context);
    });
    getGroupChatHomeRequest(context);
  }

  void onJoinGroup(BuildContext context, int id) async {
    savePage();
    final groupInformationPage = GroupChatInformationPageWrapper(id);

    await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => groupInformationPage),
    ).then((restore) {
      print("Join Restore: $restore");
      if (restore ?? true) {
        restorePage(context);
      }
      // Refresh Group Home Page on resume.
      getGroupChatHomeRequest(context);
    });
  }

  void onMyGroupTapped(BuildContext context, GroupJoined group) {
    savePage();
    final groupChatModel = GroupChatModel(
        groupId: group.id, channelId: group.channelId, groupName: group.name);
    final groupChatPage =
        GroupChatPage(groupId: group.id, groupChatModel: groupChatModel);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => groupChatPage),
    ).then((_) {
      restorePage(context);
    });
  }

  void onDisclaimerNextButtonTapped() {
    this.showDisclaimer = false;
    getGroupChatHomeRequest(context);
    notifyListeners();
  }
  // END: Navigation Methods.

  // BEGIN: Network Methods.
  Future<void> getGroupChatHomeRequest(BuildContext context) async {
    if (!loading) {
      loading = true;
      await networkProvider.getGroupChatHome().then((value) {
        if (value.status != null) {
          loading = false;
          var data = (value as DataResponse).data;
          myGroups.clear();
          data["joined_groups"]
              .forEach((jg) => myGroups.add(GroupJoined.fromMap(jg)));
          selectGroups.clear();
          data["unjoined_groups"]
              .forEach((jg) => selectGroups.add(GroupUnjoined.fromMap(jg)));
        } else {
          loading = false;
          alertError(
            context,
            value.error.errorMessage,
            () {
              getGroupChatHomeRequest(context);
              Navigator.pop(context);
            },
          );
        }
        notifyListeners();
        return;
      });
    }

    return;
  }

  void showRecommendGroupPrompt(BuildContext context) {
    alertFeedback(context, "Recommend Group", "What group should we add?",
        "Ex: Group for cleanliness OCD.", (String text) async {
      if (text.isNotEmpty) {
        print(text);
        Navigator.pop(context);
        await networkProvider
            .postFeedback(text, "GROUP_RECOMMENDATION",
                metadata: appBloc.flutterConfig.toJson().toString())
            .then((value) {
          if (value.status != null) {
            FlushbarHelperProvider.createInfo(
                    message: "Feedback sent!", width: 160)
                .show(context);
          } else {
            FlushbarHelperProvider.createError(
                    message: value.error.errorMessage)
                .show(context);
          }
        });
      }
    });
  }
  // END: Network Methods.

  bool get loaded => !loading || myGroups.isNotEmpty || selectGroups.isNotEmpty;
}

/// A wrapper to provide [GroupChatPage] with [GroupChatPageModel].
class GroupChatHomePageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChatHomePageModel>(
      builder: (context) => GroupChatHomePageModel(context),
      child: GroupChatHomePage(),
    );
  }
}

class GroupChatHomePage extends StatelessWidget {
  Widget buildMyGroupRow(String iconUrl, String title, int badgeCount,
      String lastMessage, String lastMessageTimestamp, Function onTap) {
    return Column(children: [
      /*
              Divider
               */
      Divider(color: divider),
      InkWell(
          onTap: onTap,
          child: Row(children: [
            // Image icon with badge.
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(24, 8, 16, 8),
                  height: 58,
                  width: 58,
                  child: Image.network(iconUrl),
                ),
                Visibility(
                  visible: badgeCount != null && badgeCount > 0,
                  child: Positioned(
                      right: 6,
                      child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Text(
                            badgeCount != null
                                ? (badgeCount > 100 ? "100+" : "$badgeCount")
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ))),
                ),
              ],
            ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          title,
                          style: TextStyle(color: textSecondary, fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 8, right: 24),
                          child: Text(lastMessageTimestamp,
                              style: TextStyle(
                                  color: textSecondaryLight, fontSize: 12),
                              textAlign: TextAlign.right)),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 64),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        lastMessage,
                        style:
                            TextStyle(color: textSecondaryLight, fontSize: 14),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ])),
    ]);
  }

  Widget buildSelectGroupRow(
      BuildContext context, String iconUrl, String title, Function onTap) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Divider(
        color: divider,
      ),
      InkWell(
        onTap: onTap,
        child: Row(children: [
          Container(
              margin: EdgeInsets.fromLTRB(24, 8, 16, 8),
              height: 58,
              width: 58,
              child: Image.network(iconUrl)),
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              child: Text(
                title,
                style: TextStyle(color: textSecondary, fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 24),
            child: Text(
              "Join",
              style: TextStyle(color: primary, fontSize: 18),
            ),
          ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupChatHomePageModel>(builder: (context, model, child) {
      return PageWrapper(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                BackHelper(
                  child: BackButtonCustom(
                      Image.asset("assets/images/back_blue.png"),
                      () => BackHelper.navigateBack(context)),
                ),
                Expanded(
                    child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: <Widget>[
                    CupertinoSliverRefreshControl(
                      key: model._refreshIndicatorKey,
                      onRefresh: () {
                        return model.getGroupChatHomeRequest(context);
                      },
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        /*
            Title
             */
                        Row(children: [
                          Container(
                            margin: EdgeInsets.only(left: 24, right: 24),
                            child: Text(
                              "Groups",
                              style:
                                  TextStyle(color: textSecondary, fontSize: 28),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ]),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Divider(
                              color: Color.fromARGB(255, 185, 185, 185),
                            )),

                        /*
            My group widgets
             */
                        Visibility(
                          visible: model.myGroups.isNotEmpty,
                          child: Row(children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: 24, top: 12, bottom: 4),
                              child: Text(
                                "MY GROUP",
                                style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ]),
                        ),
                        ...model.myGroups.map((group) => buildMyGroupRow(
                            group.iconUrl,
                            group.name,
                            group.badgeCount,
                            group.lastMessage,
                            group.lastMessageTimestamp,
                            () => model.onMyGroupTapped(context, group))),

                        /*
            Select group widgets
             */
                        Visibility(
                          visible: model.selectGroups.isNotEmpty,
                          child: Row(children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: 24, top: 12, bottom: 4),
                              child: Text(
                                "SELECT GROUP",
                                style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ]),
                        ),
                        ...model.selectGroups.map((group) =>
                            buildSelectGroupRow(
                                context,
                                group.iconUrl,
                                group.name,
                                () => model.onJoinGroup(context, group.id))),
                        /*
            Recommend a group section
             */
                        Container(height: 24),
                        if (model.loaded)
                          Text(
                            "Don’t see a group you are looking for?",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        if (model.loaded)
                          FlatButton(
                            onPressed: () =>
                                model.showRecommendGroupPrompt(context),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Text(
                              "Recommend a group",
                              style: TextStyle(fontSize: 18, color: primary),
                            ),
                          ),
                        Container(height: 56),
                      ]),
                    )
                  ],
                )),
              ],
            ),
            Visibility(
              visible: !model.loaded,
              child: Center(child: CupertinoActivityIndicator(radius: 16)),
            ),
            Visibility(
              visible: model.showDisclaimer,
              child:
                  groupChatDisclaimerPage(model.onDisclaimerNextButtonTapped),
            )
          ],
        ),
      );
    });
  }
}
