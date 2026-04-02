import 'package:flutter/material.dart';
import 'package:get_shit_done/src/theme/theme_providers.dart';

class AppTheme {
  static Color _seedForPalette(AppPalette palette) {
    switch (palette) {
      case AppPalette.ember:
        return const Color(0xFFDC5F00);
      case AppPalette.forest:
        return const Color(0xFF1C7C54);
      case AppPalette.ocean:
        return const Color(0xFF0D9488);
    }
  }

  static ThemeData lightTheme(AppPalette palette) {
    final seed = _seedForPalette(palette);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
    );
  }

  static ThemeData darkTheme(AppPalette palette) {
    final seed = _seedForPalette(palette);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
    );
  }
}
