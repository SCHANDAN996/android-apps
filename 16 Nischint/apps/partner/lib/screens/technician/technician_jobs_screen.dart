import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/catalog.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../app/shells.dart';
import '../../technician/rates.dart';
import '../../training/curriculum.dart';
import 'widgets/training_bits.dart';

/// टेक्नीशियन का "काम" टैब। v0.1 में असली काम नहीं आते (सर्वर v0.2 में),
/// इसलिए यहाँ दिखाते हैं कि काम कैसा दिखेगा और पैसे का हिसाब कैसे बनेगा।
class TechnicianJobsScreen extends StatelessWidget {
  const TechnicianJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final certified = AppScope.of(context).training.isCertified;
    final cash = TechnicianRates.cashBooking(customerPays: Catalog.solarCleaning.priceFrom);
    final vendor = TechnicianRates.vendorComplaint();
    final vendorUrgent = TechnicianRates.vendorComplaint(urgent: true);

    return Scaffold(
      appBar: AppBar(title: const Text('आज के काम')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          if (!certified) ...[
            const InfoBanner(
              tone: ChipTone.warning,
              icon: Icons.lock_outline,
              title: 'काम ट्रेनिंग के बाद खुलेंगे',
              text: 'पहले 6 दिन की ट्रेनिंग पूरी करें और सर्टिफ़िकेट लें। उसके बाद आपको काम मिलने लगेंगे।',
            ),
            const SizedBox(height: AppSpace.m),
            AppButton(
              label: 'ट्रेनिंग पर जाएँ',
              icon: Icons.school,
              onPressed: () => ShellNav.goToTab(context, 0),
            ),
          ] else
            const InfoBanner(
              tone: ChipTone.success,
              icon: Icons.verified_outlined,
              title: 'आप प्रशिक्षित टेक्नीशियन हैं',
              text: 'पहले 10 काम मालिक की निगरानी में होंगे। हर काम की फ़ोटो मालिक देखेंगे।',
            ),
          const SizedBox(height: AppSpace.l),
          const AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NumberBadge(icon: Icons.cloud_outlined, background: AppColors.primarySoft, foreground: AppColors.primary),
                SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('असली काम यहाँ कब आएँगे?', style: AppText.h3),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        'सर्वर जुड़ने के बाद (वर्ज़न 0.2) मालिक जो काम आपको देंगे, वह यहाँ अपने-आप दिखेगा: '
                        'ग्राहक, पूरा पता, रास्ता और पूरा हिसाब। तब तक मालिक फ़ोन या WhatsApp पर काम बताएँगे।',
                        style: AppText.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader('नमूना काम', trailing: StatusChip('सिर्फ़ देखने के लिए', tone: ChipTone.warning)),
          const Text('असली काम ऐसा दिखेगा। इन पर कुछ दबाने से कुछ नहीं होगा।', style: AppText.muted),
          const SizedBox(height: AppSpace.m),
          _SampleJobCard(
            kindLabel: 'घर वाले की बुकिंग · नकद',
            service: '${Catalog.solarCleaning.title} (3 kW)',
            area: 'Shivpur',
            extraLine: 'ग्राहक का नाम और कॉल बटन यहाँ दिखेगा',
            money: cash,
            moneyNote: null,
          ),
          const SizedBox(height: AppSpace.m),
          _SampleJobCard(
            kindLabel: 'वेंडर की शिकायत',
            service: 'शिकायत-विज़िट (जाँच)',
            area: 'Sarnath',
            extraLine: 'वेंडर का नाम, ग्राहक का नाम और दिक्कत यहाँ दिखेगी',
            money: vendor,
            moneyNote: 'ग्राहक से कुछ नहीं लेना — वेंडर महीने के बिल से देगा। '
                'जल्दी वाली (48 घंटे) विज़िट पर आपकी कमाई ${rupees(vendorUrgent.earning)}।',
          ),

          const SectionHeader('आपकी कमाई के नियम'),
          AppCard(
            child: Column(
              children: [
                _RateRow(label: 'हर विज़िट की मेहनत', value: rupees(TechnicianRates.perVisit)),
                _RateRow(label: 'पेट्रोल भत्ता (हर विज़िट)', value: rupees(TechnicianRates.petrol)),
                _RateRow(label: 'जल्दी वाली (48 घंटे) विज़िट', value: '+${rupees(TechnicianRates.urgentBonus)}'),
                _RateRow(
                  label: '3 kW से बड़े सिस्टम की सफ़ाई',
                  value: '+${rupees(TechnicianRates.extraPerKwAbove3)} हर अतिरिक्त kW',
                ),
                const SizedBox(height: AppSpace.s),
                const Text('ये सुझाए रेट हैं। पक्के रेट मालिक बताएँगे।', style: AppText.small),
              ],
            ),
          ),

          const SectionHeader('हर विज़िट के 7 क़दम'),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < visitSteps.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpace.m),
                    child: Row(
                      children: [
                        NumberBadge(
                          label: '${i + 1}',
                          size: 32,
                          background: AppColors.primarySoft,
                          foreground: AppColors.primaryDark,
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(child: Text(visitSteps[i], style: AppText.body)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpace.m),
                const Text(
                  'यही 7 क़दम हमारे भरोसे की नींव हैं — कोई क़दम न छोड़ें।',
                  style: AppText.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// नमूना काम का कार्ड।
class _SampleJobCard extends StatelessWidget {
  const _SampleJobCard({
    required this.kindLabel,
    required this.service,
    required this.area,
    required this.extraLine,
    required this.money,
    required this.moneyNote,
  });

  final String kindLabel;
  final String service;
  final String area;
  final String extraLine;
  final JobMoney money;
  final String? moneyNote;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpace.s,
            runSpacing: AppSpace.s,
            children: [
              const StatusChip('नमूना', tone: ChipTone.warning),
              StatusChip(kindLabel, tone: ChipTone.info),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          Text(service, style: AppText.h2),
          const SizedBox(height: AppSpace.s),
          _IconLine(icon: Icons.location_on_outlined, text: 'इलाका: $area'),
          const _IconLine(icon: Icons.home_outlined, text: 'पूरा पता यहाँ दिखेगा (मकान नंबर, गली, लैंडमार्क)'),
          _IconLine(icon: Icons.person_outline, text: extraLine),
          const SizedBox(height: AppSpace.m),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.directions),
              label: const Text('रास्ता देखें (सर्वर जुड़ने के बाद)'),
            ),
          ),
          const SizedBox(height: AppSpace.m),
          _MoneyBox(money: money, note: moneyNote),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: AppSpace.s),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}

/// हिसाब बॉक्स: ग्राहक से लेना · आपकी कमाई · कंपनी को जमा।
class _MoneyBox extends StatelessWidget {
  const _MoneyBox({required this.money, this.note});

  final JobMoney money;
  final String? note;

  @override
  Widget build(BuildContext context) {
    const base = TechnicianRates.perVisit + TechnicianRates.petrol;
    final earningText = money.earning == base
        ? '${rupees(TechnicianRates.perVisit)} + ${rupees(TechnicianRates.petrol)} = ${rupees(money.earning)}'
        : rupees(money.earning);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSpace.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'हिसाब',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppSpace.s),
          _MoneyRow(label: 'ग्राहक से लेना', value: rupees(money.customerPays)),
          _MoneyRow(
            label: 'आपकी कमाई',
            value: earningText,
            strong: true,
          ),
          _MoneyRow(label: 'कंपनी को जमा (उसी दिन)', value: rupees(money.depositToCompany)),
          if (note != null) ...[
            const SizedBox(height: AppSpace.s),
            Text(note!, style: AppText.small),
          ],
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          const SizedBox(width: AppSpace.s),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: strong ? 18 : 16,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                color: strong ? AppColors.success : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          const SizedBox(width: AppSpace.s),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
