// core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'theme_extensions.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    extensions: <ThemeExtension<dynamic>>[
      const MyColors(brand: Colors.blue, accent: Colors.orange),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    extensions: <ThemeExtension<dynamic>>[
      const MyColors(brand: Colors.blueGrey, accent: Colors.redAccent),
    ],
  );
}
