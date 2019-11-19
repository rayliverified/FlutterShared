import 'package:flutter/material.dart';

class ImageFixedHeight extends StatelessWidget {
  ImageFixedHeight(Key key, this.buildContext, this.image, this.height,
      {this.imageRatio = 1.50})
      : super(key: key);
  final BuildContext buildContext;
  final String image;
  final double height;
  final double imageRatio;

  @override
  Widget build(BuildContext context) {
    double width = imageRatio * height;

    return new Material(
      borderRadius: new BorderRadius.circular(4.0),
      elevation: 8.0,
      shadowColor: new Color(0xCC000000),
      child: new FadeInImage.assetNetwork(
        image: image,
        placeholder: "assets/placeholder_cover.jpg",
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ImageFixedWidth extends StatelessWidget {
  ImageFixedWidth(this.image, this.width, {this.imageRatio});
  final String image;
  final double width;
  final double imageRatio;

  @override
  Widget build(BuildContext context) {
    double height = imageRatio == null ? width : imageRatio * width;

    return FadeInImage.assetNetwork(
      image: image,
      placeholder: "",
      width: width,
      height: height,
      fit: BoxFit.cover,
      fadeOutDuration: Duration(milliseconds: 100),
      fadeInDuration: Duration(milliseconds: 200),
    );
  }
}
