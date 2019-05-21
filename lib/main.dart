import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/page/page_main.dart';
import 'package:flutter_android/route_switcher.dart';
import 'package:flutter_android/themes.dart';
import 'package:flutter_android/utils.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(BlocProvider<AppBloc>(bloc: AppBloc(), child: App()));

class AppBloc implements BlocBase {
  static const String CHANNEL_METHOD_PAGE = "CHANNEL_METHOD_PAGE";
  static const String CHANNEL_METHOD_NAVIGATION = "CHANNEL_METHOD_NAVIGATION";
  static const String NAVIGATION_BACK = "NAVIGATION_BACK";
  static const String NAVIGATION_CLOSE = "NAVIGATION_CLOSE";
  static const String CHANNEL_METHOD_BACK_STATUS = "CHANNEL_METHOD_BACK_STATUS";
  static const channel = MethodChannel('app');

  String _page = window.defaultRouteName ?? "";
  bool _back = false;

  BehaviorSubject<String> pageController = BehaviorSubject<String>();
  ValueObservable get getPage => pageController;

  void dispose() {
    pageController.close();
  }

  AppBloc() {
    _page = RouteSwitcher.PAGE_DELETE_ACCOUNT;
    initPlatformChannels();
  }

  void updatePage(String page) {
    _page = page;
    pageController.sink.add(_page);
  }

  void updateBack(bool back) {
    if (_back != back) {
      _back = back;
      sendBackStatus(_back);
    }
  }

  void initPlatformChannels() async {
    // Receive method invocations from platform and return results.
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case AppBloc.CHANNEL_METHOD_PAGE:
          updatePage(call.arguments);
          return;
        case AppBloc.CHANNEL_METHOD_NAVIGATION:
          switch (call.arguments) {
            case AppBloc.NAVIGATION_BACK:
              {}
          }
          return;
        default:
          throw MissingPluginException();
      }
    });
  }

  void navigate(String navigation) {
    switch (navigation) {
      case AppBloc.NAVIGATION_BACK:
        navigateBack();
        return;
      case AppBloc.NAVIGATION_CLOSE:
        navigateClose();
        return;
    }
  }

  //BEGIN: Back navigation
  void navigateBack() async {
    try {
      print(await channel.invokeMethod(
          CHANNEL_METHOD_NAVIGATION, NAVIGATION_BACK));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }

  void sendBackStatus(bool backStatus) async {
    try {
      print(await channel.invokeMethod(
          AppBloc.CHANNEL_METHOD_BACK_STATUS, backStatus));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }

  //END: Back Navigation
  void navigateClose() async {
    updatePage(RouteSwitcher.PAGE_BLANK);
    try {
      print(await channel.invokeMethod(
          AppBloc.CHANNEL_METHOD_NAVIGATION, AppBloc.NAVIGATION_CLOSE));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return StreamBuilder(
        stream: appBloc.getPage,
        initialData: appBloc._page,
        builder: (context, snapshot) {
          return RouteSwitcher().widgetForRoute(snapshot.data);
        });
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: defaultTheme,
      home: new MainPage(),
    );
  }
}

class Transparent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);

    return new MaterialApp(
        title: 'Flutter Transparent',
        theme: transparentTheme,
        home: Scaffold(
          body: Container(
            child: Center(
                child: GestureDetector(
                    onTap: () {
                      appBloc.navigate(AppBloc.NAVIGATION_BACK);
                    },
                    child: Text('Transparent Scaffold Background',
                        style: TextStyle(color: Colors.white)))),
          ),
          backgroundColor: HexColor('#00FFFFFF'),
        ));
  }
}

//UNUSED: App Provider implementation.
//class AppBloc implements BlocBase {
//  AppProvider appProvider = AppProvider();
//
//  //UNUSED: Example using dart:async Streams.
//  StreamController<String> appController = StreamController();
//  Stream get getPage => appController.stream;
//
//  AppBloc() {
//  }
//
//  void updatePage(String page) {
//    appProvider.updatePage(page);
//    appController.sink.add(appProvider._page);
//  }
//
//  void dispose() {
//    appController.close();
//  }
//}

//UNUSED: App Provider wrapper for complex value mutations.
//class AppProvider {
//  String _page = window.defaultRouteName ?? "";
//
//  void updatePage(String page) {
//    _page = page;
//  }
//}
