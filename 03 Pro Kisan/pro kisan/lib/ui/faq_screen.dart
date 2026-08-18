import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/faq.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';

/// अक्सर पूछे जाने वाले सवाल — 10 भाषाओं में।
///
/// Data: `lib/data/faq.dart` में। नया सवाल जोड़ना हो तो वहाँ जाएँ।
/// यह screen सिर्फ़ चुनी भाषा के सवाल-जवाब दिखाता है।
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  String _t(BuildContext c, String k) => AppLocalizations.get(c, k);

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(title: Text(_t(context, 'faqTitle'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
        children: [
          // छोटी सी पट्टी — किसान को बताती है क्या है यह
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: DairyTheme.primaryTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: DairyTheme.primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_t(context, 'faqIntro'),
                      style: const TextStyle(fontSize: 14, height: 1.35)),
                ),
              ],
            ),
          ),

          for (var i = 0; i < kFaq.length; i++) _faqCard(context, kFaq[i], lang, i + 1),

          const SizedBox(height: 20),

          // अगर सवाल फिर भी बचा हो — support link
          _moreHelp(context),
        ],
      ),
    );
  }

  /// एक ExpansionTile — बंद रहती है, tap पर जवाब खुलता है।
  Widget _faqCard(BuildContext context, FaqItem item, String lang, int num) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            radius: 15,
            backgroundColor: DairyTheme.primaryTeal.withValues(alpha: 0.14),
            child: Text('$num',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DairyTheme.primaryTeal)),
          ),
          title: Text(item.q(lang),
              style:
                  const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
          children: [
            Text(item.a(lang),
                style: const TextStyle(fontSize: 15, height: 1.45)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _shareQnA(item, lang),
                icon: const Icon(Icons.share_rounded, size: 16),
                label: Text(AppLocalizations.get(context, 'yShare'),
                    style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreHelp(BuildContext context) => Card(
        color: DairyTheme.creamBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: ListTile(
          leading: const Icon(Icons.help_outline_rounded,
              color: DairyTheme.primaryTeal),
          title: Text(_t(context, 'faqMoreHelp'),
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          subtitle: Text(_t(context, 'faqMoreHelpSub'),
              style: const TextStyle(fontSize: 13)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/sujhav'),
        ),
      );

  void _shareQnA(FaqItem item, String lang) {
    Share.share('❓ ${item.q(lang)}\n\n💡 ${item.a(lang)}\n\n— प्रो किसान');
  }
}
