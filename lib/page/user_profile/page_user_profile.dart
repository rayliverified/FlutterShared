import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_user_profile.dart';
import 'package:nocd/page/user_profile/route_user_profile.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/error_helper.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:rxdart/rxdart.dart';

class UserProfileBloc implements BlocBase {
  String _page;
  BehaviorSubject<String> pageController = BehaviorSubject<String>();
  ValueObservable get getPage => pageController;

  AppBloc appBloc;

  List<String> activeRoute = [];

  int userId;
  UserProfileModel model = UserProfileModel();

  UserProfileBloc(BuildContext context, int userId) {
    print("Profile Bloc Built");
    appBloc = BlocProvider.of<AppBloc>(context);
    _page = UserProfileRouteController.PAGE_USER_PROFILE_OVERVIEW;
    activeRoute.add(UserProfileRouteController.PAGE_USER_PROFILE_OVERVIEW);
    if (userId == null) {
      getData(context);
    } else {
      this.userId = userId;
    }
  }

  @override
  void dispose() {
    pageController.close();
  }

  // BEGIN: Model.
  void getData(BuildContext context) {
    try {
      Map jsonMap = json.decode(appBloc.data);
      if (jsonMap.containsKey("user_id")) {
        userId = parseToInt(jsonMap["user_id"]);
      }
    } on FormatException catch (e) {
      ErrorHelper().reportException(e);
      return;
    }
  }
  // END: Model.

  // BEGIN: Navigation.
  void updatePage(String page) {
    print("Update Page: " + page);
    print("Current Page: " + this._page);
    this._page = page;
    pageController.sink.add(page);
  }

  void previousPage() {
    activeRoute.removeLast();
    print(activeRoute);
    updatePage(activeRoute.last);
  }

  void nextPage(String page) {
    print("Next Page");
    activeRoute.add(page);
    updatePage(page);
  }
  // END: Navigation.

  //BEGIN: Model.
  void updateModel({
    String avatarName,
    String communityHandle,
    String caption,
    String about,
    List<String> tags,
    bool canEdit,
  }) {
    model.copyWith(
      avatarName: avatarName,
      communityHandle: communityHandle,
      caption: caption,
      about: about,
      tags: tags,
      canEdit: canEdit,
    );
  }
//END: Model.
}

/// A wrapper to provide [UserProfilePage] with [UserProfileBloc].
class UserProfilePageWrapper extends StatelessWidget {
  final int userId;

  UserProfilePageWrapper({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("User Profile Page Wrapper Built");
    return BlocProvider<UserProfileBloc>(
        bloc: UserProfileBloc(context, this.userId), child: UserProfilePage());
  }
}

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("User Profile Page Built");
    final UserProfileBloc bloc = BlocProvider.of<UserProfileBloc>(context);
    return StreamBuilder(
        stream: bloc.getPage,
        initialData: bloc._page,
        builder: (context, snapshot) {
          return UserProfileRouteController()
              .routeSwitcher(context, snapshot.data);
        });
  }
}
