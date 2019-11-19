import 'package:flutter/cupertino.dart';

/**
 * A custom title text with image blob component.
 */
class BubbleTitle extends StatelessWidget {
  /// Title text.
  final String title;

  /// A number used to assign an image blob.
  final int pageNumber;

  /// Background bubble image scale factor.
  double bubbleScale;

  /// Title text font size.
  double fontSize;

  EdgeInsets margins;

  BubbleTitle(this.title, this.pageNumber,
      {double bubbleScale = 1.0,
      double fontSize = 22,
      EdgeInsets margins =
          const EdgeInsets.only(left: 16, top: 12, right: 16)}) {
    this.bubbleScale = bubbleScale;
    this.fontSize = fontSize;
    this.margins = margins;
  }

  @override
  Widget build(BuildContext context) {
    const imagePaths = [
      "assets/images/bg_blob_salmon.png",
      "assets/images/bg_blob_blue.png",
      "assets/images/bg_blob_purple.png",
      "assets/images/bg_blob_sea_green.png"
    ];

    return Container(
      height: 70 * this.bubbleScale,
      margin: this.margins,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: 91 * this.bubbleScale,
            height: 58 * this.bubbleScale,
            child: Image.asset(
              imagePaths[(pageNumber - 1) % imagePaths.length],
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              title,
              style: TextStyle(
                  color: Color.fromARGB(255, 31, 75, 117),
                  fontSize: this.fontSize,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
