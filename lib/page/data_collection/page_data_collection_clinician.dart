import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_data_collection.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/ui/ui_yes_no_button.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionClinicianPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return StreamBuilder(
        stream: dataCollectionBloc.getModel,
        initialData: dataCollectionBloc.model,
        builder: (context, snapshot) {
          DataCollectionModel model = (snapshot.data as DataCollectionModel);

          return PageWrapper(
            child: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {FocusScope.of(context).unfocus()},
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DataCollectionHeaderWrapper(dataCollectionBloc),
                      BubbleTitle(
                          "Are you currently working with a clinician?", 1),
                      Container(
                        height: 90,
                        margin: EdgeInsets.only(left: 25, right: 25, top: 45),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: SelectableButton(
                                    "Yes", (model.hasClinician ?? false), () {
                              dataCollectionBloc.updateHasClinician(true);
                            })),
                            Container(width: 25),
                            Expanded(
                                child: SelectableButton(
                                    "No", !(model.hasClinician ?? true), () {
                              dataCollectionBloc.updateHasClinician(false);
                            })),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 30, right: 30, top: 45),
                          child: Visibility(
                            child: TextField(
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              onChanged: (text) =>
                                  {dataCollectionBloc.updateClinician(text)},
                              decoration: InputDecoration(
                                  labelText: 'Clinician Name (optional)'),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            visible: model.hasClinician ?? false,
                          )),
                      NextButton(model.hasClinician != null,
                          () => dataCollectionBloc.nextPage()),
                      Container(
                        height: 56,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
