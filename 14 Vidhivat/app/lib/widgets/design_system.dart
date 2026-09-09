import 'package:flutter/material.dart';

import '../theme.dart';

/// The semantic action variants available to future screens.
enum VidhivatButtonVariant { primary, secondary, text, destructive }

/// A minimum-touch-target action with optional icon and loading state.
///
/// This does not contain any business action; callers retain ownership of the
/// callback and its state.
class VidhivatButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final VidhivatButtonVariant variant;
  final bool compact;
  final bool fullWidth;
  final bool isLoading;
  final String? semanticLabel;

  const VidhivatButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = VidhivatButtonVariant.primary,
    this.compact = false,
    this.fullWidth = false,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final callback = isLoading ? null : onPressed;
    // `Size.fromHeight` uses an infinite width. That is fine in a bounded
    // button bar but breaks a compact section action inside a `Row`.
    final minimumSize = Size(
      0,
      compact ? VidhivatActionSize.compact : VidhivatActionSize.regular,
    );
    final content = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      expand: fullWidth,
      textStyle: type.label,
      spinnerColor: variant == VidhivatButtonVariant.primary ||
              variant == VidhivatButtonVariant.destructive
          ? colors.textOnPrimary
          : colors.primary,
    );

    final ButtonStyle sizeStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(minimumSize),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: compact ? VidhivatSpacing.md : VidhivatSpacing.xl,
        ),
      ),
    );

    final Widget button;
    switch (variant) {
      case VidhivatButtonVariant.primary:
        button = _PrimaryButtonShell(
          enabled: callback != null,
          child: FilledButton(
            onPressed: callback,
            style: sizeStyle.copyWith(
              elevation: const WidgetStatePropertyAll(VidhivatElevation.none),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
              foregroundColor: WidgetStatePropertyAll(colors.textOnPrimary),
              overlayColor: WidgetStatePropertyAll(
                colors.textOnPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: content,
          ),
        );
      case VidhivatButtonVariant.secondary:
        button = OutlinedButton(
            onPressed: callback, style: sizeStyle, child: content);
      case VidhivatButtonVariant.text:
        button =
            TextButton(onPressed: callback, style: sizeStyle, child: content);
      case VidhivatButtonVariant.destructive:
        button = FilledButton(
          onPressed: callback,
          style: sizeStyle.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.disabled)
                    ? colors.error.withValues(alpha: 0.38)
                    : colors.error),
            foregroundColor: WidgetStatePropertyAll(colors.textOnPrimary),
          ),
          child: content,
        );
    }

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: callback != null,
      child:
          fullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final TextStyle textStyle;
  final Color spinnerColor;

  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.expand,
    required this.textStyle,
    required this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: VidhivatIconSize.small,
              height: VidhivatIconSize.small,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: spinnerColor),
            )
          else if (icon != null)
            Icon(icon, size: VidhivatIconSize.small),
          if (isLoading || icon != null)
            const SizedBox(width: VidhivatSpacing.xs),
          if (expand)
            Flexible(
              child: Text(label, style: textStyle, textAlign: TextAlign.center),
            )
          else
            Text(label, style: textStyle),
        ],
      );
}

/// Gives primary actions a distinct, tactile sacred-gold treatment without
/// changing their hit target, semantics or caller-owned callback.
class _PrimaryButtonShell extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const _PrimaryButtonShell({required this.child, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: enabled
              ? [colors.primary, colors.primaryPressed]
              : [
                  colors.primaryMuted.withValues(alpha: 0.72),
                  colors.primaryMuted.withValues(alpha: 0.5),
                ],
        ),
        borderRadius: VidhivatRadius.extraLarge,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// An accessible icon-only action. Supply [tooltip] for both sighted and
/// assistive-technology users.
class VidhivatIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool compact;

  const VidhivatIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: tooltip,
        enabled: onPressed != null,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon),
          constraints: BoxConstraints.tightFor(
            width: compact
                ? VidhivatActionSize.minimumTouchTarget
                : VidhivatActionSize.regular,
            height: compact
                ? VidhivatActionSize.minimumTouchTarget
                : VidhivatActionSize.regular,
          ),
        ),
      );
}

enum VidhivatCardVariant {
  standard,
  elevated,
  highlight,
  information,
  warning,
  success,
  selectable,
}

/// A surface primitive. It intentionally uses contrast and spacing first;
/// ordinary cards do not receive a visible border or heavy shadow.
class VidhivatSurfaceCard extends StatelessWidget {
  final Widget child;
  final VidhivatCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final String? semanticLabel;

  const VidhivatSurfaceCard({
    super.key,
    required this.child,
    this.variant = VidhivatCardVariant.standard,
    this.padding = const EdgeInsets.all(VidhivatSpacing.md),
    this.onTap,
    this.selected = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final style = _cardStyle(colors);
    final body = Padding(padding: padding, child: child);
    final tappable = onTap == null
        ? body
        : InkWell(
            onTap: onTap,
            borderRadius: VidhivatRadius.large,
            child: body,
          );

    return Semantics(
      container: true,
      excludeSemantics: semanticLabel != null,
      button: onTap != null,
      selected: variant == VidhivatCardVariant.selectable ? selected : null,
      label: semanticLabel,
      child: Material(
        color: style.color,
        elevation: style.elevation,
        shadowColor: style.elevation == VidhivatElevation.none
            ? Colors.transparent
            : Colors.black,
        borderRadius: VidhivatRadius.large,
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: VidhivatRadius.large,
            gradient: style.gradient,
            boxShadow: style.shadow,
            border: style.border == null
                ? null
                : Border.fromBorderSide(style.border!),
          ),
          child: tappable,
        ),
      ),
    );
  }

  _CardStyle _cardStyle(VidhivatColorTokens colors) {
    final selectedBorder =
        BorderSide(color: colors.primary, width: VidhivatStroke.focus);
    return switch (variant) {
      VidhivatCardVariant.standard => _CardStyle(colors.surface),
      VidhivatCardVariant.elevated => _CardStyle(
          colors.surfaceElevated,
          elevation: VidhivatElevation.subtle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surfaceElevated, colors.surface],
          ),
        ),
      VidhivatCardVariant.highlight => _CardStyle(
          colors.primaryMuted,
          elevation: VidhivatElevation.subtle,
          border: selectedBorder,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryMuted,
              colors.secondary.withValues(alpha: 0.50),
            ],
          ),
          shadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      VidhivatCardVariant.information =>
        _CardStyle(colors.info.withValues(alpha: 0.13)),
      VidhivatCardVariant.warning =>
        _CardStyle(colors.warning.withValues(alpha: 0.14)),
      VidhivatCardVariant.success =>
        _CardStyle(colors.success.withValues(alpha: 0.14)),
      VidhivatCardVariant.selectable => _CardStyle(
          selected ? colors.primaryMuted : colors.surface,
          border: selected ? selectedBorder : null,
        ),
    };
  }
}

class _CardStyle {
  final Color color;
  final double elevation;
  final BorderSide? border;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;

  const _CardStyle(
    this.color, {
    this.elevation = 0,
    this.border,
    this.gradient,
    this.shadow,
  });
}

enum VidhivatStatusTone { neutral, primary, success, warning, error, info }

/// A quiet hierarchy marker for sections that do not need a card wrapper.
class VidhivatSectionHeader extends StatelessWidget {
  final String title;
  final String? supportingText;
  final Widget? action;

  const VidhivatSectionHeader({
    super.key,
    required this.title,
    this.supportingText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: VidhivatSpacing.xxs,
          height: VidhivatSpacing.xxl,
          margin: const EdgeInsets.only(top: VidhivatSpacing.xxs),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.primary, colors.secondary],
            ),
            borderRadius: VidhivatRadius.pill,
          ),
        ),
        const SizedBox(width: VidhivatSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: type.sectionTitle),
              if (supportingText != null) ...[
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(
                  supportingText!,
                  style: type.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

/// A compact status/category/duration/count primitive. It always includes
/// text, so colour never carries the meaning alone.
class VidhivatStatusChip extends StatelessWidget {
  final String label;
  final VidhivatStatusTone tone;
  final IconData? icon;
  final bool selected;

  const VidhivatStatusChip({
    super.key,
    required this.label,
    this.tone = VidhivatStatusTone.neutral,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final colour = switch (tone) {
      VidhivatStatusTone.neutral => colors.textSecondary,
      VidhivatStatusTone.primary => colors.primary,
      VidhivatStatusTone.success => colors.success,
      VidhivatStatusTone.warning => colors.warning,
      VidhivatStatusTone.error => colors.error,
      VidhivatStatusTone.info => colors.info,
    };

    return Semantics(
      label: label,
      selected: selected,
      child: Container(
        constraints: const BoxConstraints(minHeight: VidhivatSpacing.xxl),
        padding: const EdgeInsets.symmetric(
          horizontal: VidhivatSpacing.sm,
          vertical: VidhivatSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: selected ? 0.23 : 0.14),
          borderRadius: VidhivatRadius.pill,
          border: Border.all(color: colour.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: VidhivatIconSize.small, color: colour),
              const SizedBox(width: VidhivatSpacing.xxs),
            ],
            Flexible(
              child: Text(
                label,
                style: VidhivatTheme.typographyOf(context)
                    .caption
                    .copyWith(color: colour),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quiet dividers for use only where proximity does not make the grouping
/// clear on its own.
class VidhivatDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final double thickness;

  const VidhivatDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) => Divider(
        indent: indent,
        endIndent: endIndent,
        thickness: thickness,
        height: thickness,
      );
}

/// A low-contrast midnight backdrop with a warm, sacred focal glow. It uses
/// only Flutter drawing primitives so local devotional artwork can be added
/// later without changing the screen layout.
class VidhivatSacredBackdrop extends StatelessWidget {
  final Widget child;

  const VidhivatSacredBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.backgroundElevated, colors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -88,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.secondary.withValues(alpha: 0.055),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.045),
                      blurRadius: 90,
                      spreadRadius: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Asset-ready sacred hero. The motif is intentionally abstract rather than a
/// representation of a deity, so it remains respectful when no local artwork
/// is bundled with the application.
class VidhivatSacredHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? footer;
  final bool compact;
  final String? semanticLabel;
  final String? artworkAsset;
  final String? artworkSemanticLabel;

  /// A featured card can enlarge the painted artwork without changing the
  /// transparent source file or its packaged size.
  final double artworkScale;

  const VidhivatSacredHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.icon = Icons.local_fire_department_outlined,
    this.footer,
    this.compact = false,
    this.semanticLabel,
    this.artworkAsset,
    this.artworkSemanticLabel,
    this.artworkScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final media = MediaQuery.of(context);
    final dense = compact ||
        media.size.width < 360 ||
        media.textScaler.scale(type.bodyMedium.fontSize!) >
            type.bodyMedium.fontSize! * 1.3;
    final padding = dense ? VidhivatSpacing.md : VidhivatSpacing.xl;
    final baseLabel = semanticLabel ?? '$eyebrow। $title। $subtitle';
    final accessibleLabel = artworkSemanticLabel == null
        ? baseLabel
        : '$baseLabel। $artworkSemanticLabel';
    return Semantics(
      container: true,
      label: accessibleLabel,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: VidhivatRadius.extraLarge,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.secondary.withValues(alpha: 0.34),
              colors.surfaceElevated,
              colors.backgroundElevated,
            ],
          ),
          border: Border.all(color: colors.primary.withValues(alpha: 0.26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showArtwork =
                artworkAsset != null && constraints.maxWidth >= 280;
            final artworkHeight = dense
                ? 148.0
                : (constraints.maxWidth * 0.68).clamp(196.0, 272.0).toDouble();
            final textContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: type.caption.copyWith(
                    color: colors.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                Text(
                  title,
                  style: (dense ? type.pageTitle : type.displayMedium)
                      .copyWith(color: colors.textPrimary),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: VidhivatSpacing.xs),
                  Text(
                    subtitle,
                    // गद्य दोनों किनारों से सीधा। एक लाइन वाले subtitle
                    // पर असर नहीं — justify आख़िरी लाइन नहीं खींचता।
                    textAlign: TextAlign.justify,
                    style: type.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            );
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showArtwork) ...[
                    textContent,
                    const SizedBox(height: VidhivatSpacing.md),
                    Center(
                      child: ClipRect(
                        child: Transform.scale(
                          scale: artworkScale,
                          alignment: Alignment.bottomCenter,
                          child: _HeroArtwork(
                            assetPath: artworkAsset!,
                            width: constraints.maxWidth - (padding * 2),
                            height: artworkHeight,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: textContent),
                        const SizedBox(width: VidhivatSpacing.sm),
                        _SacredMotif(icon: icon),
                      ],
                    ),
                  if (footer != null) ...[
                    const SizedBox(height: VidhivatSpacing.lg),
                    footer!,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SacredMotif extends StatelessWidget {
  final IconData icon;

  const _SacredMotif({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return Container(
      width: VidhivatSpacing.huge,
      height: VidhivatSpacing.huge,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.15),
        border: Border.all(color: colors.primary.withValues(alpha: 0.68)),
      ),
      child: Icon(icon, color: colors.primary, size: VidhivatIconSize.large),
    );
  }
}

/// A safe local image shell for bundled devotional art. Decorative artwork is
/// excluded from TalkBack because the surrounding Puja card already names the
/// context. If an asset is unavailable, the visual falls back quietly instead
/// of breaking the screen.
class _HeroArtwork extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const _HeroArtwork({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          // ⚠ **`cacheWidth` और `cacheHeight` दोनों मत देना।**
          //
          // दोनों देने पर Flutter बिंब को ठीक उसी नाप पर **खींच** देता
          // है — अनुपात नहीं बचाता (`ImageDescriptor.instantiateCodec`)। और
          // `BoxFit.contain` उसे सुधार नहीं सकता, क्योंकि जो bitmap उसे मिलता
          // है वो पहले से खिंचा हुआ होता है।
          //
          // फ़ोन पर पकड़ा गया (6 सितम्बर): भगवान का चित्र 720×900 का है
          // (खड़ा, 0.80) — और यहाँ डिब्बा चौड़ा है, इसलिए चेहरा चौड़ाई में
          // फैला हुआ दिखता था।
          //
          // सारे चित्र या खड़े हैं या वर्गाकार, और डिब्बा वर्गाकार या लेटा —
          // यानी सीमा हमेशा **ऊँचाई** तय करती है। इसलिए सिर्फ़ `cacheHeight`।
          cacheHeight: (height * pixelRatio).round(),
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
            ),
            child: Icon(
              Icons.local_fire_department_outlined,
              color: colors.primary,
              size: VidhivatIconSize.large,
            ),
          ),
        ),
      ),
    );
  }
}

enum VidhivatStateTone { neutral, error }

/// A calm full-page loading, empty or error presentation.
///
/// Callers own the factual copy. Technical exceptions and stack traces should
/// never be passed into this widget.
class VidhivatStateView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final bool loading;
  final VidhivatStateTone tone;

  const VidhivatStateView({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.loading = false,
    this.tone = VidhivatStateTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final accent =
        tone == VidhivatStateTone.error ? colors.error : colors.textSecondary;

    return Semantics(
      key: Key(loading ? 'vidhivat_loading_state' : 'vidhivat_message_state'),
      container: true,
      liveRegion: true,
      label: [title, if (message != null) message!].join('. '),
      excludeSemantics: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VidhivatSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: VidhivatIconSize.large,
                    height: VidhivatIconSize.large,
                    child: CircularProgressIndicator(
                      strokeWidth: VidhivatStroke.focus,
                      color: colors.primary,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: VidhivatIconSize.large, color: accent),
                if (loading || icon != null)
                  const SizedBox(height: VidhivatSpacing.md),
                Text(title, style: type.cardTitle, textAlign: TextAlign.center),
                if (message != null) ...[
                  const SizedBox(height: VidhivatSpacing.xs),
                  Text(
                    message!,
                    style: type.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **ⓘ वाला बटन — पढ़ने की चीज़ें एक दबाव पीछे।**
///
/// ## यह क्यों बना
///
/// ऐप के तीन पन्नों पर वही समस्या थी: नीचे एक कार्ड जो बताता है कि यह
/// पाठ/विधि *कहाँ से आई* — पद्धति, क्षेत्र, रचयिता, स्रोत। ईमानदारी के
/// लिए वो ज़रूरी है, पर **पूजा या पाठ करते आदमी के लिए नहीं** — वो हवाला
/// पढ़ने नहीं आया।
///
/// यही फ़ैसला मंत्र के स्रोत पर पहले लिया जा चुका था (→ D-042 के बाद),
/// जहाँ नापकर निकला था कि सहायक-पाठ मंत्र से **सवा तीन गुना** ज़्यादा है।
/// अब वही रूप तीनों जगह एक जैसा है (→ D-045)।
///
/// **छिपाया कुछ नहीं जाता** — बटन पर साफ़ लिखा रहता है कि अंदर क्या है,
/// और वो हमेशा दिखता है। सिर्फ़ खुला नहीं पड़ा रहता।
class VidhivatSrotButton extends StatelessWidget {
  final String label;

  /// शीट के ऊपर का शीर्षक। न दो तो [label] ही — दोनों एक रहने से दबाने
  /// वाला भटकता नहीं। अलग तब चाहिए जब बटन पर कुछ जोड़ा गया हो, जैसे
  /// "· इस पर दो चलन हैं"।
  final String? shirshak;

  /// शीट के अंदर की पंक्तियाँ, क्रम से।
  final List<VidhivatSrotPankti> panktiyan;

  /// सबसे नीचे की छोटी बात — जैसे "आपके घर का चलन अलग हो तो वही सही है"।
  final String? antimBaat;

  const VidhivatSrotButton({
    super.key,
    required this.label,
    required this.panktiyan,
    this.shirshak,
    this.antimBaat,
  });

  void _kholo(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          // ⚠️ नीचे की जगह `xxl` से नहीं, फ़ोन के अपने inset से बनती है।
          // `useSafeArea` सिर्फ़ शीट को ऊपर वाले notch से बचाता है; नीचे
          // Android का नेविगेशन बार शीट के **ऊपर** बैठा रहता है और
          // आख़िरी पंक्ति उसके पीछे चली जाती है (फ़ोन पर पकड़ा गया)।
          padding: EdgeInsets.fromLTRB(
            VidhivatSpacing.lg,
            0,
            VidhivatSpacing.lg,
            VidhivatSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            Text(shirshak ?? label, style: type.sectionTitle),
            for (final pankti in panktiyan)
              if (pankti.value.trim().isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                Text(pankti.label, style: type.label),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(pankti.value, style: type.bodyMedium),
              ],
            if (antimBaat != null) ...[
              const SizedBox(height: VidhivatSpacing.lg),
              Text(antimBaat!, style: type.caption),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);

    // ── चौड़ाई ख़ुद बाँधनी पड़ती है ───────────────────────
    //
    // Material का बटन अपने बच्चे को `Align(widthFactor: 1)` में रखता है —
    // यानी बच्चे को **बिना सीमा वाली चौड़ाई** मिलती है। वहाँ न `Flexible`
    // काम करता है, न `Expanded` — लेबल लपेटने की बजाय सीधा स्क्रीन
    // से बाहर चला जाता है।
    //
    // 320dp चौड़ी स्क्रीन पर 1.5× अक्षरों के साथ यह **252px का overflow**
    // बनाता था — जाँच ने पकड़ा (`phase6_screens_test`)। इसलिए जगह
    // बाहर से नापकर लेबल पर खुद बाँधी जाती है।
    return LayoutBuilder(
      builder: (context, constraints) {
        // बटन का अपना padding, ℹ का चिह्न, और दोनों के बीच की जगह।
        final bachiJagah = constraints.maxWidth -
            VidhivatSpacing.sm * 2 -
            VidhivatIconSize.small -
            VidhivatSpacing.xs;
        final labelKiJagah = constraints.hasBoundedWidth && bachiJagah > 0
            ? bachiJagah
            : double.infinity;
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _kholo(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: VidhivatSpacing.sm,
                vertical: VidhivatSpacing.xs,
              ),
              // उँगली के लिए पूरी ऊँचाई, भले अक्षर छोटे हों।
              minimumSize: const Size(0, VidhivatActionSize.minimumTouchTarget),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: VidhivatIconSize.small,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: VidhivatSpacing.xs),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: labelKiJagah),
                  child: Text(
                    label,
                    style: type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// [VidhivatSrotButton] की शीट में एक पंक्ति। ख़ाली `value` छँट जाती है।
class VidhivatSrotPankti {
  final String label;
  final String value;

  const VidhivatSrotPankti(this.label, this.value);
}

/// **दीये का चिह्न** — नीचे वाली पट्टी के "पूजा" टैब के लिए।
///
/// ## यह क्यों बना
///
/// पहले वहाँ `Text('🪔')` था — यानी emoji। बाक़ी तीनों टैब (होम,
/// कैलेंडर, अधिक) Material के **रेखा-वाले** चिह्न हैं, इसलिए बीच में
/// एक भरा-पूरा रंगीन चित्र अटपटा लगता था — जैसे किसी और ऐप से चिपका हो।
/// ऊपर से emoji हर फ़ोन पर अपनी शक़्ल का होता है (Samsung, vivo और Pixel
/// में तीन अलग दीये), इसलिए ऐप का रूप फ़ोन-दर-फ़ोन बदल जाता था।
///
/// Material में दीया है ही नहीं, और आग वाला चिह्न (`local_fire_department`)
/// दीया नहीं कहता। इसलिए यह ख़ुद बनाया गया — 24×24 की उसी नाप पर, उसी
/// 1.8 मोटाई की रेखा से, ताकि बाक़ी तीनों के बीच बैठ जाए।
///
/// रंग `IconTheme` से आता है, इसलिए चुने और बिना-चुने दोनों हालतों में
/// पट्टी अपने आप सही रंग देती है।
class VidhivatDiyaIcon extends StatelessWidget {
  final double size;

  /// चुना हुआ टैब भरा हुआ दिखता है, बाक़ी खोखले — वही नियम जो Material
  /// के `outlined`/भरे चिह्नों में है।
  final bool bhara;

  final Color? color;

  const VidhivatDiyaIcon({
    super.key,
    this.size = 24,
    this.bhara = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rang = color ??
        IconTheme.of(context).color ??
        VidhivatTheme.colorsOf(context).textSecondary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiyaPainter(color: rang, bhara: bhara),
      ),
    );
  }
}

/// दीया — ऊपर लौ, नीचे उथला दीपपात्र। सारे नाप 24×24 की जाली पर हैं,
/// फिर असली नाप के हिसाब से बढ़ा दिए जाते हैं।
class _DiyaPainter extends CustomPainter {
  final Color color;
  final bool bhara;

  const _DiyaPainter({required this.color, required this.bhara});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24.0;
    Offset p(double x, double y) => Offset(x * k, y * k);

    // ── लौ — आँसू की शक़्ल ──
    final lau = Path()
      ..moveTo(12 * k, 2.8 * k)
      ..quadraticBezierTo(16.4 * k, 7.4 * k, 16.4 * k, 10.2 * k)
      ..quadraticBezierTo(16.4 * k, 13.4 * k, 12 * k, 13.4 * k)
      ..quadraticBezierTo(7.6 * k, 13.4 * k, 7.6 * k, 10.2 * k)
      ..quadraticBezierTo(7.6 * k, 7.4 * k, 12 * k, 2.8 * k)
      ..close();

    // ── दीपपात्र — उथला कटोरा ──
    final patra = Path()
      ..moveTo(3.2 * k, 15.2 * k)
      ..quadraticBezierTo(12 * k, 22.4 * k, 20.8 * k, 15.2 * k)
      ..close();

    final brush = Paint()
      ..color = color
      ..isAntiAlias = true;

    if (bhara) {
      brush.style = PaintingStyle.fill;
    } else {
      brush
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * k
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
    }

    canvas.drawPath(lau, brush);
    canvas.drawPath(patra, brush);
    // खोखली हालत में लौ और पात्र के बीच की बत्ती — वरना दोनों अलग-अलग
    // तैरते दिखते हैं।
    if (!bhara) {
      canvas.drawLine(p(12, 13.4), p(12, 15.2), brush);
    }
  }

  @override
  bool shouldRepaint(_DiyaPainter old) =>
      old.color != color || old.bhara != bhara;
}
