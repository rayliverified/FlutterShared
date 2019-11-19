import 'dart:convert';

/**
 * A model of initialization variables from the host app.
 *
 * Deserialize a JSON string to initialize variables.
 */
class FlutterConfig {
  String flavor = "";
  String accessToken = "";
  String guid = "";

  FlutterConfig();

  FlutterConfig.fromJson(String json) {
    try {
      Map<String, dynamic> map = jsonDecode(json);
      flavor = map["flavor"];
      accessToken = map["accessToken"];
      guid = map["guid"];
    } catch (e) {
      print("Error: Flutter Config JSON decode exception " + e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flavor'] = flavor;
    data['accessToken'] = accessToken;
    return data;
  }
}
