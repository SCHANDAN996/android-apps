/// **कथा** — पूजा के बीच सुनाई जाने वाली गद्य कथा (→ D-060)।
///
/// ## यह मंत्र से अलग चीज़ क्यों है
///
/// [Mantra] का खाना श्लोक के लिए बना है — देवनागरी, रोमन, अर्थ, तीनों
/// छोटे। कथा गद्य है, अध्यायों में बँटी, और सत्यनारायण की कथा अकेले
/// **पाँच अध्याय, लगभग तीन हज़ार शब्द** है। उसे `mantra.devanagari` में
/// ठूँसना ग़लत होता — न रोमन का मतलब बनता, न अर्थ का।
///
/// ## ⚠️ सबसे ज़रूरी बात — यह भावार्थ है, शब्दशः पाठ नहीं
///
/// ऐप का अपना नियम है: *"जब तक प्रामाणिक स्रोत से न आए, हम अंदाज़े से
/// कुछ नहीं लिखेंगे।"* कथा पर वह नियम इस तरह लगता है —
///
/// कथा का मूल **स्कंद पुराण, रेवा खंड** में संस्कृत में है। घरों में वो
/// संस्कृत में नहीं, **हिंदी में** पढ़ी जाती है, और छपी पुस्तिकाएँ
/// (गीता प्रेस, और बाज़ार की पोथियाँ) आपस में अलग-अलग हैं — कोई एक
/// "असली" हिंदी पाठ है ही नहीं।
///
/// इसलिए ऐप वो नहीं करता जो मंत्र पर करता है (शब्द-दर-शब्द स्रोत से
/// लेना), और वो भी नहीं करता जो ग़लत होता (चुप रह जाना)। वो **तीसरा
/// रास्ता** लेता है: कथा हिंदी में लिखता है, और [KathaRoop.bhavarth]
/// से हर पन्ने पर साफ़ कहता है कि यह भावार्थ है।
///
/// जिस दिन किसी छपी पोथी से शब्दशः पाठ मिल जाए, [KathaRoop.shabdashah]
/// पहले से बना रखा है — तब सिर्फ़ झंडा बदलेगा, ढाँचा नहीं।
library;

import 'dart:convert';

import 'vidhi.dart' show VidhiFormatException;

/// कथा किस रूप में लिखी है।
enum KathaRoop {
  /// हिंदी में कही गई कथा — शब्द अपने, घटनाएँ मूल की।
  ///
  /// ⚠️ ऐप इसे **छिपाता नहीं।** हर कथा के ऊपर यह लिखा रहता है।
  bhavarth(
    'भावार्थ',
    'यह कथा हिंदी में कही गई है — घटनाएँ मूल कथा की हैं, शब्द अपने। '
        'यह शब्दशः संस्कृत पाठ नहीं है। आपकी पोथी से थोड़ा फ़र्क़ हो '
        'सकता है, और वो स्वाभाविक है।',
  ),

  /// किसी छपी पोथी से हूबहू लिया गया पाठ।
  shabdashah(
    'शब्दशः',
    'यह पाठ छपी हुई पोथी से हूबहू लिया गया है।',
  );

  final String naam;

  /// यूज़र को दिखने वाली पूरी बात। यही ईमानदारी है।
  final String batao;

  const KathaRoop(this.naam, this.batao);

  static KathaRoop parse(String file, String raw) =>
      KathaRoop.values.firstWhere(
        (r) => r.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'roop "$raw" ग़लत है। चलेंगी: '
          '${KathaRoop.values.map((r) => r.name).join(", ")}',
        ),
      );
}

/// कथा का एक अध्याय।
class KathaAdhyay {
  /// पहला, दूसरा… — गिनती 1 से।
  final int kram;

  /// जैसे "पहला अध्याय — नारद जी का प्रश्न"।
  final String shirshak;

  /// पूरी कथा, पैराग्राफ़ में (`\n\n` से बँटी)।
  final String gadya;

  /// एक पंक्ति में — क्या हुआ। सूची में यही दिखता है।
  final String saar;

  const KathaAdhyay({
    required this.kram,
    required this.shirshak,
    required this.gadya,
    required this.saar,
  });

  /// पढ़ने में लगभग कितने मिनट। **200 शब्द प्रति मिनट** — ज़ोर से,
  /// ठहरकर पढ़ने की रफ़्तार, चुपचाप पढ़ने की नहीं।
  int get minute {
    final shabd = gadya.trim().split(RegExp(r'\s+')).length;
    return (shabd / 200).ceil().clamp(1, 60);
  }

  factory KathaAdhyay.fromJson(String file, Map<String, dynamic> j) {
    final kram = j['kram'];
    if (kram is! int || kram < 1) {
      throw VidhiFormatException(file, 'अध्याय का kram 1 से बड़ा होना चाहिए');
    }
    return KathaAdhyay(
      kram: kram,
      shirshak: _str(file, j, 'shirshak'),
      gadya: _str(file, j, 'gadya'),
      saar: _str(file, j, 'saar'),
    );
  }
}

/// एक पूरी कथा।
class Katha {
  final String id;
  final String naam;
  final List<KathaAdhyay> adhyay;
  final KathaRoop roop;

  /// कथा कहाँ से आई — मूल ग्रंथ, और किन पोथियों से मिलाई गई।
  final String strot;

  /// कब सुनाई जाती है।
  final String kabSunayen;

  const Katha({
    required this.id,
    required this.naam,
    required this.adhyay,
    required this.roop,
    required this.strot,
    required this.kabSunayen,
  });

  int get adhyayKul => adhyay.length;

  /// पूरी कथा पढ़ने में लगभग कितने मिनट।
  int get minute => adhyay.fold(0, (a, b) => a + b.minute);

  factory Katha.parse(String file, String source) {
    final Object? raw;
    try {
      raw = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON पढ़ा नहीं जा सका — ${e.message}');
    }
    if (raw is! Map<String, dynamic>) {
      throw VidhiFormatException(file, 'सबसे ऊपर एक object होना चाहिए');
    }

    final list = raw['adhyay'];
    if (list is! List || list.isEmpty) {
      throw VidhiFormatException(file, 'कम से कम एक अध्याय चाहिए');
    }
    final adhyay = [
      for (final a in list)
        KathaAdhyay.fromJson(
          file,
          a is Map<String, dynamic>
              ? a
              : throw VidhiFormatException(file, 'हर अध्याय object हो'),
        ),
    ];

    // ⚠️ क्रम 1, 2, 3… लगातार होना चाहिए। एक अध्याय छूट जाए तो यूज़र
    // को पता ही नहीं चलेगा — वो सोचेगा कथा ऐसी ही है।
    for (var i = 0; i < adhyay.length; i++) {
      if (adhyay[i].kram != i + 1) {
        throw VidhiFormatException(
          file,
          'अध्यायों का क्रम टूटा है — ${i + 1} की जगह ${adhyay[i].kram}',
        );
      }
    }

    return Katha(
      id: _str(file, raw, 'id'),
      naam: _str(file, raw, 'naam'),
      adhyay: adhyay,
      roop: KathaRoop.parse(file, _str(file, raw, 'roop')),
      strot: _str(file, raw, 'strot'),
      kabSunayen: _str(file, raw, 'kabSunayen'),
    );
  }
}

String _str(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! String || v.trim().isEmpty) {
    throw VidhiFormatException(file, '"$key" भरा होना चाहिए');
  }
  return v;
}
