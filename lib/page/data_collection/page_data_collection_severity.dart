import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_gradient_slider.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class DataCollectionSeverityModel with ChangeNotifier {
  DataCollectionBloc dataCollectionBloc;

  /// Selected year.
  double _severity;
  double get severity => _severity;

  /// User selected year flag.
  bool _severitySelected = false;

  DataCollectionSeverityModel(context) {
    dataCollectionBloc = BlocProvider.of<DataCollectionBloc>(context);
    // Restore year or set to default.
    if (dataCollectionBloc.model.severity != null) {
      _severity = dataCollectionBloc.model.severity;
      _severitySelected = true;
    } else {
      // Set default severity to 0 because Slider requires a nonnull value.
      _severity = 0;
    }
  }

  void updateSeverity(double value) {
    _severitySelected = true;
    _severity = value;
    notifyListeners();
  }

  bool nextEnabled() {
    return _severitySelected;
  }

  void finish() {
    dataCollectionBloc.updateModelData(severity: _severity);
    dataCollectionBloc.nextPage();
  }
}

/// A wrapper to provide [DataCollectionSeverityPage] with [DataCollectionSeverityModel].
class DataCollectionSeverityWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataCollectionSeverityModel>(
      builder: (context) => DataCollectionSeverityModel(context),
      child: DataCollectionSeverityPage(),
    );
  }
}

class DataCollectionSeverityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return PageWrapper(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataCollectionHeaderWrapper(dataCollectionBloc),
            BubbleTitle("How severe are your OCD symptoms?", 1),
            Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 72),
                child: Consumer<DataCollectionSeverityModel>(
                    builder: (context, model, child) {
                  return GradientSlider(
                      model.severity,
                      0,
                      10,
                      null,
                      model.severity.round().toString() + "/10",
                      (value) => model.updateSeverity(value));
                })),
            Align(
              alignment: Alignment.topCenter,
              child: Consumer<DataCollectionSeverityModel>(
                  builder: (context, model, child) {
                return NextButton(model.nextEnabled(), () => model.finish());
              }),
            ),
          ],
        ),
      ),
    );
  }
}
