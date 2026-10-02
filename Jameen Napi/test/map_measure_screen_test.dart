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

    // बिंदु वहीं रहें जहाँ उंगली रखी थी। फ़ोन पर तीसरा बिंदु लगाते ही नक्शा
    // उछलकर zoom हो जाता था (initialCameraFit हर build पर दोबारा बनता था)।
    expect(tester.getCenter(find.text('1')).dx,
        closeTo(box.center.dx - 120, 2));
    expect(tester.getCenter(find.text('1')).dy,
        // रकबा दिखने पर नीचे का पैनल कुछ pixel बढ़ता है, उतना नक्शा खिसकता है
        closeTo(box.center.dy - 260, 15));

    // तीन बिंदु = रकबा दिखने लगे
    expect(find.text(strings.mapNeedThreePoints), findsNothing);
    expect(find.text('3'), findsOneWidget); // तीसरे बिंदु का नंबर

    // undo — फिर से "3 बिंदु चाहिए"
    await tester.tap(find.byTooltip(strings.mapUndo));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(strings.mapNeedThreePoints), findsOneWidget);
  });

  testWidgets('बिंदु खींचने पर बिंदु सरकता है, नक्शा नहीं', (tester) async {
    // फ़ोन पर उल्टा होता था: बिंदु अपनी जगह रहता और पूरा नक्शा खिसक जाता।
    await pumpScreen(tester, MeasureKind.area);
    final box = tester.getRect(find.byType(MapMeasureScreen));
    for (final offset in [
      const Offset(-120, -260),
      const Offset(120, -260),
      const Offset(120, -60),
    ]) {
      await tester.tapAt(box.center + offset);
      await tester.pump(const Duration(milliseconds: 400));
    }
    final firstBefore = tester.getCenter(find.text('1'));
    final thirdBefore = tester.getCenter(find.text('3'));

    final gesture = await tester.startGesture(thirdBefore);
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(8, 12));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 800));

    final thirdAfter = tester.getCenter(find.text('3'));
    expect(thirdAfter.dx, closeTo(thirdBefore.dx + 80, 3));
    expect(thirdAfter.dy, closeTo(thirdBefore.dy + 120, 3));
    // नक्शा नहीं हिला — पहला बिंदु वहीं है
    expect(tester.getCenter(find.text('1')).dx, closeTo(firstBefore.dx, 1));
    expect(tester.getCenter(find.text('1')).dy, closeTo(firstBefore.dy, 1));
    // बिंदु छूने से चौथा बिंदु नहीं बना
    expect(find.text('4'), findsNothing);
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
