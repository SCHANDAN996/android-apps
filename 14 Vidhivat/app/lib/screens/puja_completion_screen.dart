import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/vidhi.dart';
import '../widgets/design_system.dart';

/// Player की मार्गदर्शिका समाप्त होने के बाद का शांत technical handoff।
///
/// यह screen पूजा की धार्मिक वैधता अथवा सफलता का दावा नहीं करती। यह सिर्फ़
/// बताती है कि app ने इस मार्गदर्शिका के सभी चरण दिखा दिए हैं।
class PujaCompletionScreen extends StatelessWidget {
  final Vidhi vidhi;

  const PujaCompletionScreen({super.key, required this.vidhi});

  void _returnToVidhiHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                      const SizedBox(height: VidhivatSpacing.xl),
                      VidhivatSurfaceCard(
                        variant: VidhivatCardVariant.information,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_list_numbered,
                              color: colors.info,
                              size: VidhivatIconSize.medium,
                            ),
                            const SizedBox(width: VidhivatSpacing.sm),
                            Expanded(
                              child: Text(
                                'इस मार्गदर्शिका में ${vidhi.charan.length} चरण हैं।',
                                style: type.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VidhivatSpacing.lg,
              VidhivatSpacing.sm,
              VidhivatSpacing.lg,
              VidhivatSpacing.md,
            ),
            child: VidhivatButton(
              label: 'विधि पर लौटें',
              semanticLabel: '${vidhi.naam} के बाद विधि पर लौटें',
              onPressed: () => _returnToVidhiHome(context),
              icon: Icons.home_outlined,
              fullWidth: true,
            ),
          ),
        ),
      ),
    );
  }
}
