import 'package:flutter/material.dart';

class BackButtonCustom extends BackButton {
  final Color color;

  const BackButtonCustom({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: const BackButtonIcon(),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}
