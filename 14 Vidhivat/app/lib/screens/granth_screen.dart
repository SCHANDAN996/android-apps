import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/granth.dart';
import '../widgets/common.dart';
import '../widgets/reading_cards.dart';
import '../widgets/design_system.dart';
import 'paath_screen.dart';

/// एक ग्रंथ का पन्ना — उसके सारे अध्याय, क्रम से (→ D-084, D-098)।
///
/// पहले यह सिर्फ़ दुर्गा सप्तशती के लिए था (`saptashati_screen.dart`)। गीता
/// आने पर वही पन्ना ग्रंथ की id लेने लगा; सप्तशती अब इसी से खुलती है।
///
/// ## यह पन्ना क्या करता है
/// - पूरा क्रम एक जगह — किस हिस्से में कौन सा पाठ, कितने श्लोक।
/// - **जहाँ छोड़ा था वहीं से** — आख़िरी खोला पाठ स्थानीय रूप से याद रहता
///   है (सिर्फ़ इसी फ़ोन में — कहीं भेजा नहीं जाता)।
/// - हर अध्याय में **पिछला/अगला** और उसका क्रम।
///
/// ⛔ **यहाँ दक्षिणा नहीं।** पाठ वही जगह है जहाँ आदमी पूजा में है (→ D-053)।
class GranthScreen extends StatefulWidget {
  final GranthSuchiEntry granth;

  const GranthScreen({super.key, required this.granth});

  /// आख़िरी खोला पाठ — `SharedPreferences` में।
  static String pichhlaKeyFor(String granthId) => '${granthId}_pichhla';

  @override
  State<GranthScreen> createState() => _GranthScreenState();
}

class _GranthScreenState extends State<GranthScreen> {
  late final Future<GranthKram> _kram = granthBhandar.kram(widget.granth.id);
  String? _pichhla;

  GranthSuchiEntry get granth => widget.granth;

  String get _pichhlaKey => GranthScreen.pichhlaKeyFor(granth.id);

  @override
  void initState() {
    super.initState();
    _pichhlaPadho();
  }

  Future<void> _pichhlaPadho() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_pichhlaKey);
      if (mounted) setState(() => _pichhla = id);
    } catch (_) {
      // याद न रहे तो कोई बात नहीं — सूची वैसे ही चलती है।
    }
  }

  Future<void> _yaadRakho(String id) async {
    if (mounted) setState(() => _pichhla = id);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pichhlaKey, id);
    } catch (_) {}
  }

  /// क्रम का [i]वाँ पाठ खोलो। [badlo] = पिछले अध्याय की जगह (ताकि "पीछे"
  /// दबाने पर सीधे सूची पर लौटें, हर पढ़ा अध्याय फिर से न खुले)।
  void _kholo(NavigatorState nav, List<GranthPaath> kram, int i,
      {bool badlo = false}) {
    final p = kram[i];
    _yaadRakho(p.id);
    final pichhla = i > 0 ? kram[i - 1] : null;
    final agla = i + 1 < kram.length ? kram[i + 1] : null;
    final route = MaterialPageRoute<void>(
      builder: (_) => PaathScreen(
        id: p.id,
        granth: GranthNavigation(
          granthId: granth.id,
          granthNaam: granth.chhotaNaam,
          ikai: granth.ikai,
          khandIkai: p.gintiNaam ?? granth.khandIkai,
          paathId: p.id,
          kram: i,
          kul: kram.length,
          pichhlaNaam: pichhla?.naam,
          aglaNaam: agla?.naam,
          pichhlaKholo: pichhla == null
              ? null
              : () => _kholo(nav, kram, i - 1, badlo: true),
          aglaKholo:
              agla == null ? null : () => _kholo(nav, kram, i + 1, badlo: true),
        ),
      ),
    );
    if (badlo) {
      nav.pushReplacement(route);
    } else {
      nav.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(granth.naam)),
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<GranthKram>(
            future: _kram,
            builder: (context, snap) {
              if (snap.hasError) {
                return VidhivatStateView(
                  title: '${granth.chhotaNaam} नहीं खुल सकी',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              final k = snap.data;
              if (k == null) {
                return VidhivatStateView(
                  title: '${granth.chhotaNaam} खुल रही है',
                  loading: true,
                );
              }
              final kram = k.kram;
              final nav = Navigator.of(context);
              final pichhlaI = kram.indexWhere((p) => p.id == _pichhla);

              return Panna(
                padding: const EdgeInsets.fromLTRB(
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.xxl,
                ),
                children: [
                  Text(k.parichay,
                      style: type.bodyMedium, textAlign: TextAlign.justify),
                  if (pichhlaI >= 0) ...[
                    const SizedBox(height: VidhivatSpacing.lg),
                    VidhivatSurfaceCard(
                      variant: VidhivatCardVariant.information,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('पिछली बार यह पाठ खोला था',
                              textAlign: TextAlign.justify,
                              style: type.bodySmall),
                          const SizedBox(height: VidhivatSpacing.xxs),
                          Text(kram[pichhlaI].naam, style: type.cardTitle),
                          const SizedBox(height: VidhivatSpacing.md),
                          VidhivatButton(
                            label: 'वहीं से पढ़ें',
                            semanticLabel:
                                '${kram[pichhlaI].naam} से आगे पढ़ें',
                            icon: Icons.play_arrow_rounded,
                            fullWidth: true,
                            onPressed: () => _kholo(nav, kram, pichhlaI),
                          ),
                        ],
                      ),
                    ),
                  ],
                  for (final h in k.hisse) ...[
                    const SizedBox(height: VidhivatSpacing.xl),
                    VidhivatSectionHeader(title: h.shirshak),
                    const SizedBox(height: VidhivatSpacing.sm),
                    ReadingCardGrid(
                      gridKey: ValueKey('granth_chapters_${h.shirshak}'),
                      children: [
                        for (final p in h.paath)
                          _Pankti(
                            paath: p,
                            pichhla: p.id == _pichhla,
                            ekLineDikhao: granth.ekLineDikhao,
                            gintiNaam: granth.gintiNaam,
                            onTap: () => _kholo(nav, kram, kram.indexOf(p)),
                          ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Pankti extends StatelessWidget {
  final GranthPaath paath;
  final bool pichhla;
  final bool ekLineDikhao;
  final String gintiNaam;
  final VoidCallback onTap;

  const _Pankti({
    required this.paath,
    required this.pichhla,
    required this.ekLineDikhao,
    required this.gintiNaam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Semantics(
        button: true,
        label: paath.naam,
        onTap: onTap,
        excludeSemantics: true,
        child: VidhivatSurfaceCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(paath.naam,
                  textAlign: TextAlign.center, style: type.cardTitle),
              if (ekLineDikhao) ...[
                const SizedBox(height: VidhivatSpacing.xs),
                Text(paath.ekLine,
                    textAlign: TextAlign.center, style: type.bodySmall),
              ],
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                  '${paath.shlok} ${paath.gintiNaam ?? gintiNaam}'
                  '${pichhla ? ' · पिछली बार खोला था' : ''}',
                  textAlign: TextAlign.center,
                  style: type.bodySmall
                      .copyWith(color: pichhla ? colors.primary : null)),
            ],
          ),
        ));
  }
}
