import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';
import 'settings_screen.dart';

/// और tab — सिर्फ़ *जानकारी + ऐप* की चीज़ें।
///
/// पहले यह tab एक कूड़ेदान था (8 items की सूची — मौसम/मंडी भी यहीं थे)।
/// अब मौसम/मंडी "खेती" tab में चले गए, और बाक़ी बड़े icon-tiles के grid में —
/// किसान एक नज़र में देख ले, पढ़ना न पड़े।
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  String _t(BuildContext c, String k) => AppLocalizations.get(c, k);

  @override
  Widget build(BuildContext context) {
    final info = <_Item>[
      _Item(_t(context, 'moreYojana'), Icons.account_balance_rounded,
          Colors.purple.shade400, () => Navigator.pushNamed(context, '/yojana'),
          imageAsset: 'assets/images/3d_schemes.webp'),
      _Item(_t(context, 'moreNews'), Icons.article_rounded, Colors.teal.shade600,
          () => Navigator.pushNamed(context, '/news'),
          imageAsset: 'assets/images/3d_news.webp'),
      _Item(_t(context, 'moreHelpline'), Icons.phone_in_talk_rounded,
          Colors.red.shade600, () => Navigator.pushNamed(context, '/helpline'),
          imageAsset: 'assets/images/3d_helpline.webp'),
      _Item(_t(context, 'moreSujhav'), Icons.lightbulb_rounded, DairyTheme.amber,
          () => Navigator.pushNamed(context, '/sujhav'),
          imageAsset: 'assets/images/3d_feedback.webp'),
      _Item(_t(context, 'moreFaq'), Icons.help_center_rounded,
          Colors.blue.shade600, () => Navigator.pushNamed(context, '/faq'),
          imageAsset: 'assets/images/3d_faq.webp'),
    ];

    final app = <_Item>[
      _Item(
          _t(context, 'settings'),
          Icons.settings_rounded,
          DairyTheme.primaryTeal,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          imageAsset: 'assets/images/3d_settings.webp'),
      _Item(_t(context, 'moreAbout'), Icons.info_rounded, Colors.blueGrey,
          () => Navigator.pushNamed(context, '/about'),
          imageAsset: 'assets/images/3d_about.webp'),
    ];

    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(title: Text(_t(context, 'navMore'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          _title(_t(context, 'moreInfoSection')),
          const SizedBox(height: 12),
          _grid(info),
          const SizedBox(height: 26),
          _title(_t(context, 'moreAppSection')),
          const SizedBox(height: 12),
          _grid(app),
        ],
      ),
    );
  }

  Widget _title(String text) => Text(text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w800, color: DairyTheme.textDark));

  Widget _grid(List<_Item> items) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: items.map(_tile).toList(),
      );

  Widget _tile(_Item it) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: it.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: it.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                  child: it.imageAsset != null
                      ? Image.asset(
                          it.imageAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Icon(it.icon, color: it.color, size: 27),
                        )
                      : Icon(it.icon, color: it.color, size: 27),
                ),
                const SizedBox(height: 9),
                Text(it.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, height: 1.2)),
              ],
            ),
          ),
        ),
      );
}

class _Item {
  final String label;
  final IconData icon;
  final Color color;
  final String? imageAsset;
  final VoidCallback onTap;

  const _Item(this.label, this.icon, this.color, this.onTap, {this.imageAsset});
}
