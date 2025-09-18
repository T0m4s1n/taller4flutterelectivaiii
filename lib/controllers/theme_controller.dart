import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeController extends ChangeNotifier {
  static ThemeController? _instance;
  static ThemeController get instance {
    _instance ??= ThemeController._internal();
    return _instance!;
  }
  
  ThemeController._internal();

  bool _isDarkMode = false;
  String _themeName = 'default';

  bool get isDarkMode => _isDarkMode;
  String get themeName => _themeName;

  void initialize() {
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    try {
      _isDarkMode = HiveService.isDarkMode;
      _themeName = HiveService.themeName;
    } catch (e) {
      print('Error loading theme from storage: $e');
      _isDarkMode = false;
      _themeName = 'default';
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await HiveService.updateSettings(isDarkMode: _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await HiveService.updateSettings(isDarkMode: _isDarkMode);
    notifyListeners();
  }

  Future<void> setThemeName(String name) async {
    _themeName = name;
    await HiveService.updateSettings(themeName: _themeName);
    notifyListeners();
  }

  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeData buildTheme(bool isDark) {
    final colorScheme = isDark
        ? ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          );

    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        bodyLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        bodySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        labelMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
        labelSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: colorScheme.onSurface),
      ),
      useMaterial3: true,
    );
  }
}
