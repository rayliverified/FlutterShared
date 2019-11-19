import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/main.dart';

enum BuildType { DEBUG, RELEASE }

class DeviceUtils {
  static bool isDebug() => kReleaseMode == false;
  static bool isRelease() => kReleaseMode == true;

  void openUrl(AppBloc appBloc, String url) {
    Map<String, dynamic> data = {
      "event": EVENT_OPEN_URL,
      "url": url,
    };
    appBloc.sendFlutterEvent(data);
  }
}

class NetworkUtils {
  /// Print network requests if app is in debug mode.
  /// Print [response] to console.
  static void debugPrintResponse(Response response) {
    if (DeviceUtils.isDebug()) {
      print(response.data);
      print(response.headers);
      print(response.request);
      print(response.statusCode);
    }
  }
}

List<String> stateList = [
  "Alabama",
  "Alaska",
  "American Samoa",
  "Arizona",
  "Arkansas",
  "California",
  "Colorado",
  "Connecticut",
  "Delaware",
  "District of Columbia",
  "Florida",
  "Georgia",
  "Guam",
  "Hawaii",
  "Idaho",
  "Illinois",
  "Indiana",
  "Iowa",
  "Kansas",
  "Kentucky",
  "Louisiana",
  "Maine",
  "Maryland",
  "Massachusetts",
  "Michigan",
  "Minnesota",
  "Minor Outlying Islands",
  "Mississippi",
  "Missouri",
  "Montana",
  "Nebraska",
  "Nevada",
  "New Hampshire",
  "New Jersey",
  "New Mexico",
  "New York",
  "North Carolina",
  "North Dakota",
  "Northern Mariana Islands",
  "Ohio",
  "Oklahoma",
  "Oregon",
  "Pennsylvania",
  "Puerto Rico",
  "Rhode Island",
  "South Carolina",
  "South Dakota",
  "Tennessee",
  "Texas",
  "U.S. Virgin Islands",
  "Utah",
  "Vermont",
  "Virginia",
  "Washington",
  "West Virginia",
  "Wisconsin",
  "Wyoming",
  "Not in US",
];

/// Convert [value] to int.
int parseToInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String || value is double) {
    return int.parse(value);
  }

  return null;
}

/**
 * Scroll to bottom helper.
 *
 * A scroll helper with a 50 millisecond activation delay
 * to allow the scroll item to finish rendering.
 * Smooth scroll a [scrollController] in [milliseconds] to the bottom.
 */
void scrollToBottomAsync(ScrollController scrollController, int milliseconds) {
  Timer(Duration(milliseconds: 50), () {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: milliseconds),
          curve: Curves.easeOutQuad);
    }
  });
}

/**
 * Scroll to top helper.
 *
 * A scroll helper with a 50 millisecond activation delay
 * to allow the scroll item to finish rendering.
 * Smooth scroll a [scrollController] in [milliseconds] to the top.
 */
void scrollToTopAsync(ScrollController scrollController, int milliseconds) {
  Timer(Duration(milliseconds: 50), () {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: milliseconds),
          curve: Curves.easeOutQuad);
    }
  });
}
