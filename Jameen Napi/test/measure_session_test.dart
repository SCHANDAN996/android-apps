import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:jameen_napi/geo/geo_math.dart';
import 'package:jameen_napi/geo/measure_session.dart';

/// पटना के पास, हर 0.0001° ≈ 11 मी (अक्षांश) / 10 मी (देशांतर)
LatLng p(int north, int east) =>
    LatLng(25.6 + north * 0.0001, 85.1 + east * 0.0001);

void main() {
  group('MeasureSession — रकबा', () {
    test('3 बिंदु से पहले रकबा नहीं', () {
      final s = MeasureSession(MeasureKind.area)
        ..add(p(0, 0))
        ..add(p(0, 1));
      expect(s.hasArea, isFalse);
      expect(s.areaSqFt, 0);
    });

    test('रकबा geo_math से मेल खाता है, टुकड़े होने पर भी', () {
      final s = MeasureSession(MeasureKind.area)
        ..add(p(0, 0))
        ..add(p(0, 5))
        ..startNewSegment()
        ..add(p(5, 5))
        ..add(p(5, 0));
      expect(s.segments.length, 2);
      expect(s.areaSqFt,
          closeTo(polygonAreaSqFt([p(0, 0), p(0, 5), p(5, 5), p(5, 0)]), 1e-6));
      // परिधि बंद आकृति की
      expect(
          s.lengthMeters,
          closeTo(
              pathLengthMeters([p(0, 0), p(0, 5), p(5, 5), p(5, 0)],
                  closed: true),
              1e-6));
    });

    test('"8" आकार पकड़ा जाता है', () {
      final s = MeasureSession(MeasureKind.area)
        ..add(p(0, 0))
        ..add(p(0, 5))
        ..add(p(5, 0))
        ..add(p(5, 5));
      expect(s.crossesItself, isTrue);
    });

    test('move दूसरे टुकड़े का सही बिंदु बदलता है', () {
      final s = MeasureSession(MeasureKind.area)
        ..add(p(0, 0))
        ..add(p(0, 5))
        ..startNewSegment()
        ..add(p(5, 5));
      s.move(2, p(9, 9));
      expect(s.points[2], p(9, 9));
      expect(s.points[1], p(0, 5));
    });
  });

  group('MeasureSession — दूरी', () {
    test('टुकड़ों के बीच की छलांग दूरी में नहीं जुड़ती', () {
      final s = MeasureSession(MeasureKind.distance)
        ..add(p(0, 0))
        ..add(p(10, 0))
        ..startNewSegment()
        ..add(p(50, 0))
        ..add(p(60, 0));
      final expected = distanceMeters(p(0, 0), p(10, 0)) +
          distanceMeters(p(50, 0), p(60, 0));
      expect(s.lengthMeters, closeTo(expected, 1e-6));
      expect(s.areaSqFt, 0);
      expect(s.crossesItself, isFalse);
    });

    test('ख़ाली टुकड़े पर दोबारा pause नया टुकड़ा नहीं बनाता', () {
      final s = MeasureSession(MeasureKind.distance)
        ..add(p(0, 0))
        ..startNewSegment()
        ..startNewSegment();
      s.add(p(1, 0));
      expect(s.segments.length, 2);
    });

    test('undo टुकड़े की सीमा पार करके पिछला बिंदु हटाता है', () {
      final s = MeasureSession(MeasureKind.distance)
        ..add(p(0, 0))
        ..add(p(1, 0))
        ..startNewSegment();
      s.undo();
      expect(s.points, [p(0, 0)]);
      s.undo();
      s.undo(); // ख़ाली पर undo से crash नहीं
      expect(s.isEmpty, isTrue);
    });

    test('clear के बाद सब शून्य', () {
      final s = MeasureSession(MeasureKind.distance)
        ..add(p(0, 0))
        ..add(p(1, 0))
        ..clear();
      expect(s.pointCount, 0);
      expect(s.lengthMeters, 0);
    });
  });

  group('JSON', () {
    test('सहेजना और वापस पढ़ना', () {
      final s = MeasureSession(MeasureKind.distance)
        ..add(const LatLng(25.123456789, 85.987654321))
        ..add(p(3, 3))
        ..startNewSegment()
        ..add(p(9, 9));
      final back =
          MeasureSession.fromJson(jsonDecode(jsonEncode(s.toJson())))!;
      expect(back.kind, MeasureKind.distance);
      expect(back.segments.length, 2);
      // 7 दशमलव तक गोल (≈1 सेमी)
      expect(back.points.first.latitude, closeTo(25.1234568, 1e-9));
      expect(back.lengthMeters, closeTo(s.lengthMeters, 0.01));
    });

    test('टूटा JSON null देता है, crash नहीं', () {
      expect(MeasureSession.fromJson(null), isNull);
      expect(MeasureSession.fromJson({'kind': 'xyz', 'segments': []}), isNull);
      expect(MeasureSession.fromJson({'kind': 'area', 'segments': 'abc'}),
          isNull);
      expect(
          MeasureSession.fromJson({
            'kind': 'area',
            'segments': [
              [
                [200, 85]
              ]
            ]
          }),
          isNull);
    });
  });

  group('gpsAreaUncertainty', () {
    test('1 एकड़ (63.6 मी वर्ग), 4 मी accuracy ≈ 13% — चेतावनी नहीं', () {
      const side = 63.61;
      final u = gpsAreaUncertainty(
          perimeterMeters: 4 * side,
          areaSqMeters: side * side,
          accuracyMeters: 4);
      expect(u, closeTo(0.126, 0.005));
      expect(u < gpsAreaWarnThreshold, isTrue);
    });

    test('20 × 20 मी, 4 मी accuracy = 40% — चेतावनी', () {
      final u = gpsAreaUncertainty(
          perimeterMeters: 80, areaSqMeters: 400, accuracyMeters: 4);
      expect(u, closeTo(0.4, 1e-9));
      expect(u > gpsAreaWarnThreshold, isTrue);
    });

    test('शून्य रकबा = अनंत', () {
      expect(
          gpsAreaUncertainty(
              perimeterMeters: 10, areaSqMeters: 0, accuracyMeters: 4),
          double.infinity);
    });
  });
}
