import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// **सूर्यग्रहण** — कब, यहाँ से कैसा दिखेगा, और सूतक कब से।
///
/// ## चंद्रग्रहण वाले पन्ने से यह क्यों अलग है
///
/// चंद्रग्रहण जिसे दिखता है, एक जैसा दिखता है। सूर्यग्रहण में छाया पृथ्वी
/// पर पड़ती है, इसलिए **हर शहर का जवाब अलग** होता है — कहीं पूरा सूरज ढका,
/// कहीं आधा, और कुछ सौ किलोमीटर दूर कुछ भी नहीं। इसीलिए यहाँ हर ग्रहण के
/// साथ *"यहाँ कितना ढकेगा"* भी लिखा जाता है।
///
/// ⚠️ **आँख की चेतावनी इस पन्ने से कभी मत हटाना।** चंद्रग्रहण नंगी आँख से
/// देखा जा सकता है, सूर्यग्रहण नहीं — और यह ऐप उस अंतर को साफ़ लिखेगा।
///
/// ⚠️ **फल या असर का कोई दावा नहीं** (→ D-052, D-055)। यहाँ सिर्फ़ समय है।
class SuryaGrahanScreen extends StatefulWidget {
  const SuryaGrahanScreen({super.key});

  @override
  State<SuryaGrahanScreen> createState() => _SuryaGrahanScreenState();
}

class _SuryaGrahanScreenState extends State<SuryaGrahanScreen> {
  /// अगले पाँच साल — सूर्यग्रहण साल में दो से पाँच पड़ते हैं, पर किसी एक
  /// शहर से दिखने वाला दस साल में दो-तीन ही होता है।
  late final Future<List<SuryaGrahanDarshan>> _sab = _nikalo();

  Future<List<SuryaGrahanDarshan>> _nikalo() async {
    final aaj = DateTime.now();
    return suryaGrahan(
      se: aaj,
      tak: DateTime(aaj.year + 5, aaj.month, aaj.day),
    )
        .map((g) => suryaGrahanYahanSe(g, settings.place))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('सूर्यग्रहण')),
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<SuryaGrahanDarshan>>(
            future: _sab,
            builder: (context, snap) {
              if (snap.hasError) {
                return const VidhivatStateView(
                  title: 'ग्रहण की सूची नहीं बन सकी',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                );
              }
              if (!snap.hasData) {
                return const VidhivatStateView(
                  title: 'ग्रहण की गणना हो रही है',
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
                    'अगले पाँच साल के सूर्यग्रहण। समय ${settings.city.name} '
                    'का है, और "कितना दिखेगा" भी यहीं से — सूर्यग्रहण हर '
                    'शहर में अलग दिखता है।',
                    style: type.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: VidhivatSpacing.md),
                  const _AankhKiChetavni(),
                  const SizedBox(height: VidhivatSpacing.lg),
                  if (sab.isEmpty)
                    const VidhivatStateView(
                      title: 'अगले पाँच साल में कोई सूर्यग्रहण नहीं',
                      icon: Icons.event_busy_outlined,
                    )
                  else
                    for (final d in sab) ...[
                      _SuryaGrahanCard(darshan: d),
                      const SizedBox(height: VidhivatSpacing.md),
                    ],
                  const SizedBox(height: VidhivatSpacing.lg),
                  const _SuryaGrahanKeNiyam(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// UTC को इस शहर की घड़ी में बदलो।
///
/// ⚠️ इंजन के ग्रहण-समय **असली UTC पल** हैं (यह `muhurta.dart` वाले
/// घड़ी-वाले नक़ली UTC से अलग बात है — → D-043)।
DateTime _shaharKiGhadi(DateTime utc) =>
    utc.add(settings.place.timeZoneOffset);

/// सूरज को नंगी आँख से देखने की मनाही — यह सबसे ऊपर रहती है।
class _AankhKiChetavni extends StatelessWidget {
  const _AankhKiChetavni();

  @override
  Widget build(BuildContext context) => const Chetavni(
        'सूर्यग्रहण नंगी आँख से कभी मत देखिए — चश्मे, एक्स-रे या धुँधले '
        'काँच से भी नहीं। आँख को हमेशा के लिए नुक़सान हो सकता है, और तब '
        'दर्द भी नहीं होता। देखना ही हो तो ग्रहण देखने वाले प्रमाणित चश्मे '
        'से, या पानी में परछाईं से।',
        icon: Icons.visibility_off_outlined,
        serious: true,
      );
}

class _SuryaGrahanCard extends StatelessWidget {
  final SuryaGrahanDarshan darshan;

  const _SuryaGrahanCard({required this.darshan});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final din = _shaharKiGhadi(darshan.grahan.madhya);
    final dikhega = darshan.dikhega;

    return VidhivatSurfaceCard(
      variant: dikhega
          ? VidhivatCardVariant.elevated
          : VidhivatCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarikh(din), style: type.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      dikhega ? darshan.prakar.naam : 'सूर्यग्रहण',
                      style:
                          type.bodySmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              // ⚠️ चिप को `Flexible` चाहिए। 320dp पर 1.5x अक्षरों के साथ
              // "यहाँ नहीं दिखेगा" अकेला कार्ड से **सत्तर पिक्सल** चौड़ा
              // हो जाता है। चिप के अंदर अक्षर पहले से लचीले हैं, बस उसे
              // ऊपर से सीमा मिलनी चाहिए।
              Flexible(
                child: VidhivatStatusChip(
                  label: dikhega ? 'यहाँ दिखेगा' : 'यहाँ नहीं दिखेगा',
                  tone: dikhega
                      ? VidhivatStatusTone.success
                      : VidhivatStatusTone.neutral,
                ),
              ),
            ],
          ),

          // ── जो ग्रहण यहाँ दिखता ही नहीं, उसका समय देने का मतलब नहीं ──
          if (!dikhega) ...[
            const SizedBox(height: VidhivatSpacing.sm),
            Text(
              'यह ग्रहण ${settings.city.name} से नहीं दिखेगा — चंद्रमा की '
              'छाया यहाँ तक नहीं पहुँचेगी। इसलिए यहाँ सूतक भी नहीं है।',
              style: type.bodySmall.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.justify,
            ),
          ] else ...[
            const SizedBox(height: VidhivatSpacing.md),
            const VidhivatDivider(),
            Pankti('स्पर्श', hm(_shaharKiGhadi(darshan.shuru!))),
            Pankti('मध्य', hm(_shaharKiGhadi(darshan.madhya!)), bold: true),
            Pankti('मोक्ष', hm(_shaharKiGhadi(darshan.khatm!))),
            Pankti(
              'ग्रास',
              'सूरज का ${(darshan.maan * 100).round()}%',
              note: 'व्यास के हिसाब से',
            ),
            if (darshan.kendriyaShuru != null)
              Pankti(
                darshan.prakar == SuryaGrahanPrakar.khagras
                    ? 'खग्रास'
                    : 'कंकणाकृति',
                '${hm(_shaharKiGhadi(darshan.kendriyaShuru!))} – '
                    '${hm(_shaharKiGhadi(darshan.kendriyaKhatm!))}',
                note: _avadhi(darshan.kendriyaAvadhi!),
              ),

            // ── सूतक ──
            //
            // ⚠️ "बारह घंटे पहले" कभी मत लिखना। सूतक चार **प्रहर** पहले
            // लगता है, और प्रहर मौसम के साथ बदलता है (→ D-054)।
            //
            // ⚠️ सूतक अक्सर **पिछले दिन** शुरू होता है — सूर्यग्रहण में
            // चार प्रहर पहले, यानी बारह घंटे से भी ज़्यादा। इसीलिए
            // `samayAurDin` — बिना तारीख़ के "21:17 बजे से 15:07 बजे तक"
            // उल्टा पढ़ा जाता है (फ़ोन पर पकड़ा गया)।
            const SizedBox(height: VidhivatSpacing.sm),
            Chetavni(
              'सूतक ${samayAurDin(_shaharKiGhadi(darshan.sutakShuru!), din)} '
              'से ${samayAurDin(_shaharKiGhadi(darshan.sutakKhatm!), din)} '
              'तक।',
              icon: Icons.schedule_outlined,
              serious: true,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: VidhivatSpacing.md,
                bottom: VidhivatSpacing.sm,
              ),
              child: Text(
                'बच्चों, बूढ़ों और बीमारों के लिए सूतक '
                '${samayAurDin(_shaharKiGhadi(darshan.komalSutakShuru!), din)}'
                ' से माना जाता है।',
                style: type.bodySmall.copyWith(color: colors.textSecondary),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _avadhi(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds} सेकंड';
    final sekand = d.inSeconds % 60;
    return '${d.inMinutes} मिनट${sekand > 0 ? " $sekand सेकंड" : ""}';
  }
}

/// सूर्यग्रहण और सूतक के नियम — ⓘ के पीछे।
class _SuryaGrahanKeNiyam extends StatelessWidget {
  const _SuryaGrahanKeNiyam();

  @override
  Widget build(BuildContext context) => const VidhivatSrotButton(
        label: 'सूर्यग्रहण और सूतक के बारे में',
        panktiyan: [
          VidhivatSrotPankti('खग्रास',
              'चंद्रमा पूरे सूरज को ढक लेता है। दिन में अँधेरा हो जाता है।'),
          VidhivatSrotPankti(
              'कंकणाकृति',
              'चंद्रमा सूरज के ठीक बीच में तो आता है, पर उस दिन दूर होने की '
                  'वजह से छोटा पड़ता है — किनारे पर चमकती अँगूठी रह जाती है।'),
          VidhivatSrotPankti('खंडग्रास',
              'सूरज का कुछ हिस्सा ही ढकता है। भारत में ज़्यादातर यही दिखता है।'),
          VidhivatSrotPankti(
              'हर शहर में अलग क्यों',
              'चंद्रमा की छाया पृथ्वी पर कुछ सौ किलोमीटर चौड़ी ही होती है। '
                  'इसीलिए एक ही ग्रहण एक शहर में पूरा दिखता है और दूसरे में '
                  'बिल्कुल नहीं।'),
          VidhivatSrotPankti(
              'सूतक',
              'सूर्यग्रहण में ग्रहण से चार प्रहर पहले लगता है — चंद्रग्रहण '
                  'के तीन से एक ज़्यादा। ग्रहण छूटने पर उतरता है। जो ग्रहण '
                  'यहाँ दिखता ही नहीं, उसका सूतक भी नहीं होता।'),
          VidhivatSrotPankti(
              'प्रहर',
              'दिन के चार, रात के चार। प्रहर तीन घंटे का नहीं होता — गर्मी '
                  'में दिन का प्रहर बड़ा होता है और रात का छोटा, जाड़े में '
                  'उल्टा। इसीलिए सूतक हर बार अलग-अलग लंबा होता है।'),
          VidhivatSrotPankti('बच्चे, बूढ़े और बीमार',
              'उनके लिए सूतक सिर्फ़ एक प्रहर पहले से माना जाता है।'),
          VidhivatSrotPankti(
              'गणना',
              'उस शहर से, उस पल, सूर्य और चंद्रमा के बिंब आसमान में कितनी '
                  'दूर हैं — यही नापा जाता है। समय NASA के ग्रहण-कैटलॉग से '
                  'और सूतक Drik Panchang से मिलाया हुआ है।'),
        ],
        antimBaat: 'ऐप सिर्फ़ समय बताता है। ग्रहण के फल या किसी राशि पर '
            'असर का कोई दावा यहाँ नहीं है। सूतक में क्या करना है, यह अपने '
            'घर के चलन और पंडित जी से तय करें।',
      );
}
