import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/katha.dart';
import '../vidhi/paath.dart';
import '../vidhi/vrat_artwork.dart';
import '../vidhi/vrat_panna.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/katha_khand.dart';
import '../widgets/mantra_khand.dart';
import 'paath_screen.dart';
import 'vidhi_screen.dart';

/// **एक व्रत का पूरा पन्ना** — बारह खाने, हर व्रत में इसी क्रम से (→ D-075)।
///
/// ## क्रम क्यों तय है
///
/// एकादशी पढ़ चुका आदमी सोमवार का पन्ना खोलते ही जान ले कि क्या कहाँ
/// है। इसलिए खानों का क्रम कंटेंट से नहीं, इस पन्ने से आता है।
///
/// ## ⚠️ जो खुला रहता है, और जो ⓘ के पीछे
///
/// - **सावधानी खुली** — जिसे न पढ़ने से नुक़सान हो, वो छिपाया नहीं जाता
///   (→ D-056)। निर्जल वाला भोजन-रूप भी चेतावनी के रंग में।
/// - **स्रोत ⓘ के पीछे** — माहात्म्य का हवाला और पन्ने के स्रोत (→ D-045)।
/// - **माहात्म्य के ठीक नीचे** ⓘ, ताकि कथा का कथन कभी बिना हवाले के न पढ़ा
///   जाए। "फ़ायदे" का ऐप अपना वादा नहीं करता (→ D-051)।
class VratPannaScreen extends StatefulWidget {
  final String id;

  const VratPannaScreen({super.key, required this.id});

  @override
  State<VratPannaScreen> createState() => _VratPannaScreenState();
}

class _VratPannaScreenState extends State<VratPannaScreen> {
  late final Future<VratPanna> _panna = vratBhandar.panna(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VratPanna>(
      future: _panna,
      builder: (context, snap) {
        final panna = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(panna?.naam ?? 'व्रत')),
          body: SafeArea(
            top: false,
            child: VidhivatSacredBackdrop(
              child: snap.hasError
                  ? const VidhivatStateView(
                      title: 'यह व्रत खुल नहीं सका',
                      message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                      icon: Icons.error_outline,
                      tone: VidhivatStateTone.error,
                    )
                  : panna == null
                      ? const VidhivatStateView(
                          title: 'व्रत खुल रहा है', loading: true)
                      : _Panna(panna: panna),
            ),
          ),
        );
      },
    );
  }
}

class _Panna extends StatelessWidget {
  final VratPanna panna;

  const _Panna({required this.panna});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final artwork = VratArtwork.forVratId(panna.id);
    const beech = SizedBox(height: VidhivatSpacing.xl);
    const chhota = SizedBox(height: VidhivatSpacing.sm);

    return Panna(
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        VidhivatSpacing.lg,
        VidhivatSpacing.lg,
        VidhivatSpacing.xxl,
      ),
      children: [
        // ── १ · एक नज़र में ─────────────────────────────
        Wrap(
          spacing: VidhivatSpacing.xs,
          runSpacing: VidhivatSpacing.xs,
          children: [
            VidhivatStatusChip(
              label: panna.devta,
              tone: VidhivatStatusTone.primary,
            ),
            VidhivatStatusChip(label: panna.samuh.naam),
          ],
        ),
        chhota,
        VidhivatSacredHero(
          eyebrow: panna.samuh.naam,
          title: panna.naam,
          subtitle: panna.ekLine,
          compact: true,
          artworkAsset: artwork.assetPath,
          artworkSemanticLabel: artwork.semanticLabel,
        ),
        beech,
        if (panna.engine != null) ...[
          chhota,
          _AglaDin(engineId: panna.engine!),
        ] else if (panna.festival != null) ...[
          chhota,
          _TyoharKaDin(festivalId: panna.festival!),
        ],
        beech,

        // ── २ · कब करें ─────────────────────────────────
        const VidhivatSectionHeader(title: 'कब करें'),
        chhota,
        Text(panna.kabSaral, style: type.bodyLarge),
        chhota,
        _Khand(shirshak: 'कब से शुरू करें', text: panna.shuruKab),
        _Khand(shirshak: 'कितनी बार', text: panna.kitniBaar),
        if (panna.doDin.trim().isNotEmpty) ...[
          chhota,
          Chetavni(panna.doDin, icon: Icons.event_note_outlined),
        ],
        beech,

        // ── ३ · भाव ──────────────────────────────────────
        const VidhivatSectionHeader(title: 'यह व्रत क्यों रखा जाता है'),
        chhota,
        Text(panna.bhav, style: type.bodyLarge, textAlign: TextAlign.justify),
        beech,

        // ── ४ · माहात्म्य ────────────────────────────────
        const VidhivatSectionHeader(
          title: 'माहात्म्य',
          supportingText: 'ग्रंथ या कथा क्या कहती है',
        ),
        chhota,
        Text(
          panna.mahatmyaKathan,
          style: type.bodyMedium,
          textAlign: TextAlign.justify,
        ),
        VidhivatSrotButton(
          label: 'यह बात कहाँ से है',
          panktiyan: [
            VidhivatSrotPankti('भरोसा', panna.mahatmyaBharosa.naam),
            VidhivatSrotPankti('स्रोत', panna.mahatmyaStrot),
          ],
          antimBaat: 'यह ग्रंथ या कथा का कथन है — ऐप का वादा नहीं।',
        ),
        beech,

        // ── ५ · नियम ─────────────────────────────────────
        const VidhivatSectionHeader(title: 'नियम'),
        chhota,
        _Khand(shirshak: 'एक दिन पहले', text: panna.pehleDin),
        _Suchi(shirshak: 'व्रत के दिन', panktiyan: panna.vratKeDin),
        if (panna.naKarein.isNotEmpty)
          _Suchi(shirshak: 'क्या न करें', panktiyan: panna.naKarein),
        beech,

        // ── ६ · भोजन ─────────────────────────────────────
        const VidhivatSectionHeader(
          title: 'भोजन',
          supportingText: 'रूप आपकी सामर्थ्य से — हर रूप पूरा व्रत है',
        ),
        chhota,
        for (final b in panna.bhojan) ...[
          VidhivatSurfaceCard(
            variant: b.nirjal
                ? VidhivatCardVariant.warning
                : VidhivatCardVariant.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.roop, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(b.vivaran, style: type.bodyMedium),
              ],
            ),
          ),
          chhota,
        ],
        const SizedBox(height: VidhivatSpacing.md),

        // ── ७ · पारण ─────────────────────────────────────
        const VidhivatSectionHeader(title: 'पारण — व्रत कब और कैसे खोलें'),
        chhota,
        Text(panna.paran, style: type.bodyLarge, textAlign: TextAlign.justify),
        beech,

        // ── ८ · पूजा ─────────────────────────────────────
        const VidhivatSectionHeader(title: 'पूजा', supportingText: 'छोटी विधि'),
        chhota,
        for (final k in panna.puja) ...[
          _Kadam(kadam: k),
          chhota,
        ],
        if (panna.vidhiId != null) ...[
          VidhivatButton(
            label: 'पूरी पूजा-विधि खोलें',
            icon: Icons.local_florist_outlined,
            variant: VidhivatButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VidhiScreen(id: panna.vidhiId!),
              ),
            ),
          ),
        ],
        beech,

        // ── ९ · मंत्र ─────────────────────────────────────
        // पाठ न हो तो ख़ाली डिब्बा, बना हुआ मंत्र नहीं — और क्यों ख़ाली है,
        // वो खुला (→ D-041, D-076)।
        MantraKhand(mantra: panna.mantra, khaaliSandesh: panna.mantra.strot),
        beech,

        // ── १० · कथा ─────────────────────────────────────
        const VidhivatSectionHeader(title: 'कथा'),
        chhota,
        if (panna.kathaIds.isEmpty)
          Chetavni(panna.kathaKyonNahi)
        else
          for (final kid in panna.kathaIds) ...[
            _KathaKholo(id: kid),
            chhota,
          ],
        if (panna.id == 'ekadashi') ...[
          chhota,
          VidhivatButton(
            label: 'साल की सब एकादशियाँ और उनकी कथाएँ',
            icon: Icons.calendar_month_outlined,
            variant: VidhivatButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EkadashiVarshScreen()),
            ),
          ),
        ],
        beech,

        // ── ११ · आरती और उद्यापन ────────────────────────
        if (panna.paath.isNotEmpty) ...[
          _PaathKholo(ids: panna.paath),
          beech,
        ],
        const VidhivatSectionHeader(title: 'उद्यापन'),
        chhota,
        Text(panna.udyapan,
            style: type.bodyMedium, textAlign: TextAlign.justify),
        beech,

        // ── १२ · सावधानी और सवाल ────────────────────────
        const VidhivatSectionHeader(title: 'सावधानी'),
        chhota,
        for (final s in panna.savdhani)
          Chetavni(s, icon: Icons.health_and_safety_outlined, serious: true),
        const SizedBox(height: VidhivatSpacing.md),
        const VidhivatSectionHeader(title: 'आम सवाल'),
        chhota,
        for (final s in panna.sawaal) ...[
          _Sawaal(sawaal: s),
          chhota,
        ],
        const SizedBox(height: VidhivatSpacing.md),
        VidhivatSrotButton(
          label: 'यह पन्ना कहाँ से बना',
          panktiyan: [
            for (var i = 0; i < panna.strot.length; i++)
              VidhivatSrotPankti('${i + 1}', panna.strot[i]),
          ],
          antimBaat: 'आपके घर या क्षेत्र का चलन अलग हो तो वही सही है।',
        ),
        Text(
          'यह पन्ना घर की सरल परंपरा के लिए है। बड़ा अनुष्ठान या उद्यापन '
          'आचार्य के साथ करें।',
          style: type.caption.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

/// पंचांग से अगला दिन — सिर्फ़ उन व्रतों पर जिनकी तारीख़ ऐप गिनता है।
class _AglaDin extends StatefulWidget {
  final String engineId;

  const _AglaDin({required this.engineId});

  @override
  State<_AglaDin> createState() => _AglaDinState();
}

class _AglaDinState extends State<_AglaDin> {
  /// ⚠️ हर दिन का पंचांग बनता है — इसलिए एक बार, `build` में नहीं।
  late final Future<VratDin?> _agla = () async {
    final sab = aaneWaleVrat(
      place: settings.place,
      masaSystem: settings.masaSystem,
      dinAage: 60,
      kitne: 30,
    );
    for (final d in sab) {
      if (d.niyam.id == widget.engineId) return d;
    }
    return null;
  }();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VratDin?>(
      future: _agla,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const SizedBox.shrink();
        return VidhivatStatusChip(
          label: 'अगला: ${d.kabLikha} · ${tarikhChhoti(d.tarikh)} · '
              '${d.tithiNaam}',
          icon: Icons.event_outlined,
          tone: d.kitneDinBaad == 0
              ? VidhivatStatusTone.success
              : VidhivatStatusTone.info,
        );
      },
    );
  }
}

/// साल के व्रत की अगली तारीख़ — इंजन के त्योहार-नियम से (→ D-130)।
/// नियम दो दिन दावेदार बताए तो दूसरा दिन भी।
class _TyoharKaDin extends StatefulWidget {
  final String festivalId;

  const _TyoharKaDin({required this.festivalId});

  @override
  State<_TyoharKaDin> createState() => _TyoharKaDinState();
}

class _TyoharKaDinState extends State<_TyoharKaDin> {
  late final Future<FestivalDate?> _agla = () async {
    final ab = DateTime.now();
    final aaj = DateTime.utc(ab.year, ab.month, ab.day);
    for (final saal in [ab.year, ab.year + 1]) {
      for (final f in festivalsInYear(saal, settings.place)) {
        if (f.rule.id == widget.festivalId && !f.date.isBefore(aaj)) return f;
      }
    }
    return null;
  }();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FestivalDate?>(
      future: _agla,
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) return const SizedBox.shrink();
        final ab = DateTime.now();
        final baad =
            f.date.difference(DateTime.utc(ab.year, ab.month, ab.day)).inDays;
        final kab = switch (baad) {
          0 => 'आज',
          1 => 'कल',
          2 => 'परसों',
          _ => '$baad दिन बाद',
        };
        final doosra = f.otherCandidate;
        return VidhivatStatusChip(
          label: 'अगला: $kab · ${tarikhChhoti(f.date)}'
              '${doosra == null ? '' : ' (कुछ पंचांगों में ${tarikhChhoti(doosra)})'}',
          icon: Icons.event_outlined,
          tone: baad == 0 ? VidhivatStatusTone.success : VidhivatStatusTone.info,
        );
      },
    );
  }
}

/// छोटा शीर्षक और उसके नीचे पाठ।
class _Khand extends StatelessWidget {
  final String shirshak;
  final String text;

  const _Khand({required this.shirshak, required this.text});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VidhivatSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shirshak, style: type.label),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(text, style: type.bodyMedium, textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}

/// शीर्षक और बिंदुओं वाली सूची।
class _Suchi extends StatelessWidget {
  final String shirshak;
  final List<String> panktiyan;

  const _Suchi({required this.shirshak, required this.panktiyan});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VidhivatSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shirshak, style: type.label),
          const SizedBox(height: VidhivatSpacing.xxs),
          for (final p in panktiyan)
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ',
                      style: type.bodyMedium.copyWith(color: colors.primary)),
                  Expanded(child: Text(p, style: type.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// पूजा का एक कदम — क्रम-संख्या के साथ।
class _Kadam extends StatelessWidget {
  final VratKadam kadam;

  const _Kadam({required this.kadam});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.primary.withValues(alpha: 0.16),
            child: Text(
              '${kadam.kram}',
              style: type.label.copyWith(color: colors.primary),
            ),
          ),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kadam.shirshak, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(kadam.vivaran, style: type.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// कथा का बटन — नाम कथा की फ़ाइल से, ताकि लिखा और खुला एक रहे।
class _KathaKholo extends StatelessWidget {
  final String id;

  const _KathaKholo({required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Katha>(
      future: kathaBhandar.katha(id),
      builder: (context, snap) {
        final katha = snap.data;
        if (katha == null) return const SizedBox.shrink();
        return VidhivatSurfaceCard(
          semanticLabel: '${katha.naam} पढ़ें',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => KathaScreen(id: id)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_stories_outlined),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      katha.naam,
                      style: VidhivatTheme.typographyOf(context).cardTitle,
                    ),
                    Text(
                      '${katha.adhyayKul} अध्याय · लगभग ${katha.minute} मिनट',
                      style: VidhivatTheme.typographyOf(context).bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      },
    );
  }
}

/// आरती-चालीसा के बटन — नाम पाठ की सूची से।
class _PaathKholo extends StatelessWidget {
  final List<String> ids;

  const _PaathKholo({required this.ids});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaathSuchiEntry>>(
      future: paathBhandar.suchi(),
      builder: (context, snap) {
        final suchi = snap.data;
        if (suchi == null) return const SizedBox.shrink();
        final mile = [
          for (final id in ids) ...suchi.where((e) => e.id == id && e.taiyar),
        ];
        if (mile.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VidhivatSectionHeader(title: 'आरती और पाठ'),
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

/// एक सवाल — दबाने पर जवाब खुलता है।
class _Sawaal extends StatefulWidget {
  final VratSawaal sawaal;

  const _Sawaal({required this.sawaal});

  @override
  State<_Sawaal> createState() => _SawaalState();
}

class _SawaalState extends State<_Sawaal> {
  bool _khula = false;

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      onTap: () => setState(() => _khula = !_khula),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(widget.sawaal.sawaal, style: type.cardTitle),
              ),
              Icon(
                _khula ? Icons.expand_less : Icons.expand_more,
                color: colors.textTertiary,
              ),
            ],
          ),
          if (_khula) ...[
            const SizedBox(height: VidhivatSpacing.xs),
            Text(widget.sawaal.jawaab, style: type.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// **एक कथा, अपने पन्ने पर** — व्रत के पन्ने या एकादशी-सूची से।
class KathaScreen extends StatelessWidget {
  final String id;

  /// कथा से ऊपर दिखने वाली बातें — जैसे एकादशी का महीना और ख़ास बात।
  final List<String> upar;

  const KathaScreen({super.key, required this.id, this.upar = const []});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('कथा')),
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
                for (final u in upar) Chetavni(u),
                KathaKhand(id: id),
              ],
            ),
          ),
        ),
      );
}

/// **साल की एकादशियाँ** — 24, और अधिक मास की दो (→ D-076)।
///
/// तारीख़ यहाँ नहीं — वो पंचांग से व्रत की सूची में आती है। यह पन्ना
/// बताता है कि किस महीने की एकादशी का नाम क्या है, और उसकी कथा क्या है।
class EkadashiVarshScreen extends StatefulWidget {
  const EkadashiVarshScreen({super.key});

  @override
  State<EkadashiVarshScreen> createState() => _EkadashiVarshScreenState();
}

class _EkadashiVarshScreenState extends State<EkadashiVarshScreen> {
  late final Future<List<EkadashiVarsh>> _sab = vratBhandar.ekadashiVarsh();

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('साल की एकादशियाँ')),
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<EkadashiVarsh>>(
            future: _sab,
            builder: (context, snap) {
              if (snap.hasError) {
                return const VidhivatStateView(
                  title: 'एकादशियों की सूची नहीं खुल सकी',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              final sab = snap.data;
              if (sab == null) {
                return const VidhivatStateView(
                    title: 'सूची खुल रही है', loading: true);
              }
              return Panna(
                padding: const EdgeInsets.fromLTRB(
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.xxl,
                ),
                children: [
                  Text(
                    'महीने पूर्णिमांत गणना से हैं (उत्तर भारत)। अमांत गणना में '
                    'कृष्ण पक्ष की एकादशी पिछले महीने में गिनी जाती है — हर '
                    'एकादशी पर दोनों लिखे हैं। तारीख़ व्रत की सूची में पंचांग '
                    'से आती है।',
                    style: type.bodyMedium,
                  ),
                  const SizedBox(height: VidhivatSpacing.lg),
                  for (final e in sab) ...[
                    VidhivatSurfaceCard(
                      semanticLabel: '${e.naam}, ${e.kabLikha}, ${e.ekLine}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KathaScreen(
                            id: e.kathaId,
                            upar: [
                              '${e.naam} — ${e.kabLikha}'
                                  '${e.adhik ? '' : ' (अमांत: ${e.amantMaas})'}',
                              e.vishesh,
                            ],
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${e.kram}',
                              style: type.label.copyWith(color: colors.primary),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.naam, style: type.cardTitle),
                                Text(
                                  e.kabLikha,
                                  style: type.bodySmall
                                      .copyWith(color: colors.textSecondary),
                                ),
                                Text(e.ekLine, style: type.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    const SizedBox(height: VidhivatSpacing.sm),
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
