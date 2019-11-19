import 'dart:ui';

/**
 * Returns a [Color] object from a hexadecimal color.
 *
 * Accepts a hexadecimal color code, with or without alpha values (i.e. #FFFFFF or #00FFFFFF).
 * https://stackoverflow.com/a/53905427/6211703
 */
class HexColor extends Color {
  /// Accepts [hexColor] as a hexadecimal color code, with or without alpha values (i.e. #FFFFFF or #00FFFFFF).
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  /// Calculates [Color] by parsing [hexColor].
  /// Sets alpha to 1.0 for hex values passed without an alpha.
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
