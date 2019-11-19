import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';

/**
 * A custom slider with a gradient background and value popup.
 */
class GradientSlider extends StatelessWidget {
  /// Current value of slider.
  final double value;

  /// Slider min value.
  final double min;

  /// Slider max value.
  final double max;

  /// Slider divisions.
  final int divisions;

  /// Slider label.
  final String label;

  /// Slider OnChange and OnEnd callback.
  final Function updateSeverity;

  const GradientSlider(
    this.value,
    this.min,
    this.max,
    this.divisions,
    this.label,
    this.updateSeverity,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 70,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: [
                      0,
                      1,
                    ],
                    colors: [
                      Color.fromARGB(255, 135, 183, 237),
                      Color.fromARGB(255, 247, 228, 234),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  min.round().toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  max.round().toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                  child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  tickMarkShape: null,
                  overlayColor: Colors.black12,
                  trackHeight: 20,
                  thumbColor: Colors.grey.shade100,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.transparent,
                  valueIndicatorTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: label,
                  onChangeEnd: (double value) {
                    updateSeverity(value.roundToDouble());
                  },
                  onChanged: (double value) {
                    updateSeverity(value);
                  },
                ),
              )),
            ),
          ],
        ));
  }
}
