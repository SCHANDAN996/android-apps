import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// चौघड़िया और होरा की जाँच।
///
/// दोनों तालिकाएँ **Drik से दो वार पर** मिलाई हुई हैं — 20 अगस्त 2026
/// (गुरुवार) और 23 अगस्त 2026 (रविवार)। दो वार इसलिए कि एक से शुरुआती
/// तालिका पक्की होती है और दूसरे से यह कि आगे का क्रम सही चल रहा है।

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

void main() {
  group('चौघड़िया — Drik से हूबहू', () {
    // Drik के पन्ने से सीधे उतारे हुए
    const expected = {
      // गुरुवार
      (2026, 8, 20): (
        day: ['शुभ', 'रोग', 'उद्वेग', 'चर', 'लाभ', 'अमृत', 'काल', 'शुभ'],
        night: ['अमृत', 'चर', 'रोग', 'काल', 'लाभ', 'उद्वेग', 'शुभ', 'अमृत'],
      ),
      // रविवार
      (2026, 8, 23): (
        day: ['उद्वेग', 'चर', 'लाभ', 'अमृत', 'काल', 'शुभ', 'रोग', 'उद्वेग'],
        night: ['शुभ', 'अमृत', 'चर', 'रोग', 'काल', 'लाभ', 'उद्वेग', 'शुभ'],
      ),
    };

    for (final entry in expected.entries) {
      final (y, m, d) = entry.key;
      final want = entry.value;

      test('$d/$m/$y — ${varaNameFor(y, m, d)}', () {
        final all = choghadiya(y, m, d, Place.delhi);
        final day = all.where((s) => s.isDay).map((s) => s.name).toList();
        final night = all.where((s) => !s.isDay).map((s) => s.name).toList();

        expect(day, want.day, reason: 'दिन की चौघड़िया');
        expect(night, want.night, reason: 'रात की चौघड़िया');
      });
    }

    test('रात का क्रम दिन से उल्टा चलता है', () {
      // यह वो जगह है जहाँ याददाश्त से लिखने पर ग़लती हुई थी।
      // दिन में क्रम एक क़दम आगे, रात में **दो क़दम पीछे**।
      final all = choghadiya(2026, 8, 23, Place.delhi);
      final night = all.where((s) => !s.isDay).toList();

      for (var i = 1; i < 8; i++) {
        final previous = choghadiyaNames.indexOf(night[i - 1].name);
        final current = choghadiyaNames.indexOf(night[i].name);
        expect((previous - current + 7) % 7, 2,
            reason: 'रात ${i + 1} — क़दम दो पीछे होना चाहिए');
      }
    });

    test('सोलह टुकड़े — आठ दिन के, आठ रात के', () {
      final all = choghadiya(2026, 8, 20, Place.delhi);
      expect(all.length, 16);
      expect(all.where((s) => s.isDay).length, 8);
      expect(all.where((s) => !s.isDay).length, 8);
    });

    test('टुकड़े बिना छेद के जुड़े हैं, सूर्योदय से अगले सूर्योदय तक', () {
      final p = computePanchang(2026, 8, 20, Place.delhi);
      final all = choghadiya(2026, 8, 20, Place.delhi);

      expect(all.first.start, p.sunrise);
      expect(all.last.end, p.nextSunrise);

      for (var i = 1; i < all.length; i++) {
        expect(all[i].start, all[i - 1].end, reason: 'टुकड़ा $i');
      }
    });

    test('शुभ-अशुभ सही बँटे हैं', () {
      // चर, लाभ, अमृत, शुभ — शुभ। उद्वेग, काल, रोग — अशुभ।
      const shubh = {'चर', 'लाभ', 'अमृत', 'शुभ'};

      for (final slot in choghadiya(2026, 8, 20, Place.delhi)) {
        expect(slot.auspicious, shubh.contains(slot.name), reason: slot.name);
      }
    });

    test('हर वार अपने स्वामी की चौघड़िया से शुरू होता है', () {
      // रवि→उद्वेग(सूर्य) · सोम→अमृत(चंद्र) · मंगल→रोग(मंगल) ·
      // बुध→लाभ(बुध) · गुरु→शुभ(गुरु) · शुक्र→चर(शुक्र) · शनि→काल(शनि)
      const first = {
        0: 'उद्वेग', 1: 'अमृत', 2: 'रोग', 3: 'लाभ',
        4: 'शुभ', 5: 'चर', 6: 'काल',
      };

      for (var d = 17; d <= 23; d++) {
        final vara = DateTime.utc(2026, 8, d).weekday % 7;
        final all = choghadiya(2026, 8, d, Place.delhi);
        expect(all.first.name, first[vara], reason: '8/$d');
      }
    });
  });

  group('होरा — Drik से हूबहू', () {
    test('20 अगस्त 2026 (गुरुवार) के पहले आठ होरा', () {
      // Drik: Jupiter, Mars, Sun, Venus, Mercury, Moon, Saturn, Jupiter
      const want = ['गुरु', 'मंगल', 'सूर्य', 'शुक्र', 'बुध', 'चंद्र', 'शनि', 'गुरु'];
      final h = hora(2026, 8, 20, Place.delhi);

      expect(h.take(8).map((s) => s.name).toList(), want);
      expect(_hm(h.first.start), '05:52'); // Drik 05:53, एक मिनट की छूट
    });

    test('23 अगस्त 2026 (रविवार) सूर्य के होरा से शुरू', () {
      const want = ['सूर्य', 'शुक्र', 'बुध', 'चंद्र', 'शनि'];
      final h = hora(2026, 8, 23, Place.delhi);
      expect(h.take(5).map((s) => s.name).toList(), want);
    });

    test('चौबीस होरा — बारह दिन के, बारह रात के', () {
      final h = hora(2026, 8, 20, Place.delhi);
      expect(h.length, 24);
      expect(h.where((s) => s.isDay).length, 12);
      expect(h.where((s) => !s.isDay).length, 12);
    });

    test('होरा एक घंटे का नहीं होता — दिन और रात में अलग', () {
      // गर्मियों में दिन लंबा, तो दिन का होरा भी लंबा
      final h = hora(2026, 8, 20, Place.delhi);
      final dayHora = h.first.duration;
      final nightHora = h[12].duration;

      expect(dayHora.inMinutes, greaterThan(nightHora.inMinutes));
      expect(dayHora.inMinutes, inInclusiveRange(60, 70));
      expect(nightHora.inMinutes, inInclusiveRange(50, 60));
    });

    test('क्रम दिन-रात के बीच टूटता नहीं', () {
      final h = hora(2026, 8, 20, Place.delhi);
      for (var i = 1; i < h.length; i++) {
        final previous = horaLords.indexOf(h[i - 1].name);
        final current = horaLords.indexOf(h[i].name);
        expect((current - previous + 7) % 7, 1, reason: 'होरा ${i + 1}');
      }
    });

    test('चौबीस होरा बाद अगले वार का स्वामी आता है', () {
      // यही वो सुंदर बात है जिससे वारों का क्रम बना है
      for (var d = 17; d <= 22; d++) {
        final aaj = hora(2026, 8, d, Place.delhi);
        final kal = hora(2026, 8, d + 1, Place.delhi);

        final aage = horaLords[
            (horaLords.indexOf(aaj.last.name) + 1) % 7];
        expect(kal.first.name, aage,
            reason: '8/$d के आख़िरी होरा के बाद 8/${d + 1} का पहला');
      }
    });
  });

  group('अभी क्या चल रहा है', () {
    test('सूर्योदय के ठीक बाद पहली चौघड़िया', () {
      final p = computePanchang(2026, 8, 20, Place.delhi);
      final now = p.sunrise!.add(const Duration(minutes: 5));

      final current = currentChoghadiya(now, Place.delhi);
      expect(current, isNotNull);
      expect(current!.name, 'शुभ');
      expect(current.isDay, isTrue);
    });

    test('आधी रात का समय पिछले दिन की सूची में मिलता है', () {
      // हिंदू दिन सूर्योदय से शुरू होता है — 21 अगस्त की रात 1 बजे
      // असल में 20 अगस्त वाले हिंदू दिन की रात है
      final raat = DateTime.utc(2026, 8, 21, 1, 0);

      final current = currentChoghadiya(raat, Place.delhi);
      expect(current, isNotNull);
      expect(current!.isDay, isFalse);
      expect(current.name, 'लाभ'); // 20/8 की रात का पाँचवाँ
    });

    test('होरा भी उसी तरह मिलता है', () {
      final p = computePanchang(2026, 8, 20, Place.delhi);
      final now = p.sunrise!.add(const Duration(minutes: 5));

      expect(currentHora(now, Place.delhi)!.name, 'गुरु');
    });

    test('आगे की शुभ चौघड़िया मिलती हैं', () {
      final p = computePanchang(2026, 8, 20, Place.delhi);
      // दिन की तीसरी चौघड़िया (उद्वेग, अशुभ) के बीच से देखो
      final now = p.sunrise!.add(const Duration(hours: 3, minutes: 30));

      final aage = upcomingAuspicious(now, Place.delhi, howMany: 3);

      expect(aage.length, 3);
      for (final slot in aage) {
        expect(slot.auspicious, isTrue);
        expect(slot.end.isAfter(now), isTrue);
      }
      // क्रम में होनी चाहिए
      expect(aage[1].start.isAfter(aage[0].start), isTrue);
      expect(aage[2].start.isAfter(aage[1].start), isTrue);
    });
  });

  // ── ऐप वाला `DateTime.now()` — यहीं वो बग छिपा था ─────────────────
  //
  // ऊपर की सारी जाँचें `DateTime.utc(...)` या `p.sunrise` भेजती हैं, जो
  // पहले से घड़ी वाले समय हैं। ऐप असली local पल भेजता है, और उसमें +5:30
  // जुड़ा होता है — इसीलिए फ़ोन पर दोपहर 13:19 बजे स्क्रीन "अभी चल रही
  // है — लाभ 07:24–08:57" दिखा रही थी। जाँचें साफ़ थीं, ऐप ग़लत था।
  //
  // ⚠️ ये जाँचें local `DateTime` से ही चलनी चाहिए। इन्हें कभी
  // `DateTime.utc` में मत बदलना — तब वो बग वापस छिप जाएगा।
  group('local DateTime से भी सही जवाब', () {
    /// वही पल, दो रूपों में — जैसा ऐप भेजता है और जैसा जाँचें भेजती हैं।
    (DateTime local, DateTime ghadi) donoRoop(
      int y,
      int m,
      int d,
      int hh,
      int mm,
    ) =>
        (DateTime(y, m, d, hh, mm), DateTime.utc(y, m, d, hh, mm));

    test('दोपहर की चौघड़िया — local और UTC दोनों से एक ही', () {
      final (local, ghadi) = donoRoop(2026, 8, 20, 13, 19);

      final localSe = currentChoghadiya(local, Place.delhi);
      final ghadiSe = currentChoghadiya(ghadi, Place.delhi);

      expect(localSe, isNotNull);
      expect(localSe!.name, ghadiSe!.name);
      expect(localSe.start, ghadiSe.start);
      // और वो सचमुच उसी वक़्त चल रही हो, 5:30 पहले वाली नहीं
      expect(localSe.start.hour, lessThanOrEqualTo(13));
      expect(localSe.end.hour, greaterThanOrEqualTo(13));
    });

    test('होरा भी local से वही', () {
      final (local, ghadi) = donoRoop(2026, 8, 20, 13, 19);

      expect(currentHora(local, Place.delhi)!.name,
          currentHora(ghadi, Place.delhi)!.name);
    });

    test('आगे की शुभ चौघड़िया — एक भी बीती हुई नहीं', () {
      final (local, ghadi) = donoRoop(2026, 8, 20, 13, 19);

      final aage = upcomingAuspicious(local, Place.delhi, howMany: 3);

      expect(aage.length, 3);
      for (final slot in aage) {
        expect(slot.khatmHoneMein(local), greaterThan(Duration.zero),
            reason: '${slot.name} बीत चुकी है');
      }
      expect(
        aage.map((s) => s.start).toList(),
        upcomingAuspicious(ghadi, Place.delhi, howMany: 3)
            .map((s) => s.start)
            .toList(),
      );
    });

    test('आधी रात का local समय भी पिछले दिन में मिलता है', () {
      final current = currentChoghadiya(DateTime(2026, 8, 21, 1, 0),
          Place.delhi);

      expect(current, isNotNull);
      expect(current!.isDay, isFalse);
      expect(current.name, 'लाभ');
    });

    test('khatmHoneMein — बीत चुकी चौघड़िया ऋणात्मक देती है', () {
      final slots = choghadiya(2026, 8, 20, Place.delhi);
      final pehli = slots.first;

      expect(pehli.khatmHoneMein(DateTime(2026, 8, 20, 13, 19)),
          lessThan(Duration.zero));
      expect(pehli.khatmHoneMein(DateTime(2026, 8, 20, 6, 0)),
          greaterThan(Duration.zero));
    });
  });

  group('जगह बदलने पर', () {
    test('चेन्नई में भी सोलह टुकड़े, सही जुड़े हुए', () {
      final all = choghadiya(2026, 8, 20, Place.chennai);
      expect(all.length, 16);

      for (var i = 1; i < all.length; i++) {
        expect(all[i].start, all[i - 1].end);
      }
    });

    test('नाम जगह से नहीं बदलते, सिर्फ़ समय बदलता है', () {
      final delhi = choghadiya(2026, 8, 20, Place.delhi);
      final chennai = choghadiya(2026, 8, 20, Place.chennai);

      expect(delhi.map((s) => s.name).toList(),
          chennai.map((s) => s.name).toList());
      expect(delhi.first.start == chennai.first.start, isFalse);
    });
  });
}
