class TreatmentRecommendationProvider {
  TreatmentRecommendationProvider();

  /// Calculate treatment recommendation to display.
  int calculateTreatmentRecommendation(bool diagnosed, int severity) {
    // Option 1: Undiagnosed.
    if (!diagnosed) {
      return 1;
    }
    // Option 2: Diagnosed and low severity score.
    if (severity <= 4) {
      return 2;
    }
    // Option 3: Diagnosed and moderate to high severity.
    if (severity > 4) {
      return 3;
    }

    return -1;
  }

  /// Return list of recommendation image paths.
  List<TreatmentRecommendationOption> getRecommendationOptions(
      int recommendation, bool enrolled) {
    List<TreatmentRecommendationOption> recommendations = List();
    switch (recommendation) {
      case 1:
      case 2:
      case 3:
        recommendations = [
          TreatmentRecommendationOption("assets/images/solution_1.png",
              "https://lp.treatmyocd.com/get-started-therapy"),
          TreatmentRecommendationOption("assets/images/solution_2.png",
              "https://www.psychologytoday.com/us/therapists/"),
          TreatmentRecommendationOption(
              "assets/images/solution_3.png", "http://www.rileyswish.com"),
          TreatmentRecommendationOption("assets/images/solution_4.png",
              "https://www.amazon.com/OCD-Workbook-Breaking-Obsessive-Compulsive-Disorder/dp/1572249218/"),
        ];
        break;
      default:
        break;
    }

    // If undiagnosed, remove option 3.
    if (!enrolled) {
      recommendations.remove(TreatmentRecommendationOption(
          "assets/images/solution_3.png", "http://www.rileyswish.com"));
      recommendations.remove(TreatmentRecommendationOption(
          "assets/images/solution_4.png",
          "https://www.amazon.com/OCD-Workbook-Breaking-Obsessive-Compulsive-Disorder/dp/1572249218/"));
      recommendations.add(TreatmentRecommendationOption(
          "assets/images/solution_3_2.png",
          "https://www.amazon.com/OCD-Workbook-Breaking-Obsessive-Compulsive-Disorder/dp/1572249218/"));
    }

    return recommendations;
  }

  /// Return recommendation text.
  String getRecommendationText(int recommendation) {
    switch (recommendation) {
      case 1:
        return "Get diagnosed by a licensed professional and receive personalized treatment solutions";
      case 2:
        return "Manage OCD symptoms and maintain treatment progress by working with an OCD specialist";
      case 3:
        return "Reduce the severity of the OCD symtoms and work on a more effective and personalized  treatment plan with an OCD specialist.";
      default:
        return "";
    }
  }
}

class TreatmentRecommendationOption {
  final String path;
  final String url;

  TreatmentRecommendationOption(this.path, this.url);

  @override
  bool operator ==(other) {
    return this.path == (other as TreatmentRecommendationOption).path &&
        this.url == (other as TreatmentRecommendationOption).url;
  }
}
