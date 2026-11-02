import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/widgets/common.dart';
import '../vendor/vendor_profile_screen.dart';
import '../vendor/widgets/partner_brand.dart';
import 'package:nischint_core/screens/common/widgets/info_row.dart';

/// सेटिंग (वेंडर ऐप): फ़र्म की जानकारी, सारा डेटा मिटाना, ऐप के बारे में।
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _editFirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VendorProfileScreen()),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('सारा डेटा मिटाएँ?'),
        content: const Text(
          'इस फ़ोन में सेव सारी शिकायतें और आपकी फ़र्म की जानकारी हमेशा के लिए मिट जाएगी। '
          'यह वापस नहीं आएगी।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('रहने दें'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('हाँ, मिटाएँ'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    if (!context.mounted) return;
    final app = AppScope.read(context);
    await app.clearAll();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final vendor = AppScope.of(context).vendor;
    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.xl),
        children: [
          const SectionHeader('फ़र्म की जानकारी'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'फ़र्म का नाम', value: vendor.firmName, icon: Icons.business),
                InfoRow(label: 'संपर्क व्यक्ति', value: vendor.contactPerson, icon: Icons.person_outline),
                InfoRow(label: 'मोबाइल', value: vendor.mobile, icon: Icons.phone_outlined),
                const SizedBox(height: AppSpace.m),
                AppButton(
                  label: 'फ़र्म की जानकारी बदलें',
                  icon: Icons.edit_outlined,
                  outlined: true,
                  onPressed: () => _editFirm(context),
                ),
              ],
            ),
          ),

          const SectionHeader('डेटा'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'इस फ़ोन में सेव सारी शिकायतें और फ़र्म की जानकारी मिट जाएगी, और ऐप नए जैसा हो जाएगा।',
                  style: AppText.muted,
                ),
                const SizedBox(height: AppSpace.m),
                AppButton(
                  label: 'सारा डेटा मिटाएँ',
                  icon: Icons.delete_outline,
                  outlined: true,
                  color: AppColors.danger,
                  onPressed: () => _confirmClear(context),
                ),
              ],
            ),
          ),

          const SectionHeader('ऐप के बारे में'),
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpace.m),
                  decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
                  child: const Icon(Icons.solar_power, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppSpace.l),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(partnerAppName, style: AppText.h2),
                      SizedBox(height: AppSpace.xs),
                      Text(AppConfig.vendorLine, style: AppText.muted),
                      SizedBox(height: AppSpace.xs),
                      Text('वर्ज़न ${AppConfig.version}', style: AppText.small),
                    ],
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
