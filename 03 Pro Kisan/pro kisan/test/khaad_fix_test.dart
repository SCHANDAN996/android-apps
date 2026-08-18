import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/crops.dart';

Crop _c(String id) => kCrops.firstWhere((c) => c.id == id);

void main() {
  group('गंभीर गड़बड़ियों की जाँच', () {
    test('नारियल: प्रति पेड़ की खुराक अब हेक्टेयर में सही बदलती है', () {
      final coconut = _c('coconut');
      expect(coconut.isPerPlant, isTrue);
      expect(coconut.nRaw, 500);                 // 500 ग्राम प्रति पेड़
      expect(coconut.n, closeTo(87.5, 0.1));     // 500g × 175 पेड़ = 87.5 kg/ha
      expect(coconut.k, closeTo(210.0, 0.1));    // 1200g × 175 = 210 kg/ha
    });

    test('काली मिर्च: प्रति बेल → हेक्टेयर', () {
      final bp = _c('blackpepper');
      expect(bp.isPerPlant, isTrue);
      expect(bp.n, closeTo(110.0, 0.1));         // 100g × 1100 बेल
    });

    test('गन्ना: बीज अब शून्य नहीं', () {
      final sc = _c('sugarcane');
      expect(sc.seedKgHa, greaterThan(0));
      expect(sc.seedKind, SeedKind.setts);
      expect(sc.seedMinKgHa, 5000);
      expect(sc.seedMaxKgHa, 7500);
    });

    test('केला/नारियल/काली मिर्च — पौधों वाली फ़सल के रूप में चिह्नित', () {
      for (final id in ['banana', 'coconut', 'blackpepper']) {
        expect(_c(id).seedKind, SeedKind.saplings, reason: id);
        expect(_c(id).plantsPerHa, greaterThan(0), reason: id);
      }
    });

    test('सरसों: गंधक + SSP का रास्ता मिलता है', () {
      final m = _c('mustard');
      expect(m.sulphurKgHa, 40);
      expect(m.preferSSP, isTrue);
      final r = computeKhaad3Tier(crop: m, areaHa: 1).recommended;
      expect(r.hasSspRoute, isTrue);
      expect(r.sspKg, closeTo(250, 1));                 // 40 ÷ 0.16 = 250 किलो
      expect(r.sulphurFromSspKg, closeTo(27.5, 0.6));   // 250 × 11%
      expect(r.gypsumKg, greaterThan(0));               // बचा गंधक जिप्सम से
    });

    test('चारों तिलहन में गंधक है', () {
      for (final id in ['mustard', 'groundnut', 'sesame', 'soybean']) {
        expect(_c(id).sulphurKgHa, greaterThan(0), reason: id);
        expect(_c(id).preferSSP, isTrue, reason: id);
      }
    });
  });

  group('पुराना सिस्टम नहीं टूटा', () {
    test('गेहूँ का हिसाब पहले जैसा ही', () {
      final w = _c('wheat');
      expect(w.n, 120);
      expect(w.doseUnit, DoseUnit.perHectare);
      final r = computeKhaad3Tier(crop: w, areaHa: 1).recommended;
      expect(r.dapKg, closeTo(130.5, 1));   // 60 ÷ 0.46
      expect(r.mopKg, closeTo(66.5, 1));    // 40 ÷ 0.60
      expect(r.hasSspRoute, isFalse);       // गेहूँ में SSP का रास्ता नहीं
    });

    test('सभी 30 फ़सलें मौजूद, कोई खुराक ऋणात्मक नहीं', () {
      expect(kCrops.length, 30);
      for (final c in kCrops) {
        expect(c.n, greaterThanOrEqualTo(0), reason: c.id);
        expect(c.nMin, lessThanOrEqualTo(c.n), reason: c.id);
        expect(c.n, lessThanOrEqualTo(c.nMax), reason: c.id);
      }
    });
  });

  group('समूह 1 — अनाज का शोध', () {
    const cereals = ['wheat', 'paddy', 'maize', 'barley', 'bajra', 'jowar', 'ragi'];

    test('सातों अनाज सत्यापित हैं (स्रोत लिखा है)', () {
      for (final id in cereals) {
        expect(_c(id).isVerified, isTrue, reason: id);
        expect(_c(id).source, contains('ICAR'), reason: id);
      }
    });

    test('सातों में गोबर खाद, बीज की सीमा, दूरी और बीज उपचार है', () {
      for (final id in cereals) {
        final c = _c(id);
        expect(c.fymTonHa, greaterThan(0), reason: '$id — गोबर खाद');
        expect(c.seedMinKgHa, greaterThan(0), reason: '$id — बीज कम');
        expect(c.seedMaxKgHa, greaterThanOrEqualTo(c.seedMinKgHa), reason: '$id — बीज ज़्यादा');
        expect(c.spacingHi, isNotNull, reason: '$id — दूरी');
        expect(c.seedTreatHi, isNotNull, reason: '$id — बीज उपचार');
      }
    });

    test('गेहूं, धान, मक्का में ज़िंक सल्फ़ेट 25 किलो/हे.', () {
      for (final id in ['wheat', 'paddy', 'maize']) {
        expect(_c(id).zincSulphateKgHa, 25, reason: id);
      }
    });

    test('हर अनाज का split plan 100% N बाँटता है', () {
      for (final id in cereals) {
        final c = _c(id);
        expect(c.splitPlan, isNotEmpty, reason: id);
        final n = c.splitPlan.fold<double>(0, (a, s) => a + s.nPct);
        final p = c.splitPlan.fold<double>(0, (a, s) => a + s.pPct);
        final k = c.splitPlan.fold<double>(0, (a, s) => a + s.kPct);
        expect(n, closeTo(100, 1), reason: '$id — N');
        expect(p, closeTo(100, 1), reason: '$id — P');
        expect(k, closeTo(100, 1), reason: '$id — K');
      }
    });

    test('गेहूं 1 हेक्टेयर — कब कितनी यूरिया', () {
      final rows = computeSplitPlan(crop: _c('wheat'), areaHa: 1);
      expect(rows.length, 3);
      // कुल यूरिया 236 किलो के आसपास; आधा बुवाई पर
      final total = rows.fold<double>(0, (a, r) => a + r.ureaKg);
      final full = computeKhaad3Tier(crop: _c('wheat'), areaHa: 1).recommended;
      expect(total, closeTo(full.ureaKg, 1.5));
      expect(rows[0].ureaKg, closeTo(full.ureaKg / 2, 1));
      expect(rows[0].dapKg, closeTo(full.dapKg, 1));   // DAP पूरा बुवाई पर
      expect(rows[1].dapKg, 0);                        // बाद में नहीं
      expect(rows[2].dapKg, 0);
    });

    test('बाजरा की बीज दर विधि से बदलती है (4 से 15 किलो)', () {
      final b = _c('bajra');
      expect(b.seedMinKgHa, 4);
      expect(b.seedMaxKgHa, 15);
    });

    test('गोबर खाद रक़बे के हिसाब से', () {
      final e = computeExtras(crop: _c('wheat'), areaHa: 2);
      expect(e.fymTon, 20);            // 10 टन × 2 हे.
      expect(e.zincSulphateKg, 50);    // 25 × 2
      expect(e.isEmpty, isFalse);
    });
  });

  group('समूह 2 — दलहन का शोध', () {
    const pulses = ['gram', 'lentil', 'moong', 'urad', 'pigeonpea', 'soybean'];

    test('छहों दलहन सत्यापित हैं', () {
      for (final id in pulses) {
        expect(_c(id).isVerified, isTrue, reason: id);
      }
    });

    test('हर दलहन में राइज़ोबियम का बीज उपचार लिखा है', () {
      for (final id in pulses) {
        expect(_c(id).seedTreatHi, contains('राइज़ोबियम'), reason: id);
      }
    });

    test('हर दलहन में गंधक है और SSP का रास्ता खुलता है', () {
      for (final id in pulses) {
        final c = _c(id);
        expect(c.sulphurKgHa, greaterThan(0), reason: id);
        expect(c.preferSSP, isTrue, reason: id);
        final r = computeKhaad3Tier(crop: c, areaHa: 1).recommended;
        expect(r.hasSspRoute, isTrue, reason: id);
      }
    });

    test('दलहन में नाइट्रोजन जान-बूझकर कम — फ़ॉस्फ़ोरस से ज़्यादा नहीं', () {
      for (final id in pulses) {
        final c = _c(id);
        expect(c.n, lessThan(c.p),
            reason: '$id — दलहन में N < P होना चाहिए (गाँठें बनती रहें)');
        expect(c.n, lessThanOrEqualTo(30), reason: '$id — N बहुत ज़्यादा');
      }
    });

    test('चना 1 हेक्टेयर — SSP वाला रास्ता सही', () {
      final r = computeKhaad3Tier(crop: _c('gram'), areaHa: 1).recommended;
      expect(r.sspKg, closeTo(375, 1));            // 60 ÷ 0.16
      expect(r.sulphurFromSspKg, closeTo(41.5, 1)); // 375 × 11% — 20 किलो की ज़रूरत से ज़्यादा
      expect(r.gypsumKg, 0);                        // इसलिए जिप्सम की ज़रूरत नहीं
    });

    test('मूंग की बीज दर मौसम से बदलती है', () {
      expect(_c('moong').seedMinKgHa, 15);   // खरीफ
      expect(_c('moong').seedMaxKgHa, 30);   // गर्मी/रबी
    });

    test('सबका split plan एक ही बार में पूरा (दलहन में विभाजन नहीं)', () {
      for (final id in pulses) {
        final c = _c(id);
        expect(c.splitPlan.length, 1, reason: id);
        expect(c.splitPlan.first.nPct, 100, reason: id);
      }
    });
  });

  group('अब तक का कुल हिसाब', () {
    test('13 फ़सलों का शोध पूरा (7 अनाज + 6 दलहन) + 3 तिलहन/बाग़ान', () {
      final verified = kCrops.where((c) => c.isVerified).map((c) => c.id).toSet();
      for (final id in ['wheat','paddy','maize','barley','bajra','jowar','ragi',
                        'gram','lentil','moong','urad','pigeonpea','soybean',
                        'mustard','groundnut','sesame',
                        'sugarcane','banana','coconut','blackpepper']) {
        expect(verified.contains(id), isTrue, reason: '$id सत्यापित नहीं');
      }
    });

    test('हर सत्यापित फ़सल का split plan 100% N बाँटता है', () {
      for (final c in kCrops.where((c) => c.splitPlan.isNotEmpty)) {
        final n = c.splitPlan.fold<double>(0, (a, s) => a + s.nPct);
        expect(n, closeTo(100, 1), reason: c.id);
      }
    });
  });

  group('समूह 3 — तिलहन + नक़दी', () {
    const cash = ['mustard', 'groundnut', 'sesame', 'cotton', 'sugarcane', 'banana'];

    test('छहों सत्यापित हैं और स्रोत लिखा है', () {
      for (final id in cash) {
        expect(_c(id).isVerified, isTrue, reason: id);
        expect(_c(id).source.length, greaterThan(20), reason: id);
      }
    });

    test('कपास: Bt और देसी दोनों की बीज दर', () {
      final c = _c('cotton');
      expect(c.seedMinKgHa, 1.5);     // Bt संकर
      expect(c.seedMaxKgHa, 20);      // देसी
      expect(c.spacingHi, contains('Bt'));
      expect(c.seedTreatHi, contains('पहले से उपचारित'));
    });

    test('कपास का बारानी वाला आँकड़ा CICR के मुताबिक़', () {
      expect(_c('cotton').nMin, 60);
      expect(_c('cotton').pMin, 30);
      expect(_c('cotton').kMin, 30);
    });

    test('केला: फ़ॉस्फ़ोरस पूरा रोपाई पर, N-K चार बार', () {
      final c = _c('banana');
      final first = c.splitPlan.first;
      expect(first.pPct, 100);
      expect(first.nPct, 0);          // रोपाई पर नाइट्रोजन नहीं
      final n = c.splitPlan.fold<double>(0, (a, s) => a + s.nPct);
      final k = c.splitPlan.fold<double>(0, (a, s) => a + s.kPct);
      expect(n, 100);
      expect(k, 100);
    });

    test('गन्ना: तीन बार नाइट्रोजन', () {
      expect(_c('sugarcane').splitPlan.length, 3);
    });
  });

  group('स्रोत हर सत्यापित फ़सल में', () {
    test('जिसका source है उसमें संस्थान का नाम भी है', () {
      final verified = kCrops.where((c) => c.isVerified);
      expect(verified.length, greaterThanOrEqualTo(21));
      for (final c in verified) {
        final s = c.source;
        final hasInstitute = s.contains('ICAR') ||
            s.contains('DPD') ||
            s.contains('caneadvisory') ||
            s.contains('indiaagronet') ||
            s.contains('AICRP');
        expect(hasInstitute, isTrue, reason: '${c.id} — स्रोत में संस्थान नहीं: $s');
      }
    });
  });

  group('समूह 4 — सब्ज़ी और मसाला', () {
    const veg = ['potato', 'tomato', 'onion', 'chilli', 'cabbage',
                 'brinjal', 'okra', 'turmeric', 'ginger'];

    test('नौ सत्यापित हैं', () {
      for (final id in veg) {
        expect(_c(id).isVerified, isTrue, reason: id);
      }
    });

    test('आलू, हल्दी, अदरक — बीज कंद है (किलो नहीं, क्विंटल)', () {
      for (final id in ['potato', 'turmeric', 'ginger']) {
        final c = _c(id);
        expect(c.seedKind, SeedKind.tuber, reason: id);
        expect(c.seedMinKgHa, greaterThan(1000), reason: id);
        expect(c.spacingHi, contains('क्विंटल'), reason: id);
      }
    });

    test('गोभी और टमाटर में बोरेक्स है', () {
      expect(_c('cabbage').boraxKgHa, 10);
      expect(_c('tomato').boraxKgHa, 10);
      expect(_c('cabbage').source, contains('खोखला'));
    });

    test('भिंडी की बीज दर मौसम से दोगुनी', () {
      expect(_c('okra').seedMinKgHa, 8);    // खरीफ
      expect(_c('okra').seedMaxKgHa, 18);   // गर्मी
    });

    test('हल्दी में पोटाश सबसे ज़्यादा', () {
      final t = _c('turmeric');
      expect(t.k, greaterThan(t.n));
      expect(t.k, greaterThan(t.p));
    });

    test('प्याज़ में गंधक है (स्वाद और भंडारण के लिए)', () {
      expect(_c('onion').sulphurKgHa, 30);
    });
  });

  group('🏁 सारी 30 फ़सलें — आख़िरी जाँच', () {
    test('हर फ़सल सत्यापित है और स्रोत में संस्थान का नाम है', () {
      final missing = kCrops.where((c) => !c.isVerified).map((c) => c.id).toList();
      expect(missing, isEmpty, reason: 'इनका शोध बाक़ी: $missing');
    });

    test('हर फ़सल में गोबर खाद, बीज सीमा, दूरी, बीज उपचार, split plan', () {
      for (final c in kCrops) {
        expect(c.fymTonHa, greaterThan(0), reason: '${c.id} — गोबर खाद');
        expect(c.spacingHi, isNotNull, reason: '${c.id} — दूरी');
        expect(c.seedTreatHi, isNotNull, reason: '${c.id} — बीज उपचार');
        expect(c.splitPlan, isNotEmpty, reason: '${c.id} — कब डालें');
        // पौधों वाली फ़सलों में बीज "किलो" में नहीं होता
        if (c.seedKind != SeedKind.saplings) {
          expect(c.seedMinKgHa, greaterThan(0), reason: '${c.id} — बीज कम');
          expect(c.seedMaxKgHa, greaterThanOrEqualTo(c.seedMinKgHa), reason: '${c.id} — बीज ज़्यादा');
        }
      }
    });

    test('हर फ़सल का split plan N, P, K तीनों का 100% बाँटता है', () {
      for (final c in kCrops) {
        final n = c.splitPlan.fold<double>(0, (a, s) => a + s.nPct);
        final p = c.splitPlan.fold<double>(0, (a, s) => a + s.pPct);
        final k = c.splitPlan.fold<double>(0, (a, s) => a + s.kPct);
        expect(n, closeTo(100, 1), reason: '${c.id} — N');
        expect(p, closeTo(100, 1), reason: '${c.id} — P');
        expect(k, closeTo(100, 1), reason: '${c.id} — K');
      }
    });

    test('कम ≤ सही ≤ ज़्यादा — हर फ़सल, हर तत्व', () {
      for (final c in kCrops) {
        expect(c.nMin, lessThanOrEqualTo(c.n), reason: '${c.id} N');
        expect(c.n, lessThanOrEqualTo(c.nMax), reason: '${c.id} N');
        expect(c.pMin, lessThanOrEqualTo(c.p), reason: '${c.id} P');
        expect(c.p, lessThanOrEqualTo(c.pMax), reason: '${c.id} P');
        expect(c.kMin, lessThanOrEqualTo(c.k), reason: '${c.id} K');
        expect(c.k, lessThanOrEqualTo(c.kMax), reason: '${c.id} K');
      }
    });

    test('हर फ़सल का हिसाब 1 एकड़ पर बिना गड़बड़ी चलता है', () {
      const acreInHa = 0.4047;
      for (final c in kCrops) {
        final r = computeKhaad3Tier(crop: c, areaHa: acreInHa);
        for (final t in [r.min, r.recommended, r.max]) {
          expect(t.ureaKg, greaterThanOrEqualTo(0), reason: c.id);
          expect(t.ureaKg.isFinite, isTrue, reason: c.id);
          expect(t.dapKg.isFinite, isTrue, reason: c.id);
          expect(t.mopKg.isFinite, isTrue, reason: c.id);
        }
        final rows = computeSplitPlan(crop: c, areaHa: acreInHa);
        expect(rows, isNotEmpty, reason: c.id);
        final e = computeExtras(crop: c, areaHa: acreInHa);
        expect(e.fymTon, greaterThan(0), reason: c.id);
      }
    });
  });
}
