import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/paath.dart';
import '../vidhi/paath_assets.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'paath_screen.dart';

/// चालीसा और स्तोत्र की सूची — **पूजा से अलग जगह** (→ D-039)।
///
/// पूजा एक काम है (सामग्री, कदम, संकल्प); पाठ बैठकर पढ़ने की चीज़ है।
/// इसीलिए यह पूजाओं की सूची में नहीं घुसाया गया — वहाँ जाकर यह "एक और
/// पूजा" जैसा दिखता, जो यह है नहीं।
class PaathListScreen extends StatefulWidget {
  const PaathListScreen({super.key});

  @override
  State<PaathListScreen> createState() => _PaathListScreenState();
}

class _PaathListScreenState extends State<PaathListScreen> {
  late Future<List<PaathSuchiEntry>> _suchi;

  /// `null` = सब दिखाओ। चालीसा और आरती एक ही तरह की चीज़ें हैं (बैठकर
  /// या खड़े होकर पढ़ी जाने वाली रचनाएँ), इसलिए अलग tab नहीं — एक ही
  /// सूची, ऊपर छन्नी (→ D-039)।
  PaathPrakar? _chhanni;

  @override
  void initState() {
    super.initState();
    _suchi = paathBhandar.suchi();
  }

  void _open(PaathSuchiEntry entry) {
    if (!entry.taiyar) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaathScreen(id: entry.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      // "अधिक" वाले कार्ड पर इसका नाम "चालीसा और आरती" है — खुलने पर
      // वही नाम दिखना चाहिए।
      appBar: AppBar(title: const Text('चालीसा और आरती')),
      // ⚠️ `bottom: false` यहाँ नहीं चलेगा — इस पन्ने के नीचे ऐप की
      // अपनी कोई पट्टी नहीं है, इसलिए सबसे नीचे का हिस्सा सीधे Android
      // के नेविगेशन बार के पीछे चला जाता है (फ़ोन पर पकड़ा गया, 4 सित)।
      // `top: false` इसलिए कि ऊपर AppBar पहले से सँभाल लेता है।
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<PaathSuchiEntry>>(
            future: _suchi,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const VidhivatStateView(
                  title: 'पाठों की सूची नहीं खुल सकी',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              if (!snapshot.hasData) {
                return const VidhivatStateView(
                  title: 'पाठ तैयार हो रहे हैं',
                  loading: true,
                );
              }

              final sab = snapshot.data!;
              final entries = _chhanni == null
                  ? sab
                  : sab
                      .where((e) => e.prakar == _chhanni)
                      .toList(growable: false);
              // जिस तरह का एक भी पाठ नहीं, उसकी छन्नी दिखाने का मतलब नहीं।
              final prakarMaujud = <PaathPrakar>[
                for (final p in PaathPrakar.values)
                  if (sab.any((e) => e.prakar == p)) p,
              ];
              return Panna(
                padding: const EdgeInsets.fromLTRB(
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.xxl,
                ),
                children: [
                  Text(
                    'बैठकर पढ़ने वाली स्तुतियाँ। इनके लिए कोई सामग्री या '
                    'संकल्प नहीं चाहिए — बस शुरू से आख़िर तक पढ़ना होता है।',
                    textAlign: TextAlign.justify,
                    style: type.bodyMedium,
                  ),
                  if (prakarMaujud.length > 1) ...[
                    const SizedBox(height: VidhivatSpacing.lg),
                    Wrap(
                      spacing: VidhivatSpacing.xs,
                      children: [
                        ChoiceChip(
                          label: const Text('सब'),
                          selected: _chhanni == null,
                          onSelected: (_) => setState(() => _chhanni = null),
                        ),
                        for (final p in prakarMaujud)
                          ChoiceChip(
                            label: Text(p.naam),
                            selected: _chhanni == p,
                            onSelected: (_) => setState(() => _chhanni = p),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: VidhivatSpacing.xxl),
                  for (final entry in entries) ...[
                    _PaathTile(entry: entry, onTap: () => _open(entry)),
                    const SizedBox(height: VidhivatSpacing.sm),
                  ],
                  // ── "और चालीसा आगे जोड़े जाएँगे … अपनी रिकॉर्डिंग के
                  //     साथ" वाली पंक्ति यहाँ थी — अब नहीं ──────────────
                  //
                  // वो हमारा प्लान था, यूज़र की बात नहीं — और उसमें एक ऐसा
                  // वायदा था जो अभी पूरा नहीं हो सकता: ऐप में **एक भी
                  // रिकॉर्डिंग नहीं है** — `assets/` में `audio/` फ़ोल्डर तक नहीं।
                  //
                  // जो चीज़ ऐप में नहीं है, उसका वायदा सूची के नीचे नहीं छपेगा।
                  // रिकॉर्डिंग आएंगी तो ख़ुद दिख जाएंगी (→ D-056)।
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaathTile extends StatelessWidget {
  final PaathSuchiEntry entry;
  final VoidCallback onTap;

  const _PaathTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final artwork = PaathAssets.forPaathId(entry.id);

    return VidhivatSurfaceCard(
      onTap: entry.taiyar ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primaryMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                artwork.assetPath,
                fit: BoxFit.contain,
                cacheHeight: 92,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(width: VidhivatSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.naam, style: type.cardTitle),
                const SizedBox(height: 2),
                Text(
                  entry.taiyar ? entry.ekLine : 'जल्द आएगा',
                  style: type.bodySmall,
                ),
              ],
            ),
          ),
          if (entry.taiyar)
            Icon(Icons.chevron_right, color: colors.textTertiary),
        ],
      ),
    );
  }
}
