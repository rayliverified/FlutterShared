import 'package:flutter/material.dart';

Color materialSplashRipple() {
  return Color.fromARGB(23, 0, 0, 0);
}

Widget visibilityWrapper(Widget widget1, Widget widget2, bool visible) {
  return visible ? widget1 : widget2;
}
