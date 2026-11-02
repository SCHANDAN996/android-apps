import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/config.dart';
import '../../models/service_item.dart';
import '../../services/contact_service.dart';
import '../../widgets/common.dart';
import 'widgets/info_row.dart';

/// घर वालों के सवाल (ग्राहक ऐप, डिफ़ॉल्ट)।
const List<Faq> customerFaqs = [
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

/// सोलर वेंडरों के सवाल (पार्टनर ऐप, वेंडर)। रेट कार्ड (`Catalog.vendorRates`) से मेल खाएँ।
const List<Faq> vendorFaqs = [
  Faq(
    'पैसा कब और कैसे देना है?',
    'हर शिकायत-विज़िट का पैसा काम के बाद, हफ़्ते या महीने के बिल में। ₹500 से ऊपर के पार्ट पर पहले आपकी हाँ ली जाती है।',
  ),
  Faq(
    'आपके ग्राहक से पैसा कौन लेगा?',
    'आपकी शिकायत वाली विज़िट पर हम ग्राहक से कोई पैसा नहीं लेते। बिल सिर्फ़ आपको आता है।',
  ),
  Faq(
    'शिकायत कितने समय में निपटेगी?',
    'शिकायत मिलते ही हम ग्राहक को कॉल करके समय पक्का करते हैं, और 48 घंटे के अंदर विज़िट की कोशिश करते हैं।',
  ),
  Faq(
    'काम का सबूत कैसे मिलेगा?',
    'हर विज़िट से पहले और बाद की फ़ोटो आपके WhatsApp पर — शिकायत निपटने का सबूत।',
  ),
  Faq(
    'वारंटी वाला पैनल या इन्वर्टर ख़राब हो तो?',
    'पार्ट कंपनी से आएगा। हम सिर्फ़ लगाने की मेहनत लेते हैं, और कंपनी से बात करने में मदद करते हैं।',
  ),
  Faq(
    'वाराणसी से बाहर सेवा मिलेगी?',
    'अभी सिर्फ़ ${AppConfig.serviceArea} में। आसपास के ज़िलों में जल्द शुरू होगी।',
  ),
];

/// टेक्नीशियन के सवाल (पार्टनर ऐप, टेक्नीशियन)।
const List<Faq> technicianFaqs = [
  Faq(
    'मेरा पैसा कब मिलेगा?',
    'हर हफ़्ते। हर विज़िट का पैसा और पेट्रोल "काम" टैब के हिसाब में दिखता है।',
  ),
  Faq(
    'ग्राहक से नकद मिला तो?',
    'उसी दिन कंपनी को जमा करें। काम के हिसाब में "कंपनी को जमा" की रकम दिखती है।',
  ),
  Faq(
    'क्विज़ में पास नहीं हुआ तो?',
    'पाठ दोबारा पढ़ें और फिर से क्विज़ दें — जितनी बार चाहें। सुरक्षा वाले दिन (दिन 2) में सब सही ज़रूरी है।',
  ),
  Faq(
    'फ़ील्ड ट्रायल कैसे होगा?',
    'मालिक या सीनियर के सामने 7 असली काम। हर काम ठीक होने पर वे अपना सुपरवाइज़र कोड डालकर उसे पास करेंगे।',
  ),
  Faq(
    'छत पर ख़तरा लगे तो?',
    'काम रोकें, फ़ोटो लें और मालिक को फ़ोन करें। असुरक्षित छत पर काम मना करना आपका हक़ है — इस पर कोई सज़ा नहीं।',
  ),
  Faq(
    'कुछ समझ न आए तो?',
    'अंदाज़े से काम न करें। रुकें और मालिक को कॉल या WhatsApp करें।',
  ),
];

/// मदद टैब: कॉल, WhatsApp, काम का समय, सेवा क्षेत्र और सवाल-जवाब।
/// [faqs] हर भूमिका के अपने सवाल (डिफ़ॉल्ट: घर वाले)।
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, this.faqs = customerFaqs});

  final List<Faq> faqs;

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
                for (var i = 0; i < faqs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: 2),
                    childrenPadding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.l),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(faqs[i].question, style: AppText.h3),
                    children: [Text(faqs[i].answer, style: AppText.body)],
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
