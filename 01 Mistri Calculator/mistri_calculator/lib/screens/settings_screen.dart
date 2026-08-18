import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import 'guide_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  const SettingsScreen({super.key, required this.storage});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _lang;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _lang = widget.storage.language;
    _unit = widget.storage.defaultUnit;
  }  static const Map<String, String> _languages = {
    'hi': 'हिन्दी (Hindi)',
    'en': 'English',
    'bho': 'भोजपुरी (Bhojpuri)',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
  };

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  AppStrings.get('language'),
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _languages.entries.map((entry) {
                      final code = entry.key;
                      final name = entry.value;
                      final isSelected = _lang == code;
                      return ListTile(
                        leading: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : const Icon(Icons.circle_outlined, color: AppColors.textHint),
                        title: Text(
                          name,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await widget.storage.setLanguage(code);
                          AppStrings.setLanguage(code);
                          setState(() => _lang = code);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          _SettingsAction(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFFE65100),
            title: '${AppStrings.get('language')}: ${_languages[_lang] ?? _lang}',
            onTap: _showLanguagePicker,
          ),
          const SizedBox(height: 12),

          // Default unit
          _SettingsTile(
            icon: Icons.straighten_rounded,
            iconColor: const Color(0xFF4527A0),
            title: AppStrings.get('defaultUnit'),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'ft',
                  label: Text(AppStrings.get('feet')),
                ),
                ButtonSegment(
                  value: 'm',
                  label: Text(AppStrings.get('meter')),
                ),
              ],
              selected: {_unit},
              onSelectionChanged: (v) async {
                final newUnit = v.first;
                await widget.storage.setDefaultUnit(newUnit);
                setState(() => _unit = newUnit);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Construction Guide
          _SettingsAction(
            icon: Icons.book_outlined,
            iconColor: const Color(0xFFE65100),
            title: AppStrings.get('constructionGuide'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuideScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Share app
          _SettingsAction(
            icon: Icons.share_outlined,
            iconColor: const Color(0xFF00695C),
            title: AppStrings.get('shareApp'),
            onTap: () {
              Share.share(
                AppStrings.currentLang == 'hi'
                      ? 'मिस्त्री कैलकुलेटर — घर बनाने का पूरा हिसाब, बिल्कुल फ्री! 📐🧱\n\nडाउनलोड करें: https://play.google.com/store/apps/details?id=com.mistricalculator.mistri_calculator'
                      : 'Mistri Calculator — Complete construction estimate, totally free! 📐🧱\n\nDownload: https://play.google.com/store/apps/details?id=com.mistricalculator.mistri_calculator',
              );
            },
          ),
          const SizedBox(height: 12),

          // Privacy Policy
          _SettingsAction(
            icon: Icons.privacy_tip_outlined,
            iconColor: const Color(0xFF0277BD),
            title: AppStrings.get('privacyPolicy'),
            onTap: () async {
              final uri = Uri.parse('https://tubealgo.github.io/mistri-calculator-privacy-policy/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 12),

          // More Apps
          _SettingsAction(
            icon: Icons.apps_rounded,
            iconColor: const Color(0xFFC62828),
            title: AppStrings.get('moreApps'),
            onTap: () async {
              final uri = Uri.parse('https://play.google.com/store/apps/developer?id=Tube+algo');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),

          // Version
          Center(
            child: Text(
              '${AppStrings.get('version')}: 1.0.0',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Made with ❤️ in India 🇮🇳',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: trailing),
        ],
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _SettingsAction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
