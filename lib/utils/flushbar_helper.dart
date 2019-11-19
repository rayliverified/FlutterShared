import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/**
 * A provider for custom [Flushbar] configurations.
 */
class FlushbarHelperProvider extends FlushbarHelper {
  /// Error Flushbar with customizable [message] and [title].
  static Flushbar createError(
      {@required String message,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Flushbar(
      title: title,
      message: message,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon:
          //Add a left padding to center the icon.
          Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(
          Icons.warning,
          size: 28.0,
          color: Colors.red[400],
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8.0,
      duration: duration,
    );
  }

  static Flushbar createInfo(
      {@required String message,
      String title,
      Duration duration = const Duration(seconds: 2),
      double width = 120}) {
    return Flushbar(
      title: title,
      message: message,
      flushbarStyle: FlushbarStyle.FLOATING,
      maxWidth: width,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8.0,
      duration: duration,
    );
  }
}
