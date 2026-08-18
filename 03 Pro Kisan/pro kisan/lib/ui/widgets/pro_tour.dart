import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';

/// 🧭 ऐप का रास्ता दिखाने वाली परत — **एक ही जगह, सब screen के लिए**।
///
/// ## पहले क्या ख़राब था
///
/// हर screen `tutorial_coach_mark` को सीधे, **बिना कुछ तय किए** बुलाती थी।
/// उस package का default आकार **गोला** है और default padding बड़ा — इसलिए
/// एक छोटे से बटन के लिए भी चौथाई screen का गोला बन जाता था। किसान को यह
/// पता ही नहीं चलता था कि छूना कहाँ है।
///
/// ऊपर से आगे बढ़ने का कोई बटन नहीं था — कहीं भी छूने से अगला क़दम आ जाता,
/// जो और भ्रम पैदा करता।
///
/// ## अब क्या है
///
/// | | पहले | अब |
/// |---|---|---|
/// | आकार | गोला (चौथाई screen) | **चौकोर**, जितना बड़ा असली बटन है |
/// | घेरा | बहुत बड़ा | बस 4 pixel का हाशिया |
/// | आगे बढ़ना | कहीं भी छुओ | **साफ़ "आगे →" बटन** |
/// | कितना बचा | पता नहीं | **"2 / 5"** ऊपर लिखा |
/// | जगह | तय (कभी-कभी screen से बाहर) | ऊपर/नीचे — जहाँ जगह हो |
///
/// ## ⚠️ इस ऐप के किसान
///
/// बहुत से पढ़ नहीं पाते (देखें `docs/ANPADH_UI_NIYAM.md`)। इसलिए —
/// एक क़दम में **एक ही बात**, बड़े अक्षर, और आगे बढ़ने का बटन इतना बड़ा कि
/// उँगली से चूके नहीं।
class ProTour {
  ProTour._();

  /// एक क़दम — किस चीज़ पर, क्या लिखा जाए
  static Future<void> dikhao(
    BuildContext context, {
    required List<ProTourStep> steps,
    required VoidCallback onKhatam,
  }) async {
    if (steps.isEmpty) {
      onKhatam();
      return;
    }

    // बाद में `.next()` बुलाने के लिए इसका पता चाहिए
    late TutorialCoachMark tour;

    final targets = <TargetFocus>[];
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      targets.add(
        TargetFocus(
          identify: 'step_$i',
          keyTarget: s.key,

          // ⚠️ यही सबसे बड़ा सुधार — चौकोर, असली बटन जितना
          shape: ShapeLightFocus.RRect,
          radius: 10,
          paddingFocus: 4,

          // असली बटन दबाने से आगे मत बढ़ो — किसान ग़लती से एंट्री कर देगा।
          // आगे बढ़ने का एक ही रास्ता: "आगे" बटन।
          enableTargetTab: false,
          enableOverlayTab: false,

          contents: [
            TargetContent(
              align: _kahanRakhein(s.key),
              builder: (_, __) => _Card(
                step: s,
                kaunSa: i + 1,
                kul: steps.length,
                aakhri: i == steps.length - 1,
                onAage: () => tour.next(),
                onChhodo: () => tour.finish(),
              ),
            ),
          ],
        ),
      );
    }

    tour = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.82,
      // ऊपर अपना "छोड़ें" है, package वाला छोटा नहीं चाहिए
      hideSkip: true,
      onFinish: onKhatam,
      onSkip: () {
        onKhatam();
        return true;
      },
    )..show(context: context);
  }

  /// लिखा हुआ ऊपर रखें या नीचे — जहाँ जगह हो।
  ///
  /// पहले यह तय (हमेशा नीचे) था, इसलिए screen के निचले हिस्से वाले बटन का
  /// समझाने वाला डिब्बा screen से बाहर चला जाता और आधा कटा दिखता।
  static ContentAlign _kahanRakhein(GlobalKey key) {
    try {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return ContentAlign.bottom;
      final upar = box.localToGlobal(Offset.zero).dy;
      final screen =
          MediaQuery.of(key.currentContext!).size.height;
      // ऊपर आधे में है तो डिब्बा नीचे, नीचे आधे में है तो ऊपर
      return upar < screen / 2 ? ContentAlign.bottom : ContentAlign.top;
    } catch (_) {
      return ContentAlign.bottom;
    }
  }
}

/// एक क़दम की बात
class ProTourStep {
  /// किस चीज़ को घेरना है
  final GlobalKey key;

  /// एक पंक्ति में — यह चीज़ है क्या
  final String title;

  /// दो पंक्ति में — इससे करना क्या है
  final String desc;

  const ProTourStep({
    required this.key,
    required this.title,
    required this.desc,
  });
}

/// समझाने वाला डिब्बा
class _Card extends StatelessWidget {
  final ProTourStep step;
  final int kaunSa;
  final int kul;
  final bool aakhri;
  final VoidCallback onAage;
  final VoidCallback onChhodo;

  const _Card({
    required this.step,
    required this.kaunSa,
    required this.kul,
    required this.aakhri,
    required this.onAage,
    required this.onChhodo,
  });

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // कितना बचा — किसान को पता रहे कि यह कब ख़त्म होगा
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$kaunSa / $kul',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DairyTheme.primaryTeal),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onChhodo,
                child: Padding(
                  // उँगली के लिए बड़ा इलाक़ा
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 4),
                  child: Text(
                    isHi ? 'छोड़ें' : 'Skip',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            step.title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DairyTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            step.desc,
            style: TextStyle(
                fontSize: 14.5, height: 1.5, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 14),

          // ⚠️ बटन पूरी चौड़ाई का और 48 ऊँचा — किसान की उँगली चूके नहीं
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onAage,
              style: FilledButton.styleFrom(
                backgroundColor: DairyTheme.primaryTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                  aakhri ? Icons.check_rounded : Icons.arrow_forward_rounded),
              label: Text(
                aakhri
                    ? (isHi ? 'समझ गया' : 'Got it')
                    : (isHi ? 'आगे' : 'Next'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
