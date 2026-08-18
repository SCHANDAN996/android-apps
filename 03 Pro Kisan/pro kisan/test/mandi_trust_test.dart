// मंडी भाव — भरोसे की जाँच
//
// यह पन्ना किसान को दाम दिखाता है और उसी पर वह फ़सल बेचने जाता है। सर्वर
// पर हर ज़िले का भाव नहीं होता, इसलिए ऐप बीच के ख़ाली हिस्से अपने **नमूना**
// भावों से भरता है।
//
// ⚠️ असली ख़तरा यह है कि नमूना भाव असली जैसा दिख जाए। पहले ठीक यही होता था:
// एक `_hasRealRates` झंडा था, और सर्वर से *कहीं का भी* भाव आ जाने पर वह
// `true` हो जाता — चेतावनी ग़ायब हो जाती और ऊपर "स्रोत: Agmarknet (कृषि
// मंत्रालय, भारत सरकार)" लिख आता। पर सूची में ऐप के बनाए हज़ारों भाव वैसे
// के वैसे पड़े रहते थे। यानी महाराष्ट्र के किसान को ऐप का बनाया दाम "भारत
// सरकार का" कहकर दिखता।
//
// ये जाँचें उसी को दोबारा होने से रोकती हैं।

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/l10n/app_localizations.dart';
import 'package:pro_kisan/ui/mandi_screen.dart';

/// टेस्ट में असली नेटवर्क नहीं चलता — Flutter का टेस्ट binding हर HTTP माँग
/// पर 400 लौटाता है। इसलिए `_fetchRealMandiData()` चुपचाप नाकाम होती है और
/// पन्ना पूरी तरह **नमूना** भावों पर आ जाता है।
///
/// किसान के लिए यह सबसे ख़राब हालत है (सर्वर बंद / नेटवर्क नहीं / उसका
/// राज्य सर्वर पर नहीं) — और ठीक यही हालत सबसे ज़रूरी है जाँचना।
Widget _app() => const MaterialApp(
      locale: Locale('hi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MandiScreen(),
    );

void main() {
  group('मंडी — नमूना भाव कभी असली न लगे', () {
    testWidgets('सब नमूना हों तो नारंगी चेतावनी दिखती है', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('अनुमानित भाव हैं, असली मंडी भाव नहीं'),
        findsOneWidget,
        reason: 'नमूना भाव पर चेतावनी हर हाल में दिखनी चाहिए',
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('सब नमूना हों तो Agmarknet/भारत सरकार का दावा न हो',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 100));

      // ⚠️ यही असली बग था — नक़ली दाम पर सरकारी ठप्पा।
      expect(find.textContaining('Agmarknet'), findsNothing,
          reason: 'एक भी असली भाव नहीं है, तो Agmarknet का नाम नहीं आना चाहिए');
      expect(find.textContaining('भारत सरकार'), findsNothing);

      // इसकी जगह साफ़ लिखा हो कि भाव ऐप के भीतर के हैं
      expect(find.textContaining('ऐप के भीतर रखे अनुमान'), findsOneWidget);
    });

    testWidgets('हर कार्ड पर 🟠 का अपना निशान है', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 100));

      // ऊपर की पट्टी पूरी सूची की बात करती है; किसान तो एक कार्ड देखकर
      // फ़ैसला करता है, इसलिए निशान हर कार्ड पर अलग से चाहिए।
      expect(
        find.textContaining('ऐप का अनुमान — असली भाव नहीं'),
        findsWidgets,
        reason: 'हर नमूना कार्ड पर उसका अपना निशान होना चाहिए',
      );

      // नमूना भाव पर "असली मंडी भाव" का हरा निशान कभी न लगे
      expect(find.textContaining('🟢 असली मंडी भाव'), findsNothing);
    });

    testWidgets('नमूना भाव पर "ऐप में आए" वाला समय नहीं दिखता',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 100));

      // नमूना भाव कोई सर्वर नहीं उठाता। वहाँ समय लिखना झूठ है और उन्हें
      // ताज़ा दिखा देता है।
      expect(find.textContaining('ऐप में आए'), findsNothing);
    });
  });
}
