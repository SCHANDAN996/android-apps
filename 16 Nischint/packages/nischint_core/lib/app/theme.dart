import 'package:flutter/material.dart';

/// निश्चिंत के रंग और दूरी। स्क्रीनें इन्हीं का इस्तेमाल करें, नए रंग न बनाएँ।
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F766E); // टील: भरोसा
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color sun = Color(0xFFF59E0B); // एम्बर: सोलर, ऑफ़र
  static const Color sunSoft = Color(0xFFFEF3C7);
  static const Color background = Color(0xFFF7F7F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color text = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
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
  static const double radius = 16;

  /// बटन के कोने।
  static const double buttonRadius = 14;

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
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.standard,
  );
  return base.copyWith(
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
      TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3);
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
