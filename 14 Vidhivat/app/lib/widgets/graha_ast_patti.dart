/// **गुरु / शुक्र अस्त की पट्टी** — जिन पूजाओं में तारीख़ चुननी पड़ती है,
/// वहाँ "कौन से दिन टालने हैं" के नीचे (→ D-119, `docs/30` §५ का म५)।
///
/// ## यह क्या कहती है, और क्या नहीं
///
/// सिर्फ़ इतना: *इन तारीख़ों के आस-पास गुरु (या शुक्र) सूर्य के पास हैं, और
/// ग्रंथ इस दौर में मांगलिक काम नहीं कराते।* कोई दिन "शुभ" नहीं कहती, कोई
/// तारीख़ नहीं सुझाती — वह रोक (D-019) जस की तस है।
///
/// ## ⚠ यह अभी बंद क्यों है
///
/// अस्त की तारीख़ें छपी-प्रकाशित सूचियों में आपस में **कुछ दिन** अलग मिलती
/// हैं — गुरु में चार दिन तक, शुक्र की लंबी अस्त में दो-तीन हफ़्ते तक — क्योंकि
/// गिनने के तीन तरीक़े चलते हैं (`engine/lib/src/graha_ast.dart` का सिर)।
/// ऐप किस तरीक़े से दिखाए, यह डेवलपर के घर के पंचांग की अस्त-सूची देखकर तय
/// होगा; तब [grahaAstGanana] चुनो और [grahaAstPattiKhuli] `true` करो।
/// नाप और खोलने की शर्त: `docs/08_VERIFICATION.md` §21।
///
/// ⚠️ यहाँ से **"लगभग"** शब्द और *"अपने पंचांग से मिला लें"* वाली पंक्ति
/// कभी मत हटाना — इनके बिना यह पट्टी वह दावा करने लगेगी जो हम कर नहीं सकते।
library;

import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../theme.dart';
import 'common.dart';
import 'design_system.dart';

/// पट्टी ऐप में दिखे या नहीं। **अभी नहीं** — ऊपर की टिप्पणी देखो।
const bool grahaAstPattiKhuli = false;

/// पट्टी किस तरीक़े से गिनी हुई तारीख़ें दिखाए।
const AstGanana grahaAstGanana = AstGanana.ansh;

/// [aaj] से [aageDin] दिन आगे तक जो अस्त-काल छूते हैं — आगे-पीछे के
/// "वृद्ध" और "बाल" दिनों समेत। तारीख़ के क्रम में।
///
/// ⚠️ [AstGanana.kalansh] धीमा है — इसे `build` के भीतर मत बुलाना।
List<GrahaAst> aaneWaleGrahaAst(
  DateTime aaj,
  int aageDin,
  Place place, {
  AstGanana ganana = grahaAstGanana,
}) {
  final se = DateTime.utc(aaj.year, aaj.month, aaj.day);
  final tak = se.add(Duration(days: aageDin));
  // वृद्ध/बाल के दिन पंद्रह तक जाते हैं — उतना आगे-पीछे भी देखो
  const haashiya = Duration(days: 16);

  final mile = <GrahaAst>[
    for (final g in [Graha.guru, Graha.shukra])
      for (final a in grahaAstKaal(
          g, se.subtract(haashiya), tak.add(haashiya), place,
          ganana: ganana))
        if (!a.balyaAnt.isBefore(se) && !a.vardhakShuru.isAfter(tak)) a,
  ];
  mile.sort((a, b) => a.ast.compareTo(b.ast));
  return mile;
}

class GrahaAstPatti extends StatelessWidget {
  final List<GrahaAst> kaal;

  const GrahaAstPatti({super.key, required this.kaal});

  @override
  Widget build(BuildContext context) {
    if (kaal.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in kaal) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          _EkAst(a: a),
        ],
      ],
    );
  }
}

class _EkAst extends StatelessWidget {
  final GrahaAst a;

  const _EkAst({required this.a});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final naam = a.graha.naam;

    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.information,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.wb_twilight_outlined,
                size: VidhivatIconSize.medium,
                color: VidhivatTheme.colorsOf(context).info,
              ),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(
                child: Text(
                  '$naam अस्त — लगभग ${tarikhChhoti(a.astDin)} से '
                  '${tarikhChhoti(a.udayDin)} तक',
                  style: type.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          Text(
            'इस दौर में गृह प्रवेश, मुंडन, जनेऊ जैसे मांगलिक काम नहीं कराए '
            'जाते। अस्त से पहले के ${a.vardhakDin} और उदय के बाद के '
            '${a.balyaDin} दिन भी टाले जाते हैं — यानी '
            '${tarikhChhoti(a.vardhakShuru)} से ${tarikhChhoti(a.balyaAnt)} तक।',
            style: type.bodySmall,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          // ⚠️ यह पंक्ति हटाई नहीं जा सकती — ऊपर फ़ाइल के सिर की टिप्पणी।
          Text(
            'अलग-अलग पंचांग ये तारीख़ें कुछ दिन आगे-पीछे लिखते हैं — '
            'अपने पंचांग से मिला लें।',
            style: type.bodySmall,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: VidhivatSpacing.xs),
          VidhivatSrotButton(
            label: 'यह कैसे निकला',
            shirshak: '$naam अस्त',
            panktiyan: [
              VidhivatSrotPankti('अस्त क्या है', _kyaHai(a)),
              VidhivatSrotPankti('तारीख़ें', _tarikhein(a)),
              VidhivatSrotPankti('आगे-पीछे के दिन', _aagePeechhe(a)),
            ],
            antimBaat: 'अंतिम निर्णय अपने पंडित जी से करें।',
          ),
        ],
      ),
    );
  }
}

String _disha(bool purv) => purv ? 'पूर्व' : 'पश्चिम';

String _kyaHai(GrahaAst a) =>
    '${a.graha.naam} जब सूर्य के बहुत पास आ जाते हैं तो कुछ दिन दिखाई नहीं '
    'देते — इसी को अस्त कहते हैं। इस बार वे ${_disha(a.astPurvMein)} में '
    'डूबकर ${_disha(a.udayPurvMein)} में फिर दिखेंगे — यह गणना है; आँख से '
    'दिखना मौसम और जगह पर भी टिका है (→ D-138)।';

String _tarikhein(GrahaAst a) {
  final niyam = a.ganana == AstGanana.ansh
      ? 'सूर्य और ${a.graha.naam} के बीच ${a.kalansh} अंश से कम अंतर रहने पर '
          'अस्त माना गया है। सूर्यसिद्धांत में यही संख्या कालांश में है — वहाँ '
          'उदय-अस्त के समय का अंतर गिना जाता है; यह उसका अंश वाला नज़दीकी रूप है।'
      : 'जब ${a.graha.naam} का उदय या अस्त सूर्य के उदय या अस्त से '
          '${a.kalansh} कालांश (लगभग ${a.kalansh * 4} मिनट) के भीतर आ जाए, '
          'तब अस्त माना गया है (सूर्यसिद्धांत)।';
  return 'अस्त: ${tarikh(a.astDin)}\nउदय: ${tarikh(a.udayDin)}\n\n$niyam\n\n'
      'जो पंचांग आँख से दिखने के हिसाब से गिनते हैं, वे ये तारीख़ें कुछ दिन '
      'अलग लिखते हैं।';
}

String _aagePeechhe(GrahaAst a) =>
    'मुहूर्त चिंतामणि के अनुसार अस्त से पहले ${a.graha.naam} "वृद्ध" और उदय '
    'के बाद "बाल" माने जाते हैं, और उन दिनों में भी मांगलिक काम नहीं होते — '
    'इस बार ${a.vardhakDin} दिन पहले और ${a.balyaDin} दिन बाद।\n\n'
    'दूसरे मत: कुछ आचार्य दोनों ओर ${astKeMatantarDin[0]} दिन कहते हैं, कुछ '
    '${astKeMatantarDin[1]}, और बहुत ज़रूरी काम में ${astKeMatantarDin[2]} दिन।';
