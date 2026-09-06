// ℹ बटन और उसके पीछे की शीट — D-045 और D-056 वाले फ़ैसलों की जाँच।
//
// इन जाँचों का काम एक ही है: यह पक्का करना कि **मिटाया कुछ नहीं गया**।
// जो बात पहले खुली पड़ी थी वो अब एक दबाव पीछे है — पर है।
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/aaj_screen.dart';
import 'package:vidhivat/screens/muhurta_screen.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/sankalp_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/widgets/design_system.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    // ⚠ यजमान भरे बिना संकल्प का पन्ना पूरा बनता ही नहीं —
    // वहाँ "नाम और गोत्र भरिए" वाला रास्ता आता है, और नीचे
    // का ℹ बटन बनता ही नहीं (प्रोब में पकड़ा गया)।
    await settings.setYajman(name: 'चन्दन', gotra: 'कश्यप');
  });

  Widget app(Widget home, {TextScaler? scaler}) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          theme: VidhivatTheme.dark(),
          builder: (context, child) => scaler == null
              ? child!
              : MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: scaler),
                  child: child!,
                ),
          home: home,
        ),
      );

  void phone(WidgetTester tester, {double width = 400, double height = 900}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(
      tak,
      300,
      // ⚠ `find.byType(ListView)` पर टिका रहना चलता नहीं — कुछ पन्ने
      // `FutureBuilder` के पीछे बनते हैं, और उस पल कोई ListView होता
      // ही नहीं। पहला Scrollable हर पन्ने पर पन्ने का अपना होता है।
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> kholo(WidgetTester tester, String label) async {
    await scrollTak(tester, find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// खुली ℹ शीट के अंदर नीचे तक जाओ।
  ///
  /// ⚠ शीट आधी ऊँचाई पर खुलती है (`initialChildSize: 0.5`) और उसकी
  /// `ListView` आलसी है — नीचे की पंक्तियाँ **बनी ही नहीं** होतीं।
  /// इसलिए वहाँ `findsNothing` "नहीं है" नहीं कहता — सिर्फ़ "अभी बना
  /// नहीं" कहता है।
  Future<void> sheetMeinNeeche(WidgetTester tester, Finder tak) async {
    await tester.dragUntilVisible(
      tak,
      find.byType(ListView).last,
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
  }

  group('ℹ बटन ख़ुद', () {
    // ── वो बग जो जाँच ने पकड़ा ─────────────────────────────────
    //
    // Material का बटन अपने बच्चे को `Align(widthFactor: 1)` में रखता है,
    // यानी बच्चे को **बिना सीमा वाली चौड़ाई** मिलती है। वहाँ `Flexible`
    // कुछ नहीं करता — लंबा लेबल सीधा स्क्रीन से बाहर चला जाता है।
    //
    // 320dp पर 1.5× अक्षरों के साथ यह 252px का overflow बनाता था।
    testWidgets('लंबा लेबल 320dp और 1.5× पर भी बाहर नहीं निकलता',
        (tester) async {
      phone(tester, width: 320);
      await tester.pumpWidget(app(
        const Scaffold(
          body: VidhivatSrotButton(
            label: 'इस पाठ के बारे में · इस पर दो चलन हैं · और भी बहुत कुछ',
            panktiyan: [VidhivatSrotPankti('स्रोत', 'कहीं से')],
          ),
        ),
        scaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '320dp × 1.5 पर overflow');
    });

    testWidgets('ख़ाली पंक्ति शीट में नहीं छपती', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const Scaffold(
        body: VidhivatSrotButton(
          label: 'खोलो',
          panktiyan: [
            VidhivatSrotPankti('भरी', 'यह दिखेगी'),
            VidhivatSrotPankti('ख़ाली', '   '),
          ],
        ),
      )));
      await tester.tap(find.text('खोलो'));
      await tester.pumpAndSettle();

      expect(find.text('यह दिखेगी'), findsOneWidget);
      expect(find.text('ख़ाली'), findsNothing);
    });
  });

  group('संकल्प — पद्धति वाली बात ℹ में गई (→ D-056)', () {
    testWidgets('पन्ने पर खुली नहीं, पर बटन दबाने पर पूरी मिलती है',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const SankalpScreen()));
      await tester.pumpAndSettle();

      // `needsPanditReview` का default ही `true` है — यानी यह डिब्बा
      // शर्त नहीं, दीवार था। अब वो संकल्प के ठीक नीचे नहीं बैठता।
      expect(find.textContaining('व्याकरण और छपी पद्धतियों से'), findsNothing);

      await kholo(tester, 'यह संकल्प कैसे बना');
      expect(
          find.textContaining('व्याकरण और छपी पद्धतियों से'), findsOneWidget);
      expect(find.textContaining('संवत्, अयन, ऋतु'), findsOneWidget);
    });
  });

  group('आज का पंचांग — अयनांश एक ही जगह (→ D-056)', () {
    testWidgets('पन्ने पर दो बार नहीं, ℹ में एक बार', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const AajScreen()));
      await tester.pumpAndSettle();

      expect(find.text('अयनांश'), findsNothing);
      expect(find.textContaining('दृक् गणित'), findsNothing);

      await kholo(tester, 'यह पंचांग कैसे बना');
      expect(find.text('आज का अयनांश'), findsOneWidget);
      expect(find.text('दृक् गणित'), findsOneWidget);
    });
  });

  group('चौघड़िया — सिद्धांत ℹ में (→ D-056)', () {
    testWidgets('होरा का नियम खुला नहीं, बटन के पीछे है', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const MuhurtaScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('वारों का क्रम इसी से बना है'), findsNothing);

      await kholo(tester, 'चौघड़िया और होरा के बारे में');
      // ये दोनों शीट की तीसरी और चौथी पंक्ति हैं — तह से नीचे।
      await sheetMeinNeeche(
          tester, find.textContaining('वारों का क्रम इसी से बना है'));
      expect(
          find.textContaining('वारों का क्रम इसी से बना है'), findsOneWidget);
      // और वो बातें भी, जो पहले कहीं लिखी ही नहीं थीं
      expect(find.text('चौघड़िया'), findsWidgets);
      expect(find.text('गणना'), findsOneWidget);
    });
  });

  group('चालीसा — पहला दोहा पहली तह में (→ D-056)', () {
    testWidgets('"कब/कैसे पढ़ें" ℹ में, पर आग वाली सावधानी खुली',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'ganesh_aarti')));
      await tester.pumpAndSettle();

      // विधि वाला हिस्सा छिपा…
      expect(find.textContaining('थाली घुमाता है'), findsNothing);
      // …पर सावधानी नहीं। इसे न पढ़ने से चोट लग सकती है।
      expect(find.textContaining('ढीले कपड़े'), findsOneWidget);

      await kholo(tester, 'कब और कैसे पढ़ें');
      expect(find.textContaining('थाली घुमाता है'), findsOneWidget);
    });

    testWidgets('सावधानी `kaisePadhein` से सचमुच अलग होती है', (tester) async {
      final aarti = await paathBhandar.paath('ganesh_aarti');
      final chalisa = await paathBhandar.paath('hanuman_chalisa');

      expect(aarti.saavdhani, contains('ढीले कपड़े'));
      expect(aarti.kaisePadheinVidhi, isNot(contains('ढीले कपड़े')));
      expect(aarti.kaisePadheinVidhi, contains('थाली घुमाता है'));

      // चालीसा का ⚠ ख़तरे का नहीं, बताने का है — पर अलग वैसे ही होता है
      expect(chalisa.saavdhani, contains('पूजा नहीं'));
      expect(chalisa.kaisePadheinVidhi, isNot(contains('पूजा नहीं')));
    });
  });

  group('जो वादे ऐप पूरा नहीं कर सकता, वो नहीं छपते (→ D-056)', () {
    testWidgets('चालीसा की सूची रिकॉर्डिंग का वादा नहीं करती', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const PaathListScreen()));
      await tester.pumpAndSettle();

      // ऐप में एक भी ऑडियो फ़ाइल नहीं है — `assets/` में `audio/` तक नहीं।
      expect(find.textContaining('रिकॉर्डिंग'), findsNothing);
      expect(find.textContaining('आगे जोड़े जाएँगे'), findsNothing);
    });
  });
}
