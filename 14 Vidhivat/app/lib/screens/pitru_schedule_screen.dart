import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/pitru_schedule.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'vidhi_screen.dart';

/// पितृ पक्ष का स्थानीय तिथि-क्रम — पूर्णिमा + कृष्ण पक्ष की 15 तिथियाँ।
class PitruScheduleScreen extends StatelessWidget {
  final int? year;

  const PitruScheduleScreen({super.key, this.year});

  @override
  Widget build(BuildContext context) {
    final selectedYear = year ?? DateTime.now().year;
    final dates = pitruSchedule(selectedYear, settings.place);
    return Scaffold(
      appBar: AppBar(title: const Text('पितृ पक्ष की तिथियाँ')),
      body: SafeArea(
        child: VidhivatSacredBackdrop(
          child: Panna(
            children: [
              Text('$selectedYear · ${settings.place.name}',
                  style: VidhivatTheme.typographyOf(context).pageTitle),
              const SizedBox(height: VidhivatSpacing.sm),
              const Chetavni(
                'पूर्णिमा श्राद्ध पितृ पक्ष से पहले अलग दिन है। उसके बाद कृष्ण '
                'प्रतिपदा से अमावस्या तक 15 तिथियाँ आती हैं। तिथि अंग्रेज़ी '
                'तारीख़ नहीं है। श्राद्ध के लिए अपराह्न (दिन का चौथा भाग) '
                'महत्त्वपूर्ण है; आपकी कुल-परंपरा मालूम हो तो उसे पहले रखें।',
              ),
              const SizedBox(height: VidhivatSpacing.md),
              for (final item in dates) ...[
                VidhivatSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.rule.name,
                          style: VidhivatTheme.typographyOf(context).cardTitle),
                      const SizedBox(height: VidhivatSpacing.xs),
                      Text(tarikh(item.date)),
                      Text(
                        item.rule.paksha == 0
                            ? 'पूर्णिमा का अलग स्मरण, पितृ पक्ष शुरू होने से पहले।'
                            : item.rule.tithi == 15
                                ? 'तिथि अज्ञात हो तो सभी ज्ञात-अज्ञात पूर्वजों का स्मरण।'
                                : 'जिन परिजन की मृत्यु इस चंद्र-तिथि को हुई हो, उनका स्मरण।',
                        textAlign: TextAlign.justify,
                        style: VidhivatTheme.typographyOf(context).bodySmall,
                      ),
                      if (item.ambiguous && item.otherCandidate != null)
                        Text(
                            'दूसरी संभावित तारीख़: ${tarikh(item.otherCandidate!)}'),
                      if (item.missedKaal)
                        const Text(
                            'अपराह्न में तिथि नहीं मिली; अवधि के आधार पर दिन चुना गया।'),
                      const SizedBox(height: VidhivatSpacing.xs),
                      VidhivatButton(
                        label: 'सरल स्मरण खोलें',
                        icon: Icons.arrow_forward_rounded,
                        variant: VidhivatButtonVariant.text,
                        fullWidth: true,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VidhiScreen(id: 'shraadh'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VidhivatSpacing.sm),
              ],
              Text(
                'गणना: दृक् पंचांग, अपराह्न-व्यापिनी नियम। क्षय/वृद्धि '
                'तिथि में पास के प्रकाशित पंचांग से मिलान करें।',
                style: VidhivatTheme.typographyOf(context).caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
