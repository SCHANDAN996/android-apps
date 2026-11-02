import 'package:flutter/material.dart';

/// काजो के रंग और दूरी। स्क्रीनें इन्हीं का इस्तेमाल करें, नए रंग न बनाएँ।
class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF211839);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onBrandMuted = Color(0xFFE4DDF7);
  static const Color primary = Color(0xFF5B35D5); // काजो वायलेट
  static const Color primaryDark = Color(0xFF352064);
  static const Color primarySoft = Color(0xFFF0EBFF);
  static const Color sun = Color(0xFFFFB547); // गर्म एम्बर: हाइलाइट
  static const Color sunSoft = Color(0xFFFFF2DD);
  static const Color background = Color(0xFFF7F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7F0);
  static const Color text = Color(0xFF202136);
  static const Color textMuted = Color(0xFF666B80);
  static const Color success = Color(0xFF15803D);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFFEDD5);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEE2E2);
}

class AppSpace {
  AppSpace._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// कार्ड के कोने।
  static const double radius = 20;

  /// बटन के कोने।
  static const double buttonRadius = 16;

  /// बटन की ऊँचाई।
  static const double buttonHeight = 52;
}

/// ऐप की थीम। सिर्फ़ रंग-योजना और बुनियादी चीज़ें, ताकि हर Flutter वर्ज़न पर चले।
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.sun,
    surface: AppColors.card,
    error: AppColors.danger,
  );
  // Material 3 Flutter 3.16 से डिफ़ॉल्ट है, इसलिए useMaterial3 फ़्लैग नहीं लिखा (वर्ज़न बदलने पर टूट न जाए)।
  final base = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.standard,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}

/// आम टेक्स्ट स्टाइल।
class AppText {
  AppText._();

  static const TextStyle h1 =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3);
  static const TextStyle h2 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3);
  static const TextStyle h3 =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.35);
  static const TextStyle body = TextStyle(fontSize: 16, color: AppColors.text, height: 1.45);
  static const TextStyle muted = TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4);
  static const TextStyle small = TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.35);
  static const TextStyle price =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary);
}
