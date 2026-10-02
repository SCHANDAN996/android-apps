import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/aaj_screen.dart';
import 'package:vidhivat/screens/calendar_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/tyohar_saal.dart';

/// "आज" और कैलेंडर में संक्रांति वाली पूजा।
///
/// 17 सितम्बर 2026 — विश्वकर्मा पूजा के दिन वह होम पर थी, पर "आज" पन्ने
/// और कैलेंडर में नहीं, क्योंकि दोनों सिर्फ़ इंजन के तिथि वाले त्योहार
/// पढ़ते थे।
void main() {
  group('tyoharSaalBhar', () {
    test('2026 में विश्वकर्मा पूजा 17 सितम्बर को, इंजन के सब त्योहारों के साथ',
        () {
      final sab = tyoharSaalBhar(2026, Place.delhi);
      final engine = festivalsInYear(2026, Place.delhi);

      final vishwakarma =
          sab.where((f) => f.rule.name == 'विश्वकर्मा पूजा').toList();
      expect(vishwakarma, hasLength(1));
      expect(vishwakarma.single.date, DateTime(2026, 9, 17));
      expect(vishwakarma.single.ambiguous, isFalse);
      expect(vishwakarma.single.explanation, contains('कन्या संक्रांति'));
      expect(vishwakarma.single.explanation.split('\n').last,
          startsWith('दृक् गणित'),
          reason: 'कैलेंडर आख़िरी लाइन को गणित की पद्धति मानता है');

      expect(sab, hasLength(engine.length + 2));
      for (var i = 1; i < sab.length; i++) {
        expect(sab[i].date.isBefore(sab[i - 1].date), isFalse,
            reason: 'तारीख़ के क्रम में');
      }
    });

    test('2024 में शाम की संक्रांति — दिन 16 सितम्बर ही', () {
      final f = sankrantiTyohar(2024, Place.delhi)
          .singleWhere((f) => f.rule.name == 'विश्वकर्मा पूजा');
      expect(f.date, DateTime(2024, 9, 16));
      expect(f.ambiguous, isFalse);
    });

    test('मकर संक्रांति: 2026 दिन का प्रवेश, 2027 रात का प्रवेश', () {
      final m2026 = sankrantiTyohar(2026, Place.delhi)
          .singleWhere((f) => f.rule.name == 'मकर संक्रांति');
      expect(m2026.date, DateTime(2026, 1, 14));

      final m2027 = sankrantiTyohar(2027, Place.delhi)
          .singleWhere((f) => f.rule.name == 'मकर संक्रांति');
      expect(m2027.date, DateTime(2027, 1, 15));
      expect(m2027.explanation, contains('पुण्यकाल अगले दिन सूर्योदय से'));
    });
  });

  group('पल आधी रात के पास — दो तारीख़ें', () {
    test('आधी रात के ठीक बाद हो तो पिछला दिन भी दावेदार', () {
      expect(sankrantiDoosraDin(DateTime(2030, 9, 17, 0, 3)),
          DateTime(2030, 9, 16));
    });

    test('आधी रात के ठीक पहले हो तो अगला दिन भी दावेदार', () {
      expect(sankrantiDoosraDin(DateTime(2030, 9, 16, 23, 57)),
          DateTime(2030, 9, 17));
    });

    test('दिन में हो तो दिन पक्का', () {
      expect(sankrantiDoosraDin(DateTime(2026, 9, 17, 7, 58)), isNull);
      expect(sankrantiDoosraDin(DateTime(2025, 9, 17, 1, 55)), isNull);
    });
  });

  group('पन्नों पर', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
    });

    Widget app(Widget home) => ListenableBuilder(
          listenable: settings,
          builder: (context, _) =>
              MaterialApp(theme: VidhivatTheme.dark(), home: home),
        );

    testWidgets('"आज" पन्ना 17 सितम्बर 2026 को विश्वकर्मा पूजा दिखाता है',
        (tester) async {
      tester.view.physicalSize = const Size(393 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester
          .pumpWidget(app(AajScreen(initialDay: DateTime(2026, 9, 17))));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('विश्वकर्मा पूजा'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('आज के त्योहार / व्रत'), findsOneWidget);
      expect(find.text('विश्वकर्मा पूजा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('कैलेंडर में 17 सितम्बर 2026 पर विश्वकर्मा पूजा',
        (tester) async {
      tester.view.physicalSize = const Size(393 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(app(const CalendarScreen()));
      await tester.pump();

      final now = DateTime.now();
      final monthOffset = (2026 - now.year) * 12 + 9 - now.month;
      final shift = monthOffset >= 0
          ? find.byKey(const Key('calendar_next_month'))
          : find.byKey(const Key('calendar_previous_month'));
      for (var i = 0; i < monthOffset.abs(); i++) {
        await tester.tap(shift);
        await tester.pump();
      }

      final din = find.byKey(const Key('calendar_day_2026_9_17'));
      expect(din, findsOneWidget);
      expect(tester.getSemantics(din).label, contains('विश्वकर्मा पूजा'));
      expect(tester.takeException(), isNull);
    });
  });
}
