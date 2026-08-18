// Play Store listing assets generator.
// Chalane ke liye: flutter test tool/generate_store_assets.dart
//
// Banata hai (play_store_assets/ me):
//   - icon-512.png                 (Play Console app icon, 512x512)
//   - feature-graphic-1024x500.png (Play Console feature graphic)
//   - screenshots/01..06 .png      (1080x2160 phone screenshots, asli app render)
//
// Hindi text ke liye Windows ka Nirmala UI font 'Roboto' family ke naam se
// load hota hai (flutter test me warna sab text khali boxes dikhta hai).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jameen_napi/main.dart';
import 'package:jameen_napi/screens/converter_screen.dart';
import 'package:jameen_napi/screens/length_screen.dart';

const String _outDir = 'play_store_assets';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Nirmala UI (Devanagari + Latin + sabhi Indic scripts) ko default
    // 'Roboto' family ke naam se register karo.
    await _loadFont('Roboto', [
      'C:/Windows/Fonts/Nirmala.ttf',
      'C:/Windows/Fonts/NirmalaB.ttf',
    ]);
    await _loadFont('MaterialIcons', [
      'C:/src/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    ]);
  });

  test('generate icon 512 and feature graphic', () async {
    await _writePng(_drawIcon512(), 512, 512, '$_outDir/icon-512.png');
    await _writePng(
        _drawFeatureGraphic(), 1024, 500, '$_outDir/feature-graphic-1024x500.png');
  });

  testWidgets('generate phone screenshots', (tester) async {
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;

    try {
      // Converter screenshot me Bihar chuna hua dikhe.
      // (Ye file flutter test se hi chalti hai, isliye ye call theek hai.)
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(
          {'converter_last_state': 'बिहार / झारखंड'});

      await _snap(tester, const KisanCalculatorApp(isOnboardingCompleted: true),
          '$_outDir/screenshots/01-home.png');

      await _snap(tester, _wrap(const ConverterScreen()),
          '$_outDir/screenshots/02-bhumi-converter.png');

      await _snap(tester, _wrap(const LengthScreen()),
          '$_outDir/screenshots/03-plot-lambai-nap.png');
    } finally {
      debugDisableShadows = true;
    }
  });
}

// ---------------------------------------------------------------- helpers

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Widget _wrap(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: child,
    );

Future<void> _snap(WidgetTester tester, Widget app, String outPath,
    {Future<void> Function(WidgetTester)? interact}) async {
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  await tester.pumpAndSettle();
  if (interact != null) {
    await interact(tester);
    await tester.pumpAndSettle();
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(outPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<void> _writePng(
    ui.Picture picture, int w, int h, String path) async {
  final image = await picture.toImage(w, h);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

// ------------------------------------------------------------ icon artwork
// tool/generate_icon.dart wali hi drawing (1024 base), yahan reuse ke liye.

void _drawIconArt(Canvas canvas) {
  const size = 1024.0;

  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(size, size),
        [const Color(0xFF43A047), const Color(0xFF1B5E20)],
      ),
  );

  canvas.drawCircle(
      const Offset(830, 190), 90, Paint()..color = const Color(0xFFFFD54F));

  final farField = Path()
    ..moveTo(0, 780)
    ..quadraticBezierTo(256, 720, 512, 770)
    ..quadraticBezierTo(768, 820, 1024, 760)
    ..lineTo(1024, 1024)
    ..lineTo(0, 1024)
    ..close();
  canvas.drawPath(farField, Paint()..color = const Color(0xFF66BB6A));

  final nearField = Path()
    ..moveTo(0, 890)
    ..quadraticBezierTo(300, 840, 600, 885)
    ..quadraticBezierTo(850, 915, 1024, 880)
    ..lineTo(1024, 1024)
    ..lineTo(0, 1024)
    ..close();
  canvas.drawPath(nearField, Paint()..color = const Color(0xFF2E7D32));

  _drawCalculator(canvas, const Offset(512, 520), 400, 490);
}

void _drawCalculator(Canvas canvas, Offset center, double w, double h) {
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: center, width: w, height: h),
    Radius.circular(w * 0.13),
  );

  canvas.drawRRect(
    body.shift(const Offset(0, 14)),
    Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
  );

  canvas.drawRRect(body, Paint()..color = Colors.white);

  final pad = w * 0.09;
  final displayRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(body.left + pad, body.top + pad, w - pad * 2, h * 0.24),
    Radius.circular(w * 0.05),
  );
  canvas.drawRRect(displayRect, Paint()..color = const Color(0xFF1B5E20));

  final digitPaint = Paint()
    ..color = const Color(0xFF81C784)
    ..strokeWidth = h * 0.028
    ..strokeCap = StrokeCap.round;
  final digitY = displayRect.top + displayRect.height * 0.62;
  final digitRight = displayRect.right - w * 0.06;
  canvas.drawLine(Offset(digitRight - w * 0.12, digitY),
      Offset(digitRight, digitY), digitPaint);
  canvas.drawLine(Offset(digitRight - w * 0.32, digitY),
      Offset(digitRight - w * 0.20, digitY), digitPaint);

  final gridPad = pad * 1.5;
  final gridTop = displayRect.bottom + h * 0.10;
  final gridBottom = body.bottom - gridPad;
  final rowGap = (gridBottom - gridTop) / 2;
  final colGap = (w - gridPad * 2) / 2;
  final radius = w * 0.072;

  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      final isAccent = row == 2 && col == 2;
      canvas.drawCircle(
        Offset(body.left + gridPad + colGap * col, gridTop + rowGap * row),
        radius,
        Paint()
          ..color =
              isAccent ? const Color(0xFFFF9800) : const Color(0xFFC8E6C9),
      );
    }
  }
}

ui.Picture _drawIcon512() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(0.5); // 1024 art -> 512 output
  _drawIconArt(canvas);
  return recorder.endRecording();
}

// -------------------------------------------------------- feature graphic

/// Text ek hi line me fit hone tak font chhota karke paint karta hai.
/// Return: painted text ki height (agli line ka y nikalne ke liye).
double _drawText(Canvas canvas, String text, Offset offset,
    {required double fontSize,
    FontWeight weight = FontWeight.normal,
    Color color = Colors.white,
    double maxWidth = 600}) {
  var size = fontSize;
  TextPainter painter;
  while (true) {
    painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: 1.15,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    if (!painter.didExceedMaxLines && painter.width <= maxWidth) break;
    size -= 2;
    if (size < 20) break;
  }
  painter.paint(canvas, offset);
  return painter.height;
}

ui.Picture _drawFeatureGraphic() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const w = 1024.0;
  const h = 500.0;

  // Background gradient
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(w, h),
        [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      ),
  );

  // Decorative halke circles
  final deco = Paint()..color = const Color(0x14FFFFFF);
  canvas.drawCircle(const Offset(950, 60), 160, deco);
  canvas.drawCircle(const Offset(60, 470), 130, deco);

  // Field curve at bottom
  final field = Path()
    ..moveTo(0, 440)
    ..quadraticBezierTo(300, 400, 620, 440)
    ..quadraticBezierTo(850, 468, 1024, 435)
    ..lineTo(1024, 500)
    ..lineTo(0, 500)
    ..close();
  canvas.drawPath(field, Paint()..color = const Color(0x3366BB6A));

  // App icon card (left)
  const double iconSize = 280;
  canvas.save();
  canvas.translate(70, 110);
  final iconRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, iconSize, iconSize),
    const Radius.circular(56),
  );
  canvas.drawRRect(
    iconRRect.shift(const Offset(0, 10)),
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
  );
  canvas.clipRRect(iconRRect);
  canvas.scale(iconSize / 1024);
  _drawIconArt(canvas);
  canvas.restore();

  // Text block (right) — har line ek hi row me auto-fit hoti hai.
  const double textX = 420;
  const double textMaxW = 560;
  double y = 118;
  y += _drawText(canvas, 'किसान कैलकुलेटर', Offset(textX, y),
          fontSize: 72, weight: FontWeight.bold, maxWidth: textMaxW) +
      18;
  y += _drawText(canvas, 'ज़मीन • प्लाट • फसल • EMI • सूद', Offset(textX, y),
          fontSize: 38, color: const Color(0xFFE8F5E9), maxWidth: textMaxW) +
      14;
  y += _drawText(
          canvas,
          'बीघा, कट्ठा, धुर, एकड़ — राज्य के हिसाब से सही नाप',
          Offset(textX, y),
          fontSize: 30,
          color: const Color(0xFFC8E6C9),
          maxWidth: textMaxW) +
      26;

  // "100% ऑफलाइन" chip
  final chipRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(textX, y, 330, 62),
    const Radius.circular(31),
  );
  canvas.drawRRect(chipRect, Paint()..color = const Color(0xFFFFD54F));
  _drawText(canvas, '100% ऑफलाइन • फ्री', Offset(textX + 30, y + 12),
      fontSize: 30, weight: FontWeight.bold, color: const Color(0xFF1B5E20));

  return recorder.endRecording();
}
