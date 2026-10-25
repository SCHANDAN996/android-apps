import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// शुभ मुहूर्त की जाँच।
///
/// # नियम अब दो छपे ग्रंथों से (→ D-148), फिर भी ऐप में बंद
///
/// यहाँ दो तरह की जाँचें हैं:
///
/// **1. ग्रंथ के नियम बाँधने वाली** — मास, अयन, कुम्भ-चक्र, पंचक, संक्रांति,
///    गुरु-शुक्र अस्त। हर एक के पीछे मुहूर्त चिंतामणि और मुहूर्त मार्तण्ड के
///    श्लोक हैं (`docs/18` §४४)। ये टूटनी नहीं चाहिए।
///
/// **2. नाप** — website वाली सूची से कितना मिलता है। **यह "पास" वाली जाँच नहीं।**
///    वह सूची ख़ुद अलग नियम से बनी है (दक्षिणायन में और आषाढ़ में भी गृह प्रवेश देती
///    है, जो दोनों ग्रंथ मना करते हैं) — इसलिए खोलने की कसौटी उससे नहीं बनेगी।

/// एक website की 2026 गृह प्रवेश सूची — दिल्ली, 37 तारीख़ें। सिर्फ़ नाप के लिए।
const drikGrihaPravesh2026 = [
  '2-6', '2-11', '2-19', '2-20', '2-21', '2-25', '2-26',
  '3-4', '3-5', '3-6', '3-9', '3-13', '3-14',
  '4-20', '5-4', '5-8', '5-13',
  '6-24', '6-26', '6-27', '7-1', '7-2', '7-6',
  '11-11', '11-14', '11-20', '11-21', '11-25', '11-26',
  '12-2', '12-3', '12-4', '12-11', '12-12', '12-18', '12-19', '12-30',
];

/// पक्का होने वाले काम — वाहन का नियम दो ग्रंथों में नहीं मिला।
final pakkeKaam = Activity.values.where((a) => ruleFor(a).pakka).toList();

Panchang _p(DateTime d) =>
    computePanchang(d.year, d.month, d.day, Place.delhi,
        masaSystem: MasaSystem.amanta);

void main() {
  // हर काम की 2026 सूची एक बार — हर दिन दो पंचांग, धीमा है
  final suchi = {
    for (final a in Activity.values) a: shubhDinList(a, 2026, Place.delhi),
  };

  group('🚧 हालत — ऐप में अभी बंद', () {
    test('कोड ख़ुद कहता है कि तैयार नहीं है', () {
      expect(shubhMuhuratIsReady, isFalse);
      for (final din in suchi[Activity.grihaPravesh]!) {
        expect(din.isReliable, isFalse);
      }
    });

    test('विवाह का मुहूर्त जान-बूझकर नहीं है', () {
      final ids = activityRules.map((r) => r.name).toList();
      expect(ids, isNot(contains('विवाह')));
    });

    test('वाहन — दो ग्रंथों में नियम नहीं, इसलिए सूची ख़ाली और कारण लिखा', () {
      final rule = ruleFor(Activity.vahan);
      expect(rule.pakka, isFalse);
      expect(suchi[Activity.vahan], isEmpty);
      expect(rule.strot, contains('नहीं मिला'));
    });

    test('website वाली सूची से नाप — दर्ज, कसौटी नहीं', () {
      final hamara = {
        for (final d in suchi[Activity.grihaPravesh]!)
          '${d.date.month}-${d.date.day}',
      };
      final website = drikGrihaPravesh2026.toSet();
      final mile = website.intersection(hamara).length;
      final zyada = hamara.difference(website).length;

      print('');
      print('  गृह प्रवेश 2026 — website सूची से');
      print('     मिले $mile / ${website.length} · फ़ालतू $zyada · '
          'हमारे कुल ${hamara.length}');
      print('     (website दक्षिणायन और दूसरे नक्षत्रों में भी देती है — '
          'दोनों ग्रंथ नहीं)');
      print('');

      // 25 अक्टूबर 2026 की नाप: मिले 5, फ़ालतू 2। नियम बदले तो यहाँ बदलना।
      expect(mile, 5);
      expect(zyada, 2);
    });
  });

  group('📖 ग्रंथ के नियम — टूटने नहीं चाहिए', () {
    test('हर पक्के नियम में दोनों ग्रंथों का नाम है', () {
      for (final a in pakkeKaam) {
        final rule = ruleFor(a);
        expect(rule.strot, contains('मुहूर्त चिंतामणि'), reason: rule.name);
        expect(rule.strot, contains('मुहूर्त मार्तण्ड'), reason: rule.name);
      }
    });

    test('हर पक्के काम के लिए कुछ दिन निकलते हैं', () {
      for (final a in pakkeKaam) {
        expect(suchi[a], isNotEmpty, reason: ruleFor(a).name);
        expect(suchi[a]!.length, lessThan(200), reason: ruleFor(a).name);
      }
    });

    test('खिड़की में तिथि, नक्षत्र और वार तीनों मान्य हैं', () {
      for (final a in pakkeKaam) {
        final rule = ruleFor(a);
        for (final din in suchi[a]!) {
          expect(rule.varas, contains(din.date.weekday % 7),
              reason: '${rule.name} ${din.date}');
          expect(rule.nakshatras, contains(nakshatraNames.indexOf(din.nakshatra)),
              reason: '${rule.name} ${din.date} — ${din.nakshatra}');
          final index = tithiNames.indexOf(din.tithi);
          final inPaksha = index < 15 ? index + 1 : index - 14;
          expect(rule.tithis, contains(inPaksha),
              reason: '${rule.name} ${din.date} — ${din.tithi}');
        }
      }
    });

    test('मास, अयन, पक्ष — ग्रंथ वाले ही', () {
      for (final a in pakkeKaam) {
        final rule = ruleFor(a);
        for (final din in suchi[a]!) {
          final p = _p(din.date);
          expect(p.isAdhikaMasa, isFalse, reason: '${rule.name} ${din.date}');
          if (rule.masas != null) {
            expect(rule.masas, contains(p.masa),
                reason: '${rule.name} ${din.date} — ${p.masaName}');
          }
          if (rule.uttarayanOnly) {
            expect(p.ayana, 0, reason: '${rule.name} ${din.date}');
          }
          if (rule.shuklaOnly) {
            expect(p.paksha, 0, reason: '${rule.name} ${din.date}');
          }
          if (rule.sunNotKumbha) {
            expect(p.sunRashi, isNot(10), reason: '${rule.name} ${din.date}');
          }
        }
      }
    });

    test('गृह प्रवेश — रवि-मंगल नहीं, सिर्फ़ ज्येष्ठ-माघ-फाल्गुन-वैशाख', () {
      for (final din in suchi[Activity.grihaPravesh]!) {
        final p = _p(din.date);
        expect(p.vara == 0 || p.vara == 2, isFalse, reason: '${din.date}');
        expect(['ज्येष्ठ', 'माघ', 'फाल्गुन', 'वैशाख'], contains(p.masaName),
            reason: '${din.date}');
      }
    });

    test('दक्षिणायन में गृह प्रवेश, मुंडन, विद्यारंभ नहीं — अगस्त से दिसंबर ख़ाली', () {
      for (final a in [Activity.grihaPravesh, Activity.mundan, Activity.vidyarambh]) {
        expect(suchi[a]!.where((d) => d.date.month >= 8), isEmpty,
            reason: ruleFor(a).name);
      }
    });

    test('मुंडन — सोमवार सिर्फ़ शुक्ल पक्ष में (मार्तण्ड)', () {
      for (final din in suchi[Activity.mundan]!) {
        final p = _p(din.date);
        if (p.vara == 1) expect(p.paksha, 0, reason: '${din.date}');
      }
    });

    test('भूमि पूजन — पंचक में नहीं, शनिवार मान्य', () {
      expect(ruleFor(Activity.bhumiPujan).varas, contains(6));
      for (final din in suchi[Activity.bhumiPujan]!) {
        expect(_p(din.date).isPanchak, isFalse, reason: '${din.date}');
      }
    });

    test('नामकरण — संक्रांति के दिन नहीं, तीनों उत्तरा मान्य', () {
      final rule = ruleFor(Activity.namkaran);
      for (final n in ['उत्तरा फाल्गुनी', 'उत्तराषाढ़ा', 'उत्तरा भाद्रपदा']) {
        expect(rule.nakshatras, contains(nakshatraNames.indexOf(n)), reason: n);
      }
      for (final din in suchi[Activity.namkaran]!) {
        final kal = din.date.add(const Duration(days: 1));
        expect(_p(din.date).sunRashi, _p(kal).sunRashi, reason: '${din.date}');
      }
    });

    test('विद्यारंभ — त्रयोदशी नहीं (मार्तण्ड), षष्ठी मान्य (चिंतामणि)', () {
      final rule = ruleFor(Activity.vidyarambh);
      expect(rule.tithis, isNot(contains(13)));
      expect(rule.tithis, contains(6));
    });

    test('गुरु-शुक्र के अस्त-काल में एक भी दिन नहीं', () {
      final daur = [
        for (final g in [Graha.guru, Graha.shukra])
          ...grahaAstKaal(g, DateTime.utc(2026, 1, 1), DateTime.utc(2026, 12, 31),
              Place.delhi),
      ];
      for (final a in pakkeKaam.where((a) => ruleFor(a).guruShukraAst)) {
        for (final din in suchi[a]!) {
          for (final d in daur) {
            final bhitar =
                !din.date.isBefore(d.astDin) && !din.date.isAfter(d.udayDin);
            expect(bhitar, isFalse,
                reason: '${ruleFor(a).name} ${din.date} — ${d.graha.name} अस्त');
          }
        }
      }
    });

    test('व्याख्या में नियम का स्रोत और ऐप की सीमा', () {
      for (final a in pakkeKaam) {
        for (final din in suchi[a]!.take(2)) {
          expect(din.explanation, contains('मुहूर्त चिंतामणि'));
          expect(din.explanation, contains('पुरोहित'));
        }
      }
      for (final din in suchi[Activity.grihaPravesh]!) {
        expect(din.explanation, contains('अस्त'));
      }
    });
  });

  group('✅ जो सही है और टूटना नहीं चाहिए', () {
    test('मुहूर्त एक खिड़की है — दिन के उजाले में', () {
      for (final din in suchi[Activity.grihaPravesh]!) {
        expect(din.muhurtaStart.isBefore(din.muhurtaEnd), isTrue,
            reason: '${din.date}');
        final p = _p(din.date);
        expect(din.muhurtaStart.isBefore(p.sunrise!), isFalse);
        expect(din.muhurtaEnd.isAfter(p.sunset!), isFalse);
      }
    });

    test('भद्रा और पंचक की चेतावनियाँ सही लगती हैं', () {
      for (final din in suchi[Activity.namkaran]!) {
        final p = _p(din.date);
        expect(din.cautions.any((c) => c.startsWith('भद्रा')), p.bhadra != null,
            reason: '${din.date} भद्रा');
        expect(din.cautions.contains('पंचक चल रहा है'), p.isPanchak,
            reason: '${din.date} पंचक');
      }
    });

    test('शुभ चौघड़िया मुहूर्त की खिड़की के भीतर ही आती हैं', () {
      for (final din in suchi[Activity.namkaran]!) {
        for (final slot in din.windows) {
          expect(slot.auspicious, isTrue);
          expect(slot.isDay, isTrue);
          expect(slot.start.isBefore(din.muhurtaEnd), isTrue);
          expect(din.muhurtaStart.isBefore(slot.end), isTrue);
        }
      }
    });

    test('तारीख़ें क्रम में आती हैं', () {
      final list = suchi[Activity.namkaran]!;
      for (var i = 1; i < list.length; i++) {
        expect(list[i].date.isAfter(list[i - 1].date), isTrue);
      }
    });
  });
}
