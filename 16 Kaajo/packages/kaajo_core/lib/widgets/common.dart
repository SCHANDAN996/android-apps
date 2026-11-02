import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../content/config.dart';

/// पूरी चौड़ाई का बटन। [outlined] true हो तो बॉर्डर वाला।
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  /// भरे बटन का रंग (डिफ़ॉल्ट टील)।
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpace.buttonRadius));
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpace.s)],
        Flexible(child: Text(label, textAlign: TextAlign.center, style: textStyle)),
      ],
    );
    return SizedBox(
      width: double.infinity,

      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpace.buttonHeight),
        child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                foregroundColor: color ?? AppColors.primary,
                side: BorderSide(color: color ?? AppColors.primary, width: 1.4),
              ),
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: shape,
                backgroundColor: color ?? AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: child,
            ),
      ),
    );
  }
}

/// सफ़ेद कार्ड, हल्की बॉर्डर, कोने 16। [onTap] हो तो दबाने लायक।
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.l),
    this.color = AppColors.card,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpace.radius);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// सेक्शन का शीर्षक, साथ में वैकल्पिक दाईं तरफ़ का बटन।
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.m),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.h2)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// भरोसे की पट्टी: "48 घंटे में विज़िट · फ़ोटो रिपोर्ट · तय रेट"
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.schedule, '48 घंटे में विज़िट'),
      (Icons.photo_camera, 'फ़ोटो रिपोर्ट'),
      (Icons.currency_rupee, 'तय रेट'),
    ];
    return Row(
      children: [
        for (final (icon, label) in items)
          Expanded(
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(height: AppSpace.xs),
                Text(label, textAlign: TextAlign.center, style: AppText.small),
              ],
            ),
          ),
      ],
    );
  }
}

/// स्थिति का छोटा रंगीन लेबल।
enum ChipTone { neutral, success, warning, danger, info }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = ChipTone.neutral});

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      ChipTone.success => (AppColors.successSoft, AppColors.success),
      ChipTone.warning => (AppColors.warningSoft, AppColors.warning),
      ChipTone.danger => (AppColors.dangerSoft, AppColors.danger),
      ChipTone.info => (AppColors.primarySoft, AppColors.primaryDark),
      ChipTone.neutral => (const Color(0xFFF3F4F6), AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

/// ख़ाली सूची के लिए संदेश और बटन।
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpace.l),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpace.s),
          Text(message, style: AppText.muted, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpace.xl),
            AppButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// रंगीन सूचना-पट्टी (चेतावनी, सुझाव आदि)।
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.text,
    this.title,
    this.icon = Icons.info_outline,
    this.tone = ChipTone.info,
  });

  final String? title;
  final String text;
  final IconData icon;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      ChipTone.success => (AppColors.successSoft, AppColors.success),
      ChipTone.warning => (AppColors.warningSoft, AppColors.warning),
      ChipTone.danger => (AppColors.dangerSoft, AppColors.danger),
      ChipTone.info => (AppColors.primarySoft, AppColors.primaryDark),
      ChipTone.neutral => (const Color(0xFFF3F4F6), AppColors.text),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSpace.radius)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpace.xs),
                ],
                Text(text, style: TextStyle(color: fg, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// नीचे चिपका मुख्य बटन (Scaffold के bottomNavigationBar में रखें)।
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.l, AppSpace.m),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: child,
      ),
    );
  }
}

/// छोटा संदेश नीचे दिखाना।
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

/// WhatsApp न खुले तो दिखने वाला संदेश।
const String whatsAppFailedMessage =
    'WhatsApp नहीं खुला। कृपया WhatsApp इंस्टॉल करें या मदद वाले पेज से कॉल करें।';


/// ग्राहक और पार्टनर ऐप की एक जैसी ब्रांड पहचान।
class KaajoBrand extends StatelessWidget {
  const KaajoBrand({super.key, this.partner = false, this.light = false});
  final bool partner;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.s),
          decoration: BoxDecoration(
            color: light ? AppColors.sun : AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpace.buttonRadius),
          ),
          child: Icon(Icons.bolt_rounded, color: light ? AppColors.ink : AppColors.onBrand),
        ),
        const SizedBox(width: AppSpace.s),
        Flexible(
          child: Text(
            partner ? AppConfig.partnerAppName : AppConfig.appName,
            style: AppText.h2.copyWith(color: light ? AppColors.onBrand : AppColors.primary),
          ),
        ),
      ],
    );
  }
}
