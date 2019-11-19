import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';

class DataCollectionPreviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return PageWrapper(
      child: GestureDetector(
        onTap: () {
          dataCollectionBloc.nextPage();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 5, left: 20, right: 20),
                child: Image.asset(
                  "assets/images/family.png",
                ),
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Spacer(flex: 2),
              Container(
                margin: EdgeInsets.only(left: 25, right: 25),
                child: Text(
                  "Thanks for helping us demonstrate the importance \nof affordable OCD treatment!\n\nWe just have a few quick \nquestions for you, it only takes a few minutes.\n \n",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              Container(
                width: 210,
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () => dataCollectionBloc.nextPage(),
                    color: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 5),
            ]),
          ],
        ),
      ),
    );
  }
}
