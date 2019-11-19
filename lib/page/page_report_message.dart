import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/page/page_report_message_complete.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class ReportMessageModel with ChangeNotifier {
  AppBloc appBloc;
  StreamSubscription backEventListener;
  BuildContext context;
  TextEditingController feedbackController = TextEditingController();

  GroupChatItemModel groupChatItemModel;
  List<String> feedbackButtons = [
    "Suicide or Self Harm",
    "It's Spam",
    "Reassurance",
    "It's Offensive"
  ];
  String selectedButton = "";
  Map<String, String> buttonTextToCategory;
  bool loading = true;
  bool loadingReportMessage = false;

  @override
  void dispose() {
    backEventListener.cancel();
    feedbackController.dispose();
    super.dispose();
  }

  ReportMessageModel(context, groupChatItemModel) {
    this.groupChatItemModel = groupChatItemModel;
    this.context = context;
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Report Message Back Event Received");
      Navigator.maybePop(context);
    });
    buttonTextToCategory = {
      feedbackButtons[0]: "self_harm_suicide",
      feedbackButtons[1]: "spam",
      feedbackButtons[2]: "reassurance",
      feedbackButtons[3]: "offensive",
    };
  }

  bool isFeedbackButtonSelected(String button) {
    return button == selectedButton;
  }

  void selectFeedbackButton(String button) {
    if (button != selectedButton) {
      selectedButton = button;
      notifyListeners();
    }
  }

  void postReportMessage() async {
    loadingReportMessage = true;
    await networkProvider
        .postReportMessage(groupChatItemModel.id,
            buttonTextToCategory[selectedButton], feedbackController.text)
        .then((value) {
      if (value.status != null) {
        loadingReportMessage = false;
        notifyListeners();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ReportMessageCompletePage()));
      } else {
        loadingReportMessage = false;
        notifyListeners();
        alertError(context, value.error.errorMessage, () {
          postReportMessage();
          Navigator.pop(context);
        });
      }
    });
  }
}

/// A wrapper to provide [ReportMessagePage] with [ReportMessageModel].
class ReportMessagePageWrapper extends StatelessWidget {
  final groupChatItemModel;

  ReportMessagePageWrapper({Key key, this.groupChatItemModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportMessageModel>(
      builder: (context) => ReportMessageModel(context, groupChatItemModel),
      child: ReportMessagePage(),
    );
  }
}

class ReportMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportMessageModel>(builder: (context, model, child) {
      return PageWrapper(
        backgroundColor: Color(0xFFe2f5fb),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackHelper(
                child: BackButtonCustom(
                  Image.asset(
                    "assets/images/back_blue.png",
                  ),
                  () => BackHelper.navigateBack(context),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Text(
                  "Help us understand what’s happening",
                  style: TextStyle(fontSize: 22, color: textPrimary),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  "This post is being removed from your feed. Please tell us why.\n\nOther community members can’t see when you flag a post.",
                  style: TextStyle(fontSize: 16, color: textPrimary),
                ),
              ),
              Container(height: 8),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: FeedbackButton(
                              model.feedbackButtons[0],
                              model.isFeedbackButtonSelected(
                                  model.feedbackButtons[0]),
                              () => model.selectFeedbackButton(
                                  model.feedbackButtons[0]))),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: FeedbackButton(
                              model.feedbackButtons[1],
                              model.isFeedbackButtonSelected(
                                  model.feedbackButtons[1]),
                              () => model.selectFeedbackButton(
                                  model.feedbackButtons[1]))),
                    ),
                  ],
                ),
              ),
              Container(height: 4),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: FeedbackButton(
                              model.feedbackButtons[2],
                              model.isFeedbackButtonSelected(
                                  model.feedbackButtons[2]),
                              () => model.selectFeedbackButton(
                                  model.feedbackButtons[2]))),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: FeedbackButton(
                              model.feedbackButtons[3],
                              model.isFeedbackButtonSelected(
                                  model.feedbackButtons[3]),
                              () => model.selectFeedbackButton(
                                  model.feedbackButtons[3]))),
                    ),
                  ],
                ),
              ),
              Container(height: 8),
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(128, 218, 218, 218),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      child: TextField(
                        controller: model.feedbackController,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: "Additional Comments",
                          border: InputBorder.none,
                          hintMaxLines: 5,
                          focusColor: Colors.transparent,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "If someone is in immediate danger, tell them to call their local emergency service or go to the hospital.",
                  style: TextStyle(fontSize: 14, color: textPrimary),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: NextButton(
                  model.selectedButton.isNotEmpty,
                  () => model.postReportMessage(),
                  text: "Submit",
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

Widget FeedbackButton(String text, bool selected, Function onPressed) {
  return FlatButton(
    onPressed: onPressed,
    color: selected ? Color(0xFF315C83) : Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
    textColor: selected ? Colors.white : textPrimary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Text(
      text,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    ),
  );
}
