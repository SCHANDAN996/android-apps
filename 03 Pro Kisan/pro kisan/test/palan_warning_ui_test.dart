// मशीन-अनुवाद की चेतावनी सचमुच परदे पर दिखती है या नहीं
//
// ⚠️ गहरी जानकारी (नस्ल, दाना, टीका, बीमारी, खुराक) आठ भाषाओं में **मशीन**
// ने अनुवाद की है — किसी पशु-चिकित्सक ने नहीं जाँची। इसलिए उन भाषाओं में
// गाइड खुलते ही सबसे ऊपर चेतावनी दिखनी चाहिए कि दवा/टीके की बात डॉक्टर या
// KVK से पक्की कर लें।
//
// `palan_i18n_test.dart` सिर्फ़ यह जाँचता है कि चेतावनी का **पाठ मौजूद** है।
// यहाँ यह जाँचते हैं कि वह पाठ सचमुच **दिखता** भी है — और हिंदी/अंग्रेज़ी
// में नहीं दिखता, क्योंकि वे मूल हैं।

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/palan/palan_data.dart';
import 'package:pro_kisan/data/palan/palan_i18n.dart';
import 'package:pro_kisan/l10n/app_localizations.dart';
import 'package:pro_kisan/ui/pashu/palan_detail_screen.dart';

Widget _app(String lang) => MaterialApp(
      locale: Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      // ⚠️ भोजपुरी (bho) Flutter का मानक locale नहीं है, इसलिए
      // GlobalMaterialLocalizations उसे नहीं जानता और AppBar टूट जाता है।
      // असली ऐप इसी वजह से Fallback delegates रखता है (देखें main.dart) —
      // जाँच में भी वही क्रम रखना ज़रूरी है, वरना जाँच असली ऐप जैसी नहीं रहेगी।
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // गाय की गाइड सबसे भारी है — नस्ल, टीका, खुराक सब उसी में
      home: PalanDetailScreen(
        guide: kPalanGuides.firstWhere((g) => g.id == 'gaay'),
      ),
    );

void main() {
  group('मशीन-अनुवाद की चेतावनी', () {
    for (final lang in ['ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho']) {
      testWidgets('$lang में चेतावनी दिखती है', (tester) async {
        await tester.pumpWidget(_app(lang));
        await tester.pump();

        // पूरा वाक्य लंबा है और कई लाइनों में टूटता है — इसलिए उसी भाषा के
        // पाठ का एक टुकड़ा ढूँढ़ते हैं। हर भाषा में "KVK" ज़रूर आता है।
        final warn = kMachineTxWarning[lang]!;
        expect(find.text(warn), findsOneWidget,
            reason: '$lang में चेतावनी की पट्टी नहीं मिली');
      });
    }

    testWidgets('हिंदी में चेतावनी नहीं दिखती — वह मूल भाषा है',
        (tester) async {
      await tester.pumpWidget(_app('hi'));
      await tester.pump();
      expect(find.textContaining('मशीन से अनुवाद'), findsNothing);
      expect(find.textContaining('यंत्र'), findsNothing);
    });

    testWidgets('अंग्रेज़ी में भी नहीं दिखती', (tester) async {
      await tester.pumpWidget(_app('en'));
      await tester.pump();
      for (final w in kMachineTxWarning.values) {
        expect(find.text(w), findsNothing);
      }
    });
  });
}
