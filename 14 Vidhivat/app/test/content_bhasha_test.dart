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
  const dikhneWaleKhane = {'note', 'strot', 'vikalp', 'kyon', 'kabPadhein',
                           'kaisePadhein', 'parichay', 'ekLine'};

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
        for (final dir in ['assets/vidhi', 'assets/paath'])
          ...Directory(dir)
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              // `_suchi.json` का `_note` सिर्फ़ फ़ाइल के अंदर की टिप्पणी
              // है — वो कभी स्क्रीन पर नहीं जाता, इसलिए छूट है।
              .where((f) => !f.path.endsWith('_suchi.json')),
      ];

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
        if (!hawalaKhane.contains(khaana) && khaana != 'vikalp') continue;
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
}
