import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_notification.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/notifications/page_notifications.dart';
import 'package:nocd/page/notifications/route_notifications.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

class NotificationsOverviewPageModel with ChangeNotifier {
  AppBloc appBloc;
  NotificationsBloc notificationsBloc;
  BuildContext buildContext;
  StreamSubscription backEventListener;

  List data = List();
  bool loading = true;

  @override
  void dispose() {
    backEventListener.cancel();
    super.dispose();
  }

  NotificationsOverviewPageModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Notifications Overview Back Event Received");
      Navigator.maybePop(context);
    });
    notificationsBloc = BlocProvider.of<NotificationsBloc>(context);
    buildContext = context;
    getData(context);
  }

  // BEGIN: Network Methods.
  void getData(BuildContext context) async {
    await networkProvider.getNotifications().then((value) {
      if (value.status != null) {
        loading = false;
        data.clear();
        Map json = (value as DataResponse).data;
        if (!json.containsKey("notifications")) {
          // error
          return;
        }
        var notifications = json["notifications"];
        for (var i = 0; i < notifications.length; i++) {
          if (notifications[i]["type"] == "reply") {
            data.add(ReplyNotification.fromMap(notifications[i]));
          } else if (notifications[i]["type"] == "like") {
            data.add(LikeNotification.fromMap(notifications[i]));
          } else if (notifications[i]["type"] == "flag") {
            data.add(FlagNotification.fromMap(notifications[i]));
          }
        }
      } else {
        alertError(context, value.error.errorMessage, () {
          getData(context);
          Navigator.pop(context);
        });
      }
      notifyListeners();
    });
  }
  // END: Network Methods.

  void onSettingsTapped() {
    backEventListener.cancel();

    NotificationsBloc notificationsBloc =
        BlocProvider.of<NotificationsBloc>(buildContext);

    notificationsBloc
        .nextPage(NotificationsRouteController.PAGE_NOTIFICATION_SETTINGS);
  }

  void onOpenUserProfile(BuildContext context, int userId) async {
    backEventListener.cancel();
    final userProfilePage = UserProfilePageWrapper(userId: userId);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userProfilePage),
    ).then((_) {
      restoreBack(context);
    });
  }

  void onOpenThread(BuildContext context, int threadId) async {
    backEventListener.cancel();
    final postThreadPage = PostThreadPage(postId: threadId);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => postThreadPage),
    ).then((_) {
      restoreBack(context);
    });
  }

  void restoreBack(BuildContext context) {
    backEventListener = appBloc.backEventController.listen((_) {
      print("Notifications Overview Back Event Received");
      Navigator.maybePop(context);
    });
    getData(context);
  }
}

/// A wrapper to provide [NotificationsOverviewPage] with [NotificationsOverviewPageModel].
class NotificationsOverviewPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationsOverviewPageModel>(
      builder: (context) => NotificationsOverviewPageModel(context),
      child: NotificationsOverviewPage(),
    );
  }
}

class NotificationsOverviewPage extends StatelessWidget {
  List<TextSpan> getTextSpan(String message, String linkString,
      String timeString, Function linkCallback) {
    List<TextSpan> spans = [];
    int spanBoundary = 0;

    do {
      // look for the next match
      final startIndex = message.indexOf(linkString, spanBoundary);

      // if no more matches then add the rest of the string without style
      if (startIndex == -1) {
        spans.add(TextSpan(
            text: message.substring(spanBoundary) + " ",
            style: TextStyle(color: Color(0xFF333333), fontSize: 16)));
        break;
      }

      // add any unstyled text before the next match
      if (startIndex > spanBoundary) {
        spans.add(TextSpan(text: message.substring(spanBoundary, startIndex)));
      }

      // style the matched text
      final endIndex = startIndex + linkString.length;
      final spanText = message.substring(startIndex, endIndex);
      spans.add(TextSpan(
          text: spanText,
          recognizer: new TapGestureRecognizer()..onTap = linkCallback,
          style: TextStyle(color: Color(0xFF4A90E2), fontSize: 16)));

      // mark the boundary to start the next search from
      spanBoundary = endIndex;

      // continue until there are no more matches
    } while (spanBoundary < message.length);

    spans.add(TextSpan(
        text: timeString,
        style: TextStyle(color: Color(0xFF949494), fontSize: 14)));

    return spans;
  }

  List<Widget> buildNotificationWidgets(
      BuildContext context, NotificationsOverviewPageModel pageModel) {
    List<Widget> widgets = List<Widget>();
    pageModel.data.forEach((model) {
      if (model is ReplyNotification) {
        widgets.add(buildLikeOrReplyNotificationRow(context, pageModel, model));
      } else if (model is LikeNotification) {
        widgets.add(buildLikeOrReplyNotificationRow(context, pageModel, model));
      } else if (model is FlagNotification) {
        widgets.add(buildFlagNotificationRow(context, pageModel, model));
      }
    });
    return widgets;
  }

  Widget buildLikeOrReplyNotificationRow(BuildContext context,
      NotificationsOverviewPageModel pageModel, dynamic model) {
    return Column(children: <Widget>[
      GestureDetector(
        onTap: () => pageModel.onOpenThread(context, model.threadId),
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: GestureDetector(
                          onTap: () => pageModel.onOpenUserProfile(
                              context, model.sourceUserId),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                  left: 15,
                                  top: 5,
                                  width: 45,
                                  height: 45,
                                  child: getAvatarImage(model
                                      .sourceUserAvatarName) //Image.asset("assets/images/avatar_0.png")
                                  ),
                              Positioned(
                                  right: 12,
                                  bottom: 5,
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(model.type == "like"
                                      ? "assets/images/notification_heart.png"
                                      : "assets/images/notification_comment.png"))
                            ],
                          )))),
              Expanded(
                  flex: 6,
                  child: Column(children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: RichText(
                            text: TextSpan(
                                text: "",
                                style: TextStyle(),
                                children: getTextSpan(
                                    model.message,
                                    model.sourceUserHandle,
                                    model.timestamp,
                                    () => pageModel.onOpenUserProfile(
                                        context, model.sourceUserId))))),
                  ])),
              Expanded(
                  flex: 1,
                  child: Container(
                      height: 12,
                      width: 12,
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Visibility(
                          child:
                              Image.asset("assets/images/notification_dot.png"),
                          visible: model.unseen))),
            ],
          ),
        ),
      ),
      Container(child: Divider(color: Color(0xFFE0E0E0))),
    ]);
  }

  Widget buildFlagNotificationRow(BuildContext context,
      NotificationsOverviewPageModel pageModel, FlagNotification model) {
    return Column(children: <Widget>[
      GestureDetector(
        onTap: () {
          pageModel.onOpenThread(context, model.threadId);
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child:
                          Image.asset("assets/images/notification_flag.png"))),
              Expanded(
                  flex: 6,
                  child: Column(children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: model.message + " ",
                              style: TextStyle(
                                  color: Color(0xFF333333), fontSize: 16)),
                          TextSpan(
                              text: model.timestamp,
                              style: TextStyle(
                                  color: Color(0xFF949494), fontSize: 14)),
                        ])))
                  ])),
              Expanded(
                  flex: 1,
                  child: Container(
                      height: 12,
                      width: 12,
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Visibility(
                          child:
                              Image.asset("assets/images/notification_dot.png"),
                          visible: model.unseen))),
            ],
          ),
        ),
      ),
      Container(child: Divider(color: Color(0xFFE0E0E0))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsOverviewPageModel>(
        builder: (context, model, child) {
      return PageWrapper(
          child: Stack(children: [
        Visibility(child: loadingIndicator(), visible: model.loading),
        Visibility(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Spacer(flex: 5),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(text: "", children: [
                      TextSpan(text: "🦉", style: TextStyle(fontSize: 72)),
                      TextSpan(
                          text:
                              "\n\nYou're all caught up!\nThis has been a real hoot.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF1F4B75))),
                    ])),
                Spacer(flex: 6),
              ],
            ),
            visible: model.data.length == 0 && !model.loading),
        SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            BackHelper(
                child: BackButtonCustom(
              Image.asset(
                "assets/images/back_blue.png",
              ),
              () => BackHelper.navigateBack(context),
            )),
            Row(children: [
              Expanded(
                  child: BubbleTitle("Notifications", 1,
                      margins:
                          const EdgeInsets.only(left: 16, top: 0, right: 16))),
              Container(
                  width: 48,
                  height: 60,
                  child: FlatButton(
                    onPressed: model.onSettingsTapped,
                    color: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    textColor: Color.fromARGB(255, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(0, 6, 18, 0),
                    child: Image.asset(
                      "assets/images/gear.png",
                    ),
                  )),
            ]),
            Container(child: Divider(color: Color(0xFFE0E0E0))),
            ListView(
              shrinkWrap: true,
              controller: ScrollController(),
              children: buildNotificationWidgets(context, model),
            ),
          ]),
        )
      ]));
    });
  }
}
