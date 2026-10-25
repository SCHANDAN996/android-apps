import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/kundali_profiles_screen.dart';
import 'package:vidhivat/screens/kundali_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/state/kundali_profiles.dart';
import 'package:vidhivat/theme.dart';

void main() {
  final profile = KundaliProfile(
    id: 'audit',
    naam: 'कुंडली परीक्षण',
    janm: DateTime(1990, 5, 15, 14, 30),
    sthanNaam: 'परीक्षण स्थल',
    latitude: 25.5941,
    longitude: 85.1376,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget host(Widget child, {bool light = false}) => MaterialApp(
        theme: light ? VidhivatTheme.light() : VidhivatTheme.dark(),
        home: child,
      );

  testWidgets('Hindi coordinates save as numbers with birth details intact',
      (tester) async {
    KundaliProfile? saved;
    await tester.pumpWidget(host(Builder(builder: (context) {
      return Scaffold(
        body: TextButton(
          onPressed: () async {
            saved = await Navigator.of(context).push<KundaliProfile>(
              MaterialPageRoute(builder: (_) => KundaliForm(existing: profile)),
            );
          },
          child: const Text('खोलें'),
        ),
      );
    })));
    await tester.tap(find.text('खोलें'));
    await tester.pumpAndSettle();
    for (final (label, value) in [
      ('अक्षांश (उत्तर)', '२५.५९'),
      ('देशांतर (पूर्व)', '८५.१४'),
    ]) {
      final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('सहेजें'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('सहेजें'));
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    expect(saved!.latitude, 25.59);
    expect(saved!.longitude, 85.14);
    expect(saved!.id, profile.id);
    expect(saved!.janm, profile.janm);
    expect(find.byType(KundaliForm), findsNothing);
  });

  for (final (label, value, message) in [
    ('नाम *', '   ', 'नाम लिखिए।'),
    ('जगह का नाम *', '   ', 'जगह का नाम लिखिए।'),
    ('अक्षांश (उत्तर)', '5.99', 'अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।'),
    ('अक्षांश (उत्तर)', '37.51', 'अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।'),
    (
      'अक्षांश (उत्तर)',
      '-25.59',
      'अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।'
    ),
    ('अक्षांश (उत्तर)', 'NaN', 'अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।'),
    (
      'देशांतर (पूर्व)',
      '-85.14',
      'देशांतर 68 और 97.5 के बीच का अंक होना चाहिए।'
    ),
    (
      'देशांतर (पूर्व)',
      'Infinity',
      'देशांतर 68 और 97.5 के बीच का अंक होना चाहिए।'
    ),
    (
      'अक्षांश (उत्तर)',
      '25..59',
      'अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।'
    ),
    (
      'देशांतर (पूर्व)',
      '67.99',
      'देशांतर 68 और 97.5 के बीच का अंक होना चाहिए।'
    ),
    (
      'देशांतर (पूर्व)',
      '97.51',
      'देशांतर 68 और 97.5 के बीच का अंक होना चाहिए।'
    ),
  ]) {
    testWidgets('invalid $label=$value is blocked', (tester) async {
      await tester.pumpWidget(host(KundaliForm(existing: profile)));
      await tester.pumpAndSettle();
      final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final save = find.text('सहेजें');
      await tester.scrollUntilVisible(save, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(save);
      await tester.pump();
      expect(find.text(message), findsOneWidget);
      expect(find.byType(KundaliForm), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final light in [false, true]) {
    for (final size in [const Size(320, 640), const Size(640, 320)]) {
      testWidgets('all tabs ${light ? "light" : "dark"} $size 2x',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(host(
          KundaliScreen(profile: profile, abhi: DateTime.utc(2026, 10, 24)),
          light: light,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'कुंडली');
        for (final tab in ['ग्रह', 'दशा', 'पंचांग', 'कुंडली']) {
          await tester.tap(find.text(tab).first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: tab);
        }
      });
    }
  }
}
