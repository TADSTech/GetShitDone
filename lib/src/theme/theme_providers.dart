import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPalette { ocean, ember, forest }

class ThemeSettings {
  const ThemeSettings({
    required this.mode,
    required this.palette,
    required this.reducedMotion,
  });

  final ThemeMode mode;
  final AppPalette palette;
  final bool reducedMotion;

  ThemeSettings copyWith({
    ThemeMode? mode,
    AppPalette? palette,
    bool? reducedMotion,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

const _modeKey = 'theme_mode_v1';
const _paletteKey = 'theme_palette_v1';
const _reducedMotionKey = 'reduced_motion_v1';

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsController, ThemeSettings>(
  ThemeSettingsController.new,
);

class ThemeSettingsController extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    _loadFromPrefs();
    return const ThemeSettings(
      mode: ThemeMode.system,
      palette: AppPalette.ocean,
      reducedMotion: false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
  }

  Future<void> setPalette(AppPalette palette) async {
    state = state.copyWith(palette: palette);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paletteKey, palette.name);
  }

  Future<void> setReducedMotion(bool reducedMotion) async {
    state = state.copyWith(reducedMotion: reducedMotion);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, reducedMotion);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final modeIndex = prefs.getInt(_modeKey);
    final mode = (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length)
        ? ThemeMode.values[modeIndex]
        : ThemeMode.system;

    final paletteName = prefs.getString(_paletteKey);
    final palette = AppPalette.values.firstWhere(
      (value) => value.name == paletteName,
      orElse: () => AppPalette.ocean,
    );

    final reducedMotion = prefs.getBool(_reducedMotionKey) ?? false;

    state = ThemeSettings(
      mode: mode,
      palette: palette,
      reducedMotion: reducedMotion,
    );
  }
}
