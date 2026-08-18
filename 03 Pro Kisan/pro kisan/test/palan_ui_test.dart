import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/palan/palan_common.dart';
import 'package:pro_kisan/data/pashu_calc.dart';
import 'package:pro_kisan/data/palan/palan_data.dart';
import 'package:pro_kisan/data/palan/palan_meta.dart';
import 'package:pro_kisan/ui/pashu/palan_picker_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: PalanPickerScreen()));
  await tester.pumpAndSettle();
}

void main() {
  group('पालन चुनने का पन्ना', () {
    testWidgets('सारे पालन 2 कतार के grid में, tagline सहित', (tester) async {
      await _pump(tester);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final del = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(del.crossAxisCount, 2, reason: '2 × 2 चाहिए (पहले 3 था)');
      expect(find.text('बकरी पालन'), findsOneWidget);
      // tagline भी दिखनी चाहिए
      expect(find.textContaining('गरीब की गाय'), findsOneWidget);
    });

    testWidgets('चित्र बची हुई पूरी जगह लेता है, लिखा हुआ नीचे टिकता है',
        (tester) async {
      // ⚠️ पहले उल्टा था — चित्र की ऊँचाई 68 पर बँधी थी और tagline
      // `Expanded` में। इससे चित्र कार्ड के हिसाब से छोटा रहता और लिखा हुआ
      // बची हुई जगह के बीच में तैरता — हर कार्ड में अलग जगह पर, क्योंकि
      // tagline कहीं एक लाइन की है कहीं दो की।
      await _pump(tester);

      final card = find.ancestor(
        of: find.text('बकरी पालन'),
        matching: find.byType(Column),
      ).first;

      // चित्र वाला हिस्सा Expanded में हो — तभी वह बड़ा होगा
      expect(
        find.descendant(of: card, matching: find.byType(Expanded)),
        findsOneWidget,
        reason: 'चित्र `Expanded` में होना चाहिए, तय ऊँचाई में नहीं',
      );

      // tagline की ऊँचाई तय हो — तभी सारे कार्ड में चित्र बराबर बड़ा होगा
      // और नाम एक ही रेखा पर बैठेगा
      final taglineBox = tester.widgetList<SizedBox>(
        find.descendant(of: card, matching: find.byType(SizedBox)),
      ).where((b) => b.height == 30);
      expect(taglineBox, isNotEmpty,
          reason: 'tagline की ऊँचाई 30 पर बँधी होनी चाहिए (2 लाइनें)');

      // चित्र नाम से ऊपर है
      final imgY = tester.getCenter(
          find.descendant(of: card, matching: find.byType(Expanded))).dy;
      final nameY = tester.getCenter(find.text('बकरी पालन')).dy;
      expect(imgY, lessThan(nameY), reason: 'चित्र नाम के ऊपर रहे');
    });

    testWidgets('खोज हिंदी और रोमन दोनों से', (tester) async {
      await _pump(tester);
      Finder inGrid(String s) =>
          find.descendant(of: find.byType(GridView), matching: find.text(s));

      await tester.enterText(find.byType(TextField), 'bakri');
      await tester.pump();
      expect(inGrid('बकरी पालन'), findsOneWidget);
      expect(inGrid('सुअर पालन'), findsNothing);

      await tester.enterText(find.byType(TextField), 'मछली');
      await tester.pump();
      expect(inGrid('बकरी पालन'), findsNothing);
    });

    testWidgets('श्रेणी की चिप्पी छाँटती है', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('पक्षी'));
      await tester.pumpAndSettle();
      expect(find.text('बकरी पालन'), findsNothing);
      expect(find.textContaining('मुर्गी'), findsWidgets);
    });

    testWidgets('कुछ न मिले तो साफ़ बताता है', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump();
      expect(find.text('यह पालन नहीं मिला'), findsOneWidget);
    });
  });

  group('पालन का ब्योरा', () {
    test('हर पालन का अपना चित्र है — कोई साझा नहीं', () {
      final seen = <String, String>{};
      for (final g in kPalanGuides) {
        final p = palanImage(g.id);
        expect(p, isNotNull, reason: '${g.id} का चित्र नहीं');
        expect(seen.containsKey(p), isFalse,
            reason: '${g.id} और ${seen[p]} एक ही चित्र इस्तेमाल कर रहे हैं');
        seen[p!] = g.id;
      }
    });

    test('हर पालन की श्रेणी तय है', () {
      for (final g in kPalanGuides) {
        expect(PalanGroup.values.contains(palanGroup(g.id)), isTrue, reason: g.id);
      }
    });

    test('खोज हिंदी, अंग्रेज़ी, रोमन और tagline चारों से', () {
      final bakri = palanById('bakri')!;
      for (final q in ['बकरी', 'goat', 'bakri', 'chhagal', 'गरीब']) {
        expect(palanMatches(bakri, q), isTrue, reason: q);
      }
      expect(palanMatches(bakri, 'मछली'), isFalse);
    });
  });

  group('नए हिस्से', () {
    test('सरकारी मदद में NLM और KCC दोनों हैं', () {
      final all = kCommonSchemes.map((e) => e.hi).join(' ');
      expect(all, contains('NLM'));
      expect(all, contains('KCC'));
      expect(all, contains('बीमा'));
      expect(all, contains('50%'));
      expect(all, contains('4%'));
    });

    test('आम ग़लतियाँ और ख़रीदने की जगह ख़ाली नहीं', () {
      expect(kCommonMistakes.length, greaterThanOrEqualTo(5));
      expect(kCommonWhereToBuy.length, greaterThanOrEqualTo(4));
      // ठगी की चेतावनी ज़रूर हो
      expect(kCommonWhereToBuy.map((e) => e.hi).join(' '), contains('वापस ख़रीद लेंगे'));
    });

    test('जिन पालन में ख़ास ख़तरा है उनकी अपनी चेतावनी भी है', () {
      for (final id in ['bakri', 'layer', 'broiler', 'pig', 'fish', 'bee', 'emu']) {
        final g = palanById(id)!;
        expect(g.mistakes.isNotEmpty || g.whereToBuy.isNotEmpty, isTrue,
            reason: '$id — अपनी कोई चेतावनी नहीं');
      }
      // एमू की ठगी वाली चेतावनी सबसे ज़रूरी है
      expect(palanById('emu')!.mistakes.first.hi, contains('ठगी'));
    });

    test('हर पालन में दाम की तारीख़ लिखी है', () {
      for (final g in kPalanGuides) {
        expect(g.priceAsOf, isNotEmpty, reason: g.id);
      }
      expect(kSchemeAsOf, isNotEmpty);
    });
  });

  group('रिमाइंडर', () {
    test('हर पालन में रिमाइंडर है — मछली/मधुमक्खी/एमू भी', () {
      final missing =
          kPalanGuides.where((g) => g.reminderPlan.isEmpty).map((g) => g.id).toList();
      expect(missing, isEmpty, reason: 'इनमें रिमाइंडर नहीं: $missing');
    });

    test('मछली और मधुमक्खी में टीका नहीं, मौसमी काम का रिमाइंडर', () {
      final fish = palanById('fish')!.reminderPlan.map((r) => r.what.hi).join(' ');
      expect(fish, contains('ऑक्सीजन'));
      final bee = palanById('bee')!.reminderPlan.map((r) => r.what.hi).join(' ');
      expect(bee, contains('शहद'));
    });

    test('एमू में असली टीका है', () {
      final emu = palanById('emu')!.reminderPlan.map((r) => r.what.hi).join(' ');
      expect(emu, contains('रानीखेत'));
    });

    test('हर रिमाइंडर की तारीख़ बढ़ते क्रम में है', () {
      for (final g in kPalanGuides) {
        final days = g.reminderPlan.map((r) => r.day).toList();
        final sorted = [...days]..sort();
        expect(days, sorted, reason: '${g.id} — तारीख़ें क्रम में नहीं');
      }
    });
  });

  group('🐄 गाय और भैंस — सबसे ज़रूरी गाइड', () {
    test('दोनों मौजूद हैं और सबसे ऊपर हैं', () {
      expect(kPalanGuides.length, 15);
      expect(kPalanGuides[0].id, 'gaay', reason: 'गाय सबसे ऊपर होनी चाहिए');
      expect(kPalanGuides[1].id, 'bhains');
    });

    test('दोनों में हर हिस्सा भरा है', () {
      for (final id in ['gaay', 'bhains']) {
        final g = palanById(id)!;
        expect(g.breeds.length, greaterThanOrEqualTo(4), reason: '$id नस्लें');
        expect(g.housing.length, greaterThanOrEqualTo(4), reason: '$id आवास');
        expect(g.feed.length, greaterThanOrEqualTo(4), reason: '$id चारा');
        expect(g.production.length, greaterThanOrEqualTo(5), reason: '$id उत्पादन');
        expect(g.vaccines.length, greaterThanOrEqualTo(4), reason: '$id टीके');
        expect(g.diseases.length, greaterThanOrEqualTo(5), reason: '$id बीमारी');
        expect(g.selling.length, greaterThanOrEqualTo(4), reason: '$id बिक्री');
        expect(g.mistakes.length, greaterThanOrEqualTo(4), reason: '$id ग़लतियाँ');
        expect(g.whereToBuy.length, greaterThanOrEqualTo(4), reason: '$id ख़रीद');
        expect(g.schemes.length, greaterThanOrEqualTo(3), reason: '$id योजना');
        expect(g.reminderPlan.length, greaterThanOrEqualTo(7), reason: '$id रिमाइंडर');
      }
    });

    test('टीकाकरण NDDB/NADCP की अनुसूची से मेल खाता है', () {
      final cow = palanById('gaay')!;
      final v = cow.vaccines.map((e) => '${e.when.hi} ${e.what.hi}').join(' | ');
      expect(v, contains('FMD'));
      expect(v, contains('ब्रूसेलोसिस'));
      expect(v, contains('HS'));
      expect(v, contains('BQ'));
      // FMD 4 माह पर, फिर हर 6 माह
      expect(v, contains('4 माह'));
      expect(v, contains('6 माह'));
      // ब्रूसेलोसिस जीवन में एक बार, 4-8 माह की बछिया को
      expect(v, contains('4-8 माह'));
      expect(v, contains('एक ही बार'));
    });

    test('दाना का हिसाब ऐप के आहार कैलकुलेटर जैसा ही', () {
      // कैलकुलेटर: 1.5 किग्रा रखरखाव + 0.4 किग्रा प्रति लीटर
      final cow = palanById('gaay')!.feedNotes.map((e) => e.hi).join(' ');
      expect(cow, contains('1.5 किग्रा'));
      expect(cow, contains('400 ग्राम'));
      // भैंस को ज़्यादा — फ़ैट बनाने में ताक़त लगती है।
      // ⚠️ यह संख्या ऐप के आहार कैलकुलेटर (2.0 + 0.45×लीटर) से मेल खानी
      // चाहिए, वरना किसान को दो अलग जवाब मिलेंगे और भरोसा टूटेगा।
      final buf = palanById('bhains')!.feedNotes.map((e) => e.hi).join(' ');
      expect(buf, contains('450 ग्राम'));
      final calc = calculateFullAahar(speciesId: 'buffalo', milkL: 10).danaKg;
      expect(calc, closeTo(2.0 + 10 * 0.45, 0.01));
    });

    test('दोनों का लागत-मुनाफ़ा सही, घाटा नहीं', () {
      for (final id in ['gaay', 'bhains']) {
        final g = palanById(id)!;
        expect(g.cycleProfit, greaterThan(0), reason: id);
        expect(g.setupCost, greaterThan(0), reason: id);
        expect(g.paybackMonths, isNotNull, reason: id);
      }
    });

    test('भैंस में गर्मी/पानी की चेतावनी सबसे ऊपर', () {
      final b = palanById('bhains')!;
      expect(b.mistakes.first.hi, contains('पानी'));
      expect(b.housing.map((e) => e.hi).join(' '), contains('पसीना'));
      // गलघोंटू भैंस में सबसे जानलेवा
      expect(b.diseases.first.hi, contains('गलघोंटू'));
    });

    test('गाय में थनैला और ब्याने का अंतर — दोनों बड़ी बातें', () {
      final c = palanById('gaay')!;
      expect(c.diseases.first.hi, contains('थनैला'));
      expect(c.production.first.hi, contains('ब्याने का अंतर'));
    });

    test('दोनों के चित्र अलग हैं और मौजूद हैं', () {
      expect(palanImage('gaay'), 'assets/images/3d_cow_profile.webp');
      expect(palanImage('bhains'), 'assets/images/3d_buffalo_profile.webp');
    });

    test('खोज — गाय/gaay/cow/dudh सबसे मिलती है', () {
      final cow = palanById('gaay')!;
      for (final q in ['गाय', 'gaay', 'cow', 'dudh', 'sahiwal']) {
        expect(palanMatches(cow, q), isTrue, reason: q);
      }
      final buf = palanById('bhains')!;
      for (final q in ['भैंस', 'bhains', 'buffalo', 'murrah']) {
        expect(palanMatches(buf, q), isTrue, reason: q);
      }
    });
  });
}
