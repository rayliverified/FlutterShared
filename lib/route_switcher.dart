import 'package:flutter/material.dart';
import 'package:flutter_android/main.dart';
import 'package:flutter_android/page/page_delete_account.dart';

class RouteSwitcher {
  static const String PAGE_MAIN = "PAGE_MAIN";
  static const String PAGE_BLANK = "PAGE_BLANK";
  static const String PAGE_TRANSPARENT = "PAGE_TRANSPARENT";
  static const String PAGE_DELETE_ACCOUNT = "PAGE_DELETE_ACCOUNT";

  Widget widgetForRoute(String route) {
    print("Switch Route: " + route);
    switch (route) {
      case PAGE_MAIN:
        return MyApp();
      case PAGE_TRANSPARENT:
        return Transparent();
      case PAGE_DELETE_ACCOUNT:
        return DeleteAccountPageWrapper();
      case PAGE_BLANK:
        return Container();
      default:
        return Center(
          child: Text(
            'Unknown route: $route',
            textDirection: TextDirection.ltr,
          ),
        );
    }
  }
}
