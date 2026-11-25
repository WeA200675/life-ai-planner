import 'package:flutter/material.dart';

/// Shared visual language for the offline-first Android app.
/// Keep contrast and accessibility ahead of decorative effects.
abstract final class PlannerTheme {
  static const background = Color(0xFF0D0C0E);
  static const surface = Color(0xFF1B171A);
  static const ruby = Color(0xFFE53935);
  static const coral = Color(0xFFFF6257);
  static const bordeaux = Color(0xFF92252C);
  static const turquoise = Color(0xFF18B8C5);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: ruby,
      brightness: Brightness.dark,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: scheme.copyWith(
        primary: coral,
        onPrimary: background,
        secondary: const Color(0xFFFF9A85),
        onSurface: const Color(0xFFF7EEEE),
        outline: const Color(0xFF796367),
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Color(0xFFF7EEEE),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFF7EEEE), fontSize: 22,
          fontWeight: FontWeight.w700, letterSpacing: -.4,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D292D), thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF594045)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: coral, width: 2),
        ),
      ),
    );
  }
}
