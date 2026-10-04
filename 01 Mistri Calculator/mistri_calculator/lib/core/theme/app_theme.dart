import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  /// Which palette the getters below hand out. Set by the app root from the
  /// theme setting and the phone's own light/dark mode, before anything
  /// builds; the brand and signal colours are the same in both.
  static bool dark = false;

  static Color _pick(int light, int darkValue) =>
      Color(dark ? darkValue : light);

  // Primary — Deep Orange (Construction / Brick feel)
  static const Color primary = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFF6D00);
  static const Color primaryDark = Color(0xFFBF360C);

  // Accent — Warm Amber
  static const Color accent = Color(0xFFFF8F00);
  static const Color accentLight = Color(0xFFFFCA28);

  // Surfaces — warm grey by day, warm charcoal by night
  static Color get background => _pick(0xFFFAF5F0, 0xFF17120E);
  static Color get surface => _pick(0xFFFFFFFF, 0xFF241C16);
  static Color get surfaceVariant => _pick(0xFFFFF3E0, 0xFF33271D);
  static Color get cardBorder => _pick(0xFFE8DDD0, 0xFF45382C);

  // Text. The hint tone is dark enough to read in sunlight (about 5:1 on
  // white) — this app is opened on building sites.
  static Color get textPrimary => _pick(0xFF2E1A0E, 0xFFF5EBE0);
  static Color get textSecondary => _pick(0xFF6E5A4A, 0xFFCDBDAB);
  static Color get textHint => _pick(0xFF7A6A5A, 0xFFA39281);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static Color get successBackground => _pick(0xFFE8F5E9, 0xFF1E3A22);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static Color get costHighlight => _pick(0xFF1565C0, 0xFF8AB8F0);
  static Color get costBackground => _pick(0xFFE3F2FD, 0xFF16283A);
  static Color get divider => _pick(0xFFEDE4DA, 0xFF3A2E24);
}

class AppTheme {
  /// The user's choice: 'system', 'light' or 'dark'.
  static final ValueNotifier<String> mode = ValueNotifier<String>('system');

  /// The theme for whichever palette [AppColors.dark] currently selects.
  static ThemeData get theme {
    final brightness = AppColors.dark ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.standard,
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: AppColors.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        // Always a dark bar with white text. (textPrimary turns pale in the
        // dark theme, which made the message unreadable.)
        backgroundColor: Color(AppColors.dark ? 0xFF4A3B2E : 0xFF2E1A0E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: AppColors.cardBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }
}
