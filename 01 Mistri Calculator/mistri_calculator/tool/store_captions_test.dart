// Renders the headline strip for each Play Store screenshot.
//
// Not part of the test suite — run it by hand:
//
//   flutter test tool/store_captions_test.dart
//
// It writes build/store/caption_<name>.png (1080 px wide). Flutter draws the
// text so that Devanagari conjuncts are shaped properly; tool/store_shots.py
// then puts each strip above its screenshot.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const captions = {
  '01_home': 'घर बनाने का पूरा हिसाब',
  '02_brick': 'कितनी ईंट, सीमेंट, बालू लगेगी',
  '03_concrete': 'छत की ढलाई का सामान और खर्च',
  '04_project': 'पूरे घर का हिसाब एक जगह',
  '04b_project_bill': 'कुल सामान, मज़दूरी और बिल',
  '05_stairs': 'सीढ़ी के पायदान और कंक्रीट',
  '06_paint': 'पेंट, प्राइमर और पुट्टी',
  '07_rates': 'अपने इलाके का रेट डालें',
  '08_dark': 'रात में आँखों को आराम',
};

const double width = 1080;
const double height = 300;

void main() {
  testWidgets('render caption strips', (tester) async {
    // A Devanagari font from this PC; the test engine has none of its own.
    final font = File(r'C:\Windows\Fonts\NirmalaB.ttf').readAsBytesSync();
    await (FontLoader('Caption')
          ..addFont(Future.value(ByteData.view(font.buffer))))
        .load();

    tester.view.physicalSize = const Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final out = Directory('build/store')..createSync(recursive: true);
    final key = GlobalKey();

    for (final entry in captions.entries) {
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.ltr,
            // Transparent: the gradient behind it is painted by the script.
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Caption',
                    fontSize: 68,
                    height: 1.25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File(
          '${out.path}/caption_${entry.key}.png',
        ).writeAsBytesSync(data!.buffer.asUint8List());
      });
    }
  });
}
