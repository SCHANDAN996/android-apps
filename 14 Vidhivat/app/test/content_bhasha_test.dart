import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **यूज़र की स्क्रीन पर डेवलपर का कोई संदेश नहीं।**
///
/// ## यह जाँच क्यों लिखी गई
///
/// 4 सितम्बर 2026 — डेवलपर ने फ़ोन पर हनुमान चालीसा का ⓘ खोला और उसमें
/// यह पढ़ा:
///
/// > **सबसे पहले यही कीजिए** — अपनी चालीसा-पुस्तिका खोलकर पूरे 43 पद
/// > मिला लीजिए… और रिकॉर्डिंग भी अपनी ही बनानी है।
///
/// यह यूज़र के लिए लिखा ही नहीं था — यह **हमारे अपने बचे हुए काम की
/// पर्ची** थी, जो कंटेंट की JSON में पड़ी रह गई और सीधे स्क्रीन पर छप
/// गई। साथ में कॉपीराइट की दलील, Drik से मिलान की तारीख़, और यह वाक्य
/// भी कि *"हर पद पर 'जाँच बाकी' दिखता है"* — जो उसी दिन झूठ हो चुका
/// था, क्योंकि वो लेबल सुबह ही हटा दिया गया था।
///
/// नापने पर **40 जगह** ऐसी निकलीं, और एक ⓘ शीट में 873 अक्षर तक भरे थे।
/// सब `docs/18_SROT_PANJI.md` में चला गया — मिटाया कुछ नहीं (→ D-050)।
///
/// > **नियम:** ऐप की अपनी हालत ऐप के काग़ज़ों में रहती है, स्क्रीन पर
/// > नहीं। स्क्रीन पर सिर्फ़ वो जो यूज़र के काम आए।
void main() {
  /// जिन खानों का पाठ **सीधे यूज़र को दिखता है।**
  ///
  /// ⚠️ `arth` और `vivaran` जान-बूझकर बाहर हैं — वहाँ "मैं/मुझे" भक्त
  /// का अपना वचन होता है ("मुझे बल, बुद्धि और विद्या दीजिए"), डेवलपर
  /// की आवाज़ नहीं।
  const dikhneWaleKhane = {
    'note',
    'strot',
    'vikalp',
    'chetavni',
    'kyon',
    'kabPadhein',
    'kaisePadhein',
    'parichay',
    'ekLine'
  };

  /// डेवलपर की निशानियाँ — इनमें से कुछ भी कंटेंट में नहीं जाना चाहिए।
  final nishani = <RegExp, String>{
    RegExp(r'→\s*D-\d+'): 'फ़ैसले का नंबर (→ D-0xx)',
    RegExp(r'\bD-\d{3}\b'): 'फ़ैसले का नंबर',
    RegExp(r'docs/'): 'docs की राह',
    RegExp(r'\.json\b'): 'फ़ाइल का नाम',
    RegExp(r'\.dart\b'): 'फ़ाइल का नाम',
    RegExp(r'\bTODO\b|\bFIXME\b'): 'काम की पर्ची',
    RegExp(r'⬜|🔜'): 'बचे काम का डिब्बा',
    RegExp(r'\bPhase\s*[A-Z0-9]'): 'Phase का ज़िक्र',
    RegExp(r'assets/|schemaVersion'): 'कोड की चीज़',
    // ⚠️ यह नियम बाद में जोड़ा गया। पहली बार जाँच लिखते समय सिर्फ़
    // D-0xx जैसे निशान देखे थे, और "कोई भी अभी पंडित जी से पास नहीं
    // हुआ है" वाला वाक्य निकल गया — जबकि डेवलपर की शिकायत की जड़ ही
    // वही दर्जा था (→ D-043, D-050)।
    RegExp(r'पंडित जी से पास नहीं|जाँच बाकी|पंडित जी की मुहर|'
        r'जाँचा नहीं गया है'): 'ऐप की अपनी जाँच की हालत',
    RegExp(r'पक्का करना बाक़ी|पक्का करना बाकी|मिलाना बाक़ी|मिलाना बाकी|'
            r'लिखवाना चाहिए|लिखवाई जा सकती|'
            r'पंडित जी बताएँ कि आपके यहाँ क्या चलन है'):
        'अधूरी जाँच या बाहर की अनिवार्य सलाह',
    // ⚠️ सिर्फ़ **तारीख़ वाला** सत्यापन-record पकड़ो, हर drikpanchang
    // नहीं। "drikpanchang के दुर्गा सप्तशती पन्ने से हूबहू लिया गया"
    // असली **हवाला** है और यूज़र के काम का — वही तो ऐप का वादा है
    // (→ D-041)। पर "ढाँचा … से मिलाया गया (4 सितंबर 2026)" हमारी
    // अपनी जाँच का पर्चा है।
    RegExp(r'मिलाया गया \s*\(\d'): 'हमारे सत्यापन का ब्यौरा (तारीख़ सहित)',
  };

  /// सिर्फ़ हवाला-वाले खानों में — वहाँ पहला पुरुष डेवलपर ही होता है।
  final pehlaPurush = RegExp(r'मैंने|मुझे नहीं मिला|मैं समझता');
  const hawalaKhane = {'note', 'strot'};

  Iterable<(String, String)> chalo(dynamic node, [String path = '']) sync* {
    if (node is Map) {
      for (final e in node.entries) {
        yield* chalo(e.value, '$path/${e.key}');
      }
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        yield* chalo(node[i], '$path[$i]');
      }
    } else if (node is String) {
      yield (path, node);
    }
  }

  List<File> contentFiles() => [
        for (final dir in [
          'assets/vidhi',
          'assets/paath',
          'assets/vrat',
          'assets/katha',
          'assets/granth',
        ])
          ...Directory(dir)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              // `_suchi.json` का `_note` सिर्फ़ फ़ाइल के अंदर की टिप्पणी
              // है — वो कभी स्क्रीन पर नहीं जाता, इसलिए छूट है।
              .where((f) => !f.path.endsWith('_suchi.json')),
      ];

  List<File> shippedTextFiles() => [
        for (final dir in ['assets', 'lib'])
          ...Directory(dir).listSync(recursive: true).whereType<File>().where(
              (f) =>
                  f.path.endsWith('.json') ||
                  f.path.endsWith('.dart') ||
                  f.path.endsWith('.yaml')),
      ];

  /// **किसी बाहरी वेबसाइट का नाम ऐप में नहीं जाता (→ D-080).**
  ///
  /// 20 सितम्बर 2026 — डेवलपर ने कहा: *"हर जगह स्रोत नहीं लिखेंगे, इससे
  /// हमारा ऐप दूसरे का ad करने वाला ऐप लगता है। पूरी ज़िम्मेदारी हमारी
  /// ही रहेगी।"* नापने पर **48 फ़ाइलों में 64 जगह** बाहर की वेबसाइट का
  /// नाम छपा मिला — webdunia, bhaktibharat, karmkandvidhi.in, quora,
  /// india.com और दूसरे।
  ///
  /// यह सिर्फ़ विज्ञापन जैसा नहीं लगता — यह **भरोसा घटाता भी है।**
  /// यूज़र पढ़ता है कि पाठ किसी वेबसाइट से उठाया गया है।
  ///
  /// > **नियम:** *ग्रंथ* का नाम रहता है — दुर्गा सप्तशती, ऋग्वेद १०.८१,
  /// > वाजसनेयी संहिता २३.१९, स्कंद पुराण। यही ऐप की रीढ़ है।
  /// > *वेबसाइट* का नाम नहीं। जहाँ पता अधूरा है वहाँ अब भी अधूरा लिखा
  /// > है ("⚠️ मूल ग्रंथ और अध्याय पक्का नहीं") — बस दुकान का नाम हटा।
  /// > लिंक `docs/18_SROT_PANJI.md` में हैं, जो ऐप में नहीं जाती।
  ///
  /// ⚠️ यहाँ नामों की **गिनी हुई सूची** है, `\.com` जैसा चौड़ा नियम
  /// नहीं — वरना गोपनीयता-नीति का पता और package का नाम भी पकड़ में आ
  /// जाते, जिनका यहाँ होना ठीक है।
  test('shipped app में किसी बाहरी वेबसाइट या brand का प्रचार नहीं', () {
    final brand = RegExp(
      r'drik\s*panchang|drikpanchang|दृक\s*पंचांग|द्रिक\s*पंचांग|'
      r'webdunia|bhaktibharat|bhaktvatsal|sanskritbhasi|karmkandvidhi|'
      r'srimandir|shlokmantra|mnsgranth|vaikunthdham|prabhusharnam|'
      r'asianetnews|timesnowhindi|aajtak|amarujala|navbharattimes|'
      r'astrosage|templepurohit|dharmawiki|wikipedia|quora|india\.com|'
      r'thedivineindia|jeevanjali|hindunidhi|stotranidhi|vedadhara|'
      r'vadicjagat|pandit\s*online|wisdomlib|devi-bhagwat|dharmsaar|'
      r'bharatdarshan|athshri',
      caseSensitive: false,
    );
    final chuke = <String>[];

    for (final f in shippedTextFiles()) {
      if (brand.hasMatch(f.readAsStringSync())) {
        chuke.add(f.path);
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'Vidhivat अपनी गणना और स्रोत अपने नाम से समझाता है, और उनकी '
          'ज़िम्मेदारी ख़ुद लेता है। ग्रंथ का नाम लिखिए, वेबसाइट का नहीं; '
          'लिंक `docs/18_SROT_PANJI.md` में रखिए (→ D-080):\n'
          '  ${chuke.join("\n  ")}',
    );
  });

  /// **नामों की सूची काफ़ी नहीं — जो अंग्रेज़ी शब्द दिखे, वो गिना जाए।**
  ///
  /// ऊपर वाली जाँच में 29 नाम थे और वह फिर भी अधूरी थी। 20 सित 2026 को
  /// चरण ३ का काम शुरू करते ही अष्टमी की फ़ाइल में *"Vadicjagat और
  /// Pandit Online"* दिखा — और गिनने पर वह एक ही वाक्य **27 विधियों**
  /// में था। साथ में `wisdomlib` (10), `devi-bhagwat` (4), `dharmsaar`,
  /// `bharatdarshan`, `athshri`। **सूची वाली जाँच इनमें से एक भी नहीं
  /// पकड़ पाई थी, क्योंकि ये नाम सूची में थे ही नहीं।**
  ///
  /// इसलिए यह उल्टी जाँच: यूज़र को दिखने वाले खानों में **लैटिन अक्षरों
  /// का कोई भी शब्द** पकड़ो, और सिर्फ़ गिनी हुई छूट जाने दो। नया स्रोत
  /// इस्तेमाल हो तो यह जाँच उसे पहले दिन पकड़ लेगी — नाम याद रखने की
  /// ज़रूरत नहीं (→ D-080)।
  ///
  /// ⚠️ `roman` खाना बाहर है — वह लिप्यंतरण है, वहाँ लैटिन ही चलेगा।
  test('यूज़र को दिखने वाले पाठ में कोई बाहरी अंग्रेज़ी नाम नहीं', () {
    /// जो जायज़ हैं। **यहाँ कुछ जोड़ने से पहले सोचिए** — क्या यह यूज़र
    /// के काम का शब्द है, या किसी और की दुकान का नाम?
    const chhoot = {
      'ORS', // जीवन-रक्षक घोल — छठ की सुरक्षा वाली बात में
      'Vidhivat', // ऐप का अपना नाम
    };
    final latin = RegExp(r'[A-Za-z][A-Za-z0-9._-]{2,}');
    final chuke = <String>[];

    for (final f in contentFiles()) {
      final d = jsonDecode(f.readAsStringSync());
      final naam = f.uri.pathSegments.last;
      for (final (path, text) in chalo(d)) {
        if (path.endsWith('/roman')) continue;
        final khaana = path.split('/').last.replaceAll(RegExp(r'\[\d+\]'), '');
        if (!dikhneWaleKhane.contains(khaana) &&
            khaana != 'jawaab' &&
            khaana != 'arth' &&
            khaana != 'vivaran') {
          continue;
        }
        for (final m in latin.allMatches(text)) {
          if (chhoot.contains(m[0])) continue;
          chuke.add('$naam $path — "${m[0]}"');
        }
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'ऐप हिंदी में बोलता है और अपने स्रोतों की ज़िम्मेदारी ख़ुद '
          'लेता है। ग्रंथ का नाम देवनागरी में लिखिए; वेबसाइट का नाम '
          '`docs/18_SROT_PANJI.md` में जाता है (→ D-080)। सचमुच ज़रूरी '
          'शब्द हो तो ऊपर `chhoot` में वजह सहित जोड़िए:\n'
          '  ${chuke.join("\n  ")}',
    );
  });

  test('कंटेंट में डेवलपर का कोई संदेश नहीं', () {
    final chuke = <String>[];

    for (final f in contentFiles()) {
      final d = jsonDecode(f.readAsStringSync());
      final naam = f.uri.pathSegments.last;

      for (final (path, text) in chalo(d)) {
        final khaana = path.split('/').last.replaceAll(RegExp(r'\[\d+\]'), '');
        if (!dikhneWaleKhane.contains(khaana)) continue;

        for (final e in nishani.entries) {
          if (e.key.hasMatch(text)) {
            chuke.add('$naam $path — ${e.value}');
          }
        }
        if (hawalaKhane.contains(khaana) && pehlaPurush.hasMatch(text)) {
          chuke.add('$naam $path — डेवलपर की आवाज़ (पहला पुरुष)');
        }
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'यह पाठ यूज़र की स्क्रीन पर छपेगा। हमारी अपनी बात '
          '`docs/18_SROT_PANJI.md` या `docs/06_CONTENT_TRACKER.md` में '
          'जाती है, कंटेंट की JSON में नहीं:\n  ${chuke.join("\n  ")}',
    );
  });

  /// ⓘ शीट पढ़ने की चीज़ है, दस्तावेज़ नहीं।
  ///
  /// पहले एक शीट में 873 अक्षर थे — सात पैराग्राफ़, जबकि बटन सिर्फ़
  /// इतना पूछता है कि "यह पाठ कहाँ से आया"। यह हद उदार है; असली
  /// इरादा यह पकड़ना है कि कहीं फिर से पूरा दस्तावेज़ तो नहीं भर गया।
  test('ⓘ में जाने वाला पाठ पढ़ने लायक लंबाई में है', () {
    const hadd = 600;
    final lambe = <String>[];

    for (final f in contentFiles()) {
      final d = jsonDecode(f.readAsStringSync());
      final naam = f.uri.pathSegments.last;
      for (final (path, text) in chalo(d)) {
        final khaana = path.split('/').last.replaceAll(RegExp(r'\[\d+\]'), '');
        if (!hawalaKhane.contains(khaana) &&
            khaana != 'vikalp' &&
            khaana != 'chetavni') {
          continue;
        }
        if (text.length > hadd) {
          lambe.add('$naam $path — ${text.length} अक्षर');
        }
      }
    }

    expect(
      lambe,
      isEmpty,
      reason: 'ⓘ के पीछे इतना लंबा पाठ पढ़ा नहीं जाता। ब्यौरा '
          '`docs/18_SROT_PANJI.md` में रखो:\n  ${lambe.join("\n  ")}',
    );
  });

  test('पाठ की फलश्रुति ऐप की सीधी गारंटी बनकर नहीं लिखी', () {
    final daava = RegExp(
      r'मनचाह|फल मिलता|कष्ट दूर|रोग.*(?:नष्ट|दूर|ठीक)|'
      r'सुख और सम्पत्ति|सुख-सम्पत्ति|संतान.*(?:देते|मिल)|'
      r'पाप.*नष्ट|मोक्ष.*(?:मिल|प्राप्त)|धन.*(?:देते|मिल)',
    );
    final sandarbh = RegExp(
      r'रचना|पद|कथन|प्रार्थना|भक्तिपरक|काव्यात्मक|वर्णन|कहा गया',
    );
    final chuke = <String>[];

    for (final f in Directory('assets/paath')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))) {
      final d = jsonDecode(f.readAsStringSync());
      if (d is! Map || d['khand'] is! List) continue;
      for (final (i, khand) in (d['khand'] as List).indexed) {
        if (khand is! Map) continue;
        final arth = khand['arth'];
        if (arth is String &&
            daava.hasMatch(arth) &&
            !sandarbh.hasMatch(arth)) {
          chuke.add('${f.uri.pathSegments.last} /khand[$i]/arth');
        }
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'आरती/स्तोत्र की आस्था-भाषा को उसी रचना का कथन बताइए; '
          'उसे ऐप की चिकित्सा, धन, संतान या निश्चित फल की गारंटी न बनाइए:\n'
          '  ${chuke.join("\n  ")}',
    );
  });
}
