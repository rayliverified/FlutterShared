import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/page/group_chat/page_group_chat_about_information.dart';
import 'package:nocd/page/group_chat/page_group_chat_guidelines.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

class GroupChatMenuPageModel with ChangeNotifier {
  AppBloc appBloc;
  BuildContext buildContext;
  StreamSubscription backEventListener;

  final String screenEventName = "group_chat_menu";
  GroupChatModel groupChatModel;

  bool notificationEnabled = true;

  GroupChatMenuPageModel(context, groupChatModel) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      Navigator.maybePop(context);
    });
    buildContext = context;
    this.groupChatModel = groupChatModel;
    getNotificationEnabledRequest();
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  @override
  void dispose() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    backEventListener.cancel();
    super.dispose();
  }

  // BEGIN: Network Methods.
  void getNotificationEnabledRequest() async {
    await networkProvider
        .getGroupNotificationEnabled(groupChatModel.groupId)
        .then((value) {
      if (value.status != null) {
        var data = (value as DataResponse).data;
        notificationEnabled = data["group_chat_notifications_enabled"];
      } else {
        FlushbarHelperProvider.createInfo(message: value.error.errorMessage);
      }
      notifyListeners();
    });
  }

  void setNotificationEnabled(bool enabled) async {
    this.notificationEnabled = enabled;
    notifyListeners();
    await networkProvider
        .postGroupNotificationEnabled(groupChatModel.groupId, enabled)
        .then((value) {
      if (value.status != null) {
        // Do Nothing.
      } else {
        FlushbarHelperProvider.createInfo(message: value.error.errorMessage);
      }
      notifyListeners();
    });
  }
  // END: Network Methods.

  // BEGIN: Navigation Methods.
  void openAboutInformation(BuildContext context, groupId) async {
    backEventListener.cancel();
    final groupChatAboutInformationPage =
        GroupChatAboutInformationPageWrapper(groupId);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => groupChatAboutInformationPage),
    ).then((_) => {
          backEventListener = appBloc.backEventController.listen((_) {
            Navigator.maybePop(context);
          })
        });
  }

  void openGroupGuidelines(BuildContext context) async {
    backEventListener.cancel();
    final groupChatGuidelinesPage =
        GroupChatGuidelinesPageWrapper(false, null, null);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => groupChatGuidelinesPage),
    ).then((_) => {
          backEventListener = appBloc.backEventController.listen((_) {
            Navigator.maybePop(context);
          })
        });
  }

  void openUserProfile(BuildContext context) async {
    backEventListener.cancel();
    final userProfilePage = UserProfilePageWrapper();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userProfilePage),
    ).then((_) => {
          backEventListener = appBloc.backEventController.listen((_) {
            Navigator.maybePop(context);
          })
        });
  }

  void showFeedbackPrompt(BuildContext context) {
    alertFeedback(
        context,
        "Give Feedback",
        "Send us your comments, feedback, or questions:",
        "Ex: What can we do to improve the app? How is the app helping you with your OCD?",
        (String text) async {
      if (text.isNotEmpty) {
        print(text);
        Navigator.pop(context);
        await networkProvider
            .postFeedback(text, "GROUP_FEEDBACK",
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

  void showLeaveGroupPrompt(BuildContext context) {
    alertConfirmation(context, "Leave Group", () async {
      Navigator.pop(context);
      await networkProvider
          .postLeaveGroup(groupChatModel.groupId)
          .then((value) {
        if (value.status != null) {
          FlushbarHelperProvider.createInfo(message: "Group Left!", width: 160)
              .show(context);
        } else {
          FlushbarHelperProvider.createError(message: value.error.errorMessage)
              .show(context);
        }
      });
    });
  }
// END: Navigation Methods.
}

/// A wrapper to provide [GroupChatMenuPage] with [GroupChatMenuPageModel].
class GroupChatMenuPageWrapper extends StatelessWidget {
  final GroupChatModel groupChatModel;

  GroupChatMenuPageWrapper({Key key, this.groupChatModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChatMenuPageModel>(
      builder: (context) => GroupChatMenuPageModel(context, groupChatModel),
      child: GroupChatMenuPage(),
    );
  }
}

class GroupChatMenuPage extends StatelessWidget {
  Widget buildMenuItem(String title,
      {Function function, EdgeInsets margins = EdgeInsets.zero}) {
    return Container(
      margin: margins,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: function ?? () {},
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 24),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20, right: 35),
                    width: 12,
                    height: 20,
                    child:
                        Image.asset("assets/images/icon_menu_selection.png")),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupChatMenuPageModel>(builder: (context, model, child) {
      return PageWrapper(
          backgroundColor: Color.fromARGB(255, 242, 242, 242),
          child: Stack(children: <Widget>[
            /*
          Body
          */
            Container(
              margin: EdgeInsets.only(top: 53),
              child: ListView(children: [
                /*
                      Divider
                       */
                Container(
                  color: Color.fromARGB(255, 242, 242, 242),
                  child: ListView(
                      shrinkWrap: true,
                      controller: ScrollController(),
                      children: [
                        buildMenuItem("About this Group",
                            function: () => model.openAboutInformation(
                                context, model.groupChatModel.groupId),
                            margins: EdgeInsets.only(top: 10)),
                        Container(
                            color: Colors.white,
                            height: 1,
                            padding: EdgeInsets.only(left: 26),
                            child: Divider()),
                        buildMenuItem("Group Guidelines",
                            function: () => model.openGroupGuidelines(context)),
                        buildMenuItem("Edit my profile",
                            function: () => model.openUserProfile(context),
                            margins: EdgeInsets.only(top: 10)),
                        MenuToggleOption(
                            "Mute notifications", !model.notificationEnabled,
                            onChanged: (value) =>
                                model.setNotificationEnabled(!value),
                            margins: EdgeInsets.only(top: 10)),
                        buildMenuItem("Give feedback",
                            function: () => model.showFeedbackPrompt(context),
                            margins: EdgeInsets.only(top: 10)),
                        Container(height: 68),
                        Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => model.showLeaveGroupPrompt(context),
                            child: Container(
                              height: 57,
                              alignment: Alignment.center,
                              child: Text(
                                "Leave group",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xFFFF5D47)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ]),
            ),
            /*
          Top Navigation bar
           */
            Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
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
                            model.groupChatModel.groupName != null
                                ? model.groupChatModel.groupName
                                : "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(width: 52) // Same width as BackButtonCustom.
                    ],
                  ),
                ),
                Container(height: 1, child: Divider()),
              ],
            ),
          ]));
    });
  }
}
