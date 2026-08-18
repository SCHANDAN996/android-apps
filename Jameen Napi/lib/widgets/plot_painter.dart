import 'package:flutter/material.dart';

/// Interactive visual sketch for a 4-sided field (Quadrilateral).
class QuadrilateralPlotPainter extends CustomPainter {
  final double a; // Top / North
  final double b; // Right / East
  final double c; // Bottom / South
  final double d; // Left / West
  final double? diagonal; // Diagonal
  final String unitName;

  QuadrilateralPlotPainter({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    this.diagonal,
    this.unitName = 'ft',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final diagonalPaint = Paint()
      ..color = Colors.deepOrange.shade400
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const pad = 36.0;
    final w = size.width - 2 * pad;
    final h = size.height - 2 * pad;

    // Normalize side lengths for a visually pleasing polygon
    final maxSide = [a, b, c, d, 1.0].reduce((curr, next) => curr > next ? curr : next);
    final topRatio = (a / maxSide).clamp(0.4, 1.0);
    final rightRatio = (b / maxSide).clamp(0.4, 1.0);
    final bottomRatio = (c / maxSide).clamp(0.4, 1.0);
    final leftRatio = (d / maxSide).clamp(0.4, 1.0);

    // 4 Corner Vertices (P1: Top-Left, P2: Top-Right, P3: Bottom-Right, P4: Bottom-Left)
    final p1 = Offset(pad + (1.0 - leftRatio) * 15, pad + (1.0 - topRatio) * 15);
    final p2 = Offset(pad + w * topRatio, pad + (1.0 - rightRatio) * 15);
    final p3 = Offset(pad + w * bottomRatio, pad + h * rightRatio);
    final p4 = Offset(pad + (1.0 - leftRatio) * 15, pad + h * leftRatio);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    // Fill & Outline
    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);

    // Draw Diagonal if provided
    if (diagonal != null && diagonal! > 0) {
      canvas.drawLine(p1, p3, diagonalPaint);

      // Label on diagonal
      _drawText(
        canvas,
        textPainter,
        'विकर्ण: ${diagonal!.toStringAsFixed(1)} $unitName',
        Offset((p1.dx + p3.dx) / 2, (p1.dy + p3.dy) / 2 - 8),
        color: Colors.deepOrange.shade800,
        isBold: true,
      );
    }

    // Draw Corner Dots
    final dotPaint = Paint()..color = const Color(0xFF1B5E20);
    for (final p in [p1, p2, p3, p4]) {
      canvas.drawCircle(p, 4.5, dotPaint);
    }

    // Label Side A (Top / North)
    _drawText(
      canvas,
      textPainter,
      'A (उत्तर): ${a.toStringAsFixed(1)} $unitName',
      Offset((p1.dx + p2.dx) / 2, p1.dy - 18),
      color: const Color(0xFF1B5E20),
    );

    // Label Side B (Right / East)
    _drawText(
      canvas,
      textPainter,
      'B (पूर्व): ${b.toStringAsFixed(1)} $unitName',
      Offset(p2.dx + 8, (p2.dy + p3.dy) / 2),
      color: const Color(0xFF1B5E20),
      alignLeft: true,
    );

    // Label Side C (Bottom / South)
    _drawText(
      canvas,
      textPainter,
      'C (दक्षिण): ${c.toStringAsFixed(1)} $unitName',
      Offset((p4.dx + p3.dx) / 2, p3.dy + 8),
      color: const Color(0xFF1B5E20),
    );

    // Label Side D (Left / West)
    _drawText(
      canvas,
      textPainter,
      'D (पश्चिम): ${d.toStringAsFixed(1)} $unitName',
      Offset(p1.dx - 10, (p1.dy + p4.dy) / 2),
      color: const Color(0xFF1B5E20),
      alignRight: true,
    );
  }

  void _drawText(
    Canvas canvas,
    TextPainter tp,
    String text,
    Offset offset, {
    Color color = Colors.black87,
    bool isBold = false,
    bool alignLeft = false,
    bool alignRight = false,
  }) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
    );
    tp.layout();

    var dx = offset.dx - tp.width / 2;
    if (alignLeft) dx = offset.dx;
    if (alignRight) dx = offset.dx - tp.width;

    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant QuadrilateralPlotPainter oldDelegate) {
    return oldDelegate.a != a ||
        oldDelegate.b != b ||
        oldDelegate.c != c ||
        oldDelegate.d != d ||
        oldDelegate.diagonal != diagonal ||
        oldDelegate.unitName != unitName;
  }
}

/// Visual sketch for Triangular field.
class TrianglePlotPainter extends CustomPainter {
  final double a;
  final double b;
  final double c;
  final String unitName;

  TrianglePlotPainter({
    required this.a,
    required this.b,
    required this.c,
    this.unitName = 'ft',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const pad = 36.0;
    final w = size.width - 2 * pad;
    final h = size.height - 2 * pad;

    final p1 = Offset(pad + w / 2, pad);
    final p2 = Offset(pad + w, pad + h);
    final p3 = Offset(pad, pad + h);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);

    final dotPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(p1, 4.5, dotPaint);
    canvas.drawCircle(p2, 4.5, dotPaint);
    canvas.drawCircle(p3, 4.5, dotPaint);

    // Labels
    _drawText(
      canvas,
      textPainter,
      'A: ${a.toStringAsFixed(1)} $unitName',
      Offset((p1.dx + p2.dx) / 2 + 10, (p1.dy + p2.dy) / 2),
      color: const Color(0xFF1B5E20),
    );
    _drawText(
      canvas,
      textPainter,
      'B (आधार): ${b.toStringAsFixed(1)} $unitName',
      Offset((p2.dx + p3.dx) / 2, p2.dy + 8),
      color: const Color(0xFF1B5E20),
    );
    _drawText(
      canvas,
      textPainter,
      'C: ${c.toStringAsFixed(1)} $unitName',
      Offset((p1.dx + p3.dx) / 2 - 10, (p1.dy + p3.dy) / 2),
      color: const Color(0xFF1B5E20),
    );
  }

  void _drawText(Canvas canvas, TextPainter tp, String text, Offset offset,
      {Color color = Colors.black87}) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy));
  }

  @override
  bool shouldRepaint(covariant TrianglePlotPainter oldDelegate) {
    return oldDelegate.a != a ||
        oldDelegate.b != b ||
        oldDelegate.c != c ||
        oldDelegate.unitName != unitName;
  }
}
