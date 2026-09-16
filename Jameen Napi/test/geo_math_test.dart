import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:jameen_napi/geo/geo_math.dart';

/// एक डिग्री अक्षांश/देशांतर कितने मीटर का — भूगोल की किताबों वाली मानक
/// series (WGS-84)। `geo_math.dart` के सूत्र से अलग तरीक़ा है, इसलिए इससे
/// बनाए खेत पर जाँच सच्ची जाँच है, अपने ही सूत्र को दोहराना नहीं।
double metersPerDegLat(double lat) {
  final p = lat * math.pi / 180;
  return 111132.954 - 559.822 * math.cos(2 * p) + 1.175 * math.cos(4 * p);
}

double metersPerDegLon(double lat) {
  final p = lat * math.pi / 180;
  return 111412.84 * math.cos(p) -
      93.5 * math.cos(3 * p) +
      0.118 * math.cos(5 * p);
}

/// [lat],[lon] को दक्षिण-पश्चिम कोना मानकर [w] × [h] मीटर का आयत
List<LatLng> rectangle(double lat, double lon, double w, double h) {
  final dLat = h / metersPerDegLat(lat + h / 2 / metersPerDegLat(lat));
  final dLon = w / metersPerDegLon(lat + dLat / 2);
  return [
    LatLng(lat, lon),
    LatLng(lat, lon + dLon),
    LatLng(lat + dLat, lon + dLon),
    LatLng(lat + dLat, lon),
  ];
}

Matcher within(double expected, double fraction) =>
    closeTo(expected, expected.abs() * fraction);

void main() {
  group('distanceMeters', () {
    test('भूमध्य रेखा पर 1° देशांतर = 1,11,319 मी (±0.5%)', () {
      // 20 किमी से लंबी दूरी पर गोले वाला haversine चलता है — ellipsoid से
      // ~0.1% कम। खेत/सड़क के टुकड़ों पर यह रास्ता लगता ही नहीं।
      expect(distanceMeters(const LatLng(0, 77), const LatLng(0, 78)),
          within(111319.5, 0.005));
    });

    test('भूमध्य रेखा पर 10 किमी देशांतर — ellipsoid वाला सटीक हिसाब', () {
      const dLon = 10000 / 111319.49;
      expect(distanceMeters(const LatLng(0, 77), const LatLng(0, 77 + dLon)),
          within(10000, 0.0002));
    });

    test('वाराणसी के पास 1 किमी पूरब की दूरी', () {
      const lat = 25.3176;
      final dLon = 1000 / metersPerDegLon(lat);
      expect(
          distanceMeters(
              const LatLng(lat, 82.9739), LatLng(lat, 82.9739 + dLon)),
          within(1000, 0.001));
    });

    test('लंबी दूरी (दिल्ली → मुंबई) haversine से ~1,150 किमी', () {
      final d = distanceMeters(
          const LatLng(28.6139, 77.2090), const LatLng(19.0760, 72.8777));
      expect(d, within(1150000, 0.01));
    });

    test('एक ही बिंदु की दूरी शून्य', () {
      expect(distanceMeters(const LatLng(26, 85), const LatLng(26, 85)), 0);
    });
  });

  group('polygonAreaSqMeters', () {
    // Pro Kisan में longitude की cos(lat) वाली गलती से वाराणसी पर +10.6% और
    // लुधियाना पर +16.5% ज़्यादा रकबा आता था। अलग-अलग अक्षांशों पर जाँचें।
    for (final place in const [
      ('कन्याकुमारी', 8.0883, 77.5385),
      ('पटना', 25.5941, 85.1376),
      ('वाराणसी', 25.3176, 82.9739),
      ('लुधियाना', 30.9010, 75.8573),
      ('श्रीनगर', 34.0837, 74.7973),
    ]) {
      test('${place.$1}: 100 × 100 मी का खेत = 1 हेक्टेयर', () {
        final field = rectangle(place.$2, place.$3, 100, 100);
        expect(polygonAreaSqMeters(field), within(10000, 0.001));
      });
    }

    test('बड़ा खेत: 1 × 0.5 किमी = 50 हेक्टेयर', () {
      final field = rectangle(26.0, 84.0, 1000, 500);
      expect(polygonAreaSqMeters(field), within(500000, 0.002));
    });

    test('बिंदु घड़ी की दिशा में हों या उल्टी — रकबा वही', () {
      final field = rectangle(25.6, 85.1, 60, 40);
      expect(polygonAreaSqMeters(field.reversed.toList()),
          within(polygonAreaSqMeters(field), 1e-9));
    });

    test('1 बीघा (बिहार, 27,225 वर्ग फीट) वाला खेत', () {
      // 27,225 वर्ग फीट = 50.292 × 50.292 मी
      final side = math.sqrt(27225 / sqFtPerSqMeter);
      final field = rectangle(25.6, 85.1, side, side);
      expect(polygonAreaSqFt(field), within(27225, 0.001));
    });

    test('3 से कम बिंदु = शून्य', () {
      expect(polygonAreaSqMeters(const []), 0);
      expect(
          polygonAreaSqMeters(const [LatLng(25, 85), LatLng(25.001, 85)]), 0);
    });

    test('त्रिभुज: आधार 80 मी, ऊँचाई 50 मी = 2,000 वर्ग मी', () {
      final r = rectangle(25.6, 85.1, 80, 50);
      // दक्षिण की भुजा आधार, उत्तर-पश्चिम कोना शीर्ष
      expect(polygonAreaSqMeters([r[0], r[1], r[3]]), within(2000, 0.001));
    });
  });

  group('pathLengthMeters', () {
    test('खुली रेखा: आयत की तीन भुजाएँ', () {
      final r = rectangle(25.6, 85.1, 100, 40);
      expect(pathLengthMeters(r.sublist(0, 3)), within(140, 0.001));
    });

    test('बंद आकृति: परिधि', () {
      final r = rectangle(25.6, 85.1, 100, 40);
      expect(pathLengthMeters(r, closed: true), within(280, 0.001));
    });

    test('1 बिंदु = शून्य', () {
      expect(pathLengthMeters(const [LatLng(25, 85)]), 0);
    });
  });

  group('isSelfIntersecting', () {
    test('सही क्रम वाला आयत नहीं कटता', () {
      expect(isSelfIntersecting(rectangle(25.6, 85.1, 50, 50)), isFalse);
    });

    test('1-2-4-3 क्रम वाला "8" आकार कटता है', () {
      final r = rectangle(25.6, 85.1, 50, 50);
      expect(isSelfIntersecting([r[0], r[1], r[3], r[2]]), isTrue);
    });

    test('त्रिभुज कभी नहीं कटता', () {
      final r = rectangle(25.6, 85.1, 50, 50);
      expect(isSelfIntersecting(r.sublist(0, 3)), isFalse);
    });

    test('अंदर धँसा (L आकार) खेत नहीं कटता', () {
      final base = rectangle(25.6, 85.1, 100, 100);
      final mid = rectangle(25.6, 85.1, 50, 50);
      final l = [base[0], base[1], LatLng(mid[2].latitude, base[1].longitude),
        mid[2], LatLng(base[3].latitude, mid[2].longitude), base[3]];
      expect(isSelfIntersecting(l), isFalse);
      expect(polygonAreaSqMeters(l), within(7500, 0.002));
    });
  });

  group('averageFixes', () {
    final t = DateTime(2026, 9, 15, 10);

    test('सटीक reading का वज़न ज़्यादा', () {
      final r = averageFixes([
        GpsFix(const LatLng(25.0, 85.0), 2, t),
        GpsFix(const LatLng(25.001, 85.0), 10, t),
      ]);
      // 2 मी वाली reading 25× भारी है — औसत उसी के पास रहे
      expect(r.position.latitude, closeTo(25.0, 0.0001));
      expect(r.samplesUsed, 2);
      expect(r.isWeak, isFalse);
    });

    test('15 मी से ख़राब readings छूटती हैं', () {
      final r = averageFixes([
        GpsFix(const LatLng(25.0, 85.0), 5, t),
        GpsFix(const LatLng(25.01, 85.0), 40, t),
      ]);
      expect(r.samplesUsed, 1);
      expect(r.position.latitude, 25.0);
    });

    test('सब ख़राब हों तो सबसे अच्छी वाली, isWeak के साथ', () {
      final r = averageFixes([
        GpsFix(const LatLng(25.0, 85.0), 30, t),
        GpsFix(const LatLng(25.01, 85.0), 22, t),
      ]);
      expect(r.isWeak, isTrue);
      expect(r.position.latitude, 25.01);
      expect(r.accuracyMeters, 22);
    });

    test('खाली सूची पर error', () {
      expect(() => averageFixes(const []), throwsArgumentError);
    });
  });

  group('TrackFilter', () {
    final t0 = DateTime(2026, 9, 15, 10);
    const start = LatLng(25.6, 85.1);
    LatLng north(double meters) =>
        LatLng(start.latitude + meters / metersPerDegLat(25.6), 85.1);

    test('पहला अच्छा बिंदु हमेशा जुड़ता है', () {
      expect(TrackFilter.walking().accept(GpsFix(start, 5, t0)), isTrue);
    });

    test('ख़राब accuracy वाला बिंदु नहीं जुड़ता', () {
      expect(TrackFilter.walking().accept(GpsFix(start, 50, t0)), isFalse);
    });

    test('खड़े-खड़े 1 मी का हिलना नहीं जुड़ता', () {
      final f = TrackFilter.walking()..accept(GpsFix(start, 5, t0));
      expect(
          f.accept(GpsFix(north(1), 5, t0.add(const Duration(seconds: 5)))),
          isFalse);
    });

    test('पैदल 1 सेकंड में 60 मी की छलांग नहीं जुड़ती', () {
      final f = TrackFilter.walking()..accept(GpsFix(start, 5, t0));
      expect(
          f.accept(GpsFix(north(60), 5, t0.add(const Duration(seconds: 1)))),
          isFalse);
      // छलांग छूटने पर "आख़िरी बिंदु" वही पुराना रहे
      expect(f.last!.position, start);
    });

    test('गाड़ी में 1 सेकंड में 20 मी जुड़ता है', () {
      final f = TrackFilter.vehicle()..accept(GpsFix(start, 5, t0));
      expect(
          f.accept(GpsFix(north(20), 5, t0.add(const Duration(seconds: 1)))),
          isTrue);
    });

    test('reset के बाद दूर का बिंदु भी नया शुरुआती बिंदु बनता है', () {
      final f = TrackFilter.walking()..accept(GpsFix(start, 5, t0));
      f.reset();
      expect(
          f.accept(GpsFix(north(500), 5, t0.add(const Duration(seconds: 2)))),
          isTrue);
    });

    test('100 मी सीधा चलना → track की लंबाई ~100 मी', () {
      final f = TrackFilter.walking();
      final kept = <LatLng>[];
      for (var i = 0; i <= 100; i++) {
        // हर सेकंड 1 मी, ऊपर से ±0.5 मी का GPS शोर
        final noise = (i.isEven ? 0.5 : -0.5);
        final fix = GpsFix(
            north(i + noise), 4, t0.add(Duration(seconds: i)));
        if (f.accept(fix)) kept.add(fix.position);
      }
      expect(pathLengthMeters(kept), closeTo(100, 4));
    });
  });
}
