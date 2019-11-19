import 'package:flutter/material.dart';
import 'package:nocd/page/data_collection/page_data_collection_birth_year.dart';
import 'package:nocd/page/data_collection/page_data_collection_clinician.dart';
import 'package:nocd/page/data_collection/page_data_collection_college.dart';
import 'package:nocd/page/data_collection/page_data_collection_diagnosed.dart';
import 'package:nocd/page/data_collection/page_data_collection_insurance.dart';
import 'package:nocd/page/data_collection/page_data_collection_other_conditions.dart';
import 'package:nocd/page/data_collection/page_data_collection_preview.dart';
import 'package:nocd/page/data_collection/page_data_collection_prompt.dart';
import 'package:nocd/page/data_collection/page_data_collection_severity.dart';
import 'package:nocd/page/data_collection/page_data_collection_state.dart';
import 'package:nocd/page/data_collection/page_data_collection_thank_you.dart';
import 'package:nocd/page/data_collection/page_treatment_recommendation_loading.dart';
import 'package:nocd/page/data_collection/page_treatment_recommendation_results.dart';

class DataCollectionRouteController {
  static const String PAGE_DATA_COLLECTION_PROMPT =
      "PAGE_DATA_COLLECTION_PROMPT";
  static const String PAGE_DATA_COLLECTION_PREVIEW =
      "PAGE_DATA_COLLECTION_PREVIEW";
  static const String PAGE_DATA_COLLECTION_DIAGNOSED =
      "PAGE_DATA_COLLECTION_DIAGNOSED";
  static const String PAGE_DATA_COLLECTION_SEVERITY =
      "PAGE_DATA_COLLECTION_SEVERITY";
  static const String PAGE_DATA_COLLECTION_STATE = "PAGE_DATA_COLLECTION_STATE";
  static const String PAGE_DATA_COLLECTION_COLLEGE =
      "PAGE_DATA_COLLECTION_COLLEGE";
  static const String PAGE_DATA_COLLECTION_INSURANCE =
      "PAGE_DATA_COLLECTION_INSURANCE";
  static const String PAGE_DATA_COLLECTION_BIRTH_YEAR =
      "PAGE_DATA_COLLECTION_BIRTH_YEAR";
  static const String PAGE_DATA_COLLECTION_OTHER_CONDITIONS =
      "PAGE_DATA_COLLECTION_OTHER_CONDITIONS";
  static const String PAGE_DATA_COLLECTION_CLINICIAN =
      "PAGE_DATA_COLLECTION_CLINICIAN";
  static const String PAGE_DATA_COLLECTION_THANK_YOU =
      "PAGE_DATA_COLLECTION_THANK_YOU";
  // Treatment flow pages.
  static const String PAGE_TREATMENT_RECOMMENDATION_LOADING =
      "PAGE_TREATMENT_RECOMMENDATION_LOADING";
  static const String PAGE_TREATMENT_RECOMMENDATION_RESULTS =
      "PAGE_TREATMENT_RECOMMENDATION_RESULTS";

  Widget routeSwitcher(BuildContext context, String dataCollectionPages) {
    switch (dataCollectionPages) {
      case PAGE_DATA_COLLECTION_PROMPT:
        return DataCollectionPromptPage();
      case PAGE_DATA_COLLECTION_PREVIEW:
        return DataCollectionPreviewPage();
      case PAGE_DATA_COLLECTION_DIAGNOSED:
        return DataCollectionDiagnosedPage();
      case PAGE_DATA_COLLECTION_SEVERITY:
        return DataCollectionSeverityWrapper();
      case PAGE_DATA_COLLECTION_STATE:
        return DataCollectionStateWrapper();
      case PAGE_DATA_COLLECTION_BIRTH_YEAR:
        return DataCollectionBirthYearWrapper();
      case PAGE_DATA_COLLECTION_INSURANCE:
        return DataCollectionInsurancePage();
      case PAGE_DATA_COLLECTION_COLLEGE:
        return DataCollectionCollegePage();
      case PAGE_DATA_COLLECTION_OTHER_CONDITIONS:
        return DataCollectionOtherConditionsPage();
      case PAGE_DATA_COLLECTION_CLINICIAN:
        return DataCollectionClinicianPage();
      case PAGE_DATA_COLLECTION_THANK_YOU:
        return DataCollectionThankYouPage();
      case PAGE_TREATMENT_RECOMMENDATION_LOADING:
        return TreatmentRecommendationLoadingPage();
      case PAGE_TREATMENT_RECOMMENDATION_RESULTS:
        return TreatmentRecommendationResultsWrapper();
      default:
        return Container();
    }
  }
}
