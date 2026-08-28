import 'package:flutter/material.dart';

import '../data/app_language.dart';

/// ऐप की privacy summary, Home और Settings दोनों से खुलती है।
///
/// यही एक जगह है जहाँ यह लिखा है — इसे `privacy_policy.html` और Play के Data
/// safety form से मेल खाते रहना चाहिए। पहले यह दो स्क्रीनों में copy थी और
/// इसी वजह से पुरानी (गलत) बात रह गई थी कि ऐप में कोई विज्ञापन नहीं है।
void showAppPrivacyPolicy(BuildContext context, AppStrings strings) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.privacy_tip, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(child: Text(strings.privacyPolicy)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.privacyIntro,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• ${strings.privacyOffline}'),
            const SizedBox(height: 4),
            Text('• ${strings.privacyNoPersonalData}'),
            const SizedBox(height: 4),
            Text('• ${strings.privacyAds}'),
            const SizedBox(height: 4),
            Text('• ${strings.privacyNoOtherPermission}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(strings.ok),
        ),
      ],
    ),
  );
}
