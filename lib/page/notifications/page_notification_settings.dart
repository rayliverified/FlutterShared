import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_notification_settings.dart';
import 'package:nocd/page/notifications/page_notifications.dart';
import 'package:nocd/ui/ralert/alert.dart';
import 'package:nocd/ui/ralert/alert_style.dart';
import 'package:nocd/ui/ralert/constants.dart';
import 'package:nocd/ui/ralert/dialog_button.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPageModel with ChangeNotifier {
  AppBloc appBloc;
  NotificationsBloc notificationsBloc;
  BuildContext buildContext;
  StreamSubscription backEventListener;

  bool loading = true;

  NotificationSettingsModel model = NotificationSettingsModel(
      postsAndComments: true,
      bookmarks: true,
      fromPro: true,
      reminders: true,
      fromNocd: true);

  NotificationSettingsPageModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((bool) {
      print("Notification Settings Back Event Received");
      exitClick();
    });
    notificationsBloc = BlocProvider.of<NotificationsBloc>(context);
    buildContext = context;
    getData(context);
  }

  // BEGIN: Network Methods.
  void getData(BuildContext context) async {
    await networkProvider.getNotificationSettings().then((value) {
      if (value.status != null) {
        loading = false;
        model = NotificationSettingsModel.fromMap((value as DataResponse).data);
      } else {
        // TODO Move to Network Provider? Common error UI.
        Alert(
          context: context,
          type: AlertType.warning,
          title: value.error.errorMessage,
          style: AlertStyle(
              isOverlayTapDismiss: false, overlayColor: Colors.black38),
          buttons: [
            DialogButton(
              child: Text(
                "Retry",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                getData(context);
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
          closeFunction: () {},
        ).show();
      }
      notifyListeners();
    });
  }

  void postData(BuildContext context, NotificationSettingsModel model) async {
    await networkProvider.postNotificationSettings(model).then((value) {
      if (value.status != null) {
        this.model =
            NotificationSettingsModel.fromMap((value as DataResponse).data);
      } else {
        // TODO Move to Network Provider? Common error UI.
        Alert(
          context: context,
          type: AlertType.warning,
          title: value.error.errorMessage,
          style: AlertStyle(
              isOverlayTapDismiss: false, overlayColor: Colors.black38),
          buttons: [
            DialogButton(
              child: Text(
                "Retry",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                postData(context, model);
              },
              width: 120,
            ),
          ],
          closeFunction: () {},
        ).show();
      }
      notifyListeners();
    });
  }

  void onPostsAndCommentsChanged(BuildContext context, bool newValue) async {
    model.postsAndComments = newValue;
    notifyListeners();

    postData(context, model);
  }

  void onBookmarksChanged(BuildContext context, bool newValue) async {
    model.bookmarks = newValue;
    notifyListeners();

    postData(context, model);
  }

  void onfromProChanged(BuildContext context, bool newValue) async {
    model.fromPro = newValue;
    notifyListeners();

    postData(context, model);
  }

  void onRemindersChanged(BuildContext context, bool newValue) async {
    model.reminders = newValue;
    notifyListeners();

    postData(context, model);
  }

  void onfromNocdChanged(BuildContext context, bool newValue) async {
    model.fromNocd = newValue;
    notifyListeners();

    postData(context, model);
  }

  void onPauseAll(BuildContext context) async {
    if (!model.postsAndComments &&
        !model.bookmarks &&
        (!model.fromPro || !notificationsBloc.premiumEligible) &&
        !model.reminders &&
        !model.fromNocd) {
      model.postsAndComments = true;
      model.bookmarks = true;
      model.fromPro = true;
      model.reminders = true;
      model.fromNocd = true;
    } else {
      model.postsAndComments = false;
      model.bookmarks = false;
      model.fromPro = false || !notificationsBloc.premiumEligible;
      model.reminders = false;
      model.fromNocd = false;
    }
    notifyListeners();

    postData(context, model);
  }

  void exitClick() {
    backEventListener.cancel();
    notificationsBloc.previousPage();
  }
}

/// A wrapper to provide [NotificationSettingsPage] with [NotificationSettingsPageModel].
class NotificationSettingsPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationSettingsPageModel>(
      builder: (context) => NotificationSettingsPageModel(context),
      child: NotificationSettingsPage(),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  Container buildOption(
      BuildContext context,
      String title,
      String description,
      String unselectedText,
      Function(BuildContext, bool) onSwitchPressed,
      bool switchValue) {
    return Container(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Color(0xFF747474), fontSize: 16),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
                activeColor: Color(0xFF00A3AD),
                onChanged: (value) {
                  onSwitchPressed(context, value);
                },
                value: switchValue),
          ]),
          Visibility(
              child: Visibility(
                  child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(unselectedText,
                          style: TextStyle(
                              color: Color(0xFFD0021B), fontSize: 16))),
                  visible: !switchValue),
              visible: unselectedText != ""),
          Container(
              padding: EdgeInsets.only(top: 8), child: Divider(color: divider)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationSettingsPageModel>(
        builder: (context, model, child) {
      return PageWrapper(
          child: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            BackButtonCustom(
                Image.asset(
                  "assets/images/back_blue.png",
                ),
                () => model.exitClick())
          ]),
          BubbleTitle("Notification Settings", 1,
              margins: const EdgeInsets.only(left: 16, top: 0, right: 16)),
          buildOption(
              context,
              "Your posts & comments",
              "Find out when someone likes or replies to your posts and comments",
              "Don’t miss out when someone answers a question or tells you how helpful you’ve been.",
              model.onPostsAndCommentsChanged,
              model.model.postsAndComments),
          buildOption(
              context,
              "Your bookmarks",
              "Stay up to date when someone comments on a post you’ve bookmarked",
              "",
              model.onBookmarksChanged,
              model.model.bookmarks),
          Visibility(
              child: buildOption(
                  context,
                  "NOCD Pro",
                  "Get notified when your NOCD Pro sends you a message",
                  "Messaging back and forth with your NOCD Pro is important—they’re here to help you feel better. We recommend you keep these notifications on.",
                  model.onfromProChanged,
                  model.model.fromPro),
              visible: model.notificationsBloc.premiumEligible),
          buildOption(
              context,
              "From NOCD",
              "We’ll share occasional tips, community updates, and great posts we’ve seen from members like you! ",
              "",
              model.onfromNocdChanged,
              model.model.fromNocd),
          FlatButton(
              onPressed: () {
                model.onPauseAll(context);
              },
              child: Text(
                  !model.model.postsAndComments &&
                          !model.model.bookmarks &&
                          (!model.model.fromPro ||
                              !model.notificationsBloc.premiumEligible) &&
                          !model.model.reminders &&
                          !model.model.fromNocd
                      ? "Enable all"
                      : "Pause all",
                  style: TextStyle(color: Color(0xFF00A3AD), fontSize: 18))),
        ]),
      ));
    });
  }
}
