import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/parv.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'paath_screen.dart';
import 'saptashati_screen.dart';
import 'vrat_panna_screen.dart';

/// कई दिनों के पर्व के संक्षिप्त और दिन-प्रतिदिन रास्ते।
class ParvScreen extends StatefulWidget {
  final Parv parv;
  final ParvAaj aaj;
  final void Function(String vidhiId) onVidhiKholo;

  const ParvScreen({
    super.key,
    required this.parv,
    required this.aaj,
    required this.onVidhiKholo,
  });

  @override
  State<ParvScreen> createState() => _ParvScreenState();
}

class _ParvScreenState extends State<ParvScreen> {
  // आज की पूजा ऊपर अपने अलग कार्ड में सीधे खुलती है। पूरी सूची अपने-आप
  // खोलने पर वही दिन दोबारा दिखता और व्रत बहुत नीचे चला जाता था।
  bool _poorna = false;

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(widget.parv.naam)),
      body: SafeArea(
        top: false,
        child: Panna(
          padding: const EdgeInsets.fromLTRB(
            VidhivatSpacing.lg,
            VidhivatSpacing.lg,
            VidhivatSpacing.lg,
            VidhivatSpacing.xxl,
          ),
          children: [
            VidhivatSacredHero(
              eyebrow: 'पर्व',
              title: widget.parv.naam,
              subtitle: widget.parv.ekLine,
              icon: Icons.auto_awesome_outlined,
              artworkAsset: widget.parv.artworkAsset,
              artworkSemanticLabel: widget.parv.artworkLabel,
              footer: _TarikhPattee(aaj: widget.aaj),
            ),
            const SizedBox(height: VidhivatSpacing.xl),
            _AajKaCard(
              parv: widget.parv,
              aaj: widget.aaj,
              onVidhiKholo: widget.onVidhiKholo,
            ),
            if (widget.aaj.aajKaDin == 1 &&
                widget.aaj.ghatasthapanaShuru != null &&
                widget.aaj.ghatasthapanaAnt != null) ...[
              const SizedBox(height: VidhivatSpacing.md),
              _MuhuratCard(
                shirshak: 'आज घटस्थापना का समय',
                samay: '${hm(widget.aaj.ghatasthapanaShuru)} – '
                    '${hm(widget.aaj.ghatasthapanaAnt)}',
                sahayak: widget.aaj.ghatasthapanaAbhijitShuru == null
                    ? null
                    : 'अभिजित विकल्प — '
                        '${hm(widget.aaj.ghatasthapanaAbhijitShuru)} – '
                        '${hm(widget.aaj.ghatasthapanaAbhijitAnt)}',
              ),
            ],
            if (widget.aaj.aajKaDin == 8 &&
                widget.aaj.sandhiShuru != null &&
                widget.aaj.sandhiAnt != null) ...[
              const SizedBox(height: VidhivatSpacing.md),
              _MuhuratCard(
                shirshak: 'संधि पूजा का समय',
                samay: '${hm(widget.aaj.sandhiShuru)} – '
                    '${hm(widget.aaj.sandhiAnt)}',
                sahayak: 'अष्टमी के अंतिम 24 और नवमी के पहले 24 मिनट',
              ),
            ],
            if (widget.aaj.tippani != null) ...[
              const SizedBox(height: VidhivatSpacing.md),
              _TithiTippani(text: widget.aaj.tippani!),
            ],
            // 📖 "आज का पाठ" — संक्षिप्त/पूर्ण के **ऊपर**, जान-बूझकर।
            //
            // पाठ *पूजा नहीं है* (→ D-039): वह दोनों रास्तों के साथ चलता
            // है — संक्षिप्त करने वाला भी करता है, नौ दिन वाला भी।
            // इसलिए वह किसी एक रास्ते के अंदर नहीं, दोनों के ऊपर बैठता है।
            const SizedBox(height: VidhivatSpacing.xxl),
            const _AajKaPaath(),
            const SizedBox(height: VidhivatSpacing.xl),
            const _VratKaLink(),
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(title: 'कैसे करना है'),
            const SizedBox(height: VidhivatSpacing.md),
            _RastaChunav(
              parv: widget.parv,
              aaj: widget.aaj,
              poorna: _poorna,
              onBadlo: (poorna) => setState(() => _poorna = poorna),
            ),
            const SizedBox(height: VidhivatSpacing.lg),
            if (_poorna)
              _DinSuchi(
                parv: widget.parv,
                aaj: widget.aaj,
                onVidhiKholo: widget.onVidhiKholo,
              )
            else
              _SankshiptKriya(
                rasta: widget.parv.sankshipt,
                onVidhiKholo: widget.onVidhiKholo,
              ),
            const SizedBox(height: VidhivatSpacing.xl),
            const VidhivatSrotButton(
              label: 'यह पर्व कहाँ से आया',
              panktiyan: [
                VidhivatSrotPankti(
                  'नौ रूपों के नाम',
                  'देवी कवच के श्लोक 3–5 में शैलपुत्री से सिद्धिदात्री तक '
                      'नवदुर्गा के नौ नाम इसी क्रम में आते हैं।',
                ),
                VidhivatSrotPankti(
                  'नवरात्रि का मुख्य पाठ',
                  'दुर्गा सप्तशती अर्थात देवी माहात्म्य के तेरह अध्याय ऐप '
                      'में पूरे हैं। पारंपरिक पाठ-क्रम में साथ पढ़े जाने वाले '
                      'कवच, अर्गला और कीलक भी अलग पूरे दिए गए हैं।',
                ),
                VidhivatSrotPankti(
                  'तारीख और समय',
                  'ऐप आपके शहर के सूर्योदय और तिथि-व्याप्ति से दिन निकालता '
                      'है। घटस्थापना, संधि पूजा और विजयादशमी के समय भी इसी '
                      'स्थानीय पंचांग-गणना से आते हैं।',
                ),
                VidhivatSrotPankti(
                  'घर की पूजा-विधि',
                  'कलश, जवारे, दीप, भोग और कन्या-पूजन का क्रम सरल घरेलू '
                      'पद्धति है। आपके घर या क्षेत्र की परंपरा अलग हो तो वही '
                      'मानें।',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// नवरात्रि का पाठ — पूरी दुर्गा सप्तशती, और समय कम हो तो सप्तश्लोकी।
///
/// ## पहले यहाँ क्या था
/// *"वह पूरी ऐप में नहीं है; अपनी पुस्तिका से पढ़िए।"* — डेवलपर ने साफ़
/// कहा कि पूरा पाठ ऐप में चाहिए। अब तेरह अध्याय, कवच, अर्गला और कीलक
/// सब ऐप में हैं, अपने पन्ने पर (→ D-084)।
class _AajKaPaath extends StatelessWidget {
  const _AajKaPaath();

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return VidhivatSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: colors.primary),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(
                child: Text('नवरात्रि का पाठ', style: type.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'नवरात्रि में दुर्गा सप्तशती का पाठ किया जाता है — कवच, अर्गला, '
            'कीलक और तेरह अध्याय। पूरा पाठ ऐप में है, और जहाँ छोड़ेंगे वहीं '
            'से आगे खुलेगा। अध्यायों को नौ दिनों में बाँटने के अलग-अलग चलन '
            'हैं; ऐप कोई एक बँटवारा अनिवार्य नहीं बताता।\n\n'
            'समय कम हो तो सप्तश्लोकी दुर्गा — सात श्लोक, पाँच मिनट।',
            style: type.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: VidhivatSpacing.md),
          VidhivatButton(
            label: 'दुर्गा सप्तशती पढ़ें',
            semanticLabel: 'दुर्गा सप्तशती का पाठ खोलें',
            icon: Icons.menu_book_outlined,
            fullWidth: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SaptashatiScreen()),
            ),
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          VidhivatButton(
            label: 'सप्तश्लोकी दुर्गा पढ़ें',
            semanticLabel: 'सप्तश्लोकी दुर्गा का पाठ खोलें',
            icon: Icons.timer_outlined,
            variant: VidhivatButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaathScreen(id: 'saptashloki_durga'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// नवरात्रि का व्रत — पन्ना पहले से बना है, रास्ता नहीं था।
///
/// पूजा और व्रत दो अलग चीज़ें हैं (→ D-075): पूजा एक बैठक का काम है,
/// व्रत पूरे दिन का नियम। इसलिए व्रत की बात पूजा के कदमों में नहीं
/// घुसाई गई — पर नवरात्रि में व्रत रखने वाला आदमी इसी पन्ने पर खड़ा
/// होता है, और उसे नियम, भोजन, पारण और कथा तक पहुँचने का एक दरवाज़ा
/// चाहिए।
class _VratKaLink extends StatelessWidget {
  const _VratKaLink();

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return VidhivatSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, color: colors.primary),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(
                child: Text('नवरात्रि का व्रत', style: type.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'व्रत रख रहे हैं तो उसके नियम, भोजन, पारण और कथा अलग पन्ने '
            'पर हैं। ऐप निर्जल व्रत का सुझाव कभी नहीं देता — अपनी सेहत '
            'सबसे ऊपर रखें।',
            style: type.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: VidhivatSpacing.md),
          VidhivatButton(
            label: 'व्रत का पन्ना खोलें',
            semanticLabel: 'नवरात्रि व्रत का पन्ना खोलें',
            icon: Icons.menu_book_outlined,
            variant: VidhivatButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VratPannaScreen(id: 'navratri'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuhuratCard extends StatelessWidget {
  final String shirshak;
  final String samay;
  final String? sahayak;

  const _MuhuratCard({
    required this.shirshak,
    required this.samay,
    this.sahayak,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_outlined, color: colors.info),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shirshak, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(samay, style: type.numericHighlight),
                if (sahayak != null) ...[
                  const SizedBox(height: VidhivatSpacing.xs),
                  Text(sahayak!, style: type.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarikhPattee extends StatelessWidget {
  final ParvAaj aaj;

  const _TarikhPattee({required this.aaj});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: VidhivatSpacing.xs,
        runSpacing: VidhivatSpacing.xs,
        children: [
          if (aaj.shuruTarikh != null)
            VidhivatStatusChip(
              label: 'आरम्भ ${tarikhChhoti(aaj.shuruTarikh!)}',
              tone: VidhivatStatusTone.primary,
            ),
          if (aaj.antTarikh != null)
            VidhivatStatusChip(
              label: 'समापन ${tarikhChhoti(aaj.antTarikh!)}',
            ),
          VidhivatStatusChip(label: '${aaj.kulDin} दिन'),
        ],
      );
}

class _AajKaCard extends StatelessWidget {
  final Parv parv;
  final ParvAaj aaj;
  final void Function(String) onVidhiKholo;

  const _AajKaCard({
    required this.parv,
    required this.aaj,
    required this.onVidhiKholo,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final din = aaj.aajKaDin == null
        ? null
        : parv.din.where((item) => item.ank == aaj.aajKaDin).firstOrNull;

    if (din != null) {
      return VidhivatSurfaceCard(
        key: const Key('parv_aaj_card'),
        variant: VidhivatCardVariant.highlight,
        semanticLabel: 'आज, दिन ${din.ank}, ${din.shirshak}, ${din.ekLine}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('आज — दिन ${din.ank}', style: type.label),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(din.shirshak, style: type.pageTitle),
            const SizedBox(height: VidhivatSpacing.xxs),
            Text(din.ekLine, style: type.bodyMedium),
            const SizedBox(height: VidhivatSpacing.md),
            if (din.vidhiId == null) ...[
              const VidhivatStatusChip(label: 'विधि अभी नहीं'),
              const SizedBox(height: VidhivatSpacing.sm),
            ],
            VidhivatButton(
              label: 'आज की पूजा खोलें',
              semanticLabel: din.vidhiId == null
                  ? 'आज की पूजा अभी उपलब्ध नहीं है'
                  : 'आज की पूजा खोलें',
              onPressed:
                  din.vidhiId == null ? null : () => onVidhiKholo(din.vidhiId!),
              fullWidth: true,
            ),
          ],
        ),
      );
    }

    if (aaj.kitneDinBaad != null) {
      return VidhivatSurfaceCard(
        key: const Key('parv_countdown_card'),
        variant: VidhivatCardVariant.information,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${parv.naam} शुरू होने में ${aaj.kitneDinBaad} दिन',
              style: type.cardTitle,
            ),
            if (aaj.shuruTarikh != null) ...[
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                'आरम्भ — ${tarikh(aaj.shuruTarikh!)}',
                style: type.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      );
    }

    return VidhivatSurfaceCard(
      key: const Key('parv_beet_chuka_card'),
      child: Text(
        '${parv.naam} इस वर्ष बीत चुका है।',
        style: type.bodyMedium,
      ),
    );
  }
}

class _RastaChunav extends StatelessWidget {
  final Parv parv;
  final ParvAaj aaj;
  final bool poorna;
  final ValueChanged<bool> onBadlo;

  const _RastaChunav({
    required this.parv,
    required this.aaj,
    required this.poorna,
    required this.onBadlo,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final sankshipt = _RastaCard(
            key: const Key('parv_sankshipt_rasta'),
            shirshak: 'संक्षिप्त पूजा',
            vivaran: '${parv.sankshipt.samayMinute} मिनट · एक ही बैठक',
            artworkAsset:
                'assets/images/devotional/navratri_sankshipt_rasta_v1.webp',
            artworkLabel: 'पूजा थाली, दीप और पुष्पों का सजावटी चित्र',
            selected: !poorna,
            onTap: () => onBadlo(false),
          );
          final poora = _RastaCard(
            key: const Key('parv_poorna_rasta'),
            shirshak: 'पूर्ण पूजा',
            vivaran: '${aaj.kulDin} दिन · रोज़ थोड़ा-थोड़ा',
            artworkAsset:
                'assets/images/devotional/navratri_poorna_rasta_v1.webp',
            artworkLabel:
                'नवरात्रि कलश, जवारे, अखंड दीप और पुष्पों का सजावटी चित्र',
            selected: poorna,
            onTap: () => onBadlo(true),
          );
          if (constraints.maxWidth < 240) {
            return Column(
              children: [
                sankshipt,
                const SizedBox(height: VidhivatSpacing.sm),
                poora,
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: sankshipt),
                const SizedBox(width: VidhivatSpacing.sm),
                Expanded(child: poora),
              ],
            ),
          );
        },
      );
}

class _RastaCard extends StatelessWidget {
  final String shirshak;
  final String vivaran;
  final String artworkAsset;
  final String artworkLabel;
  final bool selected;
  final VoidCallback onTap;

  const _RastaCard({
    super.key,
    required this.shirshak,
    required this.vivaran,
    required this.artworkAsset,
    required this.artworkLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.selectable,
      selected: selected,
      onTap: onTap,
      semanticLabel: '$shirshak चुनें। $vivaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            image: true,
            label: artworkLabel,
            child: ExcludeSemantics(
              child: SizedBox(
                height: 108,
                child: Image.asset(
                  artworkAsset,
                  fit: BoxFit.contain,
                  cacheHeight: 324,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.auto_awesome_outlined,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          Text(
            shirshak,
            style: type.cardTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(
            vivaran,
            style: type.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (selected) ...[
            const SizedBox(height: VidhivatSpacing.xs),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: VidhivatSpacing.xxs,
              children: [
                Icon(Icons.check_circle, size: 17, color: colors.primary),
                Text(
                  'चुना हुआ',
                  style: type.caption.copyWith(color: colors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SankshiptKriya extends StatelessWidget {
  final ParvRasta rasta;
  final void Function(String) onVidhiKholo;

  const _SankshiptKriya({required this.rasta, required this.onVidhiKholo});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rasta.vivaran,
              style: VidhivatTheme.typographyOf(context).bodyMedium),
          const SizedBox(height: VidhivatSpacing.md),
          if (rasta.vidhiId == null) ...[
            const VidhivatStatusChip(label: 'विधि अभी नहीं'),
            const SizedBox(height: VidhivatSpacing.sm),
          ],
          VidhivatButton(
            label: 'पूजा खोलें',
            semanticLabel: rasta.vidhiId == null
                ? 'संक्षिप्त पूजा अभी उपलब्ध नहीं है'
                : 'संक्षिप्त पूजा खोलें',
            onPressed: rasta.vidhiId == null
                ? null
                : () => onVidhiKholo(rasta.vidhiId!),
            fullWidth: true,
          ),
        ],
      );
}

class _DinSuchi extends StatelessWidget {
  final Parv parv;
  final ParvAaj aaj;
  final void Function(String) onVidhiKholo;

  const _DinSuchi({
    required this.parv,
    required this.aaj,
    required this.onVidhiKholo,
  });

  @override
  Widget build(BuildContext context) => Column(
        key: const Key('parv_din_suchi'),
        children: [
          for (final din in parv.din) ...[
            _DinCard(din: din, aaj: aaj, onVidhiKholo: onVidhiKholo),
            if (din != parv.din.last)
              const SizedBox(height: VidhivatSpacing.sm),
          ],
        ],
      );
}

class _DinCard extends StatelessWidget {
  final ParvDin din;
  final ParvAaj aaj;
  final void Function(String) onVidhiKholo;

  const _DinCard({
    required this.din,
    required this.aaj,
    required this.onVidhiKholo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final aajHai = din.ank == aaj.aajKaDin;
    final beetGaya = aaj.aajKaDin != null && din.ank < aaj.aajKaDin!;
    final milaHua = aaj.mileHueDin.contains(din.ank);
    final uplabdh = din.vidhiId != null;
    final tarikhein = aaj.dinTarikhein[din.ank] ?? const <DateTime>[];
    final tarikhLikhi = tarikhein.map(tarikhChhoti).join(' / ');

    return Opacity(
      opacity: beetGaya ? 0.72 : 1,
      child: VidhivatSurfaceCard(
        key: Key('parv_din_${din.ank}'),
        variant: aajHai
            ? VidhivatCardVariant.highlight
            : VidhivatCardVariant.standard,
        onTap: uplabdh ? () => onVidhiKholo(din.vidhiId!) : null,
        semanticLabel: 'दिन ${din.ank}, ${din.shirshak}, ${din.tithiNaam}'
            '${tarikhLikhi.isEmpty ? '' : ', $tarikhLikhi'}, '
            '${din.ekLine}, ${din.samayMinute} मिनट'
            '${uplabdh ? ', पूजा खोलें' : ', विधि अभी नहीं'}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DinArtwork(
                  din: din,
                  beetGaya: beetGaya,
                  aajHai: aajHai,
                ),
                const SizedBox(width: VidhivatSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (din.ank == 10)
                        const VidhivatStatusChip(
                          label: 'समापन',
                          tone: VidhivatStatusTone.success,
                        ),
                      if (din.ank == 10)
                        const SizedBox(height: VidhivatSpacing.xs),
                      Text(
                        din.ank == 10 ? din.shirshak : 'माँ ${din.shirshak}',
                        style: type.cardTitle,
                      ),
                      const SizedBox(height: VidhivatSpacing.xxs),
                      Text(
                        din.tithiNaam,
                        style: type.label.copyWith(color: colors.primary),
                      ),
                      if (tarikhLikhi.isNotEmpty) ...[
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          tarikhLikhi,
                          style: type.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: VidhivatSpacing.xs),
                      Text(din.ekLine, style: type.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: VidhivatSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VidhivatSpacing.sm,
                vertical: VidhivatSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: VidhivatSpacing.xs),
                  Expanded(
                    child: Text(
                      'प्रचलित भोग · ${din.bhog}',
                      style: type.bodySmall,
                    ),
                  ),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: VidhivatSpacing.xxs),
                  Text('${din.samayMinute} मिनट', style: type.caption),
                ],
              ),
            ),
            if (aajHai || !uplabdh || milaHua) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              Wrap(
                spacing: VidhivatSpacing.xs,
                runSpacing: VidhivatSpacing.xs,
                children: [
                  if (aajHai)
                    const VidhivatStatusChip(
                      label: 'आज',
                      tone: VidhivatStatusTone.primary,
                      selected: true,
                    ),
                  if (!uplabdh)
                    const VidhivatStatusChip(label: 'विधि अभी नहीं'),
                  if (milaHua)
                    const VidhivatStatusChip(
                      label: 'इस साल एक साथ',
                      tone: VidhivatStatusTone.info,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DinArtwork extends StatelessWidget {
  final ParvDin din;
  final bool beetGaya;
  final bool aajHai;

  const _DinArtwork({
    required this.din,
    required this.beetGaya,
    required this.aajHai,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return SizedBox(
      width: 116,
      height: 144,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(VidhivatSpacing.xs),
                child: Semantics(
                  image: true,
                  label: din.artworkLabel,
                  child: ExcludeSemantics(
                    child: Image.asset(
                      din.artworkAsset,
                      fit: BoxFit.contain,
                      cacheHeight: 432,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_awesome_outlined,
                        size: 44,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -4,
            top: -4,
            child: VidhivatStatusChip(
              label: '${din.ank}',
              tone: beetGaya
                  ? VidhivatStatusTone.success
                  : VidhivatStatusTone.primary,
              icon: beetGaya ? Icons.check : null,
              selected: aajHai,
            ),
          ),
        ],
      ),
    );
  }
}

class _TithiTippani extends StatelessWidget {
  final String text;

  const _TithiTippani({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.info),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: VidhivatTheme.typographyOf(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
