// कथा का हिस्सा — पूजा के कदम पर भी, और व्रत के पन्ने से खुली कथा में भी।
//
// पहले यह `vidhi_player_screen.dart` में निजी था। व्रत की कथाएँ (→ D-075)
// अब पूजा के बाहर भी खुलती हैं, इसलिए यहाँ निकाला गया।
import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/katha.dart';
import 'common.dart';
import 'design_system.dart';

/// **कथा** — पाँच अध्याय, एक-एक करके (→ D-060)।
///
/// ## यह अकेला सबसे लंबा कदम है
///
/// सत्यनारायण की कथा लगभग तीन हज़ार शब्द है — पढ़ने में बीस से पच्चीस
/// मिनट। पूरी कथा एक साथ खोल देने पर पन्ना इतना लंबा हो जाता है कि
/// पढ़ने वाला अपनी जगह खो देता है, और यह वो कदम है जहाँ पूरा परिवार
/// बैठकर सुन रहा होता है।
///
/// इसलिए अध्याय **एक-एक करके** खुलते हैं। हर अध्याय के ऊपर उसका सार और
/// लगभग कितने मिनट लगेंगे, यह लिखा रहता है।
///
/// ⚠️ **कोई अध्याय छिपा नहीं है।** पाँचों के शीर्षक हमेशा दिखते हैं —
/// यह वैसा ही है जैसा ℹ पर तय हुआ था (→ D-056): एक दबाव पीछे, ग़ायब
/// नहीं। जो सुन रहा है उसे यह भी पता रहना चाहिए कि आगे कितना बाक़ी है।
class KathaKhand extends StatefulWidget {
  final String id;

  const KathaKhand({super.key, required this.id});

  @override
  State<KathaKhand> createState() => _KathaKhandState();
}

class _KathaKhandState extends State<KathaKhand> {
  late final Future<Katha> _katha = kathaBhandar.katha(widget.id);

  /// कौन-कौन से अध्याय खुले हैं। पहला शुरू से खुला रहता है, ताकि
  /// पढ़ना शुरू करने के लिए एक दबाव भी न लगे।
  final Set<int> _khule = {1};

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return FutureBuilder<Katha>(
      future: _katha,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Chetavni(
            'कथा खुल नहीं सकी। ऐप दोबारा खोलकर कोशिश करें — तब तक अपनी '
            'कथा-पुस्तिका से पढ़ें।',
            serious: true,
          );
        }
        if (!snap.hasData) {
          return Text('कथा खुल रही है…',
              textAlign: TextAlign.justify, style: type.bodySmall);
        }
        final katha = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VidhivatSectionHeader(
              title: katha.naam,
              supportingText: '${katha.adhyayKul} अध्याय · '
                  'लगभग ${katha.minute} मिनट',
            ),
            const SizedBox(height: VidhivatSpacing.sm),

            // ⚠️ यह पंक्ति हटाई नहीं जा सकती। कथा हिंदी में कही गई है,
            // शब्दशः संस्कृत पाठ नहीं — और यूज़र को यह पता होना चाहिए,
            // क्योंकि उसकी पोथी से फ़र्क़ मिलेगा (→ D-060)।
            Chetavni(katha.roop.batao),

            for (final a in katha.adhyay) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        _khule.contains(a.kram)
                            ? _khule.remove(a.kram)
                            : _khule.add(a.kram);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(VidhivatSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.shirshak, style: type.cardTitle),
                                  const SizedBox(height: VidhivatSpacing.xxs),
                                  Text(
                                    '${a.saar}  ·  लगभग ${a.minute} मिनट',
                                    textAlign: TextAlign.justify,
                                    style: type.bodySmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _khule.contains(a.kram)
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: colors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_khule.contains(a.kram))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          VidhivatSpacing.md,
                          0,
                          VidhivatSpacing.md,
                          VidhivatSpacing.md,
                        ),
                        // ⚠️ कथा ज़ोर से पढ़ी जाती है, और फ़ोन दो फ़ुट दूर
                        // रखा होता है — इसलिए `bodyLarge`, `bodyMedium`
                        // नहीं। वही वजह जो संकल्प पर थी।
                        child: SelectableText(
                          a.gadya,
                          textAlign: TextAlign.justify,
                          style: type.bodyLarge.copyWith(height: 1.75),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: VidhivatSpacing.md),
            VidhivatSrotButton(
              label: 'यह कथा कहाँ से आई',
              panktiyan: [
                VidhivatSrotPankti('रूप', katha.roop.batao),
                VidhivatSrotPankti('स्रोत', katha.strot),
                VidhivatSrotPankti('कब सुनाई जाती है', katha.kabSunayen),
              ],
              antimBaat: 'आपके घर या क्षेत्र में कथा थोड़ी अलग कही जाती हो '
                  'तो वही सही है।',
            ),
          ],
        );
      },
    );
  }
}
