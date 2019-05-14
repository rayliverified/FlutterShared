import 'package:flutter/material.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/main.dart';
import 'package:flutter_android/model/game.dart';
import "package:flutter_android/page/page_game_details.dart";
import "package:flutter_android/ui/item_game_box.dart";

class GameContainerItem extends StatelessWidget {
  GameContainerItem(this.buildContext, this.game);
  final BuildContext buildContext;
  final Game game;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: new InkWell(
        onTap: () => _goGameDetailsPage(context, game),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Hero(
              tag: game.name,
              child: new GameBoxItem(context, game, width: 120.0),
            ),
            new Padding(padding: const EdgeInsets.only(top: 6.0)),
            new ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Text(game.name,
                        style: Theme.of(context).textTheme.display1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    new Text(game.getPlatforms(),
                        style: Theme.of(context).textTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.fade),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _goGameDetailsPage(BuildContext context, Game game) {
    AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.updateBack(true);
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (c) {
          return new GameDetailsPage(game);
        },
      ),
    );
  }
}
