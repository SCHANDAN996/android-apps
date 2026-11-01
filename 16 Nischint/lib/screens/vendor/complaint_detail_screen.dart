import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../content/catalog.dart';
import '../../models/complaint.dart';
import '../../services/contact_service.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/pickers.dart';
import '../common/widgets/info_row.dart';
import 'widgets/complaint_bits.dart';

/// एक शिकायत का पूरा विवरण, पोर्टल की गिनती और स्थिति बदलना।
class ComplaintDetailScreen extends StatelessWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final String complaintId;

  Future<void> _changeStatus(BuildContext context, VendorComplaint c, String label) async {
    ComplaintStatus? next;
    for (final s in ComplaintStatus.values) {
      if (s.label == label) next = s;
    }
    if (next == null || next == c.status) return;
    final status = next;
    await AppScope.read(context).updateComplaintStatus(c.id, status);
    if (!context.mounted) return;
    showMessage(
      context,
      status == ComplaintStatus.resolved
          ? 'बढ़िया! शिकायत निपट गई। पोर्टल पर भी इसे बंद करना न भूलें।'
          : 'स्थिति बदली: ${status.label}',
    );
  }

  Future<void> _askOnWhatsApp(BuildContext context, VendorComplaint c) async {
    final opened = await ContactService.whatsApp(ContactService.followUpMessage(c.id));
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  Future<void> _resend(BuildContext context, VendorComplaint c) async {
    final vendor = AppScope.read(context).vendor;
    final opened = await ContactService.whatsApp(ContactService.complaintMessage(c, vendor));
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  Future<void> _callCustomer(BuildContext context, VendorComplaint c) async {
    final opened = await ContactService.call(c.customerMobile);
    if (!context.mounted) return;
    if (!opened) showMessage(context, 'कॉल नहीं लग पाया। ग्राहक का नंबर: ${c.customerMobile}');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final matches = app.complaints.where((x) => x.id == complaintId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('शिकायत')),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off,
            title: 'शिकायत नहीं मिली',
            message: 'हो सकता है यह शिकायत फ़ोन से मिटा दी गई हो।',
          ),
        ),
      );
    }
    final c = matches.first;

    return Scaffold(
      appBar: AppBar(title: const Text('शिकायत की जानकारी')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.customerName, style: AppText.h1),
                    const SizedBox(height: AppSpace.xs),
                    Text('शिकायत नंबर: ${c.id}', style: AppText.muted),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: StatusChip(c.status.label, tone: complaintStatusTone(c.status)),
              ),
            ],
          ),
          if (c.urgent) ...[
            const SizedBox(height: AppSpace.s),
            const Align(alignment: Alignment.centerLeft, child: UrgentBadge()),
          ],
          const SizedBox(height: AppSpace.l),
          _PortalCountBox(complaint: c),

          const SectionHeader('स्थिति बदलें'),
          OptionChips(
            options: [for (final s in ComplaintStatus.values) s.label],
            selected: c.status.label,
            onChanged: (label) => _changeStatus(context, c, label),
          ),
          const SizedBox(height: AppSpace.s),
          const Text(
            'विज़िट का दिन तय हो जाए तो "विज़िट तय", काम पूरा हो जाए तो "निपट गई" चुनें।',
            style: AppText.small,
          ),

          const SectionHeader('पूरा विवरण'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'ग्राहक का नाम', value: c.customerName, icon: Icons.person_outline),
                InfoRow(label: 'ग्राहक का मोबाइल', value: c.customerMobile, icon: Icons.phone_outlined),
                InfoRow(label: 'पता', value: c.address, icon: Icons.home_outlined),
                InfoRow(label: 'इलाका', value: c.area, icon: Icons.location_on_outlined),
                InfoRow(label: 'सिस्टम', value: Catalog.kwLabel(c.systemKw), icon: Icons.solar_power),
                InfoRow(label: 'दिक्कत', value: c.problem, icon: Icons.build),
                InfoRow(
                  label: 'शिकायत की तारीख',
                  value: hindiDateYear(c.complaintDate),
                  icon: Icons.calendar_today,
                ),
                if (c.portalComplaintId.isNotEmpty)
                  InfoRow(
                    label: 'पोर्टल शिकायत नंबर',
                    value: c.portalComplaintId,
                    icon: Icons.receipt_long_outlined,
                  ),
                InfoRow(
                  label: 'जल्दी चाहिए?',
                  value: c.urgent ? 'हाँ, 48 घंटे में विज़िट' : 'नहीं',
                  icon: Icons.bolt,
                ),
                if (c.note.isNotEmpty) InfoRow(label: 'नोट', value: c.note, icon: Icons.notes),
                InfoRow(
                  label: 'हमें भेजी गई',
                  value: hindiDateYear(c.createdAt),
                  icon: Icons.send,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.l),
          AppButton(
            label: 'ग्राहक को कॉल करें',
            icon: Icons.call,
            outlined: true,
            onPressed: () => _callCustomer(context, c),
          ),
          const SizedBox(height: AppSpace.m),
          AppButton(
            label: 'दोबारा भेजें',
            icon: Icons.replay,
            outlined: true,
            onPressed: () => _resend(context, c),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: 'WhatsApp पर पूछें',
          icon: Icons.chat,
          onPressed: () => _askOnWhatsApp(context, c),
        ),
      ),
    );
  }
}

/// "पोर्टल की गिनती: X दिन बीते" वाला बड़ा डिब्बा।
class _PortalCountBox extends StatelessWidget {
  const _PortalCountBox({required this.complaint});

  final VendorComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    final rawDays = c.daysSinceComplaint();
    final days = rawDays < 0 ? 0 : rawDays;
    final left = portalReminderDays - days;
    final (Color bg, Color fg) = toneColors(portalDaysTone(c));

    final String message;
    if (c.status == ComplaintStatus.resolved) {
      message = 'शिकायत निपट गई। पोर्टल पर भी इसे बंद करना न भूलें।';
    } else if (days >= portalReminderDays) {
      message = '8 दिन पूरे हो गए। अब पोर्टल से रिमाइंडर और फिर नोटिस आ सकता है, '
          'उसके बाद ID Deactivation का ख़तरा है। आज ही हमें WhatsApp पर याद दिलाएँ।';
    } else if (days >= portalWarningDays) {
      message = 'सिर्फ़ $left दिन बचे हैं। करीब 8 दिन के बाद पोर्टल रिमाइंडर भेजता है, '
          'फिर ID Deactivation का ख़तरा होता है।';
    } else {
      message = 'करीब 8 दिन के बाद पोर्टल रिमाइंडर भेजता है, फिर ID Deactivation का ख़तरा होता है। '
          'अभी $left दिन बचे हैं।';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        border: Border.all(color: fg, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const Text('दिन', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'पोर्टल की गिनती: $days ${days == 1 ? 'दिन बीता' : 'दिन बीते'}',
                  style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w700, height: 1.35),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(message, style: TextStyle(color: fg, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
