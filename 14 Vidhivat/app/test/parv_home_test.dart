import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/home_dashboard_screen.dart';
import 'package:vidhivat/screens/parv_screen.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/screens/vrat_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/parv.dart';
import 'package:vidhivat/vidhi/parv_aaj.dart';
import 'package:vidhivat/vidhi/parv_home.dart';

/// होम के slider पर नवरात्रि (→ D-074)।
///
/// 13 सित 2026 तक नवरात्रि slider में सिर्फ़ "घटस्थापना" बनकर आती थी, और
/// 15 व 19 अक्टूबर 2026 — दिन 5 और अष्टमी-नवमी — को होम पर उसका नाम तक नहीं
/// था। तारीख़ें Drik की दिल्ली वाली हैं (→ D-073)।
void main() {
  final parv = Parv.parse(
    'assets/parv/navratri.json',
    File('assets/parv/navratri.json').readAsStringSync(),
  );

  ParvHomeAvsar? avsar(int saal, int mahina, int din) {
    final aaj = DateTime(saal, mahina, din);
    return navratriHomeAvsar(
      parv: parv,
      aaj: navratriAaj(aaj: aaj, place: Place.delhi),
      aajKiTarikh: aaj,
    );
  }

  group('कब, और कौन-सा पत्ता', () {
    test('पंद्रह दिन से पहले नहीं, पंद्रहवें दिन से पर्व का पत्ता', () {
      expect(avsar(2026, 9, 13), isNull, reason: '28 दिन बाक़ी');
      expect(avsar(2026, 9, 25), isNull, reason: '16 दिन बाक़ी');

      final pandrah = avsar(2026, 9, 26)!;
      expect(pandrah.upar, '15 दिन बाद');
      expect(pandrah.naam, 'शारदीय नवरात्रि');
      expect(pandrah.vidhiId, isNull, reason: 'पहले पूरा पर्व-पन्ना खुले');
      expect(pandrah.aajKa, isFalse);

      expect(avsar(2026, 10, 10)!.upar, 'कल');
    });

    test('नौ दिनों में उस दिन की देवी और उसी दिन की विधि', () {
      final pehla = avsar(2026, 10, 11)!;
      expect(pehla.naam, 'माँ शैलपुत्री');
      expect(pehla.vidhiId, 'kalash_sthapana');
      expect(pehla.aajKa, isTrue);

      final paanch = avsar(2026, 10, 15)!;
      expect(paanch.upar, 'आज');
      expect(paanch.naam, 'माँ स्कंदमाता');
      expect(paanch.vidhiId, 'navratri_din_5');
      expect(paanch.artworkAsset, contains('skandamata'));

      // 2026 में सप्तमी दो सूर्योदय तक — 18 को भी कालरात्रि
      expect(avsar(2026, 10, 18)!.naam, 'माँ कालरात्रि');
    });

    test(
        'अष्टमी-नवमी एक दिन हों तो दोनों पूजाओं वाला पर्व-पन्ना, संधि के समय सहित',
        () {
      final saath = avsar(2026, 10, 19)!;
      expect(saath.naam, 'अष्टमी और नवमी');
      expect(saath.vidhiId, isNull);
      // 2 अक्टूबर 2026 तक यह 10:27–11:15 था। पंचांग का सूर्य VSOP पर आने से
      // (→ D-104) अष्टमी का अंत 23 सेकंड आगे खिसका और मिनट बदल गया। नया समय
      // NASA के क्षण के पास है; संदर्भ-पंचांग के छपे समय असली क्षण से लगभग
      // एक मिनट पहले होते हैं।
      expect(saath.neeche, 'संधि पूजा 10:28–11:16');
      expect(saath.artworkAsset, contains('mahagauri'));
    });

    test('अलग अष्टमी पर महागौरी की विधि और संधि का समय (2025)', () {
      final ashtami = avsar(2025, 9, 30)!;
      expect(ashtami.naam, 'माँ महागौरी');
      expect(ashtami.vidhiId, 'durga_ashtami_kanya_poojan');
      expect(ashtami.neeche, 'संधि पूजा 17:42–18:30');
    });

    test('विजयादशमी पर दशमी की विधि, और उसके बाद कुछ नहीं', () {
      final dashami = avsar(2026, 10, 20)!;
      expect(dashami.naam, 'विजयादशमी');
      expect(dashami.vidhiId, 'vijayadashami');
      expect(avsar(2026, 10, 21), isNull);
    });
  });

  group('होम का slider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
    });

    Future<void> kholoHome(WidgetTester tester, DateTime aaj) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: HomeDashboardScreen(onOpenPujaLibrary: () {}, aaj: aaj),
      ));
      await tester.pumpAndSettle();
    }

    /// पत्ता मिलना काफ़ी नहीं — बगल से झाँकता पत्ता भी "मिल" जाता है, पर
    /// उसका बटन स्क्रीन से बाहर होता है। इसलिए तब तक खिसकाओ जब तक वो
    /// पत्ता पूरा सामने न आ जाए।
    Future<bool> carouselMeDhoondo(WidgetTester tester, Finder kya) async {
      final carousel = find.byKey(const Key('puja_carousel'));
      bool saamne() =>
          kya.evaluate().isNotEmpty && tester.getTopLeft(kya.first).dx < 120;
      for (var i = 0; i < 10; i++) {
        if (saamne()) return true;
        await tester.drag(carousel, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
      return saamne();
    }

    testWidgets('दिन 5 पर स्कंदमाता का पत्ता, और दबाने पर पूरा पर्व-पन्ना',
        (tester) async {
      await kholoHome(tester, DateTime(2026, 10, 15));

      expect(find.text('माँ स्कंदमाता'), findsOneWidget);
      expect(find.text('नवरात्रि देखें'), findsOneWidget);
      await tester.tap(find.text('नवरात्रि देखें'));
      await tester.pumpAndSettle();

      expect(find.byType(ParvScreen), findsOneWidget);
      expect(find.text('शारदीय नवरात्रि'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('तुरंत खोलें में सामग्री के बजाय व्रत खुलता है',
        (tester) async {
      await kholoHome(tester, DateTime(2026, 10, 15));

      await tester.scrollUntilVisible(find.text('व्रत'), 200,
          scrollable: find
              .descendant(
                  of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      await tester.pumpAndSettle();
      expect(find.text('सामग्री'), findsNothing);
      await tester.tap(find.text('व्रत'));
      await tester.pumpAndSettle();

      expect(find.byType(VratScreen), findsOneWidget);
      expect(find.text('व्रत और उपवास'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'पंद्रह दिन पहले पर्व का पत्ता पर्व-पन्ना खोलता है, दोहरा पत्ता नहीं',
        (tester) async {
      await kholoHome(tester, DateTime(2026, 9, 26));

      expect(await carouselMeDhoondo(tester, find.text('शारदीय नवरात्रि')),
          isTrue);
      expect(find.text('शारदीय नवरात्रि — घटस्थापना'), findsNothing);

      await tester.tap(find.text('पर्व देखें'));
      await tester.pumpAndSettle();
      expect(find.byType(ParvScreen), findsOneWidget);
    });

    testWidgets('अष्टमी-नवमी वाले दिन पत्ता पर्व-पन्ना खोलता है',
        (tester) async {
      await kholoHome(tester, DateTime(2026, 10, 19));

      expect(find.text('अष्टमी और नवमी'), findsOneWidget);
      await tester.tap(find.text('दोनों पूजाएँ देखें'));
      await tester.pumpAndSettle();
      expect(find.byType(ParvScreen), findsOneWidget);
    });

    // पंद्रह दिन से दूर — पहले यह पत्ता "घटस्थापना" बनकर सीधे कलश स्थापना
    // की विधि खोलता था, जबकि पूजा section का नवरात्रि कार्ड पूरा पर्व-पन्ना।
    // डेवलपर ने फ़ोन पर पकड़ा (22 सित 2026): दोनों एक ही जगह ले जाएँ।
    // लोकप्रिय पूजा — गृह प्रवेश और वाहन पूजा की जगह (डेवलपर, 22 सित 2026)
    testWidgets(
        'लोकप्रिय पूजा में नवरात्रि और पितृ पक्ष; नवरात्रि पर्व-पन्ना खोलता है',
        (tester) async {
      // जून — ऊपर की पट्टी में नवरात्रि नहीं, ताकि नाम एक ही जगह हो
      await kholoHome(tester, DateTime(2026, 6, 1));

      final navratri = find.text('शारदीय नवरात्रि');
      // होम की सूची आलसी है — नीचे का कार्ड स्क्रॉल करने पर ही बनता है
      await tester.scrollUntilVisible(navratri, 200,
          scrollable: find
              .descendant(
                  of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      await tester.pumpAndSettle();
      expect(navratri, findsOneWidget);
      expect(find.text('पितृ पक्ष — श्राद्ध'), findsOneWidget);
      expect(find.text('गृह प्रवेश'), findsNothing);
      expect(find.text('वाहन पूजा'), findsNothing);

      await tester.tap(navratri);
      await tester.pumpAndSettle();
      expect(find.byType(ParvScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'उन्नीस दिन पहले भी पत्ता पर्व-पन्ना खोलता है, कलश की विधि नहीं',
        (tester) async {
      await kholoHome(tester, DateTime(2026, 9, 22));

      expect(await carouselMeDhoondo(tester, find.text('शारदीय नवरात्रि')),
          isTrue);
      expect(find.text('घटस्थापना · 11 अक्तू'), findsOneWidget);
      expect(find.text('शारदीय नवरात्रि — घटस्थापना'), findsNothing);

      await tester.tap(find.text('पर्व देखें'));
      await tester.pumpAndSettle();
      expect(find.byType(ParvScreen), findsOneWidget);
      expect(find.byType(VidhiScreen), findsNothing);
    });
  });
}
