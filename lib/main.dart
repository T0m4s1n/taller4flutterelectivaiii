import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'controllers/theme_controller.dart';
import 'controllers/chat_controller.dart';
import 'pages/chat_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    await HiveService.init();
    
    // Initialize services
    AuthService.instance.initialize();
    ThemeController.instance.initialize();
    
    runApp(const MyApp());
  } catch (e) {
    print('Initialization error: $e');
    // Fallback: run app without services
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: AuthService.instance,
        ),
        ChangeNotifierProvider<ThemeController>.value(
          value: ThemeController.instance,
        ),
        ChangeNotifierProvider<ChatController>(
          create: (context) {
            final controller = ChatController();
            controller.initialize();
            return controller;
          },
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'AI Chat App',
            theme: themeController.buildTheme(false),
            darkTheme: themeController.buildTheme(true),
            themeMode: themeController.themeMode,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          return const ChatPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}