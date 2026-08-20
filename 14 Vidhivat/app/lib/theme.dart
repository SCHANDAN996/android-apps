import 'package:flutter/material.dart';

/// विधिवत का रंग-रूप।
///
/// दो बातें ध्यान में रखकर बनाया गया:
///
/// **1. अक्षर बड़े रहें।** यूज़र अक्सर ज़मीन पर बैठा होता है, हाथ में जल
/// होता है, और फ़ोन दो फ़ुट दूर रखा होता है। छोटा फ़ॉन्ट वहाँ किसी काम का
/// नहीं। इसीलिए हर जगह सामान्य से बड़ा नाप लिया है।
///
/// **2. रंग गरिमा वाले हों, भड़कीले नहीं।** हल्दी और सिंदूर की छाया —
/// पर चमकीली नहीं, दबी हुई।
class VidhivatTheme {
  // ── रंग ──
  static const haldi = Color(0xFFB8860B); // गहरा हल्दी
  static const sindoor = Color(0xFF9B2C1E); // दबा हुआ सिंदूर
  static const tulsi = Color(0xFF2E6B4F); // तुलसी हरा — शुभ के लिए
  static const ink = Color(0xFF2A1F14); // गहरी स्याही
  static const kagaz = Color(0xFFFDF8F0); // काग़ज़ जैसा

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: haldi,
        primary: haldi,
        secondary: sindoor,
        surface: kagaz,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: kagaz,
      textTheme: _textTheme(base.textTheme, ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: kagaz,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: ink.withValues(alpha: 0.08)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: 0.08),
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: haldi.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        height: 68,
      ),
    );
  }

  static ThemeData dark() {
    const raat = Color(0xFF16120D);
    const kagazRaat = Color(0xFF1F1A14);
    const inkRaat = Color(0xFFEDE4D6);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: haldi,
        primary: const Color(0xFFD9A441),
        secondary: const Color(0xFFD1705F),
        surface: kagazRaat,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: raat,
      textTheme: _textTheme(base.textTheme, inkRaat),
      appBarTheme: const AppBarTheme(
        backgroundColor: raat,
        foregroundColor: inkRaat,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: inkRaat,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: kagazRaat,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: inkRaat.withValues(alpha: 0.10)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: inkRaat.withValues(alpha: 0.10),
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kagazRaat,
        indicatorColor: haldi.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        height: 68,
      ),
    );
  }

  /// अक्षरों का नाप — हर जगह सामान्य से बड़ा।
  static TextTheme _textTheme(TextTheme base, Color colour) => base
      .copyWith(
        displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w600),
        headlineMedium:
            base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.titleMedium?.copyWith(fontSize: 18),
        bodyLarge: base.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
        bodyMedium: base.bodyMedium?.copyWith(fontSize: 16.5, height: 1.5),
        labelLarge: base.labelLarge?.copyWith(fontSize: 16),
      )
      .apply(bodyColor: colour, displayColor: colour);
}

/// शुभ-अशुभ का रंग — पूरे ऐप में एक जैसा।
Color shubhColour(BuildContext context, bool shubh) => shubh
    ? VidhivatTheme.tulsi
    : Theme.of(context).colorScheme.secondary;
