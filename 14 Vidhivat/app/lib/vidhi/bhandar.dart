import 'dart:convert' show utf8;

import 'package:flutter/services.dart' show rootBundle;

import 'katha.dart';
import 'parv.dart';
import 'paath.dart';
import 'vidhi.dart';

/// JSON फ़ाइल पढ़ने का अपना तरीक़ा — `rootBundle.loadString` नहीं।
///
/// ## यह अलग क्यों है
///
/// `loadString` **50 KB से बड़ी फ़ाइल को एक अलग isolate में** भेजकर
/// decode करता है (Flutter का अपना नियम, ताकि मुख्य thread अटके नहीं)।
/// 12 सितम्बर 2026 को `satyanarayan.json` 46 KB से बढ़कर **53 KB** हुई
/// और उसी दिन **59 widget जाँचें एक साथ टूट गईं** — होम का पन्ना
/// *"आपका होम तैयार हो रहा है"* पर हमेशा के लिए अटक गया।
///
/// वजह: `testWidgets` नक़ली घड़ी (FakeAsync) पर चलता है, और उसमें
/// isolate वाला काम **कभी पूरा नहीं होता**। यानी जाँच फ़ोन की नहीं,
/// सिर्फ़ इस 50 KB की लकीर की शिकायत कर रही थी।
///
/// bytes ख़ुद पढ़कर यहीं decode करने से वह लकीर हट जाती है। फ़ोन पर भी
/// एक isolate कम बनता है। और कंटेंट बढ़ता ही जाएगा — नवरात्रि जैसी
/// दिन-प्रतिदिन वाली विधि आते ही कई फ़ाइलें 50 KB पार करेंगी।
Future<String> _padho(String path) async {
  final data = await rootBundle.load(path);
  return utf8.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}

/// पूजाओं का भंडार — JSON फ़ाइलें ऐप के अंदर से पढ़ता है।
///
/// **सब कुछ ऐप के अंदर बंडल है।** कोई डाउनलोड नहीं, कोई सर्वर नहीं
/// (→ D-004)। हवाई जहाज़ में भी पूरी विधि खुलेगी।
///
/// सूची (`_suchi.json`) हल्की है और शुरू में एक बार पढ़ी जाती है। पूरी
/// पूजा तभी पढ़ी जाती है जब यूज़र उसे खोले, और फिर याद रख ली जाती है।
class VidhiBhandar {
  static const _dir = 'assets/vidhi';
  static const suchiPath = '$_dir/_suchi.json';

  List<VidhiSuchiEntry>? _suchi;
  final Map<String, Vidhi> _khuliHuin = {};

  /// पूजाओं की सूची।
  Future<List<VidhiSuchiEntry>> suchi() async {
    final pehleSe = _suchi;
    if (pehleSe != null) return pehleSe;

    final source = await _padho(suchiPath);
    final list = VidhiSuchiEntry.parseAll(suchiPath, source);
    _suchi = list;
    return list;
  }

  /// एक पूरी पूजा। दूसरी बार माँगने पर याद रखी हुई मिलेगी।
  Future<Vidhi> vidhi(String id) async {
    final yaad = _khuliHuin[id];
    if (yaad != null) return yaad;

    final path = pathFor(id);
    final source = await _padho(path);
    final v = Vidhi.parse(path, source);

    // फ़ाइल के अंदर की id और फ़ाइल का नाम एक ही होने चाहिए, वरना
    // सूची और फ़ाइल आपस में उलझ जाएँगी।
    if (v.id != id) {
      throw VidhiFormatException(
        path,
        'फ़ाइल का नाम "$id" है पर अंदर id "${v.id}" लिखी है',
      );
    }

    _khuliHuin[id] = v;
    return v;
  }

  static String pathFor(String id) =>
      (id.startsWith('navratri_') || id == 'vijayadashami')
          ? '$_dir/navratri/$id.json'
          : '$_dir/$id.json';

  /// किसी मंत्र की रिकॉर्डिंग कहाँ रखी है।
  static String audioPathFor(String file) => '$_dir/audio/$file';
}

/// पूरे ऐप के लिए एक ही भंडार।
/// कथाओं का भंडार (→ D-060)।
///
/// कथा पूजा की JSON में नहीं रखी जाती — वो तीन हज़ार शब्द की होती
/// है, और **एक ही कथा कई पूजाओं में चलती है**। इसलिए वो अपनी
/// फ़ाइल में रहती है — ठीक वैसे जैसे आरती `assets/paath/` में रहती है
/// (→ D-039)।
class KathaBhandar {
  static const _dir = 'assets/katha';

  final Map<String, Katha> _khuliHuin = {};

  Future<Katha> katha(String id) async {
    final yaad = _khuliHuin[id];
    if (yaad != null) return yaad;

    final path = pathFor(id);
    final k = Katha.parse(path, await _padho(path));
    if (k.id != id) {
      throw VidhiFormatException(
        path,
        'फ़ाइल का नाम "$id" है पर अंदर id "${k.id}" लिखी है',
      );
    }
    _khuliHuin[id] = k;
    return k;
  }

  static String pathFor(String id) => '$_dir/$id.json';
}

/// पूरे ऐप के लिए एक ही कथा-भंडार।
final kathaBhandar = KathaBhandar();

final vidhiBhandar = VidhiBhandar();

/// चालीसा और स्तोत्र का भंडार — पूजाओं से अलग (→ D-039)।
///
/// वही ढंग जो [VidhiBhandar] का है: सूची हल्की और एक बार पढ़ी जाती है,
/// पूरा पाठ तभी जब यूज़र खोले।
class PaathBhandar {
  static const _dir = 'assets/paath';
  static const suchiPath = '$_dir/_suchi.json';

  List<PaathSuchiEntry>? _suchi;
  final Map<String, Paath> _khuleHue = {};

  /// पाठों की सूची।
  Future<List<PaathSuchiEntry>> suchi() async {
    final pehleSe = _suchi;
    if (pehleSe != null) return pehleSe;

    final source = await _padho(suchiPath);
    final list = PaathSuchiEntry.parseAll(suchiPath, source);
    _suchi = list;
    return list;
  }

  /// एक पूरा पाठ। दूसरी बार माँगने पर याद रखा हुआ मिलेगा।
  Future<Paath> paath(String id) async {
    final yaad = _khuleHue[id];
    if (yaad != null) return yaad;

    final path = pathFor(id);
    final source = await _padho(path);
    final p = Paath.parse(path, source);

    if (p.id != id) {
      throw VidhiFormatException(
        path,
        'फ़ाइल का नाम "$id" है पर अंदर id "${p.id}" लिखी है',
      );
    }

    _khuleHue[id] = p;
    return p;
  }

  static String pathFor(String id) => '$_dir/$id.json';

  /// किसी पद की रिकॉर्डिंग कहाँ रखी है।
  static String audioPathFor(String file) => '$_dir/audio/$file';
}

/// पूरे ऐप के लिए एक ही भंडार।
final paathBhandar = PaathBhandar();

/// कई दिनों वाले पर्वों का ऑफलाइन भंडार।
class ParvBhandar {
  static const _dir = 'assets/parv';

  final Map<String, Parv> _khuleHue = {};

  Future<Parv> parv(String id) async {
    final yaad = _khuleHue[id];
    if (yaad != null) return yaad;

    final path = pathFor(id);
    final p = Parv.parse(path, await _padho(path));
    if (p.id != id) {
      throw VidhiFormatException(
        path,
        'फ़ाइल का नाम "$id" है पर अंदर id "${p.id}" लिखी है',
      );
    }
    _khuleHue[id] = p;
    return p;
  }

  static String pathFor(String id) => '$_dir/$id.json';
}

/// पूरे ऐप के लिए एक ही पर्व-भंडार।
final parvBhandar = ParvBhandar();
