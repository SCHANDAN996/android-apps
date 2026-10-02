/// भारत की घड़ी, इतिहास सहित — जन्म के छपे समय को UTC में बदलने के लिए
/// (→ D-105, docs/29 §5 की दूसरी अड़चन)।
///
/// पंचांग को यह कभी नहीं चाहिए था: आज की घड़ी हमेशा +5:30 है। पर जन्म-कुंडली
/// में 1940 के दशक के जन्म आएँगे, और तब घड़ी दो बार एक घंटा आगे की गई थी।
/// लग्न चार मिनट में एक अंश चलता है — एक घंटे की भूल पूरी राशि बदल देती है।
///
/// ## स्रोत
/// IANA का समय-क्षेत्र डेटाबेस (tz database), `asia` फ़ाइल, `Asia/Kolkata`:
///
/// ```
/// 5:30        IST   1941 Oct
/// 5:30  1:00        1942 May 15
/// 5:30        IST   1942 Sep
/// 5:30  1:00        1945 Oct 15
/// 5:30        IST
/// ```
///
/// ⚠️ उसी फ़ाइल में लिखा है कि 1941–45 वाली तारीख़ों का इकलौता स्रोत Shanks
/// है, और वह "dubious" है। इसलिए ऐप इन दौरों के जन्म पर **खुली** चेतावनी
/// देता है कि घड़ी एक घंटा आगे मानी गई है।
///
/// ⚠️ 1906 से पहले रेल और तार मद्रास के समय (+5:21:10) पर चलते थे, और
/// कलकत्ता (+5:53:20, 1948 तक) और बम्बई (+4:51, 1955 तक) की अपनी घड़ियाँ
/// नगर के कामों में चलती रहीं। यह फलन **मानक समय** देता है; पुराने काग़ज़ में
/// समय किस घड़ी का है, यह यूज़र ही जानता है।
library;

/// भारतीय मानक समय, आज का।
const Duration bharatManakSamay = Duration(hours: 5, minutes: 30);

/// इससे पहले के साल के जन्म के लिए यह फलन भरोसे लायक़ नहीं — तब पूरे देश की
/// एक घड़ी थी ही नहीं।
const int bharatSamayPehlaSaal = 1906;

final _yuddh1Shuru = DateTime.utc(1941, 10, 1);
final _yuddh1Ant = DateTime.utc(1942, 5, 15);
final _yuddh2Shuru = DateTime.utc(1942, 9, 1);
final _yuddh2Ant = DateTime.utc(1945, 10, 15);

/// [sthaniya] — घड़ी पर लिखा समय (साल, महीना, दिन, घंटा, मिनट; समय-क्षेत्र का
/// निशान देखा नहीं जाता)। उस घड़ी और UTC का अंतर।
Duration bharatSamayAntar(DateTime sthaniya) =>
    yuddhKalKiGhadi(sthaniya) ? const Duration(hours: 6, minutes: 30) : bharatManakSamay;

/// उस क्षण भारत की घड़ी एक घंटा आगे थी (दूसरे विश्वयुद्ध का "war time")?
bool yuddhKalKiGhadi(DateTime sthaniya) {
  final t = DateTime.utc(sthaniya.year, sthaniya.month, sthaniya.day,
      sthaniya.hour, sthaniya.minute);
  bool beech(DateTime a, DateTime b) => !t.isBefore(a) && t.isBefore(b);
  return beech(_yuddh1Shuru, _yuddh1Ant) || beech(_yuddh2Shuru, _yuddh2Ant);
}
