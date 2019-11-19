import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';

class TreatmentRecommendationLoadingPage extends StatelessWidget {
  void _startTimer(DataCollectionBloc dataCollectionBloc) {
    Timer(Duration(seconds: 1), () {
      dataCollectionBloc.nextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);
    _startTimer(dataCollectionBloc);

    return PageWrapper(
      child: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 100,
                  height: 100,
                  child: Image.asset("assets/images/magnifying_glass.png")),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Text(
                  "We're searching for options that might fit your needs...",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 24,
              )
            ],
          ),
        ),
      ),
    );
  }
}
