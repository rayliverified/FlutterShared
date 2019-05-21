import 'package:flutter/material.dart';

class TextFieldMultilinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: buildTextFieldMultiline(context));
  }

  Scaffold buildTextFieldMultiline(BuildContext context) {
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
                                      margin: EdgeInsets.only(top: 35),
                                      child: Column(
                                        children: [
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
                                        ],
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
            ),
          ],
        ),
      ),
    );
  }
}
