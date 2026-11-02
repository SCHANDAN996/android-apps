import 'package:flutter/material.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/catalog.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/complaint.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';
import '../common/settings_screen.dart';
import 'complaint_detail_screen.dart';
import 'complaint_form_screen.dart';
import 'widgets/complaint_bits.dart';
import 'widgets/partner_brand.dart';

/// वेंडर का पहला टैब: चेतावनी, गिनती और शिकायतों की सूची।
class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  void _openNewComplaint(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ComplaintFormScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final firmName = app.vendor.firmName.trim();
    final complaints = app.complaints;

    // खुली शिकायतें ऊपर, निपटी हुई नीचे (दोनों में नई पहले)।
    final ordered = <VendorComplaint>[
      ...complaints.where((c) => c.status != ComplaintStatus.resolved),
      ...complaints.where((c) => c.status == ComplaintStatus.resolved),
    ];
    final overdue = complaints
        .where((c) => c.status != ComplaintStatus.resolved && c.daysSinceComplaint() >= portalReminderDays)
        .length;

    var warningText = 'ग्राहक की शिकायत समय पर न निपटे तो पोर्टल ID एक महीने के लिए बंद हो सकती है। '
        'उस दौरान नए ग्राहक बंद रहते हैं।';
    if (overdue == 1) {
      warningText += '\n\nअभी 1 शिकायत 8 दिन से पुरानी है, उसे आज ही निपटवाएँ।';
    } else if (overdue > 1) {
      warningText += '\n\nअभी $overdue शिकायतें 8 दिन से पुरानी हैं, इन्हें आज ही निपटवाएँ।';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          firmName.isEmpty ? partnerAppName : firmName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'सेटिंग',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          InfoBanner(
            tone: overdue > 0 ? ChipTone.danger : ChipTone.warning,
            icon: Icons.warning_amber_rounded,
            title: 'ध्यान दें: ID Deactivation का ख़तरा',
            text: warningText,
          ),
          const SizedBox(height: AppSpace.m),
          const _PromiseCard(),
          const SizedBox(height: AppSpace.l),
          Row(
            children: [
              Expanded(
                child: _CountTile(
                  label: 'कुल',
                  count: complaints.length,
                  background: AppColors.primarySoft,
                  foreground: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: _CountTile(
                  label: 'खुली',
                  count: app.openComplaints,
                  background: AppColors.warningSoft,
                  foreground: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: _CountTile(
                  label: 'निपटी',
                  count: app.resolvedComplaints,
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                ),
              ),
            ],
          ),
          const SectionHeader('शिकायतें'),
          if (ordered.isEmpty)
            const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'अभी कोई शिकायत नहीं',
              message: 'ग्राहक की शिकायत आए तो नीचे "नई शिकायत" दबाएँ। '
                  'हम आपके नाम से विज़िट करेंगे, फ़ोटो सबूत के साथ।',
            )
          else
            for (final c in ordered)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.m),
                child: _ComplaintCard(complaint: c),
              ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: 'नई शिकायत',
          icon: Icons.add,
          onPressed: () => _openNewComplaint(context),
        ),
      ),
    );
  }
}

/// टील कार्ड: "आप पैनल लगाइए, मेंटेनेंस हम संभाल लेंगे।"
class _PromiseCard extends StatelessWidget {
  const _PromiseCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primary,
      borderColor: AppColors.primary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
            child: const Icon(Icons.solar_power, color: Colors.white),
          ),
          const SizedBox(width: AppSpace.m),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.vendorLine,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.35),
                ),
                SizedBox(height: AppSpace.xs),
                Text(
                  'शिकायत भेजिए, हम आपके नाम से ग्राहक के घर जाएँगे और फ़ोटो सबूत देंगे।',
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// गिनती का छोटा डिब्बा।
class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.count,
    required this.background,
    required this.foreground,
  });

  final String label;
  final int count;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.m, horizontal: AppSpace.s),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSpace.radius)),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: foreground, height: 1.2),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: foreground),
          ),
        ],
      ),
    );
  }
}

/// सूची में एक शिकायत।
class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint});

  final VendorComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    final resolved = c.status == ComplaintStatus.resolved;
    final days = c.daysSinceComplaint();

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ComplaintDetailScreen(complaintId: c.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(c.customerName, style: AppText.h3)),
              const SizedBox(width: AppSpace.s),
              StatusChip(c.status.label, tone: complaintStatusTone(c.status)),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text('${c.area} · ${Catalog.kwLabel(c.systemKw)}', style: AppText.muted),
          const SizedBox(height: AppSpace.xs),
          Text(c.problem, style: AppText.body),
          const SizedBox(height: AppSpace.m),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpace.s,
                  runSpacing: AppSpace.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (resolved)
                      Text('शिकायत: ${hindiDate(c.complaintDate)}', style: AppText.small)
                    else
                      StatusChip(daysPassedLabel(days), tone: portalDaysTone(c)),
                    if (c.urgent && !resolved) const UrgentBadge(),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
