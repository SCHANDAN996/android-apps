/// **"कौन से दिन टालने हैं"** — गृह प्रवेश जैसी पूजाओं पर (→ D-059)।
///
/// ## यह क्यों बना
///
/// गृह प्रवेश में सबसे पहला सवाल यही होता है — *कौन सी तारीख़?* ऐप
/// बाक़ी सब देता था (36 सामग्री, 14 कदम, मंत्र) पर उसी सवाल पर लिखता
/// था *"पंडित जी से तारीख़ निकलवाएँ"*।
///
/// ## पर यह मुहूर्त नहीं है, और नहीं बनेगा
///
/// D-019 ने मुहूर्त इसलिए रोका था कि गुरु/शुक्र के अस्त की गणना नहीं
/// हो सकती, और नियम शास्त्र से नहीं लिए गए थे। **वो रोक अब भी क़ायम
/// है।** यह डिब्बा तारीख़ *सुझाता नहीं* — सिर्फ़ यह बताता है कि किन
/// दिनों में मांगलिक काम नहीं होते, और हर दिन के साथ वजह लिखता है।
///
/// ```
/// जानते हैं  →  कौन से दिन टालने हैं     ← यह डिब्बा
/// नहीं जानते →  कौन सा दिन सबसे शुभ है   ← पंडित जी
/// ```
///
/// ⚠️ यहाँ कभी "यह दिन शुभ है" मत लिखना। साफ़ दिनों की गिनती तक नहीं —
/// क्योंकि "बाक़ी 19 दिन ठीक हैं" पढ़ते ही वो सुझाव बन जाता है।
library;

import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'design_system.dart';

/// कितने दिन आगे तक देखें। दो महीने — गृह प्रवेश की तैयारी इतनी ही
/// पहले शुरू होती है, और इससे ज़्यादा में सूची पढ़ी नहीं जाती।
const int taalneKeDin = 60;

class TaalneWaleDinCard extends StatefulWidget {
  const TaalneWaleDinCard({super.key});

  @override
  State<TaalneWaleDinCard> createState() => _TaalneWaleDinCardState();
}

class _TaalneWaleDinCardState extends State<TaalneWaleDinCard> {
  late Future<List<TaalneWalaDin>> _din;

  @override
  void initState() {
    super.initState();
    _din = _nikalo();
  }

  /// ⚠️ साठ दिन का पंचांग सस्ता नहीं है — हर दिन के लिए सूर्योदय,
  /// चंद्र-स्थिति और भद्रा निकलती है। इसलिए यह `Future` में जाता है और
  /// `initState` में एक ही बार चलता है, हर `build` पर नहीं।
  Future<List<TaalneWalaDin>> _nikalo() async {
    final aaj = DateTime.now();
    return taalneWaleDin(
      aaj,
      aaj.add(const Duration(days: taalneKeDin)),
      settings.place,
      masaSystem: settings.masaSystem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);

    return FutureBuilder<List<TaalneWalaDin>>(
      future: _din,
      builder: (context, snap) {
        if (!snap.hasData) {
          return VidhivatSurfaceCard(
            child: Text('आगे के दिन देखे जा रहे हैं…', style: type.bodySmall),
          );
        }
        final sab = snap.data!;
        final poore = pooreDinTalneWale(sab);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VidhivatSurfaceCard(
              variant: VidhivatCardVariant.information,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: VidhivatIconSize.medium,
                        color: VidhivatTheme.colorsOf(context).info,
                      ),
                      const SizedBox(width: VidhivatSpacing.sm),
                      Expanded(
                        child: Text(
                          poore == 0
                              ? 'अगले $taalneKeDin दिनों में कोई ऐसा दिन नहीं '
                                  'जिसे पूरा टाला जाता हो।'
                              : 'अगले $taalneKeDin दिनों में $poore दिन ऐसे हैं '
                                  'जिनमें मांगलिक काम नहीं होते।',
                          style: type.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VidhivatSpacing.sm),
                  // ⚠️ यह पंक्ति हटाई नहीं जा सकती। इसके बिना यह डिब्बा
                  // मुहूर्त होने का दावा करने लगता है (→ D-019, D-059)।
                  Text(
                    'ऐप शुभ दिन नहीं बताता — वह पंडित जी तय करते हैं। '
                    'यहाँ सिर्फ़ वही है जो पंचांग से सीधे निकलता है।',
                    style: type.bodySmall,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            if (sab.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              _TaalneKiSuchi(sab: sab),
            ],
          ],
        );
      },
    );
  }
}

/// पूरी सूची — ⓘ के पीछे, क्योंकि यह लंबी होती है (→ D-056)।
class _TaalneKiSuchi extends StatelessWidget {
  final List<TaalneWalaDin> sab;

  const _TaalneKiSuchi({required this.sab});

  @override
  Widget build(BuildContext context) {
    // वजह-वार बाँटो, तारीख़-वार नहीं। साठ दिन की तारीख़ें पढ़ी नहीं
    // जातीं; "पितृ पक्ष — 26 सित से 10 अक्तू" पढ़ा जाता है।
    final panktiyan = <VidhivatSrotPankti>[];
    for (final v in TaalneKiVajah.values) {
      final din = sab.where((d) => d.vajahein.contains(v)).toList();
      if (din.isEmpty) continue;
      panktiyan.add(VidhivatSrotPankti(
        '${v.naam} — ${din.length} दिन',
        '${_tarikhein(din, v)}\n\n${v.kyon}',
      ));
    }

    return VidhivatSrotButton(
      label: 'कौन से दिन, और क्यों',
      shirshak: 'अगले $taalneKeDin दिनों में',
      panktiyan: panktiyan,
      antimBaat: 'पंचक और गंडमूल पर हर घर और क्षेत्र का चलन अलग है। '
          'अंतिम निर्णय अपने पंडित जी से करें।',
    );
  }
}

/// तारीख़ें — लगातार दिनों को "से … तक" में समेटकर।
///
/// पितृ पक्ष के पंद्रह दिन पंद्रह तारीख़ों की तरह छापना पढ़ने लायक़ नहीं
/// रहता। भद्रा वाले दिनों पर समय भी लिखा जाता है, क्योंकि वो पूरा दिन
/// नहीं टलता।
String _tarikhein(List<TaalneWalaDin> din, TaalneKiVajah v) {
  if (v == TaalneKiVajah.bhadra) {
    return din
        .map((d) => '${tarikhChhoti(d.din)} — '
            '${hm(d.bhadraKaal!.start)} से ${hm(d.bhadraKaal!.end)} तक')
        .join('\n');
  }

  final tukde = <String>[];
  var shuru = din.first.din;
  var pichla = shuru;
  for (final d in din.skip(1)) {
    if (d.din.difference(pichla).inDays == 1) {
      pichla = d.din;
      continue;
    }
    tukde.add(_tukda(shuru, pichla));
    shuru = d.din;
    pichla = d.din;
  }
  tukde.add(_tukda(shuru, pichla));
  return tukde.join(' · ');
}

String _tukda(DateTime se, DateTime tak) => se == tak
    ? tarikhChhoti(se)
    : '${tarikhChhoti(se)} से ${tarikhChhoti(tak)} तक';
