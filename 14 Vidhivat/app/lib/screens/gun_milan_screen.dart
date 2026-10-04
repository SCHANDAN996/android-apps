import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/kundali_profiles.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// "1½", "½", "26" — गुण का अंक, आधे के साथ।
String gunAnk(double ank) {
  final poora = ank.floor();
  final aadha = (ank - poora) >= 0.25;
  if (!aadha) return '$poora';
  return poora == 0 ? '½' : '$poora½';
}

/// चंद्रमा नक्षत्र की सीमा के इतने पास हो (अंश) तो जन्म-समय का आधा घंटा उसे
/// दूसरे नक्षत्र में ले जा सकता है — चंद्रमा घंटे में लगभग आधा अंश चलता है।
const double chandraSeemaKiHad = 0.3;

/// अष्टकूट गुण मिलान — दो सहेजी हुई कुंडलियों के बीच (→ D-110)।
///
/// ## जो यहाँ नहीं है, और नहीं आएगा
/// - **फ़ैसला।** "रिश्ता ठीक है / नहीं है", "इतने गुण चाहिए" — कुछ नहीं। यह
///   तालिकाओं का जोड़ है; उसका मतलब निकालना ऐप का काम नहीं।
/// - **"दोष" शब्द**, किसी कूट का फल, उपाय, परिहार।
/// - दक्षिणा — यह पन्ना किसी की शादी की बात का है, माँगने की जगह नहीं।
///
/// ## जो खुला लिखा है (ⓘ के पीछे नहीं → D-056)
/// 1. यह गणित है, फ़ैसला नहीं।
/// 2. तीन कूटों की तालिकाएँ पुस्तकों में अलग-अलग छपी हैं — जहाँ दूसरी तालिका
///    का अंक अलग आता है, वह साथ में दिखता है (→ D-041)।
/// 3. चंद्रमा नक्षत्र की सीमा के पास हो तो जन्म-समय की ज़रा सी भूल अंक बदल देगी।
class GunMilanScreen extends StatefulWidget {
  /// जिनमें से चुनना है।
  final List<KundaliProfile> profiles;

  /// शुरू में चुने हुए — जाँच के लिए।
  final KundaliProfile? vara;
  final KundaliProfile? kanya;

  const GunMilanScreen({
    super.key,
    required this.profiles,
    this.vara,
    this.kanya,
  });

  @override
  State<GunMilanScreen> createState() => _GunMilanScreenState();
}

class _GunMilanScreenState extends State<GunMilanScreen> {
  KundaliProfile? _var;
  KundaliProfile? _kanya;

  @override
  void initState() {
    super.initState();
    _var = widget.vara;
    _kanya = widget.kanya;
  }

  RashiSthiti _chandra(KundaliProfile p) =>
      computeKundali(p.janmUtc, p.place)[KundaliGraha.chandra];

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final v = _var;
    final k = _kanya;
    final ekHi = v != null && k != null && v.id == k.id;

    return Scaffold(
      appBar: AppBar(title: const Text('गुण मिलान')),
      body: SafeArea(
        child: VidhivatSacredBackdrop(
          child: Panna(
            children: [
              // ── पहला खुला सच ───────────────────────────────────────
              const Chetavni(
                'यह आठ पुरानी तालिकाओं के अंकों का जोड़ है — जन्म के चंद्रमा की '
                'राशि और नक्षत्र से। रिश्ता कैसा रहेगा, या कितने गुण पर क्या '
                'करना चाहिए, यह ऐप नहीं बताता।',
              ),
              _chunav('वर', _var, (p) => setState(() => _var = p)),
              const SizedBox(height: VidhivatSpacing.sm),
              _chunav('कन्या', _kanya, (p) => setState(() => _kanya = p)),
              if (v != null && k != null && !ekHi)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _var = k;
                      _kanya = v;
                    }),
                    icon: const Icon(Icons.swap_vert),
                    label: const Text('वर और कन्या आपस में बदलें'),
                  ),
                ),
              const SizedBox(height: VidhivatSpacing.md),
              if (v == null || k == null)
                Text(
                  'दोनों की कुंडली चुनिए। जो यहाँ नहीं है, उसकी कुंडली पहले '
                  '"जन्म कुंडली" वाले पन्ने पर बनाइए।',
                  style: type.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else if (ekHi)
                Text(
                  'दोनों जगह एक ही कुंडली चुनी है।',
                  style: type.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else
                ..._natija(context, v, k),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chunav(String label, KundaliProfile? chuna,
          ValueChanged<KundaliProfile?> onChanged) =>
      DropdownButtonFormField<String>(
        // `initialValue` एक ही बार पढ़ा जाता है — अदला-बदली पर नया खाना बने
        key: ValueKey('chunav-$label-${chuna?.id}'),
        initialValue: chuna?.id,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final p in widget.profiles)
            DropdownMenuItem(
              value: p.id,
              child: Text(p.naam, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (id) =>
            onChanged(widget.profiles.where((p) => p.id == id).firstOrNull),
      );

  List<Widget> _natija(
      BuildContext context, KundaliProfile v, KundaliProfile k) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final vc = _chandra(v);
    final kc = _chandra(k);
    final m = gunMilan(varChandra: vc.nirayan, kanyaChandra: kc.nirayan);
    final purani = m.puraniTalikaSeKul;

    return [
      // ── तीसरा खुला सच: चंद्रमा सीमा के पास ───────────────────────
      for (final (p, c) in [(v, vc), (k, kc)])
        if (c.nakshatraSeemaSeDoori < chandraSeemaKiHad)
          Chetavni(
            '${p.naam} का चंद्रमा ${c.nakshatraNaam} नक्षत्र की सीमा के बिल्कुल '
            'पास है। जन्म का समय आधा घंटा भी अलग हो तो नक्षत्र दूसरा होगा, और '
            'नीचे के अंक बदल जाएँगे।',
            serious: true,
          ),
      VidhivatSurfaceCard(
        variant: VidhivatCardVariant.highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('कुल गुण', style: type.bodyMedium),
            const SizedBox(height: VidhivatSpacing.xxs),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: gunAnk(m.kul), style: type.displayMedium),
                TextSpan(
                    text: '  $gunMilanAdhiktam में से',
                    style: type.bodyLarge),
              ]),
              key: const ValueKey('kul-gun'),
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              '${v.naam} — ${vc.rashiNaam}, ${vc.nakshatraNaam}\n'
              '${k.naam} — ${kc.rashiNaam}, ${kc.nakshatraNaam}',
              style: type.bodySmall.copyWith(color: colors.textSecondary),
            ),
            if (purani != null) ...[
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                'पुरानी छपी तालिका से जोड़ें तो ${gunAnk(purani)}',
                style: type.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: VidhivatSpacing.md),
      const VidhivatSectionHeader(title: 'आठ कूट'),
      const SizedBox(height: VidhivatSpacing.xs),
      VidhivatSurfaceCard(
        padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
        child: Column(
          children: [
            for (final a in m.koot)
              Pankti(
                a.koot.naam,
                '${gunAnk(a.ank)} / ${a.koot.adhiktam}',
                note: [
                  'वर ${a.varKa} · कन्या ${a.kanyaKa}',
                  if (a.puraniTalikaSe != null)
                    'पुरानी छपी तालिका में ${gunAnk(a.puraniTalikaSe!)}',
                  if (a.talikaBantiHai) 'यह तालिका हर पुस्तक में अलग छपी है',
                ].join('\n'),
              ),
          ],
        ),
      ),
      const SizedBox(height: VidhivatSpacing.sm),
      // ── दूसरा खुला सच ───────────────────────────────────────
      Text(
        'योनि, गण और वश्य की तालिकाएँ पुस्तकों में अलग-अलग छपी हैं। इसलिए '
        'किसी और पंचांग या ऐप में कुल एक-दो गुण कम-ज़्यादा मिल सकता है — '
        'वह ग़लती नहीं, दूसरी तालिका है।',
        style: type.bodySmall.copyWith(color: colors.textSecondary),
      ),
      const SizedBox(height: VidhivatSpacing.md),
      _srot(),
    ];
  }

  Widget _srot() => const VidhivatSrotButton(
        label: 'ये अंक कैसे निकले',
        panktiyan: [
          VidhivatSrotPankti(
            'आठ कूट',
            'वर्ण 1, वश्य 2, तारा 3, योनि 4, ग्रह मैत्री 5, गण 6, भकूट 7, '
                'नाड़ी 8 — कुल 36। नाम और क्रम मुहूर्तचिंतामणि के विवाह प्रकरण '
                'से। सब कुछ जन्म के चंद्रमा से निकलता है, लग्न से नहीं।',
          ),
          VidhivatSrotPankti(
            'वर्ण',
            'राशि का पुराना वर्ग (जाति नहीं)। वर का वर्ग कन्या के बराबर या '
                'ऊपर हो तो 1।',
          ),
          VidhivatSrotPankti(
            'वश्य',
            'राशियाँ पाँच वर्गों में गिनी जाती हैं। कौन सी राशि किस वर्ग में '
                'है और किस जोड़े के कितने अंक — दोनों बातें पुस्तकों में अलग '
                'हैं। ऊपर आजकल की प्रचलित तालिका का अंक है।',
          ),
          VidhivatSrotPankti(
            'तारा',
            'एक के नक्षत्र से दूसरे के नक्षत्र तक गिनकर नौ से भाग; शेष 3, 5 '
                'या 7 न हो तो उस ओर से डेढ़ गुण। दोनों ओर से गिना जाता है।',
          ),
          VidhivatSrotPankti(
            'योनि',
            'हर नक्षत्र की एक योनि गिनी जाती है। चौदह योनियों के जोड़ों की '
                'तालिका दो तरह की छपी मिलती है — एक आजकल के कंप्यूटर-पंचांगों '
                'वाली, एक 1932 की "अति बृहत् अवकहड़ा चक्रम्" वाली। जहाँ दोनों '
                'अलग हैं, दोनों अंक दिखते हैं।',
          ),
          VidhivatSrotPankti(
            'ग्रह मैत्री',
            'दोनों की चंद्र राशि के स्वामियों की आपसी मित्रता से: दोनों मित्र '
                'या एक ही स्वामी 5, एक मित्र एक सम 4, दोनों सम 3, एक मित्र एक '
                'शत्रु 1, एक सम एक शत्रु आधा, दोनों शत्रु 0।',
          ),
          VidhivatSrotPankti(
            'गण',
            'नक्षत्र तीन गणों में बँटे हैं। एक ही गण हो तो 6। बाक़ी जोड़ों '
                'में पुस्तकें एक खाने पर अलग हैं; वहाँ दोनों अंक दिखते हैं।',
          ),
          VidhivatSrotPankti(
            'भकूट',
            'एक की राशि से दूसरे की राशि कौन सी पड़ती है: दूसरी-बारहवीं, '
                'पाँचवीं-नौवीं या छठी-आठवीं हो तो 0, नहीं तो 7।',
          ),
          VidhivatSrotPankti(
            'नाड़ी',
            'नक्षत्र तीन नाड़ियों में बँटे हैं। दोनों की नाड़ी अलग हो तो 8, '
                'एक हो तो 0।',
          ),
          VidhivatSrotPankti(
            'जो नहीं जोड़ा गया',
            'पुस्तकों में इन अंकों के कई अपवाद लिखे हैं, और वे भी हर पुस्तक '
                'में अलग हैं। ऐप सिर्फ़ मूल तालिका का अंक दिखाता है।',
          ),
        ],
        antimBaat: 'घर के पंचांग की मेलापक सारणी में अंक अलग हो तो वही '
            'मानिए — वह आपकी परंपरा की तालिका है। अंकों का मतलब निकालना इस '
            'ऐप का काम नहीं।',
      );
}
