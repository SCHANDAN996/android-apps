import 'parv.dart';

/// नवरात्रि शुरू होने से कितने दिन पहले होम के slider में आ जाए।
///
/// पंद्रह दिन — जौ, कलश और सामग्री जुटाने के लिए इतना काफ़ी है, और slider
/// पहले भी घटस्थापना इतने ही दिन पहले दिखाता था (→ D-074)।
const int navratriPehleKitneDin = 15;

/// होम के slider पर नवरात्रि का पत्ता — सिर्फ़ क्या दिखे, कैसे नहीं।
///
/// ## यह क्यों बना (→ D-074)
///
/// 13 सित 2026 तक नवरात्रि slider तक सिर्फ़ "घटस्थापना" नाम के **एक दिन के
/// त्योहार** की तरह पहुँचती थी, और slider की पाँच जगहें हर हफ़्ते वाली
/// पूजाएँ भर देती थीं। नतीजा: 15 और 19 अक्टूबर 2026 — दिन 5 और
/// अष्टमी-नवमी — को होम पर नवरात्रि का नाम तक नहीं था।
class ParvHomeAvsar {
  /// "आज", "कल", "15 दिन बाद"
  final String upar;
  final String naam;
  final String neeche;
  final String artworkAsset;

  /// उसी दिन की विधि, जहाँ सूची उसे सीधे खोलती है। Dashboard नवरात्रि के
  /// हर पत्ते से पहले पूरा पर्व-पन्ना खोलता है। `null` = सिर्फ़ पर्व-पन्ना।
  final String? vidhiId;

  /// पर्व चल रहा है — slider में "आज" वाली जगह पर जाए।
  final bool aajKa;

  /// आरम्भ में कितने दिन बाक़ी (पर्व चल रहा हो तो 0)।
  final int kitneDinBaad;

  final String bulawa;

  const ParvHomeAvsar({
    required this.upar,
    required this.naam,
    required this.neeche,
    required this.artworkAsset,
    required this.vidhiId,
    required this.aajKa,
    required this.kitneDinBaad,
    required this.bulawa,
  });
}

/// आज के लिए नवरात्रि का पत्ता — या `null`, जब दिखाने का समय न हो।
ParvHomeAvsar? navratriHomeAvsar({
  required Parv parv,
  required ParvAaj aaj,
  required DateTime aajKiTarikh,
}) {
  final ank = aaj.aajKaDin;

  // ── पर्व से पहले ──────────────────────────────────────────────────
  if (ank == null) {
    final baad = aaj.kitneDinBaad;
    if (baad == null || baad < 1 || baad > navratriPehleKitneDin) return null;
    return ParvHomeAvsar(
      upar: switch (baad) {
        1 => 'कल',
        2 => 'परसों',
        _ => '$baad दिन बाद',
      },
      naam: parv.naam,
      neeche: parv.ekLine,
      artworkAsset: parv.artworkAsset,
      vidhiId: null,
      aajKa: false,
      kitneDinBaad: baad,
      bulawa: 'पर्व देखें',
    );
  }

  final din = _din(parv, ank);
  if (din == null) return null;

  // ── दो पूजा-दिन एक ही तारीख़ पर ──────────────────────────────────
  //
  // दोनों की अपनी विधि है (2026 में अष्टमी की कन्या पूजन वाली और नवमी की
  // हवन वाली)। एक चुनकर खोलना दूसरी को छिपा देता — इसलिए पर्व-पन्ना खुलता
  // है, जहाँ दोनों पंक्तियाँ साथ दिखती हैं।
  if (aaj.mileHueDin.contains(ank)) {
    final pichhla = _din(parv, ank - 1);
    return ParvHomeAvsar(
      upar: 'आज',
      naam: ank == 9
          ? 'अष्टमी और नवमी'
          : '${pichhla?.shirshak} और ${din.shirshak}',
      neeche: _sandhiYaDin(aaj, aajKiTarikh) ??
          'नवरात्रि दिन ${ank - 1}–$ank · इस साल एक साथ',
      artworkAsset: pichhla?.artworkAsset ?? din.artworkAsset,
      vidhiId: null,
      aajKa: true,
      kitneDinBaad: 0,
      bulawa: 'दोनों पूजाएँ देखें',
    );
  }

  // ── विजयादशमी ─────────────────────────────────────────────────────
  if (ank == 10) {
    return ParvHomeAvsar(
      upar: 'आज',
      naam: din.shirshak,
      neeche: din.ekLine,
      artworkAsset: din.artworkAsset,
      vidhiId: din.vidhiId,
      aajKa: true,
      kitneDinBaad: 0,
      bulawa: din.vidhiId == null ? 'पर्व देखें' : 'आज की पूजा',
    );
  }

  // ── नवरात्रि का कोई एक दिन ──────────────────────────────────────────
  return ParvHomeAvsar(
    upar: 'आज',
    naam: 'माँ ${din.shirshak}',
    neeche:
        _sandhiYaDin(aaj, aajKiTarikh) ?? 'नवरात्रि दिन $ank · ${din.ekLine}',
    artworkAsset: din.artworkAsset,
    vidhiId: din.vidhiId,
    aajKa: true,
    kitneDinBaad: 0,
    bulawa: din.vidhiId == null ? 'पर्व देखें' : 'आज की पूजा',
  );
}

ParvDin? _din(Parv parv, int ank) {
  for (final d in parv.din) {
    if (d.ank == ank) return d;
  }
  return null;
}

/// आज संधि पूजा हो तो उसका समय — वही सबसे काम की एक लाइन है।
String? _sandhiYaDin(ParvAaj aaj, DateTime aajKiTarikh) {
  final shuru = aaj.sandhiShuru;
  final ant = aaj.sandhiAnt;
  if (shuru == null || ant == null) return null;
  final ekDin = shuru.year == aajKiTarikh.year &&
      shuru.month == aajKiTarikh.month &&
      shuru.day == aajKiTarikh.day;
  if (!ekDin) return null;
  return 'संधि पूजा ${_samay(shuru)}–${_samay(ant)}';
}

String _samay(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
