import 'package:panchang_engine/panchang_engine.dart';
import 'package:panchang_engine/src/avakahada_data.dart';
import 'package:test/test.dart';

/// अवकहड़ा और गुण मिलान (→ D-110, docs/29 चरण K4)।
///
/// ⚠️ **ये जाँचें तालिकाओं की हैं, खगोल की नहीं** — चंद्रमा कहाँ था, यह
/// `kundali_test` और `graha_test` देखते हैं। यहाँ देखा जाता है कि
///
/// 1. तालिकाएँ भीतर से ठीक हैं (गिनती, सममिति, महावैर के सात जोड़े);
/// 2. जो अंक नियम से निकलते हैं वे **छपी तालिकाओं** से खाना-दर-खाना मिलते हैं
///    (नीचे की तालिकाएँ 1932 की छपी पुस्तक के पन्नों से दोबारा टाइप की गई
///    हैं — `tools/banao_avakahada.py` वाली प्रति से अलग, ताकि एक की भूल दूसरी
///    पकड़े);
/// 3. एक आधुनिक पाठ्य-पुस्तिका का **हल किया हुआ उदाहरण** ज्यों का त्यों आता है।
///
/// घर के पंचांग की मेलापक सारणी से मिलान **नहीं हुआ** — वह डेवलपर के पास है।
void main() {
  /// नक्षत्र (0 = अश्विनी) के चरण (1–4) के बीच का देशांतर।
  double chandra(int nakshatra, int charan) =>
      (nakshatra * 4 + charan - 0.5) * (360.0 / 108.0);

  int nak(String naam) => nakshatraNames.indexOf(naam);

  group('नाम का अक्षर — शतपद चक्र', () {
    test('108 चरण, 108 अलग अक्षर; अभिजित के चार और', () {
      final sab = <String>{};
      for (var n = 0; n < 27; n++) {
        for (var c = 1; c <= 4; c++) {
          sab.add(avakahada(chandra(n, c)).naamAkshar);
        }
      }
      expect(sab, hasLength(108));
      expect({...sab, ...abhijitAksharData}, hasLength(112));
    });

    test('पुस्तकों के जाने-पहचाने अक्षर', () {
      String a(String n, int c) => avakahada(chandra(nak(n), c)).naamAkshar;
      expect([for (var c = 1; c <= 4; c++) a('अश्विनी', c)],
          ['चू', 'चे', 'चो', 'ला']);
      expect([for (var c = 1; c <= 4; c++) a('रेवती', c)],
          ['दे', 'दो', 'चा', 'ची']);
      // दोनों पुस्तकों का उदाहरण: मृगशिरा का तीसरा चरण — "क" से नाम
      expect(a('मृगशिरा', 3), 'का');
      expect([for (var c = 1; c <= 4; c++) a('हस्त', c)], ['पू', 'ष', 'ण', 'ठ']);
    });

    test('चक्र का नाम अपने अक्षरों से: अ-व-क-ह-ड', () {
      String a(String n, int c) => avakahada(chandra(nak(n), c)).naamAkshar;
      expect(a('कृत्तिका', 1), 'अ');
      expect(a('रोहिणी', 2), 'वा');
      expect(a('मृगशिरा', 3), 'का');
      expect(a('पुनर्वसु', 3), 'हा');
      expect(a('पुष्य', 4), 'डा');
    });

    test('ङ, ण, ञ की जगह ग, ड, ज — पुस्तक का नियम', () {
      final ardra3 = avakahada(chandra(nak('आर्द्रा'), 3));
      expect(ardra3.naamAkshar, 'ङ');
      expect(ardra3.naamAksharKiJagah, 'ग');
      expect(avakahada(chandra(nak('हस्त'), 3)).naamAksharKiJagah, 'ड');
      expect(avakahada(chandra(nak('उत्तरा भाद्रपदा'), 4)).naamAksharKiJagah, 'ज');
      expect(avakahada(chandra(0, 1)).naamAksharKiJagah, isNull);
    });

    test('अभिजित — 276°40′ से 280°53′20″ के भीतर ही, चार बराबर चरण', () {
      expect(avakahada(276.6).abhijitAkshar, isNull);
      expect(avakahada(276.7).abhijitAkshar, 'जू');
      expect(avakahada(278.0).abhijitAkshar, 'जे');
      expect(avakahada(279.0).abhijitAkshar, 'जो');
      expect(avakahada(280.5).abhijitAkshar, 'खा');
      expect(avakahada(280.9).abhijitAkshar, isNull);
      // उसी जगह का मुख्य अक्षर 27 नक्षत्रों वाला ही रहता है
      expect(avakahada(278.0).naamAkshar, 'जी'); // उत्तराषाढ़ा, चरण 4
      expect(avakahada(280.5).naamAkshar, 'खी'); // श्रवण, चरण 1
    });
  });

  group('नक्षत्र और राशि की तालिकाएँ', () {
    test('हर गण और हर नाड़ी में नौ-नौ नक्षत्र', () {
      for (final g in Gana.values) {
        expect(nakshatraGanaData.where((x) => x == g.index), hasLength(9));
      }
      for (final n in Nadi.values) {
        expect(nakshatraNadiData.where((x) => x == n.index), hasLength(9));
      }
    });

    test('मुहूर्तचिंतामणि के श्लोकों वाले नक्षत्र', () {
      Avakahada a(String n) => avakahada(chandra(nak(n), 1));
      // २९: रक्षोगण — मघा, आश्लेषा, धनिष्ठा, ज्येष्ठा, मूल, शतभिषा, कृत्तिका,
      // चित्रा, विशाखा
      for (final n in [
        'मघा', 'आश्लेषा', 'धनिष्ठा', 'ज्येष्ठा', 'मूल', 'शतभिषा', 'कृत्तिका',
        'चित्रा', 'विशाखा',
      ]) {
        expect(a(n).gana, Gana.rakshas, reason: n);
      }
      // ३४: एक नाड़ी — ज्येष्ठा, आर्द्रा, उत्तरा फाल्गुनी, शतभिषा और हर एक का
      // अगला; और अश्विनी
      for (final n in [
        'ज्येष्ठा', 'मूल', 'आर्द्रा', 'पुनर्वसु', 'उत्तरा फाल्गुनी', 'हस्त',
        'शतभिषा', 'पूर्वा भाद्रपदा', 'अश्विनी',
      ]) {
        expect(a(n).nadi, Nadi.adi, reason: n);
      }
      // २५–२६: योनि के जोड़े
      expect(a('अश्विनी').yoni, Yoni.ashva);
      expect(a('शतभिषा').yoni, Yoni.ashva);
      expect(a('स्वाति').yoni, Yoni.mahish);
      expect(a('हस्त').yoni, Yoni.mahish);
      expect(a('पुष्य').yoni, Yoni.mesh);
      expect(a('कृत्तिका').yoni, Yoni.mesh);
      expect(a('उत्तराषाढ़ा').yoni, Yoni.nakul);
      expect(a('उत्तरा फाल्गुनी').yoni, Yoni.gau);
      expect(a('उत्तरा भाद्रपदा').yoni, Yoni.gau);
    });

    test('वर्ण — जल राशियाँ, फिर अग्नि, पृथ्वी, वायु', () {
      Varna v(int rashi) => avakahada(rashi * 30.0 + 5).varna;
      expect([v(3), v(7), v(11)], everyElement(Varna.brahman));
      expect([v(0), v(4), v(8)], everyElement(Varna.kshatriya));
      expect([v(1), v(5), v(9)], everyElement(Varna.vaishya));
      expect([v(2), v(6), v(10)], everyElement(Varna.shudra));
    });

    test('राशि के स्वामी', () {
      expect([for (var r = 0; r < 12; r++) rashiSwami(r).naam], [
        'मंगल', 'शुक्र', 'बुध', 'चंद्र', 'सूर्य', 'बुध', 'शुक्र', 'मंगल', 'गुरु',
        'शनि', 'शनि', 'गुरु',
      ]);
    });

    test('वश्य — धनु और मकर आधे-आधे; तीन राशियों पर पुरानी गिनती अलग', () {
      Avakahada a(int rashi, double ansh) => avakahada(rashi * 30.0 + ansh);
      expect(a(8, 10).vashya, Vashya.manav);
      expect(a(8, 20).vashya, Vashya.chatushpad);
      expect(a(9, 10).vashya, Vashya.chatushpad);
      expect(a(9, 20).vashya, Vashya.jalchar);
      expect(a(4, 10).vashya, Vashya.vanchar);
      expect(a(7, 10).vashya, Vashya.keet);

      expect(a(3, 10).vashya, Vashya.jalchar);
      expect(a(3, 10).vashyaPurana, Vashya.keet);
      expect(a(10, 10).vashya, Vashya.manav);
      expect(a(10, 10).vashyaPurana, Vashya.jalchar);
      expect(a(4, 10).vashyaPurana, Vashya.chatushpad);
      expect(a(0, 10).vashyaPurana, isNull);
    });
  });

  group('गुण — नियम और छपी तालिका एक', () {
    test('ग्रह मैत्री — 1932 की छपी 7×7 तालिका का हर खाना', () {
      const h = 0.5;
      // क्रम: सूर्य, चंद्र, मंगल, बुध, गुरु, शुक्र, शनि
      const chhapi = [
        [5, 5, 5, 4, 5, 0, 0],
        [5, 5, 4, 1, 4, h, h],
        [5, 4, 5, h, 5, 3, h],
        [4, 1, h, 5, h, 5, 4],
        [5, 4, 5, h, 5, h, 3],
        [0, h, 3, 5, h, 5, 5],
        [0, h, h, 4, 3, 5, 5],
      ];
      for (var i = 0; i < 7; i++) {
        for (var j = 0; j < 7; j++) {
          expect(
            grahaMaitriAnk(KundaliGraha.values[i], KundaliGraha.values[j]),
            chhapi[i][j],
            reason: '${KundaliGraha.values[i].naam}–${KundaliGraha.values[j].naam}',
          );
        }
      }
    });

    test('तारा — 3, 5, 7 अलग; छपी तालिका की तीन पंक्तियाँ', () {
      // एक नक्षत्र से गिनें तो वही नक्षत्र पहला, दसवाँ फिर पहला
      expect(tara(0, 0), 1);
      expect(tara(0, 8), 9);
      expect(tara(0, 9), 1);
      // पाठ्य-पुस्तिका का उदाहरण: उत्तरा फाल्गुनी से रोहिणी तक 20 → शेष 2
      expect(tara(nak('उत्तरा फाल्गुनी'), nak('रोहिणी')), 2);

      // [कन्या की तारा][वर की तारा] — तारा 1, 3 और 9 वाली पंक्तियाँ
      const pankti = {
        1: [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
        3: [1.5, 1.5, 0, 1.5, 0, 1.5, 0, 1.5, 1.5],
        9: [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
      };
      // वर को अश्विनी पर थामकर: कन्या का नक्षत्र k हो तो
      //   वर की तारा (कन्या से गिनी)  = tara(k, 0)
      //   कन्या की तारा (वर से गिनी) = tara(0, k)
      for (var k = 0; k < 27; k++) {
        final kanyaTara = tara(0, k);
        final varTara = tara(k, 0);
        final row = pankti[kanyaTara];
        if (row == null) continue;
        expect(taraAnk(0, k), row[varTara - 1], reason: 'कन्या का नक्षत्र $k');
      }
    });

    test('भकूट — छपी तालिका की तीन पंक्तियाँ (कन्या मेष, वृष, कुंभ)', () {
      const pankti = {
        0: [7, 0, 7, 7, 0, 0, 7, 0, 0, 7, 7, 0],
        1: [0, 7, 0, 7, 7, 0, 0, 7, 0, 0, 7, 7],
        10: [7, 7, 0, 0, 7, 0, 0, 7, 7, 0, 7, 0],
      };
      pankti.forEach((kanya, row) {
        for (var v = 0; v < 12; v++) {
          expect(bhakootAnk(v, kanya), row[v], reason: 'कन्या $kanya, वर $v');
        }
      });
      // किसी भी ओर से गिनो, अंक वही
      for (var a = 0; a < 12; a++) {
        for (var b = 0; b < 12; b++) {
          expect(bhakootAnk(a, b), bhakootAnk(b, a));
        }
      }
    });

    test('योनि की दोनों तालिकाएँ — सममित, अपनी योनि 4, महावैर के सात जोड़े 0', () {
      const mahavair = [
        (Yoni.ashva, Yoni.mahish),
        (Yoni.gaj, Yoni.simha),
        (Yoni.mesh, Yoni.vanar),
        (Yoni.sarp, Yoni.nakul),
        (Yoni.shvan, Yoni.mrig),
        (Yoni.marjar, Yoni.mushak),
        (Yoni.gau, Yoni.vyaghra),
      ];
      bool vair(int i, int j) => mahavair.any((p) =>
          (p.$1.index == i && p.$2.index == j) ||
          (p.$1.index == j && p.$2.index == i));
      for (final t in [yoniAnkPrachalitData, yoniAnkPuraniData]) {
        expect(t, hasLength(14));
        for (var i = 0; i < 14; i++) {
          expect(t[i], hasLength(14));
          expect(t[i][i], 4);
          for (var j = 0; j < 14; j++) {
            expect(t[i][j], t[j][i]);
            if (i != j) expect(t[i][j] == 0, vair(i, j));
          }
        }
      }
    });

    test('गण — दोनों तालिकाओं में एक ही खाना अलग', () {
      var alag = 0;
      for (var k = 0; k < 3; k++) {
        for (var v = 0; v < 3; v++) {
          if (ganaAnkPrachalitData[k][v] != ganaAnkPuraniData[k][v]) alag++;
        }
      }
      expect(alag, 1);
      // कन्या मनुष्य, वर देव
      expect(ganaAnkPrachalitData[Gana.manushya.index][Gana.dev.index], 6);
      expect(ganaAnkPuraniData[Gana.manushya.index][Gana.dev.index], 5);
    });
  });

  group('गुण मिलान — पूरा जोड़', () {
    test('पाठ्य-पुस्तिका का हल किया उदाहरण: वर उत्तरा फाल्गुनी (सिंह), कन्या रोहिणी',
        () {
      final m = gunMilan(
        varChandra: chandra(nak('उत्तरा फाल्गुनी'), 1), // सिंह में
        kanyaChandra: chandra(nak('रोहिणी'), 2),
      );
      expect(m.vara.rashi, 4);
      expect(m.kanya.rashi, 1);

      // पुस्तिका: क्षत्रिय वर, वैश्य कन्या → 1
      expect(m[Koot.varna].varKa, 'क्षत्रिय');
      expect(m[Koot.varna].kanyaKa, 'वैश्य');
      expect(m[Koot.varna].ank, 1);
      // पुस्तिका: वनचर वर, चतुष्पद कन्या → ½
      expect(m[Koot.vashya].varKa, 'वनचर');
      expect(m[Koot.vashya].kanyaKa, 'चतुष्पद');
      expect(m[Koot.vashya].ank, 0.5);
      expect(m[Koot.vashya].talikaBantiHai, isTrue);
      // पुस्तिका: दोनों ओर की तारा शुभ
      expect(m[Koot.tara].ank, 3);
      // पुस्तिका: गौ और सर्प → 1
      expect(m[Koot.yoni].varKa, 'गौ');
      expect(m[Koot.yoni].kanyaKa, 'सर्प');
      expect(m[Koot.yoni].ank, 1);
      // पुस्तिका: सूर्य और शुक्र → 0
      expect(m[Koot.grahaMaitri].ank, 0);
      // पुस्तिका: दोनों मनुष्य गण → 6
      expect(m[Koot.gana].ank, 6);
      expect(m[Koot.bhakoot].ank, 7);
      expect(m[Koot.nadi].ank, 8);
      expect(m.kul, 26.5);
      expect(m.puraniTalikaSeKul, isNull);
    });

    test('वही उदाहरण, पुस्तिका का दूसरा वश्य: वर सिंह (वनचर), कन्या कर्क (जलचर) → 1',
        () {
      final m = gunMilan(varChandra: 4 * 30.0 + 5, kanyaChandra: 3 * 30.0 + 5);
      expect(m[Koot.vashya].ank, 1);
    });

    test('जहाँ पुरानी तालिका अलग है, वहाँ दोनों अंक', () {
      // वर अश्विनी (अश्व, देव), कन्या उत्तरा फाल्गुनी (गौ, मनुष्य)
      final m = gunMilan(
        varChandra: chandra(nak('अश्विनी'), 2),
        kanyaChandra: chandra(nak('उत्तरा फाल्गुनी'), 2),
      );
      expect(m[Koot.yoni].ank, 1);
      expect(m[Koot.yoni].puraniTalikaSe, 3);
      expect(m[Koot.gana].ank, 6);
      expect(m[Koot.gana].puraniTalikaSe, 5);
      expect(m.puraniTalikaSeKul, m.kul + 2 - 1);
      // जिन कूटों में पुस्तकें एक हैं वहाँ दूसरा अंक नहीं
      for (final k in [
        Koot.varna, Koot.tara, Koot.grahaMaitri, Koot.bhakoot, Koot.nadi,
      ]) {
        expect(m[k].puraniTalikaSe, isNull, reason: k.naam);
        expect(m[k].talikaBantiHai, isFalse, reason: k.naam);
      }
    });

    test('एक ही नक्षत्र-चरण दोनों ओर: नाड़ी छोड़ सब पूरे — 28', () {
      for (var n = 0; n < 27; n++) {
        final l = chandra(n, 2);
        final m = gunMilan(varChandra: l, kanyaChandra: l);
        expect(m.kul, 28, reason: nakshatraNames[n]);
        expect(m[Koot.nadi].ank, 0);
      }
    });

    test('हर चरण-जोड़े पर: कोई कूट अपने पूरे गुणों से ऊपर नहीं, कुल 0 से 36',
        () {
      var sabseZyada = 0.0;
      var sabseKam = 36.0;
      for (var a = 0; a < 108; a++) {
        for (var b = 0; b < 108; b++) {
          final m = gunMilan(
            varChandra: (a + 0.5) * (360.0 / 108.0),
            kanyaChandra: (b + 0.5) * (360.0 / 108.0),
          );
          expect(m.koot, hasLength(8));
          for (final k in m.koot) {
            if (k.ank < 0 || k.ank > k.koot.adhiktam) {
              fail('${k.koot.naam}: ${k.ank} ($a, $b)');
            }
            final p = k.puraniTalikaSe;
            if (p != null && (p < 0 || p > k.koot.adhiktam || p == k.ank)) {
              fail('${k.koot.naam} पुरानी: $p ($a, $b)');
            }
          }
          if (m.kul > sabseZyada) sabseZyada = m.kul;
          if (m.kul < sabseKam) sabseKam = m.kul;
        }
      }
      expect(sabseZyada, lessThanOrEqualTo(36));
      expect(sabseKam, greaterThanOrEqualTo(0));
      expect([for (final k in Koot.values) k.adhiktam].reduce((a, b) => a + b),
          gunMilanAdhiktam);
    });
  });
}
