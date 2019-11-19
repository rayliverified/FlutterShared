
import 'package:flutter/cupertino.dart';
import 'package:nocd/page/notifications/page_notification_settings.dart';
import 'package:nocd/page/notifications/page_notifications.dart';
import 'package:nocd/page/notifications/page_notifications_overview.dart';

class NotificationsRouteController {
  static const String PAGE_NOTIFICATIONS = "PAGE_NOTIFICATIONS";
  static const String PAGE_NOTIFICATIONS_OVERVIEW = "PAGE_NOTIFICATIONS_OVERVIEW";
  static const String PAGE_NOTIFICATION_SETTINGS = "PAGE_NOTIFICATION_SETTINGS";

  Widget routeSwitcher(BuildContext context, String page) {
    print("UserProfileRouteController: " + page);
    switch (page) {
      case PAGE_NOTIFICATIONS_OVERVIEW:
        return NotificationsOverviewPageWrapper();
      case PAGE_NOTIFICATION_SETTINGS:
        return NotificationSettingsPageWrapper();
      default:
        return Container();
    }
  }
}
