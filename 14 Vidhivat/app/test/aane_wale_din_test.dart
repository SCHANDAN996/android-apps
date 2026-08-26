@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:vidhivat/vidhi/aane_wale_din.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

/// आने वाली पूजाओं की जाँच।
///
/// यह सूची **पूरी तरह गणित से बनती है** — एक भी तारीख़ हाथ से नहीं भरी।
/// इसलिए जाँच भी असली JSON और असली पंचांग इंजन से चलती है, नक़ली डेटा से
/// नहीं। तारीख़ें तय (2026) रखी हैं ताकि जाँच कल भी वही नतीजा दे।
void main() {
  const dir = 'assets/vidhi';
  late List<Vidhi> pujaayein;

  setUpAll(() {
    final suchi = VidhiSuchiEntry.parseAll(
      '$dir/_suchi.json',
      File('$dir/_suchi.json').readAsStringSync(),
    );
    pujaayein = [
      for (final e in suchi.where((e) => e.taiyar))
        Vidhi.parse('$dir/${e.id}.json',
            File('$dir/${e.id}.json').readAsStringSync()),
    ];
  });

  List<PujaAvsar> aage(DateTime aaj, {int kitne = 6, int dinAage = 30}) =>
      aaneWaliPujaayein(
        pujaayein: pujaayein,
        place: Place.delhi,
        masaSystem: MasaSystem.purnimanta,
        aaj: aaj,
        kitne: kitne,
        dinAage: dinAage,
      );

  group('सूची बनती है और क्रम में रहती है', () {
    test('कुछ न कुछ मिलता ही है', () {
      final avsar = aage(DateTime(2026, 8, 26));
      expect(avsar, isNotEmpty);
      expect(avsar.length, lessThanOrEqualTo(6));
    });

    test('तारीख़ें बढ़ते क्रम में हैं', () {
      final avsar = aage(DateTime(2026, 8, 26), kitne: 10);
      for (var i = 1; i < avsar.length; i++) {
        expect(avsar[i].tarikh.isAfter(avsar[i - 1].tarikh), isTrue,
            reason: '${avsar[i].naam} पिछले से पहले आ गई');
      }
    });

    test('एक दिन पर एक ही पूजा आती है', () {
      // वरना पूर्णिमा वाले शनिवार को सत्यनारायण और हनुमान दोनों आ जाते।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 12, dinAage: 60);
      final tarikhein = avsar.map((a) => a.tarikh).toList();
      expect(tarikhein.toSet(), hasLength(tarikhein.length));
    });

    test('कोई भी अवसर आज से पहले का नहीं', () {
      final aaj = DateTime(2026, 8, 26);
      for (final a in aage(aaj, kitne: 10)) {
        expect(a.kitneDinBaad, greaterThanOrEqualTo(0));
        expect(a.tarikh.isBefore(aaj), isFalse);
      }
    });
  });

  group('त्योहार इंजन से आते हैं, हाथ से नहीं', () {
    test('दीपावली 2026 — 8 नवम्बर को, और लक्ष्मी पूजन से जुड़ी', () {
      // यह तारीख़ Drik से जाँची हुई है (→ docs/08_VERIFICATION.md 7.5)।
      final avsar = aage(DateTime(2026, 11, 1), kitne: 12, dinAage: 20);
      final deepavali = avsar.where((a) => a.naam == 'दीपावली');
      expect(deepavali, hasLength(1));
      expect(deepavali.first.tarikh, DateTime(2026, 11, 8));
      expect(deepavali.first.pujaId, 'lakshmi_poojan');
      expect(deepavali.first.karan, AvsarKaKaran.tyohar);
    });

    test('जन्माष्टमी 2026 — 4 सितम्बर, कृष्ण पूजा से जुड़ी', () {
      final avsar = aage(DateTime(2026, 9, 1), kitne: 12, dinAage: 15);
      final j = avsar.where((a) => a.naam == 'जन्माष्टमी');
      expect(j, hasLength(1));
      expect(j.first.tarikh, DateTime(2026, 9, 4));
      expect(j.first.pujaId, 'krishna_pooja');
    });

    test('जिस त्योहार की विधि नहीं है वो दिखता तो है, खुलता नहीं', () {
      // रक्षाबंधन 2026 — 28 अगस्त (Drik से जाँचा हुआ)। उसकी अपनी विधि
      // अभी नहीं बनी, इसलिए तारीख़ दिखेगी पर पन्ना नहीं खुलेगा।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 12, dinAage: 10);
      final r = avsar.where((a) => a.naam == 'रक्षाबंधन');
      expect(r, hasLength(1));
      expect(r.first.pujaId, isEmpty);
      expect(r.first.khulSaktiHai, isFalse);
    });

    test('हर जुड़ी हुई पूजा सचमुच ऐप में मौजूद है', () {
      // ग़लत id लिखी तो अवसर चुपचाप बिना पन्ने का रह जाएगा।
      final maujud = pujaayein.map((v) => v.id).toSet();
      for (final entry in tyoharKiPuja.entries) {
        expect(maujud, contains(entry.value),
            reason: '"${entry.key}" जिस पूजा से जुड़ी है वो है ही नहीं');
      }
    });
  });

  group('तिथि और वार वाली पूजाएँ', () {
    test('पूर्णिमा पर सत्यनारायण आती है', () {
      // 26 अगस्त 2026 के बाद पहली पूर्णिमा।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 20, dinAage: 40);
      final s = avsar.where((a) => a.pujaId == 'satyanarayan');
      expect(s, isNotEmpty, reason: 'चालीस दिन में एक पूर्णिमा तो आएगी');
      expect(s.first.karan, AvsarKaKaran.tithi);
      expect(s.first.kyon, 'पूर्णिमा');
    });

    test('हनुमान पूजा मंगल या शनि को ही आती है', () {
      final avsar = aage(DateTime(2026, 8, 26), kitne: 20, dinAage: 40);
      for (final a in avsar.where((a) => a.pujaId == 'hanuman_pooja')) {
        expect([DateTime.tuesday, DateTime.saturday],
            contains(a.tarikh.weekday),
            reason: '${a.tarikh} मंगल या शनि नहीं है');
      }
    });

    test('रोज़ वाली पूजाएँ इस सूची में नहीं आतीं', () {
      // नित्य पूजा, सूर्य अर्घ्य और तुलसी में तिथि-वार दोनों ख़ाली हैं।
      // वे आ जातीं तो हर दिन तीन पंक्तियाँ भर जातीं।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 20, dinAage: 40);
      final ids = avsar.map((a) => a.pujaId).toSet();
      expect(ids, isNot(contains('nitya_pooja')));
      expect(ids, isNot(contains('surya_arghya')));
      expect(ids, isNot(contains('tulsi_pooja')));
    });

    test('गणेश चतुर्थी हर मंगलवार को नहीं दिखती', () {
      // गणेश की JSON में तिथि [4,19] और वार [2,3] दोनों हैं। वार वाला
      // रास्ता तभी चलना चाहिए जब तिथि का बंधन न हो — वरना हर मंगल-बुध
      // को गणेश पूजन आ जाता।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 20, dinAage: 40);
      for (final a in avsar.where((a) => a.pujaId == 'ganesh_poojan')) {
        expect(a.karan, isNot(AvsarKaKaran.vaar),
            reason: 'गणेश चतुर्थी या त्योहार से आनी चाहिए, हर मंगलवार नहीं');
      }
    });

    test('एक पूजा सूची में एक ही बार आती है', () {
      // हनुमान हर मंगल-शनि पड़ती है। हर बार दिखाई जाती तो पाँच पंक्तियों
      // में दीपावली के लिए जगह ही न बचती।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 12, dinAage: 60);
      final ids = avsar.where((a) => a.khulSaktiHai).map((a) => a.pujaId);
      expect(ids.toSet(), hasLength(ids.length));
    });
  });

  group('जो नियम दोहराता नहीं, वो सूची में नहीं आता', () {
    // यह बग फ़ोन पर दिखा था: "आज — गृह प्रवेश · बुधवार"। गृह प्रवेश हर
    // बुधवार को नहीं होता — उसका vaarSuchi सिर्फ़ यह बताता है कि कौन से
    // वार शुभ माने जाते हैं, और असली तारीख़ पंडित जी तय करते हैं (D-019)।

    test('गृह प्रवेश, मुंडन, उपनयन और वाहन पूजा नहीं आतीं', () {
      final avsar = aage(DateTime(2026, 8, 26), kitne: 25, dinAage: 60);
      final ids = avsar.map((a) => a.pujaId).toSet();
      for (final id in [
        'grih_pravesh',
        'mundan',
        'upanayan',
        'vahan_pooja',
        'shraadh',
      ]) {
        expect(ids, isNot(contains(id)),
            reason: '$id का नियम दोहराता नहीं, फिर भी सूची में आ गई');
      }
    });

    test('करवा चौथ हर कृष्ण चतुर्थी को नहीं दिखती', () {
      // साल में एक बार होती है, पर कृष्ण चतुर्थी हर महीने आती है।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 25, dinAage: 60);
      expect(avsar.map((a) => a.pujaId), isNot(contains('karwa_chauth')));
    });

    test('जो दोहराती हैं वे आती हैं', () {
      final avsar = aage(DateTime(2026, 8, 26), kitne: 25, dinAage: 60);
      final ids = avsar.map((a) => a.pujaId).toSet();
      expect(ids, contains('hanuman_pooja'));
      expect(ids, contains('satyanarayan'));
    });

    test('हर पूजा पर dohrata लिखा है', () {
      // यह खाना ज़रूरी है — भूलने पर फ़ाइल पढ़ी ही नहीं जाएगी, पर यह
      // जाँच बताती है कि फ़ैसला सोच-समझकर लिया गया।
      for (final v in pujaayein) {
        expect(v.kabKarein.dohrata, isA<bool>());
      }
    });
  });

  group('कब लिखा जाता है', () {
    test('आज, कल, परसों और उसके बाद', () {
      PujaAvsar banao(int din) => PujaAvsar(
            tarikh: DateTime(2026, 8, 26).add(Duration(days: din)),
            pujaId: 'x',
            naam: 'x',
            kyon: 'x',
            karan: AvsarKaKaran.tithi,
            kitneDinBaad: din,
          );
      for (final (din, likha) in [
        (0, 'आज'),
        (1, 'कल'),
        (2, 'परसों'),
        (12, '12 दिन बाद'),
      ]) {
        expect(banao(din).kabLikha, likha);
      }
    });
  });
}
