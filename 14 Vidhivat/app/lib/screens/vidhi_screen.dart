import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'samagri_screen.dart';
import 'vidhi_player_screen.dart';

/// एक पूजा का तैयारी-पन्ना। यह केवल मौजूदा Vidhi data को पढ़ने में आसान
/// क्रम में दिखाता है; धार्मिक पाठ, क्रम और स्रोत इसमें नहीं लिखे जाते।
class VidhiScreen extends StatefulWidget {
  final String id;

  const VidhiScreen({super.key, required this.id});

  @override
  State<VidhiScreen> createState() => _VidhiScreenState();
}

class _VidhiScreenState extends State<VidhiScreen> {
  late Future<Vidhi> _vidhi;

  @override
  void initState() {
    super.initState();
    _vidhi = vidhiBhandar.vidhi(widget.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Vidhi>(
        future: _vidhi,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('पूजा')),
              body: const SafeArea(
                child: VidhivatStateView(
                  title: 'यह पूजा नहीं खुल सकी',
                  message: 'वापस जाकर इसे फिर से खोलें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(title: const Text('पूजा')),
              body: const SafeArea(
                child: VidhivatStateView(
                  title: 'पूजा की जानकारी खुल रही है',
                  loading: true,
                ),
              ),
            );
          }
          return _PreparationDetail(vidhi: snapshot.data!);
        },
      );
}

/// "1 मंत्र का पाठ" बनाम "3 मंत्रों का पाठ"।
///
/// फ़ोन पर स्क्रीन कह रही थी *"इस पूजा के 1 मंत्रों का पाठ…"* — हिंदी
/// में एक के साथ बहुवचन नहीं चलता, और यह ठीक उस डिब्बे में था जिसे
/// यूज़र सबसे पहले पढ़ता है।
String _mantraGinti(int kitne) =>
    kitne == 1 ? '1 मंत्र का पाठ' : '$kitne मंत्रों का पाठ';

class _PreparationDetail extends StatefulWidget {
  final Vidhi vidhi;

  const _PreparationDetail({required this.vidhi});

  @override
  State<_PreparationDetail> createState() => _PreparationDetailState();
}

class _PreparationDetailState extends State<_PreparationDetail> {
  bool _isStartingOver = false;

  Vidhi get vidhi => widget.vidhi;

  void _openMaterials(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SamagriScreen(vidhi: vidhi)),
    );
  }

  void _startPuja(BuildContext context, {int initialStepIndex = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VidhiPlayerScreen(
          vidhi: vidhi,
          initialStepIndex: initialStepIndex,
        ),
      ),
    );
  }

  Future<void> _startOver(BuildContext context) async {
    if (_isStartingOver || !mounted) return;
    setState(() => _isStartingOver = true);
    await settings.clearPlayerProgress(vidhi.id);
    if (!context.mounted) return;
    _startPuja(context);
    if (mounted) setState(() => _isStartingOver = false);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: settings,
        builder: (context, child) {
          final colors = VidhivatTheme.colorsOf(context);
          final resume =
              settings.playerProgressFor(vidhi.id, vidhi.charan.length);

          return Scaffold(
            appBar: AppBar(title: const Text('पूजा की तैयारी')),
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
                    VidhivatSacredHero(
                      // ── एक ही बात तीन बार मत कहो ────────────────
                      //
                      // पहले "पूजा की तैयारी" तीन जगह एक साथ दिखता था —
                      // ऊपर AppBar में, यहाँ eyebrow में, और नीचे बटन
                      // पर। अब AppBar वो काम करता है, और यह जगह कुछ
                      // नया बताती है — पूजा किस तरह की है।
                      eyebrow: vidhi.shreni.naam,
                      title: vidhi.naam,
                      subtitle: vidhi.parichay,
                      icon: Icons.account_balance_outlined,
                      artworkAsset:
                          DevotionalAssets.forVidhiId(vidhi.id).assetPath,
                      artworkSemanticLabel:
                          DevotionalAssets.forVidhiId(vidhi.id).semanticLabel,
                      semanticLabel: '${vidhi.naam} की पूजा तैयारी',
                      footer: _PujaMetadata(vidhi: vidhi),
                    ),
                    if (resume != null) ...[
                      const SizedBox(height: VidhivatSpacing.lg),
                      _ResumePanel(
                        vidhi: vidhi,
                        resume: resume,
                        onShuruSeKaro: vidhi.scope.poorViDhiKholSakteHain
                            ? () => _startOver(context)
                            : null,
                        shuruHoRahaHai: _isStartingOver,
                      ),
                    ],
                    // ── यह पूजा कहाँ तक अपने आप की जा सकती है (→ D-035) ──
                    //
                    // कुछ विधियाँ अपने आप करने लायक हैं ही नहीं — उपनयन में
                    // आचार्य गायत्री का उपदेश देते हैं, मुंडन में बच्चे पर
                    // उस्तरा चलता है। ऐसी पूजाओं पर "विधि शुरू करें" वाला
                    // बटन नीचे दिखता ही नहीं।
                    if (vidhi.scope != Scope.selfGuided) ...[
                      const SizedBox(height: VidhivatSpacing.lg),
                      _TrustNotice(
                        title: vidhi.scope.naam,
                        text: vidhi.scope.batao,
                        serious: !vidhi.scope.poorViDhiKholSakteHain,
                      ),
                    ],
                    // ── "यह विधि कैसी है" वाला डिब्बा यहाँ था — अब ℹ के पीछे ──
                    //
                    // वो सच था, पर वो **28 में से 28 पूजाओं पर** दिखता था —
                    // `jaanch.paas` किसी JSON में `true` नहीं है, इसलिए
                    // `needsPanditReview` हमेशा सच रहता है। यानी यह शर्त नहीं,
                    // दीवार थी — और जो चेतावनी हर बार दिखे, वो चेतावनी रह
                    // ही नहीं जाती (→ D-042 का वही सबक़, छोटे पैमाने पर)।
                    //
                    // मिटाया कुछ नहीं — पूरी बात अब नीचे वाले ℹ "यह विधि कहाँ
                    // से आई" के अंदर है, जो ठीक यही सवाल पूछता है (→ D-056)।
                    //
                    // ⚠ स्कोप वाली चेतावनी (ऊपर) **ओथे ही रहती है** — वो
                    // सिर्फ़ तीन पूजाओं पर आती है और कहती है "यह अकेले करने
                    // की चीज़ नहीं" — वो छिपाने वाली बात नहीं है।
                    const SizedBox(height: VidhivatSpacing.xxl),
                    const VidhivatSectionHeader(title: 'कब करें'),
                    const SizedBox(height: VidhivatSpacing.sm),
                    _ContextCard(vidhi: vidhi),
                    const SizedBox(height: VidhivatSpacing.xxl),
                    VidhivatSectionHeader(
                      title: 'सामग्री',
                      supportingText:
                          '${vidhi.zaruriSamagri.length} ज़रूरी सामग्री',
                      action: VidhivatButton(
                        label: 'सभी देखें',
                        semanticLabel: '${vidhi.naam} की सभी सामग्री देखें',
                        onPressed: () => _openMaterials(context),
                        variant: VidhivatButtonVariant.text,
                        compact: true,
                      ),
                    ),
                    const SizedBox(height: VidhivatSpacing.sm),
                    _MaterialsPreview(vidhi: vidhi),
                    const SizedBox(height: VidhivatSpacing.xxl),
                    VidhivatSectionHeader(
                      title: 'विधि',
                      supportingText: '${vidhi.charan.length} चरणों की झलक',
                    ),
                    const SizedBox(height: VidhivatSpacing.sm),
                    _StepsPreview(vidhi: vidhi),
                    if (vidhi.sawaal.isNotEmpty) ...[
                      const SizedBox(height: VidhivatSpacing.xxl),
                      const VidhivatSectionHeader(title: 'आम सवाल'),
                      const SizedBox(height: VidhivatSpacing.sm),
                      _Questions(questions: vidhi.sawaal),
                    ],
                    // स्रोत अब ⓘ के पीछे — मिटाया नहीं, एक दबाव पीछे
                    // (→ D-045)। वही रूप जो चालीसा और मंत्र पर है।
                    const SizedBox(height: VidhivatSpacing.xl),
                    _SourceInformation(vidhi: vidhi),
                  ],
                ),
              ),
            ),
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
                  // ── नीचे **एक ही** बटन (→ D-048) ───────────────
                  //
                  // पहले यहाँ तीन बटन एक के नीचे एक थे — 320px, यानी
                  // काम की स्क्रीन का 22%, और वो ऊपर के chips को ढक भी
                  // रहे थे। तीनों बराबरी पर बैठे थे जबकि बराबर थे नहीं:
                  //
                  // • भरा हुआ बटन **सामग्री** खोलता था — और वही काम
                  //   ऊपर "सामग्री" शीर्षक के "सभी देखें" से भी होता है।
                  //   यानी एक ही पन्ने पर वही बटन दो बार।
                  // • असली काम — पूजा शुरू करना — फीके text-लिंक में था।
                  // • "शुरू से करें" उस कार्ड से 500px दूर था जिसके बारे
                  //   में वो है; अब वो `_ResumePanel` के अंदर चला गया।
                  //
                  // ⚠️ जिन पूजाओं की पूरी विधि खुलती ही नहीं (उपनयन,
                  // मुंडन — → D-035), वहाँ शुरू करने को कुछ है नहीं।
                  // उनके लिए सामग्री ही इकलौता काम है, इसलिए बटन वही बनता
                  // है — पट्टी कभी ख़ाली नहीं रहती।
                  child: vidhi.scope.poorViDhiKholSakteHain
                      ? VidhivatButton(
                          label: resume == null
                              ? 'पूजा शुरू करें'
                              : 'चरण ${resume.lastReachedStepIndex + 1} से जारी रखें',
                          semanticLabel: resume == null
                              ? '${vidhi.naam} शुरू करें'
                              : '${vidhi.naam} में चरण ${resume.lastReachedStepIndex + 1} से जारी रखें',
                          onPressed: _isStartingOver
                              ? null
                              : () => _startPuja(
                                    context,
                                    initialStepIndex:
                                        resume?.lastReachedStepIndex ?? 0,
                                  ),
                          icon: resume == null
                              ? Icons.play_arrow
                              : Icons.play_circle_outline,
                          fullWidth: true,
                        )
                      : VidhivatButton(
                          label: 'सामग्री की सूची देखें',
                          semanticLabel:
                              '${vidhi.naam} की सामग्री की सूची देखें',
                          onPressed: () => _openMaterials(context),
                          icon: Icons.checklist_outlined,
                          fullWidth: true,
                        ),
                ),
              ),
            ),
          );
        },
      );
}

/// "आप यहाँ तक पहुँचे थे" — और यहीं से **शुरू से करने** का रास्ता भी।
///
/// "शुरू से करें" पहले नीचे की पट्टी में था, इस कार्ड से पाँच सौ पिक्सल
/// दूर — जबकि वो इसी कार्ड की बात है (→ D-048)। जो चीज़ जिसके बारे में
/// हो, उसी के साथ रहनी चाहिए; तभी वो सन्दर्भ के साथ पढ़ी जाती है।
class _ResumePanel extends StatelessWidget {
  final Vidhi vidhi;
  final PujaPlayerProgress resume;
  final VoidCallback? onShuruSeKaro;
  final bool shuruHoRahaHai;

  const _ResumePanel({
    required this.vidhi,
    required this.resume,
    this.onShuruSeKaro,
    this.shuruHoRahaHai = false,
  });

  @override
  Widget build(BuildContext context) {
    final step = vidhi.charan[resume.lastReachedStepIndex];
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      semanticLabel:
          'आप यहाँ तक पहुँचे थे। चरण ${resume.lastReachedStepIndex + 1} में से ${vidhi.charan.length}: ${step.shirshak}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bookmark_outline,
            color: colors.info,
            size: VidhivatIconSize.medium,
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          Text('आप यहाँ तक पहुँचे थे', style: type.cardTitle),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(
            'चरण ${resume.lastReachedStepIndex + 1} / ${vidhi.charan.length}',
            style: type.label,
          ),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(step.shirshak, style: type.bodyMedium),
          if (onShuruSeKaro != null) ...[
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatButton(
              label: 'शुरू से करें',
              semanticLabel:
                  '${vidhi.naam} पहले चरण से शुरू करें, सहेजी हुई जगह हटाकर',
              onPressed: shuruHoRahaHai ? null : onShuruSeKaro,
              variant: VidhivatButtonVariant.secondary,
              icon: Icons.restart_alt,
              compact: true,
              // ⚠️ `fullWidth` ज़रूरी है। बिना इसके बटन अपनी चौड़ाई से
              // बनता है, और 320dp / 1.5x अक्षर पर "शुरू से करें" +
              // चिह्न कार्ड से **80px बाहर** निकल जाते थे।
              fullWidth: true,
              isLoading: shuruHoRahaHai,
            ),
          ],
        ],
      ),
    );
  }
}

class _PujaMetadata extends StatelessWidget {
  final Vidhi vidhi;

  const _PujaMetadata({required this.vidhi});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: VidhivatSpacing.xs,
        runSpacing: VidhivatSpacing.xs,
        children: [
          VidhivatStatusChip(
            label: vidhi.samayLikha,
            icon: Icons.schedule_outlined,
          ),
          VidhivatStatusChip(
            label: '${vidhi.charan.length} चरण',
            icon: Icons.format_list_numbered,
          ),
          // श्रेणी अब ऊपर eyebrow में है — यहाँ दोहराने की ज़रूरत नहीं।
          VidhivatStatusChip(
            label: '${vidhi.zaruriSamagri.length} ज़रूरी सामग्री',
            icon: Icons.checklist_outlined,
          ),
        ],
      );
}

class _TrustNotice extends StatelessWidget {
  final String title;
  final String text;
  final bool serious;

  const _TrustNotice({
    required this.title,
    required this.text,
    this.serious = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      variant: serious
          ? VidhivatCardVariant.warning
          : VidhivatCardVariant.information,
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            serious ? Icons.warning_amber_outlined : Icons.info_outline,
            color: serious ? colors.warning : colors.info,
            size: VidhivatIconSize.medium,
          ),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(text, style: type.bodySmall, textAlign: TextAlign.justify),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final Vidhi vidhi;

  const _ContextCard({required this.vidhi});

  @override
  Widget build(BuildContext context) => VidhivatSurfaceCard(
        variant: VidhivatCardVariant.information,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event_outlined, size: VidhivatIconSize.medium),
            const SizedBox(width: VidhivatSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vidhi.kabKarein.saral,
                    textAlign: TextAlign.justify,
                    style: VidhivatTheme.typographyOf(context).bodyMedium,
                  ),
                  if (vidhi.kabKarein.note.isNotEmpty) ...[
                    const SizedBox(height: VidhivatSpacing.xs),
                    Text(
                      vidhi.kabKarein.note,
                      textAlign: TextAlign.justify,
                      style: VidhivatTheme.typographyOf(context).bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _MaterialsPreview extends StatelessWidget {
  final Vidhi vidhi;

  const _MaterialsPreview({required this.vidhi});

  @override
  Widget build(BuildContext context) {
    final preview = vidhi.zaruriSamagri.take(3).toList(growable: false);
    return VidhivatSurfaceCard(
      child: Column(
        children: [
          for (var index = 0; index < preview.length; index++) ...[
            if (index > 0) const VidhivatDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.checklist_outlined,
                      size: VidhivatIconSize.small),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Expanded(
                    child: Text(
                      preview[index].vastu,
                      style: VidhivatTheme.typographyOf(context).bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (vidhi.zaruriSamagri.length > preview.length) ...[
            const VidhivatDivider(),
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.sm),
              child: Text(
                '${vidhi.zaruriSamagri.length - preview.length} और ज़रूरी सामग्री',
                style: VidhivatTheme.typographyOf(context).caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepsPreview extends StatelessWidget {
  final Vidhi vidhi;

  const _StepsPreview({required this.vidhi});

  @override
  Widget build(BuildContext context) {
    final preview = vidhi.charan.take(3).toList(growable: false);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      child: Column(
        children: [
          for (var index = 0; index < preview.length; index++) ...[
            if (index > 0) const VidhivatDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: VidhivatSpacing.xxl,
                    height: VidhivatSpacing.xxl,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryMuted,
                      borderRadius: VidhivatRadius.pill,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: VidhivatTheme.typographyOf(context).caption,
                    ),
                  ),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Expanded(
                    child: Text(
                      preview[index].shirshak,
                      style: VidhivatTheme.typographyOf(context).bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (vidhi.charan.length > preview.length) ...[
            const VidhivatDivider(),
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.sm),
              child: Text(
                'आगे ${vidhi.charan.length - preview.length} चरण और हैं',
                style: VidhivatTheme.typographyOf(context).caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Questions extends StatelessWidget {
  final List<SawaalJawaab> questions;

  const _Questions({required this.questions});

  @override
  Widget build(BuildContext context) => VidhivatSurfaceCard(
        child: Column(
          children: [
            for (var index = 0; index < questions.length; index++) ...[
              if (index > 0) const VidhivatDivider(),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(
                  left: VidhivatSpacing.md,
                  right: VidhivatSpacing.md,
                  bottom: VidhivatSpacing.md,
                ),
                title: Text(
                  questions[index].sawaal,
                  style: VidhivatTheme.typographyOf(context).bodyMedium,
                ),
                children: [
                  Text(
                    questions[index].jawaab,
                    textAlign: TextAlign.justify,
                    style: VidhivatTheme.typographyOf(context).bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}

class _SourceInformation extends StatelessWidget {
  final Vidhi vidhi;

  const _SourceInformation({required this.vidhi});

  @override
  Widget build(BuildContext context) => VidhivatSrotButton(
        label: 'यह विधि कहाँ से आई',
        panktiyan: [
          // ── यह पहली पंक्ति पहले ऊपर खुला डिब्बा थी (→ D-056) ──
          //
          // यह सबसे पहले आती है, पद्धति से भी पहले — जो आदमी
          // यह ℹ दबाता है वो यही पूछने आया है।
          const VidhivatSrotPankti(
            'यह विधि कैसी है',
            'यह घर की सरल पद्धति है। हर पाठ के नीचे उसका स्रोत लिखा है, '
            'और जहाँ एक से ज़्यादा चलन हैं वहाँ दोनों दिए गए हैं।',
          ),
          VidhivatSrotPankti('पद्धति', vidhi.strot.paddhati),
          VidhivatSrotPankti('क्षेत्र', vidhi.strot.kshetra),
          // ── "जाँच — अभी बाकी है" वाली पंक्ति सिर्फ़ पास होने पर ──
          //
          // पहले यह हमेशा दिखती थी, और न होने पर नारंगी रंग में
          // "अभी बाकी है" लिखती थी (→ D-043)। पद्धति और क्षेत्र लिखा
          // होना अपने आप में जवाब है; अधूरी मुहर का ऐलान करना नहीं।
          // मुहर लग जाए तो वो अच्छी ख़बर है — तब पूरी दिखती है।
          if (vidhi.jaanch.paas)
            VidhivatSrotPankti(
              'जाँच',
              '${vidhi.jaanch.panditNaam} · ${vidhi.jaanch.tarikh}',
            ),
          // कितने मंत्र अभी ख़ाली हैं — यह भी यहीं, गिनकर।
          //
          // ⚠ इससे वो चेतावनी नहीं हटती जो हर ख़ाली कदम पर खुली
          // मिलती है — वहाँ ऐप अपनी कमी मान रहा होता है, और वो
          // छिपती नहीं (→ D-049)। यहाँ सिर्फ़ कुल गिनती है।
          if (vidhi.mantraKul > vidhi.mantraBhareHue)
            VidhivatSrotPankti(
              'अभी क्या कम है',
              'इसमें ${_mantraGinti(vidhi.mantraKul - vidhi.mantraBhareHue)} '
              'अभी जोड़ा नहीं गया — जब तक प्रामाणिक स्रोत से न आए, हम '
              'अंदाज़े से कुछ नहीं लिखेंगे। जिस कदम पर पाठ नहीं है, वहाँ वो '
              'साफ़ लिखा मिलेगा।',
            ),
          VidhivatSrotPankti('और', vidhi.strot.note),
        ],
        antimBaat: 'आपके घर या क्षेत्र की परंपरा अलग हो तो वही सही है।',
      );
}
