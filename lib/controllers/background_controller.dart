import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BackgroundState {
  idle,
  userTyping,
  aiTyping,
  messageReceived,
  error,
}

class BackgroundController extends GetxController {
  // Observable background state
  final Rx<BackgroundState> currentState = BackgroundState.idle.obs;
  
  // Animation controllers for smooth transitions
  AnimationController? animationController;
  Animation<double>? animation;
  
  // Default color schemes for different states
  final Map<BackgroundState, List<Color>> _defaultStateColors = {
    BackgroundState.idle: [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf093fb),
    ],
    BackgroundState.userTyping: [
      const Color(0xFF4facfe),
      const Color(0xFF00f2fe),
      const Color(0xFF43e97b),
    ],
    BackgroundState.aiTyping: [
      const Color(0xFFa8edea),
      const Color(0xFFfed6e3),
      const Color(0xFFffecd2),
    ],
    BackgroundState.messageReceived: [
      const Color(0xFFffecd2),
      const Color(0xFFfcb69f),
      const Color(0xFFff9a9e),
    ],
    BackgroundState.error: [
      const Color(0xFFff9a9e),
      const Color(0xFFfecfef),
      const Color(0xFFff6b6b),
    ],
  };

  // Custom color schemes (can be modified by user)
  final RxMap<BackgroundState, List<Color>> _customStateColors = <BackgroundState, List<Color>>{}.obs;

  // Pattern types for different states
  final Map<BackgroundState, String> _statePatterns = {
    BackgroundState.idle: 'static',
    BackgroundState.userTyping: 'pulse',
    BackgroundState.aiTyping: 'wave',
    BackgroundState.messageReceived: 'ripple',
    BackgroundState.error: 'shake',
  };

  @override
  void onInit() {
    super.onInit();
    // Animation controller will be initialized in the widget
  }

  @override
  void onClose() {
    animationController?.dispose();
    super.onClose();
  }

  // Change background state
  void changeState(BackgroundState newState) {
    currentState.value = newState;
  }

  // Get current colors (custom or default)
  List<Color> get currentColors => 
      _customStateColors[currentState.value] ?? _defaultStateColors[currentState.value]!;

  // Get current pattern
  String get currentPattern => _statePatterns[currentState.value]!;

  // Get animation value
  double get animationValue => animation?.value ?? 0.0;

  // Check if state is active
  bool isState(BackgroundState state) => currentState.value == state;

  // Get state-specific properties
  double getOpacity() {
    switch (currentState.value) {
      case BackgroundState.idle:
        return 0.4;
      case BackgroundState.userTyping:
        return 0.7;
      case BackgroundState.aiTyping:
        return 0.8;
      case BackgroundState.messageReceived:
        return 0.9;
      case BackgroundState.error:
        return 0.8;
    }
  }

  Duration getAnimationDuration() {
    switch (currentState.value) {
      case BackgroundState.idle:
        return const Duration(seconds: 3);
      case BackgroundState.userTyping:
        return const Duration(milliseconds: 600);
      case BackgroundState.aiTyping:
        return const Duration(milliseconds: 800);
      case BackgroundState.messageReceived:
        return const Duration(milliseconds: 400);
      case BackgroundState.error:
        return const Duration(milliseconds: 150);
    }
  }

  // Get animation intensity for more dramatic effects
  double getAnimationIntensity() {
    switch (currentState.value) {
      case BackgroundState.idle:
        return 1.0;
      case BackgroundState.userTyping:
        return 1.5;
      case BackgroundState.aiTyping:
        return 2.0;
      case BackgroundState.messageReceived:
        return 2.5;
      case BackgroundState.error:
        return 3.0;
    }
  }

  // Get state-specific blur effect
  double getBlurRadius() {
    switch (currentState.value) {
      case BackgroundState.idle:
        return 0.0;
      case BackgroundState.userTyping:
        return 2.0;
      case BackgroundState.aiTyping:
        return 4.0;
      case BackgroundState.messageReceived:
        return 1.0;
      case BackgroundState.error:
        return 6.0;
    }
  }

  // Change colors for a specific state
  void changeStateColors(BackgroundState state, List<Color> colors) {
    _customStateColors[state] = colors;
  }

  // Change colors for all states
  void changeAllColors(List<Color> colors) {
    for (BackgroundState state in BackgroundState.values) {
      _customStateColors[state] = colors;
    }
  }

  // Reset colors to default
  void resetColors() {
    _customStateColors.clear();
  }

  // Get available color themes with unique patterns
  Map<String, List<Color>> get availableThemes => {
    'Default': [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFFf093fb)],
    'Ocean': [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFFf093fb)],
    'Sunset': [const Color(0xFFff9a9e), const Color(0xFFfecfef), const Color(0xFFff6b6b)],
    'Forest': [const Color(0xFF56ab2f), const Color(0xFFa8e6cf), const Color(0xFF43e97b)],
    'Purple': [const Color(0xFF9c27b0), const Color(0xFF673ab7), const Color(0xFFe1bee7)],
    'Pink': [const Color(0xFFe91e63), const Color(0xFFf8bbd9), const Color(0xFFfce4ec)],
    'Blue': [const Color(0xFF2196f3), const Color(0xFF03a9f4), const Color(0xFF81d4fa)],
    'Green': [const Color(0xFF4caf50), const Color(0xFF8bc34a), const Color(0xFFc8e6c9)],
    'Fire': [const Color(0xFFff5722), const Color(0xFFff9800), const Color(0xFFffcc02)],
    'Night': [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f3460)],
    'Aurora': [const Color(0xFF00c9ff), const Color(0xFF92fe9d), const Color(0xFF00f5ff)],
    'Galaxy': [const Color(0xFF2c3e50), const Color(0xFF34495e), const Color(0xFF7f8c8d)],
  };

  // Get theme-specific pattern types
  Map<String, String> get themePatterns => {
    'Default': 'static',
    'Ocean': 'waves',
    'Sunset': 'ripples',
    'Forest': 'leaves',
    'Purple': 'stars',
    'Pink': 'hearts',
    'Blue': 'bubbles',
    'Green': 'nature',
    'Fire': 'flames',
    'Night': 'constellation',
    'Aurora': 'northern_lights',
    'Galaxy': 'cosmic',
  };

  // Get current theme pattern
  String get currentThemePattern {
    final currentColors = this.currentColors;
    for (final entry in availableThemes.entries) {
      if (entry.value == currentColors) {
        return themePatterns[entry.key] ?? 'static';
      }
    }
    return 'static';
  }

  // Apply a theme to all states
  void applyTheme(String themeName) {
    final themeColors = availableThemes[themeName];
    if (themeColors != null) {
      changeAllColors(themeColors);
    }
  }
}
