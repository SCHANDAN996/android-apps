import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// शुभ मुहूर्त की जाँच।
///
/// # 🚧 यह हिस्सा अधूरा है — और ये जाँचें वही बात पक्की रखती हैं
///
/// यहाँ दो तरह की जाँचें हैं:
///
/// **1. जो सही है उसे बाँधने वाली** — खिड़की का गणित, अधिक मास का बहिष्कार,
///    चेतावनियाँ। ये काम कर रहा है और टूटना नहीं चाहिए।
///
/// **2. हालत दर्ज करने वाली** — Drik से कितना मिलता है, यह नाप कर लिख
///    दिया है। **यह "पास" होने वाली जाँच नहीं, नाप है।** जब कोई नियम
///    सुधारे तो यहाँ का आँकड़ा बेहतर होना चाहिए — और तब यह जाँच बताएगी
///    कि सच में सुधार हुआ या सिर्फ़ लगा।

/// Drik की 2026 गृह प्रवेश सूची — दिल्ली, 37 तारीख़ें।
/// drikpanchang.com/shubh-dates/griha-pravesh-dates-with-muhurat.html
const drikGrihaPravesh2026 = [
  '2-6', '2-11', '2-19', '2-20', '2-21', '2-25', '2-26',
  '3-4', '3-5', '3-6', '3-9', '3-13', '3-14',
  '4-20', '5-4', '5-8', '5-13',
  '6-24', '6-26', '6-27', '7-1', '7-2', '7-6',
  '11-11', '11-14', '11-20', '11-21', '11-25', '11-26',
  '12-2', '12-3', '12-4', '12-11', '12-12', '12-18', '12-19', '12-30',
];

void main() {
  group('🚧 हालत — यह फ़ीचर अभी तैयार नहीं', () {
    test('कोड ख़ुद कहता है कि तैयार नहीं है', () {
      // ऐप को यह देखकर ही तय करना है कि दिखाना है या नहीं
      expect(shubhMuhuratIsReady, isFalse);
    });

    test('हर नतीजा ख़ुद को अविश्वसनीय बताता है', () {
      final list = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi);
      expect(list, isNotEmpty);

      for (final din in list.take(5)) {
        expect(din.isReliable, isFalse);
        expect(din.explanation, contains('अधूरी'));
      }
    });

    test('गुरु/शुक्र वाले कामों में चेतावनी आती है', () {
      for (final activity in [
        Activity.grihaPravesh,
        Activity.bhumiPujan,
        Activity.mundan
      ]) {
        final list = shubhDinList(activity, 2026, Place.delhi);
        expect(list, isNotEmpty, reason: ruleFor(activity).name);
        expect(list.first.guruShukraNotChecked, isTrue);
        expect(list.first.explanation, contains('अस्त'));
      }
    });

    test('विवाह का मुहूर्त जान-बूझकर नहीं है', () {
      // गुरु-शुक्र देखे बिना विवाह मुहूर्त बताना ग़लत सलाह होगी
      final ids = activityRules.map((r) => r.name).toList();
      expect(ids, isNot(contains('विवाह')));
    });

    test('Drik से मिलान की नापी हुई हालत', () {
      final hamara = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi)
          .map((d) => '${d.date.month}-${d.date.day}')
          .toSet();
      final drik = drikGrihaPravesh2026.toSet();

      final mile = drik.intersection(hamara).length;
      final chhoote = drik.difference(hamara).length;
      final zyada = hamara.difference(drik).length;

      print('');
      print('  🚧 गृह प्रवेश 2026 — Drik से मिलान');
      print('     मिले $mile / ${drik.length}  ·  छूटे $chhoote  ·  फ़ालतू $zyada');
      print('     (फ़ालतू में ज़्यादातर गुरु/शुक्र अस्त वाले महीनों के हैं)');
      print('     ➜ तैयार माने जाने के लिए: मिले 37, फ़ालतू 0');
      print('');

      // यह "पास" होने वाली शर्त नहीं, आज की हालत है। सुधरे तो यहाँ बदलना।
      expect(mile, greaterThanOrEqualTo(26),
          reason: 'मिलान पहले से बिगड़ा है — कौन सा नियम बदला?');
      expect(zyada, lessThanOrEqualTo(33),
          reason: 'फ़ालतू तारीख़ें बढ़ी हैं — कौन सा नियम ढीला हुआ?');
    });

    test('अगस्त–अक्टूबर की फ़ालतू तारीख़ें अस्त की वजह से हैं', () {
      // Drik में इन महीनों में एक भी तारीख़ नहीं — गुरु/शुक्र अस्त की वजह से।
      // हमारे पास हैं, क्योंकि हम अस्त देख ही नहीं सकते।
      // यह जाँच उसी कमी को दर्ज रखती है।
      final hamara = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi);
      final astaMahine = hamara.where((d) =>
          d.date.month >= 8 && d.date.month <= 10);

      expect(astaMahine, isNotEmpty,
          reason: 'अगर यह ख़ाली हो गया तो शायद अस्त की गणना जुड़ गई — '
              'तब इस जाँच को बदलना होगा');
      expect(drikGrihaPravesh2026.where((d) {
        final m = int.parse(d.split('-')[0]);
        return m >= 8 && m <= 10;
      }), isEmpty, reason: 'Drik में इन महीनों में कुछ नहीं है');
    });
  });

  group('✅ जो सही है और टूटना नहीं चाहिए', () {
    test('मुहूर्त एक खिड़की है, पूरा दिन नहीं', () {
      final list = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi);

      for (final din in list) {
        expect(din.muhurtaStart.isBefore(din.muhurtaEnd), isTrue,
            reason: '${din.date}');

        // खिड़की दिन के उजाले में ही होनी चाहिए
        final p = computePanchang(
            din.date.year, din.date.month, din.date.day, Place.delhi);
        expect(din.muhurtaStart.isBefore(p.sunrise!), isFalse);
        expect(din.muhurtaEnd.isAfter(p.sunset!), isFalse);
      }
    });

    test('खिड़की में तिथि, नक्षत्र और वार तीनों मान्य हैं', () {
      final rule = ruleFor(Activity.grihaPravesh);

      for (final din in shubhDinList(Activity.grihaPravesh, 2026, Place.delhi)) {
        expect(rule.varas, contains(din.date.weekday % 7), reason: '${din.date}');
        expect(rule.nakshatras, contains(nakshatraNames.indexOf(din.nakshatra)),
            reason: '${din.date} — ${din.nakshatra}');

        final index = tithiNames.indexOf(din.tithi);
        final inPaksha = index < 15 ? index + 1 : index - 14;
        expect(rule.tithis, contains(inPaksha),
            reason: '${din.date} — ${din.tithi}');
      }
    });

    test('अधिक मास में एक भी दिन नहीं', () {
      // 2026 में अधिक ज्येष्ठ — 17 मई से 15 जून तक
      for (final activity in Activity.values) {
        for (final din in shubhDinList(activity, 2026, Place.delhi)) {
          final p = computePanchang(
              din.date.year, din.date.month, din.date.day, Place.delhi);
          expect(p.isAdhikaMasa, isFalse,
              reason: '${ruleFor(activity).name} — ${din.date}');
        }
      }
    });

    test('रविवार और मंगलवार गृह प्रवेश में नहीं आते', () {
      for (final din in shubhDinList(Activity.grihaPravesh, 2026, Place.delhi)) {
        final vara = din.date.weekday % 7;
        expect(vara == 0 || vara == 2, isFalse,
            reason: '${din.date} — ${din.vara}');
      }
    });

    test('भद्रा और पंचक की चेतावनियाँ सही लगती हैं', () {
      for (final din in shubhDinList(Activity.grihaPravesh, 2026, Place.delhi)) {
        final p = computePanchang(
            din.date.year, din.date.month, din.date.day, Place.delhi);

        expect(din.cautions.any((c) => c.startsWith('भद्रा')), p.bhadra != null,
            reason: '${din.date} भद्रा');
        expect(din.cautions.contains('पंचक चल रहा है'), p.isPanchak,
            reason: '${din.date} पंचक');
      }
    });

    test('शुभ चौघड़िया मुहूर्त की खिड़की के भीतर ही आती हैं', () {
      for (final din in shubhDinList(Activity.grihaPravesh, 2026, Place.delhi)) {
        for (final slot in din.windows) {
          expect(slot.auspicious, isTrue);
          expect(slot.isDay, isTrue);
          // खिड़की से कम से कम कुछ हिस्सा मिलना चाहिए
          expect(slot.start.isBefore(din.muhurtaEnd), isTrue);
          expect(din.muhurtaStart.isBefore(slot.end), isTrue);
        }
      }
    });

    test('हर काम के लिए कुछ न कुछ दिन निकलते हैं', () {
      for (final activity in Activity.values) {
        final list = shubhDinList(activity, 2026, Place.delhi);
        expect(list, isNotEmpty, reason: ruleFor(activity).name);
        expect(list.length, lessThan(200),
            reason: '${ruleFor(activity).name} — इतने सारे? नियम ढीले हैं');
      }
    });

    test('तारीख़ें क्रम में आती हैं', () {
      final list = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].date.isAfter(list[i - 1].date), isTrue);
      }
    });
  });
}
