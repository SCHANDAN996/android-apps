import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

void main() {
  for (final bottomInset in [24.0, 48.0]) {
    testWidgets('Android system bars ($bottomInset dp): tabs stay visible',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();

      const pixelRatio = 3.0;
      const screenHeight = 800.0;
      tester.view.devicePixelRatio = pixelRatio;
      tester.view.physicalSize = const Size(1080, screenHeight * pixelRatio);
      final bars = FakeViewPadding(
        top: 24 * pixelRatio,
        bottom: bottomInset * pixelRatio,
      );
      tester.view.padding = bars;
      tester.view.viewPadding = bars;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);

      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: const HomeShell(),
      ));
      await tester.pump(const Duration(seconds: 2));

      Future<void> checkTabs() async {
        expect(tester.takeException(), isNull);
        final rect = tester.getRect(find.byType(NavigationBar));
        expect(rect.bottom, lessThanOrEqualTo(screenHeight - bottomInset + 1));
        expect(rect.top, greaterThan(24));
      }

      await checkTabs();
      for (final tab in ['पूजा', 'कैलेंडर', 'अधिक']) {
        await tester.tap(find.text(tab).last);
        await tester.pump(const Duration(seconds: 2));
        await checkTabs();
      }
    });
  }
}
