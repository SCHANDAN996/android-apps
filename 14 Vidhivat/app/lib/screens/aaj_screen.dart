import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// आज का पंचांग — ऐप का मुख्य पन्ना, जो रोज़ खुलेगा।
class AajScreen extends StatefulWidget {
  const AajScreen({super.key});

  @override
  State<AajScreen> createState() => _AajScreenState();
}

class _AajScreenState extends State<AajScreen> {
  DateTime _day = DateTime.now();

  void _shift(int days) =>
      setState(() => _day = _day.add(Duration(days: days)));

  bool get _isToday {
    final now = DateTime.now();
    return _day.year == now.year && _day.month == now.month && _day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final p = settings.panchangFor(_day);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isToday ? 'आज' : tarikhChhoti(_day)),
        actions: [
          IconButton(
            onPressed: () => _shift(-1),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'पिछला दिन',
          ),
          if (!_isToday)
            TextButton(
              onPressed: () => setState(() => _day = DateTime.now()),
              child: const Text('आज'),
            ),
          IconButton(
            onPressed: () => _shift(1),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'अगला दिन',
          ),
        ],
      ),
      body: Panna(
        children: [
          _Sirlekh(p: p, day: _day),
          const SizedBox(height: 20),

          if (p.kshayaTithiName != null)
            Chetavni('क्षय तिथि — ${p.kshayaTithiName} किसी सूर्योदय को नहीं छूती'),
          if (p.isVriddhiTithi)
            Chetavni('वृद्धि तिथि — ${p.tithi.name} कल भी रहेगी'),

          // ── पंचांग के पाँच अंग ──
          Khand(
            title: 'पंचांग',
            subtitle: 'सूर्योदय के समय का, और दिन भर कब-कब बदला',
            child: Column(
              children: [
                ..._angaPanktiyan('तिथि', p.tithis, _day),
                const Divider(),
                ..._angaPanktiyan('नक्षत्र', p.nakshatras, _day),
                const Divider(),
                ..._angaPanktiyan('योग', p.yogas, _day),
                const Divider(),
                ..._angaPanktiyan('करण', p.karanas, _day),
                const Divider(),
                Pankti('वार', p.varaName),
              ],
            ),
          ),

          // ── सूर्य और चंद्र ──
          Khand(
            title: 'सूर्य और चंद्र',
            child: Column(
              children: [
                Pankti('सूर्योदय', hms(p.sunrise), bold: true),
                Pankti('सूर्यास्त', hms(p.sunset)),
                Pankti('दिनमान', _avadhi(p.dinamana)),
                Pankti('रात्रिमान', _avadhi(p.ratrimana)),
                const Divider(),
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
          Khand(
            title: 'काल',
            child: Column(
              children: [
                if (p.abhijit != null)
                  Pankti(
                    'अभिजित',
                    '${hm(p.abhijit!.start)} – ${hm(p.abhijit!.end)}',
                    note: 'दिन का सबसे शुभ मुहूर्त',
                    valueColour: VidhivatTheme.tulsi,
                    bold: true,
                  ),
                const Divider(),
                if (p.rahuKaal != null)
                  Pankti('राहुकाल',
                      '${hm(p.rahuKaal!.start)} – ${hm(p.rahuKaal!.end)}',
                      valueColour: theme.colorScheme.secondary),
                if (p.yamaganda != null)
                  Pankti('यमगंड',
                      '${hm(p.yamaganda!.start)} – ${hm(p.yamaganda!.end)}',
                      valueColour: theme.colorScheme.secondary),
                if (p.gulika != null)
                  Pankti('गुलिक',
                      '${hm(p.gulika!.start)} – ${hm(p.gulika!.end)}',
                      valueColour: theme.colorScheme.secondary),
                if (p.bhadra != null)
                  Pankti(
                    'भद्रा',
                    '${hm(p.bhadra!.start)}${dinKaNishan(p.bhadra!.start, _day)}'
                        ' – ${hm(p.bhadra!.end)}${dinKaNishan(p.bhadra!.end, _day)}',
                    note: 'इसमें शुभ काम नहीं होते',
                    valueColour: theme.colorScheme.secondary,
                  ),
              ],
            ),
          ),

          // ── राशि और विशेष ──
          Khand(
            title: 'और',
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
                    valueColour: theme.colorScheme.secondary,
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
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

  String _avadhi(Duration? d) => d == null
      ? '—'
      : '${d.inHours} घंटे ${d.inMinutes % 60} मिनट';
}

/// ऊपर का शीर्ष — वार, मास, पक्ष, संवत्।
class _Sirlekh extends StatelessWidget {
  final Panchang p;
  final DateTime day;

  const _Sirlekh({required this.p, required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tarikh(day), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          '${p.varaName} · ${p.tithi.name}',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 6),
        Text(
          '${p.masaFullName} ${p.pakshaName} पक्ष',
          style: theme.textTheme.titleMedium?.copyWith(
            color: VidhivatTheme.haldi,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (p.isAdhikaMasa)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'पुरुषोत्तम मास — इसमें मांगलिक काम नहीं होते',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        const SizedBox(height: 10),
        Text(
          'विक्रम संवत् ${p.vikramSamvat} ${p.vikramSamvatsara}   ·   '
          'शक संवत् ${p.shakaSamvat} ${p.shakaSamvatsara}',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          '${p.ayanaName} · ${p.rituName} ऋतु · ${p.nakshatra.name} नक्षत्र',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
