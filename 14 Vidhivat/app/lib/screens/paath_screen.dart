import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// सप्तशती में chapter number, last-read marker और पिछला/अगला रास्ता।
  final GranthNavigation? granth;

  const PaathScreen({super.key, required this.id, this.granth});

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
          return PaathReader(
            paath: snapshot.data!,
            granth: widget.granth,
          );
        },
      );
}

/// पाठ का असली पन्ना। **public है ताकि जाँचा जा सके** — इसकी दो
/// हालतें (पाठ भरा है / अभी नहीं जोड़ा गया) पहले सिर्फ़ तभी जँचती थीं
/// जब कोई असली आरती ख़ाली पड़ी हो। कंटेंट भरते ही वो जाँच टूट जाती थी,
/// इसलिए अब टेस्ट सीधे यहाँ `Paath` देकर दोनों हालतें देखता है।
class PaathReader extends StatefulWidget {
  final Paath paath;
  final GranthNavigation? granth;

  const PaathReader({super.key, required this.paath, this.granth});

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
  final _scroll = ScrollController();
  late final List<GlobalKey> _khandKeys;
  Timer? _padhneKaThaharav;
  int _aakhriPadh = 0;

  Paath get paath => widget.paath;

  GranthNavigation? get _granth => widget.granth;

  @override
  void initState() {
    super.initState();
    _khandKeys = List.generate(paath.khand.length, (_) => GlobalKey());
    // ScrollEndNotification कुछ embedded scroll paths में ऊपर तक नहीं आता;
    // controller listener हर असली finger-scroll को देखता है। Timer इसे हर
    // pixel पर लिखने के बजाय रुकने के बाद एक बार save करता है।
    _scroll.addListener(_scrollRuka);
    if (_granth != null) _puraniJagahPadho();
  }

  @override
  void dispose() {
    _padhneKaThaharav?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _puraniJagahPadho() async {
    final nav = _granth;
    if (nav == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(nav.khandKey);
      if (saved == null || !mounted) return;
      final safe = saved.clamp(0, paath.khand.length - 1);
      setState(() => _aakhriPadh = safe);
      WidgetsBinding.instance.addPostFrameCallback((_) => _wahanJao(safe));
    } catch (_) {
      // Progress न बचे तो पाठ फिर भी शुरू से चलता है।
    }
  }

  Future<void> _wahanJao(int index) async {
    if (!mounted || index <= 0) return;
    // ⚠️ `Panna` एक lazy ListView है — दूर का पाठ तब तक बनता ही नहीं जब
    // तक स्क्रीन उसके पास न पहुँचे। पहले यहाँ `currentContext == null`
    // पर चुपचाप लौट जाते थे, यानी असली फ़ोन पर "जहाँ छोड़ा वहीं से"
    // सिर्फ़ पहले कुछ पाठों तक चलता था (जाँचें 6000dp ऊँची स्क्रीन पर
    // थीं, इसलिए पकड़ में नहीं आया)। अब एक-एक स्क्रीन आगे कूदकर उसे
    // बनवाते हैं, फिर ठीक जगह पर ले जाते हैं।
    var target = _khandKeys[index].currentContext;
    for (var kood = 0; target == null && kood < 400; kood++) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position;
      if (pos.pixels >= pos.maxScrollExtent) break;
      _scroll.jumpTo(
          math.min(pos.pixels + pos.viewportDimension, pos.maxScrollExtent));
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      target = _khandKeys[index].currentContext;
    }
    if (target == null || !target.mounted) return;
    await Scrollable.ensureVisible(
      target,
      alignment: 0.14,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : VidhivatMotion.standard,
      curve: Curves.easeOut,
    );
  }

  void _scrollRuka() {
    if (_granth == null || !_scroll.hasClients) return;
    _padhneKaThaharav?.cancel();
    _padhneKaThaharav = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      var naya = 0;
      // जो खंड पढ़ने की जगह से ऊपर निकल चुका है, वही आख़िरी पहुँचा खंड है।
      for (var i = 0; i < _khandKeys.length; i++) {
        final box =
            _khandKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null && box.localToGlobal(Offset.zero).dy <= 156) {
          naya = i;
        }
      }
      if (naya == _aakhriPadh) return;
      setState(() => _aakhriPadh = naya);
      _aakhriJagahLikho(naya);
    });
  }

  Future<void> _aakhriJagahLikho(int index) async {
    final nav = _granth;
    if (nav == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(nav.khandKey, index);
    } catch (_) {
      // Local save वैकल्पिक है; पढ़ने का रास्ता कभी न रुके।
    }
  }

  /// "पाठ" शीर्षक के नीचे की गिनती। ग्रंथ के अध्याय में श्लोक गिने जाते
  /// हैं — समापन-वाक्य श्लोक नहीं है, इसलिए "48 खंड" नहीं, "47 श्लोक"।
  static String _khandGinti(Paath paath) => switch (paath.prakar) {
        PaathPrakar.granth => _granthGinti(paath),
        PaathPrakar.stotra => '${paath.khandKul} खंड',
        PaathPrakar.chalisa || PaathPrakar.aarti => '${paath.khandKul} पद',
      };

  /// गीता के अध्याय में श्लोक गिने जाते हैं — समापन-वाक्य, ध्यान या
  /// मंगलाचरण श्लोक की गिनती में नहीं आते। सुंदरकांड के प्रसंग में दोहे,
  /// चौपाइयाँ और छंद हैं — वहाँ "3 श्लोक" लिखना ग़लत होता, इसलिए सब मिलाकर
  /// "पद" (→ D-106)।
  static String _granthGinti(Paath paath) {
    final padya = paath.khand.any((k) =>
        k.shirshak.startsWith('चौपाई') || k.shirshak.startsWith('दोहा'));
    if (padya) return '${paath.khandKul} पद';
    final shlok =
        paath.khand.where((k) => k.shirshak.startsWith('श्लोक')).length;
    // वेद के सूक्त में खंड "मंत्र १, मंत्र २ …" हैं (→ D-108)
    final mantra =
        paath.khand.where((k) => k.shirshak.startsWith('मंत्र')).length;
    if (shlok == 0 && mantra > 0) return '$mantra मंत्र';
    // तैत्तिरीय उपनिषद अनुवाकों में बँटा है (→ D-109)
    final anuvak =
        paath.khand.where((k) => k.shirshak.startsWith('अनुवाक')).length;
    if (shlok == 0 && anuvak > 0) return '$anuvak अनुवाक';
    return '$shlok श्लोक';
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final bhare = paath.khandBhareHue;

    return Scaffold(
      appBar: AppBar(title: Text(paath.naam)),
      // सप्तशती का navigator scroll के साथ गायब नहीं होता। लंबे अध्याय में
      // user जहाँ तक पहुँचा हो, वहीं से पिछला/अगला और गिनती हमेशा उपलब्ध।
      bottomNavigationBar: _granth == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VidhivatSpacing.lg,
                  VidhivatSpacing.xs,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.sm,
                ),
                child: _GranthNavigationCard(
                  navigation: _granth!,
                  khandIndex: _aakhriPadh,
                  khandKul: paath.khandKul,
                ),
              ),
            ),
      // ⚠️ `bottom: false` यहाँ नहीं चलेगा — इस पन्ने के नीचे ऐप की
      // अपनी कोई पट्टी नहीं है, इसलिए सबसे नीचे का हिस्सा सीधे Android
      // के नेविगेशन बार के पीछे चला जाता है (फ़ोन पर पकड़ा गया, 4 सित)।
      // `top: false` इसलिए कि ऊपर AppBar पहले से सँभाल लेता है।
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _scrollRuka();
              return false;
            },
            child: Panna(
              controller: _scroll,
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

                // नवदुर्गा के नाम पाठ में श्लोक ३–५ पर आते हैं, लेकिन कवच
                // खोलने वाले को उन्हें ढूँढने के लिए नीचे नहीं जाना चाहिए।
                if (paath.id == 'saptashati_kavach') ...[
                  const SizedBox(height: VidhivatSpacing.lg),
                  const _NavdurgaNaamCard(),
                ],

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
                  // हल्के रंग वाली पंक्तियाँ क्या हैं — यह **एक बार** यहीं
                  // कहा जाता है, हर पद पर लेबल लगाकर नहीं (→ D-083)।
                  supportingText: paath.dohraavKhand == null
                      ? _khandGinti(paath)
                      : '${paath.padGinti} पद · हल्के रंग वाली पंक्तियाँ '
                          'हर पद के बाद दोहराएँ',
                  action: paath.kuchBharaHai
                      ? VidhivatButton(
                          // जिस पाठ में अर्थ नहीं, सिर्फ़ रोमन है — वहाँ
                          // "अर्थ दिखाएँ" लिखना झूठ होता।
                          label: _arthDikhao
                              ? 'सिर्फ़ पाठ'
                              : paath.khand.any((k) => k.arth.trim().isNotEmpty)
                                  ? 'अर्थ दिखाएँ'
                                  : 'रोमन दिखाएँ',
                          semanticLabel: _arthDikhao
                              ? 'सिर्फ़ पाठ दिखाएँ, अर्थ छिपाएँ'
                              : 'हर पद का रोमन और अर्थ दिखाएँ',
                          icon: _arthDikhao
                              ? Icons.menu_book_rounded
                              : Icons.visibility_rounded,
                          onPressed: () =>
                              setState(() => _arthDikhao = !_arthDikhao),
                          // यह मुख्य पढ़ने का control है। Text button पन्ने के
                          // रंग में घुल रहा था; primary variant app के अपने
                          // रंग और सही contrast में साफ़ दिखता है।
                          variant: VidhivatButtonVariant.primary,
                          compact: true,
                        )
                      : null,
                ),
                const SizedBox(height: VidhivatSpacing.sm),
                // ── आरती: बिना शीर्षक, और हर पद के बाद उसकी टेक ──────
                //
                // पहले यहाँ हर खंड के ऊपर "टेक", "पद १", "पद २" लिखा आता था,
                // और टेक सिर्फ़ सबसे ऊपर एक बार — गाने वाले को हर पद के बाद
                // ऊपर स्क्रॉल करना पड़ता। छपी आरती-पुस्तकों में न लेबल होते
                // हैं, न ऊपर लौटना पड़ता है: हर पद के बाद टेक छपी होती है।
                // अब यहाँ भी वही (→ D-083)। चालीसा और स्तोत्र में "दोहा",
                // "चौपाई", "श्लोक" काम के हैं, इसलिए वहाँ लेबल बने रहते हैं।
                for (final (i, k) in paath.khand.indexed) ...[
                  _KhandCard(
                    key: _khandKeys[i],
                    khand: k,
                    arthDikhao: _arthDikhao,
                    shirshakDikhao: paath.prakar != PaathPrakar.aarti,
                    baadMein: k.dohraav ? null : paath.dohraavKhand,
                  ),
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
      ),
    );
  }
}

/// ग्रंथ के किसी पाठ की जगह और दोनों तरफ़ के अध्याय का रास्ता — गीता,
/// सप्तशती (→ D-084, D-098)।
///
/// यह जान-बूझकर सिर्फ़ ग्रंथों को मिलता है: साधारण चालीसा/आरती एक सतत पाठ
/// हैं, उनके ऊपर अध्याय वाली पट्टी लगाना पढ़ने में मदद नहीं करेगा।
class GranthNavigation {
  /// ग्रंथ की id — याद रखने वाली कुंजी इसी से बनती है।
  final String granthId;

  /// पट्टी में दिखने वाला नाम — "गीता", "सप्तशती"।
  final String granthNaam;

  /// ग्रंथ का एक टुकड़ा क्या कहलाता है — "अध्याय" या "पाठ"।
  final String ikai;

  /// पाठ के भीतर एक खंड क्या कहलाता है — "श्लोक" या "पाठ"।
  final String khandIkai;

  final String paathId;
  final int kram;
  final int kul;
  final String? pichhlaNaam;
  final String? aglaNaam;
  final VoidCallback? pichhlaKholo;
  final VoidCallback? aglaKholo;

  const GranthNavigation({
    required this.granthId,
    required this.granthNaam,
    required this.ikai,
    required this.khandIkai,
    required this.paathId,
    required this.kram,
    required this.kul,
    required this.pichhlaNaam,
    required this.aglaNaam,
    required this.pichhlaKholo,
    required this.aglaKholo,
  });

  /// हर अध्याय की आख़िरी दिखी जगह अलग बचती है।
  String get khandKey => '${granthId}_aakhri_khand_$paathId';
}

/// पाठ शुरू करने से पहले दिखने वाला compact glass navigation card।
class _GranthNavigationCard extends StatelessWidget {
  final GranthNavigation navigation;
  final int khandIndex;
  final int khandKul;

  const _GranthNavigationCard({
    required this.navigation,
    required this.khandIndex,
    required this.khandKul,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return ClipRRect(
      borderRadius: VidhivatRadius.large,
      // ⚡ यहाँ पहले `BackdropFilter` (blur 10) था। पर यह कार्ड Scaffold की
      // `bottomNavigationBar` में है — इसके पीछे पाठ नहीं, सिर्फ़ सादा
      // पृष्ठभूमि है, इसलिए blur दिखता ही नहीं था। फिर भी GPU उसे पाठ
      // scroll होते वक़्त हर frame दोबारा बनाता था — सस्ते फ़ोन पर झटके।
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceElevated.withValues(alpha: 0.78),
          borderRadius: VidhivatRadius.large,
          border: Border.all(color: colors.primary.withValues(alpha: 0.42)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(VidhivatSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row नहीं, Wrap ─────────────────────────────────────
              //
              // यहाँ दो लिखावटें एक पंक्ति में थीं, और दाईं वाली सिकुड़ नहीं
              // सकती थी। सप्तशती का "पाठ 1/43 तक" समा जाता था; गीता का
              // "श्लोक 1/56 तक" 320 चौड़ाई और 1.5 गुना अक्षर पर **15 पिक्सल
              // बाहर** निकल गया (जाँच ने पकड़ा, फ़ोन ने नहीं)। अब जगह कम हो
              // तो गिनती अगली पंक्ति में चली जाती है।
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: VidhivatSpacing.sm,
                runSpacing: VidhivatSpacing.xxs,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: VidhivatIconSize.small, color: colors.primary),
                      const SizedBox(width: VidhivatSpacing.xs),
                      Flexible(
                        child: Text(
                          '${navigation.granthNaam} · ${navigation.ikai} '
                          '${navigation.kram + 1}/${navigation.kul}',
                          style: type.label,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${navigation.khandIkai} ${khandIndex + 1}/$khandKul तक',
                    style: type.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              ClipRRect(
                borderRadius: VidhivatRadius.pill,
                child: LinearProgressIndicator(
                  value: (khandIndex + 1) / khandKul,
                  minHeight: 5,
                  backgroundColor: colors.primaryMuted,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(
                'जहाँ तक पहुँचे, वह इस फ़ोन में याद रहेगा।',
                style: type.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: VidhivatSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: VidhivatButton(
                      label: 'पिछला',
                      semanticLabel: navigation.pichhlaNaam == null
                          ? 'इससे पहले कोई ${navigation.ikai} नहीं'
                          : 'पिछला — ${navigation.pichhlaNaam}',
                      icon: Icons.arrow_back_rounded,
                      variant: VidhivatButtonVariant.secondary,
                      compact: true,
                      fullWidth: true,
                      onPressed: navigation.pichhlaKholo,
                    ),
                  ),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Expanded(
                    child: VidhivatButton(
                      label: 'अगला',
                      semanticLabel: navigation.aglaNaam == null
                          ? 'यह ${navigation.granthNaam} का आख़िरी '
                              '${navigation.ikai} है'
                          : 'अगला — ${navigation.aglaNaam}',
                      icon: Icons.arrow_forward_rounded,
                      compact: true,
                      fullWidth: true,
                      onPressed: navigation.aglaKholo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// देवी कवच के श्लोक ३–५ में आए नवदुर्गा के नाम — पाठ शुरू होने से पहले
/// एक जगह, उसी क्रम में।
class _NavdurgaNaamCard extends StatelessWidget {
  const _NavdurgaNaamCard();

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    const naam = [
      'शैलपुत्री',
      'ब्रह्मचारिणी',
      'चन्द्रघण्टा',
      'कूष्माण्डा',
      'स्कन्दमाता',
      'कात्यायनी',
      'कालरात्रि',
      'महागौरी',
      'सिद्धिदात्री',
    ];

    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('नवदुर्गा के नौ नाम', style: type.cardTitle),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(naam.join(' · '), style: type.bodyMedium),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'देवी कवच · श्लोक ३–५',
            style: type.label.copyWith(color: colors.textSecondary),
          ),
        ],
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

/// एक पद — दोहा, चौपाई या आरती का पद।
class _KhandCard extends StatelessWidget {
  final PaathKhand khand;
  final bool arthDikhao;

  /// "दोहा १", "चौपाई ५" — चालीसा और स्तोत्र में दिखता है, आरती में नहीं।
  /// आरती में यह सिर्फ़ स्क्रीन-रीडर को सुनाई देता है।
  final bool shirshakDikhao;

  /// इस पद के **बाद** दोहराई जाने वाली पंक्तियाँ — आरती की टेक (→ D-083)।
  final PaathKhand? baadMein;

  const _KhandCard({
    super.key,
    required this.khand,
    this.arthDikhao = false,
    this.shirshakDikhao = true,
    this.baadMein,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final dohraav = baadMein;

    return VidhivatSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shirshakDikhao) ...[
            Text(khand.shirshak, style: type.label),
            const SizedBox(height: VidhivatSpacing.xs),
          ] else
            // दिखता नहीं, पर न देख सकने वाले को सुनाई दे — उसे पता
            // चलना चाहिए कि यह शुरुआत है या कौन सा पद।
            Semantics(label: khand.shirshak, child: const SizedBox.shrink()),
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
          if (dohraav != null && dohraav.hasPath && khand.hasPath) ...[
            const SizedBox(height: VidhivatSpacing.md),
            _Dohraav(khand: dohraav, romanDikhao: arthDikhao),
          ],
        ],
      ),
    );
  }
}

/// पद के बाद दोहराई जाने वाली टेक — **कोई लेबल नहीं**, सिर्फ़ रूप अलग।
///
/// हल्का रंग, थोड़ा अंदर, बाईं ओर एक पतली लकीर — ताकि आँख पद और टेक में
/// फ़र्क़ कर सके, और चाहे तो टेक छोड़कर अगले पद पर जा सके। "↻ फिर से"
/// जैसा लेबल जान-बूझकर नहीं: छपी आरती-पुस्तकों में भी नहीं होता, और
/// नब्बे पदों पर नब्बे बार एक ही शब्द शोर है (→ D-083)।
///
/// अर्थ यहाँ दोबारा नहीं — वह सबसे ऊपर एक बार है। रोमन दिखता है, क्योंकि
/// गाते वक़्त वही काम आता है।
class _Dohraav extends StatelessWidget {
  final PaathKhand khand;
  final bool romanDikhao;

  const _Dohraav({required this.khand, required this.romanDikhao});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return Semantics(
      label: 'हर पद के बाद दोहराएँ',
      container: true,
      child: Container(
        padding: const EdgeInsets.only(left: VidhivatSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colors.borderSubtle, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              khand.dev,
              style: type.mantra.copyWith(
                color: colors.textSecondary,
                fontSize: (type.mantra.fontSize ?? 20) * 0.88,
              ),
            ),
            if (romanDikhao && khand.roman.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                khand.roman,
                style: type.mantraTransliteration
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ],
        ),
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
