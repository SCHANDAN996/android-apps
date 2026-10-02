import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/screens/parv_screen.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/parv.dart';

void main() {
  const din = [
    ParvDin(
      ank: 1,
      tithiNaam: 'प्रतिपदा',
      shirshak: 'शैलपुत्री',
      ekLine: 'घटस्थापना और जौ बोना',
      bhog: 'गाय का घी',
      vidhiId: 'navratri_1',
      artworkAsset: 'assets/images/devotional/test.webp',
      artworkLabel: 'माँ शैलपुत्री का सजावटी चित्र',
      samayMinute: 25,
    ),
    ParvDin(
      ank: 2,
      tithiNaam: 'द्वितीया',
      shirshak: 'ब्रह्मचारिणी',
      ekLine: 'दूसरे दिन की पूजा',
      bhog: 'शक्कर',
      vidhiId: null,
      artworkAsset: 'assets/images/devotional/test.webp',
      artworkLabel: 'माँ ब्रह्मचारिणी का सजावटी चित्र',
      samayMinute: 20,
    ),
    ParvDin(
      ank: 3,
      tithiNaam: 'तृतीया',
      shirshak: 'चंद्रघंटा',
      ekLine: 'तीसरे दिन की पूजा',
      bhog: 'दूध',
      vidhiId: 'navratri_3',
      artworkAsset: 'assets/images/devotional/test.webp',
      artworkLabel: 'माँ चंद्रघंटा का सजावटी चित्र',
      samayMinute: 20,
    ),
  ];

  const parv = Parv(
    id: 'navratri',
    naam: 'शारदीय नवरात्रि',
    ekLine: 'नौ दिन, नौ रूप',
    parichay: 'माँ दुर्गा के नौ रूपों की आराधना।',
    artworkAsset: 'assets/images/devotional/test.webp',
    artworkLabel: 'नवरात्रि का सजावटी चित्र',
    sankshipt: ParvRasta(
      shirshak: 'संक्षिप्त नवरात्रि पूजा',
      vivaran: 'एक ही बैठक में पूरी पूजा',
      vidhiId: 'navratri_short',
      samayMinute: 30,
    ),
    din: din,
  );

  ParvAaj halat({
    int? aajKaDin,
    int? kitneDinBaad,
    String? tippani,
  }) =>
      ParvAaj(
        aajKaDin: aajKaDin,
        kitneDinBaad: kitneDinBaad,
        shuruTarikh: DateTime(2026, 10, 11),
        antTarikh: DateTime(2026, 10, 19),
        kulDin: 9,
        tippani: tippani,
        mileHueDin: const {2},
        dinTarikhein: {
          1: [DateTime(2026, 10, 11)],
          2: [DateTime(2026, 10, 12)],
          3: [DateTime(2026, 10, 13)],
        },
      );

  Widget app(ParvAaj aaj, {ValueChanged<String>? onKholo, TextScaler? scaler}) {
    return MaterialApp(
      theme: VidhivatTheme.dark(),
      builder: (context, child) => scaler == null
          ? child!
          : MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scaler),
              child: child!,
            ),
      home: ParvScreen(
        parv: parv,
        aaj: aaj,
        onVidhiKholo: onKholo ?? (_) {},
      ),
    );
  }

  void phone(WidgetTester tester, double width, {double height = 800}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> dikhao(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('चलते पर्व में आज का सही दिन दिखता है', (tester) async {
    await tester.pumpWidget(app(halat(aajKaDin: 1)));

    expect(find.text('आज — दिन 1'), findsOneWidget);
    expect(find.text('शैलपुत्री'), findsWidgets);
    expect(find.text('आज की पूजा खोलें'), findsOneWidget);
  });

  testWidgets('पर्व से पहले दिनों की गिनती दिखती है', (tester) async {
    await tester.pumpWidget(app(halat(kitneDinBaad: 5)));

    expect(find.text('शारदीय नवरात्रि शुरू होने में 5 दिन'), findsOneWidget);
    expect(find.textContaining('आरम्भ — 11 अक्टूबर 2026'), findsOneWidget);
  });

  testWidgets('रास्ता बदलने से दिन की सूची छिपती और खुलती है', (tester) async {
    await tester.pumpWidget(app(halat(aajKaDin: 1)));
    await dikhao(tester, find.byKey(const Key('parv_sankshipt_rasta')));
    expect(find.byKey(const Key('parv_din_suchi')), findsNothing);

    await tester.tap(find.byKey(const Key('parv_poorna_rasta')));
    await tester.pumpAndSettle();
    await dikhao(tester, find.byKey(const Key('parv_din_suchi')));
    expect(find.byKey(const Key('parv_din_suchi')), findsOneWidget);
  });

  testWidgets('दोनों पूजा रास्ते चित्रों के साथ बराबर पंक्ति में दिखते हैं',
      (tester) async {
    phone(tester, 320);
    await tester.pumpWidget(
      app(halat(aajKaDin: 1), scaler: const TextScaler.linear(1.5)),
    );
    await dikhao(tester, find.byKey(const Key('parv_sankshipt_rasta')));
    expect(find.text('30 मिनट · एक ही बैठक'), findsOneWidget);
    expect(find.text('9 दिन · रोज़ थोड़ा-थोड़ा'), findsOneWidget);
    expect(find.text('चुना हुआ'), findsOneWidget);

    final sankshipt = find.byKey(const Key('parv_sankshipt_rasta'));
    final poorna = find.byKey(const Key('parv_poorna_rasta'));
    expect(tester.getTopLeft(sankshipt).dy, tester.getTopLeft(poorna).dy);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is ResizeImage &&
            (widget.image as ResizeImage).imageProvider is AssetImage &&
            ((widget.image as ResizeImage).imageProvider as AssetImage)
                    .assetName ==
                'assets/images/devotional/navratri_sankshipt_rasta_v1.webp',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is ResizeImage &&
            (widget.image as ResizeImage).imageProvider is AssetImage &&
            ((widget.image as ResizeImage).imageProvider as AssetImage)
                    .assetName ==
                'assets/images/devotional/navratri_poorna_rasta_v1.webp',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('बिना विधि वाला दिन नहीं खुलता और निशान दिखाता है',
      (tester) async {
    var khula = false;
    await tester.pumpWidget(
      app(halat(aajKaDin: 1), onKholo: (_) => khula = true),
    );
    await dikhao(tester, find.byKey(const Key('parv_poorna_rasta')));
    await tester.tap(find.byKey(const Key('parv_poorna_rasta')));
    await tester.pumpAndSettle();
    await dikhao(tester, find.byKey(const Key('parv_din_2')));

    await tester.tap(find.byKey(const Key('parv_din_2')));
    await tester.pump();
    expect(khula, isFalse);
    expect(
      find.descendant(
        of: find.byKey(const Key('parv_din_2')),
        matching: find.text('विधि अभी नहीं'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('उपलब्ध दिन दबाने पर उसकी विधि खुलती है', (tester) async {
    String? vidhiId;
    await tester.pumpWidget(
      app(halat(aajKaDin: 1), onKholo: (id) => vidhiId = id),
    );
    await dikhao(tester, find.byKey(const Key('parv_poorna_rasta')));
    await tester.tap(find.byKey(const Key('parv_poorna_rasta')));
    await tester.pumpAndSettle();
    await dikhao(tester, find.byKey(const Key('parv_din_3')));

    await tester.tap(find.byKey(const Key('parv_din_3')));
    await tester.pump();
    expect(vidhiId, 'navratri_3');
  });

  testWidgets('हर दिन का कार्ड उसके धार्मिक चित्र के साथ दिखता है',
      (tester) async {
    await tester.pumpWidget(app(halat(aajKaDin: 1)));
    await dikhao(tester, find.byKey(const Key('parv_poorna_rasta')));
    await tester.tap(find.byKey(const Key('parv_poorna_rasta')));
    await tester.pumpAndSettle();
    await dikhao(tester, find.byKey(const Key('parv_din_1')));

    final card = find.byKey(const Key('parv_din_1'));
    expect(
      find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is ResizeImage &&
              ((widget.image as ResizeImage).imageProvider as AssetImage)
                      .assetName ==
                  'assets/images/devotional/test.webp',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('11 अक्तू')),
      findsOneWidget,
    );
  });

  /// पाठ **पूजा नहीं है** (→ D-039) — वह दोनों रास्तों के साथ चलता है,
  /// इसलिए "कैसे करना है" वाले चुनाव के **ऊपर** बैठता है, किसी एक
  /// रास्ते के अंदर नहीं। यह जाँच वही क्रम पकड़े रखती है।
  testWidgets('पाठ का कार्ड संक्षिप्त/पूर्ण के चुनाव से ऊपर है',
      (tester) async {
    phone(tester, 412);
    await tester.pumpWidget(app(halat(aajKaDin: 3)));
    await tester.pumpAndSettle();

    await dikhao(tester, find.text('सप्तश्लोकी दुर्गा पढ़ें'));
    expect(find.text('नवरात्रि का पाठ'), findsOneWidget);
    expect(find.text('सप्तश्लोकी दुर्गा पढ़ें'), findsOneWidget);
    // पूरी सप्तशती अब ऐप में है (→ D-084) — "अपनी पुस्तिका से पढ़िए"
    // वाली पुरानी बात लौटनी नहीं चाहिए।
    expect(find.text('दुर्गा सप्तशती पढ़ें'), findsOneWidget);
    expect(find.textContaining('पूरा पाठ ऐप में है'), findsOneWidget);
    expect(find.textContaining('पुस्तिका से पढ़िए'), findsNothing);

    // ⚠️ क्रम स्क्रीन की y से नहीं नापा जा सकता (कार्ड स्क्रॉल से बाहर
    // होता है), इसलिए widget-वृक्ष के क्रम से नापा जाता है — वही असली
    // क्रम है, स्क्रॉल चाहे जहाँ हो।
    final sab = find
        .byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'नवरात्रि का पाठ' || w.data == 'कैसे करना है'))
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .toList();
    expect(sab, ['नवरात्रि का पाठ', 'कैसे करना है'],
        reason: 'पाठ का कार्ड "कैसे करना है" से ऊपर रहना चाहिए');
  });

  /// व्रत का पन्ना `vrat/navratri.json` में पहले से बना था — नियम,
  /// भोजन, पारण, कथा, सब — पर **इस पन्ने से वहाँ जाने का कोई रास्ता
  /// नहीं था**, जबकि नवरात्रि में व्रत रखने वाला आदमी यहीं खड़ा होता है
  /// (20 सित 2026 को पकड़ा)।
  testWidgets('व्रत के पन्ने तक जाने का रास्ता मौजूद है', (tester) async {
    phone(tester, 412);
    await tester.pumpWidget(app(halat(aajKaDin: 3)));
    await tester.pumpAndSettle();

    await dikhao(tester, find.text('व्रत का पन्ना खोलें'));
    expect(find.text('नवरात्रि का व्रत'), findsOneWidget);
    expect(find.text('व्रत का पन्ना खोलें'), findsOneWidget);
    // ⚠️ निर्जल व्रत का सुझाव ऐप कभी नहीं देता — यह वाक्य यहीं से
    // हटना नहीं चाहिए (→ `docs/23` §९.३)।
    expect(
      find.textContaining('निर्जल व्रत का सुझाव कभी नहीं देता'),
      findsOneWidget,
    );
  });

  testWidgets('पर्व का स्रोत-बटन खाली शीट नहीं खोलता', (tester) async {
    phone(tester, 412);
    await tester.pumpWidget(app(halat(aajKaDin: 3)));
    await tester.pumpAndSettle();

    await dikhao(tester, find.text('यह पर्व कहाँ से आया'));
    await tester.tap(find.text('यह पर्व कहाँ से आया'));
    await tester.pumpAndSettle();

    expect(find.text('नौ रूपों के नाम'), findsOneWidget);
    expect(find.text('नवरात्रि का मुख्य पाठ'), findsOneWidget);
  });

  for (final maamla in [(320.0, 1.5), (412.0, 1.0)]) {
    testWidgets(
        '${maamla.$1.toInt()} चौड़ाई और ${maamla.$2} अक्षर पर बहाव नहीं',
        (tester) async {
      phone(tester, maamla.$1);
      await tester.pumpWidget(
        app(
          halat(aajKaDin: 1, tippani: 'इस साल द्वितीया और तृतीया एक साथ हैं।'),
          scaler: TextScaler.linear(maamla.$2),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await dikhao(tester, find.text('यह पर्व कहाँ से आया'));
      expect(tester.takeException(), isNull);
    });
  }
}
