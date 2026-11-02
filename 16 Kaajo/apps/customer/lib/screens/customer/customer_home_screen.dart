import 'package:flutter/material.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/catalog.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/service_item.dart';
import 'package:kaajo_core/services/contact_service.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../common/settings_screen.dart';
import 'service_detail_screen.dart';
import 'widgets/customer_bits.dart';

/// होम टैब: नमस्ते, सफ़ाई का बड़ा कार्ड, भरोसे की पट्टी, सेवाएँ, जल्द आने वाली सेवाएँ और सुझाव।
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  static void _openService(BuildContext context, ServiceItem service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ServiceDetailScreen(service: service)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AppScope.of(context).customer.name.trim();
    return Scaffold(
      appBar: AppBar(
        title: const KaajoBrand(),
        actions: [
          IconButton(
            tooltip: 'सेटिंग',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.l, AppSpace.xl),
        children: [
          Text(name.isEmpty ? 'नमस्ते' : 'नमस्ते, $name जी', style: AppText.h2),
          const SizedBox(height: AppSpace.xs),
          const Row(children: [
            Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
            SizedBox(width: AppSpace.xs),
            Expanded(child: Text(AppConfig.serviceArea, style: AppText.muted)),
          ]),
          const SizedBox(height: AppSpace.l),
          _HeroCard(onBook: () => _openService(context, Catalog.solarCleaning)),
          const SizedBox(height: AppSpace.l),
          const AppCard(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.s, vertical: AppSpace.l),
            child: TrustStrip(),
          ),
          const SectionHeader('अभी बुक करें'),
          for (var i = 0; i < Catalog.active.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.m),
            _ServiceCard(
              service: Catalog.active[i],
              onTap: () => _openService(context, Catalog.active[i]),
            ),
          ],
          const SectionHeader('आगे आपकी हर ज़रूरत के लिए'),
          const _ComingSoonGrid(services: Catalog.comingSoon),
          const SizedBox(height: AppSpace.xl),
          const InfoBanner(
            title: 'सफ़ाई का फ़ायदा',
            text: 'गंदे पैनल 15–25% तक कम बिजली बनाते हैं, हर 2–3 महीने में सफ़ाई कराएँ।',
            icon: Icons.lightbulb_outline,
            tone: ChipTone.success,
          ),
        ],
      ),
    );
  }
}

/// सबसे ऊपर का धूप वाला बड़ा कार्ड: "सोलर पैनल की सफ़ाई ₹600 से"।
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    const service = Catalog.solarCleaning;
    return Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSpace.radius),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppConfig.tagline,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBrand,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      service.priceLabel,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sun,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.m),
              const IconBubble(
                Icons.bolt_rounded,
                size: 52,
                color: AppColors.sun,
                background: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s),
          Text('सोलर पैनल की सफ़ाई · ${service.shortLine}',
            style: AppText.body.copyWith(color: AppColors.onBrandMuted)),
          const SizedBox(height: AppSpace.s),
          const Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: AppColors.sun),
              SizedBox(width: AppSpace.xs),
              Expanded(
                child: Text('पैसा काम के बाद · समय कॉल पर पक्का होगा',
                  style: TextStyle(color: AppColors.onBrandMuted, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.l),
          AppButton(label: 'सोलर सफ़ाई बुक करें', icon: Icons.arrow_forward, onPressed: onBook),
        ],
      ),
    );
  }
}

/// चालू सेवा का कार्ड: आइकन, नाम, एक लाइन और रेट।
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final ServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBubble(service.icon, size: 52),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: AppText.h3),
                const SizedBox(height: 2),
                Text(service.shortLine, style: AppText.muted),
                const SizedBox(height: AppSpace.s),
                Text(service.priceLabel, style: AppText.price),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// "जल्द आ रहा है" की 2 कॉलम वाली जाली। हर पंक्ति के दोनों कार्ड बराबर ऊँचे।
class _ComingSoonGrid extends StatelessWidget {
  const _ComingSoonGrid({required this.services});

  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < services.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: AppSpace.m));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ComingSoonCard(service: services[i])),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: i + 1 < services.length
                    ? _ComingSoonCard(service: services[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// जल्द आने वाली सेवा का हल्का (muted) कार्ड।
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSpace.m),
      onTap: () => _showComingSoon(context, service),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBubble(
                service.icon,
                size: 40,
                color: AppColors.textMuted,
                background: AppColors.primaryDark,
              ),
              const StatusChip('जल्द', tone: ChipTone.warning),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(service.shortLine, style: AppText.small),
        ],
      ),
    );
  }
}

/// जल्द आने वाली सेवा पर टैप: नीचे से पट्टी, "मुझे बताना" से WhatsApp पर रुचि का मैसेज।
Future<void> _showComingSoon(BuildContext context, ServiceItem service) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBubble(
                service.icon,
                size: 72,
                color: AppColors.sun,
                background: AppColors.sunSoft,
              ),
              const SizedBox(height: AppSpace.l),
              Text(service.title, style: AppText.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.s),
              const Text('यह सेवा जल्द शुरू होगी', style: AppText.h3, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.xs),
              const Text(
                '"मुझे बताना" दबाएँ। सेवा शुरू होते ही हम आपको WhatsApp पर बता देंगे।',
                style: AppText.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.xl),
              AppButton(
                label: 'मुझे बताना',
                icon: Icons.notifications_active_outlined,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final opened =
                      await ContactService.whatsApp(ContactService.interestMessage(service.title));
                  if (!context.mounted) return;
                  if (!opened) showMessage(context, whatsAppFailedMessage);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
