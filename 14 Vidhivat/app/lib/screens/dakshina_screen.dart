import 'package:flutter/material.dart';

import '../vidhi/devotional_assets.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dakshina_card.dart';
import '../widgets/design_system.dart';

/// दक्षिणा का पूरा पन्ना — "अधिक" से, और पूजा पूरी होने वाले डिब्बे से।
///
/// ## यह पन्ना क्यों है
/// बहुत लोग उसी वक़्त नहीं देते, बाद में देते हैं। तब ढूँढ़ने की एक जगह
/// होनी चाहिए — वरना देने वाला भी लौट जाता है।
///
/// ## और इस पन्ने का सबसे ज़रूरी हिस्सा कौन सा है
/// नीचे वाला **"साफ़-साफ़"** — ख़ासकर यह पंक्ति कि *यह पूजा की दक्षिणा
/// नहीं है*। वही इस पूरे पन्ने को ईमानदार बनाती है (→ D-053)।
class DakshinaScreen extends StatelessWidget {
  const DakshinaScreen({super.key});

  /// राशि कहाँ लगती है — पाँच सच्ची पंक्तियाँ।
  ///
  /// ⚠️ इनमें कोई ऐसी चीज़ मत जोड़ना जो सचमुच न होती हो। ₹800 वाला अंक
  /// `docs/18_SROT_PANJI.md` से आया है और यूज़र उसे जाँच सकता है — यही
  /// इस पन्ने की असली ताक़त है, कोई भावनात्मक वाक्य नहीं।
  static const _kharch = <(IconData, String)>[
    (
      Icons.verified_outlined,
      'पंडित जी से हर पूजा की जाँच — लगभग ₹800 प्रति पूजा'
    ),
    (Icons.mic_none_outlined, 'मंत्रों की रिकॉर्डिंग'),
    (Icons.menu_book_outlined, 'पंचांग और शास्त्र की पुस्तकें'),
    (Icons.add_circle_outline, 'नई पूजाएँ और नए पाठ जोड़ना'),
    (Icons.storefront_outlined, 'Play Store की फ़ीस'),
  ];

  /// तीनों पंक्तियाँ ज़रूरी हैं। तीसरी सबसे ज़्यादा।
  static const _safSaf = <String>[
    'यह राशि ऐप बनाने वाले तक जाती है — किसी मंदिर, संस्था या पंडित को '
        'दान नहीं जाती।',
    'दक्षिणा देने से ऐप में कुछ नया नहीं खुलता। सब पूजाएँ, सब पाठ और सब '
        'पंचांग पहले से सबके लिए खुले हैं।',
    'यह पूजा की दक्षिणा नहीं है। पूजा की दक्षिणा वही है जो आप अपनी विधि '
        'में रखते हैं।',
  ];

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('दक्षिणा')),
      // ⚠️ नीचे `SafeArea(top: false)` — यानी **नीचे की जगह बचाई जाती
      // है।** यह पन्ना shell के अंदर नहीं खुलता, इसलिए इसके नीचे ऐप की
      // अपनी पट्टी नहीं होती; Android 15 का नेविगेशन बार सीधे इसी के
      // ऊपर बैठ जाता है। पहले यहाँ `bottom: false` लिखा था —
      // `bottom_inset_test` ने उसे पकड़ लिया।
      body: VidhivatSacredBackdrop(
        child: SafeArea(
          top: false,
          child: Panna(
            padding: const EdgeInsets.fromLTRB(
              VidhivatSpacing.lg,
              VidhivatSpacing.lg,
              VidhivatSpacing.lg,
              VidhivatSpacing.xxl,
            ),
            children: [
              // ── ऊपर hero — बाक़ी पन्नों जैसा ─────────────────
              //
              // यह इकलौता पन्ना था जो सीधे एक कार्ड से शुरू होता था — बाक़ी
              // सब पर hero है। माँगने वाला पन्ना ही अजनबी लगे, यह ठीक नहीं।
              //
              // चित्र दीया है, किसी देवता का नहीं — माँग के साथ किसी देवता का
              // चेहरा रखना ठीक नहीं लगता (→ D-053 का भाव)।
              VidhivatSacredHero(
                eyebrow: 'ऐप के लिए',
                title: DakshinaShabd.shirshak,
                subtitle: DakshinaShabd.hisaab,
                icon: Icons.volunteer_activism_outlined,
                artworkAsset: DevotionalAssets.diya.assetPath,
                artworkSemanticLabel: DevotionalAssets.diya.semanticLabel,
                compact: true,
                semanticLabel: DakshinaShabd.shirshak,
              ),
              const SizedBox(height: VidhivatSpacing.xl),
              VidhivatSurfaceCard(
                variant: VidhivatCardVariant.elevated,
                padding: const EdgeInsets.all(VidhivatSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'यह ऐप पूरी तरह मुफ़्त है। कोई विज्ञापन नहीं, कोई '
                      'खाता नहीं, कोई सदस्यता नहीं। जो आज इसमें है, वह '
                      'सबके लिए है।',
                      style: type.bodyMedium,
                    ),
                    const SizedBox(height: VidhivatSpacing.lg),
                    const DakshinaChunav(),
                    const SizedBox(height: VidhivatSpacing.md),
                    Text(
                      DakshinaShabd.vaikalpik,
                      style:
                          type.caption.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: VidhivatSpacing.xs),
                    // पैसा किस रास्ते जाएगा — यह बिना पूछे हर आदमी सोचता है।
                    Text(
                      DakshinaShabd.bhugtaan,
                      style: type.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: DakshinaShabd.vistaar),
              const SizedBox(height: VidhivatSpacing.md),
              VidhivatSurfaceCard(
                padding: const EdgeInsets.all(VidhivatSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (icon, baat) in _kharch) ...[
                      if (baat != _kharch.first.$2)
                        const SizedBox(height: VidhivatSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            size: VidhivatIconSize.small,
                            color: colors.primary,
                          ),
                          const SizedBox(width: VidhivatSpacing.sm),
                          Expanded(
                            child: Text(baat, style: type.bodyMedium),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'साफ़-साफ़'),
              const SizedBox(height: VidhivatSpacing.md),
              VidhivatSurfaceCard(
                variant: VidhivatCardVariant.information,
                padding: const EdgeInsets.all(VidhivatSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final baat in _safSaf) ...[
                      if (baat != _safSaf.first)
                        const SizedBox(height: VidhivatSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•', style: type.bodyMedium),
                          const SizedBox(width: VidhivatSpacing.sm),
                          Expanded(child: Text(baat, style: type.bodyMedium)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
