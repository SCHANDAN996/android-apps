import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'theme/dairy_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/link_service.dart';
// ignore_for_file: deprecated_member_use

/// ---------------------------------------------------------------------------
///  About Us — App Info + Developer Details
/// ---------------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// ऐप का संपर्क ईमेल — एक ही जगह रखा है ताकि बदलना हो तो यहीं बदले।
  static const String kContactEmail = 'all.chandansingh@gmail.com';

  /// Privacy policy का असली URL। खाली रहेगा तो About में वह पंक्ति दिखेगी ही
  /// नहीं (टूटा लिंक दिखाने से बेहतर है न दिखाना)।
  /// Play Store अपलोड से पहले यहाँ असली लिंक डालना अनिवार्य है।
  static const String kPrivacyPolicyUrl =
      'https://prokishan.blogspot.com/2026/07/pro-kishan.html';

  Future<void> _launchUrl(BuildContext context, String url) =>
      LinkService.openUrl(context, url);

  Future<void> _sendEmail(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    return LinkService.sendEmail(
      context,
      to: kContactEmail,
      subject: isHi ? 'प्रो किसान ऐप — सुझाव' : 'Pro Kisan App — Suggestion',
    );
  }

  @override
  Widget build(BuildContext context) {
    String t(String k) => AppLocalizations.get(context, k);
    final isHi = AppLocalizations.isHindiLike(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('moreAbout')),
        backgroundColor: DairyTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── असली app logo (generic icon नहीं) ──
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: DairyTheme.primaryTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.agriculture_rounded,
                    size: 50,
                    color: DairyTheme.primaryTeal),
              ),
            ),
            const SizedBox(height: 16),
            Text(t('appName'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DairyTheme.textDark)),
            const SizedBox(height: 4),
            Text(t('aboutVersion'), style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: DairyTheme.primaryTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t('aboutTagline'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DairyTheme.primaryTeal)),
            ),

            const SizedBox(height: 28),

            // ── App Description ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: DairyTheme.primaryTeal, size: 20),
                        const SizedBox(width: 8),
                        Text(t('aboutHeading'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t('aboutDesc'),
                      style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 🛡️ आपकी जानकारी कहाँ रहती है ──
            //
            // Google Drive वाला backup जुड़ने के बाद यह बताना ज़रूरी हो गया।
            // पहले ऐप सिर्फ़ फ़ोन में रहता था; अब (किसान की मर्ज़ी से) एक नक़ल
            // उसकी अपनी Drive में जाती है। किसान को यह साफ़ पता होना चाहिए —
            // और Play Store की नीति भी यही माँगती है।
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.blue.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('aboutDataTitle'),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('aboutDataBody'),
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Developer Info ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.developer_mode_rounded, color: Colors.deepPurple, size: 20),
                        const SizedBox(width: 8),
                        Text(t('aboutDeveloper'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Developer Name
                    ListTile(
                       contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, color: Colors.deepPurple.shade400),
                      ),
                      title: Text(t('aboutDevName'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(t('aboutDevRole'), style: const TextStyle(fontSize: 12)),
                    ),
                    const Divider(),

                    // Email
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.email_rounded, color: Colors.blue.shade400),
                      ),
                      title: const Text(kContactEmail, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(t('aboutEmailSub'), style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 16),
                      onTap: () => _sendEmail(context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Action Buttons ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star_rounded, color: Colors.amber),
                    title: Text(t('aboutRate'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t('aboutRateSub'), style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.share_rounded, color: Colors.green),
                    title: Text(t('aboutShare'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t('aboutShareSub'), style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      final shareMsg = isHi
                          ? '🌾 *प्रो किसान ऐप* डाउनलोड करें!\n\n'
                              '✅ दूध का हिसाब\n'
                              '✅ खाद कैलकुलेटर\n'
                              '✅ मौसम, समाचार, मंडी भाव\n'
                              '✅ सरकारी योजनाएं\n\n'
                              '📲 डाउनलोड करें: https://play.google.com/store/apps/details?id=com.prokisan.app'
                          : '🌾 Download *Pro Kisan App*!\n\n'
                              '✅ Milk Ledger\n'
                              '✅ Fertilizer Calculator\n'
                              '✅ Weather, News, Mandi Rates\n'
                              '✅ Govt Schemes\n\n'
                              '📲 Download: https://play.google.com/store/apps/details?id=com.prokisan.app';
                      Share.share(shareMsg);
                    },
                  ),
                  // Privacy policy — तभी दिखाओ जब असली URL भर दिया गया हो।
                  // ⚠️ Play Store पर अपलोड से पहले नीचे kPrivacyPolicyUrl में
                  // अपना असली लिंक डालना ज़रूरी है (Console भी यही माँगेगा)।
                  if (kPrivacyPolicyUrl.isNotEmpty) ...[
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_rounded, color: Colors.teal),
                      title: const Text('Privacy Policy',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _launchUrl(context, kPrivacyPolicyUrl),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ──
            Text(t('appFooter'), style: TextStyle(fontSize: 11, color: Colors.grey.shade400), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('© 2026 ${t('aboutDevName')}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}
