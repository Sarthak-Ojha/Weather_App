import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Entry point of the Flutter Weather App
void main() {
  runApp(const WeatherApp());
}

/// Root widget of the application
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App configuration
      title: 'Weather App',
      debugShowCheckedModeBanner: false, // Remove debug banner
      
      // Theme configuration for modern Material Design
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3 design
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      
      // Dark theme support
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      
      // Set home screen
      home: const HomeScreen(),
    );
  }
}