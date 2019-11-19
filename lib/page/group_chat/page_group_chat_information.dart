import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/model/model_group_information.dart';
import 'package:nocd/page/group_chat/group_chat_components.dart';
import 'package:nocd/page/group_chat/page_group_chat.dart';
import 'package:nocd/page/group_chat/page_group_chat_guidelines.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

class GroupChatInformationModel with ChangeNotifier {
  AppBloc appBloc;
  StreamSubscription backEventListener;
  BuildContext buildContext;
  final String screenEventName = "group_chat_join_information";

  int groupId;

  GroupInformation groupInformation = GroupInformation();
//      id: 1,
//      channelId: "channel_1",
//      name: "Beginners with OCD",
//      description: "Check it out.",
//      totalMembers: 42,
//      isMember: false);
  bool acceptedGuidelines = false;

  bool loadingGroupInformation = false;
  bool loadingAcceptedGuidelines = false;
  bool loadingGroupMembership = false;

  GroupChatInformationModel(context, groupId) {
    appBloc = BlocProvider.of<AppBloc>(context);
    this.buildContext = context;
    backEventListener = appBloc.backEventController.listen((_) {
      print("Report Message Back Event Received");
      Navigator.maybePop(context);
    });
    this.groupId = groupId;
    getGroupInformation(context);
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  void restoreBack(BuildContext context) {
    backEventListener = appBloc.backEventController.listen((_) {
      print("Group Chat Information Back Event Received");
      Navigator.maybePop(context, false);
    });
  }

  @override
  void dispose() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    backEventListener.cancel();
    super.dispose();
  }

  void getGroupInformation(BuildContext context) async {
    loadingGroupInformation = true;
    await networkProvider.getGroupInformation(groupId).then((value) {
      if (value.status != null) {
        loadingGroupInformation = false;
        var data = (value as DataResponse).data;
        groupInformation = GroupInformation.fromMap(data["group"]);
      } else {
        alertError(
          context,
          value.error.errorMessage,
          () {
            getGroupInformation(context);
            Navigator.pop(context);
          },
        );
      }
      notifyListeners();
    });
  }

  void onButtonTapped(BuildContext context) async {
    if (acceptedGuidelines) {
      onJoinGroup(context);
    } else {
      backEventListener.cancel();
      final groupChatModel = GroupChatModel(
          groupId: this.groupId,
          channelId: this.groupInformation.channelId,
          groupName: this.groupInformation.name);
      final groupGuidelinesPage =
          GroupChatGuidelinesPageWrapper(true, groupId, groupChatModel);

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => groupGuidelinesPage),
      ).then((_) {
        restoreBack(context);
      });
    }
  }

  void onJoinGroup(BuildContext context) async {
    loadingGroupMembership = true;
    notifyListeners();
    await networkProvider
        .postJoinGroup(groupInformation.id)
        .then((value) async {
      if (value.status != null) {
        groupInformation.isMember = true;
        loadingGroupMembership = false;

        final groupChatModel = GroupChatModel(
            groupId: this.groupId,
            channelId: this.groupInformation.channelId,
            groupName: this.groupInformation.name);
        final groupChatPage = GroupChatPage(
          groupId: this.groupId,
          groupChatModel: groupChatModel,
        );

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => groupChatPage),
        ).then((_) {
          restoreBack(context);
        });
      } else {
        loadingGroupMembership = false;
        alertError(context, value.error.errorMessage, () {
          onJoinGroup(context);
          Navigator.pop(context);
        });
      }
      notifyListeners();
    });
  }

  bool get loading =>
      loadingGroupInformation ||
      loadingAcceptedGuidelines ||
      loadingGroupMembership;
}

/// A wrapper to provide [GroupChatInformationPage] with [GroupChatInformationModel].
class GroupChatInformationPageWrapper extends StatelessWidget {
  final int groupId;

  GroupChatInformationPageWrapper(this.groupId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChatInformationModel>(
      builder: (context) => GroupChatInformationModel(context, groupId),
      child: GroupChatInformationPage(),
    );
  }
}

class GroupChatInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GroupChatInformationModel>(
        builder: (context, model, child) {
      return PageWrapper(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  BackHelper(
                    child: BackButtonCustom(
                        Image.asset("assets/images/back_blue.png"),
                        () => BackHelper.navigateBack(context)),
                  ),
                  if (!model.loading)
                    ...groupInformationBody(model.groupInformation),
                  if (!model.loading)
                    NextButton(
                      true,
                      () => model.onButtonTapped(context),
                      text: model.groupInformation.isMember != null
                          ? "Join Group"
                          : "",
                    ),
                ],
              ),
            ),
            Visibility(
              visible: model.loading,
              child: Center(child: CupertinoActivityIndicator(radius: 16)),
            )
          ],
        ),
      );
    });
  }
}
