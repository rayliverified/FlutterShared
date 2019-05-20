import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/main.dart';

class BackHelper extends StatelessWidget {
  final Widget child;

  const BackHelper({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    //If platform is Android, capture and handle back events.
    if (Platform.isAndroid) {
      return WillPopScope(
        child: child,
        onWillPop: () {
          //Flutter app cannot go back anymore.
          //Send back event to device for handling.
          if (!Navigator.canPop(context)) {
            appBloc.updateBack(false);
            appBloc.navigate(Navigation.BACK);
            return Future<bool>.value(false);
          }

          //Flutter app can still go back. Navigate back.
          Navigator.pop(context);
          //Update back status. Can the Flutter app keep going back?
          bool canPop = Navigator.canPop(context);
          appBloc.updateBack(canPop);
          print("Back Status New: " + canPop.toString());

          //Return false because navigation has been handled manually.
          return Future<bool>.value(false);
        },
      );
    } else {
      //Pass through widget on iOS to enable natural back navigation.
      return child;
    }
  }
}
