import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

//TODO Convert to immutable with others.
class ShimmerRectangle extends StatelessWidget {
  double width;

  double height;

  double radius = 10;

  Color baseColor = Colors.grey[300];

  Color highlightColor = Colors.grey[100];

  ShimmerRectangle(
      {double width,
      double height,
      double radius,
      Color baseColor,
      Color highlightColor}) {
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.radius = radius ?? this.radius;
    this.baseColor = baseColor ?? this.baseColor;
    this.highlightColor = highlightColor ?? this.highlightColor;
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              color: Colors.white),
        ),
      ),
    );
  }
}

//TODO Convert to immutable with others.
class ShimmerRound extends StatelessWidget {
  double width;

  double height;

  Color baseColor = Colors.grey[300];

  Color highlightColor = Colors.grey[100];

  ShimmerRound(
      {double width, double height, Color baseColor, Color highlightColor}) {
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.baseColor = baseColor ?? this.baseColor;
    this.highlightColor = highlightColor ?? this.highlightColor;
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  int lineCount = 1;

  double lineSpacing = 4;

  double lineWidth;

  double lineHeight;

  double lineRadius = 10;

  Color baseColor = Colors.grey[300];

  Color highlightColor = Colors.grey[100];

  ShimmerText(
      {int lineCount,
      double lineSpacing,
      double lineWidth,
      double lineHeight,
      double lineRadius,
      Color baseColor,
      Color highlightColor}) {
    this.lineCount = lineCount ?? this.lineCount;
    this.lineSpacing = lineSpacing ?? this.lineSpacing;
    this.lineWidth = lineWidth ?? this.lineWidth;
    this.lineHeight = lineHeight ?? this.lineHeight;
    this.lineRadius = lineRadius ?? this.lineRadius;
    this.baseColor = baseColor ?? this.baseColor;
    this.highlightColor = highlightColor ?? this.highlightColor;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: lineWidth,
              height: lineHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(lineRadius)),
                  color: Colors.white),
            ),
          ),
          separatorBuilder: (context, index) => Container(height: lineSpacing),
          itemCount: lineCount,
        ),
      ),
    );
  }
}
