import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_language.dart';
import '../data/app_links.dart';
import '../data/pro_kisan_strings.dart';

/// हमारे दूसरे ऐप "प्रो किसान" का परिचय।
///
/// सीधे Play Store पर भेजने के बजाय पहले यह पन्ना दिखता है — user को पता तो
/// चले कि वो ऐप करता क्या है। जो लिखा है वो Pro Kisan की अपनी Play listing से
/// है, बढ़ा-चढ़ाकर कुछ नहीं।
class ProKisanScreen extends StatelessWidget {
  const ProKisanScreen({super.key});

  Future<void> _openPlayStore(BuildContext context, AppStrings strings) async {
    // सिर्फ़ https वाला Play लिंक — `market://` फोन-कंपनी का अपना store खोल
    // देता है (देखें app_links.dart)। Play लगा हो तो वही खुलेगा, वरना browser।
    try {
      final ok = await launchUrl(
        Uri.parse(proKisanWebLink),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    } catch (_) {
      // नीचे संदेश दिखा देंगे
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pkCouldNotOpen)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        final theme = Theme.of(context);

        final features = <_Feature>[
          _Feature(Icons.local_drink_rounded, const Color(0xFF1565C0),
              strings.pkMilkTitle, strings.pkMilkBody),
          _Feature(Icons.grass_rounded, const Color(0xFF2E7D32),
              strings.pkFertTitle, strings.pkFertBody),
          _Feature(Icons.pets_rounded, const Color(0xFF6A1B9A),
              strings.pkCattleTitle, strings.pkCattleBody),
          _Feature(Icons.wb_sunny_rounded, const Color(0xFFE65100),
              strings.pkWeatherTitle, strings.pkWeatherBody),
          _Feature(Icons.trending_up_rounded, const Color(0xFF00695C),
              strings.pkMandiTitle, strings.pkMandiBody),
          _Feature(Icons.account_balance_rounded, const Color(0xFFAD1457),
              strings.pkSchemeTitle, strings.pkSchemeBody),
          _Feature(Icons.my_location_rounded, const Color(0xFF4527A0),
              strings.pkGpsTitle, strings.pkGpsBody),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F5),
          appBar: AppBar(title: Text(strings.pkName)),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Hero(strings: strings),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    strings.pkWhatItDoes,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...features.map((f) => _FeatureCard(feature: f)),
                const SizedBox(height: 4),
                _NoteCard(
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF2E7D32),
                  text: strings.pkDataNote,
                ),
                _NoteCard(
                  icon: Icons.wifi_off_rounded,
                  color: const Color(0xFF1565C0),
                  text: strings.pkInternetNote,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Button नीचे चिपका रहता है — scroll करते-करते भी हाथ के पास।
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                icon: const Icon(Icons.download_rounded),
                label: Text(
                  strings.pkInstallNow,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _openPlayStore(context, strings),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(26),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/pro_kisan.png',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            strings.pkName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.pkTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.94),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Pill(icon: Icons.card_giftcard_rounded, text: strings.pkFree),
              _Pill(icon: Icons.translate_rounded, text: strings.pkTenLanguages),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.color, this.title, this.body);

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.body,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
