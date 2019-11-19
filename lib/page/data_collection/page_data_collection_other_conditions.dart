import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/main.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionOtherConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return StreamBuilder(
        stream: dataCollectionBloc.getModel,
        initialData: dataCollectionBloc.model,
        builder: (context, snapshot) {
          return PageWrapper(
            child: ListView.builder(
              itemCount:
                  (dataCollectionBloc.dataCollectionInputModel.conditions !=
                              null
                          ? dataCollectionBloc
                              .dataCollectionInputModel.conditions.length
                          : 0) +
                      3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return DataCollectionHeaderWrapper(dataCollectionBloc);
                } else if (index == 1) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 25),
                      child: BubbleTitle(
                          "Do you have any other mental health conditions?",
                          6));
                } else if (index ==
                    (dataCollectionBloc.dataCollectionInputModel.conditions !=
                                null
                            ? dataCollectionBloc
                                .dataCollectionInputModel.conditions.length
                            : 0) +
                        2) {
                  return Container(
                      margin: EdgeInsets.only(top: 30),
                      child: NextButtonWithDisclaimer(
                          NextButton(true, () => dataCollectionBloc.nextPage()),
                          "Insurers are often interested in solutions that address multiple conditions at once. We'll present deidentified data to demonstrate the need for these solutions."));
                }

                // return condition cell
                return GestureDetector(
                  onTap: () => dataCollectionBloc.onConditionTapped(
                      dataCollectionBloc
                          .dataCollectionInputModel.conditions[index - 2]),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 315,
                      height: 69,
                      margin: EdgeInsets.only(top: 22),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(128, 218, 218, 218),
                            offset: Offset(0, 0),
                            blurRadius: 10,
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 19),
                            child: Text(
                              '${dataCollectionBloc.dataCollectionInputModel.conditions[index - 2]}',
                              style: TextStyle(
                                color: Color.fromARGB(255, 33, 34, 33),
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Spacer(),
                          Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: primary,
                              ),
                              child: Checkbox(
                                activeColor: primary,
                                value: dataCollectionBloc.model.otherConditions
                                    .contains(dataCollectionBloc
                                        .dataCollectionInputModel
                                        .conditions[index - 2]),
                                onChanged: (bool value) {
                                  dataCollectionBloc.onConditionTapped(
                                      dataCollectionBloc
                                          .dataCollectionInputModel
                                          .conditions[index - 2]);
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
