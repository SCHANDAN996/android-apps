import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_language.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Ads asynchronously in background (non-blocking for instant app launch)
  AdService.instance.init();
  
  // Pre-load onboarding status and language preferences synchronously to avoid UI flicker
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('is_onboarding_completed') ?? false;

  // भाषा: user की सेव की हुई पसंद > फोन की भाषा > हिंदी.
  // पहली बार खोलने पर ऐप अब अपने आप फोन की भाषा में खुलेगा।
  LanguageNotifier.instance.value = resolveStartupLanguage(
    savedCode: prefs.getString(LanguageNotifier.prefKey),
    deviceLocales: PlatformDispatcher.instance.locales,
  );

  runApp(KisanCalculatorApp(isOnboardingCompleted: isOnboardingCompleted));
}

class KisanCalculatorApp extends StatelessWidget {
  final bool isOnboardingCompleted;
  const KisanCalculatorApp({super.key, required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'जमीन नापी',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      home: isOnboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
