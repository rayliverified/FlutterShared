import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleObserver extends WidgetsBindingObserver {
  LifecycleObserver({this.onResumeCallback, this.onPauseCallback});

  final AsyncCallback onResumeCallback;
  final AsyncCallback onPauseCallback;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await onPauseCallback();
        break;
      case AppLifecycleState.resumed:
        await onResumeCallback();
        break;
      default:
        break;
    }
  }
}
