import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//     brightness: Brightness.light,
//     colorScheme: ColorScheme.light(
//         surface: Colors.deepPurple.shade400,
//         primary: Colors.deepPurple.shade300,
//         secondary: Colors.deepPurple.shade200,
//         tertiary: Colors.deepPurple.shade100));

// ThemeData darkMode = ThemeData(
//     brightness: Brightness.dark,
//     colorScheme: ColorScheme.dark(
//         surface: Colors.deepPurple.shade900,
//         primary: Colors.deepPurple.shade800,
//         secondary: Colors.deepPurple.shade700,
//         tertiary: Colors.deepPurple.shade600));

class AppColors {
  // Base colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color red = Colors.red;
  static const Color orange = Colors.orange;
  static const Color green = Colors.green;

  // Theme-specific colors
  static const MaterialColor primary = Colors.deepPurple;
  static const secondary = Color.fromARGB(255, 0, 0, 0);
}

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary.shade300,
  colorScheme: ColorScheme.light(
      surface: Colors.white,
      primary: AppColors.primary.shade300,
      secondary: AppColors.primary.shade200,
      tertiary: AppColors.primary.shade100,
      onPrimary: AppColors.white,
      onSurface: Colors.grey.shade700,
      primaryContainer: AppColors.white,
      secondaryContainer: AppColors.lightGrey),
  textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 14, 14, 14)),
      bodyMedium: TextStyle(color: AppColors.black),
      bodySmall: TextStyle(color: AppColors.lightGrey),
      titleMedium: TextStyle(color: AppColors.black),
      displayMedium: TextStyle(color: AppColors.black)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.green,
      foregroundColor: AppColors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary.shade800,
  colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade800,
      primary: AppColors.primary.shade800,
      secondary: AppColors.primary.shade700,
      tertiary: AppColors.primary.shade600,
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
      primaryContainer: Colors.grey.shade800,
      secondaryContainer: Colors.grey.shade500),
  textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.lightGrey),
      bodySmall: TextStyle(color: AppColors.white),
      titleMedium: TextStyle(color: AppColors.white),
      displayMedium: TextStyle(color: AppColors.white)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orange,
      foregroundColor: AppColors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);
