import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/parv.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

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
  late bool _poorna = widget.aaj.aajKaDin != null;

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
            if (widget.aaj.tippani != null) ...[
              const SizedBox(height: VidhivatSpacing.xl),
              _TithiTippani(text: widget.aaj.tippani!),
            ],
            const SizedBox(height: VidhivatSpacing.xl),
            const VidhivatSrotButton(
              label: 'यह पर्व कहाँ से आया',
              panktiyan: [],
            ),
          ],
        ),
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
            selected: !poorna,
            onTap: () => onBadlo(false),
          );
          final poora = _RastaCard(
            key: const Key('parv_poorna_rasta'),
            shirshak: 'पूर्ण नवरात्रि',
            vivaran: '${aaj.kulDin} दिन · रोज़ थोड़ा-थोड़ा',
            selected: poorna,
            onTap: () => onBadlo(true),
          );
          if (constraints.maxWidth < 360) {
            return Column(
              children: [
                sankshipt,
                const SizedBox(height: VidhivatSpacing.sm),
                poora,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sankshipt),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(child: poora),
            ],
          );
        },
      );
}

class _RastaCard extends StatelessWidget {
  final String shirshak;
  final String vivaran;
  final bool selected;
  final VoidCallback onTap;

  const _RastaCard({
    super.key,
    required this.shirshak,
    required this.vivaran,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.selectable,
      selected: selected,
      onTap: onTap,
      semanticLabel: '$shirshak चुनें। $vivaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shirshak, style: type.cardTitle),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(vivaran, style: type.bodySmall),
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

    return Opacity(
      opacity: beetGaya ? 0.72 : 1,
      child: VidhivatSurfaceCard(
        key: Key('parv_din_${din.ank}'),
        variant: aajHai
            ? VidhivatCardVariant.highlight
            : VidhivatCardVariant.standard,
        onTap: uplabdh ? () => onVidhiKholo(din.vidhiId!) : null,
        semanticLabel: 'दिन ${din.ank}, ${din.shirshak}, ${din.tithiNaam}, '
            '${din.ekLine}, ${din.samayMinute} मिनट'
            '${uplabdh ? ', पूजा खोलें' : ', विधि अभी नहीं'}',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VidhivatStatusChip(
              label: '${din.ank}',
              tone: beetGaya
                  ? VidhivatStatusTone.success
                  : VidhivatStatusTone.primary,
              icon: beetGaya ? Icons.check : null,
              selected: aajHai,
            ),
            const SizedBox(width: VidhivatSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(din.shirshak, style: type.cardTitle),
                  const SizedBox(height: VidhivatSpacing.xxs),
                  Text(
                    '${din.tithiNaam} · भोग: ${din.bhog}',
                    style: type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: VidhivatSpacing.xs),
                  Text(din.ekLine, style: type.bodyMedium),
                  const SizedBox(height: VidhivatSpacing.sm),
                  Wrap(
                    spacing: VidhivatSpacing.xs,
                    runSpacing: VidhivatSpacing.xs,
                    children: [
                      Text('${din.samayMinute} मिनट', style: type.caption),
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
              ),
            ),
          ],
        ),
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
