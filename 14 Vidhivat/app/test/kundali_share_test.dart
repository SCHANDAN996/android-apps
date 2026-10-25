// Sharing is intercepted at the plugin boundary; no image is sent.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// The platform interface comes with the application's share_plus plugin.
// ignore: depend_on_referenced_packages
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/kundali_screen.dart';
import 'package:vidhivat/screens/kundali_profiles_screen.dart';
import 'package:vidhivat/state/kundali_profiles.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

class AuditShare extends SharePlatform {
  int calls = 0;
  @override
  Future<ShareResult> share(ShareParams params) async {
    calls++;
    return const ShareResult('audit-intercepted', ShareResultStatus.success);
  }
}

void main() {
  final fake = AuditShare();
  SharePlatform.instance = fake;
  testWidgets('Hindi coordinates normalize and negative signs remain visible',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    await tester.pumpWidget(MaterialApp(
      theme: VidhivatTheme.dark(),
      home: KundaliForm(
          existing: KundaliProfile(
        id: 'input',
        naam: 'परीक्षण',
        janm: DateTime(1990, 5, 15, 14, 30),
        sthanNaam: 'परीक्षण स्थल',
        latitude: 25.5941,
        longitude: 85.1376,
      )),
    ));
    await tester.pumpAndSettle();
    final field = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'अक्षांश (उत्तर)');
    await tester.ensureVisible(field);
    await tester.enterText(field, '-25.59');
    final signed = tester.widget<TextField>(field).controller!.text;
    await tester.enterText(field, '२५.५९');
    final hindi = tester.widget<TextField>(field).controller!.text;
    expect(signed, '-25.59');
    expect(hindi, '25.59');
  });
  for (final tab in ['कुंडली', 'ग्रह', 'दशा', 'पंचांग']) {
    testWidgets('share is available only on chart, returning from $tab',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
      fake.calls = 0;
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: KundaliScreen(
            profile: KundaliProfile(
          id: 'probe',
          naam: 'परीक्षण',
          janm: DateTime(1990, 5, 15, 14, 30),
          sthanNaam: 'पटना',
          latitude: 25.5941,
          longitude: 85.1376,
        )),
      ));
      await tester.pumpAndSettle();
      if (tab != 'कुंडली') {
        if (tab == 'ग्रह') {
          await tester.drag(find.byType(TabBarView), const Offset(-600, 0));
        } else {
          await tester.tap(find.text(tab).first);
        }
        await tester.pumpAndSettle();
        expect(find.byTooltip('कुंडली का चित्र भेजें'), findsNothing);
        expect(fake.calls, 0);
        await tester.tap(find.text('कुंडली').first);
        await tester.pumpAndSettle();
      }
      expect(find.byTooltip('कुंडली का चित्र भेजें'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('कुंडली का चित्र भेजें'));
        for (var i = 0; i < 30 && fake.calls == 0; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      expect(fake.calls, 1,
          reason: 'Visible share button must produce a share image');
    });
  }
}
