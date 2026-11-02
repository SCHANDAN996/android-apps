import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/profiles.dart';
import 'package:nischint_core/widgets/common.dart';

/// पहली स्क्रीन: आप वेंडर हैं या निश्चिंत टीम के टेक्नीशियन।
/// भूमिका चुनते ही RootGate अपने-आप अगली स्क्रीन दिखा देता है।
class PartnerRoleScreen extends StatelessWidget {
  const PartnerRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.xl),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(AppSpace.m),
                decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
                child: const Icon(Icons.solar_power, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpace.l),
            const Text('नमस्ते! ${AppConfig.partnerAppName} में स्वागत है', style: AppText.h1),
            const SizedBox(height: AppSpace.s),
            const Text(
              AppConfig.vendorLine,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.35),
            ),
            const SizedBox(height: AppSpace.xl),
            const Text('आप कौन हैं?', style: AppText.h2),
            const SizedBox(height: AppSpace.xs),
            const Text('नीचे अपनी भूमिका चुनें।', style: AppText.muted),
            const SizedBox(height: AppSpace.l),
            _RoleCard(
              icon: Icons.storefront,
              iconBackground: AppColors.sun,
              title: 'मैं सोलर वेंडर हूँ',
              line: 'अपने ग्राहक की शिकायत भेजें — विज़िट हम आपके नाम से करेंगे, फ़ोटो सबूत के साथ।',
              onTap: () => AppScope.read(context).setRole(AppRole.vendor),
            ),
            const SizedBox(height: AppSpace.m),
            _RoleCard(
              icon: Icons.engineering,
              iconBackground: AppColors.primary,
              title: 'मैं टेक्नीशियन हूँ (निश्चिंत टीम)',
              line: 'इसी ऐप में 6 दिन की ट्रेनिंग, क्विज़ और सर्टिफ़िकेट — फिर काम और कमाई।',
              onTap: () => AppScope.read(context).setRole(AppRole.technician),
            ),
            const SizedBox(height: AppSpace.xl),
            const InfoBanner(
              icon: Icons.lock_outline,
              text: 'अभी आपकी जानकारी सिर्फ़ इसी फ़ोन में रहती है। मोबाइल OTP से लॉगिन अगले वर्ज़न में आएगा।',
            ),
          ],
        ),
      ),
    );
  }
}

/// भूमिका चुनने का बड़ा कार्ड।
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.line,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpace.l),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.m),
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(width: AppSpace.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h2),
                const SizedBox(height: AppSpace.xs),
                Text(line, style: AppText.muted),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 28),
        ],
      ),
    );
  }
}
