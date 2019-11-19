import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_data_collection.dart';
import 'package:nocd/model/model_data_collection_input.dart';
import 'package:nocd/model/provider_treatment_recommendation.dart';
import 'package:nocd/page/data_collection/route_data_collection.dart';
import 'package:nocd/ui/ui_progress_header.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/error_helper.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/route_controller.dart';
import 'package:rxdart/rxdart.dart';

class DataCollectionBloc implements BlocBase {
  static const String DATA_COLLECTION_PROMPT = "DATA_COLLECTION_PROMPT";
  static const List<String> routeDefault = [
    DataCollectionRouteController.PAGE_DATA_COLLECTION_PROMPT,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_PREVIEW,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_DIAGNOSED,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_SEVERITY,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_STATE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_BIRTH_YEAR,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_COLLEGE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_INSURANCE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_OTHER_CONDITIONS,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_CLINICIAN,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_THANK_YOU,
  ];

  static const String TREATMENT_RECOMMENDATION = "TREATMENT_RECOMMENDATION";
  static const List<String> routeTreatmentRecommendation = [
    DataCollectionRouteController.PAGE_DATA_COLLECTION_PREVIEW,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_DIAGNOSED,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_SEVERITY,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_STATE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_BIRTH_YEAR,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_COLLEGE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_INSURANCE,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_OTHER_CONDITIONS,
    DataCollectionRouteController.PAGE_DATA_COLLECTION_CLINICIAN,
    DataCollectionRouteController.PAGE_TREATMENT_RECOMMENDATION_LOADING,
    DataCollectionRouteController.PAGE_TREATMENT_RECOMMENDATION_RESULTS,
  ];

  List<String> activeRoute;
  String activeRouteName = DATA_COLLECTION_PROMPT;

  DataCollectionInputModel dataCollectionInputModel =
      DataCollectionInputModel();

  DataCollectionModel model = DataCollectionModel();
  BehaviorSubject<DataCollectionModel> modelController =
      BehaviorSubject<DataCollectionModel>();
  ValueObservable get getModel => modelController;

  String _page;
  BehaviorSubject<String> pageController = BehaviorSubject<String>();
  ValueObservable get getPage => pageController;

  TextEditingController insuranceCustomController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  StreamSubscription backEventListener;

  AppBloc appBloc;

  /// Dialog context holder so dialogs can be dismissed with the back button.
  BuildContext dialogContext;

  void dispose() {
    backEventListener.cancel();
    pageController.close();
    modelController.close();
    insuranceCustomController.dispose();
  }

  DataCollectionBloc(BuildContext context) {
    print("Data Collection Initialize");
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((bool) {
      print("Data Collection Back Event Received");
      previousPage();
    });
    // Set Active Route from data passed from client.
    activeRouteName = setActiveRoute(appBloc.data) ?? activeRouteName;
    updatePage(activeRoute[0]);
    print("Data Collection Route Data: " + appBloc.data);
    print("Data Collection Active Route: " + activeRouteName);
    print("Data Collection Route Page:  " + _page);
    // Get data from network.
    getData(context);
  }

  // BEGIN: Network Methods.
  void getData(BuildContext context) async {
    await networkProvider.getDataCollectionInput(activeRouteName).then((value) {
      if (value.status != null) {
        dataCollectionInputModel =
            DataCollectionInputModel.fromMap((value as DataResponse).data);
        // Set state based on input model.
        // Append "Others" option to insurance selector.
        dataCollectionInputModel.insurers.add("Other");
        // If user is already diagnosed, remove diagnosis screen from route.
        if (dataCollectionInputModel.answeredDiagnosed) {
          activeRoute.remove(
              DataCollectionRouteController.PAGE_DATA_COLLECTION_DIAGNOSED);
        }
        // Set model diagnosed state to diagnosed status.
        model.diagnosed = dataCollectionInputModel.diagnosed;
      } else {
        print(value.error.errorMessage);
        dataCollectionInputModel.insurers.add("Other");
      }
    });
  }

  Future<void> saveProfileData(Object payload, {String completed_flow}) async {
    if (networkProvider != null) {
      await networkProvider.postDataProfile(payload).then((value) {
        return true;
      });
    } else {
      return false;
    }
  }

  void postTreatmentRecommendationClick(String recommendation) {
    networkProvider.postTreatmentRecommendationClick(recommendation);
  }
  // END: Network Methods.

  // BEGIN: Model Methods
  void updateModelChanged() {
    modelController.sink.add(model);
  }

  void updateModel(DataCollectionModel model) {
    this.model = model;
    modelController.sink.add(model);
  }

  void updateModelData(
      {bool diagnosed,
      double severity,
      String state,
      bool collegeEnrollment,
      String collegeName,
      int birthYear,
      String insurance,
      String insuranceCustom,
      List<String> otherConditions}) {
    //update model
    model.copyWith(
        diagnosed: diagnosed,
        severity: severity,
        state: state,
        collegeEnrollment: collegeEnrollment,
        collegeName: collegeName,
        birthYear: birthYear,
        insurance: insurance,
        insuranceCustom: insuranceCustom,
        otherConditions: otherConditions);
    updateModel(model);
  }

  void updateCollegeEnrollment(bool val) {
    model.collegeEnrollment = val;
    updateModel(model);
  }

  void updateCollegeName(String val) {
    model.collegeName = val;
    updateModel(model);
  }

  void updateHasClinician(bool hasClinician) {
    model.hasClinician = hasClinician;
    updateModel(model);
  }

  void updateClinician(String clinician) {
    model.clinicianName = clinician;
    updateModel(model);
  }

  void saveInsuranceCustomValue(String value) {
    updateModelData(insuranceCustom: value);
  }

  /// Calculate treatment recommendation to display.
  int getTreatmentRecommendation() {
    return TreatmentRecommendationProvider().calculateTreatmentRecommendation(
        model.diagnosed, model.severity.toInt());
  }
  // END: Model Methods.

  // BEGIN: Button States.
  /// [DataCollectionOtherConditionsPage]
  void onConditionTapped(condition) {
    if (model.otherConditions.contains(condition)) {
      model.otherConditions.remove(condition);
    } else {
      model.otherConditions.add(condition);
    }
    updateModel(model);
  }

  /// [DataCollectionInsurancePage]
  bool insuranceNextEnabled() {
    if (model.insurance == null) {
      return false;
    }
    if (model.insurance == "Other" &&
        (model.insuranceCustom == null || model.insuranceCustom.isEmpty)) {
      return false;
    }

    return true;
  }
  // END: Button States.

  // BEGIN: Navigation.
  void updatePage(String page) {
    if (this._page != page) {
      this._page = page;
      pageController.sink.add(page);
    }
  }

  /// Navigate to the previous screen in route path.
  void previousPage() {
    // Dismiss dialog if dialog is showing.
    if (dialogContext != null) {
      Navigator.pop(dialogContext);
      dialogContext = null;
      return;
    }
    String previousPage = RouteController().getPreviousPage(activeRoute, _page);
    if (previousPage.isNotEmpty) {
      updatePage(previousPage);
    } else {
      exitClick();
    }
  }

  /// Navigate to the next screen in route path.
  void nextPage() {
    // Get name of next page.
    String nextPage = RouteController().getNextPage(activeRoute, _page);
    //Save data flags.
    bool saveData = false;
    var profileData;
    //Page specific logic.
    switch (_page) {
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_PROMPT:
        saveData = true;
        profileData = {
          "clicked_get_started": 1,
        };
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_PREVIEW:
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_DIAGNOSED:
        saveData = true;
        profileData = {"diagnosed": model.diagnosed};
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_SEVERITY:
        saveData = true;
        profileData = {"severity": model.severity};
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_STATE:
        saveData = true;
        profileData = {"state": model.state};
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_BIRTH_YEAR:
        saveData = true;
        profileData = {"yob": model.birthYear};
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_COLLEGE:
        saveData = true;
        profileData = {
          "college": model.collegeName,
          "goes_to_college": model.collegeEnrollment
        };
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_INSURANCE:
        saveData = true;
        profileData = {
          "insurance": model.insurance,
          "custom_insurance": model.insuranceCustom
        };
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_OTHER_CONDITIONS:
        saveData = true;
        profileData = {"other_conditions": model.otherConditions};
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_CLINICIAN:
        saveData = true;
        profileData = {
          "current_clinician": model.clinicianName,
          "has_clinician": model.hasClinician,
        };
        if (activeRouteName == DATA_COLLECTION_PROMPT) {
          activeRoute = [
            DataCollectionRouteController.PAGE_DATA_COLLECTION_THANK_YOU
          ];
        }
        break;
      case DataCollectionRouteController.PAGE_TREATMENT_RECOMMENDATION_LOADING:
        activeRoute = [
          DataCollectionRouteController.PAGE_TREATMENT_RECOMMENDATION_RESULTS
        ];
        break;
      case DataCollectionRouteController.PAGE_DATA_COLLECTION_THANK_YOU:
        exitClick(completed: true);
        break;
      case DataCollectionRouteController.PAGE_TREATMENT_RECOMMENDATION_RESULTS:
        exitClick(completed: true);
        break;
      default:
        break;
    }
    // Perform file save here.
    if (saveData) {
      saveProfileData(profileData);
    }
    // Navigate to the next page.
    if (nextPage.isNotEmpty) {
      updatePage(nextPage);
    }
  }

  /// Calculate progress value.
  int getProgressHeaderProgress() {
    return activeRoute.indexOf(_page) + 1 + getProgressModifier();
  }

  /// Calculate progress length.
  int getProgressHeaderLength() {
    return activeRoute.length + getLengthModifier();
  }

  /// Return a progress modifier count of excluded screens.
  int getProgressModifier() {
    switch (activeRouteName) {
      case TREATMENT_RECOMMENDATION:
        // Exclude Preview.
        int modifier = -1;
        return modifier;
      default:
        // Exclude Prompt, Preview.
        int modifier = -2;
        return modifier;
    }
  }

  /// Return a length modifier count of excluded screens.
  int getLengthModifier() {
    switch (activeRouteName) {
      case TREATMENT_RECOMMENDATION:
        // Exclude Preview, Loading, Results.
        int modifier = -3;
        return modifier;
      default:
        // Exclude Prompt, Preview, Thank You.
        int modifier = -3;
        return modifier;
    }
  }

  /// Exit [DataCollectionPages].
  void exitClick({bool completed = false}) async {
    await saveProfileData({
      "completed": completed,
      "last_screen": _page,
      "completed_flow": activeRouteName,
      "clicked_get_started": 1,
      "diagnosed": model.diagnosed,
      "severity": model.severity,
      "yob": model.birthYear,
      "college": model.collegeName,
      "goes_to_college": model.collegeEnrollment,
      "insurance": model.insurance,
      "custom_insurance": model.insuranceCustom,
      "other_conditions": model.otherConditions,
      "current_clinician": model.clinicianName,
      "has_clinician": model.hasClinician
    }).then((value) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      appBloc.navigate(AppBloc.NAVIGATION_CLOSE);
    });
  }

  /// Set [activeRoute] based on specified route path.
  /// Process [data] json string to get route path.
  String setActiveRoute(String data) {
    // Set route if data is not empty.
    if (data.isNotEmpty) {
      try {
        Map jsonMap = json.decode(data);
        if (jsonMap.containsKey("route")) {
          String route = jsonMap["route"];
          switch (route) {
            case TREATMENT_RECOMMENDATION:
              activeRoute = List.from(routeTreatmentRecommendation);
              return TREATMENT_RECOMMENDATION;
          }
        }
      } on FormatException catch (e) {
        ErrorHelper().reportException(e);
      }
    }

    activeRoute = List.from(routeDefault);
    return DATA_COLLECTION_PROMPT;
  }
// END: Navigation.
}

/// A wrapper to provide [DataCollectionPage] with [DataCollectionBloc].
class DataCollectionPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Data Collection Wrapper");
    return BlocProvider<DataCollectionBloc>(
        bloc: DataCollectionBloc(context), child: DataCollectionPage());
  }
}

class DataCollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Data Collection Page");
    final DataCollectionBloc dataCollectionBloc =
        BlocProvider.of<DataCollectionBloc>(context);
    return StreamBuilder(
        stream: dataCollectionBloc.getPage,
        initialData: dataCollectionBloc._page,
        builder: (context, snapshot) {
          print("Data Collection Stream Builder");
          print("Data Collection Data: " + snapshot.data);
          return DataCollectionRouteController()
              .routeSwitcher(context, snapshot.data);
        });
  }
}

class DataCollectionHeaderWrapper extends StatelessWidget {
  final DataCollectionBloc dataCollectionBloc;

  DataCollectionHeaderWrapper(this.dataCollectionBloc);

  @override
  Widget build(BuildContext context) {
    return ProgressHeader(
        dataCollectionBloc.getProgressHeaderProgress(),
        dataCollectionBloc.getProgressHeaderLength(),
        () => dataCollectionBloc.previousPage(),
        () => dataCollectionBloc.exitClick());
  }
}
