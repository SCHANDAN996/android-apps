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

/// महाभारत — अठारह पर्वों का **सार** (→ D-111): पाठ नहीं, गद्य; आधार महाभारत
/// का अपना पर्वसंग्रह। और **यक्ष प्रश्न** पूरे पाठ में (→ D-112): छपी पुस्तकों
/// वाला अध्याय ३१३, 133 श्लोक। और **भीष्म स्तवराज** (→ D-115): शांति पर्व
/// का अध्याय ४७, 108 श्लोक। स्रोत `docs/18_SROT_PANJI.md` अध्याय २७।
void main() {
  const dir = 'assets/granth/mahabharat';
  const ank = '०१२३४५६७८९';

  /// "७,९८४" → 7984
  int ginti(String s) => int.parse(s
      .replaceAll(',', '')
      .split('')
      .map((c) => ank.indexOf(c).toString())
      .join());

  late GranthKram kram;
  late Map<String, Paath> paath;
  late List<Paath> parv; // p01 … p18, क्रम में
  late List<Paath> saar; // परिचय + अठारह पर्व — गद्य वाले
  late Paath yaksha;
  late Paath stavaraj;
  late Paath anusmriti;
  late List<Paath> vn; // विदुर नीति के आठ पन्ने, क्रम में
  late List<Paath> ss; // सनत्सुजातीय के पाँच पन्ने, क्रम में

  setUpAll(() {
    kram = GranthKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse(
            '$dir/${p.id}.json', File('$dir/${p.id}.json').readAsStringSync()),
    };
    parv = [
      for (var i = 1; i <= 18; i++)
        paath['mahabharat_p${i.toString().padLeft(2, '0')}']!,
    ];
    saar = [paath['mahabharat_parichay']!, ...parv];
    yaksha = paath['mahabharat_yaksha']!;
    stavaraj = paath['mahabharat_stavaraj']!;
    anusmriti = paath['mahabharat_anusmriti']!;
    vn = [for (var i = 1; i <= 8; i++) paath['mahabharat_vn$i']!];
    ss = [for (var i = 1; i <= 5; i++) paath['mahabharat_ss$i']!];
  });

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है; परिचय, अठारह पर्व और यक्ष प्रश्न, क्रम में', () {
      final suchi = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'mahabharat');
      expect(g.naam, 'महाभारत');
      expect(g.gintiNaam, 'खंड');
      expect(GranthBhandar.granthIds, contains('mahabharat'));

      expect(kram.kram.map((p) => p.id), [
        'mahabharat_parichay',
        for (var i = 1; i <= 18; i++)
          'mahabharat_p${i.toString().padLeft(2, '0')}',
        'mahabharat_yaksha',
        'mahabharat_stavaraj',
        'mahabharat_anusmriti',
        for (var i = 1; i <= 8; i++) 'mahabharat_vn$i',
        for (var i = 1; i <= 5; i++) 'mahabharat_ss$i',
      ]);
      expect(kram.kram.map((p) => p.naam).skip(1).take(18), [
        'आदि पर्व', 'सभा पर्व', 'वन पर्व', 'विराट पर्व', 'उद्योग पर्व',
        'भीष्म पर्व', 'द्रोण पर्व', 'कर्ण पर्व', 'शल्य पर्व', 'सौप्तिक पर्व',
        'स्त्री पर्व', 'शांति पर्व', 'अनुशासन पर्व', 'आश्वमेधिक पर्व',
        'आश्रमवासिक पर्व', 'मौसल पर्व', 'महाप्रस्थानिक पर्व',
        'स्वर्गारोहण पर्व',
      ]);
    });

    test('परिचय और अठारहों पर्व "सार" हैं — गद्य भरा, रोमन और अर्थ ख़ाली', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      expect(saar, hasLength(19));
      for (final p in saar) {
        expect(p.prakar, PaathPrakar.saar, reason: p.id);
        expect(p.bhasha, 'हिंदी', reason: p.id);
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.dev.trim().split(RegExp(r'\s+')).length, greaterThan(7),
              reason: kahan);
          expect(k.roman, isEmpty, reason: kahan);
          expect(k.arth, isEmpty, reason: kahan);
          expect(latin.hasMatch(k.dev), isFalse, reason: kahan);
        }
      }
      // सूची की गिनती = खंडों की गिनती
      for (final s in kram.kram) {
        expect(s.shlok, paath[s.id]!.khandKul, reason: s.id);
      }
    });

    test('🔑 "यह सार है, शब्दशः पाठ नहीं" हर सार वाले पन्ने पर खुला रहेगा', () {
      for (final p in saar) {
        expect(p.saavdhani, contains('यह सार है'), reason: p.id);
        expect(p.saavdhani, contains('शब्दशः पाठ नहीं'), reason: p.id);
      }
      // यक्ष प्रश्न पूरा पाठ है — उस पर यह पंक्ति लगना झूठ होता
      expect(yaksha.saavdhani, isEmpty);
      expect(stavaraj.saavdhani, isEmpty);
      expect(anusmriti.saavdhani, isEmpty);
      for (final p in [...vn, ...ss]) {
        expect(p.saavdhani, isEmpty, reason: p.id);
      }
    });
  });

  group('गिनती — पर्वसंग्रह और समीक्षित संस्करण', () {
    final nazar = RegExp(r'पर्वसंग्रह की गिनती: ([०-९,]+) अध्याय, ([०-९,]+) श्लोक। '
        r'समीक्षित संस्करण में (?:भी )?([०-९,]+) अध्याय।');

    test('हर पर्व का पहला खंड "एक नज़र में", और उसमें दोनों गिनतियाँ', () {
      // पर्वसंग्रह (१.२.९५–२३२) के शब्दों से पढ़ी हुई गिनती
      const parvasangraha = [
        (218, 7984), (72, 2511), (269, 11664), (67, 2050), (186, 6698),
        (117, 5884), (170, 8909), (69, 4900), (59, 3220), (18, 870),
        (27, 775), (339, 14525), (146, 6700), (133, 3320), (42, 1506),
        (8, 300), (3, 120), (5, 200),
      ];
      // समीक्षित संस्करण की फ़ाइलों से मशीन की गिनती
      const samikshit = [
        225, 72, 299, 67, 197, 117, 173, 69, 64, 18, 27, 353, 154, 96, 47, 9,
        3, 5,
      ];
      for (var i = 0; i < 18; i++) {
        final pehla = parv[i].khand.first;
        expect(pehla.shirshak, 'एक नज़र में', reason: parv[i].id);
        final m = nazar.firstMatch(pehla.dev);
        expect(m, isNotNull, reason: parv[i].id);
        expect(ginti(m!.group(1)!), parvasangraha[i].$1, reason: parv[i].id);
        expect(ginti(m.group(2)!), parvasangraha[i].$2, reason: parv[i].id);
        expect(ginti(m.group(3)!), samikshit[i], reason: parv[i].id);
        // "भी" तभी, जब दोनों गिनतियाँ एक हों
        expect(pehla.dev.contains('संस्करण में भी'),
            parvasangraha[i].$1 == samikshit[i],
            reason: parv[i].id);
      }
    });

    test('परिचय का जोड़ पर्वों की गिनती से मिलता है', () {
      var adhyay = 0, shlok = 0, samikshit = 0;
      for (final p in parv) {
        final m = nazar.firstMatch(p.khand.first.dev)!;
        adhyay += ginti(m.group(1)!);
        shlok += ginti(m.group(2)!);
        samikshit += ginti(m.group(3)!);
      }
      expect(adhyay, 1948);
      expect(shlok, 82136);
      expect(samikshit, 1995);
      final kitna = paath['mahabharat_parichay']!
          .khand
          .singleWhere((k) => k.shirshak == 'कितना बड़ा')
          .dev;
      expect(kitna, contains('१,९४८ अध्याय और ८२,१३६ श्लोक'));
      expect(kitna, contains('१,९९५ अध्याय'));
      expect(kitna, contains('एक लाख श्लोकों'));
    });
  });

  group('कथा', () {
    String sab(Paath p) => p.khand.map((k) => k.dev).join('\n');

    test('जो हिस्से ग्रंथालय में पूरे पाठ के साथ हैं, उनका पता सही पर्व में', () {
      expect(sab(parv[5]), contains('गीता')); // भीष्म
      expect(sab(parv[5]), contains('अध्याय २३ से ४० तक'));
      expect(sab(parv[12]), contains('विष्णु सहस्रनाम')); // अनुशासन
      expect(sab(parv[12]), contains('अध्याय १३५'));
      expect(sab(parv[4]), contains('विदुर नीति')); // उद्योग
      expect(sab(parv[4]), contains('सनत्सुजात'));
      expect(sab(parv[2]), contains('यक्ष के प्रश्नों')); // वन
    });

    test('हर पर्व की पहचान वाली घटना अपने पर्व में है', () {
      const pehchan = [
        ['जनमेजय', 'भीष्म', 'द्रौपदी का विवाह', 'खांडव वन'],
        ['राजसूय', 'जरासंध', 'शिशुपाल', 'शकुनि'],
        ['नल और दमयंती', 'किरात', 'जयद्रथ', 'सावित्री', 'कुंडल'],
        ['शमी', 'कीचक', 'उत्तरा'],
        ['उपप्लव्य', 'अक्षौहिणी', 'संजय', 'योगेश्वर', 'अंबा'],
        ['जंबूखंड', 'शिखंडी', 'दस दिन'],
        ['संशप्तक', 'अभिमन्यु', 'जयद्रथ', 'नारायणास्त्र'],
        ['शल्य', 'त्रिपुर', 'कर्ण को मार देते हैं'],
        ['शल्य', 'गदायुद्ध', 'सरस्वती'],
        ['कृतवर्मा', 'अश्वत्थामा', 'सात्यकि', 'तर्पण'],
        ['विलाप', 'गांधारी', 'दाह'],
        ['राजधर्म', 'आपद्धर्म', 'मोक्षधर्म'],
        ['दानों का फल', 'भीष्म स्वर्ग को जाते हैं'],
        ['संवर्त', 'परीक्षित', 'बभ्रुवाहन', 'नेवले'],
        ['गांधारी', 'कुंती', 'विदुर', 'नारद'],
        ['एरका', 'बलराम', 'द्वारका', 'गांडीव'],
        ['उत्तर दिशा', 'कुत्ता', 'इंद्र', 'द्वैतवन'],
        ['दुर्योधन', 'देवदूत', 'तीसरी परीक्षा', 'आकाशगंगा', '«जय»'],
      ];
      for (var i = 0; i < 18; i++) {
        for (final shabd in pehchan[i]) {
          expect(sab(parv[i]), contains(shabd),
              reason: '${parv[i].naam}: "$shabd"');
        }
      }
    });

    test('ⓘ बताता है कि सार किस पर टिका है — और क्या नहीं जोड़ा गया', () {
      final note = parv[0].strot.note;
      expect(note, contains('पर्वसंग्रह'));
      expect(note, contains('जो बात वहाँ नहीं है, वह यहाँ भी नहीं जोड़ी गई'));
      expect(note, contains('शब्द ऐप के अपने हैं'));
      // आख़िरी दो पर्व सीधे अपने पाठ से
      for (final p in [parv[16], parv[17]]) {
        expect(p.strot.note, contains('सीधे इन पर्वों के पाठ को पढ़कर'),
            reason: p.id);
      }
    });
  });

  group('यक्ष प्रश्न — पूरा पाठ', () {
    const ank = '०१२३४५६७८९';
    int dev(String s) =>
        int.parse(s.split('').map((c) => ank.indexOf(c).toString()).join());
    final shirshak = RegExp(r'^(.+) · श्लोक ([०-९]+)(?:–([०-९]+))?$');

    test('48 खंड; शीर्षकों के श्लोक-अंक 1 से 133 तक, बिना छेद', () {
      expect(yaksha.prakar, PaathPrakar.granth);
      expect(yaksha.bhasha, 'संस्कृत');
      expect(yaksha.khand, hasLength(48));
      var agla = 1;
      for (final k in yaksha.khand) {
        final m = shirshak.firstMatch(k.shirshak);
        expect(m, isNotNull, reason: k.shirshak);
        final a = dev(m!.group(2)!);
        final b = m.group(3) == null ? a : dev(m.group(3)!);
        expect(a, agla, reason: k.shirshak);
        expect(b, greaterThanOrEqualTo(a), reason: k.shirshak);
        // खंड में उतने ही श्लोक हैं जितने शीर्षक कहता है
        expect('॥'.allMatches(k.dev).length, b - a + 1, reason: k.shirshak);
        agla = b + 1;
      }
      expect(agla - 1, 133);
    });

    test('33 प्रश्न-खंड, क्रम से; हर एक में पहले यक्ष, फिर युधिष्ठिर', () {
      final prashn =
          yaksha.khand.where((k) => k.shirshak.startsWith('प्रश्न ')).toList();
      expect(prashn, hasLength(33));
      for (final (i, k) in prashn.indexed) {
        expect(dev(k.shirshak.split(' ')[1]), i + 1);
        final y = k.dev.indexOf('यक्ष उवाच');
        final u = k.dev.indexOf('युधिष्ठिर उवाच');
        expect(y, 0, reason: k.shirshak);
        expect(u, greaterThan(y), reason: k.shirshak);
        expect(k.arth, startsWith('यक्ष ने पूछा — '), reason: k.shirshak);
        expect(k.arth, contains('युधिष्ठिर ने कहा — '), reason: k.shirshak);
      }
      // पहले दस खंड कथा के हैं
      expect(yaksha.khand.take(10).every((k) => !k.shirshak.startsWith('प्रश्न')),
          isTrue);
      expect(yaksha.khand[10].shirshak, 'प्रश्न १ · श्लोक ४५–४६');
    });

    test('हर खंड में पाठ, रोमन और अर्थ; देवनागरी में अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      for (final k in yaksha.khand) {
        expect(k.dev, isNotEmpty, reason: k.shirshak);
        expect(k.roman, isNotEmpty, reason: k.shirshak);
        expect(k.arth.split(' ').length, greaterThan(8), reason: k.shirshak);
        expect(latin.hasMatch(k.dev), isFalse, reason: k.shirshak);
        expect(latin.hasMatch(k.arth), isFalse, reason: k.shirshak);
      }
    });

    test('जो श्लोक सबको याद हैं, वे अपनी जगह हैं', () {
      String khand(String s) =>
          yaksha.khand.singleWhere((k) => k.shirshak.endsWith(s)).dev;
      expect(khand('श्लोक ५९–६०'), contains('माता गुरुतरा भूमेः'));
      expect(khand('श्लोक ५९–६०'), contains('चिन्ता बहुतरी तृणात्'));
      final chaar = khand('श्लोक ११४–११८');
      for (final pankti in [
        'को मोदते किमाश्चर्यं कः पन्थाः का च वार्तिका',
        'अहन्यहनि भूतानि गच्छन्तीह यमालयम्',
        'शेषाः स्थावरमिच्छन्ति किमाश्चर्यमतः परम्',
        'तर्कोऽप्रतिष्ठः श्रुतयो विभिन्ना',
        'महाजनो येन गतः स पन्थाः',
        'भूतानि कालः पचतीति वार्ता',
      ]) {
        expect(chaar, contains(pankti), reason: pankti);
      }
      expect(khand('श्लोक १२८–१३२'),
          contains('धर्म एव हतो हन्ति धर्मो रक्षति रक्षितः'));
      expect(yaksha.khand.first.dev, startsWith('वैशंपायन उवाच'));
      expect(yaksha.khand.last.dev, contains('जीवन्तु भरतर्षभ'));
    });

    test('छपी पुस्तक की पाँच भूलें — दूसरे पाठों वाला रूप लिया गया (→ D-112)', () {
      final sab = yaksha.khand.map((k) => k.dev).join('\n');
      for (final (liya, chhapa) in [
        ('गान्धारराजरचितं', 'गान्धारराजचारितं'),
        ('किं नु हित्वा प्रियो भवति', 'हित्वा न प्रियो भवति'),
        ('भयार्थं चैव राजसु', 'भवार्थं चैव राजसु'),
        ('स कस्मान्नकुलं राजन्', 'कस्मान्नकुलो राजन्'),
        ('यथा कुन्ती तथा माद्री', 'यथा कुन्ती यथा माद्री'),
      ]) {
        expect(sab, contains(liya), reason: liya);
        expect(sab, isNot(contains(chhapa)), reason: chhapa);
      }
    });

    test('ⓘ: कौन सा पाठ है, समीक्षित संस्करण में क्या नहीं, और आचरण वाली बात', () {
      final note = yaksha.strot.note;
      expect(note, contains('एक सौ तैंतीस श्लोक'));
      expect(note, contains('चौहत्तर श्लोक'));
      expect(note, contains('दूसरी पाठ-परंपरा है, भूल नहीं'));
      expect(note, contains('आचरण से पहचाना जाता है, जन्म से'));
      expect(note, contains('अर्थ अपने शब्दों में है'));
      // परिचय में आगे-पीछे की कथा — और सार वाली पंक्ति नहीं
      expect(yaksha.parichay, contains('अरणी'));
      expect(yaksha.parichay, contains('वे स्वयं धर्म हैं'));
    });
  });

  group('भीष्म स्तवराज — पूरा पाठ', () {
    const ank = '०१२३४५६७८९';
    int dev(String s) =>
        int.parse(s.split('').map((c) => ank.indexOf(c).toString()).join());
    final shirshak = RegExp(r'^(.+) · श्लोक ([०-९]+)(?:–([०-९]+))?$');
    String khand(String s) =>
        stavaraj.khand.singleWhere((k) => k.shirshak.endsWith(s)).dev;

    test('32 खंड; शीर्षकों के श्लोक-अंक 1 से 108 तक, बिना छेद', () {
      expect(stavaraj.prakar, PaathPrakar.granth);
      expect(stavaraj.bhasha, 'संस्कृत');
      expect(stavaraj.khand, hasLength(32));
      var agla = 1;
      for (final k in stavaraj.khand) {
        final m = shirshak.firstMatch(k.shirshak);
        expect(m, isNotNull, reason: k.shirshak);
        final a = dev(m!.group(2)!);
        final b = m.group(3) == null ? a : dev(m.group(3)!);
        expect(a, agla, reason: k.shirshak);
        // खंड में उतने ही श्लोक हैं जितने शीर्षक कहता है
        expect('॥'.allMatches(k.dev).length, b - a + 1, reason: k.shirshak);
        agla = b + 1;
      }
      expect(agla - 1, 108);
    });

    test('हर खंड में पाठ, रोमन और अर्थ; देवनागरी में अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      for (final k in stavaraj.khand) {
        expect(k.dev, isNotEmpty, reason: k.shirshak);
        expect(k.roman, isNotEmpty, reason: k.shirshak);
        expect(k.arth.split(' ').length, greaterThan(8), reason: k.shirshak);
        expect(latin.hasMatch(k.dev), isFalse, reason: k.shirshak);
        expect(latin.hasMatch(k.arth), isFalse, reason: k.shirshak);
      }
    });

    test('🔑 श्लोक ३८ से ८३ — छियालीस बार "…आत्मने नमः", और अर्थ में उतने ही नमस्कार', () {
      final beech = stavaraj.khand.where((k) {
        final a = dev(shirshak.firstMatch(k.shirshak)!.group(2)!);
        return a >= 38 && a <= 83;
      }).toList();
      expect(beech, hasLength(15));
      var kul = 0;
      for (final k in beech) {
        // संधि में «आ» मात्रा बन जाता है (सूर्यात्मने) — इसलिए मात्रा से ढूँढो
        final n = 'ात्मने नमः'.allMatches(k.dev).length;
        expect(n, '॥'.allMatches(k.dev).length, reason: k.shirshak);
        expect('को नमस्कार।'.allMatches(k.arth).length, n, reason: k.shirshak);
        kul += n;
      }
      expect(kul, 46);
      // बाक़ी खंडों में यह टेक नहीं है
      for (final k in stavaraj.khand.where((k) => !beech.contains(k))) {
        expect(k.dev, isNot(contains('त्मने नमः')), reason: k.shirshak);
      }
    });

    test('जो श्लोक सबको याद हैं, वे अपनी जगह हैं', () {
      expect(stavaraj.khand.first.dev, startsWith('जनमेजय उवाच'));
      expect(stavaraj.khand.first.dev, contains('शरतल्पे शयानस्तु भरतानां पितामहः'));
      expect(khand('श्लोक १६–१७'), startsWith('भीष्म उवाच'));
      expect(khand('श्लोक १६–१७'), contains('आरिराधयिषुः कृष्णं'));
      final ek = khand('श्लोक ९०–९२');
      for (final pankti in [
        'अतसीपुष्पसङ्काशं पीतवाससमच्युतम्',
        'एकोऽपि कृष्णस्य कृतः प्रणामो',
        'दशाश्वमेधावभृथेन तुल्यः',
        'कृष्णप्रणामी न पुनर्भवाय',
        // छपाई में पाद के बीच टूटा शब्द जोड़कर
        'ते कृष्णदेहाः प्रविशन्ति कृष्णमाज्यं यथा मन्त्रहुतं हुताशे',
      ]) {
        expect(ek, contains(pankti), reason: pankti);
      }
      expect(khand('श्लोक ९३–९५'), contains('नमो ब्रह्मण्यदेवाय गोब्राह्मणहिताय च'));
      expect(khand('श्लोक ९३–९५'), contains('हरिरित्यक्षरद्वयम्'));
      expect(khand('श्लोक ९६–९९'), contains('नारायणः परं ब्रह्म नारायणपरं तपः'));
      expect(stavaraj.khand.last.dev, contains('स केशिहा मुदितमनाभ्यनन्दत'));
    });

    test('छपी पुस्तिका की ग्यारह भूलें — दूसरे पाठों वाला रूप लिया गया (→ D-115)', () {
      final sab = stavaraj.khand.map((k) => k.dev).join('\n');
      for (final (liya, chhapa) in [
        ('पुरुषव्याघ्रः कर्मणा', 'पुरुषव्याघ्र कर्मणा'),
        ('युक्त्वा सर्वात्मनात्मानं', 'मुक्त्वा सर्वात्मनात्मानं'),
        ('यदङ्गेष्वनुतिष्ठति', 'मदङ्गेष्वनुतिष्ठति'),
        ('एकं द्वादशधा जज्ञे', 'द्वादशधा यज्ञे'),
        ('उन्मादः सर्वभूतानां', 'उन्मादाः सर्वभूतानां'),
        ('क्षेत्रे क्षेत्रज्ञमासीनं', 'क्षेत्रक्षेत्रज्ञमासीनं'),
        ('युगसहस्रान्ते प्रदीप्तार्चिर्विभावसुः', 'सहस्रान्तप्रदीप्तार्चि'),
        ('सर्गप्रलयविक्रियाः', 'सर्वप्रलयविक्रियाः'),
        ('धर्मव्युत्क्रान्तगौरवम्', 'धर्मवित् क्रान्तगौरवम्'),
        ('तस्मै दृप्तात्मने नमः', 'दृप्त्यात्मने'),
        ('पथि सुमनाः स शुश्रुवे', 'पथि सुमना स शुश्रुवे'),
      ]) {
        expect(sab, contains(liya), reason: liya);
        expect(sab, isNot(contains(chhapa)), reason: chhapa);
      }
    });

    test('ⓘ: कौन सा पाठ है, दूसरे पाठों में कितने श्लोक, और सड़सठवें श्लोक की बात', () {
      final note = stavaraj.strot.note;
      expect(note, contains('एक सौ आठ श्लोक'));
      expect(note, contains('बहत्तर श्लोक'));
      expect(note, contains('एक सौ पैंतालीस'));
      expect(note, contains('दूसरी पाठ-परंपरा है, भूल नहीं'));
      expect(note, contains('वही बात जो पुरुष सूक्त में है'));
      expect(note, contains('अर्थ अपने शब्दों में है'));
      expect(khand('श्लोक ६५–६७'), contains('ब्रह्म वक्त्रं भुजौ क्षत्रं'));
      expect(stavaraj.parichay, contains('पंचरत्न गीता'));
      // परिचय की गिनती पाठ से मिलती है: 15 + 84 + 9 = 108
      expect(stavaraj.parichay, contains('पहले पंद्रह श्लोकों'));
      expect(stavaraj.parichay, contains('चौरासी'));
      expect(stavaraj.parichay, contains('छियालीस श्लोक'));
      expect(stavaraj.parichay, contains('अंत के नौ श्लोकों'));
    });
  });

  group('अनुस्मृति — पूरा पाठ', () {
    const ank = '०१२३४५६७८९';
    int dev(String s) =>
        int.parse(s.split('').map((c) => ank.indexOf(c).toString()).join());
    final shirshak = RegExp(r'^(.+) · श्लोक ([०-९]+)(?:–([०-९]+))?$');
    // औज़ार एक दण्ड «।» से पहले न टूटने वाली जगह लगाता है — मिलान के लिए सादी जगह
    String saaf(String s) => s.replaceAll('\u00A0', ' ');
    String khand(String s) =>
        saaf(anusmriti.khand.singleWhere((k) => k.shirshak.endsWith(s)).dev);
    String sab() => saaf(anusmriti.khand.map((k) => k.dev).join('\n'));

    test('25 खंड; शीर्षकों के श्लोक-अंक 1 से 102 तक, बिना छेद', () {
      expect(anusmriti.prakar, PaathPrakar.granth);
      expect(anusmriti.bhasha, 'संस्कृत');
      expect(anusmriti.khand, hasLength(25));
      var agla = 1;
      for (final k in anusmriti.khand) {
        final m = shirshak.firstMatch(k.shirshak);
        expect(m, isNotNull, reason: k.shirshak);
        // स्क्रीन की गिनती शीर्षक के पहले शब्द से तय होती है — «मंत्र · …» नाम का
        // खंड पूरे पाठ को "1 मंत्र" बना देता था (11 अक्टूबर 2026 को पकड़ा गया)
        for (final w in ['श्लोक', 'मंत्र', 'अनुवाक', 'चौपाई', 'दोहा']) {
          expect(k.shirshak.startsWith(w), isFalse, reason: k.shirshak);
        }
        final a = dev(m!.group(2)!);
        final b = m.group(3) == null ? a : dev(m.group(3)!);
        expect(a, agla, reason: k.shirshak);
        // खंड में उतने ही श्लोक हैं जितने शीर्षक कहता है
        expect('॥'.allMatches(k.dev).length, b - a + 1, reason: k.shirshak);
        agla = b + 1;
      }
      expect(agla - 1, 102);
    });

    test('हर खंड में पाठ, रोमन और अर्थ; देवनागरी में अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      final nagari = RegExp(r'[\u0900-\u097F]');
      for (final k in anusmriti.khand) {
        expect(k.dev, isNotEmpty, reason: k.shirshak);
        expect(k.roman, isNotEmpty, reason: k.shirshak);
        expect(nagari.hasMatch(k.roman), isFalse, reason: k.shirshak);
        expect(k.arth.split(' ').length, greaterThan(8), reason: k.shirshak);
        expect(latin.hasMatch(k.dev), isFalse, reason: k.shirshak);
        expect(latin.hasMatch(k.arth), isFalse, reason: k.shirshak);
      }
    });

    test('कौन बोल रहा है — आठ जगह, पुस्तिका के क्रम में', () {
      final vakta = RegExp(r'^(.+वाच) ।$', multiLine: true)
          .allMatches(sab())
          .map((m) => m.group(1))
          .toList();
      expect(vakta, [
        'शतानीक उवाच', 'शौनक उवाच', 'युधिष्ठिर उवाच', 'भीष्म उवाच',
        'नारद उवाच', 'भीष्म उवाच', 'श्रीभगवानुवाच', 'भीष्म उवाच',
      ]);
      expect(saaf(anusmriti.khand.first.dev),
          startsWith('शतानीक उवाच ।\nमहामते महाप्राज्ञ सर्वशास्त्रविशारद'));
      expect(khand('श्लोक १३–१६'), startsWith('श्रीभगवानुवाच ।\nहन्त ते कथयिष्यामि'));
      expect(khand('श्लोक ८६–८९'), startsWith('भीष्म उवाच ।\nहरेः पृष्टं पुरा तेन'));
    });

    test('🔑 मंत्र और प्रार्थना: «स मे विष्णुः प्रसीदतु» नौ बार, «तमस्मि शरणं गतः» पाँच, '
        '«स महात्मा प्रसीदतु» पाँच — और अर्थ में उतनी ही बार', () {
      expect(khand('श्लोक १३–१६'), contains('ॐ नमो भगवते वासुदेवाय इत्ययम्'));
      final s = sab();
      final a = anusmriti.khand.map((k) => k.arth).join(' ');
      expect('स मे विष्णुः प्रसीदतु'.allMatches(s), hasLength(9));
      expect('वे विष्णु मुझ पर प्रसन्न हों।'.allMatches(a), hasLength(9));
      expect('तमस्मि शरणं गतः'.allMatches(s), hasLength(5));
      expect('शरण में मैं आया हूँ।'.allMatches(a), hasLength(6)); // + श्लोक १९ का «प्रपन्नोऽस्मि»
      expect('स महात्मा प्रसीदतु'.allMatches(s), hasLength(5));
      expect('वे महात्मा प्रसन्न हों।'.allMatches(a), hasLength(5));
    });

    test('जानी-पहचानी पंक्तियाँ अपनी जगह हैं', () {
      expect(khand('श्लोक ५–८'), contains('प्रयाणकाले किं चिन्त्यं मुमुक्षोस्तत्त्वचिन्तकैः'));
      expect(khand('श्लोक २९–३३'), contains('चतुर्भिश्च चतुर्भिश्च द्वाभ्यां पञ्चभिरेव च'));
      expect(khand('श्लोक ५०–५३'), contains('सूत्रे मणिगणा इव'));
      expect(khand('श्लोक ६२–६४'), contains('त्वामेवाहं स्मरिष्यामि मरणे पर्यवस्थिते'));
      expect(khand('श्लोक ९०–९४'), contains('नमो नारायणायेति मन्त्रः सर्वार्थसाधकः'));
      expect(khand('श्लोक १००–१०२'),
          contains('अद्यापि न निवर्तन्ते द्वादशाक्षरचिन्तकाः'));
      expect(khand('श्लोक १००–१०२'), contains('तं वासुदेवं प्रणमन्न सीदति'));
      expect(saaf(anusmriti.khand.last.dev),
          endsWith('स वीतरागो विचरेन्महीमिमाम् ॥'));
    });

    test('🔑 पाठ पुस्तिका वाला है — जहाँ दूसरी छपी पुस्तक अलग है, वहाँ उसका रूप नहीं लिया गया', () {
      final s = sab();
      for (final (yahan, vahan) in [
        ('कल्य उत्थाय मानवः', 'कल्प उत्थाय'),
        ('महर्षेः सत्त्वभावनम्', 'महर्षे सत्त्वभावनम्'),
        ('सर्वावास वरप्रद', 'सर्ववास वरप्रद'),
        ('अनन्यभक्ता जानन्ति', 'अन्यभक्ता न जान'),
        ('उपतिष्ठन्तु मा सर्वे', 'उपतिष्ठन्तु मां सर्वे'),
        ('पठेद्यत्नेन च समभ्यसेत्', 'पठेद्यत्र यत्र'),
        ('जुह्वद् बलिं ददत्', 'जुह्वन् बलिं ददन्'),
        ('अवाप्स्यसि ततः सिद्धिं प्राप्स्यसे', 'अवाप्स्यति ततः'),
        ('नासौ पदमवाप्नोति', 'नासौ परमवाप्नोति'),
      ]) {
        expect(s, contains(yahan), reason: yahan);
        expect(s, isNot(contains(vahan)), reason: vahan);
      }
      // दो श्लोकों का क्रम भी पुस्तिका वाला: पहले «श्रुत्वैवं नारदो…», फिर «त्वमप्येकमना…»
      final k = khand('श्लोक ८६–८९');
      expect(k.indexOf('श्रुत्वैवं नारदो वाक्यं'),
          lessThan(k.indexOf('त्वमप्येकमना भूत्वा')));
    });

    test('जिन शब्दों का अर्थ पक्का नहीं, वे अर्थ में गढ़े नहीं गए — और पहेली पहेली ही कही गई', () {
      final a = anusmriti.khand.map((k) => k.arth).join(' ');
      // «पार्थो» (३६) को दोनों छपे गुजराती भाषान्तर अलग खोलते हैं — अर्थ में नहीं
      for (final w in ['पार्थ', 'संगमन', 'सत्त्वभावन']) {
        expect(a, isNot(contains(w)), reason: w);
      }
      // जिन पर दोनों छपे भाषान्तर (1890 अहमदाबाद, भिक्षु अखण्डानन्द) एक हैं, वे अब अर्थ में (D-158)
      expect(a, contains('महर्षियों में सत्त्व को उपजाते और पालते हैं')); // २१
      expect(a, contains('गति करने वाले हैं')); // ३६ संगमनः
      expect(a, contains('पाँच कालों को जानने वाले')); // ३६ पञ्च कालज्ञः
      final paheli = anusmriti.khand
          .singleWhere((k) => k.shirshak.endsWith('श्लोक २९–३३'))
          .arth;
      expect(paheli, contains('शमी के गर्भ का जो गर्भ है'));
      expect(paheli, contains('यह श्लोक पहेली की तरह है; उसका खुलासा यहाँ नहीं किया गया'));
    });

    test('अर्थ बताता है कि प्रार्थना कहाँ शुरू और कहाँ पूरी होती है', () {
      String arth(String s) =>
          anusmriti.khand.singleWhere((k) => k.shirshak.endsWith(s)).arth;
      expect(arth('श्लोक १७–२४'), contains('(यहाँ से प्रार्थना के शब्द हैं।)'));
      expect(arth('श्लोक ६५–६८'), endsWith('(प्रार्थना यहाँ पूरी होती है।)'));
      expect(arth('श्लोक ६९–७२'), startsWith('(आगे फिर भगवान के वचन हैं।)'));
      // परिचय और «कैसे पढ़ें» की गिनती खंडों से मिलती है
      expect(anusmriti.parichay, contains('सत्रहवें से अड़सठवें श्लोक तक'));
      expect(anusmriti.kaisePadhein, contains('पाँचवें से सोलहवें खंड तक प्रार्थना के शब्द हैं'));
      expect(anusmriti.khand[4].shirshak, endsWith('श्लोक १७–२४'));
      expect(anusmriti.khand[15].shirshak, endsWith('श्लोक ६५–६८'));
      expect(anusmriti.khand[16].shirshak, endsWith('श्लोक ६९–७२'));
      expect(anusmriti.khand[21].shirshak, endsWith('श्लोक ८६–८९'));
    });

    test('ⓘ: कौन सा पाठ, कैसे पढ़ा गया, और महाभारत में कहाँ मिला', () {
      expect(anusmriti.strot.paddhati, contains('पंचरत्न गीता की पुस्तकों का पाठ'));
      expect(anusmriti.strot.paddhati, contains('शांति पर्व'));
      final note = anusmriti.strot.note;
      expect(note.length, lessThanOrEqualTo(600));
      expect(note, contains('एक सौ दो श्लोक'));
      expect(note, contains('दो अलग प्रकाशकों की छपी पुस्तकें आँख से पढ़ी गईं'));
      expect(note, contains('पाठ में कोई सुधार नहीं किया गया'));
      expect(note, contains('दोनों पुस्तकें इसे महाभारत के अनुशासन पर्व का कहती हैं'));
      expect(note, contains('वहाँ यह शांति पर्व में है — दक्षिण के पाठ में'));
      expect(note, contains('दूसरी परंपरा है, भूल नहीं'));
      expect(note, contains('कुछ कठिन शब्द अर्थ में छोड़े गए हैं'));
      expect(anusmriti.parichay, contains('पाँचों ग्रंथालय में हैं'));
    });

    test('🔑 पाठ का फल ग्रंथ के शब्द हैं — ऐप का दावा नहीं', () {
      expect(anusmriti.kaisePadhein,
          contains('पाठ का फल ग्रंथ के अपने शब्द हैं, ऐप का दावा नहीं'));
      expect(anusmriti.kabPadhein, contains('पाठ के अपने शब्दों में'));
    });
  });

  group('विदुर नीति — उद्योग पर्व के आठ अध्याय (→ D-124, D-125)', () {
    const ank = '०१२३४५६७८९';
    int dev(String s) =>
        int.parse(s.split('').map((c) => ank.indexOf(c).toString()).join());
    final shirshak = RegExp(r'^(.+) · श्लोक ([०-९]+)(?:–([०-९]+))?$');
    // औज़ार एक दण्ड «।» से पहले न टूटने वाली जगह लगाता है — मिलान के लिए सादी जगह
    String saaf(String s) => s.replaceAll(' ', ' ');
    String sab(Paath p) => saaf(p.khand.map((k) => k.dev).join('\n'));
    String sabKuchh() => vn.map(sab).join('\n');

    test('आठ पन्ने: खंड 28 · 17 · 16 · 14 · 22 · 16 · 18 · 9; कुल 593 श्लोक — हर पन्ने पर 1 से, बिना छेद', () {
      expect(vn.map((p) => p.khand.length), [28, 17, 16, 14, 22, 16, 18, 9]);
      const shlok = [128, 86, 77, 74, 64, 47, 85, 32];
      for (var i = 0; i < 8; i++) {
        final p = vn[i];
        expect(p.prakar, PaathPrakar.granth, reason: p.id);
        expect(p.bhasha, 'संस्कृत', reason: p.id);
        expect(p.naam, startsWith('विदुर नीति ${ank[i + 1]} — '));
        expect(kram.kram.singleWhere((e) => e.id == p.id).ekLine, contains('अध्याय ${['३३', '३४', '३५', '३६', '३७', '३८', '३९', '४०'][i]}'),
            reason: p.id);
        var agla = 1;
        for (final k in p.khand) {
          final m = shirshak.firstMatch(k.shirshak);
          expect(m, isNotNull, reason: k.shirshak);
          // स्क्रीन की गिनती शीर्षक के पहले शब्द से तय होती है (→ D-122)
          for (final w in ['श्लोक', 'मंत्र', 'अनुवाक', 'चौपाई', 'दोहा']) {
            expect(k.shirshak.startsWith(w), isFalse, reason: k.shirshak);
          }
          final a = dev(m!.group(2)!);
          final b = m.group(3) == null ? a : dev(m.group(3)!);
          expect(a, agla, reason: '${p.id} ${k.shirshak}');
          expect('॥'.allMatches(k.dev).length, b - a + 1,
              reason: '${p.id} ${k.shirshak}');
          agla = b + 1;
        }
        expect(agla - 1, shlok[i], reason: p.id);
      }
      expect(shlok.reduce((a, b) => a + b), 593);
    });

    test('हर खंड में पाठ, रोमन और अर्थ; देवनागरी में अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      final nagari = RegExp(r'[ऀ-ॿ]');
      for (final p in vn) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.dev, isNotEmpty, reason: kahan);
          expect(k.roman, isNotEmpty, reason: kahan);
          expect(nagari.hasMatch(k.roman), isFalse, reason: kahan);
          expect(k.arth.split(' ').length, greaterThan(8), reason: kahan);
          expect(latin.hasMatch(k.dev), isFalse, reason: kahan);
          expect(latin.hasMatch(k.arth), isFalse, reason: kahan);
        }
      }
    });

    test('कौन बोल रहा है — हर अध्याय में, जैसा पुस्तिका में छपा है', () {
      Map<String, int> vakta(Paath p) {
        final m = <String, int>{};
        for (final x in RegExp(r'^(.+(?:वाच|ऊचुः)) ।$', multiLine: true)
            .allMatches(sab(p))) {
          m[x.group(1)!] = (m[x.group(1)!] ?? 0) + 1;
        }
        return m;
      }

      expect(vakta(vn[0]), {
        'वैशम्पायन उवाच': 2, 'द्वाःस्थ उवाच': 2, 'धृतराष्ट्र उवाच': 3,
        'विदुर उवाच': 2,
      });
      expect(vakta(vn[1]), {'धृतराष्ट्र उवाच': 1, 'विदुर उवाच': 1});
      expect(vakta(vn[2]), {
        'धृतराष्ट्र उवाच': 1, 'विदुर उवाच': 4, 'केशिन्युवाच': 2,
        'विरोचन उवाच': 6, 'सुधन्वोवाच': 8, 'प्रह्लाद उवाच': 5,
      });
      expect(vakta(vn[3]), {
        'धृतराष्ट्र उवाच': 2, 'विदुर उवाच': 3, 'साध्या ऊचुः': 1,
        'हंस उवाच': 1,
      });
      expect(vakta(vn[4]), {'धृतराष्ट्र उवाच': 1, 'विदुर उवाच': 2});
      expect(vakta(vn[5]), {'विदुर उवाच': 1});
      expect(vakta(vn[6]), {'धृतराष्ट्र उवाच': 2, 'विदुर उवाच': 2});
      expect(vakta(vn[7]), {'धृतराष्ट्र उवाच': 1, 'विदुर उवाच': 1});
    });

    test('🔑 OCR या मसौदे से छूटी पंक्तियाँ — पन्ने से जोड़ी हुई, अपनी जगह', () {
      expect(sab(vn[1]), contains('कर्णिनालीकनाराचान्निर्हरन्ति शरीरतः'));
      expect(sab(vn[2]), contains('स्वयंवरे स्थिता कन्या केशिनी नाम नामतः'));
      expect(sab(vn[3]), contains('हन्तुं च यो नेच्छति पापकं वै'));
      expect(sab(vn[6]), contains('धर्मार्थौ वेदितुं शक्यौ बृहस्पतिसमैरपि'));
      expect(sab(vn[6]), contains('चौरे कृतघ्ने विश्वासो न कार्यो न च नास्तिके'));
      // अनुवाद का कोई टुकड़ा श्लोक बनकर नहीं घुसा
      for (final w in ['कुलकी वृद्धि', 'अपनी स्थिति बतावे', ' है ', ' हैं ']) {
        expect(sabKuchh(), isNot(contains(w)), reason: w);
      }
    });

    test('🔑 पुस्तिका की सोलह छपाई-भूलें ठीक — छपा रूप ऐप में नहीं', () {
      const theek = {
        'वह्निः': 'बह्निः',
        'स्रवति प्रज्ञा': 'स्त्रवति',
        'नियन्तेन्द्रियाण्यस्य': 'नियतेन्द्रियाण्यस्य',
        'प्राह्लादिं': 'प्रह्लादिं',
        'बहिर्द्वारे': 'बहिद्वरि',
        'सर्वान्गुणानेष': 'सर्वान्गुणानेषु',
        'न सा सभा': 'न स सभा',
        'स्रवते बुद्धिरस्य': 'स्त्रवते',
        'बहुत्वादायासान्': 'बहूत्वाद',
        'यश्चापि लब्ध्वा': 'यश्चापि लब्धा',
        'हरति हि धैर्यमाशा': 'हरति धैर्यमाशा',
        'विशेषा हि प्रसङ्गिनः': 'प्रसंङ्गिनः',
        'बुद्ध्या सम्पाद्य': 'वुद्ध्या',
        'समानि ब्रह्महत्यया': 'समानि ब्रह्महत्या ',
        'यथा तात पतत्रिणः': 'तात्त',
      };
      final s = '${sabKuchh()} ';
      theek.forEach((sahi, chhapa) {
        expect(s, contains(sahi), reason: sahi);
        expect(s, isNot(contains(chhapa)), reason: chhapa);
      });
      expect(s, contains('राजानं'));
      expect(s, isNot(contains('राजांनं')));
    });

    test('ⓘ: कौन सा पाठ, कैसे पढ़ा गया, समीक्षित में कितने श्लोक', () {
      final note = vn.first.strot.note;
      expect(note.length, lessThanOrEqualTo(600));
      expect(vn.first.strot.paddhati, contains('अध्याय ३३–४०'));
      expect(note, contains('पाँच सौ तिरानवे श्लोक'));
      expect(note, contains('सब पन्ने आँख से पढ़े गए'));
      expect(note, contains('सोलह जगह पुस्तिका की छपाई की भूल'));
      expect(note, contains('पाँच सौ तीस श्लोक'));
      expect(note, contains('दूसरी पाठ-परंपरा है, भूल नहीं'));
      // प्रकाशक या जगह का नाम ऐप में नहीं (पते docs/18 §३६ में)
      for (final w in ['गीताप्रेस', 'गीता प्रेस', 'archive', 'चित्रशाला', 'भण्डारकर']) {
        expect(note, isNot(contains(w)), reason: w);
      }
      for (final p in vn) {
        expect(p.strot.note, note, reason: p.id);
        expect(p.kabPadhein, contains('पूजा का पाठ नहीं है'), reason: p.id);
      }
      expect(kram.parichay, contains('उद्योग पर्व की विदुर नीति और सनत्सुजातीय'));
    });
  });

  group('सनत्सुजातीय — उद्योग पर्व के पाँच अध्याय', () {
    const ank = '०१२३४५६७८९';
    int dev(String s) =>
        int.parse(s.split('').map((c) => ank.indexOf(c).toString()).join());
    final shirshak = RegExp(r'^(.+) · श्लोक ([०-९]+)(?:–([०-९]+))?$');
    // औज़ार एक दण्ड «।» से पहले न टूटने वाली जगह लगाता है — मिलान के लिए सादी जगह
    String saaf(String s) => s.replaceAll('\u00A0', ' ');
    String sab(Paath p) => saaf(p.khand.map((k) => k.dev).join('\n'));
    String arth(Paath p) => p.khand.map((k) => k.arth).join(' ');

    test('पाँच पन्ने: खंड 13 · 15 · 8 · 6 · 8; श्लोक 46 · 63 · 31 · 21 · 31 — हर पन्ने पर 1 से, बिना छेद', () {
      expect(kram.kram.length, 35);
      expect(ss.map((p) => p.khand.length), [13, 15, 8, 6, 8]);
      const shlok = [46, 63, 31, 21, 31];
      for (var i = 0; i < 5; i++) {
        final p = ss[i];
        expect(p.prakar, PaathPrakar.granth, reason: p.id);
        expect(p.bhasha, 'संस्कृत', reason: p.id);
        expect(p.naam, startsWith('सनत्सुजातीय ${ank[i + 1]} — '));
        var agla = 1;
        for (final k in p.khand) {
          final m = shirshak.firstMatch(k.shirshak);
          expect(m, isNotNull, reason: k.shirshak);
          // स्क्रीन की गिनती शीर्षक के पहले शब्द से तय होती है (→ D-122)
          for (final w in ['श्लोक', 'मंत्र', 'अनुवाक', 'चौपाई', 'दोहा']) {
            expect(k.shirshak.startsWith(w), isFalse, reason: k.shirshak);
          }
          final a = dev(m!.group(2)!);
          final b = m.group(3) == null ? a : dev(m.group(3)!);
          expect(a, agla, reason: '${p.id} ${k.shirshak}');
          expect('॥'.allMatches(k.dev).length, b - a + 1,
              reason: '${p.id} ${k.shirshak}');
          agla = b + 1;
        }
        expect(agla - 1, shlok[i], reason: p.id);
      }
      expect(shlok.reduce((a, b) => a + b), 192);
    });

    test('हर खंड में पाठ, रोमन और अर्थ; देवनागरी में अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      final nagari = RegExp(r'[\u0900-\u097F]');
      for (final p in ss) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.dev, isNotEmpty, reason: kahan);
          expect(k.roman, isNotEmpty, reason: kahan);
          expect(nagari.hasMatch(k.roman), isFalse, reason: kahan);
          expect(k.arth.split(' ').length, greaterThan(8), reason: kahan);
          expect(latin.hasMatch(k.dev), isFalse, reason: kahan);
          expect(latin.hasMatch(k.arth), isFalse, reason: kahan);
        }
      }
    });

    test('कौन बोल रहा है — हर अध्याय में, जैसा छपा है', () {
      Map<String, int> vakta(Paath p) {
        final m = <String, int>{};
        for (final x in RegExp(r'^(.+वाच) ।$', multiLine: true).allMatches(sab(p))) {
          m[x.group(1)!] = (m[x.group(1)!] ?? 0) + 1;
        }
        return m;
      }

      expect(vakta(ss[0]),
          {'वैशम्पायन उवाच': 1, 'धृतराष्ट्र उवाच': 5, 'सनत्सुजात उवाच': 5});
      expect(vakta(ss[1]), {'धृतराष्ट्र उवाच': 6, 'सनत्सुजात उवाच': 6});
      expect(vakta(ss[2]), {'धृतराष्ट्र उवाच': 4, 'सनत्सुजात उवाच': 4});
      expect(vakta(ss[3]), {'सनत्सुजात उवाच': 1});
      expect(vakta(ss[4]), {'सनत्सुजात उवाच': 1});
      expect(saaf(ss[0].khand.first.dev),
          startsWith('वैशम्पायन उवाच ।\nततो राजा धृतराष्ट्रो मनीषी'));
    });

    test('जानी-पहचानी पंक्तियाँ अपनी जगह हैं', () {
      expect(sab(ss[0]), contains('प्रमादं वै मृत्युमहं ब्रवीमि'));
      expect(sab(ss[0]), contains('किं तेन न कृतं पापं चौरेणात्मापहारिणा'));
      expect(sab(ss[1]), contains('मौनान्न स मुनिर्भवति नारण्यवसनान्मुनिः'));
      expect(sab(ss[1]), contains('य एव सत्यान्नापैति स ज्ञेयो ब्राह्मणस्त्वया'));
      expect(sab(ss[2]), contains('नान्यः पन्था अयनाय विद्यते'));
      expect(sab(ss[2]), contains('न्मुञ्जादिषीकामिव सत्त्वसंस्थाः'));
      expect(sab(ss[3]), contains('सौहृदे वै षड् गुणा वेदितव्याः'));
      expect(sab(ss[4]), contains('पूर्णात् पूर्णान्युद्धरन्ति पूर्णात् पूर्णानि चक्रिरे'));
      expect(sab(ss[4]), contains('अङ्गुष्ठमात्रः पुरुषोऽन्तरात्मा'));
      expect(saaf(ss[4].khand.last.dev),
          endsWith('पितरं सर्वभूतेषु पुष्करे निहितं विदुः ॥'));
      // छपाई में पाद के अंत पर टूटा शब्द जोड़कर
      expect(sab(ss[0]), contains('देवासुरा ह्याचरन् ब्रह्मचर्यममृत्यवे तत् कतरन्नु सत्यम्'));
    });

    test('🔑 अध्याय ४६ की टेक तेईस बार — पाठ में, और अर्थ में उतनी ही बार', () {
      expect('योगिनस्तं प्रपश्यन्ति भगवन्तं सनातनम्'.allMatches(sab(ss[4])),
          hasLength(23));
      expect('उन सनातन भगवान को योगी देखते हैं।'.allMatches(arth(ss[4])),
          hasLength(23));
      // ग्यारहवें श्लोक में टेक नहीं है; और पच्चीसवें से आगे भी नहीं
      final k = ss[4].khand.singleWhere((k) => k.shirshak.endsWith('श्लोक ९–१२'));
      expect('योगिनस्तं'.allMatches(k.dev), hasLength(3));
      for (final k in ss[4].khand.skip(6)) {
        expect(k.dev, isNot(contains('योगिनस्तं')), reason: k.shirshak);
      }
    });

    test('छपी पुस्तक की दो छपाई-भूलें — दूसरी छपी पुस्तक वाला रूप लिया गया', () {
      expect(sab(ss[1]), contains('स्तथा नृशंसानि दशत्रि राजन्'));
      expect(sab(ss[1]), isNot(contains('नृशांसानि')));
      expect(sab(ss[2]), contains('यन्मां पृच्छन्नतिहृष्यस्यतीव'));
      expect(sab(ss[2]), isNot(contains('पृच्छन्नतिहृष्यतीव')));
    });

    test('🔑 जहाँ दूसरी छपी पुस्तक अलग है पर भूल नहीं — वहाँ आधार-पुस्तक का रूप ही रहा', () {
      expect(sab(ss[0]), contains('स्तत्रानुयान्ति न तरन्ति मृत्युम्'));
      expect(sab(ss[0]), isNot(contains('स्तत्रानु ते यान्ति')));
      expect(sab(ss[3]), contains('बहुप्रशंसी वन्दितद्विट् सदैव'));
      expect(sab(ss[3]), isNot(contains('वनिताद्विट्')));
      expect(sab(ss[3]), contains('त्रिभिर्द्वाभ्यामेकतो वान्वितो यो'));
      // दूसरे अध्याय में वही पंक्ति «वार्थितो» के साथ है — वह भी जैसी छपी है
      expect(sab(ss[1]), contains('त्रिभिर्द्वाभ्यामेकतो वार्थितो यस्तस्य स्वमस्तीति'));
    });

    test('🔑 रूपक खोले नहीं गए — छपे अनुवाद के खुलासे अर्थ में नहीं घुसे', () {
      // अध्याय ४६: नदी «बारह के समूह वाली» ही रही, घोड़े घोड़े ही, पीपल पीपल ही
      final a = arth(ss[4]);
      for (final w in ['इन्द्रिय', 'जीव', 'संसार', 'हिरण्यगर्भ', 'शरीररूप']) {
        expect(a, isNot(contains(w)), reason: w);
      }
      expect(a, contains('बारह के समूह वाली'));
      expect(a, contains('सोने के पत्तों वाले पीपल'));
      expect(a, contains('जल से ऊपर उठता हंस'));
      // अध्याय ४४: «रसभेद» वाली उपमा का खुलासा नहीं
      expect(arth(ss[2]), isNot(contains('चिन्तामणि')));
      // अध्याय ४२: «अनादि» का नाम नहीं गढ़ा
      expect(arth(ss[0]), isNot(contains('माया')));
      for (final p in ss) {
        expect(p.kaisePadhein, contains('रूपकों का खुलासा नहीं किया गया'),
            reason: p.id);
      }
    });

    test('ⓘ: कौन सा पाठ, कैसे पढ़ा गया, दूसरे पाठों में कितने अध्याय', () {
      final note = ss.first.strot.note;
      expect(note.length, lessThanOrEqualTo(600));
      expect(ss.first.strot.paddhati, contains('अध्याय ४२–४६'));
      expect(note, contains('एक सौ बानवे श्लोक'));
      expect(note, contains('बीस पन्ने आँख से पढ़े गए'));
      expect(note, contains('दो जगह छपाई की भूल ठीक हुई'));
      expect(note, contains('समीक्षित संस्करण में यही उपदेश चार अध्यायों में है'));
      expect(note, contains('दूसरी परंपरा है, भूल नहीं'));
      expect(note, contains('रूपक खोले नहीं गए'));
      expect(note, contains('कुछ कठिन शब्द छोड़े गए हैं'));
      for (final p in ss) {
        expect(p.strot.note, note, reason: p.id);
      }
      // ग्रंथ का परिचय पाँचों अंश गिनाता है (विदुर नीति जुड़ने के बाद, → D-125)
      expect(kram.parichay, contains('पाँच अंश'));
      expect(kram.parichay, contains('उद्योग पर्व की विदुर नीति और सनत्सुजातीय'));
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

    void lambaPhone(WidgetTester tester, {double width = 400}) {
      tester.view.physicalSize = Size(width * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> granthKholo(WidgetTester tester) async {
      lambaPhone(tester);
      final g = (await granthBhandar.suchi())
          .singleWhere((g) => g.id == 'mahabharat');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();
    }

    testWidgets('ग्रंथ का पन्ना — तीन हिस्से, गिनती "खंड" में', (tester) async {
      await granthKholo(tester);
      for (final hissa in [
        'युद्ध से पहले',
        'अठारह दिन का युद्ध',
        'युद्ध के बाद',
      ]) {
        expect(find.text(hissa), findsOneWidget, reason: hissa);
      }
      expect(find.text('आदि पर्व'), findsOneWidget);
      expect(find.text('6 खंड'), findsOneWidget); // आदि पर्व
      expect(find.textContaining('श्लोक'), findsNothing);
      // सूची उतनी ही बनती है जितनी दिखती है — आख़िरी पर्व तक खिसकाओ
      await tester.scrollUntilVisible(find.text('स्वर्गारोहण पर्व'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('स्वर्गारोहण पर्व'), findsOneWidget);
      expect(find.textContaining('श्लोक'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पर्व खुलता है: "यह सार है" खुला, "अर्थ दिखाएँ" नहीं, अक्षर पढ़ने वाले',
        (tester) async {
      await granthKholo(tester);
      await tester.tap(find.text('भीष्म पर्व'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 7/${kram.kram.length}'), findsOneWidget);

      // खुला सच — ⓘ के पीछे नहीं (→ D-060)
      expect(find.textContaining('यह सार है'), findsOneWidget);
      expect(find.textContaining('शब्दशः पाठ नहीं'), findsOneWidget);

      // "पाठ" नहीं, "सार"; और अर्थ/रोमन का बटन नहीं
      expect(find.text('सार'), findsOneWidget);
      expect(find.text('पाठ'), findsNothing);
      expect(find.text('4 खंड'), findsOneWidget);
      expect(find.text('अर्थ दिखाएँ'), findsNothing);
      expect(find.text('रोमन दिखाएँ'), findsNothing);

      // गद्य मंत्र वाले बड़े अक्षरों में नहीं
      final type = VidhivatTheme.typographyOf(
          tester.element(find.byType(PaathScreen)));
      final gadya = tester.widget<Text>(
          find.textContaining('अर्जुन पर मोह छा जाता है'));
      expect(gadya.style!.fontSize, type.bodyLarge.fontSize);
      expect(gadya.style!.fontSize, isNot(type.mantra.fontSize));
      expect(tester.takeException(), isNull);
    });

    testWidgets('यक्ष प्रश्न खुलता है: "48 खंड", अर्थ का बटन, और सार वाली पंक्ति नहीं',
        (tester) async {
      await granthKholo(tester);
      final yp = find.text('यक्ष प्रश्न');
      await tester.scrollUntilVisible(yp, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('महाभारत से — पूरा पाठ'), findsOneWidget);
      expect(find.text('48 खंड'), findsOneWidget);

      await tester.tap(yp);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 20/${kram.kram.length}'), findsOneWidget);
      expect(find.text('पाठ'), findsOneWidget);
      expect(find.text('48 खंड'), findsOneWidget);
      expect(find.textContaining('यह सार है'), findsNothing);
      expect(find.text('भाइयों को देखकर · श्लोक १–३'), findsOneWidget);

      expect(find.textContaining('युधिष्ठिर ने अपने भाइयों को'), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('युधिष्ठिर ने अपने भाइयों को'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('भीष्म स्तवराज खुलता है: "32 खंड" और अर्थ का बटन', (tester) async {
      await granthKholo(tester);
      final bs = find.text('भीष्म स्तवराज');
      await tester.scrollUntilVisible(bs, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('32 खंड'), findsOneWidget);

      await tester.tap(bs);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 21/${kram.kram.length}'), findsOneWidget);
      expect(find.text('पाठ'), findsOneWidget);
      expect(find.text('32 खंड'), findsOneWidget);
      expect(find.textContaining('यह सार है'), findsNothing);
      expect(find.text('भीष्म शरशय्या पर · श्लोक १–४'), findsOneWidget);

      expect(find.textContaining('जनमेजय ने पूछा'), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('जनमेजय ने पूछा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('अनुस्मृति खुलती है: "25 खंड" और अर्थ का बटन', (tester) async {
      await granthKholo(tester);
      final an = find.text('अनुस्मृति');
      await tester.scrollUntilVisible(an, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('25 खंड'), findsOneWidget);

      await tester.tap(an);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 22/${kram.kram.length}'), findsOneWidget);
      expect(find.text('पाठ'), findsOneWidget);
      expect(find.text('25 खंड'), findsOneWidget);
      expect(find.textContaining('यह सार है'), findsNothing);
      expect(find.text('शतानीक का प्रश्न · श्लोक १–४'), findsOneWidget);

      expect(find.textContaining('शतानीक ने पूछा'), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('शतानीक ने पूछा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('सनत्सुजातीय का पहला पन्ना खुलता है: "13 खंड" और अर्थ का बटन', (tester) async {
      await granthKholo(tester);
      final p1 = find.text('सनत्सुजातीय १ — मृत्यु और प्रमाद');
      await tester.scrollUntilVisible(p1, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('सनत्सुजातीय — उद्योग पर्व से'), findsOneWidget);
      expect(find.text('13 खंड'), findsOneWidget);

      await tester.tap(p1);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      // परिचय + अठारह पर्व + तीन अंश + विदुर नीति के आठ = 30; यह 31वाँ
      expect(find.text('महाभारत · भाग 31/${kram.kram.length}'), findsOneWidget);
      expect(find.text('पाठ'), findsOneWidget);
      expect(find.text('13 खंड'), findsOneWidget);
      expect(find.textContaining('यह सार है'), findsNothing);
      expect(find.text('धृतराष्ट्र का प्रश्न · श्लोक १–३'), findsOneWidget);

      expect(find.textContaining('वैशम्पायन बोले'), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('वैशम्पायन बोले'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('विदुर नीति का पहला पन्ना खुलता है: "28 खंड", भाग 23, और अर्थ का बटन', (tester) async {
      await granthKholo(tester);
      final p1 = find.text('विदुर नीति १ — पण्डित और मूढ़');
      await tester.scrollUntilVisible(p1, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('विदुर नीति — उद्योग पर्व से'), findsOneWidget);
      expect(find.text('28 खंड'), findsOneWidget);

      await tester.tap(p1);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 23/${kram.kram.length}'), findsOneWidget);
      expect(find.text('28 खंड'), findsOneWidget);
      expect(find.textContaining('यह सार है'), findsNothing);
      expect(find.text('धृतराष्ट्र विदुर को बुलवाते हैं · श्लोक १–३'), findsOneWidget);

      expect(find.textContaining('द्वारपाल से कहा'), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('द्वारपाल से कहा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (chaudai, akshar) in [(320.0, 1.5), (360.0, 2.0)]) {
      testWidgets(
          'छोटे फ़ोन पर भी कुछ बाहर नहीं निकलता — $chaudai चौड़ाई, $akshar गुना अक्षर',
          (tester) async {
        tester.view.physicalSize = Size(chaudai * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        tester.platformDispatcher.textScaleFactorTestValue = akshar;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final g = (await granthBhandar.suchi())
            .singleWhere((g) => g.id == 'mahabharat');
        await tester.pumpWidget(app(GranthScreen(granth: g)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'सूची');
        await tester.scrollUntilVisible(find.text('आदि पर्व'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('आदि पर्व'));
        await tester.pumpAndSettle();
        expect(find.byType(PaathScreen), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'पर्व');
      });
    }
  });
}
