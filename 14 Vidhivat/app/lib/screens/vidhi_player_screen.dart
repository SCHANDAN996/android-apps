import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/vidhi.dart';
import '../vidhi/instructional_assets.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/katha_khand.dart';
import '../widgets/mantra_khand.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/granth.dart';
import '../vidhi/paath.dart';
import 'granth_screen.dart';
import 'paath_screen.dart';
import 'puja_completion_screen.dart';
import 'samagri_screen.dart';
import 'sankalp_screen.dart';

/// विधि प्लेयर — **यहीं असली पूजा होती है।**
///
/// यह पन्ना बाक़ी ऐप से अलग है, क्योंकि इसकी हालत अलग है: आदमी ज़मीन पर
/// बैठा है, हाथ में जल है, फ़ोन दो फ़ुट दूर रखा है, और वो पढ़ते-पढ़ते
/// बोल रहा है। इसलिए —
///
/// - **अक्षर बहुत बड़े।** मंत्र 26px पर, विवरण 20px पर।
/// - **स्क्रीन बंद नहीं होती** (`WakelockPlus`) — बीच पूजा में फ़ोन
///   काला हो जाना सबसे बुरी बात है।
/// - **एक कदम, एक पन्ना।** नीचे बड़े बटन, ताकि गीली उँगली से भी लगें।
///
/// ## ⛔ इस स्क्रीन पर विज्ञापन कभी नहीं (→ D-008)
/// चाहे मुफ़्त यूज़र हो। आदमी संकल्प ले रहा है और स्क्रीन पर विज्ञापन आ
/// गया — वो 1 स्टार देगा और लिखेगा कि ऐप ने पूजा भ्रष्ट कर दी। दूसरे
/// पूजा ऐपों में बीच अनुष्ठान आने वाले विज्ञापनों की शिकायत आम है;
/// Vidhivat में यही अनुभव साफ़ रहना चाहिए। **यहाँ कोई ad widget मत जोड़ना।**
class VidhiPlayerScreen extends StatefulWidget {
  final Vidhi vidhi;
  final int initialStepIndex;

  const VidhiPlayerScreen({
    super.key,
    required this.vidhi,
    this.initialStepIndex = 0,
  });

  @override
  State<VidhiPlayerScreen> createState() => _VidhiPlayerScreenState();
}

class _VidhiPlayerScreenState extends State<VidhiPlayerScreen> {
  late final PageController _pages;
  int _index = 0;
  bool _isLeaving = false;
  Future<void>? _pendingProgressWrite;

  Vidhi get vidhi => widget.vidhi;

  @override
  void initState() {
    super.initState();
    _index = vidhi.charan.isEmpty
        ? 0
        : widget.initialStepIndex.clamp(0, vidhi.charan.length - 1).toInt();
    _pages = PageController(initialPage: _index);
    _screenJagaayeRakho(true);
  }

  @override
  void dispose() {
    // पूजा ख़त्म — अब स्क्रीन को सामान्य की तरह बंद होने दो, वरना
    // बैटरी यूँ ही ख़त्म होती रहेगी।
    _screenJagaayeRakho(false);
    _pages.dispose();
    super.dispose();
  }

  /// कुछ फ़ोन/प्लेटफ़ॉर्म पर यह नहीं चलता। उसके लिए पूरी पूजा रुकनी
  /// नहीं चाहिए, इसलिए चुपचाप छोड़ देते हैं।
  Future<void> _screenJagaayeRakho(bool jagaao) async {
    try {
      await WakelockPlus.toggle(enable: jagaao);
    } catch (_) {
      // कोई बात नहीं — बस स्क्रीन सामान्य की तरह बंद होगी।
    }
  }

  void _jao(int naya) {
    if (naya < 0 || naya >= vidhi.charan.length) return;
    _pages.animateToPage(
      naya,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : VidhivatMotion.standard,
      curve: Curves.easeOut,
    );
  }

  void _kholoCharanSuchi() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _CharanSuchiSheet(
        charan: vidhi.charan,
        currentIndex: _index,
        onSelect: (index) {
          Navigator.of(sheetContext).pop();
          _jao(index);
        },
      ),
    );
  }

  Future<void> _poojaPuriKaro() async {
    if (_isLeaving || !mounted) return;
    _isLeaving = true;
    // अंतिम PageView change की local write पहले पूरी हो जाए, फिर clear करें।
    // इससे late write completion के बाद stale resume record वापस नहीं बनता।
    await _pendingProgressWrite;
    await settings.clearPlayerProgress(vidhi.id);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PujaCompletionScreen(vidhi: vidhi)),
    );
  }

  void _saveLastReachedStep(int index) {
    _pendingProgressWrite = settings.recordLastReachedStep(
      pujaId: vidhi.id,
      stepIndex: index,
      totalSteps: vidhi.charan.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kul = vidhi.charan.length;
    if (kul == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(vidhi.naam)),
        body: const Panna(
          children: [
            Chetavni(
              'इस विधि में कोई चरण उपलब्ध नहीं है। कृपया वापस जाकर इसे फिर से खोलें।',
              icon: Icons.error_outline,
              serious: true,
            ),
          ],
        ),
      );
    }
    final aakhri = _index == kul - 1;
    final vaikalpik = vidhi.charan[_index].vaikalpik;
    final colors = VidhivatTheme.colorsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(vidhi.naam),
        actions: [
          VidhivatIconAction(
            tooltip: 'चरणों की सूची',
            onPressed: _kholoCharanSuchi,
            icon: Icons.format_list_numbered,
          ),
          VidhivatIconAction(
            tooltip: 'सामग्री',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SamagriScreen(vidhi: vidhi)),
            ),
            icon: Icons.checklist_outlined,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / kul,
            minHeight: 4,
          ),
        ),
      ),

      body: VidhivatSacredBackdrop(
        child: PageView.builder(
          controller: _pages,
          itemCount: kul,
          // ⚡ अगला (और पिछला) कदम पहले से बना रहता है — उसकी तस्वीर decode
          // और कथा की फ़ाइल swipe शुरू होने से पहले ही तैयार। पहले "आगे"
          // दबाते ही यह सब एक साथ होता था, और सस्ते फ़ोन पर तस्वीर एक पल
          // बाद "कूदकर" आती थी।
          allowImplicitScrolling: true,
          onPageChanged: (i) {
            setState(() => _index = i);
            _saveLastReachedStep(i);
          },
          itemBuilder: (context, i) => _CharanPanna(
            vidhi: vidhi,
            charan: vidhi.charan[i],
            number: i + 1,
            total: kul,
          ),
        ),
      ),

      // ── नीचे के बटन — बड़े, ताकि गीली उँगली से भी लगें ──
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevated,
          border: Border(top: BorderSide(color: colors.borderSubtle)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: VidhivatReadableWidth(
            // लेटे रूप में यह बटन 853dp चौड़ा हो जाता था (→ D-062)।
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VidhivatSpacing.lg,
                VidhivatSpacing.sm,
                VidhivatSpacing.lg,
                VidhivatSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CharanNavigation(
                    first: _index == 0,
                    last: aakhri,
                    title: vidhi.naam,
                    onPrevious: () => _jao(_index - 1),
                    onContinue:
                        aakhri ? _poojaPuriKaro : () => _jao(_index + 1),
                  ),
                  if (vaikalpik && !aakhri) ...[
                    const SizedBox(height: VidhivatSpacing.xs),
                    VidhivatButton(
                      key: const Key('skip_optional_step'),
                      label: 'यह वैकल्पिक कदम छोड़ें',
                      onPressed: () => _jao(_index + 1),
                      variant: VidhivatButtonVariant.text,
                      fullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// एक कदम का पूरा पन्ना।
class _CharanPanna extends StatelessWidget {
  final Vidhi vidhi;
  final Charan charan;
  final int number;
  final int total;

  const _CharanPanna({
    required this.vidhi,
    required this.charan,
    required this.number,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final instructionalArtwork = InstructionalAssets.forStep(
      vidhiId: vidhi.id,
      title: charan.shirshak,
    );

    return Panna(
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        VidhivatSpacing.lg,
        VidhivatSpacing.lg,
        VidhivatSpacing.xxl,
      ),
      children: [
        _CharanHeader(number: number, total: total, title: charan.shirshak),
        const SizedBox(height: VidhivatSpacing.xxl),
        const VidhivatSectionHeader(title: 'अब क्या करें'),
        const SizedBox(height: VidhivatSpacing.sm),
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.highlight,
          child: Text(
            charan.vivaran,
            style: VidhivatTheme.typographyOf(context).bodyLarge,
            textAlign: TextAlign.justify,
          ),
        ),
        if (instructionalArtwork != null) ...[
          const SizedBox(height: VidhivatSpacing.xl),
          Semantics(
            image: true,
            label: instructionalArtwork.semanticLabel,
            child: Center(
              child: SizedBox(
                height: 192,
                child: Image.asset(
                  instructionalArtwork.assetPath,
                  fit: BoxFit.contain,
                  cacheHeight: 384,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ],
        if (charan.samayMinute > 0) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          VidhivatStatusChip(
            label: 'लगभग ${charan.samayMinute} मिनट',
            icon: Icons.schedule_outlined,
          ),
        ],
        if (charan.vaikalpik) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          const VidhivatStatusChip(label: 'वैकल्पिक', icon: Icons.tune),
        ],
        if (charan.vishesh == CharanVishesh.sankalp) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          const VidhivatSectionHeader(title: 'संकल्प'),
          const SizedBox(height: VidhivatSpacing.sm),
          _SankalpKhand(vidhi: vidhi),
        ],
        if (charan.vishesh == CharanVishesh.katha) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          // ── कथा (→ D-060) ──────────────────────────────
          //
          // पहले यहाँ सिर्फ़ लिखा था "कथा अभी जोड़ी नहीं गई"। अब जो
          // जुड़ चुकी है वो खुलती है, और जो नहीं जुड़ी उस पर वही ईमानदार
          // वाक्य रहता है।
          // जिस कदम पर ग्रंथ का बटन है (कृष्ण पूजा में गीता), वहाँ "पाठ
          // ऐप में नहीं है" कहना झूठ होता — वही बात जो आरती पर थी
          // (→ D-049)।
          if (charan.katha.isEmpty && charan.granth.isEmpty)
            const Chetavni(
              'कथा का पूरा पाठ अभी ऐप में नहीं जोड़ा गया है। तब तक अपनी '
              'कथा-पुस्तिका से पढ़ें।',
            )
          else if (charan.katha.isNotEmpty)
            KathaKhand(id: charan.katha),
        ],
        // ग्रंथ वाले कदम पर सीधे ग्रंथ खोलने का रास्ता (→ D-098)।
        if (charan.granth.isNotEmpty) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          _GranthKholo(ids: charan.granthSuchi),
        ],
        // आरती वाले कदम पर सीधे आरती खोलने का रास्ता (→ D-039)।
        // पाठ यहाँ दोहराया नहीं जाता — वो एक ही जगह रहता है।
        if (charan.paath.isNotEmpty) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          _PaathKholo(ids: charan.paath),
        ],
        // ── जिस कदम का पाठ ऊपर बटन में है, वहाँ "मंत्र नहीं है"
        //     वाली चेतावनी झूठ है (→ D-049) ──────────────────────────
        //
        // आरती वाले कदम पर मंत्र जान-बूझकर ख़ाली है — आरती का पूरा पाठ
        // `assets/paath/` में एक ही जगह रहता है और ऊपर वाला बटन उसे
        // वहीं से खोल देता है (→ D-039)। फिर भी ऐप नीचे लिखता था
        // *"इस कदम का मंत्र अभी ऐप में नहीं जोड़ा गया है"* — यानी
        // पाठ की ओर उँगली उठाकर साथ ही कहना कि पाठ है ही नहीं।
        //
        // वही उल्टी बात जो चालीसा पर थी ("43/43 पद भरे हैं, पर जाँच
        // बाकी") — और वही इलाज: जहाँ चीज़ मौजूद है वहाँ चेतावनी मत दो।
        if (charan.mantra != null &&
            !(charan.paath.isNotEmpty && !charan.mantra!.hasPath)) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          MantraKhand(mantra: charan.mantra!),
        ],
      ],
    );
  }
}

class _CharanHeader extends StatelessWidget {
  final int number;
  final int total;
  final String title;

  const _CharanHeader({
    required this.number,
    required this.total,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'चरण $number में से $total',
      child: VidhivatSacredHero(
        eyebrow: 'चरण $number / $total',
        title: title,
        subtitle: '',
        compact: true,
        icon: Icons.local_fire_department_outlined,
        semanticLabel: 'चरण $number में से $total। $title',
        footer: LinearProgressIndicator(
          value: number / total,
          minHeight: VidhivatSpacing.xxs,
        ),
      ),
    );
  }
}

class _CharanNavigation extends StatelessWidget {
  final bool first;
  final bool last;
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onContinue;

  const _CharanNavigation({
    required this.first,
    required this.last,
    required this.title,
    required this.onPrevious,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final continueLabel = last ? 'पूजा पूर्ण करें' : 'आगे बढ़ें';
    final continueSemantic = last ? '$title पूर्ण करें' : '$title का अगला चरण';
    if (first) {
      return VidhivatButton(
        label: continueLabel,
        semanticLabel: continueSemantic,
        onPressed: onContinue,
        icon: last ? Icons.check_circle_outline : Icons.arrow_forward,
        fullWidth: true,
      );
    }

    return Row(
      children: [
        Expanded(
          child: VidhivatButton(
            label: 'पीछे',
            semanticLabel: '$title का पिछला चरण',
            onPressed: onPrevious,
            icon: Icons.arrow_back,
            variant: VidhivatButtonVariant.secondary,
            compact: true,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: VidhivatSpacing.sm),
        Expanded(
          flex: 2,
          child: VidhivatButton(
            label: continueLabel,
            semanticLabel: continueSemantic,
            onPressed: onContinue,
            icon: last ? Icons.check_circle_outline : Icons.arrow_forward,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _CharanSuchiSheet extends StatelessWidget {
  final List<Charan> charan;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _CharanSuchiSheet({
    required this.charan,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VidhivatSpacing.lg,
          VidhivatSpacing.sm,
          VidhivatSpacing.lg,
          VidhivatSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VidhivatSectionHeader(
              title: 'पूजा के चरण',
              supportingText: 'किसी चरण पर जाने के लिए चुनें',
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            Expanded(
              child: ListView.separated(
                key: const Key('charan_overview_list'),
                itemCount: charan.length,
                separatorBuilder: (context, index) => const VidhivatDivider(),
                itemBuilder: (context, index) {
                  final current = index == currentIndex;
                  final visited = index < currentIndex;
                  final status = visited
                      ? 'इस सत्र में देखा गया'
                      : current
                          ? 'अभी यह चरण खुला है'
                          : 'आगे का चरण';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: VidhivatSpacing.xs,
                    leading: Icon(
                      visited
                          ? Icons.visibility_outlined
                          : current
                              ? Icons.play_circle_outline
                              : Icons.circle_outlined,
                      color: visited || current
                          ? colors.primary
                          : colors.textTertiary,
                    ),
                    title: Text(
                      charan[index].shirshak,
                      textAlign: TextAlign.justify,
                      style: VidhivatTheme.typographyOf(context).bodyMedium,
                    ),
                    subtitle: Text(status),
                    selected: current,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// संकल्प वाला कदम — **यहीं ऐप अपना सबसे बड़ा काम करता है।**
///
/// पंचांग इंजन से आज का पूरा संकल्प वाक्य बनकर सामने आ जाता है, संवत् से
/// नक्षत्र तक सब भरा हुआ। यही वो जगह है जहाँ हर आदमी अटकता है (→ D-006)।
class _SankalpKhand extends StatefulWidget {
  final Vidhi vidhi;

  const _SankalpKhand({required this.vidhi});

  @override
  State<_SankalpKhand> createState() => _SankalpKhandState();
}

class _SankalpKhandState extends State<_SankalpKhand> {
  bool _pooraRoop = true;

  @override
  Widget build(BuildContext context) {
    if (!settings.hasYajman) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chetavni(
            'संकल्प में आपका नाम और गोत्र बोला जाता है। एक बार भर दीजिए — '
            'फिर हर पूजा में अपने आप आ जाएगा।',
          ),
          VidhivatButton(
            label: 'नाम और गोत्र भरिए',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NaamPoochho(onDone: () {
                  Navigator.of(context).pop();
                  setState(() {});
                }),
              ),
            ),
            icon: Icons.person_outline,
            fullWidth: true,
          ),
        ],
      );
    }

    final p = settings.panchangFor(DateTime.now());
    final sankalp = buildSankalp(
      p,
      SankalpDetails(
        name: settings.name,
        gotra: settings.gotra,
        place: settings.city.name,
        purpose: commonPurposes[widget.vidhi.sankalpPurpose] ?? 'देवपूजनं',
        yajaman: settings.yajaman,
        sthanPrakar: settings.sthanPrakar,
      ),
    );
    final path = _pooraRoop ? sankalp.full : sankalp.simple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerSankalpFormatSelector(
          full: _pooraRoop,
          onChanged: (value) => setState(() => _pooraRoop = value),
        ),
        const SizedBox(height: VidhivatSpacing.md),
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.elevated,
          semanticLabel: 'बना हुआ ${_pooraRoop ? 'पूरा' : 'सरल'} संकल्प',
          child: SelectableText(
            path,
            textAlign: TextAlign.justify,
            style: VidhivatTheme.typographyOf(context).mantra.copyWith(
                  fontSize:
                      VidhivatTheme.typographyOf(context).bodyLarge.fontSize,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        Text(
          '${tarikh(DateTime.now())} · ${settings.city.name} · '
          '${p.varaName} · ${p.masaFullName} ${p.pakshaName} ${p.tithi.name}',
          textAlign: TextAlign.justify,
          style: VidhivatTheme.typographyOf(context).bodySmall,
        ),
        // ── यहाँ पहले पद्धति वाली चेतावनी भी छपती थी — अब नहीं ───────
        //
        // वही बात तीन जगह एक साथ लिखी जा रही थी — पूजा की तैयारी
        // वाले पन्ने पर, संकल्प वाले पन्ने पर, और यहाँ। और `needsPanditReview`
        // अभी **हमेशा** सच है (28/28 पूजाओं पर, और संकल्प में तो
        // default ही `true` है) — यानी यह शर्त नहीं, दीवार थी।
        //
        // जो चेतावनी हर बार दिखे, वो चेतावनी रह ही नहीं जाती (→ D-042)।
        // और यहाँ आदमी जमीन पर बैठा संकल्प बोल रहा है — यह वो पल
        // नहीं जब उसे पद्धतियों का भेद पढ़ना है। पूरी बात संकल्प वाले
        // अपने पन्ने के ℹ में है (→ D-056)।
      ],
    );
  }
}

class _PlayerSankalpFormatSelector extends StatelessWidget {
  final bool full;
  final ValueChanged<bool> onChanged;

  const _PlayerSankalpFormatSelector({
    required this.full,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final baseSize = VidhivatTheme.typographyOf(context).bodyMedium.fontSize!;
    final vertical = media.size.width < 360 ||
        media.textScaler.scale(baseSize) > baseSize * 1.25;

    if (vertical) {
      return VidhivatSurfaceCard(
        padding: EdgeInsets.zero,
        child: RadioGroup<bool>(
          groupValue: full,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: const Column(
            children: [
              RadioListTile<bool>(
                value: true,
                title: Text('पूरा संकल्प'),
              ),
              RadioListTile<bool>(
                value: false,
                title: Text('सरल (हिंदी में)'),
              ),
            ],
          ),
        ),
      );
    }

    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('पूरा संकल्प')),
        ButtonSegment(value: false, label: Text('सरल (हिंदी में)')),
      ],
      selected: {full},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// आरती वाले कदम पर — "आरती खोलें" (→ D-039)।
///
/// ## यहाँ पाठ क्यों नहीं छपता
///
/// आरती हर पूजा के अंत में आती है — ऐप में **पंद्रह कदमों पर।** उसका
/// पाठ पंद्रह जगह दोहराना सबसे बुरा तरीक़ा होता: एक जगह सुधार करो तो
/// चौदह जगह पुरानी रह जाएँ।
///
/// इसलिए पाठ एक ही जगह रहता है — `assets/paath/` में — और यह बटन उसे
/// वहीं से खोल देता है। एक बार वहाँ आरती भर जाए, तो **पंद्रहों जगह एक
/// साथ जुड़ जाती है।**
///
/// एक कदम पर एक से ज़्यादा भी हो सकती हैं (दीपावली में गणेश और लक्ष्मी
/// दोनों की), इसलिए यह सूची लेता है।
class _PaathKholo extends StatefulWidget {
  final List<String> ids;

  const _PaathKholo({required this.ids});

  @override
  State<_PaathKholo> createState() => _PaathKholoState();
}

class _PaathKholoState extends State<_PaathKholo> {
  // ⚡ future एक बार — `build()` के अंदर `paathBhandar.suchi()` लिखने से हर
  // rebuild पर नया future बनता था।
  late final Future<List<PaathSuchiEntry>> _suchi = paathBhandar.suchi();

  List<String> get ids => widget.ids;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaathSuchiEntry>>(
      future: _suchi,
      builder: (context, snap) {
        final suchi = snap.data;
        if (suchi == null) return const SizedBox.shrink();

        final mile = [
          for (final id in ids) ...suchi.where((e) => e.id == id),
        ];
        if (mile.isEmpty) return const SizedBox.shrink();

        // ⚠️ शीर्षक तय नहीं, पीछे जो है उससे बनता है। पहले यहाँ हमेशा
        // "आरती" लिखा था — और हनुमान पूजा में उसके नीचे **चालीसा** का
        // बटन आ गया। जो लिखा है और जो खुलता है, दोनों एक होने चाहिए।
        final prakar = {for (final e in mile) e.prakar};
        final shirshak = prakar.length == 1 ? prakar.first.naam : 'पाठ';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VidhivatSectionHeader(title: shirshak),
            const SizedBox(height: VidhivatSpacing.sm),
            for (final e in mile) ...[
              VidhivatButton(
                label: e.naam,
                semanticLabel: '${e.naam} खोलें',
                icon: Icons.menu_book_outlined,
                variant: VidhivatButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PaathScreen(id: e.id)),
                ),
              ),
              const SizedBox(height: VidhivatSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// कदम पर लिखे ग्रंथ का पन्ना खोलने वाला बटन (→ D-098)।
///
/// [_PaathKholo] जैसा ही, पर यह एक पाठ नहीं, पूरे ग्रंथ की अध्याय-सूची
/// खोलता है — वहाँ से जो अध्याय पढ़ना हो वह चुना जाता है, और ग्रंथ याद
/// रखता है कि पिछली बार कहाँ तक पहुँचे थे।
class _GranthKholo extends StatefulWidget {
  /// एक या ज़्यादा ग्रंथ — शीर्षक एक बार, हर ग्रंथ का अपना बटन (→ D-107)।
  final List<String> ids;

  const _GranthKholo({required this.ids});

  @override
  State<_GranthKholo> createState() => _GranthKholoState();
}

class _GranthKholoState extends State<_GranthKholo> {
  late final Future<List<GranthSuchiEntry>> _suchi = granthBhandar.suchi();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GranthSuchiEntry>>(
      future: _suchi,
      builder: (context, snap) {
        final sab = [...?snap.data, GranthSuchiEntry.saptashati];
        final mile = [
          for (final id in widget.ids) ...sab.where((g) => g.id == id),
        ];
        if (snap.data == null || mile.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VidhivatSectionHeader(title: 'पाठ'),
            const SizedBox(height: VidhivatSpacing.sm),
            for (final mila in mile) ...[
              VidhivatButton(
                label: mila.naam,
                semanticLabel: '${mila.naam} खोलें',
                icon: Icons.auto_stories_outlined,
                variant: VidhivatButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => GranthScreen(granth: mila)),
                ),
              ),
              const SizedBox(height: VidhivatSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}
