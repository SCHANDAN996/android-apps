// मंत्र का हिस्सा — पूजा के कदम पर भी, और व्रत के पन्ने पर भी।
//
// पहले यह `vidhi_player_screen.dart` में निजी था। व्रत का पन्ना (→ D-075)
// वही मंत्र उसी रूप में दिखाता है, इसलिए यहाँ निकाला गया — एक जगह सुधार
// हो तो दोनों जगह लगे।
import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/vidhi.dart';
import 'common.dart';
import 'design_system.dart';

/// मंत्र वाला हिस्सा।
///
/// पाठ न भरा हो तो **ख़ाली डिब्बा दिखाते हैं, बना हुआ मंत्र नहीं।**
/// अंदाज़े से मंत्र लिखना इस प्रोजेक्ट में सबसे बड़ी ग़लती मानी गई है —
/// मंत्र ग़लत होना तिथि ग़लत होने से भी बुरा है।
class MantraKhand extends StatelessWidget {
  final Mantra mantra;

  /// पाठ न हो तो क्या लिखें। न दो तो पूजा के कदम वाला वाक्य।
  final String? khaaliSandesh;

  const MantraKhand({super.key, required this.mantra, this.khaaliSandesh});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    if (!mantra.hasPath) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VidhivatSectionHeader(title: 'मंत्र'),
          const SizedBox(height: VidhivatSpacing.sm),
          Chetavni(
            khaaliSandesh ??
                'इस कदम का मंत्र अभी ऐप में नहीं जोड़ा गया है। जब तक प्रामाणिक '
                    'स्रोत से न आ जाए, हम अंदाज़े से कुछ नहीं लिखेंगे — तब तक अपनी '
                    'पूजा-पुस्तिका से पढ़ें, या मन ही मन भगवान का नाम लें।',
          ),
          // ⚠️ यह **खुला ही रहेगा।** एक बार इसे भी ⓘ के पीछे भेजा गया
          // था (भरे मंत्र वाले नियम के साथ मिलाने के चक्कर में), पर
          // जाँच ने पकड़ लिया — और वो सही थी।
          //
          // भरे मंत्र पर ⓘ के अंदर *हवाला* होता है, जो पूजा के बीच
          // नहीं चाहिए। यहाँ उसमें **वजह** होती है — कि मंत्र ख़ाली
          // क्यों है (जैसे नौ अलग नवग्रह-मंत्र अभी न जोड़े जाने का कारण)।
          // वो ठीक उसी जगह चाहिए जहाँ
          // ऐप अपनी कमी मान रहा है — वरना चेतावनी अधूरी रह जाती है।
          if (mantra.vikalp.isNotEmpty)
            Text(mantra.vikalp, style: type.bodySmall),
          if (mantra.chetavni.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.sm),
            Chetavni(mantra.chetavni),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VidhivatSectionHeader(title: 'मंत्र'),
        const SizedBox(height: VidhivatSpacing.sm),
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.elevated,
          padding: const EdgeInsets.all(VidhivatSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // सबसे बड़ा अक्षर पूरे ऐप में — यही बोलकर पढ़ा जाता है।
              SelectableText(mantra.devanagari, style: type.mantra),
              if (mantra.roman.isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                const VidhivatDivider(),
                const SizedBox(height: VidhivatSpacing.sm),
                Text('उच्चारण', style: type.label),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(mantra.roman, style: type.mantraTransliteration),
              ],
              if (mantra.arth.isNotEmpty) ...[
                const SizedBox(height: VidhivatSpacing.lg),
                const VidhivatDivider(),
                const SizedBox(height: VidhivatSpacing.sm),
                Text('अर्थ', style: type.label),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(mantra.arth, style: type.mantraMeaning),
              ],
            ],
          ),
        ),
        const SizedBox(height: VidhivatSpacing.md),

        // ── यहाँ पहले हर मंत्र पर लाल चेतावनी थी — अब नहीं (→ D-042) ──
        //
        // वो वाक्य था "यह मंत्र अभी पंडित जी से पास नहीं हुआ है", और वो
        // **हर** भरे हुए मंत्र पर दिखता था — 203 में से 150 कदमों पर।
        // दो दिक़्क़तें थीं:
        //
        // 1. वो ठीक उसी कदम पर नीचे छपे स्रोत से टकराता था — यूज़र
        //    "स्रोत: ऋग्वेद ७.५९.१२ · भरोसा ऊँचा" और "पास नहीं हुआ"
        //    एक साथ पढ़ता था।
        // 2. जब हर कदम पर चेतावनी हो, तो वो पढ़ी ही नहीं जाती।
        //
        // अब पूजा के पन्ने पर **एक बार** साफ़ लिखा है कि यह घर की सरल
        // पद्धति है और हर पाठ के नीचे स्रोत मिलेगा। यहाँ वे चीज़ें
        // दिखती हैं जो सचमुच काम की हैं — **सावधानी**, दूसरा चलन और स्रोत।
        //
        // ⚠️ जिस कदम का पाठ **है ही नहीं**, वहाँ चेतावनी अब भी पूरी
        // ताक़त से लगती है (ऊपर `!mantra.hasPath` वाला हिस्सा) — वही
        // असली चेतावनी है, और वो अब भीड़ में नहीं खोती।

        // ── स्रोत, भरोसा और दूसरा चलन — ⓘ के अंदर ──────────────
        //
        // ये तीनों पहले मंत्र के नीचे खुले पड़े थे। नापने पर पता चला
        // कि **मंत्र से सवा तीन गुना ज़्यादा** सहायक-पाठ था (मंत्र
        // औसतन 107 अक्षर, स्रोत 175, दूसरा चलन 165)।
        //
        // पूजा करते आदमी को मंत्र चाहिए, हवाला नहीं। इसलिए तीनों अब
        // एक बटन के पीछे हैं — जिसे जानना हो वो दबाए।
        //
        // ⚠️ जिस कदम का पाठ **है ही नहीं**, वहाँ की चेतावनी छिपाई
        // नहीं गई (ऊपर `!mantra.hasPath` वाला हिस्सा) — वही असली
        // चेतावनी है और वो दिखती ही रहनी चाहिए (→ D-042)।
        if (mantra.strot.isNotEmpty ||
            mantra.vikalp.isNotEmpty ||
            mantra.chetavni.isNotEmpty)
          PaathKeBaareMein(mantra: mantra),
      ],
    );
  }
}

/// "इस पाठ के बारे में" — स्रोत, भरोसा और दूसरा चलन, एक बटन के पीछे।
///
/// ## यह क्यों बना
///
/// पहले ये तीनों मंत्र के नीचे खुले पड़े थे। नापने पर निकला कि हर भरे
/// मंत्र के साथ **मंत्र से सवा तीन गुना ज़्यादा** सहायक-पाठ है —
/// मंत्र औसतन 107 अक्षर, स्रोत 175, दूसरा चलन 165।
///
/// पूजा के बीच में आदमी को **मंत्र** चाहिए; स्रोत और पाठ-भेद तब काम
/// आते हैं जब कोई जाँचने बैठे। इसलिए वो सब यहाँ, एक दबाव पीछे।
///
/// छिपाया कुछ नहीं गया — बटन पर साफ़ लिखा है कि अंदर क्या है, और जहाँ
/// दो चलन हों वो बटन पर ही दिख जाता है।
///
/// ⚠️ अब यही रूप चालीसा और पूजा-विवरण पर भी है, इसलिए शीट बनाने का
/// काम [VidhivatSrotButton] करता है — तीनों जगह एक जैसा (→ D-045)।
class PaathKeBaareMein extends StatelessWidget {
  final Mantra mantra;

  const PaathKeBaareMein({super.key, required this.mantra});

  @override
  Widget build(BuildContext context) => VidhivatSrotButton(
        label: mantra.chetavni.isNotEmpty
            ? 'इस पाठ के बारे में · सावधानी'
            : mantra.vikalp.isNotEmpty
                ? 'इस पाठ के बारे में · इस पर दो चलन हैं'
                : 'इस पाठ के बारे में',
        shirshak: 'इस पाठ के बारे में',
        panktiyan: [
          VidhivatSrotPankti('सावधानी', mantra.chetavni),
          VidhivatSrotPankti('भरोसा', mantra.bharosa.naam),
          VidhivatSrotPankti('यह पाठ कहाँ से है', mantra.strot),
          VidhivatSrotPankti('दूसरा चलन', mantra.vikalp),
        ],
        antimBaat: 'आपके घर या क्षेत्र का चलन अलग हो तो वही सही है।',
      );
}
