import 'package:flutter/material.dart';

import 'package:flutter_android/component/item_screenshot_container.dart';

class HorizontalScreenshotController extends StatelessWidget {
  HorizontalScreenshotController(this.screenshots);
  final List<String> screenshots;

  @override
  Widget build(BuildContext context) {
    const double height = 240.0;

    return new SizedBox.fromSize(
      size: const Size.fromHeight(height),
      child: new ListView.builder(
          itemCount: screenshots.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 12.0),
          itemBuilder: (BuildContext context, int position) {
            return ScreenshotContainerItem(context, screenshots[position], height: height - 16.0);
          }),
    );
  }
}
