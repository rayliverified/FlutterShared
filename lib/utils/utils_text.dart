import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nocd/utils/error_helper.dart';

class TextUtils {
  static String getDomainName(String url) {
    try {
      Uri uri = Uri.parse(url);
      String domain = uri.host;
      return (uri.host.startsWith("www.")) ? domain.substring(4) : domain;
    } on FormatException catch (e) {
      return "treatmyocd.com";
    }
  }

  /**
   * Toggle TextField Focus.
   *
   * Place text cursor into [focusNode] and show keyboard if [focus] is true.
   */
  void textFieldFocusToggle(
      BuildContext context, FocusNode focusNode, bool focus) {
    if (focus) {
      if (focusNode != null) {
        FocusScope.of(context).requestFocus(focusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    } else {
      focusNode?.unfocus();
    }
  }

  /*
   * Parse ISO8601 to Short Date.
   *
   * Return a short date with conditional logic based
   * on recency. If date is within last day, return only time.
   * If date is older than today, return month, day and time.
   */
  String iso8601ToShortDate(String date) {
    try {
      DateTime currentTime = DateTime.now();
      DateTime today =
          DateTime(currentTime.year, currentTime.month, currentTime.day);
      DateTime dateTimeFormat = DateTime.parse(date);
      bool isToday = !dateTimeFormat.isBefore(today);
      return isToday
          ? DateFormat("h:mm a").format(dateTimeFormat.toLocal())
          : DateFormat("MMM d h:mm a").format(dateTimeFormat.toLocal());
    } on FormatException catch (e) {
      ErrorHelper().reportException(e);
      return "";
    }
  }

  /// Get the current time as a short date.
  String getCurrentShortDate() {
    DateTime currentTime = DateTime.now();
    return iso8601ToShortDate(currentTime.toIso8601String());
  }
}
