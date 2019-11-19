import 'package:flutter/material.dart';
import 'package:nocd/colors.dart';

/**
 * A flavor holder to help provide values based on app flavor.
 *
 * Instantiate in [AppBloc].
 * https://medium.com/flutter-community/flutter-ready-to-go-e59873f9d7de
 */
class FlavorConfig {
  static const String DEV = "DEV";
  static const String QA = "QA";
  static const String PROD = "PROD";
  static const String ERROR = "ERROR";

  final String flavor;
  final FlavorValues values;

  FlavorConfig({this.flavor, this.values});
  bool isDevelopment() => flavor == DEV;
  bool isQA() => flavor == QA;
  bool isProduction() => flavor == PROD;

  Color flavorColor() {
    switch (flavor) {
      case DEV:
        return colorDev;
      case QA:
        return colorQA;
      case PROD:
        return colorProd;
      default:
        return colorError;
    }
  }
}

final FlavorValues flavorValuesDev = FlavorValues(
    endpoint: "https://nocd-dev.ngrok.io/",
    pubnubSubscribeKey: "sub-c-e96ffeec-2726-11e9-934b-52f171d577c7",
    pubnubPublishKey: "pub-c-451d7b93-2fa0-4ffe-9622-cd31b7234eb5");
final FlavorValues flavorValuesQA = FlavorValues(
    endpoint: "https://api-qa.treatmyocd.com/",
    pubnubSubscribeKey: "sub-c-de87e874-2725-11e9-9508-c2e2c4d7488a",
    pubnubPublishKey: "pub-c-f8a5f859-894f-4543-9314-a5a18228c3bc");
final FlavorValues flavorValuesProd = FlavorValues(
    endpoint: "https://api.treatmyocd.com/",
    pubnubSubscribeKey: "sub-c-d8164526-2725-11e9-9ee5-ae9cce607226",
    pubnubPublishKey: "pub-c-64861669-36bb-4359-9724-7b427377016d");
final FlavorValues flavorValuesError = FlavorValues(endpoint: "");

class FlavorValues {
  FlavorValues({this.endpoint, this.pubnubSubscribeKey, this.pubnubPublishKey});
  final String endpoint;
  final String pubnubSubscribeKey;
  final String pubnubPublishKey;
}
