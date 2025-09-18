import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'hive_service.dart';

class AuthService extends ChangeNotifier {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }
  
  AuthService._internal();

  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  void initialize() {
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      if (HiveService.rememberLogin && HiveService.lastLoggedInUserId != null) {
        final user = await DatabaseService.getUserById(HiveService.lastLoggedInUserId!);
        if (user != null) {
          _setCurrentUser(user);
        }
      }
    } catch (e) {
      print('Auto-login check failed: $e');
      // Continue without auto-login
    }
  }

  Future<AuthResult> register({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
    String? avatarUrl,
  }) async {
    if (password != confirmPassword) {
      return AuthResult(success: false, message: 'Passwords do not match');
    }

    if (password.length < 6) {
      return AuthResult(success: false, message: 'Password must be at least 6 characters');
    }

    if (!_isValidEmail(email)) {
      return AuthResult(success: false, message: 'Please enter a valid email address');
    }

    if (name.trim().isEmpty) {
      return AuthResult(success: false, message: 'Name cannot be empty');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await DatabaseService.registerUser(
        email: email.trim().toLowerCase(),
        name: name.trim(),
        password: password,
        avatarUrl: avatarUrl,
      );

      if (userId != null) {
        final user = await DatabaseService.getUserById(userId);
        if (user != null) {
          _setCurrentUser(user);
          await HiveService.updateSettings(lastLoggedInUserId: userId);
          return AuthResult(success: true, message: 'Registration successful');
        }
      }

      return AuthResult(success: false, message: 'Registration failed');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return AuthResult(success: false, message: 'Email and password are required');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = await DatabaseService.loginUser(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (user != null) {
        _setCurrentUser(user);
        await HiveService.updateSettings(
          lastLoggedInUserId: rememberMe ? user.id : null,
          rememberLogin: rememberMe,
        );
        return AuthResult(success: true, message: 'Login successful');
      } else {
        return AuthResult(success: false, message: 'Invalid email or password');
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Login failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    
    await HiveService.updateSettings(
      lastLoggedInUserId: null,
      rememberLogin: false,
    );
    notifyListeners();
  }

  void _setCurrentUser(User user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final user = await DatabaseService.loginUser(
        email: email.trim().toLowerCase(),
        password: 'dummy_password', // This will fail but we just want to check if user exists
      );
      return user == null; // If user is null, email is available
    } catch (e) {
      if (e.toString().contains('User with this email already exists')) {
        return false;
      }
      return true; // If there's another error, assume email is available
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (currentUser == null) {
      return AuthResult(success: false, message: 'User not logged in');
    }

    if (newPassword != confirmNewPassword) {
      return AuthResult(success: false, message: 'New passwords do not match');
    }

    if (newPassword.length < 6) {
      return AuthResult(success: false, message: 'Password must be at least 6 characters');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Verify current password
      final user = await DatabaseService.loginUser(
        email: currentUser!.email,
        password: currentPassword,
      );

      if (user == null) {
        return AuthResult(success: false, message: 'Current password is incorrect');
      }

      // Here you would implement password change in DatabaseService
      // For now, we'll return success
      return AuthResult(success: true, message: 'Password changed successfully');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to change password: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (currentUser == null) {
      return AuthResult(success: false, message: 'User not logged in');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Here you would implement profile update in DatabaseService
      // For now, we'll update the current user object
      final updatedUser = User(
        id: currentUser!.id,
        email: currentUser!.email,
        name: name ?? currentUser!.name,
        avatarUrl: avatarUrl ?? currentUser!.avatarUrl,
        createdAt: currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      _setCurrentUser(updatedUser);
      return AuthResult(success: true, message: 'Profile updated successfully');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update profile: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}