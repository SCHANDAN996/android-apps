import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/paath.dart';
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
      // ⚠️ `bottom: false` यहाँ नहीं चलेगा — इस पन्ने के नीचे ऐप की
      // अपनी कोई पट्टी नहीं है, इसलिए सबसे नीचे का हिस्सा सीधे Android
      // के नेविगेशन बार के पीछे चला जाता है (फ़ोन पर पकड़ा गया, 4 सित)।
      // `top: false` इसलिए कि ऊपर AppBar पहले से सँभाल लेता है।
      body: SafeArea(
        top: false,
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
              Text(paath.parichay,
                  style: type.bodyMedium, textAlign: TextAlign.justify),

              // ── पाठ अभी नहीं आया, तो सबसे ऊपर साफ़ कहो ──
              if (!paath.kuchBharaHai) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                _Notice(
                  title: 'पाठ अभी जोड़ा नहीं गया',
                  text: '${paath.khandKul} पदों की जगह बनी हुई है, पर पाठ अभी '
                      'नहीं लिखा गया। ${paath.prakar.naam} गाई जाने वाली रचना '
                      'है — ऐप में वही रूप जाएगा जो आपके घर में पढ़ा जाता है। '
                      'तब तक अपनी पुस्तिका से पढ़िए।',
                  serious: true,
                ),
              ] else if (bhare < paath.khandKul) ...[
                // ── अधूरा पाठ — यही असली चेतावनी है ──────────────────
                //
                // पहले यहाँ "जाँच बाकी है" लिखा था और वो **पूरे भरे**
                // पाठ पर भी दिखता था: हनुमान चालीसा पर "(43 / 43 पद भरे
                // हैं)" के साथ चेतावनी — यानी ऐप कह रहा था "सब कुछ है,
                // पर भरोसा मत करो"। उससे यूज़र को कुछ मिलता नहीं था।
                //
                // अब चेतावनी सिर्फ़ तब, जब सचमुच कुछ **कम** हो, और वो
                // कमी गिनकर बताई जाती है (→ D-042)।
                const SizedBox(height: VidhivatSpacing.lg),
                _Notice(
                  title: 'यह पाठ अभी अधूरा है',
                  text: '${paath.khandKul} में से $bhare पद ही जोड़े गए हैं। '
                      'बाक़ी अपनी पुस्तिका से पढ़िए — जब तक पूरा पाठ '
                      'प्रामाणिक स्रोत से न आ जाए, हम अंदाज़े से कुछ नहीं '
                      'लिखेंगे।',
                  serious: true,
                ),
              ],

              const SizedBox(height: VidhivatSpacing.lg),
              
              // ── "कब पढ़ें" और "कैसे पढ़ें" यहाँ दो पूरे खंड थे ────
              //
              // नतीजा यह था कि हनुमान चालीसा खोलने पर **पहला दोहा
              // तीसरी स्क्रीन पर** मिलता था — नाम, पहचान, परिचय,
              // "कब पढ़ें", "कैसे पढ़ें", *फिर* पाठ।
              //
              // ये दोनों एक बार पढ़ने की चीज़ें हैं; पाठ रोज़ की। इसलिए वे
              // एक दबाव पीछे गए — मिटे नहीं (→ D-045, D-056)।
              _KabAurKaisePadhein(paath: paath),
              
              // ── सावधानी ⚠ — यह खुली ही रहती है ────────────────
              //
              // आरती में हाथ में जलता दीपक होता है। "ढीले कपड़े, दुपट्टा
              // और बाल दूर रखें" एक दबाव पीछे रखना वैसी ही भूल होती जैसी
              // सूर्यग्रहण वाली आँख की चेतावनी छिपाना (→ D-056)।
              //
              // आरती पर यह नारंगी है (आग है), चालीसा पर सादी — वहाँ ⚠
              // सिर्फ़ इतना कहता है कि "यह पाठ है, पूजा नहीं"।
              if (paath.saavdhani.isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.sm),
                Chetavni(
                  paath.saavdhani,
                  serious: paath.prakar == PaathPrakar.aarti,
                  icon: paath.prakar == PaathPrakar.aarti
                      ? Icons.local_fire_department_outlined
                      : Icons.info_outline,
                ),
              ],

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

              // ── स्रोत — अब ⓘ के पीछे (→ D-045) ──────────────────
              //
              // यह पूरा कार्ड पहले खुला पड़ा रहता था, पाठ के ठीक बाद।
              // पाठ करने वाले को हवाला नहीं चाहिए — पर जिसे चाहिए उसे
              // मिलना चाहिए, इसलिए मिटाया नहीं, एक दबाव पीछे किया।
              //
              // ⚠️ **रचयिता और भाषा ऊपर वाली लाइन में अब भी खुली हैं**
              // ("चालीसा · हनुमान जी · गोस्वामी तुलसीदास · अवधी")। वही
              // असली attribution है और वो छिपनी नहीं चाहिए।
              const SizedBox(height: VidhivatSpacing.xl),
              VidhivatSrotButton(
                label: 'यह पाठ कहाँ से आया',
                panktiyan: [
                  VidhivatSrotPankti('रचयिता', paath.rachnakar),
                  VidhivatSrotPankti('भाषा', paath.bhasha),
                  VidhivatSrotPankti('पद्धति', paath.strot.paddhati),
                  VidhivatSrotPankti('क्षेत्र', paath.strot.kshetra),
                  VidhivatSrotPankti('और', paath.strot.note),
                ],
                antimBaat: 'आपके घर या क्षेत्र का चलन अलग हो तो वही सही है।',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "कब पढ़ें" और "कैसे पढ़ें" — एक ही ℹ के पीछे।
///
/// यह पाठ के **ऊपर** रहता है, नीचे नहीं — क्योंकि ये बातें
/// पाठ से *पहले* की हैं। पर एक पंक्ति में, दो खंडों में नहीं।
class _KabAurKaisePadhein extends StatelessWidget {
  final Paath paath;

  const _KabAurKaisePadhein({required this.paath});

  @override
  Widget build(BuildContext context) => VidhivatSrotButton(
        label: 'कब और कैसे पढ़ें',
        panktiyan: [
          VidhivatSrotPankti('कब पढ़ें', paath.kabPadhein),
          VidhivatSrotPankti('कैसे पढ़ें', paath.kaisePadheinVidhi),
        ],
      );
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
            // हर पद के नीचे "जाँच बाकी" लिखना बंद — तैंतालीस पदों पर
            // तैंतालीस बार वही बात, और यूज़र के लिए उसमें कोई काम नहीं।
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
