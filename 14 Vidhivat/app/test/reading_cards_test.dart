import 'dart:convert';
import 'dart:io';
import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/granthalaya_screen.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath_assets.dart';
import 'package:vidhivat/widgets/reading_cards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  // जिन ग्रंथों का अपना चित्र अभी बनना है — तब तक मिलता-जुलता पूजा-चित्र
  // (रुद्राष्टाध्यायी पर रुद्राभिषेक वाला शिवलिंग, → D-156; prompt `docs/24` §१३)।
  // चित्र आ जाए तो यहाँ से हटाओ — यह सूची बढ़नी नहीं चाहिए।
  const chitraBaaki = {'rudri'};

  test('चित्र-बाक़ी वाले ग्रंथ पर दीया नहीं, असली पूजा-चित्र है', () async {
    for (final id in chitraBaaki) {
      final path = PaathAssets.forGranthId(id).assetPath;
      expect(path, isNot(contains('diya')), reason: id);
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('all 22 reading entries have distinct existing image files', () async {
    final p = (await paathBhandar.suchi()).where((e) => e.taiyar);
    final g = [...await granthBhandar.suchi(), GranthSuchiEntry.saptashati]
        .where((e) => !chitraBaaki.contains(e.id));
    final paths = [
      for (final e in p) PaathAssets.forPaathId(e.id).assetPath,
      for (final e in g) PaathAssets.forGranthId(e.id).assetPath
    ];
    expect(paths.length, 22);
    expect(paths.toSet().length, 22);
    final content = <String>{};
    for (final path in paths) {
      expect(path, endsWith('_v2.webp'));
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      content.add(base64Encode(file.readAsBytesSync()));
    }
    expect(content.length, 22,
        reason: 'renamed copies must not pass as new art');
  });

  testWidgets('reading card exposes a screen-reader tap action',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
          theme: VidhivatTheme.dark(),
          home: Scaffold(
              body: ReadingArtworkCard(
                  name: 'श्री हनुमान चालीसा',
                  artwork: PaathAssets.forPaathId('hanuman_chalisa').assetPath,
                  onTap: () => tapped = true))));
      await tester.pumpAndSettle();
      final ink = find.byType(InkWell).first;
      expect(
          tester
              .getSemantics(ink)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue);
      await tester.tap(ink);
      expect(tapped, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  for (final page in ['paath', 'library', 'chapters']) {
    for (final dark in [true, false]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets(
            '$page 320dp ${dark ? 'dark' : 'light'} ${scale}x two columns',
            (tester) async {
          tester.view.physicalSize = const Size(320, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final granth =
              (await granthBhandar.suchi()).firstWhere((g) => g.id == 'gita');
          final screen = switch (page) {
            'paath' => const PaathListScreen(),
            'library' => const GranthalayaScreen(),
            _ => GranthScreen(granth: granth),
          };
          await tester.pumpWidget(MaterialApp(
            theme: dark ? VidhivatTheme.dark() : VidhivatTheme.light(),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!),
            home: screen,
          ));
          await tester.pumpAndSettle();
          final firstGroup =
              (await granthBhandar.kram('gita')).hisse.first.shirshak;
          final gridFinder = find.byKey(ValueKey(page == 'paath'
              ? 'paath_catalog_grid'
              : page == 'library'
                  ? 'granth_catalog_grid'
                  : 'granth_chapters_$firstGroup'));
          await tester.scrollUntilVisible(gridFinder, 150,
              scrollable: find
                  .descendant(
                      of: find.byType(ListView),
                      matching: find.byType(Scrollable))
                  .first);
          await tester.pumpAndSettle();
          final wrap = gridFinder;
          final items = tester.widget<Wrap>(wrap).children;
          expect(items.length, greaterThanOrEqualTo(2));
          final first = find.byWidget(items[0]);
          final second = find.byWidget(items[1]);
          expect(tester.getTopLeft(first).dy, tester.getTopLeft(second).dy);
          expect(tester.getTopLeft(first).dx,
              lessThan(tester.getTopLeft(second).dx));
          if (page != 'chapters') {
            for (final t in tester.widgetList<Text>(
                find.descendant(of: gridFinder, matching: find.byType(Text)))) {
              expect(t.textAlign, TextAlign.center);
              expect(t.data, isNot(contains('पढ़ें')));
              expect(t.data, isNot(contains('ग्रंथ खोलें')));
            }
            final card = find
                .descendant(
                    of: gridFinder, matching: find.byType(ReadingArtworkCard))
                .first;
            final decorations = tester.widgetList<Container>(
                find.descendant(of: card, matching: find.byType(Container)));
            expect(
                decorations.any((c) =>
                    c.decoration is BoxDecoration &&
                    ((c.decoration as BoxDecoration).boxShadow?.any(
                            (s) => s.blurRadius == 34 && s.spreadRadius == 2) ??
                        false)),
                isTrue);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
