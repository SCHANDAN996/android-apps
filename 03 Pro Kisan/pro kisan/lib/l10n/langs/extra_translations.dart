import 'lang_bho.dart';
import 'lang_bn.dart';
import 'lang_gap2.dart';
import 'lang_gap2_deva.dart';
import 'lang_gap3.dart';
import 'lang_gap_dravidian.dart';
import 'lang_gap_north.dart';
import 'lang_gu.dart';
import 'lang_kn.dart';
import 'lang_mr.dart';
import 'lang_pa.dart';
import 'lang_ta.dart';
import 'lang_te.dart';

/// app_localizations.dart का `_localizedValues` अब भी हर भाषा का "core" रखता है
/// (दूध/ग्राहक/सेटिंग वाले पुराने ~102 keys)। बाद में जुड़े ~457 keys — खाद, मंडी,
/// योजना, समाचार, मौसम, पशु, dashboard — हर भाषा की अपनी file में हैं और यहाँ
/// जुड़ते हैं। इससे मुख्य file फूलती नहीं और हर भाषा अलग से जाँची जा सकती है।
///
/// `lang_gap_*` और `lang_gap2*` में वे **153 चाबियाँ** हैं जो आठों भाषाओं में
/// छूट गई थीं — पालन गाइड के सारे शीर्षक, अनुमति वाला पन्ना, रिपोर्ट, FCR,
/// मौसम की खोज। इनके बिना तमिल/तेलुगु/कन्नड़/बांग्ला/गुजराती/पंजाबी वाले को
/// उन जगहों पर **देवनागरी** दिख जाती थी, जो वे पढ़ ही नहीं सकते।
///
/// अब दसों भाषाएँ 712/712 पूरी हैं।
///
/// lookup क्रम (AppLocalizations.translate में):
///   _localizedValues[lang] → kExtraTranslations[lang]
///   → देवनागरी वालों को hi, बाक़ी को en → फिर key
Map<String, String> _merge(List<Map<String, String>> parts) {
  final out = <String, String>{};
  for (final p in parts) {
    out.addAll(p);
  }
  return out;
}

final Map<String, Map<String, String>> kExtraTranslations = {
  'bho': _merge([kBho, kBhoGap, kBhoGap2, kBhoGap3]),
  'bn': _merge([kBn, kBnGap, kBnGap2, kBnGap3]),
  'gu': _merge([kGu, kGuGap, kGuGap2, kGuGap3]),
  'kn': _merge([kKn, kKnGap, kKnGap2, kKnGap3]),
  'mr': _merge([kMr, kMrGap, kMrGap2, kMrGap3]),
  'pa': _merge([kPa, kPaGap, kPaGap2, kPaGap3]),
  'ta': _merge([kTa, kTaGap, kTaGap2, kTaGap3]),
  'te': _merge([kTe, kTeGap, kTeGap2, kTeGap3]),
};
