import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/utils_color.dart';

class DataCollectionThankYouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);

    return PageWrapper(
      backgroundColor: HexColor('#00FFFFFF'),
      child: GestureDetector(
        onTap: () => dataCollectionBloc.nextPage(),
        child: Stack(children: [
          // dimmed background
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.86,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 33, 33, 33),
                ),
                child: null,
              ),
            ),
          ),

          Center(
              child: Column(children: [
            Container(
              margin: EdgeInsets.only(top: 140),
              alignment: Alignment.center,
              width: 210,
              child: Image.asset(
                "assets/images/thank_you.png",
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 45, left: 45, right: 45),
              child: Text(
                "Thank you for being a part of this important effort! You're helping us make affordable OCD treatment a reality.",
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ]))
        ]),
      ),
    );
  }
}
