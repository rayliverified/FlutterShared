import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_user_profile.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class UserProfileEditModel with ChangeNotifier {
  AppBloc appBloc;
  UserProfileBloc userProfileBloc;
  StreamSubscription backEventListener;

  TextEditingController handleController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  @override
  void dispose() {
    backEventListener.cancel();
    handleController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  UserProfileEditModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
//    appBloc.updateBack(false);
    backEventListener = appBloc.backEventController.listen((bool) {
      print("Notification Settings Back Event Received");
      backClick();
    });
    userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    handleController.text = userProfileBloc.model.communityHandle;
    aboutController.text = userProfileBloc.model.about;
  }

  void backClick() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    userProfileBloc.previousPage();
  }

  void saveClick(BuildContext context) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    UserProfileModel userProfileModel = UserProfileModel(
      avatarName: userProfileBloc.model.avatarName,
      communityHandle: handleController.text,
      caption: userProfileBloc.model.caption,
      about: aboutController.text,
      tags: userProfileBloc.model.tags,
      canEdit: userProfileBloc.model.canEdit,
    );

    await networkProvider.postUserProfile(userProfileModel).then((value) {
      if (value.status != null) {
        userProfileBloc.updateModel(
            communityHandle: userProfileModel.communityHandle,
            about: userProfileModel.about,
            tags: List<String>());
        Map<String, dynamic> data = {
          "event": EVENT_UPDATE_AVATAR,
          "avatarName": userProfileModel.communityHandle
        };
        appBloc.sendFlutterEvent(data);
        userProfileBloc.previousPage();
      } else {
        alertError(context, value.error.errorMessage, () {
          saveClick(context);
          Navigator.pop(context);
        });
      }
    });
  }
}

/// A wrapper to provide [DataCollectionSeverityPage] with [DataCollectionSeverityModel].
class UserProfileEditWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProfileEditModel>(
      builder: (context) => UserProfileEditModel(context),
      child: UserProfileEditPage(),
    );
  }
}

class UserProfileEditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileEditModel>(builder: (context, model, child) {
      return PageWrapper(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: SingleChildScrollView(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => {FocusScope.of(context).unfocus()},
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackButtonCustom(
                        Image.asset(
                          "assets/images/back_blue.png",
                        ),
                        () => model.backClick()),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    BubbleTitle("Profile Picture", 0,
                        bubbleScale: 0.6, fontSize: 18),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(top: 16, left: 24),
                        child: getPostAvatar(
                            model.userProfileBloc.model.avatarType,
                            avatarName: model.userProfileBloc.model.avatarName,
                            avatarImg: model.userProfileBloc.model.avatarImg),
                      ),
                    ),
                    BubbleTitle("Display Name", 1,
                        bubbleScale: 0.6, fontSize: 18),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
                      child: Text(
                        "This will be used when you post or reply.",
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(128, 218, 218, 218),
                              blurRadius: 10,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            child: TextField(
                              controller: model.handleController,
                              onEditingComplete: () =>
                                  {FocusScope.of(context).unfocus()},
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "Display name",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BubbleTitle("About (optional)", 2,
                        bubbleScale: 0.6, fontSize: 18),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
                      child: Text(
                        "Introduce yourself to everyone",
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(128, 218, 218, 218),
                              blurRadius: 10,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            child: TextField(
                              controller: model.aboutController,
                              expands: true,
                              decoration: InputDecoration(
                                hintText: "About me",
                                border: InputBorder.none,
                                hintMaxLines: 5,
                                focusColor: Colors.transparent,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              textAlignVertical: TextAlignVertical.top,
                            ),
                          ),
                        ),
                      ),
                    ),
//                    BubbleTitle("Tags", 3, bubbleScale: 0.6, fontSize: 18),
                    Align(
                      alignment: Alignment.topCenter,
                      child: NextButton(
                        true,
                        () => model.saveClick(context),
                        text: "Save",
                      ),
                    ),
                    Container(
                      height: 200,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
