import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/home_dashboard_screen.dart';
import 'package:vidhivat/screens/kundali_profiles_screen.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/granthalaya_screen.dart';
import 'package:vidhivat/screens/vrat_panna_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/devotional_assets.dart';
import 'package:vidhivat/vidhi/paath_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const previewDir = String.fromEnvironment('HOME_PREVIEW_DIR');
  final today = DateTime(2026, 10, 24);
  final boundaryKey = GlobalKey();

  String assetPath(Image image) {
    final provider = image.image;
    return ((provider is ResizeImage ? provider.imageProvider : provider)
            as AssetImage)
        .assetName;
  }

  setUpAll(() async {
    if (previewDir.isNotEmpty) {
      // Local preview font only; no font asset or system path enters the app.
      final font = File('C:/Windows/Fonts/Nirmala.ttf');
      final bytes = ByteData.sublistView(await font.readAsBytes());
      for (final family in [
        'Ahem',
        'Roboto',
        'Noto Sans Devanagari',
        'Noto Serif Devanagari'
      ]) {
        await (FontLoader(family)..addFont(Future.value(bytes))).load();
      }
      final icons = File(
          'C:/src/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
      await (FontLoader('MaterialIcons')
            ..addFont(
                Future.value(ByteData.sublistView(await icons.readAsBytes()))))
          .load();
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Future<void> open(WidgetTester tester,
      {double width = 360,
      double height = 800,
      double scale = 1,
      bool dark = true,
      DateTime? date,
      DateTime Function()? now}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var theme = dark ? VidhivatTheme.dark() : VidhivatTheme.light();
    if (previewDir.isNotEmpty) {
      theme = theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Roboto'));
    }
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!),
      home: RepaintBoundary(
          key: boundaryKey,
          child: HomeDashboardScreen(
              onOpenPujaLibrary: () {},
              aaj: now == null ? date ?? today : null,
              now: now)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('home refreshes festival day counts while crossing midnight',
      (tester) async {
    var now = DateTime(2026, 10, 25, 23, 59, 58);
    await open(tester, height: 3200, now: () => now);
    expect(find.text('4 दिन बाद'), findsWidgets);
    now = DateTime(2026, 10, 26, 0, 0, 2);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('4 दिन बाद'), findsNothing);
    expect(find.text('3 दिन बाद'), findsWidgets);
    expect(find.text(settings.panchangFor(now).tithi.name), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home refreshes the date after resuming on a new day',
      (tester) async {
    var now = DateTime(2026, 10, 25, 23, 0);
    await open(tester, height: 3200, now: () => now);
    expect(find.text('4 दिन बाद'), findsWidgets);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 10, 26, 7);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('4 दिन बाद'), findsNothing);
    expect(find.text('3 दिन बाद'), findsWidgets);
    expect(find.text(settings.panchangFor(now).tithi.name), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'popular pujas follow upcoming festivals instead of past seasonal cards',
      (tester) async {
    await open(tester, height: 3200, date: DateTime(2026, 10, 25));
    final grid = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_PopularPujaGrid');
    final images = tester.widgetList<Image>(
        find.descendant(of: grid, matching: find.byType(Image)));
    expect(images.map(assetPath).toList(), [
      for (final id in [
        'karwa_chauth',
        'dhanteras',
        'lakshmi_poojan',
        'govardhan_annakut'
      ])
        DevotionalAssets.forVidhiId(id).assetPath,
    ]);
    expect(find.descendant(of: grid, matching: find.text('शारदीय नवरात्रि')),
        findsNothing);
    expect(
        find.descendant(of: grid, matching: find.text('पितृ पक्ष — श्राद्ध')),
        findsNothing);
  });

  testWidgets('popular pujas remove Diwali cards after the festival window',
      (tester) async {
    await open(tester, height: 3200, date: DateTime(2026, 11, 26));
    final grid = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_PopularPujaGrid');
    final paths = tester
        .widgetList<Image>(
            find.descendant(of: grid, matching: find.byType(Image)))
        .map(assetPath)
        .toList();
    expect(paths, hasLength(4));
    expect(paths.toSet(), hasLength(4));
    for (final id in [
      'dhanteras',
      'lakshmi_poojan',
      'govardhan_annakut',
      'bhai_dooj_pooja'
    ]) {
      expect(paths, isNot(contains(DevotionalAssets.forVidhiId(id).assetPath)));
    }
  });

  Future<void> capture(WidgetTester tester, String name) async {
    if (previewDir.isEmpty) return;
    await tester.runAsync(() async {
      await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
          (img) => precacheImage(
              img.image, tester.element(find.byKey(boundaryKey)))));
    });
    await tester.pumpAndSettle();
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      await Directory(previewDir).create(recursive: true);
      await File('$previewDir/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  }

  testWidgets('requested order and image-backed 2 by 2 paath cards',
      (tester) async {
    await open(tester, height: 3200);
    expect(find.text('जय श्री गणेश 🙏'), findsNothing);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    final titles = [
      'आने वाली पूजा',
      'लोकप्रिय पूजा',
      'तुरंत खोलें',
      'आज का पंचांग',
      'चालीसा और आरती',
      'ग्रंथालय'
    ];
    final positions =
        titles.map((t) => tester.getTopLeft(find.text(t)).dy).toList();
    for (var i = 1; i < positions.length; i++) {
      expect(positions[i], greaterThan(positions[i - 1]));
    }
    final grid = find.byKey(const Key('home_paath_grid'));
    final cards = tester.widget<Wrap>(grid).children;
    expect(cards.length, 4);
    final boxes = find.descendant(of: grid, matching: find.byType(InkWell));
    final offsets = [
      for (var i = 0; i < 4; i++) tester.getTopLeft(boxes.at(i))
    ];
    expect(offsets[0].dy, offsets[1].dy);
    expect(offsets[0].dx, offsets[2].dx);
    expect(offsets[2].dy, offsets[3].dy);
    expect(offsets[2].dy, greaterThan(offsets[0].dy));
    final images = tester
        .widgetList<Image>(
            find.descendant(of: grid, matching: find.byType(Image)))
        .toList();
    expect(images.length, 4);
    final entries =
        (await paathBhandar.suchi()).where((e) => e.taiyar).take(4).toList();
    for (var i = 0; i < 4; i++) {
      expect(assetPath(images[i]),
          PaathAssets.forPaathId(entries[i].id).assetPath);
    }
    expect(tester.takeException(), isNull);
    await capture(tester, 'home-dark-full');
  });

  testWidgets(
      'vrat switch uses engine date and opens matching vrat; carousel resets',
      (tester) async {
    await open(tester);
    await tester.drag(
        find.byKey(const Key('puja_carousel')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('आने वाले व्रत'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<PageView>(find.byKey(const Key('puja_carousel')))
            .controller!
            .page,
        0);
    final first = aaneWaleVrat(
            place: settings.place,
            masaSystem: settings.masaSystem,
            aaj: today,
            dinAage: 60,
            kitne: 6)
        .first;
    expect(find.text(first.niyam.naam), findsWidgets);
    expect(find.text(first.tithiNaam), findsWidgets);
    await capture(tester, 'home-vrat-top');
    await tester.tap(find.text('व्रत देखें').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.widget<VratPannaScreen>(find.byType(VratPannaScreen)).id,
        first.niyam.id);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('आने वाली पूजा'));
    await tester.pumpAndSettle();
    expect(find.text('व्रत देखें').hitTestable(), findsNothing);
    expect(
        tester
            .widget<PageView>(find.byKey(const Key('puja_carousel')))
            .controller!
            .page,
        0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved puja remains available while viewing upcoming vrat',
      (tester) async {
    final nitya = await vidhiBhandar.vidhi('nitya_pooja');
    await settings.recordLastReachedStep(
        pujaId: nitya.id, stepIndex: 2, totalSteps: nitya.charan.length);
    await open(tester);
    await tester.tap(find.text('आने वाले व्रत'));
    await tester.pumpAndSettle();
    expect(find.text('पूजा जारी रखें'), findsOneWidget);
    expect(find.textContaining('चरण 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick actions remove puja and put janm kundali fourth',
      (tester) async {
    await open(tester, height: 3200);
    expect(find.text('पूजा विधि'), findsNothing);
    final labels = ['व्रत', 'संकल्प', 'चौघड़िया', 'जन्म कुंडली'];
    final pos = labels
        .map((t) => tester.getTopLeft(find
            .ancestor(of: find.text(t), matching: find.byType(InkWell))
            .first))
        .toList();
    expect(pos[0].dy, pos[1].dy);
    expect(pos[2].dy, pos[3].dy);
    expect(pos[2].dy, greaterThan(pos[0].dy));
    expect(pos[3].dx, greaterThan(pos[2].dx));
    await tester.tap(find.text('जन्म कुंडली'));
    await tester.pumpAndSettle();
    expect(find.byType(KundaliProfilesScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('four granth image cards are 2 by 2 and open real granth',
      (tester) async {
    await open(tester, height: 3200);
    final grid = find.byKey(const Key('home_granth_grid'));
    expect(tester.widget<Wrap>(grid).children.length, 4);
    final taps = find.descendant(of: grid, matching: find.byType(InkWell));
    final pos = [for (var i = 0; i < 4; i++) tester.getTopLeft(taps.at(i))];
    expect(pos[0].dy, pos[1].dy);
    expect(pos[2].dy, pos[3].dy);
    expect(pos[2].dy, greaterThan(pos[0].dy));
    expect(pos[0].dx, pos[2].dx);
    final ids = ['gita', 'sundarkand', 'vishnusahasranama', 'saptashati'];
    final imgs = tester
        .widgetList<Image>(
            find.descendant(of: grid, matching: find.byType(Image)))
        .toList();
    expect(imgs.length, 4);
    for (var i = 0; i < 4; i++) {
      expect(assetPath(imgs[i]), PaathAssets.forGranthId(ids[i]).assetPath);
    }
    await tester.tap(taps.first);
    await tester.pumpAndSettle();
    expect(tester.widget<GranthScreen>(find.byType(GranthScreen)).granth.id,
        'gita');
    expect(tester.takeException(), isNull);
  });

  testWidgets('full granthalaya footer opens library', (tester) async {
    await open(tester, height: 3200);
    await tester.tap(find.text('पूरा ग्रंथालय देखें'));
    await tester.pumpAndSettle();
    expect(find.byType(GranthalayaScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [true, false]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          '320dp ${dark ? 'dark' : 'light'} ${scale}x all sections and toggles',
          (tester) async {
        await open(tester, width: 320, scale: scale, dark: dark);
        if (scale == 1) {
          await capture(tester, 'home-${dark ? 'dark' : 'light'}-top');
        }
        await tester.tap(find.text('आने वाले व्रत'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
            find.byKey(const Key('home_paath_grid')), 250,
            scrollable: find
                .descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable))
                .first);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('home_paath_grid')), findsOneWidget);
        await tester.scrollUntilVisible(
            find.byKey(const Key('home_granth_grid')), 250,
            scrollable: find
                .descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable))
                .first);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('home_granth_grid')), findsOneWidget);
        await tester.scrollUntilVisible(find.text('पूरा ग्रंथालय देखें'), 250,
            scrollable: find
                .descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable))
                .first);
        await tester.pumpAndSettle();
        expect(find.text('पूरा ग्रंथालय देखें').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
