import 'package:flutter/material.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/models/service_item.dart';
import 'package:nischint_core/widgets/common.dart';

import 'booking_form_screen.dart';
import 'widgets/customer_bits.dart';

/// सेवा की जानकारी: रेट, समय, क्या-क्या शामिल है, सवाल-जवाब, और नीचे "बुक करें"।
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final ServiceItem service;

  void _book(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookingFormScreen(service: service)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सेवा की जानकारी')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          _ServiceHeader(service: service),
          if (service.includes.isNotEmpty) ...[
            const SectionHeader('क्या-क्या शामिल है'),
            AppCard(
              child: Column(
                children: [for (final item in service.includes) _IncludeLine(item)],
              ),
            ),
          ],
          if (service.faqs.isNotEmpty) ...[
            const SectionHeader('अक्सर पूछे सवाल'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < service.faqs.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.l),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(service.faqs[i].question, style: AppText.h3),
                      children: [Text(service.faqs[i].answer, style: AppText.body)],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          const InfoBanner(
            title: 'पैसा काम के बाद',
            text: 'पहले कोई पैसा नहीं। काम पूरा होने के बाद UPI या नकद दें। '
                'रेट पहले से तय है, कोई छिपा खर्च नहीं।',
            icon: Icons.verified_outlined,
            tone: ChipTone.success,
          ),
        ],
      ),
      bottomNavigationBar: service.available
          ? BottomActionBar(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.priceLabel, style: AppText.price),
                      const Text('पैसा काम के बाद', style: AppText.small),
                    ],
                  ),
                  const SizedBox(width: AppSpace.l),
                  Expanded(
                    child: AppButton(
                      label: 'बुक करें',
                      icon: Icons.arrow_forward,
                      onPressed: () => _book(context),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

/// ऊपर का हिस्सा: आइकन, नाम, एक लाइन, रेट, रेट की बात और समय।
class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primarySoft,
      borderColor: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(service.icon, size: 60, background: AppColors.card),
              const SizedBox(width: AppSpace.m),
              Expanded(child: Text(service.title, style: AppText.h2)),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          Text(service.shortLine, style: AppText.body),
          const SizedBox(height: AppSpace.l),
          Text(
            service.priceLabel,
            style: AppText.price.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          if (service.priceNote.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xs),
            Text(service.priceNote, style: AppText.muted),
          ],
          if (service.duration.isNotEmpty) ...[
            const SizedBox(height: AppSpace.m),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpace.s),
                Expanded(
                  child: Text('कितना समय लगेगा: ${service.duration}', style: AppText.body),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// चेकलिस्ट की एक लाइन: हरा टिक और बात।
class _IncludeLine extends StatelessWidget {
  const _IncludeLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.check_circle, size: 22, color: AppColors.success),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}
