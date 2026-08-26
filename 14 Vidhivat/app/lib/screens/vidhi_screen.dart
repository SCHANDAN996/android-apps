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
          final mantraAdhure = vidhi.mantraKul - vidhi.mantraBhareHue;
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
                      eyebrow: 'पूजा की तैयारी',
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
                    if (vidhi.needsPanditReview) ...[
                      const SizedBox(height: VidhivatSpacing.lg),
                      const _TrustNotice(
                        title: 'जाँच बाकी है',
                        text:
                            'यह विधि अभी किसी पंडित जी से जाँच करवाकर पास नहीं हुई है। '
                            'ढाँचा आम घरेलू चलन के अनुसार है — अपने घर की परंपरा से '
                            'मिला लीजिए।',
                        serious: true,
                      ),
                    ],
                    if (mantraAdhure > 0) ...[
                      const SizedBox(height: VidhivatSpacing.sm),
                      _TrustNotice(
                        title: 'मंत्रों के बारे में',
                        text:
                            'इस पूजा के $mantraAdhure मंत्रों का पाठ अभी ऐप में जोड़ा नहीं '
                            'गया है। जब तक प्रामाणिक स्रोत से न आ जाए, हम अंदाज़े से कुछ '
                            'नहीं लिखेंगे।',
                      ),
                    ],
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
                    const SizedBox(height: VidhivatSpacing.xxl),
                    const VidhivatSectionHeader(title: 'यह विधि कहाँ से आई'),
                    const SizedBox(height: VidhivatSpacing.sm),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VidhivatButton(
                        label: 'पूजा की तैयारी करें',
                        semanticLabel: '${vidhi.naam} की तैयारी करें',
                        onPressed: () => _openMaterials(context),
                        icon: Icons.checklist_outlined,
                        fullWidth: true,
                      ),
                      if (vidhi.scope.poorViDhiKholSakteHain)
                      VidhivatButton(
                        label: resume == null
                            ? 'अभी विधि शुरू करें'
                            : 'यहीं से जारी रखें',
                        semanticLabel: resume == null
                            ? '${vidhi.naam} अभी शुरू करें'
                            : '${vidhi.naam} में चरण ${resume.lastReachedStepIndex + 1} से जारी रखें',
                        onPressed: _isStartingOver
                            ? null
                            : () => _startPuja(
                                  context,
                                  initialStepIndex:
                                      resume?.lastReachedStepIndex ?? 0,
                                ),
                        // 320dp / 1.5x पर यह वाक्य icon के साथ बहुत संकरा हो
                        // जाता है; यहाँ पूरा शब्द पढ़ पाना decorative icon से
                        // ज़्यादा उपयोगी है।
                        icon: resume == null ? Icons.play_arrow : null,
                        variant: VidhivatButtonVariant.text,
                        compact: resume != null,
                        fullWidth: true,
                      ),
                      if (resume != null && vidhi.scope.poorViDhiKholSakteHain)
                        VidhivatButton(
                          label: 'शुरू से करें',
                          semanticLabel: '${vidhi.naam} शुरू से करें',
                          onPressed: _isStartingOver
                              ? null
                              : () => _startOver(context),
                          variant: VidhivatButtonVariant.text,
                          compact: true,
                          fullWidth: true,
                          isLoading: _isStartingOver,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _ResumePanel extends StatelessWidget {
  final Vidhi vidhi;
  final PujaPlayerProgress resume;

  const _ResumePanel({required this.vidhi, required this.resume});

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
          VidhivatStatusChip(label: vidhi.shreni.naam),
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
                Text(text, style: type.bodySmall),
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
                    style: VidhivatTheme.typographyOf(context).bodyMedium,
                  ),
                  if (vidhi.kabKarein.note.isNotEmpty) ...[
                    const SizedBox(height: VidhivatSpacing.xs),
                    Text(
                      vidhi.kabKarein.note,
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
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SourceLine(label: 'पद्धति', value: vidhi.strot.paddhati),
          const VidhivatDivider(),
          _SourceLine(label: 'क्षेत्र', value: vidhi.strot.kshetra),
          const VidhivatDivider(),
          _SourceLine(
            label: 'जाँच',
            value: vidhi.jaanch.paas
                ? '${vidhi.jaanch.panditNaam} · ${vidhi.jaanch.tarikh}'
                : 'अभी बाकी है',
            valueColor: vidhi.jaanch.paas ? colors.success : colors.warning,
          ),
          if (vidhi.strot.note.isNotEmpty) ...[
            const VidhivatDivider(),
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.sm),
              child: Text(vidhi.strot.note, style: type.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SourceLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: VidhivatSpacing.massive,
              child: Text(
                label,
                style: VidhivatTheme.typographyOf(context).bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: VidhivatTheme.typographyOf(context)
                    .bodyMedium
                    .copyWith(color: valueColor),
              ),
            ),
          ],
        ),
      );
}
