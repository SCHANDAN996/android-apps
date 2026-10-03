import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/granthalaya_screen.dart';
import 'package:vidhivat/screens/more_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/saptashati_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/widgets/common.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// ग्रंथालय और गीता के पन्ने — उँगली चलाकर (→ D-098)।
///
/// कंटेंट की जाँच `granth_test.dart` में है। यहाँ यह देखा जाता है कि जो
/// बना है वह **स्क्रीन पर पहुँचता है**: सूची से अध्याय, अध्याय से अगला
/// अध्याय, और लौटने पर "जहाँ छोड़ा था वहीं से"।
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) =>
            MaterialApp(theme: VidhivatTheme.dark(), home: home),
      );

  /// ऊँची स्क्रीन — पूरी सूची एक साथ बन जाए, ताकि जाँच स्क्रॉल में न उलझे।
  void lambaPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 3, 6000 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// असली फ़ोन का नाप (→ D-024)।
  void phone(WidgetTester tester, {double width = 360, double scale = 1}) {
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  const gita = GranthSuchiEntry(
    id: 'gita',
    naam: 'श्रीमद्भगवद्गीता',
    chhotaNaam: 'गीता',
    ekLine: 'अठारह अध्याय, सात सौ श्लोक — हर श्लोक का अर्थ',
    ikai: 'अध्याय',
    khandIkai: 'श्लोक',
  );

  group('ग्रंथालय', () {
    testWidgets('गीता और सप्तशती, दोनों दिखती हैं — और कोई अधूरा वायदा नहीं',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const GranthalayaScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ग्रंथालय'), findsOneWidget);
      expect(find.text('श्रीमद्भगवद्गीता'), findsOneWidget);
      // चार ग्रंथ हैं — फ़ोन की ऊँचाई में सप्तशती नीचे है, सूची lazy है
      await tester.scrollUntilVisible(find.text('दुर्गा सप्तशती'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('दुर्गा सप्तशती'), findsOneWidget);
      expect(find.textContaining('जल्द'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('सूची वाली गीता वही है जो कोड की जाँचों में मानी गई है',
        (tester) async {
      final g = (await granthBhandar.suchi()).singleWhere((g) => g.id == 'gita');
      expect(g.naam, gita.naam);
      expect(g.chhotaNaam, gita.chhotaNaam);
      expect(g.ikai, gita.ikai);
      expect(g.khandIkai, gita.khandIkai);
    });

    testWidgets('गीता दबाने पर उसका पन्ना, सप्तशती दबाने पर उसका',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const GranthalayaScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('श्रीमद्भगवद्गीता'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('अध्याय १ — अर्जुनविषादयोग'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('दुर्गा सप्तशती'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('दुर्गा सप्तशती'));
      await tester.pumpAndSettle();
      expect(find.text('देवी कवच'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"अधिक" पन्ने से ग्रंथालय खुलता है', (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ग्रंथालय'), findsOneWidget);
      await tester.tap(find.text('ग्रंथालय'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthalayaScreen), findsOneWidget);
    });

    testWidgets('320 चौड़ाई और 1.5 गुना अक्षर पर कुछ बाहर नहीं निकलता',
        (tester) async {
      phone(tester, width: 320, scale: 1.5);
      await tester.pumpWidget(app(const GranthalayaScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('श्रीमद्भगवद्गीता'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('गीता का पन्ना', () {
    testWidgets('अठारहों अध्याय तीन हिस्सों में, हर एक की एक लाइन के साथ',
        (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const GranthScreen(granth: gita)));
      await tester.pumpAndSettle();

      expect(find.text('अध्याय १ से ६'), findsOneWidget);
      expect(find.text('अध्याय १३ से १८'), findsOneWidget);
      expect(find.text('अध्याय १ — अर्जुनविषादयोग'), findsOneWidget);
      expect(find.text('अध्याय १८ — मोक्षसंन्यासयोग'), findsOneWidget);
      expect(find.text('दोनों सेनाओं के बीच अर्जुन का शोक'), findsOneWidget);
      expect(find.text('47 श्लोक'), findsNWidgets(2)); // अध्याय १ और ६
      // पहली बार — "पिछली बार" वाला कार्ड नहीं
      expect(find.text('पिछली बार यह पाठ खोला था'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('अध्याय खुलता है, पट्टी "गीता · अध्याय" कहती है, अगला चलता है',
        (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const GranthScreen(granth: gita)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('अध्याय २ — साङ्ख्ययोग'));
      await tester.pumpAndSettle();

      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('गीता · अध्याय 2/18'), findsOneWidget);
      expect(find.textContaining('श्लोक 1/'), findsOneWidget);
      // समापन-वाक्य श्लोक नहीं है — गिनती बहत्तर ही रहे
      expect(find.text('72 श्लोक'), findsOneWidget);
      // सूची lazy है — ऊपर के श्लोक ही बने होते हैं
      expect(find.text('श्लोक ३'), findsOneWidget);
      expect(find.textContaining('क्लैब्यं मा स्म गमः'), findsOneWidget);

      await tester.tap(find.text('अगला'));
      await tester.pumpAndSettle();
      expect(find.text('गीता · अध्याय 3/18'), findsOneWidget);
      expect(find.text('अध्याय ३ — कर्मयोग'), findsWidgets);

      // "पीछे" सीधे सूची पर — हर पढ़ा अध्याय फिर से नहीं खुलता
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.byType(PaathScreen), findsNothing);
      expect(find.text('पिछली बार यह पाठ खोला था'), findsOneWidget);
      expect(find.text('अध्याय ३ — कर्मयोग'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('"अर्थ दिखाएँ" दबाने पर श्लोक का अर्थ दिखता है', (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'gita_12')));
      await tester.pumpAndSettle();

      // पहले श्लोक का अर्थ — अर्जुन का प्रश्न
      const arth = 'उनमें योग को सबसे अच्छा जानने वाले कौन हैं';
      expect(find.textContaining(arth), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining(arth), findsOneWidget);
      // और रोमन भी — दोनों एक ही बटन से खुलते हैं
      expect(find.textContaining('arjuna uvaacha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पहले अध्याय में "पिछला" बंद, अठारहवें में "अगला" बंद',
        (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const GranthScreen(granth: gita)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('अध्याय १ — अर्जुनविषादयोग'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<VidhivatButton>(
                  find.widgetWithText(VidhivatButton, 'पिछला'))
              .onPressed,
          isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('अध्याय १८ — मोक्षसंन्यासयोग'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<VidhivatButton>(find.widgetWithText(VidhivatButton, 'अगला'))
              .onPressed,
          isNull);
    });

    /// नीचे की पट्टी में दो लिखावटें एक पंक्ति में हैं — "गीता · अध्याय
    /// 11/18" और "श्लोक 56/56 तक"। छोटे फ़ोन और बड़े अक्षरों पर यही सबसे
    /// पहले बाहर निकलती; ग्यारहवाँ अध्याय इसलिए कि उसके श्लोक (त्रिष्टुप्)
    /// सबसे लंबे हैं।
    for (final (chaudai, scale) in [(320.0, 1.5), (360.0, 2.0)]) {
      testWidgets(
          'अध्याय का पन्ना ${chaudai.toInt()} चौड़ाई और $scale गुना अक्षर पर ठीक बैठता है',
          (tester) async {
        phone(tester, width: chaudai, scale: scale);
        await tester.pumpWidget(app(const PaathScreen(
          id: 'gita_11',
          granth: GranthNavigation(
            granthId: 'gita',
            granthNaam: 'गीता',
            ikai: 'अध्याय',
            khandIkai: 'श्लोक',
            paathId: 'gita_11',
            kram: 10,
            kul: 18,
            pichhlaNaam: 'अध्याय १० — विभूतियोग',
            aglaNaam: 'अध्याय १२ — भक्तियोग',
            pichhlaKholo: null,
            aglaKholo: null,
          ),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('गीता · अध्याय 11/18'), findsOneWidget);

        // अर्थ खोलकर कुछ स्क्रीन नीचे — लंबे श्लोक, रोमन और अर्थ तीनों के साथ
        final soochi = find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first;
        await tester.scrollUntilVisible(find.text('अर्थ दिखाएँ'), 200,
            scrollable: soochi);
        await tester.pumpAndSettle();
        await tester.tap(find.text('अर्थ दिखाएँ'));
        await tester.pumpAndSettle();
        expect(find.textContaining('arjuna uvaacha'), findsWidgets);
        for (var i = 0; i < 6; i++) {
          await tester.drag(soochi, const Offset(0, -500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('पिछली बार खोला अध्याय याद रहता है — सिर्फ़ इसी ग्रंथ का',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        GranthScreen.pichhlaKeyFor('gita'): 'gita_07',
        SaptashatiScreen.pichhlaKey: 'saptashati_03',
      });
      lambaPhone(tester);
      await tester.pumpWidget(app(const GranthScreen(granth: gita)));
      await tester.pumpAndSettle();

      expect(find.text('पिछली बार यह पाठ खोला था'), findsOneWidget);
      expect(find.text('अध्याय ७ — ज्ञानविज्ञानयोग'), findsNWidgets(2));
      expect(find.text('वहीं से पढ़ें'), findsOneWidget);
    });

    testWidgets('श्लोक की पहुँची हुई जगह गीता की अपनी कुंजी में बचती है',
        (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(
        {'gita_aakhri_khand_gita_02': 40},
      );

      await tester.pumpWidget(app(const PaathScreen(
        id: 'gita_02',
        granth: GranthNavigation(
          granthId: 'gita',
          granthNaam: 'गीता',
          ikai: 'अध्याय',
          khandIkai: 'श्लोक',
          paathId: 'gita_02',
          kram: 1,
          kul: 18,
          pichhlaNaam: null,
          aglaNaam: null,
          pichhlaKholo: null,
          aglaKholo: null,
        ),
      )));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));

      // आम फ़ोन पर भी चालीसवें खंड तक पहुँचे — सूची lazy है (→ D-097)
      final scroll = tester.state<ScrollableState>(find
          .descendant(
              of: find.byType(PaathReader), matching: find.byType(Scrollable))
          .first);
      expect(scroll.position.pixels, greaterThan(3000));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('gita_aakhri_khand_gita_02'),
          greaterThanOrEqualTo(38));
    });
  });

  group('कृष्ण पूजा से गीता', () {
    Future<void> paathKadamPar(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400 * 3, 2600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final v = await vidhiBhandar.vidhi('krishna_pooja');
      final index = v.charan.indexWhere((c) => c.granth.isNotEmpty);
      await tester.pumpWidget(
        app(VidhiPlayerScreen(vidhi: v, initialStepIndex: index)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('"पाठ" वाले कदम पर गीता का बटन है, और झूठी चेतावनी नहीं',
        (tester) async {
      await paathKadamPar(tester);

      expect(find.widgetWithText(VidhivatButton, 'श्रीमद्भगवद्गीता'),
          findsOneWidget);
      // गीता ऐप में है — "अभी नहीं जोड़ा गया" कहना झूठ होता (→ D-049)
      expect(find.byType(Chetavni), findsNothing);
      expect(find.textContaining('अभी ऐप में नहीं जोड़ा गया'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('बटन गीता की अध्याय-सूची खोलता है', (tester) async {
      await paathKadamPar(tester);

      await tester.tap(find.widgetWithText(VidhivatButton, 'श्रीमद्भगवद्गीता'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('अध्याय १ — अर्जुनविषादयोग'), findsOneWidget);
    });
  });
}
