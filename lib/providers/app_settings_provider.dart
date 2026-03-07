import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends Cubit<int> {
  AppSettingsProvider(this._prefs)
    : _isDarkMode = _prefs.getBool(_darkModeKey) ?? false,
      super(0);
  static const String _darkModeKey = 'settings.dark_mode';
  final SharedPreferences _prefs;
  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    _notify();
    await _prefs.setBool(_darkModeKey, value);
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}
