import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';

/**
 * A custom title text with image blob component.
 */
class NextButton extends StatelessWidget {
  /// A number used to assign an image blob.
  final bool enabled;
  final Function onPressed;
  String text;

  NextButton(this.enabled, this.onPressed, {String text = "Next"}) {
    this.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 43,
      margin: EdgeInsets.symmetric(vertical: 24),
      child: FlatButton(
        onPressed: enabled ? this.onPressed : () {},
        color: enabled ? primary : Color.fromARGB(255, 158, 158, 158),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3))),
        textColor: Color.fromARGB(255, 255, 255, 255),
        padding: EdgeInsets.all(0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class NextButtonWithDisclaimer extends StatelessWidget {
  final NextButton nextBtn;
  final String disclaimerText;

  const NextButtonWithDisclaimer(this.nextBtn, this.disclaimerText);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          nextBtn,
          Container(
              margin: EdgeInsets.only(left: 45, right: 45, bottom: 45),
              child: Text(
                disclaimerText,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 158, 158, 158),
                ),
                textAlign: TextAlign.center,
              ))
        ]));
  }
}
