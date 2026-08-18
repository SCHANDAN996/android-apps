import 'package:flutter/material.dart';

import '../data/app_language.dart';

/// The app's privacy summary, shown from both Home and Settings.
///
/// Keep this the single source of truth: the wording has to stay in step with
/// `privacy_policy.html` and the Play Data safety form, and it previously drifted
/// out of date because the same dialog was duplicated in two screens.
void showAppPrivacyPolicy(BuildContext context, AppStrings strings) {
  final isEn = strings.isEn;

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
              isEn
                  ? 'Jameen Napi respects your privacy.'
                  : 'जमीन नापी आपकी गोपनीयता का पूरा सम्मान करता है।',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(isEn
                ? '• All calculations run offline on your phone. Nothing you measure is uploaded anywhere.'
                : '• आपकी सारी नाप-गणना आपके फोन में ही होती है। नाप का कोई डेटा कहीं नहीं भेजा जाता।'),
            Text(isEn
                ? '• We collect no name, phone number, location or contacts.'
                : '• हम आपका नाम, मोबाइल नंबर, लोकेशन या कॉन्टैक्ट कुछ भी एकत्र नहीं करते।'),
            Text(isEn
                ? '• The app shows Google AdMob ads. For ads only, AdMob uses the internet and your device\'s Advertising ID.'
                : '• ऐप में Google AdMob के विज्ञापन दिखते हैं। सिर्फ़ विज्ञापनों के लिए AdMob इंटरनेट और आपके फोन की Advertising ID का उपयोग करता है।'),
            Text(isEn
                ? '• No other permission (location, contacts, storage, camera) is requested.'
                : '• इसके अलावा कोई परमिशन (लोकेशन, कॉन्टैक्ट, स्टोरेज, कैमरा) नहीं मांगी जाती।'),
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
