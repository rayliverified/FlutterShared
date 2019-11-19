import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/ui/ralert/rflutter_alert.dart';
import 'package:nocd/utils/utils_image.dart';
import 'package:rxdart/rxdart.dart';

/**
 * A custom [BackButton] with user configurable [color].
 */
class BackButtonColored extends BackButton {
  final Color color;

  const BackButtonColored({Key key, this.color}) : super(key: key);

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

/**
 * A custom [FlatButton] that reacts to loading state.
 *
 * Displays a progress spinner and also disables multiple clicks.
 * Button container must specify size. Button will expand to fill container.
 */
class LoadingFlatButton extends StatelessWidget {
  /// Stream that returns true or false for loading state.
  final ValueObservable stream;

  /// Initial loading state.
  final bool initialData;

  /// Function to call when pressed.
  final Function action;

  /// Button text.
  final String text;

  /// Button primary color.
  final Color color;

  /// Button background color.
  final Color backgroundColor;

  /// Corner radii.
  final BorderRadius borderRadius;

  LoadingFlatButton(this.stream, this.initialData, this.action, this.text,
      this.color, this.backgroundColor, this.borderRadius);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        return FlatButton.icon(
          onPressed: !snapshot.data ? action : () {},
          color: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textColor: color,
          padding: EdgeInsets.all(0),
          icon: snapshot.data
              ? Padding(
                  //Add a bottom padding to center the loading indicator with text.
                  padding: const EdgeInsets.only(bottom: 2),
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    width: 15,
                    height: 15,
                  ),
                )
              : Center(),
          label: Padding(
            padding: snapshot.data
                ? const EdgeInsets.only(right: 23)
                : EdgeInsets.only(right: 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Product Sans",
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
        );
      },
    );
  }
}

/**
 * Show a dialog selector with [title] and a list of string [options]
 * Displays a [SimpleDialog] widget.
 */
Future<String> asyncSimpleDialogSelector(
    BuildContext context, title, List<String> options) async {
  return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: "Product Sans",
              fontWeight: FontWeight.bold,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          children: generateSimpleDialogOptions(context, options),
        );
      });
}

/**
 * Dynamically generate dialog string [options].
 * Returns a [list] of [SimpleDialogOption] widgets.
 * Passes the selected option back to the dialog.
 */
List<Widget> generateSimpleDialogOptions(
    BuildContext context, List<String> options) {
  List<Widget> list = List();
  for (String option in options) {
    list.add(SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, option);
      },
      child: Text(option,
          style: TextStyle(
            fontFamily: "Product Sans",
            fontSize: 18,
          )),
    ));
  }
  return list;
}

class BackButtonCustom extends StatelessWidget {
  final Image image;

  final Function onPressed;

  final double width;

  const BackButtonCustom(this.image, this.onPressed, {this.width = 52});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: this.width,
        height: 52,
        child: FlatButton(
          onPressed: onPressed,
          color: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          textColor: Color.fromARGB(255, 0, 0, 0),
          padding: EdgeInsets.all(16),
          child: image,
        ),
      ),
    );
  }
}

Widget getAvatarImage(String avatar) {
  return Image.asset(
    getAvatarAssetPath(avatar),
    fit: BoxFit.fill,
  );
}

String getAvatarAssetPath(String avatar) {
  switch (avatar) {
    case "avatar_0":
      return "assets/images/avatar_0_circle.png";
    case "avatar_1":
      return "assets/images/avatar_1_circle.png";
    case "avatar_2":
      return "assets/images/avatar_2_circle.png";
    case "avatar_3":
      return "assets/images/avatar_3_circle.png";
    case "avatar_4":
      return "assets/images/avatar_4_circle.png";
    case "avatar_5":
      return "assets/images/avatar_5_circle.png";
    case "avatar_6":
      return "assets/images/avatar_6_circle.png";
    case "avatar_7":
      return "assets/images/avatar_7_circle.png";
    case "avatar_8":
      return "assets/images/avatar_8_circle.png";
    case "avatar_logo":
      return "assets/images/image_nocd_circle.png";
    default:
      return "assets/images/avatar_0_circle.png";
  }
}

Widget getPostAvatar(String avatarType,
    {String avatarName, String avatarImg, int res = 256}) {
  switch (avatarType) {
    case "nocd_pro":
    case "nocd_advocate":
      if (avatarImg?.isNotEmpty ?? false) {
        return Image.network(
          ImageUtils.getCloudinaryThumbnailClinician(avatarImg, res: res),
          fit: BoxFit.contain,
        );
      } else {
        return getAvatarImage("avatar_logo");
      }
      break;
    default:
      return getAvatarImage(avatarName);
  }
}

void alertError(BuildContext context, String errorMessage, Function onPressed) {
  Alert(
    context: context,
    type: AlertType.error,
    title: errorMessage,
    style: AlertStyle(isOverlayTapDismiss: false, overlayColor: Colors.black38),
    buttons: [
      DialogButton(
        child: Text(
          "Retry",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: onPressed,
        width: 120,
      ),
    ],
  ).show();
}

void alertFeedback(BuildContext context, String title, String body, String hint,
    Function onPressed) {
  TextEditingController textEditingController = TextEditingController();
  Alert(
      style: AlertStyle(
        titleStyle: TextStyle(fontSize: 18, color: textPrimary),
        descStyle: TextStyle(fontSize: 14, color: textSecondary),
      ),
      context: context,
      title: title,
      desc: body,
      content: Container(
        margin: EdgeInsets.only(left: 4, top: 12, right: 4, bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(128, 218, 218, 218),
                blurRadius: 5,
              ),
            ],
            border: Border.all(
                color: textSecondaryLight, width: 1, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.hardEdge,
            child: Container(
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintMaxLines: 5,
                  focusColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          height: 35,
        ),
        DialogButton(
          onPressed: () {
            onPressed(textEditingController.text);
          },
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          height: 35,
        )
      ]).show();
}

void alertConfirmation(BuildContext context, String title, Function onPressed,
    {String description, String buttonText = "Confirm"}) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: title,
    desc: description,
    style: AlertStyle(overlayColor: Colors.black38),
    buttons: [
      DialogButton(
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: onPressed,
        width: 120,
      ),
    ],
  ).show();
}

/**
 * Page loading indicator.
 */
Widget loadingIndicator() {
  return Center(child: CupertinoActivityIndicator(radius: 16));
}

class LoadingFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: loadingIndicator(),
    );
  }
}

/*
 * Menu item with CupertinoSwitch toggle.
 *
 * Required menu [title] and initial switch boolean [value].
 * Optional [margins] to space menu item and [onChanged] function
 * switch callback.
 *
 * Used in [GroupChatInformationPageWrapper].
 */
class MenuToggleOption extends StatelessWidget {
  final EdgeInsets margins;
  final String title;
  final bool value;
  final Function onChanged;

  MenuToggleOption(this.title, this.value,
      {Key key, this.margins, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margins,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap:
              null, // Setting onTap intercepts tap from switch. Set tap to null to propagate taps.
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 24),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18),
                    )),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20, right: 35),
                  width: 12,
                  height: 20,
                  child: CupertinoSwitch(
                      activeColor: Color(0xFF00A3AD),
                      onChanged: (value) {
                        onChanged(value);
                      },
                      value: value),
                ),
              ]),
        ),
      ),
    );
  }
}
