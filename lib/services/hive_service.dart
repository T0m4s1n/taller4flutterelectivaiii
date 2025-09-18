import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';

class HiveService {
  static const String _settingsBoxName = 'app_settings';
  static const String _cacheBoxName = 'app_cache';
  
  static Box<AppSettings>? _settingsBox;
  static Box? _cacheBox;

  static Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      
      // Open boxes
      _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
      _cacheBox = await Hive.openBox(_cacheBoxName);
    } catch (e) {
      print('Hive initialization error: $e');
      rethrow;
    }
  }

  // Settings operations
  static AppSettings getSettings() {
    if (_settingsBox == null) {
      return AppSettings.defaultSettings();
    }
    final box = _settingsBox!;
    return box.get('settings', defaultValue: AppSettings.defaultSettings())!;
  }

  static Future<void> saveSettings(AppSettings settings) async {
    if (_settingsBox == null) return;
    final box = _settingsBox!;
    await box.put('settings', settings);
  }

  static Future<void> updateSettings({
    bool? isDarkMode,
    String? themeName,
    double? fontSize,
    String? language,
    bool? notificationsEnabled,
    String? lastLoggedInUserId,
    bool? rememberLogin,
    String? backgroundPattern,
    double? chatBubbleRadius,
    bool? soundEnabled,
  }) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(
      isDarkMode: isDarkMode,
      themeName: themeName,
      fontSize: fontSize,
      language: language,
      notificationsEnabled: notificationsEnabled,
      lastLoggedInUserId: lastLoggedInUserId,
      rememberLogin: rememberLogin,
      backgroundPattern: backgroundPattern,
      chatBubbleRadius: chatBubbleRadius,
      soundEnabled: soundEnabled,
    );
    await saveSettings(updatedSettings);
  }

  // Cache operations
  static Future<void> cacheData(String key, dynamic value) async {
    if (_cacheBox == null) return;
    final box = _cacheBox!;
    await box.put(key, value);
  }

  static T? getCachedData<T>(String key) {
    if (_cacheBox == null) return null;
    final box = _cacheBox!;
    return box.get(key) as T?;
  }

  static Future<void> removeCachedData(String key) async {
    if (_cacheBox == null) return;
    final box = _cacheBox!;
    await box.delete(key);
  }

  static Future<void> clearCache() async {
    if (_cacheBox == null) return;
    final box = _cacheBox!;
    await box.clear();
  }

  // Theme specific helpers
  static bool get isDarkMode => getSettings().isDarkMode;
  static String get themeName => getSettings().themeName;
  static double get fontSize => getSettings().fontSize;
  static String get language => getSettings().language;
  static bool get notificationsEnabled => getSettings().notificationsEnabled;
  static String? get lastLoggedInUserId => getSettings().lastLoggedInUserId;
  static bool get rememberLogin => getSettings().rememberLogin;
  static String? get backgroundPattern => getSettings().backgroundPattern;
  static double get chatBubbleRadius => getSettings().chatBubbleRadius;
  static bool get soundEnabled => getSettings().soundEnabled;

  // Utility methods
  static Future<void> resetSettings() async {
    await saveSettings(AppSettings.defaultSettings());
  }

  static Future<void> close() async {
    await _settingsBox?.close();
    await _cacheBox?.close();
  }

  static Future<void> deleteAllData() async {
    await _settingsBox?.clear();
    await _cacheBox?.clear();
  }
}
