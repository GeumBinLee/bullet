import 'package:flutter/material.dart';

class AppSettingsProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final String? fontFamily;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(String?) onFontFamilyChanged;

  const AppSettingsProvider({
    super.key,
    required this.themeMode,
    required this.fontFamily,
    required this.onThemeChanged,
    required this.onFontFamilyChanged,
    required super.child,
  });

  static AppSettingsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettingsProvider>();
  }

  @override
  bool updateShouldNotify(AppSettingsProvider oldWidget) {
    return themeMode != oldWidget.themeMode ||
        fontFamily != oldWidget.fontFamily;
  }
}

