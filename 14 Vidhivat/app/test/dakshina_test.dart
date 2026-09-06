import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/dakshina_screen.dart';
import 'package:vidhivat/services/dakshina_service.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/dakshina_card.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// **दक्षिणा का पहरा** (→ D-053, `docs/20_KAMAI_YOJANA.md`)
///
/// यहाँ पाँच चीज़ें रोकी जाती हैं, और पाँचों कोड से नहीं — **नीयत से**
/// आती हैं। इसीलिए इनकी जाँच ज़रूरी है: कोड बाद में कोई और छुएगा, और
/// उसे यह वजहें याद नहीं होंगी।
///
/// 1. दे चुके यूज़र से छह महीने तक दोबारा नहीं पूछा जाता
/// 2. तीन बार दिखने के बाद तीस दिन की चुप्पी
/// 3. **जहाँ आदमी पूजा कर रहा है वहाँ दक्षिणा कभी नहीं** — विधि प्लेयर,
///    पाठ, संकल्प, होम
/// 4. कोई राशि पहले से चुनी हुई नहीं
/// 5. §6.4 की मनाही — जो वाक्य कभी नहीं लिखने
void main() {
  final abhi = DateTime(2026, 9, 5, 20);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await dakshina.load();
    dakshina.dwar = null;
  });

  Widget app(Widget home) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: Scaffold(body: SingleChildScrollView(child: home)),
      );

  // ─────────────────────────────────────────────────────────────
  // 1 और 2 — घड़ी का नियम
  // ─────────────────────────────────────────────────────────────

  group('घड़ी का नियम', () {
    test('पहली बार पूजा पूरी होने पर डिब्बा दिखता है', () {
      expect(dakshina.dikhega(abhi), isTrue);
    });

    test('दे चुके यूज़र से छह महीने तक दोबारा नहीं पूछा जाता', () async {
      await dakshina.mili(abhi);

      expect(dakshina.dikhega(abhi.add(const Duration(days: 1))), isFalse);
      expect(dakshina.dikhega(abhi.add(const Duration(days: 181))), isFalse);
      // छह महीने बाद फिर पूछा जा सकता है — साल में दो बार से ज़्यादा कभी नहीं।
      expect(dakshina.dikhega(abhi.add(const Duration(days: 183))), isTrue);
    });

    test('तीन बार दिखने के बाद तीस दिन की चुप्पी, फिर गिनती नए सिरे से',
        () async {
      await dakshina.dikhaayiGayi(abhi);
      expect(dakshina.dikhega(abhi), isTrue);
      await dakshina.dikhaayiGayi(abhi.add(const Duration(days: 1)));
      expect(dakshina.dikhega(abhi.add(const Duration(days: 1))), isTrue);
      await dakshina.dikhaayiGayi(abhi.add(const Duration(days: 2)));

      // तीसरी बार के बाद चुप।
      expect(dakshina.dikhega(abhi.add(const Duration(days: 3))), isFalse);
      expect(dakshina.dikhega(abhi.add(const Duration(days: 31))), isFalse);

      // तीस दिन बाद फिर — और गिनती शून्य से, यानी फिर तीन मौक़े।
      final baad = abhi.add(const Duration(days: 33));
      expect(dakshina.dikhega(baad), isTrue);
      await dakshina.dikhaayiGayi(baad);
      expect(dakshina.dikhega(baad.add(const Duration(days: 1))), isTrue);
    });

    test('दक्षिणा मिलते ही छोड़ने की गिनती भी मिट जाती है', () async {
      await dakshina.dikhaayiGayi(abhi);
      await dakshina.dikhaayiGayi(abhi);
      await dakshina.dikhaayiGayi(abhi);
      expect(dakshina.dikhega(abhi), isFalse);

      await dakshina.mili(abhi);
      // छह महीने बाद वापसी — तीस दिन वाली सज़ा साथ नहीं आती।
      expect(dakshina.dikhega(abhi.add(const Duration(days: 183))), isTrue);
    });

    test('फ़ोन की घड़ी पीछे चली जाए तो ऐप चुप रहता है, दोबारा नहीं पूछता',
        () async {
      await dakshina.mili(abhi);
      expect(dakshina.dikhega(abhi.subtract(const Duration(days: 400))),
          isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // दुकान — नक़ली द्वार से, असली Play को छुए बिना
  // ─────────────────────────────────────────────────────────────

  group('देना', () {
    test('द्वार लगा ही नहीं है तो कुछ कटता नहीं', () async {
      expect(await dakshina.dena(dakshinaRaashiyan.first),
          DakshinaNatija.upalabdhNahi);
      expect(dakshina.kabhiDiThi, isFalse);
    });

    test('मिलने पर बही में दर्ज होती है, रद्द होने पर नहीं', () async {
      dakshina.dwar = _NakliDwar(DakshinaNatija.radd);
      expect(await dakshina.dena(dakshinaRaashiyan[1]), DakshinaNatija.radd);
      expect(dakshina.kabhiDiThi, isFalse);

      dakshina.dwar = _NakliDwar(DakshinaNatija.mili);
      expect(await dakshina.dena(dakshinaRaashiyan[1]), DakshinaNatija.mili);
      expect(dakshina.kabhiDiThi, isTrue);
    });

    test('छह राशियाँ, और उनके id वही जो Play Console में बनेंगे', () {
      expect(dakshinaRaashiyan.length, 7);
      expect(
        dakshinaRaashiyan.map((r) => r.id).toList(),
        ['dakshina_11', 'dakshina_21', 'dakshina_51', 'dakshina_101',
         'dakshina_251', 'dakshina_501', 'dakshina_1100'],
      );
      expect(dakshinaRaashiyan.map((r) => r.rupaye).toList(),
          [11, 21, 51, 101, 251, 501, 1100]);
      // सबसे छोटी राशि सबसे पहले — मना करने लायक छोटा पहला क़दम।
      // ₹11 सबसे पहले — मना करने लायक़ छोटा पहला क़दम।
      expect(dakshinaRaashiyan.first.rupaye, 11);
      // और Play की भारत वाली सबसे कम क़ीमत (₹10) से नीचे कोई न हो।
      expect(dakshinaRaashiyan.every((r) => r.rupaye >= 10), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 4 — कोई राशि पहले से चुनी हुई नहीं
  // ─────────────────────────────────────────────────────────────

  group('चुनाव', () {
    testWidgets('कोई राशि पहले से चुनी हुई नहीं, और बिना चुने बटन नहीं चलता',
        (tester) async {
      await tester.pumpWidget(app(const DakshinaChunav()));

      final button = tester.widget<VidhivatButton>(
        find.widgetWithText(VidhivatButton, 'दक्षिणा दें'),
      );
      expect(button.onPressed, isNull,
          reason: 'राशि चुने बिना दक्षिणा का बटन कभी नहीं चलना चाहिए');

      // सातों राशियाँ दिखती हैं — ₹11 समेत।
      for (final raashi in dakshinaRaashiyan) {
        expect(find.text(raashi.label), findsOneWidget);
      }
      expect(find.text('₹11'), findsOneWidget);

      // बटन फीका क्यों है, यह देखने वाले को भी दिखना चाहिए — पहले यह
      // सिर्फ़ semantics में था।
      expect(find.byKey(const Key('dakshina_pehle_chuniye')), findsOneWidget);
    });

    testWidgets('₹11 चुनकर दी जा सकती है', (tester) async {
      final dwar = _NakliDwar(DakshinaNatija.mili);
      dakshina.dwar = dwar;
      await tester.pumpWidget(app(const DakshinaChunav()));

      await tester.tap(find.text('₹11'));
      await tester.pump();
      await tester.tap(find.text('दक्षिणा दें'));
      await tester.pumpAndSettle();

      expect(dwar.maangiGayi?.rupaye, 11);
      expect(dwar.maangiGayi?.id, 'dakshina_11');
    });

    testWidgets('हर चिप उँगली भर बड़ी है', (tester) async {
      // ⚠ यहाँ ज़रा सी चूक से पैसे वाला काम रुक जाता है।
      await tester.pumpWidget(app(const DakshinaChunav()));
      for (final raashi in dakshinaRaashiyan) {
        final naap = tester.getSize(find.ancestor(
          of: find.text(raashi.label),
          matching: find.byType(ConstrainedBox),
        ).first);
        expect(naap.height,
            greaterThanOrEqualTo(VidhivatActionSize.minimumTouchTarget),
            reason: '${raashi.label} की चिप बहुत छोटी है');
      }
    });

    testWidgets('राशि चुनने पर ही बटन खुलता है', (tester) async {
      await tester.pumpWidget(app(const DakshinaChunav()));
      await tester.tap(find.text('₹51'));
      await tester.pump();

      final button = tester.widget<VidhivatButton>(
        find.widgetWithText(VidhivatButton, 'दक्षिणा दें'),
      );
      expect(button.onPressed, isNotNull);
      // चुनते ही वो सहायक पंक्ति हट जाती है — उसका काम पूरा हुआ।
      expect(find.byKey(const Key('dakshina_pehle_chuniye')), findsNothing);
    });

    testWidgets('मिलने पर धन्यवाद — कोई रसीद, कोई बैज, कोई सुविधा नहीं',
        (tester) async {
      final dwar = _NakliDwar(DakshinaNatija.mili);
      dakshina.dwar = dwar;

      await tester.pumpWidget(app(const DakshinaChunav()));
      await tester.tap(find.text('₹101'));
      await tester.pump();
      await tester.tap(find.text('दक्षिणा दें'));
      await tester.pumpAndSettle();

      expect(dwar.maangiGayi?.rupaye, 101);
      expect(find.byKey(const Key('dakshina_dhanyavaad')), findsOneWidget);
      expect(find.text('दक्षिणा दें'), findsNothing);
    });

    testWidgets('बीच में छोड़ने पर एक शब्द भी नहीं कहा जाता', (tester) async {
      dakshina.dwar = _NakliDwar(DakshinaNatija.radd);

      await tester.pumpWidget(app(const DakshinaChunav()));
      await tester.tap(find.text('₹21'));
      await tester.pump();
      await tester.tap(find.text('दक्षिणा दें'));
      await tester.pumpAndSettle();

      // कोई ताना नहीं, कोई "क्यों नहीं दिया" नहीं। बटन वैसे का वैसा।
      expect(find.byKey(const Key('dakshina_gadbad')), findsNothing);
      expect(find.byKey(const Key('dakshina_dhanyavaad')), findsNothing);
      expect(find.text('दक्षिणा दें'), findsOneWidget);
    });

    testWidgets('दुकान बंद हो तो दोष यूज़र पर नहीं डाला जाता', (tester) async {
      dakshina.dwar = _NakliDwar(DakshinaNatija.upalabdhNahi);

      await tester.pumpWidget(app(const DakshinaChunav()));
      await tester.tap(find.text('₹21'));
      await tester.pump();
      await tester.tap(find.text('दक्षिणा दें'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dakshina_gadbad')), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // पन्ना — तीनों सच्ची पंक्तियाँ
  // ─────────────────────────────────────────────────────────────

  testWidgets('दक्षिणा का पन्ना तीनों साफ़-साफ़ बातें कहता है',
      (tester) async {
    // पूरा पन्ना एक बार में बन जाए — `Panna` एक ListView है, और छोटी
    // खिड़की में नीचे वाला हिस्सा बनता ही नहीं।
    tester.view.physicalSize = const Size(393 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: VidhivatTheme.dark(), home: const DakshinaScreen()),
    );

    expect(find.text(DakshinaShabd.shirshak), findsOneWidget);
    expect(find.textContaining('किसी मंदिर, संस्था या पंडित को'),
        findsOneWidget);
    expect(find.textContaining('कुछ नया नहीं खुलता'), findsOneWidget);
    expect(find.textContaining('यह पूजा की दक्षिणा नहीं है'), findsOneWidget);
    expect(find.textContaining('लगभग ₹800 प्रति पूजा'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────
  // 3 और 5 — स्रोत पढ़कर की जाने वाली जाँचें
  // ─────────────────────────────────────────────────────────────

  group('स्रोत का पहरा', () {
    /// जहाँ आदमी सचमुच पूजा कर रहा है। यहाँ पैसा माँगना विज्ञापन से भी
    /// बुरा है — और विज्ञापन तो पूरे ऐप में हैं ही नहीं (→ D-008, D-053)।
    const pavitraScreens = [
      'lib/screens/vidhi_player_screen.dart',
      'lib/screens/paath_screen.dart',
      'lib/screens/sankalp_screen.dart',
      'lib/screens/home_dashboard_screen.dart',
      'lib/screens/vidhi_screen.dart',
    ];

    test('पूजा वाली स्क्रीनों पर दक्षिणा का नाम तक नहीं', () {
      for (final raah in pavitraScreens) {
        final source = File(raah).readAsStringSync();
        for (final nishani in ['DakshinaCard', 'DakshinaChunav',
                               'DakshinaScreen', 'dakshina.dena']) {
          expect(source.contains(nishani), isFalse,
              reason: '$raah में "$nishani" नहीं होना चाहिए — वहाँ आदमी '
                  'पूजा कर रहा है (→ D-008, D-053)');
        }
      }
    });

    test('दक्षिणा सिर्फ़ पूजा पूरी होने वाले पन्ने से खुलती है', () {
      final poorn =
          File('lib/screens/puja_completion_screen.dart').readAsStringSync();
      expect(poorn.contains('DakshinaCard'), isTrue,
          reason: 'पूजा पूरी होने पर ही माँगी जाती है — वही इस पूरे मॉडल '
              'की जड़ है (मूल्य पहले, माँग बाद में)');
      expect(poorn.contains('dakshina.dikhega'), isTrue,
          reason: 'घड़ी का नियम लगे बिना डिब्बा हर बार दिखेगा');
    });

    /// §6.4 — जो वाक्य कभी नहीं लिखने।
    ///
    /// ⚠️ जाँच सिर्फ़ **string** पढ़ती है, टिप्पणियाँ नहीं — क्योंकि
    /// टिप्पणियों में ये वाक्य जान-बूझकर लिखे हैं ("यह मत लिखना")।
    test('मनाही वाला कोई वाक्य स्क्रीन पर नहीं जाता', () {
      const dakshinaKiFileein = [
        'lib/services/dakshina_service.dart',
        'lib/widgets/dakshina_card.dart',
        'lib/screens/dakshina_screen.dart',
      ];

      final manahi = <RegExp, String>{
        RegExp('पुण्य'): 'दक्षिणा को पूजा के फल से जोड़ना',
        RegExp('फल मिलेगा|फल मिलता'): 'फल का दावा',
        RegExp('पूजा अधूरी'): 'अधूरी पूजा का डर',
        RegExp('दान करें|दान दें|दान दीजिए'): 'दान का दावा',
        RegExp('पंडित जी को दक्षिणा'): 'पैसा किसी पंडित को नहीं जाता',
        RegExp('गौशाला|अनाथालय'): 'झूठा charity का दावा',
        RegExp('सबसे लोकप्रिय|सबसे ज़्यादा लोग'): 'दबाव बनाना',
        RegExp('सिर्फ़ आज|24 घंटे|आख़िरी मौक़ा'): 'बाज़ारू जल्दबाज़ी',
        RegExp('प्रीमियम|सहयोगी सदस्य|Premium'): 'बैज जैसा दर्जा',
        RegExp('आपने अब तक'): 'ताना',
      };

      for (final raah in dakshinaKiFileein) {
        final shabd = _stringLiterals(File(raah).readAsStringSync());
        manahi.forEach((nishani, kyon) {
          expect(nishani.hasMatch(shabd), isFalse,
              reason: '$raah की किसी पंक्ति में "$kyon" आ गया '
                  '(→ docs/20_KAMAI_YOJANA.md §6.4)');
        });
      }
    });

    test('हर जगह साफ़ लिखा है कि देने से कुछ नहीं बदलता', () {
      final card = File('lib/widgets/dakshina_card.dart').readAsStringSync();
      expect(card.contains('कोई पूजा या सुविधा बंद नहीं होती'), isTrue);
      // पाने वाले का नाम लिए बिना यह पूजा का ही कदम पढ़ा जाएगा —
      // शब्द *दक्षिणा* ऐप की पूजाओं में पहले से 42 जगह है।
      expect(card.contains("static const shirshak = 'दक्षिणा दें'"), isFalse,
          reason: 'शीर्षक में पाने वाले का नाम होना ही चाहिए');
      expect(card.contains("'विधिवत को दक्षिणा'"), isTrue);
    });
  });
}

/// स्रोत में से सिर्फ़ string निकालो — टिप्पणियाँ छोड़कर।
String _stringLiterals(String source) {
  final binaTippani = source
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('//'))
      .join('\n');
  final ek = RegExp(r"'([^'\\\n]|\\.)*'");
  final do_ = RegExp(r'"([^"\\\n]|\\.)*"');
  return [
    ...ek.allMatches(binaTippani).map((m) => m.group(0)!),
    ...do_.allMatches(binaTippani).map((m) => m.group(0)!),
  ].join(' ');
}

/// नक़ली द्वार — असली Play को छुए बिना पूरा रास्ता जाँचने के लिए।
class _NakliDwar extends DakshinaDwar {
  final DakshinaNatija natija;
  DakshinaRaashi? maangiGayi;

  _NakliDwar(this.natija);

  @override
  Future<bool> khulaHai() async => natija != DakshinaNatija.upalabdhNahi;

  @override
  Future<DakshinaNatija> dena(DakshinaRaashi raashi) async {
    maangiGayi = raashi;
    return natija;
  }
}
