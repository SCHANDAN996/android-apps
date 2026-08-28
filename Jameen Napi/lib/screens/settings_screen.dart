import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_language.dart';
import '../widgets/privacy_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, currentLang, _) {
        final strings = AppStrings(currentLang);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.settingsTitle),
          ),
          body: SafeArea(
            top: false,
            bottom: true,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              strings.selectLanguage,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        RadioGroup<AppLang>(
                          groupValue: currentLang,
                          onChanged: (AppLang? val) {
                            if (val != null) {
                              LanguageNotifier.instance.setLanguage(val);
                            }
                          },
                          child: Column(
                            children: AppLang.values.map((lang) {
                              final displayName = AppStrings.languageNames[lang] ?? lang.name;
                              final isSelected = lang == currentLang;

                              return RadioListTile<AppLang>(
                                title: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.colorScheme.primary : null,
                                  ),
                                ),
                                value: lang,
                                contentPadding: EdgeInsets.zero,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              strings.aboutApp,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${strings.appTitle} v1.1.0',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.appSubtitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.share, color: Color(0xFF2E7D32)),
                          title: Text(strings.shareAppTitle),
                          subtitle: Text(strings.shareAppSubtitle),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            Share.share(
                              '🌾 जमीन नापी ऐप — बीघा, कट्ठा, धूर, एकड़, 4-भुजा विषमबाहु खेत नापी और लग्गी पैमाना कैलकुलेटर। 100% फ्री व बिना इंटरनेट के। अभी डाउनलोड करें: https://play.google.com/store/apps/details?id=com.chandansingh.kisan_calculator',
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF2E7D32)),
                          title: Text(strings.privacyPolicy),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => showAppPrivacyPolicy(context, strings),
                        ),
                      ],
                    ),
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
