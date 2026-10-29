import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/calendar_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/tyohar_saal.dart';

void main() {
  final previewDirectory = Platform.environment['VIDHIVAT_QA_SCREENSHOTS'];
  setUpAll(() async {
    if (previewDirectory == null) return;
    final bytes = ByteData.sublistView(
        await File('C:/Windows/Fonts/Nirmala.ttf').readAsBytes());
    for (final family in [
      'PreviewHindi',
      'Ahem',
      'Roboto',
      'Noto Sans Devanagari',
      'Noto Serif Devanagari'
    ]) {
      await (FontLoader(family)..addFont(Future.value(bytes))).load();
    }
    final icons = ByteData.sublistView(await File(
            'C:/src/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
        .readAsBytes());
    await (FontLoader('MaterialIcons')..addFont(Future.value(icons))).load();
  });

  Future<void> capture(WidgetTester tester, String name) async {
    if (previewDirectory == null) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('calendar_preview')));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(previewDirectory).create(recursive: true);
      await File('$previewDirectory/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Future<void> mount(WidgetTester tester,
      {bool dark = true, double scale = 1}) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final base = dark ? VidhivatTheme.dark() : VidhivatTheme.light();
    await tester.pumpWidget(MaterialApp(
      theme: previewDirectory == null
          ? base
          : base.copyWith(
              textTheme: base.textTheme.apply(fontFamily: 'PreviewHindi'),
              primaryTextTheme:
                  base.primaryTextTheme.apply(fontFamily: 'PreviewHindi'),
            ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const RepaintBoundary(
          key: Key('calendar_preview'), child: CalendarScreen()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> festivals(WidgetTester tester) async {
    await tester.tap(find.text('त्योहार'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('calendar_festival_search')),
      160,
      scrollable: find
          .byWidgetPredicate((widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down)
          .last,
    );
  }

  Future<void> countIs(WidgetTester tester, int expected) async {
    final count = find.byKey(const Key('calendar_result_count'));
    await tester.scrollUntilVisible(count, 160,
        scrollable: find
            .byWidgetPredicate((widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down)
            .last);
    expect(tester.widget<Text>(count).data, '$expected दिन मिले');
    expect(tester.takeException(), isNull);
  }

  testWidgets('खोज, category और clear से वास्तविक त्योहारों की गिनती बदलती है',
      (tester) async {
    await mount(tester);
    await festivals(tester);
    final all = tyoharSaalBhar(DateTime.now().year, settings.place);
    final search = find.byKey(const Key('calendar_festival_search'));
    await tester.enterText(search, 'एकादशी');
    await tester.pumpAndSettle();
    await countIs(
        tester, all.where((f) => f.rule.name.contains('एकादशी')).length);
    await tester.ensureVisible(find.text('पर्व'));
    await tester.tap(find.text('पर्व'));
    await tester.pumpAndSettle();
    await countIs(tester, 0);
    await tester.ensureVisible(find.byTooltip('खोज साफ़ करें'));
    await tester.tap(find.byTooltip('खोज साफ़ करें'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
  });

  testWidgets('आने वाले दिन past dates हटाते हैं और alternative dates रखते हैं',
      (tester) async {
    await mount(tester);
    await festivals(tester);
    await tester.tap(find.text('केवल आने वाले दिन'));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final expected = tyoharSaalBhar(now.year, settings.place)
        .where((f) =>
            !f.date.isBefore(start) ||
            (f.ambiguous &&
                f.otherCandidate != null &&
                !f.otherCandidate!.isBefore(start)))
        .length;
    await countIs(tester, expected);
  });

  testWidgets('सीधे तारीख़ पर जाना दिसंबर के दिन और महीने को साथ चुनता है',
      (tester) async {
    await mount(tester);
    await tester.tap(find.byKey(const Key('calendar_choose_date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '12/31/2026');
    await tester.tap(find.text('देखें'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar_day_2026_12_31')), findsOneWidget);
    expect(find.text('दिसम्बर 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('320dp और ${scale}x अक्षर: grid/search dark=$dark',
          (tester) async {
        await mount(tester, dark: dark, scale: scale);
        expect(tester.takeException(), isNull);
        await capture(tester, 'month-dark-$dark-scale-$scale');
        await festivals(tester);
        await tester.pumpAndSettle();
        await capture(tester, 'festivals-dark-$dark-scale-$scale');
        await tester.enterText(
            find.byKey(const Key('calendar_festival_search')), 'zzzz');
        await tester.pumpAndSettle();
        await countIs(tester, 0);
      });
    }
  }
}
