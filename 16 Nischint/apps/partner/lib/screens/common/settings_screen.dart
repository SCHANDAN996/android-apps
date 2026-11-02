import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/app_state.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/profiles.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';
import '../technician/technician_signup_screen.dart';
import '../vendor/vendor_profile_screen.dart';
import '../vendor/widgets/partner_brand.dart';
import 'package:nischint_core/screens/common/widgets/info_row.dart';

/// सेटिंग (पार्टनर ऐप): वेंडर हो तो फ़र्म की जानकारी, टेक्नीशियन हो तो उसकी जानकारी और
/// ट्रेनिंग; फिर सारा डेटा मिटाना और ऐप के बारे में।
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _editFirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VendorProfileScreen()),
    );
  }

  void _editTechnician(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TechnicianSignupScreen()),
    );
  }

  Future<void> _confirmResetTraining(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ट्रेनिंग दोबारा शुरू करें?'),
        content: const Text(
          'पढ़े हुए पाठ, क्विज़ के स्कोर, फ़ील्ड ट्रायल और सर्टिफ़िकेट — सब मिट जाएगा और ट्रेनिंग '
          'दिन 1 से शुरू होगी। आपकी जानकारी (नाम, मोबाइल) बनी रहेगी।',
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
            child: const Text('हाँ, दोबारा शुरू करें'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    if (!context.mounted) return;
    final app = AppScope.read(context);
    await app.resetTraining();
    if (!context.mounted) return;
    showMessage(context, 'ट्रेनिंग दोबारा शुरू हो गई');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _confirmClear(BuildContext context, AppRole? role) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('सारा डेटा मिटाएँ?'),
        content: Text(
          role == AppRole.technician
              ? 'इस फ़ोन में सेव आपकी जानकारी और पूरी ट्रेनिंग (स्कोर, सर्टिफ़िकेट) हमेशा के लिए मिट जाएगी। '
                  'यह वापस नहीं आएगी।'
              : 'इस फ़ोन में सेव सारी शिकायतें और आपकी फ़र्म की जानकारी हमेशा के लिए मिट जाएगी। '
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
    final app = AppScope.of(context);
    final role = app.role;
    final isTechnician = role == AppRole.technician;

    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.xl),
        children: [
          if (isTechnician) ..._technicianSection(context, app) else ..._vendorSection(context, app),

          const SectionHeader('डेटा'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTechnician
                      ? 'इस फ़ोन में सेव आपकी जानकारी और पूरी ट्रेनिंग मिट जाएगी, और ऐप नए जैसा हो जाएगा।'
                      : 'इस फ़ोन में सेव सारी शिकायतें और फ़र्म की जानकारी मिट जाएगी, और ऐप नए जैसा हो जाएगा।',
                  style: AppText.muted,
                ),
                const SizedBox(height: AppSpace.m),
                AppButton(
                  label: 'सारा डेटा मिटाएँ',
                  icon: Icons.delete_outline,
                  outlined: true,
                  color: AppColors.danger,
                  onPressed: () => _confirmClear(context, role),
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

  /// वेंडर: फ़र्म की जानकारी (पहले जैसा)।
  List<Widget> _vendorSection(BuildContext context, AppState app) {
    final vendor = app.vendor;
    return [
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
    ];
  }

  /// टेक्नीशियन: उसकी जानकारी और ट्रेनिंग।
  List<Widget> _technicianSection(BuildContext context, AppState app) {
    final t = app.technician;
    final p = app.training;
    final certifiedAt = p.certifiedAt;
    final joinedAt = t.joinedAt;
    return [
      const SectionHeader('मेरी जानकारी'),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: 'नाम', value: t.name, icon: Icons.person_outline),
            InfoRow(label: 'मोबाइल', value: t.mobile, icon: Icons.phone_outlined),
            InfoRow(label: 'इलाका', value: t.area, icon: Icons.location_on_outlined),
            InfoRow(label: 'योग्यता', value: t.qualification, icon: Icons.school_outlined),
            InfoRow(label: 'स्कूटी', value: t.hasScooty ? 'है' : 'नहीं', icon: Icons.two_wheeler),
            if (joinedAt != null)
              InfoRow(label: 'अकाउंट बना', value: hindiDateYear(joinedAt), icon: Icons.event_outlined),
            const SizedBox(height: AppSpace.m),
            AppButton(
              label: 'जानकारी बदलें',
              icon: Icons.edit_outlined,
              outlined: true,
              onPressed: () => _editTechnician(context),
            ),
          ],
        ),
      ),
      const SectionHeader('ट्रेनिंग'),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
              label: 'स्थिति',
              value: certifiedAt != null
                  ? 'प्रशिक्षित टेक्नीशियन (${hindiDateYear(certifiedAt)})'
                  : 'ट्रेनिंग चल रही है',
              icon: certifiedAt != null ? Icons.workspace_premium : Icons.school_outlined,
            ),
            const SizedBox(height: AppSpace.s),
            const Text(
              'ट्रेनिंग दोबारा शुरू करने पर पढ़े हुए पाठ, स्कोर और सर्टिफ़िकेट मिट जाएँगे।',
              style: AppText.muted,
            ),
            const SizedBox(height: AppSpace.m),
            AppButton(
              label: 'ट्रेनिंग दोबारा शुरू करें',
              icon: Icons.refresh,
              outlined: true,
              color: AppColors.warning,
              onPressed: () => _confirmResetTraining(context),
            ),
          ],
        ),
      ),
    ];
  }
}
