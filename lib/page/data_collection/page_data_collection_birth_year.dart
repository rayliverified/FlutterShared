import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class DataCollectionBirthYearModel with ChangeNotifier {
  DataCollectionBloc dataCollectionBloc;

  /// Min year for [CupertinoPicker].
  static const startYear = 1940;

  /// List of year options.
  List yearList;

  /// Selected year.
  int _year;
  int get year => _year;

  /// User selected year flag.
  bool _yearSelected = false;

  DataCollectionBirthYearModel(context) {
    dataCollectionBloc = BlocProvider.of<DataCollectionBloc>(context);
    // Generate year list dynamically.
    yearList = generateYearList(startYear);
    // Restore year or set to default.
    if (dataCollectionBloc.model.birthYear != null) {
      _year = dataCollectionBloc.model.birthYear;
      _yearSelected = true;
    } else {
      // Set default year option to 18 years ago.
      _year = DateTime.now().year - 18;
    }
  }

  /// Create a list of years from [startYear] to current year in ascending order.
  List generateYearList(int startYear) {
    int currentYear = DateTime.now().year;
    // Calculate offset. If currentYear is equal to startYear, return list with currentYear.
    int offset = currentYear - startYear;
    // Return empty list if offset is negative.
    if (offset < 0) {
      return List();
    }
    // Generate list.
    List list = List();
    for (int i = currentYear - offset; i <= currentYear; i++) {
      list.add(i);
    }

    return list;
  }

  void updateYear(int yearIndex) {
    _yearSelected = true;
    _year = yearList[yearIndex];
    notifyListeners();
  }

  bool nextEnabled() {
    return _yearSelected;
  }

  void finish() {
    dataCollectionBloc.updateModelData(birthYear: _year);
    dataCollectionBloc.nextPage();
  }
}

/// A wrapper to provide [DataCollectionBirthYearPage] with [DataCollectionBirthYearModel].
class DataCollectionBirthYearWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataCollectionBirthYearModel>(
      builder: (context) => DataCollectionBirthYearModel(context),
      child: DataCollectionBirthYearPage(),
    );
  }
}

class DataCollectionBirthYearPage extends StatelessWidget {
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
            BubbleTitle("Which year were you born?", 2),
            Container(
              height: 140,
              margin: EdgeInsets.only(left: 16, right: 16, top: 16),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<DataCollectionBirthYearModel>(
                  builder: (context, model, child) {
                return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification:
                        (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowGlow();
                      return true;
                    },
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: model.yearList.indexOf(model.year)),
                      itemExtent: 40,
                      backgroundColor: Colors.transparent,
                      onSelectedItemChanged: (int index) {
                        model.updateYear(index);
                      },
                      children: List<Widget>.generate(model.yearList.length,
                          (int index) {
                        return Center(
                            child: Text(
                          model.yearList[index].toString(),
                          style: TextStyle(fontSize: 28),
                        ));
                      }),
                    ));
              }),
            ),
            Consumer<DataCollectionBirthYearModel>(
                builder: (context, model, child) {
              return NextButtonWithDisclaimer(
                  new NextButton(model.nextEnabled(), () => model.finish()),
                  "This will help us identify OCD trends by age group");
            }),
          ],
        ),
      ),
    );
  }
}
