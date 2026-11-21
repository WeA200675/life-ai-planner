import 'package:flutter/material.dart';

/// Shared visual language for the offline-first Android app.
/// Keep contrast and accessibility ahead of decorative effects.
abstract final class PlannerTheme {
  static const background = Color(0xFF171B22);
  static const surface = Color(0xFF252B34);
  static const ruby = Color(0xFFE53935);
  static const coral = Color(0xFFFF6257);
  static const bordeaux = Color(0xFF9F253D);
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
        secondary: turquoise,
        surface: surface,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
