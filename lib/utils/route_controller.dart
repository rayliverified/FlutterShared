import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/group_chat/page_group_chat_home.dart';
import 'package:nocd/page/notifications/page_notifications.dart';
import 'package:nocd/page/page_delete_account.dart';
import 'package:nocd/page/page_report_message.dart';
import 'package:nocd/page/page_report_message_complete.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';

/**
 * A controller to fetch the correct widget from a page constant.
 */
class RouteController {
  // TODO: Rename these to prefix with ROUTE
  static const String PAGE_DELETE_ACCOUNT = "PAGE_DELETE_ACCOUNT";
  static const String PAGE_DATA_COLLECTION = "PAGE_DATA_COLLECTION";
  static const String PAGE_USER_PROFILE = "PAGE_USER_PROFILE";
  static const String PAGE_POST_THREAD = "PAGE_POST_THREAD";
  static const String PAGE_NOTIFICATIONS = "PAGE_NOTIFICATIONS";
  static const String PAGE_GROUP_CHAT = 'PAGE_GROUP_CHAT';
  static const String PAGE_REPORT_MESSAGE = 'PAGE_REPORT_MESSAGE';
  static const String PAGE_REPORT_MESSAGE_COMPLETE =
      'PAGE_REPORT_MESSAGE_COMPLETE';
  static const String PAGE_BLANK = "PAGE_BLANK";

  /// Returns the widget that matches [route] or [DefaultBlank] as default.
  Widget widgetForRoute(String route) {
    print("Switch Route: " + route);
    switch (route) {
      case PAGE_DELETE_ACCOUNT:
        return DeleteAccountPageWrapper();
      case PAGE_DATA_COLLECTION:
        return DataCollectionPageWrapper();
      case PAGE_USER_PROFILE:
        return UserProfilePageWrapper();
      case PAGE_POST_THREAD:
        return PostThreadPage();
      case PAGE_NOTIFICATIONS:
        return NotificationsPageWrapper();
      case PAGE_GROUP_CHAT:
        return GroupChatHomePageWrapper();
      case PAGE_REPORT_MESSAGE:
        return ReportMessagePageWrapper();
      case PAGE_REPORT_MESSAGE_COMPLETE:
        return ReportMessageCompletePage();
      case PAGE_BLANK:
      default:
        return DefaultBlank();
    }
  }

  /// Return the previous page route.
  String getPreviousPage(List<String> routes, String currentRoute) {
    int routePosition = routes.indexOf(currentRoute);
    if (routePosition != -1 && routePosition > 0) {
      return routes[routePosition - 1];
    }

    return "";
  }

  /// Return the next page route.
  String getNextPage(List<String> routes, String currentRoute) {
    int routePosition = routes.indexOf(currentRoute);
    if (routePosition != -1 && routePosition < routes.length - 1) {
      return routes[routePosition + 1];
    }

    return "";
  }
}
