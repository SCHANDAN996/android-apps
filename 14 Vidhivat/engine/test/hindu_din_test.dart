import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// दिन की सीमा — **ब्रह्म मुहूर्त से अगले ब्रह्म मुहूर्त तक** (→ D-044)।
///
/// ⚠️ यहाँ के सारे पल **असली** हैं। यह `muhurta.dart` वाले *घड़ी वाले*
/// समय से अलग बात है — वहाँ UTC का ठप्पा नक़ली होता है (→ D-043)।
/// दोनों को कभी आपस में मत मिलाना।
void main() {
  const dilli = Place.delhi;

  /// भारत की घड़ी में `hh:mm` को असली पल बनाओ।
  DateTime ist(int y, int m, int d, int hh, int mm) =>
      DateTime.utc(y, m, d, hh, mm)
          .subtract(const Duration(hours: 5, minutes: 30));

  group('दिन कहाँ से कहाँ तक', () {
    test('दोपहर का समय उसी तारीख़ के दिन में पड़ता है', () {
      expect(hinduDin(ist(2026, 8, 20, 13, 0), dilli)!.ginti, 20260820);
    });

    test('सूर्योदय के बाद वही दिन चलता रहता है', () {
      expect(hinduDin(ist(2026, 8, 20, 7, 0), dilli)!.ginti, 20260820);
    });

    test('सीमा सूर्योदय से ठीक 96 मिनट पहले है', () {
      final din = hinduDin(ist(2026, 8, 20, 13, 0), dilli)!;

      expect(din.aarambh, sunriseSunset(2026, 8, 20, dilli).sunrise!
          .subtract(brahmaMuhurtaSePehle));
      expect(din.suryoday, sunriseSunset(2026, 8, 20, dilli).sunrise);
      expect(din.suryoday.difference(din.aarambh), brahmaMuhurtaSePehle);
    });

    test('दो सीमाओं के बीच लगभग चौबीस घंटे', () {
      final din = hinduDin(ist(2026, 8, 20, 13, 0), dilli)!;

      expect(din.ant.difference(din.aarambh).inHours, inInclusiveRange(23, 25));
    });
  });

  // ── वो दो हालतें जिन पर पूरा फ़ैसला टिका है ─────────────────────────
  //
  // इन्हें कभी "सरल" करने के चक्कर में सूर्योदय या आधी रात पर मत ले
  // जाना — दोनों में से एक हालत टूट जाएगी।
  group('रात की पूजाएँ — आधी रात पर दिन नहीं बदलता', () {
    test('जन्माष्टमी — रात 11 बजे और रात 12:30 एक ही दिन', () {
      // कृष्ण जन्म निशीथ काल में होता है, यानी ठीक आधी रात।
      final pehle = hinduDin(ist(2026, 9, 4, 23, 0), dilli)!;
      final baad = hinduDin(ist(2026, 9, 5, 0, 30), dilli)!;

      expect(baad.ginti, pehle.ginti);
      expect(pehle.ginti, 20260904);
    });

    test('दीपावली — प्रदोष काल की पूजा उसी दिन की है', () {
      final din = hinduDin(ist(2026, 11, 8, 19, 0), dilli)!;

      expect(din.ginti, 20261108);
    });

    test('महाशिवरात्रि — निशीथ की पूजा बीच में नहीं कटती', () {
      final shuru = hinduDin(ist(2026, 2, 15, 23, 45), dilli)!;
      final khatm = hinduDin(ist(2026, 2, 16, 0, 45), dilli)!;

      expect(khatm.ginti, shuru.ginti);
    });
  });

  group('ब्रह्म मुहूर्त में उठने वाले — उन्हें नया दिन मिलता है', () {
    test('सुबह 4:30 की पूजा अगले दिन की गिनी जाती है', () {
      // दिल्ली में 21 अगस्त का सूर्योदय ~5:52 IST, यानी सीमा ~4:16।
      // सूर्योदय वाली पुरानी सीमा इसे 20 अगस्त बताती — और सुबह उठे
      // आदमी को कल की अधूरी पूजा थमा देती।
      final din = hinduDin(ist(2026, 8, 21, 4, 30), dilli)!;

      expect(din.ginti, 20260821);
    });

    test('ब्रह्म मुहूर्त से ठीक पहले अब भी पिछला दिन', () {
      final din = hinduDin(ist(2026, 8, 21, 3, 30), dilli)!;

      expect(din.ginti, 20260820);
    });

    test('सीमा के दोनों किनारे — एक भीतर, एक बाहर', () {
      final din = hinduDin(ist(2026, 8, 20, 13, 0), dilli)!;

      expect(din.samaayeHai(din.aarambh), isTrue);
      expect(din.samaayeHai(din.aarambh.subtract(const Duration(seconds: 1))),
          isFalse);
      expect(din.samaayeHai(din.ant), isFalse);
      expect(
          din.samaayeHai(din.ant.subtract(const Duration(seconds: 1))), isTrue);
    });
  });

  group('samaayeHai', () {
    late HinduDin din;

    setUp(() => din = hinduDin(ist(2026, 8, 20, 13, 0), dilli)!);

    test('उसी दिन की दोपहर, शाम और उसी रात — तीनों भीतर', () {
      expect(din.samaayeHai(ist(2026, 8, 20, 13, 0)), isTrue);
      expect(din.samaayeHai(ist(2026, 8, 20, 19, 30)), isTrue);
      expect(din.samaayeHai(ist(2026, 8, 21, 2, 0)), isTrue,
          reason: 'आधी रात के बाद भी वही दिन');
    });

    test('अगली सुबह ब्रह्म मुहूर्त के बाद बाहर', () {
      expect(din.samaayeHai(ist(2026, 8, 21, 4, 30)), isFalse);
      expect(din.samaayeHai(ist(2026, 8, 21, 9, 0)), isFalse);
    });

    test('पिछली शाम बाहर', () {
      expect(din.samaayeHai(ist(2026, 8, 19, 20, 0)), isFalse);
    });
  });

  group('जगह और रूप', () {
    test('चेन्नई का सूर्योदय अलग है, इसलिए सीमा भी अलग', () {
      final dilliKa = hinduDin(ist(2026, 8, 20, 13, 0), dilli)!;
      final chennaiKa = hinduDin(ist(2026, 8, 20, 13, 0), Place.chennai)!;

      expect(chennaiKa.ginti, dilliKa.ginti);
      expect(chennaiKa.aarambh, isNot(dilliKa.aarambh));
    });

    test('local DateTime भी चलता है — असली पल तो वही है', () {
      // ऐप `DateTime.now()` भेजता है, जो local होता है।
      final asli = ist(2026, 8, 20, 13, 0);

      expect(
          hinduDin(asli.toLocal(), dilli)!.ginti, hinduDin(asli, dilli)!.ginti);
    });
  });
}
