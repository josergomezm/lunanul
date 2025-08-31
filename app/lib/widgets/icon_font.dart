import 'package:flutter/material.dart';

/// Custom icon font class
/// Generate this using tools like FlutterIcon.com or IcoMoon
class CustomIcons {
  CustomIcons._();

  static const String _fontFamily = 'CustomIcons';

  // Example icon codes (replace with your actual icon font codes)
  static const IconData home = IconData(0xe800, fontFamily: _fontFamily);
  static const IconData homeFilled = IconData(0xe801, fontFamily: _fontFamily);
  static const IconData readings = IconData(0xe802, fontFamily: _fontFamily);
  static const IconData readingsFilled = IconData(
    0xe803,
    fontFamily: _fontFamily,
  );
  static const IconData manual = IconData(0xe804, fontFamily: _fontFamily);
  static const IconData manualFilled = IconData(
    0xe805,
    fontFamily: _fontFamily,
  );
  static const IconData yourself = IconData(0xe806, fontFamily: _fontFamily);
  static const IconData yourselfFilled = IconData(
    0xe807,
    fontFamily: _fontFamily,
  );
  static const IconData friends = IconData(0xe808, fontFamily: _fontFamily);
  static const IconData friendsFilled = IconData(
    0xe809,
    fontFamily: _fontFamily,
  );
}
