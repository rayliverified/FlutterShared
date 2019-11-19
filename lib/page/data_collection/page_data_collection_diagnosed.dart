import 'package:flutter/material.dart';
import 'package:nocd/model/model_data_collection.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/ui/ui_yes_no_button.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionDiagnosedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return StreamBuilder(
        stream: dataCollectionBloc.getModel,
        initialData: dataCollectionBloc.model,
        builder: (context, snapshot) {
          DataCollectionModel model = (snapshot.data as DataCollectionModel);

          bool enableNextButton = false;
          if (model.diagnosed != null) {
            enableNextButton = true;
          }

          return PageWrapper(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DataCollectionHeaderWrapper(dataCollectionBloc),
                  BubbleTitle("Have you been diagnosed with OCD?", 1),
                  Container(
                    height: 90,
                    margin: EdgeInsets.only(left: 25, right: 25, top: 45),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: SelectableButton(
                                "Yes", (model.diagnosed ?? false), () {
                          dataCollectionBloc.updateModelData(diagnosed: true);
                        })),
                        Container(width: 25),
                        Expanded(
                            child: SelectableButton(
                                "No", !(model.diagnosed ?? true), () {
                          dataCollectionBloc.updateModelData(diagnosed: false);
                        })),
                      ],
                    ),
                  ),
                  Spacer(flex: 1),
                  NextButton(
                      enableNextButton, () => dataCollectionBloc.nextPage()),
                  Spacer(flex: 3)
                ],
              ),
            ),
          );
        });
  }
}
