import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';

class ReportMessageCompletePage extends StatefulWidget {
  ReportMessageCompletePage({Key key}) : super(key: key);

  @override
  _ReportMessageCompleteState createState() => _ReportMessageCompleteState();
}

class _ReportMessageCompleteState extends State<ReportMessageCompletePage> {
  AppBloc appBloc;
  StreamSubscription backEventListener;

  @override
  void initState() {
    super.initState();
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Report Message Back Event Received");
      Navigator.maybePop(context);
    });
  }

  @override
  void dispose() {
    backEventListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      backgroundColor: Color(0xFFe2f5fb),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: double.infinity,
              height:
                  32), // Expand to fit width so items are centered correctly.
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Image.network(
              "https://res.cloudinary.com/nocdcloud/image/upload/v1571680228/static/image_envelope_256x.png",
              fit: BoxFit.cover,
              height: 60,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Text(
              "Thank you for your feedback",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary),
            ),
          ),
          Text(
            "We are looking into it.",
            style: TextStyle(fontSize: 14, color: textPrimary),
          ),
          NextButton(
            true,
            () => Navigator.maybePop(context),
            text: "Done",
          ),
        ],
      ),
    );
  }
}
