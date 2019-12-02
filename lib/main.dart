import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/model/flavor_config.dart';
import 'package:nocd/model/flutter_config.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/banner_config.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/error_helper.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/route_controller.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:rxdart/rxdart.dart';

/// Global [ErrorHelper] instance to support
/// error reporting from anywhere within the app.
ErrorHelper errorHelper = ErrorHelper();

/// Global [NetworkProvider] instance.
NetworkProvider networkProvider;

Future<Null> main() async {
  /// Desktop embedding support.
  if ((Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  ///  Support method channels on Flutter v1.9+
  WidgetsFlutterBinding.ensureInitialized();

  /// This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (DeviceUtils.isDebug()) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  /**
   * This creates a [Zone] that contains the Flutter application and stablishes
   * an error handler that captures errors and reports them.
   *
   * Using a zone makes sure that as many errors as possible are captured,
   * including those thrown from [Timer]s, microtasks, I/O, and those forwarded
   * from the `FlutterError` handler.
   *
   * More about zones:
   * - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
   * - https://www.dartlang.org/articles/libraries/zones
   */
  runZoned<Future<Null>>(() async {
    runApp(BlocProvider<AppBloc>(bloc: AppBloc(), child: App()));
  }, onError: (error, stackTrace) async {
    await errorHelper.reportError(error, stackTrace);
  });
}

/**
 * A global bloc that controls application state.
 *
 * This bloc acts as a global singleton accessible from any widget within the app.
 * Controls active widget [_route] navigation routing.
 * Tracks and propagates [_back] navigation stack status to host app.
 * Stores static flavor values from [_flavorConfig].
 */
class AppBloc implements BlocBase {
  static const channel = MethodChannel('app');

  /// App to Flutter. Set active Flutter Module.
  static const String CHANNEL_METHOD_PAGE = "CHANNEL_METHOD_PAGE";

  /// Flutter to App. Notify App to handle navigation events on FLutter module.
  static const String CHANNEL_METHOD_NAVIGATION = "CHANNEL_METHOD_NAVIGATION";

  /// Flutter to App. Notify App to close Flutter Module.
  static const String NAVIGATION_CLOSE = "NAVIGATION_CLOSE";

  /// App to Flutter. Similar to [NAVIGATION_CLOSE] except no additional callback to app is made.
  static const String NAVIGATION_HIDE = "NAVIGATION_HIDE";

  /// App to Flutter. Android only event to propagate back event to Flutter.
  static const String NAVIGATION_BACK = "NAVIGATION_BACK";

  /// App to Flutter. Set Flutter initialization variables.
  static const String CHANNEL_METHOD_CONFIG = "CHANNEL_METHOD_CONFIG";

  /// Flutter to App. Events channel used to perform actions in the App.
  static const String CHANNEL_METHOD_EVENTS = "CHANNEL_METHOD_EVENTS";

  /// App to Flutter. Single event data channel used to send data to Flutter module.
  static const String CHANNEL_METHOD_DATA = "CHANNEL_METHOD_DATA";

  /// Active widget navigation route page name.
  /// Defaults to [initialRoute] or [DefaultBlank] if none is provided.
  String _route = window.defaultRouteName ?? "";

  /// Observable flag that mirrors [Navigator]'s canPop value.
  bool _back = false;

  /// Stream for [getPage].
  BehaviorSubject<String> pageController = BehaviorSubject<String>();

  /// Observable navigation route value.
  ValueObservable get getPage => pageController;

  bool _backEvent = false;

  /// Stream for [getBackEvent].
  PublishSubject<bool> backEventController = PublishSubject<bool>();

  /// Observable back event from Android app.
  ValueObservable get getBackEvent => backEventController.publishValue();

  StreamSubscription backEventListener;

  /// A object to accept config variables from the host app.
  FlutterConfig flutterConfig = FlutterConfig();

  /// A static instance containing flavor specific values.
  /// Default initialize to production flavor.
  FlavorConfig flavorConfig =
      FlavorConfig(flavor: FlavorConfig.ERROR, values: flavorValuesError);

  /// Access token for network authorization.
  String accessToken = "";

  /// String containing data in JSON format.
  String data = "";

  void dispose() {
    pageController.close();
    backEventListener.cancel();
    backEventController.close();
  }

  /// Reset all [AppBloc] variables to the initial state.
  /// A top level Bloc cannot dispose itself so it's state must be reset manually.
  void reset() {
    print("Reset App Bloc");
    updateRoute("");
    setConfig("");
    setData("");
  }

  AppBloc() {
    initPlatformChannels();
    // Manual value configuration for development.
    if (DeviceUtils.isDebug()) {}
  }

  //BEGIN: Navigation
  /// Updates navigation [route] route.
  void updateRoute(String route) {
    print("Data:  " + data + ", Config: " + flutterConfig.toJson().toString());
    print("updateRoute: $route");
    _route = route;
    pageController.sink.add(_route);
    // Verify configuration is set correctly.
    if (_route.isNotEmpty && _route != RouteController.PAGE_BLANK) {
      // Verify access token is set.
      if (accessToken.isEmpty) {
        throw Exception("Unable to load access token. Please try again.");
      }
    }
  }

  /// Update back stream with new event.
  /// All listeners are notified that a back event has been called.
  void updateBackEvent(bool backEvent) {
    this._backEvent = backEvent;
    backEventController.add(_backEvent);
  }

  /// Listen to host app events.
  /// Setup receivers for host app to Flutter module communication.
  void initPlatformChannels() async {
    //Receive method invocations from platform and return results.
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case CHANNEL_METHOD_PAGE:
          updateRoute(call.arguments);
          return;
        case CHANNEL_METHOD_CONFIG:
          setConfig(call.arguments);
          return;
        case CHANNEL_METHOD_DATA:
          setData(call.arguments);
          return;
        case CHANNEL_METHOD_NAVIGATION:
          navigate(call.arguments);
          return;
        default:
          throw MissingPluginException();
      }
    });
  }

  /// Navigation type controller for routing internal navigation events.
  void navigate(String navigation, {Map data}) {
    switch (navigation) {
      case NAVIGATION_CLOSE:
        navigateClose();
        return;
      case NAVIGATION_HIDE:
        navigateHide();
        return;
      case NAVIGATION_BACK:
        updateBackEvent(true);
        return;
    }
  }

  /// Close the Flutter module by sending an event to the host app to hide the FlutterView.
  /// Resets the loaded page to [DefaultBlank].
  void navigateClose() async {
    Map<String, dynamic> data = Map<String, dynamic>();
    data["navigation"] = NAVIGATION_CLOSE;
    data["route"] = _route;

    updateRoute("");
    setData("");

    navigateInvoke(data);
  }

  /// Reset Flutter module to a clean state.
  void navigateHide() async {
    updateRoute("");
    setData("");
  }

  void navigateInvoke(Map<String, dynamic> data) async {
    try {
      print(await channel.invokeMethod(
          CHANNEL_METHOD_NAVIGATION, json.encode(data).toString()));
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }
  //END: Navigation

  /// Send [data] from Flutter to App.
  void sendFlutterEvent(Map<String, dynamic> data) async {
    if (!data.containsKey("event")) {
      print('No "event" key in $data');
      return;
    }

    try {
      // Switch to perform Flutter specific actions.
      switch (data["event"]) {
        case EVENT_LOGOUT:
          reset();
          print(await channel.invokeMethod(
              CHANNEL_METHOD_EVENTS, json.encode(data).toString()));
          return;
        default:
          print(await channel.invokeMethod(
              CHANNEL_METHOD_EVENTS, json.encode(data).toString()));
          return;
      }
    } on PlatformException catch (e) {
      print('Failed: ${e.message}');
    } on MissingPluginException {
      print('Not implemented');
    }
  }

  /// Send Screen Event Start from Flutter to App.
  void sendFlutterScreenStartEvent(String screen) async {
    Map<String, dynamic> data = {
      "event": EVENT_SCREEN_START,
      "screen_name": screen,
    };
    sendFlutterEvent(data);
  }

  /// Send Screen Event End from Flutter to App.
  void sendFlutterScreenEndEvent(String screen) async {
    Map<String, dynamic> data = {
      "event": EVENT_SCREEN_END,
      "screen_name": screen,
    };
    sendFlutterEvent(data);
  }

  //BEGIN: Flutter Config
  /// Deserialize [flutterConfig] to [AppBloc.flutterConfig] ([FlutterConfig]).
  /// Initialize and setup:
  /// *[flavorConfig]
  /// *[accessToken]
  void setConfig(String flutterConfig) {
    if (flutterConfig.isEmpty) {
      print("Empty configuration set.");
      flutterConfig = "{}";
    }
    this.flutterConfig = FlutterConfig.fromJson(flutterConfig);
    setFlavor(this.flutterConfig.flavor);
    setAccessToken(this.flutterConfig.accessToken);
    errorHelper.setSentryUserAttributes(jsonDecode(flutterConfig));
    networkProvider = NetworkProvider(
        this.flavorConfig.values.endpoint, this.flutterConfig.accessToken);
  }

  /// Set [flavor] static values.
  /// Default to [FlavorConfig.PROD].
  void setFlavor(String flavor) {
    print("setFlavor: $flavor");
    switch (flavor) {
      case FlavorConfig.DEV:
        print("Set DEV");
        flavorConfig =
            FlavorConfig(flavor: FlavorConfig.DEV, values: flavorValuesDev);
        return;
      case FlavorConfig.QA:
        flavorConfig =
            FlavorConfig(flavor: FlavorConfig.QA, values: flavorValuesQA);
        return;
      case FlavorConfig.PROD:
        flavorConfig =
            FlavorConfig(flavor: FlavorConfig.PROD, values: flavorValuesProd);
        return;
      default:
        print("Error: Flavor Invalid");
        flavorConfig =
            FlavorConfig(flavor: FlavorConfig.ERROR, values: flavorValuesError);
        return;
    }
  }

  /// Set [accessToken] used for network authorization.
  void setAccessToken(String accessToken) {
    print("setAccessToken: $accessToken");
    this.accessToken = accessToken;
  }
//END: Flutter Config

  /// Set [data] required from the client.
  void setData(String data) {
    print("setData: $data");
    this.data = data;
  }
}

/**
 * Parent widget that listens to the navigation [AppBloc._route] to switch between widgets.
 */
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("App Bloc Built");
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return StreamBuilder(
        stream: appBloc.getPage,
        initialData: appBloc._route,
        builder: (context, snapshot) {
          return MaterialApp(
            home: FlavorBanner(
              child: RouteController().widgetForRoute(snapshot.data),
            ),
            theme: ThemeData(
              fontFamily: Platform.isIOS ? "SF Pro Display" : "Product Sans",
            ),
          );
        });
  }
}

/**
 * A Blank Widget shown by default and upon closing the FlutterView.
 *
 * Contains a [GestureDetector] that closes the FlutterView on click in case the FlutterView is showing so the user is never stuck.
 */
class DefaultBlank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);

    return PageWrapper(
      child: GestureDetector(
          onTap: () => appBloc.navigateClose(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: DeviceUtils.isDebug()
                ? Center(
                    child: Text(
                      "Tap to close.",
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                : null,
          )),
      backgroundColor: Colors.transparent,
    );
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
