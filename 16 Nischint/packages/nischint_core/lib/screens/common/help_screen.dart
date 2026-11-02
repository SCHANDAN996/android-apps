import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/config.dart';
import '../../models/service_item.dart';
import '../../services/contact_service.dart';
import '../../widgets/common.dart';
import 'widgets/info_row.dart';

/// अक्सर पूछे सवाल। घर वाले और वेंडर, दोनों के लिए सही बैठें।
const List<Faq> _faqs = [
  Faq(
    'पैसा कब देना है?',
    'काम पूरा होने के बाद। UPI या नकद, जो आपको आसान लगे। पहले से कोई पैसा नहीं लगता।',
  ),
  Faq(
    'फ़ोटो रिपोर्ट कैसे मिलेगी?',
    'हर काम से पहले और बाद की फ़ोटो आपके WhatsApp पर भेजी जाती है।',
  ),
  Faq(
    'आप किस कंपनी का सिस्टम देखते हैं?',
    'किसी भी कंपनी या वेंडर का लगाया सोलर सिस्टम: पैनल, इन्वर्टर, तार, सब।',
  ),
  Faq(
    'काम रद्द करना हो या समय बदलना हो तो?',
    'हमें WhatsApp पर बताएँ। साथ में अपना बुकिंग या शिकायत नंबर लिख दें तो काम जल्दी होगा।',
  ),
  Faq(
    'वाराणसी से बाहर सेवा मिलेगी?',
    'अभी सिर्फ़ ${AppConfig.serviceArea} में। चंदौली, जौनपुर, ग़ाज़ीपुर, मिर्ज़ापुर और भदोही में जल्द शुरू होगी।',
  ),
];

/// मदद टैब: कॉल, WhatsApp, काम का समय, सेवा क्षेत्र और सवाल-जवाब।
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _call(BuildContext context) async {
    final opened = await ContactService.call();
    if (!context.mounted) return;
    if (!opened) showMessage(context, 'कॉल नहीं लग पाया। हमारा नंबर: ${AppConfig.businessPhone}');
  }

  Future<void> _whatsApp(BuildContext context) async {
    final opened = await ContactService.whatsApp('नमस्ते, मुझे आपकी सेवा के बारे में थोड़ी मदद चाहिए।');
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मदद')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          const Text('हम आपकी मदद के लिए हैं', style: AppText.h2),
          const SizedBox(height: AppSpace.xs),
          const Text('कोई भी सवाल या दिक्कत हो, सीधे कॉल या WhatsApp कीजिए।', style: AppText.muted),
          const SizedBox(height: AppSpace.l),
          AppButton(
            label: 'कॉल करें',
            icon: Icons.call,
            onPressed: () => _call(context),
          ),
          const SizedBox(height: AppSpace.m),
          AppButton(
            label: 'WhatsApp करें',
            icon: Icons.chat,
            outlined: true,
            onPressed: () => _whatsApp(context),
          ),
          const SizedBox(height: AppSpace.l),
          const AppCard(
            child: Column(
              children: [
                InfoRow(label: 'काम का समय', value: AppConfig.workingHours, icon: Icons.schedule),
                Divider(height: AppSpace.l),
                InfoRow(label: 'सेवा क्षेत्र', value: AppConfig.serviceArea, icon: Icons.location_on_outlined),
              ],
            ),
          ),
          const SectionHeader('अक्सर पूछे सवाल'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _faqs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: 2),
                    childrenPadding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.l),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(_faqs[i].question, style: AppText.h3),
                    children: [Text(_faqs[i].answer, style: AppText.body)],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
