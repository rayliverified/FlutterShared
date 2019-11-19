/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 * 
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/material.dart';

import 'alert_style.dart';
import 'animation_transition.dart';
import 'constants.dart';
import 'dialog_button.dart';

/// Main class to create alerts.
///
/// You must call the "show()" method to view the alert class you have defined.
class Alert {
  final BuildContext context;
  final AlertType type;
  final AlertStyle style;
  final Image image;
  final String title;
  final String desc;
  final Widget content;
  final List<Widget> buttons;
  final Function closeFunction;
  final bool popContextOnClose;

  /// Alert constructor
  ///
  /// [context], [title] are required.
  Alert(
      {@required this.context,
      this.type,
      this.style = const AlertStyle(),
      this.image,
      @required this.title,
      this.desc,
      this.content,
      this.buttons,
      this.closeFunction,
      this.popContextOnClose = true});

  /// Displays defined alert window
  Future<bool> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return _buildDialog();
      },
      barrierDismissible: style.isOverlayTapDismiss,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: style.overlayColor,
      transitionDuration: style.animationDuration,
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          _showAnimation(animation, secondaryAnimation, child),
    );
  }

// Will be added in next version.
  // void dismiss() {
  //   Navigator.pop(context);
  // }

  // Alert dialog content widget
  Widget _buildDialog() {
    return ConstrainedBox(
      constraints: style.constraints ??
          BoxConstraints.expand(
              width: double.infinity, height: double.infinity),
      child: AlertDialog(
        backgroundColor:
            style.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
        shape: style.alertBorder ?? _defaultShape(),
        titlePadding: EdgeInsets.all(0.0),
        contentPadding: EdgeInsets.all(0.0),
        content: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: <Widget>[
                        _getImage(),
                        Text(
                          title,
                          style: style.titleStyle,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                        ),
                        SizedBox(
                          height: title == null ? 0 : 8,
                        ),
                        desc == null
                            ? Container()
                            : Text(
                                desc,
                                style: style.descStyle,
                                textAlign: TextAlign.center,
                              ),
                        content == null ? Container() : content,
                        Padding(
                          padding: style.buttonAreaPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _getButtons(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _getCloseButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns alert default border style
  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
  }

// Returns the close button on the top right
  Widget _getCloseButton() {
    return style.isCloseButton
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: Container(
              alignment: FractionalOffset.topRight,
              child: GestureDetector(
                onTap: () {
                  if (this.popContextOnClose) {
                    Navigator.pop(context);
                  }
                  if (closeFunction != null) {
                    closeFunction();
                  }
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        '$kImagePath/close.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  // Returns defined buttons. Default: Cancel Button
  List<Widget> _getButtons() {
    List<Widget> expandedButtons = [];
    if (buttons != null) {
      buttons.forEach(
        (button) {
          var buttonWidget = Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: button,
          );
          if (buttons.length == 1) {
            expandedButtons.add(buttonWidget);
          } else {
            expandedButtons.add(Expanded(
              child: buttonWidget,
            ));
          }
        },
      );
    } else {
      expandedButtons.add(
        Expanded(
          child: DialogButton(
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    return expandedButtons;
  }

// Returns alert image for icon
  Widget _getImage() {
    // Use provided image override.
    if (this.image != null) {
      return this.image;
    }

    // Use AlertType image.
    Widget image;
    switch (type) {
      case AlertType.success:
        image = Image.asset(
          '$kImagePath/icon_success.png',
        );
        break;
      case AlertType.error:
        image = Image.asset(
          '$kImagePath/icon_error.png',
        );
        break;
      case AlertType.info:
        image = Image.asset(
          '$kImagePath/icon_info.png',
        );
        break;
      case AlertType.warning:
        image = Image.asset(
          '$kImagePath/icon_warning.png',
        );
        break;
      case AlertType.none:
        image = Container();
        break;
    }

    return image == null
        ? Container()
        : Container(
            height: 80, margin: EdgeInsets.only(bottom: 12), child: image);
  }

// Shows alert with selected animation
  _showAnimation(animation, secondaryAnimation, child) {
    if (style.animationType == AnimationType.fromRight) {
      return AnimationTransition.fromRight(
          animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.fromLeft) {
      return AnimationTransition.fromLeft(animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.fromBottom) {
      return AnimationTransition.fromBottom(
          animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.grow) {
      return AnimationTransition.grow(animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.shrink) {
      return AnimationTransition.shrink(animation, secondaryAnimation, child);
    } else {
      return AnimationTransition.fromTop(animation, secondaryAnimation, child);
    }
  }
}
