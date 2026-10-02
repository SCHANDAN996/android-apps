import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../theme.dart';

/// कुंडली किस आधार से गिनी जाए।
enum KundaliAadhar {
  lagna('लग्न'),
  chandra('चंद्र'),
  navamsha('नवमांश');

  final String naam;
  const KundaliAadhar(this.naam);
}

/// ग्रहों के छोटे नाम — चित्र के तिकोने खानों में पूरा नाम नहीं समाता।
const Map<KundaliGraha, String> grahaChhotaNaam = {
  KundaliGraha.surya: 'सू',
  KundaliGraha.chandra: 'चं',
  KundaliGraha.mangal: 'मं',
  KundaliGraha.budh: 'बु',
  KundaliGraha.guru: 'गु',
  KundaliGraha.shukra: 'शु',
  KundaliGraha.shani: 'श',
  KundaliGraha.rahu: 'रा',
  KundaliGraha.ketu: 'के',
};

const _devAnk = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

/// 12 → "१२"
String devAnk(int n) => n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : _devAnk[d];
    }).join();

/// एक भाव में क्या है — चित्र और उसका पढ़ा जाने वाला ब्यौरा, दोनों इसी से।
class BhavKaBhaag {
  /// 1–12
  final int bhav;

  /// 0 = मेष … 11 = मीन
  final int rashi;
  final List<GrahaSthiti> grahas;

  /// लग्न इसी भाव में है (चंद्र कुंडली में यह पहला भाव नहीं होता)।
  final bool lagnaYahan;

  const BhavKaBhaag(this.bhav, this.rashi, this.grahas, this.lagnaYahan);
}

/// [aadhar] के हिसाब से बारहों भाव — कौन सी राशि, कौन से ग्रह।
///
/// - लग्न: पहला भाव = लग्न की राशि; ग्रह अपनी राशि वाले भाव में।
/// - चंद्र: पहला भाव = चंद्र की राशि।
/// - नवमांश: पहला भाव = लग्न का नवमांश; ग्रह अपने नवमांश वाले भाव में।
List<BhavKaBhaag> bhavVibhag(Kundali k, KundaliAadhar aadhar) {
  final pehliRashi = switch (aadhar) {
    KundaliAadhar.lagna => k.lagna.rashi,
    KundaliAadhar.chandra => k[KundaliGraha.chandra].rashi,
    KundaliAadhar.navamsha => k.lagna.navamsha,
  };
  int rashiOf(RashiSthiti s) =>
      aadhar == KundaliAadhar.navamsha ? s.navamsha : s.rashi;
  return [
    for (var b = 1; b <= 12; b++)
      BhavKaBhaag(
        b,
        (pehliRashi + b - 1) % 12,
        [
          for (final g in k.grahas)
            if (rashiOf(g) == (pehliRashi + b - 1) % 12) g
        ],
        rashiOf(k.lagna) == (pehliRashi + b - 1) % 12,
      ),
  ];
}

/// उत्तर भारतीय कुंडली का चित्र — चौकोर, दो कर्ण, और बीच का तिरछा चौकोर।
///
/// भाव **अपनी जगह पर टिके रहते हैं** (पहला ऊपर बीच में, फिर घड़ी की उलटी
/// दिशा में); राशि का अंक हर भाव में लिखा जाता है। कोई तस्वीर नहीं — रेखाएँ
/// `CustomPainter` से, अक्षर `Text` से।
///
/// अक्षरों का नाप चित्र की चौड़ाई से बँधा है, फ़ोन के "बड़े अक्षर" से नहीं —
/// तिकोने खाने में जगह तय है। बड़े अक्षर वालों के लिए वही सब कुछ नीचे की
/// सूची और "ग्रह" वाली पट्टी में पूरे नाप में है।
class KundaliChitra extends StatelessWidget {
  final Kundali kundali;
  final KundaliAadhar aadhar;

  const KundaliChitra({
    super.key,
    required this.kundali,
    this.aadhar = KundaliAadhar.lagna,
  });

  // भाव 1–12 के ग्रहों वाले खाने का केंद्र और नाप, और राशि-अंक की जगह —
  // सब चित्र की भुजा के हिस्से में (0–1)।
  static const _grahaKendra = <Offset>[
    Offset(0.50, 0.215), Offset(0.25, 0.085), Offset(0.085, 0.25),
    Offset(0.235, 0.50), Offset(0.085, 0.75), Offset(0.25, 0.915),
    Offset(0.50, 0.785), Offset(0.75, 0.915), Offset(0.915, 0.75),
    Offset(0.765, 0.50), Offset(0.915, 0.25), Offset(0.75, 0.085),
  ];
  static const _grahaNaap = <Size>[
    Size(0.30, 0.21), Size(0.32, 0.13), Size(0.15, 0.30),
    Size(0.27, 0.24), Size(0.15, 0.30), Size(0.32, 0.13),
    Size(0.30, 0.21), Size(0.32, 0.13), Size(0.15, 0.30),
    Size(0.27, 0.24), Size(0.15, 0.30), Size(0.32, 0.13),
  ];
  static const _rashiJagah = <Offset>[
    Offset(0.50, 0.435), Offset(0.25, 0.205), Offset(0.205, 0.25),
    Offset(0.435, 0.50), Offset(0.205, 0.75), Offset(0.25, 0.795),
    Offset(0.50, 0.565), Offset(0.75, 0.795), Offset(0.795, 0.75),
    Offset(0.565, 0.50), Offset(0.795, 0.25), Offset(0.75, 0.205),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final bhag = bhavVibhag(kundali, aadhar);

    return Semantics(
      container: true,
      label: '${aadhar.naam} कुंडली। ${[
        for (final b in bhag)
          if (b.grahas.isNotEmpty || b.lagnaYahan)
            'भाव ${b.bhav}, ${rashiNames[b.rashi]}: '
                '${[
              if (b.lagnaYahan) 'लग्न',
              for (final g in b.grahas) g.graha.naam
            ].join(', ')}'
      ].join('। ')}',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, c) {
            final bhuja = c.maxWidth;
            final grahaStyle = type.bodyMedium.copyWith(
              fontSize: bhuja * 0.046,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            );
            final rashiStyle = type.caption.copyWith(
              fontSize: bhuja * 0.036,
              height: 1.0,
              color: colors.textTertiary,
            );
            return MediaQuery.withNoTextScaling(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RekhaPainter(
                        rekha: colors.primary.withValues(alpha: 0.75),
                        prishth: colors.surface,
                      ),
                    ),
                  ),
                  for (final b in bhag) ...[
                    _beech(
                      bhuja,
                      _rashiJagah[b.bhav - 1],
                      const Size(0.09, 0.06),
                      Text(devAnk(b.rashi + 1), style: rashiStyle),
                    ),
                    _beech(
                      bhuja,
                      _grahaKendra[b.bhav - 1],
                      _grahaNaap[b.bhav - 1],
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _grahaNaap[b.bhav - 1].width * bhuja,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: bhuja * 0.014,
                            children: [
                              if (b.lagnaYahan)
                                Text('ल',
                                    style: grahaStyle.copyWith(
                                        color: colors.primary)),
                              for (final g in b.grahas)
                                Text.rich(
                                  TextSpan(
                                    text: grahaChhotaNaam[g.graha],
                                    children: [
                                      // वक्री का निशान — छोटा, ताकि तिकोने
                                      // खाने में तीन-चार ग्रह भी समा जाएँ
                                      if (g.vakri)
                                        TextSpan(
                                          text: '(व)',
                                          style: TextStyle(
                                            fontSize: bhuja * 0.028,
                                            fontWeight: FontWeight.w400,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  style: grahaStyle,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// [kendra] पर बीचोबीच बैठा, [naap] जितना बड़ा खाना।
  static Widget _beech(double bhuja, Offset kendra, Size naap, Widget child) =>
      Positioned(
        left: (kendra.dx - naap.width / 2) * bhuja,
        top: (kendra.dy - naap.height / 2) * bhuja,
        width: naap.width * bhuja,
        height: naap.height * bhuja,
        child: Center(child: child),
      );
}

class _RekhaPainter extends CustomPainter {
  final Color rekha;
  final Color prishth;

  const _RekhaPainter({required this.rekha, required this.prishth});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bharo = Paint()..color = prishth;
    final kalam = Paint()
      ..color = rekha
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.006).clamp(1.2, 2.5)
      ..strokeJoin = StrokeJoin.round;
    final dabba = Rect.fromLTWH(0, 0, w, h).deflate(kalam.strokeWidth / 2);
    canvas.drawRect(dabba, bharo);
    canvas.drawRect(dabba, kalam);
    // दो कर्ण
    canvas.drawLine(dabba.topLeft, dabba.bottomRight, kalam);
    canvas.drawLine(dabba.topRight, dabba.bottomLeft, kalam);
    // भुजाओं के मध्य-बिंदुओं को जोड़ता तिरछा चौकोर
    final path = Path()
      ..moveTo(dabba.center.dx, dabba.top)
      ..lineTo(dabba.left, dabba.center.dy)
      ..lineTo(dabba.center.dx, dabba.bottom)
      ..lineTo(dabba.right, dabba.center.dy)
      ..close();
    canvas.drawPath(path, kalam);
  }

  @override
  bool shouldRepaint(_RekhaPainter old) =>
      old.rekha != rekha || old.prishth != prishth;
}
