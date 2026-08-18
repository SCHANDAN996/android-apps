import 'package:flutter/material.dart';

import '../../data/palan/palan_common.dart';
import '../../data/palan/palan_data.dart';
import '../../data/palan/palan_i18n.dart' show kMachineTxWarning;
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';

/// एक पालन की पूरी जानकारी — 7 खंड, सब ऑफ़लाइन।
class PalanDetailScreen extends StatelessWidget {
  final PalanGuide guide;
  const PalanDetailScreen({super.key, required this.guide});

  /// notification के लिए इस पालन का तयशुदा खाना (slot)
  int get _slot {
    final i = kPalanGuides.indexWhere((g) => g.id == guide.id);
    return i < 0 ? 0 : i;
  }

  /// 🔔 टीके का रिमाइंडर — "बच्चे कब आए?" पूछकर सारी तारीख़ें लगा दो।
  ///
  /// तारीख़ें guide की `reminderPlan` से आती हैं (कितने दिन बाद कौन सा टीका)।
  /// दोबारा लगाने पर पुराने रिमाइंडर पहले हट जाते हैं, इसलिए दुगने
  /// notification कभी नहीं आते।
  Future<void> _setReminders(BuildContext context, bool isHi) async {
    // चुनी हुई भाषा का कोड — tx() इसी से अनुवाद की परत देखता है
    final lang = AppLocalizations.langCode(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: AppLocalizations.get(context, 'vaccineReminderAsk'),
    );
    if (picked == null || !context.mounted) return;

    final n = await NotificationService.instance.schedulePalanVaccines(
      slot: _slot,
      palanName: tx(guide.name, isHi, lang),
      startDate: picked,
      plan: [
        for (final r in guide.reminderPlan)
          (day: r.day, what: tx(r.what, isHi, lang))
      ],
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.get(context, 'vaccineReminderSet')
          .replaceFirst('{n}', '$n')),
      backgroundColor: Colors.green.shade700,
    ));
  }

  Future<void> _cancelReminders(BuildContext context) async {
    await NotificationService.instance.cancelPalanVaccines(_slot);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.get(context, 'vaccineReminderOff')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    // चुनी हुई भाषा का कोड — tx() इसी से अनुवाद की परत देखता है
    final lang = AppLocalizations.langCode(context);
    String t(String k) => AppLocalizations.get(context, k);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: guide.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, right: 16, bottom: 14),
              title: Text(
                tx(guide.name, isHi, lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [guide.color, guide.color.withValues(alpha: 0.72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0.82, -0.1),
                  child: Builder(
                    builder: (_) {
                      final imgPath = switch (guide.id) {
                        'bakri' => 'assets/images/3d_goat.webp',
                        'bhed' || 'sheep' => 'assets/images/3d_sheep.webp',
                        'layer' => 'assets/images/3d_egg.webp',
                        'broiler' => 'assets/images/3d_broiler.webp',
                        'kadaknath' => 'assets/images/3d_kadaknath.webp',
                        'quail' => 'assets/images/3d_quail.webp',
                        'batakh' || 'duck' => 'assets/images/3d_duck.webp',
                        'turkey' => 'assets/images/3d_turkey.webp',
                        'emu' => 'assets/images/3d_emu.webp',
                        'pig' || 'suar' => 'assets/images/3d_pig.webp',
                        'rabbit' => 'assets/images/3d_rabbit.webp',
                        'beekeeping' || 'bee' => 'assets/images/3d_beekeeping.webp',
                        'machhli' || 'fish' => 'assets/images/3d_fish.webp',
                        'gaay' => 'assets/images/3d_cow_profile.webp',
                        'bhains' => 'assets/images/3d_buffalo_profile.webp',
                        _ => null,
                      };
                      if (imgPath != null) {
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            imgPath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(guide.emoji,
                                style: const TextStyle(fontSize: 78)),
                          ),
                        );
                      }
                      return Text(guide.emoji,
                          style: const TextStyle(fontSize: 78));
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ⚠️ मशीन के अनुवाद की चेतावनी।
                //
                // इस पन्ने की गहरी जानकारी (नस्ल, दाना, टीका, बीमारी) हिंदी और
                // अंग्रेज़ी में लिखी गई थी। बाक़ी आठ भाषाओं में वह **मशीन ने**
                // अनुवाद की है — किसी पशु-चिकित्सक ने नहीं जाँची।
                //
                // टीके का नाम या खुराक का एक शब्द भी इधर-उधर हो जाए तो किसान
                // का जानवर जा सकता है। इसलिए उसी भाषा में, सबसे ऊपर, साफ़ लिखा
                // रहता है कि दवा-टीके की बात पशु-चिकित्सक या KVK से पक्की कर
                // लें। हिंदी/अंग्रेज़ी मूल हैं, वहाँ यह पट्टी नहीं दिखती।
                if (kMachineTxWarning[lang] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700, width: 1),
                    ),
                    child: Text(
                      kMachineTxWarning[lang]!,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade900),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // tagline
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: guide.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tx(guide.tagline, isHi, lang),
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: guide.color),
                  ),
                ),
                const SizedBox(height: 14),

                // 1. परिचय
                _section(context, '📖', t('palanIntro'),
                    child: Text(tx(guide.intro, isHi, lang),
                        style: const TextStyle(fontSize: 14, height: 1.55))),

                // नस्लें
                _section(context, '🧬', t('palanBreeds'),
                    child: _bullets(guide.breeds, isHi, lang, guide.color)),

                // 2. आवास
                _section(context, '🏠', t('palanHousing'),
                    child: _bullets(guide.housing, isHi, lang, guide.color)),

                // 3. चारा
                _section(context, '🌾', t('palanFeed'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _feedTable(context, isHi),
                        if (guide.feedNotes.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _bullets(guide.feedNotes, isHi, lang, guide.color),
                        ],
                      ],
                    )),

                // 4. उत्पादन
                _section(context, '📈', t('palanProduction'),
                    child: _bullets(guide.production, isHi, lang, guide.color)),

                // 5. टीका + बीमारी
                _section(context, '💉', t('palanVaccine'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _vaccineTable(context, isHi),
                        const SizedBox(height: 12),
                        Text('🩺 ${t('palanDisease')}',
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        _bullets(guide.diseases, isHi, lang, Colors.red.shade700),
                        if (guide.reminderPlan.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: guide.color,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.notifications_active_rounded,
                                size: 20, color: Colors.white),
                            label: Text(
                              AppLocalizations.get(context, 'vaccineReminderBtn')
                                  .replaceAll('🔔 ', ''),
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _setReminders(context, isHi),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.notifications_off_rounded,
                                size: 18),
                            label: Text(
                                AppLocalizations.get(context, 'removeReminder')),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700),
                            onPressed: () => _cancelReminders(context),
                          ),
                          // टीके की तारीख़ें — पहले से दिख जाएँ
                          _reminderPreview(context, isHi),
                        ],
                        const SizedBox(height: 10),
                        _vetNote(context),
                      ],
                    )),

                // 6. लागत-मुनाफ़ा
                _section(context, '💰', t('palanEconomics'),
                    child: _economics(context, isHi)),

                // 7. बिक्री
                _section(context, '🏪', t('palanSelling'),
                    child: _bullets(guide.selling, isHi, lang, guide.color)),

                // 8. सरकारी मदद — पहले ऐप में इसका एक शब्द भी नहीं था।
                // किसान के पास पूँजी नहीं होती; यही जानकारी उसे शुरू करवा
                // सकती है, इसलिए बिक्री के तुरंत बाद रखी है।
                _section(context, '🏛️', isHi ? 'सरकारी मदद' : 'Government support',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bullets([...guide.schemes, ...kCommonSchemes], isHi,
                            lang, Colors.blue.shade700),
                        const SizedBox(height: 8),
                        _stampNote(
                          isHi
                              ? '⭑ यह जानकारी $kSchemeAsOf तक की है। योजनाओं की शर्तें और रकम बदलती रहती हैं — अपने ब्लॉक कार्यालय या बैंक से पुष्टि ज़रूर कीजिए।'
                              : '⭑ Information as of $kSchemeAsOf. Scheme terms and amounts change — always confirm with your block office or bank.',
                        ),
                      ],
                    )),

                // 9. कहाँ से ख़रीदें — सबसे ज़्यादा ठगी यहीं होती है
                _section(context, '🛒', isHi ? 'कहाँ से ख़रीदें' : 'Where to buy',
                    child: _bullets(
                        [...guide.whereToBuy, ...kCommonWhereToBuy], isHi, lang, Colors.teal)),

                // 10. आम ग़लतियाँ — नया पालक वही 5-6 ग़लतियाँ दोहराता है
                _section(context, '⚠️',
                    isHi ? 'ये ग़लतियाँ मत कीजिए' : 'Do not make these mistakes',
                    child: _bullets([...guide.mistakes, ...kCommonMistakes], isHi,
                        lang, Colors.red.shade600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String emoji, String title,
      {required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _bullets(List<L> items, bool isHi, String lang, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Text(tx(item, isHi, lang),
                        style: const TextStyle(fontSize: 13.5, height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _feedTable(BuildContext context, bool isHi) {
    // चुनी हुई भाषा का कोड — tx() इसी से अनुवाद की परत देखता है
    final lang = AppLocalizations.langCode(context);
    String t(String k) => AppLocalizations.get(context, k);
    const border = BorderSide(color: Color(0xFFDDDDDD));
    return Table(
      border: const TableBorder(
          horizontalInside: border, top: border, bottom: border),
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: guide.color.withValues(alpha: 0.1)),
          children: [
            _cell(t('palanFeedStage'), bold: true),
            _cell(t('palanFeedWhat'), bold: true),
            _cell(t('palanFeedQty'), bold: true),
          ],
        ),
        for (final f in guide.feed)
          TableRow(children: [
            _cell(tx(f.stage, isHi, lang), bold: true),
            _cell(tx(f.feed, isHi, lang)),
            _cell(tx(f.qty, isHi, lang)),
          ]),
      ],
    );
  }

  Widget _vaccineTable(BuildContext context, bool isHi) {
    // चुनी हुई भाषा का कोड — tx() इसी से अनुवाद की परत देखता है
    final lang = AppLocalizations.langCode(context);
    String t(String k) => AppLocalizations.get(context, k);
    const border = BorderSide(color: Color(0xFFDDDDDD));
    return Table(
      border: const TableBorder(
          horizontalInside: border, top: border, bottom: border),
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.6)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: guide.color.withValues(alpha: 0.1)),
          children: [
            _cell(t('palanVaccineWhen'), bold: true),
            _cell(t('palanVaccineWhat'), bold: true),
          ],
        ),
        for (final v in guide.vaccines)
          TableRow(children: [
            _cell(tx(v.when, isHi, lang), bold: true),
            _cell(tx(v.what, isHi, lang)),
          ]),
      ],
    );
  }

  Widget _cell(String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Text(text,
            style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      );

  /// टीके किस दिन पड़ेंगे — बटन दबाने से पहले ही दिख जाए
  Widget _reminderPreview(BuildContext context, bool isHi) {
    final lang = AppLocalizations.langCode(context);
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final r in guide.reminderPlan)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 62,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: guide.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${r.day} ${AppLocalizations.get(context, 'days')}',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: guide.color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tx(r.what, isHi, lang),
                          style:
                              const TextStyle(fontSize: 12, height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
  }

  Widget _vetNote(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.get(context, 'vetDisclaimer'),
                style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      );

  Widget _economics(BuildContext context, bool isHi) {
    // चुनी हुई भाषा का कोड — tx() इसी से अनुवाद की परत देखता है
    final lang = AppLocalizations.langCode(context);
    // ⚠️ पहले यहाँ सारे ख़र्च (शेड, पिंजरा, जानवर ख़रीदना — जो एक ही बार लगते
    // हैं) एक चक्र की आमदनी में से घटा दिए जाते थे। नतीजा: बकरी, ब्रॉयलर,
    // भेड़, बटेर और एमू की गाइड में बड़े लाल अक्षरों में **घाटा** दिखता था,
    // जबकि असल में इन सबमें मुनाफ़ा है। किसान उसी धंधे से पीछे हट जाता जो
    // उसके लिए सबसे सुरक्षित था।
    //
    // अब तीन अलग संख्याएँ: शुरुआती तैयारी · हर चक्र का हिसाब · लागत कब निकलेगी
    final setup = guide.setupCost;
    final cycleCost = guide.cycleCost;
    final cycleIncome = guide.cycleIncome;
    final profit = guide.cycleProfit;
    final payback = guide.paybackMonths;
    final cyclesYr = guide.cyclesPerYear;
    final oneCycleAYear = (cyclesYr - 1).abs() < 0.05;

    String inr(int v) {
      final s = v.abs().toString();
      // भारतीय अंक-प्रणाली: आख़िरी 3, फिर 2-2
      if (s.length <= 3) return '${v < 0 ? '-' : ''}₹$s';
      final last3 = s.substring(s.length - 3);
      var rest = s.substring(0, s.length - 3);
      final buf = StringBuffer();
      while (rest.length > 2) {
        buf.write(',${rest.substring(rest.length - 2)}');
        rest = rest.substring(0, rest.length - 2);
      }
      final parts = buf.toString().split(',')..removeWhere((e) => e.isEmpty);
      return '${v < 0 ? '-' : ''}₹$rest${parts.isEmpty ? '' : ',${parts.reversed.join(',')}'},$last3';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: guide.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('📦 ${tx(guide.economicsUnit, isHi, lang)}',
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 14),

        // ── 1. शुरुआती तैयारी — एक ही बार ────────────────────────────
        Text(
          isHi ? '🏗️ शुरू करने का ख़र्च (एक ही बार)' : '🏗️ Setup cost (one time only)',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue.shade800),
        ),
        const SizedBox(height: 4),
        for (final c in guide.costs.where((c) => c.oneTime))
          _moneyRow(tx(c.item, isHi, lang), c.value),
        _totalRow(isHi ? 'कुल तैयारी' : 'Total setup', inr(setup), Colors.blue.shade800),

        const Divider(height: 20),

        // ── 2. हर चक्र का हिसाब ──────────────────────────────────────
        Text(
          isHi
              ? (oneCycleAYear ? '🔄 हर साल का हिसाब' : '🔄 हर चक्र का हिसाब')
              : (oneCycleAYear ? '🔄 Every year' : '🔄 Every cycle'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        for (final c in guide.costs.where((c) => !c.oneTime))
          _moneyRow('🔻 ${tx(c.item, isHi, lang)}', c.value),
        for (final c in guide.income)
          _moneyRow('🔺 ${tx(c.item, isHi, lang)}', c.value),
        _totalRow(isHi ? 'ख़र्च' : 'Cost', inr(cycleCost), Colors.orange.shade800),
        _totalRow(isHi ? 'आमदनी' : 'Income', inr(cycleIncome), Colors.green.shade800),

        const SizedBox(height: 12),

        // ── 3. असली मुनाफ़ा ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: profit > 0
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isHi
                          ? (oneCycleAYear ? '💵 हर साल का मुनाफ़ा' : '💵 हर चक्र का मुनाफ़ा')
                          : (oneCycleAYear ? '💵 Profit per year' : '💵 Profit per cycle'),
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    inr(profit),
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: profit > 0 ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
              if (!oneCycleAYear && profit > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isHi
                            ? 'साल में ${_cycles(cyclesYr)} चक्र → साल भर में'
                            : '${_cycles(cyclesYr)} cycles a year → per year',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ),
                    Text(
                      inr(guide.yearlyProfit),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade900),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ── 4. लागत कब निकलेगी — किसान का सबसे पहला सवाल ─────────────
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHi ? 'तैयारी का ख़र्च निकलने में' : 'Setup cost recovers in',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                payback == null
                    ? (isHi ? 'नहीं निकलेगा' : 'never')
                    : _period(payback, isHi),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: payback == null ? Colors.red.shade800 : Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        Text(tx(guide.economicsNote, isHi, lang),
            style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic)),

        // ── दाम कब के हैं ────────────────────────────────────────────
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: Colors.grey, width: 3)),
          ),
          child: Text(
            isHi
                ? '⭑ ये दाम ${guide.priceAsOf} के अनुमान हैं। इलाक़े, नस्ल और बाज़ार से बदलते हैं — शुरू करने से पहले अपने यहाँ के दाम पता कीजिए।'
                : '⭑ Prices are estimates as of ${guide.priceAsOf}. They vary by region, breed and market — check local rates before starting.',
            style: TextStyle(fontSize: 11, height: 1.4, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  /// "8" या "1.5" — जो भी ठीक पढ़ा जाए
  static String _cycles(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  /// महीनों को "1 साल 9 महीने" जैसी बात में बदलता है
  static String _period(double months, bool isHi) {
    final m = months.round();
    if (m < 12) return isHi ? '$m महीने' : '$m months';
    final y = m ~/ 12;
    final rem = m % 12;
    if (isHi) {
      return rem == 0 ? '$y साल' : '$y साल $rem महीने';
    }
    return rem == 0 ? '$y year${y > 1 ? 's' : ''}' : '$y y $rem m';
  }

  /// छोटी धूसर पट्टी — "यह जानकारी कब तक की है"
  Widget _stampNote(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: const Border(left: BorderSide(color: Colors.grey, width: 3)),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 11, height: 1.4, color: Colors.grey.shade700)),
      );

  Widget _totalRow(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800, color: color)),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      );

  Widget _moneyRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            const SizedBox(width: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
