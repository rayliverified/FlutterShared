import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/provider_treatment_recommendation.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class TreatmentRecommendationResultsModel with ChangeNotifier {
  String recommendationText = "";
  List<TreatmentRecommendationOption> recommendationOptions = List();

  DataCollectionBloc dataCollectionBloc;
  AppBloc appBloc;

  TreatmentRecommendationResultsModel(context) {
    appBloc = BlocProvider.of<AppBloc>(context);
    dataCollectionBloc = BlocProvider.of<DataCollectionBloc>(context);
    // Get treatment recommendations from parent bloc.
    int recommendation = dataCollectionBloc.getTreatmentRecommendation();
    recommendationText =
        TreatmentRecommendationProvider().getRecommendationText(recommendation);
    recommendationOptions = TreatmentRecommendationProvider()
        .getRecommendationOptions(
            recommendation, dataCollectionBloc.model.collegeEnrollment);
  }

  void postTreatmentRecommendationClick(String recommendation) {
    dataCollectionBloc.postTreatmentRecommendationClick(recommendation);
  }

  void openUrl(String url) {
    Map<String, dynamic> data = {
      "event": EVENT_OPEN_URL,
      "url": url,
    };
    appBloc.sendFlutterEvent(data);
  }

  void finish() {
    dataCollectionBloc.nextPage();
  }
}

/// A wrapper to provide [TreatmentRecommendationResultsPage] with [TreatmentRecommendationResultsModel].
class TreatmentRecommendationResultsWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TreatmentRecommendationResultsModel>(
      builder: (context) => TreatmentRecommendationResultsModel(context),
      child: TreatmentRecommendationResultsPage(),
    );
  }
}

class TreatmentRecommendationResultsPage extends StatelessWidget {
  /// Returns a image widget with treatment option image.
  Widget _buildTreatmentOption(TreatmentRecommendationOption option,
      TreatmentRecommendationResultsModel model) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              model.postTreatmentRecommendationClick(option.url);
              model.openUrl(option.url);
            },
            splashColor: Colors.transparent,
            child: Image.asset(option.path)));
  }

  /// Returns a list of image widgets with treatment options.
  List<Widget> _buildTreatmentOptions(
      List<TreatmentRecommendationOption> options,
      TreatmentRecommendationResultsModel model) {
    List<Widget> widgets = List();
    for (TreatmentRecommendationOption option in options) {
      widgets.add(_buildTreatmentOption(option, model));
    }

    // If widget list is empty, add an empty container to avoid crash.
    if (widgets.length == 0) {
      widgets.add(Container());
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TreatmentRecommendationResultsModel>(context);

    return PageWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BubbleTitle("Results", 3),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Text(
                "Based on your information, here are our recommendations: ",
                style: TextStyle(
                  color: Color.fromARGB(255, 33, 33, 33),
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Text(
                "Your treatment priority",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      model.recommendationText,
                      style: TextStyle(
                        color: Color.fromARGB(255, 33, 33, 33),
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              child: Text(
                "Our recommendations",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: ListView(
                shrinkWrap: true,
                controller: ScrollController(),
                children:
                    _buildTreatmentOptions(model.recommendationOptions, model),
              ),
            ),
            GestureDetector(
              onTap: () => model.finish(),
              child: Container(
                margin:
                    EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24),
                alignment: Alignment.center,
                child: Text(
                  "Go back home",
                  style: TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
