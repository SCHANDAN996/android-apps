import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// **व्रत और उपवास** — कौन सा व्रत किस दिन पड़ता है।
///
/// ## यह पन्ना सिर्फ़ तारीख़ बताता है
///
/// ⚠️ *"यह व्रत करने से क्या मिलेगा"* — वो दावा ऐप कभी नहीं करेगा
/// (→ D-051)। हर व्रत का फल हर परंपरा में अलग बताया जाता है, और उसे
/// लिखना भविष्यवाणी के दर्जे में चला जाता है, जो इस ऐप की मनाही है।
///
/// ## तारीख़ कहाँ से आती है
///
/// पूरी सूची **पंचांग से बनती है** — वही व्यापिनी नियम जो त्योहारों में
/// लगता है। एक भी तारीख़ हाथ से नहीं भरी, इसलिए दस साल बाद भी सही रहेगी।
class VratScreen extends StatefulWidget {
  const VratScreen({super.key});

  @override
  State<VratScreen> createState() => _VratScreenState();
}

class _VratScreenState extends State<VratScreen> {
  /// ⚠️ यह हर दिन का पंचांग बनाता है — पैंतालीस दिन यानी पैंतालीस गणनाएँ।
  /// इसीलिए यह `initState` में एक बार चलता है, `build` में नहीं।
  late final Future<List<VratDin>> _vrat = _nikalo();

  Future<List<VratDin>> _nikalo() async => aaneWaleVrat(
        place: settings.place,
        masaSystem: settings.masaSystem,
        dinAage: 60,
        kitne: 15,
      );

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('व्रत और उपवास')),
      // नीचे ऐप की अपनी कोई पट्टी नहीं — `SafeArea` के बिना आख़िरी पंक्ति
      // नेविगेशन बार के पीछे चली जाती है।
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<VratDin>>(
            future: _vrat,
            builder: (context, snap) {
              if (snap.hasError) {
                return const VidhivatStateView(
                  title: 'व्रत की सूची नहीं बन सकी',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              if (!snap.hasData) {
                return const VidhivatStateView(
                  title: 'पंचांग से तारीख़ें निकाली जा रही हैं',
                  loading: true,
                );
              }

              final sab = snap.data!;
              return Panna(
                padding: const EdgeInsets.fromLTRB(
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.lg,
                  VidhivatSpacing.xxl,
                ),
                children: [
                  Text(
                    'आगे आने वाले व्रत — तारीख़ें आपके शहर के पंचांग से, '
                    'सूर्योदय के समय की तिथि पर।',
                    style: type.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: VidhivatSpacing.xl),
                  if (sab.isEmpty)
                    const VidhivatStateView(
                      title: 'अगले दो महीनों में कोई व्रत नहीं मिला',
                      icon: Icons.event_busy_outlined,
                    )
                  else
                    _VratSuchi(sab: sab),
                  const SizedBox(height: VidhivatSpacing.xl),
                  const _KaunSeVrat(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// तारीख़ों की सूची — कब, क्या, और उस दिन की तिथि।
class _VratSuchi extends StatelessWidget {
  final List<VratDin> sab;

  const _VratSuchi({required this.sab});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);

    return VidhivatSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < sab.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: colors.borderSubtle),
            Semantics(
              container: true,
              label: '${sab[i].niyam.naam}, ${sab[i].kabLikha}, '
                  '${tarikh(sab[i].tarikh)}, ${sab[i].tithiNaam}',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VidhivatSpacing.lg,
                  vertical: VidhivatSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 82,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sab[i].kabLikha,
                            style: type.label.copyWith(
                              color: sab[i].kitneDinBaad == 0
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                          ),
                          Text(
                            tarikhChhoti(sab[i].tarikh),
                            style: type.caption
                                .copyWith(color: colors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sab[i].niyam.naam, style: type.cardTitle),
                          const SizedBox(height: 2),
                          Text(
                            sab[i].tithiNaam,
                            style: type.bodySmall
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// कौन सा व्रत कब पड़ता है — नियम, ⓘ के पीछे।
///
/// यह हर बार पढ़ने की चीज़ नहीं है; जिसे जानना हो वो दबाए (→ D-045)।
class _KaunSeVrat extends StatelessWidget {
  const _KaunSeVrat();

  @override
  Widget build(BuildContext context) => VidhivatSrotButton(
        label: 'ये व्रत कब-कब पड़ते हैं',
        panktiyan: [
          for (final n in vratNiyam) VidhivatSrotPankti(n.naam, n.kabPadta),
        ],
        antimBaat: 'तारीख़ें आपके शहर के सूर्योदय से बनती हैं, इसलिए किसी '
            'दूसरे शहर के पंचांग से एक दिन का फ़र्क़ हो सकता है। आपके घर या '
            'क्षेत्र का चलन अलग हो तो वही सही है।',
      );
}
