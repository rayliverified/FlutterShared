import 'dart:convert';

/**
 * Model data collection input.
 *
 * Deserialize a JSON string to initialize variables.
 */
class DataCollectionInputModel {
  bool answeredDiagnosed = false;
  bool diagnosed;
  List<String> insurers = [];
  List<String> conditions = [];

  DataCollectionInputModel({
    answeredDiagnosed,
    diagnosed,
    insurers,
    conditions,
  })  : this.answeredDiagnosed = answeredDiagnosed ?? false,
        this.diagnosed = diagnosed,
        this.insurers = insurers ?? [],
        this.conditions = conditions ?? [];

  factory DataCollectionInputModel.fromJson(String str) =>
      DataCollectionInputModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DataCollectionInputModel.fromMap(Map<String, dynamic> json) =>
      new DataCollectionInputModel(
        answeredDiagnosed: json["answered_diagnosed"],
        diagnosed: json["diagnosed"],
        insurers: new List<String>.from(json["insurers"].map((x) => x)),
        conditions: new List<String>.from(json["conditions"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "answeredDiagnosed": answeredDiagnosed,
        "diagnosed": diagnosed,
        "insurers": new List<dynamic>.from(insurers.map((x) => x)),
        "conditions": new List<dynamic>.from(conditions.map((x) => x)),
      };
}
