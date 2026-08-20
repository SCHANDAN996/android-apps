/// विधिवत का पंचांग इंजन।
///
/// शुद्ध Dart — कोई Flutter निर्भरता नहीं, कोई नेटवर्क नहीं, कोई
/// खगोल लाइब्रेरी नहीं। पूरा गणित फ़ोन पर ही होता है, हमेशा के लिए,
/// किसी भी साल के लिए।
///
/// इस्तेमाल:
/// ```dart
/// final p = computePanchang(2026, 8, 20, Place.delhi);
/// print('${p.tithi.name} — ${p.tithi.endsAt}');
/// ```
///
/// ⚠️ पहला काम: छपे हुए ठाकुर प्रसाद पंचांग से मिलाना।
/// देखो `test/data/reference_dates.json`।
library;

export 'src/angles.dart' show toDms, norm360, norm180;
export 'src/ayanamsa.dart' show lahiriAyanamsa, toSidereal, ayanamsaCalibration;
export 'src/julian.dart'
    show julianDay, julianDayFromUtc, utcFromJulianDay, toEphemerisTime, deltaTSeconds, j2000;
export 'src/moon.dart'
    show
        moonLongitude,
        moonLatitude,
        moonDistance,
        moonParallax,
        moonMeanLongitude,
        moonGeometricLongitude;
export 'src/nutation.dart' show nutationInLongitude;
export 'src/festival.dart';
export 'src/muhurta.dart';
export 'src/names.dart';
export 'src/sankalp.dart';
export 'src/shubh_muhurat.dart';
export 'src/panchang.dart';
export 'src/place.dart' show Place;
export 'src/sun.dart'
    show sunApparentLongitude, sunEquatorial, meanObliquity, trueObliquity;
export 'src/moonrise.dart'
    show moonriseMoonset, moonAltitude, moonEquatorial, moonHorizonAdjustment;
export 'src/sunrise.dart' show sunriseSunset, sunriseJd, sunAltitude, greenwichMeanSiderealTime;
