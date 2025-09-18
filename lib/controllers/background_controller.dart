import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum BackgroundState {
  idle,
  userTyping,
  aiTyping,
  messageReceived,
  error,
}

class BackgroundController extends ChangeNotifier {
  // Current state of the background
  BackgroundState _currentState = BackgroundState.idle;
  BackgroundState get currentState => _currentState;
  
  // Current theme name
  String _currentTheme = 'Default';
  String get currentTheme => _currentTheme;

  // Available themes with their color schemes
  final Map<String, List<Color>> availableThemes = {
    'Default': [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ],
    'Ocean': [
      const Color(0xFF00c9ff),
      const Color(0xFF92fe9d),
    ],
    'Sunset': [
      const Color(0xFFff9a9e),
      const Color(0xFFfecfef),
    ],
    'Forest': [
      const Color(0xFF56ab2f),
      const Color(0xFFa8e6cf),
    ],
    'Purple': [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
    ],
    'Pink': [
      const Color(0xFFf093fb),
      const Color(0xFFf5576c),
    ],
    'Blue': [
      const Color(0xFF4facfe),
      const Color(0xFF00f2fe),
    ],
    'Green': [
      const Color(0xFF43e97b),
      const Color(0xFF38f9d7),
    ],
    'Fire': [
      const Color(0xFFfa709a),
      const Color(0xFFfee140),
    ],
    'Night': [
      const Color(0xFF0f3460),
      const Color(0xFF16537e),
    ],
    'Aurora': [
      const Color(0xFF00c6ff),
      const Color(0xFF0072ff),
    ],
    'Galaxy': [
      const Color(0xFF8360c3),
      const Color(0xFF2ebf91),
    ],
  };

  // Custom color schemes (can be modified by user)
  final Map<BackgroundState, List<Color>> _customStateColors = <BackgroundState, List<Color>>{};

  void initialize() {
    // Initialization logic if needed
  }

  // Change background state
  void changeState(BackgroundState newState) {
    _currentState = newState;
    notifyListeners();
  }

  // Apply a theme
  void applyTheme(String themeName) {
    if (availableThemes.containsKey(themeName)) {
      _currentTheme = themeName;
      notifyListeners();
    }
  }

  // Reset to default colors
  void resetColors() {
    _currentTheme = 'Default';
    _customStateColors.clear();
    notifyListeners();
  }

  // Get current colors (custom or default)
  List<Color> getCurrentColors() {
    return _customStateColors[_currentState] ?? 
           availableThemes[_currentTheme] ?? 
           availableThemes['Default']!;
  }

  // Check if state is active
  bool isState(BackgroundState state) => _currentState == state;

  // Get state-specific properties
  double getOpacity() {
    switch (_currentState) {
      case BackgroundState.idle:
        return 0.4;
      case BackgroundState.userTyping:
        return 0.7;
      case BackgroundState.aiTyping:
        return 0.6;
      case BackgroundState.messageReceived:
        return 0.5;
      case BackgroundState.error:
        return 0.8;
      default:
        return 0.3;
    }
  }

  Duration getAnimationDuration() {
    switch (_currentState) {
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
      default:
        return const Duration(seconds: 2);
    }
  }

  // Get animation intensity for more dramatic effects
  double getAnimationIntensity() {
    switch (_currentState) {
      case BackgroundState.idle:
        return 1.0;
      case BackgroundState.userTyping:
        return 1.5;
      case BackgroundState.aiTyping:
        return 1.2;
      case BackgroundState.messageReceived:
        return 2.0;
      case BackgroundState.error:
        return 3.0;
      default:
        return 1.0;
    }
  }

  // Get state-specific blur effect
  double getBlurRadius() {
    switch (_currentState) {
      case BackgroundState.idle:
        return 0.0;
      case BackgroundState.userTyping:
        return 2.0;
      case BackgroundState.aiTyping:
        return 1.5;
      case BackgroundState.messageReceived:
        return 1.0;
      case BackgroundState.error:
        return 4.0;
      default:
        return 0.0;
    }
  }

  // Set custom colors for a specific state
  void setCustomStateColors(BackgroundState state, List<Color> colors) {
    _customStateColors[state] = colors;
    notifyListeners();
  }

  // Remove custom colors for a specific state
  void removeCustomStateColors(BackgroundState state) {
    _customStateColors.remove(state);
    notifyListeners();
  }
}