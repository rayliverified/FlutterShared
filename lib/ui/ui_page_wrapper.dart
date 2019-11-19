import 'package:flutter/material.dart';

/**
 * A wrapper widget for common top level page widgets.
 *
 * Widgets and functionality provided:
 * - Scaffold with configurable [backgroundColor].
 * - MediaQuery to set text scale to 1.0.
 */
class PageWrapper extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Scaffold background color. Defaults to transparent if null.
  final Color backgroundColor;

  PageWrapper({@required this.child, this.backgroundColor})
      : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => MediaQuery(
        child: Scaffold(
          backgroundColor: this.backgroundColor ?? Colors.white,
          body: SafeArea(
            child: this.child,
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
