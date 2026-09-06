@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

/// पूजा के कंटेंट की जाँच।
///
/// **यह जाँच सबसे ज़्यादा काम की तब आएगी जब बाक़ी ग्यारह पूजाएँ डलेंगी।**
/// एक-एक पूजा में ~40 सामग्री और ~14 चरण होते हैं। हाथ से लिखी JSON में
/// कॉमा छूटना, `zaruri` भूल जाना, या सूची और फ़ाइल का आपस में न मिलना —
/// ये सब यहीं पकड़े जाएँगे, फ़ोन पर नहीं।
///
/// यहाँ फ़ाइलें `dart:io` से पढ़ी जाती हैं, `rootBundle` से नहीं — इसलिए
/// जाँच को Flutter का ऐप चलाने की ज़रूरत नहीं पड़ती।
void main() {
  group('वर्ज्य द्रव्य — A10', () {
    test('हर पूजा पर लागू होने वाली बातें एक ही जगह हैं', () {
      expect(saamaanyaVarjya, isNotEmpty);
      for (final v in saamaanyaVarjya) {
        expect(v.vastu.trim(), isNotEmpty);
        expect(v.kyon.trim(), isNotEmpty);
        expect(v.strot.trim(), isNotEmpty);
      }
    });

    test('विवादित निषेध कहीं नहीं लिखे गए', () {
      // "विष्णु को अक्षत नहीं" वाले श्लोक का ग्रंथ-प्रमाण नहीं मिला और
      // उस पर मतभेद है — इसलिए वह ऐप में नहीं आना चाहिए (→ docs/18 §3)।
      // दुर्गा-दूर्वा और सूर्य-बेलपत्र उसी श्लोक के हैं।
      for (final id in ['ram_pooja', 'krishna_pooja', 'satyanarayan',
                        'nitya_pooja', 'kalash_sthapana', 'surya_arghya']) {
        final path = 'assets/vidhi/$id.json';
        final v = Vidhi.parse(path, File(path).readAsStringSync());
        expect(v.varjya, isEmpty,
            reason: '${v.naam} में विवादित निषेध लिखा है');
      }
    });
  });

  const dir = 'assets/vidhi';
  const suchiPath = '$dir/_suchi.json';

  late List<VidhiSuchiEntry> suchi;

  setUpAll(() {
    suchi = VidhiSuchiEntry.parseAll(
      suchiPath,
      File(suchiPath).readAsStringSync(),
    );
  });

  group('सूची और फ़ाइलें आपस में मेल खाती हैं', () {
    test('सूची पढ़ी जा सकती है और ख़ाली नहीं है', () {
      expect(suchi, isNotEmpty);
    });

    test('हर तैयार पूजा की फ़ाइल सचमुच मौजूद है और पढ़ी जा सकती है', () {
      for (final e in suchi.where((e) => e.taiyar)) {
        final path = '$dir/${e.id}.json';
        expect(
          File(path).existsSync(),
          isTrue,
          reason: 'सूची में "${e.naam}" तैयार लिखी है पर $path है ही नहीं',
        );
        expect(
          () => Vidhi.parse(path, File(path).readAsStringSync()),
          returnsNormally,
          reason: '$path पढ़ी नहीं जा सकी',
        );
      }
    });

    test('जो तैयार नहीं, उसकी फ़ाइल होनी भी नहीं चाहिए', () {
      // वरना फ़ाइल बन चुकी है और सूची अब भी "जल्द आएगी" दिखा रही है।
      for (final e in suchi.where((e) => !e.taiyar)) {
        expect(
          File('$dir/${e.id}.json').existsSync(),
          isFalse,
          reason: '"${e.naam}" की फ़ाइल बन चुकी है — सूची में taiyar सच करो',
        );
      }
    });

    test('फ़ोल्डर की हर फ़ाइल सूची में दर्ज है', () {
      final files = Directory(dir)
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json') && n != '_suchi.json')
          .map((n) => n.substring(0, n.length - 5))
          .toSet();
      final suchiIds = suchi.map((e) => e.id).toSet();

      expect(
        files.difference(suchiIds),
        isEmpty,
        reason: 'ये फ़ाइलें फ़ोल्डर में हैं पर सूची में नहीं',
      );
    });

    test('सूची का नाम, श्रेणी और पास-हालत फ़ाइल से मिलती है', () {
      // सूची अलग फ़ाइल में है ताकि ऐप शुरू होते ही बारह फ़ाइलें न पढ़नी
      // पड़ें। उसकी क़ीमत यह है कि दोनों जगह एक ही बात लिखी होती है —
      // इसलिए हर बार मिलाकर देखना ज़रूरी है।
      for (final e in suchi.where((e) => e.taiyar)) {
        final path = '$dir/${e.id}.json';
        final v = Vidhi.parse(path, File(path).readAsStringSync());

        expect(v.id, e.id, reason: '$path — id नहीं मिली');
        expect(v.naam, e.naam, reason: '$path — नाम नहीं मिला');
        expect(v.shreni, e.shreni, reason: '$path — श्रेणी नहीं मिली');
        expect(v.jaanch.paas, e.paas, reason: '$path — पास-हालत नहीं मिली');
      }
    });
  });

  group('हर तैयार पूजा में वो सब है जो ट्रैकर माँगता है', () {
    // 06_CONTENT_TRACKER.md की "हर पूजा में क्या-क्या चाहिए" वाली सूची।
    for (final id in _taiyarIds(suchiPath, dir)) {
      final path = '$dir/$id.json';
      late Vidhi v;

      setUpAll(() => v = Vidhi.parse(path, File(path).readAsStringSync()));

      group(id, () {
        test('परिचय, कब करें, समय और कठिनाई भरे हैं', () {
          expect(v.parichay.trim(), isNotEmpty);
          expect(v.kabKarein.saral.trim(), isNotEmpty);
          expect(v.samayMinute, greaterThan(0));
        });

        test('सामग्री की सूची है, और हर चीज़ का समूह लिखा है', () {
          expect(v.samagri, isNotEmpty);
          expect(v.zaruriSamagri, isNotEmpty,
              reason: 'एक भी ज़रूरी सामग्री नहीं — कुछ तो छूट गया है');
          for (final s in v.samagri) {
            expect(s.vastu.trim(), isNotEmpty);
            expect(s.samuh.trim(), isNotEmpty,
                reason: '"${s.vastu}" का समूह नहीं लिखा');
          }
        });

        test('चरण हैं, और हर चरण में शीर्षक + विवरण है', () {
          expect(v.charan, isNotEmpty);
          for (final c in v.charan) {
            expect(c.shirshak.trim(), isNotEmpty);
            expect(c.vivaran.trim(), isNotEmpty,
                reason: '"${c.shirshak}" में विवरण नहीं');
          }
        });

        test('संकल्प वाला ठीक एक चरण है', () {
          // हर पूजा संकल्प से शुरू होती है — यही ऐप का सबसे बड़ा फ़र्क़
          // है (→ D-006)। दो संकल्प चरण होना भी ग़लती है।
          final sankalpWale =
              v.charan.where((c) => c.vishesh == CharanVishesh.sankalp);
          expect(sankalpWale.length, 1,
              reason:
                  'संकल्प वाले चरण ${sankalpWale.length} हैं, एक होना चाहिए');
        });

        test('संकल्प का purpose इंजन की सूची में मौजूद है', () {
          // ग़लत कुंजी लिखी तो संकल्प चुपचाप "देवपूजनं" पर गिर जाएगा।
          if (v.sankalpPurpose.isEmpty) return;
          expect(commonPurposes.containsKey(v.sankalpPurpose), isTrue,
              reason: '"${v.sankalpPurpose}" commonPurposes में नहीं है। '
                  'चलेंगी: ${commonPurposes.keys.join(", ")}');
        });

        test('कम से कम तीन सवाल-जवाब हैं', () {
          expect(v.sawaal.length, greaterThanOrEqualTo(3));
        });

        test('समय कदमों के जोड़ के बराबर है (→ D-027)', () {
          // पहले बारहों में घोषित समय जोड़ से कम था — यूज़र आधा घंटा
          // सोचकर बैठता और डेढ़ घंटा लग जाता।
          final jod = v.charan.fold<int>(0, (a, c) => a + c.samayMinute);
          expect(v.samayMinute, jod,
              reason: 'घोषित ${v.samayMinute} बनाम जोड़ $jod');
        });

        // ── A9: आवाहन है तो विसर्जन भी हो ────────────────────────
        // पूजा का ढाँचा आवाहन → उपचार → विसर्जन है। ऐप में आवाहन तो
        // था, विसर्जन कहीं नहीं — जबकि जो क्षमा-श्लोक अंत में बोला
        // जाता है उसकी पहली पंक्ति ही है "न जानामि विसर्जनम्"।
        test('देवता का आवाहन है तो विसर्जन का कदम भी है (→ A9)', () {
          final naam = v.charan.map((c) => c.shirshak).toList();
          final devAavahan = naam.any((n) => n.contains('आवाहन'));
          final visarjan = naam.any((n) => n == 'विसर्जन');

          if (!devAavahan) {
            expect(visarjan, isFalse,
                reason: '${v.naam}: आवाहन नहीं, फिर विसर्जन क्यों?');
            return;
          }
          // नवरात्रि इकलौता अपवाद है — देवी नौ दिन के लिए बैठती हैं,
          // पहले दिन विसर्जन होता ही नहीं (वजह कदम में लिखी है)।
          if (v.id == 'kalash_sthapana') {
            expect(visarjan, isFalse);
            return;
          }
          expect(visarjan, isTrue,
              reason: '${v.naam}: आवाहन है पर विसर्जन का कदम नहीं');
        });

        test('विसर्जन आवाहन के बाद आता है, और अंत के पास', () {
          final naam = v.charan.map((c) => c.shirshak).toList();
          final v0 = naam.indexOf('विसर्जन');
          if (v0 < 0) return;
          final a0 = naam.indexWhere((n) => n.contains('आवाहन'));
          expect(a0, greaterThanOrEqualTo(0), reason: v.naam);
          expect(v0, greaterThan(a0),
              reason: '${v.naam}: विसर्जन आवाहन से पहले आ गया');
          // आख़िरी तीन कदमों में होना चाहिए
          expect(v0, greaterThanOrEqualTo(naam.length - 3),
              reason: '${v.naam}: विसर्जन बीच में पड़ा है');
        });

        // ── A10: क्या नहीं चढ़ाना ─────────────────────────────────
        test('जो वर्ज्य लिखा है वो सामग्री की सूची में नहीं होना चाहिए', () {
          // यही पूरी बात है — अगर कोई चीज़ "मत चढ़ाइए" में है और सूची
          // में भी है, तो ऐप ख़ुद अपने से उलटा कह रहा है।
          final sooch = v.samagri.map((s) => s.vastu).join(' ');
          for (final varjya in v.varjya) {
            expect(sooch.contains(varjya.vastu), isFalse,
                reason: '${v.naam}: "${varjya.vastu}" वर्ज्य है, '
                    'फिर सामग्री में क्यों?');
          }
        });

        test('हर वर्ज्य के साथ वजह और स्रोत दोनों लिखे हैं', () {
          for (final varjya in v.varjya) {
            expect(varjya.vastu.trim(), isNotEmpty, reason: v.naam);
            expect(varjya.kyon.trim(), isNotEmpty,
                reason: '${v.naam}: "${varjya.vastu}" की वजह नहीं लिखी');
            expect(varjya.strot.trim(), isNotEmpty,
                reason: '${v.naam}: "${varjya.vastu}" का स्रोत नहीं लिखा');
          }
        });

        // ── आरती का लिंक (→ D-039) ──────────────────────────────
        test('हर आरती वाले कदम से कोई पाठ जुड़ा है', () {
          // पाठ पंद्रह जगह दोहराया नहीं जाता — कदम सिर्फ़ नाम रखता है।
          // नाम न हो तो यूज़र के लिए वो कदम ख़ाली डिब्बा बन जाता है।
          for (final c in v.charan) {
            if (c.vishesh != CharanVishesh.aarti) continue;
            expect(c.paath, isNotEmpty,
                reason: '${v.naam} / ${c.shirshak}: आरती का कदम है '
                    'पर कोई पाठ नहीं जुड़ा');
          }
        });

        test('जुड़ा हुआ हर पाठ सचमुच मौजूद है', () {
          // ग़लत id लिखी तो ऐप में बटन दिखेगा ही नहीं — चुपचाप ग़ायब।
          for (final c in v.charan) {
            for (final id in c.paath) {
              expect(
                File('assets/paath/$id.json').existsSync(),
                isTrue,
                reason: '${v.naam} / ${c.shirshak}: "$id" नाम का '
                    'कोई पाठ नहीं है',
              );
            }
          }
        });

        test('scope लिखा है, और उसी के हिसाब से विधि खुलती है', () {
          // preparation_only / expert_assisted वाली पूजा की पूरी विधि
          // नहीं खुलनी चाहिए (→ D-026)।
          expect(Scope.values, contains(v.scope));
          if (v.scope == Scope.expertAssisted ||
              v.scope == Scope.preparationOnly) {
            expect(v.scope.poorViDhiKholSakteHain, isFalse);
          }
        });

        test('जो सामग्री किसी कदम में माँगी है वो सूची में भी है', () {
          // audit 5.2 — गणेश में पंचामृत, कलश/करवा/शिव में दूर्वा गायब थे।
          final sooch = v.samagri.map((s) => s.vastu).join(' ');
          final sabKadam = v.charan.map((c) => c.vivaran).join(' ');
          for (final cheez in ['पंचामृत', 'दूर्वा']) {
            if (sabKadam.contains(cheez)) {
              expect(sooch.contains(cheez) || v.samagriSamuhWar.keys.join(' ').contains(cheez),
                  isTrue,
                  reason: '"$cheez" किसी कदम में माँगी है पर सामग्री में नहीं');
            }
          }
        });

        // ⚠️ यह जाँच दो बार फ़ोन पर पकड़ी गई ग़लती के बाद लिखी गई।
        //
        // JSON में `**bold**` इसलिए है कि पंडित जी वाली .md शीट में वो
        // शब्द मोटे दिखें। पर ऐप में markdown renderer नहीं — वहाँ वो
        // कच्चे तारे बनकर दिखते थे ("**डूबते सूर्य**")।
        //
        // पहले हर स्क्रीन पर अलग-अलग हटाया गया, और `parichay` छूट गया।
        // अब `_str()` पढ़ते ही हटा देता है — यह जाँच उसी का पहरा है।
        test('ऐप में कहीं markdown के कच्चे तारे नहीं दिखते', () {
          final sabText = [
            v.naam, v.parichay, v.kabKarein.saral, v.kabKarein.note,
            v.strot.paddhati, v.strot.kshetra, v.strot.note,
            ...v.upnaam,
            ...v.samagri.map((s) => '${s.vastu} ${s.note}'),
            ...v.varjya.map((x) => '${x.vastu} ${x.kyon} ${x.strot}'),
            ...v.sawaal.map((q) => '${q.sawaal} ${q.jawaab}'),
            ...v.charan.expand((c) => [
                  c.shirshak,
                  c.vivaran,
                  if (c.mantra != null) ...[
                    c.mantra!.devanagari, c.mantra!.roman, c.mantra!.arth,
                    c.mantra!.strot, c.mantra!.vikalp,
                  ],
                ]),
          ].join(' ');
          expect(sabText.contains('**'), isFalse,
              reason: '${v.naam} में कहीं ** बचा है — यूज़र को कच्चे '
                  'तारे दिखेंगे');
        });

        test('स्रोत लिखा है — ऐप में यही दिखता है', () {
          expect(v.strot.paddhati.trim(), isNotEmpty);
          expect(v.strot.kshetra.trim(), isNotEmpty);
        });

        test('हर लिखे हुए मंत्र के साथ स्रोत और भरोसे का दर्जा है', () {
          // बिना स्रोत के लिखा पाठ ड्राफ़्ट नहीं, अंदाज़ा है (→ D-022)।
          for (final c in v.charan) {
            final m = c.mantra;
            if (m == null || !m.hasPath) continue;
            expect(m.strot.trim(), isNotEmpty,
                reason: '"${c.shirshak}" के मंत्र का स्रोत नहीं लिखा');
            expect(m.arth.trim(), isNotEmpty,
                reason: '"${c.shirshak}" के मंत्र का सरल अर्थ नहीं लिखा');
            expect(m.roman.trim(), isNotEmpty,
                reason: '"${c.shirshak}" के मंत्र का रोमन रूप नहीं लिखा');
          }
        });

        test('जो मंत्र ख़ाली है उस पर वजह लिखी है', () {
          // ख़ाली छोड़ना ठीक है — चुपचाप ख़ाली छोड़ना नहीं।
          for (final c in v.charan) {
            final m = c.mantra;
            if (m == null || m.hasPath) continue;
            expect(m.vikalp.trim(), isNotEmpty,
                reason: '"${c.shirshak}" का मंत्र ख़ाली है पर वजह नहीं लिखी');
          }
        });

        test('जिस मंत्र की रिकॉर्डिंग लिखी है वो फ़ाइल मौजूद है', () {
          for (final c in v.charan) {
            final audio = c.mantra?.audio ?? '';
            if (audio.isEmpty) continue;
            expect(File('$dir/audio/$audio').existsSync(), isTrue,
                reason: '"${c.shirshak}" की रिकॉर्डिंग $audio नहीं मिली');
          }
        });
      });
    }
  });

  group('ढाँचा ग़लत कंटेंट को अंदर नहीं आने देता', () {
    // ये पाँच जाँचें ही असली रखवाली हैं। इनके बिना कोई भी अधूरी पूजा
    // चुपचाप "तैयार" दिखने लगेगी।

    test('बिना पाठ के मंत्र "पास" नहीं हो सकता', () {
      expect(
        () => Vidhi.parse('जाँच', _vidhiWithMantra('''
          "devanagari": "", "roman": "", "arth": "",
          "audio": "", "strot": "कोई किताब", "sthiti": "paas"
        ''')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('बिना स्रोत के मंत्र "पास" नहीं हो सकता', () {
      expect(
        () => Vidhi.parse('जाँच', _vidhiWithMantra('''
          "devanagari": "कुछ पाठ", "roman": "", "arth": "",
          "audio": "", "strot": "", "sthiti": "paas"
        ''')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('पाठ लिखा हो तो sthiti "khaali" नहीं रह सकती', () {
      expect(
        () => Vidhi.parse('जाँच', _vidhiWithMantra('''
          "devanagari": "कुछ पाठ", "roman": "", "arth": "",
          "audio": "", "strot": "", "sthiti": "khaali"
        ''')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('बिना स्रोत के मंत्र "draft" भी नहीं हो सकता', () {
      expect(
        () => Vidhi.parse('जाँच', _vidhiWithMantra('''
          "devanagari": "कुछ पाठ", "roman": "", "arth": "",
          "audio": "", "strot": "", "sthiti": "draft"
        ''')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('ग़लत bharosa वाला मंत्र नहीं चलेगा', () {
      expect(
        () => Vidhi.parse('जाँच', _vidhiWithMantra('''
          "devanagari": "कुछ पाठ", "roman": "", "arth": "",
          "audio": "", "strot": "कोई किताब", "bharosa": "bahut-uncha",
          "sthiti": "draft"
        ''')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('कच्चे मंत्र वाली पूजा "पास" नहीं हो सकती', () {
      final json = _vidhiWithMantra('''
        "devanagari": "कुछ पाठ", "roman": "", "arth": "",
        "audio": "", "strot": "कोई किताब", "sthiti": "draft"
      ''').replaceFirst(
        '"panditNaam": "", "tarikh": "", "paas": false',
        '"panditNaam": "कोई पंडित जी", "tarikh": "2026-09-15", "paas": true',
      );
      expect(() => Vidhi.parse('जाँच', json),
          throwsA(isA<VidhiFormatException>()));
    });

    test('बिना पंडित जी के नाम के पूजा "पास" नहीं हो सकती', () {
      final json = _vidhiWithMantra('''
        "devanagari": "", "roman": "", "arth": "",
        "audio": "", "strot": "", "sthiti": "khaali"
      ''').replaceFirst(
        '"panditNaam": "", "tarikh": "", "paas": false',
        '"panditNaam": "", "tarikh": "", "paas": true',
      );
      expect(() => Vidhi.parse('जाँच', json),
          throwsA(isA<VidhiFormatException>()));
    });

    test('ग़लत scope वाली फ़ाइल नहीं चलेगी', () {
      final json = _vidhiWithMantra('''
        "devanagari": "", "roman": "", "arth": "",
        "audio": "", "strot": "", "sthiti": "khaali"
      ''').replaceFirst('"scope": "self_guided"', '"scope": "jo-mann-aaye"');
      expect(() => Vidhi.parse('जाँच', json),
          throwsA(isA<VidhiFormatException>()));
    });

    test('समय जोड़ से न मिले तो फ़ाइल नहीं चलेगी', () {
      final json = _vidhiWithMantra('''
        "devanagari": "", "roman": "", "arth": "",
        "audio": "", "strot": "", "sthiti": "khaali"
      ''').replaceFirst('"samayMinute": 2', '"samayMinute": 99');
      expect(() => Vidhi.parse('जाँच', json),
          throwsA(isA<VidhiFormatException>()));
    });

    test('ग़लत schemaVersion वाली फ़ाइल नहीं चलेगी', () {
      final json = _vidhiWithMantra('''
        "devanagari": "", "roman": "", "arth": "",
        "audio": "", "strot": "", "sthiti": "khaali"
      ''').replaceFirst('"schemaVersion": 1', '"schemaVersion": 99');
      expect(() => Vidhi.parse('जाँच', json),
          throwsA(isA<VidhiFormatException>()));
    });

    test('बिना चरण वाली पूजा player तक नहीं पहुँच सकती', () {
      final data = jsonDecode(_vidhiWithMantra('''
        "devanagari": "", "roman": "", "arth": "",
        "audio": "", "strot": "", "sthiti": "khaali"
      ''')) as Map<String, dynamic>;
      data['charan'] = <Object?>[];
      expect(
        () => Vidhi.parse('जाँच', jsonEncode(data)),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('ग़लती के संदेश में फ़ाइल का नाम आता है', () {
      // बारह पूजाओं में यह बहुत काम आएगा — पता चलना चाहिए कि किस फ़ाइल में।
      try {
        Vidhi.parse('satyanarayan.json', '{"schemaVersion": 99}');
        fail('फेंकना चाहिए था');
      } on VidhiFormatException catch (e) {
        expect(e.toString(), contains('satyanarayan.json'));
      }
    });
  });

  group('🚧 कंटेंट की नापी हुई हालत', () {
    // शुभ मुहूर्त वाली जाँच की तरह — आज की हालत **नाप कर** दर्ज करते हैं,
    // ताकि सुधार होने पर पता चले कि सच में हुआ या सिर्फ़ लगा (→ D-019)।
    test('कितनी पूजाएँ, कितने मंत्र, कितनी रिकॉर्डिंग', () {
      final taiyar = suchi.where((e) => e.taiyar).toList();
      final paas = suchi.where((e) => e.paas).length;

      var mantraKul = 0, mantraBhare = 0, mantraAudio = 0;
      final bharosaGinti = <Bharosa, int>{};
      for (final e in taiyar) {
        final path = '$dir/${e.id}.json';
        final v = Vidhi.parse(path, File(path).readAsStringSync());
        mantraKul += v.mantraKul;
        mantraBhare += v.mantraBhareHue;
        mantraAudio += v.mantraAudioWale;
        for (final c in v.charan) {
          final m = c.mantra;
          if (m == null || !m.hasPath) continue;
          bharosaGinti[m.bharosa] = (bharosaGinti[m.bharosa] ?? 0) + 1;
        }
      }
      final bharosaLine = Bharosa.values
          .map((b) => '${b.naam} ${bharosaGinti[b] ?? 0}')
          .join(' · ');

      // ignore: avoid_print
      print('''

  🚧 कंटेंट की हालत
     पूजाएँ       ${taiyar.length} / ${suchi.length} की फ़ाइल बनी
     पंडित जी से  $paas / ${suchi.length} पास
     मंत्र        $mantraBhare / $mantraKul का पाठ भरा (ड्राफ़्ट)
     भरोसा        $bharosaLine
     रिकॉर्डिंग   $mantraAudio / $mantraKul
     ➜ रिलीज़ के लिए: बारहों पास, हर मंत्र भरा और रिकॉर्ड किया हुआ
''');

      // यह जाँच कुछ रोकती नहीं — सिर्फ़ हालत दिखाती है।
      expect(taiyar.length, lessThanOrEqualTo(suchi.length));
    });
  });
}

/// सूची से तैयार पूजाओं की id — `setUpAll` से पहले चाहिए होती हैं,
/// इसलिए फ़ाइल यहाँ सीधे पढ़ी जाती है।
List<String> _taiyarIds(String suchiPath, String dir) =>
    VidhiSuchiEntry.parseAll(suchiPath, File(suchiPath).readAsStringSync())
        .where((e) => e.taiyar)
        .map((e) => e.id)
        .toList(growable: false);

/// जाँच के लिए सबसे छोटी चलने लायक पूजा, जिसमें एक मंत्र डाला जा सके।
String _vidhiWithMantra(String mantraFields) => '''
{
  "schemaVersion": 1,
  "id": "jaanch",
  "naam": "जाँच वाली पूजा",
  "upnaam": [],
  "shreni": "nitya",
  "scope": "self_guided",
  "parichay": "सिर्फ़ जाँच के लिए",
  "kabKarein": { "saral": "कभी भी", "tithiSuchi": [], "vaarSuchi": [], "note": "", "dohrata": true },
  "samayMinute": 2,
  "kathinai": "aasan",
  "sankalpPurpose": "",
  "samagri": [
    { "vastu": "जल", "matra": "1", "ikai": "लोटा", "zaruri": true, "samuh": "थाली", "note": "" }
  ],
  "charan": [
    {
      "shirshak": "पहला कदम",
      "vivaran": "कुछ करो",
      "samayMinute": 2,
      "vishesh": "saada",
      "mantra": { $mantraFields }
    }
  ],
  "sawaal": [],
  "strot": { "paddhati": "जाँच", "kshetra": "जाँच", "note": "" },
  "jaanch": { "panditNaam": "", "tarikh": "", "paas": false }
}
''';
