import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'aaj_screen.dart';
import 'muhurta_screen.dart';
import 'paath_list_screen.dart';
import 'sankalp_screen.dart';
import 'settings_screen.dart';

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
                  icon: Icons.menu_book_outlined,
                  title: 'चालीसा और आरती',
                  subtitle: 'बैठकर पढ़ने वाली स्तुतियाँ — पूजा से अलग',
                  onTap: () => _open(context, const PaathListScreen()),
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
                const SizedBox(height: VidhivatSpacing.xxl),
                const VidhivatSectionHeader(title: 'ऐप'),
                const SizedBox(height: VidhivatSpacing.md),
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
