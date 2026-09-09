import 'package:flutter/material.dart';

import '../services/dakshina_service.dart';
import '../theme.dart';
import 'design_system.dart';

/// स्क्रीन पर छपने वाले शब्द, एक ही जगह।
///
/// ⚠️ इन्हें बदलने से पहले `docs/20_KAMAI_YOJANA.md` §6.4 पढ़ना — वहाँ
/// ग्यारह वाक्य लिखे हैं जो **कभी नहीं** लिखने, और `dakshina_test.dart`
/// उनका पहरा देता है।
abstract final class DakshinaShabd {
  /// पाने वाले का नाम लेकर, हमेशा।
  ///
  /// ⚠️ अकेला *"दक्षिणा दें"* शीर्षक कभी मत लिखना। शब्द *दक्षिणा* ऐप की
  /// पूजाओं में **पहले से 42 जगह** है — वहाँ वह *पूजा की* दक्षिणा है, जो
  /// जजमान अंत में रखता है। नाम लिए बिना ऐप अपनी माँग को पूजा का ही एक
  /// कदम बना देगा।
  static const shirshak = 'विधिवत को दक्षिणा';

  static const upsheershak = 'ऐप के लिए';

  /// असली हिसाब, गोल बात नहीं। यही सबसे ज़्यादा असर करता है — और यह
  /// जाँचा जा सकता है (→ `docs/18_SROT_PANJI.md`)।
  static const hisaab = 'विधिवत मुफ़्त है, और पूरे ऐप में एक भी विज्ञापन '
      'नहीं है। एक पूजा को लिखने और पंडित जी से जँचवाने में लगभग सात घंटे '
      'और ₹800 लगते हैं।';

  static const nyota = 'उपयोगी लगा हो तो स्वेच्छा से दक्षिणा दीजिए।';

  static const bataan = 'दक्षिणा दें';

  /// हर जगह, हर बार। यही पूरे पन्ने को ईमानदार रखता है।
  static const vaikalpik = 'दक्षिणा वैकल्पिक है। देने या न देने से ऐप में '
      'कुछ नहीं बदलता — कोई पूजा या सुविधा बंद नहीं होती।';

  /// पैसा किस रास्ते जाता है — यह पूछे बिना हर आदमी सोचता है।
  ///
  /// Play Billing में ऐप को कार्ड या UPI का कोई विवरण मिलता ही
  /// नहीं — पूरी ख़रीद Play की अपनी शीट में होती है। यह डर मिटाना
  /// ज़रूरी है, और यह सच भी है।
  static const bhugtaan = 'भुगतान Google Play से होता है। ऐप आपके '
      'कार्ड या UPI का कोई विवरण नहीं देखता।';

  /// बटन बंद क्यों है — सुनने वाले को semantics से पता चल जाता
  /// था, पर देखने वाले को सिर्फ़ एक फीका बटन दिखता था।
  static const pehleChuniye = 'पहले ऊपर से राशि चुनिए।';

  static const vistaar = 'यह राशि कहाँ लगती है';

  static const dhanyavaad = 'आपकी दक्षिणा मिल गई। इसी से अगली पूजा जुड़ेगी।';

  /// दुकान ही नहीं खुली। दोष यूज़र पर नहीं डालना।
  static const dukaanBand = 'अभी Play से बात नहीं हो पा रही। बाद में कभी।';

  static const kuchhAtka = 'कुछ अटक गया। दोबारा कोशिश कर सकते हैं।';
}

/// राशि चुनने और देने वाला हिस्सा — डिब्बे और पूरे पन्ने, दोनों में यही।
class DakshinaChunav extends StatefulWidget {
  /// दक्षिणा मिलने पर — डिब्बा/पन्ना अपने आप धन्यवाद में बदल जाता है,
  /// यह सिर्फ़ ऊपर वाले को ख़बर करने के लिए है।
  final VoidCallback? onMili;

  const DakshinaChunav({super.key, this.onMili});

  @override
  State<DakshinaChunav> createState() => _DakshinaChunavState();
}

class _DakshinaChunavState extends State<DakshinaChunav> {
  /// ── ₹51 पहले से चुनी रहती है (→ D-063) ────────────────
  ///
  /// ⚠ यह D-053 से पलटा हुआ है। वहाँ लिखा था कि कोई राशि पहले
  /// से चुनी हुई न हो, क्योंकि "यूज़र ने चुना ही नहीं होता"।
  /// डेवलपर ने जोख़िम जानते हुए यह बदलवाया (9 सित 2026)।
  ///
  /// ⛔ पर एक बात नहीं बदली, और नहीं बदलनी चाहिए — **पैसा बटन
  /// दबाए बिना कभी नहीं कटता।** चुनी हुई राशि सिर्फ़ एक सुझाव है।
  DakshinaRaashi? _chuni = pehleSeChuniRaashi;

  bool _chalRahiHai = false;
  bool _mili = false;
  String? _gadbad;

  Future<void> _do() async {
    final raashi = _chuni;
    if (raashi == null || _chalRahiHai) return;
    setState(() {
      _chalRahiHai = true;
      _gadbad = null;
    });

    final natija = await dakshina.dena(raashi);
    if (!mounted) return;

    setState(() {
      _chalRahiHai = false;
      switch (natija) {
        case DakshinaNatija.mili:
          _mili = true;
        // यूज़र ने बीच में छोड़ा — **कुछ मत कहो।** यह उसका पूरा हक़ है,
        // और यहाँ एक भी शब्द ताना बन जाता है।
        case DakshinaNatija.radd:
          break;
        case DakshinaNatija.upalabdhNahi:
          _gadbad = DakshinaShabd.dukaanBand;
        case DakshinaNatija.truti:
          _gadbad = DakshinaShabd.kuchhAtka;
      }
    });

    if (natija == DakshinaNatija.mili) widget.onMili?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);

    if (_mili) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ऐप का अपना दीया, emoji नहीं (→ D-047)।
          VidhivatDiyaIcon(bhara: true, color: colors.primary),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Text(
              DakshinaShabd.dhanyavaad,
              key: const Key('dakshina_dhanyavaad'),
              style: type.bodyMedium,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: VidhivatSpacing.sm,
          runSpacing: VidhivatSpacing.sm,
          children: [
            for (final raashi in dakshinaRaashiyan)
              _RaashiChip(
                raashi: raashi,
                chuni: _chuni == raashi,
                onTap: _chalRahiHai
                    ? null
                    : () => setState(() => _chuni = raashi),
              ),
          ],
        ),
        const SizedBox(height: VidhivatSpacing.md),
        VidhivatButton(
          label: DakshinaShabd.bataan,
          semanticLabel: _chuni == null
              ? 'दक्षिणा दें — पहले राशि चुनिए'
              : '${_chuni!.label} की दक्षिणा दें',
          // राशि चुने बिना बटन नहीं चलता — ताकि ग़लती से कुछ न कट जाए।
          onPressed: _chuni == null ? null : _do,
          isLoading: _chalRahiHai,
          fullWidth: true,
        ),
        // बटन फीका क्यों है, यह दिखना भी चाहिए — semantics में पहले
        // से था, पर आँख से देखने वाले को सिर्फ़ बंद बटन दिखता था।
        if (_chuni == null && _gadbad == null) ...[
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            DakshinaShabd.pehleChuniye,
            key: const Key('dakshina_pehle_chuniye'),
            style: type.caption.copyWith(color: colors.textSecondary),
          ),
        ],
        if (_gadbad != null) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          Text(
            _gadbad!,
            key: const Key('dakshina_gadbad'),
            style: type.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _RaashiChip extends StatelessWidget {
  final DakshinaRaashi raashi;
  final bool chuni;
  final VoidCallback? onTap;

  const _RaashiChip({
    required this.raashi,
    required this.chuni,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.selectable,
      selected: chuni,
      onTap: onTap,
      semanticLabel: '${raashi.label} की दक्षिणा',
      padding: const EdgeInsets.symmetric(
        horizontal: VidhivatSpacing.lg,
        vertical: VidhivatSpacing.sm,
      ),
      // ⚠ ऊँचाई ख़ुद बाँधनी पड़ती है। सिर्फ़ padding से चिप 44 dp के
      // आस-पास रह जाती थी — यहाँ ज़रा सी चूक से पैसे वाला काम रुक
      // जाता है, इसलिए पूरी उँगली भर जगह दी जाती है।
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: VidhivatActionSize.minimumTouchTarget,
          minWidth: VidhivatActionSize.minimumTouchTarget,
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            raashi.label,
            style: type.cardTitle.copyWith(
              color: chuni ? colors.primary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// पूजा पूरी होने वाले पन्ने पर बैठने वाला शांत डिब्बा।
///
/// ⛔ **यह डिब्बा सिर्फ़ वहीं जहाँ पूजा पूरी हो चुकी हो।** विधि प्लेयर,
/// पाठ, संकल्प, होम और notification में कभी नहीं (→ D-008, D-053) —
/// आदमी संकल्प लेकर बैठा है, वहाँ पैसा माँगना विज्ञापन से भी बुरा है।
/// `dakshina_test.dart` इसका पहरा देता है।
class DakshinaCard extends StatefulWidget {
  /// "यह राशि कहाँ लगती है" दबाने पर। न दो तो वह पंक्ति नहीं दिखती।
  final VoidCallback? onVistaar;

  const DakshinaCard({super.key, this.onVistaar});

  @override
  State<DakshinaCard> createState() => _DakshinaCardState();
}

class _DakshinaCardState extends State<DakshinaCard> {
  @override
  void initState() {
    super.initState();
    // दिखना ही वो चीज़ है जिसकी हद बाँधनी है। तीन बार के बाद तीस दिन
    // चुप्पी — यह गिनती वहीं से चलती है।
    dakshina.dikhaayiGayi(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Column(
      key: const Key('dakshina_card'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VidhivatSectionHeader(title: DakshinaShabd.upsheershak),
        const SizedBox(height: VidhivatSpacing.md),
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.elevated,
          padding: const EdgeInsets.all(VidhivatSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DakshinaShabd.shirshak, style: type.cardTitle),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(DakshinaShabd.hisaab, style: type.bodySmall),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(DakshinaShabd.nyota, style: type.bodyMedium),
              const SizedBox(height: VidhivatSpacing.lg),
              const DakshinaChunav(),
              const SizedBox(height: VidhivatSpacing.md),
              Text(
                DakshinaShabd.vaikalpik,
                style: type.caption.copyWith(color: colors.textSecondary),
              ),
              if (widget.onVistaar != null) ...[
                const SizedBox(height: VidhivatSpacing.xs),
                // ⚠️ `fullWidth` यहाँ सजावट नहीं, ज़रूरत है। design system
                // का बटन सिर्फ़ इसी हाल में label को `Flexible` में रखता
                // है; बिना इसके 320 dp और 1.5x अक्षरों पर यह पंक्ति
                // **दायीं तरफ़ 60 pixel बाहर निकल जाती थी**।
                VidhivatButton(
                  label: DakshinaShabd.vistaar,
                  variant: VidhivatButtonVariant.text,
                  onPressed: widget.onVistaar,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
