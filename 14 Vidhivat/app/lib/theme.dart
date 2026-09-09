import 'package:flutter/material.dart';

/// Semantic colours for every future visual primitive.
@immutable
class VidhivatColorTokens extends ThemeExtension<VidhivatColorTokens> {
  final Color background;
  final Color backgroundElevated;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSubtle;
  final Color primary;
  final Color primaryPressed;
  final Color primaryMuted;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color divider;
  final Color borderSubtle;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const VidhivatColorTokens({
    required this.background,
    required this.backgroundElevated,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSubtle,
    required this.primary,
    required this.primaryPressed,
    required this.primaryMuted,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.divider,
    required this.borderSubtle,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const dark = VidhivatColorTokens(
    background: Color(0xFF0D1118),
    backgroundElevated: Color(0xFF131A24),
    surface: Color(0xFF1A222D),
    surfaceElevated: Color(0xFF242D38),
    surfaceSubtle: Color(0xFF302A31),
    primary: Color(0xFFC9775B),
    primaryPressed: Color(0xFFA65042),
    primaryMuted: Color(0xFF4D3031),
    secondary: Color(0xFF806073),
    textPrimary: Color(0xFFFFF7E9),
    textSecondary: Color(0xFFD7CABC),
    textTertiary: Color(0xFF9D9087),
    textOnPrimary: Color(0xFF261A09),
    divider: Color(0xFF39414B),
    borderSubtle: Color(0xFF514B4A),
    success: Color(0xFF82B58B),
    warning: Color(0xFFE0A455),
    error: Color(0xFFD07268),
    info: Color(0xFF86B5C8),
  );

  static const light = VidhivatColorTokens(
    background: Color(0xFFF9F3E9),
    backgroundElevated: Color(0xFFFFFBF5),
    surface: Color(0xFFFFFCF7),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF0E8DB),
    primary: Color(0xFF9C5140),
    primaryPressed: Color(0xFF7B3C33),
    primaryMuted: Color(0xFFE7C8C0),
    secondary: Color(0xFF765067),
    textPrimary: Color(0xFF2D241B),
    textSecondary: Color(0xFF65594C),
    textTertiary: Color(0xFF897C6D),
    textOnPrimary: Color(0xFFFFF8EB),
    divider: Color(0xFFE1D7C9),
    borderSubtle: Color(0xFFD4C8B9),
    success: Color(0xFF47774E),
    warning: Color(0xFFA96524),
    error: Color(0xFF9B4038),
    info: Color(0xFF3F7085),
  );

  @override
  VidhivatColorTokens copyWith({
    Color? background,
    Color? backgroundElevated,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSubtle,
    Color? primary,
    Color? primaryPressed,
    Color? primaryMuted,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnPrimary,
    Color? divider,
    Color? borderSubtle,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) =>
      VidhivatColorTokens(
        background: background ?? this.background,
        backgroundElevated: backgroundElevated ?? this.backgroundElevated,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
        primary: primary ?? this.primary,
        primaryPressed: primaryPressed ?? this.primaryPressed,
        primaryMuted: primaryMuted ?? this.primaryMuted,
        secondary: secondary ?? this.secondary,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textOnPrimary: textOnPrimary ?? this.textOnPrimary,
        divider: divider ?? this.divider,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        info: info ?? this.info,
      );

  @override
  VidhivatColorTokens lerp(covariant VidhivatColorTokens? other, double t) {
    if (other is! VidhivatColorTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return VidhivatColorTokens(
      background: mix(background, other.background),
      backgroundElevated: mix(backgroundElevated, other.backgroundElevated),
      surface: mix(surface, other.surface),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      surfaceSubtle: mix(surfaceSubtle, other.surfaceSubtle),
      primary: mix(primary, other.primary),
      primaryPressed: mix(primaryPressed, other.primaryPressed),
      primaryMuted: mix(primaryMuted, other.primaryMuted),
      secondary: mix(secondary, other.secondary),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      textOnPrimary: mix(textOnPrimary, other.textOnPrimary),
      divider: mix(divider, other.divider),
      borderSubtle: mix(borderSubtle, other.borderSubtle),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      error: mix(error, other.error),
      info: mix(info, other.info),
    );
  }
}

/// Semantic typography for Hindi, Sanskrit, English and mixed content.
@immutable
class VidhivatTypography extends ThemeExtension<VidhivatTypography> {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle mantra;
  final TextStyle mantraTransliteration;
  final TextStyle mantraMeaning;
  final TextStyle numericHighlight;

  const VidhivatTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.label,
    required this.caption,
    required this.mantra,
    required this.mantraTransliteration,
    required this.mantraMeaning,
    required this.numericHighlight,
  });

  static const _fallbacks = <String>[
    'Noto Sans Devanagari',
    'Noto Serif Devanagari',
    'Roboto',
  ];

  factory VidhivatTypography.from(VidhivatColorTokens colors) {
    TextStyle style({
      required double size,
      required FontWeight weight,
      Color? color,
      double height = 1.45,
      FontStyle? fontStyle,
    }) =>
        TextStyle(
          fontFamilyFallback: _fallbacks,
          fontSize: size,
          fontWeight: weight,
          color: color ?? colors.textPrimary,
          height: height,
          fontStyle: fontStyle,
        );

    return VidhivatTypography(
      displayLarge: style(size: 36, weight: FontWeight.w700, height: 1.2),
      displayMedium: style(size: 30, weight: FontWeight.w700, height: 1.25),
      pageTitle: style(size: 24, weight: FontWeight.w700, height: 1.3),
      sectionTitle: style(
        size: 19,
        weight: FontWeight.w700,
        color: colors.primary,
        height: 1.35,
      ),
      cardTitle: style(size: 18, weight: FontWeight.w600, height: 1.35),
      bodyLarge: style(size: 18, weight: FontWeight.w400, height: 1.58),
      bodyMedium: style(size: 16, weight: FontWeight.w400, height: 1.55),
      bodySmall: style(
        size: 14,
        weight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.45,
      ),
      label: style(size: 15, weight: FontWeight.w600, height: 1.25),
      caption: style(
        size: 12,
        weight: FontWeight.w500,
        color: colors.textTertiary,
        height: 1.35,
      ),
      mantra: style(size: 26, weight: FontWeight.w500, height: 1.85),
      mantraTransliteration: style(
        size: 16,
        weight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.6,
        fontStyle: FontStyle.italic,
      ),
      mantraMeaning: style(size: 16, weight: FontWeight.w400, height: 1.65),
      numericHighlight: style(
        size: 24,
        weight: FontWeight.w700,
        color: colors.primary,
        height: 1.2,
      ),
    );
  }

  @override
  VidhivatTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? mantra,
    TextStyle? mantraTransliteration,
    TextStyle? mantraMeaning,
    TextStyle? numericHighlight,
  }) =>
      VidhivatTypography(
        displayLarge: displayLarge ?? this.displayLarge,
        displayMedium: displayMedium ?? this.displayMedium,
        pageTitle: pageTitle ?? this.pageTitle,
        sectionTitle: sectionTitle ?? this.sectionTitle,
        cardTitle: cardTitle ?? this.cardTitle,
        bodyLarge: bodyLarge ?? this.bodyLarge,
        bodyMedium: bodyMedium ?? this.bodyMedium,
        bodySmall: bodySmall ?? this.bodySmall,
        label: label ?? this.label,
        caption: caption ?? this.caption,
        mantra: mantra ?? this.mantra,
        mantraTransliteration:
            mantraTransliteration ?? this.mantraTransliteration,
        mantraMeaning: mantraMeaning ?? this.mantraMeaning,
        numericHighlight: numericHighlight ?? this.numericHighlight,
      );

  @override
  VidhivatTypography lerp(covariant VidhivatTypography? other, double t) {
    if (other is! VidhivatTypography) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return VidhivatTypography(
      displayLarge: mix(displayLarge, other.displayLarge),
      displayMedium: mix(displayMedium, other.displayMedium),
      pageTitle: mix(pageTitle, other.pageTitle),
      sectionTitle: mix(sectionTitle, other.sectionTitle),
      cardTitle: mix(cardTitle, other.cardTitle),
      bodyLarge: mix(bodyLarge, other.bodyLarge),
      bodyMedium: mix(bodyMedium, other.bodyMedium),
      bodySmall: mix(bodySmall, other.bodySmall),
      label: mix(label, other.label),
      caption: mix(caption, other.caption),
      mantra: mix(mantra, other.mantra),
      mantraTransliteration:
          mix(mantraTransliteration, other.mantraTransliteration),
      mantraMeaning: mix(mantraMeaning, other.mantraMeaning),
      numericHighlight: mix(numericHighlight, other.numericHighlight),
    );
  }
}

abstract final class VidhivatSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;
}

abstract final class VidhivatRadius {
  static const double smallValue = 8;
  static const double mediumValue = 12;
  static const double largeValue = 16;
  static const double extraLargeValue = 24;
  static const double pillValue = 999;

  static const small = BorderRadius.all(Radius.circular(smallValue));
  static const medium = BorderRadius.all(Radius.circular(mediumValue));
  static const large = BorderRadius.all(Radius.circular(largeValue));
  static const extraLarge = BorderRadius.all(Radius.circular(extraLargeValue));
  static const pill = BorderRadius.all(Radius.circular(pillValue));
}

abstract final class VidhivatElevation {
  static const double none = 0;
  static const double subtle = 1;
  static const double raised = 3;

  static const subtleShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

abstract final class VidhivatIconSize {
  static const double small = 18;
  static const double medium = 24;
  static const double large = 32;
  static const double hero = 48;
}

/// Minimum action dimensions keep tap targets consistent and accessible.
/// पन्ने की चौड़ाई — चौड़ी स्क्रीन पर भी पढ़ने लायक़ (→ D-062)।
abstract final class VidhivatLayout {
  /// पन्ने की सबसे ज़्यादा चौड़ाई।
  ///
  /// फ़ोन खड़ा हो तो इसका कोई असर नहीं — वहाँ चौड़ाई 384dp के
  /// आस-पास रहती है। लेटाने पर वो 853dp हो जाती है, और तब अक्षर
  /// पूरी चौड़ाई में फैल जाते हैं — एक पंक्ति इतनी लंबी हो जाती है कि
  /// आँख अगली पंक्ति का सिरा ढूँढ़ नहीं पाती।
  ///
  /// 600 यहीं से आया — एक पंक्ति में लगभग उतने अक्षर जितने छपी
  /// पुस्तक में होते हैं।
  static const double maxContentWidth = 600;
}

abstract final class VidhivatActionSize {
  static const double compact = VidhivatSpacing.xxxl;
  static const double minimumTouchTarget = 44;
  static const double regular = VidhivatSpacing.huge;
}

abstract final class VidhivatStroke {
  static const double focus = 1.5;
}

/// Restrained motion timings for presentation-only state changes.
abstract final class VidhivatMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 220);
}

/// विधिवत का रंग-रूप. Legacy aliases remain while future screens migrate.
class VidhivatTheme {
  static final haldi = VidhivatColorTokens.dark.primary;
  static final sindoor = VidhivatColorTokens.dark.secondary;
  static final tulsi = VidhivatColorTokens.dark.success;
  static final ink = VidhivatColorTokens.light.textPrimary;
  static final kagaz = VidhivatColorTokens.light.background;

  static VidhivatColorTokens colorsOf(BuildContext context) =>
      Theme.of(context).extension<VidhivatColorTokens>() ??
      VidhivatColorTokens.dark;

  static VidhivatTypography typographyOf(BuildContext context) =>
      Theme.of(context).extension<VidhivatTypography>() ??
      VidhivatTypography.from(colorsOf(context));

  static ThemeData light() => _build(VidhivatColorTokens.light);
  static ThemeData dark() => _build(VidhivatColorTokens.dark);

  static ThemeData _build(VidhivatColorTokens colors) {
    final isDark = colors == VidhivatColorTokens.dark;
    final type = VidhivatTypography.from(colors);
    final scheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: colors.primary,
      onPrimary: colors.textOnPrimary,
      primaryContainer: colors.primaryMuted,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.secondary,
      onSecondary: colors.textOnPrimary,
      secondaryContainer: colors.surfaceSubtle,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.info,
      onTertiary: colors.textOnPrimary,
      tertiaryContainer: colors.surfaceSubtle,
      onTertiaryContainer: colors.textPrimary,
      error: colors.error,
      onError: colors.textOnPrimary,
      errorContainer: colors.error.withValues(alpha: 0.18),
      onErrorContainer: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderSubtle,
      outlineVariant: colors.divider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.background,
      inversePrimary: colors.primaryPressed,
      surfaceTint: colors.primary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[colors, type],
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      textTheme: base.textTheme
          .copyWith(
            displaySmall: type.displayMedium,
            headlineMedium: type.pageTitle,
            headlineSmall: type.pageTitle,
            titleLarge: type.pageTitle,
            titleMedium: type.sectionTitle,
            titleSmall: type.cardTitle,
            bodyLarge: type.bodyLarge,
            bodyMedium: type.bodyMedium,
            bodySmall: type.bodySmall,
            labelLarge: type.label,
            labelMedium: type.caption,
            labelSmall: type.caption,
          )
          .apply(
              bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundElevated,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: type.pageTitle,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: VidhivatElevation.none,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: VidhivatRadius.large),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        space: 1,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceSubtle,
        circularTrackColor: colors.surfaceSubtle,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceElevated,
        contentTextStyle: type.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: VidhivatRadius.medium,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.backgroundElevated,
        surfaceTintColor: colors.backgroundElevated,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VidhivatRadius.extraLargeValue),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.backgroundElevated,
        surfaceTintColor: colors.backgroundElevated,
        titleTextStyle: type.sectionTitle,
        contentTextStyle: type.bodyMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: VidhivatRadius.extraLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(VidhivatActionSize.regular),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: VidhivatSpacing.xl),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: VidhivatRadius.extraLarge),
          ),
          textStyle: WidgetStatePropertyAll(type.label),
          foregroundColor: WidgetStatePropertyAll(colors.textOnPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.primaryMuted.withValues(alpha: 0.55);
            }
            return states.contains(WidgetState.pressed)
                ? colors.primaryPressed
                : colors.primary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(VidhivatActionSize.regular),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: VidhivatSpacing.lg),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: VidhivatRadius.medium),
          ),
          textStyle: WidgetStatePropertyAll(type.label),
          foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? colors.borderSubtle.withValues(alpha: 0.45)
                    : colors.borderSubtle,
              )),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(
              VidhivatActionSize.minimumTouchTarget,
              VidhivatActionSize.minimumTouchTarget,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: VidhivatRadius.small),
          ),
          textStyle: WidgetStatePropertyAll(type.label),
          foregroundColor: WidgetStatePropertyAll(colors.primary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(VidhivatActionSize.regular, VidhivatActionSize.regular),
          ),
          iconSize: const WidgetStatePropertyAll(VidhivatIconSize.medium),
          foregroundColor: WidgetStatePropertyAll(colors.textPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VidhivatSpacing.md,
          vertical: VidhivatSpacing.md,
        ),
        hintStyle: type.bodyMedium.copyWith(color: colors.textTertiary),
        labelStyle: type.bodySmall,
        helperStyle: type.caption,
        errorStyle: type.caption.copyWith(color: colors.error),
        border: const OutlineInputBorder(
          borderRadius: VidhivatRadius.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: VidhivatRadius.medium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VidhivatRadius.medium,
          borderSide:
              BorderSide(color: colors.primary, width: VidhivatStroke.focus),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: VidhivatRadius.medium,
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSubtle,
        selectedColor: colors.primaryMuted,
        disabledColor: colors.surfaceSubtle.withValues(alpha: 0.55),
        secondarySelectedColor: colors.primaryMuted,
        padding: const EdgeInsets.symmetric(
          horizontal: VidhivatSpacing.sm,
          vertical: VidhivatSpacing.xs,
        ),
        labelStyle: type.caption.copyWith(color: colors.textSecondary),
        secondaryLabelStyle: type.caption.copyWith(color: colors.textPrimary),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryMuted,
        labelTextStyle:
            WidgetStateProperty.resolveWith((states) => type.caption.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? colors.textPrimary
                      : colors.textTertiary,
                )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.textTertiary,
              size: VidhivatIconSize.medium,
            )),
        height: VidhivatSpacing.massive + VidhivatSpacing.xs,
      ),
    );
  }
}

Color shubhColour(BuildContext context, bool shubh) {
  final colors = VidhivatTheme.colorsOf(context);
  return shubh ? colors.success : colors.secondary;
}
