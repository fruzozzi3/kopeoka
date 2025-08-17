// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:my_kopilka/theme/color.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: kPrimaryLight,
        onPrimary: kOnPrimary,
        secondary: kPrimaryLight,
        background: kBgLight,
        surface: kCardLight,
      ),
      scaffoldBackgroundColor: kBgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: kCardLight,
        elevation: 2,
        shadowColor: kSoftShadow[0].color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: kTextPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: kTextPrimaryLight),
        bodySmall: TextStyle(color: kTextSecondaryLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelStyle: const TextStyle(color: kPrimaryLight),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryLight, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryLight,
          foregroundColor: kOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: kPrimaryDark,
        onPrimary: kTextPrimaryDark,
        secondary: kPrimaryDark,
        background: kBgDark,
        surface: kCardDark,
      ),
      scaffoldBackgroundColor: kBgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kTextPrimaryDark),
      ),
      cardTheme: CardTheme(
        color: kCardDark,
        elevation: 4,
        shadowColor: kSoftShadow[0].color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: kTextPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: kTextPrimaryDark),
        bodySmall: TextStyle(color: kTextSecondaryDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelStyle: const TextStyle(color: kPrimaryDark),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryDark, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryDark,
          foregroundColor: kTextPrimaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
