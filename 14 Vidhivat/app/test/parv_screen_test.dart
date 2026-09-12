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
    expect(find.byKey(const Key('parv_din_suchi')), findsOneWidget);

    await tester.tap(find.byKey(const Key('parv_sankshipt_rasta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('parv_din_suchi')), findsNothing);
    expect(find.text('पूजा खोलें'), findsOneWidget);

    await tester.tap(find.byKey(const Key('parv_poorna_rasta')));
    await tester.pumpAndSettle();
    await dikhao(tester, find.byKey(const Key('parv_din_suchi')));
    expect(find.byKey(const Key('parv_din_suchi')), findsOneWidget);
  });

  testWidgets('बिना विधि वाला दिन नहीं खुलता और निशान दिखाता है',
      (tester) async {
    var khula = false;
    await tester.pumpWidget(
      app(halat(aajKaDin: 1), onKholo: (_) => khula = true),
    );
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
    await dikhao(tester, find.byKey(const Key('parv_din_3')));

    await tester.tap(find.byKey(const Key('parv_din_3')));
    await tester.pump();
    expect(vidhiId, 'navratri_3');
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
