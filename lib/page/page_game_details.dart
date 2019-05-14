import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/component/item_description.dart';
import 'package:flutter_android/component/item_header_game.dart';
import 'package:flutter_android/controller/scroll_horizontal_screenshots.dart';
import 'package:flutter_android/main.dart';
import 'package:flutter_android/model/game.dart';
import 'package:flutter_android/ui/back_helper.dart';

class GameDetailsPage extends StatefulWidget {
  GameDetailsPage(this.game, {Key key}) : super(key: key);

  final Game game;

  @override
  _GameDetailsPageState createState() => new _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return BackHelper(
        child: new Material(
      borderRadius: new BorderRadius.circular(8.0),
      child: new SingleChildScrollView(
        child: new Column(
          children: [
            new GameDetailHeader(widget.game),
            new Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0.0),
              child: new SizedBox(
                width: double.infinity,
                // height: double.infinity,
                child: new RaisedButton(
                  onPressed: () => {},
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: new Icon(
                          Icons.adjust,
                          color: Colors.white,
                        ),
                      ),
                      new Text(
                        "Rent",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .apply(color: Colors.white),
                      ),
                    ],
                  ),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(4.0)),
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.green,
                  highlightColor: Colors.green.shade400,
                  splashColor: Colors.green.shade400,
                  elevation: 8.0,
                  highlightElevation: 10.0,
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: new SizedBox(
                width: double.infinity,
                // height: double.infinity,
                child: new OutlineButton(
                  onPressed: () => {},
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: new Icon(
                          Icons.archive,
                          color: Colors.green,
                        ),
                      ),
                      new Text(
                        "Buy",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .apply(color: Colors.green),
                      ),
                    ],
                  ),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(4.0)),
                  padding: const EdgeInsets.all(12.0),
                  borderSide: new BorderSide(color: Colors.green, width: 4.0),
                  color: Colors.white,
                  highlightColor: Colors.white70,
                  splashColor: Colors.green.shade200,
                  highlightElevation: 0.0,
                  highlightedBorderColor: Colors.green.shade400,
                ),
              ),
            ),
            new Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: new DescriptionText(widget.game.description)),
            new Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: new HorizontalScreenshotController(
                    widget.game.screenshots)),
          ],
        ),
      ),
    ));
  }
}
