import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/screens/grahan_screen.dart';
import 'package:vidhivat/screens/more_screen.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/surya_grahan_screen.dart';
import 'package:vidhivat/screens/vrat_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

/// चालीसा-आरती का अपना हिस्सा, और व्रत की सूची (→ D-051)।
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget child) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: child,
      );

  void phoneNaap(WidgetTester tester,
      {double width = 360, double height = 800}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(tak, 160,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  group('होम पर चालीसा और आरती', () {
    testWidgets('अपना हिस्सा है और नाम दिखते हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('चालीसा और आरती'));
      expect(find.text('चालीसा और आरती'), findsOneWidget);
      expect(find.text('बैठकर पढ़ने वाली स्तुतियाँ'), findsOneWidget);
      expect(find.text('श्री हनुमान चालीसा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('नाम दबाने पर वही पाठ खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('श्री हनुमान चालीसा'));
      await tester.tap(find.text('श्री हनुमान चालीसा'));
      await tester.pumpAndSettle();

      expect(find.byType(PaathScreen), findsOneWidget);
    });

    testWidgets('"सभी चालीसा और आरती" पूरी सूची खोलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('सभी चालीसा और आरती'));
      await tester.tap(find.text('सभी चालीसा और आरती'));
      await tester.pumpAndSettle();

      expect(find.byType(PaathListScreen), findsOneWidget);
    });
  });

  group('"अधिक" पर पढ़ने का अपना हिस्सा', () {
    testWidgets('चालीसा अब "पूजा के साधन" में नहीं, अपने हिस्से में है',
        (tester) async {
      // ⚠️ लंबा पर्दा जान-बूझकर — दोनों शीर्षक एक साथ बने रहें, वरना
      // `ListView` ऊपर वाले को हटा देता है और जगह नापी ही नहीं जा सकती।
      phoneNaap(tester, height: 1600);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      expect(find.text('पढ़ने के लिए'), findsOneWidget);
      expect(find.text('चालीसा और आरती'), findsOneWidget);
      expect(find.text('व्रत और उपवास'), findsOneWidget);

      // पढ़ने वाला हिस्सा "पूजा के साधन" के **बाद** आना चाहिए।
      expect(
        tester.getTopLeft(find.text('पढ़ने के लिए')).dy,
        greaterThan(tester.getTopLeft(find.text('पूजा के साधन')).dy),
      );
    });

    testWidgets('ग्रहण का पन्ना खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('चंद्रग्रहण'));
      await tester.tap(find.text('चंद्रग्रहण'));
      await tester.pumpAndSettle();

      expect(find.byType(GrahanScreen), findsOneWidget);
    });

    testWidgets('व्रत का पन्ना खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('व्रत और उपवास'));
      await tester.tap(find.text('व्रत और उपवास'));
      await tester.pumpAndSettle();

      expect(find.byType(VratScreen), findsOneWidget);
    });
  });

  group('व्रत का पन्ना', () {
    testWidgets('पंचांग से बनी सूची दिखती है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratScreen()));
      await tester.pumpAndSettle();

      // अगले साठ दिनों में एकादशी तो पड़ेगी ही — हर महीने दो बार।
      expect(find.text('एकादशी'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('फल या लाभ का कोई दावा नहीं', (tester) async {
      // ⚠️ यह जाँच जान-बूझकर है। "यह व्रत करने से मनोकामना पूरी होती है"
      // जैसा एक भी वाक्य इस पन्ने पर नहीं आना चाहिए — वो भविष्यवाणी के
      // दर्जे में चला जाता है, जो इस ऐप की साफ़ मनाही है।
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratScreen()));
      await tester.pumpAndSettle();

      for (final daawa in [
        'मनोकामना',
        'पूरी होती',
        'लाभ होता',
        'फल मिलता',
        'पुण्य मिलता',
        'कष्ट दूर',
      ]) {
        expect(find.textContaining(daawa), findsNothing,
            reason: '"$daawa" — यह दावा ऐप नहीं करेगा');
      }
    });

    testWidgets('नियम ⓘ के पीछे हैं, खुले नहीं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('ये व्रत कब-कब पड़ते हैं'));
      // बंद हालत में नियम का पाठ स्क्रीन पर नहीं
      expect(find.textContaining('दोनों पक्षों की ग्यारस'), findsNothing);

      await tester.tap(find.text('ये व्रत कब-कब पड़ते हैं'));
      await tester.pumpAndSettle();
      expect(find.textContaining('दोनों पक्षों की ग्यारस'), findsOneWidget);
    });

    testWidgets('320 dp और 1.5x अक्षर पर भी सुरक्षित है', (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: VratScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '320dp/1.5x पर overflow');
    });
  });

  group('चंद्रग्रहण का पन्ना', () {
    testWidgets('ग्रहण दिखते हैं, और "दिखेगा या नहीं" भी', (tester) async {
      phoneNaap(tester, height: 1600);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      // अगले पाँच साल में ग्रहण तो पड़ेंगे ही — साल में दो-तीन।
      expect(find.textContaining('चंद्रग्रहण'), findsWidgets);
      expect(
        find.text('यहाँ दिखेगा').evaluate().isNotEmpty ||
            find.text('यहाँ नहीं दिखेगा').evaluate().isNotEmpty,
        isTrue,
        reason: 'हर ग्रहण पर दिखने का जवाब होना चाहिए',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('फल या असर का कोई दावा नहीं', (tester) async {
      // ⚠️ यह जाँच जान-बूझकर है। "इस ग्रहण का किस राशि पर क्या असर
      // होगा" — वो भविष्यवाणी है, और इस ऐप की साफ़ मनाही (→ D-052)।
      phoneNaap(tester, height: 1600);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      for (final daawa in [
        'राशि पर',
        'अशुभ फल',
        'हानि होगी',
        'लाभ होगा',
        'बचने के उपाय',
        'दान करने से',
      ]) {
        expect(find.textContaining(daawa), findsNothing,
            reason: '"$daawa" — यह दावा ऐप नहीं करेगा');
      }
    });

    testWidgets('जो ग्रहण यहाँ नहीं दिखता, उसका सूतक भी नहीं लिखा',
        (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      // "यहाँ नहीं दिखेगा" वाले कार्ड पर साफ़ लिखा हो कि सूतक नहीं।
      if (find.text('यहाँ नहीं दिखेगा').evaluate().isNotEmpty) {
        expect(find.textContaining('इसलिए यहाँ सूतक भी नहीं है'),
            findsWidgets);
      }
    });

    // ── सूतक तीन प्रहर पहले, नौ घंटे नहीं (→ D-054) ──────────────
    //
    // Drik से मिलाने पर पता चला कि "नौ घंटे" औसत है, नियम नहीं। स्क्रीन
    // पर वो पुराना वाक्य दोबारा न लौट आए, यह जाँच उसी के लिए है।
    testWidgets('सूतक के साथ "नौ घंटे" वाला पुराना वाक्य कहीं नहीं',
        (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('नौ घंटे'), findsNothing,
          reason: 'सूतक तीन प्रहर पहले लगता है, ठीक नौ घंटे पहले नहीं');
    });

    testWidgets('जिस ग्रहण पर सूतक है, वहाँ बच्चों-बूढ़ों वाली बात भी है',
        (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      if (find.textContaining('सूतक ').evaluate().isNotEmpty) {
        expect(find.textContaining('बच्चों, बूढ़ों और बीमारों के लिए सूतक'),
            findsWidgets,
            reason: 'सूतक लिखा है तो कोमल जनों वाली छूट भी लिखी होनी चाहिए');
      }
    });

    // ── आधी रात पार करने वाला ग्रहण ─────────────────────────────
    //
    // ⚠️ 16 जून 2030 के कार्ड पर स्पर्श 22:50 (15 जून की रात) और मध्य
    // 00:02 (16 जून) एक साथ लिखे थे, दोनों बिना तारीख़ के — पढ़ने में
    // लगता था कि सब एक ही रात का है। फ़ोन पर पकड़ा गया।
    testWidgets('आधी रात पार करने वाले समय के साथ तारीख़ भी लिखी होती है',
        (tester) async {
      phoneNaap(tester, height: 4000);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      // हर कार्ड के तीन समय क्रम में होने चाहिए — स्पर्श, मध्य, मोक्ष।
      // जहाँ क्रम उलटा दिखे वहाँ तारीख़ लिखी होनी चाहिए।
      final sparshWale = find
          .textContaining(RegExp(r'^\d{2} [^,]+, \d{2}:\d{2}$'))
          .evaluate();
      final saade = find
          .textContaining(RegExp(r'^\d{2}:\d{2}$'))
          .evaluate();

      // कम से कम एक ऐसा कार्ड मिलना ही चाहिए जो आधी रात पार करता हो —
      // वरना यह जाँच कुछ नहीं जाँच रही।
      expect(sparshWale, isNotEmpty,
          reason: 'आधी रात पार करने वाला एक भी समय नहीं मिला');
      expect(saade, isNotEmpty, reason: 'सादा समय भी दिखना चाहिए');
      expect(tester.takeException(), isNull);
    });

    testWidgets('नियम ⓘ के पीछे हैं, खुले नहीं', (tester) async {
      phoneNaap(tester, height: 1600);
      await tester.pumpWidget(app(const GrahanScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('ग्रहण और सूतक के बारे में'));
      expect(find.textContaining('तीन प्रहर'), findsNothing);

      await tester.tap(find.text('ग्रहण और सूतक के बारे में'));
      await tester.pumpAndSettle();
      expect(find.textContaining('तीन प्रहर'), findsOneWidget);
    });

    testWidgets('320 dp और 1.5x अक्षर पर भी सुरक्षित है', (tester) async {
      phoneNaap(tester, width: 320, height: 1600);
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: GrahanScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '320dp/1.5x पर overflow');
    });
  });

  // ── सूर्यग्रहण का अपना पन्ना (→ D-055) ─────────────────────────
  //
  // चंद्रग्रहण वाले पन्ने से यह दो बातों में अलग है, और दोनों जाँची
  // जाती हैं: **आँख की चेतावनी**, और **यहाँ कितना ढकेगा**।
  group('सूर्यग्रहण का पन्ना', () {
    testWidgets('"अधिक" से खुलता है', (tester) async {
      phoneNaap(tester, height: 2000);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('सूर्यग्रहण'));
      await tester.tap(find.text('सूर्यग्रहण'));
      await tester.pumpAndSettle();

      expect(find.byType(SuryaGrahanScreen), findsOneWidget);
    });

    testWidgets('आँख की चेतावनी सबसे ऊपर है, ⓘ के पीछे नहीं',
        (tester) async {
      // ⚠️ यह सुरक्षा की बात है, सजावट की नहीं। चंद्रग्रहण नंगी आँख से
      // देखा जा सकता है, सूर्यग्रहण नहीं — और यह फ़र्क़ छिपाया नहीं जाएगा।
      phoneNaap(tester, height: 1600);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('नंगी आँख से कभी मत देखिए'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('हर ग्रहण पर "यहाँ दिखेगा या नहीं" का जवाब है',
        (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('यहाँ दिखेगा').evaluate().isNotEmpty ||
            find.text('यहाँ नहीं दिखेगा').evaluate().isNotEmpty,
        isTrue,
      );
      // जो यहाँ नहीं दिखता उसका सूतक भी नहीं लिखा जाता।
      if (find.text('यहाँ नहीं दिखेगा').evaluate().isNotEmpty) {
        expect(find.textContaining('इसलिए यहाँ सूतक भी नहीं है'),
            findsWidgets);
      }
    });

    testWidgets('फल या असर का कोई दावा नहीं', (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      for (final daawa in [
        'राशि पर',
        'अशुभ फल',
        'हानि होगी',
        'लाभ होगा',
        'बचने के उपाय',
        'दान करने से',
      ]) {
        expect(find.textContaining(daawa), findsNothing,
            reason: '"$daawa" — यह दावा ऐप नहीं करेगा');
      }
    });

    testWidgets('सूतक के साथ "बारह घंटे" वाला वाक्य कहीं नहीं',
        (tester) async {
      // सूर्यग्रहण का सूतक चार **प्रहर** पहले लगता है, ठीक बारह घंटे
      // पहले नहीं (→ D-054)।
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('बारह घंटे'), findsNothing);
    });

    testWidgets('नियम ⓘ के पीछे हैं, खुले नहीं', (tester) async {
      phoneNaap(tester, height: 2400);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('सूर्यग्रहण और सूतक के बारे में'));
      expect(find.textContaining('चार प्रहर'), findsNothing);

      await tester.tap(find.text('सूर्यग्रहण और सूतक के बारे में'));
      await tester.pumpAndSettle();
      expect(find.textContaining('चार प्रहर'), findsOneWidget);
    });

    // ── सूतक पिछले दिन शुरू हो तो तारीख़ लिखी जाए ────────────────
    //
    // ⚠️ यह बग असली फ़ोन पर मिला था, जाँच से नहीं। सूर्यग्रहण का सूतक
    // चार प्रहर पहले लगता है — यानी बारह घंटे से भी ज़्यादा — इसलिए वो
    // अक्सर **पिछली शाम** का होता है। बिना तारीख़ के कार्ड पर लिखा आता
    // था *"सूतक 21:17 बजे से 15:07 बजे तक"*, जो उल्टा पढ़ा जाता है।
    testWidgets('पिछले दिन वाले सूतक के साथ तारीख़ भी लिखी होती है',
        (tester) async {
      phoneNaap(tester, height: 4000);
      await tester.pumpWidget(app(const SuryaGrahanScreen()));
      await tester.pumpAndSettle();

      final sutakWale = find
          .textContaining(RegExp(r'^सूतक .* से .* तक।'))
          .evaluate()
          .map((e) => (e.widget as Text).data!)
          .toList();

      expect(sutakWale, isNotEmpty,
          reason: 'अगले पाँच साल में एक भी दिखने वाला सूर्यग्रहण नहीं मिला');

      for (final vaakya in sutakWale) {
        final samay = RegExp(r'(\d{2}):(\d{2}) बजे')
            .allMatches(vaakya)
            .map((m) => int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!))
            .toList();
        if (samay.length != 2) continue;

        // दोनों समय एक ही दिन के दिखें तो पहला दूसरे से पहले होना ही
        // चाहिए। पीछे का निकले तो वाक्य में तारीख़ ("… को") होनी चाहिए,
        // वरना पढ़ने वाले को समय उल्टा चलता दिखेगा।
        if (samay[0] >= samay[1]) {
          expect(vaakya.contains(' को '), isTrue,
              reason: '"$vaakya" — शुरू का समय अंत से बाद का है, यानी वो '
                  'पिछले दिन का है और तारीख़ लिखी होनी चाहिए थी');
        }
      }

      // और कम से कम एक ऐसा वाक्य होना ही चाहिए — सूर्यग्रहण का सूतक
      // चार प्रहर पहले लगता है, इसलिए वो अक्सर पिछली शाम का होता है।
      expect(sutakWale.any((v) => v.contains(' को ')), isTrue,
          reason: 'एक भी सूतक पिछले दिन का नहीं निकला — जाँच बेकार है');
    });

    testWidgets('320 dp और 1.5x अक्षर पर भी सुरक्षित है', (tester) async {
      phoneNaap(tester, width: 320, height: 2400);
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: SuryaGrahanScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '320dp/1.5x पर overflow');
    });
  });
}
