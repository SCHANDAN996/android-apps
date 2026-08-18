import 'package:flutter/material.dart';

/// Pro Kisan design system.
/// NOTE: the historic constant names (primaryTeal, secondaryTeal…) are kept so
/// existing screens keep compiling — only their VALUES were upgraded to the new
/// farmer-green brand palette.
class DairyTheme {
  // Brand — farmer green
  static const Color primaryTeal = Color(0xFF2E7D32); // primary green
  static const Color secondaryTeal = Color(0xFF1B5E20); // deep green
  static const Color creamBg = Color(0xFFF5F8F1); // soft green-cream
  static const Color cardColor = Colors.white;

  // Module accents
  static const Color accentBrown = Color(0xFF6D4C41); // pashu
  static const Color milkAccent = Color(0xFF00897B); // दूध teal
  static const Color khetiAccent = Color(0xFF43A047); // खेती green
  static const Color amber = Color(0xFFF9A825); // highlights

  // Text
  static const Color textDark = Color(0xFF1B2E1B);
  static const Color textLight = Color(0xFF6B7B6B);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      secondary: khetiAccent,
      surface: creamBg,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Mukta',
      scaffoldBackgroundColor: creamBg,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Mukta',
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        height: 66,
        indicatorColor: primaryTeal.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Mukta',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primaryTeal : textLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primaryTeal : textLight);
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 1.5,
          shadowColor: primaryTeal.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: primaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Mukta',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: 16, color: textLight),
        hintStyle: const TextStyle(fontSize: 16, color: textLight),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // ⚠️ यहाँ पहले सादा `BorderSide(grey)` था — वह *हर* हालत पर लगता था,
        // चुने हुए chip पर भी। इसलिए "कौन सा चुना है" दिखता ही नहीं था।
        // अब चुने हुए पर मोटा हरा घेरा।
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: primaryTeal, width: 2);
          }
          return BorderSide(color: Colors.grey.shade300);
        }),
        labelStyle: const TextStyle(
            fontFamily: 'Mukta', fontSize: 14, fontWeight: FontWeight.w600),
      ),

      // किसान के लिए बड़ा पढ़ने योग्य text + बड़ा touch area (48dp+)
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        titleTextStyle: TextStyle(
            fontFamily: 'Mukta',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textDark),
        subtitleTextStyle:
            TextStyle(fontFamily: 'Mukta', fontSize: 14, color: textLight),
      ),

      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
        bodyLarge: TextStyle(fontSize: 18, color: textDark, height: 1.4),
        bodyMedium: TextStyle(fontSize: 16, color: textDark, height: 1.4),
        bodySmall: TextStyle(fontSize: 14, color: textLight, height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: const Color(0xFF66BB6A),
      secondary: khetiAccent,
      surface: const Color(0xFF121B13),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Mukta',
      scaffoldBackgroundColor: const Color(0xFF0D140E),
      splashFactory: InkRipple.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B381D),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Mukta',
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1A261C),
        surfaceTintColor: const Color(0xFF1A261C),
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF141F15),
        selectedItemColor: Color(0xFF81C784),
        unselectedItemColor: Color(0xFF758576),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
