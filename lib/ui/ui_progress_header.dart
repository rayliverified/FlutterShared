import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/utils/error_helper.dart';

/**
 * A custom app bar with navigation controls and a [FAProgressBar].
 */
class ProgressHeader extends StatelessWidget {
  /// Progress value.
  final int progress;

  /// Progress complete value.
  final int total;

  /// Function to call on back button click.
  final Function backClick;

  /// Function to call on exit button click.
  final Function exitClick;

  ProgressHeader(this.progress, this.total, this.backClick, this.exitClick);

  @override
  Widget build(BuildContext context) {
    // Progress must be between 0 and 100.
    if (total == 0 || (progress / total) < 0 || (progress / total) > 1) {
      ErrorHelper().reportErrorMessage(
          "ProgressHeader: Out of bounds progress value [progress: " +
              progress.toString() +
              ", total: " +
              total.toString() +
              "]");
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: 16, left: 8, right: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              child: FlatButton(
                onPressed: backClick,
                color: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                textColor: Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  "assets/images/back_blue.png",
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              child: FlatButton(
                onPressed: exitClick,
                color: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                textColor: Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  "assets/images/close_blue.png",
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: FAProgressBar(
                  currentValue: ((progress / total) * 100).toInt(),
                  animatedDuration: Duration(milliseconds: 0),
                  backgroundColor: Colors.white,
                  progressColor: blue,
                  borderRadius: 10,
                  size: 15,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Text(
                progress.toString() + "/" + total.toString(),
                style: TextStyle(
                  color: Color.fromARGB(255, 74, 144, 226),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
