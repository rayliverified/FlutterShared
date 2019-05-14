import 'package:flutter/material.dart';

import 'package:flutter_android/model/game.dart';

class RatingInformation extends StatelessWidget {
  RatingInformation(this.game);

  final Game game;

  _buildRatingBar(ThemeData theme) {
    var stars = <Widget>[];

    for (var i = 1; i <= 5; i++) {
      var color = i <= game.rating ? theme.accentColor : Colors.black12;
      var star = new Icon(
        Icons.star,
        color: color,
      );

      stars.add(star);
    }

    return new Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var ratingCaptionStyle = textTheme.caption.copyWith(color: Colors.black45);

    var numericRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text(
          game.rating.toString(),
          style: textTheme.title.copyWith(
            fontWeight: FontWeight.w400,
            color: theme.accentColor,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: new Text(
            'Rating',
            style: ratingCaptionStyle,
          ),
        ),
      ],
    );

    var starRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRatingBar(theme),
//        new Padding(
//          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
//          child: new Text(
//            'Tap to Rate',
//            style: ratingCaptionStyle,
//          ),
//        ),
      ],
    );

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        numericRating,
        new Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: starRating,
        ),
      ],
    );
  }
}
