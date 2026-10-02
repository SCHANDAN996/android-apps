import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// लग्न, कुंडली और विंशोत्तरी दशा (→ D-098, docs/29 चरण K2)।
///
/// ⚠️ **ये जाँचें गणित की हैं, परंपरा की नहीं।** इनमें कोई असली जन्मपत्री
/// नहीं है। लग्न की जाँच खगोल से है (जो बिंदु "उग रहा" कहा गया, वह सचमुच
/// क्षितिज पर है या नहीं); ग्रह `graha_test.dart` में JPL Horizons से मिले
/// हैं; दशा अंकगणित है। किसी छपी जन्मपत्री और संदर्भ-पंचांग की कुंडली से
/// मिलान **अभी बाक़ी** है — इसीलिए `kundaliIsReady` `false` है।
void main() {
  double jdOf(DateTime utc) => julianDayFromUtc(utc);

  group('लग्न — जो बिंदु उग रहा है, वह सचमुच क्षितिज पर है', () {
    /// क्रांतिवृत्त के [lambda] वाले बिंदु (अक्षांश 0) की ऊँचाई और घंटा-कोण।
    ({double unchai, double ghantaKon}) kshitijSe(
        double lambda, double jdUt, Place place) {
      final eps = trueObliquity(toEphemerisTime(jdUt));
      double r(double d) => d * math.pi / 180;
      final ra = math.atan2(math.sin(r(lambda)) * math.cos(r(eps)),
              math.cos(r(lambda))) *
          180 /
          math.pi;
      final dec =
          math.asin(math.sin(r(eps)) * math.sin(r(lambda))) * 180 / math.pi;
      final h = norm180(localSiderealTime(jdUt, place) - ra);
      final alt = math.asin(math.sin(r(place.latitude)) * math.sin(r(dec)) +
              math.cos(r(place.latitude)) *
                  math.cos(r(dec)) *
                  math.cos(r(h))) *
          180 /
          math.pi;
      return (unchai: alt, ghantaKon: h);
    }

    test('सात शहर, साल भर, दिन के हर पहर — ऊँचाई शून्य, और पूर्व में', () {
      var gine = 0;
      for (final place in [...Place.testCities, Place.varanasi, Place.mumbai]) {
        for (var din = 0; din < 365; din += 13) {
          for (var ghanta = 0.0; ghanta < 24; ghanta += 1.7) {
            final jd = julianDay(2026, 1, 1) + din + ghanta / 24;
            final lagna = lagnaSayan(jd, place);
            final k = kshitijSe(lagna, jd, place);
            expect(k.unchai.abs(), lessThan(1e-6),
                reason: '$place दिन $din घंटा $ghanta: ऊँचाई ${k.unchai}');
            // घंटा-कोण ऋणात्मक = याम्योत्तर से पूर्व, यानी उग रहा है
            expect(k.ghantaKon, lessThan(0),
                reason: '$place दिन $din घंटा $ghanta: पश्चिम में निकला');
            gine++;
          }
        }
      }
      expect(gine, greaterThan(2500));
    });

    /// लग्न का सूत्र तीन चीज़ों से बनता है: स्थानीय नाक्षत्र काल, तिरछाहट और
    /// अक्षांश। ऊपर वाली जाँच सूत्र को परखती है; यह उसकी **जड़** को — वही
    /// नाक्षत्र काल NASA JPL Horizons से, दो शहर, 1972 से 2036 तक।
    test('स्थानीय नाक्षत्र काल JPL Horizons से 2 सेकंड के भीतर', () {
      final j = jsonDecode(
              File('test/data/horizons_graha.json').readAsStringSync())
          as Map<String, dynamic>;
      final lst = (j['lst'] as List).cast<Map<String, dynamic>>();
      expect(lst, hasLength(2));
      for (final s in lst) {
        final place = Place(
          name: s['sthan'] as String,
          latitude: (s['latitude'] as num).toDouble(),
          longitude: (s['longitude'] as num).toDouble(),
        );
        final jds = (s['jdUt'] as List).cast<num>();
        final ghante = (s['ghante'] as List).cast<num>();
        expect(jds, hasLength(6));
        for (var i = 0; i < jds.length; i++) {
          final hamara = localSiderealTime(jds[i].toDouble(), place);
          // घंटे → डिग्री; 2 सेकंड समय = 0.0083° — लग्न में भी उतना ही
          final farq = norm180(hamara - ghante[i] * 15.0);
          expect(farq.abs(), lessThan(0.0083),
              reason: '${s['sthan']} @ ${jds[i]}: $farq°');
        }
      }
    });

    test('भूमध्य रेखा पर, जब मेष का आदि बिंदु सिर के ऊपर हो — कर्क उगता है', () {
      // θ = 0 पर, अक्षांश 0: उगते बिंदु का RA 90° होता है → देशांतर 90°।
      const bhumadhya = Place(name: 'भूमध्य', latitude: 0, longitude: 0);
      // वह क्षण खोजो जब स्थानीय नाक्षत्र काल 0 हो
      var jd = julianDay(2026, 3, 21);
      for (var i = 0; i < 20; i++) {
        final theta = norm180(localSiderealTime(jd, bhumadhya));
        jd -= theta / 360.98564736629;
      }
      expect(norm180(localSiderealTime(jd, bhumadhya)).abs(), lessThan(1e-6));
      expect(lagnaSayan(jd, bhumadhya), closeTo(90.0, 1e-4));
    });

    test('सूर्योदय के क्षण लग्न सूर्य के पास होता है', () {
      // सूर्य क्रांतिवृत्त पर ही रहता है, तो जब उसका केंद्र क्षितिज पर हो
      // तब वही उगता बिंदु है। पर इंजन का सूर्योदय "ऊपरी कोर + अपवर्तन" पर
      // है — उस क्षण सूर्य का केंद्र अभी क्षितिज से 0.83° **नीचे** है। तो
      // जो बिंदु ठीक क्षितिज पर है वह सूर्य से ज़रा पहले का है: लग्न सूर्य
      // से 1–2 अंश **पीछे**।
      for (final place in Place.testCities) {
        for (final (m, d) in [(1, 15), (4, 10), (7, 5), (10, 2), (12, 21)]) {
          final uday = sunriseSunset(2026, m, d, place).sunrise!;
          final jd = jdOf(uday);
          final surya = sunApparentLongitude(toEphemerisTime(jd));
          final farq = norm180(lagnaSayan(jd, place) - surya);
          expect(farq, inInclusiveRange(-2.5, -0.5),
              reason: '$place $d/$m: लग्न − सूर्य = $farq°');
        }
      }
    });

    test('लग्न 24 घंटे में पूरा चक्र घूमता है — हर राशि एक बार उगती है', () {
      final jd0 = julianDay(2026, 10, 2);
      final rashiyan = <int>{};
      var pichhla = lagnaNirayan(jd0, Place.patna);
      var kul = 0.0;
      for (var i = 1; i <= 24 * 12; i++) {
        final l = lagnaNirayan(jd0 + i / (24 * 12), Place.patna);
        final badha = norm180(l - pichhla);
        expect(badha, greaterThan(0), reason: 'लग्न पीछे चला');
        kul += badha;
        rashiyan.add(l ~/ 30);
        pichhla = l;
      }
      expect(rashiyan, hasLength(12));
      // एक सौर दिन में 360° से ज़रा ज़्यादा: नाक्षत्र दिन 4 मिनट छोटा है, तो
      // 24 घंटे बाद लग्न उसी जगह से ~1° आगे होता है (ठीक कितना, यह इस पर
      // टिका है कि उस घड़ी कौन सी राशि उग रही है — धीमी या तेज़)।
      expect(kul, inInclusiveRange(360.5, 361.7));
    });

    test('निरयन लग्न = सायन लग्न − अयनांश', () {
      final jd = julianDay(2026, 10, 2.3);
      final farq = norm180(lagnaSayan(jd, Place.delhi) -
          lagnaNirayan(jd, Place.delhi) -
          lahiriAyanamsa(toEphemerisTime(jd)));
      expect(farq.abs(), lessThan(1e-9));
    });
  });

  group('राशि, नक्षत्र, चरण, नवमांश — एक ही देशांतर से', () {
    test('राशि और अंश', () {
      const s = RashiSthiti(95.5);
      expect(s.rashi, 3);
      expect(s.rashiNaam, rashiNames[3]);
      expect(s.ansh, closeTo(5.5, 1e-9));
      expect(const RashiSthiti(0).rashi, 0);
      expect(const RashiSthiti(359.999).rashi, 11);
    });

    test('नक्षत्र और चरण — 13°20′ और 3°20′', () {
      expect(const RashiSthiti(0.1).nakshatra, 0);
      expect(const RashiSthiti(0.1).charan, 1);
      expect(const RashiSthiti(3.4).charan, 2); // 3°20′ के बाद
      expect(const RashiSthiti(13.2).charan, 4);
      expect(const RashiSthiti(13.4).nakshatra, 1); // भरणी
      expect(const RashiSthiti(13.4).charan, 1);
      expect(const RashiSthiti(359.9).nakshatra, 26); // रेवती
      expect(const RashiSthiti(359.9).charan, 4);
    });

    test('नवमांश: अग्नि राशि मेष से, पृथ्वी मकर से, वायु तुला से, जल कर्क से',
        () {
      // हर राशि का पहला नवमांश (0°–3°20′)
      const pehla = [0, 9, 6, 3, 0, 9, 6, 3, 0, 9, 6, 3];
      for (var r = 0; r < 12; r++) {
        expect(RashiSthiti(r * 30 + 1.0).navamsha, pehla[r], reason: 'राशि $r');
        // और आख़िरी नवमांश (26°40′–30°) उससे आठ आगे
        expect(RashiSthiti(r * 30 + 29.0).navamsha, (pehla[r] + 8) % 12,
            reason: 'राशि $r का नौवाँ');
      }
    });

    test('वर्गोत्तम: चर राशि का पहला, स्थिर का पाँचवाँ, द्विस्वभाव का नौवाँ नवमांश',
        () {
      // इन जगहों पर नवमांश की राशि वही होती है जो जन्म की — नियम की
      // स्वतंत्र जाँच।
      for (var r = 0; r < 12; r++) {
        final kaun = switch (r % 3) { 0 => 0, 1 => 4, _ => 8 };
        final s = RashiSthiti(r * 30 + kaun * (10 / 3) + 1.0);
        expect(s.navamsha, r, reason: 'राशि $r');
      }
    });

    test('राशि की सीमा से दूरी', () {
      expect(const RashiSthiti(30.4).rashiSeemaSeDoori, closeTo(0.4, 1e-9));
      expect(const RashiSthiti(59.7).rashiSeemaSeDoori, closeTo(0.3, 1e-9));
      expect(const RashiSthiti(45).rashiSeemaSeDoori, closeTo(15, 1e-9));
    });
  });

  group('कुंडली', () {
    // 2 अक्टूबर 2026, सुबह 6:30 IST, पटना
    final janm = DateTime.utc(2026, 10, 2, 1, 0);
    final k = computeKundali(janm, Place.patna);

    test('अभी ऐप के लिए तैयार नहीं — संदर्भ से मिलान बाक़ी', () {
      expect(kundaliIsReady, isFalse);
    });

    test('नौ ग्रह, अपने क्रम में', () {
      expect(k.grahas.map((g) => g.graha).toList(), KundaliGraha.values);
      for (final g in k.grahas) {
        expect(g.nirayan, inInclusiveRange(0, 360), reason: g.graha.name);
      }
    });

    test('सूर्य और चंद्र वही हैं जो उस दिन के पंचांग में हैं', () {
      final p = computePanchang(2026, 10, 2, Place.patna);
      // सुबह 6:30 पर — सूर्योदय के आसपास; राशि वही होनी चाहिए
      expect(k[KundaliGraha.surya].rashi, p.sunRashi);
      expect(k[KundaliGraha.chandra].rashi, p.moonRashi);
      // और चंद्र का नक्षत्र पंचांग की उस दिन की नक्षत्र-सूची में है
      expect(p.nakshatras.map((n) => n.name),
          contains(k[KundaliGraha.chandra].nakshatraNaam));
    });

    test('केतु राहु के ठीक सामने; दोनों उलटे चलते हैं पर "वक्री" नहीं लिखे जाते',
        () {
      final r = k[KundaliGraha.rahu], ke = k[KundaliGraha.ketu];
      expect(norm180(ke.nirayan - r.nirayan).abs(), closeTo(180, 1e-9));
      expect(r.gati, lessThan(0));
      expect(r.vakri, isFalse);
      expect(ke.vakri, isFalse);
      expect(k.bhav(KundaliGraha.ketu),
          (k.bhav(KundaliGraha.rahu) + 5) % 12 + 1); // सातवाँ भाव
    });

    test('सूर्य और चंद्र कभी वक्री नहीं; बुध और शुक्र सूर्य के आसपास ही', () {
      expect(k[KundaliGraha.surya].vakri, isFalse);
      expect(k[KundaliGraha.chandra].vakri, isFalse);
      final s = k[KundaliGraha.surya].nirayan;
      expect(norm180(k[KundaliGraha.budh].nirayan - s).abs(), lessThan(29));
      expect(norm180(k[KundaliGraha.shukra].nirayan - s).abs(), lessThan(48.5));
    });

    test('भाव लग्न की राशि से गिने जाते हैं — एक राशि, एक भाव', () {
      for (final g in KundaliGraha.values) {
        final b = k.bhav(g);
        expect(b, inInclusiveRange(1, 12));
        expect((k.lagna.rashi + b - 1) % 12, k[g].rashi, reason: g.name);
      }
      // बारहों भावों में मिलाकर नौ ही ग्रह
      expect(
          [for (var b = 1; b <= 12; b++) ...k.bhavMein(b)], hasLength(9));
      // चंद्र कुंडली में चंद्र पहले भाव में
      expect(k.chandraSeBhav(KundaliGraha.chandra), 1);
    });

    test('सूर्योदय के ठीक बाद जन्म — सूर्य पहले या बारहवें भाव में', () {
      // सूर्य अभी-अभी उगा है, तो वह लग्न की राशि में है या उससे ठीक पहले की में
      expect(k.bhav(KundaliGraha.surya), anyOf(1, 12));
    });

    test('चार मिनट बाद लग्न लगभग एक अंश आगे', () {
      final k2 = computeKundali(janm.add(const Duration(minutes: 4)), Place.patna);
      final badha = norm180(k2.lagna.nirayan - k.lagna.nirayan);
      expect(badha, inInclusiveRange(0.6, 1.5));
      // और ग्रह लगभग वहीं — चंद्र भी चार मिनट में 2 कला ही चलता है
      expect(
          norm180(k2[KundaliGraha.chandra].nirayan - k[KundaliGraha.chandra].nirayan),
          inInclusiveRange(0.02, 0.05));
    });

    test('लग्न-संधि: राशि की सीमा के पास हो तो चेतावनी', () {
      // वह क्षण खोजो जब लग्न राशि बदलता है
      var t = janm;
      var pichhli = computeKundali(t, Place.patna).lagna.rashi;
      DateTime? badla;
      for (var i = 0; i < 200; i++) {
        t = t.add(const Duration(minutes: 1));
        final r = computeKundali(t, Place.patna).lagna.rashi;
        if (r != pichhli) {
          badla = t;
          break;
        }
        pichhli = r;
      }
      expect(badla, isNotNull);
      expect(computeKundali(badla!, Place.patna).lagnaSandhiMein(), isTrue);
      // एक घंटे बाद — राशि के बीच में, कोई चेतावनी नहीं
      expect(
          computeKundali(badla.add(const Duration(hours: 1)), Place.patna)
              .lagnaSandhiMein(),
          isFalse);
    });

    test('1950 का जन्म भी बनता है — ΔT वाले पुराने साल', () {
      final purana =
          computeKundali(DateTime.utc(1950, 1, 26, 4, 45), Place.delhi);
      expect(purana.grahas, hasLength(9));
      // 1950 में अयनांश 23° के आसपास था
      expect(purana.ayanamsa, inInclusiveRange(23.0, 23.3));
    });
  });

  group('विंशोत्तरी दशा', () {
    final janm = DateTime.utc(2000, 1, 1);
    const nakshatraAnsh = 360.0 / 27.0;

    test('नौ स्वामी, कुल 120 साल', () {
      expect(vimshottariKram.toSet(), KundaliGraha.values.toSet());
      expect(vimshottariVarsh.fold<int>(0, (a, b) => a + b), 120);
    });

    test('नक्षत्र का स्वामी — अश्विनी केतु, भरणी शुक्र, कृत्तिका सूर्य…', () {
      expect(nakshatraSwami(0), KundaliGraha.ketu);
      expect(nakshatraSwami(1), KundaliGraha.shukra);
      expect(nakshatraSwami(2), KundaliGraha.surya);
      expect(nakshatraSwami(3), KundaliGraha.chandra); // रोहिणी
      // नौ-नौ नक्षत्र बाद वही: अश्विनी, मघा, मूल — तीनों केतु के
      expect(nakshatraSwami(9), KundaliGraha.ketu);
      expect(nakshatraSwami(18), KundaliGraha.ketu);
      expect(nakshatraSwami(26), KundaliGraha.budh); // रेवती
    });

    test('चंद्र अश्विनी के ठीक आरंभ पर — केतु की पूरी सात साल की दशा बची', () {
      final d = vimshottariMahadasha(janm, 0.0);
      expect(d.first.swami, KundaliGraha.ketu);
      expect(d.first.shuru, janm);
      expect(d.first.ant.difference(janm).inDays, closeTo(7 * 365.25, 1));
      expect(janmParDashaShesh(0.0), closeTo(7, 1e-9));
    });

    test('चंद्र नक्षत्र के ठीक बीच में — आधी दशा बीत चुकी', () {
      // भरणी (शुक्र, 20 साल) का मध्य
      final chandra = nakshatraAnsh * 1.5;
      final d = vimshottariMahadasha(janm, chandra);
      expect(d.first.swami, KundaliGraha.shukra);
      expect(janm.difference(d.first.shuru).inDays, closeTo(10 * 365.25, 1));
      expect(d.first.ant.difference(janm).inDays, closeTo(10 * 365.25, 1));
      expect(janmParDashaShesh(chandra), closeTo(10, 1e-9));
      expect(d.first.mein(janm), isTrue);
    });

    test('दशाएँ बिना छेद के जुड़ी हैं, और क्रम वही है', () {
      final d = vimshottariMahadasha(janm, 100.0);
      for (var i = 1; i < d.length; i++) {
        expect(d[i].shuru, d[i - 1].ant);
        expect(vimshottariKram.indexOf(d[i].swami),
            (vimshottariKram.indexOf(d[i - 1].swami) + 1) % 9);
      }
      // जन्म से पूरे 120 साल ढके हैं
      expect(d.last.ant.difference(janm).inDays,
          greaterThan((120 * 365.25).floor()));
      // पहली नौ दशाएँ ठीक 120 साल की
      expect(d[8].ant.difference(d[0].shuru).inDays, closeTo(120 * 365.25, 1));
    });

    test('अंतर्दशा: उसी स्वामी से शुरू, नौ खंड, महादशा के भीतर बिना छेद', () {
      final maha = vimshottariMahadasha(janm, 0.0)[1]; // शुक्र, 20 साल
      final a = vimshottariAntardasha(maha);
      expect(a, hasLength(9));
      expect(a.first.swami, KundaliGraha.shukra);
      expect(a.first.shuru, maha.shuru);
      expect(a.last.ant, maha.ant);
      for (var i = 1; i < a.length; i++) {
        expect(a[i].shuru, a[i - 1].ant);
      }
      // शुक्र में शुक्र = 20 × 20 / 120 साल = 3 साल 4 महीने
      expect(a.first.ant.difference(a.first.shuru).inDays,
          closeTo(20 * 20 / 120 * 365.25, 1));
      // शुक्र में सूर्य = 20 × 6 / 120 = 1 साल
      expect(a[1].swami, KundaliGraha.surya);
      expect(a[1].ant.difference(a[1].shuru).inDays, closeTo(365.25, 1));
    });

    test('चंद्र 1 कला खिसके तो शुक्र की दशा ~9 दिन खिसकती है', () {
      // यही वह बात है जो स्क्रीन पर लिखी जाएगी: तारीख़ें कुछ दिन आगे-पीछे
      final chandra = nakshatraAnsh * 1.5;
      final a = vimshottariMahadasha(janm, chandra).first.ant;
      final b = vimshottariMahadasha(janm, chandra + 1 / 60).first.ant;
      expect(a.difference(b).inHours / 24, closeTo(9.13, 0.1));
    });
  });
}
