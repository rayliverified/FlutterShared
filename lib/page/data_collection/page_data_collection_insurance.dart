import 'package:flutter/material.dart';
import 'package:nocd/model/model_data_collection.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_bubble_title.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_misc.dart';
import 'package:nocd/ui/ui_next_button.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionInsurancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return StreamBuilder(
        stream: dataCollectionBloc.getModel,
        initialData: dataCollectionBloc.model,
        builder: (context, snapshot) {
          DataCollectionModel data = snapshot.data as DataCollectionModel;
          return PageWrapper(
            child: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {FocusScope.of(context).unfocus()},
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DataCollectionHeaderWrapper(dataCollectionBloc),
                      BubbleTitle("What’s your insurance provider?", 3),
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                // Register dialog context.
                                dataCollectionBloc.dialogContext = context;
                                final String insurance =
                                    await asyncSimpleDialogSelector(
                                        context,
                                        "Choose provider",
                                        dataCollectionBloc
                                            .dataCollectionInputModel.insurers);
                                if (insurance != null) {
                                  dataCollectionBloc.model.insurance =
                                      insurance;
                                  dataCollectionBloc.updateModelChanged();
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
                                        data.insurance ?? "Choose provider",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 31, 75, 117),
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
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Visibility(
                            child: Form(
                              key: dataCollectionBloc.formKey,
                              child: TextFormField(
                                controller: dataCollectionBloc
                                    .insuranceCustomController,
                                validator: (value) {
                                  if (value !=
                                      dataCollectionBloc
                                          .model.insuranceCustom) {
                                    print("Validate: $value");
                                    dataCollectionBloc
                                        .saveInsuranceCustomValue(value);
                                  }
                                  if (value.isEmpty) {
                                    return 'Input text please';
                                  }
                                  return null;
                                },
                                autovalidate: true,
                                onSaved: (value) => {print("Saved")},
                                onEditingComplete: () =>
                                    {FocusScope.of(context).unfocus()},
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                    labelText: 'Insurance provider'),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            visible: ((data.insurance ?? false) == "Other")
                                ? true
                                : false,
                          )),
                      Container(
                        height: 60,
                      ),
                      NextButtonWithDisclaimer(
                          NextButton(dataCollectionBloc.insuranceNextEnabled(),
                              () => dataCollectionBloc.nextPage()),
                          "By providing this information, you'll help us gather deidentified data and demonstrate the need for better coverage of OCD treatment to insurers."),
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
