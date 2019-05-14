import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/page/page_main.dart';
import 'package:flutter_android/themes.dart';
import 'package:flutter_android/utils.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(BlocProvider<AppBloc>(bloc: AppBloc(), child: App()));

class AppBloc implements BlocBase {
  static const channel = MethodChannel('app');

  String _page = window.defaultRouteName ?? "";
  bool _back = false;

  BehaviorSubject<String> pageController = BehaviorSubject<String>();
  ValueObservable get getPage => pageController;

  void dispose() {
    pageController.close();
  }

  AppBloc() {
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
        case 'page':
          updatePage(call.arguments);
          return;
        case 'navigation':
          switch (call.arguments) {
            case "back":
              {}
          }
          return;
        default:
          throw MissingPluginException();
      }
    });
  }

  void navigate(Navigation navigation) {
    switch (navigation) {
      case Navigation.BACK:
        navigateBack();
        return;
    }
  }

  void navigateBack() async {
    try {
      print(await channel.invokeMethod("navigation", "back"));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }

  void sendBackStatus(bool backStatus) async {
    try {
      print(await channel.invokeMethod("back_status", backStatus));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }
}

enum Navigation { BACK }

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return StreamBuilder(
        stream: appBloc.getPage,
        initialData: appBloc._page,
        builder: (context, snapshot) {
          return _widgetForRoute(snapshot.data);
        });
  }
}

Widget _widgetForRoute(String route) {
  print("Switch Route: " + route);
  switch (route) {
    case 'page_main':
      return MyApp();
    case 'page_transparent':
      return Transparent();
    default:
      return Center(
        child: Text(
          'Unknown route: $route',
          textDirection: TextDirection.ltr,
        ),
      );
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
          body: Center(
              child: GestureDetector(
                  onTap: () {
                    appBloc.navigate(Navigation.BACK);
                  },
                  child: Text('Transparent Scaffold Background'))),
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
