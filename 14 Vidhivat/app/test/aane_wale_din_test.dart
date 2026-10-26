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
        Vidhi.parse(
            '$dir/${e.id}.json', File('$dir/${e.id}.json').readAsStringSync()),
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
      // एक दिन पर दो त्योहार हो सकते हैं (28 अग 2026 — रक्षाबंधन और
      // वरलक्ष्मी व्रत), इसलिए "पहले से पहले नहीं", "ठीक बाद" नहीं।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 10);
      for (var i = 1; i < avsar.length; i++) {
        expect(avsar[i].tarikh.isBefore(avsar[i - 1].tarikh), isFalse,
            reason: '${avsar[i].naam} पिछले से पहले आ गई');
      }
    });

    test('एक दिन पर एक ही तिथि-वार वाली पूजा आती है', () {
      // वरना पूर्णिमा वाले शनिवार को सत्यनारायण और हनुमान दोनों आ जाते।
      // त्योहार अलग बात हैं — एक दिन पर दो सचमुच पड़ें तो दोनों दिखें
      // (→ D-087), और उस दिन कोई तिथि-वार वाली पूजा नहीं जुड़ती।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 12, dinAage: 60);
      final baaki = avsar
          .where((a) => a.karan != AvsarKaKaran.tyohar)
          .map((a) => a.tarikh)
          .toList();
      expect(baaki.toSet(), hasLength(baaki.length));
      final tyoharDin = avsar
          .where((a) => a.karan == AvsarKaKaran.tyohar)
          .map((a) => a.tarikh)
          .toSet();
      expect(baaki.toSet().intersection(tyoharDin), isEmpty);
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

    test('रक्षाबंधन 2026 — 28 अगस्त, अपनी पूजा-विधि से जुड़ा', () {
      // तारीख़ Drik से जाँची हुई है।
      final avsar = aage(DateTime(2026, 8, 26), kitne: 12, dinAage: 10);
      final r = avsar.where((a) => a.naam == 'रक्षाबंधन');
      expect(r, hasLength(1));
      expect(r.first.tarikh, DateTime(2026, 8, 28));
      expect(r.first.pujaId, 'raksha_bandhan_pooja');
      expect(r.first.khulSaktiHai, isTrue);
    });

    test('धनतेरस, गोवर्धन और भाई दूज अपनी-अपनी विधि खोलते हैं', () {
      final avsar = aage(DateTime(2026, 11, 1), kitne: 20, dinAage: 15);
      final expected = {
        'धनतेरस': (DateTime(2026, 11, 6), 'dhanteras'),
        'गोवर्धन पूजा': (DateTime(2026, 11, 10), 'govardhan_annakut'),
        'भाई दूज': (DateTime(2026, 11, 11), 'bhai_dooj_pooja'),
      };
      for (final MapEntry(key: naam, value: (tarikh, id)) in expected.entries) {
        final mila = avsar.where((a) => a.naam == naam).toList();
        expect(mila, hasLength(1), reason: naam);
        expect(mila.single.tarikh, tarikh, reason: naam);
        expect(mila.single.pujaId, id, reason: naam);
        expect(mila.single.khulSaktiHai, isTrue, reason: naam);
      }
    });

    test('वसंत पंचमी 2026 — 23 जनवरी, सरस्वती पूजा से जुड़ी', () {
      final avsar = aage(DateTime(2026, 1, 20), kitne: 10, dinAage: 10);
      final v = avsar.where((a) => a.naam == 'वसंत पंचमी').toList();
      expect(v, hasLength(1));
      expect(v.single.tarikh, DateTime(2026, 1, 23));
      expect(v.single.pujaId, 'saraswati_pooja');
      expect(v.single.khulSaktiHai, isTrue);
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

  group('संक्रांति वाली पूजा — विश्वकर्मा पूजा', () {
    // Drik Panchang: 2024 में 16 सितम्बर (संक्रांति शाम 7:53), 2026 में
    // 17 सितम्बर (सुबह 7:58)। इंजन की अपनी जाँच `engine/test/sankranti_test.dart`।
    test('2026 — 17 सितम्बर, होम वाली गिनती (5 जगह, 45 दिन) में भी', () {
      // 5 सितम्बर से बारह दिन दूर — बीच में हर हफ़्ते वाली पूजाएँ पाँचों
      // जगह भर देती हैं। पुराने नियम (सब तारीख़ से छाँटो, पहले पाँच लो)
      // में यह त्योहार बाहर रह जाता था।
      //
      // (पहले यह 25 अगस्त से जाँचा जाता था। अब इंजन व्रत भी जानता है —
      // 25 अगस्त से पाँच जगहें रक्षाबंधन, वरलक्ष्मी, जन्माष्टमी, तीज और
      // गणेश चतुर्थी से भर जाती हैं; पाँचों असली त्योहार, इसलिए ठीक है।)
      final avsar = aage(DateTime(2026, 9, 5), kitne: 5, dinAage: 45);
      final v = avsar.where((a) => a.naam == 'विश्वकर्मा पूजा');
      expect(v, hasLength(1),
          reason: 'हर हफ़्ते वाली पूजाओं ने त्योहार को बाहर धकेल दिया');
      expect(v.first.tarikh, DateTime(2026, 9, 17));
      expect(v.first.pujaId, 'vishwakarma_pooja');
      expect(v.first.kyon, 'कन्या संक्रांति');
      expect(v.first.karan, AvsarKaKaran.tyohar);
    });

    test('2024 — 16 सितम्बर (संक्रांति शाम को थी, दिन वही)', () {
      final avsar = aage(DateTime(2024, 9, 1), kitne: 12, dinAage: 30);
      final v = avsar.where((a) => a.naam == 'विश्वकर्मा पूजा');
      expect(v, hasLength(1));
      expect(v.first.tarikh, DateTime(2024, 9, 16));
    });

    test('उसी दिन "आज", और अगले दिन से सूची में नहीं', () {
      final aaj = aage(DateTime(2026, 9, 17), kitne: 5, dinAage: 45);
      expect(aaj.first.naam, 'विश्वकर्मा पूजा');
      expect(aaj.first.kabLikha, 'आज');

      final baad = aage(DateTime(2026, 9, 18), kitne: 12, dinAage: 45);
      expect(baad.map((a) => a.naam), isNot(contains('विश्वकर्मा पूजा')));
    });

    test('त्योहार पहले चुने जाते हैं, पर सूची तारीख़ के क्रम में रहती है', () {
      final avsar = aage(DateTime(2026, 9, 10), kitne: 5, dinAage: 45);
      for (var i = 1; i < avsar.length; i++) {
        expect(avsar[i].kitneDinBaad,
            greaterThanOrEqualTo(avsar[i - 1].kitneDinBaad));
      }
    });

    test('हर संक्रांति वाली पूजा सचमुच ऐप में है', () {
      final maujud = pujaayein.map((v) => v.id).toSet();
      for (final puja in sankrantiKiPuja.values) {
        expect(maujud, contains(puja.id), reason: puja.naam);
      }
    });
  });

  group('मकर संक्रांति — स्थानीय सूर्यास्त वाला दिन-नियम', () {
    test('2026 में दिन का प्रवेश — 14 जनवरी को अपनी विधि', () {
      final avsar = aage(DateTime(2026, 1, 10), kitne: 10, dinAage: 10);
      final m = avsar.where((a) => a.naam == 'मकर संक्रांति').toList();
      expect(m, hasLength(1));
      expect(m.single.tarikh, DateTime(2026, 1, 14));
      expect(m.single.pujaId, 'makar_sankranti_pooja');
      expect(m.single.khulSaktiHai, isTrue);
    });

    test('2027 में रात का प्रवेश — पुण्यकाल 15 जनवरी को', () {
      // Drik Delhi: प्रवेश 14 जनवरी 21:14, अवलोकन 15 जनवरी।
      final avsar = aage(DateTime(2027, 1, 10), kitne: 10, dinAage: 10);
      final m = avsar.where((a) => a.naam == 'मकर संक्रांति').toList();
      expect(m, hasLength(1));
      expect(m.single.tarikh, DateTime(2027, 1, 15));
      expect(m.single.pujaId, 'makar_sankranti_pooja');
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
        expect(
            [DateTime.tuesday, DateTime.saturday], contains(a.tarikh.weekday),
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
      ]) {
        expect(ids, isNot(contains(id)),
            reason: '$id का नियम दोहराता नहीं, फिर भी सूची में आ गई');
      }
      // श्राद्ध अब पितृ पक्ष के त्योहार-नियम से आता है (→ D-087) — पर
      // कभी अपनी तिथि या वार से नहीं।
      for (final a in avsar.where((a) => a.pujaId == 'shraadh')) {
        expect(a.karan, AvsarKaKaran.tyohar);
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

  /// पूजा section में त्योहार के कार्डों की तारीख़ (→ D-086)।
  group('हर सालाना त्योहार की अगली तारीख़', () {
    final agli =
        agliTyoharTarikh(place: Place.delhi, aaj: DateTime(2026, 9, 22));

    test('आगे वाली तारीख़ें — दिल्ली, 22 सित 2026 से', () {
      expect(agli['kalash_sthapana'], DateTime(2026, 10, 11));
      expect(agli['dhanteras'], DateTime(2026, 11, 6));
      expect(agli['lakshmi_poojan'], DateTime(2026, 11, 8));
    });

    test('बीत चुका त्योहार अगले साल का दिखता है, पिछला नहीं', () {
      // विश्वकर्मा पूजा 17 सित 2026 को बीत गई
      expect(agli['vishwakarma_pooja']!.year, 2027);
      for (final din in agli.values) {
        expect(din.isBefore(DateTime(2026, 9, 22)), isFalse);
      }
    });

    test('हर महीने वाली पूजाएँ इसमें नहीं', () {
      expect(agli.containsKey('satyanarayan'), isFalse);
      expect(agli.containsKey('hanuman_pooja'), isFalse);
      expect(agli.containsKey('ganesh_poojan'), isTrue,
          reason: 'गणेश चतुर्थी — साल में एक बार वाला त्योहार');
    });
  });

  /// व्रत और पितृ पक्ष — इंजन के नए नियम (→ D-087)।
  group('व्रत और पितृ पक्ष आने वाली पूजाओं में', () {
    PujaAvsar? naamSe(List<PujaAvsar> l, String naam) {
      final mile = l.where((a) => a.naam == naam);
      return mile.isEmpty ? null : mile.first;
    }

    test('पितृ पक्ष से पहले — आरम्भ का दिन, श्राद्ध की विधि के साथ', () {
      final l = aage(DateTime(2026, 9, 22), kitne: 12, dinAage: 30);
      final a = naamSe(l, 'पितृ पक्ष आरम्भ')!;
      expect(a.tarikh, DateTime(2026, 9, 27));
      expect(a.pujaId, 'shraadh');
      // एक पूजा एक बार — अमावस्या अलग से नहीं
      expect(naamSe(l, 'सर्वपितृ अमावस्या'), isNull);
    });

    test('पितृ पक्ष के बीच — "आज" का पत्ता, अमावस्या तक', () {
      final l = aage(DateTime(2026, 9, 30), kitne: 12, dinAage: 30);
      final a = naamSe(l, 'पितृ पक्ष')!;
      expect(a.kitneDinBaad, 0);
      expect(a.pujaId, 'shraadh');
      expect(a.kyon, 'सर्वपितृ अमावस्या तक');
      expect(l.where((x) => x.pujaId == 'shraadh'), hasLength(1));
    });

    test('सर्वपितृ अमावस्या के दिन वही नाम, "आज"', () {
      final l = aage(DateTime(2026, 10, 10), kitne: 12, dinAage: 30);
      final a = naamSe(l, 'सर्वपितृ अमावस्या')!;
      expect(a.kitneDinBaad, 0);
      expect(naamSe(l, 'पितृ पक्ष'), isNull);
    });

    test('पितृ पक्ष से महीनों पहले "आज" वाला पत्ता नहीं', () {
      final l = aage(DateTime(2026, 6, 1), kitne: 12, dinAage: 45);
      expect(naamSe(l, 'पितृ पक्ष'), isNull);
    });

    test('एक दिन पर दो त्योहार — रक्षाबंधन और वरलक्ष्मी व्रत, दोनों', () {
      final l = aage(DateTime(2026, 8, 20), kitne: 12, dinAage: 20);
      expect(naamSe(l, 'रक्षाबंधन')!.tarikh, DateTime(2026, 8, 28));
      expect(naamSe(l, 'वरलक्ष्मी व्रत')!.tarikh, DateTime(2026, 8, 28));
    });

    test('करवा चौथ और छठ अपनी विधि खोलते हैं', () {
      final l = aage(DateTime(2026, 10, 20), kitne: 12, dinAage: 30);
      expect(naamSe(l, 'करवा चौथ')!.pujaId, 'karwa_chauth');
      expect(naamSe(l, 'करवा चौथ')!.tarikh, DateTime(2026, 10, 29));
      expect(naamSe(l, 'छठ पूजा')!.pujaId, 'chhath_pooja');
    });

    test('दशहरा अलग पत्ता नहीं बनता — वो नवरात्रि पर्व का दिन है', () {
      final l = aage(DateTime(2026, 10, 1), kitne: 20, dinAage: 45);
      expect(naamSe(l, 'दशहरा'), isNull);
    });

    test('व्रतों की अगली तारीख़ें भी', () {
      final agli =
          agliTyoharTarikh(place: Place.delhi, aaj: DateTime(2026, 9, 22));
      expect(agli['shraadh'], DateTime(2026, 9, 27));
      expect(agli['karwa_chauth'], DateTime(2026, 10, 29));
      expect(agli['chhath_pooja'], DateTime(2026, 11, 15));
      expect(agli['vat_savitri']!.year, 2027);
    });
  });

  /// 22 सित 2026, फ़ोन पर: "शिवरात्रि … 3 दिन बाद · चतुर्दशी" — वह शुक्ल
  /// चतुर्दशी थी, और पढ़ने में महाशिवरात्रि लगती थी।
  group('मासिक शिवरात्रि', () {
    test('शुक्ल चतुर्दशी को शिव अभिषेक नहीं — अगली कृष्ण चतुर्दशी को', () {
      final l = aage(DateTime(2026, 9, 22), kitne: 12, dinAage: 30);
      final shiv = l.where((a) => a.pujaId == 'rudrabhishek').toList();
      expect(shiv, hasLength(1));
      expect(shiv.single.tarikh, isNot(DateTime(2026, 9, 25)));
      expect(shiv.single.kyon, 'मासिक शिवरात्रि');
      final p = computePanchang(shiv.single.tarikh.year,
          shiv.single.tarikh.month, shiv.single.tarikh.day, Place.delhi);
      expect(p.tithi.number, 29, reason: 'कृष्ण चतुर्दशी');
    });

    test('हर महीने वाली पूजा के नीचे पक्ष या मासिक नाम', () {
      expect(maasikKyon(29, 'कृष्ण', 'चतुर्दशी'), 'मासिक शिवरात्रि');
      expect(maasikKyon(19, 'कृष्ण', 'चतुर्थी'), 'संकष्टी चतुर्थी');
      expect(maasikKyon(4, 'शुक्ल', 'चतुर्थी'), 'विनायक चतुर्थी');
      expect(maasikKyon(9, 'शुक्ल', 'नवमी'), 'शुक्ल नवमी');
      expect(maasikKyon(15, 'शुक्ल', 'पूर्णिमा'), 'पूर्णिमा');
    });
  });

  /// न विधि, न व्रत-पन्ना — ग्रंथालय का ग्रंथ खुलता है (→ D-153)।
  group('ग्रंथ वाले त्योहार', () {
    test(
        'हर नाम इंजन का त्योहार है, हर ग्रंथ सचमुच है, और विधि/व्रत से टकराव नहीं',
        () {
      final naam = {for (final r in festivalRules) r.name};
      for (final e in tyoharKaGranth.entries) {
        expect(naam, contains(e.key), reason: '"${e.key}" इंजन में नहीं');
        expect(Directory('assets/granth/${e.value}').existsSync(), isTrue,
            reason: '"${e.key}" का ग्रंथ ${e.value} नहीं है');
        // विधि या व्रत-पन्ना हो तो वही खुलता है — ग्रंथ वाला नक़्शा बेकार रहता
        expect(tyoharKiPuja.containsKey(e.key), isFalse, reason: e.key);
        expect(tyoharKaVrat.containsKey(e.key), isFalse, reason: e.key);
      }
    });

    test('2026 — गीता जयंती 20 दिसंबर, और उसका पत्ता गीता खोलता है', () {
      final l = aage(DateTime(2026, 12, 15), kitne: 12, dinAage: 10);
      final g = l.where((a) => a.naam == 'गीता जयंती').single;
      expect(g.tarikh, DateTime(2026, 12, 20));
      expect(g.granthKhulega, isTrue);
      expect(g.granthId, 'gita');
      expect(g.khulSaktiHai, isFalse);
      expect(g.vratKhulega, isFalse);
      // बिना पन्ने वाला त्योहार वैसे ही रहे — खुलता नहीं
      final datta = l.where((a) => a.naam == 'दत्तात्रेय जयंती').single;
      expect(datta.granthKhulega, isFalse);
    });
  });

  /// विधि नहीं, व्रत-पन्ना खुलता है (→ D-130, D-140)।
  group('व्रत-पन्ने वाले त्योहार', () {
    test('हर नाम इंजन का त्योहार है, और हर पन्ना सचमुच है', () {
      final naam = {for (final r in festivalRules) r.name};
      for (final e in tyoharKaVrat.entries) {
        expect(naam, contains(e.key), reason: '"${e.key}" इंजन में नहीं');
        expect(File('assets/vrat/${e.value}.json').existsSync(), isTrue,
            reason: '"${e.key}" का पन्ना ${e.value} नहीं है');
      }
    });

    test('2026 — तुलसी विवाह 21 नव; 24 नव को एक ही पत्ता, दो नाम होते हुए भी',
        () {
      final l = aage(DateTime(2026, 11, 18), kitne: 12, dinAage: 10);
      final tulsi = l.where((a) => a.vratId == 'tulsi_vivah').single;
      expect(tulsi.tarikh, DateTime(2026, 11, 21));
      expect(tulsi.vratKhulega, isTrue);
      // देव दीपावली और कार्तिक पूर्णिमा, दोनों 24 को — पन्ना एक
      final kartik = l.where((a) => a.vratId == 'kartik_purnima').toList();
      expect(kartik, hasLength(1));
      expect(kartik.single.tarikh, DateTime(2026, 11, 24));
      expect(kartik.single.naam, 'कार्तिक पूर्णिमा');
    });

    // → D-154: 2026 में नरक चतुर्दशी और दीपावली एक ही दिन (8 नव)
    test('2026 — नरक चतुर्दशी 8 नव, उसका पत्ता व्रत-पन्ना खोलता है', () {
      final l = aage(DateTime(2026, 11, 5), kitne: 12, dinAage: 5);
      final narak = l.where((a) => a.naam == 'नरक चतुर्दशी').single;
      expect(narak.tarikh, DateTime(2026, 11, 8));
      expect(narak.vratId, 'narak_chaturdashi');
      expect(narak.vratKhulega, isTrue);
    });

    test(
        '2026 — गोपाष्टमी 17 नव, आँवला नवमी 18 नव: दोनों पत्ते व्रत-पन्ने खोलते हैं',
        () {
      final l = aage(DateTime(2026, 11, 15), kitne: 12, dinAage: 5);
      final gopa = l.where((a) => a.naam == 'गोपाष्टमी').single;
      final aanwla = l.where((a) => a.naam == 'आँवला नवमी').single;
      expect(
          (gopa.tarikh, gopa.vratId), (DateTime(2026, 11, 17), 'gopashtami'));
      expect((aanwla.tarikh, aanwla.vratId),
          (DateTime(2026, 11, 18), 'akshaya_navami'));
      expect(gopa.vratKhulega && aanwla.vratKhulega, isTrue);
    });

    // → D-155
    test('2027 — होलिका दहन 21 मार्च, अक्षय तृतीया 9 मई: व्रत-पन्ने खुलते हैं',
        () {
      final holi = aage(DateTime(2027, 3, 18), kitne: 12, dinAage: 5)
          .where((a) => a.naam == 'होलिका दहन')
          .single;
      expect(
          (holi.tarikh, holi.vratId), (DateTime(2027, 3, 21), 'holika_dahan'));
      final akshaya = aage(DateTime(2027, 5, 6), kitne: 12, dinAage: 5)
          .where((a) => a.naam == 'अक्षय तृतीया')
          .single;
      expect((akshaya.tarikh, akshaya.vratId),
          (DateTime(2027, 5, 9), 'akshaya_tritiya'));
      expect(holi.vratKhulega && akshaya.vratKhulega, isTrue);
    });

    test('2027 — दीपदान की शाम 13 नव, स्नान-दान 14 नव: दोनों पत्ते', () {
      final l = aage(DateTime(2027, 11, 12), kitne: 12, dinAage: 5);
      final kartik = l.where((a) => a.vratId == 'kartik_purnima').toList();
      expect([
        for (final a in kartik) (a.tarikh, a.naam)
      ], [
        (DateTime(2027, 11, 13), 'देव दीपावली'),
        (DateTime(2027, 11, 14), 'कार्तिक पूर्णिमा'),
      ]);
    });
  });
}
