import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FoodRecognizerApp());
}

class FoodRecognizerApp extends StatelessWidget {
  const FoodRecognizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0F9D58),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          primary: const Color(0xFF0F9D58),
          background: const Color(0xFFF8F9FA),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
