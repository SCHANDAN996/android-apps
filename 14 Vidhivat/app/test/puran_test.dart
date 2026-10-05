import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';

/// वेद और पुराण — **परिचय**। पाठ नहीं, गद्य।
///
/// अठारह पुराण (→ D-113): आधार पुराणों की अपनी सूचियाँ — मत्स्य ५३, भागवत
/// १२.७ और १२.१३, विष्णु ३.६ (`docs/18_SROT_PANJI.md` अध्याय २८)।
/// चार वेद (→ D-114): संहिताओं के ढाँचे की गिनती डिजिटल पाठों में मशीन से;
/// वेद का बँटना विष्णु ३.४ से (अध्याय २९)।
void main() {
  const dir = 'assets/granth/puran';

  /// (शीर्षक में नाम, भागवत १२.१३ की गिनती, मत्स्य ५३ की गिनती) — विष्णु ३.६ के क्रम में।
  /// यह तालिका `tools/granth_paath/puran/milan/pu_suchi.py` से अलग, दोबारा लिखी गई है।
  const suchi = <(String, int, int)>[
    ('ब्रह्म पुराण', 10000, 13000),
    ('पद्म पुराण', 55000, 55000),
    ('विष्णु पुराण', 23000, 23000),
    ('शिव पुराण — या वायु पुराण', 24000, 24000),
    ('भागवत पुराण', 18000, 18000),
    ('नारद पुराण', 25000, 25000),
    ('मार्कण्डेय पुराण', 9000, 9000),
    ('अग्नि पुराण', 15400, 16000),
    ('भविष्य पुराण', 14500, 14500),
    ('ब्रह्मवैवर्त पुराण', 18000, 18000),
    ('लिङ्ग पुराण', 11000, 11000),
    ('वराह पुराण', 24000, 24000),
    ('स्कन्द पुराण', 81100, 81100),
    ('वामन पुराण', 10000, 10000),
    ('कूर्म पुराण', 17000, 18000),
    ('मत्स्य पुराण', 14000, 14000),
    ('गरुड पुराण', 19000, 19000),
    ('ब्रह्माण्ड पुराण', 12000, 12200),
  ];
  const ank = '०१२३४५६७८९';
  const hazar = {
    9: 'नौ', 10: 'दस', 11: 'ग्यारह', 12: 'बारह', 13: 'तेरह', 14: 'चौदह',
    15: 'पंद्रह', 16: 'सोलह', 17: 'सत्रह', 18: 'अठारह', 19: 'उन्नीस',
    23: 'तेईस', 24: 'चौबीस', 25: 'पच्चीस', 55: 'पचपन', 81: 'इक्यासी',
  };
  const sau = {1: 'एक', 2: 'दो', 4: 'चार', 5: 'पाँच'};

  String dev(int n) =>
      n.toString().split('').map((c) => ank[int.parse(c)]).join();
  String shabd(int n) {
    final h = n ~/ 1000, s = (n % 1000) ~/ 100;
    return '${hazar[h]} हज़ार${s == 0 ? '' : ' ${sau[s]} सौ'}';
  }

  late GranthKram kram;
  late Paath parichay;
  late Paath atharah;
  late Paath ved;

  setUpAll(() {
    kram = GranthKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    Paath padho(String id) =>
        Paath.parse('$dir/$id.json', File('$dir/$id.json').readAsStringSync());
    parichay = padho('puran_parichay');
    atharah = padho('puran_atharah');
    ved = padho('puran_ved');
  });

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है; तीन पन्ने, क्रम में', () {
      final sab = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = sab.singleWhere((g) => g.id == 'puran');
      expect(g.naam, 'वेद और पुराण — परिचय');
      expect(g.gintiNaam, 'खंड');
      // सूची की पंक्ति में ही लिखा है कि यह पाठ नहीं है
      expect(g.ekLine, contains('परिचय है, पाठ नहीं'));
      expect(GranthBhandar.granthIds, contains('puran'));
      expect(kram.kram.map((p) => p.id),
          ['puran_ved', 'puran_parichay', 'puran_atharah']);
    });

    test('तीनों पन्ने "सार" हैं — गद्य भरा, रोमन और अर्थ ख़ाली, अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      expect(parichay.khand, hasLength(7));
      expect(atharah.khand, hasLength(18));
      expect(ved.khand, hasLength(7));
      for (final p in [ved, parichay, atharah]) {
        expect(p.prakar, PaathPrakar.saar, reason: p.id);
        expect(p.bhasha, 'हिंदी');
        for (final k in p.khand) {
          expect(k.dev.split(' ').length, greaterThan(8), reason: k.shirshak);
          expect(k.roman, isEmpty, reason: k.shirshak);
          expect(k.arth, isEmpty, reason: k.shirshak);
          expect(latin.hasMatch(k.dev), isFalse, reason: k.shirshak);
          expect(latin.hasMatch(k.shirshak), isFalse, reason: k.shirshak);
        }
      }
    });

    test('🔑 "यह परिचय है — शब्दशः पाठ नहीं" तीनों पन्नों पर खुला रहेगा', () {
      for (final p in [ved, parichay, atharah]) {
        expect(p.saavdhani, contains('यह परिचय है'), reason: p.id);
        expect(p.saavdhani, contains('शब्दशः पाठ नहीं'), reason: p.id);
      }
    });

    test('ⓘ: किन सूचियों से लिखा गया, और गिनती किसकी कही हुई है', () {
      final note = parichay.strot.note;
      expect(note, contains('मत्स्य पुराण का तिरपनवाँ अध्याय'));
      expect(note, contains('श्रीमद्भागवत के बारहवें स्कंध'));
      expect(note, contains('विष्णु पुराण के तीसरे अंश'));
      expect(note, contains('वह यहाँ नहीं जोड़ी गई'));
      expect(note, contains('शब्द ऐप के अपने हैं'));
      expect(atharah.strot.note, note);
    });
  });

  group('अठारह पुराण — एक-एक', () {
    test('अठारह खंड, विष्णु पुराण के गिनाए क्रम में', () {
      expect(atharah.khand.map((k) => k.shirshak), [
        for (final (i, s) in suchi.indexed) '${dev(i + 1)} · ${s.$1}',
      ]);
    });

    test('🔑 हर पुराण के साथ दोनों सूचियों की गिनती — शब्दों में, तालिका से हूबहू', () {
      for (final (i, (naam, b, m)) in suchi.indexed) {
        final t = atharah.khand[i].dev;
        final chahiye = b == m
            ? 'गिनती: दोनों सूचियों में ${shabd(b)} श्लोक।'
            : 'गिनती: भागवत की सूची में ${shabd(b)} श्लोक, '
                'मत्स्य की सूची में ${shabd(m)}।';
        expect(t, contains(chahiye), reason: naam);
        expect('गिनती:'.allMatches(t), hasLength(1), reason: naam);
      }
    });

    test('भागवत की सूची का जोड़ ठीक चार लाख; मत्स्य की सूची का चार लाख से ऊपर', () {
      expect(suchi.fold<int>(0, (a, s) => a + s.$2), 400000);
      expect(suchi.fold<int>(0, (a, s) => a + s.$3), 404800);
      // जहाँ दोनों अलग हैं — वही चार, जो परिचय में गिनाए गए हैं
      expect([
        for (final s in suchi)
          if (s.$2 != s.$3) s.$1.replaceAll(' पुराण', '')
      ], ['ब्रह्म', 'अग्नि', 'कूर्म', 'ब्रह्माण्ड']);
      final kitne = parichay.khand
          .singleWhere((k) => k.shirshak == 'कितने बड़े')
          .dev;
      expect(kitne, contains('ब्रह्म, अग्नि, कूर्म और ब्रह्माण्ड'));
      expect(kitne, contains('चार लाख'));
      // विष्णु पुराण का नापा हुआ उदाहरण
      expect(kitne, contains('तेईस हज़ार'));
      expect(kitne, contains('छह अंश और एक सौ छब्बीस अध्याय'));
      expect(kitne, contains('५,६०६'));
    });

    test('किसने कहा — मत्स्य पुराण की सूची वाली बातें अपनी जगह हैं', () {
      String khand(String naam) =>
          atharah.khand.singleWhere((k) => k.shirshak.endsWith('· $naam')).dev;
      expect(khand('ब्रह्म पुराण'), contains('ब्रह्मा ने पहले महर्षि मरीचि को'));
      expect(khand('विष्णु पुराण'), contains('महर्षि पराशर'));
      expect(khand('मार्कण्डेय पुराण'), contains('पक्षियों को लेकर'));
      expect(khand('अग्नि पुराण'), contains('अग्नि ने वसिष्ठ को'));
      expect(khand('ब्रह्मवैवर्त पुराण'), contains('सावर्णि ने नारद को'));
      expect(khand('वराह पुराण'), contains('भगवान विष्णु ने पृथ्वी को'));
      expect(khand('स्कन्द पुराण'), contains('सबसे बड़ा पुराण'));
      expect(khand('मत्स्य पुराण'), contains('तिरपनवें अध्याय'));
      // हर खंड बताता है कि बात किसकी कही हुई है
      for (final k in atharah.khand) {
        expect(
            k.dev.contains('मत्स्य पुराण की सूची') ||
                k.dev.contains('अपने बारे में यह कहता है'),
            isTrue,
            reason: k.shirshak);
      }
    });

    test('शिव या वायु — दोनों नाम, और ऐप किसी को ग़लत नहीं कहता', () {
      final chautha = atharah.khand[3].dev;
      expect(chautha, contains('«शैव»'));
      expect(chautha, contains('«वायवीय»'));
      final k = parichay.khand
          .singleWhere((k) => k.shirshak == 'चौथा पुराण — शिव या वायु')
          .dev;
      expect(k, contains('कहीं शिव पुराण गिना जाता है, कहीं वायु पुराण'));
      expect(k, contains('किसी को ग़लत नहीं कहता'));
    });

    test('🔑 "इस ऐप में" — जो कहा है वह ऐप की उसी कथा के स्रोत-नोट में लिखा है', () {
      // (खंड का नाम, [(फ़ाइल, उसमें होने चाहिए ये शब्द)])
      final jod = <String, List<(String, List<String>)>>{
        'पद्म पुराण': [
          ('assets/katha/ekadashi_utpatti.json', ['पद्म पुराण']),
        ],
        'शिव पुराण — या वायु पुराण': [
          ('assets/katha/shivratri_shikari.json', ['शिव पुराण', 'कोटिरुद्र संहिता']),
          ('assets/katha/vinayak_chaturthi.json', ['शिव पुराण', 'रुद्र संहिता']),
        ],
        'भागवत पुराण': [
          ('assets/katha/krishna_janm.json', ['श्रीमद्भागवत पुराण', 'दशम स्कंध']),
        ],
        'मार्कण्डेय पुराण': [
          ('assets/paath/saptashati/_kram.json', ['मार्कण्डेय पुराण']),
          ('assets/katha/durga_mahishasur.json', ['मार्कण्डेय पुराण']),
        ],
        'भविष्य पुराण': [
          ('assets/katha/hartalika.json', ['भविष्य पुराण']),
          ('assets/katha/anant_chaturdashi.json', ['भविष्य पुराण']),
        ],
        'ब्रह्मवैवर्त पुराण': [
          ('assets/katha/chhath_shashthi.json', ['ब्रह्मवैवर्त पुराण']),
        ],
        'स्कन्द पुराण': [
          ('assets/katha/satyanarayan.json', ['स्कंद पुराण', 'रेवा खंड']),
          ('assets/katha/pradosh_vrat.json', ['स्कंद पुराण', 'ब्रह्मोत्तर खंड']),
          ('assets/katha/varalakshmi.json', ['स्कंद पुराण']),
        ],
      };
      for (final k in atharah.khand) {
        final naam = k.shirshak.split(' · ').last;
        expect(k.dev.contains('इस ऐप में:'), jod.containsKey(naam),
            reason: naam);
        for (final (path, shabdSab)
            in jod[naam] ?? const <(String, List<String>)>[]) {
          final s = File(path).readAsStringSync();
          for (final w in shabdSab) {
            expect(s, contains(w), reason: '$naam ← $path');
          }
        }
      }
      // "प्रायः जोड़ी जाती है" वाली कथाओं पर वही सावधानी यहाँ भी
      String khand(String naam) =>
          atharah.khand.singleWhere((k) => k.shirshak.endsWith('· $naam')).dev;
      expect(khand('पद्म पुराण'), contains('प्रायः इसी पुराण से जोड़ी जाती है'));
      expect(khand('ब्रह्मवैवर्त पुराण'), contains('प्रायः इसी पुराण से जोड़ी जाती है'));
      expect(khand('स्कन्द पुराण'), contains('प्रायः इसी पुराण से जोड़ी जाती है'));
      expect(khand('भविष्य पुराण'), contains('प्रायः इसी से जोड़ी जाती है'));
    });
  });

  group('पुराण क्या हैं', () {
    test('सात खंड; पाँच लक्षण और अठारह नाम', () {
      expect(parichay.khand.map((k) => k.shirshak), [
        'पुराण क्या है',
        'एक से अठारह',
        'अठारह नाम',
        'चौथा पुराण — शिव या वायु',
        'कितने बड़े',
        'उपपुराण',
        'इस ऐप में',
      ]);
      final pehla = parichay.khand.first.dev;
      for (final l in ['सर्ग', 'प्रतिसर्ग', 'वंश', 'मन्वन्तर', 'वंशानुचरित']) {
        expect(pehla, contains(l), reason: l);
      }
      expect(
          parichay.khand[2].dev,
          contains('ब्रह्म, पद्म, विष्णु, शिव, भागवत, नारद, मार्कण्डेय, अग्नि, भविष्य, '
              'ब्रह्मवैवर्त, लिङ्ग, वराह, स्कन्द, वामन, कूर्म, मत्स्य, गरुड और ब्रह्माण्ड'));
      expect(parichay.khand[1].dev, contains('सौ करोड़ श्लोकों का'));
      expect(parichay.khand[1].dev, contains('चार लाख श्लोकों में'));
      expect(parichay.khand[5].dev, contains('नारसिंह, नन्दी और साम्ब'));
    });

    test('"इस ऐप में" साफ़ कहता है कि यहाँ पुराणों का पाठ नहीं है', () {
      final k = parichay.khand.last.dev;
      expect(k, contains('यहाँ पुराणों का पाठ नहीं है'));
      expect(k, contains('दुर्गा सप्तशती मार्कण्डेय पुराण का हिस्सा है'));
    });
  });

  group('चार वेद', () {
    String khand(String naam) =>
        ved.khand.singleWhere((k) => k.shirshak == naam).dev;

    /// ऋग्वेद, शाकल शाखा — मण्डल-वार सूक्त। यह तालिका
    /// `tools/granth_paath/puran/milan/ved_suchi.py` से अलग, दोबारा लिखी गई है।
    const mandal = [191, 43, 62, 58, 87, 75, 104, 103, 114, 191];
    const kram10 = [
      'पहले', 'दूसरे', 'तीसरे', 'चौथे', 'पाँचवें', 'छठे', 'सातवें', 'आठवें',
      'नवें', 'दसवें',
    ];

    test('सात खंड — चार वेद, उनका काम, और संहिता के आगे', () {
      expect(ved.khand.map((k) => k.shirshak), [
        'वेद एक, फिर चार',
        'किस वेद का क्या काम',
        'ऋग्वेद',
        'यजुर्वेद',
        'सामवेद',
        'अथर्ववेद',
        'संहिता, और उसके आगे',
      ]);
      expect(ved.devta, 'वेद');
      expect(ved.strot.note, contains('याद से नहीं लिखी गईं'));
      expect(ved.strot.note, contains('वह पुराण की कही हुई बात है'));
      expect(ved.saavdhani, contains('एक-एक शाखा'));
    });

    test('वेद का बँटना — विष्णु पुराण के चार शिष्य और चार ऋत्विज', () {
      final k = khand('वेद एक, फिर चार');
      expect(k, contains('विष्णु पुराण में पराशर कहते हैं'));
      expect(
          k,
          contains('पैल को ऋग्वेद, वैशम्पायन को यजुर्वेद, जैमिनि को सामवेद '
              'और सुमन्तु को अथर्ववेद'));
      expect(
          khand('किस वेद का क्या काम'),
          contains('ऋचाओं से होता का काम, यजुओं से अध्वर्यु का, सामों से उद्गाता का, '
              'और अथर्व-मंत्रों से ब्रह्मा नाम के ऋत्विज का'));
    });

    test('🔑 ऋग्वेद: दस मण्डल, 1,028 सूक्त, 10,552 मंत्र — और मण्डल-वार जोड़ वही', () {
      final k = khand('ऋग्वेद');
      expect(mandal.fold<int>(0, (a, b) => a + b), 1028);
      expect(k, contains('दस मण्डलों में'));
      expect(k, contains('१,०२८ सूक्त और १०,५५२ मंत्र'));
      for (final (i, n) in mandal.indexed) {
        expect(k, contains('${kram10[i]} में ${dev(n)}'), reason: '${i + 1}');
      }
    });

    test('यजुर्वेद, सामवेद, अथर्ववेद की गिनतियाँ', () {
      final y = khand('यजुर्वेद');
      expect(y, contains('शुक्ल यजुर्वेद की संहिता में चालीस अध्याय'));
      expect(y, contains('तैत्तिरीय संहिता में सात काण्ड और चौवालीस प्रपाठक'));
      final sv = khand('सामवेद');
      expect(650 + 1225, 1875);
      expect(sv, contains('कुल १,८७५ मंत्र'));
      expect(sv, contains('पहले भाग में ६५०, दूसरे में १,२२५'));
      final a = khand('अथर्ववेद');
      expect(a, contains('बीस काण्डों में'));
      // सूक्तों की गिनती एक नहीं — यह बात छिपाई नहीं गई
      expect(a, contains('इसलिए गिनती एक नहीं है'));
      expect(a, contains('एक संस्करण में ७३१'));
    });

    test('🔑 "इस ऐप में" — हर बात उसी पाठ की अपनी फ़ाइल में लिखी है', () {
      // (खंड, ऐप की फ़ाइल, उसमें होने चाहिए ये शब्द)
      final jod = <(String, String, List<String>)>[
        ('ऋग्वेद', 'assets/granth/sukta/sukta_purusha.json', ['मण्डल १०, सूक्त ९०']),
        ('ऋग्वेद', 'assets/granth/sukta/sukta_nasadiya.json', ['मण्डल १०, सूक्त १२९']),
        ('ऋग्वेद', 'assets/paath/saptashati/saptashati_devi_sukta.json', ['मण्डल १०, सूक्त १२५']),
        ('ऋग्वेद', 'assets/paath/saptashati/saptashati_ratri_sukta.json', ['मण्डल १०, सूक्त १२७']),
        ('ऋग्वेद', 'assets/paath/vishwakarma_sukta.json', ['मण्डल १०, सूक्त ८१']),
        ('ऋग्वेद', 'assets/granth/sukta/sukta_shri.json', ['ऋग्वेद के खिल']),
        ('ऋग्वेद', 'assets/granth/upanishad/upanishad_aitareya_1.json', ['ऋग्वेद', 'ऐतरेय आरण्यक']),
        ('यजुर्वेद', 'assets/granth/sukta/sukta_purusha_yv.json', ['शुक्ल यजुर्वेद, अध्याय ३१']),
        ('यजुर्वेद', 'assets/granth/upanishad/upanishad_isha.json', ['शुक्ल यजुर्वेद', 'अध्याय ४०']),
        ('यजुर्वेद', 'assets/granth/upanishad/upanishad_katha_11.json', ['कृष्ण यजुर्वेद']),
        ('यजुर्वेद', 'assets/granth/upanishad/upanishad_tait_1.json', ['कृष्ण यजुर्वेद', 'तैत्तिरीय आरण्यक']),
        ('यजुर्वेद', 'assets/granth/upanishad/upanishad_shveta_1.json', ['कृष्ण यजुर्वेद']),
        ('सामवेद', 'assets/granth/upanishad/upanishad_kena.json', ['सामवेद', 'ब्राह्मण का भाग']),
        ('सामवेद', 'assets/granth/gita/gita_10.json', ['वेदानां सामवेदोऽस्मि']),
        ('अथर्ववेद', 'assets/granth/upanishad/upanishad_mundaka_11.json', ['अथर्ववेद']),
        ('अथर्ववेद', 'assets/granth/upanishad/upanishad_prashna_1.json', ['अथर्ववेद']),
        ('अथर्ववेद', 'assets/granth/upanishad/upanishad_mandukya.json', ['अथर्ववेद']),
      ];
      for (final (kh, path, shabdSab) in jod) {
        expect(khand(kh), contains('इस ऐप में:'), reason: kh);
        final s = File(path).readAsStringSync();
        for (final w in shabdSab) {
          expect(s, contains(w), reason: '$kh ← $path');
        }
      }
      final r = khand('ऋग्वेद');
      for (final w in [
        'दसवें मण्डल का नब्बेवाँ सूक्त',
        'एक सौ उनतीसवाँ',
        'सूक्त १२५',
        'सूक्त १२७',
        'सूक्त ८१',
        'ऐतरेय आरण्यक',
      ]) {
        expect(r, contains(w), reason: w);
      }
      expect(khand('यजुर्वेद'), contains('इकतीसवें अध्याय'));
      expect(khand('यजुर्वेद'), contains('चालीसवाँ — आख़िरी — अध्याय'));
      // और यह साफ़ कहा है कि वेदों का पूरा पाठ यहाँ नहीं है
      expect(khand('संहिता, और उसके आगे'),
          contains('इस ऐप में वेदों का पूरा पाठ नहीं है'));
    });
  });

  group('स्क्रीन पर', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
    });

    Widget app(Widget home) => ListenableBuilder(
          listenable: settings,
          builder: (context, _) =>
              MaterialApp(theme: VidhivatTheme.dark(), home: home),
        );

    Future<void> granthKholo(WidgetTester tester,
        {double width = 400, double height = 3000}) async {
      tester.view.physicalSize = Size(width * 3, height * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final g =
          (await granthBhandar.suchi()).singleWhere((g) => g.id == 'puran');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();
    }

    testWidgets('ग्रंथ का पन्ना — दो हिस्से, तीन पन्ने, गिनती "खंड" में', (tester) async {
      await granthKholo(tester);
      expect(find.text('चार वेद'), findsOneWidget);
      expect(find.text('अठारह पुराण'), findsOneWidget);
      expect(find.text('चार वेद — परिचय'), findsOneWidget);
      expect(find.text('पुराण क्या हैं'), findsOneWidget);
      expect(find.text('अठारह पुराण — एक-एक'), findsOneWidget);
      expect(find.text('7 खंड'), findsNWidgets(2));
      expect(find.text('18 खंड'), findsOneWidget);
      // गिनती "श्लोक" में नहीं — ये श्लोक नहीं, गद्य के खंड हैं
      expect(find.text('7 श्लोक'), findsNothing);
      expect(find.text('18 श्लोक'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पन्ना खुलता है: "यह परिचय है" खुला, "अर्थ दिखाएँ" नहीं',
        (tester) async {
      await granthKholo(tester);
      await tester.tap(find.text('अठारह पुराण — एक-एक'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('वेद और पुराण · भाग 3/3'), findsOneWidget);

      // खुला सच — ⓘ के पीछे नहीं (→ D-060)
      expect(find.textContaining('यह परिचय है'), findsOneWidget);
      expect(find.textContaining('शब्दशः पाठ नहीं'), findsOneWidget);

      expect(find.text('सार'), findsOneWidget);
      expect(find.text('पाठ'), findsNothing);
      expect(find.text('18 खंड'), findsOneWidget);
      expect(find.text('अर्थ दिखाएँ'), findsNothing);
      expect(find.text('रोमन दिखाएँ'), findsNothing);
      expect(find.text('१ · ब्रह्म पुराण'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (chaudai, akshar) in [(320.0, 1.5), (360.0, 2.0)]) {
      testWidgets(
          'छोटे फ़ोन पर भी कुछ बाहर नहीं निकलता — $chaudai चौड़ाई, $akshar गुना अक्षर',
          (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = akshar;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await granthKholo(tester, width: chaudai, height: 800);
        expect(tester.takeException(), isNull, reason: 'सूची');
        await tester.scrollUntilVisible(find.text('पुराण क्या हैं'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('पुराण क्या हैं'));
        await tester.pumpAndSettle();
        expect(find.byType(PaathScreen), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'पन्ना');
      });
    }
  });
}
