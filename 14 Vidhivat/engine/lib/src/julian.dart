/// जूलियन दिन (Julian Day) और ΔT।
///
/// पूरे इंजन में समय दो रूपों में चलता है:
///   • JD (UT)  — घड़ी का समय, सूर्योदय वगैरह के लिए
///   • JDE (TT) — गणित का समय, ग्रहों की स्थिति के लिए
/// दोनों के बीच का फ़र्क़ ही ΔT है। JDE = JD + ΔT/86400
///
/// संदर्भ: Meeus, "Astronomical Algorithms", अध्याय 7 और 10।

/// J2000.0 — सारी गणना का शून्य बिंदु (1 जनवरी 2000, दोपहर 12 बजे TT)।
const double j2000 = 2451545.0;

/// एक जूलियन शताब्दी में कितने दिन।
const double daysPerCentury = 36525.0;

/// किसी UTC क्षण का जूलियन दिन।
double julianDayFromUtc(DateTime utc) {
  assert(utc.isUtc, 'DateTime UTC में होना चाहिए');
  final dayFraction = (utc.hour +
          utc.minute / 60.0 +
          utc.second / 3600.0 +
          utc.millisecond / 3600000.0) /
      24.0;
  return julianDay(utc.year, utc.month, utc.day.toDouble() + dayFraction);
}

/// साल, महीना और (दशमलव वाला) दिन → जूलियन दिन। ग्रेगोरियन कैलेंडर।
double julianDay(int year, int month, double day) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      b -
      1524.5;
}

/// जूलियन दिन → UTC।
DateTime utcFromJulianDay(double jd) {
  final z = (jd + 0.5).floor();
  final f = (jd + 0.5) - z;

  int a;
  if (z < 2299161) {
    a = z;
  } else {
    final alpha = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + alpha - (alpha / 4).floor();
  }

  final b = a + 1524;
  final c = ((b - 122.1) / 365.25).floor();
  final d = (365.25 * c).floor();
  final e = ((b - d) / 30.6001).floor();

  final dayWithFraction = b - d - (30.6001 * e).floor() + f;
  final day = dayWithFraction.floor();
  final month = e < 14 ? e - 1 : e - 13;
  final year = month > 2 ? c - 4716 : c - 4715;

  // बचे हुए हिस्से को मिलीसेकंड में। गोलाई की ग़लती से बचने के लिए round.
  final msInDay = ((dayWithFraction - day) * 86400000).round();
  return DateTime.utc(year, month, day).add(Duration(milliseconds: msInDay));
}

/// जूलियन शताब्दी — J2000 से कितनी सदियाँ।
double julianCenturies(double jd) => (jd - j2000) / daysPerCentury;

/// ΔT — दुनिया का घूमना धीमा पड़ने से TT और UT में जो फ़र्क़ आता है, सेकंड में।
///
/// Espenak & Meeus (NASA) के बहुपद। पंचांग के लिए ΔT का असर छोटा है
/// (~70 सेकंड), पर तिथि की समाप्ति का समय बताते वक़्त वही 70 सेकंड
/// दिखते हैं — इसलिए लगाया है।
double deltaTSeconds(int year, int month) {
  final y = year + (month - 0.5) / 12.0;

  if (y >= 2005 && y < 2050) {
    final t = y - 2000;
    return 62.92 + 0.32217 * t + 0.005589 * t * t;
  }
  if (y >= 1986 && y < 2005) {
    final t = y - 2000;
    return 63.86 +
        0.3345 * t -
        0.060374 * t * t +
        0.0017275 * t * t * t +
        0.000651814 * t * t * t * t +
        0.00002373599 * t * t * t * t * t;
  }
  if (y >= 2050 && y < 2150) {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u - 0.5628 * (2150 - y);
  }
  if (y >= 1961 && y < 1986) {
    final t = y - 1975;
    return 45.45 + 1.067 * t - t * t / 260 - t * t * t / 718;
  }
  // इससे बाहर की तारीख़ों के लिए मोटा-मोटी अनुमान। ऐप में ऐसी तारीख़ें
  // आएँगी नहीं, पर गणित टूटना नहीं चाहिए।
  final u = (y - 1820) / 100;
  return -20 + 32 * u * u;
}

/// UT का JD → TT का JD (जिसे JDE कहते हैं)।
double toEphemerisTime(double jdUt) {
  final utc = utcFromJulianDay(jdUt);
  return jdUt + deltaTSeconds(utc.year, utc.month) / 86400.0;
}
