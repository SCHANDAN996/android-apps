import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jameen_napi/data/app_language.dart';
import 'package:jameen_napi/data/map_strings.dart';
import 'package:jameen_napi/data/saved_measurements.dart';
import 'package:jameen_napi/geo/measure_session.dart';
import 'package:jameen_napi/screens/map_measure_hub_screen.dart';

/// Hub वही पन्ना है जहाँ से तीनों तरीक़े खुलते हैं। तीनों में से एक भी card
/// ग़ायब हो जाए तो वो पूरा फ़ीचर user तक पहुँचता ही नहीं — इसलिए यह जाँच।
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LanguageNotifier.instance.value = AppLang.hindi;
  });

  Future<void> pumpHub(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: MapMeasureHubScreen()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hub shows all three ways of measuring', (tester) async {
    await pumpHub(tester);
    final strings = AppStrings(AppLang.hindi);

    expect(find.text(strings.mapTapTitle), findsOneWidget);
    expect(find.text(strings.mapWalkTitle), findsOneWidget);
    expect(find.text(strings.mapRoadTitle), findsOneWidget);
    // GPS और नक्शे की सीमाएँ पहले ही बता देनी हैं
    expect(find.text(strings.mapAccuracyNote), findsOneWidget);
    expect(find.text(strings.mapInternetNote), findsOneWidget);
    expect(find.text(strings.mapNoSaved), findsOneWidget);
  });

  testWidgets('a saved measurement shows up with its area', (tester) async {
    final session = MeasureSession(MeasureKind.area)
      ..add(const LatLng(25.6000, 85.1000))
      ..add(const LatLng(25.6000, 85.1010))
      ..add(const LatLng(25.6010, 85.1010))
      ..add(const LatLng(25.6010, 85.1000));
    await SavedMeasurementStore.instance.save('नदी वाला खेत', session);

    await pumpHub(tester);

    expect(find.text('नदी वाला खेत'), findsOneWidget);
    expect(find.text(AppStrings(AppLang.hindi).mapNoSaved), findsNothing);
    // ~100 × 111 मी का खेत — वर्ग फीट में छह अंकों वाली संख्या दिखे
    final subtitle = tester
        .widget<Text>(find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').startsWith('रकबा:')))
        .data!;
    expect(subtitle, contains('4 बिंदु'));
  });
}
