import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'aaj_screen.dart';
import 'dakshina_screen.dart';
import 'muhurta_screen.dart';
import 'paath_list_screen.dart';
import 'grahan_screen.dart';
import 'vrat_screen.dart';
import 'sankalp_screen.dart';
import 'settings_screen.dart';
import 'surya_grahan_screen.dart';

/// Features removed from the crowded six-item navigation remain available
/// here. This is a destination list, not a second dashboard.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: VidhivatSacredBackdrop(
            child: Panna(
              padding: const EdgeInsets.fromLTRB(
                VidhivatSpacing.lg,
                VidhivatSpacing.lg,
                VidhivatSpacing.lg,
                VidhivatSpacing.xxl,
              ),
              children: [
                Text('अधिक',
                    style: VidhivatTheme.typographyOf(context).pageTitle),
                const SizedBox(height: VidhivatSpacing.xs),
                Text(
                  'पूजा के सहायक साधन और ऐप की सेटिंग',
                  style: VidhivatTheme.typographyOf(context).bodyMedium,
                ),
                const SizedBox(height: VidhivatSpacing.xxl),
                const VidhivatSectionHeader(title: 'पूजा के साधन'),
                const SizedBox(height: VidhivatSpacing.md),
                _MoreItem(
                  icon: Icons.water_drop_outlined,
                  title: 'संकल्प',
                  subtitle: 'अपने या परिवार के सदस्य के लिए संकल्प बनाएँ',
                  onTap: () => _open(context, const SankalpScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                _MoreItem(
                  icon: Icons.schedule_outlined,
                  title: 'चौघड़िया और होरा',
                  subtitle: 'आपके स्थान के अनुसार दिन और रात का समय',
                  onTap: () => _open(context, const MuhurtaScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                _MoreItem(
                  icon: Icons.wb_sunny_outlined,
                  title: 'आज का पूरा पंचांग',
                  subtitle: 'तिथि, नक्षत्र, योग, करण और समय',
                  onTap: () => _open(context, const AajScreen()),
                ),
                // ── पढ़ने की चीज़ें, पूजा के साधनों से अलग (→ D-051) ──
                //
                // चालीसा और आरती पहले "पूजा के साधन" में एक कार्ड थीं।
                // पर वे साधन नहीं हैं — वे अपने आप में पढ़ी जाने वाली
                // चीज़ें हैं, और घर में सबसे ज़्यादा यही पढ़ी जाती हैं।
                // इसीलिए इनका अपना हिस्सा है।
                const SizedBox(height: VidhivatSpacing.xxl),
                const VidhivatSectionHeader(
                  title: 'पढ़ने के लिए',
                  supportingText: 'इसके लिए सामग्री या संकल्प नहीं चाहिए',
                ),
                const SizedBox(height: VidhivatSpacing.md),
                _MoreItem(
                  icon: Icons.menu_book_outlined,
                  title: 'चालीसा और आरती',
                  subtitle: 'हनुमान चालीसा और दस आरतियाँ',
                  onTap: () => _open(context, const PaathListScreen()),
                ),
                // ── व्रत और ग्रहण — दोनों तिथि-काल की चीज़ें ─────────
                //
                // ये "पढ़ने के लिए" नहीं हैं, न "पूजा के साधन"। ये बताते
                // हैं कि **कौन सा दिन क्या है** — इसलिए अपना हिस्सा।
                const SizedBox(height: VidhivatSpacing.xxl),
                const VidhivatSectionHeader(
                  title: 'व्रत और ग्रहण',
                  supportingText: 'तारीख़ें आपके शहर के पंचांग से',
                ),
                const SizedBox(height: VidhivatSpacing.md),
                _MoreItem(
                  icon: Icons.event_available_outlined,
                  title: 'व्रत और उपवास',
                  subtitle: 'एकादशी, प्रदोष, संकष्टी, पूर्णिमा, अमावस्या',
                  onTap: () => _open(context, const VratScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                _MoreItem(
                  icon: Icons.brightness_3_outlined,
                  title: 'चंद्रग्रहण',
                  subtitle: 'कब, यहाँ से दिखेगा या नहीं, और सूतक',
                  onTap: () => _open(context, const GrahanScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                _MoreItem(
                  // आधा ढका सूरज — ऊपर "आज का पूरा पंचांग" वाला
                  // `wb_sunny_outlined` यहाँ दोबारा नहीं लगाया जा सकता।
                  icon: Icons.brightness_medium_outlined,
                  title: 'सूर्यग्रहण',
                  subtitle: 'यहाँ कितना दिखेगा, और सूतक',
                  onTap: () => _open(context, const SuryaGrahanScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.xxl),
                const VidhivatSectionHeader(title: 'ऐप'),
                const SizedBox(height: VidhivatSpacing.md),
                // ── दक्षिणा यहाँ क्यों (→ D-053) ────────────────────
                //
                // बहुत लोग पूजा के तुरंत बाद नहीं देते, बाद में सोचकर
                // देते हैं। तब ढूँढ़ने की जगह न हो तो देने वाला भी लौट
                // जाता है। इसीलिए यह पंक्ति हमेशा रहती है — घड़ी का
                // नियम सिर्फ़ *ख़ुद से पूछने* पर लगता है, यहाँ नहीं।
                _MoreItem(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'विधिवत को दक्षिणा',
                  subtitle: 'स्वेच्छा से — इससे ऐप में कुछ नहीं बदलता',
                  onTap: () => _open(context, const DakshinaScreen()),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                _MoreItem(
                  icon: Icons.settings_outlined,
                  title: 'सेटिंग',
                  subtitle: 'स्थान, मास-पद्धति और यजमान की जानकारी',
                  onTap: () => _open(context, const SettingsScreen()),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      onTap: onTap,
      variant: VidhivatCardVariant.elevated,
      semanticLabel: title,
      child: Row(
        children: [
          Container(
            width: VidhivatSpacing.huge,
            height: VidhivatSpacing.huge,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: VidhivatRadius.medium,
            ),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: VidhivatSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(
                  subtitle,
                  style: type.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: VidhivatSpacing.xs),
          Icon(Icons.chevron_right, color: colors.textTertiary),
        ],
      ),
    );
  }
}
