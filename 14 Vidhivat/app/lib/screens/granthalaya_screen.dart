import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/granth.dart';
import '../vidhi/paath_assets.dart';
import '../widgets/common.dart';
import '../widgets/reading_cards.dart';
import '../widgets/design_system.dart';
import 'granth_screen.dart';

/// ग्रंथालय — पूरे ग्रंथ, अध्याय-दर-अध्याय (→ D-098)।
///
/// "चालीसा और आरती" एक बैठक में पढ़ी जाने वाली छोटी रचनाएँ हैं। ग्रंथ कई
/// दिनों में पढ़ा जाता है — इसलिए उसकी अपनी जगह, और हर ग्रंथ याद रखता है
/// कि आप कहाँ तक पहुँचे।
///
/// यहाँ वही ग्रंथ दिखता है जिसका **पूरा पाठ ऐप में है**। "जल्द आएगा" वाली
/// कोई पंक्ति नहीं — जो चीज़ ऐप में नहीं है, उसका वायदा सूची में नहीं छपता
/// (→ D-056)।
class GranthalayaScreen extends StatefulWidget {
  const GranthalayaScreen({super.key});

  @override
  State<GranthalayaScreen> createState() => _GranthalayaScreenState();
}

class _GranthalayaScreenState extends State<GranthalayaScreen> {
  late final Future<List<GranthSuchiEntry>> _suchi = granthBhandar.suchi();

  void _kholo(GranthSuchiEntry g) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => GranthScreen(granth: g)),
      );

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ग्रंथालय')),
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<GranthSuchiEntry>>(
            future: _suchi,
            builder: (context, snap) {
              if (snap.hasError) {
                return const VidhivatStateView(
                  title: 'ग्रंथों की सूची नहीं खुल सकी',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              final suchi = snap.data;
              if (suchi == null) {
                return const VidhivatStateView(
                  title: 'ग्रंथालय खुल रहा है',
                  loading: true,
                );
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
                    'पूरे ग्रंथ, अध्याय-दर-अध्याय — हर श्लोक और हर चौपाई के साथ '
                    'सरल हिंदी अर्थ। आप जहाँ तक पढ़ें, वह इसी फ़ोन में याद रहता है।',
                    textAlign: TextAlign.justify,
                    style: type.bodyMedium,
                  ),
                  const SizedBox(height: VidhivatSpacing.xxl),
                  // सप्तशती `_suchi.json` में नहीं है (उसका पाठ अपने पुराने
                  // फ़ोल्डर में रहा), इसलिए सूची के बाद यहीं जोड़ी जाती है।
                  ReadingCardGrid(
                    gridKey: const Key('granth_catalog_grid'),
                    children: [
                      for (final g in [...suchi, GranthSuchiEntry.saptashati])
                        ReadingArtworkCard(
                            name: g.naam,
                            artwork: PaathAssets.forGranthId(g.id).assetPath,
                            onTap: () => _kholo(g)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
