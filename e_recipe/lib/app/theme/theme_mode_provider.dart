import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'setting_theme_mode';

  Box<String> get _settings => Hive.box<String>(HiveTableConstant.sessionBox);

  @override
  ThemeMode build() {
    return switch (_settings.get(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _settings.put(_key, mode.name);
  }
}
