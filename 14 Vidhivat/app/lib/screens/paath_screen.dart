import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/paath.dart';
import '../vidhi/vidhi.dart' show MantraSthiti;
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// एक पाठ पढ़ने का पन्ना — चालीसा, आरती या स्तोत्र।
///
/// ## यह विधि प्लेयर जैसा क्यों नहीं है
/// प्लेयर में एक कदम एक पन्ने पर आता है, क्योंकि वहाँ हर कदम पर कुछ
/// *करना* होता है। पाठ में करना कुछ नहीं — बस पढ़ना है। बीच में पन्ना
/// पलटना पढ़ने की लय तोड़ता, इसलिए यहाँ **सब पद एक ही लंबी सूची में**
/// हैं और उँगली सिर्फ़ स्क्रॉल करती है।
///
/// ⛔ **इस स्क्रीन पर विज्ञापन कभी नहीं** (→ D-008) — वही नियम जो विधि
/// प्लेयर पर है। आदमी पाठ कर रहा है, बीच में विज्ञापन नहीं आना चाहिए।
class PaathScreen extends StatefulWidget {
  final String id;

  const PaathScreen({super.key, required this.id});

  @override
  State<PaathScreen> createState() => _PaathScreenState();
}

class _PaathScreenState extends State<PaathScreen> {
  late Future<Paath> _paath;

  @override
  void initState() {
    super.initState();
    _paath = paathBhandar.paath(widget.id);
    _screenJagaayeRakho(true);
  }

  @override
  void dispose() {
    _screenJagaayeRakho(false);
    super.dispose();
  }

  /// पाठ के बीच स्क्रीन बंद नहीं होनी चाहिए। कुछ फ़ोन पर यह नहीं चलता —
  /// उसके लिए पाठ रुकना नहीं चाहिए, इसलिए चुपचाप छोड़ देते हैं।
  Future<void> _screenJagaayeRakho(bool jagaao) async {
    try {
      await WakelockPlus.toggle(enable: jagaao);
    } catch (_) {
      // कोई बात नहीं — स्क्रीन सामान्य की तरह बंद होगी।
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Paath>(
        future: _paath,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('पाठ')),
              body: const SafeArea(
                child: VidhivatStateView(
                  title: 'यह पाठ नहीं खुल सका',
                  message: 'वापस जाकर इसे फिर से खोलें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(title: const Text('पाठ')),
              body: const SafeArea(
                child: VidhivatStateView(
                  title: 'पाठ खुल रहा है',
                  loading: true,
                ),
              ),
            );
          }
          return PaathReader(paath: snapshot.data!);
        },
      );
}

/// पाठ का असली पन्ना। **public है ताकि जाँचा जा सके** — इसकी दो
/// हालतें (पाठ भरा है / अभी नहीं जोड़ा गया) पहले सिर्फ़ तभी जँचती थीं
/// जब कोई असली आरती ख़ाली पड़ी हो। कंटेंट भरते ही वो जाँच टूट जाती थी,
/// इसलिए अब टेस्ट सीधे यहाँ `Paath` देकर दोनों हालतें देखता है।
class PaathReader extends StatefulWidget {
  final Paath paath;

  const PaathReader({super.key, required this.paath});

  @override
  State<PaathReader> createState() => _PaathReaderState();
}

class _PaathReaderState extends State<PaathReader> {
  /// पाठ करते वक़्त सिर्फ़ देवनागरी चाहिए। रोमन और अर्थ सन्दर्भ की चीज़ें
  /// हैं — इसलिए डिफ़ॉल्ट रूप से छिपी रहती हैं।
  ///
  /// ⚠️ यह सिर्फ़ सजावट नहीं है। तीनों एक साथ दिखाने पर हनुमान चालीसा का
  /// पन्ना **33,000px से ज़्यादा** लंबा हो जाता है — फ़ोन पर लगभग 45
  /// स्क्रीन। पाठ करने वाला इतना स्क्रॉल नहीं कर सकता।
  bool _arthDikhao = false;

  Paath get paath => widget.paath;

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final bhare = paath.khandBhareHue;

    return Scaffold(
      appBar: AppBar(title: Text(paath.naam)),
      body: SafeArea(
        bottom: false,
        child: VidhivatSacredBackdrop(
          child: Panna(
            padding: const EdgeInsets.fromLTRB(
              VidhivatSpacing.lg,
              VidhivatSpacing.lg,
              VidhivatSpacing.lg,
              VidhivatSpacing.xxl,
            ),
            children: [
              // ── ऊपर: यह क्या है ──
              Text(paath.naam, style: type.pageTitle),
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                '${paath.prakar.naam} · ${paath.devta} · '
                '${paath.rachnakar} · ${paath.bhasha}',
                style: type.bodySmall,
              ),
              const SizedBox(height: VidhivatSpacing.lg),
              Text(paath.parichay, style: type.bodyMedium),

              // ── पाठ अभी नहीं आया, तो सबसे ऊपर साफ़ कहो ──
              if (!paath.kuchBharaHai) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                _Notice(
                  title: 'पाठ अभी जोड़ा नहीं गया',
                  text:
                      '${paath.khandKul} पदों की जगह बनी हुई है, पर पाठ अभी '
                      'नहीं लिखा गया। ${paath.prakar.naam} गाई जाने वाली रचना '
                      'है — ऐप में वही रूप जाएगा जो आपके घर में पढ़ा जाता है। '
                      'तब तक अपनी पुस्तिका से पढ़िए।',
                  serious: true,
                ),
              ] else if (paath.needsPanditReview) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                _Notice(
                  title: 'जाँच बाकी है',
                  text: 'यह पाठ अभी किसी जानकार से जाँच करवाकर पास नहीं हुआ '
                      'है ($bhare / ${paath.khandKul} पद भरे हैं)। अपने घर की '
                      'पुस्तिका से मिला लीजिए।',
                  serious: true,
                ),
              ],

              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'कब पढ़ें'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                child: Text(paath.kabPadhein, style: type.bodyMedium),
              ),

              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'कैसे पढ़ें'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                child: Text(paath.kaisePadhein, style: type.bodyMedium),
              ),

              // ── पाठ ──
              const SizedBox(height: VidhivatSpacing.xxl),
              VidhivatSectionHeader(
                title: 'पाठ',
                supportingText: '${paath.khandKul} पद',
                action: paath.kuchBharaHai
                    ? VidhivatButton(
                        label: _arthDikhao ? 'सिर्फ़ पाठ' : 'अर्थ दिखाएँ',
                        semanticLabel: _arthDikhao
                            ? 'सिर्फ़ पाठ दिखाएँ, अर्थ छिपाएँ'
                            : 'हर पद का रोमन और अर्थ दिखाएँ',
                        onPressed: () =>
                            setState(() => _arthDikhao = !_arthDikhao),
                        variant: VidhivatButtonVariant.text,
                        compact: true,
                      )
                    : null,
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              for (final k in paath.khand) ...[
                _KhandCard(khand: k, arthDikhao: _arthDikhao),
                const SizedBox(height: VidhivatSpacing.sm),
              ],

              // ── स्रोत ──
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'यह पाठ कहाँ से आया'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('रचयिता — ${paath.rachnakar}', style: type.bodyMedium),
                    const SizedBox(height: VidhivatSpacing.xxs),
                    Text('भाषा — ${paath.bhasha}', style: type.bodyMedium),
                    const SizedBox(height: VidhivatSpacing.xxs),
                    Text('पद्धति — ${paath.strot.paddhati}',
                        style: type.bodyMedium),
                    if (paath.strot.note.isNotEmpty) ...[
                      const SizedBox(height: VidhivatSpacing.sm),
                      Text(paath.strot.note, style: type.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// एक पद — दोहा या चौपाई।
class _KhandCard extends StatelessWidget {
  final PaathKhand khand;
  final bool arthDikhao;

  const _KhandCard({required this.khand, this.arthDikhao = false});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return VidhivatSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(khand.shirshak, style: type.label),
          const SizedBox(height: VidhivatSpacing.xs),
          if (khand.hasPath) ...[
            // सबसे बड़ा अक्षर — यही बोलकर पढ़ा जाता है।
            //
            // ⚠️ यहाँ `SelectableText` जान-बूझकर नहीं है। वो हर पद के
            // अंदर अपना scrollable बनाता है; 43 पदों पर वो 43 nested
            // scrollable हो जाते हैं, और लंबे पन्ने पर स्क्रॉल उलझता है।
            // (विधि प्लेयर में एक पन्ने पर एक ही मंत्र होता है, इसलिए
            // वहाँ `SelectableText` ठीक है।)
            Text(khand.dev, style: type.mantra),
            if (arthDikhao && khand.roman.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.xs),
              Text(khand.roman, style: type.mantraTransliteration),
            ],
            if (arthDikhao && khand.arth.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              Text(khand.arth, style: type.mantraMeaning),
            ],
            if (arthDikhao && khand.sthiti != MantraSthiti.paas) ...[
              const SizedBox(height: VidhivatSpacing.xs),
              Text('जाँच बाकी', style: type.caption),
            ],
          ] else
            Text(
              '— अभी नहीं जोड़ा गया —',
              style: type.bodyMedium.copyWith(color: colors.textTertiary),
            ),
        ],
      ),
    );
  }
}

/// छोटा चेतावनी-डिब्बा। विधि वाले पन्ने के `_TrustNotice` जैसा ही, पर
/// वो private है इसलिए यहाँ अपना।
class _Notice extends StatelessWidget {
  final String title;
  final String text;
  final bool serious;

  const _Notice({
    required this.title,
    required this.text,
    this.serious = false,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final tone = serious ? colors.warning : colors.info;

    return Container(
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: VidhivatRadius.large,
        border: Border(left: BorderSide(color: tone, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: type.label.copyWith(color: tone)),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(text, style: type.bodySmall),
        ],
      ),
    );
  }
}
