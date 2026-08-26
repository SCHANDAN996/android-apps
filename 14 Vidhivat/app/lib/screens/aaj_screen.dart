import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// आज का पंचांग — ऐप का मुख्य पन्ना, जो रोज़ खुलेगा।
class AajScreen extends StatefulWidget {
  const AajScreen({super.key});

  @override
  State<AajScreen> createState() => _AajScreenState();
}

class _AajScreenState extends State<AajScreen> {
  static const _maxFestivalCacheEntries = 8;
  DateTime _day = DateTime.now();
  final Map<String, List<FestivalDate>> _festivalCache = {};

  void _shift(int days) =>
      setState(() => _day = _day.add(Duration(days: days)));

  bool get _isToday {
    final now = DateTime.now();
    return _day.year == now.year &&
        _day.month == now.month &&
        _day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final p = settings.panchangFor(_day);
    final theme = Theme.of(context);
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final festivalKey = '${_day.year}|${settings.city.cacheKey}';
    var yearFestivals = _festivalCache[festivalKey];
    if (yearFestivals == null) {
      if (_festivalCache.length >= _maxFestivalCacheEntries) {
        _festivalCache.remove(_festivalCache.keys.first);
      }
      yearFestivals = _festivalCache[festivalKey] =
          festivalsInYear(_day.year, settings.place);
    }
    final festivals = yearFestivals
        .where(
          (festival) =>
              _sameDate(festival.date, _day) ||
              (festival.ambiguous &&
                  festival.otherCandidate != null &&
                  _sameDate(festival.otherCandidate!, _day)),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isToday ? 'आज' : tarikhChhoti(_day)),
        actions: [
          VidhivatIconAction(
            onPressed: () => _shift(-1),
            icon: Icons.chevron_left,
            tooltip: 'पिछला दिन',
          ),
          if (!_isToday)
            TextButton(
              onPressed: () => setState(() => _day = DateTime.now()),
              child: const Text('आज'),
            ),
          VidhivatIconAction(
            onPressed: () => _shift(1),
            icon: Icons.chevron_right,
            tooltip: 'अगला दिन',
          ),
        ],
      ),
      body: VidhivatSacredBackdrop(
        child: Panna(
          children: [
            _Sirlekh(p: p, day: _day),
            const SizedBox(height: VidhivatSpacing.xl),

            if (p.kshayaTithiName != null)
              Chetavni(
                  'क्षय तिथि — ${p.kshayaTithiName} किसी सूर्योदय को नहीं छूती'),
            if (p.isVriddhiTithi)
              Chetavni('वृद्धि तिथि — ${p.tithi.name} कल भी रहेगी'),

            // ── पंचांग के पाँच अंग ──
            const VidhivatSectionHeader(
              title: 'आज का पंचांग',
              supportingText: 'सूर्योदय के समय और दिन भर के बदलाव',
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ..._angaPanktiyan('तिथि', p.tithis, _day),
                  const VidhivatDivider(),
                  ..._angaPanktiyan('नक्षत्र', p.nakshatras, _day),
                  const VidhivatDivider(),
                  ..._angaPanktiyan('योग', p.yogas, _day),
                  const VidhivatDivider(),
                  ..._angaPanktiyan('करण', p.karanas, _day),
                  const VidhivatDivider(),
                  Pankti('वार', p.varaName),
                ],
              ),
            ),

            // ── सूर्य और चंद्र ──
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(title: 'सूर्य और चंद्र'),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Pankti('सूर्योदय', hms(p.sunrise), bold: true),
                  Pankti('सूर्यास्त', hms(p.sunset)),
                  Pankti('दिनमान', _avadhi(p.dinamana)),
                  Pankti('रात्रिमान', _avadhi(p.ratrimana)),
                  const VidhivatDivider(),
                  Pankti(
                    'चंद्रोदय',
                    hms(p.moonrise) + dinKaNishan(p.moonrise, _day),
                    note: p.moonrise == null ? 'आज चंद्रोदय नहीं पड़ता' : null,
                  ),
                  Pankti(
                    'चंद्रास्त',
                    hms(p.moonset) + dinKaNishan(p.moonset, _day),
                    note: p.moonset == null ? 'आज चंद्रास्त नहीं पड़ता' : null,
                  ),
                ],
              ),
            ),

            // ── शुभ और अशुभ काल ──
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(title: 'आज के काल'),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              variant: VidhivatCardVariant.highlight,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (p.abhijit != null)
                    Pankti(
                      'अभिजित',
                      '${hm(p.abhijit!.start)} – ${hm(p.abhijit!.end)}',
                      note: 'दिन का सबसे शुभ मुहूर्त',
                      valueColour: colors.success,
                      bold: true,
                    ),
                  const VidhivatDivider(),
                  if (p.rahuKaal != null)
                    Pankti('राहुकाल',
                        '${hm(p.rahuKaal!.start)} – ${hm(p.rahuKaal!.end)}',
                        valueColour: colors.secondary),
                  if (p.yamaganda != null)
                    Pankti('यमगंड',
                        '${hm(p.yamaganda!.start)} – ${hm(p.yamaganda!.end)}',
                        valueColour: colors.secondary),
                  if (p.gulika != null)
                    Pankti('गुलिक',
                        '${hm(p.gulika!.start)} – ${hm(p.gulika!.end)}',
                        valueColour: colors.secondary),
                  if (p.bhadra != null)
                    Pankti(
                      'भद्रा',
                      '${hm(p.bhadra!.start)}${dinKaNishan(p.bhadra!.start, _day)}'
                          ' – ${hm(p.bhadra!.end)}${dinKaNishan(p.bhadra!.end, _day)}',
                      note: 'इसमें शुभ काम नहीं होते',
                      valueColour: colors.secondary,
                    ),
                ],
              ),
            ),

            if (festivals.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'आज के त्योहार / व्रत'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final festival in festivals)
                      ListTile(
                        title: Text(festival.rule.name),
                        subtitle: festival.ambiguous
                            ? const Text('दो संभावित तारीख़ों में यह दिन भी है')
                            : null,
                      ),
                  ],
                ),
              ),
            ],

            // ── राशि और विशेष ──
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(title: 'अन्य जानकारी'),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Pankti('सूर्य राशि', p.sunRashiName),
                  Pankti('चंद्र राशि', p.moonRashiName),
                  if (p.isPanchak || p.isGandmool)
                    Pankti(
                      'विशेष',
                      [
                        if (p.isPanchak) 'पंचक',
                        if (p.isGandmool) 'गंडमूल',
                      ].join(' · '),
                      valueColour: colors.secondary,
                    ),
                  Pankti('अयनांश', toDms(p.ayanamsa)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'दृक् गणित · लाहिड़ी अयनांश · '
                '${p.masaSystem == MasaSystem.purnimanta ? "पूर्णिमांत" : "अमांत"} पद्धति'
                '\n${settings.city.name}',
                style: type.bodySmall.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// एक अंग की सारी पंक्तियाँ — दिन में जितनी बार बदला।
  List<Widget> _angaPanktiyan(String label, List<Anga> angas, DateTime day) {
    return [
      for (var i = 0; i < angas.length; i++)
        Pankti(
          i == 0 ? label : '',
          angas[i].name,
          note: 'तक ${hm(angas[i].endsAt)}${dinKaNishan(angas[i].endsAt, day)}',
          bold: i == 0,
        ),
    ];
  }

  String _avadhi(Duration? d) =>
      d == null ? '—' : '${d.inHours} घंटे ${d.inMinutes % 60} मिनट';
}

/// ऊपर का शीर्ष — वार, मास, पक्ष, संवत्।
class _Sirlekh extends StatelessWidget {
  final Panchang p;
  final DateTime day;

  const _Sirlekh({required this.p, required this.day});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);

    return VidhivatSacredHero(
      eyebrow: tarikh(day),
      title: '${p.varaName} · ${p.tithi.name}',
      subtitle: '${p.masaFullName} ${p.pakshaName} पक्ष',
      icon: Icons.wb_sunny_outlined,
      semanticLabel:
          '${tarikh(day)}, ${p.varaName}, ${p.pakshaName} ${p.tithi.name}, ${p.masaFullName}',
      footer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (p.isAdhikaMasa)
          Padding(
            padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
            child: Text(
              'पुरुषोत्तम मास — इसमें मांगलिक काम नहीं होते',
              style: type.bodySmall.copyWith(color: colors.secondary),
            ),
          ),
        Text(
          'विक्रम संवत् ${p.vikramSamvat} ${p.vikramSamvatsara}   ·   '
          'शक संवत् ${p.shakaSamvat} ${p.shakaSamvatsara}',
          style: type.bodySmall,
        ),
        Text(
          '${p.ayanaName} · ${p.rituName} ऋतु · ${p.nakshatra.name} नक्षत्र',
          style: type.bodySmall,
        ),
      ]),
    );
  }
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
