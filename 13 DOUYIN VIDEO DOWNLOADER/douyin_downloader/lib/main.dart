import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Douyin Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF004F),
          brightness: Brightness.dark,
          primary: const Color(0xFFFF004F),
          secondary: const Color(0xFF00F0FF),
          surface: const Color(0xFF0F1115),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
