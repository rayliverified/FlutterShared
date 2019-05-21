import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android/bloc/BlocProvider.dart';
import 'package:flutter_android/main.dart';
import 'package:flutter_android/ui/ui_misc.dart';
import 'package:flutter_android/utils.dart';
import 'package:rxdart/rxdart.dart';

enum DeleteAccountPages { DELETE_ACCOUNT_1, DELETE_ACCOUNT_2, DELETE_ACCOUNT_3 }

class DeleteAccountBloc implements BlocBase {
  DeleteAccountPages _page = DeleteAccountPages.DELETE_ACCOUNT_1;

  BehaviorSubject<DeleteAccountPages> pageController =
      BehaviorSubject<DeleteAccountPages>();
  ValueObservable get getPage => pageController;

  void dispose() {
    pageController.close();
  }

  DeleteAccountBloc() {}

  void updatePage(DeleteAccountPages page) {
    _page = page;
    pageController.sink.add(_page);
  }
}

class DeleteAccountPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.updateBack(true);
    return BlocProvider<DeleteAccountBloc>(
        bloc: DeleteAccountBloc(), child: DeleteAccountPage());
  }
}

class DeleteAccountPage extends StatelessWidget {
  // DELETE_ACCOUNT_1 confirm delete button. Go to DELETE_ACCOUNT_2 on click.
  void onDeletePressed(BuildContext context) {
    print("onDeletePressed");
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
    deleteAccountBloc.updatePage(DeleteAccountPages.DELETE_ACCOUNT_2);
  }

  // DELETE_ACCOUNT_2 submit feedback button.
  void onSubmit(BuildContext context) {
    print("onSubmitPressed");
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
    deleteAccountBloc.updatePage(DeleteAccountPages.DELETE_ACCOUNT_3);
  }

  // DELETE_ACCOUNT_2 skip submit feedback. Go to DELETE_ACCOUNT_3 on click.
  void onSkip(BuildContext context) {
    print("onSkipPressed");
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
    deleteAccountBloc.updatePage(DeleteAccountPages.DELETE_ACCOUNT_3);
  }

  // Exit DeleteAccountPages.
  void onExitPressed(BuildContext context) {
    print("onExitPressed");
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
  }

  @override
  Widget build(BuildContext context) {
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
    return StreamBuilder(
        stream: deleteAccountBloc.getPage,
        initialData: deleteAccountBloc._page,
        builder: (context, snapshot) {
          return MaterialApp(home: _routeSwitcher(context, snapshot.data));
        });
  }

  Widget _routeSwitcher(
      BuildContext context, DeleteAccountPages deleteAccountPages) {
    switch (deleteAccountPages) {
      case DeleteAccountPages.DELETE_ACCOUNT_1:
        return buildDeleteAccountPage1(context);
      case DeleteAccountPages.DELETE_ACCOUNT_2:
        return buildDeleteAccountPage2(context);
      case DeleteAccountPages.DELETE_ACCOUNT_3:
        return buildDeleteAccountPage3(context);
      default:
        return Container();
    }
  }

  Scaffold buildDeleteAccountPage1(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#00FFFFFF'),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => this.onExitPressed(context),
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
            ),
            Positioned(
              top: 72,
              child: Container(
                width: 300,
                height: 256,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 300,
                        height: 215,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 300,
                              height: 180,
                              margin: EdgeInsets.only(top: 35),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      height: 180,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              "Are you sure?",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 251, 97, 0),
                                                fontSize: 24,
                                                fontFamily: "Product Sans",
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              width: 270,
                                              margin: EdgeInsets.only(top: 10),
                                              child: Text(
                                                "If you proceed, you will lose all of your data. You cannot undo this action.",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 33, 33, 33),
                                                  fontSize: 18,
                                                  fontFamily: "Product Sans",
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 16),
                                              child: Opacity(
                                                opacity: 0.37,
                                                child: Container(
                                                  width: 300,
                                                  height: 2,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 151, 151, 151),
                                                  ),
                                                  child: Container(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 56,
                                            margin: EdgeInsets.only(right: 1),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    width: 149,
                                                    height: 56,
                                                    child: FlatButton(
                                                      onPressed: () => this
                                                          .onExitPressed(
                                                              context),
                                                      color: Colors.transparent,
                                                      textColor: Color.fromARGB(
                                                          255, 74, 144, 226),
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          highlightRipple(),
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontFamily:
                                                              "Product Sans",
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    width: 150,
                                                    height: 56,
                                                    child: FlatButton(
                                                      onPressed: () => this
                                                          .onDeletePressed(
                                                              context),
                                                      color: Colors.transparent,
                                                      textColor: Color.fromARGB(
                                                          255, 251, 97, 0),
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          highlightRipple(),
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontFamily:
                                                              "Product Sans",
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
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
                                  ),
                                  Positioned(
                                    top: 124,
                                    child: Opacity(
                                      opacity: 0.37,
                                      child: Container(
                                        width: 2,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 151, 151, 151),
                                        ),
                                        child: Container(),
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
                              width: 35,
                              height: 35,
                              child: Image.asset(
                                "assets/images/warning.png",
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

  Scaffold buildDeleteAccountPage2(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#00FFFFFF'),
      body: Container(
        constraints: BoxConstraints.expand(),
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
                width: 300,
                height: 420,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 300,
                        height: 415,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 35,
                              child: GestureDetector(
                                onTap: () {
                                  print("hideKeyboard");
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                },
                                child: Container(
                                  width: 301,
                                  height: 380,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 255,
                                        height: 332,
                                        margin: EdgeInsets.only(top: 37),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 90,
                                              child: Text(
                                                "We're sorry the NOCD app missed the mark. Would you mind telling us how we could improve?",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 33, 33, 33),
                                                  fontSize: 18,
                                                  fontFamily: "Product Sans",
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              width: 253,
                                              height: 140,
                                              margin: EdgeInsets.only(top: 10),
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
                                                ),
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontSize: 18,
                                                  fontFamily: "Product Sans",
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 182,
                                              height: 82,
                                              margin: EdgeInsets.only(top: 10),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Positioned(
                                                    top: 0,
                                                    child: Container(
                                                      width: 182,
                                                      height: 42,
                                                      child: FlatButton(
                                                        onPressed: () => this
                                                            .onSubmit(context),
                                                        color: Color.fromARGB(
                                                            255, 0, 163, 173),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            3))),
                                                        textColor:
                                                            Color.fromARGB(255,
                                                                255, 255, 255),
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        highlightColor:
                                                            Color.fromARGB(255,
                                                                33, 210, 237),
                                                        child: Text(
                                                          "Submit",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontFamily:
                                                                "Product Sans",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 40,
                                                    child: Container(
                                                      width: 182,
                                                      height: 42,
                                                      child: FlatButton(
                                                        onPressed: () => this
                                                            .onSkip(context),
                                                        color:
                                                            Colors.transparent,
                                                        textColor:
                                                            Color.fromARGB(255,
                                                                0, 163, 173),
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Text(
                                                          "Skip",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontFamily:
                                                                "Product Sans",
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 35,
                                height: 35,
                                child: FlatButton(
                                  onPressed: () => this.onExitPressed(context),
                                  color: Colors.transparent,
                                  textColor: Color.fromARGB(255, 0, 0, 0),
                                  padding: EdgeInsets.all(0),
                                  child: Image.asset(
                                    "assets/images/close.png",
                                  ),
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

  Scaffold buildDeleteAccountPage3(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#00FFFFFF'),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => this.onExitPressed(context),
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
            ),
            Positioned(
              top: 72,
              child: Container(
                width: 300,
                height: 256,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 40,
                      child: Container(
                        width: 300,
                        height: 215,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 300,
                              height: 180,
                              margin: EdgeInsets.only(top: 35),
                              child: Column(
                                children: [
                                  Container(
                                    width: 270,
                                    child: Text(
                                      "Your account has been deleted",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 33, 33, 33),
                                        fontSize: 24,
                                        fontFamily: "Product Sans",
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    margin: EdgeInsets.only(top: 6),
                                    child: Text(
                                      "We’re sorry to see you go. Hope to have you back soon. ",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 33, 33, 33),
                                        fontSize: 18,
                                        fontFamily: "Product Sans",
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    width: 301,
                                    height: 56,
                                    margin: EdgeInsets.only(top: 7),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          child: Opacity(
                                            opacity: 0.37,
                                            child: Container(
                                              width: 300,
                                              height: 2,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 151, 151, 151),
                                              ),
                                              child: Container(),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 1,
                                          child: Container(
                                            width: 300,
                                            height: 55,
                                            child: FlatButton(
                                              onPressed: () =>
                                                  this.onExitPressed(context),
                                              color: Colors.transparent,
                                              textColor: Color.fromARGB(
                                                  255, 74, 144, 226),
                                              padding: EdgeInsets.all(0),
                                              splashColor: Colors.transparent,
                                              highlightColor: highlightRipple(),
                                              child: Text(
                                                "Exit",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "Product Sans",
                                                ),
                                                textAlign: TextAlign.left,
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
                              width: 39,
                              height: 37,
                              child: Image.asset(
                                "assets/images/waving-hand.png",
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
