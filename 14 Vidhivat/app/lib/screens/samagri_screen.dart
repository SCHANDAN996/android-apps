import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'vidhi_player_screen.dart';

/// सामग्री की तैयारी सूची। इसकी ticks पहले से device-local settings में रहती
/// हैं; Phase 3 उस व्यवहार को बदलता या कोई नई persistence नहीं जोड़ता।
class SamagriScreen extends StatefulWidget {
  final Vidhi vidhi;

  const SamagriScreen({super.key, required this.vidhi});

  @override
  State<SamagriScreen> createState() => _SamagriScreenState();
}

class _SamagriScreenState extends State<SamagriScreen> {
  bool _sirfZaruri = false;

  Vidhi get vidhi => widget.vidhi;

  Future<void> _setTick(int index, bool value) async {
    await settings.setSamagriTick(vidhi.id, index, value);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ticks = settings.samagriTicks(vidhi.id);
    final visible =
        _sirfZaruri ? vidhi.zaruriSamagri.length : vidhi.samagri.length;
    final prepared = _sirfZaruri
        ? ticks.where((index) => vidhi.samagri[index].zaruri).length
        : ticks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('सामग्री'),
        actions: [
          VidhivatIconAction(
            tooltip: 'सूची भेजें',
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: vidhi.samagriText(sirfZaruri: _sirfZaruri)),
            ),
            icon: Icons.share_outlined,
          ),
          if (ticks.isNotEmpty)
            VidhivatIconAction(
              tooltip: 'सारी टिक हटाओ',
              onPressed: () async {
                await settings.clearSamagriTicks(vidhi.id);
                if (context.mounted) setState(() {});
              },
              icon: Icons.restart_alt,
            ),
        ],
      ),
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
              Text(
                '${vidhi.naam} की सामग्री',
                style: VidhivatTheme.typographyOf(context).pageTitle,
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                'पूजा शुरू करने से पहले अपनी तैयारी देख लें।',
                style: VidhivatTheme.typographyOf(context).bodyMedium,
              ),
              const SizedBox(height: VidhivatSpacing.lg),
              _PreparationProgress(
                prepared: prepared,
                total: visible,
                onlyRequired: _sirfZaruri,
                onOnlyRequiredChanged: (value) =>
                    setState(() => _sirfZaruri = value),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              for (final group in vidhi.samagriSamuhWar.entries) ...[
                _MaterialGroup(
                  title: group.key,
                  entries: group.value
                      .where((entry) => !_sirfZaruri || entry.samagri.zaruri)
                      .toList(growable: false),
                  ticks: ticks,
                  onChanged: _setTick,
                ),
                const SizedBox(height: VidhivatSpacing.xl),
              ],
              // क्या नहीं चढ़ाना — यहीं दिखता है, क्योंकि सामग्री
              // जुटाते वक़्त ही आदमी सोचता है "यह भी रख लूँ" (→ A10)।
              _KyaNahiChadhana(vidhi: vidhi),
              const SizedBox(height: VidhivatSpacing.xl),
              Text(
                'टिक सिर्फ़ आपके फ़ोन में रहती है। "सारी टिक हटाओ" से अगली '
                'बार के लिए सूची साफ़ हो जाती है।',
                style: VidhivatTheme.typographyOf(context).caption,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VidhivatSpacing.lg,
            VidhivatSpacing.sm,
            VidhivatSpacing.lg,
            VidhivatSpacing.md,
          ),
          child: VidhivatButton(
            label: 'पूजा शुरू करें',
            semanticLabel: '${vidhi.naam} शुरू करें',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => VidhiPlayerScreen(vidhi: vidhi)),
            ),
            icon: Icons.play_arrow,
            fullWidth: true,
          ),
        ),
      ),
    );
  }
}

class _PreparationProgress extends StatelessWidget {
  final int prepared;
  final int total;
  final bool onlyRequired;
  final ValueChanged<bool> onOnlyRequiredChanged;

  const _PreparationProgress({
    required this.prepared,
    required this.total,
    required this.onlyRequired,
    required this.onOnlyRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Column(
        children: [
          Wrap(
            spacing: VidhivatSpacing.sm,
            runSpacing: VidhivatSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$prepared / $total जुट गईं',
                style: VidhivatTheme.typographyOf(context).cardTitle,
              ),
              FilterChip(
                label: const Text('सिर्फ़ ज़रूरी'),
                selected: onlyRequired,
                onSelected: onOnlyRequiredChanged,
              ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          LinearProgressIndicator(
            value: total == 0 ? 0 : prepared / total,
            minHeight: VidhivatSpacing.xs,
            borderRadius: VidhivatRadius.pill,
            color: prepared == total && total > 0
                ? colors.success
                : colors.primary,
          ),
        ],
      ),
    );
  }
}

class _MaterialGroup extends StatelessWidget {
  final String title;
  final List<({int index, Samagri samagri})> entries;
  final Set<int> ticks;
  final void Function(int index, bool value) onChanged;

  const _MaterialGroup({
    required this.title,
    required this.entries,
    required this.ticks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VidhivatSectionHeader(title: title),
        const SizedBox(height: VidhivatSpacing.sm),
        VidhivatSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: Column(
            children: [
              for (var item = 0; item < entries.length; item++) ...[
                if (item > 0) const VidhivatDivider(),
                _MaterialChecklistTile(
                  item: entries[item].samagri,
                  index: entries[item].index,
                  selected: ticks.contains(entries[item].index),
                  onChanged: onChanged,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialChecklistTile extends StatelessWidget {
  final Samagri item;
  final int index;
  final bool selected;
  final void Function(int index, bool value) onChanged;

  const _MaterialChecklistTile({
    required this.item,
    required this.index,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = [item.matra, item.ikai]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onChanged(index, value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: VidhivatSpacing.xxs,
        vertical: VidhivatSpacing.xxs,
      ),
      title: Text(
        item.vastu,
        style: type.bodyLarge.copyWith(
          decoration: selected ? TextDecoration.lineThrough : null,
          color: selected ? colors.textSecondary : colors.textPrimary,
        ),
      ),
      subtitle: (quantity.isNotEmpty || item.note.isNotEmpty || !item.zaruri)
          ? Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.xxs),
              child: Wrap(
                spacing: VidhivatSpacing.xs,
                runSpacing: VidhivatSpacing.xxs,
                children: [
                  if (quantity.isNotEmpty)
                    VidhivatStatusChip(
                      label: quantity,
                      tone: VidhivatStatusTone.primary,
                    ),
                  if (!item.zaruri)
                    const VidhivatStatusChip(
                      label: 'वैकल्पिक',
                      tone: VidhivatStatusTone.neutral,
                    ),
                  if (item.note.isNotEmpty)
                    Text(item.note, style: type.bodySmall),
                ],
              ),
            )
          : null,
    );
  }
}

/// "क्या नहीं चढ़ाना" — सामग्री की सूची के नीचे (→ A10)।
///
/// ## यह यहाँ क्यों है
///
/// ये चीज़ें सामग्री-सूची में पहले से नहीं थीं — नतीजा सही था। पर **जो
/// सूची में नहीं है, यूज़र उसे ख़ुद जोड़ लेता है** ("तुलसी तो हर पूजा
/// में चढ़ती है" सोचकर)। इसलिए *"नहीं है"* काफ़ी नहीं; *"मत चढ़ाइए, और
/// यह रही वजह"* लिखना पड़ता है — और ठीक उसी पन्ने पर, जहाँ आदमी सामान
/// जुटा रहा होता है।
///
/// देवता-विशेष निषेध पूजा की JSON से आते हैं ([Vidhi.varjya]); जो हर
/// पूजा पर लागू हैं वे [saamaanyaVarjya] से।
class _KyaNahiChadhana extends StatelessWidget {
  final Vidhi vidhi;

  const _KyaNahiChadhana({required this.vidhi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = VidhivatTheme.typographyOf(context);
    final sab = [...vidhi.varjya, ...saamaanyaVarjya];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(VidhivatSpacing.sm),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.do_not_disturb_on_outlined,
                  size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: VidhivatSpacing.xs),
              Expanded(
                child: Text('क्या नहीं चढ़ाना', style: typography.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'ये चीज़ें सूची में जान-बूझकर नहीं हैं — इन्हें अपनी तरफ़ से '
            'मत जोड़िए।',
            textAlign: TextAlign.justify,
            style: typography.bodyMedium,
          ),
          const SizedBox(height: VidhivatSpacing.md),
          for (final v in sab) ...[
            Text('• ${v.vastu}', style: typography.bodyLarge),
            const SizedBox(height: VidhivatSpacing.xxs),
            Padding(
              padding: const EdgeInsets.only(left: VidhivatSpacing.sm),
              // ── "स्रोत: … · भरोसा: …" वाली लाइन यहाँ थी ─────
              //
              // हर चीज़ के नीचे एक, यानी शिव अभिषेक में आठ बार। वो
              // हमारा हवाला है, यूज़र का काम नहीं — सामान जुटाता आदमी
              // "मत चढ़ाइए" और "यह रही वजह" पढ़ता है, हवाला नहीं।
              // बारहों हवाले अब नीचे एक ही ℹ में हैं (→ D-056)।
              child: Text(v.kyon,
                  textAlign: TextAlign.justify, style: typography.bodyMedium),
            ),
            const SizedBox(height: VidhivatSpacing.md),
          ],
          VidhivatSrotButton(
            label: 'ये निषेध कहाँ से आए',
            panktiyan: [
              for (final v in sab)
                VidhivatSrotPankti(
                  v.vastu,
                  'स्रोत: ${v.strot}  ·  भरोसा: ${v.bharosa.naam}',
                ),
            ],
            antimBaat: 'जिन निषेधों पर पद्धतियों में मतभेद है, वे सूची में '
                'लिखे ही नहीं गए — अपने घर का चलन ही मानिए।',
          ),
        ],
      ),
    );
  }
}
