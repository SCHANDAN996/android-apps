// "कौन से दिन टालने हैं" — मुहूर्त का वो हिस्सा जो पक्का है (→ D-059)।
//
// ⚠️ ये जाँचें सबसे ज़्यादा इस बात का पहरा देती हैं कि यह फ़ाइल
// **तारीख़ सुझाने न लगे।** D-019 ने वही जान-बूझकर रोका था। यहाँ सिर्फ़
// वही निकलता है जो पंचांग से सीधे आता है — कोई ग्रह नहीं, कोई अंदाज़ा
// नहीं।
import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

void main() {
  final delhi = Place(name: 'दिल्ली', latitude: 28.6139, longitude: 77.2090);

  group('पितृ पक्ष — दोनों पद्धतियों में', () {
    // पितृ पक्ष 2026: 26 सितम्बर से 10 अक्टूबर (भाद्रपद पूर्णिमा से
    // आश्विन अमावस्या तक)। पूर्णिमांत में ये दिन "आश्विन कृष्ण" हैं,
    // अमांत में "भाद्रपद कृष्ण" — दिन वही, नाम अलग।
    test('पूर्णिमांत में पकड़ा जाता है', () {
      final p = computePanchang(2026, 10, 2, delhi);
      expect(p.paksha, 1, reason: 'कृष्ण पक्ष होना चाहिए');
      expect(isPitruPaksha(p), isTrue);
    });

    test('अमांत में भी वही दिन पकड़ा जाता है', () {
      final p = computePanchang(2026, 10, 2, delhi,
          masaSystem: MasaSystem.amanta);
      expect(isPitruPaksha(p), isTrue,
          reason: 'दिन वही है — सिर्फ़ मास का नाम बदलता है');
    });

    test('शुक्ल पक्ष कभी पितृ पक्ष नहीं होता', () {
      // नवरात्रि — पितृ पक्ष ख़त्म होते ही शुरू होती है।
      final p = computePanchang(2026, 10, 13, delhi);
      expect(p.paksha, 0);
      expect(isPitruPaksha(p), isFalse);
    });
  });

  group('टालने वाले दिन', () {
    test('सूची तारीख़ के क्रम में आती है, और साफ़ दिन उसमें नहीं होते', () {
      final sab = taalneWaleDin(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 30),
        delhi,
      );
      expect(sab, isNotEmpty);
      for (var i = 1; i < sab.length; i++) {
        expect(sab[i].din.isAfter(sab[i - 1].din), isTrue);
      }
      for (final d in sab) {
        expect(d.vajahein, isNotEmpty,
            reason: 'बिना वजह का दिन सूची में नहीं आना चाहिए');
      }
    });

    test('पितृ पक्ष के पंद्रहों दिन आते हैं', () {
      final sab = taalneWaleDin(
        DateTime(2026, 9, 27),
        DateTime(2026, 10, 9),
        delhi,
      );
      final pitru =
          sab.where((d) => d.vajahein.contains(TaalneKiVajah.pitruPaksha));
      expect(pitru.length, greaterThanOrEqualTo(12),
          reason: 'पितृ पक्ष लगभग पंद्रह दिन का होता है');
    });

    test('एक दिन पर एक से ज़्यादा वजह हो सकती है', () {
      final sab = taalneWaleDin(
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
        delhi,
      );
      expect(sab.any((d) => d.vajahein.length > 1), isTrue);
    });

    test('भद्रा वाले दिन का समय साथ आता है', () {
      final sab = taalneWaleDin(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 30),
        delhi,
      );
      for (final d in sab) {
        if (d.vajahein.contains(TaalneKiVajah.bhadra)) {
          expect(d.bhadraKaal, isNotNull,
              reason: 'भद्रा है तो उसका समय भी होना चाहिए — '
                  'वरना यूज़र पूरा दिन काट देगा');
          expect(d.bhadraKaal!.end.isAfter(d.bhadraKaal!.start), isTrue);
        } else {
          expect(d.bhadraKaal, isNull);
        }
      }
    });
  });

  group('⚠️ पूरा दिन बनाम दिन का हिस्सा', () {
    test('अकेली भद्रा पूरा दिन नहीं काटती', () {
      final d = TaalneWalaDin(
        din: DateTime(2026, 1, 1),
        vajahein: [TaalneKiVajah.bhadra],
      );
      expect(d.pooraDinTalta, isFalse);
    });

    test('पितृ पक्ष पूरा दिन काटता है', () {
      final d = TaalneWalaDin(
        din: DateTime(2026, 1, 1),
        vajahein: [TaalneKiVajah.pitruPaksha],
      );
      expect(d.pooraDinTalta, isTrue);
    });

    test('गिनती में अकेली भद्रा वाले दिन नहीं गिने जाते', () {
      final sab = [
        TaalneWalaDin(din: DateTime(2026, 1, 1), vajahein: [TaalneKiVajah.bhadra]),
        TaalneWalaDin(din: DateTime(2026, 1, 1), vajahein: [TaalneKiVajah.panchak]),
        TaalneWalaDin(
            din: DateTime(2026, 1, 1),
            vajahein: [TaalneKiVajah.bhadra, TaalneKiVajah.adhikaMasa]),
      ];
      expect(pooreDinTalneWale(sab), 2);
    });
  });

  group('हर वजह अपनी बात ख़ुद कहती है', () {
    test('हर वजह का नाम और वजह भरी हुई है', () {
      for (final v in TaalneKiVajah.values) {
        expect(v.naam.trim(), isNotEmpty);
        expect(v.kyon.trim().length, greaterThan(30),
            reason: '${v.naam} की वजह इतनी छोटी नहीं होनी चाहिए');
      }
    });

    // ⚠️ अधिक मास, पितृ पक्ष और भद्रा पर पूरे भारत में एक राय है।
    // पंचक और गंडमूल पर नहीं — और ऐप को वह फ़र्क़ बोलना चाहिए।
    test('जिन पर मतभेद है, वे अलग दर्जे में हैं', () {
      expect(TaalneKiVajah.adhikaMasa.sabMante, isTrue);
      expect(TaalneKiVajah.pitruPaksha.sabMante, isTrue);
      expect(TaalneKiVajah.bhadra.sabMante, isTrue);
      expect(TaalneKiVajah.panchak.sabMante, isFalse);
      expect(TaalneKiVajah.gandmool.sabMante, isFalse);
    });

    test('किसी वजह में तारीख़ सुझाने वाली भाषा नहीं है', () {
      // यही D-019 की लक्ष्मण-रेखा है।
      for (final v in TaalneKiVajah.values) {
        expect(v.kyon, isNot(contains('शुभ दिन')));
        expect(v.kyon, isNot(contains('इस दिन करें')));
      }
    });
  });
}
