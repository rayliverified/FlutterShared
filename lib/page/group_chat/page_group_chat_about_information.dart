import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group_information.dart';
import 'package:nocd/page/group_chat/group_chat_components.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:provider/provider.dart';

class GroupChatAboutInformationModel with ChangeNotifier {
  AppBloc appBloc;
  StreamSubscription backEventListener;
  BuildContext buildContext;
  final String screenEventName = "group_chat_menu_information";

  int groupId;
  bool fetchGuidelinesAccepted;

  GroupInformation groupInformation = GroupInformation();
  bool acceptedGuidelines = false;

  bool loadingGroupInformation = false;

  GroupChatAboutInformationModel(context, groupId) {
    appBloc = BlocProvider.of<AppBloc>(context);
    this.buildContext = context;
    backEventListener = appBloc.backEventController.listen((_) {
      print("Back Event Received");
      Navigator.maybePop(context);
    });
    this.groupId = groupId;
    getGroupInformation(context, groupId);
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  void restoreBack(BuildContext context) {
    backEventListener = appBloc.backEventController.listen((_) {
      print("Group Chat Information Back Event Received");
      Navigator.maybePop(context);
    });
  }

  @override
  void dispose() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    backEventListener.cancel();
    super.dispose();
  }

  void getGroupInformation(BuildContext context, int groupId) async {
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
            getGroupInformation(context, groupId);
            Navigator.pop(context);
          },
        );
      }
      notifyListeners();
    });
  }

  bool get loading => loadingGroupInformation;
}

/// A wrapper to provide [GroupChatAboutInformationPage] with [GroupChatAboutInformationModel].
class GroupChatAboutInformationPageWrapper extends StatelessWidget {
  final int groupId;

  GroupChatAboutInformationPageWrapper(this.groupId, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChatAboutInformationModel>(
      builder: (context) => GroupChatAboutInformationModel(context, groupId),
      child: GroupChatAboutInformationPage(),
    );
  }
}

class GroupChatAboutInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GroupChatAboutInformationModel>(
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
