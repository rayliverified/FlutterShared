import 'package:flutter/material.dart';
import 'package:flutter_android/main.dart';
import 'package:flutter_android/page/page_delete_account.dart';

class RouteSwitcher {
  Widget widgetForRoute(String route) {
    print("Switch Route: " + route);
    switch (route) {
      case 'page_main':
        return MyApp();
      case 'page_transparent':
        return Transparent();
      case 'page_delete_account':
        return DeleteAccount1();
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
