import 'package:flutter/material.dart';

class FontSizes {
  static const extraSmall = 14.0;
  static const small = 16.0;
  static const standard = 18.0;
  static const large = 20.0;
  static const extraLarge = 24.0;
  static const doubleExtraLarge = 26.0;
}

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xff3369FF),
    secondary: Color(0xffEEEEEE),
    surface: Color(0xffffffff),
  ),
  textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xff000000),
      ),
      titleSmall: TextStyle(
        color: Color(0xff000000),
      ),
      bodyMedium:
          TextStyle(color: Color(0xffEEEEEE), fontSize: FontSizes.small),
      bodySmall:
          TextStyle(color: Color(0xff000000), fontSize: FontSizes.small)),
  useMaterial3: true,
);
final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xff3369FF),
    secondary: Color(0xffEEEEEE),
    surface: Color(0xff000000),
  ),
  textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xffEEEEEE),
      ),
      titleSmall: TextStyle(
        color: Color(0xffEEEEEE),
      ),
      bodyMedium:
          TextStyle(color: Color(0xffEEEEEE), fontSize: FontSizes.small),
      bodySmall:
          TextStyle(color: Color(0xff000000), fontSize: FontSizes.small)),
  useMaterial3: true,
);
