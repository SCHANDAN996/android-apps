import 'package:flutter/material.dart';

import '../services/dakshina_service.dart';
import '../theme.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/dakshina_card.dart';
import '../widgets/design_system.dart';
import 'dakshina_screen.dart';

/// Player की मार्गदर्शिका समाप्त होने के बाद का शांत technical handoff।
///
/// यह screen पूजा की धार्मिक वैधता अथवा सफलता का दावा नहीं करती। यह सिर्फ़
/// बताती है कि app ने इस मार्गदर्शिका के सभी चरण दिखा दिए हैं।
///
/// ## दक्षिणा सिर्फ़ यहाँ माँगी जाती है, और कहीं नहीं (→ D-053)
/// पूजा **पूरी हो चुकी** है — मूल्य दिया जा चुका, तभी माँगा जा रहा है।
/// एक कदम पहले (विधि प्लेयर में) यही माँग विज्ञापन से भी बुरी होती।
///
/// और छोड़ने का रास्ता नीचे पहले से है — *"होम पर लौटें"*, पूरी चौड़ाई
/// का। इसीलिए "अभी नहीं" वाला अलग बटन जान-बूझकर नहीं रखा: छोड़ना यहाँ
/// **मना करना नहीं, बस आगे बढ़ना** है।
class PujaCompletionScreen extends StatelessWidget {
  final Vidhi vidhi;

  const PujaCompletionScreen({super.key, required this.vidhi});

  void _returnToVidhiHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _kholoDakshinaPanna(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DakshinaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('मार्गदर्शिका')),
      body: VidhivatSacredBackdrop(
        child: SafeArea(
          bottom: false,
          child: Semantics(
            container: true,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(VidhivatSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VidhivatSacredHero(
                        // ── छोटा hero, ताकि दक्षिणा पहली तह में आए ────────
                        //
                        // फ़ोन पर पकड़ा गया: पूरा hero इतनी जगह ले लेता था कि दक्षिणा
                        // का डिब्बा स्क्रीन से नीचे चला जाता था — और जो दिखता ही नहीं,
                        // वो माँगा ही नहीं जाता।
                        //
                        // `compact` से चित्र 272 से 148 हो जाता है और शीर्षक भी
                        // एक दर्जा छोटा — लगभग डेढ़ सौ पिक्सल बचते हैं (→ D-063)।
                        compact: true,
                        eyebrow: 'मार्गदर्शिका',
                        title: 'मार्गदर्शिका पूरी हुई',
                        subtitle:
                            'आपने इस मार्गदर्शिका के सभी चरण देख लिए हैं।',
                        icon: Icons.auto_awesome_outlined,
                        artworkAsset: DevotionalAssets.completion.assetPath,
                        artworkSemanticLabel:
                            DevotionalAssets.completion.semanticLabel,
                        semanticLabel: '${vidhi.naam} की मार्गदर्शिका पूरी हुई',
                        footer: Text(
                          vidhi.naam,
                          style: type.sectionTitle.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                      // ── "इस मार्गदर्शिका में 9 चरण हैं" वाला कार्ड यहाँ था ──
                      //
                      // आदमी अभी-अभी नौ के नौ चरण चलकर यहाँ पहुँचा है। उसे गिनती
                      // बताना कुछ नहीं देता — न कोई काम, न कोई भरोसा। और लेता
                      // पूरा एक कार्ड था — ठीक उस जगह जो इस पन्ने की सबसे शांत
                      // होनी चाहिए (→ D-056)।

                      // घड़ी का नियम बही में है (→ `dakshina_service.dart`):
                      // दे चुके हैं तो छह महीने चुप, तीन बार दिख चुका तो
                      // तीस दिन। यहाँ सिर्फ़ पूछा जाता है, तय नहीं होता।
                      if (dakshina.dikhega(DateTime.now())) ...[
                        const SizedBox(height: VidhivatSpacing.xxl),
                        DakshinaCard(
                          onVistaar: () => _kholoDakshinaPanna(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevated,
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: VidhivatReadableWidth(
            // लेटे रूप में यह बटन 853dp चौड़ा हो जाता था (→ D-062)।
              child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VidhivatSpacing.lg,
                VidhivatSpacing.sm,
                VidhivatSpacing.lg,
                VidhivatSpacing.md,
              ),
              // यह बटन `popUntil(isFirst)` करता है — यानी होम पर ले जाता
              // है, विधि पर नहीं। नाम वही कहे जो होता है।
              child: VidhivatButton(
                label: 'होम पर लौटें',
                semanticLabel: '${vidhi.naam} के बाद होम पर लौटें',
                onPressed: () => _returnToVidhiHome(context),
                icon: Icons.home_outlined,
                fullWidth: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
