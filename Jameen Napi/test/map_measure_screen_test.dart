import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jameen_napi/data/app_language.dart';
import 'package:jameen_napi/data/map_strings.dart';
import 'package:jameen_napi/geo/measure_session.dart';
import 'package:jameen_napi/screens/map_measure_screen.dart';

/// नक्शे पर उंगली से नापने वाला रास्ता — बिना GPS, बिना इंटरनेट।
///
/// test में tiles नहीं आतीं (network image fail) और geolocator का plugin भी
/// नहीं होता; यही जाँचने लायक़ है कि इन दोनों के बिना भी screen खुलती है और
/// tap से बिंदु लगते हैं।
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    LanguageNotifier.instance.value = AppLang.hindi;
  });

  Future<void> pumpScreen(WidgetTester tester, MeasureKind kind) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: MapMeasureScreen(method: MeasureMethod.tap, kind: kind),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('GPS plugin न हो तब भी tap वाली screen खुलती है',
      (tester) async {
    await pumpScreen(tester, MeasureKind.area);
    final strings = AppStrings(AppLang.hindi);

    expect(find.text(strings.mapTapTitle), findsOneWidget);
    // अभी बिंदु नहीं हैं — user को यही बताना चाहिए
    expect(find.text(strings.mapNeedThreePoints), findsOneWidget);
    // लोकेशन का पर्दा tap मोड में नहीं आना चाहिए
    expect(find.text(strings.mapPermissionDenied), findsNothing);
  });

  testWidgets('नक्शे पर तीन tap से रकबा बनता है, undo से घटता है',
      (tester) async {
    await pumpScreen(tester, MeasureKind.area);
    final strings = AppStrings(AppLang.hindi);
    final map = find.byType(MapMeasureScreen);
    final box = tester.getRect(map);

    for (final offset in [
      const Offset(-120, -260),
      const Offset(120, -260),
      const Offset(120, -60),
    ]) {
      await tester.tapAt(box.center + offset);
      // नक्शा double-tap (zoom) और single-tap में फ़र्क़ करने के लिए थोड़ा
      // रुकता है — उतना pump किए बिना बिंदु जुड़ता ही नहीं
      await tester.pump(const Duration(milliseconds: 400));
    }

    // तीन बिंदु = रकबा दिखने लगे
    expect(find.text(strings.mapNeedThreePoints), findsNothing);
    expect(find.text('3'), findsOneWidget); // तीसरे बिंदु का नंबर

    // undo — फिर से "3 बिंदु चाहिए"
    await tester.tap(find.byTooltip(strings.mapUndo));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(strings.mapNeedThreePoints), findsOneWidget);
  });

  testWidgets('दूरी वाले मोड में दो बिंदु काफ़ी हैं', (tester) async {
    await pumpScreen(tester, MeasureKind.distance);
    final strings = AppStrings(AppLang.hindi);
    final box = tester.getRect(find.byType(MapMeasureScreen));

    expect(find.text(strings.mapNeedTwoPoints), findsOneWidget);
    await tester.tapAt(box.center + const Offset(-100, -200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(strings.mapNeedTwoPoints), findsOneWidget);
    await tester.tapAt(box.center + const Offset(100, -200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(strings.mapNeedTwoPoints), findsNothing);
    // "2 बिंदु" नतीजे के नीचे भी है और बटन पर भी
    expect(find.textContaining(strings.mapPointCount(2)), findsWidgets);
  });
}
