import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/main.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/flushbar_helper.dart';
import 'package:nocd/utils/utils_color.dart';
import 'package:rxdart/rxdart.dart';

enum DeleteAccountPages { DELETE_ACCOUNT_1, DELETE_ACCOUNT_2, DELETE_ACCOUNT_3 }

class DeleteAccountBloc implements BlocBase {
  DeleteAccountPages _page = DeleteAccountPages.DELETE_ACCOUNT_1;
  BehaviorSubject<DeleteAccountPages> pageController =
      BehaviorSubject<DeleteAccountPages>();
  ValueObservable get getPage => pageController;

  final _deleteAccount1FeedbackTextFieldController = TextEditingController();
  bool _deleteAccount1SubmitLoading = false;
  BehaviorSubject<bool> deleteAccount1SubmitLoadingController =
      BehaviorSubject<bool>();
  ValueObservable get getDeleteAccount1SubmitLoading =>
      deleteAccount2DeleteLoadingController;

  bool _deleteAccount2DeleteLoading = false;
  BehaviorSubject<bool> deleteAccount2DeleteLoadingController =
      BehaviorSubject<bool>();
  ValueObservable get getDeleteAccount2DeleteLoading =>
      deleteAccount2DeleteLoadingController;

  StreamSubscription backEventListener;

  bool accountDeleted = false;

  AppBloc appBloc;

  void dispose() {
    backEventListener.cancel();
    pageController.close();
    deleteAccount2DeleteLoadingController.close();
    _deleteAccount1FeedbackTextFieldController.dispose();
    deleteAccount1SubmitLoadingController.close();
  }

  DeleteAccountBloc(BuildContext context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((bool) {
      exitClick(context);
    });
    print("Delete Status:  $accountDeleted");
    // TODO Navigation back handling.
  }

  void updatePage(DeleteAccountPages page) {
    _page = page;
    pageController.sink.add(_page);
  }

  /// DELETE_ACCOUNT_1 submit feedback button.
  void deleteAccount1SubmitClick(BuildContext context) async {
    print("deleteAccount1SubmitClick");
    if (_deleteAccount1FeedbackTextFieldController.text.isNotEmpty) {
      deleteAccount1SubmitLoadingController.sink.add(true);
      await networkProvider
          .postFeedback(
              _deleteAccount1FeedbackTextFieldController.text, "DELETE_ACCOUNT",
              metadata: appBloc.flutterConfig.toJson().toString())
          .then((value) {
        deleteAccount1SubmitLoadingController.sink.add(false);
        if (value.status != null) {
          updatePage(DeleteAccountPages.DELETE_ACCOUNT_2);
        } else {
          FlushbarHelperProvider.createError(message: value.error.errorMessage)
              .show(context);
        }
      });
    }
  }

  /// DELETE_ACCOUNT_1 skip submit feedback. Go to DELETE_ACCOUNT_2 on click1.
  void deleteAccount1SkipClick() {
    print("deleteAccount1SkipClick");
    updatePage(DeleteAccountPages.DELETE_ACCOUNT_2);
  }

  /// DELETE_ACCOUNT_2 confirm delete button. Go to DELETE_ACCOUNT_3 on click.
  void deleteAccount2DeleteClick(BuildContext context) async {
    print("deleteAccount2DeleteClick");
    deleteAccount2DeleteLoadingController.sink.add(true);
    await networkProvider.postDeleteAccount().then((value) {
      deleteAccount2DeleteLoadingController.sink.add(false);
      if (value.status != null) {
        accountDeleted = true;
        updatePage(DeleteAccountPages.DELETE_ACCOUNT_3);
      } else {
        FlushbarHelperProvider.createError(message: value.error.errorMessage)
            .show(context);
      }
    });
  }

  /// Exit DeleteAccountPages.
  void exitClick(BuildContext context) {
    print("exitClick");
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (accountDeleted) {
      final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
      appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
      Map<String, dynamic> data = {"event": EVENT_LOGOUT};
      appBloc.sendFlutterEvent(data);
    } else {
      final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
      appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
    }
  }
}

/// A wrapper to provide [DeleteAccountPage] with [DeleteAccountBloc].
class DeleteAccountPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeleteAccountBloc>(
        bloc: DeleteAccountBloc(context), child: DeleteAccountPage());
  }
}

class DeleteAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
    return StreamBuilder(
      stream: deleteAccountBloc.getPage,
      initialData: deleteAccountBloc._page,
      builder: (context, snapshot) {
        return _routeSwitcher(context, snapshot.data);
      },
    );
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
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
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
                onTap: () => deleteAccountBloc.exitClick(context),
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
                                        margin: EdgeInsets.only(top: 40),
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
                                                controller: deleteAccountBloc
                                                    ._deleteAccount1FeedbackTextFieldController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "What needs were you unable to meet in the NOCD app? Are there any features that didn't meet your expectations?",
                                                  contentPadding:
                                                      EdgeInsets.all(8),
                                                  border: InputBorder.none,
                                                  hintMaxLines: 5,
                                                ),
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontSize: 18,
                                                ),
                                                maxLines: null,
                                                textInputAction:
                                                    TextInputAction.done,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
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
                                                      child: LoadingFlatButton(
                                                        deleteAccountBloc
                                                            .getDeleteAccount1SubmitLoading,
                                                        deleteAccountBloc
                                                            ._deleteAccount1SubmitLoading,
                                                        () => deleteAccountBloc
                                                            .deleteAccount1SubmitClick(
                                                                context),
                                                        "Submit",
                                                        Colors.white,
                                                        Color.fromARGB(
                                                            255, 0, 163, 173),
                                                        BorderRadius.zero,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 40,
                                                    child: Container(
                                                      width: 182,
                                                      height: 42,
                                                      child: FlatButton(
                                                        onPressed: () =>
                                                            deleteAccountBloc
                                                                .deleteAccount1SkipClick(),
                                                        color:
                                                            Colors.transparent,
                                                        textColor:
                                                            Color.fromARGB(255,
                                                                0, 163, 173),
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        highlightColor:
                                                            Colors.transparent,
                                                        child: Text(
                                                          "Skip",
                                                          style: TextStyle(
                                                            fontSize: 18,
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
                                  onPressed: () =>
                                      deleteAccountBloc.exitClick(context),
                                  color: Colors.transparent,
                                  textColor: Color.fromARGB(255, 0, 0, 0),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
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

  Scaffold buildDeleteAccountPage2(BuildContext context) {
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
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
                onTap: () => deleteAccountBloc.exitClick(context),
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
                                            height: 57,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    width: 149,
                                                    height: 57,
                                                    child: FlatButton(
                                                      onPressed: () =>
                                                          deleteAccountBloc
                                                              .exitClick(
                                                                  context),
                                                      color: Colors.transparent,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15))),
                                                      textColor: Color.fromARGB(
                                                          255, 74, 144, 226),
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                          fontSize: 18,
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
                                                    width: 149,
                                                    height: 57,
                                                    child: LoadingFlatButton(
                                                      deleteAccountBloc
                                                          .getDeleteAccount2DeleteLoading,
                                                      deleteAccountBloc
                                                          ._deleteAccount2DeleteLoading,
                                                      () => deleteAccountBloc
                                                          .deleteAccount2DeleteClick(
                                                              context),
                                                      "Delete",
                                                      Color.fromARGB(
                                                          255, 251, 97, 0),
                                                      Colors.transparent,
                                                      BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(15),
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

  Scaffold buildDeleteAccountPage3(BuildContext context) {
    final DeleteAccountBloc deleteAccountBloc =
        BlocProvider.of<DeleteAccountBloc>(context);
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
                onTap: () => deleteAccountBloc.exitClick(context),
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
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    width: 300,
                                    height: 58,
                                    margin: EdgeInsets.only(top: 8),
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
                                            height: 57,
                                            child: FlatButton(
                                              onPressed: () => deleteAccountBloc
                                                  .exitClick(context),
                                              color: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                  15))),
                                              textColor: Color.fromARGB(
                                                  255, 74, 144, 226),
                                              padding: EdgeInsets.all(0),
                                              child: Text(
                                                "Exit",
                                                style: TextStyle(
                                                  fontSize: 18,
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
