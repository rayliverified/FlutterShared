import 'package:flutter/material.dart';

class SelectableButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;

  const SelectableButton(this.text, this.selected, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.transparent,
        borderRadius: new BorderRadius.all(Radius.circular(10.0)),
        border: new Border.all(
            color: selected
                ? Color.fromARGB(255, 78, 146, 223)
                : Color.fromARGB(0, 255, 255, 255),
            width: 5.0,
            style: BorderStyle.solid),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: const Color(0x64C6C6C6),
              offset: Offset(0, 0),
              blurRadius: 10.0,
              spreadRadius: 2),
        ],
      ),
      child: FlatButton(
        onPressed: this.onPressed,
        color: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9))),
        textColor: Color.fromARGB(255, 31, 75, 117),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class YesNoButton extends StatefulWidget {
  final bool initialYesSelected;
  final bool initialNoSelected;
  final Function(bool, bool) selectedYesNoCb;

  YesNoButton(
      this.initialYesSelected, this.initialNoSelected, this.selectedYesNoCb);

  @override
  State createState() {
    return new YesNoButtonState(
        this.initialYesSelected, this.initialNoSelected, this.selectedYesNoCb);
  }
}

class YesNoButtonState extends State<YesNoButton> {
  bool yesSelected;
  bool noSelected;
  final Function(bool, bool) selectedYesNoCb;

  YesNoButtonState(this.yesSelected, this.noSelected, this.selectedYesNoCb);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 90,
      margin: EdgeInsets.only(left: 25, right: 25, top: 45),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SelectableButton("Yes", yesSelected, () {
            this.yesSelected = true;
            this.noSelected = false;

            this.selectedYesNoCb(this.yesSelected, this.noSelected);
          })),
          Container(width: 25),
          Expanded(
              child: SelectableButton("No", noSelected, () {
            this.yesSelected = false;
            this.noSelected = true;

            this.selectedYesNoCb(this.yesSelected, this.noSelected);
          })),
        ],
      ),
    );
  }
}
