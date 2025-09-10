import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          bodySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          labelMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
          labelSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300),
        ),
        useMaterial3: true,
      ),
      home: const ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

