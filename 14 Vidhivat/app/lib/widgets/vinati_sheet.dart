import 'package:flutter/material.dart';

import '../screens/dakshina_screen.dart';
import '../theme.dart';
import 'common.dart';
import 'dakshina_card.dart' show DakshinaShabd;
import 'design_system.dart';

/// दक्षिणा की विनती वाली पट्टी के शब्द (→ D-132, `docs/32` §6.2)।
///
/// ⚠️ `docs/20_KAMAI_YOJANA.md` §6.4 की मनाही यहाँ भी — `dakshina_test.dart` इस
/// फ़ाइल का भी पहरा देता है।
abstract final class VinatiShabd {
  static const baat =
      'विधिवत मुफ़्त है — कोई विज्ञापन नहीं, कोई खाता नहीं। जो आज '
      'इसमें है, वह सबके लिए है और रहेगा। ऐप उपयोगी लगा हो, तो स्वेच्छा से '
      'दक्षिणा दे सकते हैं।';

  static const kholo = 'दक्षिणा का पन्ना खोलें';

  static const abhiNahi = 'अभी नहीं';
}

/// नीचे से उठने वाली छोटी पट्टी — दस बार आने पर, कभी न देने वाले से (→ D-132)।
///
/// ⛔ **पट्टी पर पैसा नहीं।** राशियाँ, PayU, "पैसा कहाँ जाता है" — सब
/// `DakshinaScreen` में, जो बटन से खुलता है। पैसा तभी जब वहाँ «दक्षिणा दें» दबे।
/// नीचे खिसकाकर बंद करना = «अभी नहीं»।
Future<void> dakshinaVinatiDikhao(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => const _DakshinaVinati(),
    );

class _DakshinaVinati extends StatelessWidget {
  const _DakshinaVinati();

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return SingleChildScrollView(
      key: const Key('dakshina_vinati'),
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        0,
        VidhivatSpacing.lg,
        VidhivatSpacing.xl,
      ),
      child: VidhivatReadableWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: VidhivatDiyaIcon(bhara: true, color: colors.primary)),
            const SizedBox(height: VidhivatSpacing.sm),
            Text(
              DakshinaShabd.upsheershak,
              textAlign: TextAlign.center,
              style: type.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              DakshinaShabd.shirshak,
              textAlign: TextAlign.center,
              style: type.sectionTitle,
            ),
            const SizedBox(height: VidhivatSpacing.md),
            Text(VinatiShabd.baat,
                textAlign: TextAlign.justify, style: type.bodyMedium),
            const SizedBox(height: VidhivatSpacing.lg),
            VidhivatButton(
              key: const Key('vinati_kholo'),
              label: VinatiShabd.kholo,
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute<void>(
                      builder: (_) => const DakshinaScreen()),
                );
              },
              fullWidth: true,
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            VidhivatButton(
              key: const Key('vinati_abhi_nahi'),
              label: VinatiShabd.abhiNahi,
              variant: VidhivatButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
              fullWidth: true,
            ),
            const SizedBox(height: VidhivatSpacing.md),
            Text(
              DakshinaShabd.vaikalpik,
              style: type.caption.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
