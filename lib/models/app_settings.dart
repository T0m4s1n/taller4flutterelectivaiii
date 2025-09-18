import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String themeName;

  @HiveField(2)
  double fontSize;

  @HiveField(3)
  String language;

  @HiveField(4)
  bool notificationsEnabled;

  @HiveField(5)
  String? lastLoggedInUserId;

  @HiveField(6)
  bool rememberLogin;

  @HiveField(7)
  String? backgroundPattern;

  @HiveField(8)
  double chatBubbleRadius;

  @HiveField(9)
  bool soundEnabled;

  AppSettings({
    this.isDarkMode = false,
    this.themeName = 'default',
    this.fontSize = 14.0,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.lastLoggedInUserId,
    this.rememberLogin = false,
    this.backgroundPattern,
    this.chatBubbleRadius = 12.0,
    this.soundEnabled = true,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings();
  }

  AppSettings copyWith({
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
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeName: themeName ?? this.themeName,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastLoggedInUserId: lastLoggedInUserId ?? this.lastLoggedInUserId,
      rememberLogin: rememberLogin ?? this.rememberLogin,
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      chatBubbleRadius: chatBubbleRadius ?? this.chatBubbleRadius,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
