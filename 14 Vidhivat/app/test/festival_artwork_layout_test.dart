import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vrat_panna_screen.dart';
import 'package:vidhivat/screens/vrat_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/vrat_artwork.dart';

const ids = [
  'narak_chaturdashi',
  'gopashtami',
  'akshaya_navami',
  'holika_dahan',
  'akshaya_tritiya'
];

void main() {
  setUpAll(() async {
    if (Platform.environment['VIDHIVAT_QA_SCREENSHOTS'] == null) return;
    final font = File('C:/Windows/Fonts/Nirmala.ttf');
    final bytes = ByteData.sublistView(await font.readAsBytes());
    for (final family in [
      'PreviewHindi',
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
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Future<void> mount(WidgetTester tester, Widget screen,
      {required double width,
      required bool dark,
      required double scale}) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final base = dark ? VidhivatTheme.dark() : VidhivatTheme.light();
    final preview = Platform.environment['VIDHIVAT_QA_SCREENSHOTS'] != null;
    await tester.pumpWidget(MaterialApp(
      theme: preview
          ? base.copyWith(
              textTheme: base.textTheme.apply(fontFamily: 'PreviewHindi'),
              primaryTextTheme:
                  base.primaryTextTheme.apply(fontFamily: 'PreviewHindi'))
          : base,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!),
      home: RepaintBoundary(
          key: const ValueKey('artwork-preview'), child: screen),
    ));
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 360.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('व्रत कार्ड $width/$scale dark=$dark नाम और चित्र पूरे',
            (tester) async {
          await mount(tester, const VratScreen(),
              width: width, dark: dark, scale: scale);
          final card =
              find.byKey(const ValueKey('vrat-card-narak_chaturdashi'));
          await tester.scrollUntilVisible(card, 400,
              maxScrolls: 80, scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          final labels = tester.widgetList<Text>(
              find.descendant(of: card, matching: find.byType(Text)));
          expect(labels.any((t) => t.data == 'नरक चतुर्दशी'), isTrue);
          expect(
              labels.every((t) => t.overflow != TextOverflow.ellipsis), isTrue);
          final image = tester.widget<Image>(
              find.descendant(of: card, matching: find.byType(Image)));
          expect(image.fit, BoxFit.contain);
          final size = tester
              .getSize(find.descendant(of: card, matching: find.byType(Image)));
          expect(size.width, closeTo(size.height, .1));
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
              find.descendant(of: card, matching: find.text('व्रत देखें')));
          await tester.tap(
              find.descendant(of: card, matching: find.text('व्रत देखें')));
          await tester.pumpAndSettle();
          expect(find.byType(VratPannaScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final id in ids) {
    testWidgets('$id नया चित्र hero में पूरा दिखता है', (tester) async {
      await mount(tester, VratPannaScreen(id: id),
          width: 360, dark: true, scale: 1);
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(images.any((image) {
        final provider = image.image;
        return provider is ResizeImage &&
            provider.imageProvider is AssetImage &&
            (provider.imageProvider as AssetImage).assetName ==
                VratArtwork.forVratId(id).assetPath;
      }), isTrue);
      expect(tester.takeException(), isNull);
      final out = Platform.environment['VIDHIVAT_QA_SCREENSHOTS'];
      if (out != null) {
        await tester.runAsync(() async {
          await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
              (image) => precacheImage(
                  image.image,
                  tester.element(
                      find.byKey(const ValueKey('artwork-preview'))))));
        });
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('artwork-preview')));
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory(out).createSync(recursive: true);
          File('$out/$id.png').writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}
