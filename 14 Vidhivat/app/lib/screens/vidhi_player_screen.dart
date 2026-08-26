import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
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
/// गया — वो 1 स्टार देगा और लिखेगा कि ऐप ने पूजा भ्रष्ट कर दी। Drik
/// Panchang की सबसे बड़ी शिकायत यही है; उसकी सबसे बड़ी कमज़ोरी को अपनी
/// सबसे बड़ी ताक़त बनाना है। **यहाँ कोई ad widget मत जोड़ना।**
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VidhivatSpacing.lg,
              VidhivatSpacing.sm,
              VidhivatSpacing.lg,
              VidhivatSpacing.md,
            ),
            child: _CharanNavigation(
              first: _index == 0,
              last: aakhri,
              title: vidhi.naam,
              onPrevious: () => _jao(_index - 1),
              onContinue: aakhri ? _poojaPuriKaro : () => _jao(_index + 1),
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
          ),
        ),
        if (charan.samayMinute > 0) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          VidhivatStatusChip(
            label: 'लगभग ${charan.samayMinute} मिनट',
            icon: Icons.schedule_outlined,
          ),
        ],
        if (charan.vishesh == CharanVishesh.sankalp) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          const VidhivatSectionHeader(title: 'संकल्प'),
          const SizedBox(height: VidhivatSpacing.sm),
          _SankalpKhand(vidhi: vidhi),
        ],
        if (charan.vishesh == CharanVishesh.katha) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          const Chetavni(
            'कथा का पूरा पाठ अभी ऐप में नहीं जोड़ा गया है। तब तक अपनी '
            'कथा-पुस्तिका से पढ़ें।',
          ),
        ],
        if (charan.mantra != null) ...[
          const SizedBox(height: VidhivatSpacing.xxl),
          _MantraKhand(mantra: charan.mantra!),
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
          style: VidhivatTheme.typographyOf(context).bodySmall,
        ),
        const SizedBox(height: VidhivatSpacing.md),
        if (sankalp.needsPanditReview)
          const Chetavni(
            'संकल्प के मान पंचांग से बने हैं और जाँचे हुए हैं, पर संस्कृत '
            'का रूप अभी पंडित जी से पास नहीं हुआ है।',
            serious: true,
          ),
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

/// मंत्र वाला हिस्सा।
///
/// पाठ न भरा हो तो **ख़ाली डिब्बा दिखाते हैं, बना हुआ मंत्र नहीं।**
/// अंदाज़े से मंत्र लिखना इस प्रोजेक्ट में सबसे बड़ी ग़लती मानी गई है —
/// मंत्र ग़लत होना तिथि ग़लत होने से भी बुरा है।
class _MantraKhand extends StatelessWidget {
  final Mantra mantra;

  const _MantraKhand({required this.mantra});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    if (!mantra.hasPath) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VidhivatSectionHeader(title: 'मंत्र'),
          const SizedBox(height: VidhivatSpacing.sm),
          const Chetavni(
            'इस कदम का मंत्र अभी ऐप में नहीं जोड़ा गया है। जब तक प्रामाणिक '
            'स्रोत से न आ जाए, हम अंदाज़े से कुछ नहीं लिखेंगे — तब तक अपनी '
            'पूजा-पुस्तिका से पढ़ें, या मन ही मन भगवान का नाम लें।',
          ),
          if (mantra.vikalp.isNotEmpty)
            Text(mantra.vikalp, style: type.bodySmall),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VidhivatSectionHeader(title: 'मंत्र'),
        const SizedBox(height: VidhivatSpacing.sm),
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.elevated,
          padding: const EdgeInsets.all(VidhivatSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // सबसे बड़ा अक्षर पूरे ऐप में — यही बोलकर पढ़ा जाता है।
              SelectableText(mantra.devanagari, style: type.mantra),
              if (mantra.roman.isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                const VidhivatDivider(),
                const SizedBox(height: VidhivatSpacing.sm),
                Text('उच्चारण', style: type.label),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(mantra.roman, style: type.mantraTransliteration),
              ],
              if (mantra.arth.isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                const VidhivatDivider(),
                const SizedBox(height: VidhivatSpacing.sm),
                Text('अर्थ', style: type.label),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(mantra.arth, style: type.mantraMeaning),
              ],
            ],
          ),
        ),
        const SizedBox(height: VidhivatSpacing.md),

        if (mantra.needsPanditReview)
          Chetavni(
            'यह मंत्र अभी पंडित जी से पास नहीं हुआ है '
            '(भरोसा — ${mantra.bharosa.naam})।',
            serious: true,
          ),

        // ── जहाँ एक से ज़्यादा चलन हैं, वो छिपाना नहीं है ──
        //
        // पंडित जी के लिए यही सबसे काम की लाइन है — वे यहीं बता देंगे कि
        // आपके घर में कौन सा रूप चलता है।
        if (mantra.vikalp.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
            child: Text(
              'दूसरा चलन — ${mantra.vikalp}',
              style: type.bodySmall,
            ),
          ),

        if (mantra.strot.isNotEmpty)
          VidhivatSurfaceCard(
            variant: VidhivatCardVariant.information,
            padding: const EdgeInsets.all(VidhivatSpacing.md),
            child: Text(
              'स्रोत — ${mantra.strot}',
              style: type.bodySmall,
            ),
          ),
      ],
    );
  }
}
