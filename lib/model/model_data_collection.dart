class DataCollectionModel {
  bool diagnosed;
  double severity;
  String state;

  /// College enrollment status. Default null no selection.
  bool collegeEnrollment;
  String collegeName;

  int birthYear;

  bool hasClinician;
  String clinicianName;

  String insurance;
  String insuranceCustom;
  List<String> otherConditions = [];

  DataCollectionModel();

  copyWith(
      {bool diagnosed,
      double severity,
      String state,
      bool collegeEnrollment,
      String collegeName,
      int birthYear,
      String insurance,
      String insuranceCustom,
      List<String> otherConditions}) {
    this.diagnosed = diagnosed ?? this.diagnosed;
    this.severity = severity ?? this.severity;
    this.state = state ?? this.state;
    this.collegeEnrollment = collegeEnrollment ?? this.collegeEnrollment;
    this.collegeName = collegeName ?? this.collegeName;
    this.birthYear = birthYear ?? this.birthYear;
    this.insurance = insurance ?? this.insurance;
    this.insuranceCustom = insuranceCustom ?? this.insuranceCustom;
    this.otherConditions = otherConditions ?? this.otherConditions;
  }
}
