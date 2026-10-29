import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_notifier.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // Latihan 4: Menerapkan ChangeNotifierProvider di root aplikasi
    ChangeNotifierProvider(
      create: (_) => UserNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca state tema dari UserNotifier
    final isDarkMode = context.watch<UserNotifier>().isDarkMode;

    return MaterialApp(
      title: 'State & Preferences',
      debugShowCheckedModeBanner: false,
      // Latihan 1: Tema dinamis berdasarkan state
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}