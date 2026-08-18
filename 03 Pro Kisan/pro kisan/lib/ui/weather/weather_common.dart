import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// WMO कोड → emoji + विवरण
Map<String, String> wmoInfo(BuildContext context, int? code) {
  String t(String k) => AppLocalizations.get(context, k);
  if (code == null) return {'emoji': '🌡️', 'desc': t('weather_desc_clear')};
  switch (code) {
    case 0:
      return {'emoji': '☀️', 'desc': t('weather_desc_clear')};
    case 1:
      return {'emoji': '🌤️', 'desc': t('weather_desc_mainly_clear')};
    case 2:
      return {'emoji': '⛅', 'desc': t('weather_desc_partly_cloudy')};
    case 3:
      return {'emoji': '☁️', 'desc': t('weather_desc_overcast')};
    case 45:
    case 48:
      return {'emoji': '🌫️', 'desc': t('weather_desc_fog')};
    case 51:
    case 53:
    case 55:
      return {'emoji': '🌦️', 'desc': t('weather_desc_light_drizzle')};
    case 61:
    case 63:
    case 80:
    case 81:
      return {'emoji': '🌧️', 'desc': t('weather_desc_rain')};
    case 65:
    case 82:
      return {'emoji': '⛈️', 'desc': t('weather_desc_heavy_rain')};
    case 95:
    case 96:
    case 99:
      return {'emoji': '⛈️', 'desc': t('weather_desc_thunderstorm')};
    default:
      if (code >= 70 && code <= 77) {
        return {'emoji': '❄️', 'desc': t('weather_desc_snow')};
      }
      return {'emoji': '☀️', 'desc': t('weather_desc_clear')};
  }
}

/// दिन के समय के हिसाब से background gradient
List<Color> skyGradient(DateTime now, {bool rainy = false}) {
  final h = now.hour;
  if (rainy) {
    return const [Color(0xFF37474F), Color(0xFF263238)]; // Rainy Slate
  }
  if (h >= 5 && h < 8) {
    return const [Color(0xFFF97316), Color(0xFFFB923C)]; // Sunrise Vibrant Orange
  }
  if (h >= 8 && h < 16) {
    return const [Color(0xFF0284C7), Color(0xFF38BDF8)]; // Daytime Clear Sky Blue
  }
  if (h >= 16 && h < 19) {
    return const [Color(0xFFE11D48), Color(0xFF7C3AED)]; // Sunset Purple-Pink
  }
  return const [Color(0xFF0F172A), Color(0xFF1E293B)]; // Night Deep Navy
}

const List<String> kMonthsHi = [
  '', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
  'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
];
const List<String> kMonthsShortHi = [
  '', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
  'जुल', 'अग', 'सित', 'अक्टू', 'नव', 'दिस'
];
const List<String> kMonthsShortEn = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

const List<String> kWeekdaysHi = [
  '', 'सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'
];
const List<String> kWeekdaysLongHi = [
  '', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'
];
const List<String> kWeekdaysEn = [
  '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
];
const List<String> kWeekdaysLongEn = [
  '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

const Map<String, List<String>> _kWeekdaysShort = {
  'hi': ['', 'सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'],
  'bho': ['', 'सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'],
  'mr': ['', 'सोम', 'मंगळ', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'],
  'pa': ['', 'ਸੋਮ', 'ਮੰਗਲ', 'ਬੁਧ', 'ਵੀਰ', 'ਸ਼ੁੱਕਰ', 'ਸ਼ਨਿੱਚਰ', 'ਐਤ'],
  'gu': ['', 'સોમ', 'મંગળ', 'બુધ', 'ગુરુ', 'શુક્ર', 'શનિ', 'રવિ'],
  'bn': ['', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'],
  'te': ['', 'సోమ', 'మంగళ', 'బుధ', 'గురు', 'శుక్ర', 'శని', 'ఆది'],
  'ta': ['', 'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு'],
  'kn': ['', '<ctrl42>ನನ್ನ ಸ್ಥಳ', '<ctrl42>ಮಂಗಳ', '<ctrl42>ಬುಧ', '<ctrl42>ಗುರು', '<ctrl42>ಶುಕ್ರ', '<ctrl42>ಶನಿ', '<ctrl42>ಭಾನು'],
  'en': ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
};

const Map<String, List<String>> _kWeekdaysLong = {
  'hi': ['', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'],
  'bho': ['', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'],
  'mr': ['', 'सोमवार', 'मंगळवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'],
  'pa': ['', 'ਸੋਮਵਾਰ', 'ਮੰਗਲਵਾਰ', 'ਬੁਧਵਾਰ', 'ਵੀਰਵਾਰ', 'ਸ਼ੁੱਕਰਵਾਰ', 'ਸ਼ਨਿੱਚਰਵਾਰ', 'ਐਤਵਾਰ'],
  'gu': ['', 'સોમવાર', 'મંગળવાર', 'બુધવાર', 'ગુરુવાર', 'શુક્રવાર', 'શનિવાર', 'રવિવાર'],
  'bn': ['', 'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'],
  'te': ['', 'సోమవారం', 'మంగళవారం', 'బుధవారం', 'గురువారం', 'శుక్రవారం', 'శనివారం', 'ఆదివారం'],
  'ta': ['', 'திங்கட்கிழமை', 'செவ்வாய்க்கிழமை', 'புதன்கிழமை', 'வியாழக்கிழமை', 'வெள்ளிக்கிழமை', 'சனிக்கிழமை', 'ஞாயிற்றுக்கிழமை'],
  'kn': ['', 'ಸೋಮವಾರ', 'ಮಂಗಳವಾರ', 'ಬುಧವಾರ', 'ಗುರುವಾರ', 'ಶುಕ್ರವಾರ', 'ಶನಿವಾರ', 'ಭಾನುವਾਰ'],
  'en': ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
};

const Map<String, List<String>> _kMonthsShort = {
  'hi': ['', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुल', 'अग', 'सित', 'अक्टू', 'नव', 'दिस'],
  'bho': ['', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुल', 'अग', 'सित', 'अक्टू', 'नव', 'दिस'],
  'mr': ['', 'जाने', 'फेब्रु', 'मार्च', 'एप्रिल', 'मे', 'जून', 'जुलै', 'ऑगस्ट', 'सप्टें', 'ऑक्टो', 'नोव्हें', 'डिसें'],
  'pa': ['', 'ਜਨ', 'ਫ਼ਰ', 'ਮਾਰਚ', 'ਅਪ੍ਰੈਲ', 'ਮਈ', 'ਜੂਨ', 'ਜੁਲਾਈ', 'ਅਗ', 'ਸਤੰ', 'ਅਕਤੂ', 'ਨਵੰ', 'ਦਸੰ'],
  'gu': ['', 'જાન્યુ', 'ફેબ્રુ', 'માર્ચ', 'એપ્રિલ', 'મે', 'જૂન', 'જુલાઈ', 'ઓગસ્ટ', 'સપ્ટે', 'ઓક્ટો', 'નવે', 'ડિસે'],
  'bn': ['', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে'],
  'te': ['', 'జన', 'ఫిబ్ర', 'మార్చి', 'ఏప్రి', 'మే', 'జూన్', 'జూలై', 'ఆగ', 'సెప్టెం', 'అక్టో', 'నవం', 'డిసెం'],
  'ta': ['', 'ஜன', 'பிப்', 'மார்ச்', 'ஏப்', 'மே', 'ஜூன்', 'ஜூலை', 'ஆக', 'செப்', 'அக்டோ', 'நவ', 'டிச'],
  'kn': ['', 'ಜನ', 'ಫೆಬ್ರ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿ', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗ', 'ಸೆಪ್ಟೆ', 'ಅಕ್ಟೋ', 'ನವೆ', 'ಡಿಸೆ'],
  'en': ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
};

const Map<String, List<String>> _kMonthsLong = {
  'hi': ['', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'],
  'bho': ['', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'],
  'mr': ['', 'जानेवारी', 'फेब्रुवारी', 'मार्च', 'एप्रिल', 'मे', 'जून', 'जुलै', 'ऑगस्ट', 'सप्टेंबर', 'ऑक्टोबर', 'नोव्हेंबर', 'डिसेंबर'],
  'pa': ['', 'ਜਨਵਰੀ', 'ਫ਼ਰਵਰੀ', 'ਮਾਰਚ', 'ਅਪ੍ਰੈਲ', 'ਮਈ', 'ਜੂਨ', 'ਜੁਲਾਈ', 'ਅਗਸਤ', 'ਸਤੰਬਰ', 'ਅਕਤੂਬਰ', 'ਨਵੰਬਰ', 'ਦਸੰਬਰ'],
  'gu': ['', 'જાન્યુઆરી', 'ફેબ્રુઆરી', 'માર્ચ', 'એપ્રિલ', 'મે', 'જૂન', 'જુલાઈ', 'ઓગસ્ટ', 'સપ્ટેમ્બર', 'ઓક્ટોબર', 'નવેમ્બર', 'ડિસેમ્બર'],
  'bn': ['', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'],
  'te': ['', 'జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్', 'జూలై', 'ఆగస్టు', 'సెప్టెంబరు', 'అక్టోబరు', 'నవంబరు', 'డిసెంబరు'],
  'ta': ['', 'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்', 'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்'],
  'kn': ['', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್'],
  'en': ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
};

String _getLang(String? code) => (code != null && _kWeekdaysShort.containsKey(code)) ? code : 'en';

String _resolveLang(dynamic langOrBool) {
  if (langOrBool is bool) {
    return langOrBool ? 'hi' : 'en';
  }
  if (langOrBool is String) {
    return langOrBool;
  }
  return 'en';
}

/// "सोम" / "Mon"
String weekdayShort(DateTime d, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final list = _kWeekdaysShort[_getLang(langCode)]!;
  return list[d.weekday.clamp(1, 7)];
}

/// "सोमवार" / "Monday"
String weekdayLong(DateTime d, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final list = _kWeekdaysLong[_getLang(langCode)]!;
  return list[d.weekday.clamp(1, 7)];
}

/// "28 जुल" / "28 Jul"
String dayMonthShort(DateTime d, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final list = _kMonthsShort[_getLang(langCode)]!;
  return '${d.day} ${list[d.month.clamp(1, 12)]}';
}

/// "सोमवार, 28 जुलाई 2026"
String fullDate(DateTime d, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final wList = _kWeekdaysLong[_getLang(langCode)]!;
  final mList = _kMonthsLong[_getLang(langCode)]!;
  return '${wList[d.weekday.clamp(1, 7)]}, ${d.day} ${mList[d.month.clamp(1, 12)]} ${d.year}';
}

/// "दोपहर 2 बजे" / "2 PM"
String hourLabel(DateTime d, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final lang = _getLang(langCode);
  final h = d.hour;
  if (lang == 'en') {
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12 ${h < 12 ? 'AM' : 'PM'}';
  }
  final h12 = (h % 12 == 0) ? 12 : h % 12;
  if (lang == 'hi' || lang == 'bho') {
    if (h == 0) return 'रात 12';
    if (h < 4) return 'रात $h12';
    if (h < 12) return 'सुबह $h12';
    if (h == 12) return 'दोपहर 12';
    if (h < 17) return 'दोपहर $h12';
    if (h < 20) return 'शाम $h12';
    return 'रात $h12';
  }
  if (lang == 'mr') {
    if (h < 12) return 'सकाळी $h12';
    if (h < 17) return 'दुपारी $h12';
    if (h < 20) return 'संध्याकाळी $h12';
    return 'रात्री $h12';
  }
  return '$h12 ${h < 12 ? 'AM' : 'PM'}';
}

/// "5 मिनट पहले" / "5 min ago" — cache age
String agoLabel(int minutes, dynamic langOrBool) {
  final langCode = _resolveLang(langOrBool);
  final lang = _getLang(langCode);
  if (minutes < 1) {
    switch (lang) {
      case 'hi': case 'bho': return 'अभी';
      case 'mr': return 'आत्ताच';
      case 'pa': return 'ਹੁਣੇ';
      case 'gu': return 'હમણાં';
      case 'bn': return 'এখনই';
      case 'te': return 'ఇప్పుడే';
      case 'ta': return 'இப்போது';
      case 'kn': return 'ಈಗಷ್ಟੇ';
      default: return 'just now';
    }
  }
  if (minutes < 60) {
    switch (lang) {
      case 'hi': case 'bho': return '$minutes मिनट पहले';
      case 'mr': return '$minutes मिनिटांपूर्वी';
      case 'pa': return '$minutes ਮਿੰਟ ਪਹਿਲਾਂ';
      case 'gu': return '$minutes મિનિટ પહેલાં';
      case 'bn': return '$minutes মিনিট আগে';
      case 'te': return '$minutes నిమిషాల క్రితం';
      case 'ta': return '$minutes நிமிடங்களுக்கு முன்';
      case 'kn': return '$minutes ನಿಮಿಷಗಳ ಹಿಂದೆ';
      default: return '$minutes min ago';
    }
  }
  final h = minutes ~/ 60;
  if (h < 24) {
    switch (lang) {
      case 'hi': case 'bho': return '$h घंटे पहले';
      case 'mr': return '$h तासांपूर्वी';
      case 'pa': return '$h ਘੰਟੇ ਪਹਿਲਾਂ';
      case 'gu': return '$h કલાક પહેલાં';
      case 'bn': return '$h ঘণ্টা আগে';
      case 'te': return '$h గంటల క్రితం';
      case 'ta': return '$h மணிநேரத்திற்கு முன்';
      case 'kn': return '$h ಗಂಟೆಗಳ ಹಿಂದೆ';
      default: return '${h}h ago';
    }
  }
  final d = h ~/ 24;
  switch (lang) {
    case 'hi': case 'bho': return '$d दिन पहले';
    case 'mr': return '$d दिवसांपूर्वी';
    case 'pa': return '$d ਦਿਨ ਪਹਿਲਾਂ';
    case 'gu': return '$d દિવસ પહેલાં';
    case 'bn': return '$d দিন আগে';
    case 'te': return '$d రోజులు క్రితం';
    case 'ta': return '$d நாட்களுக்கு முன்';
    case 'kn': return '$d ದಿನಗಳ ಹಿಂದೆ';
    default: return '${d}d ago';
  }
}
