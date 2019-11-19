import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionPromptPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return Builder(
      builder: (context) => MediaQuery(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => dataCollectionBloc.exitClick(),
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
                left: 24,
                top: 32,
                right: 24,
                bottom: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(), // child: Container(),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowGlow();
                          return true;
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 16),
                                width: double.infinity,
                                child: Image.asset(
                                  "assets/images/family.png",
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                child: Text(
                                  "Help us make OCD treatment affordable",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 33, 33, 33),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                padding: EdgeInsets.only(bottom: 45),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 33, 33, 33),
                                      fontSize: 16,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              "Our mission is to make OCD treatment accessible to everyone. We're currently gathering information to show colleges and insurance companies how important this is. \n\nWill you help us demonstrate the need for better options by answering a few questions? "),
                                      TextSpan(
                                          text:
                                              "\n\nWe will protect your personal information closely so no one will be able to connect your responses and any other information that identifies you.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () => dataCollectionBloc.nextPage(),
                            color: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3))),
                            textColor: Color.fromARGB(255, 255, 255, 255),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text(
                              "I’d love to help",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: EdgeInsets.all(8),
                        child: FlatButton(
                          onPressed: () => dataCollectionBloc.exitClick(),
                          color: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          textColor: Color.fromARGB(255, 0, 0, 0),
                          padding: EdgeInsets.all(8),
                          child: Image.asset(
                            "assets/images/close_blue_dark.png",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
