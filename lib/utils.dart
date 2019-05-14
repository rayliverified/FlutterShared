import 'dart:ui';

class HexColor extends Color {

  /// Returns a [Color()] object from a hexadecimal color.
  ///
  /// Accepts [HexColor(hexColor)] as a hexadecimal color code, with
  /// or without alpha values (i.e. #FFFFFF or #00FFFFFF).
  ///
  /// https://stackoverflow.com/a/53905427/6211703
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}