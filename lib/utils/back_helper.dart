import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocd/main.dart';
import 'package:nocd/utils/bloc_provider.dart';

/**
 * A wrapper for [WillPopScope] used around any back navigation components.
 *
 * Used to detect navigator stack and use the correct back navigation method.
 */
class BackHelper extends StatelessWidget {
  final Widget child;

  const BackHelper({@required this.child}) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    // If platform is Android, capture and handle back events.
    if (Platform.isAndroid) {
      return WillPopScope(
        child: child,
        onWillPop: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          // Detect if Flutter can go back.
          if (!Navigator.canPop(context)) {
            //Flutter app cannot go back anymore.
            //Send back event to device for handling.
            appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
            return Future<bool>.value(false);
          }

          //Flutter app can still go back. Navigate back.
          Navigator.pop(context);
          //Update back status. Can the Flutter app keep going back?
          bool canPop = Navigator.canPop(context);
          print("Back Status New: " + canPop.toString());

          //Return false because navigation has been handled manually.
          return Future<bool>.value(false);
        },
      );
    } else {
      return child;
    }
  }

  // Back event helper for iOS specific logic.
  // WillPopScope is not used on iOS so handle navigation manually on iOS.
  static void navigateBack(BuildContext context) {
    if (Platform.isIOS) {
      if (Navigator.canPop(context)) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Navigator.pop(context);
      } else {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        AppBloc appBloc = BlocProvider.of<AppBloc>(context);
        appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
      }
    }
    else {
      Navigator.maybePop(context);
    }
  }
}
