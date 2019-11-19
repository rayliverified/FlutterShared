import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/main.dart';
import 'package:nocd/page/notifications/route_notifications.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/error_helper.dart';
import 'package:rxdart/rxdart.dart';

class NotificationsBloc implements BlocBase {
  String _page;
  BehaviorSubject<String> pageController = BehaviorSubject<String>();
  ValueObservable get getPage => pageController;

  AppBloc appBloc;

  List<String> activeRoute = [];

  bool premiumEligible = false;

  NotificationsBloc(BuildContext context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    _page = NotificationsRouteController.PAGE_NOTIFICATIONS_OVERVIEW;
    activeRoute.add(NotificationsRouteController.PAGE_NOTIFICATIONS_OVERVIEW);
    getData(context);
    updatePage(_page);
  }

  @override
  void dispose() {
    pageController.close();
  }

  // BEGIN: Model.
  void getData(BuildContext context) {
    try {
      Map jsonMap = json.decode(appBloc.data);
      if (jsonMap.containsKey("premium_eligible")) {
        premiumEligible = jsonMap["premium_eligible"];
      }
    } on FormatException catch (e) {
      ErrorHelper().reportException(e);
      return;
    }
  }
  // END: Model.

  // BEGIN: Navigation.
  void updatePage(String page) {
    if (this._page != page) {
      this._page = page;
      pageController.sink.add(page);
    }
  }

  void previousPage() {
    activeRoute.removeLast();
    print(activeRoute);
    // TODO Safety check for active route.
    updatePage(activeRoute.last);
  }

  void nextPage(String page) {
    print("Next Page");
    activeRoute.add(page);
    updatePage(page);
  }
  // END: Navigation.
}

/// A wrapper to provide [NotificationsPage] with [NotificationsBloc].
class NotificationsPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
        bloc: NotificationsBloc(context), child: NotificationsPage());
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotificationsBloc bloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder(
        stream: bloc.getPage,
        initialData: bloc._page,
        builder: (context, snapshot) {
          return NotificationsRouteController()
              .routeSwitcher(context, snapshot.data);
        });
  }
}
