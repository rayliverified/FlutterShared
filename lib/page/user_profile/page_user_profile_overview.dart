import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_user_profile.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/page/user_profile/route_user_profile.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_misc.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/ui/ui_shimmer_helper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:provider/provider.dart';

class UserProfileOverviewModel with ChangeNotifier {
  AppBloc appBloc;
  UserProfileBloc userProfileBloc;
  BuildContext buildContext;
  StreamSubscription backEventListener;

  bool loading = true;

  @override
  void dispose() {
    backEventListener.cancel();
    super.dispose();
  }

  UserProfileOverviewModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("User Profile Overview Back Event Received");
      Navigator.maybePop(context);
    });
    userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    buildContext = context;
    if (userProfileBloc.model.communityHandle != null) {
      loading = false;
    }
    getData(context);
  }

  // BEGIN: Network Methods.
  void getData(BuildContext context) async {
    await networkProvider.getUserProfile(userProfileBloc.userId).then((value) {
      if (value.status != null) {
        loading = false;
        userProfileBloc.model =
            UserProfileModel.fromMap((value as DataResponse).data);
      } else {
        alertError(
          context,
          value.error.errorMessage,
          () {
            getData(context);
            Navigator.pop(context);
          },
        );
      }
      notifyListeners();
    });
  }

  void nextPage() {
    // Workaround for a bug where Flutter framework overwrites saved
    // UserProfileModel.
    UserProfileModel userProfileModel = this.userProfileBloc.model;

    UserProfileBloc userProfileBloc =
        BlocProvider.of<UserProfileBloc>(buildContext);
    userProfileBloc.model = userProfileModel;

    userProfileBloc.nextPage(UserProfileRouteController.PAGE_USER_EDIT);
  }
}

/// A wrapper to provide [UserProfileOverviewPage] with [UserProfileOverviewModel].
class UserProfileOverviewWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProfileOverviewModel>(
      builder: (context) => UserProfileOverviewModel(context),
      child: UserProfileOverviewPage(),
    );
  }
}

class UserProfileOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileOverviewModel>(builder: (context, model, child) {
      return PageWrapper(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackHelper(
                child: BackButtonCustom(
                  Image.asset(
                    "assets/images/back_blue.png",
                  ),
                  () => BackHelper.navigateBack(context),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 24),
                  child: visibilityWrapper(
                    ShimmerRound(),
                    getPostAvatar(model.userProfileBloc.model.avatarType,
                        avatarName: model.userProfileBloc.model.avatarName,
                        avatarImg: model.userProfileBloc.model.avatarImg),
                    model.loading,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: visibilityWrapper(
                  ShimmerRectangle(
                    width: 120,
                    height: 26,
                    radius: 20,
                  ),
                  Text(
                    model.userProfileBloc.model.communityHandle ?? "Anonymous",
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 33, 33),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  model.loading,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: visibilityWrapper(
                  ShimmerRectangle(
                    width: 180,
                    height: 20,
                    radius: 20,
                  ),
                  Text(
                    model.userProfileBloc.model.caption ?? "",
                    style: TextStyle(
                      color: Color.fromARGB(160, 33, 33, 33),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  model.loading,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24),
                child: visibilityWrapper(
                  ShimmerText(
                    lineCount: 3,
                    lineHeight: 20,
                    lineRadius: 20,
                  ),
                  Visibility(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              model.userProfileBloc.model.about ?? "",
                              style: TextStyle(
                                color: Color.fromARGB(255, 33, 33, 33),
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ]),
                    visible: (model.userProfileBloc.model.about ?? "") != "",
                  ),
                  model.loading,
                ),
              ),
              Visibility(
                child: Container(
                  height: 14,
                ),
                visible: (model.userProfileBloc.model.about ?? "") != "",
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 230,
                  height: 1,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 217, 217, 217),
                  ),
                  child: Container(),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Visibility(
                    child: Container(
                      width: 160,
                      height: 40,
                      margin: EdgeInsets.only(top: 12),
                      child: FlatButton(
                        onPressed: () => model.nextPage(),
                        color: Colors.transparent,
                        textColor: primary,
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "Edit profile",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    visible: !model.loading &&
                        (model.userProfileBloc.model.canEdit ?? false)),
              ),
              if (model.userProfileBloc.model.isNOCDPro)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 160,
                    height: 40,
                    margin: EdgeInsets.only(top: 12, bottom: 16),
                    child: RaisedButton(
                      onPressed: () => DeviceUtils().openUrl(
                          model.appBloc, model.userProfileBloc.model.ctaUrl),
                      color: primary,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          side: BorderSide(color: primary)),
                      child: Text(
                        model.userProfileBloc.model.ctaText ?? "",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
