import 'package:flutter/material.dart';
import 'package:nocd/page/user_profile/page_user_avatar_edit.dart';
import 'package:nocd/page/user_profile/page_user_profile_edit.dart';
import 'package:nocd/page/user_profile/page_user_profile_overview.dart';

class UserProfileRouteController {
  static const String PAGE_USER_PROFILE = "PAGE_USER_PROFILE";
  static const String PAGE_USER_EDIT = "PAGE_USER_EDIT";
  static const String PAGE_USER_AVATAR_EDIT = "PAGE_USER_AVATAR_EDIT";
  static const String PAGE_USER_PROFILE_OVERVIEW = "PAGE_USER_PROFILE_OVERVIEW";

  Widget routeSwitcher(BuildContext context, String page) {
    print("UserProfileRouteController: " + page);
    switch (page) {
      case PAGE_USER_PROFILE_OVERVIEW:
        return UserProfileOverviewWrapper();
      case PAGE_USER_EDIT:
        return UserProfileEditWrapper();
      // TODO Create avatar edit screen.
      case PAGE_USER_AVATAR_EDIT:
        return UserAvatarEditWrapper();
      default:
        return Container();
    }
  }
}
