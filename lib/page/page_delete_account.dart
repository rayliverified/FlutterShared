import 'package:flutter/material.dart';

class DeleteAccount1 extends StatelessWidget {
  void onSubmit(BuildContext context) {}

  void onSkip(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: buildPage(context));
  }

  Scaffold buildPage(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: Container(),
                ),
              ),
            ),
            Positioned(
              top: 72,
              child: Container(
                width: 301,
                height: 483,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 4,
                      right: 0,
                      child: Container(
                        width: 301,
                        height: 478,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 35,
                              child: Container(
                                width: 301,
                                height: 443,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 255,
                                      height: 392,
                                      margin: EdgeInsets.only(top: 37),
                                      child: Column(
                                        children: [
                                          Text(
                                            "We're sorry the NOCD app missed the mark. Would you mind telling us how we could improve?",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 33, 33, 33),
                                              fontSize: 18,
                                              fontFamily: "Product Sans",
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Container(
                                            width: 253,
                                            height: 193,
                                            margin: EdgeInsets.only(top: 11),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 151, 151, 151),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(9)),
                                            ),
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText:
                                                    "What needs were you unable to meet in the NOCD app? Are there any features that didn't meet your expectations?",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: InputBorder.none,
                                                hintMaxLines: null,
                                              ),
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontSize: 18,
                                                fontFamily: "Product Sans",
                                              ),
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                            ),
                                          ),
                                          Container(
                                            width: 180,
                                            height: 40,
                                            margin: EdgeInsets.only(top: 18),
                                            child: FlatButton(
                                              onPressed: () =>
                                                  this.onSubmit(context),
                                              color: Color.fromARGB(
                                                  255, 0, 163, 173),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3))),
                                              textColor: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              padding: EdgeInsets.all(0),
                                              highlightColor: Color.fromARGB(
                                                  255, 33, 210, 237),
                                              child: Text(
                                                "Submit",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "Product Sans",
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 180,
                                            height: 40,
                                            child: FlatButton(
                                              onPressed: () =>
                                                  this.onSkip(context),
                                              color: Colors.transparent,
                                              textColor: Color.fromARGB(
                                                  255, 0, 163, 173),
                                              padding: EdgeInsets.all(0),
                                              child: Text(
                                                "Skip",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: ".SF NS Text",
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 35,
                                height: 35,
                                child: Image.asset(
                                  "assets/images/group-4.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 37,
                              child: Image.asset(
                                "assets/images/conversation.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
