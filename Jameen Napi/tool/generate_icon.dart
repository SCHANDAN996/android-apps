// App icon generator — flutter test tool/generate_icon.dart se chalayein.
// assets/icon/icon.png (full) aur icon_foreground.png (adaptive) banata hai.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generate launcher icons', (tester) async {
    await tester.runAsync(() async {
      await _writePng(_drawFullIcon(), 'assets/icon/icon.png');
      await _writePng(_drawForeground(), 'assets/icon/icon_foreground.png');
    });
  });
}

Future<void> _writePng(ui.Picture picture, String path) async {
  final image = await picture.toImage(1024, 1024);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

ui.Picture _drawFullIcon() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 1024.0;

  // हरा gradient background
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(size, size),
        [const Color(0xFF43A047), const Color(0xFF1B5E20)],
      ),
  );

  // सूरज
  canvas.drawCircle(
      const Offset(830, 190), 90, Paint()..color = const Color(0xFFFFD54F));

  // पीछे की फसल की पट्टी
  final farField = Path()
    ..moveTo(0, 780)
    ..quadraticBezierTo(256, 720, 512, 770)
    ..quadraticBezierTo(768, 820, 1024, 760)
    ..lineTo(1024, 1024)
    ..lineTo(0, 1024)
    ..close();
  canvas.drawPath(farField, Paint()..color = const Color(0xFF66BB6A));

  // आगे की गहरी पट्टी
  final nearField = Path()
    ..moveTo(0, 890)
    ..quadraticBezierTo(300, 840, 600, 885)
    ..quadraticBezierTo(850, 915, 1024, 880)
    ..lineTo(1024, 1024)
    ..lineTo(0, 1024)
    ..close();
  canvas.drawPath(nearField, Paint()..color = const Color(0xFF2E7D32));

  // खेत की मेड़ (furrow) रेखाएँ
  final furrow = Paint()
    ..color = const Color(0x552E7D32)
    ..strokeWidth = 12
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(90, 1000), const Offset(170, 800), furrow);
  canvas.drawLine(const Offset(870, 1000), const Offset(830, 810), furrow);

  _drawCalculator(canvas, const Offset(512, 520), 400, 490);

  return recorder.endRecording();
}

ui.Picture _drawForeground() {
  // Adaptive icon foreground — transparent background, content को
  // बीच के ~62% safe zone में रखा गया है।
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  _drawCalculator(canvas, const Offset(512, 512), 380, 470);
  return recorder.endRecording();
}

void _drawCalculator(Canvas canvas, Offset center, double w, double h) {
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: center, width: w, height: h),
    Radius.circular(w * 0.13),
  );

  // हल्की छाया
  canvas.drawRRect(
    body.shift(const Offset(0, 14)),
    Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
  );

  // सफेद बॉडी
  canvas.drawRRect(body, Paint()..color = Colors.white);

  // डिस्प्ले
  final pad = w * 0.09;
  final displayRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      body.left + pad,
      body.top + pad,
      w - pad * 2,
      h * 0.24,
    ),
    Radius.circular(w * 0.05),
  );
  canvas.drawRRect(displayRect, Paint()..color = const Color(0xFF1B5E20));

  // डिस्प्ले में "अंक" जैसी पट्टियाँ
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

  // बटन — 3 x 3 grid
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
