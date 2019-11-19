import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_misc.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:provider/provider.dart';

class DataCollectionStateModel with ChangeNotifier {
  DataCollectionBloc dataCollectionBloc;

  String _state;
  String get state => _state;

  DataCollectionStateModel(context) {
    dataCollectionBloc = BlocProvider.of<DataCollectionBloc>(context);
    // Restore state or set to default.
    if (dataCollectionBloc.model.state != null) {
      _state = dataCollectionBloc.model.state;
    }
  }

  void updateState(String value) {
    _state = value;
    notifyListeners();
  }

  bool nextEnabled() {
    return _state != null;
  }

  void finish() {
    dataCollectionBloc.updateModelData(state: _state);
    dataCollectionBloc.nextPage();
  }
}

/// A wrapper to provide [DataCollectionStatePage] with [DataCollectionStateModel].
class DataCollectionStateWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataCollectionStateModel>(
      builder: (context) => DataCollectionStateModel(context),
      child: DataCollectionStatePage(),
    );
  }
}

class DataCollectionStatePage extends StatelessWidget {
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
            BubbleTitle("What state do you live in?", 2),
            Container(
                margin: EdgeInsets.only(left: 24, right: 24, top: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(128, 218, 218, 218),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Consumer<DataCollectionStateModel>(
                      builder: (context, model, child) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Register dialog context.
                          dataCollectionBloc.dialogContext = context;
                          final String state = await asyncSimpleDialogSelector(
                              context, "Select state", stateList);
                          if (state != null) {
                            model.updateState(state);
                          }
                          // Dialog dismissed. Clear dialog context.
                          dataCollectionBloc.dialogContext = null;
                        },
                        borderRadius: BorderRadius.circular(6),
                        splashColor: materialSplashRipple(),
                        highlightColor: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 16),
                                child: Text(
                                  model.state ?? "Select state",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 31, 75, 117),
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Container(
                              width: 27,
                              margin: EdgeInsets.only(
                                  top: 18, right: 16, bottom: 18),
                              child: Image.asset(
                                "assets/images/triangle_down.png",
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )),
            Container(
              height: 24,
            ),
            Consumer<DataCollectionStateModel>(
                builder: (context, model, child) {
              return NextButtonWithDisclaimer(
                  NextButton(model.nextEnabled(), () => model.finish()),
                  "Coverage varies by state which is why we collect this information to understand where to focus.");
            }),
          ],
        ),
      ),
    );
  }
}
