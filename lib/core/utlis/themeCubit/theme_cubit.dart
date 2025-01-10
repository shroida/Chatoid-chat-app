import 'package:chatoid/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _colorOfApp = ChatAppColors.primaryColor;

  ThemeMode get themeMode => _themeMode;
  Color get colorOfApp => _colorOfApp;

  ThemeCubit() : super(lightMode) {
    loadThemeMode();
    loadColorOfApp();
  }
  bool get isDark => _themeMode == ThemeMode.dark;
  Color get textColor => isDark ? Colors.white : Colors.black;
  void toggleLightMode() async {
    _themeMode = ThemeMode.light;
    emit(_buildThemeData());
    await _saveThemeMode(lightMode);
  }

  void toggleDarkMode() async {
    _themeMode = ThemeMode.dark;
    emit(_buildThemeData()); 
    await _saveThemeMode(darkMode);
  }

  Future<void> _saveThemeMode(ThemeData theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', theme == lightMode ? 'light' : 'dark');
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String? modeString = prefs.getString('theme_mode');
    if (modeString != null && modeString == 'dark') {
      emit(darkMode);
    } else {
      emit(lightMode);
    }
  }

  void toggleBackground(int index) {
    switch (index) {
      case 1:
        _colorOfApp = ChatAppColors.primaryColor;
        break;
      case 2:
        _colorOfApp = ChatAppColors.primaryColor2;
        break;
      case 3:
        _colorOfApp = ChatAppColors.primaryColor3;
        break;
      case 4:
        _colorOfApp = ChatAppColors.primaryColor4;
        break;
      case 5:
        _colorOfApp = ChatAppColors.primaryColor5;
        break;
      case 6:
        _colorOfApp = ChatAppColors.primaryColor6;
        break;
      case 7:
        _colorOfApp = ChatAppColors.primaryColor7;
        break;
      case 8:
        _colorOfApp = ChatAppColors.primaryColor8;
        break;
      default:
        _colorOfApp = ChatAppColors.primaryColor;
        break;
    }
    emit(_buildThemeData()); 
  }

  ThemeData _buildThemeData() {
    if (_themeMode == ThemeMode.dark) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: _colorOfApp,
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: _colorOfApp,
      );
    }
  }

  int increseCounter(int index) {
    return index < 6 ? index += 1 : index = 1;
  }

  Future<void> saveColorOfApp(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'color_of_app', color.value);
  }

  Future<void> loadColorOfApp() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('color_of_app');
    if (colorValue != null) {
      _colorOfApp = Color(colorValue); 
    }
  }
}
