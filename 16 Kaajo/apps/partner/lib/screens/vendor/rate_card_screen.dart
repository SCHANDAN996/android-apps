import 'package:flutter/material.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/catalog.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/services/contact_service.dart';
import 'package:kaajo_core/widgets/common.dart';

/// भरोसे की बातें: (आइकन, शीर्षक, एक लाइन)।
const List<(IconData, String, String)> _trustPoints = [
  (Icons.photo_camera, 'फ़ोटो सबूत', 'हर विज़िट से पहले और बाद की फ़ोटो, ताकि पोर्टल पर सबूत रहे।'),
  (Icons.assignment_return, 'पुराना पार्ट वापस', 'जो पार्ट बदला, वह पुराना पार्ट आपको लौटाएँगे।'),
  (Icons.receipt_long, 'पक्का बिल', 'हर विज़िट और हर पार्ट का पक्का बिल, कोई छिपा खर्च नहीं।'),
  (Icons.lock_outline, 'ग्राहक का OTP', 'ग्राहक के OTP से ही काम पूरा माना जाएगा।'),
  (Icons.store, 'आपके नाम से', 'ग्राहक के घर हम आपकी फ़र्म के नाम से जाएँगे।'),
];

/// वेंडर का दूसरा टैब: रेट, काम का तरीका, भरोसा और मुफ़्त पायलट।
class RateCardScreen extends StatelessWidget {
  const RateCardScreen({super.key});

  Future<void> _askPilot(BuildContext context) async {
    final vendor = AppScope.read(context).vendor;
    final opened = await ContactService.whatsApp(ContactService.pilotMessage(vendor));
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  @override
  Widget build(BuildContext context) {
    const steps = Catalog.vendorProcess;
    return Scaffold(
      appBar: AppBar(title: const Text('रेट कार्ड')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          const _HeaderCard(),
          const SizedBox(height: AppSpace.m),
          const _PilotCard(),

          const SectionHeader('रेट'),
          for (final row in Catalog.vendorRates)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.m),
              child: _RateTile(row: row),
            ),
          const InfoBanner(
            tone: ChipTone.success,
            icon: Icons.currency_rupee,
            text: 'कोई छिपा खर्च नहीं। पार्ट्स का पैसा हमेशा पक्के बिल पर, और बड़ा खर्च आपकी हाँ के बाद ही।',
          ),

          const SectionHeader('हर काम का तरीका'),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  _StepRow(number: i + 1, text: steps[i], showLine: i < steps.length - 1),
              ],
            ),
          ),

          const SectionHeader('भरोसा'),
          for (final (icon, title, line) in _trustPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s),
              child: _TrustTile(icon: icon, title: title, line: line),
            ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: 'मुफ़्त पायलट के बारे में पूछें',
          icon: Icons.chat,
          onPressed: () => _askPilot(context),
        ),
      ),
    );
  }
}

/// ऊपर का टील कार्ड।
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      color: AppColors.primary,
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConfig.vendorLine,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
          ),
          SizedBox(height: AppSpace.s),
          Text(
            'आपके ग्राहक की शिकायत पर हम विज़िट करेंगे, आपके नाम से, फ़ोटो सबूत के साथ। '
            'शिकायत-विज़िट ₹500–600, पार्ट्स पक्के बिल पर।',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
          ),
        ],
      ),
    );
  }
}

/// मुफ़्त पायलट की सूचना।
class _PilotCard extends StatelessWidget {
  const _PilotCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      color: AppColors.sunSoft,
      borderColor: AppColors.sun,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.card_giftcard, color: AppColors.warning, size: 28),
          SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('पहला महीना 50 घरों पर मुफ़्त पायलट', style: AppText.h3),
                SizedBox(height: AppSpace.xs),
                Text(
                  'पहले हमारा काम देखिए, फिर फ़ैसला कीजिए। बाक़ी बातें WhatsApp पर बात करके तय करेंगे।',
                  style: AppText.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// रेट की एक पंक्ति।
class _RateTile extends StatelessWidget {
  const _RateTile({required this.row});

  final RateRow row;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.item, style: AppText.h3),
          const SizedBox(height: AppSpace.xs),
          Text(row.rate, style: AppText.price),
          if (row.when.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpace.xs),
                Expanded(child: Text(row.when, style: AppText.small)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// काम के तरीके का एक क़दम: गोल नंबर और बात।
class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text, required this.showLine});

  final int number;
  final String text;

  /// नीचे अगले क़दम तक की पतली लाइन।
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text(
                '$number',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            if (showLine) Container(width: 2, height: 18, color: AppColors.primarySoft),
          ],
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: AppText.body),
          ),
        ),
      ],
    );
  }
}

/// भरोसे की एक बात।
class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.title, required this.line});

  final IconData icon;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.s),
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h3),
                const SizedBox(height: 2),
                Text(line, style: AppText.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
