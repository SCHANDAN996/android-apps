import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// **चंद्रग्रहण** — कब, कहाँ से दिखेगा, और सूतक कब से।
///
/// ## यह पन्ना क्या नहीं करता
///
/// ⚠️ **ग्रहण के फल या असर का कोई दावा नहीं।** *"इस ग्रहण का किस राशि पर
/// क्या असर होगा"* — वो भविष्यवाणी है, और इस ऐप की साफ़ मनाही (→ D-052)।
/// यहाँ सिर्फ़ समय है।
///
/// ## सूतक — दो शर्तें, दोनों ज़रूरी
///
/// 1. ग्रहण **यहाँ से दिखे** — जो दिखता ही नहीं, उसका सूतक नहीं
/// 2. वो **उपछाया ग्रहण न हो** — वो आँख से दिखता ही नहीं
///
/// गणित `engine/lib/src/grahan.dart` में है, और NASA के कैटलॉग से
/// मिलाया हुआ है — समय ढाई मिनट के भीतर।
class GrahanScreen extends StatefulWidget {
  const GrahanScreen({super.key});

  @override
  State<GrahanScreen> createState() => _GrahanScreenState();
}

class _GrahanScreenState extends State<GrahanScreen> {
  /// अगले पाँच साल — ग्रहण साल में दो-तीन ही होते हैं, इसलिए इतनी दूर
  /// तक देखना पड़ता है कि सूची ख़ाली न लगे।
  late final Future<List<GrahanDarshan>> _sab = _nikalo();

  Future<List<GrahanDarshan>> _nikalo() async {
    final aaj = DateTime.now();
    return chandraGrahan(
      se: aaj,
      tak: DateTime(aaj.year + 5, aaj.month, aaj.day),
    ).map((g) => dekhaJayega(g, settings.place)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('चंद्रग्रहण')),
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: FutureBuilder<List<GrahanDarshan>>(
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
                    'अगले पाँच साल के चंद्रग्रहण। समय ${settings.city.name} '
                    'का है, और "दिखेगा या नहीं" भी यहीं से।',
                    style: type.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: VidhivatSpacing.xl),
                  if (sab.isEmpty)
                    const VidhivatStateView(
                      title: 'अगले पाँच साल में कोई चंद्रग्रहण नहीं',
                      icon: Icons.event_busy_outlined,
                    )
                  else
                    for (final d in sab) ...[
                      _GrahanCard(darshan: d),
                      const SizedBox(height: VidhivatSpacing.md),
                    ],
                  const SizedBox(height: VidhivatSpacing.lg),
                  const _GrahanKeNiyam(),
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
/// घड़ी-वाले नक़ली UTC से अलग बात है — → D-043)। दिखाने से पहले शहर का
/// समय-क्षेत्र जोड़ना पड़ता है, वरना साढ़े पाँच घंटे पीछे दिखेगा।
DateTime _shaharKiGhadi(DateTime utc) =>
    utc.add(settings.place.timeZoneOffset);

class _GrahanCard extends StatelessWidget {
  final GrahanDarshan darshan;

  const _GrahanCard({required this.darshan});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final g = darshan.grahan;
    final din = _shaharKiGhadi(g.madhya);

    return VidhivatSurfaceCard(
      variant: darshan.dikhega
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
                      g.prakar.naam,
                      style: type.bodySmall
                          .copyWith(color: colors.textSecondary),
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
                  label: darshan.dikhega ? 'यहाँ दिखेगा' : 'यहाँ नहीं दिखेगा',
                  tone: darshan.dikhega
                      ? VidhivatStatusTone.success
                      : VidhivatStatusTone.neutral,
                ),
              ),
            ],
          ),

          // ── जो ग्रहण यहाँ दिखता ही नहीं, उसका समय देने का मतलब नहीं ──
          //
          // वो कहीं और के लिए है। तारीख़ बता देना काफ़ी है, ताकि सुनकर
          // आया आदमी देख सके कि "हाँ, ग्रहण तो है, पर यहाँ नहीं दिखेगा"।
          if (!darshan.dikhega) ...[
            const SizedBox(height: VidhivatSpacing.sm),
            Text(
              'यह ग्रहण ${settings.city.name} से नहीं दिखेगा — उस समय '
              'चंद्रमा क्षितिज के नीचे रहेगा। इसलिए यहाँ सूतक भी नहीं है।',
              style: type.bodySmall.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.justify,
            ),
          ] else ...[
            const SizedBox(height: VidhivatSpacing.md),
            const VidhivatDivider(),
            // ⚠️ यहाँ हर समय `samayAurDinChhota` से जाता है, `hm` से
            // नहीं। चंद्रग्रहण आधी रात के आर-पार चलता है — 16 जून 2030
            // को स्पर्श 15 जून की रात 22:50 पर है और मध्य 16 जून 00:02
            // पर। बिना तारीख़ के दोनों एक ही रात के लगते हैं।
            //
            // (सूर्यग्रहण में यह नहीं हो सकता — वहाँ सूरज ऊपर होना ज़रूरी
            // है, इसलिए ग्रहण आधी रात पार नहीं करता।)
            if (g.sparsha != null)
              Pankti(
                'स्पर्श',
                samayAurDinChhota(_shaharKiGhadi(g.sparsha!), din),
                // ग्रहण लगा हुआ चाँद निकलेगा — यहाँ स्पर्श का समय
                // दिखाना ही काफ़ी नहीं, तब चाँद उगा ही नहीं होता।
                note: darshan.chandrodayParShuru
                    ? 'तब चाँद निकला नहीं होगा — यहाँ ग्रहण '
                        '${hm(_shaharKiGhadi(darshan.sthaniyaShuru!))} बजे '
                        'चंद्रोदय के साथ दिखना शुरू होगा'
                    : null,
              ),
            Pankti('मध्य', hm(din), bold: true),
            if (g.moksha != null)
              Pankti(
                'मोक्ष',
                samayAurDinChhota(_shaharKiGhadi(g.moksha!), din),
                note: darshan.chandrastParKhatm
                    ? 'यहाँ उससे पहले ही चाँद डूब जाएगा — '
                        '${hm(_shaharKiGhadi(darshan.sthaniyaKhatm!))} बजे'
                    : null,
              ),
            Pankti(
              'उपछाया',
              '${samayAurDinChhota(_shaharKiGhadi(g.upachhayaSparsha), din)}'
                  ' – '
                  '${samayAurDinChhota(_shaharKiGhadi(g.upachhayaMoksha), din)}',
              note: g.sparsha == null ? 'आँख से लगभग कुछ नहीं दिखता' : null,
            ),

            // ── सूतक — इस पन्ने की सबसे काम की बात ──
            //
            // ⚠️ "नौ घंटे पहले" कभी मत लिखना। सूतक तीन **प्रहर** पहले
            // लगता है, और प्रहर मौसम के साथ बदलता है (→ D-054)। यहाँ
            // सिर्फ़ समय लिखा जाता है, कोई सूत्र नहीं।
            //
            // ⚠️ सूतक अक्सर **पिछले दिन** शुरू होता है (तीन प्रहर पहले),
            // और चंद्रग्रहण आधी रात के बाद छूटे तो अंत **अगले दिन** पड़ता
            // है। इसीलिए `samayAurDin` — बिना तारीख़ के दोनों सिरे उल्टे
            // पढ़े जाते हैं (फ़ोन पर पकड़ा गया)।
            if (darshan.sutakShuru != null) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              Chetavni(
                'सूतक '
                '${samayAurDin(_shaharKiGhadi(darshan.sutakShuru!), din)} से '
                '${samayAurDin(_shaharKiGhadi(darshan.sutakKhatm!), din)} '
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
            ] else
              Padding(
                padding: const EdgeInsets.only(top: VidhivatSpacing.sm),
                child: Text(
                  'उपछाया ग्रहण पर सूतक नहीं माना जाता।',
                  style:
                      type.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// ग्रहण और सूतक के नियम — ⓘ के पीछे।
class _GrahanKeNiyam extends StatelessWidget {
  const _GrahanKeNiyam();

  @override
  Widget build(BuildContext context) => const VidhivatSrotButton(
        label: 'ग्रहण और सूतक के बारे में',
        panktiyan: [
          VidhivatSrotPankti('खग्रास',
              'पूरा चंद्रमा पृथ्वी की असली छाया में आ जाता है।'),
          VidhivatSrotPankti('खंडग्रास',
              'चंद्रमा का कुछ हिस्सा ही असली छाया में आता है।'),
          VidhivatSrotPankti(
              'उपछाया',
              'चंद्रमा सिर्फ़ हल्की छाया से गुज़रता है — आँख से लगभग कुछ '
                  'नहीं दिखता, बस ज़रा धुँधला पड़ता है। इस पर सूतक नहीं '
                  'माना जाता।'),
          VidhivatSrotPankti(
              'सूतक',
              'चंद्रग्रहण में ग्रहण से तीन प्रहर पहले लगता है, और ग्रहण '
                  'छूटने पर उतरता है। जो ग्रहण यहाँ दिखता ही नहीं, उसका '
                  'सूतक भी नहीं होता।'),
          VidhivatSrotPankti(
              'प्रहर',
              'दिन के चार, रात के चार। प्रहर तीन घंटे का नहीं होता — '
                  'गर्मी में दिन का प्रहर बड़ा होता है और रात का छोटा, '
                  'जाड़े में उल्टा। इसीलिए सूतक हर बार अलग-अलग लंबा होता है।'),
          VidhivatSrotPankti(
              'बच्चे, बूढ़े और बीमार',
              'उनके लिए सूतक सिर्फ़ एक प्रहर पहले से माना जाता है, तीन '
                  'नहीं।'),
          VidhivatSrotPankti('गणना',
              'Meeus की विधि से — समय NASA के ग्रहण-कैटलॉग से और सूतक '
                  'Drik Panchang से मिलाया हुआ।'),
        ],
        antimBaat: 'ऐप सिर्फ़ समय बताता है। ग्रहण के फल या किसी राशि पर '
            'असर का कोई दावा यहाँ नहीं है। सूतक में क्या करना है, यह अपने '
            'घर के चलन और पंडित जी से तय करें।',
      );
}
